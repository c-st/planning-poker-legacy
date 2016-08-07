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

case class IncomingEstimation(sender: String, estimation: String, eventType: String = "estimation") extends PokerEvent
case class ShowEstimationResult(sender: String, eventType: String = "showResult") extends PokerEvent