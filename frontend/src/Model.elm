module Model exposing (..)

import Time exposing (Time)
import Date exposing (Date)


type Page
    = LandingPage
    | PlanningPokerRoom


type State
    = Initial
    | Estimate
    | ShowResult


type alias User =
    { name : String
    , isSpectator : Bool
    , hasEstimated : Bool
    , estimation : Maybe String
    }


type alias Task =
    { name : String
    , startDate : Date
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
    , elapsedTime : Time
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
        emptyUser
        []
        []
        Nothing
        0
    , Cmd.none
    )


type Msg
    = SetUserName String
    | SetRoomId String
    | SetNewTaskName String
    | JoinRoom
    | LeaveRoom
    | TimerTick Time
    | IncomingEvent String
      -- is being decoded and mapped to these:
    | UnexpectedPayload String
      -- todo: handle errors
    | UserJoined User
    | UserLeft User
    | StartEstimation Task
    | UserHasEstimated User
    | EstimationResult (List User)
      -- Messages that trigger outgoing messages:
    | RequestStartEstimation Task
    | PerformEstimation String
    | RequestShowResult


emptyTask : Task
emptyTask =
    Task "" (Date.fromTime 0)


emptyUser : User
emptyUser =
    (User "" False False Nothing)
