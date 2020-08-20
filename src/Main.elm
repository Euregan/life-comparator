module Main exposing (main)

import Browser
import Component.DisplayOptions as DisplayOptions
import Component.Salary as Salary
import Component.User as User
import Data.Chronology exposing (Chronology)
import Data.Gender exposing (Gender(..))
import Data.Salary as Salary exposing (Salary(..))
import Data.SocioProfessionalCategories exposing (SocioProfessionalCategories)
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
    }


type alias MenWomen a =
    { men : a
    , women : a
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
    { title = ""
    , body =
        [ User.card UserSalaryChanged model.user
        , DisplayOptions.card model.displayOptions SalaryDisplayChanged
        , table []
            [ thead []
                [ tr []
                    [ td [] []
                    , td [ colspan 4 ] [ text "Femmes" ]
                    , td [ colspan 4 ] [ text "Hommes" ]
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
                    (\( year, data ) ->
                        tr []
                            [ td [] [ text <| String.fromInt year ]
                            , td [] [ Salary.withoutKind model.displayOptions.salary data.women.executive ]
                            , td [] [ Salary.withoutKind model.displayOptions.salary data.women.technician ]
                            , td [] [ Salary.withoutKind model.displayOptions.salary data.women.employee ]
                            , td [] [ Salary.withoutKind model.displayOptions.salary data.women.worker ]
                            , td [] [ Salary.withoutKind model.displayOptions.salary data.men.executive ]
                            , td [] [ Salary.withoutKind model.displayOptions.salary data.men.technician ]
                            , td [] [ Salary.withoutKind model.displayOptions.salary data.men.employee ]
                            , td [] [ Salary.withoutKind model.displayOptions.salary data.men.worker ]
                            ]
                    )
                <|
                    Dict.toList model.salaries
            ]
        ]
    }
