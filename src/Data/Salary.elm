module Data.Salary exposing (..)

import Component.DisplayOptions as DisplayOptions
import Data.Cotisation exposing (Cotisation)
import Data.SocioProfessionalCategory exposing (SocioProfessionalCategory(..))


type Salary
    = NetMonthly Float
    | GrossMonthly Float
    | NetYearly Float
    | GrossYearly Float


raw : DisplayOptions.SalaryDisplay -> Cotisation -> SocioProfessionalCategory -> Salary -> Float
raw option cotisation socioProfessionalCategory salary =
    let
        isExecutive =
            case socioProfessionalCategory of
                Executive ->
                    True

                _ ->
                    False

        minimum a b =
            if a > b then
                b

            else
                a

        getCotisation : ( Float, Float ) -> Float
        getCotisation ( notExecutive, executive ) =
            if isExecutive then
                executive

            else
                notExecutive

        getCotisationFromLevel level =
            case level of
                0 ->
                    getCotisation cotisation.employerContribution.inferiorTo1Ceiling + getCotisation cotisation.employeeContribution.inferiorTo1Ceiling

                1 ->
                    getCotisation cotisation.employerContribution.between1And3Ceilings + getCotisation cotisation.employeeContribution.between1And3Ceilings

                2 ->
                    getCotisation cotisation.employerContribution.between1And3Ceilings + getCotisation cotisation.employeeContribution.between1And3Ceilings

                3 ->
                    getCotisation cotisation.employerContribution.between3And4Ceilings + getCotisation cotisation.employeeContribution.between3And4Ceilings

                4 ->
                    getCotisation cotisation.employerContribution.above4Ceilings + getCotisation cotisation.employeeContribution.between4And8Ceilings

                5 ->
                    getCotisation cotisation.employerContribution.above4Ceilings + getCotisation cotisation.employeeContribution.between4And8Ceilings

                6 ->
                    getCotisation cotisation.employerContribution.above4Ceilings + getCotisation cotisation.employeeContribution.between4And8Ceilings

                7 ->
                    getCotisation cotisation.employerContribution.above4Ceilings + getCotisation cotisation.employeeContribution.between4And8Ceilings

                _ ->
                    getCotisation cotisation.employerContribution.above4Ceilings + getCotisation cotisation.employeeContribution.above8Ceilings

        ceilingCotisation : Int -> Float -> Float -> Float
        ceilingCotisation level ceiling remainingSalary =
            if remainingSalary > 0 then
                minimum ceiling remainingSalary
                    * getCotisationFromLevel level
                    + ceilingCotisation (level + 1) ceiling (remainingSalary - ceiling)

            else
                0

        rawCotisation =
            case salary of
                NetMonthly amount ->
                    ceilingCotisation 0 cotisation.netCeiling amount

                NetYearly amount ->
                    ceilingCotisation 0 (cotisation.netCeiling * 12) amount

                GrossMonthly amount ->
                    ceilingCotisation 0 cotisation.grossCeiling amount

                GrossYearly amount ->
                    ceilingCotisation 0 (cotisation.grossCeiling * 12) amount
    in
    case ( option, salary ) of
        ( DisplayOptions.NetMonthly, NetMonthly amount ) ->
            amount

        ( DisplayOptions.NetMonthly, GrossMonthly amount ) ->
            amount - rawCotisation

        ( DisplayOptions.NetMonthly, NetYearly amount ) ->
            amount / 12

        ( DisplayOptions.NetMonthly, GrossYearly amount ) ->
            (amount - rawCotisation) / 12

        ( DisplayOptions.GrossMonthly, GrossMonthly amount ) ->
            amount

        ( DisplayOptions.GrossMonthly, NetMonthly amount ) ->
            amount + rawCotisation

        ( DisplayOptions.GrossMonthly, NetYearly amount ) ->
            (amount + rawCotisation) / 12

        ( DisplayOptions.GrossMonthly, GrossYearly amount ) ->
            amount / 12

        ( DisplayOptions.NetYearly, NetYearly amount ) ->
            amount

        ( DisplayOptions.NetYearly, NetMonthly amount ) ->
            amount * 12

        ( DisplayOptions.NetYearly, GrossMonthly amount ) ->
            (amount - rawCotisation) * 12

        ( DisplayOptions.NetYearly, GrossYearly amount ) ->
            amount - rawCotisation

        ( DisplayOptions.GrossYearly, GrossYearly amount ) ->
            amount

        ( DisplayOptions.GrossYearly, NetMonthly amount ) ->
            (amount + rawCotisation) * 12

        ( DisplayOptions.GrossYearly, GrossMonthly amount ) ->
            amount * 12

        ( DisplayOptions.GrossYearly, NetYearly amount ) ->
            amount + rawCotisation


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
