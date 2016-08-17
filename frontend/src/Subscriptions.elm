module Subscriptions exposing (subscriptions)

import Globals exposing (planningPokerServer)
import Model exposing (Model, Msg, Msg(IncomingEvent))
import WebSocket
import Platform.Sub exposing (none)


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.roomJoined of
        True ->
            let
                serverUrl =
                    planningPokerServer model.user model.roomId
            in
                WebSocket.listen serverUrl IncomingEvent

        False ->
            Platform.Sub.none
