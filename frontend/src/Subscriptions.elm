module Subscriptions exposing (subscriptions)

import Globals exposing (planningPokerServerUrl)
import Model
    exposing
        ( Model
        , Msg
        , Msg(IncomingEvent, TimerTick, HealthCheckTick)
        , State(Estimate)
        )
import WebSocket
import Time exposing (second)
import Platform.Sub exposing (none, batch)


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        isSpectator =
            False

        serverUrl =
            planningPokerServerUrl model

        webSocketSubscription =
            if model.roomJoined then
                WebSocket.listen serverUrl IncomingEvent
            else
                Platform.Sub.none

        timerTickSubscription =
            if model.uiState == Estimate then
                Time.every second TimerTick
            else
                Platform.Sub.none

        healthCheckSubscription =
            Time.every (5 * second) HealthCheckTick
    in
        Sub.batch
            [ webSocketSubscription
            , timerTickSubscription
            , healthCheckSubscription
            ]
