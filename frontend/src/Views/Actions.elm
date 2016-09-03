module Views.Actions exposing (actionsView)

import Model exposing (User, Model, Task, Page(..), Msg(..), State(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Date exposing (fromTime)


actionsView : Model -> Html Msg
actionsView model =
    let
        user =
            model.user

        startEstimationView =
            div []
                [ input
                    [ type' "text"
                    , placeholder "Task name"
                    , class "block col-12 mb1 input"
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
            Estimate ->
                showResultView

            Initial ->
                startEstimationView

            ShowResult ->
                startEstimationView
