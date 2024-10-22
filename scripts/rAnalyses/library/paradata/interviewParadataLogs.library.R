# This file contains functions to analyze interview paradata logs
# obtained from Evolution surveys.

replace_uuids <- function(interview_logs, field_name="modifiedFields") {
  # First replace any UUIDs in modifiedFields with "any", so fields can be grouped by name later
  # Define the regex pattern for UUIDs
  uuid_pattern <- "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}"
  # Define the replacement string
  replacement <- "any"
  # Perform the replacement
  interview_logs[[field_name]] <- str_replace_all(interview_logs[[field_name]], uuid_pattern, replacement)
  return(interview_logs)
}

# Return the longest pause between two actions in each interview. It returns the timetsamp_diff (in seconds) and the field answered after the pause (max_pause_field)
get_longest_pause_by_interview <- function(participant_responses) {
  # Calculate the timestamps differences with the previous line
  times_to_answer <- participant_responses %>%
    filter(event_type == "widget_interaction" | event_type == "section_change" | event_type == "button_click") %>%
    rowwise() %>%
    group_by(id) %>%
    arrange(id, timestamp) %>%
    mutate(timestamp_diff = timestamp - lag(timestamp)) %>%
    ungroup() %>%
    filter(!is.na(timestamp_diff))
    
  # Keep only one row per interview with the maximum timestamp_diff value
  max_pause_in_interview <- times_to_answer %>%
    group_by(uuid) %>%
    slice_max(order_by = timestamp_diff, n = 1, with_ties = FALSE) %>%
    ungroup() %>%
    select(id, max_pause_duration_seconds = timestamp_diff, max_pause_event = event_type, max_pause_field = widgetPath)

  return(max_pause_in_interview)
}

get_last_answer <- function (participant_responses) {
  last_answer <- participant_responses %>%
    filter(event_type == "widget_interaction") %>%
    rowwise() %>%
    group_by(id) %>%
    slice_max(order_by = timestamp, n = 1) %>%
    ungroup() %>%
    select(id, last_response_timestamp = timestamp, last_response_event = event_type, last_response_field = widgetPath)

  return(last_answer)
}

get_last_user_action <- function (participant_responses) {
  last_user_action <- participant_responses %>%
    filter(event_type == "widget_interaction" | event_type == "section_change" | event_type == "button_click") %>%
    rowwise() %>%
    group_by(id) %>%
    slice_max(order_by = timestamp, n = 1) %>%
    ungroup() %>%
    select(id, last_user_action_timestamp = timestamp, last_user_action_event = event_type, last_user_action_field = widgetPath)

  return(last_user_action)
}

get_last_section <- function (participant_responses) {
  last_sections <- participant_responses %>%
    filter(event_type == "section_change") %>%
    group_by(id) %>%
    slice_max(order_by = timestamp, n = 1) %>%
    ungroup() %>%
    select(id, last_section_timestamp = timestamp, last_section_name = widgetPath)

  return(last_sections)
}

#' Get a dataset with the interview durations for each interview from the
#' paradata logs
#'
#' @param log_file_name The absolute path to the file containing the paradata
#' logs. It should be a CSV file, obtained with the command: `yarn node
#' packages/evolution-backend/lib/tasks/exportinterview_logs.task.js
#' [--participantResponseOnly]`
#' @return A data frame with the interview durations for each interview.
get_interview_durations_and_response_stats <- function(interview_logs) {

  # Remove non participant data, ie keep only rows with a field with "response." (also support "responses." for previous versions of Evolution)
  participant_response_only <- interview_logs %>%
    rowwise() %>%
    mutate(
            response_fields = str_split(modifiedFields, "\\|") %>% 
                    unlist() %>% 
                    .[str_detect(., "^response\\.")] %>% 
                    paste(collapse = "|"),
            unset_fields = str_split(unsetFields, "\\|") %>% 
                    unlist() %>% 
                    .[str_detect(., "^response\\.")] %>% 
                    paste(collapse = "|"),
            widget_fields = if_else(
                str_detect(widgetPath, "^response\\.") | event_type == "section_change" | event_type == "button_click",
                widgetPath,
                ""
            ),
            timestamp = timestampMs / 1000
    ) %>%
    filter(!(response_fields == "" & unset_fields == "" & widget_fields == "")) %>%
    mutate(modifiedFields = response_fields, unsetPaths = unset_fields, widgetPath = widget_fields) %>%
    select(-response_fields, -unset_fields, -widget_fields, -timestampMs)

    # Print row counts before and after filtering
    cat("Number of rows before filtering:", nrow(interview_logs), "\n")
    cat("Number of rows after filtering for participant responses only:", nrow(participant_response_only), "\n")

  # Replace UUIDs in field names with "any"
  participant_response_only <- replace_uuids(participant_response_only, "widgetPath")

  # Calculate the interview duration as the difference between max timestamp and
  # min timestamp of an interview
  interview_durations <- participant_response_only %>%
    group_by(id, uuid) %>%
    summarise(
      durationSeconds = max(timestamp) - min(timestamp),
     .groups = 'drop'
    ) %>%
    select(id, uuid, durationSeconds)

  cat("Calculated interview durations for", nrow(interview_durations), "interviews.\n")
  max_pause_in_interview <- get_longest_pause_by_interview(participant_response_only)
  cat("Calculated maximum pause between actions for", nrow(max_pause_in_interview), "interviews.\n")
  last_section_records <- get_last_section(participant_response_only)
  cat("Calculated last section records for", nrow(last_section_records), "interviews.\n")
  last_response_records <- get_last_answer(participant_response_only)
  cat("Calculated last response records for", nrow(last_response_records), "interviews.\n")

  last_user_action_records <- get_last_user_action(participant_response_only)
  cat("Calculated last user action records for", nrow(last_user_action_records), "interviews.\n")
  # Merge interviewDurations and maxDiffPerInterview on the uuid field
  merged_data <- merge(interview_durations, max_pause_in_interview, by = "id")

  merged_data <- merge(merged_data, last_section_records, by = "id")

  merged_data <- merge(merged_data, last_response_records, by = "id")

  merged_data <- merge(merged_data, last_user_action_records, by = "id")

  return(merged_data)

}
