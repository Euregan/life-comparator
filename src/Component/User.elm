module Component.User exposing (card)

import Component.Card as Card
import Component.DisplayOptions as DisplayOptions
import Data.Gender exposing (Gender(..))
import Data.Salary as Salary
import Data.User exposing (User)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Parser


card : DisplayOptions.Options -> (Maybe Float -> msg) -> User -> Html msg
card options userSalaryChanged user =
    Card.card (text "Vous")
        [ label [ for "salary" ] [ text "Salaire" ]
        , input
            [ id "salary"
            , type_ "number"
            , value <|
                Maybe.withDefault "" <|
                    Maybe.map String.fromFloat <|
                        Maybe.map (Salary.raw options.salary) user.salary
            , onInput
                (\raw ->
                    raw
                        |> Parser.run Parser.float
                        |> Result.toMaybe
                        |> userSalaryChanged
                )
            ]
            []
        , label [ for "gender" ] [ text "Genre" ]
        , select [ id "gender" ]
            [ option [ selected <| user.gender == Undisclosed ] [ text "Non communiqué" ]
            , option [ selected <| user.gender == Man ] [ text "Homme" ]
            , option [ selected <| user.gender == Woman ] [ text "Femme" ]
            ]
        ]
