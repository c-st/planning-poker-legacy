package domain

import akka.actor.ActorRef

sealed trait PokerEvent

case class PokerMessage(sender: String, text: String) extends PokerEvent

object SystemMessage {
  def apply(text: String) = PokerMessage("System", text)
}

case class UserJoined(name: String, userActor: ActorRef) extends PokerEvent
case class UserLeft(name: String) extends PokerEvent
case class IncomingMessage(sender: String, message: String) extends PokerEvent