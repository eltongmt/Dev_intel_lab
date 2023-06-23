%%%
% Author: Elton Martinez
% Last Modified: 6/23/2023
% Takes in a transcription and finds each utterance instance in which the 
% given target_word_pairs are present, returns a csv of all those instances
% 
% 
% Input: (target_word_pairs,inpath,outname)
%       eg: ({{"bug","a"},{"rub","you"}}, "speech_17662.txt","coocurrence")
% Output: A csv file 
%%%
function co_occurrences = query_word_cooccurrence(target_word_pairs,inpath,outname)
    
    % Read in the transcription and turn it into a table
    transT = transcription_to_table(inpath);
    % Container for spliting each transcription line into tockens
    bag_words = cell(height(transT),1);
    % Container for word pair column
    words = cell(0);
    
    % Predeclare a table to add valid values to
    sz = [0 3];
    varTypes = ["double","double","string"];
    varNames = ["onset","offset","utterance"];
    valid = table('Size',sz,'VariableTypes',varTypes,'VariableNames',varNames);
    
    % Check all the utterances
    for i = 1:height(transT)
        % Split each utterance into tockens
        bag_words{i} = split(transT{i,"utterance"}{1});
        % Check if all word pairs are present
        for j = 1:numel(target_word_pairs)
            keyword_1 = target_word_pairs{j}{1};
            keyword_2 = target_word_pairs{j}{2};
    
            % Checking if each keyword is in the utterance
            check_1 = any(strcmp(bag_words{i},keyword_1));
            check_2 = any(strcmp(bag_words{i},keyword_2));
        
            if check_1 & check_2
                % If both are present then its a match, take that row 
                % and merge it with the valid table
                valid = [valid;transT(i,:)];
                % Add the word pair to the words cell array for this
                % instance
                words{end+1} = sprintf("%s/%s",keyword_1,keyword_2);
    
            end   
        end
    end
    
    % Transpose the words array to match the row length and then add to 
    % the valid table
    valid.words = words';
    % Reorganzie the columns move words to the 3 position
    valid = [valid(:,1:2) valid(:,4) valid(:,3)];
    co_occurrences = renamevars(valid,["utterance"],["merged_utterance"]);
    
    % Write the table 
    writetable(co_occurrences,outname)