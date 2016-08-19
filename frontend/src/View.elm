module View exposing (view)

import Model exposing (User, Model, Task, Page(..), Msg(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


view : Model -> Html Msg
view model =
    main' [ class "flex flex-center p2" ]
        [ mainContent model ]


mainContent : Model -> Html Msg
mainContent model =
    case model.activePage of
        LandingPage ->
            div [ class "bold p2 mx-auto rounded bg-silver" ] [ landingPageContent model ]

        PlanningPokerRoom ->
            div [] [ pokerRoomPageContent2 model ]


landingPageContent : Model -> Html Msg
landingPageContent model =
    div []
        [ h3 [] [ text ("userName: " ++ model.user.name) ]
        , input [ onInput SetUserName, value model.user.name ] []
        , h3 [] [ text ("roomId: " ++ model.roomId) ]
        , input [ onInput SetRoomId, value model.roomId ] []
        , button [ onClick JoinRoom ] [ text "Join room" ]
        ]


pokerRoomPageContent2 : Model -> Html Msg
pokerRoomPageContent2 model =
    div [ class "flex mxn2" ]
        [ div [ class "flex-auto p2 m1 rounded bg-silver" ]
            [ h3 [] [ text "Actions" ]
            , currentUserView model
            , actionView model
            , currentTaskView model
            ]
        , div [ class "flex-auto p2 m1 rounded bg-silver" ]
            [ h3 [] [ text "Estimate" ]
            , estimationView model
            ]
        , div [ class "flex-auto p2 m1 rounded bg-silver" ]
            [ h3 [] [ text "Users" ]
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
            [ h2 [] [ text ("User: " ++ user.name) ]
            , button [ onClick LeaveRoom ] [ text "Leave room" ]
            ]


actionView : Model -> Html Msg
actionView model =
    let
        user =
            model.user
    in
        div []
            [ h3 [] [ text "" ]
            , button [ onClick (RequestStartEstimation (Task "New task")) ] [ text "Start estimation" ]
            , button [ onClick RequestShowResult ] [ text "Show result" ]
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
            [ h3 [] [ text ("Task: " ++ task.name ++ " (" ++ currentEstimation ++ ")") ]
            ]


estimationView : Model -> Html Msg
estimationView model =
    div []
        [ button [ onClick (PerformEstimation "1") ] [ text "Estimate 1" ]
        , button [ onClick (PerformEstimation "2") ] [ text "Estimate 2" ]
        , button [ onClick (PerformEstimation "4") ] [ text "Estimate 4" ]
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
