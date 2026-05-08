<script>
  import { onMount, onDestroy } from 'svelte';
  import maplibregl from 'maplibre-gl';
  import 'maplibre-gl/dist/maplibre-gl.css';

  export let step = 0;

  let mapContainer;
  let map;
  let initialized = false;
  let markers = [];

  const steps = [
    { center: [2.6323, 28.0339], zoom: 4.0, pitch: 0,  bearing: 0   }, // 0 intro
    { center: [5.5228, 22.7851], zoom: 9,   pitch: 40, bearing: -10 }, // 1 terrorism: tamanrasset
    { center: [0.9503, 21.3298], zoom: 10,  pitch: 35, bearing: 5   }, // 2 terrorism: bordj
    { center: [5.7693, 19.5662], zoom: 9, pitch: 40, bearing: 10 },    // 3 terrorism: In Guezzam
    { center: [2.6323, 28.0339], zoom: 4.5, pitch: 0,  bearing: 0   }, // 4 overview
    { center: [6.8607, 33.3612], zoom: 10,  pitch: 35, bearing: -5  }, // 5 drugs: el oued
    { center: [5.3218, 31.9445], zoom: 10,  pitch: 30, bearing: 10  }, // 6 drugs: ouargla
    { center: [8.1212, 35.4036], zoom: 10,  pitch: 35, bearing: -8  }, // 7 drugs: tebessa
    { center: [5.5228, 22.7851], zoom: 8,   pitch: 45, bearing: 15  }, // 8 gold: tamanrasset
    { center: [8.4799, 26.5042], zoom: 9,   pitch: 40, bearing: -5  }, // 9 gold: illizi
    { center: [9.4844, 24.5553], zoom: 9, pitch: 35, bearing: 5 },     // 10 gold: djanet
    { center: [6.1768, 35.5545], zoom: 11,  pitch: 40, bearing: -10 }, // 11 weapons: batna
    { center: [7.1457, 35.4302], zoom: 11,  pitch: 35, bearing: 8   }, // 12 weapons: khenchela
    { center: [6.6084, 36.3642], zoom: 10,  pitch: 30, bearing: -5  }, // 13 weapons: constantine
    { center: [2.6323, 24.0000], zoom: 5,   pitch: 0,  bearing: 0   }, // 14 migration overview
    { center: [5.5228, 22.7851], zoom: 8,   pitch: 40, bearing: 10  }, // 15 migration: tamanrasset
    { center: [-0.6417, 35.6969], zoom: 11, pitch: 45, bearing: -10 }, // 16 migration: Oran
    { center: [7.7549, 36.8982], zoom: 11,  pitch: 40, bearing: 5   }, // 17 migration: annaba
  ];

  const pois = [
    { id: 'tamanrasset', coords: [5.5228, 22.7851],  label: 'Tamanrasset',          steps: [1,8,9,15] },
    { id: 'bordj',       coords: [0.9503, 21.3298],  label: 'Bordj Badji Mokhtar',  steps: [2] },
    { id: 'In Guezzam',  coords: [5.7693, 19.5662],  label: 'In Guezzam',           steps: [3,9,10] },
    { id: 'eloued',      coords: [6.8607, 33.3612],  label: 'El Oued',              steps: [5] },
    { id: 'ouargla',     coords: [5.3218, 31.9445],  label: 'Ouargla',              steps: [6] },
    { id: 'tebessa',     coords: [8.1212, 35.4036],  label: 'Tebessa',              steps: [7] },
    { id: 'djanet',      coords: [9.4844, 24.5553], label: 'Djanet',                steps: [10] },
    { id: 'batna',       coords: [6.1768, 35.5545],  label: 'Batna',                steps: [11] },
    { id: 'khenchela',   coords: [7.1457, 35.4302],  label: 'Khenchela',            steps: [12] },
    { id: 'constantine', coords: [6.6084, 36.3642],  label: 'Constantine',          steps: [13] },
    { id: 'oran', coords: [-0.6417, 35.6969], label: 'Oran', steps: [16] },
    { id: 'annaba',      coords: [7.7549, 36.8982],  label: 'Annaba',               steps: [17] },
  ];

  function flyToStep(s) {
    if (!map || s < 0 || s >= steps.length) return;
    map.flyTo({ ...steps[s], duration: 2200, essential: true });
    updateMarkers(s);
  }

  function updateMarkers(s) {
    markers.forEach(({ marker, poi }) => {
      marker.getElement().classList.toggle('visible', poi.steps.includes(s));
    });
  }

  onMount(() => {
    map = new maplibregl.Map({
      container: mapContainer,
      style: `https://api.maptiler.com/maps/hybrid/style.json?key=7TyXJh8hnKEgTbuQzBEc`,
      center: steps[0].center,
      zoom: steps[0].zoom,
      pitch: 0, bearing: 0,
      interactive: false,
      attributionControl: false,
    });

    map.addControl(new maplibregl.AttributionControl({ compact: true }), 'bottom-left');

    map.on('load', () => {
      initialized = true;

      // Algeria border
      map.addSource('algeria', {
        type: 'geojson',
        data: {
          type: 'Feature',
          geometry: {
            type: 'Polygon',
            coordinates: [[
              [-8.7, 37.1], [9.0, 37.2], [9.5, 30.3], [9.5, 23.0],
              [5.8, 19.4],  [3.2, 19.1], [0.15, 14.9],[-4.8, 19.9],
              [-8.7, 27.7], [-8.7, 37.1]
            ]]
          }
        }
      });

      map.addLayer({ id: 'algeria-fill', type: 'fill', source: 'algeria',
        paint: { 'fill-color': '#c8a96e', 'fill-opacity': 0.06 } });
      map.addLayer({ id: 'algeria-line', type: 'line', source: 'algeria',
        paint: { 'line-color': '#c8a96e', 'line-width': 1.5, 'line-opacity': 0.5 } });

      // POI markers
      pois.forEach(poi => {
        const el = document.createElement('div');
        el.className = 'map-marker';
        el.innerHTML = `<div class="marker-dot"></div><div class="marker-label">${poi.label}</div>`;
        const marker = new maplibregl.Marker({ element: el, anchor: 'center' })
          .setLngLat(poi.coords).addTo(map);
        markers.push({ marker, poi });
      });

      flyToStep(step);
    });
  });

  $: if (initialized && map) flyToStep(step);

  onDestroy(() => { if (map) map.remove(); });
</script>

<div class="map-wrap" bind:this={mapContainer}></div>

<style>
  .map-wrap { width: 100%; height: 100%; }

  :global(.map-marker) {
    display: flex; flex-direction: column; align-items: center; gap: 4px;
    opacity: 0; transform: scale(0.6);
    transition: opacity 0.5s ease, transform 0.5s ease;
    pointer-events: none;
  }
  :global(.map-marker.visible) { opacity: 1; transform: scale(1); }

  :global(.marker-dot) {
    width: 10px; height: 10px; border-radius: 50%;
    background: #e05c3a; border: 2px solid #fff;
    box-shadow: 0 0 0 3px rgba(224,92,58,0.35);
  }
  :global(.marker-label) {
    font-family: Georgia, serif; font-size: 11px; font-weight: 600;
    color: #fff; background: rgba(15,15,20,0.78);
    padding: 2px 7px; border-radius: 3px;
    white-space: nowrap; letter-spacing: 0.04em;
    backdrop-filter: blur(4px);
  }
</style>
