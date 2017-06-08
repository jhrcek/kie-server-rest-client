module Example exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Http
import KieServer.Types as KS exposing (ServiceResponse, KieServerInfo)


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
    , executionServerInfo
    )



-- UPDATE


type Msg
    = Reload
    | DataArrived (Result Http.Error (ServiceResponse KieServerInfo))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Reload ->
            ( model, executionServerInfo )

        DataArrived result ->
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


executionServerInfo : Cmd Msg
executionServerInfo =
    Http.send DataArrived <| makeRequest "/kie-execution-server/services/rest/server"


makeRequest : String -> Http.Request (ServiceResponse KieServerInfo)
makeRequest apiUrl =
    Http.request
        { method = "GET"
        , headers =
            [ Http.header "Content-Type" "application/json" ]
        , url = apiUrl
        , body = Http.emptyBody
        , expect = Http.expectJson (KS.serviceResponseDecoder KS.kieServerInfoDecoder)
        , timeout = Nothing
        , withCredentials = False
        }
