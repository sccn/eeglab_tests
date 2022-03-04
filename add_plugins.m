function add_plugins
% ADD_PLUGINS adds the necessary plugins (if not yet installed) for running
% all tests

% run EEGLAB to get access to already installed plugins
eeglab nogui

try
    PLUGINLIST = evalin('base', 'PLUGINLIST');
    installedPlugins = convertCharsToStrings({PLUGINLIST.plugin});
catch
    installedPlugins = "";
end

pluginsToInstall = [
    "neuroscanio"
    "bva-io"
    "Biosig"
    "Fileio"
    "erpssimport"
    "Fieldtrip-lite"
    "corrmap"
    "BDFimport"
    "PICARD"
    "bids-matlab-tools"
    "LIMO"
    "erpssimport"
    ];

% install each plugins with the install subfunction
arrayfun(@install, pluginsToInstall);

    function install(plugin)
        force = true;

        % Only install if it is not yet installed
        if all(installedPlugins ~= plugin)

            try
                plugin_askinstall(plugin, [], force)
            catch exc
                disp(exc)
            end

        end
    end

end