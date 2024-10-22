# runAnalysis.example.R This file is an example of a R script that can be run on
# interview output files, to generate common analysis results from basic common
# fields
#
# It can be copied and adapted to each specific analysis need
#
# Inputs:
# * dataset_name: Name of the dataset, for reference
# * folder: Absolute path to the folder containing the data files. The outputs
#   will also be saved in this folder.
# * interview_file: Name of the interview data file (CSV) in the folder. This
#   file can be downloaded from the admin interface
# * logFile: Name of the log file (CSV) in the folder. This file is obtained
#   with the command: `yarn node
#   packages/evolution-backend/lib/tasks/exportInterviewLogs.task.js
#   [--participantResponseOnly]`
#
# If logFile is not set or the file does not exist, the analysis will be run
# without log data.  The log file is needed to extract interview durations,
# pauses, and other paradata.  When first running the analysis, if the log file
# is set and exists, the interview durations will be extracted from the logs and
# saved to a file named "interviewDurations.csv" in the same folder.  If the
# "interviewDurations.csv" file already exists, it will be used directly instead
# of extracting durations from logs again.
#
# Outputs:
# * interviewDurations.csv: CSV file with the interview durations for each
#   interview
# * output_interview_durations.txt: Text file with the output of the duration
#   extraction process

library(here)

# Source the custom function from the library
script_dir <- here("scripts/rAnalyses")
source(file.path(script_dir, "library/interviewParadataAnalysis.library.R"))

# List of datasets and folders on which to run the analysis
datasets <- list(
  list(
    # Name of the dataset, for reference
    dataset_name = "TestNationaleLatest",
    # Absolute path to the folder containing the data files. The outputs will also be saved in this folder.
    folder = "/absolute/path/to/folder/with/data/",
    # Name of the interview data file (CSV) in the folder. This file can be downloaded from the admin interface
    interview_file = "corrected_interview_data.csv",
    # Name of the log file (CSV) in the folder. This file is obtained with the command: `yarn node packages/evolution-backend/lib/tasks/exportInterviewLogs.task.js [--participantResponseOnly]`
    logFile = "interviewLogs.csv"
  )
)


# Loop through each dataset and run the analysis
for (dataset in datasets) {

    # Extract dataset details
    folder <- dataset$folder
    interview_file <- dataset$interview_file

    interview_file_name <- file.path(folder, interview_file)
    log_file_name <- file.path(folder, dataset$logFile)
    duration_file_name <- file.path(folder, "interviewDurations.csv")

    # Load the interview data
    interview_data <- read.csv(log_file_name)

    # Get the interview durations from logs, if the log file is set and exists
    # Initialize interview_durations as NULL
    interview_durations <- NULL

    # If the duration file does not exist, try to extract the durations from log files
    if (!file.exists(duration_file_name) && dataset$logFile != "" && file.exists(log_file_name)) {
        # Get interview durations and save to CSV, with output to a text file
        sink(file.path(folder, "output_interview_durations.txt"))
        tryCatch({
            interview_durations <- get_interview_durations(log_file_name)
            write.csv(interview_durations, file=paste(duration_file_name, sep = ','), row.names = FALSE)
        }, error = function(e) {
            message("Error extracting interview durations: ", e$message)
        }, finally = {
            print("Finished attempting to extract interview durations")
            sink()
        })
    } else if (file.exists(duration_file_name)) {
        # Load existing durations
        interview_durations <- read.csv(duration_file_name)
    } else {
        print('Log file not found or not specified, skipping duration extraction.')
    }

    # Merge the interview data with durations

    # Calculate stats on the interview data: completed, valid, durations, etc.

    # Calculate stats on the devices used

    # Calculate stats on the respondent burden perception, with the optional questions at the end

    # Calculate stats on the logs: pauses, responses that were modified, question where respondents abandon, etc
    
}