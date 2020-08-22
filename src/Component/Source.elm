module Component.Source exposing (list)

import Data.Source exposing (Source)
import Html exposing (..)
import Html.Attributes exposing (..)


list : List Source -> Html msg
list sources =
    div [ class "sources" ]
        [ div [ class "title" ] [ text "Sources" ]
        , ul [] <| List.map item sources
        ]


item : Source -> Html msg
item source =
    li []
        [ a [ href source.url, target "_blank" ] [ text <| source.label ++ " | " ++ source.organism ++ " | " ++ source.date ] ]
