module View exposing (view)

import Model exposing (User, Model, Task, Page(..), Msg(..), State(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Views.LandingPage exposing (landingPageContent)
import Views.PokerRoomPage exposing (planningPokerPageContent)


view : Model -> Html Msg
view model =
    div
        [ class "flex flex-column full-height" ]
        [ mainContent model ]


mainContent : Model -> Html Msg
mainContent model =
    case model.activePage of
        LandingPage ->
            div [ class "flex flex-center" ]
                [ div
                    [ class "p2 m2 mx-auto rounded bg-silver col-6" ]
                    [ landingPageContent model ]
                ]

        PlanningPokerRoom ->
            planningPokerPageContent model
