module Views.PokerRoomPage exposing (planningPokerPageContent)

import Views.Task exposing (taskView)
import Views.Estimations exposing (estimationView)
import Views.Users exposing (usersView, logoutButton)
import Model exposing (Model, Msg)
import Html exposing (..)
import Html.Attributes exposing (..)


planningPokerPageContent : Model -> Html Msg
planningPokerPageContent model =
    div [ class "flex full-height" ]
        [ div [ class "flex flex-none flex-column col-3" ]
            [ div [ class "flex p1" ] [ h1 [ class "m0" ] [ text "Planning Poker" ] ]
            , div [ class "flex-auto p1" ] [ usersView model ]
            , div [ class "p1" ] [ logoutButton model ]
            ]
        , div [ class "flex flex-auto flex-stretch flex-column p1" ]
            [ div [ class "" ]
                [ taskView model
                ]
            , div [ class "flex-auto p1" ]
                [ estimationView model
                ]
            ]
        ]
