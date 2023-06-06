
import pandas as pd 
import os 

def prep_data():
    
    gaze_df = pd.read_csv('Raw_data/sel-att-data-185-188-May26-2023.csv')
    group =  gaze_df.groupby(by=['subID','expID','trial']).mean()
    
    return group, group.columns.to_list()

def get_trial(measures):
    
    gaze_trial = prep_data()[0]
    
    return gaze_trial[measures]

def get_input():
    valid_measures = prep_data()[1]
    
    while True:
        raw_measures = input('Enter target measures separted by comma(,) or stop: ')
        measures = raw_measures.strip().split(',')
        
        if len(measures) == 1 and measures[0] == 'stop':
            return False
        
        inval = []
        
        for measure in measures:
            if measure not in valid_measures:
                print(f'no measure named {measure}')
                inval.append(measure)
                
        if len(inval) == 0:
            return measures  

def main():
    measures = get_input()
    
    if measures == False:
        return 

    data = get_trial(measures)
    name = '_'.join(measures)
    
    if not os.path.exists('./output'):
        os.makedirs('./output')
    
    
    path = (f'./output/{name}')
    
    if not os.path.exists(f'{path}.csv'):
         data.to_csv(path_or_buf=(f'{path}.csv'))
    else:
     
        i = 0 
        while os.path.exists(f'{path}{i}.csv'):
            i += 1 
        data.to_csv(path_or_buf=(f'{path}{i}.csv'))

main()
    


