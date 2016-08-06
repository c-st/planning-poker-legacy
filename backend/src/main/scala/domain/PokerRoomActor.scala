package domain

import akka.actor.{Actor, ActorRef}

class PokerRoomActor(roomId: Int) extends Actor {
  var participants: Map[String, ActorRef] = Map.empty[String, ActorRef]

  override def receive: Receive = {
    case UserJoined(name, actorRef) =>
      participants += name -> actorRef
      // broadcast all previous estimations to actorRef
      actorRef ! PokerMessage("System", "Hello and welcome!")
      broadcast(SystemMessage(s"User $name joined"))
      println(s"User $name joined channel[$roomId]")

    case UserLeft(name) =>
      println(s"User $name left channel[$roomId]")
      broadcast(SystemMessage(s"User $name left channel[$roomId]"))
      participants -= name

    case IncomingEstimation(name, estimation) =>
      println(s"User $name estimated $estimation")

    case ShowEstimationResult(name) =>
      println(s"User $name asked to show result")

    case msg: IncomingMessage =>
      broadcast(PokerMessage(msg.sender, msg.message))
  }

  def broadcast(message: PokerMessage): Unit = participants.values.foreach(_ ! message)
}
