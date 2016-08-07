module Main exposing (..)

import Html exposing (..)
import Html.App as App
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import WebSocket
import Json.Decode as JD exposing ((:=))


main : Program Never
main =
    App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


planningPokerServer : String
planningPokerServer =
    "ws://localhost:8080/poker/1?name=Chris"



-- model


type alias User =
    { name : String
    }


type alias Model =
    { input : String
    , messages : List String
    , users : List User
    }


init : ( Model, Cmd Msg )
init =
    ( Model "" [] [], Cmd.none )



-- update


type Msg
    = Input String
    | Send
    | IncomingEvent String
      -- is being decoded and mapped to these:
    | UnexpectedPayload String
    | UserJoined User
    | UserLeft User


update : Msg -> Model -> ( Model, Cmd Msg )
update msg { input, messages, users } =
    case msg of
        Input newInput ->
            ( Model newInput messages users, Cmd.none )

        Send ->
            ( Model "" messages users, WebSocket.send planningPokerServer input )

        IncomingEvent payload ->
            let
                nextModel =
                    (Model input messages users)

                nextMessage =
                    decodePayload payload
            in
                update nextMessage nextModel

        UnexpectedPayload message ->
            ( Model input messages users, Cmd.none )

        UserJoined user ->
            ( Model input messages (user :: users), Cmd.none )

        UserLeft user ->
            let
                newUsers =
                    List.filter (\u -> u.name /= user.name) users
            in
                ( Model input messages newUsers, Cmd.none )



-- decoding


payloadDecoder : JD.Decoder Msg
payloadDecoder =
    ("eventType" := JD.string)
        `JD.andThen`
            \eventType ->
                case eventType of
                    "userJoined" ->
                        JD.map UserJoined (JD.object1 User ("name" := JD.string))

                    "userLeft" ->
                        JD.map UserLeft (JD.object1 User ("name" := JD.string))

                    _ ->
                        JD.fail (eventType ++ " is not a recognized event type")


decodePayload : String -> Msg
decodePayload payload =
    case JD.decodeString payloadDecoder payload of
        Err err ->
            UnexpectedPayload err

        Ok msg ->
            msg



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen planningPokerServer IncomingEvent



-- view


view : Model -> Html Msg
view model =
    div []
        [ input [ onInput Input, value model.input ] []
        , button [ onClick Send ] [ text "Send" ]
        , ul [] (List.map viewUser model.users)
        ]


viewUser : User -> Html msg
viewUser user =
    li [] [ text user.name ]
