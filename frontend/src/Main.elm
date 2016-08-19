module Main exposing (..)

import Model exposing (Page(..), User, Task, Model, Msg(..))
import Update exposing (update)
import Subscriptions exposing (subscriptions)
import Routing exposing (delta2url, url2messages)
import RouteUrl exposing (UrlChange)
import View exposing (view)


main : Program Never
main =
    RouteUrl.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , delta2url = delta2url
        , location2messages = url2messages
        }


init : ( Model, Cmd Msg )
init =
    ( Model
        LandingPage
        ""
        ""
        False
        ""
        []
        (User "" False Nothing)
        []
        Nothing
    , Cmd.none
    )
