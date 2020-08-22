module Main exposing (main)

import Browser
import Component.DisplayOptions as DisplayOptions
import Component.Graph as Graph
import Component.Layout as Layout
import Component.Salary as Salary
import Component.User as User
import Data.Chronology as Chronology exposing (Chronology)
import Data.Gender exposing (Gender(..))
import Data.MenWomen as MenWomen exposing (MenWomen)
import Data.Salary as Salary exposing (Salary(..))
import Data.SocioProfessionalCategories as SocioProfessionalCategories exposing (SocioProfessionalCategories)
import Data.Source exposing (Source)
import Data.User exposing (User)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


main =
    Browser.document
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }


type Msg
    = SalaryDisplayChanged DisplayOptions.SalaryDisplay
    | UserSalaryChanged (Maybe Float)


type alias Model =
    { user : User
    , displayOptions : DisplayOptions.Options
    , salaries : Chronology (MenWomen (SocioProfessionalCategories Salary))
    , inflation : Chronology Float
    }


type alias Flags =
    { salaries :
        { sources : List Source
        , data :
            List
                ( Int
                , { bySpc :
                        { menWomen :
                            MenWomen
                                { executive : Float
                                , technician : Float
                                , employee : Float
                                , worker : Float
                                }
                        }
                  }
                )
        }
    , inflation :
        { sources : List Source
        , data : List ( Int, Float )
        }
    }


init : Flags -> ( Model, Cmd msg )
init flags =
    ( { user = { salary = Nothing, gender = Undisclosed }
      , displayOptions =
            { salary = DisplayOptions.NetMonthly
            }
      , salaries =
            Dict.fromList flags.salaries.data
                |> Dict.map
                    (\year data ->
                        MenWomen
                            (SocioProfessionalCategories
                                (NetMonthly data.bySpc.menWomen.men.executive)
                                (NetMonthly data.bySpc.menWomen.men.technician)
                                (NetMonthly data.bySpc.menWomen.men.employee)
                                (NetMonthly data.bySpc.menWomen.men.worker)
                            )
                            (SocioProfessionalCategories
                                (NetMonthly data.bySpc.menWomen.women.executive)
                                (NetMonthly data.bySpc.menWomen.women.technician)
                                (NetMonthly data.bySpc.menWomen.women.employee)
                                (NetMonthly data.bySpc.menWomen.women.worker)
                            )
                    )
                |> Chronology.fromDict
      , inflation =
            Dict.fromList flags.inflation.data
                |> Dict.foldr (\year inflation ( inflations, previousInflation ) -> ( Dict.insert year (inflation * previousInflation) inflations, inflation * previousInflation )) ( Dict.empty, 1 )
                |> Tuple.first
                |> Chronology.fromDict
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        SalaryDisplayChanged salaryDisplay ->
            let
                oldOptions =
                    model.displayOptions

                newOptions =
                    { oldOptions | salary = salaryDisplay }
            in
            ( { model | displayOptions = newOptions }, Cmd.none )

        UserSalaryChanged newSalary ->
            let
                oldUser =
                    model.user

                newUser =
                    { oldUser | salary = Maybe.map NetMonthly newSalary }
            in
            ( { model | user = newUser }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    let
        salariesWithInflation =
            Chronology.merge
                (Maybe.map2
                    (\menWomenSalaries inflation ->
                        MenWomen.map
                            (SocioProfessionalCategories.map
                                (Salary.map
                                    (\salary ->
                                        salary * inflation
                                    )
                                )
                            )
                            menWomenSalaries
                    )
                )
                model.salaries
                model.inflation

        rawSalariesWithInflation =
            Chronology.map
                (\_ maybeSalaries -> Maybe.map (MenWomen.map (SocioProfessionalCategories.map Salary.raw)) maybeSalaries)
                salariesWithInflation
    in
    { title = ""
    , body =
        [ main_ []
            [ h1 [] [ text "Life comparator" ]
            , Layout.columns
                [ User.card UserSalaryChanged model.user
                , DisplayOptions.card model.displayOptions SalaryDisplayChanged
                ]
            , Layout.columns
                [ Graph.chart "Femmes"
                    [ Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ women } -> women.worker) salaries) rawSalariesWithInflation
                    , Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ women } -> women.employee) salaries) rawSalariesWithInflation
                    , Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ women } -> women.technician) salaries) rawSalariesWithInflation
                    , Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ women } -> women.executive) salaries) rawSalariesWithInflation
                    ]
                , Graph.chart "Hommes"
                    [ Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ men } -> men.worker) salaries) rawSalariesWithInflation
                    , Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ men } -> men.employee) salaries) rawSalariesWithInflation
                    , Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ men } -> men.technician) salaries) rawSalariesWithInflation
                    , Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ men } -> men.executive) salaries) rawSalariesWithInflation
                    ]
                ]
            , table []
                [ thead []
                    [ tr []
                        [ td [] []
                        , td [ colspan 4, class "center" ] [ text "Femmes" ]
                        , td [ colspan 4, class "center" ] [ text "Hommes" ]
                        ]
                    , tr []
                        [ td [] []
                        , td [] [ text "Cadre" ]
                        , td [] [ text "Profession intermédiaire" ]
                        , td [] [ text "Employé" ]
                        , td [] [ text "Ouvrier" ]
                        , td [] [ text "Cadre" ]
                        , td [] [ text "Profession intermédiaire" ]
                        , td [] [ text "Employé" ]
                        , td [] [ text "Ouvrier" ]
                        ]
                    ]
                , tbody [] <|
                    List.map
                        (\( year, maybeData ) ->
                            tr []
                                [ td [ class "year" ] [ text <| String.fromInt year ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\data -> Salary.withoutKind model.displayOptions.salary data.women.executive) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\data -> Salary.withoutKind model.displayOptions.salary data.women.technician) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\data -> Salary.withoutKind model.displayOptions.salary data.women.employee) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\data -> Salary.withoutKind model.displayOptions.salary data.women.worker) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\data -> Salary.withoutKind model.displayOptions.salary data.men.executive) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\data -> Salary.withoutKind model.displayOptions.salary data.men.technician) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\data -> Salary.withoutKind model.displayOptions.salary data.men.employee) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\data -> Salary.withoutKind model.displayOptions.salary data.men.worker) maybeData ]
                                ]
                        )
                    <|
                        List.reverse <|
                            Chronology.toList <|
                                salariesWithInflation
                ]
            ]
        ]
    }