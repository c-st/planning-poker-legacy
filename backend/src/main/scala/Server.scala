import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.stream.ActorMaterializer
import akka.http.scaladsl.server.Directives._
import domain.PokerRooms

import scala.io.StdIn

object Server extends App {
  implicit val actorSystem = ActorSystem("akka-system")
  implicit val flowMaterializer = ActorMaterializer()

  val config = actorSystem.settings.config
  val interface = config.getString("app.interface")
  val port = config.getInt("app.port")

  val route = get {
    pathEndOrSingleSlash {
      complete("Welcome to websocket server")
    } ~ pathPrefix("poker" / IntNumber) { roomId =>
      parameter('name) { userName =>
        handleWebSocketMessages(PokerRooms.findOrCreate(roomId).websocketFlow(userName))
      }
    }
  }

  val binding = Http().bindAndHandle(route, interface, port)
  println(s"Server is now online at http://$interface:$port\nPress RETURN to stop...")
  StdIn.readLine()

  import actorSystem.dispatcher

  binding.flatMap(_.unbind()).onComplete(_ => actorSystem.terminate())
  println("Server is down...")
}