% Testcases for EEGLab
% Copyright (C) 2006 Andreas Romeyke & Ronny Lindner
% Max-Planck-Institute for Human Cognitive and Brain Sciences Leipzig, Germany
% romeyke@cbs.mpg.de, art1@it-netservice.de
%
% based on EEGLab-toolbox
% http://www.sccn.ucsd.edu/eeglab/
% Copyright (C) 1996 Scott Makeig et al, SCCN/INC/UCSD, scott@sccn.ucsd.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function passed = pass_allevents()

        EEG = tc_emptyset;
        EEG.nbchan = 2; % channels
        EEG.pnts = 20;   % data
        EEG.trials = 1; % epochs
        EEG.srate = 1;
        EEG.xmin = 0;
        EEG.xmax = 2;

        %              <------------------------ data --------------------------->
        %              <-2-------> <-6------->       <12------->       <18------->
        %                       <-5-------> <-9------->
        EEG.data = [ [  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 ]; ... % <--
                     [ 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 ] ];   % <-- channels
        % events:        2        5  6        9 10    12             17 18
        events = [ 2 5 6 9 12 18 ];
        allevents = [ 2 5 6 9 10 12 17 18 ];
        timelim = [-1 3];

        %                    channels, data, epochs
        cepocheddata = zeros(    2,      4,    6);

        % channel 1             <--   epochs   -->
        cepocheddata(1,:,:) = [ [  1  4  5  8 11 17 ]; ... % <--
                                [  2  5  6  9 12 18 ]; ... % <-- data
                                [  3  6  7 10 13 19 ]; ... % <--
                                [  4  7  8 11 14 20 ] ];   % <--
        % channel 2             <--   epochs   -->
        cepocheddata(2,:,:) = [ [ 21 24 25 28 31 37 ]; ... % <--
                                [ 22 25 26 29 32 38 ]; ... % <-- data
                                [ 23 26 27 30 33 39 ]; ... % <--
                                [ 24 27 28 31 34 40 ] ];   % <--

        cnewtime = [-1 2];
        cindices = [ [ 1 ]; ...
                     [ 2 ]; ...
                     [ 3 ]; ...
                     [ 4 ]; ...
                     [ 5 ]; ...
                     [ 6 ] ];

        crerefevent =     { [1], [2 3], [ 2 3], [4 5], [6], [ 7 8] };
        crereflatencies = { [0], [0 1], [-1 0], [0 1], [0], [-1 0] };

        [repocheddata, rnewtime, rindices, rrerefevent, rrereflatencies ] = ...
                       epoch( EEG.data, events, timelim, 'srate', EEG.srate, 'allevents', allevents );

        if ~near(cepocheddata, repocheddata) ...
        || ~near(cnewtime, rnewtime) ...
        || ~near(cindices, rindices) ...
        || ~near(crerefevent, rrerefevent) ...
        || ~near(crereflatencies, rrereflatencies)
            error('EEGLAB:unittesting', 'Error in epoch()');
        end;

