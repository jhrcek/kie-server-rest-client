module KieServer.Types exposing (..)

import Date exposing (Date)
import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)


-- org.kie.server.api.model.ServiceResponse


type alias ServiceResponse a =
    { type_ : ResponseType
    , msg : String
    , result : a
    }


serviceResponseDecoder : Decoder a -> Decoder (ServiceResponse a)
serviceResponseDecoder contentDecoder =
    Decode.map3 ServiceResponse
        (Decode.field "type" responseTypeDecoder)
        (Decode.field "msg" Decode.string)
        (Decode.field "result" contentDecoder)



-- org.kie.server.api.model.ServiceResponse.ResponseType


type ResponseType
    = SUCCESS
    | FAILURE
    | NO_RESPONSE


responseTypeDecoder : Decoder ResponseType
responseTypeDecoder =
    decoderFromDict <| Dict.fromList [ ( "SUCCESS", SUCCESS ), ( "FAILURE", FAILURE ), ( "NO_RESPONSE", NO_RESPONSE ) ]



-- org.kie.server.api.model.KieServerInfo


type alias KieServerInfo =
    { id : String
    , version : String
    , name : String
    , location : String
    , capabilities : List String
    , messages : List Message
    }


kieServerInfoDecoder : Decoder KieServerInfo
kieServerInfoDecoder =
    let
        kieServerInfoObjectDecoder =
            Decode.map6 KieServerInfo
                (Decode.field "id" Decode.string)
                (Decode.field "version" Decode.string)
                (Decode.field "name" Decode.string)
                (Decode.field "location" Decode.string)
                (Decode.field "capabilities" (Decode.list Decode.string))
                (Decode.field "messages" (Decode.list messageDecoder))
    in
        Decode.field "kie-server-info" kieServerInfoObjectDecoder



-- org.kie.server.api.model.Message


type Message
    = Message Severity Date (List String)


messageDecoder : Decoder Message
messageDecoder =
    Decode.map3 Message
        (Decode.field "severity" severityDecoder)
        (Decode.field "timestamp" dateDecoder)
        (Decode.field "content" (Decode.list Decode.string))


dateDecoder : Decoder Date
dateDecoder =
    Decode.field "java.util.Date" Decode.float
        |> Decode.map Date.fromTime



-- org.kie.server.api.model.Severity


type Severity
    = INFO
    | WARN
    | ERROR


severityDecoder : Decoder Severity
severityDecoder =
    decoderFromDict <| Dict.fromList [ ( "INFO", INFO ), ( "WARN", WARN ), ( "ERROR", ERROR ) ]



-- org.kie.server.api.model.KieServerConfigItem


type alias KieServerConfigItem =
    { name : String
    , value : String
    , type_ : String
    }


kieServerConfigItemDecoder : Decoder KieServerConfigItem
kieServerConfigItemDecoder =
    Decode.map3 KieServerConfigItem
        (Decode.field "name" Decode.string)
        (Decode.field "value" Decode.string)
        (Decode.field "type" Decode.string)



-- org.kie.server.api.model.KieServerStateInfo


type alias KieServerStateInfo =
    { controller : List String
    , config : KieServerConfig
    , containers : List KieContainerResource
    }


kieServerStateInfoDecoder : Decoder KieServerStateInfo
kieServerStateInfoDecoder =
    Decode.map3 KieServerStateInfo
        (Decode.field "controller" <| Decode.list Decode.string)
        (Decode.field "config" kieServerConfigDecoder)
        (Decode.field "containers" <| Decode.list kieContainerResourceDecoder)



-- org.kie.server.api.model.KieServerConfig


type alias KieServerConfig =
    { configItems : List KieServerConfigItem
    }


kieServerConfigDecoder : Decoder KieServerConfig
kieServerConfigDecoder =
    Decode.map KieServerConfig <| Decode.list kieServerConfigItemDecoder



-- org.kie.server.api.model.KieContainerResource


type alias KieContainerResource =
    { container_id : String
    , release_id : ReleaseId
    , resolved_releaseId : ReleaseId
    , status : KieContainerStatus
    , scanner : KieScannerResource
    , config_items : List KieServerConfigItem
    , messages : List Message
    , container_alias : String
    }


kieContainerResourceDecoder : Decoder KieContainerResource
kieContainerResourceDecoder =
    Debug.crash "implement kieContainerResourceDecoder"



-- org.kie.server.api.mode.ReleaseId


type ReleaseId
    = ReleaseId --TODO



-- org.kie.server.api.model.KieContainerStatus


type KieContainerStatus
    = CREATING
    | CONTAINER_STARTED
    | FAILED
    | DISPOSING
    | CONTAINER_STOPPED


kieContainerStatusDecoder : Decoder KieContainerStatus
kieContainerStatusDecoder =
    decoderFromDict <|
        Dict.fromList
            [ ( "CREATING", CREATING )
            , ( "STARTED", CONTAINER_STARTED )
            , ( "FAILED", FAILED )
            , ( "DISPOSING", DISPOSING )
            , ( "STOPPED", CONTAINER_STOPPED )
            ]



-- org.kie.server.api.model.KieScannerResource


type KieScannerResource
    = KieScannerResource --TODO



-- org.kie.server.api.model.KieScannerStatus


type KieScannerStatus
    = UNKNOWN
    | CREATED
    | SCANNER_STARTED
    | SCANNING
    | SCANNER_STOPPED
    | DISPOSED


kieScannerStatusDecoder : Decoder KieScannerStatus
kieScannerStatusDecoder =
    decoderFromDict <|
        Dict.fromList
            [ ( "UNKNOWN", UNKNOWN )
            , ( "CREATED", CREATED )
            , ( "STARTED", SCANNER_STARTED )
            , ( "SCANNING", SCANNING )
            , ( "STOPPED", SCANNER_STOPPED )
            , ( "DISPOSED", DISPOSED )
            ]



-- PRIVATE HELPERS


decoderFromDict : Dict String a -> Decoder a
decoderFromDict dict =
    Decode.string |> Decode.andThen (makeUnionDecoder dict)


makeUnionDecoder : Dict String a -> String -> Decoder a
makeUnionDecoder strToValDict strToParse =
    Dict.get strToParse strToValDict
        |> \maybeVal ->
            case maybeVal of
                Nothing ->
                    Decode.fail <| "Unexpected response type: '" ++ strToParse ++ "' - expected one of " ++ (toString <| Dict.keys strToValDict)

                Just val ->
                    Decode.succeed val