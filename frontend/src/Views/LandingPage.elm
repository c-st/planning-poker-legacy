module Views.LandingPage exposing (landingPageContent)

import Model exposing (User, Model, Task, Page(..), Msg(..), State(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


landingPageContent : Model -> Html Msg
landingPageContent model =
    Html.form [ onSubmit JoinRoom ]
        [ h2 [] [ text "Join a room" ]
        , label
            [ for "roomId"
            , class "label"
            ]
            [ text "Room ID" ]
        , input
            [ id "roomId"
            , type' "text"
            , class "block col-12 mb1 input"
            , onInput SetRoomId
            , value model.roomId
            ]
            []
        , label
            [ for "userName"
            , class "label"
            ]
            [ text "Your name" ]
        , input
            [ id "userName"
            , type' "text"
            , class "block col-12 mb1 input"
            , onInput SetUserName
            , value model.user.name
            ]
            []
        , button
            [ class "h6 btn btn-primary"
            , type' "submit"
            ]
            [ text "Join room" ]
        ]


options =
    { stopPropagation = True
    , preventDefault = True
    }
