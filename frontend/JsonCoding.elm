module JsonCoding exposing (..)

import Model exposing (User, Task, Msg(..))
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE exposing (encode)


payloadDecoder : JD.Decoder Msg
payloadDecoder =
    ("eventType" := JD.string)
        `JD.andThen`
            \eventType ->
                case eventType of
                    "userJoined" ->
                        JD.map UserJoined
                            (JD.object3 User
                                ("userName" := JD.string)
                                (JD.succeed False)
                                (JD.succeed Nothing)
                            )

                    "userLeft" ->
                        JD.map UserLeft
                            (JD.object3 User
                                ("userName" := JD.string)
                                (JD.succeed False)
                                (JD.succeed Nothing)
                            )

                    "startEstimation" ->
                        JD.map StartEstimation (JD.object1 Task ("taskName" := JD.string))

                    "userHasEstimated" ->
                        JD.map UserHasEstimated
                            (JD.object3 User
                                ("userName" := JD.string)
                                (JD.succeed True)
                                (JD.succeed Nothing)
                            )

                    "estimationResult" ->
                        JD.map EstimationResult
                            (JD.at
                                [ "estimates" ]
                                (JD.list
                                    (JD.object3 User
                                        ("userName" := JD.string)
                                        (JD.succeed True)
                                        (JD.maybe ("estimate" := JD.string))
                                    )
                                )
                            )

                    _ ->
                        JD.fail (eventType ++ " is not a recognized event type")


decodePayload : String -> Msg
decodePayload payload =
    case JD.decodeString payloadDecoder payload of
        Err err ->
            UnexpectedPayload err

        Ok msg ->
            msg


userEstimationEncoded : User -> Task -> String
userEstimationEncoded user task =
    let
        estimation =
            Maybe.withDefault "" user.estimation

        list =
            [ ( "eventType", JE.string "estimate" )
            , ( "userName", JE.string user.name )
            , ( "taskName", JE.string task.name )
            , ( "estimate", JE.string estimation )
            ]
    in
        list |> JE.object |> JE.encode 0
