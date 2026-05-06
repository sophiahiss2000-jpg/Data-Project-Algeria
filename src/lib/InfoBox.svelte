<script>
  export let type = 'text';  // 'text' | 'stat' | 'chart'
  export let visible = false;

  // For stat type
  export let stats = [];

  // For chart type (simple bar chart via SVG)
  export let chartData = [];
  export let chartTitle = '';
</script>

<div class="infobox" class:visible class:stat={type === 'stat'} class:chart={type === 'chart'}>
  {#if type === 'text'}
    <slot />
  {/if}

  {#if type === 'stat'}
    <div class="stat-grid">
      {#each stats as s}
        <div class="stat-item">
          <span class="stat-value">{s.value}</span>
          <span class="stat-label">{s.label}</span>
        </div>
      {/each}
    </div>
  {/if}

  {#if type === 'chart'}
    <p class="chart-title">{chartTitle}</p>
    <div class="bar-chart">
      {#each chartData as d, i}
        <div class="bar-row">
          <span class="bar-cat">{d.label}</span>
          <div class="bar-track">
            <div
              class="bar-fill"
              style="width: {visible ? d.pct : 0}%; transition-delay: {i * 0.1}s"
            ></div>
          </div>
          <span class="bar-val">{d.value}</span>
        </div>
      {/each}
    </div>
  {/if}
</div>

<style>
  .infobox {
    background: rgba(12, 12, 18, 0.88);
    border: 1px solid rgba(200, 169, 110, 0.25);
    border-left: 3px solid #c8a96e;
    border-radius: 3px;
    padding: 1.4rem 1.6rem;
    margin: 1.5rem 0;
    backdrop-filter: blur(8px);
    opacity: 0;
    transform: translateY(16px);
    transition: opacity 0.6s ease, transform 0.6s ease;
    color: #e8e0d0;
  }

  .infobox.visible {
    opacity: 1;
    transform: translateY(0);
  }

  /* Stat type */
  .stat-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
    gap: 1rem;
  }

  .stat-item {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .stat-value {
    font-family: 'Playfair Display', serif;
    font-size: 2.2rem;
    font-weight: 900;
    color: #c8a96e;
    line-height: 1;
  }

  .stat-label {
    font-family: 'Source Serif 4', serif;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    color: #8a8070;
  }

  /* Chart type */
  .chart-title {
    font-family: 'Source Serif 4', serif;
    font-size: 0.8rem;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    color: #8a8070;
    margin: 0 0 1rem 0;
  }

  .bar-chart {
    display: flex;
    flex-direction: column;
    gap: 0.65rem;
  }

  .bar-row {
    display: grid;
    grid-template-columns: 120px 1fr 50px;
    align-items: center;
    gap: 0.75rem;
  }

  .bar-cat {
    font-family: 'Source Serif 4', serif;
    font-size: 0.78rem;
    color: #b8a898;
    text-align: right;
  }

  .bar-track {
    height: 14px;
    background: rgba(200, 169, 110, 0.12);
    border-radius: 2px;
    overflow: hidden;
  }

  .bar-fill {
    height: 100%;
    background: linear-gradient(90deg, #c8a96e, #e05c3a);
    border-radius: 2px;
    transition: width 0.9s cubic-bezier(0.22, 1, 0.36, 1);
  }

  .bar-val {
    font-family: 'Source Serif 4', serif;
    font-size: 0.78rem;
    color: #c8a96e;
    font-weight: 600;
  }

  /* Text type – slots get these styles */
  :global(.infobox p) {
    font-family: 'Source Serif 4', serif;
    font-size: 0.95rem;
    line-height: 1.7;
    margin: 0;
    color: #d8cfc0;
  }

  :global(.infobox strong) {
    color: #c8a96e;
    font-weight: 600;
  }

  :global(.infobox .label) {
    font-size: 0.72rem;
    text-transform: uppercase;
    letter-spacing: 0.12em;
    color: #8a8070;
    display: block;
    margin-bottom: 0.5rem;
  }
</style>
