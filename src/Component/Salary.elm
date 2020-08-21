module Component.Salary exposing (..)

import Component.DisplayOptions as DisplayOptions
import Data.Salary exposing (Salary(..))
import Html exposing (..)


withoutKind : DisplayOptions.SalaryDisplay -> Salary -> Html msg
withoutKind option salary =
    case ( option, salary ) of
        ( DisplayOptions.NetMonthly, NetMonthly amount ) ->
            text <| String.fromInt (round amount) ++ "€"

        ( DisplayOptions.NetMonthly, GrossMonthly amount ) ->
            text <| String.fromInt (round <| amount * 0.65) ++ "€"

        ( DisplayOptions.NetMonthly, NetYearly amount ) ->
            text <| String.fromInt (round <| amount / 12) ++ "€"

        ( DisplayOptions.NetMonthly, GrossYearly amount ) ->
            text <| String.fromInt (round <| amount * 0.65 / 12) ++ "€"

        ( DisplayOptions.GrossMonthly, GrossMonthly amount ) ->
            text <| String.fromInt (round amount) ++ "€"

        ( DisplayOptions.GrossMonthly, NetMonthly amount ) ->
            text <| String.fromInt (round <| amount * 1.35) ++ "€"

        ( DisplayOptions.GrossMonthly, NetYearly amount ) ->
            text <| String.fromInt (round <| amount * 1.35 / 12) ++ "€"

        ( DisplayOptions.GrossMonthly, GrossYearly amount ) ->
            text <| String.fromInt (round <| amount / 12) ++ "€"

        ( DisplayOptions.NetYearly, NetYearly amount ) ->
            text <| String.fromInt (round amount) ++ "€"

        ( DisplayOptions.NetYearly, NetMonthly amount ) ->
            text <| String.fromInt (round <| amount * 12) ++ "€"

        ( DisplayOptions.NetYearly, GrossMonthly amount ) ->
            text <| String.fromInt (round <| amount * 12 * 0.65) ++ "€"

        ( DisplayOptions.NetYearly, GrossYearly amount ) ->
            text <| String.fromInt (round <| amount * 0.65) ++ "€"

        ( DisplayOptions.GrossYearly, GrossYearly amount ) ->
            text <| String.fromInt (round amount) ++ "€"

        ( DisplayOptions.GrossYearly, NetMonthly amount ) ->
            text <| String.fromInt (round <| amount * 1.35 * 12) ++ "€"

        ( DisplayOptions.GrossYearly, GrossMonthly amount ) ->
            text <| String.fromInt (round <| amount * 12) ++ "€"

        ( DisplayOptions.GrossYearly, NetYearly amount ) ->
            text <| String.fromInt (round <| amount * 1.35) ++ "€"
