module Views.Users exposing (usersView, currentUserView)

import Model exposing (User, Model, Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


currentUserView : Model -> Html Msg
currentUserView model =
    let
        user =
            model.user
    in
        div []
            [ h4 [] [ text ("User: " ++ user.name) ]
            , button
                [ class "h6 btn btn-outline"
                , onClick LeaveRoom
                ]
                [ i [ class "fa fa-sign-out mr1" ] []
                , text "Leave room"
                ]
            ]


usersView : Model -> Html Msg
usersView model =
    let
        users =
            model.user :: model.users

        sortedUsers =
            List.sortBy .name users
    in
        div []
            [ ul [ class "list-reset" ] (List.map viewUser sortedUsers)
            ]


viewUser : User -> Html msg
viewUser user =
    let
        cssClass =
            if user.hasEstimated then
                "mr1 fa fa-check-circle-o green"
            else
                ""
    in
        li []
            [ i [ class cssClass ] []
            , text user.name
            ]
