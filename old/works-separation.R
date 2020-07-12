###
# Separation of complete works into individual works
# @author Zane Billings
# @updated 2020-07-11
###

# Import packages; and works info data.
library(stringr)
library(rebus)
work_info <- readRDS("data/work-info.RDS")

# Read in complete text
text_file <- here::here("data", "raw-text.txt")
full_text <- readLines(text_file)
text_start <- str_which(full_text, "THE SONNETS")[2] # Use 2 to skip contents
text_end <- str_which(full_text, "FINIS")

# Save intro and closing, just in case.
text_intro <- full_text[1:text_start - 1]
text_outro <- full_text[text_end:length(full_text)]

# Remove beginning of doc (list of works/project gutenberg info)
text_trimmed <- full_text[text_start:text_end - 1]

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

# Export the list to data.
saveRDS(works_list, "data/works_list.RDS")
