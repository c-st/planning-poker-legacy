module Views.Estimations exposing (currentTaskView, estimationView)

import Model exposing (User, Model, Task, Page(..), Msg(..), State(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Chart exposing (pie, title, colours, toHtml)
import List.Extra exposing (groupWhile)


currentTaskView : Model -> Html Msg
currentTaskView model =
    let
        user =
            model.user

        task =
            Maybe.withDefault (Task "") model.currentTask
    in
        div []
            [ h4 [] [ text ("Task: " ++ task.name) ]
            ]


possibleEstimations : List String
possibleEstimations =
    [ "0", "1", "2", "3", "5", "8", "13", "20", "40", "100" ]


estimationButton : String -> Model -> Html Msg
estimationButton estimate model =
    let
        currentEstimation =
            Maybe.withDefault "" model.user.estimation

        buttonClass =
            if currentEstimation == estimate then
                "bg-green btn-primary"
            else
                "btn-outline"
    in
        button
            [ class ("btn " ++ buttonClass)
            , onClick (PerformEstimation estimate)
            ]
            [ text ("Estimate " ++ estimate) ]


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
                            estimationButton estimate model
                        )
                        possibleEstimations
            in
                div [ class "estimation-button-container" ] buttons

        ShowResult ->
            let
                task =
                    Maybe.withDefault (Task "Task") model.currentTask

                values =
                    [ 2, 2, 3 ]

                labels =
                    [ "1", "5", "8" ]
            in
                div []
                    [ userEstimationsView model.currentEstimations
                    , pie values labels
                        |> Chart.title task.name
                        |> colours [ "#0074D9", "#7FDBFF", "#2ECC40", "#FFDC00", "#FF851B", "#FF4136" ]
                        |> toHtml
                    ]
