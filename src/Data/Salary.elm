module Data.Salary exposing (..)


type Salary
    = NetMonthly Float
    | GrossMonthly Float
    | NetYearly Float
    | GrossYearly Float


raw : Salary -> Float
raw salary =
    case salary of
        NetMonthly amount ->
            amount

        GrossMonthly amount ->
            amount * 0.65

        NetYearly amount ->
            amount / 12

        GrossYearly amount ->
            amount * 0.65 / 12


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
