package domain

import akka.actor.{ActorSystem, Props}
import akka.http.scaladsl.model.ws.Message
import akka.stream.scaladsl.Flow

class PokerRoom(roomId: Int, actorSystem: ActorSystem) {
  private[this] val chatRoomActor = actorSystem.actorOf(
    Props(classOf[PokerRoomActor], roomId)
  )

  def websocketFlow(user: String): Flow[Message, Message, _] = ???

  def sendMessage(message: PokerMessage): Unit = chatRoomActor ! message
}

object PokerRoom {
  def apply(roomId: Int)(implicit actorSystem: ActorSystem) = new PokerRoom(roomId, actorSystem)
}
