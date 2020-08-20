module Data.SocioProfessionalCategories exposing (..)


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
