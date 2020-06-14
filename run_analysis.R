## Load relevant libraries
library(dplyr)

## Get the data off the web
file_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("uci_dataset.zip")) {
    download.file(file_url, destfile = "./uci_dataset.zip")
}

if(!file.exists("./UCI HAR Dataset")) {
    unzip("uci_dataset.zip")
}

## Merge the training and test datasets to create one dataset
# Read identifiers data
features <- read.table("./UCI HAR Dataset/features.txt")
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")

# Read training data
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

# Read test data
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")

# create Training and Test df's
train_df <- cbind(subject_train, y_train, x_train)
test_df <- cbind(subject_test, y_test, x_test)

# Merge train and test
full_data <- rbind(train_df, test_df)

# Assign proper column names
names <- cbind("Subject", "Activity", t(features[2]))
colnames(full_data) <- names

## Only keep the mean and std measurements 
reduced_df <- select(full_data, Subject, Activity, contains(c("mean", "std")))
dim(full_data)      # 10299   563
dim(reduced_df)     # 10299    88

## Label the activities with descriptive names
reduced_df$Activity <- recode(
    reduced_df$Activity,
    '1' = activity_labels[1, 2],
    '2' = activity_labels[2, 2],
    '3' = activity_labels[3, 2],
    '4' = activity_labels[4, 2],
    '5' = activity_labels[5, 2],
    '6' = activity_labels[6, 2]
)

## Label the dataset with descriptive variable names
names(reduced_df) <- gsub("^t", "time", names(reduced_df))
names(reduced_df) <- gsub("\\(t", "(time", names(reduced_df))
names(reduced_df) <- gsub("^f", "frequency", names(reduced_df))
names(reduced_df) <- gsub("Acc", "Accelerometer", names(reduced_df))
names(reduced_df) <- gsub("Gyro", "Gryoscope", names(reduced_df))
names(reduced_df) <- gsub("Mag", "Magnitude", names(reduced_df))
names(reduced_df) <- gsub("BodyBody", "Body", names(reduced_df))

## Create ab independent tidy data set with the average 
## of each variable for each activity and each subject
tidy_df <- reduced_df %>% 
    group_by(Subject, Activity) %>%
    summarise_all(mean)

# Export the tidy dataset to a txt file
write.table(tidy_df, "./tidy_dataset.txt", row.name = FALSE)
