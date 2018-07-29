library(reshape2)

##set working dir
setwd("D:/Programs/R/WD/Assignments/Getting and cleaning data/Week 4")
##check if file and directory exists
filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
  download.file(fileURL, filename, method="curl")
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}
# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

##extract only the mean and standard deviation features
featuresFiltered<-grep(".*mean.*|.*std.*",features[,2])
featuresFiltered.names <- features[featuresFiltered,2]
featuresFiltered.names <- gsub('-mean', 'Mean', featuresFiltered.names)
featuresFiltered.names <- gsub('-std', 'Std', featuresFiltered.names)
featuresFiltered.names <- gsub('[-()]', '', featuresFiltered.names)


##read files into objects
##train
x_train<-read.table("UCI HAR Dataset/train/X_train.txt")[featuresFiltered]
y_train<-read.table("UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table("UCI HAR Dataset/train/subject_train.txt")
##test
x_test<-read.table("UCI HAR Dataset/test/X_test.txt",header=FALSE)[featuresFiltered]
y_test<-read.table("UCI HAR Dataset/test/y_test.txt",header=FALSE)
subject_test<-read.table("UCI HAR Dataset/test/subject_test.txt",header=FALSE)

##create data frames
testDF<-cbind(subject_test,y_test,x_test)
trainDF<-cbind(subject_train,y_train,x_train)

##merge data frames
mergeDF<-rbind(trainDF,testDF)
colnames(mergeDF)<-c("subject","activity", featuresFiltered.names)

##Store as factors
mergeDF$activity<-factor(mergeDF$activity, levels = activityLabels[,1], labels = activityLabels[,2])
mergeDF$subject<-as.factor(mergeDF$subject)

#Melt the data frame
mergeDF.melted<-melt(mergeDF, id = c("subject","activity"))
mergeDF.mean<-dcast(mergeDF.melted,subject + activity ~ variable, mean)

#Write to table to file
write.table(mergeDF.mean, "tidy.txt", row.names = FALSE, quote = FALSE)