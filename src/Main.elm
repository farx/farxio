module Main exposing (..)

import Browser
import Html exposing (Html, text, div, h1, img, button)
import Html.Attributes exposing (src, width, height, style)
import Graphics exposing (logo)


---- MODEL ----


type alias Model =
    { }


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div [ style "background-color" "black"
        , style "align" "center"
        , style "height" "100vh"
        , style "display" "flex"
        ]
        [ div
          [ style "display" "flex"
          , style "flex-direction" "column"
          , style "justify-content" "center"
          , style "margin" "0 auto"
          ]
              [logo 200 "#0e0e0e" "gray"
                   ]
        ]


---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
