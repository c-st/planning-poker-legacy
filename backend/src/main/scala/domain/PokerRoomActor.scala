package domain

import akka.actor.{Actor, ActorRef}

class PokerRoomActor(roomId: Int) extends Actor {
  var participants: Map[String, ActorRef] = Map.empty[String, ActorRef]
  var moderator: String = ""

  var currentTask: String = ""
  var estimations: Map[String, Map[String, Int]] = Map.empty[String, Map[String, Int]]

  override def receive: Receive = {
    case UserJoined(name, actorRef, _) =>
      broadcast(UserJoined(name, actorRef))
      participants.foreach(p => actorRef ! UserJoined(p._1, p._2))
      participants += name -> actorRef

      // broadcast all previous estimations to actorRef
      // actorRef ! PokerMessage("System", "Hello and welcome!")
      // broadcast(SystemMessage(s"User $name joined"))
      println(s"[$roomId] User $name joined room")

    case UserLeft(name, _) =>
      broadcast(UserLeft(name))
      println(s"[$roomId] User $name left room")
      participants -= name
      if (participants.isEmpty) {
        println(s"[$roomId] Room is now empty.")
      }

    case IncomingEstimation(name, estimation, _) =>
      println(s"[$roomId] User $name estimated $estimation for $currentTask")
      // TODO save estimation

    case ShowEstimationResult(name, _) =>
      println(s"[$roomId] User $name asked to show result")
      // TODO broadcast all estimations for current task

    case msg: IncomingMessage =>
      println(s"[$roomId] Received unknown incoming message $msg")
      // broadcast(PokerMessage(msg.sender, msg.message))
  }

  def broadcast(message: PokerEvent): Unit = participants.values.foreach(_ ! message)

  private def allActors: List[ActorRef] = participants.keys.toList.flatMap(participants.get)
  private def previousEstimations: Map[String, Map[String, Int]] = estimations.filter(_._1 != currentTask)
}
