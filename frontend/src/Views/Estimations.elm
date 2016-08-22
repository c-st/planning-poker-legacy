module Views.Estimations exposing (estimationView)

import Model exposing (User, Model, Task, Page(..), Msg(..), State(..))
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Chart exposing (pie, title, colours, toHtml)
import Dict exposing (..)
import Dict.Extra exposing (groupBy)


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


estimationView : Model -> Html Msg
estimationView model =
    case model.uiState of
        Initial ->
            div [] [ text "Start estimating for a new task." ]

        Estimate ->
            let
                task =
                    Maybe.withDefault (Task "") model.currentTask

                buttons =
                    List.map
                        (\estimate ->
                            estimationButton estimate model
                        )
                        possibleEstimations
            in
                div []
                    [ h4 [] [ text task.name ]
                    , div [ class "estimation-button-container" ] buttons
                    ]

        ShowResult ->
            let
                task =
                    Maybe.withDefault (Task "Task") model.currentTask

                estimationGroups =
                    groupBy (\e -> Maybe.withDefault "" e.estimation) model.currentEstimations

                values =
                    List.map
                        (\key ->
                            let
                                entries =
                                    Maybe.withDefault [] (Dict.get key estimationGroups)
                            in
                                toFloat (List.length entries)
                        )
                        (Dict.keys estimationGroups)

                labels =
                    List.map
                        (\key ->
                            let
                                entries =
                                    Maybe.withDefault [] (Dict.get key estimationGroups)

                                userNames =
                                    List.map (\user -> user.name) entries
                            in
                                key ++ " " ++ (toString userNames)
                        )
                        (Dict.keys estimationGroups)
            in
                div []
                    [ pie values labels
                        |> Chart.title task.name
                        |> colours [ "#2ECC40", "#0074D9", "#7FDBFF", "#FFDC00", "#FF851B", "#FF4136" ]
                        |> toHtml
                    ]
