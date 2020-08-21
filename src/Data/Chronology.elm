module Data.Chronology exposing (Chronology, fromDict, map, merge, toList)

import Dict exposing (Dict(..))


type alias Chronology a =
    Dict Int a


fromDict : Dict Int a -> Chronology a
fromDict dict =
    dict


map : (Int -> a -> b) -> Chronology a -> Chronology b
map func chronology =
    Dict.map func chronology


toList : Chronology a -> List ( Int, a )
toList chronology =
    Dict.toList chronology


merge : (Maybe a -> Maybe b -> c) -> Chronology a -> Chronology b -> Chronology c
merge merger chronologyA chronologyB =
    Dict.merge
        (\key a acc -> Dict.insert key (merger (Just a) Nothing) acc)
        (\key a b acc -> Dict.insert key (merger (Just a) (Just b)) acc)
        (\key b acc -> Dict.insert key (merger Nothing (Just b)) acc)
        chronologyA
        chronologyB
        Dict.empty
