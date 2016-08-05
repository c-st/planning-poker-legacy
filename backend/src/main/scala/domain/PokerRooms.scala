package domain

import akka.actor.ActorSystem

object PokerRooms {
  var pokerRooms: Map[Int, PokerRoom] = Map.empty[Int, PokerRoom]

  def findOrCreate(roomId: Int)(implicit actorSystem: ActorSystem): PokerRoom =
    pokerRooms.getOrElse(roomId, createNewPokerRoom(roomId))

  private def createNewPokerRoom(roomId: Int)(implicit actorSystem: ActorSystem): PokerRoom = {
    val pokerRoom = PokerRoom(roomId)
    pokerRooms += roomId -> pokerRoom
    pokerRoom
  }
}