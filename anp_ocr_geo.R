# ============================================================
#  ANP Image OCR + Geolocation
#
#  Pipeline:
#  1. Scan all images with Arabic Tesseract OCR
#  2. Extract military region + sector from sign text
#  3. Geocode sector name via OpenStreetMap (Nominatim)
#     Fallback: if no sector found, geocode regional HQ city
#  4. Build DataFrame: image path | date | region | sector | lat | lon
# ============================================================

library(tesseract)
library(tidyverse)
library(tidygeocoder)
library(fs)

# ── Config ────────────────────────────────────────────────────
Sys.setenv(TESSDATA_PREFIX = "C:/Program Files/Tesseract-OCR/tessdata")
setwd("C:/Users/Sophia Hiss/Desktop/Sophia Daten/AA Uni/Master/MIA/courses/Spring26/Data Journalism/final-data-project-sophia")

IMG_DIR  <- "public/data/anp_output/images"
OUT_FILE <- "public/data/anp_output/anp_image_locations.csv"

SLEEP_GEOCODE <- 1.2  # seconds between OSM requests — be polite

# Arabic OCR engine
ara <- tesseract("ara")

# ── Military region number -> name lookup ─────────────────────
region_lookup <- c(
  "الأولى"   = "1st Region - Blida",
  "الثانية"  = "2nd Region - Oran",
  "الثالثة"  = "3rd Region - Bechar",
  "الرابعة"  = "4th Region - Ouargla",
  "الخامسة"  = "5th Region - Constantine",
  "السادسة"  = "6th Region - Tamanrasset",
  "1"        = "1st Region - Blida",
  "2"        = "2nd Region - Oran",
  "3"        = "3rd Region - Bechar",
  "4"        = "4th Region - Ouargla",
  "5"        = "5th Region - Constantine",
  "6"        = "6th Region - Tamanrasset"
)

# ── Region HQ fallback geocoding ─────────────────────────────
# If no sector is found, geocode the regional headquarters city
region_hq <- c(
  "1st Region - Blida"        = "Blida, Algeria",
  "2nd Region - Oran"         = "Oran, Algeria",
  "3rd Region - Bechar"       = "Bechar, Algeria",
  "4th Region - Ouargla"      = "Ouargla, Algeria",
  "5th Region - Constantine"  = "Constantine, Algeria",
  "6th Region - Tamanrasset"  = "Tamanrasset, Algeria"
)

# ── Arabic city names -> Latin for geocoding ──────────────────
city_transliteration <- c(
  "تامنراست"       = "Tamanrasset, Algeria",
  "تمنراست"        = "Tamanrasset, Algeria",
  "برج باجي مختار" = "Bordj Badji Mokhtar, Algeria",
  "برج بادجي مختار"= "Bordj Badji Mokhtar, Algeria",
  "عين قزام"       = "In Guezzam, Algeria",
  "إن قزام"        = "In Guezzam, Algeria",
  "إن ڤزام"        = "In Guezzam, Algeria",
  "إليزي"          = "Illizi, Algeria",
  "ورقلة"          = "Ouargla, Algeria",
  "بشار"           = "Bechar, Algeria",
  "البيض"          = "El Bayadh, Algeria",
  "أدرار"          = "Adrar, Algeria",
  "تندوف"          = "Tindouf, Algeria",
  "الجزائر"        = "Algiers, Algeria",
  "وهران"          = "Oran, Algeria",
  "قسنطينة"        = "Constantine, Algeria",
  "عنابة"          = "Annaba, Algeria",
  "سطيف"           = "Setif, Algeria",
  "باتنة"          = "Batna, Algeria",
  "تيزي وزو"       = "Tizi Ouzou, Algeria",
  "بجاية"          = "Bejaia, Algeria",
  "المدية"         = "Medea, Algeria",
  "البليدة"        = "Blida, Algeria",
  "تيارت"          = "Tiaret, Algeria",
  "سيدي بلعباس"    = "Sidi Bel Abbes, Algeria",
  "تلمسان"         = "Tlemcen, Algeria",
  "الأغواط"        = "Laghouat, Algeria",
  "غرداية"         = "Ghardaia, Algeria",
  "الوادي"         = "El Oued, Algeria",
  "بسكرة"          = "Biskra, Algeria",
  "خنشلة"          = "Khenchela, Algeria",
  "تبسة"           = "Tebessa, Algeria",
  "سوق أهراس"      = "Souk Ahras, Algeria",
  "جيجل"           = "Jijel, Algeria",
  "سكيكدة"         = "Skikda, Algeria",
  "قالمة"          = "Guelma, Algeria",
  "باتئة"          = "Batna, Algeria",
  "بائنة"          = "Batna, Algeria",
  "أم"             = "Oum El Bouaghi, Algeria",
  "برج"            = "Bordj Badji Mokhtar, Algeria",
  "خدشلة"          = "Khenchela, Algeria",
  "خدشلة\u200e"    = "Khenchela, Algeria",
  "إيليزي"         = "Illizi, Algeria",
  "المغير"         = "El Mghair, Algeria",
  "المغيلٌ"        = "El Mghair, Algeria",
  "تامنفست"        = "Tamanrasset, Algeria",
  "تامنئفست"       = "Tamanrasset, Algeria",
  "تامنة"          = "Tamanrasset, Algeria",
  "تقرت"           = "Touggourt, Algeria",
  "تقرت-"          = "Touggourt, Algeria",
  "المنيعة"        = "El Menia, Algeria",
  "الطارف"         = "El Taref, Algeria",
  "الدادي"         = "Debdeb, Algeria",
  "بجاد"           = "Biskra, Algeria",
  "قسطيية"         = "Constantine, Algeria",
  "عض"             = NA_character_
)

# ── Step 1: OCR a single image ────────────────────────────────
ocr_image <- function(img_path) {
  tryCatch({
    text <- ocr(img_path, engine = ara)
    text <- str_squish(text)
    text
  }, error = function(e) {
    message(paste0("[OCR ERROR] ", basename(img_path), " - ", conditionMessage(e)))
    NA_character_
  })
}

# ── Step 2: Extract region and sector from OCR text ───────────
extract_location <- function(ocr_text) {
  result <- list(
    military_region_ar = NA_character_,
    military_region_en = NA_character_,
    sector_ar          = NA_character_,
    sector_en          = NA_character_
  )
  
  if (is.na(ocr_text) || !nzchar(ocr_text)) return(result)
  
  # Military region: الناحية العسكرية + ordinal
  region_match <- str_extract(ocr_text, "الناحية العسكرية\\s+\\S+")
  if (!is.na(region_match)) {
    result$military_region_ar <- region_match
    ordinal <- str_extract(region_match, "\\S+$")
    for (key in names(region_lookup)) {
      if (str_detect(ordinal, fixed(key))) {
        result$military_region_en <- region_lookup[key]
        break
      }
    }
  }
  
  # Sector: القطاع العسكري + city name
  sector_match <- str_extract(ocr_text, "القطاع العسكري\\s+\\S+")
  if (!is.na(sector_match)) {
    city_ar <- str_extract(sector_match, "\\S+$")
    result$sector_ar <- city_ar
    
    for (key in names(city_transliteration)) {
      if (str_detect(ocr_text, fixed(key))) {
        result$sector_en <- city_transliteration[key]
        break
      }
    }
    
    if (is.na(result$sector_en) && !is.na(city_ar)) {
      result$sector_en <- paste(city_ar, "Algeria")
    }
  }
  
  result
}

# ── Step 3: Geocode via OSM Nominatim ─────────────────────────
geocode_cache <- list()

geocode_location <- function(location_en) {
  if (is.na(location_en) || !nzchar(location_en)) {
    return(list(lat = NA_real_, lon = NA_real_))
  }
  if (!is.null(geocode_cache[[location_en]])) {
    return(geocode_cache[[location_en]])
  }
  
  Sys.sleep(SLEEP_GEOCODE)
  
  result <- tryCatch({
    geo_result <- geo(address = location_en, method = "osm", full_results = FALSE)
    list(lat = geo_result$lat[1], lon = geo_result$long[1])
  }, error = function(e) {
    message("  [GEO ERROR] ", location_en, " -> ", conditionMessage(e))
    list(lat = NA_real_, lon = NA_real_)
  })
  
  geocode_cache[[location_en]] <<- result
  result
}

# ── Main ──────────────────────────────────────────────────────
cat("=", strrep("=", 58), "\n")
cat("  ANP Image OCR + Geolocation\n")
cat("=", strrep("=", 58), "\n\n")

all_images <- dir_ls(IMG_DIR, recurse = TRUE, glob = "*.jpg")
cat("Total images found:", length(all_images), "\n\n")

if (length(all_images) == 0) stop("No images found in ", IMG_DIR)

results <- map_dfr(seq_along(all_images), function(i) {
  img_path    <- all_images[i]
  folder_name <- basename(dirname(img_path))
  date_str    <- ifelse(str_detect(folder_name, "^\\d{4}-\\d{2}-\\d{2}$"),
                        folder_name, NA_character_)
  
  cat(sprintf("\n[%d/%d] %s\n", i, length(all_images), basename(img_path)))
  
  cat("  OCR...")
  ocr_text <- ocr_image(img_path)
  cat(" done\n")
  
  loc <- extract_location(ocr_text)
  cat("  Region:", loc$military_region_en %||% "NA", "\n")
  cat("  Sector:", loc$sector_en %||% "NA", "\n")
  
  # Geocode: prefer sector, fall back to region HQ
  geocode_target <- if (!is.na(loc$sector_en)) {
    loc$sector_en
  } else if (!is.na(loc$military_region_en)) {
    hq <- region_hq[loc$military_region_en]
    if (!is.na(hq)) {
      cat("  [Fallback] Using region HQ:", hq, "\n")
      hq
    } else NA_character_
  } else {
    NA_character_
  }
  
  coords <- geocode_location(geocode_target)
  if (!is.na(coords$lat)) {
    cat(sprintf("  Coords: %.4f, %.4f\n", coords$lat, coords$lon))
  }
  
  tibble(
    image_path         = as.character(img_path),
    image_file         = basename(img_path),
    date               = date_str,
    ocr_text_snippet   = str_trunc(ocr_text %||% "", 200),
    military_region_ar = loc$military_region_ar,
    military_region_en = loc$military_region_en,
    sector_ar          = loc$sector_ar,
    sector_en          = loc$sector_en,
    geocode_source     = if (!is.na(loc$sector_en)) "sector"
    else if (!is.na(geocode_target)) "region_hq"
    else NA_character_,
    lat                = coords$lat,
    lon                = coords$lon
  )
})

# ── Summary ───────────────────────────────────────────────────
cat("\n\n-- Summary --\n")
cat("Total images processed:", nrow(results), "\n")
cat("With region extracted: ", sum(!is.na(results$military_region_en)), "\n")
cat("With sector extracted: ", sum(!is.na(results$sector_en)), "\n")
cat("Geocoded via sector:   ", sum(results$geocode_source == "sector",    na.rm = TRUE), "\n")
cat("Geocoded via region HQ:", sum(results$geocode_source == "region_hq", na.rm = TRUE), "\n")
cat("With coordinates:      ", sum(!is.na(results$lat)), "\n")

cat("\nTop locations found:\n")
results |>
  filter(!is.na(sector_en)) |>
  count(sector_en, military_region_en, sort = TRUE) |>
  print(n = 15)

write_csv(results, OUT_FILE)
cat("\nSaved ->", OUT_FILE, "\n")
cat("  Rows:", nrow(results), "\n")
