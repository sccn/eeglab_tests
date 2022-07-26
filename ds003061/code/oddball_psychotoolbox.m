% ?? is the sound playing in stereo?
% simple Oddball script
% Arnaud Delorme - March 2008
clear
disp('Trigger 2  (bit 2) is standard');
disp('Trigger 4  (bit 3) is oddball');
disp('Trigger 8  (bit 4) is noise');
disp(' ' );
s = input('DID YOU START RECORDING YET (enter=yes)?');
if ~isempty(s), return; end;

file_standard = '500Hz_50_76dbSPL_minus8db.wav';
%file_standard = 'test_claire.wav';
file_oddball  = '1000Hz_50_76dbSPL_minus20db.wav';
file_noise    = 'WN_-5dB_76dbSPL_minus23db.wav';

ISI     = 1; % Inter-Stimulus Interval in seconds
ISIvar  = 0; % Variation in ISI in seconds (i.e., 0.2 means + or - 200 ms)
SEQlen  = 750;

disp('List of wav files in folder:');
disp('----------------------------');
a = dir('*.wav');
wavfilelist = { a.name };
for i=1:length(wavfilelist)
    disp([ int2str(i) ':' wavfilelist{i} ]);    
end;
disp(' ');

% generate sound series
% ---------------------
%  sndrate  = 44800; % sound output frequency
% ' standardsnd = makesound(500 , 0.06, sndrate)'; % standard stimuli 500 Hz, 100 ms
% ' oddballsnd  = makesound(1000, 0.06, sndrate)'; % oddball stimuli 1000 Hz, 100 ms
% ' noisesnd    = makesound(NaN , 0.06, sndrate)'; % random noize, 100 ms

[standardsnd standardrate]  = wavread(file_standard);
[oddballsnd  oddballrate]   = wavread(file_oddball);
[noisesnd    noiserate]     = wavread(file_noise);

if size(standardsnd,2) == 1, standardsnd    = [ standardsnd; zeros(100,1) ];
else                         standardsnd    = [ standardsnd; zeros(100,2) ];
end; 
if size(oddballsnd,2) == 1, oddballsnd    = [ oddballsnd; zeros(100,1) ];
else                        oddballsnd    = [ oddballsnd; zeros(100,2) ];
end;
if size(noisesnd,2) == 1, noisesnd    = [ noisesnd; zeros(100,1) ];
else                      noisesnd    = [ noisesnd; zeros(100,2) ];
end;

%ListenChar(2);

% Initialize rand to a different state each time: 
rand('state', sum(100*clock))
s1=GetSecs;
s2=GetSecs;
KbCheck;
previous = 0;

count = 0;

% generate sequence of 1=standard, 2=oddball, 3=distractor, 4=name    
% ----------------------------------------------------------------
seq = [ ones(1,round(SEQlen*0.7)) ];
for stim = [2:3]
    addoddball  = round(SEQlen*0.15);
    while addoddball > 0
        pos = ceil(rand(1)*(length(seq)));
        if seq(pos) == 1
            if pos<length(seq)
                if seq(pos+1) == 1
                    seq = [ seq(1:pos) stim seq(pos+1:end) ];
                    addoddball = addoddball-1;
                end;
            end;
        end;
    end;   
end;

% count each sound in the sequence
for i = 1:3
    fprintf('Type %d:%d occurences\n', i, length(find(seq == i)));
end;    
seq = [1 1 1 1 1 1 1 1 seq];

parport = digitalio('parallel','LPT1');
addline(parport, 0:7, 'out');
putvalue(parport.Line(1:8), 0);

while 1
    % wait until one second
    % ---------------------
    realISI = ISI-ISIvar/2+rand*ISIvar;
    while s2-s1 < realISI
        s2 = GetSecs;
    end;
    s1 = s2;
    
    % test keyboard
    % -------------
    [keyIsDown, secs, keyCode] = KbCheck;
    cc=KbName(keyCode);  %translate code into letter (string)
    if any(strcmpi(cc,'escape')) || any(strcmpi(cc,'esc'))
        disp('');
        disp('User abord');
        break;   %break out of trials loop, but perform all the cleanup things
                  %and give back results collected so far
    end;

    % present stimulus
    % ----------------
    count = count+1;
    Snd('Open');
    try
        if seq(count) == 3      Snd('Play', noisesnd'   , noiserate);
        elseif seq(count) == 2, Snd('Play', oddballsnd' , oddballrate);
        else                    Snd('Play', standardsnd', standardrate);
        end;
        putvalue(parport.Line(seq(count)+1), 1);
        putvalue(parport.Line(seq(count)+1), 0);
        Snd('Wait');
    catch, disp('Problem presenting sounds'); end;
    Snd('Close');

    % Print status
    % ------------
    if seq(count) == 5      fprintf( '%d/%d sounds -> Unknown name, trigger bit 6.\n', count, SEQlen);
    elseif seq(count) == 4  fprintf( '%d/%d sounds -> Own name, trigger bit 5.\n', count, SEQlen);
    elseif seq(count) == 3  fprintf( '%d/%d sounds -> Noise, trigger bit 4.\n', count, SEQlen);
    elseif seq(count) == 2, fprintf( '%d/%d sounds -> Oddball, trigger bit 3.\n', count, SEQlen);
    else                    fprintf( '%d/%d sounds -> Standard, trigger bit 2.\n', count, SEQlen);
    end;
    
    if count == SEQlen, break; end; 
end;
disp('Done');
delete(parport);
