###
# Export each work as a vector
# @author Zane Billings
# @updated 2020-07-12
###

library(snakecase) # To convert names to snake case
library(tm) # to remove punctuation from names
library(here) # for correct paths

works <- readRDS(here::here("data", "works_list.RDS"))
names <- snakecase::to_snake_case(tm::removePunctuation(names(works)))
file_names <- paste("data/", names, ".RDS", sep = "")

for (i in 1:length(works)) {
  obj_path <- here::here(file_names[i])
  saveRDS(object = works[[i]], file = obj_path)
}
