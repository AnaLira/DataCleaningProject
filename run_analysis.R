#You should create one R script called run_analysis.R that does the following. 
#1.Merges the training and the test sets to create one data set.
#2.Extracts only the measurements on the mean and standard deviation for each measurement. 
#3.Uses descriptive activity names to name the activities in the data set
#4.Appropriately labels the data set with descriptive variable names. 
#5.From the data set in step 4, creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject.

#The library dplyr is used to calculate all the averages per activity and subject 
library(dplyr) 

# IMPORTANT: the files are assumed to be located in the same directory where the script is run.
# (already extracted from the .zip source)

# Part A: loading the required data
#The files used during the analysis are:
#1) X_train.txt and X_test.txt are the main files with all the detailed measures 
#   for all subjects and activities and are placed in the train_data and test_data dataframes
#   respectively.
train_data<-read.table("X_train.txt")
test_data<-read.table("X_test.txt")

#2) Y_train.txt and Y_test.txt contain the corresponding activity id for each row in the 
#   X_train.txt and X_test.txt data 
train_labels<-read.table("Y_train.txt")
test_labels<-read.table("Y_test.txt")

#3) The file Activity_labels is stored in the activity_labels dataframe and is used
#   to include descriptive names for each activity id in the tidy data set
activity_labels<-read.table("Activity_labels.txt")

#4) subject_train.txt and subject_test.txt contain the corresponding subject id for each row in the 
#   X_train.txt and X_test.txt data
train_subjects<-read.table("subject_train.txt")
test_subjects<-read.table("subject_test.txt")

#5) features.txt contains the description of all measures (columns) in the 
#   X_train.txt and X_test.txt files and is used to give descriptive names to each column in the 
#   tidy data set.
features<-read.table("features.txt")


#Part B: building a dataframe "data" with all the information required.

# The first step is to rename the train_data and test_data dataframes with the 
# descriptive column names retrieved in the features dataframe in column V2
# using the col_names function.
colnames(train_data)<-features$V2
colnames(test_data)<-features$V2

# The second step is to add two columns to train_data and test_data
# with the subject and activity information corresponding to each row
# using the cbind function.
train_data<-cbind(train_labels,train_subjects,train_data)
test_data<-cbind(test_labels,test_subjects,test_data)

# The third step is to unify in one data set "data" 
# the complete train_data and test_data dataframe using the rbind function
data<-rbind(train_data,test_data)


#The fourth step is to give descriptive column names to the two columns added:
# "Activity" and "Subject", so as to the activity_labels dataframe

colnames(data)[1]<-c("Activity")
colnames(data)[2]<-c("Subject")
colnames(activity_labels)[1]<-c("Activity Id")
colnames(activity_labels)[2]<-c("Activity Name")

# Now we have the ready the "data" dataset, with all the information needed
# to create a new and summarized data set with only the mean and standard
# columns measures.


#Part C: generating the output data set "activity_subject_activity"

#1) The first step is to select only the columns that refer to a
#   mean or standard deviation (std) measure by subsetting the "data" dataframe
#   using function grepl and "or" clauses with the following strings: 
#   mean, std, Activity and Subject 
subset_data<-data[ , grepl("mean()" , colnames(data)) | grepl("std" , colnames(data)) | grepl("Activity" , colnames(data))| grepl("Subject" , colnames(data))] 

#2) The result still brings an unwanted column type "meanFreq", so the next step
# is to take all these columns out by using again the grep function but in inverse mode (invert=TRUE) 
# with the string "meanFreq"

subset_mean_std<-subset_data[,grep("meanFreq",colnames(subset_data),invert=TRUE)]

#3) Now using de dplyr library we create the summarized data set "activity_subject_averages"
# by grouping the subset_mean_std dataframe by activity and subject using group_by function
# and calcultating the mean of each not grouped column 
# using the summarise_each function

activity_subject_averages<-subset_mean_std %>% group_by(Activity,Subject) %>% summarise_each(funs(mean))

# 4) Finally, we create the output data_frame "m" to include in the
# summarized data set the activity description
# by using the function merge, joining by activity id.
# Then we write the output "m" dataframe to a file "Tidy_Dataset.txt"

m<-merge(activity_labels,activity_subject_averages,by.x="Activity Id",by.y="Activity")
write.table(m,"Tidy_Dataset.txt",row.names=FALSE,col.names=TRUE)
