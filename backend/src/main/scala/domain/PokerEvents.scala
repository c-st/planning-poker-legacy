package domain

import akka.actor.ActorRef

case class PokerMessage(sender: String, text: String)

object SystemMessage {
  def apply(text: String) = PokerMessage("System", text)
}

sealed trait PokerEvent

case class UserJoined(name: String, userActor: ActorRef) extends PokerEvent
case class UserLeft(name: String) extends PokerEvent

case class IncomingMessage(sender: String, message: String) extends PokerEvent

case class IncomingEstimation(sender: String, estimation: String) extends PokerEvent
case class ShowEstimationResult(sender: String) extends PokerEvent