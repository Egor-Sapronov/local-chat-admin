module Views exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Msg exposing (..)


messageView : (Coords -> msg) -> MessageEntity -> Html msg
messageView handleClick model =
    div
        [ onClick (handleClick model.coords) ]
        [ text (model.name ++ ": " ++ model.message) ]


footerView : (String -> msg) -> msg -> Html msg
footerView handleInputChange handleMessagePush =
    div []
        [ input [ onInput handleInputChange ] []
        , button [ onClick handleMessagePush ] [ text "Send" ]
        ]


chatView : Model -> User -> Html Msg
chatView model user =
    div []
        [ h4 [] [ text user.name ]
        , div [] [ text ("latitude: " ++ (toString model.coords.latitude)) ]
        , div [] [ text ("longitude: " ++ (toString model.coords.longitude)) ]
        , h4 [] [ text "Messages" ]
        , div []
            [ case model.messages of
                Just messages ->
                    div [] ((List.map <| messageView <| SetCoords) messages)

                Nothing ->
                    text ""
            ]
        , footerView MessageChange PushMessage
        ]


appView : Model -> Html Msg
appView model =
    div []
        [ case model.user of
            Just user ->
                div []
                    [ chatView model user ]

            Nothing ->
                div []
                    [ button [ onClick Login ] [ text "Sign in" ] ]
        ]
