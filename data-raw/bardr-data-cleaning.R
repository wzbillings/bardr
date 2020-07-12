###
# Data cleaning for bardr package
# @author Zane Billings
###

# Import libraries
## For wrangling
library(dplyr)
library(here)
library(magrittr)
## For string manipulation
library(stringr)
library(stringi)
library(rebus)
library(snakecase)
library(tm)
## For package stuff
library(usethis)

# Import the raw text
raw_text <- readLines(here::here("data-raw", "raw-text.txt"))
raw_text <- stringi::stri_enc_toascii(raw_text)
# Extract the list of works from the complete raw text file.
# This will give the "complete"/"long" names for the plays that are
#  used to label each of the works in the collection.
work_names <- raw_text %>%
  extract(43:129) %>%
  stri_remove_empty() %>%
  str_trim()

# Manually add the "short"/"common" names for the works.
# Referenced these from http://shakespeare.mit.edu/.
# Added in same order as works were listed in the complete text.
# These are in correct title case so they can be easily used as labels.
short_name <- c("Sonnets",
                "All's Well that Ends Well",
                "Antony and Cleopatra",
                "As You Like It",
                "The Comedy of Errors",
                "Coriolanus",
                "Cymbeline",
                "Hamlet",
                "Henry IV, part 1",
                "Henry IV, part 2",
                "Henry V",
                "Henry VI, part 1",
                "Henry VI, part 2",
                "Henry VI, part 3",
                "Henry VIII",
                "King John",
                "Julius Caesar",
                "King Lear",
                "Love's Labour's Lost",
                "Macbeth",
                "Measure for Measure",
                "The Merchant of Venice",
                "The Merry Wives of Windsor",
                "A Midsummer Night's Dream",
                "Much Ado About Nothing",
                "Othello",
                "Pericles, Prince of Tyre",
                "Richard II",
                "Richard III",
                "Romeo and Juliet",
                "Taming of the Shrew",
                "The Tempest",
                "Timon of Athens",
                "Titus Andronicus",
                "Troilus and Cressida",
                "Twelfth Night",
                "Two Gentlemen of Verona",
                "The Two Noble Kinsmen",
                "Winter's Tale",
                "A Lover's Complaint",
                "The Passionate Pilgrim",
                "The Phoenix and the Turtle",
                "The Rape of Lucrece",
                "Venus and Adonis")

# Manually specify the genre for each work.
# Referenced these from
# Added in same order as works were listed in the complete text.
genres <- c("P", "C", "T", "C", "C", "T", "C", "T", "H", "H", "H", "H", "H",
            "H", "H", "H", "T", "T", "C", "T", "C", "C", "C", "C", "C", "T",
            "C", "H", "H", "T", "C", "C", "T", "T", "C", "C", "C", "O", "C",
            "P", "O", "P", "P", "P")
for (i in 1:length(genres)) {
  if (genres[i] == "P") {
    genres[i] <- "Poetry"
  } else if (genres[i] == "C") {
    genres[i] <- "Comedy"
  } else if (genres[i] == "T") {
    genres[i] <- "Tragedy"
  } else if (genres[i] == "H") {
    genres[i] <- "History"
  } else {
    genres[i] <- "Other"
  }
}

# Dataframe of metadata for works
work_info <- data.frame(work = work_names, short_name, genre = genres)

# Get starting and ending line numbers
text_start <- str_which(raw_text, "THE SONNETS")[2] # Use 2 to skip contents
text_end <- str_which(raw_text, "FINIS")

# Save intro and closing, just in case.
intro <- raw_text[1:text_start - 1]
outro <- raw_text[text_end:length(raw_text)]

# Export intro and outra
usethis::use_data(intro, outro, overwrite = TRUE)

# Remove beginning of doc (list of works/project gutenberg info)
text_trimmed <- raw_text[text_start:text_end - 1]

# Here I manually add more work names, since part of the play titles
# in the actual ebook are inconsistent with the table of contents.
# Pretty sure there is no other way to fix this other than writing
# a more general regex later, which is more work than this.
inconsistent_titles <- c("THE LIFE OF KING HENRY V",
                         "MACBETH",
                         " MUCH ADO ABOUT NOTHING",
                         "OTHELLO, THE MOOR OF VENICE",
                         "TWELFTH NIGHT: OR, WHAT YOU WILL",
                         "THE TWO NOBLE KINSMEN:",
                         " VENUS AND ADONIS")

# The list of allowed titles will be these inconsistent titles, plus the
# actual titles as specified in the table of contents.
# Regex works by finding any of these allowed titles on a line by itself.
# This prevents issues with Cymbeline and King John appearing many times.
allowed_titles <- c(inconsistent_titles, work_info$work)
works_pattern <- START %R% or1(allowed_titles) %R% END
split_indices <- str_which(text_trimmed, pattern = works_pattern)

# Venus and Adonis is titled twice. Since Venus and Adonis is the last work,
# this is easily fixed by overwriting the last index with the end index.
split_indices[nrow(work_info) + 1] <- length(text_trimmed)

# Make each work a character vector, and put these all into a named list.
works_list <- vector("list", length(split_indices) - 1)
names(works_list) <- work_info$short_name
for (i in 1:(length(split_indices) - 1)) {
  sec_start <- split_indices[i]
  sec_end <- split_indices[i + 1] - 1
  works_list[[i]] <- text_trimmed[sec_start:sec_end]
}

# Export list of works
all_works_list <- works_list
usethis::use_data(all_works_list, overwrite = TRUE)

# Extract each work as its own datafile
names <- works_list %>%
  names() %>%
  tm::removePunctuation() %>%
  snakecase::to_snake_case()

# Removes each work (as a char vector) from the list and exports.
for (i in 1:length(works_list)) {
  this <- assign(names[[i]], works_list[[i]])
  do.call("use_data", list(as.name(names[[i]]), overwrite = TRUE))
}

# Intialize blank list for df's
work_dfs <- vector("list", length(works_list))

# Create one tidy dataframe of all works
for (i in 1:length(works_list)) {
  work <- works_list[[i]]
  name <- rep(names(works_list)[[i]], length(work))
  work_dfs[[i]] <- data.frame(name, work)
}

# Combine all created df's in the list into one tidy df
works_combined <- do.call(rbind, work_dfs)

# Join df with values from metadeta LUT and fix names
works_tidy <- do.call(rbind, work_dfs) %>%
  inner_join(work_info, by = c("name" = "short_name"))
colnames(works_tidy) <- c("name", "content", "full_name", "genre")

all_works_df <- works_tidy

# Export df
usethis::use_data(all_works_df, overwrite = TRUE)
