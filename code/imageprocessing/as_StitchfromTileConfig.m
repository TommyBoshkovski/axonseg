function Panorama = as_StitchfromTileConfig
% Panorama = as_StitchfromTileConfig
% reads TileConfiguration.registered.txt, generated by FIJI Grid stitch,
% and stitch images to create matrix Panorama
%
% display Panorama using:
% AS_DISPLAY_LARGEIMAGE(Panorama);


[fname,ColPos,RowPos] = ImportTileConfiguration('TileConfiguration.registered.txt');

Msize = size(imread(fname{1}));
RowPos = round(RowPos-min(RowPos));
ColPos = round(ColPos-min(ColPos));

Panorama = zeros(round(max(RowPos)+Msize(1)+1),round(max(ColPos)+Msize(2)+1),'uint8');
for ff = 1:length(fname)
    tmp = imread(fname{ff}); if size(tmp,3)==3, tmp = rgb2gray(tmp); end
    Panorama((RowPos(ff)+1):(RowPos(ff)+Msize(1)),(ColPos(ff)+1):(ColPos(ff)+Msize(2)))=im2uint8(tmp);
end

as_display_LargeImage(Panorama);

function [fname,ColPos,RowPos] = ImportTileConfiguration(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as column vectors.
%   [FNAME,VARNAME2,COLPOS,ROWPOS] = IMPORTFILE(FILENAME) Reads data from
%   text file FILENAME for the default selection.
%
%   [FNAME,VARNAME2,COLPOS,ROWPOS] = IMPORTFILE(FILENAME, STARTROW, ENDROW)
%   Reads data from rows STARTROW through ENDROW of text file FILENAME.
%
% Example:
%   [fname,VarName2,ColPos,RowPos] =
%   importfile('TileConfiguration.registered.txt',4, 157);
%
%    See also TEXTSCAN.

% Auto-generated by MATLAB on 2017/01/13 14:41:51

%% Initialize variables.
delimiter = {',',';'};
if nargin<=2
    startRow = 4;
    endRow = inf;
end

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow(1)-1, 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    textscan(fileID, '%[^\n\r]', startRow(block)-1, 'ReturnOnError', false);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[3,4]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(thousandsRegExp, ',', 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [3,4]);
rawCellColumns = raw(:, [1,2]);


%% Allocate imported array to column variable names
fname = rawCellColumns(:, 1);
VarName2 = rawCellColumns(:, 2);
ColPos = cell2mat(rawNumericColumns(:, 1));
RowPos = cell2mat(rawNumericColumns(:, 2));


