module Main exposing (Msg(..), main, update, view)

import Browser exposing (Document)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as JSON


type Model
    = Ready Int Bool
    | Error String


init : JSON.Value -> ( Model, Cmd Msg )
init flags =
    let
        flagsResult =
            JSON.decodeValue JSON.bool flags
    in
    case flagsResult of
        Ok bool ->
            ( Ready 0 bool, Cmd.none )

        _ ->
            ( Error "Failed to decode flags", Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program JSON.Value Model Msg
main =
    Browser.document { init = init, update = update, view = view, subscriptions = subscriptions }


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model of
        Ready m darkMode ->
            case msg of
                Increment ->
                    ( Ready (m + 1) darkMode, Cmd.none )

                Decrement ->
                    ( Ready (m - 1) darkMode, Cmd.none )

        _ ->
            ( model, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "ElmHax"
    , body =
        case model of
            Ready m darkMode ->
                let
                    darkModeStyles =
                        if darkMode then
                            style "background-color" "black"

                        else
                            style "background-color" "white"
                in
                [ div [ darkModeStyles ]
                    [ button [ onClick Decrement ] [ text "-" ]
                    , div [] [ text (String.fromInt m) ]
                    , button [ onClick Increment ] [ text "+" ]
                    ]
                ]

            Error err ->
                [ text err ]
    }
