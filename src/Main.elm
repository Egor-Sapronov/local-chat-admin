port module Main exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Json.Encode as Encode
import Json.Decode as Decode exposing (..)

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

-- MODEL

type alias User =
  { name: String
  , photoUrl: String
  , uid: String
  }

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

type alias Model =
  { coords: Coords
  , user: Maybe User
  , messages: Maybe (List MessageEntity)
  , message: String
  }

init : (Model, Cmd Msg)
init =
  (Model {longitude = 123, latitude = 123} Nothing Nothing "", Cmd.none)

-- UPDATE

type Msg
  = Login
  | Message Encode.Value
  | LoginResult Encode.Value
  | SetCoords Coords
  | MessageChange String
  | PushMessage

port logIn : Bool -> Cmd msg
port sendMessage : MessageToPush -> Cmd msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Login ->
      ( model, logIn False )
    PushMessage ->
      ( model, sendMessage <| getMessage model )
    LoginResult user ->
      ( { model | user = (recieveUser user) }, Cmd.none )
    Message message ->
      ( { model | messages = (recieveMessages message) }, Cmd.none )
    SetCoords coords ->
      ( { model | coords = coords }, Cmd.none )
    MessageChange message ->
      ( { model | message = message }, Cmd.none )

-- SUBSCRIPTIONS

port listMessages : (Encode.Value -> msg) -> Sub msg
port listenLogin : (Encode.Value -> msg) -> Sub msg

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

messageView: (Coords -> msg) -> MessageEntity -> Html msg
messageView handleClick model =
  div [ onClick (handleClick model.coords) ] [ text ( model.name ++ ": " ++ model.message) ]

footerView: ( String -> msg ) -> msg -> Html msg
footerView handleInputChange handleMessagePush =
  div []
    [ input [ onInput handleInputChange ] []
    , button [ onClick handleMessagePush ] [ text "Send" ] ]

chatView : Model -> User -> Html Msg
chatView model user =
  div []
    [ h4 [] [ text user.name]
    , div [] [ text ("latitude: " ++ (toString  model.coords.latitude)) ]
    , div [] [ text ("longitude: " ++ (toString model.coords.longitude)) ]
    , h4 [] [ text "Messages" ]
    , div [] [
      case model.messages of
        Just messages ->
          div [] ((List.map <| messageView <| SetCoords) messages)
        Nothing ->
          text ""
      ]
    , footerView MessageChange PushMessage
    ]

view : Model -> Html Msg
view model =
  div [] [
    case model.user of
      Just user ->
        div []
          [ chatView model user ]
      Nothing ->
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
