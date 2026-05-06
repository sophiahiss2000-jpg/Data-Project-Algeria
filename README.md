# Algeria Scrollytelling — Svelte + MapLibre GL

A Bellingcat-style scrollytelling article template built with **Svelte**, **MapLibre GL JS** (no API key needed), and **svelte-scroller**.

---

## Quick Start

```bash
npm install
npm run dev
```

Open http://localhost:5173

---

## Project Structure

```
src/
├── App.svelte          ← Main article layout + scroll logic
├── main.js             ← Entry point
└── lib/
    ├── Map.svelte      ← MapLibre GL sticky map + camera steps
    └── InfoBox.svelte  ← Three info panel types: text, stat, chart
```

---

## How the Scrollytelling Works

### The Scroller (`svelte-scroller`)

`<Scroller>` from `svelte-scroller` tracks which section is in the viewport and exposes:

- `index` — index of the currently active `<section>` in the foreground
- `offset` — 0–1 progress within the current section
- `progress` — 0–1 overall progress through all sections

The **background slot** holds the sticky map. The **foreground slot** holds all scrolling content.

### Map Steps

In `Map.svelte`, the `steps` array defines each camera position:

```js
const steps = [
  { center: [2.63, 28.03], zoom: 4.5, pitch: 0,  bearing: 0  },  // 0 — full Algeria
  { center: [3.06, 36.75], zoom: 10,  pitch: 40, bearing: -10 },  // 1 — Algiers
  { center: [-8.14, 27.67], zoom: 10, pitch: 30, bearing: 15  },  // 2 — Tindouf
  // …and so on
];
```

### Mapping Scroll Sections → Map Steps

In `App.svelte`, the `indexToMapStep` array maps each scroll section index to a camera step:

```js
const indexToMapStep = [0, 1, 1, 1, 2, 2, 2, 3, 3, 4, 4, 4, 5, 5, 6, 6];
//                      ^intro  ^algiers×3  ^tindouf×3  ^overview×2  ^bordj×3  ^guezzam×2  ^coast×2
```

This means you can have multiple scroll sections (text, info boxes, charts) all showing the same map view — the map only moves when the index crosses a boundary.

---

## Customising

### Adding a New Camera Position

1. Add an entry to `steps[]` in `Map.svelte`:
   ```js
   { center: [lon, lat], zoom: 12, pitch: 45, bearing: 0 }
   ```

2. Add a new section in `App.svelte` foreground:
   ```svelte
   <section class="scroll-section" data-index="N">
     <div class="prose-block">
       <span class="section-tag">Stop XX — Label</span>
       <h2>City Name</h2>
       <p>Your text here.</p>
     </div>
   </section>
   ```

3. Update `indexToMapStep` to include the new step index.

### InfoBox Types

#### Text box
```svelte
<InfoBox type="text" visible={showInfo.myKey}>
  <span class="label">Label text</span>
  <p>Your paragraph with <strong>highlights</strong>.</p>
</InfoBox>
```

#### Stat box
```svelte
<InfoBox type="stat" visible={showInfo.myKey} stats={[
  { value: '3.9M', label: 'Population' },
  { value: '47yrs', label: 'Since founding' },
]} />
```

#### Bar chart
```svelte
<InfoBox
  type="chart"
  visible={showInfo.myKey}
  chartTitle="My chart title"
  chartData={[
    { label: 'Category A', pct: 85, value: '85%' },
    { label: 'Category B', pct: 60, value: '60%' },
  ]}
/>
```

### Changing the Map Style

In `Map.svelte`, change the `style` option:

```js
// Free options (no API key):
style: 'https://basemaps.cartocdn.com/gl/dark-matter-gl-style/style.json'   // dark
style: 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json'       // light
style: 'https://basemaps.cartocdn.com/gl/voyager-gl-style/style.json'        // colour

// With Mapbox token (higher detail):
style: 'mapbox://styles/mapbox/satellite-streets-v12'
```

### Adding / Removing POI Markers

Edit the `pois` array in `Map.svelte`:

```js
const pois = [
  {
    id: 'myplace',
    coords: [lon, lat],
    label: 'Display Name',
    steps: [2, 3],   // visible during these map steps
  },
  // …
];
```

### Adding the Migration Route

The dashed red line in `Map.svelte` is a GeoJSON LineString. Update the `coordinates` array to match your actual route.

---

## Dependencies

| Package | Purpose |
|---|---|
| `svelte` | UI framework |
| `vite` + `@sveltejs/vite-plugin-svelte` | Build tooling |
| `maplibre-gl` | Free/open map rendering (WebGL) |
| `svelte-scroller` | Scroll position tracking |

No API keys required — uses CARTO's free basemap tiles.

---

## Tips for Production

- **Replace placeholder text** with your actual reporting
- **Add images** inside `.prose-block` with `<img>` tags
- **Animate the route** using MapLibre's line-dasharray animation trick
- **Add a progress bar** using the `progress` binding from `<Scroller>`
- **Lazy-load the map** if embedding in a CMS

---

## Attribution

Map tiles © [OpenStreetMap](https://www.openstreetmap.org/copyright) contributors, rendered by [CARTO](https://carto.com). Built with [MapLibre GL JS](https://maplibre.org/) and [svelte-scroller](https://github.com/sveltejs/svelte-scroller).
