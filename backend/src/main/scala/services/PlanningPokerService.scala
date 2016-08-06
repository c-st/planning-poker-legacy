package services

import akka.actor.ActorSystem
import akka.http.scaladsl.server.Directives._
import akka.http.scaladsl.server._
import domain.PokerRooms

object PlanningPokerService {
  def route(implicit actorSystem: ActorSystem): Route = pathPrefix("poker" / IntNumber) { roomId =>
    parameter('name) { userName =>
      handleWebSocketMessages(PokerRooms.findOrCreate(roomId).websocketFlow(userName))
    }
  }
}