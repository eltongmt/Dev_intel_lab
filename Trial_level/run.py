
import pandas as pd 
import numpy as np
import os 


def prep_data():
    
    gaze_df = pd.read_csv('Raw_data/sel-att-data-185-188-May26-2023.csv')
    
    trial_group = ['subID','expID','trial']
    dict = {5:0,6:3,7:6,8:9}
    
    # Group by subID, expID, and trial then average all the columns
    gaze_df_T = gaze_df.groupby(by=trial_group).mean()
    # Group by subID, expID, and trial then get the sum of all the values
    # This is for the standard info columns
    group = gaze_df.groupby(by=trial_group).sum()
    # Group by subID and expID this is to get the total words learned per subject
    learned = gaze_df.groupby(by=['subID','expID']).sum()
    
    # total words learned per subject
    total_learned = learned['learned'].to_list()
    # total word learned per trial per subject
    learned_per_trial = group['learned'].to_list()
    # Map the last number of each experiment to the corresponding number of 
    # pretrained words 
    pretrained_per_trial = group.reset_index()['expID'].apply(
                               lambda x: dict[x%10] ).to_list()
    
    # Make a new column to help group by labeling instances
    lb  = np.array(['1','2','3','4'])
    lb = np.resize(lb,(26244,1))
    gaze_df['labeling_window'] = lb

    # Broadcast total learned across all 6561 rows
    n_learned = [0 for i in range(6561)]
    count = 0

    for i in range(len(n_learned)):

        if i % 27 == 0 and count+1 != 243:
            count +=1

        n_learned[i] = total_learned[count]
        
    # insert columns to the grouped average datafram in the correct order
    gaze_group = gaze_df_T.reset_index()
    gaze_group.pop('pretrained')
    gaze_group.insert(1,'total_learned',n_learned)
    gaze_group.insert(4,'pretrained',pretrained_per_trial)
    gaze_group.insert(5,'trial_learned',learned_per_trial)

    return gaze_group, gaze_df, group.columns.to_list()


def get_trial(measures):
    
    info = ['subID','total_learned','expID','trial','pretrained','trial_learned']
    gaze_group = prep_data()[0]
    gaze_df = prep_data()[1]
    
    # Pivot the original dataframe by trials(eg 4 columns)
    pivot = gaze_df.pivot(index=['subID','trial'],columns='labeling_window',values=measures)
    # Flatten the multiindex columns
    pivot.columns = pivot.columns.map('_'.join).str.strip('_')
    a = pivot.reset_index()
    # Merge the averaged dataframe with the pivot data frame to get the 4 raw measures
    # along with the average
    trial_data = pd.merge(gaze_group[info + measures], a.iloc[:,2:], left_index=True, right_index=True)
 
    trial_data.index = np.arange(1, len(trial_data) + 1)
   
    return trial_data


def get_input():
    valid_measures = prep_data()[2]
    
    while True:
        raw_measures = input('Enter target measures separted by comma(,) or stop: ')
        measures = raw_measures.split(',')
        measures = [m.strip() for m in measures]
        
        if len(measures) == 1 and measures[0] == 'stop':
            return False
        
        inval = []
        
        for measure in measures:
            if measure not in valid_measures:
                print(f'no measure named {measure}')
                inval.append(measure)
                
        if len(inval) == 0:
            return measures  
    
    
def save_output(data, path):
    
    if not os.path.exists(f'{path}.csv'):
        
         data.to_csv(path_or_buf=(f'{path}.csv'))
         print_name = (f'{path}.csv')
            
    else:
     
        i = 0 
        while os.path.exists(f'{path}{i}.csv'):
            i += 1 
        data.to_csv(path_or_buf=(f'{path}{i}.csv'))
        print_name = (f'{path}{i}.csv')
        
    print(f'Data under {print_name}')
    

def main():
    measures = get_input()
    
    if measures == False:
        return 

    data = get_trial(measures)
    name = '_'.join(measures)
    
    if not os.path.exists('./output'):
        os.makedirs('./output')
    
    
    path = (f'./output/{name}')
    save_output(data, path)
      
main()