port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Json.Decode as Decode exposing (..)

-- MODEL

type alias Coords =
  { latitude: Float
  , longitude: Float
  }

type alias MessageEntity =
  { coords: Coords
  , createdAt: Int
  , message: String
  , name: String
  }

type alias MessageToPush =
  { coords: Coords
  , message: String
  }

coordsDecoder: Decoder Coords
coordsDecoder = map2 Coords ( field "latitude" float ) ( field "longitude" float )

messageDecoder: Decoder MessageEntity
messageDecoder = map4 MessageEntity ( field "coords" coordsDecoder ) ( field "createdAt" int ) ( field "message" string ) ( field "name" string )

messagesDecoder: Decoder (List MessageEntity)
messagesDecoder = list messageDecoder

recieve : Encode.Value -> List MessageEntity
recieve json =
  case Decode.decodeValue messagesDecoder json of
    Err err ->
      []
    Ok messages ->
      messages

type alias Model =
  { isLoggedIn: Bool
  , coords: Coords
  , username: String
  , messages: List MessageEntity
  , message: String
  }

init : (Model, Cmd Msg)
init =
  (Model False {longitude = 123, latitude = 123} "" [] "", Cmd.none)

-- UPDATE

type Msg
  = Login
  | Message Encode.Value
  | LoginResult (Maybe String)
  | SetCoords Coords
  | MessageChange String
  | PushMessage

port logIn : Bool -> Cmd msg
port sendMessage : MessageToPush -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Login ->
      ( model, logIn model.isLoggedIn )
    PushMessage ->
      ( model, sendMessage <| getMessage model )
    LoginResult (Just name) ->
      ( { model | isLoggedIn = True, username = name }, Cmd.none )
    LoginResult Nothing ->
      ( { model | isLoggedIn = False }, Cmd.none )
    Message message ->
      ( { model | messages = (recieve message) }, Cmd.none )
    SetCoords coords ->
      ( { model | coords = coords }, Cmd.none )
    MessageChange message ->
      ( { model | message = message }, Cmd.none )

-- SUBSCRIPTIONS

port listMessages : (Encode.Value -> msg) -> Sub msg
port listenLogin : ( Maybe String -> msg ) -> Sub msg

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ listMessages Message
    , listenLogin LoginResult
    ]

-- VIEW

getMessage: Model -> MessageToPush
getMessage model =
  {
    coords = model.coords,
    message = model.message
  }

messageView: MessageEntity -> Html Msg
messageView model =
  div [ onClick (SetCoords model.coords) ] [ text ( model.name ++ ": " ++ model.message) ]

footerView: ( String -> msg ) -> msg -> Html msg
footerView handleInputChange handleMessagePush =
  div []
    [ input [ onInput handleInputChange ] []
    , button [ onClick handleMessagePush ] [ text "Send" ] ]

chatView : Model -> Html Msg
chatView model =
  div []
    [ h4 [] [ text model.username ]
    , div [] [ text ("latitude: " ++ (toString  model.coords.latitude)) ]
    , div [] [ text ("longitude: " ++ (toString model.coords.longitude)) ]
    , h4 [] [ text "Messages" ]
    , div [] (List.map messageView model.messages)
    , footerView MessageChange PushMessage
    ]

view : Model -> Html Msg
view model =
  div [] [
    case model.isLoggedIn of
      True ->
        div []
          [ chatView model ]
      False ->
        div []
          [ button [ onClick Login ] [ text "Sign in" ] ]
  ]

main: Program Never Model Msg
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }
