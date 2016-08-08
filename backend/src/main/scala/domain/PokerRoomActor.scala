package domain

import akka.actor.{Actor, ActorRef}
import scala.collection.immutable.Map

class PokerRoomActor(roomId: Int) extends Actor {
  type Estimations = Map[String, Map[String, String]]

  var participants: Map[String, ActorRef] = Map.empty[String, ActorRef]
  var moderator: String = ""

  var currentTask: String = ""
  var estimations: Estimations = Map.empty[String, Map[String, String]]

  override def receive: Receive = {
    case UserJoined(name, actorRef, _) =>
      broadcast(UserJoined(name, actorRef))
      participants.foreach(p => actorRef ! UserJoined(p._1, p._2))
      if (!currentTask.isEmpty) {
        actorRef ! RequestStartEstimation(moderator, currentTask)
      }
      // broadcast all previous estimations to actorRef
      participants += name -> actorRef
      println(s"[$roomId] User $name joined room")

    case UserLeft(name, _) =>
      broadcast(UserLeft(name))
      println(s"[$roomId] User $name left room")
      participants -= name
      if (participants.isEmpty) {
        println(s"[$roomId] Room is now empty.")
      }

    case RequestStartEstimation(name, taskName, _) =>
      println(s"[$roomId] $name initiated an estimation for '$taskName'")
      currentTask = taskName
      broadcast(RequestStartEstimation(name, taskName))

    case UserEstimate(name, taskName, estimation, _) =>
      if (taskName != currentTask) {
        println(s"[$roomId] $name cannot save estimation for '$taskName'. It is not the current task")
      } else {
        estimations = insertEstimation((name, estimation))
        println(s"[$roomId] User $name estimated $estimation for $currentTask")
        broadcast(UserHasEstimated(name, taskName))
      }

    case RequestShowEstimationResult(name, _) =>
      println(s"[$roomId] User $name asked to show result")
      if (outstandingEstimations.nonEmpty) {
        println(s"[$roomId] there are still users that need to estimate!")
      } else {
        val estimates = estimations.getOrElse(currentTask, Map.empty[String, String])
        println(s"[$roomId] finishing estimation with result: $estimates")
        broadcast(EstimationResult(currentTask, estimates))
        currentTask = ""
      }

    case msg: IncomingMessage =>
      println(s"[$roomId] Received unknown incoming message $msg")
      // broadcast(PokerMessage(msg.sender, msg.message))
  }

  def broadcast(message: PokerEvent): Unit = participants.values.foreach(_ ! message)

  private def allActors: List[ActorRef] = participants.keys.toList.flatMap(participants.get)
  private def previousEstimations: Estimations = estimations.filter(_._1 != currentTask)
  private def outstandingEstimations : Map[String, ActorRef] = {
    // outstanding estimations for current task. find all users that haven't estimated
    ???
  }
  private def insertEstimation(estimation: (String, String)) : Estimations = {
    // insert new estimation overwriting existing one
    ???
  }
}
