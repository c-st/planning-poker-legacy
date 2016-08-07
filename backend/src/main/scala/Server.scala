import akka.actor.ActorSystem
import akka.http.scaladsl.Http
import akka.stream.ActorMaterializer
import akka.http.scaladsl.server.Directives._
import services.PlanningPokerService

import scala.util.{Failure, Success}

object Server extends App {
  implicit val actorSystem = ActorSystem("akka-system")
  implicit val flowMaterializer = ActorMaterializer()

  val config = actorSystem.settings.config
  val interface = config.getString("app.interface")
  val port = config.getInt("app.port")

  val route = get {
    pathEndOrSingleSlash {
      complete("Welcome to websocket server")
    } ~ PlanningPokerService.route
  }

  import actorSystem.dispatcher

  val binding = Http().bindAndHandle(route, interface, port)
  binding.onComplete {
    case Success(binding) =>
      println(s"Server is now running at http://$interface:$port")
    case Failure(e) =>
      println(s"Binding failed with ${e.getMessage}")
      actorSystem.terminate()
  }
}