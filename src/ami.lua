return {
    title = "Airwire Masternode",
    commands = {
        info = {
            description = "ami 'info' sub command",
            summary = "Prints runtime info and status of the app",
            action = {
                type = "code",
                code = function(_options, command, args, cli)
                    if _options.help then
                        show_cli_help(cli)
                        return
                    end
                    local _ok, _infoLua = pcall(loadfile, "__wire/info.lua")
                    if not _ok then
                        ami_error(_ok, "Failed to get info of WIRE NODE - " .. _infoLua, EXIT_APP_INFO_ERROR)
                    end
                    local _ok, _error = pcall(_infoLua, OUTPUT_FORMAT == 'json')
                    ami_assert(_ok, "Failed to get info of WIRE NODE - " .. (_error or ""), EXIT_APP_INFO_ERROR)
                end
            }
        },
        setup = {
            options = {
                configure = {
                    description = "Configures application, renders templates and installs services"
                }
            },
            action = {
                type = "code",
                code = function(options, command, args, cli)
                    if options.help then
                        show_cli_help(cli)
                        return
                    end
                    local _noOptions = #eliUtil.keys(options) == 0
                    if _noOptions or options.app then 
                        prepare_app(APP)
                        local _ok, _error = pcall(dofile, "__btc/download-binaries.lua")
                        ami_assert(_ok, "Failed to download wire binaries - " .. (_error or ""), EXIT_SETUP_ERROR)
                    end
                    if _noOptions or options.configure then 
                        render_templates(APP)
                        local _ok, _error = pcall(dofile, "__btc/configure.lua")
                        ami_assert(_ok, "Failed to configure services - " .. (_error or ""), EXIT_SETUP_ERROR)
                    end
                end
            }
        },
        start = {
            description = "ami 'start' sub command",
            summary = "Starts the WIRE node",
            action = {
                type = "code",
                code = function(options, command, args, cli)
                    if options.help then
                        show_cli_help(cli)
                        return
                    end
                    local _ok, _error = pcall(dofile, "__btc/start.lua")
                    ami_assert(_ok, "Failed to start WIRE NODE - " .. (_error or ""), EXIT_APP_START_ERROR)
                end
            }
        },
        stop = {
            description = "ami 'stop' sub command",
            summary = "Stops the WIRE node",
            action = {
                type = "code",
                code = function(options, command, args, cli)
                    if options.help then
                        show_cli_help(cli)
                        return
                    end
                    local _ok, _error = pcall(dofile, "__btc/stop.lua")
                    ami_assert(_ok, "Failed to stop WIRE NODE - " .. (_error or ""), EXIT_APP_START_ERROR)
                end
            }
        },
        validate = {
            description = "ami 'validate' sub command",
            summary = "Validates app configuration and platform support",
            action = {
                type = "code",
                code = function(_options, command, args, cli)
                    if _options.help then
                        show_cli_help(cli)
                        return
                    end
                    ami_assert(eliProc.EPROC, "wire node AMI requires extra api - eli.proc.extra", EXIT_MISSING_API)
                    ami_assert(eliFs.EFS, "wire node AMI requires extra api - eli.fs.extra", EXIT_MISSING_API)
                    
                    ami_assert(type(APP.id) == 'string', "id not specified!" , EXIT_INVALID_CONFIGURATION)
                    ami_assert(type(APP.configuration) == 'table', "configuration not found in app.h/json!" , EXIT_INVALID_CONFIGURATION)
                    ami_assert(type(APP.configuration.USER) == 'string', "USER not specified!" , EXIT_INVALID_CONFIGURATION)
                    ami_assert(type(APP.configuration.NODE_TYPE) == 'string', "NODE_TYPE not specified!" , EXIT_INVALID_CONFIGURATION)
                    ami_assert(type(APP.type) == 'table' or type(APP.type) == 'string', "Invalid app type!" , EXIT_INVALID_CONFIGURATION)
                    log_success("Airwire masternode configuration validated.")
                end
            }
        },
        about = {
            description = "ami 'about' sub command",
            summary = "Prints information about application",
            action = {
                type = "code",
                code = function(_options, command, args, cli)
                    if _options.help then
                        show_cli_help(cli)
                        return
                    end

                    local _ok, _aboutFile = eliFs.safe_read_file("__wire/about.hjson")
                    ami_assert(_ok, "Failed to read about file!", EXIT_APP_ABOUT_ERROR)
                    local _hjson = require"hjson" 
                    local _ok, _about = pcall(_hjson.parse, _aboutFile)
                    _about["App Type"] = type(APP.type) == 'table' and APP.type.id or APP.type
                    ami_assert(_ok, "Failed to parse about file!", EXIT_APP_ABOUT_ERROR)
                    if OUTPUT_FORMAT == 'json' then 
                        print(_hjson.stringify_to_json(_about, {indent = false, skipkeys = true}))
                    else 
                        print(_hjson.stringify(_about))
                    end
                end
            }
        },
        removedb = {
            index = 6,
            description = "wired 'removedb' command",
            summary = "Removes wired database",
            options = {
                help = HELP_OPTION
            },
            action = {
                type = "code",
                code = function(_options, command, args, cli)
                    if _options.help then
                        show_cli_help(cli)
                        return
                    end
                    local _ok, _error = pcall(dofile, "__btc/removedb.lua")
                    ami_assert(_ok, "Failed to removedb - " .. (_error or ""), EXIT_APP_INTERNAL_ERROR)
                    log_success("Succesfully removed wired database.")
                end
            }
        },
        remove = {
            index = 7,
            action = {
                type = "code",
                code = function(_options, command, args, cli)
                    if _options.help then
                        show_cli_help(cli)
                        return
                    end

                    if _options.all then 
                        local _ok, _error = pcall(dofile, "__btc/remove-all.lua")
                        ami_assert(_ok, "Failed to remove the app - " .. (_error or ""), EXIT_APP_INTERNAL_ERROR)
                        remove_app()
                        log_success("Application removed.")
                    else 
                        remove_app_data()
                        log_success("Application data removed.")
                    end
                    return
                end
            }
        }
    }
}
