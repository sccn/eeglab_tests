function test_pop_delset

readcontsamplefile;
[ALLEEG EEG CURRENTSET] = eeg_store([], EEG);
[ALLEEG EEG CURRENTSET] = eeg_store(ALLEEG, EEG);

ALLEEG = pop_delset( ALLEEG, [1] );
