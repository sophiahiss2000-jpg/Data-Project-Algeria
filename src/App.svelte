<script>
  import { onMount } from 'svelte';
  import Map from './lib/Map.svelte';

  const base = import.meta.env.BASE_URL;

  let index = 0;

  // Maps each scroll section index to a camera step in Map.svelte
  // sections: 0=intro, 1-4=terrorism, 5-8=drugs, 9-12=gold, 13-16=weapons, 17-20=migration
  const indexToMapStep = [
    0, 18,       // 0=intro, 1=military regions
    1, 1, 1,    // 1-3  terrorism: tamanrasset
    2, 2,       // 4-5  terrorism: bordj
    3, 3,       // 6-7  terrorism: In Guezzam
    4, 4,       // 8-9  terrorism overview/stats
    5, 5, 5,    // 10-12 drugs: el oued
    6, 6,       // 13-14 drugs: Oran
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
    16, 16,     // 34-35 migration: oran coast
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
    'Six Military Regions (RM1-RM6)',
    'Tamanrasset','Tamanrasset','Tamanrasset',
    'Bordj Badji Mokhtar','Bordj Badji Mokhtar',
    'In Guezzam','In Guezzam',
    'Algeria','Algeria',
    'El Oued','El Oued','El Oued',
    'Oran', 'Oran',
    'Tebessa','Tebessa',
    'Algeria',
    'Tamanrasset','Tamanrasset','Tamanrasset',
    'Illizi','Illizi',
    'Djanet','Djanet',
    'Batna','Batna',
    'Khenchela','Khenchela',
    'Constantine','Constantine',
    'Algeria',
    'Tamanrasset','Tamanrasset',
    'Oran','Oran',
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
        <p>This analysis is based on <strong>143 weekly reports</strong> published between January 2024 and October 2025, scraped and geotagged directly from the Algerian Ministry of Defence website.</p>
        <p>The army and intelligence services possess considerable decision-making power and executive authority in Algeria, yet data from the country's political "black box" remains largely inaccessible.</p>
        <p>These reports therefore offer an unusual glimpse into how the Algerian state documents and communicates its security operations.</p>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         1 — MILITARY REGIONS
    ════════════════════════════════════════════ -->
    <section class="scroll-section info-section" data-index="1">
      <div class="prose-block">
        <span class="section-tag">Algeria's Military Geography</span>
        <h2>Six Military Regions</h2>
        <div class="region-list">
          <div class="region-item" style="border-color:#e05c3a">
            <span class="region-code" style="color:#e05c3a">RM I</span>
            <span class="region-name">Blida</span>
            <span class="region-desc">Northern heartland — Algiers, Tizi Ouzou, Chlef</span>
          </div>
          <div class="region-item" style="border-color:#c8a96e">
            <span class="region-code" style="color:#c8a96e">RM II</span>
            <span class="region-name">Oran</span>
            <span class="region-desc">Northwest — Oran, Tlemcen, Sidi Bel Abbès</span>
          </div>
          <div class="region-item" style="border-color:#7a9abf">
            <span class="region-code" style="color:#7a9abf">RM III</span>
            <span class="region-name">Béchar</span>
            <span class="region-desc">Western Sahara — Béchar, Tindouf, Adrar</span>
          </div>
          <div class="region-item" style="border-color:#6ab187">
            <span class="region-code" style="color:#6ab187">RM IV</span>
            <span class="region-name">Ouargla</span>
            <span class="region-desc">Central Sahara — Ouargla, Illizi, El Oued, Djanet</span>
          </div>
          <div class="region-item" style="border-color:#f0c040">
            <span class="region-code" style="color:#f0c040">RM V</span>
            <span class="region-name">Constantine</span>
            <span class="region-desc">Northeast — Constantine, Batna, Annaba, Tebessa</span>
          </div>
          <div class="region-item" style="border-color:#9b59b6">
            <span class="region-code" style="color:#9b59b6">RM VI</span>
            <span class="region-name">Tamanrasset</span>
            <span class="region-desc">Deep South — Tamanrasset, In Guezzam, Bordj Badji Mokhtar</span>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 1 — TERRORISM
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="2">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color: {themes.terrorism}">01 — Counter-Terrorism</span>
        <h2>The Saharan Front</h2>
        <p>Algeria's deep south remains the primary theatre of counter-terrorism operations. The 6th Military Region — covering the counties or <em>wilayas</em> of Bordj Baji Mokhta, Tamanrasset, In Salah and In Guezzam  — covers a territory larger than Western Europe and shares porous borders with Mali, Niger and Libya.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="3">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(3)}>
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

    <section class="scroll-section info-section" data-index="4">
      <div class="prose-block">
        <div class="info-text" class:visible={v(4)}>
          <span class="label">Tamanrasset — Gateway to the Sahara</span>
          <p>Tamanrasset, Algeria's southernmost major city, sits at the junction of trans-Saharan smuggling routes. ANP reports from this region frequently document the surrender of armed militants — many crossing from northern Mali where armed groups remain active.</p>
        </div>
        <div class="report-image" class:visible={v(4)}>
          <img src="{base}data/anp_output/images/2024-02-14/img_01.jpg" alt="Armed security personnel inspecting seized weapons in a desert operations context near Tamanrasset during a counterterrorism report" loading="lazy" />
          <p class="img-caption">ANP press image — Tamanrasset region, February 2024</p>
        </div>
      </div>
    </section>

    <!-- Bordj Badji Mokhtar -->
    <section class="scroll-section" data-index="5">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.terrorism}">01 — Counter-Terrorism</span>
        <h2>One Wilaya. One Third of All Reports.</h2>
        <p>Of all the wilayas in Algeria's vast southern interior, one name stands out with striking consistency: Bordj Badji Mokhtar, a few kilometres from the Malian border. A text analysis of all 143 weekly reports found it mentioned in a counter-terrorism context in <strong>33 separate reports</strong> — more than twice the frequency of any other wilaya.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="6">
      <div class="prose-block">
        <div class="info-text" class:visible={v(6)}>
          <span class="label">Algeria's Terrorism Trauma</span>
          <p>The ANP reports describe surrenders of armed individuals at Bordj Badji Mokhtar with near-weekly regularity, often naming militants alongside their <em>nom de guerre</em>.</p>
          <p>These reports must be understood in the context of Algeria's enduring security doctrine, deeply shaped by the trauma of the <a href="https://www.monde-diplomatique.fr/2017/08/DAUM/57773" target="_blank">Black Decade</a> or <em>Décennie Noire</em> (1992–2002), a civil war that continues to structure state narratives around stability, terrorism and national survival.</p>
        </div>
        <div class="report-image" class:visible={v(6)}>
          <img src="{base}data/anp_output/images/2024-06-12/img_01.jpg" alt="Military personnel and vehicles at a remote border location near Bordj Badji Mokhtar, conveying active counterterrorism surveillance in the Sahara" loading="lazy" />
          <p class="img-caption">ANP press image — Bordj Badji Mokhtar region, June 2024</p>
        </div>
      </div>
    </section>

    <!-- In Guezzam -->
    <section class="scroll-section" data-index="7">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.terrorism}">01 — Counter-Terrorism</span>
        <h2>In Guezzam — Eastern Sahara</h2>
        <p>In Guezzam sits near Algeria's border with Niger and Libya, another source of instability. Especially after the Fall of Muammar Gadaffi in Libya in 2012. ANP reports from this region document both terrorism-related arrests and the seizure of weapons caches.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="8">
      <div class="prose-block">
        <div class="info-text" class:visible={v(8)}>
          <span class="label">Trigger Warnings</span>
          <p>The military's communication strategy surrounding these operations is often explicitly deterrent. Official reports regularly publish graphic and sometimes unblurred images of dead bodies, weapons and captured equipment — visual performances of force. In a country where the memory of the civil war remains deeply embedded in public consciousness, these images reinforce a long-standing regime narrative: that the military alone stands between Algeria and a return to chaos. The reporting therefore serves to reproduce the state's self-presentation as the sole guarantor of order, stability and protection against Islamism and terrorism.</p>
        </div>
        <div class="report-image" class:visible={v(8)}>
          <img src="{base}data/anp_output/images/2024-07-10/img_01.jpg" alt="ANP capture of killed suspected militants" loading="lazy" />
          <p class="img-caption">ANP press image — In Guezzam region, January 2024</p>
        </div>
      </div>
    </section>

    <!-- Terrorism summary -->
    <section class="scroll-section info-section" data-index="9">
      <div class="prose-block">
        <div class="info-text" class:visible={v(9)}>
          <span class="label">Counter-Terrorism in Context</span>
          <p>While domestic insurgency largely declined after the mid-2000s, terrorism increasingly came to be framed as an external and transnational threat emanating from the Sahel, allowing irregular migration, smuggling and border mobility to be incorporated into a broader security continuum. In this sense, the reports reveal less about the objective scale of militant activity than about how the Algerian state continues to narrate insecurity and justify exceptional security governance.</p>
        </div>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="10">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(10)}>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.terrorism}">22</span>
            <span class="stat-label">Months of data</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.terrorism}">~53</span>
            <span class="stat-label">Terrorism-related arrests per month</span>
          </div>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 2 — DRUGS
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="11">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.drugs}">02 — Drug Interdiction</span>
        <h2>El Oued — The Cannabis Highway</h2>
        <p>El Oued, in Algeria's northeast near the Tunisian border, appears more frequently in ANP drug reports than any other city. It sits at the end of trans-Saharan <em>cannabis routes</em> originating in Morocco's Rif mountains — and has become a key node in a narcotics economy that now stretches from South America to suburban European markets.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="12">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(12)}>
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

    <section class="scroll-section info-section" data-index="13">
      <div class="prose-block">
        <div class="info-text" class:visible={v(13)}>
          <span class="label">El Oued</span>
          <p>El Oued appeared in <strong>18 separate report weeks</strong> — more than any other city in the dataset. The region's proximity to Tunisia makes it a critical transit point: cannabis pressed in Morocco's Rif mountains travels east through Algeria before crossing into Tunisia and onward to Europe. ANP operations here consistently document large hauls alongside seized 4x4 trucks adapted for desert crossings.</p>
        </div>
        <div class="report-image" class:visible={v(13)}>
          <img src="{base}data/anp_output/images/2025-03-27/img_13.jpg" alt="ANP operational report — El Oued" loading="lazy" />
          <p class="img-caption">Seized vehicles — El Oued region, March 2025</p>
        </div>
      </div>
    </section>

    <!-- Oran -->
    <section class="scroll-section" data-index="14">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.drugs}">02 — Drug Interdiction</span>
        <h2>The Golden Arc</h2>
        <p>Algeria was long absent from cocaine trafficking maps. That changed in 2018, when 701kg of cocaine were seized at the port of Oran — hidden in a frozen meat container that had travelled from Brazil via Spain. The scandal, known as <em>cocaine-gate</em>, exposed a route that analysts at the Institute for Security Studies <a href="https://enactafrica.org/enact-observer/la-saisie-algerienne-de-cocaine-revele-des-tendances-alarmantes" target="_blank">described</a> as a <strong>"golden arc"</strong>: the North African coastline from Casablanca through Oran to Algiers — just 200km from Spain, woven into existing cannabis networks, and increasingly exploited by South American cartels.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="15">
      <div class="prose-block">
        <div class="info-text" class:visible={v(15)}>
          <span class="label">Oran — The Golden Arc</span>
          <p>Oran sits at the junction of north-south and east-west Saharan routes — a crossroads for virtually every form of contraband moving through Algeria's interior. ANP images from the region show packaged drugs alongside seized vehicles. Experts estimate that seizures represent only around 10% of actual trafficking volumes, suggesting that what the military intercepts is the visible fraction of a much larger flow.</p>
        </div>
        <div class="report-image" class:visible={v(15)}>
          <img src="{base}data/anp_output/images/2024-12-04/img_02.jpg" alt="ANP operational report — Oran" loading="lazy" />
          <p class="img-caption">A wall of packed drugs seized in Oran, December 2024</p>
        </div>
      </div>
    </section>

    <!-- Tebessa -->
    <section class="scroll-section" data-index="16">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.drugs}">02 — Drug Interdiction</span>
        <h2>Tebessa — The Tunisian Border</h2>
        <p>Tebessa, in Algeria's far northeast, sits on the Tunisian border — a corridor that has become an increasingly active transit zone for narcotics moving toward European markets. The route from Brazil to Spain to Algeria, first documented in the Oran cocaine-gate case, has established infrastructure that extends across the country's northeastern corridor.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="17">
      <div class="prose-block">
        <div class="info-text" class:visible={v(17)}>
          <span class="label">Cocaine — A New Geography</span>
          <p>The <strong>7,306 kg of cocaine</strong> seized over 22 months reflects an established pattern, not an anomaly. The 2018 Oran seizure revealed that South American cartels had already secured the route — testing it with small shipments before scaling up. The well-established ties between those cartels and Moroccan cannabis traffickers, who in turn have deep networks across northwestern Algeria, made the country a natural extension of existing supply chains. Seizures, analysts caution, represent only a fraction of what moves through.</p>
        </div>
        <div class="report-image" class:visible={v(17)}>
          <img src="{base}data/anp_output/images/2025-04-13/img_02.jpg" alt="ANP operational report — cocaine seizure" loading="lazy" />
          <p class="img-caption">66 kg of cocaine seized — April 2025</p>
        </div>
      </div>
    </section>

    <!-- Drugs summary -->
    <section class="scroll-section info-section" data-index="18">
      <div class="prose-block">
        <div class="info-text" class:visible={v(18)}>
          <span class="label">58 Million Pills</span>
          <p>The most striking drug figure is the <strong>58 million psychotropic pills</strong> seized over the period — primarily Tramadol and Captagon, manufactured in Libya and Jordan and transiting Algeria en route to West Africa and Europe. Unlike cocaine, which moves through port infrastructure along the northern coast, psychotropic pills travel overland through the Sahara. Their scale dwarfs the cocaine and cannabis figures entirely — and suggests that for every tablet intercepted, many more reach their destination.</p>
        </div>
        <div class="report-image" class:visible={v(18)}>
          <img src="{base}data/anp_output/images/2024-10-30/img_06.jpg" alt="ANP operational report — psychotropic pills" loading="lazy" />
          <p class="img-caption">14,967 psychotropic pills seized — October 2024</p>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 3 — GOLD MINING
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="19">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.gold}">03 — Illegal Gold Mining</span>
        <h2>1,600 Arrests a Month</h2>
        <p>Nothing in the ANP data is more startling in scale than the illegal gold mining figures. Between January 2024 and October 2025, Algerian military units arrested <strong>35,658 people</strong> for illegal artisanal mining — <em>orpaillage</em> — in the country's deep south. That is roughly 1,600 arrests every single month, dwarfing every other category by a factor of more than twenty.</p>
        <p>Every gold-related paragraph in the 143 reports names the same four locations: Tamanrasset, Bordj Badji Mokhtar, Illizi and In Guezzam — a corridor running along Algeria's southern border from Mauritania, Mali and Niger to Libya.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="20">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(20)}>
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

    <section class="scroll-section info-section" data-index="21">
      <div class="prose-block">
        <div class="info-text" class:visible={v(21)}>
          <span class="label">Tamanrasset — Where the Gold Rush Begins</span>
          <p>The mining sites cluster around Abalassa, Arboua and Tin Zahouten — settlements west of Tamanrasset where artisanal pits press against the edges of residential areas. Satellite analysis by <a href="https://humanglemedia.com/an-illicit-gold-economy-is-pushing-desperate-nigerians-into-southern-algeria/" target="_blank">HumAngle</a> shows excavation sites less than five kilometres from town centres, with informal access roads connecting mines to settlements that increasingly function as logistical hubs for extraction operations. The <strong>26,007 generators</strong> seized over 22 months reflects the industrial scale: generators power the pumps used to sluice gold from riverbeds, and dismantling them is the ANP's primary strategy for disrupting sites.</p>
        </div>
        <div class="report-image" class:visible={v(21)}>
          <img src="{base}data/anp_output/images/2025-10-22/img_07.jpg" alt="ANP operational report — gold mining equipment" loading="lazy" />
          <p class="img-caption">Seized gold mining equipment — Tamanrasset region, October 2025</p>
        </div>
      </div>
    </section>

    <!-- Gold: Illizi -->
    <section class="scroll-section" data-index="22">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.gold}">03 — Illegal Gold Mining</span>
        <h2>Illizi — Eastern Gold Fields</h2>
        <p>Illizi's remote terrain harbours significant gold deposits close to the Libyan border. Mining sites here operate within the same armed-group economy documented further west — where ownership of extraction sites, recruitment of fighters, and cross-border smuggling are not separate activities but aspects of a single integrated war economy.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="23">
      <div class="prose-block">
        <div class="info-text" class:visible={v(23)}>
          <span class="label">Gold Pays for Guns</span>
          <p>The mining fields are not simply illegal — they are controlled. Armed Arab and Tuareg groups own the sites, recruit labourers through agents, and pay workers one-third of proceeds after weeks of labour. Theft is punished by amputation or death. Alongside mining, the same networks recruit fighters — offering close to ₦1 million per operation, sums that dwarf anything available legally. According to <a href="https://humanglemedia.com/an-illicit-gold-economy-is-pushing-desperate-nigerians-into-southern-algeria/" target="_blank">HumAngle's</a> reporting, some groups have fought ISWAP, Ansaru, rival factions, and Wagner mercenaries along the Mali border.</p>
          <p>The <a href="https://www.unodc.org/documents/data-and-analysis/tocta_sahel/TOCTA_Sahel_Gold_v5.pdf" target="_blank">UNODC</a> estimates the Sahel produced 228 tons of gold in 2021, worth over $12.6 billion — much of it taxed or controlled by non-state armed groups.</p>
        </div>
      </div>
    </section>

    <!-- Gold: Djanet -->
    <section class="scroll-section" data-index="24">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.gold}">03 — Illegal Gold Mining</span>
        <h2>Djanet — The Libyan Border</h2>
        <p>Djanet, in Algeria's Tassili n'Ajjer region near Libya, sits at the eastern end of the gold corridor. Its remoteness makes it difficult to police and easy to use as a staging point for miners and smugglers crossing from Libya — where weapons have circulated freely since 2011 and where gold smuggling networks feed into the same transnational economy.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="25">
      <div class="prose-block">
        <div class="info-text" class:visible={v(25)}>
          <span class="label">Who Are the Miners?</span>
          <p>The ANP reports refer to those arrested only as "individuals." The reality, documented by <a href="https://humanglemedia.com/an-illicit-gold-economy-is-pushing-desperate-nigerians-into-southern-algeria/" target="_blank">HumAngle</a>, is more specific: many are young men from Nigeria's Borno State — a region devastated by Boko Haram — who travel Maiduguri → Kano → Maradi → Agadez → In Guezzam → Tamanrasset, a journey costing ₦250,000–300,000, often funded by selling family assets. Along the Trans-Saharan Highway they pass decomposed bodies of those who didn't make it. At <strong> more than 1600 arrests per month </strong>, the data shows the scale of enforcement — but says nothing about what drives so many to keep coming. "There was nothing for me in Maiduguri," one miner told HumAngle. "I had no choice."</p>
        </div>
        <div class="report-image" class:visible={v(25)}>
          <img src="{base}data/anp_output/images/2024-03-27/img_05.jpg" alt="ANP operational report — Djanet" loading="lazy" />
          <p class="img-caption">Gold miners arrested — Djanet region, March 2024</p>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 4 — WEAPONS
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="26">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.weapons}">04 — Weapons Seizures</span>
        <h2>The Northeast's Arms Problem</h2>
        <p>While counter-terrorism operations are concentrated in the Saharan south, the weapons seizure data tells a different geographic story. The hotspot here is Algeria's rugged northeast — the Aurès mountains and the Tunisian border corridor — where firearms interceptions cluster around Batna, Khenchela, Tebessa and Constantine.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="27">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(27)}>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.weapons}">981</span>
            <span class="stat-label">Firearms seized</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.weapons}">73</span>
            <span class="stat-label">Hunting rifles seized</span>
          </div>
        </div>
        <div class="info-text" class:visible={v(27)} style="margin-top:1rem">
          <span class="label">Batna</span>
          <p>Batna appears in the weapons data more than any other city — 20+ report weeks. The Aurès region's mountainous terrain provides cover for arms caches, and the city's position near the Tunisian border makes it a transit point for weapons moving in both directions.</p>
        </div>
      </div>
    </section>

    <!-- Weapons: Khenchela -->
    <section class="scroll-section" data-index="28">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.weapons}">04 — Weapons Seizures</span>
        <h2>Khenchela — Arms Town</h2>
        <p>Khenchela is not only a seizure hotspot — it is home to Algeria's own small arms industry. The <a href="https://www.menadefense.net/algerie/lecmk-monte-en-gamme-et-en-calibre/" target="_blank">Entreprise de Construction Militaire de Khenchela (ECMK)</a> has manufactured pistols, submachine guns and assault rifles since the late 1980s, and has recently expanded into Gatling guns and remote weapon stations under Chinese licence. The city sits at the intersection of Algeria's defence production and its ongoing arms interdiction operations — where the same mountainous Aurès terrain that shelters illegal weapons caches also houses the factories producing the state's own arsenal.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="29">
      <div class="prose-block">
        <div class="report-image" class:visible={v(29)}>
          <img src="{base}data/anp_output/images/2024-12-18/img_02.jpg" alt="ANP operational report — Khenchela" loading="lazy" />
          <p class="img-caption">ANP press image — Khenchela region, December 2024</p>
        </div>
      </div>
    </section>

    <!-- Weapons: Constantine -->
    <section class="scroll-section" data-index="30">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.weapons}">04 — Weapons Seizures</span>
        <h2>Constantine</h2>
        <p>Constantine — Algeria's third city and capital of the northeast — also features in the weapons data, reflecting the region's role as a hub for contraband of all kinds moving between the interior and the coast.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="31">
      <div class="prose-block">
        <div class="info-text" class:visible={v(31)}>
          <span class="label">A Regional Pattern</span>
          <p>The clustering of weapons seizures in the northeast — Batna, Khenchela, Constantine, Tebessa — points to a distinct regional dynamic compared to the south. These are not Saharan smuggling routes but denser, more urban networks operating in Algeria's most populated corridor, close to the Tunisian border where weapons have long circulated.</p>
          <p>The illicit weapons economy cannot be separated from the region's legal arms flows. According to <a href="https://www.sipri.org/commentary/topical-backgrounder/2025/recent-trends-international-arms-transfers-middle-east-and-north-africa" target="_blank">SIPRI's 2025 analysis</a>, Algeria was North Africa's largest and one of the world's top 20 arms importers in 2020–24— with Russia supplying 48% of its major weapons, followed by China (19%) and Germany (14%). Neighbouring Morocco, locked in a long-standing rivalry with Algeria over Western Sahara, armed up simultaneously with US weapons (64%), Israeli missiles and Turkish drones. The more arms that flow into a region — legally or otherwise — the more circulate beyond state control.</p>
        </div>
        <div class="report-image" class:visible={v(31)}>
          <img src="{base}data/anp_output/images/2024-11-06/img_06.jpg" alt="ANP operational report — Constantine" loading="lazy" />
          <p class="img-caption">Weapons seized — Wilaya Oum El Bouaghi, Constantine Military Region, February 2025</p>
        </div>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 5 — MIGRATION
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="32">
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
    <section class="scroll-section" data-index="33">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.migration}">05 — Irregular Migration</span>
        <h2>The Saharan Route</h2>
        <p>Tamanrasset is the first major Algerian city reached by migrants crossing from Niger or Mali. Tens of thousands are arrested here each year before they can continue northward. Many are subsequently expelled back across the border.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="34">
      <div class="prose-block">
        <div class="info-text" class:visible={v(34)}>
          <span class="label">Expulsions</span>
          <p>Local NGOs like <a href="https://alarmephonesahara.info/en" target="_blank" rel="noopener noreferrer">Alarm Phone Sahara</a> have documented hundreds of cases of migrants abandoned in the desert after Algerian military expulsions — often without water, food or their belongings. Human rights organisations including <a href="https://www.hrw.org/news/2016/12/09/algeria-halt-summary-deportations" target="_blank" rel="noopener noreferrer">Human Rights Watch</a> and <a href="https://www.amnesty.org/en/documents/mde28/9512/2018/en/" target="_blank" rel="noopener noreferrer">Amnesty International</a> have condemned these systematic <strong>summary expulsions</strong> of migrants from Algeria into the desert. The ANP reports document arrests in numbers but no pictures or what happens next.</p>
        </div>
        <div class="report-image" class:visible={v(34)}>
          <img src="{base}data/anp_output/images/ANP_1200_dossier2_119db663b9.jpg" alt="Alarm Phone Sahara — Tamanrasset/Assamaka" loading="lazy" />
          <p class="img-caption">Alarm Phone Sahara — Migrants expelled from Tamanrasset to Assamaka, Niger</p>
        </div>
      </div>
    </section>

    <!-- Migration: Oran coast -->
    <section class="scroll-section" data-index="35">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.migration}">05 — Irregular Migration</span>
        <h2>Oran — Gateway to Spain</h2>
        <p>On Algeria's northwest Mediterranean coast, Oran is one of the country's major departure points for migrants attempting the crossing to Spain. The city's proximity to the Spanish coast — roughly 200km to Almería — makes it a key node on the western Mediterranean route.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="36">
      <div class="prose-block">
        <div class="stat-grid" class:visible={v(36)}>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.migration}">~35K</span>
            <span class="stat-label">Arrested inland (various nationalities)</span>
          </div>
          <div class="stat-item">
            <span class="stat-value" style="color:{themes.migration}">~20K</span>
            <span class="stat-label">Intercepted on boats at sea</span>
          </div>
        </div>
        <div class="report-image" class:visible={v(36)}>
          <img src="{base}data/anp_output/images/unknown_168/img_09.jpg" alt="ANP operational report — Oran" loading="lazy" />
          <p class="img-caption">Interception of Emigrants — Oran</p>
        </div>
      </div>
    </section>

    <!-- Migration: Annaba -->
    <section class="scroll-section" data-index="37">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.migration}">05 — Irregular Migration</span>
        <h2>Annaba — Port of Departure</h2>
        <p>In Algeria and the wider Maghreb, irregular emigrants are commonly referred to as the <em>harraga</em>, derived from the Arabic word <em>ḥarga</em> (حَرْقَة, "burning") — a metaphor for "burning" borders or identity papers in order to cross into Europe clandestinely. Annaba, close to both Tunisia and the Italian route across the central Mediterranean, has become one of the key departure points associated with this phenomenon.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="38">
      <div class="prose-block">
        <div class="info-text" class:visible={v(38)}>
          <span class="label">What the Numbers Don't Show</span>
          <p>Interviews conducted for this investigation suggest that Algeria's migration governance operates through highly selective security logics: sub-Saharan migrants are disproportionately targeted in arrests and expulsions, whereas some groups — including Northern Malians from the Azawad region — often receive more flexible treatment because of ethnic ties, cross-border networks and regional stability considerations, within a system that officially recognises only Sahrawis, Palestinians and Syrians as broadly eligible for protection.</p>
        </div>
        <div class="report-image" class:visible={v(38)}>
          <img src="{base}data/anp_output/images/2024-10-02/img_11.jpg" alt="ANP operational report — Annaba" loading="lazy" />
          <p class="img-caption">ANP press image — Annaba region, October 2024</p>
        </div>

        <div class="end-note">
          <p><strong>Data:</strong> Algerian Ministry of Defence operational reports, January 2024 – October 2025. Scraped and analysed by the author. Image geolocation via OCR + OpenStreetMap Nominatim.</p>
          <p><strong>Methodology note:</strong> Aggregate statistics (arrests, seizures) are extracted from structured tables and are national totals — they cannot be attributed to individual cities. Location references for statistics in the article are derived from paragraph-level text analysis of 143 full report texts: a city name and theme keyword appearing in the same paragraph was used as a proxy for operational location. Totals should be treated with caution and triangulated with other sources for inference.</p>
        </div>
      </div>
    </section>

  </div><!-- /foreground -->
</div><!-- /scrolly-container -->

<footer>
  <div class="footer-inner">
    <p class="footer-attribution">
      Data:
      <a href="https://www.mdn.dz" target="_blank" rel="noopener noreferrer">Algerian Ministry of National Defence</a> ·
      Wilaya boundaries:
      <a href="https://data.humdata.org/dataset/cod-ab-dza" target="_blank" rel="noopener noreferrer">OCHA HDX Algeria Administrative Boundaries (COD-AB)</a> ·
      Map ©
      <a href="https://www.openstreetmap.org/copyright" target="_blank">OpenStreetMap</a> contributors ·
      Built with Svelte + MapLibre GL
    </p>
    <div class="footer-license">
      <p>
        <strong>Article text &amp; data</strong> ©&nbsp;2026 Sophia Hiss —
        licensed under
        <a href="https://creativecommons.org/licenses/by-nc-nd/4.0/" target="_blank" rel="noopener noreferrer">CC BY-NC-ND 4.0</a>.
        You may share with attribution; no remixing or commercial use.
      </p>
      <p>
        <strong>Code &amp; pipeline</strong> licensed under the
        <a href="https://github.com/data-journalism-26/final-project-sophiahiss4/blob/main/LICENSE-CODE" target="_blank" rel="noopener noreferrer">MIT License</a>.
      </p>
    </div>
  </div>
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

  /* ── Links — ensure tap targets are readable ── */
  :global(a) {
    color: #c8a96e;
    text-decoration: underline;
    text-underline-offset: 3px;
  }
  :global(a:hover) { color: #f0e8d8; }

  /* ── Region list ── */
  .region-list { display: flex; flex-direction: column; gap: 0.6rem; margin-top: 1rem; }
  .region-item {
    display: grid;
    grid-template-columns: 3rem 1fr;
    grid-template-rows: auto auto;
    gap: 0.15rem 0.5rem;
    border-left: 3px solid;
    padding: 0.4rem 0.6rem;
    background: rgba(255,255,255,0.03);
    border-radius: 2px;
  }
  .region-code {
    font-weight: 700; font-size: 0.8rem;
    grid-row: 1; grid-column: 1;
    align-self: center;
  }
  .region-name {
    font-size: 0.82rem; color: #f0e8d8; font-weight: 600;
    grid-row: 1; grid-column: 2;
  }
  .region-desc {
    font-size: 0.75rem; color: #6a6060; line-height: 1.3;
    grid-row: 2; grid-column: 2;
  }

  /* ── Hero ── */
  .hero {
    min-height: 100svh; /* svh avoids mobile browser chrome issues */
    display: flex; align-items: center; justify-content: center;
    background: radial-gradient(ellipse at 60% 40%, #1a1208 0%, #08080f 70%);
    padding: 2rem 1.25rem;
    position: relative; overflow: hidden;
  }
  .hero-inner {
    max-width: 680px; text-align: center;
    position: relative; z-index: 1;
  }
  .kicker {
    font-size: 0.7rem; text-transform: uppercase;
    letter-spacing: 0.2em; color: #c8a96e; margin-bottom: 1.25rem;
  }
  .hero-inner h1 {
    font-family: 'Playfair Display', Georgia, serif;
    font-size: clamp(2rem, 8vw, 5rem);
    font-weight: 900; line-height: 1.05;
    color: #f0e8d8; margin-bottom: 1.25rem;
  }
  .hero-inner h1 em { color: #c8a96e; font-style: italic; }
  .subtitle {
    font-size: clamp(0.9rem, 2.5vw, 1.05rem);
    line-height: 1.7; color: #9a9080;
    max-width: 540px; margin: 0 auto 2.5rem;
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
    50%       { transform: translateY(6px); }
  }

  /* ══════════════════════════════════════════════
     SCROLLY LAYOUT — desktop: side-by-side
     mobile:         map on top, prose below
  ══════════════════════════════════════════════ */
  .scrolly-container {
    display: grid;
    grid-template-columns: 1fr 420px; /* map left, prose right on desktop */
  }

  /* ── Sticky map ── */
  .map-sticky {
    position: sticky; top: 0; height: 100vh;
    align-self: start;
    background: #08080f; overflow: hidden;
    order: 1; /* map first column on desktop */
  }
  .step-counter {
    position: absolute; top: 1rem; left: 1rem;
    background: rgba(8,8,15,0.82);
    border: 1px solid rgba(200,169,110,0.3);
    padding: 0.35rem 0.8rem; border-radius: 3px;
    z-index: 10; backdrop-filter: blur(6px);
  }
  .step-counter span {
    font-size: 0.72rem; text-transform: uppercase;
    letter-spacing: 0.12em; color: #c8a96e;
  }

  /* ── Foreground prose ── */
  .foreground {
    display: flex; flex-direction: column;
    padding: 2rem 1.5rem;
    order: 2;
  }

  /* ── Sections ── */
  .scroll-section {
    min-height: 100vh;
    display: flex; align-items: center;
  }
  .info-section { min-height: 70vh; }

  .prose-block {
    width: 100%;
    background: rgba(8,8,15,0.88);
    border: 1px solid rgba(200,169,110,0.15);
    border-radius: 4px;
    padding: 1.75rem 1.5rem;
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
    font-size: clamp(1.3rem, 4vw, 1.8rem);
    font-weight: 700; color: #f0e8d8;
    line-height: 1.2; margin-bottom: 1rem;
  }
  .prose-block p {
    font-size: clamp(0.88rem, 2.2vw, 0.95rem);
    line-height: 1.75; color: #9a9080;
    margin-bottom: 0.85rem;
  }
  .prose-block p:last-child { margin-bottom: 0; }
  .prose-block strong { color: #c8a96e; }
  .prose-block em     { font-style: italic; color: #b8a898; }

  /* ── Stat grid ── */
  .stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
    gap: 1rem; margin-bottom: 0.5rem;
    opacity: 0; transform: translateY(12px);
    transition: opacity 0.6s ease, transform 0.6s ease;
  }
  .stat-grid.visible { opacity: 1; transform: translateY(0); }
  .stat-item  { display: flex; flex-direction: column; gap: 0.3rem; }
  .stat-value {
    font-family: 'Playfair Display', Georgia, serif;
    font-size: clamp(1.5rem, 5vw, 2rem);
    font-weight: 900; line-height: 1;
  }
  .stat-label {
    font-size: 0.7rem; text-transform: uppercase;
    letter-spacing: 0.08em; color: #6a6060; line-height: 1.3;
  }

  /* ── Info text boxes ── */
  .info-text {
    background: rgba(200,169,110,0.06);
    border-left: 3px solid #c8a96e;
    border-radius: 2px; padding: 1rem 1.1rem;
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
    font-size: clamp(0.82rem, 2vw, 0.88rem);
    line-height: 1.7; color: #9a9080; margin: 0;
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

  /* ── End note ── */
  .end-note {
    margin-top: 2rem; padding-top: 1.5rem;
    border-top: 1px solid rgba(200,169,110,0.15);
  }
  .end-note p { font-size: 0.78rem; color: #454035; margin-bottom: 0.5rem !important; }

  /* ── Footer ── */
  footer {
    background: #04040a; padding: 2rem 0;
    border-top: 1px solid rgba(200,169,110,0.1);
  }
  .footer-inner {
    max-width: 900px; margin: 0 auto;
    padding: 0 1.5rem;
    display: flex; flex-direction: column; gap: 1rem;
  }
  .footer-attribution {
    font-size: 0.75rem; color: #403830;
    line-height: 1.6;
  }
  .footer-attribution a {
    color: #6a5840; text-decoration: none;
    min-height: 44px; display: inline; /* tap target handled by line-height */
  }
  .footer-attribution a:hover { color: #c8a96e; }

  .footer-license {
    border-top: 1px solid rgba(200,169,110,0.08);
    padding-top: 1rem;
    display: flex; flex-direction: column; gap: 0.35rem;
  }
  .footer-license p {
    font-size: 0.72rem; color: #504838;
    line-height: 1.55; margin: 0;
  }
  .footer-license strong { color: #6a5840; }
  .footer-license a { color: #6a5840; }
  .footer-license a:hover { color: #c8a96e; }

  /* ══════════════════════════════════════════════
     MOBILE  ≤ 700px
     Stack: map (40svh) pinned at top, prose scrolls below
  ══════════════════════════════════════════════ */
  @media (max-width: 700px) {

    /* Switch to single-column stack: map on top */
    .scrolly-container {
      grid-template-columns: 1fr;
      grid-template-rows: auto 1fr;
    }

    /* Map sits at the top as a normal (non-sticky) block
       so it doesn't fight the foreground for space */
    .map-sticky {
      position: sticky;
      top: 0;
      height: 40svh;        /* shorter on phone */
      min-height: 220px;
      order: 1;
      z-index: 10;
    }

    .step-counter {
      top: 0.5rem; left: 0.5rem;
      padding: 0.25rem 0.6rem;
    }

    /* Foreground prose sits below the map */
    .foreground {
      order: 2;
      padding: 1.25rem 1rem;
    }

    /* Sections don't need full-viewport height on mobile —
       the map is always visible above */
    .scroll-section {
      min-height: auto;
      padding: 2rem 0;
    }
    .info-section {
      min-height: auto;
      padding: 1.5rem 0;
    }

    .prose-block {
      padding: 1.25rem 1rem;
    }

    /* Stat numbers scale down gracefully */
    .stat-grid {
      grid-template-columns: repeat(auto-fit, minmax(85px, 1fr));
      gap: 0.75rem;
    }

    /* Region list: tighten on small screens */
    .region-item {
      grid-template-columns: 2.75rem 1fr;
    }
    .region-code { font-size: 0.72rem; }
    .region-name { font-size: 0.78rem; }
    .region-desc { font-size: 0.7rem; }

    /* Footer wraps gracefully */
    .footer-inner { padding: 0 1rem; }
    .footer-attribution { font-size: 0.7rem; }

    /* Ensure all links are comfortably tappable */
    .prose-block a,
    .info-text a {
      display: inline-block;
      min-height: 44px;
      line-height: 44px;
      padding: 0 1px;
    }
  }

  /* ── Narrow edge case (≤ 380px) ── */
  @media (max-width: 380px) {
    .hero-inner h1 { font-size: 1.85rem; }
    .stat-value    { font-size: 1.35rem; }
    .stat-grid     { grid-template-columns: 1fr 1fr; }
  }
</style>