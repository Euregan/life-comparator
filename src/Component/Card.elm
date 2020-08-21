module Component.Card exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


card : Html msg -> List (Html msg) -> Html msg
card title content =
    div [ class "card" ]
        [ div [ class "header" ] [ title ]
        , div [ class "body" ] content
        ]
