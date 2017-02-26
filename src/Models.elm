module Models exposing (..)


type alias User =
    { name : String
    , photoUrl : String
    , uid : String
    }


type alias Coords =
    { latitude : Float
    , longitude : Float
    }


type alias MessageEntity =
    { coords : Coords
    , createdAt : Int
    , message : String
    , name : String
    }


type alias MessageToPush =
    { coords : Coords
    , message : String
    }


type alias Model =
    { coords : Coords
    , user : Maybe User
    , messages : Maybe (List MessageEntity)
    , message : String
    }


initialModel : Model
initialModel =
    Model { longitude = 123, latitude = 123 } Nothing Nothing ""
