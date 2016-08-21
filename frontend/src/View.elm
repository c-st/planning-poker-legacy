module View exposing (view)

import Model exposing (User, Model, Task, Page(..), Msg(..), State(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra exposing (groupWhile)


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


pokerRoomPageContent : Model -> Html Msg
pokerRoomPageContent model =
    div [ class "flex flex-auto full-height" ]
        [ div [ class "flex-none col-3 p2" ]
            [ h3 [] [ text "Actions" ]
            , actionView model
            , currentUserView model
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
                [ class "h6 btn btn-primary"
                , onClick LeaveRoom
                ]
                [ text "Leave room" ]
            ]


actionView : Model -> Html Msg
actionView model =
    let
        user =
            model.user

        startEstimationView =
            div []
                [ h4 [] [ text "Start new estimation" ]
                , input
                    [ type' "text"
                    , class "block col-12 mb1 input"
                    , onInput SetNewTaskName
                    , value model.newTaskName
                    ]
                    []
                , button
                    [ class "h6 btn btn-primary"
                    , onClick (RequestStartEstimation (Task model.newTaskName))
                    ]
                    [ text "Start estimation" ]
                ]

        showResultView =
            div []
                [ h4 [] [ text "Show current estimation" ]
                , button
                    [ class "h6 btn btn-primary"
                    , onClick RequestShowResult
                    ]
                    [ text "Show result" ]
                ]
    in
        case model.uiState of
            Estimate ->
                showResultView

            Initial ->
                startEstimationView

            ShowResult ->
                startEstimationView


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
            [ h4 [] [ text ("Task: " ++ task.name) ]
            , div [] [ text ("Your estimation: " ++ currentEstimation) ]
            ]


userEstimationsView : List User -> Html Msg
userEstimationsView estimations =
    let
        estimationGroups =
            groupWhile (\est1 est2 -> est1.estimation == est2.estimation) estimations

        estimationList =
            List.map
                (\group ->
                    let
                        firstUser =
                            Maybe.withDefault (User "" False Nothing) (List.head group)

                        estimate =
                            Maybe.withDefault "0" firstUser.estimation
                    in
                        li [] [ text (estimate ++ " -> count " ++ toString (List.length group)) ]
                )
                estimationGroups
    in
        div [] estimationList


possibleEstimations : List String
possibleEstimations =
    [ "0", "1", "2", "3", "5", "8", "13", "20", "40", "100" ]


estimationView : Model -> Html Msg
estimationView model =
    case model.uiState of
        Initial ->
            div [] [ text "Start estimating for a new task." ]

        Estimate ->
            let
                buttons =
                    List.map
                        (\estimate ->
                            button
                                [ onClick (PerformEstimation estimate) ]
                                [ text ("Estimate " ++ estimate) ]
                        )
                        possibleEstimations
            in
                div [ class "estimation-button-container" ] buttons

        ShowResult ->
            div [] [ userEstimationsView model.currentEstimations ]


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
        li [] [ text (user.name ++ " (has estimated: " ++ toString user.hasEstimated ++ ")") ]
