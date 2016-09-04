module Views.PokerRoomPage exposing (planningPokerPageContent)

import Views.Task exposing (taskView)
import Views.Estimations exposing (estimationView)
import Views.Users exposing (usersView, currentUserView)
import Model exposing (Model, Msg)
import Html exposing (..)
import Html.Attributes exposing (..)


planningPokerPageContent : Model -> Html Msg
planningPokerPageContent model =
    div [ class "flex full-height" ]
        [ div [ class "flex-none col-2 p1" ]
            [ h1 [] [ text "Planning Poker" ]
            , usersView model
            , currentUserView model
            ]
        , div [ class "flex flex-auto flex-stretch flex-column p1" ]
            [ div [ class "actions-container mb2" ]
                [ taskView model
                ]
            , div [ class "flex-auto" ]
                [ estimationView model
                ]
            ]
        ]
