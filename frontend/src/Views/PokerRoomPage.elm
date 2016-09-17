module Views.PokerRoomPage exposing (planningPokerPageContent)

import Views.Task exposing (taskView)
import Views.Estimations exposing (estimationView)
import Views.Users exposing (usersView, logoutButton)
import Model exposing (Model, Msg)
import Html exposing (..)
import Html.Attributes exposing (..)


planningPokerPageContent : Model -> Html Msg
planningPokerPageContent model =
    div [ class "flex flex-column full-height m0 p0 " ]
        [ header [ class "white mt0 p1 border-silver border-bottom bg-blue mb1" ]
            [ h1 [ class "m0 h0-responsive mt0 mb0 bold" ] [ text "Planning Poker" ]
            ]
        , main' [ class "flex flex-auto container" ]
            [ section [ class "sm-col sm-col-3 flex flex-column" ]
                [ div [ class "flex-auto p1" ] [ usersView model ]
                , div [ class "p1" ] [ logoutButton model ]
                ]
            , section [ class "flex flex-auto flex-column" ]
                [ div [ class "" ] [ taskView model ]
                , div [ class "flex-auto p1" ] [ estimationView model ]
                ]
            ]
        , footer [] []
        ]
