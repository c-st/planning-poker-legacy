package domain

import akka.actor.ActorRef

case class PokerMessage(sender: String, text: String)

object SystemMessage {
  def apply(text: String) = PokerMessage("System", text)
}

sealed trait PokerEvent
case class IncomingMessage(sender: String, message: String) extends PokerEvent

case class UserJoined(name: String, userActor: ActorRef, eventType: String = "userJoined") extends PokerEvent
case class UserLeft(name: String, eventType: String = "userLeft") extends PokerEvent

case class RequestStartEstimation(sender: String, taskName: String, eventType: String = "startEstimation") extends PokerEvent
case class UserEstimate(userName: String, taskName: String, estimate: String, eventType: String = "estimate") extends PokerEvent
case class UserHasEstimated(userName: String, taskName: String, eventType: String = "userHasEstimated") extends PokerEvent
case class RequestShowEstimationResult(sender: String, eventType: String = "showResult") extends PokerEvent
case class EstimationResult(taskName: String, estimates: Map[String, String], eventType: String = "estimationResult") extends PokerEvent