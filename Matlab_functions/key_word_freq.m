%%%
% Author: Elton Martinez
% Last Modifier: 6/14/2023
% This function returns a table containing the word count for each target 
% objID for all the subjects in the given experiment. The table can be
% returned as a variable or a csv(if an output path is provided)
% 
% Input: (expID, [objIDs], output_path)  
% Output: A table of subjects by objID alliases containing the frequency
% count of each objID alliases for each expID 
%%%

function dic_table = key_word_freq(expID,objIDs,outpath)
 
    filePath = sprintf('M:\\experiment_%d\\exp_%d_dictionary',expID,expID);
    % Try to read the dictionary as a table for expID, if no dictionary
    % is found no value is returned 
    try
        data = readtable(filePath);
    catch
        fprintf('No dictionary for experiment %d\n',expID)
        return 
    end
    
    % Subset dictionary table to only include the target objIDs
    target_data = data(ismember(data.ID_,objIDs),:);
    if isempty(target_data)
        fprintf('ID %d not found\n',objIDs)
        return
    end

    % Make a dummy row to help with creating the column names
    target_data.SID = arrayfun(@num2str,target_data.ID_);
    
    % Colunns is where the actual formated column names will be stored
    % will target will store the different aliases of each target objIDs
    columns = {'subID'};
    target_names = {};
    
    % Iterate through all of the target IDs
    for i = 1:height(target_data)
        % Split the library string into different aliases cells
        names = strsplit(target_data{i,'Library'}{1},',');
        
        % Iterate through the different aliases of the ith object
        for j = 1:numel(names)
            name = strip(names{j});
            target_names{end+1} = name;
            % Combine the objID, GazetagNaming, and alias into one string
            columns{end+1} = strcat( ...
                target_data{i,'SID'},'-', ...
                target_data{i,'GazetagNaming'}{1},'-', ...
                name);
        end
    end
    
    % Get all the subjects in expID
    subject_IDs = cIDs(expID);

    % Define the dimmensions of the table subjects v target words
    sz = [numel(subject_IDs) numel(columns)];
    % Preallocate an array to store the variable types(to create table)
    var_type = string(zeros(1,numel(columns)));
    % Define a var type for each column
    for i = 1:numel(columns)
        var_type(i) = 'single';
    end
    
    t_table = table('Size',sz,'VariableTypes',var_type,'VariableNames',columns);
    
    % For each subject try to read a word count matrix if they do not have
    % one the subjects are excluded from the result
    for i = 1:numel(subject_IDs)
        subject = subject_IDs(i);
        try
            % Read the table and set the index to be the words
            [~, ~, word_matrix] = get_word_count_matrix(subject,'');
            word_matrix.Properties.RowNames = word_matrix.word;
            word_matrix.(2) = arrayfun(@str2num,word_matrix.(2));
            word_matrix.word = [];
        catch
            continue
        end
        
        % Preallocate the row array for the ith subject 
        counts = cell(1,numel(columns));
        counts{1} = subject;
    
        % Iterate through all the target names
        for j = 2:(numel(target_names)+1)
            % index starts at 2 to not change the subjectID
            target = target_names{j-1};
            % try to query the j-1th target word in the word matrix of the
            % ith subject, if found add to the row array
            try
                x = word_matrix{target,1};
                counts{j} = x;
            catch
                counts{j} = 0;
            end
        end
        % Add the row array to the ith row
        t_table(i,:) = counts;
    end
    
    % filter out subjects who did not have a transcription file 
    t_table = t_table(t_table.subID > 0,:);
  
    % Only save to csv if a path is provided 
    if ~strcmp(outpath,'')

        outpath = string(outpath);
        columns{1} = int2str(expID);
        csv_name = strjoin(columns,'_');
        
        outpath = outpath + "\" + csv_name + ".csv";

        writetable(t_table,outpath);
        disp("Saved under " + outpath)
    else
        dic_table = t_table;
    end

end