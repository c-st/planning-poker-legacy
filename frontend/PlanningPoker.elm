module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RouteUrl.Builder as Builder exposing (Builder, builder, path, replacePath)
import RouteUrl exposing (UrlChange)
import Navigation exposing (Location)
import WebSocket
import Json.Decode as JD exposing ((:=))


main : Program Never
main =
    RouteUrl.program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , delta2url = delta2url
        , location2messages = url2messages
        }


planningPokerServer : String
planningPokerServer =
    "ws://localhost:8080/poker/1?name=Chris"



-- model


type Page
    = LandingPage
    | PlanningPokerRoom


type alias User =
    { name : String
    }


type alias Model =
    { activePage : Page
    , roomId : String
    , input : String
    , messages : List String
    , users : List User
    }


init : ( Model, Cmd Msg )
init =
    ( Model LandingPage "" "" [] [], Cmd.none )



-- update


type Msg
    = Input String
    | Send
    | SetRoomId String
    | JoinRoom
    | IncomingEvent String
      -- is being decoded and mapped to these:
    | UnexpectedPayload String
    | UserJoined User
    | UserLeft User


containsUser : List User -> User -> Bool
containsUser users user =
    (users
        |> List.filter (\u -> u.name == user.name)
        |> List.length
    )
        > 0


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input newInput ->
            ( { model
                | input = newInput
              }
            , Cmd.none
            )

        Send ->
            ( model, WebSocket.send planningPokerServer model.input )

        SetRoomId newRoomId ->
            ( { model
                | roomId = newRoomId
              }
            , Cmd.none
            )

        JoinRoom ->
            ( model, Cmd.none )

        -- reestablish connection
        IncomingEvent payload ->
            let
                nextMessage =
                    decodePayload payload
            in
                update nextMessage model

        UnexpectedPayload message ->
            ( model, Cmd.none )

        UserJoined user ->
            let
                newUsers =
                    if containsUser model.users user then
                        model.users
                    else
                        user :: model.users
            in
                ( { model | users = newUsers }, Cmd.none )

        UserLeft user ->
            let
                newUsers =
                    List.filter (\u -> u.name /= user.name) model.users
            in
                ( { model | users = newUsers }, Cmd.none )



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



-- routing


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
    Maybe.map Builder.toUrlChange <|
        delta2builder previous current


delta2builder : Model -> Model -> Maybe Builder
delta2builder previous current =
    builder
        |> replacePath [ current.roomId ]
        |> Just


url2messages : Location -> List Msg
url2messages location =
    builder2messages (Builder.fromUrl location.href)


builder2messages : Builder -> List Msg
builder2messages builder =
    case path builder of
        first :: rest ->
            [ SetRoomId first ]

        _ ->
            []



-- view


view : Model -> Html Msg
view model =
    div []
        [ input [ onInput SetRoomId, value model.roomId ] []
        , button [ onClick JoinRoom ] [ text "Join room" ]
        , h3 [] [ text ("roomId: " ++ model.roomId) ]
        , input [ onInput Input, value model.input ] []
        , button [ onClick Send ] [ text "Send" ]
        , ul [] (List.map viewUser model.users)
        ]


viewUser : User -> Html msg
viewUser user =
    li [] [ text user.name ]


title : String
title =
    "Planning poker"
