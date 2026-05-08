library(rvest)
library(httr)
library(tidyverse)

setwd("C:/Users/Sophia Hiss/Desktop/Sophia Daten/AA Uni/Master/MIA/courses/Spring26/Data Journalism/final-data-project-sophia")

UA <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36"

df <- read_csv("public/data/anp_output/anp_clean.csv",
               col_types = cols(date = col_character()))

cat("Fetching full text for", nrow(df), "reports...\n")

fetch_full_text <- function(url) {
  if (is.na(url)) return(NA_character_)
  Sys.sleep(1.5)
  tryCatch({
    resp <- GET(url, user_agent(UA), timeout(20))
    soup <- content(resp, as = "text", encoding = "UTF-8") |> read_html()
    
    # Get all text inside div.text_com, stop before the table
    div <- soup |> html_element("div.text_com")
    if (is.null(div)) return(NA_character_)
    
    # Remove the table from the div before extracting text
    # (get only paragraphs and text nodes before the table)
    paras <- div |> html_elements("p")
    if (length(paras) > 0) {
      text <- paras |> html_text(trim = TRUE) |>
        paste(collapse = "\n") |>
        str_squish()
    } else {
      # fallback: full div text
      text <- html_text(div, trim = TRUE) |> str_squish()
    }
    text
  }, error = function(e) {
    message("[ERROR] ", url, " - ", conditionMessage(e))
    NA_character_
  })
}

# Fetch all
df$full_text <- map_chr(seq_len(nrow(df)), function(i) {
  cat("[", i, "/", nrow(df), "]", df$date[i], "\n")
  fetch_full_text(df$report_url[i])
})

cat("Done. Non-NA texts:", sum(!is.na(df$full_text)), "\n")
cat("Avg length:", mean(nchar(df$full_text), na.rm = TRUE) |> round(), "chars\n")

write_csv(df, "public/data/anp_output/anp_clean.csv")
cat("Saved.\n")