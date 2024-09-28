# Load Packages
xfun::pkg_attach("readr", "here", "tidyr", "tibble", "ggplot2","tidyverse","camtrapR","exiftoolr","rgdal","magick")

#REDUCE IMAGE SIZE

source_dir <- "E:/R/CameraImageClassification/210renamed/210consol" #consolidated file
dest_dir <- "E:/R/CameraImageClassification/210renamed/210resized" #renamed, consolidated, resized
temp_dir <- "E:/R/CameraImageClassification/temp"  # Directory for temporary files

# Create necessary directories if they don't exist
if (!dir.exists(dest_dir)) {
  dir.create(dest_dir)
}
# Create the temporary directory so we don't save intermittent versions of every file
if (!dir.exists(temp_dir)) {
  dir.create(temp_dir)
}

# List all JPEG files in the source directory
jpeg_files <- list.files(source_dir, pattern = "\\.JPG$", full.names = TRUE)

# Set the target size in bytes (1000 KB or 1MB), Zooniverse will not accept files larger than 1MB
target_size <- 1000 * 1024  # 1000 KB in bytes

# Loop to iterate through every file in directory
for (file in jpeg_files) {
  output_file <- file.path(dest_dir, basename(file))
  
  if (file.exists(output_file)) {
    cat("Skipped (already exists):", basename(file), "\n")
    next
  }
  
  image <- image_read(file)
  quality <- 100
  
  repeat {
    temp_file <- file.path(temp_dir, paste0("temp_", basename(file)))
    
    image_write(image, temp_file, quality = quality)
    
    file_size <- file.info(temp_file)$size
    
    if (file_size <= target_size || quality <= 10) {
      break
    }
    
    quality <- quality - 5
  }
  
  if (file.rename(temp_file, output_file)) {
    file.remove(file)
    cat(basename(file), "-> Size:", file_size / 1024, "KB\n")
  } else {
    warning("Failed to rename temp file for:", basename(file))
  }
  
  if (file.exists(temp_file)) {
    file.remove(temp_file)
  }
  
  # Report remaining number of files in the source directory, --> countdown
  remaining_files <- length(jpeg_files) - (which(jpeg_files == file) + 1)
  cat("Remaining files in source directory:", remaining_files, "\n")
}





#clear environment. Dont run this unless you have to. 
rm(list = ls())

#to check free space on disk drive enter: "wmic logicaldisk get size,freespace,caption" into "command prompt" application on desktop

length(list.files("E:/R/CameraImageClassification/SMCTrenamed/batch_final"))

#standard error is SD/sqrt(k)
