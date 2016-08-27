module Subscriptions exposing (subscriptions)

import Globals exposing (planningPokerServer)
import Model exposing (Model, Msg, Msg(IncomingEvent, TimerTick), State(Estimate))
import WebSocket
import Time exposing (second)
import Platform.Sub exposing (none, batch)


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        serverUrl =
            planningPokerServer model.user model.roomId

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
    in
        Sub.batch [ webSocketSubscription, timerTickSubscription ]
