module Component.Layout exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


columns : List (Html msg) -> Html msg
columns content =
    div [ class "columns" ]
        content
