module Data.SourcedData exposing (SourcedData)

import Data.Source exposing (Source)


type alias InternalSourcedData a b =
    { a
        | data : b
    }


type alias SourcedData data =
    InternalSourcedData Source data
