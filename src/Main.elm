module Main exposing (main)

import Browser
import Color
import Component.DisplayOptions as DisplayOptions
import Component.Graph as Graph
import Component.Layout as Layout
import Component.Salary as Salary
import Component.Source as Source
import Data.Chronology as Chronology exposing (Chronology)
import Data.Cotisation exposing (Cotisation)
import Data.Gender exposing (Gender(..))
import Data.MenWomen as MenWomen exposing (MenWomen)
import Data.Salary as Salary exposing (Salary(..))
import Data.SocioProfessionalCategories as SocioProfessionalCategories exposing (SocioProfessionalCategories)
import Data.SocioProfessionalCategory exposing (SocioProfessionalCategory(..))
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
    , sources : List Source
    , salaries : Chronology (MenWomen (SocioProfessionalCategories Salary))
    , inflation : Chronology Float
    , cotisations : Chronology Cotisation
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
    , cotisations :
        { sources : List Source
        , data :
            List ( Int, Cotisation )
        }
    }


init : Flags -> ( Model, Cmd msg )
init flags =
    ( { user = { salary = Nothing, gender = Undisclosed }
      , displayOptions =
            { salary = DisplayOptions.NetMonthly
            }
      , sources = List.concat [ flags.salaries.sources, flags.inflation.sources, flags.cotisations.sources ]
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
      , cotisations =
            Dict.fromList flags.cotisations.data
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
        salariesWithInflation : Chronology (Maybe (MenWomen (SocioProfessionalCategories Salary)))
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

        salariesWithInflationAndCotisation : Chronology (Maybe ( Cotisation, MenWomen (SocioProfessionalCategories Salary) ))
        salariesWithInflationAndCotisation =
            Chronology.merge
                (Maybe.map2 (\cotisation salary -> ( cotisation, salary )))
                model.cotisations
                salariesWithInflation
                |> Chronology.map
                    (\_ data ->
                        case data of
                            Nothing ->
                                Nothing

                            Just ( cotisation, Nothing ) ->
                                Nothing

                            Just ( cotisation, Just salary ) ->
                                Just ( cotisation, salary )
                    )

        rawSalariesWithInflation : Chronology (Maybe (MenWomen (SocioProfessionalCategories Float)))
        rawSalariesWithInflation =
            Chronology.map
                (\_ maybeData -> Maybe.map (\( cotisation, salary ) -> MenWomen.map (SocioProfessionalCategories.mapWithCategory (Salary.raw model.displayOptions.salary cotisation)) salary) maybeData)
                salariesWithInflationAndCotisation
    in
    { title = ""
    , body =
        [ main_ []
            [ h1 [] [ text "Life comparator" ]
            , DisplayOptions.card model.displayOptions SalaryDisplayChanged
            , Layout.columns
                [ Graph.chart "Femmes"
                    [ ( Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ women } -> women.worker) salaries) rawSalariesWithInflation, Color.rgb 0.99 0.52 0.54 )
                    , ( Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ women } -> women.employee) salaries) rawSalariesWithInflation, Color.rgb 1 0.6 0.53 )
                    , ( Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ women } -> women.technician) salaries) rawSalariesWithInflation, Color.rgb 1 0.67 0.53 )
                    , ( Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ women } -> women.executive) salaries) rawSalariesWithInflation, Color.rgb 1 0.76 0.53 )
                    ]
                , Graph.chart "Hommes"
                    [ ( Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ men } -> men.worker) salaries) rawSalariesWithInflation, Color.rgb 0.99 0.52 0.54 )
                    , ( Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ men } -> men.employee) salaries) rawSalariesWithInflation, Color.rgb 1 0.6 0.53 )
                    , ( Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ men } -> men.technician) salaries) rawSalariesWithInflation, Color.rgb 1 0.67 0.53 )
                    , ( Chronology.toList <| Chronology.map (\_ salaries -> Maybe.map (\{ men } -> men.executive) salaries) rawSalariesWithInflation, Color.rgb 1 0.76 0.53 )
                    ]
                ]
            , table []
                [ thead []
                    [ tr []
                        [ th [] []
                        , th [ colspan 4, class "center" ] [ text "Femmes" ]
                        , th [ colspan 4, class "center" ] [ text "Hommes" ]
                        ]
                    , tr []
                        [ th [] []
                        , th [] [ text "Cadre" ]
                        , th [] [ text "Profession intermédiaire" ]
                        , th [] [ text "Employé" ]
                        , th [] [ text "Ouvrier" ]
                        , th [] [ text "Cadre" ]
                        , th [] [ text "Profession intermédiaire" ]
                        , th [] [ text "Employé" ]
                        , th [] [ text "Ouvrier" ]
                        ]
                    ]
                , tbody [] <|
                    List.map
                        (\( year, maybeData ) ->
                            tr []
                                [ td [ class "year" ] [ text <| String.fromInt year ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\( cotisation, data ) -> Salary.withoutKind model.displayOptions.salary cotisation Executive data.women.executive) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\( cotisation, data ) -> Salary.withoutKind model.displayOptions.salary cotisation Technician data.women.technician) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\( cotisation, data ) -> Salary.withoutKind model.displayOptions.salary cotisation Employee data.women.employee) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\( cotisation, data ) -> Salary.withoutKind model.displayOptions.salary cotisation Worker data.women.worker) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\( cotisation, data ) -> Salary.withoutKind model.displayOptions.salary cotisation Executive data.men.executive) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\( cotisation, data ) -> Salary.withoutKind model.displayOptions.salary cotisation Technician data.men.technician) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\( cotisation, data ) -> Salary.withoutKind model.displayOptions.salary cotisation Employee data.men.employee) maybeData ]
                                , td [] [ Maybe.withDefault (text "Donnée manquante") <| Maybe.map (\( cotisation, data ) -> Salary.withoutKind model.displayOptions.salary cotisation Worker data.men.worker) maybeData ]
                                ]
                        )
                    <|
                        List.reverse <|
                            Chronology.toList <|
                                salariesWithInflationAndCotisation
                ]
            , Source.list model.sources
            ]
        ]
    }
