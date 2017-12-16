library(h2o)
library(caret)
library(data.table)
library(dplyr)
h2o.init()
# Import test and train set
train <- fread("train.csv")
test <- fread("test.csv")
#merge test and train for feature engineering 
comb <- bind_rows(train, test)
#feature engineering
comb$logdiff <- log1p(comb$`Months since First Donation` -  comb$`Months since Last Donation` )
comb$logDonationPeriod <- log1p((comb$`Number of Donations`/  comb$`Months since First Donation`)) #log ratio of donation
comb$Old_Good_Donor    <- as.factor(as.integer((comb$`Months since First Donation` >= 24) & (comb$`Months since Last Donation` <= 3))) #old donor who like to donate
comb$Old_Bad_Donor     <- as.factor(as.integer((comb$`Months since First Donation` >= 24) & (comb$`Months since Last Donation` >= 5))) # old donor that maybe has quitted
comb$BadDonor          <- as.factor(as.integer((comb$`Months since Last Donation` >= 5))) #long time without donation
comb$GoodDonor         <- as.factor(as.integer((comb$`Months since Last Donation` <= 2))) # 2 months since last donation
comb$Quitted          <-  as.factor(as.integer((comb$`Months since Last Donation` >= 12) & (comb$`Number of Donations` <= 3)))#few donation and long time without donations
comb$logRatio         <- log1p((comb$`Months since Last Donation` / comb$`Months since First Donation`))
comb$`Total Volume Donated (c.c.)` <- NULL
#drop outliers if you want
combine4 <- comb[1:576,] #outliers should be checked only on train set 
combine4 <- comb[, 1:13] #change if you change the number of feature   
mod <- lm(`Made Donation in March 2007` ~ ., data=combine4 )
outliers <- car::outlierTest(mod) #outliers vector 
car::vif(mod) #check for multicollinearity 

#split again 
dtrain <- comb[1:576 ,]
dtest <- comb[577:776 ,]
# Create a stratified random sample to create train and validation sets

trainIndex   <- createDataPartition(dtrain$`Made Donation in March 2007` , p=0.75, list=FALSE, times=1)
dtrain.train        <- dtrain[ trainIndex, ]
dtrain.test         <- dtrain[-trainIndex, ]
dtrain.train$V1 <- NULL #drop useless index 
dtrain.test$V1 <- NULL
dtrain.train <- as.data.frame(dtrain.train)
dtrain.test <- as.data.frame(dtrain.test)
# Identify predictors and response
y <- "Made Donation in March 2007"
x <- setdiff(names(dtrain.train), y)
#feed the h2o cloud
dtrain.train <- as.h2o(dtrain.train)
dtrain.test <- as.h2o(dtrain.test)
dtest.test <- as.h2o(dtest)
#automl function 
aml <- h2o.automl(x = x, y = y,
                  training_frame = dtrain.train,
                  validation_frame   = dtrain.test,
                  nfolds = 10,
                  seed = 1234,
                  max_runtime_secs = 50400)
#erase Y in test set because oddly it pulls errors (maybe bacause of NA?)
dtest.test$'Made Donation in March 2007' <- NULL
pred <- as.data.frame(h2o.predict(aml@leader, dtest.test))
pred <- abs(pred) #because lower bound of Y is 0 the prediction has some negative outcomes near 0.00...
submit <- data.frame( V1 = comb[577:776,c("V1")], `Made Donation in March 2007` = pred$predict)
#workaround for submitting
# get the submission format from the file
submission_format <- read.csv("SubmissionFormat.csv", check.names=FALSE)
# update the predictions with the proper column names
colnames(submit) <- colnames(submission_format)
write.csv(submit, file = "blood3.csv", row.names = FALSE)