module KieServer.Urls exposing (base, serverState)


base : String
base =
    "/kie-server/services/rest/server"


serverState : String
serverState =
    base ++ "/state"
