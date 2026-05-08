# ============================================================
#  ANP Operational Report Scraper — R version v2
#  Fixed: URL resolution bug causing missing slash + path
# ============================================================
setwd("C:/Users/Sophia Hiss/Desktop/Sophia Daten/AA Uni/Master/MIA/courses/Spring26/Data Journalism/final-data-project-sophia")
install.packages(c("rvest", "httr", "tidyverse", "fs"))
library(rvest)
library(httr)
library(tidyverse)
library(fs)

# ── Config ────────────────────────────────────────────────────────────────────

ARCHIVE_URL <- "https://www.mdn.dz/site_principal/sommaire/archives/archives_actualites_ar.php"
BASE_URL     <- "https://www.mdn.dz"

OUT_DIR <- "anp_output"
IMG_DIR <- file.path(OUT_DIR, "images")
dir_create(OUT_DIR)
dir_create(IMG_DIR)

SLEEP           <- 1.5
REPORT_KEYWORDS <- c("lutte", "bilan")
YEARS           <- c(2024, 2025)

UA <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120.0.0.0 Safari/537.36"


# ── Helpers ───────────────────────────────────────────────────────────────────

fetch_page <- function(url) {
  tryCatch({
    resp <- GET(url, user_agent(UA), timeout(20))
    stop_for_status(resp)
    content(resp, as = "text", encoding = "UTF-8") |> read_html()
  }, error = function(e) {
    message("  [ERROR] ", url, " → ", conditionMessage(e))
    NULL
  })
}

#' Robust URL resolver — avoids the hostname-mangling bug
#' Handles: absolute URLs, root-relative (/path), and relative (../path)
resolve_url <- function(base_url, href) {
  if (is.na(href) || !nzchar(href)) return(NA_character_)
  
  # Already absolute
  if (grepl("^https?://", href)) return(href)
  
  # Root-relative: starts with /
  if (startsWith(href, "/")) {

   # Extract scheme + hostname only
    m <- regmatches(filename, regexec("(\\d{2})(\\d{2})(\\d{4})(fr|ar)\\.php", filename))[[1]]
    return(paste0(m, href))
  }
  
  # Relative: resolve against the directory of base_url
  # Get the directory part of the base URL (everything up to last /)
  base_dir <- sub("/[^/]*$", "/", base_url)
  
  combined <- paste0(base_dir, href)
  
  # Normalise ../ by repeatedly collapsing /something/../
  while (grepl("/[^/]+/\\.\\./", combined)) {
    combined <- gsub("/[^/]+/\\.\\./", "/", combined)
  }
  # Remove any remaining ./
  combined <- gsub("/\\./", "/", combined)
  
  combined
}

extract_date <- function(url) {
  filename <- basename(url)
  m <- regmatches(filename, regexec("(\\d{2})(\\d{2})(\\d{4})(?:fr|ar)\\.php", filename))[[1]]
  paste0(m[4], "-", m[3], "-", m[2])
  if (length(m) < 4) return(NA_character_)
  paste0(m[4], "-", m[3], "-", m[2])  # YYYY-MM-DD
}

extract_type <- function(url) {
  filename <- tolower(basename(url))
  for (kw in REPORT_KEYWORDS) {
    if (startsWith(filename, kw)) return(kw)
  }
  "other"
}

safe_name <- function(x) gsub("[^\\w\\-_.]", "_", x, perl = TRUE)


# ── Step 1: Monthly archive links ─────────────────────────────────────────────

get_monthly_links <- function(years = YEARS) {
  cat("\n── Step 1: Collecting monthly archive links ──\n")
  
  soup <- fetch_page(ARCHIVE_URL)
  if (is.null(soup)) stop("[FATAL] Could not load archive page.")
  
  # Try content section first, fall back to all anchors
  anchors <- soup |> html_elements("#contentSection a[href]")
  if (length(anchors) == 0) anchors <- soup |> html_elements("a[href]")
  
  results <- map_dfr(anchors, function(a) {
    href       <- html_attr(a, "href")
    month_text <- html_text(a, trim = TRUE) |>
      str_remove("^\\|\\s*") |>
      str_to_title()
    
    matched_year <- NA_integer_
    for (yr in years) {
      if (str_detect(href, as.character(yr)) && str_detect(href, "archives_")) {
        matched_year <- yr
        break
      }
    }
    if (is.na(matched_year)) return(NULL)
    
    full_url <- resolve_url(ARCHIVE_URL, href)
    cat("  ", matched_year, month_text, "→", full_url, "\n")
    
    tibble(year = matched_year, month = month_text, url = full_url)
  }) |> distinct()
  
  cat("  Total monthly pages found:", nrow(results), "\n")
  results
}


# ── Step 2: Report links from each monthly page ───────────────────────────────

get_report_links <- function(monthly_links) {
  cat("\n── Step 2: Collecting lutte/bilan report links ──\n")
  
  map_dfr(seq_len(nrow(monthly_links)), function(i) {
    entry <- monthly_links[i, ]
    cat("\n  ", entry$year, entry$month, "→", entry$url, "\n")
    Sys.sleep(SLEEP)
    
    soup <- fetch_page(entry$url)
    if (is.null(soup)) {
      return(tibble(year = entry$year, month = entry$month,
                    month_url = entry$url, report_url = NA_character_,
                    date = NA_character_, report_type = NA_character_,
                    link_text = NA_character_))
    }
    
    anchors <- soup |> html_elements("a[href]")
    hrefs   <- html_attr(anchors, "href")
    
    is_report <- map_lgl(hrefs, function(h) {
      any(str_detect(tolower(h), fixed(REPORT_KEYWORDS)))
    })
    
    report_anchors <- anchors[is_report]
    report_hrefs   <- hrefs[is_report]
    
    if (length(report_hrefs) == 0) {
      cat("    No lutte/bilan links found → NA row\n")
      return(tibble(year = entry$year, month = entry$month,
                    month_url = entry$url, report_url = NA_character_,
                    date = NA_character_, report_type = NA_character_,
                    link_text = NA_character_))
    }
    
    map_dfr(seq_along(report_hrefs), function(j) {
      full_url  <- resolve_url(entry$url, report_hrefs[j])
      date_str  <- extract_date(full_url)
      rtype     <- extract_type(full_url)
      link_text <- html_text(report_anchors[[j]], trim = TRUE)
      cat("    [", rtype, "]", date_str, "→", full_url, "\n")
      
      tibble(year = entry$year, month = entry$month,
             month_url = entry$url, report_url = full_url,
             date = date_str, report_type = rtype, link_text = link_text)
    })
  })
}


# ── Steps 3 & 4: Extract images and table ────────────────────────────────────

extract_report_content <- function(report_url) {
  empty <- list(images = character(0), table_rows = list(), raw_text = "")
  if (is.na(report_url)) return(empty)
  
  Sys.sleep(SLEEP)
  soup <- fetch_page(report_url)
  if (is.null(soup)) return(empty)
  
  content_divs <- soup |> html_elements("div.row div.text_com")
  if (length(content_divs) == 0)
    content_divs <- soup |> html_elements("div.text_com")
  
  images     <- character(0)
  table_rows <- list()
  raw_text   <- ""
  
  for (div in content_divs) {
    img_srcs <- div |> html_elements("img[src]") |> html_attr("src")
    img_urls <- map_chr(img_srcs, ~ resolve_url(report_url, .x))
    images   <- unique(c(images, img_urls))
    
    for (tbody in html_elements(div, "tbody")) {
      for (row in html_elements(tbody, "tr")) {
        cells <- row |> html_elements("td, th") |> html_text(trim = TRUE)
        if (any(nzchar(cells))) table_rows <- c(table_rows, list(cells))
      }
    }
    
    raw_text <- paste0(raw_text, html_text(div, trim = TRUE), "\n")
  }
  
  cat("    →", length(images), "images |", length(table_rows), "table rows\n")
  list(images = images, table_rows = table_rows, raw_text = raw_text)
}


# ── Image downloader ──────────────────────────────────────────────────────────

download_images <- function(image_urls, date_str, idx) {
  if (length(image_urls) == 0) return(character(0))
  
  folder_name <- safe_name(
    if (!is.na(date_str) && nzchar(date_str)) date_str else paste0("unknown_", idx)
  )
  folder <- file.path(IMG_DIR, folder_name)
  dir_create(folder)
  
  map_chr(seq_along(image_urls), function(i) {
    url  <- image_urls[i]
    ext  <- tools::file_ext(basename(strsplit(url, "\\?")[[1]][1]))
    if (!nzchar(ext)) ext <- "jpg"
    fp   <- file.path(folder, sprintf("img_%02d.%s", i, ext))
    
    if (file_exists(fp)) return(fp)
    
    Sys.sleep(0.5)
    tryCatch({
      GET(url, user_agent(UA), timeout(20), write_disk(fp, overwrite = TRUE)) |>
        stop_for_status()
      cat("      [img] saved →", fp, "\n")
      fp
    }, error = function(e) {
      message("      [img ERROR] ", url, " → ", conditionMessage(e))
      NA_character_
    })
  }) |> discard(is.na)
}


# ── Step 6: Build and save ────────────────────────────────────────────────────

build_and_save <- function(reports, all_contents) {
  
  main_rows <- map_dfr(seq_len(nrow(reports)), function(i) {
    r <- reports[i, ]
    c <- all_contents[[i]]
    
    table_str <- if (length(c$table_rows) > 0)
      paste(map_chr(c$table_rows, ~ paste(.x, collapse = " | ")), collapse = "\n")
    else ""
    
    tibble(
      year              = r$year,
      month             = r$month,
      date              = r$date,
      report_type       = r$report_type,
      report_url        = r$report_url,
      link_text         = r$link_text,
      n_images          = length(c$images),
      image_urls        = paste(c$images, collapse = " ; "),
      local_image_paths = paste(c$local_paths %||% character(0), collapse = " ; "),
      table_content     = table_str,
      raw_text_snippet  = str_trunc(c$raw_text, 600)
    )
  })
  
  # Warn about reports with no table
  no_table <- filter(main_rows, !nzchar(table_content))
  if (nrow(no_table) > 0) {
    cat("\n  ⚠", nrow(no_table), "reports had no table extracted:\n")
    pwalk(no_table, function(report_type, date, report_url, ...) {
      cat("   [", report_type, "]", date, "→", report_url, "\n")
    })
  }
  
  csv_path <- file.path(OUT_DIR, "anp_reports.csv")
  write_csv(main_rows, csv_path)
  cat("\n  ✓ Reports CSV →", csv_path, "(", nrow(main_rows), "rows)\n")
  
  # Image index
  img_rows <- map_dfr(seq_len(nrow(reports)), function(i) {
    r <- reports[i, ]; c <- all_contents[[i]]
    if (length(c$images) == 0) return(NULL)
    paths <- c$local_paths %||% rep(NA_character_, length(c$images))
    n     <- min(length(c$images), length(paths))
    tibble(date = r$date, report_type = r$report_type,
           report_url = r$report_url,
           image_url  = c$images[seq_len(n)],
           local_path = paths[seq_len(n)])
  })
  
  if (nrow(img_rows) > 0) {
    img_csv <- file.path(OUT_DIR, "anp_images_index.csv")
    write_csv(img_rows, img_csv)
    cat("  ✓ Images index →", img_csv, "(", nrow(img_rows), "images)\n")
  }
  
  main_rows
}


# ── Main ──────────────────────────────────────────────────────────────────────

cat(strrep("=", 60), "\n  ANP Scraper (R) v2\n", strrep("=", 60), "\n")

monthly_links <- get_monthly_links(YEARS)
reports       <- get_report_links(monthly_links)

cat("\n── Steps 3–5: Extracting report content ──\n")
all_contents <- map(seq_len(nrow(reports)), function(i) {
  r     <- reports[i, ]
  label <- if (!is.na(r$date)) r$date else paste(r$month, i)
  cat("\n  [", i, "/", nrow(reports), "]", label, "|",
      str_trunc(r$report_url %||% "NA", 70), "\n")
  content <- extract_report_content(r$report_url)
  content$local_paths <- download_images(content$images, r$date, i)
  content
})

cat("\n── Step 6: Saving ──\n")
df <- build_and_save(reports, all_contents)

cat("\n✓ Done. Output:", normalizePath(OUT_DIR), "\n")
cat("  Rows:", nrow(df), "\n")

# create a file
dir.create("anp_output", showWarnings = FALSE)

# save CSVs again
df <- build_and_save(reports, all_contents)

# ============================================================
#  ANP Report Cleaner & Table Extractor
#  Reads anp_reports.csv, deduplicates, extracts all numeric
#  table values into clean English-labelled columns
setwd("C:/Users/Sophia Hiss/Desktop/Sophia Daten/AA Uni/Master/MIA/courses/Spring26/Data Journalism/final-data-project-sophia")
library(tidyverse)

# ── Load ──────────────────────────────────────────────────────

df_raw <- read_csv("anp_output/anp_reports.csv", show_col_types = FALSE)
df_raw <- read_csv(
  "anp_output/anp_reports.csv",
  col_types = cols(date = col_character()),
  show_col_types = FALSE
)
cat("Raw rows:", nrow(df_raw), "\n")
problems(df_raw)
nrow(df_raw)

# ── Step 1: Deduplicate ───────────────────────────────────────
# Each report appears twice: once with full title, once with "معرفة المزيد"
# Keep the row with the real title (longer link_text)

df <- df_raw |>
  filter(link_text != "معرفة المزيد") |>
  distinct(date, report_url, .keep_all = TRUE) |>
  mutate(date = as.Date(date, format = "%Y-%m-%d")) |>  # ungültige Daten werden NA
  filter(!is.na(date)) |>                               # NA rausfiltern
  arrange(date)

cat("Clean rows after dedup:", nrow(df), "\n")
cat("Date range:", min(df$date, na.rm = TRUE), "to", max(df$date, na.rm = TRUE), "\n\n")
format(min(df$date))
format(max(df$date))

# ── Step 2: Arabic → English keyword lookup ───────────────────
# Maps Arabic table row labels to clean English column names
# Handles slight variations in wording across reports

keyword_map <- list(
  
  # ── Counter-terrorism ──
  terrorists_surrendered       = c("إرهابيون سلموا أنفسهم", "إرهابي سلّم نفسه"),
  terrorist_supporters_arrested = c("توقيف عناصر دعم للجماعات الإرهابية",
                                    "عناصر دعم للجماعات الإرهابية"),
  kalashnikovs_seized          = c("ضبط مسدسات رشاشة من نوع كلاشنيكوف",
                                   "مسدسات رشاشة من نوع كلاشنيكوف"),
  
  # ── Border protection / smuggling ──
  drug_dealers_arrested        = c("توقيف تجار مخدرات", "تجار مخدرات"),
  cannabis_kg                  = c("حجز كيف معالج", "كيف معالج"),
  psychotropic_pills           = c("حجز أقراص مهلوسة", "أقراص مهلوسة"),
  cocaine_kg                   = c("حجز مادة الكوكايين", "مادة الكوكايين"),
  heroin_kg                    = c("حجز مادة الهيروين", "مادة الهيروين"),
  
  # ── Illegal gold mining ──
  gold_mining_arrested         = c("التهريب والتنقيب غير الشرعي عن الذهب",
                                   "التنقيب غير الشرعي عن الذهب",
                                   "تهريب وتنقيب غير شرعي عن الذهب"),
  firearms_seized              = c("حجز أسلحة نارية", "أسلحة نارية"),
  generators_seized            = c("حجز مولدات كهربائية", "مولدات كهربائية"),
  pressure_hammers_seized      = c("حجز مطارق ضغط", "مطارق ضغط"),
  metal_detectors_seized       = c("حجز أجهزة الكشف عن المعادن",
                                   "أجهزة الكشف عن المعادن",
                                   "أجهزة كشف عن المعادن"),
  fuel_litres_seized           = c("حجز كميات من الوقود", "كميات من الوقود"),
  vehicles_seized              = c("حجز مركبات", "مركبات"),
  tobacco_quintals_seized      = c("حجز مادة التبغ", "كميات من مادة التبغ",
                                   "مادة التبغ"),
  food_tonnes_seized           = c("حجز مواد غذائية موجهة للتهريب",
                                   "مواد غذائية موجهة للتهريب"),
  hunting_rifles_seized        = c("حجز بنادق صيد", "بنادق صيد"),
  
  # ── Irregular migration ──
  migrants_boats_arrested      = c("توقيف مهاجرين غير شرعيين على متن قوارب",
                                   "إنقاذ مهاجرين غير شرعيين على متن قوارب",
                                   "مهاجرين غير شرعيين على متن قوارب تقليدية الصنع"),
  migrants_various_arrested    = c("توقيف مهاجرين من جنسيات مختلفة",
                                   "مهاجرين من جنسيات مختلفة")
)


# ── Step 3: Extraction function ───────────────────────────────

# Clean a number string: remove Arabic thousands separators,
# normalise decimal separator, handle leading zeros
clean_number <- function(x) {
  x <- str_trim(x)
  # Remove Arabic-style thousands dots: 1.911.257 → 1911257
  # But keep if it looks like a decimal (only one dot + ≤3 digits after)
  if (str_count(x, "\\.") > 1) {
    x <- str_remove_all(x, "\\.")   # multiple dots = thousands separator
  }
  # Replace comma decimal separator with dot
  x <- str_replace(x, ",", ".")
  # Remove any remaining non-numeric except dot and minus
  x <- str_remove_all(x, "[^0-9\\.-]")
  suppressWarnings(as.numeric(x))
}

# Extract a value for one keyword group from a table_content string
extract_value <- function(table_content, arabic_terms) {
  if (is.na(table_content) || !nzchar(table_content)) return(NA_real_)
  
  lines <- str_split(table_content, "\n")[[1]]
  
  for (term in arabic_terms) {
    # Find line(s) containing this term
    matching <- lines[str_detect(lines, fixed(term))]
    if (length(matching) == 0) next
    
    # Value is after the last | in the matched line
    # But sometimes the label spans two lines and value is on next line
    for (line in matching) {
      parts <- str_split(line, "\\|")[[1]]
      val_str <- str_trim(tail(parts, 1))
      if (nzchar(val_str) && str_detect(val_str, "[0-9]")) {
        return(clean_number(val_str))
      }
    }
    
    # If value not found on same line, check the line immediately after
    for (i in seq_along(lines)) {
      if (str_detect(lines[i], fixed(term))) {
        if (i < length(lines)) {
          next_line <- str_trim(lines[i + 1])
          parts <- str_split(next_line, "\\|")[[1]]
          val_str <- str_trim(tail(parts, 1))
          if (nzchar(val_str) && str_detect(val_str, "[0-9]")) {
            return(clean_number(val_str))
          }
        }
      }
    }
  }
  NA_real_
}


# ── Step 4: Apply to all rows ─────────────────────────────────

cat("Extracting numeric columns...\n")

extracted <- map_dfr(seq_len(nrow(df)), function(i) {
  tc <- df$table_content[i]
  map(keyword_map, ~ extract_value(tc, .x)) |> as_tibble()
})

# Bind extracted columns to clean metadata
df_final <- df |>
  select(date, report_type, report_url, n_images,
         link_text, image_urls, local_image_paths,
         raw_text_snippet) |>
  bind_cols(extracted)

cat("Done. Columns:", ncol(df_final), "\n")


# ── Step 5: Quick summary ─────────────────────────────────────

cat("\n── Coverage (non-NA per column) ──\n")
df_final |>
  select(all_of(names(keyword_map))) |>
  summarise(across(everything(), ~ sum(!is.na(.)))) |>
  pivot_longer(everything(), names_to = "variable", values_to = "n_reports") |>
  mutate(pct = round(n_reports / nrow(df_final) * 100)) |>
  arrange(desc(n_reports)) |>
  print(n = 30)

cat("\n── Sample: gold mining arrests over time ──\n")
df_final |>
  select(date, report_type, gold_mining_arrested) |>
  filter(!is.na(gold_mining_arrested)) |>
  print(n = 10)

cat("\n── Sample: irregular migrants arrested over time ──\n")
df_final |>
  select(date, migrants_boats_arrested, migrants_various_arrested) |>
  filter(!is.na(migrants_boats_arrested) | !is.na(migrants_various_arrested)) |>
  print(n = 100)


# ── Step 6: Save ──────────────────────────────────────────────

write_csv(df_final, "anp_output/anp_clean.csv")
cat("\n✓ Saved → anp_output/anp_clean.csv\n")
cat("  Rows:", nrow(df_final), "\n")
cat("  Columns:", ncol(df_final), "\n")

df_clean <- read_csv("static/data/anp_output/anp_clean.csv",
                     col_types = cols(date = col_character()))

# ── Step 7: Data Exploration  ──────────────────────────────────────────────

View(df_clean)
names(df_clean)

df_clean |>
  summarise(
    migrants_total     = sum(migrants_various_arrested, na.rm=TRUE) + sum(migrants_boats_arrested, na.rm=TRUE),
    cannabis_total_kg  = sum(cannabis_kg, na.rm=TRUE),
    cocaine_total_kg   = sum(cocaine_kg, na.rm=TRUE),
    pills_total        = sum(psychotropic_pills, na.rm=TRUE),
    gold_arrested      = sum(gold_mining_arrested, na.rm=TRUE),
    metal_detectors    = sum(metal_detectors_seized, na.rm=TRUE),
    generators         = sum(generators_seized, na.rm=TRUE),
    terrorists_surr    = sum(terrorists_surrendered, na.rm=TRUE),
    terror_support     = sum(terrorist_supporters_arrested, na.rm=TRUE),
    kalashnikovs       = sum(kalashnikovs_seized, na.rm=TRUE),
    firearms           = sum(firearms_seized, na.rm=TRUE),
    hunting_rifles     = sum(hunting_rifles_seized, na.rm=TRUE)
  ) |>
  pivot_longer(everything(), names_to = "variable", values_to = "total") |>
  print(n = 20)


df_locations <- read_csv("static/data/anp_output/anp_image_locations.csv",
                         col_types = cols(date = col_character()))
df_locations |>
  filter(!is.na(lat)) |>
  count(sector_en, military_region_en, lat, lon, sort=TRUE) |>
  print(n=50)

df_locations <- df_locations |>
  mutate(
    lon = ifelse(sector_en == "Oum El Bouaghi, Algeria", 7.1136, lon),
    lat = ifelse(sector_en == "Oum El Bouaghi, Algeria", 35.8686, lat)
  )

write_csv(df_locations, "static/data/anp_output/anp_image_locations.csv")
df_locations <- df_locations |>
  mutate(
    lat = ifelse(sector_en == "Oum El Bouaghi, Algeria", 35.8686, lat),
    lon = ifelse(sector_en == "Oum El Bouaghi, Algeria", 7.1136, lon),
    lat = ifelse(sector_en == "Tamanrasset, Algeria" & lon > 5.6, 22.7851, lat),
    lon = ifelse(sector_en == "Tamanrasset, Algeria" & lon > 5.6, 5.5228, lon),
    sector_en = ifelse(sector_en == "0 Algeria", NA_character_, sector_en),
    sector_en = ifelse(str_detect(coalesce(sector_en, ""), "عض"), NA_character_, sector_en),
    lat = ifelse(is.na(sector_en), NA_real_, lat),
    lon = ifelse(is.na(sector_en), NA_real_, lon)
  )

write_csv(df_locations, "static/data/anp_output/anp_image_locations.csv")
cat("Clean locations with coords:", sum(!is.na(df_locations$lat)), "\n")

df_locations <- read_csv("static/data/anp_output/anp_image_locations.csv",
                         col_types = cols(date = col_character()))

df_locations |>
  filter(!is.na(lat)) |>
  count(sector_en, military_region_en, lat, lon, sort=TRUE) |>
  print(n=50)

# Find best images per theme by matching dates with locations
df_locations |>
  filter(!is.na(lat)) |>
  select(date, image_file, sector_en, military_region_en, lat, lon, image_path) |>
  filter(sector_en %in% c(
    "Tamanrasset, Algeria",
    "Bordj Badji Mokhtar, Algeria", 
    "Illizi, Algeria",
    "El Oued, Algeria",
    "Ouargla, Algeria",
    "Tebessa, Algeria",
    "Adrar, Algeria",
    "Batna, Algeria",
    "Khenchela, Algeria",
    "Constantine, Algeria",
    "Skikda, Algeria",
    "Annaba, Algeria"
  )) |>
  arrange(sector_en, date) |>
  select(sector_en, date, image_path) |>
  print(n = 100)

df_locations |>
  filter(!is.na(lat)) |>
  filter(sector_en %in% c(
    "Tamanrasset, Algeria", "Bordj Badji Mokhtar, Algeria",
    "Illizi, Algeria", "El Oued, Algeria", "Ouargla, Algeria",
    "Tebessa, Algeria", "Adrar, Algeria", "Batna, Algeria",
    "Khenchela, Algeria", "Constantine, Algeria",
    "Skikda, Algeria", "Annaba, Algeria"
  )) |>
  group_by(sector_en) |>
  slice(1) |>
  ungroup() |>
  select(sector_en, date, image_path) |>
  mutate(image_path = str_replace(image_path, "static", "/")) |>
  print(n = 20, width = 120)

setwd("C:/Users/Sophia Hiss/Desktop/Sophia Daten/AA Uni/Master/MIA/courses/Spring26/Data Journalism/final-data-project-sophia")
imgs <- list.files("public/data/anp_output/images", 
                   recursive = TRUE, full.names = TRUE)
total_mb <- sum(file.size(imgs)) / 1024^2
cat("Anzahl Bilder:", length(imgs), "\n")
cat("Gesamt:", round(total_mb, 1), "MB\n")


## Location - Operation correlation 

df_clean <- read_csv("C:/Users/Sophia Hiss/Desktop/Sophia Daten/AA Uni/Master/MIA/courses/Spring26/Data Journalism/final-data-project-sophia/public/data/anp_output/anp_clean.csv",
                     col_types = cols(date = col_character()))
df_clean |>
  summarise(
    total = n(),
    has_text = sum(!is.na(raw_text_snippet)),
    avg_length = mean(nchar(raw_text_snippet), na.rm = TRUE)
  )

locations <- c(
  "تمنراست" = "Tamanrasset",
  "برج باجي مختار" = "Bordj Badji Mokhtar", 
  "إن صالح" = "In Salah",
  "إن قزام" = "In Guezzam",
  "إليزي" = "Illizi",
  "الوادي" = "El Oued",
  "ورقلة" = "Ouargla",
  "تبسة" = "Tebessa",
  "باتنة" = "Batna",
  "خنشلة" = "Khenchela",
  "قسنطينة" = "Constantine",
  "عنابة" = "Annaba",
  "سكيكدة" = "Skikda",
  "أدرار" = "Adrar",
  "غرداية" = "Ghardaia",
  "الأغواط" = "Laghouat",
  "تقرت" = "Touggourt",
  "بسكرة" = "Biskra",
  "سطيف" = "Setif",
  "بجاية" = "Bejaia"
)

themes <- list(
  terrorism = c("إرهاب", "إرهابي", "تسليم", "كلاشنيكوف", "مجموعة مسلحة"),
  drugs     = c("مخدرات", "كيف", "كوكايين", "أقراص مخدرة", "مهرب"),
  gold      = c("ذهب", "تنقيب", "مولد", "مطرقة", "كاشف معادن"),
  weapons   = c("أسلحة", "بندقية", "مسدس", "ذخيرة"),
  migration = c("مهاجر", "هجرة", "قارب", "غير شرعي")
)

results <- df_clean |>
  select(date, raw_text_snippet) |>
  filter(!is.na(raw_text_snippet)) |>
  rowwise() |>
  mutate(
    locs_found   = list(names(locations)[str_detect(raw_text_snippet, names(locations))]),
    themes_found = list(names(themes)[map_lgl(themes, ~any(str_detect(raw_text_snippet, .x)))])
  ) |>
  filter(length(locs_found) > 0, length(themes_found) > 0) |>
  unnest(locs_found) |>
  unnest(themes_found) |>
  mutate(location_en = locations[locs_found]) |>
  select(date, location_ar = locs_found, location_en, theme = themes_found)

results |>
  count(location_en, theme, sort = TRUE) |>
  print(n = 200)

summary_df <- results |>
  count(location_en, theme, sort = TRUE)

print(summary_df, n = 40)

write_csv(results, "public/data/anp_output/anp_location_themes.csv")
write_csv(summary_df, "public/data/anp_output/anp_location_themes_summary.csv")
cat("Saved.\n")


