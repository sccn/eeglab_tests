function cleanup = eeglab_test_preferences
% Restore the user's EEGLAB option file after tests that call pop_editoptions.
eeglab_options;
file = fullfile(homefolder, 'eeg_options.m');
existed = isfile(file);
backup = tempname;
if existed
    copyfile(file, backup);
end
cleanup = onCleanup(@() restorePreferences(file, backup, existed));
end

function restorePreferences(file, backup, existed)
if existed
    copyfile(backup, file);
    delete(backup);
elseif isfile(file)
    delete(file);
end
clear eeg_options
end
