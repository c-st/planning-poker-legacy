module Update exposing (..)

import Globals exposing (planningPokerServer)
import Model exposing (User, Task, Model, Page(..), Msg(..))
import JsonCoding
    exposing
        ( decodePayload
        , requestStartEstimationEncoded
        , userEstimationEncoded
        , requestShowResultEncoded
        )
import WebSocket
import String exposing (isEmpty)


containsUser : List User -> User -> Bool
containsUser users user =
    (users
        |> List.filter (\u -> u.name == user.name)
        |> List.length
    )
        > 0


replaceUser : User -> User -> User
replaceUser updatedUser user =
    if user.name == updatedUser.name then
        updatedUser
    else
        user


resetEstimation : User -> User
resetEstimation user =
    { user | hasEstimated = False, estimation = Nothing }


sufficientInfo : Model -> Bool
sufficientInfo model =
    not (String.isEmpty model.roomId) && not (String.isEmpty model.user.name)


sendPayload : User -> String -> String -> Cmd Msg
sendPayload user roomId payload =
    WebSocket.send (planningPokerServer user roomId) payload


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestStartEstimation task ->
            ( model
            , (sendPayload model.user model.roomId) (requestStartEstimationEncoded model.user task)
            )

        PerformEstimation estimate ->
            let
                user =
                    model.user

                task =
                    Maybe.withDefault (Task "") model.currentTask

                updatedUser =
                    { user | hasEstimated = True, estimation = Just estimate }
            in
                ( { model | user = updatedUser }
                , (sendPayload model.user model.roomId) (userEstimationEncoded updatedUser task)
                )

        RequestShowResult ->
            ( model
            , (sendPayload model.user model.roomId) (requestShowResultEncoded model.user)
            )

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
            let
                user =
                    model.user

                updatedUser =
                    { user | hasEstimated = False, estimation = Nothing }

                updatedUsers =
                    List.map resetEstimation model.users
            in
                ( { model | currentTask = Just task, user = updatedUser, users = updatedUsers }, Cmd.none )

        UserHasEstimated user ->
            let
                updatedUsers =
                    List.map (replaceUser user) model.users
            in
                ( { model | users = updatedUsers }, Cmd.none )

        EstimationResult users ->
            let
                filteredUsers =
                    List.filter (\u -> u.name /= model.user.name) users
            in
                ( { model | users = filteredUsers }, Cmd.none )
