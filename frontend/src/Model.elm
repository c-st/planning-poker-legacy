module Model exposing (..)


type Page
    = LandingPage
    | PlanningPokerRoom


type State
    = Initial
    | Estimate
    | ShowResult


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
    , uiState : State
    , roomId : String
    , newTaskName : String
    , roomJoined : Bool
    , input : String
    , messages : List String
    , user : User
    , users : List User
    , currentEstimations : List User
    , currentTask : Maybe Task
    }


init : ( Model, Cmd Msg )
init =
    ( Model
        LandingPage
        Initial
        ""
        ""
        False
        ""
        []
        (User "" False Nothing)
        []
        []
        Nothing
    , Cmd.none
    )


type Msg
    = SetUserName String
    | SetRoomId String
    | SetNewTaskName String
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
    | RequestStartEstimation Task
    | PerformEstimation String
    | RequestShowResult
