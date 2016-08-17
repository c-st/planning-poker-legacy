module Globals exposing (..)

import Model exposing (User)


planningPokerServer : User -> String -> String
planningPokerServer user room =
    ("ws://localhost:8080/poker/" ++ room ++ "?name=" ++ user.name)
