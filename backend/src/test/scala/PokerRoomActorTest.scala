import akka.actor.{ActorRef, ActorSystem, Props}
import akka.testkit.{TestActors, TestKit}
import domain._
import org.scalatest.{BeforeAndAfterAll, Matchers, WordSpecLike}
import akka.testkit.TestProbe

import scala.concurrent.duration._

class PokerRoomActorTest
  extends TestKit(ActorSystem("test-system"))
    with WordSpecLike with Matchers with BeforeAndAfterAll{

  override def afterAll = {
    shutdown()
  }

  "User handling" should {
    val roomRef = system.actorOf(Props(classOf[PokerRoomActor], "user-test-room"))
    val userA = TestProbe()
    val userB = TestProbe()
    val userC = TestProbe()

    "ignore invalid messages" in {
      within(100 millis) {
        roomRef ! "hi"
        expectNoMsg
      }
    }

    "broadcast other participants when users join" in {
      roomRef ! UserJoined("userA", userA.ref)
      roomRef ! UserJoined("userB", userB.ref)

      // send other user
      userA.expectMsg(UserJoined("userB", userB.ref))
      userB.expectMsg(UserJoined("userA", userA.ref))

      roomRef ! UserJoined("userC", userC.ref)
      // broadcast new user
      userA.expectMsg(UserJoined("userC", userC.ref))
      userB.expectMsg(UserJoined("userC", userC.ref))

      // send other users to new user
      userC.expectMsgAllOf(
        UserJoined("userA", userA.ref),
        UserJoined("userB", userB.ref)
      )
    }

    "broadcast when users leave" in {
      roomRef ! UserLeft("userB")
      userA.expectMsg(UserLeft("userB"))
      userC.expectMsg(UserLeft("userB"))

      roomRef ! UserLeft("userA")
      userC.expectMsg(UserLeft("userA"))

      roomRef ! UserLeft("userC")
    }
  }

  "Estimation handling" should {
    val roomRef = system.actorOf(Props(classOf[PokerRoomActor], "estimation-test-room"))
    val userA = TestProbe()
    val userB = TestProbe()
    val userC = TestProbe()
    val userD = TestProbe()

    "setup" in {
      roomRef ! UserJoined("userA", userA.ref)
      roomRef ! UserJoined("userB", userB.ref)
      roomRef ! UserJoined("userC", userC.ref)

      userB.expectMsgAllOf(
        UserJoined("userA", userA.ref),
        UserJoined("userC", userC.ref)
      )

      userA.expectMsgAllOf(
        UserJoined("userB", userB.ref),
        UserJoined("userC", userC.ref)
      )

      userC.expectMsgAllOf(
        UserJoined("userA", userA.ref),
        UserJoined("userB", userB.ref)
      )
    }

    "broadcast start of estimation" in {
      roomRef ! RequestStartEstimation("userA", "new-task", "20150102T13:37:00")

      val check: PartialFunction[Any, Boolean] = {
        case RequestStartEstimation("userA", "new-task", _, _) => true
      }

      userA.expectMsgPF(500 millis)(check)
      userB.expectMsgPF(500 millis)(check)
      userC.expectMsgPF(500 millis)(check)
    }

    "should send current estimation to new user" in {
      roomRef ! UserJoined("userD", userD.ref)

      userD.expectMsgAllOf(
        UserJoined("userA", userA.ref),
        UserJoined("userB", userB.ref),
        UserJoined("userC", userC.ref)
      )

      userD.expectMsgPF(500 millis)({
        case RequestStartEstimation("", "new-task", _, _) => true
      })
    }
  }

}
