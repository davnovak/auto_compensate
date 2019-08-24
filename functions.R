
get_directory <- function(total_path) {
  # extract dir from full path
  fpath <- unlist(strsplit(total_path, "/"))[-1]
  fpath <- fpath[1:(length(fpath)-1)]
  return(paste("/", paste0(fpath, collapse="/"), sep=""))
}

get_new_name <- function(fname, suffix="_comp_II_nnls") {
  # generate compensated file name
  fname_split <- tail(unlist(strsplit(fname, "[.]")), 2)
  fname_new <- paste(fname_split[1], suffix, ".", fname_split[2], sep="")
  return(fname_new)
}

get_new_filepath <- function(total_path, suffix="_comp_II_nnls") {
  # generate compensated file path
  fname <- tail(unlist(strsplit(total_path, "/")), 1)
  fpath <- get_directory(total_path)
  fname_new <- get_new_name(fname=fname, suffix=suffix)
  total_path_new <- paste(fpath, fname_new, sep="/")
  return(total_path_new)
}

create_comp <- function(total_path, suffix="_comp_II_nnls", compensation_matrix=spillMat, method="nnls") { 
  # create compensated .fcs file
  flowset_ke_komp <- read.flowSet(total_path, transformation = FALSE, truncate_max_range = FALSE) # fcs file, ktery chci zkompenzovat
  flowset_ke_komp_frame <- flowset_ke_komp[[1]]
  
  comped_nnls <- compCytof(x=flowset_ke_komp_frame, y=spillMat, method=method) # tahle kompenzace se mi libi
  
  total_path_new <- get_new_filepath(total_path, suffix)
  
  write.FCS(x = comped_nnls, filename = total_path_new)
  cat(".")
}

interspersedRegex <- function(name) {
  # regex string where original is possibly interspersed with other characters
  l <- as.list(unlist(strsplit(name, "")))
  m <- list()
  for (i in l) {
    m <- append(m, append(i, ".*"))
  }
  m <- unlist(m)
  return(paste0(m, sep="", collapse=""))
}

has_comp <- function(total_path, subs="comp", recursive=FALSE) { 
  # check if given file was already compensated, i.e. is a compensated file or parent dir contains a compensated version thereof
  d <- get_directory(total_path)
  file_list <- list.files(d)
  fname <- tail(unlist(strsplit(total_path, "/")), 1)
  if (grepl(subs, fname)) return(TRUE)
  
  fname_wo_extension <- unlist(strsplit(fname, "[.]"))[1]
  occurences <- which(grepl(interspersedRegex(fname_wo_extension), file_list))
  compensated <- occurences[which(grepl(subs, file_list[occurences]))]
  
  if (recursive) {
    parents <- occurences[which(!grepl(subs, file_list[occurences]))]
    parents <- parents[which(file_list[parents]!=fname)] # such files for which the examined file name is a substring but they are not its compensation file
    compensated_parents <- integer(0)
    if (length(parents > 0)) {
      compensated_parents <- NULL
      for (i in parents) {
        if (has_comp_recursive(paste(d, file_list[i], sep="/")))
          compensated_parents <- c(compensated_parents, i)
      }
    }
    parent_occurences <- NULL
    for (i in compensated_parents) {
      parent_name <- file_list[i]
      parent_name_wo_extension <- unlist(strsplit(parent_name, "[.]"))[1]
      parent_occurences <- c(parent_occurences, which(grepl(interspersedRegex(parent_name_wo_extension), file_list)))
    }
    compensated <- compensated[which(!compensated%in%parent_occurences)]
    compensated <- compensated[which(!compensated%in%parents)]
  }
  
  return(length(compensated)>0)
}

isOld <- function(dname, fresh) {
  if (!grepl("^F[0-9]{6}.*$", dname)) return(TRUE)
  ddate <- regmatches(dname, regexpr("^F[0-9]{6}", dname))
  ddate <- substring(ddate, 2)
  sdate <- as.Date(Sys.Date())-fresh
  sdate <- paste(substring(sdate, 3, 4), substring(sdate, 6, 7), substring(sdate, 9, 10), sep="")
  return(ddate<sdate)
}

get_uncomp_files <- function(directory, verbose=FALSE, fresh=TRUE) {
  # create a list of all uncompensated file in some dir
  all_files <- list.files(directory, recursive=TRUE, full.names=TRUE)
  which_fcs <- which(sapply(all_files, function(i) substr(i, nchar(i)-3, nchar(i)))==".fcs")
  fcs_files <- all_files[which_fcs]
  if (!is.null(fresh)) {
    cat("Number of .fcs files including old samples: ", length(fcs_files), ".\n", sep="")
    cat("Identifying old samples... ")
    folders <- list.files(directory, recursive=FALSE)
    which_old <- list()
    for (i in 1:length(folders)) { if (isOld(folders[i], fresh)) { which_old[[length(which_old)+1]] <- i } }
    which_old <- unlist(which_old)
    oldFolders <- folders[which_old]
    for (i in oldFolders) {
      fcs_files <- fcs_files[which(!grepl(i, fcs_files))]
    }
    cat(" done.\n")
  }
  cat("Identifying uncompensated files...\n")
  uncomp_files <- list()
  for (i in fcs_files) {
    if (!has_comp(i)) {
      uncomp_files[[length(uncomp_files)+1]] <- i
    }
  }
  uncomp_files <- unlist(uncomp_files)
  #uncomp_files <- fcs_files[!sapply(fcs_files, has_comp)]
  if (verbose) cat("Number of relevant .fcs files: ", length(fcs_files), "\nNumber of relevant uncompensated .fcs files: ", length(uncomp_files), "\n")
  return(uncomp_files)
}

## compensate_uncomp file function
## Searches 'directory' for all .fcs files (recursively). For each .fcs file, check if it has a compensated version in its parent directory
## (i.e. its name contains the original name, plus the substring "comp" at any position). If not, generate a compensated .fcs file, appending
## content of 'suffix' to the name. This suffix must contain the substring "comp" so that we keep track of the files which were already
## compensated. The function also needs to be provided with a compensation matrix and method parameter to passed to function compCytof
## (default is "nnls").

compensate_uncomp_fcs <- function(directory,
                                  fresh=TRUE,
                                  uncomp_files=NULL,
                                  suffix="_comp_II_nnls",
                                  compensation_matrix=spillMat,
                                  method="nnls") {
  if (is.null(uncomp_files)) { uncomp_files <- get_uncomp_files(directory, fresh=fresh) }
  for (i in uncomp_files)
    create_comp(i, suffix, compensation_matrix, method)
  cat("\n")
}
