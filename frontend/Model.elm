module Model exposing (..)


type Page
    = LandingPage
    | PlanningPokerRoom


type alias User =
    { name : String
    , hasEstimated : Bool
    , estimation : Maybe String
    }


type alias Task =
    { name : String
    }


type alias Model =
    { activePage : Page
    , roomId : String
    , roomJoined : Bool
    , input : String
    , messages : List String
    , user : User
    , users : List User
    , currentTask : Maybe Task
    }


type Msg
    = SetUserName String
    | SetRoomId String
    | JoinRoom
    | LeaveRoom
    | IncomingEvent String
      -- is being decoded and mapped to these:
    | UnexpectedPayload String
    | UserJoined User
    | UserLeft User
    | StartEstimation Task
    | UserHasEstimated User
    | EstimationResult (List User)
      -- Messages that trigger outgoing messages:
    | PerformEstimation String
