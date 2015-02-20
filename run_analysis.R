#You should create one R script called run_analysis.R that does the following. 
#1.Merges the training and the test sets to create one data set.
#2.Extracts only the measurements on the mean and standard deviation for each measurement. 
#3.Uses descriptive activity names to name the activities in the data set
#4.Appropriately labels the data set with descriptive variable names. 
#5.From the data set in step 4, creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject.

library(dplyr)  
train_data<-read.table("X_train.txt")
test_data<-read.table("X_test.txt")
train_labels<-read.table("Y_train.txt")
test_labels<-read.table("Y_test.txt")
activity_labels<-read.table("Activity_labels.txt")
train_subjects<-read.table("subject_train.txt")
test_subjects<-read.table("subject_test.txt")
features<-read.table("features.txt")


colnames(train_data)<-features$V2
colnames(test_data)<-features$V2
train_data<-cbind(train_labels,train_subjects,train_data)
test_data<-cbind(test_labels,test_subjects,test_data)
data<-rbind(train_data,test_data)
colnames(data)[1]<-c("Activity")
colnames(data)[2]<-c("Subject")
colnames(activity_labels)[1]<-c("Activity Id")
colnames(activity_labels)[2]<-c("Activity Name")

subset_data<-data[ , grepl("mean()" , colnames(data)) | grepl("std" , colnames(data)) | grepl("Activity" , colnames(data))| grepl("Subject" , colnames(data))] 
subset_mean_std<-subset_data[,grep("meanFreq",colnames(subset_data),invert=TRUE)]

activity_subject_averages<-subset_mean_std %>% group_by(Activity,Subject) %>% summarise_each(funs(mean))
m<-merge(activity_labels,activity_subject_averages,by.x="Activity Id",by.y="Activity")
write.table(m,"Tidy_Dataset.txt",row.names=FALSE,col.names=TRUE)
