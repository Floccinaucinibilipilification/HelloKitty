# HelloKitty
AI for Healthcare Hackathon 2019

## psLove Challenge
Using AI, predict when an upcoming period will most likely to start next for a given female user, helping women to predict fertile window and predict symptoms and correlations.

## Pipeline:

### 1. Data cleaning   

We would like to use the data to predict the next period time and also the correlation between sypmtoms with period. Questions we would expect to answer by our analysis including:

1). When's the upcoming period?   
2). What's the correlation between several sypmtoms with period?   
3). Whether there is any symptom's impact on period?   

The data was quite messy. We removed users with records less than 3. For users with only 1 or 2 incontinuous records, we will predict the upcoming period according to the last period and the period length provided by users. 


### 2. (Data merging and exploration)[https://github.com/Floccinaucinibilipilification/HelloKitty/blob/master/Data_explorationn.R]

We then mapped symptom records with periods record by date. A symptom happened no more than 30 days from the period begining will be considered as symptoms related to the symptom(whether being influneced or influence the period).

We then tried to fit linear regression and random forest models to see if symptoms were related to period.(Says, whether we could predict if a woman is before period, in period or after period by symptoms)
Result showed that sore and headache are likely to happen in or after period, while cramp tends to happen before period.

### 3. (Prediction)[https://github.com/Floccinaucinibilipilification/HelloKitty/blob/master/HelloKitty.ipynb] 

We calculated the periods lengths from previous records by continous records. We then used the records from the past 3 months to predict the next period starting date. Records with length > 50 were identified as missing one period record between, and were not included in prediction.
