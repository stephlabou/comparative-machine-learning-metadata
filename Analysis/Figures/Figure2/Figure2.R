library(tidyverse)
library(RColorBrewer)
library(stringr)

##################################################################
############ Read in and combine repo file extensions ############
############### (as determined in repo notebooks) ################
##################################################################

#get working directory, for full path
filedir <- getwd()

#get data folder full path
datapath = paste(filedir,"/", "file_ext_data/", sep ="")

#get fall names of csv files in folder
file_names <- list.files(path = datapath, pattern = '*extensions.csv')
file_names_full <- paste(datapath, file_names, sep = "")

#read each csv into a dataframe in list
csvs <- lapply(file_names_full, read.csv)

#collapse into single dataframe
df <- do.call(rbind, csvs)

#add repo total object counts as column
#from Table 3 in paper
df <- df %>% 
  mutate(repo_total = NA,
         repo_total = ifelse(repo == "dryad", 219, repo_total),
         repo_total = ifelse(repo == "ucsd", 25, repo_total),
         repo_total = ifelse(repo == "dataverse_datasets", 269, repo_total),
         repo_total = ifelse(repo == "figshare_subset", 10347, repo_total),
         repo_total = ifelse(repo == "zenodo_subset", 2217, repo_total),
         repo_total = ifelse(repo == "uci", 583, repo_total))

df %>% select(repo, index) %>% unique() %>% group_by(repo) %>% count()
# 1 dataverse_datasets   269
# 2 dryad                218
# 3 figshare_subset    10347
# 4 uci                  583
# 5 ucsd                  25
# 6 zenodo_subset       2217

#see Dryad notebook (Analysis/src/Repository_calculations/Dryad.ipynb) 
#for why this is 1 less than expected 219 objects
#(single object with only None listed in file field)

#here, 'index' is unique object ID, unique *within each repo*
#clarify this in new 'id' column and get rid of 'X' column
df <- df %>% 
  select(-X) %>% 
  mutate(id = paste(repo, index, sep = "_")) %>% 
  #add indicator for specialist vs generalist
  mutate(`Repository Type` = ifelse(repo %in% c("uci"), "Specialist", "Generalist"))

#set levels for repo
df$repo <- factor(df$repo, 
                  levels = c("dryad", 
                             "ucsd",
                             "dataverse_datasets",
                             "figshare_subset",
                             "zenodo_subset",
                             "uci"))

##################################################################
############# Clean and standardize file extensions ##############
##################################################################

#clean up file extensions based on manual assessment
#includes files with multiple extensions or multiple . separators

df_clean <- df %>%
  #make new column 'clean_ext' and clean leading . and make lower case
  mutate(clean_ext = gsub('^\\.', '', files),
         clean_ext = tolower(clean_ext)) %>% 
  #if ends with .txt, make plain .txt
  mutate(clean_ext = ifelse(grepl("txt$", clean_ext, ignore.case = TRUE), "txt", clean_ext),
         #if ends with .tif or .tiff, make .tif
         clean_ext = ifelse(grepl("tif$", clean_ext, ignore.case = TRUE), "tif", clean_ext),
         clean_ext = ifelse(grepl("tiff$", clean_ext, ignore.case = TRUE), "tif", clean_ext),
         #if ends with .gif, make .gif
         clean_ext = ifelse(grepl("gif$", clean_ext, ignore.case = TRUE), "gif", clean_ext),
         #if ends with .tar, make .tar
         clean_ext = ifelse(grepl("\\.tar$|^tar$", clean_ext, ignore.case = TRUE), "tar", clean_ext),
         #clean up various zip formats
         clean_ext = ifelse(grepl("^gz$|\\.gz$|gz$", clean_ext, ignore.case = TRUE), "gz", clean_ext),
         clean_ext = ifelse(grepl("\\.tbz$", clean_ext, ignore.case = TRUE), "tbz", clean_ext),
         clean_ext = ifelse(grepl("xz$", clean_ext, ignore.case = TRUE), "xz", clean_ext),
         clean_ext = ifelse(grepl("zip$", clean_ext, ignore.case = TRUE), "zip", clean_ext),
         clean_ext = ifelse(grepl("7z", clean_ext, ignore.case = TRUE), "7z", clean_ext),
         clean_ext = ifelse(grepl("bz2$", clean_ext, ignore.case = TRUE), "bz", clean_ext),
         clean_ext = ifelse(grepl("^Z$", clean_ext, ignore.case = TRUE), "zip", clean_ext),
         clean_ext = ifelse(grepl("\\.z$", clean_ext, ignore.case = TRUE), "zip", clean_ext),
         #consider npz as zipped
         clean_ext = ifelse(grepl("npz$", clean_ext, ignore.case = TRUE), "zip", clean_ext),
         #if ends with .rar, make .rar
         clean_ext = ifelse(grepl("rar$", clean_ext, ignore.case = TRUE), "rar", clean_ext),
         #if ends with .bmp, make .bmp
         clean_ext = ifelse(grepl("bmp$", clean_ext, ignore.case = TRUE), "bmp", clean_ext),
         #if ends with .tab, make .tab
         clean_ext = ifelse(grepl("tab$", clean_ext, ignore.case = TRUE), "tab", clean_ext),
         #if ends with .csv, make .csv
         clean_ext = ifelse(grepl("csv$", clean_ext, ignore.case = TRUE), "csv", clean_ext),
         #if ends with .pdf, make .pdf
         clean_ext = ifelse(grepl("pdf$", clean_ext, ignore.case = TRUE), "pdf", clean_ext),
         #if ends with .xlsx or .xls, make ".xlsx/.xls"
         clean_ext = ifelse(grepl("xlsx", clean_ext, ignore.case = TRUE), "excel file", clean_ext),
         clean_ext = ifelse(grepl("xls$", clean_ext, ignore.case = TRUE), "excel file", clean_ext),
         #excel file open xml or excel binary file format
         clean_ext = ifelse(grepl("xlsm$ | xlsb$", clean_ext, ignore.case = TRUE), "excel file", clean_ext),
         #if ends with .docx or .doc, make 'word doc'
         clean_ext = ifelse(grepl("docx$", clean_ext, ignore.case = TRUE), "word file", clean_ext),
         clean_ext = ifelse(grepl("doc$", clean_ext, ignore.case = TRUE), "word file", clean_ext),
         #if ends with .pptx, make 'power point'
         clean_ext = ifelse(grepl("pptx$", clean_ext, ignore.case = TRUE), "power point", clean_ext),
         #if ends with .mp4, make .mp4
         clean_ext = ifelse(grepl("mp4$", clean_ext, ignore.case = TRUE), "mp4", clean_ext),
         #if ends with .png, make .png
         clean_ext = ifelse(grepl("png$", clean_ext, ignore.case = TRUE), "png", clean_ext),
         #if ends with .jpeg or .jpg, make .peg
         clean_ext = ifelse(grepl("jpeg$|jpg", clean_ext, ignore.case = TRUE), "jpeg", clean_ext),
         #if ends with .eps, make .eps
         clean_ext = ifelse(grepl("\\.eps$|^eps$", clean_ext, ignore.case = TRUE), "eps", clean_ext),
         #if ends with .ai, make .ai
         clean_ext = ifelse(grepl("^ai$|\\.ai$", clean_ext, ignore.case = TRUE), "ai", clean_ext),
         #if ends with .sql, make sql
         clean_ext = ifelse(grepl("^sql$|\\.sql$", clean_ext, ignore.case = TRUE), "sql", clean_ext),
         #if ends with .R or .Rdata or R markdown or rds or rd or rda, make R
         clean_ext = ifelse(grepl("^R$|\\.R$", clean_ext, ignore.case = TRUE), "R", clean_ext),
         clean_ext = ifelse(grepl("^r$|\\.r$", clean_ext, ignore.case = TRUE), "R", clean_ext), #need to update to grab single r
         clean_ext = ifelse(grepl("rdata$", clean_ext, ignore.case = TRUE), "R", clean_ext),
         clean_ext = ifelse(grepl("rmd$", clean_ext, ignore.case = TRUE), "R", clean_ext),
         clean_ext = ifelse(grepl("rds$", clean_ext, ignore.case = TRUE), "R", clean_ext),
         clean_ext = ifelse(grepl("^rd$", clean_ext, ignore.case = TRUE), "R", clean_ext),
         clean_ext = ifelse(grepl("^rda$", clean_ext, ignore.case = TRUE), "R", clean_ext),
         clean_ext = ifelse(grepl("rproj$", clean_ext, ignore.case = TRUE), "R", clean_ext),
         clean_ext = ifelse(grepl("^rhistory$", clean_ext, ignore.case = TRUE), "R", clean_ext),
         #if ends with .py or .pickle or .ipynb or .pkl or .pyc, make python
         clean_ext = ifelse(grepl("^py$|\\.py$", clean_ext, ignore.case = TRUE), "python", clean_ext),
         clean_ext = ifelse(grepl("pickle$", clean_ext, ignore.case = TRUE), "python", clean_ext),
         clean_ext = ifelse(grepl("ipynb$", clean_ext, ignore.case = TRUE), "python", clean_ext),
         clean_ext = ifelse(grepl("pkl$", clean_ext, ignore.case = TRUE), "python", clean_ext),
         clean_ext = ifelse(grepl("pyc$", clean_ext, ignore.case = TRUE), "python", clean_ext),
         #special case of numpy files alone being treated as data
         clean_ext = ifelse(grepl("npy$", clean_ext, ignore.case = TRUE), "npy", clean_ext),
         #if ends with .bash, make bash
         clean_ext = ifelse(grepl("bash$", clean_ext, ignore.case = TRUE), "bash", clean_ext),
         #if ends with .mat, make .mat
         clean_ext = ifelse(grepl('^mat$|\\.mat$', clean_ext, ignore.case = TRUE), "mat", clean_ext),
         #if ends with .jmp, make .jmp
         clean_ext = ifelse(grepl('jmp$', clean_ext, ignore.case = TRUE), "jmp", clean_ext),
         #if ends with .arff, make .arff
         clean_ext = ifelse(grepl("arff$", clean_ext, ignore.case = TRUE), "arff", clean_ext),
         #if ends with .fasta, make .fasta
         clean_ext = ifelse(grepl("\\.fasta$", clean_ext, ignore.case = TRUE), "fasta", clean_ext),
         #if a TREE file (bioinformatics), make tree
         clean_ext = ifelse(grepl("\\trees$|treefile$", clean_ext, ignore.case = TRUE), "tree", clean_ext),
         #if a bed file (bioinformatics), make bed
         clean_ext = ifelse(grepl("\\.bed$|^bed$", clean_ext, ignore.case = TRUE), "bed", clean_ext),
         #if ends with .tsv, make .tsv
         clean_ext = ifelse(grepl("tsv$", clean_ext, ignore.case = TRUE), "tsv", clean_ext),
         #if ends with .mov, make .mov
         clean_ext = ifelse(grepl("^mov$|\\.mov$", clean_ext, ignore.case = TRUE), "mov", clean_ext),
         #make htm and html html
         clean_ext = ifelse(grepl("html$", clean_ext, ignore.case = TRUE), "html", clean_ext),
         clean_ext = ifelse(grepl("htm$", clean_ext, ignore.case = TRUE), "html", clean_ext),
         #if any of the main geodata formats, make 'GIS'
         clean_ext = ifelse(grepl("\\.shp$|shp$", clean_ext, ignore.case = TRUE), "GIS", clean_ext),
         clean_ext = ifelse(grepl("\\.shx$|shx$", clean_ext, ignore.case = TRUE), "GIS", clean_ext),
         clean_ext = ifelse(grepl("\\.kml$|kml$", clean_ext, ignore.case = TRUE), "GIS", clean_ext),
         clean_ext = ifelse(grepl("\\.sbn$|sbn$", clean_ext, ignore.case = TRUE), "GIS", clean_ext),
         clean_ext = ifelse(grepl("\\.sbx$|sbx$", clean_ext, ignore.case = TRUE), "GIS", clean_ext),
         clean_ext = ifelse(grepl("\\.sif$", clean_ext, ignore.case = TRUE), "GIS", clean_ext),
         clean_ext = ifelse(grepl("prj$", clean_ext, ignore.case = TRUE), "GIS", clean_ext),
         clean_ext = ifelse(grepl("\\.cpg$|cpg$", clean_ext, ignore.case = TRUE), "GIS", clean_ext),
         #if .text, make .text
         clean_ext = ifelse(grepl("\\.tex$", clean_ext, ignore.case = TRUE), "tex", clean_ext),
         #if ends in .xml, make .xml
         clean_ext = ifelse(grepl("xml$", clean_ext, ignore.case = TRUE), "xml", clean_ext),
         #if ends in .dat, dat, .data., or .dta, make 
         clean_ext = ifelse(grepl("\\.dat$|^dat$|\\.data$|\\.dta$", clean_ext, ignore.case = TRUE), "data", clean_ext),
         #if ends in .nc, make .nc
         clean_ext = ifelse(grepl("^nc$|\\.nc$", clean_ext, ignore.case = TRUE), "nc", clean_ext),
         #if ends in .h5, make .h5
         clean_ext = ifelse(grepl("^h5$|\\.h5$", clean_ext, ignore.case = TRUE), "h5", clean_ext),
         #if ends in .avi, make .avi
         clean_ext = ifelse(grepl("\\.avi$|avi$", clean_ext, ignore.case = TRUE), "avi", clean_ext),
         #if ends in .json, make .json
         clean_ext = ifelse(grepl("json$", clean_ext, ignore.case = TRUE), "json", clean_ext),
         #if ends in .rdf, make .rdf
         clean_ext = ifelse(grepl("rdf$", clean_ext, ignore.case = TRUE), "rdf", clean_ext),
         #ML specific formats (mostly UCI)
         clean_ext = ifelse(grepl("\\.names$", clean_ext, ignore.case = TRUE), "names", clean_ext),
         #there's a whole group remaining that's tar.gz.XX as well as a group that is tar.YYYY
         #as well as some that are zip.XXX
         clean_ext = ifelse(grepl("^tar.gz.[a-z]{2}$", clean_ext, ignore.case = FALSE), "gz", clean_ext),
         clean_ext = ifelse(grepl("^tar[0-9]{4}$", clean_ext, ignore.case = FALSE), "tar", clean_ext),
         clean_ext = ifelse(grepl("^zip.[0-9]{3}$", clean_ext, ignore.case = FALSE), "zip", clean_ext),
         #there are some clean_ext entries that are '', which causes problems later
         #these are from UCI having 'Parent Directory' and/or 'Index' being included in files list for objects.
         #Since these do not have a file extension, they are indicated by a blank file extension in this table.
         #make them "none" 
         clean_ext = ifelse(grepl("^$", clean_ext, ignore.case = FALSE), "none", clean_ext)) 

unique(df_clean$clean_ext)

##################################################################
########## Look into 'none' values - no file extensions ##########
##################################################################

# #there are a few 'none' values in 5 repositories
df_clean %>%
  filter(clean_ext == 'none') %>%
  group_by(repo) %>%
  summarize(count = n_distinct(id))

#side foray into confirming accuracy, and why there may be small mismatches to
#total count when summing up totals below (after removing 'none' values)

#example for Harvard Dataverse datasets
dataverse_nones <- df_clean %>%
  filter(clean_ext == 'none' & repo == 'dataverse_datasets')

df_clean %>%
  filter(id %in% dataverse_nones$id) %>%
  group_by(id) %>%
  summarize(count = n()) %>%
  arrange(count)

#there is one object that has only one file and that file has 'none' for cleaned file extension 
df_clean %>%
  filter(id == 'dataverse_datasets_70')

#  index files               repo                    id Repository Type clean_ext
#   1    70       dataverse_datasets dataverse_datasets_70      Generalist      none

#So while 269 objects were retrieved from Harvard Dataverse datasets
#file extension calculations based on 268 objects with file extension information

#remove 'none' values from df_clean, see how counts change
df_clean %>% 
  filter(clean_ext != 'none') %>% 
  group_by(repo) %>% 
  summarize(obj_count = n_distinct(id))

#count of objects with file extensions in each repo
# 1 dryad                    218
# 2 ucsd                      25
# 3 dataverse_datasets       268
# 4 figshare_subset        10286
# 5 zenodo_subset           2144
# 6 uci                      541

#note that Figure 2 reflects file extensions based on this subset of objects
#for which file extension information was possible to extract
#with proportion calculated with repository *total* objects as denominator

df_clean_use <- df_clean %>% 
  filter(clean_ext != 'none')

##################################################################
######### Crosswalk extensions to file format categories #########
##################################################################

#specify format categories
image_formats <- c('bmp', 'png', 'tif', 'jpeg', 'jpg', 'eps', 'ai', 'svg', 'ps', 'fig')
code_formats <- c('python', 'R', 'mat', 'sas', 'do', 'yaml', 'yml', 'sql', 'sqlite', 'jmp', 'sav', 'bash', 'pdb', 'sh', 'slurm', 'spv', 'pkb', 'lisp', 'nb', 'c', 'caffemodel', 'ckpt', 'csh', 'lstm', 'pt', 'pth')
basic_tabular_formats <- c('tsv', 'tab', 'csv', 'excel file')
domain_data_formats <- c('hdf5', 'h5py', 'fasta', 'fastq', 'data', 'GIS', 'nc', 'h5', 'train', 'test', 'parquet', 'tree', 'bed', 'dta', 'json', 'jsonl', 'npy', 'arff')
compressed_formats <- c('zip', 'xz', '7z', 'bz', 'gz', 'tbz', 'tar', 'rar', 'jar')
text_formats <- c('pdf', 'txt', 'word file', 'power point', 'md', 'tex', 'names', 'labels', 'odt', 'rtf')
av_formats <- c('wav', 'mp4', 'mov', 'mp3', 'wmv', 'wav', 'gif', 'avi', 'mpg', 'm4v')
web_formats <- c('html', 'xml', 'php', 'java')

#add format category column 
df_clean_categories <- df_clean_use %>% 
  #categorize formats
  mutate(format_category = "other",
         format_category = ifelse(clean_ext %in% image_formats, "image", format_category),
         format_category = ifelse(clean_ext %in% code_formats, "code", format_category),
         format_category = ifelse(clean_ext %in% basic_tabular_formats, "basic tabular", format_category),
         format_category = ifelse(clean_ext %in% domain_data_formats, "domain specific", format_category),
         format_category = ifelse(clean_ext %in% compressed_formats, "compressed", format_category),
         format_category = ifelse(clean_ext %in% text_formats, "text based", format_category),
         format_category = ifelse(clean_ext %in% av_formats, "audiovisual", format_category),
         format_category = ifelse(clean_ext %in% web_formats, "web", format_category))

file_ext_categories_list <- df_clean_categories %>% 
  select(clean_ext, format_category) %>% 
  unique()

#set factors equivalent to figure order
file_ext_categories_list$format_category <- factor(file_ext_categories_list$format_category,
                                                   levels = c('code', 
                                                              'basic tabular',
                                                              'domain specific',
                                                              'image',
                                                              'audiovisual',
                                                              'web',
                                                              'text based',
                                                              'compressed',
                                                              'other'))

file_ext_categories_list <- file_ext_categories_list %>% 
  arrange(format_category, clean_ext)

write.csv(file_ext_categories_list, "file_ext_standardized_categories.csv", row.names = FALSE)

##################################################################
############ Calculate proportions by format category ############
##################################################################

df_clean_counts <- df_clean_categories %>% 
  #keep 1 unique file ext per repo object
  #ex: if object has 5 .txt files, we just want to keep 1
  #to represent that this object contains .txt file format
  select(repo, id, repo_total, clean_ext, format_category) %>% 
  unique() %>% 
  #for each repo, group by extension type to get count of how many objects have that extension
  group_by(repo, clean_ext) %>% 
  mutate(repo_object_ext_counts = n_distinct(id),
         repo_object_ext_perc = repo_object_ext_counts/repo_total * 100) %>% 
  ungroup() %>% 
  #for each repo, group by format category to get count of how many objects have that category of file
  group_by(repo, format_category) %>% 
  mutate(repo_object_cat_counts = n_distinct(id),
         repo_object_cat_perc = repo_object_cat_counts/repo_total * 100) %>% 
  #get rid of id and unique to remove duplicates
  ungroup() %>% 
  select(-id) %>% 
  unique() %>% 
  #arrange by repo then descending counts of formats
  arrange(repo, desc(repo_object_ext_counts))

view(df_clean_counts)

#unique items in 'other' category
other <- df_clean_counts %>% 
  ungroup() %>% 
  filter(format_category == 'other') %>% 
  select(clean_ext) %>% 
  unique()

write.csv(other, "ml_repo_other.csv", row.names = FALSE)

##################################################################
########## Make graph - repo format category proportions #########
##################################################################

#ready data for plotting
df_plot <- df_clean_counts %>% 
  select(repo, format_category, repo_object_cat_counts, repo_object_cat_perc) %>% 
  unique() %>% 
  #not all repos have all format categories
  #need to add 0 values so plot reflects 'empty' categories
  complete(repo, format_category, fill = list(repo_object_cat_counts = 0, repo_object_cat_perc = 0))

view(df_plot)

#write underlying data used in plot to csv file
write.csv(df_plot, "file_format_plot_summary.csv", row.names = FALSE)

#set format category levels
df_plot$format_category <- factor(df_plot$format_category,
                                  levels = c('code', 
                                             'basic tabular',
                                             'domain specific',
                                             'image',
                                             'audiovisual',
                                             'web',
                                             'text based',
                                             'compressed',
                                             'other'))
#set repo levels
df_plot$repo <- factor(df_plot$repo,
                       levels = c("dryad", 
                                  "ucsd",
                                  "dataverse_datasets",
                                  "figshare_subset",
                                  "zenodo_subset",
                                  "uci"))

#make plot
colors_palette = unname(palette.colors(palette = "Okabe-Ito"))

file_ext_plot <- ggplot(df_plot, aes(fill=format_category, y=repo_object_cat_perc, x=repo)) + 
  geom_bar(position="dodge", stat="identity", width = 0.7) +
  scale_fill_manual(values = c('code' = colors_palette[1], 
                               'basic tabular' = colors_palette[2], 
                               'domain specific' = colors_palette[3], 
                               'image' = colors_palette[7], 
                               'audiovisual' = colors_palette[5], 
                               'web' = colors_palette[4],
                               'text based' = colors_palette[6], 
                               'compressed' = colors_palette[8], 
                               'other' = colors_palette[9]),
                    labels = c('Code', 'Basic tabular', 
                               'Domain specific', 'Image', 
                               'Audiovisual', 'Web', 
                               'Text', 'Compressed', 'Other'), 
                    name = "File format",
                    drop = FALSE) +
  #ggtitle("Files associated with 'machine learning' objects") +
  scale_x_discrete(breaks=c("dryad", 
                            "ucsd",
                            "dataverse_datasets",
                            "figshare_subset",
                            "zenodo_subset",
                            "uci"),
                   labels=c("Dryad",
                            "UC \nSan Diego \nLibrary",
                            "Harvard \nDataverse",
                            "Figshare",
                            "Zenodo",
                            "UCI \nMachine \nLearning \nRepository"),
                   drop = FALSE) +
  xlab("Repository") +
  ylab("Percent of objects containing file format") +
  scale_y_continuous(expand = c(0,0)) +
  theme_classic() +
  theme(plot.title = element_text(size = 14, 
                                  hjust = 0, 
                                  margin = margin(0,0,12,0))) 

#view plot
file_ext_plot

#save plot
ggsave("Figure2.jpeg", file_ext_plot, width = 8, height = 4, units = "in", dpi = 1200)
