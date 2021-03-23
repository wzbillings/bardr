###
# Data cleaning for bardr package
# @author Zane Billings
###

# Import libraries
## For wrangling
library(readr)
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

# Download raw text from project gutenberg, skipping the intro.
raw_text <- read_lines("https://www.gutenberg.org/files/100/100-0.txt")
# Get starting and ending lines of the work and remove PG header and footer.
text_start <- str_which(raw_text, "THE SONNETS")[2] # Use 2 to skip contents
text_end <- str_which(raw_text, "FINIS")
work_text <- raw_text[text_start:text_end]
# Remove any NA lines and blank lines.
work_text <- work_text[!is.na(work_text)]
work_text <- work_text[work_text != ""]


# List of works copied from the contents. Better to hard code this
# as the list of works does not change but the lines where the ToC appears has.
# This will give the "complete"/"long" names for the plays that are
#  used to label each of the works in the collection.
work_names <- read_lines(here::here("data-raw", "long-names.txt"))

# Manually add the "short"/"common" names for the works.
# Referenced these from http://shakespeare.mit.edu/.
# Added in same order as works were listed in the complete text.
# These are in correct title case so they can be easily used as labels.
short_names <- read_lines(here::here("data-raw", "short-names.txt"))

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
work_info <- data.frame(work = work_names, short_names, genre = genres)

# Here I manually add more work names, since part of the play titles
# in the actual ebook are inconsistent with the table of contents.
# Pretty sure there is no other way to fix this other than writing
# a more general regex later, which is more work than this.
inconsistent_titles <- c("ANTONY AND CLEOPATRA",
                         "THE LIFE OF KING HENRY V",
                         "MACBETH",
                         " MUCH ADO ABOUT NOTHING",
                         "OTHELLO, THE MOOR OF VENICE",
                         "TWELFTH NIGHT: OR, WHAT YOU WILL",
                         "THE TWO NOBLE KINSMEN:",
                         " VENUS AND ADONIS")

# The list of allowed titles will be these inconsistent titles, plus the
# actual titles as specified in the table of contents.
# Unfortunately there is not a good regex solution to this.
# The best solution would be for PG to make all of the tiles consistent but until
# that happens this has to be checked every update.
allowed_titles <- c(inconsistent_titles, str_to_upper(work_names))
works_pattern <- START %R% or1(allowed_titles) %R% END
split_indices <- str_which(work_text, pattern = works_pattern)

# Venus and Adonis is titled twice. Since Venus and Adonis is the last work,
# this is easily fixed by overwriting the last index with the end index.
split_indices[length(split_indices)] <- str_which(work_text, "FINIS")

# Convert to ASCII for CRAN standards
# Have to do this here so ASCII doesn't mess up REGEX stuff.
work_text <- stringi::stri_enc_toascii(work_text)

# Make each work a character vector, and put these all into a named list.
works_list <- vector("list", length(split_indices) - 1)
names(works_list) <- work_info$short_name
for (i in 1:(length(split_indices) - 1)) {
  sec_start <- split_indices[i]
  sec_end <- split_indices[i + 1] - 1 # -1 to prevent next title inclusion
  works_list[[i]] <- work_text[sec_start:sec_end]
}

# Export list of works
all_works_list <- works_list
usethis::use_data(all_works_list, overwrite = TRUE)

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
  inner_join(work_info, by = c("name" = "short_names"))
colnames(works_tidy) <- c("name", "content", "full_name", "genre")

all_works_df <- works_tidy

# Export df
usethis::use_data(all_works_df, overwrite = TRUE)
