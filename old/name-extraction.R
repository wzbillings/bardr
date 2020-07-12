###
# Work title extraction and meta-data lookup table generation
# @author Zane Billings
# @updated 2020-07-12
###

# Load packages
library(stringr)
library(stringi)
library(magrittr)

# Extract the list of works from the complete raw text file.
# This will give the "complete"/"long" names for the plays that are
#  used to label each of the works in the collection.
works <- readLines("data/raw-text.txt", n = 130) %>%
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

work_info <- data.frame(work = works, short_name, genre = genres)
saveRDS(work_info, "data/work-info.RDS")
