%%%
% Author: Elton Martinez
% Last Modified: 6/23/2023
% Tries to read in a transcription file, turns this file into an easier to 
% work with datatype a table 
% 
% Input: (path)  
% Output: transcription as a table datatype 
%%%

function table = transcription_to_table(path)
    % Try to read in the file, if the path cant be found throw an error and
    % return nothing
    try
        file = importdata(path);
    catch
        fprintf('Transcription not found')
        return
    end
    
    % Split each line of the input file so from an array of size i becomes
    % one of shape(i,3)
    file_split = cellfun(@(x)strsplit(x,'\t'),file,'UniformOutput',false);
    % Since the return is a cell of length i with a 1x3 cell in each cell 
    % use vertcat to merge the cells into a ix3 cell 
    file_split = vertcat(file_split{:});
    
    % Use the extracted cell to make a table(easier to understand which
    % variables are being manupulated
    t = cell2table(file_split,"VariableNames",["onset","offset","utterance"]);

    % Convert both onset and offset from strings into numeric values
    for i = 1:height(t)
            t{i,"offset"}{1} = str2num(t{i,"offset"}{1});
            t{i,"onset"}{1} = str2num(t{i,"onset"}{1});
    end