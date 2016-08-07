package domain

import akka.actor.{Actor, ActorRef}

class PokerRoomActor(roomId: Int) extends Actor {
  var participants: Map[String, ActorRef] = Map.empty[String, ActorRef]
  var moderator: String = ""

  var currentTask: String = ""
  var estimations: Map[String, Map[String, Int]] = Map.empty[String, Map[String, Int]]

  override def receive: Receive = {
    case UserJoined(name, actorRef) =>
      broadcast(UserJoined(name, actorRef))
      participants.foreach(p => actorRef ! UserJoined(p._1, p._2))
      participants += name -> actorRef

      // broadcast all previous estimations to actorRef
      // actorRef ! PokerMessage("System", "Hello and welcome!")
      // broadcast(SystemMessage(s"User $name joined"))
      println(s"User $name joined channel[$roomId]")

    case UserLeft(name) =>
      broadcast(UserLeft(name))
      println(s"User $name left channel[$roomId]")
      participants -= name
      if (participants.isEmpty) {
        println(s"Channel $roomId is now empty.")
      }

    case IncomingEstimation(name, estimation) =>
      println(s"User $name estimated $estimation")

    case ShowEstimationResult(name) =>
      println(s"User $name asked to show result")

    case msg: IncomingMessage =>
      // broadcast(PokerMessage(msg.sender, msg.message))
  }

  def broadcast(message: PokerEvent): Unit = participants.values.foreach(_ ! message)

  private def allActors: List[ActorRef] = participants.keys.toList.flatMap(participants.get)
  private def previousEstimations: Map[String, Map[String, Int]] = estimations.filter(_._1 != currentTask)


}
