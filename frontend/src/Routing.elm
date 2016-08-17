module Routing exposing (delta2url, url2messages)

import Model exposing (Model, Msg(SetRoomId))
import RouteUrl.Builder as Builder exposing (Builder, builder, path, replacePath)
import RouteUrl exposing (UrlChange)
import Navigation exposing (Location)


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
