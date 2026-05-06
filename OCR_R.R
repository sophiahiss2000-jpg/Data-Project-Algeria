setwd("C:/Users/Sophia Hiss/Desktop/Sophia Daten/AA Uni/Master/MIA/courses/Spring26/Data Journalism/final-data-project-sophia")

install.packages("tesseract")
install.packages("tidygeocoder")

library(tesseract)
tesseract_info()$available_languages
Sys.setenv(TESSDATA_PREFIX = "C:/Program Files/Tesseract-OCR/tessdata")

library(tesseract)
tesseract_info()$available_languages
tesseract_info()

source("anp_ocr_geo.R")
df <- read_csv("static/data/anp_output/anp_image_locations.csv")

# Show all sector_en values that still contain Arabic
df |> 
  filter(str_detect(sector_en, "[\u0600-\u06FF]")) |>
  count(sector_en, sort = TRUE) |>
  print(n = 50)

df |> filter(str_detect(sector_en, "^برج")) |> 
  count(military_region_en, sector_en)
