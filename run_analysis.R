####
# Script Name: Getting and Cleaning Data Course Project
# Script Description: This script computes various data gathering 
#                       and cleaning steps on the target dataset
# Date Created: April 30, 2020
# Data Modified: May 5, 2020
# Author: Pranav Annapareddy
###


###------------------------###
### STEP 0: Pre-Processing ###
###------------------------###
# 1) Load required libraries
# 2) Load data into environment
library(readr)
library(tidyr)
library(reshape2)
library(dplyr)

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- "UCI HAR Dataset.zip"
folderName <- "UCI HAR Dataset"
filePath <- paste(folderName,"/",fileName)

if (!file.exists(filePath)) {
  download.file(url, fileName, mode = "wb")
}

if (!file.exists(folderName)) {
  unzip(fileName)
} 


activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", stringsAsFactors = FALSE)
# activityLabels <- activityLabels[,2] # Keeping id column since it will be easier to merge to get labels
colnames(activityLabels) <- c("ActivityId","ActivityLabel") 

features <- read.table("UCI HAR Dataset/features.txt",stringsAsFactors = FALSE)
# features <- as.data.frame(t(as.matrix(features[,2])))
features <- features[,2]


sub_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")


sub_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")

###------------------------###
### STEP 1: Merge the data ###
###------------------------###


sub_merge<- rbind(sub_train,sub_test) 
x_merge <- rbind(x_train,x_test) #merged data without column names
y_merge <- rbind(y_train,y_test)

rm(sub_train,sub_test,x_train,x_test,y_train,y_test) # Removing unused variables

colnames(x_merge) <- features # Label required data with column names

###---------------------------------------------###
### STEP 2: Extract only Mean and Std from data ###
###---------------------------------------------###

data_subset <- x_merge[,grep("-(mean|std)",features)] # Contains only Mean and Std columns

###----------------------------------------###
### STEP 3: Use descriptive activity names ###
###----------------------------------------###

# table(y_complete) #data split between integers 1-6
# -> y_complete contains activity labels
## binding y_complete to data (check STEP 3)
colnames(y_merge) <- c("ActivityId")
colnames(sub_merge) <- c("SubjectId")

data_subset <- cbind(data_subset,y_merge,sub_merge) # Merged data with all column names

data_subset <- merge(x = data_subset,y = activityLabels,
                      by = c("ActivityId"),
                      all.x = TRUE) # Doing left join to retain all original data and get activity labels

###------------------------------------###
### STEP 4: Descriptive variable names ###
###------------------------------------###

# Remove "()" and "-" from colnames

data_subset_cols <- colnames(data_subset)

data_subset_cols <- gsub('[()]', '', data_subset_cols)
data_subset_cols <- gsub('-', '_', data_subset_cols)
data_subset_cols <- gsub("^f", "FreqDomain", data_subset_cols) 
data_subset_cols <- gsub("^t", "TimeDomain", data_subset_cols)
data_subset_cols <- gsub("Acc", "Accelerometer", data_subset_cols)
# data_subset_cols <- gsub("mean", "Mean", data_subset_cols) # mean and std are descriptive already
# data_subset_cols <- gsub("std", "StandardDeviation", data_subset_cols)

colnames(data_subset) <- data_subset_cols


###-------------------------------------------###
### STEP 5: Create tidy dataset with averages ###
###-------------------------------------------###

# data_averages <- melt(data_subset, id = c("SubjectId", "ActivityId"))
data_averages <- data_subset %>% 
                  group_by(SubjectId,ActivityLabel) %>%
                  summarise_all(funs(mean))

# output tidy data
write.table(data_averages, "TidyData.txt", row.names = FALSE, 
            quote = FALSE)

###---------------###
### END OF SCRIPT ###
###---------------###
