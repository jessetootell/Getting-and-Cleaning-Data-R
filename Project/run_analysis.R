# run_analysis.R
# Purpose: This script is for the final project of 'Getting and Cleaning Data in R' in Coursera
#       it generates the tidy dataset ('tidy.txt')
# Author: Jesse Tootell

# Steps:
# 1. Merges the training and the test sets to create one tidy data set
# 2. Extracts only the measurements on the mean and standard deviation for each measurement
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject
# 6. Generate an updated codebook
  
# load packages
library(data.table)
library(reshape2)

# Set path
path <- getwd()
path

##################
#  Get the data
# Download the file. Put it in the `Data` folder.
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
f <- "Dataset.zip"
if (!file.exists(path)) {
dir.create(path)
}
download.file(url, file.path(path, f))

# Unzip the file
unzip(f, exdir = path)

# files now in a folder named `UCI_HAR_Dataset`
# Set this folder as input path. List the files here.
pathIn <- file.path(path, "UCI HAR Dataset")
list.files(pathIn, recursive = TRUE)

# See the `codebook.txt` file for detailed information on the dataset

######################################################################
# Read the files

# Subject files
dtSubjectTrain <- fread(file.path(pathIn, "train", "subject_train.txt"))
dtSubjectTest <- fread(file.path(pathIn, "test", "subject_test.txt"))

# Activity files
dtActivityTrain <- fread(file.path(pathIn, "train", "Y_train.txt"))
dtActivityTest <- fread(file.path(pathIn, "test", "Y_test.txt"))

# Read the data files. 
# Using a helper function, read the file with `read.table` instead of 'fread', then convert the resulting data frame to a data table. Return the data table.
fileToDataTable <- function(f) {
  df <- read.table(f)
  dt <- data.table(df)
}
dtTrain <- fileToDataTable(file.path(pathIn, "train", "X_train.txt"))
dtTest <- fileToDataTable(file.path(pathIn, "test", "X_test.txt"))


##############################
#  Merge the training and the test sets

#  Concatenate the data tables.
dtSubject <- rbind(dtSubjectTrain, dtSubjectTest)
setnames(dtSubject, "V1", "subject")
dtActivity <- rbind(dtActivityTrain, dtActivityTest)
setnames(dtActivity, "V1", "activityNum")
dt <- rbind(dtTrain, dtTest)

# Merge columns
dtSubject <- cbind(dtSubject, dtActivity)
dt <- cbind(dtSubject, dt)

# Set key
setkey(dt, subject, activityNum)


########################################################################
# 2. Extracts only the measurements on the mean and standard deviation for each measurement

# Read the `features.txt` file
# `features.txt` tells which variables in `dt` are measurements for the mean and standard deviation
dtFeatures <- fread(file.path(pathIn, "features.txt"))
setnames(dtFeatures, names(dtFeatures), c("featureNum", "featureName"))


# Subset measurements for the mean and standard deviation
dtFeatures <- dtFeatures[grepl("mean\\(\\)|std\\(\\)", featureName)]

# Convert the column numbers to a vector of variable names matching columns in `dt`
dtFeatures$featureCode <- dtFeatures[, paste0("V", featureNum)]
head(dtFeatures)

dtFeatures$featureCode



# Subset these variables using variable names
select <- c(key(dt), dtFeatures$featureCode)
dt <- dt[, select, with = FALSE]


########################################################################
# 3. Use descriptive activity names to name the activities in the data set

# `activity_labels.txt` file will be used to add descriptive names to the activities
dtActivityNames <- fread(file.path(pathIn, "activity_labels.txt"))
setnames(dtActivityNames, names(dtActivityNames), c("activityNum", "activityName"))


########################################################################
# 4. Appropriately label the data set with descriptive variable names.
  
# Merge activity labels.
dt <- merge(dt, dtActivityNames, by = "activityNum", all.x = TRUE)

# Add `activityName` as a key.
setkey(dt, subject, activityNum, activityName)

# reshape table from wide to long format
dt <- data.table(melt(dt, key(dt), variable.name = "featureCode"))

# Merge with activity name
dt <- merge(dt, dtFeatures[, list(featureNum, featureCode, featureName)], by = "featureCode", 
            all.x = TRUE)

# Create a new variable, `activity` that is equivalent to `activityName` as a factor class.
# Create a new variable, `feature` that is equivalent to `featureName` as a factor class.
dt$activity <- factor(dt$activityName)
dt$feature <- factor(dt$featureName)

# Seperate features from `featureName` using the helper function `grepthis`.
grepthis <- function(regex) {
  grepl(regex, dt$feature)
}
## Features with 2 categories
n <- 2
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("^t"), grepthis("^f")), ncol = nrow(y))
dt$featDomain <- factor(x %*% y, labels = c("Time", "Freq"))
x <- matrix(c(grepthis("Acc"), grepthis("Gyro")), ncol = nrow(y))
dt$featInstrument <- factor(x %*% y, labels = c("Accelerometer", "Gyroscope"))
x <- matrix(c(grepthis("BodyAcc"), grepthis("GravityAcc")), ncol = nrow(y))
dt$featAcceleration <- factor(x %*% y, labels = c(NA, "Body", "Gravity"))
x <- matrix(c(grepthis("mean()"), grepthis("std()")), ncol = nrow(y))
dt$featVariable <- factor(x %*% y, labels = c("Mean", "SD"))
## Features with 1 category
dt$featJerk <- factor(grepthis("Jerk"), labels = c(NA, "Jerk"))
dt$featMagnitude <- factor(grepthis("Mag"), labels = c(NA, "Magnitude"))
## Features with 3 categories
n <- 3
y <- matrix(seq(1, n), nrow = n)
x <- matrix(c(grepthis("-X"), grepthis("-Y"), grepthis("-Z")), ncol = nrow(y))
dt$featAxis <- factor(x %*% y, labels = c(NA, "X", "Y", "Z"))

# make sure all possible combinations of `feature` are in 
r1 <- nrow(dt[, .N, by = c("feature")])
r2 <- nrow(dt[, .N, by = c("featDomain", "featAcceleration", "featInstrument", 
                           "featJerk", "featMagnitude", "featVariable", "featAxis")])
# Check that all combo are present (TRUE is a yes)
r1 %in% r2

#########################################################
# 5. Create a tidy data set with the average of each variable for each activity and each subject
setkey(dt, subject, activity, featDomain, featAcceleration, featInstrument, 
       featJerk, featMagnitude, featVariable, featAxis)
dtTidy <- dt[, list(count = .N, average = mean(value)), by = key(dt)]

# write tidy dataset to file
write.table(dtTidy, "tidy.txt", row.names=FALSE, sep=",")

# Make Codebook
knit("makeCodebook.Rmd", output="codebook1.md", encoding="ISO8859-1", quiet=TRUE)
