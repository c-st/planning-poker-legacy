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
            div [] [ pokerRoomPageContent model ]


landingPageContent : Model -> Html Msg
landingPageContent model =
    div []
        [ h3 [] [ text ("userName: " ++ model.user.name) ]
        , input [ onInput SetUserName, value model.user.name ] []
        , h3 [] [ text ("roomId: " ++ model.roomId) ]
        , input [ onInput SetRoomId, value model.roomId ] []
        , button [ onClick JoinRoom ] [ text "Join room" ]
        ]


pokerRoomPageContent : Model -> Html Msg
pokerRoomPageContent model =
    let
        user =
            model.user

        currentEstimation =
            Maybe.withDefault "" user.estimation

        task =
            Maybe.withDefault (Task "") model.currentTask
    in
        div []
            [ h3 [] [ text ("userName: " ++ user.name) ]
            , button [ onClick LeaveRoom ] [ text "Leave room" ]
            , h3 [] [ text ("currentTask: " ++ task.name) ]
            , div []
                [ h3 [] [ text ("currentEstimation:" ++ currentEstimation) ]
                , button [ onClick (PerformEstimation "1") ] [ text "Estimate 1" ]
                , button [ onClick (PerformEstimation "2") ] [ text "Estimate 2" ]
                , button [ onClick (PerformEstimation "4") ] [ text "Estimate 4" ]
                ]
            , div []
                [ h3 [] [ text "Users" ]
                , ul [] (List.map viewUser model.users)
                ]
            , div []
                [ h3 [] [ text "Moderation" ]
                , button [ onClick (RequestStartEstimation (Task "New task")) ] [ text "Start estimation" ]
                , button [ onClick RequestShowResult ] [ text "Show result" ]
                ]
            ]


viewUser : User -> Html msg
viewUser user =
    let
        estimation =
            toString <|
                Maybe.withDefault "--" user.estimation
    in
        li [] [ text (user.name ++ " " ++ toString user.hasEstimated ++ " " ++ estimation) ]


title : String
title =
    "Planning poker"
