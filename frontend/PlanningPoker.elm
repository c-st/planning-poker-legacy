module Main exposing (..)

import String exposing (isEmpty)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RouteUrl.Builder as Builder exposing (Builder, builder, path, replacePath)
import RouteUrl exposing (UrlChange)
import Navigation exposing (Location)
import Platform.Sub exposing (none)
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



-- model


type Page
    = LandingPage
    | PlanningPokerRoom


type alias User =
    { name : String
    , hasEstimated : Bool
    , estimation : Maybe String
    }


type alias Task =
    { name : String
    }


type alias Model =
    { activePage : Page
    , roomId : String
    , roomJoined : Bool
    , input : String
    , messages : List String
    , user : User
    , users : List User
    , currentTask : Maybe Task
    }


init : ( Model, Cmd Msg )
init =
    ( Model LandingPage "" False "" [] (User "" False Nothing) [] Nothing, Cmd.none )



-- update


type Msg
    = Input String
    | Send
    | SetUserName String
    | SetRoomId String
    | JoinRoom
    | LeaveRoom
    | IncomingEvent String
      -- is being decoded and mapped to these:
    | UnexpectedPayload String
    | UserJoined User
    | UserLeft User
    | StartEstimation Task


containsUser : List User -> User -> Bool
containsUser users user =
    (users
        |> List.filter (\u -> u.name == user.name)
        |> List.length
    )
        > 0


sufficientInfo : Model -> Bool
sufficientInfo model =
    not (String.isEmpty model.roomId) && not (String.isEmpty model.user.name)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input newInput ->
            ( { model | input = newInput }, Cmd.none )

        Send ->
            ( model, WebSocket.send (planningPokerServer model.user model.roomId) model.input )

        SetUserName newName ->
            ( { model | user = (User newName False Nothing) }, Cmd.none )

        SetRoomId newRoomId ->
            ( { model | roomId = newRoomId }, Cmd.none )

        JoinRoom ->
            let
                newPage =
                    if not (sufficientInfo model) then
                        LandingPage
                    else
                        PlanningPokerRoom
            in
                ( { model | roomJoined = sufficientInfo model, activePage = newPage, users = [] }, Cmd.none )

        LeaveRoom ->
            ( { model | roomJoined = False, roomId = "", currentTask = Nothing, activePage = LandingPage }, Cmd.none )

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

        StartEstimation task ->
            ( { model | currentTask = Just task }, Cmd.none )



-- decoding


payloadDecoder : JD.Decoder Msg
payloadDecoder =
    ("eventType" := JD.string)
        `JD.andThen`
            \eventType ->
                case eventType of
                    "userJoined" ->
                        JD.map UserJoined
                            (JD.object3 User
                                ("name" := JD.string)
                                (JD.succeed False)
                                (JD.succeed Nothing)
                            )

                    "userLeft" ->
                        JD.map UserLeft
                            (JD.object3 User
                                ("name" := JD.string)
                                (JD.succeed False)
                                (JD.succeed Nothing)
                            )

                    "startEstimation" ->
                        JD.map StartEstimation (JD.object1 Task ("taskName" := JD.string))

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
    case model.roomJoined of
        True ->
            let
                serverUrl =
                    planningPokerServer model.user model.roomId
            in
                WebSocket.listen serverUrl IncomingEvent

        False ->
            Platform.Sub.none


planningPokerServer : User -> String -> String
planningPokerServer user room =
    ("ws://localhost:8080/poker/" ++ room ++ "?name=" ++ user.name)



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
        [ mainContent model ]


mainContent : Model -> Html Msg
mainContent model =
    case model.activePage of
        LandingPage ->
            div [] [ landingPageContent model ]

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
        userName =
            model.user.name

        task =
            Maybe.withDefault (Task "") model.currentTask
    in
        div []
            [ h3 [] [ text ("userName: " ++ userName) ]
            , button [ onClick LeaveRoom ] [ text "Leave room" ]
            , h3 [] [ text ("currentTask: " ++ task.name) ]
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
