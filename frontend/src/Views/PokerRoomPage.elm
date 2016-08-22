module Views.PokerRoomPage exposing (planningPokerPageContent)

import Views.Actions exposing (actionsView)
import Views.Estimations exposing (estimationView)
import Views.Users exposing (usersView, currentUserView)
import Model exposing (Model, Msg)
import Html exposing (..)
import Html.Attributes exposing (..)


planningPokerPageContent : Model -> Html Msg
planningPokerPageContent model =
    div [ class "flex full-height" ]
        [ div [ class "flex-none col-3 p2" ]
            [ h3 [] [ text "Actions" ]
            , actionsView model
            ]
        , div [ class "flex-auto p2" ]
            [ h3 [] [ text "Estimate" ]
            , estimationView model
            ]
        , div [ class "flex-none col-3 p2" ]
            [ h3 [] [ text "Users" ]
            , usersView model
            , currentUserView model
            ]
        ]
