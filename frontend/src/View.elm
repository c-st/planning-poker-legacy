module View exposing (view)

import Model exposing (User, Model, Task, Page(..), Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


view : Model -> Html Msg
view model =
    div
        [ class "flex flex-column full-height" ]
        [ mainContent model ]


mainContent : Model -> Html Msg
mainContent model =
    case model.activePage of
        LandingPage ->
            div [ class "flex flex-center" ]
                [ div
                    [ class "p2 m2 mx-auto rounded bg-silver col-6" ]
                    [ landingPageContent model ]
                ]

        PlanningPokerRoom ->
            pokerRoomPageContent model


landingPageContent : Model -> Html Msg
landingPageContent model =
    Html.form [ onSubmit JoinRoom ]
        [ h2 [] [ text "Join a room" ]
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
        , button
            [ class "btn btn-primary"
            , type' "submit"
            ]
            [ text "Join room" ]
        ]


options =
    { stopPropagation = True
    , preventDefault = True
    }


pokerRoomPageContent : Model -> Html Msg
pokerRoomPageContent model =
    div [ class "flex flex-auto full-height" ]
        [ div [ class "flex-none col-3 p2" ]
            [ h3 [] [ text "Actions" ]
            , currentUserView model
            , actionView model
            ]
        , div [ class "flex-auto p2" ]
            [ h3 [] [ text "Estimate" ]
            , currentTaskView model
            , estimationView model
            ]
        , div [ class "flex-none col-3 p2" ]
            [ h3 [] [ text "Other users" ]
            , usersView model
            ]
        ]


currentUserView : Model -> Html Msg
currentUserView model =
    let
        user =
            model.user
    in
        div []
            [ h4 [] [ text ("User: " ++ user.name) ]
            , button
                [ class "btn btn-primary"
                , onClick LeaveRoom
                ]
                [ text "Leave room" ]
            ]


actionView : Model -> Html Msg
actionView model =
    let
        user =
            model.user
    in
        div []
            [ h3 [] [ text "" ]
            , button
                [ class "btn btn-primary"
                , onClick (RequestStartEstimation (Task "New task"))
                ]
                [ text "Start estimation" ]
            , button
                [ class "btn btn-primary"
                , onClick RequestShowResult
                ]
                [ text "Show result" ]
            ]


currentTaskView : Model -> Html Msg
currentTaskView model =
    let
        user =
            model.user

        task =
            Maybe.withDefault (Task "") model.currentTask

        currentEstimation =
            Maybe.withDefault "" user.estimation
    in
        div []
            [ h4
                []
                [ text ("Task: " ++ task.name ++ " (" ++ currentEstimation ++ ")") ]
            ]


estimationView : Model -> Html Msg
estimationView model =
    div []
        [ button
            [ onClick (PerformEstimation "1") ]
            [ text "Estimate 1" ]
        , button
            [ onClick (PerformEstimation "2") ]
            [ text "Estimate 2" ]
        , button
            [ onClick (PerformEstimation "4") ]
            [ text "Estimate 4" ]
        ]


usersView : Model -> Html Msg
usersView model =
    div []
        [ ul [] (List.map viewUser model.users)
        ]


viewUser : User -> Html msg
viewUser user =
    let
        estimation =
            toString <|
                Maybe.withDefault "--" user.estimation
    in
        li [] [ text (user.name ++ " " ++ toString user.hasEstimated ++ " " ++ estimation) ]
