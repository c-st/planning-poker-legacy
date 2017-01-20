module Views.PokerRoomPage exposing (planningPokerPageContent)

import Views.Task exposing (taskView)
import Views.Estimations exposing (estimationView)
import Views.Users exposing (usersView, logoutButton)
import Model exposing (Model, Msg, Health, HealthStatus(..))
import Html exposing (..)
import Html.Attributes exposing (..)


planningPokerPageContent : Model -> Html Msg
planningPokerPageContent model =
    let
        health =
            model.health
    in
        div [ class "flex flex-column full-height m0 p0 " ]
            [ header [ class "white mt0 p1 border-silver border-bottom bg-blue mb1" ]
                [ h1 [ class "m0 h0-responsive mt0 mb0 bold" ] [ text "Planning Poker" ]
                ]
            , main_ [ class "md-flex flex-auto container" ]
                [ section [ class "md-flex sm-col sm-col-2 flex-column" ]
                    [ div [ class "flex-auto p1" ] [ usersView model ]
                    , div [ class "p1" ] [ logoutButton model ]
                    ]
                , section [ class "flex flex-auto flex-column sm-col sm-col-9" ]
                    [ div [ class "" ] [ taskView model ]
                    , div [ class "flex-auto p1" ] [ estimationView model ]
                    ]
                ]
            , footer [] [ healthStatus health ]
            ]


healthStatus : Health -> Html Msg
healthStatus health =
    let
        statusHtml =
            case health.status of
                Healthy ->
                    div [] []

                Zombie ->
                    div [ class "p1" ]
                        [ i [ class "red fa fa-frown-o mr1" ] []
                        , text "Cannot communicate with the server. Please check your connection (WiFi, VPN, ...)"
                        ]

        missedHeartbeats =
            health.missedHeartbeats
    in
        statusHtml
