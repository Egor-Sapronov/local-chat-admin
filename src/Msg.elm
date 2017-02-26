module Msg exposing (..)

import Json.Encode as Encode
import Models exposing (Coords)


type Msg
    = Login
    | Message Encode.Value
    | LoginResult Encode.Value
    | SetCoords Coords
    | MessageChange String
    | PushMessage
