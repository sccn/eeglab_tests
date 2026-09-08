function eeglab_test_workspace(commands)
% Execute legacy menu commands in the base workspace and restore test state.
variables = evalin('base', 'whos');
values = cell(size(variables));
for index = 1:numel(variables)
    values{index} = evalin('base', variables(index).name);
end
oldFolder = pwd;
oldRandom = rng;
oldFigures = findall(groot, 'Type', 'figure');
oldVisibility = get(groot, 'DefaultFigureVisible');
oldPath = path;
oldWarnings = warning;
eeglabFigures = findall(groot, 'Type', 'figure', 'Tag', 'EEGLAB');
folder = tempname;
mkdir(folder);
state = struct('variables', variables, 'values', {values}, 'folder', oldFolder, ...
    'random', oldRandom, 'figures', oldFigures, 'visibility', oldVisibility, 'temporary', folder, ...
    'path', oldPath, 'warnings', oldWarnings, 'eeglabFigures', eeglabFigures);
cleanup = onCleanup(@() restoreWorkspace(state)); %#ok<NASGU>
% eeglab closes existing windows with this tag. Protect the caller's window.
set(eeglabFigures, 'Tag', 'EEGLAB_test_saved');
cd(folder);
set(groot, 'DefaultFigureVisible', 'off');
evalin('base', commands);
end

function restoreWorkspace(state)
cd(state.folder);
current = evalin('base', 'who');
% Clear bindings first, so formerly local variables do not stay global.
for k = 1:numel(current)
    evalin('base', ['clear ' current{k}]);
end
for k = 1:numel(state.variables)
    if state.variables(k).global
        evalin('base', ['global ' state.variables(k).name]);
    end
    assignin('base', state.variables(k).name, state.values{k});
end
delete(setdiff(findall(groot, 'Type', 'figure'), state.figures));
set(state.eeglabFigures(isgraphics(state.eeglabFigures)), 'Tag', 'EEGLAB');
set(groot, 'DefaultFigureVisible', state.visibility);
rng(state.random);
warning(state.warnings);
path(state.path);
rmdir(state.temporary, 's');
end
