<script>
  import { onMount } from 'svelte';
  import Map from './lib/Map.svelte';

  const base = import.meta.env.BASE_URL;

  let index = 0;

  // Maps each scroll section index to a camera step in Map.svelte
  // sections: 0=intro, 1-4=terrorism, 5-8=drugs, 9-12=gold, 13-16=weapons, 17-20=migration
  const indexToMapStep = [
    0,          // 0  intro
    1, 1, 1,    // 1-3  terrorism: tamanrasset
    2, 2,       // 4-5  terrorism: bordj
    3, 3,       // 6-7  terrorism: illizi
    4, 4,       // 8-9  terrorism overview/stats
    5, 5, 5,    // 10-12 drugs: el oued
    6, 6,       // 13-14 drugs: ouargla
    7, 7,       // 15-16 drugs: tebessa
    4,          // 17   drugs summary
    8, 8, 8,    // 18-20 gold: tamanrasset
    9, 9,       // 21-22 gold: illizi
    10, 10,     // 23-24 gold: adrar
    11, 11,     // 25-26 weapons: batna
    12, 12,     // 27-28 weapons: khenchela
    13, 13,     // 29-30 weapons: constantine
    14,         // 31   migration overview
    15, 15,     // 32-33 migration: tamanrasset inland
    16, 16,     // 34-35 migration: skikda coast
    17, 17,     // 36-37 migration: annaba coast
  ];

  $: mapStep = indexToMapStep[Math.min(index, indexToMapStep.length - 1)] ?? 0;

  // Theme colours
  const themes = {
    terrorism: '#e05c3a',
    drugs:     '#c8a96e',
    gold:      '#f0c040',
    weapons:   '#7a9abf',
    migration: '#6ab187',
  };

  // Visibility helpers
  $: v = (n) => index >= n;

  const locationLabels = [
    'Algeria',
    'Tamanrasset','Tamanrasset','Tamanrasset',
    'Bordj Badji Mokhtar','Bordj Badji Mokhtar',
    'Illizi','Illizi',
    'Algeria','Algeria',
    'El Oued','El Oued','El Oued',
    'Ouargla','Ouargla',
    'Tebessa','Tebessa',
    'Algeria',
    'Tamanrasset','Tamanrasset','Tamanrasset',
    'Illizi','Illizi',
    'Adrar','Adrar',
    'Batna','Batna',
    'Khenchela','Khenchela',
    'Constantine','Constantine',
    'Algeria',
    'Tamanrasset','Tamanrasset',
    'Skikda','Skikda',
    'Annaba','Annaba',
  ];

  $: currentLabel = locationLabels[Math.min(index, locationLabels.length - 1)];

  onMount(() => {
    const sections = document.querySelectorAll('.scroll-section');
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach(e => {
          if (e.isIntersecting) index = parseInt(e.target.dataset.index ?? '0');
        });
      },
      { threshold: 0.4 }
    );
    sections.forEach(s => observer.observe(s));
    return () => observer.disconnect();
  });
</script>

<!-- ── HERO ── -->
<header class="hero">
  <div class="hero-inner">
    <p class="kicker">Data Investigation · Algerian National People's Army</p>
    <h1>Tracking <em>Algerian Military</em> Activity</h1>
    <p class="subtitle">Between January 2024 and October 2025, the ANP published weekly operational reports documenting arrests, seizures and interdictions across Algeria's vast territory. This is what the data reveals.</p>
    <div class="scroll-hint">
      <span>Scroll to explore</span>
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
        <path d="M12 5v14M5 12l7 7 7-7"/>
      </svg>
    </div>
  </div>
</header>

<!-- ── SCROLLY LAYOUT ── -->
<div class="scrolly-container">

  <div class="map-sticky">
    <Map step={mapStep} />
    <div class="step-counter"><span>{currentLabel}</span></div>
  </div>

  <div class="foreground">

    <!-- ═══════════════════════════════════════════
         0 — INTRODUCTION
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="0">
      <div class="prose-block">
        <span class="section-tag">Introduction</span>
        <h2>Africa's Largest Country</h2>
        <p>Algeria shares borders with seven countries across the Sahara and Mediterranean. Its military — the Armée Nationale Populaire (ANP) — publishes weekly operational reports detailing arrests and seizures across five categories: terrorism, drugs, illegal gold mining, weapons and irregular migration.</p>
        <p>This analysis is based on <strong>143 weekly reports</strong> published between January 2024 and October 2025, scraped directly from the Algerian Ministry of Defence website.</p>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 1 — TERRORISM
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="1">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color: {themes.terrorism}">01 — Counter-Terrorism</span>
        <h2>The Saharan Front</h2>
        <p>Algeria's deep south remains the primary theatre of counter-terrorism operations. The 6th Military Region — headquartered in Tamanrasset — covers a territory larger than Western Europe and shares porous borders with Mali, Niger and Libya.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="2">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(2)}>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.terrorism}">56</span>
            <span class="stat-label">Terrorists surrendered</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.terrorism}">1,158</span>
            <span class="stat-label">Support network members arrested</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.terrorism}">38</span>
            <span class="stat-label">Kalashnikovs seized</span>
          </div>
        </div>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="3">
      <div class="prose-block">
        <div class="info-text" class:visible={v(3)}>
          <span class="label">Tamanrasset — Gateway to the Sahara</span>
          <p>Tamanrasset, Algeria's southernmost major city, sits at the junction of trans-Saharan smuggling routes. ANP reports from this region frequently document the surrender of armed militants — many crossing from northern Mali where armed groups remain active.</p>
        </div>
        <div class="report-image" class:visible={v(3)}>
          <img src="{base}data/anp_output/images/2024-02-07/img_01.jpg" alt="ANP operational report — Tamanrasset" loading="lazy" />
          <p class="img-caption">ANP press image — Tamanrasset region, February 2024</p>
        </div>
      </div>
    </section>

    <!-- Bordj Badji Mokhtar -->
    <section class="scroll-section" data-index="4">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.terrorism}">01 — Counter-Terrorism</span>
        <h2>Bordj Badji Mokhtar</h2>
        <p>One of Algeria's most remote outposts, Bordj Badji Mokhtar lies at the border of Mali. It appears repeatedly in ANP reports as a location where armed individuals surrendered to military authorities, often carrying Kalashnikovs and ammunition.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="5">
      <div class="prose-block">
        <div class="info-text" class:visible={v(5)}>
          <span class="label">Surrender Operations</span>
          <p>Across the reporting period, the ANP documented <strong>56 surrenders</strong> of armed individuals — many at Bordj Badji Mokhtar. The reports note surrenders of individuals named alongside their <em>nom de guerre</em>, suggesting these were known militant figures rather than low-level combatants.</p>
        </div>
      </div>
    </section>

    <!-- Illizi -->
    <section class="scroll-section" data-index="6">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.terrorism}">01 — Counter-Terrorism</span>
        <h2>Illizi — Eastern Sahara</h2>
        <p>Illizi sits near Algeria's border with Libya, another source of instability. ANP reports from this region document both terrorism-related arrests and the seizure of weapons caches.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="7">
      <div class="prose-block">
        <div class="info-text" class:visible={v(7)}>
          <span class="label">Illizi Region</span>
          <p>The Illizi wilaya borders Libya to the east, a country where weapons have circulated widely since 2011. Operations here are documented less frequently than in the Mali-border zone but show a consistent pattern of arms interdiction.</p>
        </div>
        <div class="report-image" class:visible={v(7)}>
          <img src="{base}data/anp_output/images/2024-01-10/img_11.jpg" alt="ANP operational report — Illizi" loading="lazy" />
          <p class="img-caption">ANP press image — Illizi region, January 2024</p>
        </div>
      </div>
    </section>

    <!-- Terrorism summary -->
    <section class="scroll-section info-section" data-index="8">
      <div class="prose-block">
        <div class="info-text" class:visible={v(8)}>
          <span class="label">Counter-Terrorism in Context</span>
          <p>Algeria has not experienced a major terrorist attack since the 2013 In Amenas hostage crisis. But the military maintains a substantial presence in the south, and weekly reports suggest ongoing low-level operations — arrests, surrenders, and weapons seizures — continue at a steady pace. The <strong>1,158 support network arrests</strong> over 22 months points to an extensive logistics and supply chain being systematically dismantled.</p>
        </div>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="9">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(9)}>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.terrorism}">22</span>
            <span class="stat-label">Months of data</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.terrorism}">~53</span>
            <span class="stat-label">Arrests per month (support networks)</span>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 2 — DRUGS
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="10">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.drugs}">02 — Drug Interdiction</span>
        <h2>El Oued — The Cannabis Highway</h2>
        <p>El Oued, in Algeria's northeast near the Tunisian border, appears more frequently in ANP drug reports than any other city. It sits at the end of trans-Saharan cannabis routes originating in Morocco's Rif mountains.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="11">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(11)}>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.drugs}">23,639</span>
            <span class="stat-label">kg cannabis seized</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.drugs}">7,306</span>
            <span class="stat-label">kg cocaine seized</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.drugs}">58M</span>
            <span class="stat-label">Psychotropic pills seized</span>
          </div>
        </div>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="12">
      <div class="prose-block">
        <div class="info-text" class:visible={v(12)}>
          <span class="label">El Oued</span>
          <p>El Oued appeared in <strong>18 separate report weeks</strong> — more than any other city in the dataset. The region's proximity to Tunisia makes it a key transit point, and ANP operations here consistently document large cannabis hauls alongside arrests of trafficking networks.</p>
        </div>
        <div class="report-image" class:visible={v(12)}>
          <img src="{base}data/anp_output/images/2024-01-17/img_06.jpg" alt="ANP operational report — El Oued" loading="lazy" />
          <p class="img-caption">ANP press image — El Oued region, January 2024</p>
        </div>
      </div>
    </section>

    <!-- Ouargla -->
    <section class="scroll-section" data-index="13">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.drugs}">02 — Drug Interdiction</span>
        <h2>Ouargla — The Desert Crossroads</h2>
        <p>Ouargla, capital of Algeria's largest wilaya, sits at the junction of north-south and east-west Saharan routes. It is a hub not just for drugs but for multiple forms of contraband — and appears in reports across all five categories.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="14">
      <div class="prose-block">
        <div class="info-text" class:visible={v(14)}>
          <span class="label">Ouargla's Role</span>
          <p>Ouargla's central position in the Algerian Sahara makes it a strategic interdiction point. ANP images from the region consistently show large quantities of packaged drugs alongside seized vehicles — often 4x4 trucks adapted for desert crossings.</p>
        </div>
        <div class="report-image" class:visible={v(14)}>
          <img src="{base}data/anp_output/images/2024-01-10/img_06.jpg" alt="ANP operational report — Ouargla" loading="lazy" />
          <p class="img-caption">ANP press image — Ouargla region, January 2024</p>
        </div>
      </div>
    </section>

    <!-- Tebessa -->
    <section class="scroll-section" data-index="15">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.drugs}">02 — Drug Interdiction</span>
        <h2>Tebessa — The Tunisian Border</h2>
        <p>Tebessa, in Algeria's far northeast, borders Tunisia — a country that has become an increasingly important transit point for narcotics entering Europe. ANP operations here document both cannabis and cocaine seizures.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="16">
      <div class="prose-block">
        <div class="info-text" class:visible={v(16)}>
          <span class="label">Cocaine — A New Pattern</span>
          <p>The <strong>7,306 kg of cocaine</strong> seized over 22 months is notable. Cocaine has historically been rare in North Africa but is increasingly documented in Algerian military reports — likely transiting from West Africa via Saharan smuggling networks en route to European markets.</p>
        </div>
        <div class="report-image" class:visible={v(16)}>
          <img src="{base}data/anp_output/images/2024-01-24/img_04.jpg" alt="ANP operational report — Tebessa" loading="lazy" />
          <p class="img-caption">ANP press image — Tebessa region, January 2024</p>
        </div>
      </div>
    </section>

    <!-- Drugs summary -->
    <section class="scroll-section info-section" data-index="17">
      <div class="prose-block">
        <div class="info-text" class:visible={v(17)}>
          <span class="label">58 Million Pills</span>
          <p>The most striking drug figure is the <strong>58 million psychotropic pills</strong> seized over the period. These tablets — primarily Tramadol and Captagon — are manufactured in Libya and Jordan and transit Algeria en route to West Africa and Europe. Their scale dwarfs the cocaine and cannabis figures and points to an industrial-scale trafficking operation.</p>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 3 — GOLD MINING
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="18">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.gold}">03 — Illegal Gold Mining</span>
        <h2>The Gold Rush in Algeria's South</h2>
        <p>One of the most striking findings in the ANP data is the scale of illegal artisanal gold mining — <em>orpaillage</em> — in Algeria's deep south. Over 35,000 people were arrested for illegal mining between January 2024 and October 2025.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="19">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(19)}>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.gold}">35,658</span>
            <span class="stat-label">People arrested for illegal gold mining</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.gold}">26,007</span>
            <span class="stat-label">Generators confiscated</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.gold}">457</span>
            <span class="stat-label">Metal detectors seized</span>
          </div>
        </div>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="20">
      <div class="prose-block">
        <div class="info-text" class:visible={v(20)}>
          <span class="label">Tamanrasset — Gold Mining Hub</span>
          <p>The Tamanrasset region sits above some of Algeria's richest alluvial gold deposits. Tens of thousands of artisanal miners — many from sub-Saharan Africa — enter Algeria through porous southern borders to work illegal mining sites. The <strong>26,007 generators</strong> seized points to the industrial scale of operations: generators power the water pumps used to sluice gold from riverbeds.</p>
        </div>
        <div class="report-image" class:visible={v(20)}>
          <img src="{base}data/anp_output/images/2024-02-14/img_01.jpg" alt="ANP operational report — gold mining equipment" loading="lazy" />
          <p class="img-caption">Seized gold mining equipment — Tamanrasset region, February 2024</p>
        </div>
      </div>
    </section>

    <!-- Gold: Illizi -->
    <section class="scroll-section" data-index="21">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.gold}">03 — Illegal Gold Mining</span>
        <h2>Illizi — Eastern Gold Fields</h2>
        <p>Illizi's remote terrain also harbours significant gold deposits. Operations here are complicated by the region's proximity to Libya and the presence of armed groups who sometimes control mining sites as a revenue stream.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="22">
      <div class="prose-block">
        <div class="info-text" class:visible={v(22)}>
          <span class="label">Mining as a Conflict Economy</span>
          <p>Researchers at the Global Initiative Against Transnational Organized Crime have documented how illegal gold mining in the Sahel has become intertwined with armed group finances. The ANP's focus on seizing equipment — generators, pressure hammers, metal detectors — rather than just arresting individuals suggests a strategy of disrupting the mining infrastructure itself.</p>
        </div>
      </div>
    </section>

    <!-- Gold: Adrar -->
    <section class="scroll-section" data-index="23">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.gold}">03 — Illegal Gold Mining</span>
        <h2>Adrar — Western Sahara</h2>
        <p>Adrar, in Algeria's far southwest, borders Mauritania and Mali. Though it appears less frequently in the data than Tamanrasset, a significant operation in September 2025 documented arrests and equipment seizures here.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="24">
      <div class="prose-block">
        <div class="info-text" class:visible={v(24)}>
          <span class="label">Scale of the Problem</span>
          <p>At <strong>35,658 arrests over 22 months</strong> — roughly 1,600 per month — illegal gold mining is by far the most common enforcement action in the ANP dataset. It dwarfs terrorism arrests by a factor of 25 and raises questions about what drives so many people to risk arrest in Algeria's brutal desert conditions.</p>
        </div>
        <div class="report-image" class:visible={v(24)}>
          <img src="{base}data/anp_output/images/2025-09-10/img_02.jpg" alt="ANP operational report — Adrar" loading="lazy" />
          <p class="img-caption">ANP press image — Adrar region, September 2025</p>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 4 — WEAPONS
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="25">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.weapons}">04 — Weapons Seizures</span>
        <h2>Batna — Firearms in the Northeast</h2>
        <p>Batna, in Algeria's northeast Aurès mountains, is the city that appears most frequently in the weapons seizure data. The region has a history of armed conflict going back to the 1990s civil war and continues to see regular firearms interdictions.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="26">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(26)}>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.weapons}">981</span>
            <span class="stat-label">Firearms seized</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.weapons}">73</span>
            <span class="stat-label">Hunting rifles seized</span>
          </div>
        </div>
        <div class="info-text" class:visible={v(26)} style="margin-top:1rem">
          <span class="label">Batna</span>
          <p>Batna appears in the weapons data more than any other city — 20+ report weeks. The Aurès region's mountainous terrain provides cover for arms caches, and the city's position near the Tunisian border makes it a transit point for weapons moving in both directions.</p>
        </div>
      </div>
    </section>

    <!-- Weapons: Khenchela -->
    <section class="scroll-section" data-index="27">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.weapons}">04 — Weapons Seizures</span>
        <h2>Khenchela</h2>
        <p>Khenchela, adjacent to Batna and similarly mountainous, appears repeatedly in the weapons data. Operations here document both firearms and hunting rifles, suggesting a mix of criminal and civilian weapons circulating in the region.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="28">
      <div class="prose-block">
        <div class="report-image" class:visible={v(28)}>
          <img src="{base}data/anp_output/images/2024-01-17/img_05.jpg" alt="ANP operational report — Khenchela" loading="lazy" />
          <p class="img-caption">ANP press image — Khenchela region, January 2024</p>
        </div>
      </div>
    </section>

    <!-- Weapons: Constantine -->
    <section class="scroll-section" data-index="29">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.weapons}">04 — Weapons Seizures</span>
        <h2>Constantine</h2>
        <p>Constantine — Algeria's third city and capital of the northeast — also features in the weapons data, reflecting the region's role as a hub for contraband of all kinds moving between the interior and the coast.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="30">
      <div class="prose-block">
        <div class="info-text" class:visible={v(30)}>
          <span class="label">A Regional Pattern</span>
          <p>The clustering of weapons seizures in the northeast — Batna, Khenchela, Constantine, Tebessa — points to a distinct regional dynamic compared to the south. These are not Saharan smuggling routes but denser, more urban networks operating in Algeria's most populated corridor.</p>
        </div>
        <div class="report-image" class:visible={v(30)}>
          <img src="{base}data/anp_output/images/2024-03-06/img_05.jpg" alt="ANP operational report — Constantine" loading="lazy" />
          <p class="img-caption">ANP press image — Constantine region, March 2024</p>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 5 — MIGRATION
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="31">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.migration}">05 — Irregular Migration</span>
        <h2>54,769 People Arrested</h2>
        <p>Algeria is both a transit country and a destination for migrants from sub-Saharan Africa. The ANP reports document two distinct migration flows: inland arrests of migrants crossing the Sahara, and coastal interceptions of boats attempting the Mediterranean crossing.</p>
        <div class="stat-grid" style="margin-top:1.5rem">
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.migration}">54,769</span>
            <span class="stat-label">Total migrants arrested</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Migration: Tamanrasset inland -->
    <section class="scroll-section" data-index="32">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.migration}">05 — Irregular Migration</span>
        <h2>The Saharan Route</h2>
        <p>Tamanrasset is the first major Algerian city reached by migrants crossing from Niger or Mali. Tens of thousands are arrested here each year before they can continue northward. Many are subsequently expelled back across the border.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="33">
      <div class="prose-block">
        <div class="info-text" class:visible={v(33)}>
          <span class="label">Expulsions</span>
          <p>Human rights organisations including Human Rights Watch and the Mixed Migration Centre have documented systematic <strong>summary expulsions</strong> of migrants from Algeria into the desert — often without water, food or their belongings. The ANP reports document arrests but not what happens next. Images from this section courtesy of Alarm Phone Sahara where available.</p>
        </div>
        <div class="placeholder-image" class:visible={v(33)}>
          <div class="img-placeholder">
            <span>📷</span>
            <p>Add image from Alarm Phone Sahara here</p>
            <p class="placeholder-note">Replace with: <code>/data/your-image.jpg</code></p>
          </div>
        </div>
      </div>
    </section>

    <!-- Migration: Skikda coast -->
    <section class="scroll-section" data-index="34">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.migration}">05 — Irregular Migration</span>
        <h2>Skikda — The Mediterranean</h2>
        <p>On Algeria's northeast coast, Skikda is one of several ports documented in the ANP reports for sea interceptions. Migrants — many of whom have transited the Sahara — attempt the crossing to Italy or Spain on small wooden or rubber boats.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="35">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(35)}>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.migration}">~35K</span>
            <span class="stat-label">Arrested inland (various nationalities)</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.migration}">~20K</span>
            <span class="stat-label">Intercepted on boats at sea</span>
          </div>
        </div>
        <div class="report-image" class:visible={v(35)}>
          <img src="{base}data/anp_output/images/2024-01-10/img_13.jpg" alt="ANP operational report — Skikda" loading="lazy" />
          <p class="img-caption">ANP press image — Skikda region, January 2024</p>
        </div>
      </div>
    </section>

    <!-- Migration: Annaba -->
    <section class="scroll-section" data-index="36">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.migration}">05 — Irregular Migration</span>
        <h2>Annaba — Port of Departure</h2>
        <p>Annaba, Algeria's fourth largest city and a major industrial port, is documented in the ANP reports as a site of boat interceptions. Its proximity to Tunisia — just 100km — makes it part of the central Mediterranean route.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="37">
      <div class="prose-block">
        <div class="info-text" class:visible={v(37)}>
          <span class="label">What the Numbers Don't Show</span>
          <p>The ANP figures document interceptions — people caught. They do not capture those who made it through, those who died in the desert or at sea, or those expelled without official documentation. Organisations like <strong>Alarm Phone Sahara</strong> have documented hundreds of cases of migrants abandoned in the desert after Algerian military expulsions.</p>
        </div>
        <div class="report-image" class:visible={v(37)}>
          <img src="{base}data/anp_output/images/2024-10-02/img_11.jpg" alt="ANP operational report — Annaba" loading="lazy" />
          <p class="img-caption">ANP press image — Annaba region, October 2024</p>
        </div>

        <div class="end-note">
          <p><strong>Data:</strong> Algerian Ministry of Defence operational reports, January 2024 – October 2025. Scraped and analysed by the author. Image geolocation via OCR + OpenStreetMap Nominatim.</p>
          <p><strong>Methodology note:</strong> Numbers are extracted from structured tables in ANP weekly reports. Some weeks contain NA values where table structure differed. Totals should be treated as conservative minimums.</p>
        </div>
      </div>
    </section>

  </div><!-- /foreground -->
</div><!-- /scrolly-container -->

<footer>
  <p>Data: <a href="https://www.mdn.dz" target="_blank" rel="noopener noreferrer">Algerian Ministry of National Defence</a> · Map © <a href="https://www.openstreetmap.org/copyright" target="_blank">OpenStreetMap</a> contributors, tiles © <a href="https://carto.com" target="_blank">CARTO</a> · Built with Svelte + MapLibre GL</p>
</footer>

<style>
  :global(*, *::before, *::after) { box-sizing: border-box; margin: 0; padding: 0; }
  :global(html) { scroll-behavior: smooth; }
  :global(body) {
    background: #08080f;
    color: #e8e0d0;
    font-family: 'Source Serif 4', Georgia, serif;
    -webkit-font-smoothing: antialiased;
  }

  /* ── Hero ── */
  .hero {
    min-height: 100vh;
    display: flex; align-items: center; justify-content: center;
    background: radial-gradient(ellipse at 60% 40%, #1a1208 0%, #08080f 70%);
    padding: 2rem; position: relative; overflow: hidden;
  }
  .hero-inner { max-width: 680px; text-align: center; position: relative; z-index: 1; }

  .kicker {
    font-size: 0.75rem; text-transform: uppercase;
    letter-spacing: 0.2em; color: #c8a96e; margin-bottom: 1.5rem;
  }
  .hero-inner h1 {
    font-family: 'Playfair Display', Georgia, serif;
    font-size: clamp(2.4rem, 6vw, 5rem);
    font-weight: 900; line-height: 1.05;
    color: #f0e8d8; margin-bottom: 1.5rem;
  }
  .hero-inner h1 em { color: #c8a96e; font-style: italic; }
  .subtitle {
    font-size: 1.05rem; line-height: 1.7; color: #9a9080;
    max-width: 540px; margin: 0 auto 3rem;
  }
  .scroll-hint {
    display: flex; flex-direction: column; align-items: center;
    gap: 0.5rem; color: #504838; font-size: 0.8rem;
    letter-spacing: 0.1em; text-transform: uppercase;
    animation: bounce 2s infinite;
  }
  .scroll-hint svg { width: 20px; height: 20px; }
  @keyframes bounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(6px); }
  }

  /* ── Layout ── */
  .scrolly-container {
    display: grid;
    grid-template-columns: 1fr 420px;
  }
  .map-sticky {
    position: sticky; top: 0; height: 100vh;
    align-self: start; background: #08080f; overflow: hidden;
  }
  .step-counter {
    position: absolute; top: 1.5rem; left: 1.5rem;
    background: rgba(8,8,15,0.82);
    border: 1px solid rgba(200,169,110,0.3);
    padding: 0.4rem 0.9rem; border-radius: 3px;
    z-index: 10; backdrop-filter: blur(6px);
  }
  .step-counter span {
    font-size: 0.75rem; text-transform: uppercase;
    letter-spacing: 0.12em; color: #c8a96e;
  }
  .foreground {
    display: flex; flex-direction: column;
    padding: 2rem 1.5rem;
  }

  /* ── Sections ── */
  .scroll-section {
    min-height: 100vh; display: flex; align-items: center;
  }
  .info-section { min-height: 70vh; }

  .prose-block {
    width: 100%;
    background: rgba(8,8,15,0.88);
    border: 1px solid rgba(200,169,110,0.15);
    border-radius: 4px; padding: 2rem;
    backdrop-filter: blur(10px);
    box-shadow: 0 8px 40px rgba(0,0,0,0.5);
  }

  .section-tag {
    display: block; font-size: 0.7rem;
    text-transform: uppercase; letter-spacing: 0.15em;
    color: #c8a96e; margin-bottom: 0.75rem;
  }
  .theme-tag { font-weight: 700; }

  .prose-block h2 {
    font-family: 'Playfair Display', Georgia, serif;
    font-size: 1.8rem; font-weight: 700;
    color: #f0e8d8; line-height: 1.15; margin-bottom: 1rem;
  }
  .prose-block p {
    font-size: 0.95rem; line-height: 1.75;
    color: #9a9080; margin-bottom: 0.85rem;
  }
  .prose-block p:last-child { margin-bottom: 0; }
  .prose-block strong { color: #c8a96e; }
  .prose-block em { font-style: italic; color: #b8a898; }

  /* ── Stat grid ── */
  .stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(110px, 1fr));
    gap: 1rem; margin-bottom: 0.5rem;
    opacity: 0; transform: translateY(12px);
    transition: opacity 0.6s ease, transform 0.6s ease;
  }
  .stat-grid.visible { opacity: 1; transform: translateY(0); }

  .stat-item { display: flex; flex-direction: column; gap: 0.3rem; }
  .stat-value {
    font-family: 'Playfair Display', Georgia, serif;
    font-size: 2rem; font-weight: 900; line-height: 1;
  }
  .stat-label {
    font-size: 0.72rem; text-transform: uppercase;
    letter-spacing: 0.08em; color: #6a6060; line-height: 1.3;
  }

  /* ── Info text boxes ── */
  .info-text {
    background: rgba(200,169,110,0.06);
    border-left: 3px solid #c8a96e;
    border-radius: 2px; padding: 1rem 1.2rem;
    margin-bottom: 1rem;
    opacity: 0; transform: translateY(12px);
    transition: opacity 0.6s ease, transform 0.6s ease;
  }
  .info-text.visible { opacity: 1; transform: translateY(0); }
  .info-text .label {
    display: block; font-size: 0.7rem;
    text-transform: uppercase; letter-spacing: 0.12em;
    color: #c8a96e; margin-bottom: 0.5rem;
  }
  .info-text p {
    font-size: 0.88rem; line-height: 1.7;
    color: #9a9080; margin: 0;
  }

  /* ── Images ── */
  .report-image {
    margin-top: 1rem;
    opacity: 0; transform: translateY(8px);
    transition: opacity 0.7s ease 0.15s, transform 0.7s ease 0.15s;
  }
  .report-image.visible { opacity: 1; transform: translateY(0); }
  .report-image img {
    width: 100%; border-radius: 3px;
    border: 1px solid rgba(200,169,110,0.2);
    display: block;
  }
  .img-caption {
    font-size: 0.72rem; color: #504838;
    font-style: italic; margin-top: 0.4rem;
    margin-bottom: 0 !important;
  }

  /* ── Placeholder image ── */
  .placeholder-image {
    margin-top: 1rem;
    opacity: 0; transform: translateY(8px);
    transition: opacity 0.7s ease 0.15s, transform 0.7s ease 0.15s;
  }
  .placeholder-image.visible { opacity: 1; transform: translateY(0); }
  .img-placeholder {
    border: 2px dashed rgba(200,169,110,0.3);
    border-radius: 3px; padding: 2rem;
    text-align: center; color: #504838;
  }
  .img-placeholder span { font-size: 2rem; display: block; margin-bottom: 0.5rem; }
  .img-placeholder p { font-size: 0.82rem; color: #504838; margin-bottom: 0.25rem !important; }
  .placeholder-note { font-size: 0.72rem !important; font-family: monospace; }

  /* ── End note ── */
  .end-note {
    margin-top: 2rem; padding-top: 1.5rem;
    border-top: 1px solid rgba(200,169,110,0.15);
  }
  .end-note p { font-size: 0.78rem; color: #454035; margin-bottom: 0.5rem !important; }

  /* ── Footer ── */
  footer {
    background: #04040a; padding: 2rem 4vw;
    border-top: 1px solid rgba(200,169,110,0.1);
  }
  footer p { font-size: 0.75rem; color: #403830; }
  footer a { color: #6a5840; text-decoration: none; }
  footer a:hover { color: #c8a96e; }

  /* ── Mobile ── */
  @media (max-width: 800px) {
    .scrolly-container { grid-template-columns: 1fr; }
    .map-sticky { height: 50vh; }
    .scroll-section { min-height: auto; padding: 2rem 0; }
    .info-section { min-height: auto; }
  }
</style>