library(CATALYST)
library(flowCore)
library(diffcyt)
library(SummarizedExperiment)
library(stringr)

# setwd(dirname(rstudioapi::getActiveDocumentContext()$path)) # set working directory to script location (for use with RStudio)

source("functions.R")

FOLDER <- "foo"

cat("Automatic compensation tool\n")

cat("Working with folder ", FOLDER, "\n")
cat("To change folder, change assignment to variabel FOLDER in this script.\n", sep="")
cat("Do you want only want to work with new data, i.e. data from the last N days?\nIn this mode, we only consider folder names beginning with 'Fyymmdd' ('F' and date) and filters only those folders with dates which are not older than the selected number of days (N).\n")
cat("Want to only browse through new data? Enter 'y'. Want to browse through all data? Enter 'n'. Abort? Enter anything else.\n")
w <- readline("Response: ")
if (w == "y" || w =="n" || w == "Y" || w =="N") {
  fresh <- NULL
  N <- NULL
  if (w == "y" || w == "Y") {
    N <- readline("N = ")
    fresh <- abs(as.numeric(N))
    cat("Browsing through samples no older than ", N, " days...\n", sep="")
  }
  g <- get_uncomp_files(FOLDER, verbose=TRUE, fresh=fresh)
  cat("To display list of files which were identified as uncompensated, enter 's'.\nTo apply compensation to these files, enter 'k'.\nIf you're lost and need help, enter 'h'.\nTo abort everything, enter anything else.\n")
  response <- readline(prompt="Response: ")
  if (response == 's' || response == 'S') {
    print(g)
    cat("To apply compensation to these files, enter 'y'. Otherwise, enter anything else.\n")
    h <- readline("Response: ")
    if (h == "y" || h == "Y") {
      response <- 'k'
    }
  }
  if (response == 'k' || response == 'K') { compensate_uncomp_fcs(FOLDER, fresh, g) }
  if (response == 'h' || response == 'H') { cat("Contact davidnovakcz@hotmail.com.\n") }
  cat("_\n")
}
