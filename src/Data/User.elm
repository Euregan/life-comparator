module Data.User exposing (User)

import Data.Gender exposing (Gender)
import Data.Salary exposing (Salary)


type alias User =
    { salary : Maybe Salary
    , gender : Gender
    }
