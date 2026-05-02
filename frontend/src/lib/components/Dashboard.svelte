<script lang="ts">
	import { onMount } from 'svelte'
	import { listRecords } from '../api'
	import type { GenericRecord } from '../types'

	let loading = true
	let error = ''

	let laboratori = 0
	let moduli = 0
	let forniture = 0
	let budgetTotale = 0
	let totaliLaboratorio: GenericRecord[] = []
	let dettaglioForniture: GenericRecord[] = []

	const currency = new Intl.NumberFormat('it-IT', {
		style: 'currency',
		currency: 'EUR',
		maximumFractionDigits: 2
	})

	onMount(async () => {
		try {
			const [laboratoriResponse, moduliResponse, fornitureResponse, totaliResponse, dettagliResponse] =
				await Promise.all([
					listRecords('Laboratorio'),
					listRecords('Modulo'),
					listRecords('Fornitura'),
					listRecords('CostoTotalePerLaboratorio'),
					listRecords('DettaglioForniture')
				])

			laboratori = laboratoriResponse.records.length
			moduli = moduliResponse.records.length
			forniture = fornitureResponse.records.length
			totaliLaboratorio = totaliResponse.records
			dettaglioForniture = dettagliResponse.records.slice(0, 8)
			budgetTotale = totaliLaboratorio.reduce(
				(total, row) => total + Number(row.costoTotale ?? 0),
				0
			)
		} catch (dashboardError) {
			error =
				dashboardError instanceof Error ? dashboardError.message : 'Errore nel caricamento dashboard'
		} finally {
			loading = false
		}
	})
</script>

<section class="dashboard">
	<header class="section-header">
		<div>
			<h2>Dashboard</h2>
			<p>Vista sintetica del progetto laboratori e del piano acquisti.</p>
		</div>
	</header>

	{#if error}
		<p class="error">{error}</p>
	{:else if loading}
		<p>Caricamento dashboard...</p>
	{:else}
		<div class="stats-grid">
			<div class="stat-card">
				<span class="label">Laboratori</span>
				<strong>{laboratori}</strong>
			</div>
			<div class="stat-card">
				<span class="label">Moduli</span>
				<strong>{moduli}</strong>
			</div>
			<div class="stat-card">
				<span class="label">Forniture</span>
				<strong>{forniture}</strong>
			</div>
			<div class="stat-card">
				<span class="label">Budget allocato</span>
				<strong>{currency.format(budgetTotale)}</strong>
			</div>
		</div>

		<div class="dashboard-grid">
			<div class="card">
				<h3>Costo totale per laboratorio</h3>
				<ul class="summary-list">
					{#each totaliLaboratorio as row}
						<li>
							<span>{row.laboratorio}</span>
							<strong>{currency.format(Number(row.costoTotale ?? 0))}</strong>
						</li>
					{/each}
				</ul>
			</div>

			<div class="card">
				<h3>Dettaglio forniture</h3>
				<ul class="detail-list">
					{#each dettaglioForniture as row}
						<li>
							<div>
								<strong>{row.fornitura}</strong>
								<p>{row.laboratorio}</p>
							</div>
							<span>{row.quantita} x {currency.format(Number(row.prezzo ?? 0))}</span>
						</li>
					{/each}
				</ul>
			</div>
		</div>
	{/if}
</section>
