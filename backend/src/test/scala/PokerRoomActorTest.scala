import akka.actor.{ActorRef, ActorSystem, Props}
import akka.testkit.{TestActors, TestKit}
import domain.{PokerRoomActor, UserJoined, UserLeft}
import org.scalatest.{BeforeAndAfterAll, Matchers, WordSpecLike}
import akka.testkit.TestProbe

import scala.concurrent.duration._

class PokerRoomActorTest
  extends TestKit(ActorSystem("test-system"))
    with WordSpecLike with Matchers with BeforeAndAfterAll{

  var roomRef: ActorRef = system.actorOf(Props(classOf[PokerRoomActor], "test-room"))

  override def afterAll = {
    shutdown()
  }

  "User handling" should {
    roomRef = system.actorOf(Props(classOf[PokerRoomActor], "test-room"))
    val probe1 = TestProbe()
    val probe2 = TestProbe()
    val probe3 = TestProbe()

    "ignore invalid messages" in {
      within(100 millis) {
        roomRef ! "hi"
        expectNoMsg
      }
    }

    "broadcast other participants when users join" in {
      roomRef ! UserJoined("userA", probe1.ref)
      roomRef ! UserJoined("userB", probe2.ref)

      // send other user
      probe1.expectMsg(500 millis, UserJoined("userB", probe2.ref))
      probe2.expectMsg(500 millis, UserJoined("userA", probe1.ref))

      roomRef ! UserJoined("userC", probe3.ref)
      // broadcast new user
      probe1.expectMsg(500 millis, UserJoined("userC", probe3.ref))
      probe2.expectMsg(500 millis, UserJoined("userC", probe3.ref))

      // send other users to new user
      probe3.expectMsg(500 millis, UserJoined("userA", probe1.ref))
      probe3.expectMsg(500 millis, UserJoined("userB", probe2.ref))
    }

    "broadcast when users leave" in {
      roomRef ! UserLeft("userB")
      probe1.expectMsg(500 millis, UserLeft("userB"))
      probe3.expectMsg(500 millis, UserLeft("userB"))
    }
  }

}
