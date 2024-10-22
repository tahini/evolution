# Import libraries
library(dplyr) # A Grammar of Data Manipulation
library(ggplot2) # Create Elegant Data Visualisations Using the Grammar of Graphics
library(tidyr) # Tidy Messy Dat
library(stringr)
library(here)

#' Get a dataset with the interview durations for each interview from the
#' paradata logs
#'
#' @param log_file_name The absolute path to the file containing the paradata
#' logs. It should be a CSV file, obtained with the command: `yarn node
#' packages/evolution-backend/lib/tasks/exportinterview_logs.task.js
#' [--participantResponseOnly]`
#' @return A data frame with the interview durations for each interview.
get_interview_durations <- function(log_file_name) {
  
  cat("Getting interview durations for file", log_file_name, "\n")

  # Load the data
  interview_logs <- read.csv(log_file_name)

  # Source the file corresponding to the version of logs
  script_dir <- here("scripts/rAnalyses/library")
  if (!("widgetPath" %in% colnames(interview_logs)) || 
        ("event_type" %in% colnames(interview_logs) && 
         any(grepl("^legacy", interview_logs$event_type)))) {
    # legacy log if not widgetPath field, or if event_type field exists and has "legacy" values
    cat("Using legacy paradata logs library\n")
    source(file.path(script_dir, "paradata/interviewLegacyParadataLogs.library.R"))
  } else {
    cat("Using current paradata logs library\n")
    source(file.path(script_dir, "paradata/interviewParadataLogs.library.R"))
  }

  duration_data <- get_interview_durations_and_response_stats(interview_logs)

  return(duration_data)

}
