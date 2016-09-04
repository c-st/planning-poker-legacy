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
            div [ class "" ]
                [ input
                    [ type' "text"
                    , placeholder "Task name"
                    , class "block col-3 mb1 input"
                    , onInput SetNewTaskName
                    , value model.newTaskName
                    ]
                    []
                , button
                    [ class "h6 btn btn-outline"
                    , onClick
                        (RequestStartEstimation
                            (Task model.newTaskName (Date.fromTime 0))
                        )
                    ]
                    [ i [ class "fa fa-play mr1" ] []
                    , text "Start estimation"
                    ]
                ]

        estimatingView =
            div []
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
