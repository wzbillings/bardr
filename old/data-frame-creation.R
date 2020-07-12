###
# Export a dataframe of works
# @author Zane Billings
# @updated 2020-07-12
###

library(here)
library(dplyr) # Used for joins

works <- readRDS(here::here("data", "works_list.RDS"))
work_info <- readRDS(here::here("data", "work-info.RDS"))
work_dfs <- vector("list", length(works))

for (i in 1:length(works)) {
  work <- works[[i]]
  name <- rep(names(works)[[i]], length(work))
  work_dfs[[i]] <- data.frame(name, work)
}

works_combined <- do.call(rbind, work_dfs)
works_clean <- do.call(rbind, work_dfs) %>%
  inner_join(work_info, by = c("name" = "short_name"))
colnames(works_clean) <- c("name", "content", "full_name", "genre")

saveRDS(works_clean, here::here("data", "works-df.RDS"))
