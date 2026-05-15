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


## Location - Operation correlation 

locations <- c(
  "تمنراست"       = "Tamanrasset",
  "برج باجي مختار" = "Bordj Badji Mokhtar",
  "إن صالح"       = "In Salah",
  "إن ڤزام"       = "In Guezzam",    # ڤ statt ق
  "إن قزام"       = "In Guezzam",    # beide Varianten
  "إليزي"         = "Illizi",
  "الوادي"        = "El Oued",
  "ورقلة"         = "Ouargla",
  "تبسة"          = "Tebessa",
  "باتنة"         = "Batna",
  "خنشلة"         = "Khenchela",
  "قسنطينة"       = "Constantine",
  "عنابة"         = "Annaba",
  "سكيكدة"        = "Skikda",
  "أدرار"         = "Adrar",
  "غرداية"        = "Ghardaia",
  "الأغواط"       = "Laghouat",
  "تقرت"          = "Touggourt",
  "بسكرة"         = "Biskra",
  "سطيف"          = "Setif",
  "بجاية"         = "Bejaia"
)

themes <- list(
  terrorism = c("إرهاب", "إرهابي", "تسليم", "كلاشنيكوف", "مجموعة مسلحة", "الإرهابيين"),
  drugs     = c("مخدرات", "كيف", "كوكايين", "أقراص مهلوسة", "مهرب", "تهريب.*مخدر"),
  gold      = c("ذهب", "تنقيب", "مولد", "مطرقة", "أورباي", "التنقيب غير المشروع",
                "مولدا كهربائيا", "خام الذهب"),
  weapons   = c("أسلحة نارية", "بندقية", "مسدس", "ذخيرة", "رشاشة"),
  migration = c("مهاجر", "هجرة غير شرعية", "قوارب", "جنسيات مختلفة")
)


results2 <- df |>
  select(date, full_text) |>
  filter(!is.na(full_text)) |>
  rowwise() |>
  mutate(
    locs_found   = list(names(locations)[str_detect(full_text, names(locations))]),
    themes_found = list(names(themes)[map_lgl(themes, ~any(str_detect(full_text, .x)))])
  ) |>
  filter(length(locs_found) > 0, length(themes_found) > 0) |>
  unnest(locs_found) |>
  unnest(themes_found) |>
  mutate(location_en = locations[locs_found]) |>
  select(date, location_ar = locs_found, location_en, theme = themes_found)

results2 |>
  count(location_en, theme, sort = TRUE) |>
  print(n = 100)

# Satzbasiertes Matching
results3 <- df |>
  select(date, full_text) |>
  filter(!is.na(full_text)) |>
  rowwise() |>
  mutate(
    sentences = list(str_split(full_text, "[\\.،\n]")[[1]] |> 
                       str_trim() |> 
                       (\(x) x[nchar(x) > 10])())
  ) |>
  unnest(sentences) |>
  rowwise() |>
  mutate(
    locs_found   = list(names(locations)[str_detect(sentences, names(locations))]),
    themes_found = list(names(themes)[map_lgl(themes, ~any(str_detect(sentences, .x)))])
  ) |>
  filter(length(locs_found) > 0, length(themes_found) > 0) |>
  unnest(locs_found) |>
  unnest(themes_found) |>
  mutate(location_en = locations[locs_found]) |>
  select(date, location_ar = locs_found, location_en, theme = themes_found)

results3 |>
  count(location_en, theme, sort = TRUE) |>
  print(n = 100)

## statt Sätzen, Absätze als Einheit nehmen, da arbaische Sätze immer sehr lang
results4 <- df |>
  select(date, full_text) |>
  filter(!is.na(full_text)) |>
  rowwise() |>
  mutate(
    paragraphs = list(str_split(full_text, "\n")[[1]] |> 
                        str_trim() |> 
                        (\(x) x[nchar(x) > 20])())
  ) |>
  unnest(paragraphs) |>
  rowwise() |>
  mutate(
    locs_found   = list(names(locations)[str_detect(paragraphs, names(locations))]),
    themes_found = list(names(themes)[map_lgl(themes, ~any(str_detect(paragraphs, .x)))])
  ) |>
  filter(length(locs_found) > 0, length(themes_found) > 0) |>
  unnest(locs_found) |>
  unnest(themes_found) |>
  mutate(location_en = locations[locs_found]) |>
  select(date, location_ar = locs_found, location_en, theme = themes_found)

results4 |>
  count(location_en, theme, sort = TRUE) |>
  print(n = 100)

