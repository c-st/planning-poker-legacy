package domain

import akka.actor.{ActorRef, ActorSystem, Props}
import akka.http.scaladsl.model.ws.{Message, TextMessage}
import akka.stream.{FlowShape, OverflowStrategy}
import akka.stream.scaladsl.{Flow, GraphDSL, Merge, Sink, Source}

class PokerRoom(roomId: Int, actorSystem: ActorSystem) {
  private[this] val pokerRoomActor = actorSystem.actorOf(
    Props(classOf[PokerRoomActor], roomId)
  )

  def websocketFlow(user: String): Flow[Message, Message, _] = {
    val source = Source.actorRef[PokerMessage](1, OverflowStrategy.fail)

    Flow.fromGraph(GraphDSL.create(source) {
      implicit builder => { (responseSource) =>

        import GraphDSL.Implicits._

        // flow used as input, it takes TextMessages
        val fromWebsocket = builder.add(
          Flow[Message].collect {
            case TextMessage.Strict(txt) => IncomingMessage(user, txt)
          })

        // flow used as output, it returns TextMessages
        val backToWebsocket = builder.add(
          Flow[PokerMessage].map {
            case PokerMessage(author, text) => TextMessage(s"[$author] $text")
          })

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
}

object PokerRoom {
  def apply(roomId: Int)(implicit actorSystem: ActorSystem) = new PokerRoom(roomId, actorSystem)
}
