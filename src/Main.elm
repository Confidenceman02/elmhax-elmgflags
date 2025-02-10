module Main exposing (Msg(..), main, update, view)

import Browser exposing (Document)
import Html exposing (Html, button, div, h1, h2, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http exposing (get)
import Json.Decode as JSON
import Json.Decode.Pipeline exposing (required)


type alias Item =
    { ask : Float
    , bid : Float
    , mid : Float
    , method : String
    , tenor : Tenor
    , yieldRange : Maybe Float
    }


type alias Data =
    { dateAsOf : String
    , items : List Item
    }


type Tenor
    = M1
    | M2
    | M3
    | M4
    | M5
    | M6


toTenorDecoder : String -> JSON.Decoder Tenor
toTenorDecoder t =
    case t of
        "1M" ->
            JSON.succeed M1

        "2M" ->
            JSON.succeed M2

        "3M" ->
            JSON.succeed M3

        "4M" ->
            JSON.succeed M4

        "5M" ->
            JSON.succeed M5

        "6M" ->
            JSON.succeed M6

        _ ->
            JSON.fail "Failed to decode tenor"


decode : JSON.Decoder Data
decode =
    JSON.at [ "data" ]
        (JSON.succeed Data
            |> required "dateAsOf" JSON.string
            |> required "items"
                (JSON.list
                    (JSON.succeed Item
                        |> required "ask" JSON.float
                        |> required "bid" JSON.float
                        |> required "mid" JSON.float
                        |> required "method" JSON.string
                        |> required "tenor" (JSON.andThen toTenorDecoder JSON.string)
                        |> required "yieldRange" (JSON.map String.toFloat JSON.string)
                    )
                )
        )


type Model
    = Ready Data
    | Error String
    | Loading


getData : Cmd Msg
getData =
    get
        { url = "https://asx.api.markitdigital.com/asx-research/1.0/bbsw/rates"
        , expect = Http.expectJson GotData decode
        }


init : JSON.Value -> ( Model, Cmd Msg )
init _ =
    ( Loading, getData )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program JSON.Value Model Msg
main =
    Browser.document { init = init, update = update, view = view, subscriptions = subscriptions }


type Msg
    = GotData (Result Http.Error Data)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotData result ->
            case result of
                Err err ->
                    ( Error "Something bad happened", Cmd.none )

                Ok data ->
                    ( Ready data, Cmd.none )


view : Model -> Document Msg
view model =
    { title = "ElmHax"
    , body =
        case model of
            Loading ->
                [ h2 [] [ text " Loading" ] ]

            Ready data ->
                [ div []
                    (List.map viewItem data.items)
                ]

            Error err ->
                [ text err ]
    }


viewItem : Item -> Html msg
viewItem i =
    let
        tenorToPresentationalString =
            case i.tenor of
                M1 ->
                    "One month"

                M2 ->
                    "Two months"

                M3 ->
                    "Three months"

                M4 ->
                    "Four months"

                M5 ->
                    "Five months"

                M6 ->
                    "Six months"
    in
    div []
        [ h1 [] [ text tenorToPresentationalString ]
        , div [] [ text (String.fromFloat i.ask) ]
        , div [] [ text (String.fromFloat i.bid) ]
        , div [] [ text (String.fromFloat i.mid) ]
        , div [] [ text (Maybe.map String.fromFloat i.yieldRange |> Maybe.withDefault "-") ]
        ]
