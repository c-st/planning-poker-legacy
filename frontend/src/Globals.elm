module Globals exposing (..)

import Model exposing (User)


planningPokerServer : User -> String -> String
planningPokerServer user room =
    ("ws://planningpoker.cc/poker/" ++ room ++ "?name=" ++ user.name)
