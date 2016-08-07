package domain

import akka.actor.ActorRef

case class PokerMessage(sender: String, text: String)

object SystemMessage {
  def apply(text: String) = PokerMessage("System", text)
}

sealed trait PokerEvent
case class IncomingMessage(sender: String, message: String) extends PokerEvent

case class UserJoined(name: String, userActor: ActorRef, id: String = "userJoined") extends PokerEvent
case class UserLeft(name: String, id: String = "userLeft") extends PokerEvent

case class IncomingEstimation(sender: String, estimation: String, id: String = "estimation") extends PokerEvent
case class ShowEstimationResult(sender: String, id: String = "showResult") extends PokerEvent