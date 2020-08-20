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
