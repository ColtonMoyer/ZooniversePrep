
#File organization: parent file with child folders starting with site name and station ID.
#In this case the site is "210" and the station folders are labeled "210_1", "210_2", etc. 


# Load Packages
xfun::pkg_attach("readr", "here", "tidyr", "tibble", "ggplot2","tidyverse","camtrapR","exiftoolr","rgdal","magick")

getwd()
#E:/R/CameraImageClassification

#list.files(path = "E:/R/CameraImageClassification/SMCTrenamed/210", full.names = FALSE, recursive = TRUE)

#install_exiftool("C:/Windows") 
#library("exiftoolr")

addToPath("C:/Windows/exiftool")
Sys.which("exiftool.exe")

#Rename images in working directory#
imageRename(inDir = "E:/R/CameraImageClassification/210renamed", outDir = "E:/R/CameraImageClassification/210renamed", 
            hasCameraFolders = FALSE, keepCameraSubfolders = FALSE, createEmptyDirectories = TRUE, copyImages = TRUE, 
            writecsv = TRUE)

CTimages <- list(path = "E:/R/CameraImageClassification/210renamed", full.names = FALSE, recursive = TRUE)
is.list(CTimages)


#consolidate renamed CT files into parent directory#
#This is important to move everything into a singular folder to speed up processing and preparing for upload. 


source_dir <- "E:/R/CameraImageClassification/210renamed"#take the files from here
dest_dir <- "E:/R/CameraImageClassification/210renamed/210consol" #deposit the files here


if (!dir.exists(dest_dir)) {
  dir.create(dest_dir, recursive = TRUE)# Create the destination directory if it doesn't exist
}


subfolders <- list.dirs(source_dir, full.names = TRUE, recursive = TRUE) # List all subfolders in the source directory

# Loop through each subfolder
for (folder in subfolders) {
  # Check if the folder name starts with "210" (excluding the root source directory)
  if (grepl("^210", basename(folder))) {
    # List all .jpg files in the subfolder
    jpg_files <- list.files(folder, pattern = "\\.JPG$", full.names = TRUE)
    
    # Copy each .jpg file to the destination directory
    if (length(jpg_files) > 0) {
      file.copy(jpg_files, dest_dir, overwrite = TRUE)
    }
  }
}
cat("All .JPG files from subfolders starting with '210' have been copied to the destination directory.\n")# Print message upon completion

