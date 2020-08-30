module Data.SocioProfessionalCategories exposing (..)

import Data.SocioProfessionalCategory exposing (SocioProfessionalCategory(..))


type alias SocioProfessionalCategories a =
    { executive : a
    , technician : a
    , employee : a
    , worker : a
    }


map : (a -> b) -> SocioProfessionalCategories a -> SocioProfessionalCategories b
map fun categories =
    { executive = fun categories.executive
    , technician = fun categories.technician
    , employee = fun categories.employee
    , worker = fun categories.worker
    }


mapWithCategory : (SocioProfessionalCategory -> a -> b) -> SocioProfessionalCategories a -> SocioProfessionalCategories b
mapWithCategory fun categories =
    { executive = fun Executive categories.executive
    , technician = fun Technician categories.technician
    , employee = fun Employee categories.employee
    , worker = fun Worker categories.worker
    }
