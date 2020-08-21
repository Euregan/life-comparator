module Data.MenWomen exposing (..)


type alias MenWomen a =
    { men : a
    , women : a
    }


map : (a -> b) -> MenWomen a -> MenWomen b
map func menWomen =
    { men = func menWomen.men
    , women = func menWomen.women
    }
