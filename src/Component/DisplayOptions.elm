module Component.DisplayOptions exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type SalaryDisplay
    = NetMonthly
    | GrossMonthly
    | NetYearly
    | GrossYearly


type alias Options =
    { salary : SalaryDisplay
    }


card : Options -> (SalaryDisplay -> msg) -> Html msg
card options onSalaryDisplayChange =
    let
        salaryDisplayStringToType raw =
            case raw of
                "NetMonthly" ->
                    NetMonthly

                "GrossMonthly" ->
                    GrossMonthly

                "NetYearly" ->
                    NetYearly

                "GrossYearly" ->
                    GrossYearly

                _ ->
                    NetMonthly
    in
    div []
        [ label [ for "salary-display" ] [ text "Salaire" ]
        , select [ id "salary-display", onInput (\raw -> onSalaryDisplayChange (salaryDisplayStringToType raw)) ]
            [ option [ selected <| options.salary == NetMonthly, value "NetMonthly" ] [ text "Mensuel net" ]
            , option [ selected <| options.salary == GrossMonthly, value "GrossMonthly" ] [ text "Mensuel brut" ]
            , option [ selected <| options.salary == NetYearly, value "NetYearly" ] [ text "Annuel net" ]
            , option [ selected <| options.salary == GrossYearly, value "GrossYearly" ] [ text "Annuel brut" ]
            ]
        ]
