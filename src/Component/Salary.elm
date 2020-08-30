module Component.Salary exposing (..)

import Component.DisplayOptions as DisplayOptions
import Data.Cotisation exposing (Cotisation)
import Data.Salary exposing (Salary(..))
import Data.SocioProfessionalCategory exposing (SocioProfessionalCategory(..))
import Html exposing (..)


withoutKind : DisplayOptions.SalaryDisplay -> Cotisation -> SocioProfessionalCategory -> Salary -> Html msg
withoutKind option cotisation spc salary =
    text <| String.fromInt (round <| Data.Salary.raw option cotisation spc salary) ++ "€"
