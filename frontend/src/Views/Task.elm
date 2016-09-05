module Views.Task exposing (taskView)

import Model exposing (User, Model, Task, Page(..), Msg(..), State(..), emptyTask)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Date exposing (fromTime)
import Time exposing (inSeconds, inMinutes)


taskView : Model -> Html Msg
taskView model =
    let
        user =
            model.user

        task =
            Maybe.withDefault emptyTask model.currentTask

        minutes =
            (floor <| inMinutes model.elapsedTime) `rem` 60

        seconds =
            (floor <| inSeconds model.elapsedTime) `rem` 60

        elapsedTime =
            (toString minutes) ++ ":" ++ (toString seconds)

        startEstimationView =
            Html.form
                [ class "flex flex-center"
                , onSubmit <|
                    RequestStartEstimation <|
                        Task model.newTaskName (Date.fromTime 0)
                ]
                [ input
                    [ type' "text"
                    , placeholder "Task name"
                    , class "flex-auto col-3 input m1"
                    , onInput SetNewTaskName
                    , value model.newTaskName
                    ]
                    []
                , button
                    [ class "btn btn-outline m1"
                    , type' "submit"
                    ]
                    [ i [ class "fa fa-play" ] []
                    , text "Start estimation"
                    ]
                ]

        estimatingView =
            div [ class "p1" ]
                [ h2 [] [ text task.name ]
                , text <| "Elapsed: " ++ elapsedTime
                , showResultView
                ]

        showResultView =
            div []
                [ button
                    [ class "h6 btn btn-outline"
                    , onClick RequestShowResult
                    ]
                    [ i [ class "fa fa-eye mr1" ] []
                    , text "Show result"
                    ]
                ]
    in
        case model.uiState of
            Initial ->
                startEstimationView

            Estimate ->
                estimatingView

            ShowResult ->
                startEstimationView
