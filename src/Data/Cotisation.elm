module Data.Cotisation exposing (..)


type alias Cotisation =
    { grossCeiling : Float
    , netCeiling : Float
    , employerContribution :
        { inferiorTo1Ceiling : ( Float, Float )
        , between1And3Ceilings : ( Float, Float )
        , between3And4Ceilings : ( Float, Float )
        , above4Ceilings : ( Float, Float )
        }
    , employeeContribution :
        { inferiorTo1Ceiling : ( Float, Float )
        , between1And3Ceilings : ( Float, Float )
        , between3And4Ceilings : ( Float, Float )
        , between4And8Ceilings : ( Float, Float )
        , above8Ceilings : ( Float, Float )
        }
    }
