port module Main exposing (..)

import Html exposing (..)
import Json.Encode as Encode
import Models exposing (..)
import Decoders exposing (..)
import Msg exposing (..)
import Views exposing (appView)


-- UPDATES


port logIn : Bool -> Cmd msg


port sendMessage : MessageToPush -> Cmd msg


getMessage : Model -> MessageToPush
getMessage model =
    { coords = model.coords
    , message = model.message
    }


update : Msg -> Model -> ( Model, Cmd Msg )
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


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.none )


main : Program Never Model Msg
main =
    program
        { init = init
        , view = appView
        , update = update
        , subscriptions = subscriptions
        }
