function count = filewrite(filename, A, mode, varargin)
%FILEWRITE Write contents of variable to file.
%   COUNT = FILEWRITE(FILENAME, A) writes contents of variable A to file
%   specified by FILENAME.
%
%   COUNT = FILEWRITE(FILENAME, A, MODE) MODE can be 't' or 'b' (default).
%           MODE 't' will write in text mode
%           MODE 'b' will write in binary mode
%           If MODE is not given, binary mode is used.
%
%   COUNT = FILEWRITE(..., ARGS) Additional arguments can be given that
%           will be passed to FOPEN, e.g. machinefmt or encodingIn.
%
%   See also FWRITE, FILEREAD, FREAD, TEXTSCAN, LOAD, READTABLE, UIIMPORT,
%   IMPORTDATA, FOPEN

% Copyright 2019 VersionBay v.o.f.

narginchk(2, inf);

% R2017b onwards
if ~verLessThan('matlab', '9.3')
    filename = convertStringsToChars(filename);
end

if ~ischar(filename)
    error('Filename must be a string scalar or character vector.'); 
end

if isempty(filename)
    error('Filename must not be empty.'); 
end

if nargin < 3 || strcmp(mode, 'b') || isempty(mode)
    mode = '';
elseif ~strcmp(mode, 't')
    error('Invalid mode: %s. Mode should be ''b'' or ''t''.', mode);
end

permission = ['w' mode];

[fid, msg] = fopen(filename, permission, varargin{:});
if fid == -1
    error('Could not open file %s. %s.', filename, msg);
end

try
    count = fwrite(fid, A);
catch exception
    fclose(fid);
    throw(exception);
end

fclose(fid);
