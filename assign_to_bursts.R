#This code assigns images to bursts. In this case I wanted bursts to be any image taken within 5 minutes (300 seconds) of another image. 


# Load Packages
xfun::pkg_attach("readr", "here", "tidyr", "tibble", "ggplot2","tidyverse","camtrapR","exiftoolr","rgdal","magick")

#Assign Images to Bursts

source_dir <- "E:/R/CameraImageClassification/210renamed/210consol"

CT_images <- list.files(path = source_dir, pattern= "\\.JPG$", full.names = TRUE)
CT_images <- data.frame(file_name = basename(CT_images), 
                        file_path = CT_images, 
                        stringsAsFactors = FALSE)
CT_images$file_path <- NULL
print(CT_images)

CT_images$newfilenames <- CT_images$file_name #rename the file_name column

CT_images$minus_jpeg = substr(CT_images$newfilename,1,nchar(CT_images$newfilename)-4) #remove the .JPEG

CT_images$time <- str_sub(CT_images$minus_jpeg, -11,-4) #extract the 11th last character to the 4th last character to a new column
CT_images$time_reduced <- gsub("-", "", CT_images$time) #remove all the hyphens
CT_images$time_reduced <- as.numeric(CT_images$time_reduced)   #make it numeric
CT_images$time_reduced <- str_pad(CT_images$time_reduced, width = 6, pad = "0") #retain 6 digits (leading zeros)

CT_images$hours <- str_sub(CT_images$time_reduced ,1,2) #extract the hours 
CT_images$minutes <- str_sub(CT_images$time_reduced , 3,4) #extract the minutes
CT_images$seconds <- str_sub(CT_images$time_reduced , 5,6) #extract the seconds

CT_images$minus_jpeg <- gsub("-", "", CT_images$minus_jpeg) #remove all the hyphens from the date
CT_images$day <- str_sub(CT_images$minus_jpeg, 9,16) #extract the date

CT_images$totalseconds <- as.numeric(CT_images$hours)*3600 + as.numeric(CT_images$minutes) *60 + as.numeric(CT_images$seconds) #how many seconds into the year is each image taken

CT_images <- CT_images %>%
  mutate(diff = totalseconds - lag(totalseconds , default = first(totalseconds)))

CT_images$burst <- 1 #create two columns of 1's
CT_images$counter <- 1

CT_images <- CT_images[!is.na(CT_images$totalseconds), ] #remove any row with an NA in the total seconds column 

#loop that assigns burst numbers to photos within the same burst -> (img1, img2, img3 -> 1); (img 4, img5 -> 2)

####VERY IMPORTANT HERE ####

#######value after <= in the second row is the "splitter" consecutive photos less than or equal to <=??? seconds are in the same burst. 
#counter 1,2,3,1,2,3,1,2,1,2,3 
for (i in 2: nrow(CT_images)){
  if(CT_images$totalseconds[i]-CT_images$totalseconds[i-1]<=
     
     300 #<<<<<<<distinction (in seconds) between successive images, images taken longer than 5 minutes (300 seconds) after the previous capture are a new detection
     
     & CT_images$day[i]==CT_images$day[i-1]){
    CT_images$burst[i] <- CT_images$burst[i-1]
    CT_images$counter[i] <- CT_images$counter[i-1] +1
  }else{
    CT_images$burst[i] <- CT_images$burst[i-1]+1
    CT_images$counter[i] <- 1
  }
}

#create new dataframe with only the necessary columns
burst <- CT_images[, c("newfilenames","burst","counter")]
#pivot from long to wide format using the burst and counter columns
burst.list <- reshape(burst, v.names = "newfilenames", timevar = "counter", idvar= "burst", direction = "wide")

colnames(burst.list)[1] <- "ID"
colnames(burst.list)[2] <- "image1"
colnames(burst.list)[3] <- "image2"
colnames(burst.list)[4] <- "image3"

#name a folder for placement of images, this is to keep the .csv made below with the images
dest_dir <- "E:/R/CameraImageClassification/210renamed/210resized" 

if (!dir.exists(dest_dir)) {
  dir.create(dest_dir)
}
#getwd()
write.csv(burst.list, file='E:/R/CameraImageClassification/210renamed/210/resized/SMCT_210_bursts.csv', row.names=FALSE) #this file will needed to be uploaded with the 

