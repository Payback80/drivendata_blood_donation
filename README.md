# How to finish into 1% in a data competition with less than 50 lines of code 

I have decided to write this short report because I had fun and it could be useful for other participants in the introductory competition “predict blood donation”  hosted on Drivendata
https://www.drivendata.org/competitions/2/warm-up-predict-blood-donations/page/5/


 The dataset is very small, in my opinion too much, it tends to overfit very easily not only on the training set but on CV and validation set too if you don't take precautions to address it.

At first I have decided to use my favorite algorithm, xgboost, but despite my expectation it didn't perform  well I had a logloss error of ~0.48 , the situation didn't improve much even with feature engineering.

So i have decided to use a a newly function of the H2o.ai framework: autoML. Automl performs automatically a stacking  of machine learning algorithms  and the split of the dataset in train/validation/CV/leaderboard in just 1 line of code that's pretty amazing ! 
I used automl without any feature engineering and i had an error of ~45/46 a good improvement but not enough for me, i went to read the forum for  other participants approaches and quite surprising nobody did an extensive feature engineering

I did feature engineering to catch some of that variance! The new features  are made up to understand the donor behavior
categorical feature: 
comb$Old_Good_Donor   a donor that has the first donation more than 2 years ago and a recent donation  

comb$Old_Bad_Donor same of above but the last donation is 5 months far ago     
comb$BadDonor    last donation is 5 months far ago    
comb$GoodDonor     last donation is equal or less than 2 months    
comb$Quitted      a donor that has the last donation equal or more than 1 year ago and only 3 donations in all of his history it's likely that he has quitted donating  

continous features log normalized to avoid skewnees:  
comb$logRatio ratio of months in donation history  
comb$logdiff  number of months enrolled as donor 
comb$logDonationPeriod ratio of donations in history

with these new features i have achieved an error of  0.4269 that fires me around in the first 1% 
As a word of advice due the small dimension of the dataset could lead to logloss difference of ~0.2 if you just change the seed 
In my code there are also two functions to detect outliers and multicollinearity, there is one outlier but i didn't adressed it and the vif value is < 7 so there isn't a multicollinearity effect 
Below i attach the statistics of the final model on 1234 seed. I hope you enjoyed my short report and if you need more info and need someone for a pro bono project 
feel free to drop me a line to my @mail andrea.mariani AT gmail.com   cheers!



## Author

* **Andrea Mariani** - *Initial work* - [Payback80](https://github.com/Payback80)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details


Model Details:
==============

H2ORegressionModel: stackedensemble
Model ID:  StackedEnsemble_AllModels_0_AutoML_20171214_182058 
NULL


H2ORegressionMetrics: stackedensemble
** Reported on training data. **

MSE:  0.1427701
RMSE:  0.3778493
MAE:  0.2770833
RMSLE:  0.2613684
Mean Residual Deviance :  0.1427701


H2ORegressionMetrics: stackedensemble
** Reported on validation data. **

MSE:  0.1603182
RMSE:  0.4003976
MAE:  0.2925581
RMSLE:  0.2726779
Mean Residual Deviance :  0.1603182


H2ORegressionMetrics: stackedensemble
** Reported on cross-validation data. **
** 10-fold cross-validation on training data (Metrics computed for combined holdout predictions) **

MSE:  0.1501806
RMSE:  0.3875315
MAE:  0.3022627
RMSLE:  0.272664
Mean Residual Deviance :  0.1501806