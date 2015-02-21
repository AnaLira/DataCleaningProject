Getting and Cleaning Data Project 
Description & Code Book

Script Description

Prerequisites

- The library dplyr needs to be installed and is used to calculate all the averages per activity and subject 
- The files source files are assumed to be located in the same directory where the script is run.
(already extracted from the .zip source)

The script is organized in three parts:

a) Loading all the files needed for the analysis
b) Preparing a consolidated dataframe with all the columns, rows and labels required to generate the output data set 
c) Calculating the output data set and writing it as a text file.

Part A: loading the required data
The files used during the analysis are:

1) X_train.txt and X_test.txt are the main files with all the detailed measures for all subjects and activities and are placed in the train_data and test_data dataframes respectively.
train_data<-read.table("X_train.txt")
test_data<-read.table("X_test.txt")

2) Y_train.txt and Y_test.txt contain the corresponding activity id for each row in the X_train.txt and X_test.txt data 
train_labels<-read.table("Y_train.txt")
test_labels<-read.table("Y_test.txt")

3) The file Activity_labels is stored in the activity_labels dataframe and is used to include descriptive names for each activity id in the tidy data set
activity_labels<-read.table("Activity_labels.txt")

4) subject_train.txt and subject_test.txt contain the corresponding subject id for each row in the 
   X_train.txt and X_test.txt data
train_subjects<-read.table("subject_train.txt")
test_subjects<-read.table("subject_test.txt")

5) features.txt contains the description of all measures (columns) in the X_train.txt and X_test.txt files and is used to give descriptive names to each column in the tidy data set.
features<-read.table("features.txt")


Part B: building a dataframe "data" with all the information required.

1) The first step is to rename the train_data and test_data dataframes with the descriptive column names retrieved in the features dataframe in column V2 using the col_names function.
colnames(train_data)<-features$V2
colnames(test_data)<-features$V2

2) The second step is to add two columns to train_data and test_data with the subject and activity information corresponding to each row  using the cbind function.
train_data<-cbind(train_labels,train_subjects,train_data)
test_data<-cbind(test_labels,test_subjects,test_data)

3) The third step is to unify in one data set "data" the complete train_data and test_data dataframe using the rbind function
data<-rbind(train_data,test_data)

4) The fourth step is to give descriptive column names to the two columns added: "Activity" and "Subject", so as to the activity_labels dataframe

colnames(data)[1]<-c("Activity")
colnames(data)[2]<-c("Subject")
colnames(activity_labels)[1]<-c("Activity Id")
colnames(activity_labels)[2]<-c("Activity Name")

 Now we have the ready the "data" dataset, with all the information needed to create a new and summarized data set with only the mean and standard columns measures.


Part C: generating the output data set "activity_subject_averages"

1) The first step is to select only the columns that refer to a mean or standard deviation (std) measure by subsetting the "data" dataframe using function grepl and "or" clauses with the following strings: “mean”, “std”, “Activity” and “Subject”

subset_data<-data[ , grepl("mean()" , colnames(data)) | grepl("std" , colnames(data)) | grepl("Activity" , colnames(data))| grepl("Subject" , colnames(data))] 

2) The result still brings an unwanted column type "meanFreq", so the next step is to take all these columns out by using again the grep function but in inverse mode (invert=TRUE)  with the string "meanFreq"

subset_mean_std<-subset_data[,grep("meanFreq",colnames(subset_data),invert=TRUE)]

3) Now using de dplyr library we create the summarized data set "activity_subject_averages"
 by grouping the subset_mean_std dataframe by activity and subject using group_by function
 and calcultating the mean of each not grouped column  using the summarise_each function

activity_subject_averages<-subset_mean_std %>% group_by(Activity,Subject) %>% summarise_each(funs(mean))

4) Finally, we create the output data_frame "m" to include in the summarized data set the activity description by using the function merge, joining by activity id.
 Then we write the output "m" dataframe to a file "Tidy_Dataset.txt"

m<-merge(activity_labels,activity_subject_averages,by.x="Activity Id",by.y="Activity")
write.table(m,"Tidy_Dataset.txt",row.names=FALSE,col.names=TRUE) 


The code book

Variables in the Tyde_dataset file:

Grouping Variables

The first three columns are the variables by which resulting averages where grouped and are:
Activity Id: identifier of the type of activity (numeric, values 1 to 6)
Activity Name: string with the corresponding activity description 

1 WALKING
2 WALKING_UPSTAIRS
3 WALKING_DOWNSTAIRS
4 SITTING
5 STANDING
6 LAYING

Subject: numeric identifier of the subject to which the measures correpsond to (measures row). Values from 1 to 30.

Measure Variables 
The ramaining columns (66 in total) correspond to the average by activity and subject of the following measured features, as described in the source files “features_info.txt”:
The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals).  These signals were used to estimate variables of the feature vector for each pattern:  '-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

tBodyAcc-mean()-X
tBodyAcc-mean()-Y
tBodyAcc-mean()-Z
tBodyAcc-std()-X
tBodyAcc-std()-Y
tBodyAcc-std()-Z
         
tGravityAcc-mean()-X
tGravityAcc-mean()-Y
tGravityAcc-mean()-Z
tGravityAcc-std()-X
tGravityAcc-std()-Y
tGravityAcc-std()-Z

tBodyAccJerk-mean()-X
tBodyAccJerk-mean()-Y
tBodyAccJerk-mean()-Z 
tBodyAccJerk-std()-X
tBodyAccJerk-std()-Y
tBodyAccJerk-std()-Z

tBodyGyro-mean()-X
tBodyGyro-mean()-Y
tBodyGyro-mean()-Z 
tBodyGyro-std()-X
tBodyGyro-std()-Y
tBodyGyro-std()-Z

tBodyGyroJerk-mean()-X
tBodyGyroJerk-mean()-Y
tBodyGyroJerk-mean()-Z 
tBodyGyroJerk-std()-X
tBodyGyroJerk-std()-Y
tBodyGyroJerk-std()-Z

tBodyAccMag-mean()
tBodyAccMag-std()

tGravityAccMag-mean()  
tGravityAccMag-std()

tBodyAccJerkMag-mean()
BodyAccJerkMag-std()

tBodyGyroMag-mean()
tBodyGyroMag-std()

tBodyGyroJerkMag-mean()    
tBodyGyroJerkMag-std()

fBodyAcc-mean()-X
fBodyAcc-mean()-Y
fBodyAcc-mean()-Z
fBodyAcc-std()-X
fBodyAcc-std()-Y           
fBodyAcc-std()-Z 

fBodyAccJerk-mean()-X
fBodyAccJerk-mean()-Y
fBodyAccJerk-mean()-Z
fBodyAccJerk-std()-X
fBodyAccJerk-std()-Y           
fBodyAccJerk-std()-Z 
fBodyGyro-mean()-X
fBodyGyro-mean()-Y
fBodyGyro-mean()-Z
fBodyGyro-std()-X
fBodyGyro-std()-Y           
fBodyGyro-std()-Z 

fBodyAccMag-mean()
fBodyAccMag-std()

fBodyBodyAccJerkMag-mean()
fBodyBodyAccJerkMag-std()
fBodyBodyGyroMag-mean()
fBodyBodyGyroMag-std()
fBodyBodyGyroJerkMag-mean()
fBodyBodyGyroJerkMag-std()


The internal variables used inside the script are:

train_data: dataframe that contains all the measures for the train subjects
test_data: dataframe that contains all the measures for the test subjects
train_labels and test_labels: contain the corresponding activity id for each row in the train_data and test_data dataframes.
train_subjects and test_subjects: contain the corresponding subject id for each row in the train_data and test_data dataframes.
activity_labels: dataframe that contains descriptive names for each activity id in the tidy data set
features: dataframe that contains the description of all measures (columns) in the train_data and test_data variables and is used to give descriptive names to each column in the tidy data set.

Data: a data frame that consolidates both the train and test data, including the columns “activity” and “subject” and has descriptive column names for each measure.
subset_data: a subset of  “data” with only the measure columns related to a mean or standard deviation
subset_mean_std: the same subset_data but taking out the columns related to a “MeanFreq” measure.
activity_subject_averages: dataframe with the average of all columns (mean and std) grouped by activity and subject
m: the same as activity_subject_average, but including the activity description column

1. Information about the summary choices you made

The script first consolidates all the information provided by the different files into a unique “data” dataframe (except for the activity description).
Then it calculates de average of each column grouped by Activity and Subject and returns it in the tyde_dataset file, (including the activity description before writing the file)
