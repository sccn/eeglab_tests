function clean_rawdata_finalrej_test

readcontsamplefile;
EEG1 = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion','off','WindowCriterion',0.25,'BurstRejection','off','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] ,'channels',[]);
EEG2 = pop_clean_rawdata(EEG, 'FlatlineCriterion','off','ChannelCriterion','off','LineNoiseCriterion','off','Highpass','off','BurstCriterion','off','WindowCriterion',0.25,'BurstRejection','off','Distance','Euclidian','WindowCriterionTolerances',[-Inf 7] ,'channels',[]);

if ~isequal(EEG1, EEG2)
    error('Clean_rawdata continuous data rejection is not equal')
end
