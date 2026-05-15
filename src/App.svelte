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
        <p>The army and secret service possess considerable decision-making power and executive authority in Algeria, but usually data on the "black box Algeria" is largely unacessible.</p>
        <p>These reports therefore offer an unusual glimpse into how the Algerian state documents and communicates its security operations.</p>
      </div>
    </section>

    <!-- ═══════════════════════════════════════════
         SECTION 1 — TERRORISM
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="1">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color: {themes.terrorism}">01 — Counter-Terrorism</span>
        <h2>The Saharan Front</h2>
        <p>Algeria's deep south remains the primary theatre of counter-terrorism operations. The 6th Military Region — covering the counties or <em>wilayas</em> of Bordj Baji Mokhta, Tamanrasset, In Salah and In Guezzam  — covers a territory larger than Western Europe and shares porous borders with Mali, Niger and Libya.</p>
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
          <img src="{base}data/anp_output/images/2024-02-14/img_01.jpg" alt="Armed security personnel inspecting seized weapons in a desert operations context near Tamanrasset during a counterterrorism report" loading="lazy" />
          <p class="img-caption">ANP press image — Tamanrasset region, February 2024</p>
        </div>
      </div>
    </section>

    <!-- Bordj Badji Mokhtar -->
    <section class="scroll-section" data-index="4">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.terrorism}">01 — Counter-Terrorism</span>
        <h2>One Wilaya. One Third of All Reports.</h2>
        <p>Of all the wilayas in Algeria's vast southern interior, one name stands out with striking consistency: Bordj Badji Mokhtar, a few kilometres from the Malian border. A text analysis of all 143 weekly reports found it mentioned in a counter-terrorism contextin <strong>33 separate reports</strong> — more than twice the frequency of any other wilaya.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="5">
      <div class="prose-block">
    <div class="info-text" class:visible={v(5)}>
      <span class="label">Algeria's Terrorism Trauma</span>
      <p>The ANP reports describe surrenders of armed individuals at Bordj Badji Mokhtar with near-weekly regularity, often naming militants alongside their <em>nom de guerre</em>.</p>
      <p>These reports must be understood in the context of Algeria's enduring security doctrine, deeply shaped by the trauma of the <a href="https://www.monde-diplomatique.fr/2017/08/DAUM/57773" target="_blank">Black Decade</a> or <em>Décennie Noire</em> (1992–2002), a civil war that continues to structure state narratives around stability, terrorism and national survival.</p>
    </div>  
        <div class="report-image" class:visible={v(5)}>
          <img src="{base}data/anp_output/images/2024-06-12/img_01.jpg" alt="Military personnel and vehicles at a remote border location near Bordj Badji Mokhtar, conveying active counterterrorism surveillance in the Sahara" loading="lazy" />
          <p class="img-caption">ANP press image — Bordj Badji Mokhtar region, June 2024</p>
        </div>
      </div>
    </section>

    <!-- In Guezzam -->
    <section class="scroll-section" data-index="6">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.terrorism}">01 — Counter-Terrorism</span>
        <h2>In Guezzam — Eastern Sahara</h2>
        <p>In Guezzam sits near Algeria's border with Niger and Libya, another source of instability. Especially after the Fall of Muammar Gadaffi in Libya in 2012. ANP reports from this region document both terrorism-related arrests and the seizure of weapons caches.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="7">
      <div class="prose-block">
        <div class="info-text" class:visible={v(7)}>
          <span class="label">In Guezzam</span>
          <p><p>The military’s communication strategy surrounding these operations is often explicitly deterrent. Official reports regularly publish graphic and sometimes unblurred images of dead bodies, weapons and captured equipment — visual performances of force. In a country where the memory of the civil war remains deeply embedded in public consciousness, these images reinforce a long-standing regime narrative: that the military alone stands between Algeria and a return to chaos. The reporting therefore serves to reproduce the state’s self-presentation as the sole guarantor of order, stability and protection against Islamism and terrorism.</p>
        </div>
        <div class="report-image" class:visible={v(7)}>
          <img src="{base}data/anp_output/images/2024-07-10/img_01.jpg" alt="ANP capture of killed suspected militants" loading="lazy" />
          <p class="img-caption">ANP press image — In Guezzam region, January 2024</p>
        </div>
      </div>
    </section>

    <!-- Terrorism summary -->
    <section class="scroll-section info-section" data-index="8">
      <div class="prose-block">
        <div class="info-text" class:visible={v(8)}>
          <span class="label">Counter-Terrorism in Context</span>
          <p>While domestic insurgency largely declined after the mid-2000s, terrorism increasingly came to be framed as an external and transnational threat emanating from the Sahel, allowing irregular migration, smuggling and border mobility to be incorporated into a broader security continuum. In this sense, the reports reveal less about the objective scale of militant activity than about how the Algerian state continues to narrate insecurity and justify exceptional security governance.</p>
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
            <span class="stat-label"> Terrorism-related arrests per month</span>
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
        <p>El Oued, in Algeria's northeast near the Tunisian border, appears more frequently in ANP drug reports than any other city. It sits at the end of trans-Saharan <em>cannabis routes</em> originating in Morocco's Rif mountains — and has become a key node in a narcotics economy that now stretches from South America to suburban European markets.</p>
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
          <p>El Oued appeared in <strong>18 separate report weeks</strong> — more than any other city in the dataset. The region's proximity to Tunisia makes it a critical transit point: cannabis pressed in Morocco's Rif mountains travels east through Algeria before crossing into Tunisia and onward to Europe. ANP operations here consistently document large hauls alongside seized 4x4 trucks adapted for desert crossings.</p>
        </div>
        <div class="report-image" class:visible={v(12)}>
          <img src="{base}data/anp_output/images/2025-03-27/img_13.jpg" alt="ANP operational report — El Oued" loading="lazy" />
          <p class="img-caption">Seized vehicles — El Oued region, March 2025</p>
        </div>
      </div>
    </section>

    <!-- Oran -->
    <section class="scroll-section" data-index="13">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.drugs}">02 — Drug Interdiction</span>
        <h2>The Golden Arc</h2>
        <p>Algeria was long absent from cocaine trafficking maps. That changed in 2018, when 701kg of cocaine were seized at the port of Oran — hidden in a frozen meat container that had travelled from Brazil via Spain. The scandal, known as <em>cocaine-gate</em>, exposed a route that analysts at the Institute for Security Studies <a href="https://enactafrica.org/enact-observer/la-saisie-algerienne-de-cocaine-revele-des-tendances-alarmantes" target="_blank">described</a> as a <strong>"golden arc"</strong>: the North African coastline from Casablanca through Oran to Algiers — just 200km from Spain, woven into existing cannabis networks, and increasingly exploited by South American cartels.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="14">
      <div class="prose-block">
        <div class="info-text" class:visible={v(14)}>
          <span class="label">Oran — The Golden Arc</span>
          <p>Oran sits at the junction of north-south and east-west Saharan routes — a crossroads for virtually every form of contraband moving through Algeria's interior. ANP images from the region show packaged drugs alongside seized vehicles. Experts estimate that seizures represent only around 10% of actual trafficking volumes, suggesting that what the military intercepts is the visible fraction of a much larger flow.</p>
        </div>
        <div class="report-image" class:visible={v(14)}>
          <img src="{base}data/anp_output/images/2024-12-04/img_02.jpg" alt="ANP operational report — Oran" loading="lazy" />
          <p class="img-caption">A wall of packed drugs seized in Oran, December 2024</p>
        </div>
      </div>
    </section>

    <!-- Tebessa -->
    <section class="scroll-section" data-index="15">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.drugs}">02 — Drug Interdiction</span>
        <h2>Tebessa — The Tunisian Border</h2>
        <p>Tebessa, in Algeria's far northeast, sits on the Tunisian border — a corridor that has become an increasingly active transit zone for narcotics moving toward European markets. The route from Brazil to Spain to Algeria, first documented in the Oran cocaine-gate case, has established infrastructure that extends across the country's northeastern corridor.</p>
      </div>
    </section>

    <section class="scroll-section info-section" data-index="16">
      <div class="prose-block">
        <div class="info-text" class:visible={v(16)}>
          <span class="label">Cocaine — A New Geography</span>
          <p>The <strong>7,306 kg of cocaine</strong> seized over 22 months reflects an established pattern, not an anomaly. The 2018 Oran seizure revealed that South American cartels had already secured the route — testing it with small shipments before scaling up. The well-established ties between those cartels and Moroccan cannabis traffickers, who in turn have deep networks across northwestern Algeria, made the country a natural extension of existing supply chains. Seizures, analysts caution, represent only a fraction of what moves through.</p>
        </div>
        <div class="report-image" class:visible={v(16)}>
          <img src="{base}data/anp_output/images/2025-04-13/img_02.jpg" alt="ANP operational report — cocaine seizure" loading="lazy" />
          <p class="img-caption">66 kg of cocaine seized — April 2025</p>
        </div>
      </div>
    </section>

    <!-- Drugs summary -->
    <section class="scroll-section info-section" data-index="17">
      <div class="prose-block">
        <div class="info-text" class:visible={v(17)}>
          <span class="label">58 Million Pills</span>
          <p>The most striking drug figure is the <strong>58 million psychotropic pills</strong> seized over the period — primarily Tramadol and Captagon, manufactured in Libya and Jordan and transiting Algeria en route to West Africa and Europe. Unlike cocaine, which moves through port infrastructure along the northern coast, psychotropic pills travel overland through the Sahara. Their scale dwarfs the cocaine and cannabis figures entirely — and suggests that for every tablet intercepted, many more reach their destination.</p>
        </div>
        <div class="report-image" class:visible={v(17)}>
          <img src="{base}data/anp_output/images/2024-10-30/img_06.jpg" alt="ANP operational report — psychotropic pills" loading="lazy" />
          <p class="img-caption">14,967 psychotropic pills seized — October 2024</p>
        </div>
      </div>
    </section>
    <!-- ═══════════════════════════════════════════
         SECTION 3 — GOLD MINING
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="18">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.gold}">03 — Illegal Gold Mining</span>
        <h2>1,600 Arrests a Month</h2>
        <p>Nothing in the ANP data is more startling in scale than the illegal gold mining figures. Between January 2024 and October 2025, Algerian military units arrested <strong>35,658 people</strong> for illegal artisanal mining — <em>orpaillage</em> — in the country's deep south. That is roughly 1,600 arrests every single month, dwarfing every other category by a factor of more than twenty.</p>
        <p>Every gold-related paragraph in the 143 reports names the same four locations: Tamanrasset, Bordj Badji Mokhtar, Illizi and In Guezzam — a corridor running along Algeria's southern border from Mauritania, Mali and Niger to Libya.</p>
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
      <span class="label">Tamanrasset — Where the Gold Rush Begins</span>
      <p>The mining sites cluster around Abalassa, Arboua and Tin Zahouten — settlements west of Tamanrasset where artisanal pits press against the edges of residential areas. Satellite analysis by <a href="https://humanglemedia.com/an-illicit-gold-economy-is-pushing-desperate-nigerians-into-southern-algeria/" target="_blank">HumAngle</a> shows excavation sites less than five kilometres from town centres, with informal access roads connecting mines to settlements that increasingly function as logistical hubs for extraction operations. The <strong>26,007 generators</strong> seized over 22 months reflects the industrial scale: generators power the pumps used to sluice gold from riverbeds, and dismantling them is the ANP's primary strategy for disrupting sites.</p>
    </div>
    <div class="report-image" class:visible={v(20)}>
      <img src="{base}data/anp_output/images/2025-10-22/img_07.jpg" alt="ANP operational report — gold mining equipment" loading="lazy" />
      <p class="img-caption">Seized gold mining equipment — Tamanrasset region, October 2025</p>
    </div>
  </div>
</section>

<!-- Gold: Illizi -->
<section class="scroll-section" data-index="21">
  <div class="prose-block">
    <span class="section-tag theme-tag" style="color:{themes.gold}">03 — Illegal Gold Mining</span>
    <h2>Illizi — Eastern Gold Fields</h2>
    <p>Illizi's remote terrain harbours significant gold deposits close to the Libyan border. Mining sites here operate within the same armed-group economy documented further west — where ownership of extraction sites, recruitment of fighters, and cross-border smuggling are not separate activities but aspects of a single integrated war economy.</p>
  </div>
</section>

<section class="scroll-section info-section" data-index="22">
  <div class="prose-block">
    <div class="info-text" class:visible={v(22)}>
      <span class="label">Gold Pays for Guns</span>
  <p>The mining fields are not simply illegal — they are controlled. Armed Arab and Tuareg groups own the sites, recruit labourers through agents, and pay workers one-third of proceeds after weeks of labour. Theft is punished by amputation or death. Alongside mining, the same networks recruit fighters — offering close to ₦1 million per operation, sums that dwarf anything available legally. According to <a href="https://humanglemedia.com/an-illicit-gold-economy-is-pushing-desperate-nigerians-into-southern-algeria/" target="_blank">HumAngle's</a> reporting, some groups have fought ISWAP, Ansaru, rival factions, and Wagner mercenaries along the Mali border.</p>
  <p>The <a href="https://www.unodc.org/documents/data-and-analysis/tocta_sahel/TOCTA_Sahel_Gold_v5.pdf" target="_blank">UNODC</a> estimates the Sahel produced 228 tons of gold in 2021, worth over $12.6 billion — much of it taxed or controlled by non-state armed groups.</p>    </div>
  </div>
</section>

<!-- Gold: Djanet -->
<section class="scroll-section" data-index="23">
  <div class="prose-block">
    <span class="section-tag theme-tag" style="color:{themes.gold}">03 — Illegal Gold Mining</span>
    <h2>Djanet — The Libyan Border</h2>
    <p>Djanet, in Algeria's Tassili n'Ajjer region near Libya, sits at the eastern end of the gold corridor. Its remoteness makes it difficult to police and easy to use as a staging point for miners and smugglers crossing from Libya — where weapons have circulated freely since 2011 and where gold smuggling networks feed into the same transnational economy.</p>
  </div>
</section>

<section class="scroll-section info-section" data-index="24">
  <div class="prose-block">
    <div class="info-text" class:visible={v(24)}>
      <span class="label">Who Are the Miners?</span>
      <p>The ANP reports refer to those arrested only as "individuals." The reality, documented by <a href="https://humanglemedia.com/an-illicit-gold-economy-is-pushing-desperate-nigerians-into-southern-algeria/" target="_blank">HumAngle</a>, is more specific: many are young men from Nigeria's Borno State — a region devastated by Boko Haram — who travel Maiduguri → Kano → Maradi → Agadez → In Guezzam → Tamanrasset, a journey costing ₦250,000–300,000, often funded by selling family assets. Along the Trans-Saharan Highway they pass decomposed bodies of those who didn't make it. At <strong>35,658 arrests in 22 months</strong>, the data shows the scale of enforcement — but says nothing about what drives so many to keep coming. "There was nothing for me in Maiduguri," one miner told HumAngle. "I had no choice."</p>
    </div>
    <div class="report-image" class:visible={v(24)}>
      <img src="{base}data/anp_output/images/2024-04-09/img_11.jpg" alt="ANP operational report — Djanet" loading="lazy" />
      <p class="img-caption">Gold miners arrested — Djanet region, April 2024</p>
    </div>
  </div>
</section>

    <!-- ═══════════════════════════════════════════
         SECTION 4 — WEAPONS
    ════════════════════════════════════════════ -->
    <section class="scroll-section" data-index="25">
      <div class="prose-block">
        <span class="section-tag theme-tag" style="color:{themes.weapons}">04 — Weapons Seizures</span>
        <h2>The Northeast's Arms Problem</h2>
        <p>While counter-terrorism operations are concentrated in the Saharan south, the weapons seizure data tells a different geographic story. The hotspot here is Algeria's rugged northeast — the Aurès mountains and the Tunisian border corridor — where firearms interceptions cluster around Batna, Khenchela, Tebessa and Constantine. Text analysis found Khenchela mentioned in a weapons context in <strong>nine separate reports</strong>, more than any other northeastern city.</p>
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
    <h2>Khenchela — Arms Town</h2>
    <p>Khenchela is not only a seizure hotspot — it is home to Algeria's own small arms industry. The <a href="https://www.menadefense.net/algerie/lecmk-monte-en-gamme-et-en-calibre/" target="_blank">Entreprise de Construction Militaire de Khenchela (ECMK)</a> has manufactured pistols, submachine guns and assault rifles since the late 1980s, and has recently expanded into Gatling guns and remote weapon stations under Chinese licence. The city sits at the intersection of Algeria's defence production and its ongoing arms interdiction operations — where the same mountainous Aurès terrain that shelters illegal weapons caches also houses the factories producing the state's own arsenal.</p>
  </div>
</section>

    <section class="scroll-section info-section" data-index="28">
      <div class="prose-block">
        <div class="report-image" class:visible={v(28)}>
          <img src="{base}data\anp_output\images\2024-12-18\img_02.jpg" alt="ANP operational report — Khenchela" loading="lazy" />
          <p class="img-caption">ANP press image — Khenchela region, December 2024</p>
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
      <p>The clustering of weapons seizures in the northeast — Batna, Khenchela, Constantine, Tebessa — points to a distinct regional dynamic compared to the south. These are not Saharan smuggling routes but denser, more urban networks operating in Algeria's most populated corridor, close to the Tunisian border where weapons have long circulated.</p>
      <p>The illicit weapons economy cannot be separated from the region's legal arms flows. According to <a href="https://www.sipri.org/commentary/topical-backgrounder/2025/recent-trends-international-arms-transfers-middle-east-and-north-africa" target="_blank">SIPRI's 2025 analysis</a>, Algeria was the world's 21st largest arms importer in 2020–24 — with Russia supplying 48% of its major weapons, followed by China (19%) and Germany (14%). Neighbouring Morocco, locked in a long-standing rivalry with Algeria over Western Sahara, armed up simultaneously with US weapons (64%), Israeli missiles and Turkish drones. The more arms that flow into a region — legally or otherwise — the more circulate beyond state control. The hunting rifles, pistols and firearms that ANP units seize in the Aurès mountains are the downstream residue of a heavily militarised neighbourhood.</p>
    </div>
    <div class="report-image" class:visible={v(30)}>
      <img src="{base}data\anp_output\images\2024-11-06\img_06.jpg" alt="ANP operational report — Constantine" loading="lazy" />
      <p class="img-caption">Weapons seized — Wilaya Oum El Bouaghi, Constantine Military Region, February 2025</p>
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
      <p>Human rights organisations including Human Rights Watch and Amnesty International have documented systematic <strong>summary expulsions</strong> of migrants from Algeria into the desert — often without water, food or their belongings. The ANP reports document arrests but not what happens next.</p>
    </div>
    <div class="report-image" class:visible={v(33)}>
      <img src="{base}data/anp_output/images/ANP_1200_dossier2_119db663b9.jpg" alt="Alarm Phone Sahara — Tamanrasset/Assamaka" loading="lazy" />
      <p class="img-caption">Alarm Phone Sahara — Migrants expelled from Tamanrasset to Assamaka, Niger</p>
    </div>
  </div>
</section>

<!-- Migration: Oran coast -->
<section class="scroll-section" data-index="34">
  <div class="prose-block">
    <span class="section-tag theme-tag" style="color:{themes.migration}">05 — Irregular Migration</span>
    <h2>Oran — Gateway to Spain</h2>
    <p>On Algeria's northwest Mediterranean coast, Oran is one of the country's major departure points for migrants attempting the crossing to Spain. The city's proximity to the Spanish coast — roughly 200km to Almería — makes it a key node on the western Mediterranean route.</p>
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
          <img src="{base}data/anp_output/images/2024-02-28/img_12.jpg" alt="ANP operational report — Oran" loading="lazy" />
          <p class="img-caption">Interception of Migrants— Oran region, February 2024</p>
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
          <p><strong>Methodology note:</strong> Aggregate statistics (arrests, seizures) are extracted from structured tables and are national totals — they cannot be attributed to individual cities. Location references in the article are derived from paragraph-level text analysis of 143 full report texts: a city name and theme keyword appearing in the same paragraph was used as a proxy for operational location. Totals should be treated with caution and triangulated with other sources for inference.</p>
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