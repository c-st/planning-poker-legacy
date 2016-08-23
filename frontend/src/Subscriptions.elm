module Subscriptions exposing (subscriptions)

import Globals exposing (planningPokerServer)
import Model exposing (Model, Msg, Msg(IncomingEvent, TimerTick))
import WebSocket
import Time exposing (second)
import Platform.Sub exposing (none, batch)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.roomJoined of
        True ->
            let
                serverUrl =
                    planningPokerServer model.user model.roomId
            in
                Sub.batch
                    [ WebSocket.listen serverUrl IncomingEvent
                    , Time.every second TimerTick
                    ]

        False ->
            Platform.Sub.none
