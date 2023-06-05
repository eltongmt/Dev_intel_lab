
import pandas as pd 
import os 

def prep_data():
    
    gaze_df = pd.read_csv('Trial_level/Raw_data/sel-att-data-185-188-May26-2023.csv')

    gaze_df['subID'] = gaze_df['subID'].astype('string')

    gaze_df['subject'] = gaze_df['subID'].str[-2:]
    gaze_df['subID'] = gaze_df['subID'].astype('string')
    
    gaze_df.sort_values(by=['subject','trial'],inplace=True)
    gaze_df.pop('subject')

    return gaze_df

def get_trial(measures):
    gaze_trial = prep_data()
        
    columns = ['subID','expID','trial','pretrained','learned']
    
    for arg in measures:
        try:
            gaze_trial[arg]
        except:
            print(f'no column named \"{arg}\"')
        else:
            if arg not in columns:
                columns.append(arg)
                
    temp = gaze_trial[columns]
    temp.reset_index(inplace=True,drop=True)
    
    return temp[columns]


def main():
    print()
    raw_measures = input('Enter target measures separted by comma(,): ')
    print()
    measures = raw_measures.strip().split(',')


    data = get_trial(measures)
    path = os.getcwd() + '/Trial_level/out'
    
    i = 0 
    while os.path.exists(f'{path}{i}.csv'):
        i += 1 

    data.to_csv(path_or_buf=(f'{path}{i}.csv'))

main()
    


