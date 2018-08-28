module Example exposing (Model, Msg(..), ServiceResponseResult, init, main, makeRequest, request_kieServerInfo, request_kieServerStateInfo, update, view)

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)
import KieServer.Types as KS exposing (..)
import KieServer.Urls as Url


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }



-- MODEL


type alias Model =
    { response : String
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( Model "Initializing"
    , request_kieServerStateInfo
    )



-- UPDATE


type Msg
    = Request_KieServerInfo
    | Request_KieServerStateInfo
    | KieServerInfoArrived (ServiceResponseResult KieServerInfo)
    | KieServerStateInfoArrived (ServiceResponseResult KieServerStateInfo)


type alias ServiceResponseResult a =
    Result Http.Error (ServiceResponse a)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Request_KieServerInfo ->
            ( model, request_kieServerStateInfo )

        Request_KieServerStateInfo ->
            ( model, request_kieServerInfo )

        KieServerInfoArrived result ->
            ( { model | response = Debug.toString result }, Cmd.none )

        KieServerStateInfoArrived result ->
            ( { model | response = Debug.toString result }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Request_KieServerInfo ] [ text "Request KieServerInfo" ]
        , button [ onClick Request_KieServerStateInfo ] [ text "Request KieServerStateInfo" ]
        , br [] []
        , div [] [ text "Response from the server:", text model.response ]
        ]


request_kieServerInfo : Cmd Msg
request_kieServerInfo =
    Http.send KieServerInfoArrived <| makeRequest Url.base <| KS.serviceResponseDecoder KS.kieServerInfoDecoder


request_kieServerStateInfo : Cmd Msg
request_kieServerStateInfo =
    Http.send KieServerStateInfoArrived <| makeRequest Url.serverState <| KS.serviceResponseDecoder KS.kieServerStateInfoDecoder


makeRequest : String -> Decoder a -> Http.Request a
makeRequest apiUrl decoder =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Content-Type" "application/json" ]
        , url = apiUrl
        , body = Http.emptyBody
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }
