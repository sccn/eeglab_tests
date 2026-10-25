classdef EeglabTestProgressPlugin < matlab.unittest.plugins.TestRunnerPlugin
    % Preserve completed results and identify a stalled test before completion.
    properties (Access = private)
        OutputDirectory
        Count = 0
    end
    methods
        function plugin = EeglabTestProgressPlugin(folder)
            plugin.OutputDirectory = folder;
            mkdir(fullfile(folder, 'individual'));
        end
    end
    methods (Access = protected)
        function runTest(plugin, data)
            file = fullfile(plugin.OutputDirectory, 'current.txt');
            handle = fopen(file, 'w');
            assert(handle ~= -1, 'Cannot write test progress to %s.', file);
            cleanup = onCleanup(@() fclose(handle));
            fprintf(handle, '%s\n%s\n', char(data.Name), char(datetime('now')));
            clear cleanup
            runTest@matlab.unittest.plugins.TestRunnerPlugin(plugin, data);
        end
        function reportFinalizedResult(plugin, data)
            result = data.TestResult;
            plugin.Count = plugin.Count + 1;
            save(fullfile(plugin.OutputDirectory, 'individual', ...
                sprintf('%04d.mat', plugin.Count)), 'result');
            reportFinalizedResult@matlab.unittest.plugins.TestRunnerPlugin(plugin, data);
        end
    end
end
