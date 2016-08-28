package domain

import akka.actor.{Actor, ActorLogging, ActorRef}
import akka.http.scaladsl.model.DateTime

import scala.collection.immutable.Map

class PokerRoomActor(roomId: String) extends Actor with ActorLogging{
  type Estimations = Map[String, Map[String, String]]

  var participants: Map[String, ActorRef] = Map.empty[String, ActorRef]

  var estimationStart: DateTime = DateTime.now
  var estimations: Estimations = Map.empty[String, Map[String, String]]

  def receive = idle

  def idle: Receive = {
    case UserJoined(name, actorRef, _) =>
      broadcast(UserJoined(name, actorRef))
      participants.foreach(p => actorRef ! UserJoined(p._1, p._2))
      participants += name -> actorRef
      log.info(s"[$roomId] User $name joined room.")

    case UserLeft(name, _) =>
      broadcast(UserLeft(name))
      participants -= name
      log.info(s"[$roomId] User $name left room")

    case RequestStartEstimation(name, taskName, _, _) =>
      log.info(s"[$roomId] $name initiated an estimation for '$taskName'")
      estimations = removeTaskEstimations(taskName)
      val estimationStart = DateTime.now
      broadcast(RequestStartEstimation(name, taskName, estimationStart.toIsoDateTimeString()))
      context.become(estimating(taskName, estimationStart))

    case _ =>
      log.info(s"Invalid message received")
  }

  def estimating(currentTask: String, estimationStart: DateTime): Receive = {
    case UserJoined(name, actorRef, _) =>
      broadcast(UserJoined(name, actorRef))
      participants.foreach(p => actorRef ! UserJoined(p._1, p._2))
      participants += name -> actorRef
      actorRef ! RequestStartEstimation("", currentTask, estimationStart.toIsoDateTimeString())
      currentEstimations(currentTask).foreach(estimation => actorRef ! UserHasEstimated(estimation._1, currentTask))
      log.info(s"[$roomId] User $name joined room during an ongoing estimation.")

    case UserLeft(name, _) =>
      broadcast(UserLeft(name))
      participants -= name
      estimations = removeUserEstimation(currentTask, name)
      if (outstandingEstimations(currentTask).isEmpty) {
        context.become(finishedEstimating(currentTask, estimationStart, DateTime.now))
      }
      log.info(s"[$roomId] User $name left room during estimation.")

    case UserEstimate(name, taskName, estimation, _) =>
      if (taskName == currentTask) {
        estimations = insertEstimation(taskName, (name, estimation))
        broadcast(UserHasEstimated(name, taskName))
        log.info(s"[$roomId] User $name estimated $estimation for $currentTask")
        if (outstandingEstimations(taskName).isEmpty) {
          context.become(finishedEstimating(currentTask, estimationStart, DateTime.now))
        }
      } else {
        log.info(s"[$roomId] cannot save estimate for $taskName. Current task is $currentTask")
      }


    case RequestShowEstimationResult(name, _) =>
      log.info(s"Cannot show results. There are still outstanding votes.")
  }

  def finishedEstimating(task: String, estimationStart: DateTime, estimationEnd: DateTime): Receive = {
    case UserJoined(name, actorRef, _) =>
      broadcast(UserJoined(name, actorRef))
      participants.foreach(p => actorRef ! UserJoined(p._1, p._2))
      participants += name -> actorRef
      currentEstimations(task).foreach(estimation => actorRef ! UserHasEstimated(estimation._1, task))
      actorRef ! RequestStartEstimation("", task, estimationStart.toIsoDateTimeString())
      log.info(s"[$roomId] User $name joined room after estimation.")
      context.become(estimating(task, estimationStart))

    case UserLeft(name, _) =>
      broadcast(UserLeft(name))
      participants -= name
      log.info(s"[$roomId] User $name left room after estimation.")

    case UserEstimate(name, taskName, estimation, _) =>
      if (taskName == task) {
        estimations = insertEstimation(taskName, (name, estimation))
        log.info(s"[$roomId] User $name estimated $estimation for $task (has changed his mind)")
      } else {
        log.info(s"[$roomId] cannot save estimate for $taskName. Current task is $task")
      }

    case RequestShowEstimationResult(name, _) =>
      val estimates = estimations.getOrElse(task, Map.empty[String, String])
      val estimatesList = estimates.keys.toList.map(userName =>
        UserEstimation(userName, estimates.getOrElse(userName, "")))
      broadcast(EstimationResult(task, estimatesList))
      log.info(s"[$roomId] finishing estimation with result: $estimates")
      context.become(idle)
  }

  def broadcast(message: PokerEvent): Unit =
    participants.values.foreach(_ ! message)

  private def allActors: List[ActorRef] =
    participants.keys.toList.flatMap(participants.get)

  private def previousEstimations(currentTask: String): Estimations =
    estimations.filter(_._1 != currentTask)

  private def currentEstimations(currentTask: String): Map[String, String] =
    estimations.getOrElse(currentTask, Map.empty[String, String])

  private def outstandingEstimations(currentTask: String) : Map[String, ActorRef] =
    participants.filter(p => !currentEstimations(currentTask).keys.toList.contains(p._1))

  private def insertEstimation(currentTask: String, estimation: (String, String)) : Estimations = {
    val newEstimations = currentEstimations(currentTask) - estimation._1 + (estimation._1 -> estimation._2)
    estimations - currentTask + (currentTask -> newEstimations)
  }

  private def removeTaskEstimations(taskName: String) : Estimations = {
    estimations - taskName
  }

  private def removeUserEstimation(taskName: String, userName: String): Estimations = {
    val newEstimations = currentEstimations(taskName) - userName
    estimations - taskName + (taskName -> newEstimations)
  }
}
