Period<-read.csv("/Users/lingyitan/Desktop/pslovedata/Period.csv") #34942
Symptom<-read.csv("/Users/lingyitan/Desktop/pslovedata/Symptom.csv") #13512
User<-read.csv("/Users/lingyitan/Desktop/pslovedata/User.csv") #6729

##################################################################
##################################################################

summary(Period)
US<-merge(x=User,y=Symptom,by.x="id",by.y="user_id")
mood<-Symptom[,c("id","user_id","mood","date")]
mood_user<-User[User$id%in%mood$user_id,] #3953
mood_Period<-Period[Period$id%in%mood$user_id,] #3367
mood_Period$leng<-difftime(as.Date(mood_Period$end_date,"%d/%m/%y"),as.Date(mood_Period$start_date,"%d/%m/%y"),units="days")
mood1<-merge(x=mood_user,y=mood_Period,by.x="id",by.y="User_id")
names(mood1)[5]<-"id_period"
mood2<-merge(x=mood1,y=mood,by.x="id",by.y="user_id")

library(ggplot2)
ggplot(mood2) + aes(x = id) + geom_bar()

#Users who reported mood symptom
mood_p<-mood2[mood2$mood>0,"id"]
mood3<-mood2[mood2$id%in%mood_p,]
mood3$start_date<-as.Date(mood3$start_date,"%d/%m/%y")
mood3$end_date<-as.Date(mood3$end_date,"%d/%m/%y")
mood3$date<-as.Date(mood3$date,"%d/%m/%y")
library(lubridate)
mood3$sympt_start<-mood3$date-mood3$start_date
mood3$sympt_end<-mood3$date-mood3$end_date
mood4<-mood3[mood3$sympt_start>-31&mood3$sympt_start<31|mood3$sympt_end>-31&mood3$sympt_end<31,]
##################################################################

Period$leng<-difftime(as.Date(Period$end_date,"%d/%m/%y"),as.Date(Period$start_date,"%d/%m/%y"),units="days")
UP<-merge(x=User,y=Period,by.x="id",by.y="User_id")
UP$start_date<-as.Date(UP$start_date,"%d/%m/%y")
UP$end_date<-as.Date(UP$end_date,"%d/%m/%y")

library("dplyr")
UP %>% group_by(id) %>% arrange(start_date)

UP<-UP[order(UP$id,UP$start_date),]
UP$leng<-UP$leng+1

##################################################################
###Extract people with >3 records of period
records<-data.frame(table(Period$User_id))
records_3<-records[records$Freq>=3,]
Period_3<-Period[Period$User_id%in%records_3$Var1,]
Period_3 <- Period_3[order("User_id"),] 
Period_3$start_date<-as.Date(Period_3$start_date,"%d/%m/%y")
Period_3$end_date<-as.Date(Period_3$end_date,"%d/%m/%y")
attach(Period_3)
newdata <- Period_3[order(User_id,start_date),] 
detach(Period_3)
UP<-merge(x=User,y=newdata,by.x="id",by.y="User_id")
UP$leng<-UP$leng+1
UP[UP$leng<=0&!is.na(UP$leng),]<-NA
###################################################################
###Map Symtom to the UP (where Symtom date is closed to period date)
Symptom$date<-as.Date(Symptom$date,"%d/%m/%y")
names(Symptom)[1]<-"Symptom_id"
UPS<-merge(x=UP,y=Symptom,by.x="id",by.y="user_id")
UPS$Symp_period<-difftime(UPS$date,UPS$start_date,units="days")
UPS$Symp_period[UPS$Symp_period>30|UPS$Symp_period< -30]=NA
UPS[is.na(UPS$Symp_period),c("Symptom_id","acne","backache","bloating","cramp","diarrhea","dizzy","headache","mood","nausea","sore")]<-0

UPS[is.na(UPS$Symp_period),"date"]<-NA
UPS_complete<-UPS[!duplicated(UPS), ]
write.csv(UPS_complete,file="/Users/lingyitan/Desktop/pslovedata/UPS_complete.csv")

attach(UPS_complete)
newdata <- UPS_complete[order(id,start_date),] 
detach(UPS_complete)


M1<-lm(data=UPS_complete,as.numeric(Symp_period)~acne+backache+bloating+cramp+diarrhea+dizzy+headache+mood+nausea+sore)
summary(M1) #sore/after period, cramp/before period, headache/before period

M2<-lm(data=UPS_complete,as.numeric(Symp_period)~cramp+headache+sore)
summary(M2)

install.packages("randomForest")
library(randomForest)
Symptom_com<-UPS_complete[!is.na(UPS_complete$Symp_period),]
rf1<-randomForest(as.numeric(Symp_period)~acne+backache+bloating+cramp+diarrhea+dizzy+headache+mood+nausea+sore,data=Symptom_com,ntree=50, norm.votes=FALSE)
importance(rf1) #cramp, bloating, backache, mood, acne, headache, sore


######Regression
newdata$Symp_periodend<-difftime(newdata$date,newdata$end_date,unit="day")
newdata$ifperiod[newdata$Symp_period<0]<- 1 #Before period
newdata$ifperiod[newdata$Symp_period>=0&newdata$Symp_periodend<=0]<- 2 #In period
newdata$ifperiod[newdata$Symp_periodend>0]<- 3 #In period
newdata$ifperiod<-as.factor(newdata$ifperiod)
newdata_com<-newdata[!is.na(newdata$ifperiod),]
rf2<-randomForest(ifperiod~acne+backache+bloating+cramp+diarrhea+dizzy+headache+mood+nausea+sore,data=newdata_com,ntree=50, norm.votes=FALSE)
importance(rf2)
rf2$confusion
1-(3212+957+106)/dim(newdata_com)[1] #error rate 0.7913616
#Model is bad

dat<-newdata_com[c("acne","backache","bloating","cramp","diarrhea","dizzy","headache","mood", "nausea","sore","ifperiod")]

#Multinomial regressionn
install.packages("nnet")
library(nnet)
MNR1<-multinom(ifperiod~acne+backache+bloating+cramp+diarrhea+dizzy+headache+mood+nausea+sore,data=newdata_com)
summary(MNR1)

predicted_class <- predict (MNR1, newdata_com)
table(predicted_class,newdata_com$ifperiod)
mean(as.character(predicted_class) != as.character(newdata_com$ifperiod)) #error rate 0.5960957

newdata$diff <- c(NA,newdata[2:nrow(newdata), 6] - newdata[1:(nrow(newdata)-1), 6])
newdata$first_id <- c(1, diff(newdata$id))
newdata$diff[newdata$first_id>0]<-NA


#Keep continuous records
data_con<-newdata[newdata$diff<50|newdata$first_id>0,]
data_com<-data_con[!is.na(data_con$cycle_length_initial),]

