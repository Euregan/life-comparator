module Data.Salary exposing (..)

import Component.DisplayOptions as DisplayOptions


type Salary
    = NetMonthly Float
    | GrossMonthly Float
    | NetYearly Float
    | GrossYearly Float


raw : DisplayOptions.SalaryDisplay -> Salary -> Float
raw option salary =
    case ( option, salary ) of
        ( DisplayOptions.NetMonthly, NetMonthly amount ) ->
            amount

        ( DisplayOptions.NetMonthly, GrossMonthly amount ) ->
            amount * 0.65

        ( DisplayOptions.NetMonthly, NetYearly amount ) ->
            amount / 12

        ( DisplayOptions.NetMonthly, GrossYearly amount ) ->
            amount * 0.65 / 12

        ( DisplayOptions.GrossMonthly, GrossMonthly amount ) ->
            amount

        ( DisplayOptions.GrossMonthly, NetMonthly amount ) ->
            amount * 1.35

        ( DisplayOptions.GrossMonthly, NetYearly amount ) ->
            amount * 1.35 / 12

        ( DisplayOptions.GrossMonthly, GrossYearly amount ) ->
            amount / 12

        ( DisplayOptions.NetYearly, NetYearly amount ) ->
            amount

        ( DisplayOptions.NetYearly, NetMonthly amount ) ->
            amount * 12

        ( DisplayOptions.NetYearly, GrossMonthly amount ) ->
            amount * 12 * 0.65

        ( DisplayOptions.NetYearly, GrossYearly amount ) ->
            amount * 0.65

        ( DisplayOptions.GrossYearly, GrossYearly amount ) ->
            amount

        ( DisplayOptions.GrossYearly, NetMonthly amount ) ->
            amount * 1.35 * 12

        ( DisplayOptions.GrossYearly, GrossMonthly amount ) ->
            amount * 12

        ( DisplayOptions.GrossYearly, NetYearly amount ) ->
            amount * 1.35


map : (Float -> Float) -> Salary -> Salary
map func salary =
    case salary of
        NetMonthly amount ->
            NetMonthly <| func amount

        GrossMonthly amount ->
            GrossMonthly <| func amount

        NetYearly amount ->
            NetYearly <| func amount

        GrossYearly amount ->
            GrossYearly <| func amount
