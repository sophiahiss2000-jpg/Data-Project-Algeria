# Tracking Algerian Military Activity
### A Data Journalism Investigation — Spring 2026

A scrollytelling investigation built with **Svelte**, **MapLibre GL JS**, and **satellite imagery**, analysing an original dataset of 143 weekly operational reports published by Algeria's Armée Nationale Populaire (ANP) between January 2024 and October 2025.

🔗 **Live:** https://sophiahiss2000-jpg.github.io/Data-Project-Algeria/
---

## License

This project uses a dual license:

**Code & Pipeline** — all `.html`, `.css`, `.js`, `.svelte`, `.R` files and build scripts are licensed under the [MIT License](LICENSE-CODE).
You are free to use, copy, modify, and distribute the code with attribution.

**Article Content & Data** — the article text, data visualisations, charts, and all datasets (`.csv`, `.geojson`) are licensed under [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/).
You may share the content with attribution, but you may not remix it, adapt it, or use it commercially. Quotation with attribution is permitted under fair use.

> © 2026 Sophia Hiss. The underlying data was collected from primary sources by the author.

---

## The Dataset

This project is built on an **original dataset** assembled from primary sources. No pre-existing dataset was used.

**Data collection pipeline:**

| Step | Method | Output |
|---|---|---|
| Web scraping | R (`rvest`, `httr`) | 143 weekly ANP reports scraped from [mdn.dz](https://www.mdn.dz) |
| Table extraction | Arabic keyword matching | 28-column CSV with arrests/seizures per category |
| Image downloading | Automated via scraper | 1,110 press images |
| Image geolocation | OCR (Tesseract Arabic) + OpenStreetMap Nominatim | Coordinates for 133 images |
| Full-text scraping | Second-pass scraper | Complete Arabic report texts |
| Text mining | Paragraph-level Arabic keyword matching | Location-theme frequency table |

## Spatial Data

Wilaya administrative boundaries are based on the Algeria COD-AB dataset provided by the United Nations Office for the Coordination of Humanitarian Affairs (OCHA) through the Humanitarian Data Exchange (HDX):

https://data.humdata.org/dataset/cod-ab-dza

The military regions visualised in this project are not official polygons but were reconstructed by grouping wilayas according to the publicly documented territorial jurisdictions of Algeria's six military regions.

**Key figures (Jan 2024 – Oct 2025):**
- 54,769 migrants arrested
- 35,658 people arrested for illegal gold mining
- 58 million psychotropic pills seized
- 23,639 kg cannabis seized
- 7,306 kg cocaine seized
- 56 terrorists surrendered; 1,158 support network members arrested
- 981 firearms seized

---

## Content Warning

This repository contains press images downloaded directly from the Algerian Ministry of Defence website. These images are unfiltered official military documentation and include graphic content — among them photographs of killed individuals, human remains, and victims of violence. Viewer discretion is strongly advised.

The author has not selected, staged or edited these images. They are reproduced as published by the ANP for the purposes of journalistic documentation.

## Methodology & Limitations

### What the data shows
The ANP weekly reports contain structured tables with operational statistics and prose descriptions of where operations took place. The dataset captures all reports published in Arabic during the 22-month period.

### Limitations
- **No location attribution for statistics:** The ANP reports aggregate numbers nationally. Drug seizure quantities and gold mining arrests cannot be attributed to specific cities from the structured data alone.
- **Location-theme matching is text-based:** City mentions in report texts are matched at paragraph level. Because Bordj Badji Mokhtar, Tamanrasset, Illizi and In Guezzam are routinely listed together in the gold mining paragraph, co-occurrence does not imply exclusive association.
- **OCR accuracy:** Arabic OCR via Tesseract produces misreads for some city names. Known errors were patched manually; unknown errors may remain.
- **Coverage:** Reports run January 2024 to October 2025. Earlier periods are not included.

---

## Avenues for Future Research

### LLM-based image analysis
The 1,110 ANP press images could be passed through a vision-capable LLM (e.g. Claude, GPT-4o) with a structured prompt to identify equipment visible in each image — generators, metal detectors, drug packages, weapons, migrants. Combined with the geolocation data already extracted, this would produce a precise `location | equipment_type | date` dataset that circumvents the text-attribution problem entirely. At approximately $0.01 per image, the full corpus would cost around $11 to process.

### Longitudinal trend analysis
With a second scraping run covering 2022-2023, it would be possible to test whether gold mining arrest rates correlate with gold price fluctuations, or whether terrorism operation tempo tracks regional events in Mali and Libya.

### Cross-referencing with NGO data
Systematic cross-referencing of ANP migration arrest figures with Alarm Phone Sahara incident reports could shed light on the gap between official arrest statistics and documented expulsions.

## Project Structure

```
src/
├── App.svelte              <- Main article + scroll logic
├── main.js                 <- Entry point
└── lib/
    └── Map.svelte          <- MapLibre GL sticky map + camera steps

public/
└── data/
    ├── dza_admin1.geojson  <- Algeria wilaya polygons from OCHA HDX COD-AB, grouped into military regions
    └── anp_output/
        ├── anp_clean.csv                      <- 143 reports, 28 numeric columns + full text
        ├── anp_image_locations.csv            <- 1,110 images with OCR-derived coordinates
        ├── anp_location_themes.csv            <- Raw location-theme mentions
        ├── anp_location_themes_summary.csv    <- Aggregated location-theme mentions
        └── images/                            <- 1,110 downloaded ANP press images

R scripts:
├── anp_scraper.R           <- Web scraper (numbers + images)
├── anp_ocr_geo.R           <- Image OCR + geolocation
└── anp_text_comm.R         <- Full report text re-scraper
```

---

## AI Disclosure

This project used AI assistance (Claude, Anthropic) during development for:
- Debugging R scraping and OCR scripts
- Writing and iterating on Svelte/MapLibre GL components
- Advising on text-mining methodology

All data collection, analysis decisions, editorial framing, and interpretations are the author's own. The underlying dataset was assembled entirely from primary sources by the author. AI tools did not access, generate, or modify the raw data.

---

## Dependencies

| Package | Purpose |
|---|---|
| `svelte` | UI framework |
| `vite` + `@sveltejs/vite-plugin-svelte` | Build tooling |
| `maplibre-gl` | Map rendering (WebGL) |
| `maptiler` | Satellite + hybrid map tiles |

**R packages:** `rvest`, `httr`, `tidyverse`, `tesseract`, `tidygeocoder`, `fs`

---

## Attribution

Map tiles © [MapTiler](https://www.maptiler.com) & [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors. Built with [MapLibre GL JS](https://maplibre.org/). Data source: [Algerian Ministry of National Defence](https://www.mdn.dz).