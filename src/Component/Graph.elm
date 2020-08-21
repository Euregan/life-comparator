module Component.Graph exposing (..)

import Axis
import Color
import Path exposing (Path)
import Scale exposing (ContinuousScale)
import Shape
import Time
import TypedSvg exposing (g, svg)
import TypedSvg.Attributes exposing (class, fill, stroke, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (strokeWidth)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types exposing (Paint(..), Transform(..))


w : Float
w =
    900


h : Float
h =
    450


padding : Float
padding =
    60


maxY : List (List ( Int, Maybe Float )) -> Float
maxY model =
    Maybe.withDefault 0 <|
        List.maximum <|
            List.map
                (List.foldl
                    (\( _, maybeValue ) acc ->
                        case maybeValue of
                            Nothing ->
                                acc

                            Just value ->
                                if value > acc then
                                    value

                                else
                                    acc
                    )
                    0
                )
                model


xScale : ContinuousScale Float
xScale =
    Scale.linear ( 0, w - 2 * padding ) ( 1950, 2020 )


yScale : Float -> ContinuousScale Float
yScale max =
    Scale.linear ( h - 2 * padding, 0 ) ( 0, max )


xAxis : List (List ( Int, Maybe Float )) -> Svg msg
xAxis model =
    Axis.bottom [ Axis.tickCount 20 ] xScale


yAxis : Float -> Svg msg
yAxis max =
    Axis.left [ Axis.tickCount 5 ] (yScale max)


transformToLineData : Float -> ( Int, Maybe Float ) -> Maybe ( Float, Float )
transformToLineData max ( x, maybeY ) =
    Maybe.map (\y -> ( Scale.convert xScale (toFloat x), Scale.convert (yScale max) y )) maybeY


line : Float -> List ( Int, Maybe Float ) -> Path
line max model =
    List.map (transformToLineData max) model
        |> Shape.line Shape.monotoneInXCurve


chart : List (List ( Int, Maybe Float )) -> Svg msg
chart model =
    svg [ viewBox 0 0 w h ]
        [ g [ transform [ Translate (padding - 1) (h - padding) ] ]
            [ xAxis model ]
        , g [ transform [ Translate (padding - 1) padding ] ]
            [ yAxis (maxY model) ]
        , g [ transform [ Translate padding padding ], class [ "series" ] ] <|
            List.map (\datapoints -> Path.element (line (maxY model) datapoints) [ stroke <| Paint <| Color.rgb 1 0 0, strokeWidth 3, fill PaintNone ]) model
        ]
