module Decoders exposing (recieveUser, recieveMessages)

import Json.Encode as Encode
import Json.Decode as Decode exposing (..)

import Models exposing (..)

coordsDecoder: Decoder Coords
coordsDecoder =
  map2 Coords
    (field "latitude" float)
    (field "longitude" float)

messageDecoder: Decoder MessageEntity
messageDecoder =
  map4 MessageEntity
    (field "coords" coordsDecoder)
    (field "createdAt" int)
    (field "message" string)
    (field "name" string)

messagesDecoder: Decoder (List MessageEntity)
messagesDecoder =
  list messageDecoder

userDecoder: Decoder User
userDecoder =
  map3 User
    (field "name" string)
    (field "photoUrl" string)
    (field "uid" string)

recieveUser: Encode.Value -> Maybe User
recieveUser json =
  case Decode.decodeValue userDecoder json of
    Ok user ->
      Just user
    Err err ->
      Nothing

recieveMessages: Encode.Value -> Maybe (List MessageEntity)
recieveMessages json =
  case Decode.decodeValue messagesDecoder json of
    Ok messages ->
      Just messages
    Err err ->
      Nothing
