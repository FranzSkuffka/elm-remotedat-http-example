module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (src)
import Html.Events exposing (onClick)
import RemoteData.Http
import RemoteData
import Json.Decode as Decode


getCat : Cmd Msg
getCat =
    RemoteData.Http.get catApi HandleGetCat catDecoder

catApi = "https://api.thecatapi.com/v1/images/search?size=full"

catDecoder = Decode.index 0 (Decode.field "url" Decode.string)
---- MODEL ----

type alias Cat = String

type alias Model =
    {counter: Int, cat : RemoteData.WebData Cat}


init : ( Model, Cmd Msg )
init =
    ( {counter = 0 , cat = RemoteData.NotAsked}, Cmd.none )



---- UPDATE ----


type Msg
    = NoOp
    | Increment
    | Decrement
    | HandleGetCat (RemoteData.WebData Cat)
    | RequestCat


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( {model | counter = model.counter + 1}, Cmd.none )
        Decrement ->
            ( {model | counter = model.counter - 1}, Cmd.none )
        NoOp->
            ( model, Cmd.none )
        HandleGetCat catStatus ->
            ( {model | cat = catStatus}, Cmd.none )
        RequestCat ->
            ( {model | cat = RemoteData.Loading}, getCat )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [text (String.fromInt model.counter)]
        , button [onClick Decrement] [text "Decrement"]
        , button [onClick Increment] [text "Increment"]
        , button [onClick RequestCat] [text "Get me a cat"]
        , viewCat model.cat
        ]

viewCat cat =
    case cat of
        RemoteData.NotAsked -> text "click the button to request a cat"
        RemoteData.Loading -> text "FEtching the next available cat"
        RemoteData.Success url -> img [src url] []
        RemoteData.Failure e -> div [] [text "Cat not avialble sorry bro"]


---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
