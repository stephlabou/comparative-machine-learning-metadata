###########################################################
######### Figure 1 - ML objects by year and repo ##########
###########################################################

library(tidyverse)
library(RColorBrewer)

#get working directory, for full path
filedir <- getwd()

#get data folder full path
datapath = paste(filedir,"/", "repository_dates/", sep ="")

#get fall names of csv files in folder
file_names <- list.files(path = datapath, pattern = '*pub_years.csv')
file_names_full <- paste(datapath, file_names, sep = "")

#read each csv into a dataframe in list
csvs <- lapply(file_names_full, read.csv)

#collapse into single dataframe
df <- do.call(rbind, csvs)

#organize - remove first column and arrange
df <- df %>% 
  select(repo, year, count) %>% 
  arrange(repo, year, count) %>% 
  #add indicator for specialist vs generalist
  mutate(`Repository Type` = ifelse(repo %in% c("openml", "uci", "kaggle"), "Specialist", "Generalist"))

#set levels for repo
df$repo <- factor(df$repo, 
                  levels = c("dryad", "ucsd", "dataverse_datasets", 
                             "figshare_full", "figshare_subset",
                             "zenodo_full", "zenodo_subset",
                             "openml", "uci", "kaggle"))

#remove figshare and zenodo full dates (keep only subsets as specified in paper)
timeline_subset <- df %>% 
  filter(!(repo %in% c('figshare_full', 'zenodo_full'))) %>% 
  filter(year >= 2000 & year < 2022)

#write to csv
write.csv(timeline_subset, "Figure1_data.csv", row.names = FALSE)

#set color palette
cols_plot = unname(palette.colors(palette = "Okabe-Ito"))

#for subsets
figure1 <- timeline_subset %>% 
  ggplot(aes(x = year, y = count, color = repo, linetype = repo)) +
  #color by repo and change line type to be by repo type
  geom_line(size = 1) +
  #manually adjust so color and linetype are in one legend
  scale_linetype_manual(values = c(rep("solid", 5), rep("solid", 3)),
                        labels = c("Dryad", 
                                   "UC San Diego Library",
                                   "Harvard Dataverse",
                                   "Figshare",
                                   "Zenodo",
                                   "OpenML",
                                   "UCI Machine Learning Repository",
                                   "Kaggle"),
                        name = "Repository") +
  scale_color_manual(values = c(cols_plot[1], cols_plot[9],
                                cols_plot[3], cols_plot[4],
                                cols_plot[5], cols_plot[6],
                                cols_plot[7], cols_plot[8]),
                     labels = c("Dryad", 
                                "UC San Diego Library",
                                "Harvard Dataverse",
                                "Figshare",
                                "Zenodo",
                                "OpenML",
                                "UCI Machine Learning Repository",
                                "Kaggle"),
                     name = "Repository") +
  #limit x axis to start in 2000
  xlim(2000, 2021) +
  scale_y_log10() +
  xlab("Year") +
  ylab("New 'machine learning' objects \n (log10 scale)") +
  theme_bw()

figure1

ggsave("Figure1.jpeg", figure1, width = 7, height = 4, units = "in", dpi = 1200)

