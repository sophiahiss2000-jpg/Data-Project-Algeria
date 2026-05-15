<script>
  import { onMount, onDestroy } from 'svelte';
  import maplibregl from 'maplibre-gl';
  import 'maplibre-gl/dist/maplibre-gl.css';

  export let step = 0;

  let mapContainer;
  let map;
  let initialized = false;
  let markers = [];
  
  const militaryRegionStep = 18;

  const steps = [
    { center: [2.6323, 28.0339], zoom: 4.0, pitch: 0, bearing: 0 },
    { center: [5.5228, 22.7851], zoom: 9, pitch: 40, bearing: -10 },
    { center: [0.9503, 21.3298], zoom: 10, pitch: 35, bearing: 5 },
    { center: [5.7693, 19.5662], zoom: 9, pitch: 40, bearing: 10 },
    { center: [2.6323, 28.0339], zoom: 4.5, pitch: 0, bearing: 0 },
    { center: [6.8607, 33.3612], zoom: 10, pitch: 35, bearing: -5 },
    { center: [-0.6417, 35.6969], zoom: 10, pitch: 30, bearing: 10 },
    { center: [8.1212, 35.4036], zoom: 10, pitch: 35, bearing: -8 },
    { center: [5.5228, 22.7851], zoom: 8, pitch: 45, bearing: 15 },
    { center: [8.4799, 26.5042], zoom: 9, pitch: 40, bearing: -5 },
    { center: [9.4844, 24.5553], zoom: 9, pitch: 35, bearing: 5 },
    { center: [6.1768, 35.5545], zoom: 11, pitch: 40, bearing: -10 },
    { center: [7.1457, 35.4302], zoom: 11, pitch: 35, bearing: 8 },
    { center: [6.6084, 36.3642], zoom: 10, pitch: 30, bearing: -5 },
    { center: [2.6323, 24.0], zoom: 5, pitch: 0, bearing: 0 },
    { center: [5.5228, 22.7851], zoom: 8, pitch: 40, bearing: 10 },
    { center: [-0.6417, 35.6969], zoom: 11, pitch: 45, bearing: -10 },
    { center: [7.7549, 36.8982], zoom: 11, pitch: 40, bearing: 5 },
    { center: [2.6323, 28.0339], zoom: 4.5, pitch: 0, bearing: 0 }, 
  ];

  const pois = [
    { id: 'tamanrasset', coords: [5.5228, 22.7851], label: 'Tamanrasset', steps: [1, 8, 9, 15] },
    { id: 'bordj', coords: [0.9503, 21.3298], label: 'Bordj Badji Mokhtar', steps: [2] },
    { id: 'inguezzam', coords: [5.7693, 19.5662], label: 'In Guezzam', steps: [3, 9, 10] },
    { id: 'eloued', coords: [6.8607, 33.3612], label: 'El Oued', steps: [5] },
    { id: 'oran-drugs', coords: [-0.6417, 35.6969], label: 'Oran', steps: [6] },
    { id: 'tebessa', coords: [8.1212, 35.4036], label: 'Tebessa', steps: [7] },
    { id: 'djanet', coords: [9.4844, 24.5553], label: 'Djanet', steps: [10] },
    { id: 'batna', coords: [6.1768, 35.5545], label: 'Batna', steps: [11] },
    { id: 'khenchela', coords: [7.1457, 35.4302], label: 'Khenchela', steps: [12] },
    { id: 'constantine', coords: [6.6084, 36.3642], label: 'Constantine', steps: [13] },
    { id: 'oran-migration', coords: [-0.6417, 35.6969], label: 'Oran', steps: [16] },
    { id: 'annaba', coords: [7.7549, 36.8982], label: 'Annaba', steps: [17] }
  ];

  const regionByWilaya = {
    Alger: 'rm1',
    Blida: 'rm1',
    Medea: 'rm1',
    Médéa: 'rm1',
    Boumerdes: 'rm1',
    Boumerdès: 'rm1',
    Bouira: 'rm1',
    'Tizi Ouzou': 'rm1',
    Tipaza: 'rm1',
    Chlef: 'rm1',
    Djelfa: 'rm1',
    'Ain Defla': 'rm1',
    'Aïn Defla': 'rm1',
    Msila: 'rm1',
    "M'Sila": 'rm1',

    Oran: 'rm2',
    Tlemcen: 'rm2',
    'Sidi Bel Abbes': 'rm2',
    'Sidi Bel Abbès': 'rm2',
    Mostaganem: 'rm2',
    Tiaret: 'rm2',
    'Ain Temouchent': 'rm2',
    'Aïn Témouchent': 'rm2',
    Mascara: 'rm2',
    'El Bayadh': 'rm2',
    Naama: 'rm2',
    Naâma: 'rm2',
    Relizane: 'rm2',
    Tissemsilt: 'rm2',
    Saida: 'rm2',
    Saïda: 'rm2',

    Bechar: 'rm3',
    Béchar: 'rm3',
    Tindouf: 'rm3',
    Adrar: 'rm3',

    Ouargla: 'rm4',
    Laghouat: 'rm4',
    Illizi: 'rm4',
    'El Oued': 'rm4',
    Ghardaia: 'rm4',
    Ghardaïa: 'rm4',
    Biskra: 'rm4',

    Constantine: 'rm5',
    Annaba: 'rm5',
    Batna: 'rm5',
    Khenchela: 'rm5',
    'Souk Ahras': 'rm5',
    'Oum El Bouaghi': 'rm5',
    Bejaia: 'rm5',
    Béjaïa: 'rm5',
    'Bordj Bou Arreridj': 'rm5',
    Setif: 'rm5',
    Sétif: 'rm5',
    Jijel: 'rm5',
    Skikda: 'rm5',
    'El Tarf': 'rm5',
    Guelma: 'rm5',
    Mila: 'rm5',
    Tebessa: 'rm5',
    Tébessa: 'rm5',

    Tamanrasset: 'rm6'
  };

  function getWilayaName(feature) {
    return feature.properties.adm1_name;
  }

  function flyToStep(s) {
    if (!map || s < 0 || s >= steps.length) return;
    map.flyTo({ ...steps[s], duration: 2200, essential: true });
    updateMarkers(s);
  }
  markers.forEach(({ marker, poi }) => {
    marker.getElement().classList.toggle(
      'visible',
      poi.steps.includes(s)
    );
  });
  
  function updateMarkers(s) {
  markers.forEach(({ marker, poi }) => {
    const el = marker.getElement();

    if (s === militaryRegionStep) {
      el.style.display = 'none';
    } else {
      el.style.display = 'flex';
      el.classList.toggle('visible', poi.steps.includes(s));
    }
  });
}

  function showRegions(show) {
    if (!map || !initialized) return;
    if (!map.getLayer('military-regions-fill')) return;

    map.setLayoutProperty('military-regions-fill', 'visibility', show ? 'visible' : 'none');
    map.setLayoutProperty('military-regions-line', 'visibility', show ? 'visible' : 'none');

    map.setPaintProperty('military-regions-fill', 'fill-opacity', show ? 0.42 : 0);
    map.setPaintProperty('military-regions-line', 'line-opacity', show ? 0.85 : 0);
  }

   $: if (initialized && map) {
  flyToStep(step);
  updateMarkers(step);
  showRegions(step === militaryRegionStep);
  }

  onMount(() => {
    maplibregl.setRTLTextPlugin(
      'https://unpkg.com/@mapbox/mapbox-gl-rtl-text@0.3.0/dist/mapbox-gl-rtl-text.js',
      true
    );
    map = new maplibregl.Map({
      container: mapContainer,
      style: `https://api.maptiler.com/maps/hybrid/style.json?key=7TyXJh8hnKEgTbuQzBEc`,
      center: steps[0].center,
      zoom: steps[0].zoom,
      pitch: 0,
      bearing: 0,
      interactive: true,
      scrollZoom: false,
      dragPan: false,
      dragRotate: false,
      doubleClickZoom: false,
      touchZoomRotate: false,
      keyboard: false,
      attributionControl: false
      
    });

    map.addControl(new maplibregl.AttributionControl({ compact: true }), 'bottom-left');
    map.addControl(
          new maplibregl.NavigationControl({
            showCompass: false,
            showZoom: true
          }),
          'top-right'
        );
   map.on('load', async () => {
  initialized = true;

  // POI markers first
  pois.forEach(poi => {
    const el = document.createElement('div');
    el.className = 'map-marker';
    el.innerHTML = `<div class="marker-dot"></div><div class="marker-label">${poi.label}</div>`;

    const marker = new maplibregl.Marker({ element: el, anchor: 'center' })
      .setLngLat(poi.coords)
      .addTo(map);

    markers.push({ marker, poi });
  });

  flyToStep(step);

  try {
    const res = await fetch('/data/dza_admin1.geojson');

    if (!res.ok) {
      throw new Error(`GeoJSON not found: ${res.status}`);
    }

    const wilayas = await res.json();

    wilayas.features = wilayas.features.map(feature => {
      const name = getWilayaName(feature);

      return {
        ...feature,
        properties: {
          ...feature.properties,
          wilaya_name: name,
          military_region: regionByWilaya[name] || null
        }
      };
    });

    console.log(
      'Wilayas without military region:',
      wilayas.features
        .filter(f => !f.properties.military_region)
        .map(f => f.properties.wilaya_name)
    );

    map.addSource('military-regions', {
      type: 'geojson',
      data: wilayas
    });

    map.addLayer({
      id: 'military-regions-fill',
      type: 'fill',
      source: 'military-regions',
      paint: {
        'fill-color': [
          'match',
          ['get', 'military_region'],
          'rm1', '#e05c3a',
          'rm2', '#c8a96e',
          'rm3', '#7a9abf',
          'rm4', '#6ab187',
          'rm5', '#f0c040',
          'rm6', '#9b59b6',
          '#555555'
        ],
        'fill-opacity': step === 0 ? 0.42 : 0
      },
      layout: {
        visibility: step === 0 ? 'visible' : 'none'
      }
    });

    map.addLayer({
      id: 'military-regions-line',
      type: 'line',
      source: 'military-regions',
      paint: {
        'line-color': '#ffffff',
        'line-width': 0.7,
        'line-opacity': step === 0 ? 0.85 : 0
      },
      layout: {
        visibility: step === 0 ? 'visible' : 'none'
      }
    });

    showRegions(step === 18);
  } catch (err) {
    console.error('Could not load military regions:', err);
  }
});
});

onDestroy(() => {
  if (map) map.remove();
});
</script>

<div class="map-wrap" bind:this={mapContainer}></div>

<style>
  .map-wrap {
    width: 100%;
    height: 100%;
  }

  :global(.map-marker) {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
    opacity: 0;
    transform: scale(0.6);
    transition: opacity 0.5s ease, transform 0.5s ease;
    pointer-events: none;
  }

  :global(.map-marker.visible) {
    opacity: 1;
    transform: scale(1);
  }

  :global(.marker-dot) {
    width: 10px;
    height: 10px;
    border-radius: 50%;
    background: #e05c3a;
    border: 2px solid #fff;
    box-shadow: 0 0 0 3px rgba(224, 92, 58, 0.35);
  }

  :global(.marker-label) {
    font-family: Georgia, serif;
    font-size: 11px;
    font-weight: 600;
    color: #fff;
    background: rgba(15, 15, 20, 0.78);
    padding: 2px 7px;
    border-radius: 3px;
    white-space: nowrap;
    letter-spacing: 0.04em;
    backdrop-filter: blur(4px);
  }
</style>