if type(APP.model) ~= "table" then
    APP.model = {}
end

if type(APP.configuration) ~= 'table' then
    ami_error("Configuration not found...", EXIT_INVALID_CONFIGURATION) 
end

local _charsetTable = {}
_charset="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
_charset:gsub(".",function(c) table.insert(_charsetTable,c) end)
local _rpcPass = eliUtil.random_string(20, _charsetTable)

APP.model = eliUtil.merge_tables(
    APP.model,
    {
        RPC_USER = APP.configuration.USER,
        RPC_PASS = APP.configuration.RPC_PASS or _rpcPass,
        RPC_PORT = APP.configuration.RPC_PORT or 5520,
        IS_SERVER = type(APP.configuration.NODE_PRIVKEY) == 'string' or APP.configuration.SERVER,
        DAEMON_NAME = "wired",
        CLI_NAME = "wire-cli",
        CONF_NAME = "wire.conf",
        CONF_SOURCE = "__btc/assets/daemon.conf",
        SERVICE_NAME = "wired",
        DATA_DIR = "data",
        ADD_NODES= {
            "108.61.89.77",
            "207.246.120.32",
            "72.74.34.120",
            "173.199.70.251",
            "45.33.69.198",
            "176.58.109.69",
            "5.79.88.130",
            "139.162.73.67"
        }
    },true
)