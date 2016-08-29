# Project: Getting and Cleaning Data in R

Author: Jesse Tootell (https://github.com/jessetootell/Getting-and-Cleaning-Data_R.git)

### Parameters for the project
The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected. 

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 

Here are the data for the project: 

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.
 
1. Merges the training and the test sets to create one data set (rbind() data tables, then cbind() with Subject df)
2.	Extracts only the measurements on the mean and standard deviation for each measurement.
3.	Uses descriptive activity names to name the activities in the data set.
4.	Appropriately labels the data set with descriptive activity names.	
5.	Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 

## Files in this repository

* **run_analysis.R** : transforms raw data into the tidy dataset 'tidy.txt'
* **codebook.md**: details about project and 'tidy.txt'
* **makeCodebook.Rmd**: used in tun_analysis.R to update codebook.md
* **tidy.txt**: tidy dataset with the average of each variable for each activity and each subject in the raw data
* **Dataset.zip**: raw data in zip file
* **UCI HAR Dataset File**: unzipped data

## Steps to reproduce this project

1.	Open the R script run_analysis.r using a text editor
2.	Change setwd() to to the your desired working directory location
3.	Run the R script run_analysis.R.

Produces a tidy dataset in the file tidy.txt (tab-delimited text) and a codebook.

**Specific steps involved in creating 'tidy.txt' are in the file run_analysis.R**

