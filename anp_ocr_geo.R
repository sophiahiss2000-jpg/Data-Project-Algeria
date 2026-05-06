# ============================================================
#  ANP Image OCR + Geolocation
#
#  Pipeline:
#  1. Scan all images with Arabic Tesseract OCR
#  2. Extract military region + sector from sign text
#  3. Geocode sector name via OpenStreetMap (Nominatim)
#  4. Build DataFrame: image path | date | region | sector | lat | lon
# ============================================================

library(tesseract)
library(tidyverse)
library(tidygeocoder)
library(fs)

# ── Config ────────────────────────────────────────────────────
Sys.setenv(TESSDATA_PREFIX = "C:/Program Files/Tesseract-OCR/tessdata")

IMG_DIR  <- "static/data/anp_output/images"
OUT_FILE <- "static/data/anp_output/anp_image_locations.csv"

SLEEP_GEOCODE <- 1.2  # seconds between OSM requests — be polite

# Arabic OCR engine
ara <- tesseract("ara")

# ── Military region number → name lookup ─────────────────────
# Algeria has 6 military regions
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

# ── Arabic city names → Latin for geocoding ──────────────────
# OSM works best with latin transliterations for Algerian cities
city_transliteration <- c(
  "تامنراست"      = "Tamanrasset, Algeria",
  "تمنراست"       = "Tamanrasset, Algeria",
  "برج باجي مختار" = "Bordj Badji Mokhtar, Algeria",
  "برج بادجي مختار" = "Bordj Badji Mokhtar, Algeria",
  "عين قزام"      = "In Guezzam, Algeria",
  "إن قزام"       = "In Guezzam, Algeria",
  "إليزي"         = "Illizi, Algeria",
  "ورقلة"         = "Ouargla, Algeria",
  "بشار"          = "Bechar, Algeria",
  "البيض"         = "El Bayadh, Algeria",
  "أدرار"         = "Adrar, Algeria",
  "تندوف"         = "Tindouf, Algeria",
  "الجزائر"       = "Algiers, Algeria",
  "وهران"         = "Oran, Algeria",
  "قسنطينة"       = "Constantine, Algeria",
  "عنابة"         = "Annaba, Algeria",
  "سطيف"          = "Setif, Algeria",
  "باتنة"         = "Batna, Algeria",
  "تيزي وزو"      = "Tizi Ouzou, Algeria",
  "بجاية"         = "Bejaia, Algeria",
  "المدية"        = "Medea, Algeria",
  "البليدة"       = "Blida, Algeria",
  "تيارت"         = "Tiaret, Algeria",
  "سيدي بلعباس"   = "Sidi Bel Abbes, Algeria",
  "تلمسان"        = "Tlemcen, Algeria",
  "الأغواط"       = "Laghouat, Algeria",
  "غرداية"        = "Ghardaia, Algeria",
  "الوادي"        = "El Oued, Algeria",
  "بسكرة"         = "Biskra, Algeria",
  "خنشلة"         = "Khenchela, Algeria",
  "تبسة"          = "Tebessa, Algeria",
  "سوق أهراس"     = "Souk Ahras, Algeria",
  "جيجل"          = "Jijel, Algeria",
  "سكيكدة"        = "Skikda, Algeria",
  "قالمة"         = "Guelma, Algeria",
  
  # Batna variants
  "باتئة"          = "Batna, Algeria",
  "بائنة"          = "Batna, Algeria",

  # Oum El Bouaghi — أم = truncated OCR
  "أم"             = "Oum El Bouaghi, Algeria",

  # Bordj Badji Mokhtar — برج = truncated OCR
  "برج"            = "Bordj Badji Mokhtar, Algeria",

  # Khenchela — OCR misreads خ
  "خدشلة"          = "Khenchela, Algeria",
  "خدشلة\u200e"    = "Khenchela, Algeria",   # with invisible unicode char

  # Illizi variants
  "إيليزي"         = "Illizi, Algeria",

  # El Mghair
  "المغير"         = "El Mghair, Algeria",
  "المغيلٌ"        = "El Mghair, Algeria",

  # Tamanrasset variants
  "تامنفست"        = "Tamanrasset, Algeria",
  "تامنئفست"       = "Tamanrasset, Algeria",
  "تامنة"          = "Tamanrasset, Algeria",

  # Touggourt
  "تقرت"           = "Touggourt, Algeria",
  "تقرت-"          = "Touggourt, Algeria",

  # El Menia
  "المنيعة"        = "El Menia, Algeria",

  # El Kala / El Taref
  "الطارف"         = "El Taref, Algeria",

  # El Oued area — الدادي possibly Debdeb
  "الدادي"         = "Debdeb, Algeria",

  # Biskra area — بجاد possibly Biskra
  "بجاد"           = "Biskra, Algeria",

  # Constantine OCR misread
  "قسطيية"         = "Constantine, Algeria",

  # عض — too short/ambiguous, skip
  "عض"             = NA_character_," 
  
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

  # ── Military region ──
  # Pattern: الناحية العسكرية + ordinal number
  region_match <- str_extract(ocr_text, "الناحية العسكرية\\s+\\S+")
  if (!is.na(region_match)) {
    result$military_region_ar <- region_match
    # Extract the ordinal word (last word)
    ordinal <- str_extract(region_match, "\\S+$")
    # Look up English name
    for (key in names(region_lookup)) {
      if (str_detect(ordinal, fixed(key))) {
        result$military_region_en <- region_lookup[key]
        break
      }
    }
  }

  # ── Sector ──
  # Pattern: القطاع العسكري + city name
  sector_match <- str_extract(ocr_text, "القطاع العسكري\\s+\\S+")
  if (!is.na(sector_match)) {
    city_ar <- str_extract(sector_match, "\\S+$")
    result$sector_ar <- city_ar

    # Transliterate to Latin for geocoding
    for (key in names(city_transliteration)) {
      if (str_detect(ocr_text, fixed(key))) {
        result$sector_en <- city_transliteration[key]
        break
      }
    }

    # Fallback: if sector name not in lookup, try raw Arabic with Algeria appended
    if (is.na(result$sector_en) && !is.na(city_ar)) {
      result$sector_en <- paste(city_ar, "Algeria")
    }
  }

  result
}


# ── Step 3: Geocode via OSM Nominatim ─────────────────────────

geocode_cache <- list()  # cache to avoid duplicate requests

geocode_location <- function(location_en) {
  if (is.na(location_en) || !nzchar(location_en)) {
    return(list(lat = NA_real_, lon = NA_real_))
  }

  # Check cache first
  if (!is.null(geocode_cache[[location_en]])) {
    return(geocode_cache[[location_en]])
  }

  Sys.sleep(SLEEP_GEOCODE)

  result <- tryCatch({
    geo_result <- geo(
      address  = location_en,
      method   = "osm",
      full_results = FALSE
    )
    list(
      lat = geo_result$lat[1],
      lon = geo_result$long[1]
    )
  }, error = function(e) {
    message("  [GEO ERROR] ", location_en, " → ", conditionMessage(e))
    list(lat = NA_real_, lon = NA_real_)
  })

  # Store in cache
  geocode_cache[[location_en]] <<- result
  result
}


# ── Main: process all images ──────────────────────────────────

cat("=" , strrep("=", 58), "\n")
cat("  ANP Image OCR + Geolocation\n")
cat("=" , strrep("=", 58), "\n\n")

# Collect all image files
all_images <- dir_ls(IMG_DIR, recurse = TRUE, glob = "*.jpg")
cat("Total images found:", length(all_images), "\n\n")

if (length(all_images) == 0) {
  stop("No images found in ", IMG_DIR)
}

# Process each image
results <- map_dfr(seq_along(all_images), function(i) {
  img_path <- all_images[i]

  # Extract date from folder name
  folder_name <- basename(dirname(img_path))
  date_str    <- ifelse(str_detect(folder_name, "^\\d{4}-\\d{2}-\\d{2}$"),
                        folder_name, NA_character_)

  cat(sprintf("\n[%d/%d] %s\n", i, length(all_images), basename(img_path)))

  # OCR
  cat("  OCR...")
  ocr_text <- ocr_image(img_path)
  cat(" done\n")

  # Extract location
  loc <- extract_location(ocr_text)
  cat("  Region:", loc$military_region_en %||% "not found", "\n")
  cat("  Sector:", loc$sector_en %||% "not found", "\n")

  # Geocode
  coords <- geocode_location(loc$sector_en)
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
    lat                = coords$lat,
    lon                = coords$lon
  )
})

# ── Summary ───────────────────────────────────────────────────
cat("\n\n── Summary ──\n")
cat("Total images processed:", nrow(results), "\n")
cat("With region extracted: ", sum(!is.na(results$military_region_en)), "\n")
cat("With sector extracted: ", sum(!is.na(results$sector_en)), "\n")
cat("With coordinates:      ", sum(!is.na(results$lat)), "\n")

cat("\nTop locations found:\n")
results |>
  filter(!is.na(sector_en)) |>
  count(sector_en, military_region_en, sort = TRUE) |>
  print(n = 15)

# ── Save ──────────────────────────────────────────────────────
write_csv(results, OUT_FILE)
cat("\n✓ Saved →", OUT_FILE, "\n")
cat("  Rows:", nrow(results), "\n")

