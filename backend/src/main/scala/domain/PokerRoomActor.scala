package domain

import akka.actor.{Actor, ActorRef}
import scala.collection.immutable.Map

class PokerRoomActor(roomId: String) extends Actor {
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
      // TODO: fill history. broadcast all previous estimations to actorRef
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
      estimations = removeTaskEstimations(taskName)
      currentTask = taskName
      broadcast(RequestStartEstimation(name, taskName))

    case UserEstimate(name, taskName, estimation, _) =>
      if (taskName != currentTask) {
        println(s"[$roomId] $name cannot save estimation for '$taskName'. It is not the current task")
      } else {
        estimations = insertEstimation((name, estimation))
        println(s"[$roomId] User $name estimated $estimation for $currentTask")
        broadcast(UserHasEstimated(name, taskName))
        if (outstandingEstimations.isEmpty) println(s"[$roomId] All users have estimated! $currentEstimations")
      }

    case RequestShowEstimationResult(name, _) =>
      println(s"[$roomId] User $name asked to show result")
      if (currentTask.isEmpty) {
        println(s"[$roomId] No estimation is started yet.")
      } else if (outstandingEstimations.nonEmpty) {
        println(s"[$roomId] There are still users that need to estimate!")
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
  private def currentEstimations: Map[String, String] = estimations.getOrElse(currentTask, Map.empty[String, String])
  private def outstandingEstimations : Map[String, ActorRef] = {
    participants.filter(p => !currentEstimations.keys.toList.contains(p._1))
  }
  private def insertEstimation(estimation: (String, String)) : Estimations = {
    val newEstimations = currentEstimations - estimation._1 + (estimation._1 -> estimation._2)
    estimations - currentTask + (currentTask -> newEstimations)
  }
  private def removeTaskEstimations(taskName: String) : Estimations = {
    estimations - currentTask
  }
}
