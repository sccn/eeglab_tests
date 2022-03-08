function clean_rawdata_filtering_test

readcontsamplefile;
EEG1 = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass',[0.25 0.75] ,'BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');
EEG2 = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass',[0.25 0.75] ,'BurstCriterion','off','WindowCriterion','off','BurstRejection','off','Distance','Euclidian');

if ~isequal(EEG1, EEG2)
    error('Clean_rawdata asr cleaning is not equal')
end
