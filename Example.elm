module Example exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Http
import KieServer.Types as KS exposing (..)
import KieServer.Urls as Url
import Json.Decode as Decode exposing (Decoder)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { response : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "Initializing"
    , kieServerStateInfo
    )



-- UPDATE


type Msg
    = Reload
    | KieServerInfoArrived (ServiceResponseResult KieServerInfo)
    | KieServerStateInfoArrived (ServiceResponseResult KieServerStateInfo)


type alias ServiceResponseResult a =
    Result Http.Error (ServiceResponse a)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reload ->
            ( model, kieServerStateInfo )

        KieServerInfoArrived result ->
            ( { model | response = toString result }, Cmd.none )

        KieServerStateInfoArrived result ->
            ( { model | response = toString result }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Reload ] [ text "Reload" ]
        , br [] []
        , div [] [ text "Response from the server:", text model.response ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


kieServerInfo : Cmd Msg
kieServerInfo =
    Http.send KieServerInfoArrived <| makeRequest Url.base (KS.serviceResponseDecoder KS.kieServerInfoDecoder)


kieServerStateInfo : Cmd Msg
kieServerStateInfo =
    Http.send KieServerStateInfoArrived <| makeRequest Url.serverState (KS.serviceResponseDecoder KS.kieServerStateInfoDecoder)


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
