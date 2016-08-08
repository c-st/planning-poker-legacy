package domain

import akka.actor.{ActorRef, ActorSystem, Props}
import akka.http.scaladsl.model.ws.{Message, TextMessage}
import akka.stream.{FlowShape, OverflowStrategy}
import akka.stream.scaladsl.{Flow, GraphDSL, Merge, Sink, Source}

import scala.collection.immutable.Map
import scala.util.parsing.json.JSON
import com.owlike.genson.defaultGenson._

class PokerRoom(roomId: Int, actorSystem: ActorSystem) {
  private[this] val pokerRoomActor = actorSystem.actorOf(
    Props(classOf[PokerRoomActor], roomId)
  )

  def websocketFlow(user: String): Flow[Message, Message, _] = {
    val source = Source.actorRef[PokerEvent](1, OverflowStrategy.fail)

    Flow.fromGraph(GraphDSL.create(source) {
      implicit builder => { (responseSource) =>

        import GraphDSL.Implicits._

        // TextMessage -> PokerEvent
        val fromWebsocket = builder.add(
          Flow[Message].collect {
            case TextMessage.Strict(textContent) => mapToIncomingPokerEvent(user, textContent)
          })

        // PokerEvent -> TextMessage
        val backToWebsocket = builder.add(
          Flow[PokerEvent].map(mapToOutgoingTextMessage))

        val pokerRoomActorSink = Sink.actorRef[PokerEvent](pokerRoomActor, UserLeft(user))
        val merge = builder.add(Merge[PokerEvent](2))
        val actorConnected = Flow[ActorRef].map(UserJoined(user, _))

        builder.materializedValue ~> actorConnected ~> merge.in(1)
        fromWebsocket ~> merge.in(0)
        merge ~> pokerRoomActorSink

        responseSource ~> backToWebsocket

        FlowShape.of(fromWebsocket.in, backToWebsocket.out)
      }
    })
  }

  def sendMessage(message: PokerMessage): Unit = pokerRoomActor ! message

  private def mapToIncomingPokerEvent(user: String, textContent: String): PokerEvent = {
    val incomingMessage = JSON.parseFull(textContent) match {
      case Some(map: Map[_, Any]) => map.asInstanceOf[Map[String, Any]]
      case _ => Map("eventType" -> "unknown")
    }

    incomingMessage.get("eventType") match {
      case Some("startEstimation") => fromJson[RequestStartEstimation](textContent).copy(sender = user)
      case Some("estimate") => fromJson[UserEstimate](textContent).copy(userName = user)
      case Some("showResult") => fromJson[RequestShowEstimationResult](textContent).copy(sender = user)
      case _ => IncomingMessage(user, "unknown event: " + textContent)
    }
  }

  private def mapToOutgoingTextMessage(pokerEvent: PokerEvent): TextMessage = {
    pokerEvent match {
      case UserJoined(name, _, _) => TextMessage(toJson(pokerEvent.asInstanceOf[UserJoined]))
      case UserLeft(name, _) => TextMessage(toJson(pokerEvent.asInstanceOf[UserLeft]))
      case RequestStartEstimation(name, taskName, _) => TextMessage(toJson(pokerEvent.asInstanceOf[RequestStartEstimation]))
      case UserHasEstimated(name, taskName, _) => TextMessage(toJson(pokerEvent.asInstanceOf[UserHasEstimated]))
      case EstimationResult(taskName, estimates, _) => TextMessage(toJson(pokerEvent.asInstanceOf[EstimationResult]))
      case IncomingMessage(sender, message) => TextMessage(s"[$sender] $message")
      case _ => TextMessage(s"Unknown event")
    }
  }
}

object PokerRoom {
  def apply(roomId: Int)(implicit actorSystem: ActorSystem) = new PokerRoom(roomId, actorSystem)
}
