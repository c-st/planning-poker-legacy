module Views.LandingPage exposing (landingPageContent)

import Model exposing (User, Model, Task, Page(..), Msg(..), State(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


landingPageContent : Model -> Html Msg
landingPageContent model =
    Html.form [ onSubmit <| JoinRoom ]
        [ h2 [ class "mt1 mb3 center" ] [ text "Join a room" ]
        , label
            [ for "roomId"
            , class "label"
            ]
            [ text "Room ID" ]
        , input
            [ id "roomId"
            , type' "text"
            , class "block col-12 mb2 input"
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
            , class "block col-12 mb2 input"
            , onInput SetUserName
            , value model.user.name
            ]
            []
        , label
            [ for "isSpectator"
            , class "block col-12 mb3"
            ]
            [ input
                [ id "isSpectator"
                , type' "checkbox"
                , checked model.user.isSpectator
                , onCheck SetSpectator
                ]
                []
            , text "Join as spectator"
            ]
        , button
            [ class "h4 btn btn-primary right"
            , type' "submit"
            ]
            [ text "Join" ]
        ]


options : { preventDefault : Bool, stopPropagation : Bool }
options =
    { stopPropagation = True
    , preventDefault = True
    }
