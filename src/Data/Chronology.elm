module Data.Chronology exposing (..)

import Dict exposing (Dict(..))


type alias Chronology a =
    Dict Int a
