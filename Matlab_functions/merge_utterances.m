%%%
% Author: Elton Martinez
% Last Modifier: 6/22/2023
% This function checks the difference between the offset of the current 
% utterance and the onset of the next utterance, for all pairs in the
% transcription file. If this difference is less than the given gap value
% the utterances are merged
%
% Input: (path, gap_between_utterance,outpath)  
% Output: A txt file containing the merged utterances based on the
% gap_between_utterance value, if the write input is 1 is then it will
% be saved as a txt file otherwise one can save it as a variable(cell)
%%%



function transcription = merge_utterances(path, gap_between_utterance,write)

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
    table = cell2table(file_split,"VariableNames",["onset","offset","utterance"]);

    % Convert both onset and offset from strings into numeric values
    for i = 1:height(table)
            table{i,"offset"}{1} = str2num(table{i,"offset"}{1});
            table{i,"onset"}{1} = str2num(table{i,"onset"}{1});
    end
    
    merged = cell(0,3);
    
    for i = 1:height(table)
        % There will never be a height+1 pair, would throw an error
        if i ~= height(table)
            % get the difference between the onset of the next(i+1) utterance
            % and the offset set of the current(i) utterance
            diff = table{i+1,"onset"}{1} - table{i,"offset"}{1};
            % Check if the differece is less than the given gap value
            % if so then merge the two
            if diff < gap_between_utterance
                % Set the onset of this new utterance to the onset of the 
                % ith utterance and the offset to the offset of the i+1th
                % utterance
                merged{end+1,1} = table{i,"onset"}{1};
                merged{end,2} = table{i+1,"offset"}{1};
                
                % Combine the two utterance strings
                str1 = table{i,"utterance"}{1};
                str2 = table{i+1,"utterance"}{1};
                merged{end,3} = append(str1," ",str2);
            end
        end
    end

     if write ~= 1
         transcription = merged;
     else
         writecell(merged,"merged_transcription.txt","Delimiter"," ", ...
                                            "QuoteStrings","none")
     end