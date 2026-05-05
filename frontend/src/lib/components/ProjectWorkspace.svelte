<script lang="ts">
	import { onMount } from 'svelte'
	import {
		createProject,
		createRecord,
		deleteRecord,
		getProjectDetail,
		getProjectLookups,
		listProjects,
		updateRecord
	} from '../api'
	import type { GenericRecord } from '../types'
	import type {
		FinancingCreatePayload,
		LookupOption,
		ProjectCreatePayload,
		ProjectDetailResponse,
		ProjectLaboratory,
		ProjectModule,
		ProjectSummary,
		SessionUser
	} from '../types'

	export let user: SessionUser

	type ProjectFormState = {
		idFinanziamento: string
		idIstitutoCapofila: string
		codice: string
		progetto: string
		tipologia: string
		descrizione: string
		ambientiMinimi: string
		partecipantiMinimi: string
	}

	type LaboratoryFormState = {
		idPlesso: string
		laboratorio: string
		aula: string
		descrizione: string
	}

	type ModuleFormState = {
		idLaboratorio: string
		idTarget: string
		modulo: string
		descrizione: string
		discipline: string
		professione: string
	}

	type TargetFormState = {
		idCurriculum: string
		abbreviazione: string
		target: string
	}

	type ModuleObjectiveFormState = {
		idObiettivo: string
		priorita: string
	}

	let loading = true
	let detailLoading = false
	let saving = false
	let savingLaboratory = false
	let savingModule = false
	let error = ''
	let projects: ProjectSummary[] = []
	let selectedProjectId: number | null = null
	let selectedLaboratoryId: number | null = null
	let detail: ProjectDetailResponse | null = null
	let currentSection: 'overview' | 'laboratori' | 'laboratorio' = 'overview'
	let finanziamenti: LookupOption[] = []
	let istituti: LookupOption[] = []
	let plessi: LookupOption[] = []
	let targetOptions: LookupOption[] = []
	let curriculumOptions: LookupOption[] = []
	let obiettiviOptions: LookupOption[] = []
	let showProjectForm = false
	let creatingFinancing = false
	let creatingTarget = false
	let editingLaboratoryId: number | null = null
	let editingModuleId: number | null = null

	let form: ProjectFormState = {
		idFinanziamento: '',
		idIstitutoCapofila: '',
		codice: '',
		progetto: '',
		tipologia: 'laboratorio',
		descrizione: '',
		ambientiMinimi: '1',
		partecipantiMinimi: '1'
	}

	let financingForm: Record<keyof FinancingCreatePayload, string> = {
		tipo: '',
		denominazione: '',
		urlAvviso: '',
		importo: '0'
	}

	let laboratoryForm: LaboratoryFormState = {
		idPlesso: '',
		laboratorio: '',
		aula: '',
		descrizione: ''
	}

	let moduleForm: ModuleFormState = {
		idLaboratorio: '',
		idTarget: '',
		modulo: '',
		descrizione: '',
		discipline: '',
		professione: ''
	}

	let targetForm: TargetFormState = {
		idCurriculum: '',
		abbreviazione: '',
		target: ''
	}

	let moduleObjectiveRows: ModuleObjectiveFormState[] = []

	const currency = new Intl.NumberFormat('it-IT', {
		style: 'currency',
		currency: 'EUR',
		maximumFractionDigits: 2
	})

	$: selectedLaboratory =
		detail?.laboratori.find((laboratorio) => Number(laboratorio.id) === selectedLaboratoryId) ?? null
	$: selectedLaboratoryModules =
		detail?.moduli.filter((modulo) => Number(modulo.idLaboratorio) === selectedLaboratoryId) ?? []

	const resetForm = () => {
		form = {
			idFinanziamento: '',
			idIstitutoCapofila: '',
			codice: '',
			progetto: '',
			tipologia: 'laboratorio',
			descrizione: '',
			ambientiMinimi: '1',
			partecipantiMinimi: '1'
		}
		financingForm = {
			tipo: '',
			denominazione: '',
			urlAvviso: '',
			importo: '0'
		}
		creatingFinancing = false
	}

	const resetLaboratoryForm = () => {
		editingLaboratoryId = null
		laboratoryForm = {
			idPlesso: '',
			laboratorio: '',
			aula: '',
			descrizione: ''
		}
	}

	const resetModuleForm = () => {
		editingModuleId = null
		moduleForm = {
			idLaboratorio: selectedLaboratoryId === null ? '' : String(selectedLaboratoryId),
			idTarget: '',
			modulo: '',
			descrizione: '',
			discipline: '',
			professione: ''
		}
		targetForm = {
			idCurriculum: '',
			abbreviazione: '',
			target: ''
		}
		moduleObjectiveRows = []
		creatingTarget = false
	}

	const ensureSelectedLaboratory = (response: ProjectDetailResponse) => {
		if (response.laboratori.length === 0) {
			selectedLaboratoryId = null
			return
		}

		const alreadySelected = response.laboratori.some(
			(laboratorio) => Number(laboratorio.id) === selectedLaboratoryId
		)
		if (!alreadySelected) {
			selectedLaboratoryId = Number(response.laboratori[0].id)
		}
	}

	const loadProjects = async (preferredId?: number) => {
		loading = true
		error = ''
		try {
			const response = await listProjects()
			projects = response.records

			if (projects.length === 0) {
				selectedProjectId = null
				selectedLaboratoryId = null
				detail = null
				return
			}

			const fallbackId = preferredId ?? selectedProjectId ?? Number(projects[0].idProgetto)
			await selectProject(fallbackId)
		} catch (loadError) {
			error = loadError instanceof Error ? loadError.message : 'Errore nel caricamento dei progetti'
		} finally {
			loading = false
		}
	}

	const loadLookups = async () => {
		const response = await getProjectLookups()
		istituti = response.istituti
		plessi = response.plessi
		targetOptions = response.target
		curriculumOptions = response.curriculum
		obiettiviOptions = response.obiettivi
		if (user.isAdmin) {
			finanziamenti = response.finanziamenti
		}
	}

	const selectProject = async (projectId: number) => {
		selectedProjectId = projectId
		detailLoading = true
		error = ''
		try {
			const response = await getProjectDetail(projectId)
			detail = response
			ensureSelectedLaboratory(response)
			resetLaboratoryForm()
			resetModuleForm()
			currentSection = 'overview'
		} catch (detailError) {
			error = detailError instanceof Error ? detailError.message : 'Errore nel caricamento del progetto'
		} finally {
			detailLoading = false
		}
	}

	const refreshSelectedProject = async () => {
		if (selectedProjectId === null) {
			return
		}
		await selectProject(selectedProjectId)
		if (currentSection === 'overview' && selectedLaboratoryId !== null) {
			resetModuleForm()
		}
	}

	const openLaboratoryWorkspace = (laboratorio: ProjectLaboratory) => {
		selectedLaboratoryId = Number(laboratorio.id)
		currentSection = 'laboratorio'
		resetModuleForm()
	}

	const saveProject = async () => {
		saving = true
		error = ''
		try {
			const payload: ProjectCreatePayload = {
				idFinanziamento: creatingFinancing ? null : Number(form.idFinanziamento),
				idIstitutoCapofila: Number(form.idIstitutoCapofila),
				codice: form.codice.trim(),
				progetto: form.progetto.trim(),
				tipologia: form.tipologia,
				descrizione: form.descrizione.trim() === '' ? null : form.descrizione.trim(),
				ambientiMinimi: Number(form.ambientiMinimi),
				partecipantiMinimi: Number(form.partecipantiMinimi),
				nuovoFinanziamento: creatingFinancing
					? {
							tipo: financingForm.tipo.trim(),
							denominazione: financingForm.denominazione.trim(),
							urlAvviso: financingForm.urlAvviso.trim() === '' ? null : financingForm.urlAvviso.trim(),
							importo: Number(financingForm.importo)
						}
					: null
			}
			const response = await createProject(payload)
			showProjectForm = false
			resetForm()
			await loadLookups()
			await loadProjects(Number(response.project.idProgetto))
		} catch (saveError) {
			error = saveError instanceof Error ? saveError.message : 'Errore nel salvataggio del progetto'
		} finally {
			saving = false
		}
	}

	const startLaboratoryEdit = (laboratorio: ProjectLaboratory) => {
		currentSection = 'laboratori'
		selectedLaboratoryId = Number(laboratorio.id)
		editingLaboratoryId = Number(laboratorio.id)
		laboratoryForm = {
			idPlesso: String(laboratorio.idPlesso),
			laboratorio: laboratorio.laboratorio,
			aula: laboratorio.aula ?? '',
			descrizione: laboratorio.descrizione ?? ''
		}
	}

	const saveLaboratory = async () => {
		if (selectedProjectId === null) {
			return
		}

		savingLaboratory = true
		error = ''
		try {
			const payload = {
				idPlesso: Number(laboratoryForm.idPlesso),
				idProgetto: selectedProjectId,
				laboratorio: laboratoryForm.laboratorio.trim(),
				aula: laboratoryForm.aula.trim() === '' ? null : laboratoryForm.aula.trim(),
				descrizione: laboratoryForm.descrizione.trim() === '' ? null : laboratoryForm.descrizione.trim()
			} as GenericRecord

			if (editingLaboratoryId === null) {
				await createRecord('Laboratorio', payload)
			} else {
				await updateRecord('Laboratorio', editingLaboratoryId, payload)
			}

			await refreshSelectedProject()
			currentSection = 'laboratori'
			resetLaboratoryForm()
		} catch (saveError) {
			error = saveError instanceof Error ? saveError.message : 'Errore nel salvataggio del laboratorio'
		} finally {
			savingLaboratory = false
		}
	}

	const startModuleEdit = (modulo: ProjectModule) => {
		currentSection = 'laboratorio'
		selectedLaboratoryId = Number(modulo.idLaboratorio)
		editingModuleId = Number(modulo.id)
		moduleForm = {
			idLaboratorio: String(modulo.idLaboratorio),
			idTarget: String(modulo.idTarget),
			modulo: modulo.modulo,
			descrizione: modulo.descrizione ?? '',
			discipline: modulo.discipline ?? '',
			professione: modulo.professione ?? ''
		}
		moduleObjectiveRows = (detail?.obiettiviModulo ?? [])
			.filter((item) => Number(item.idModulo) === Number(modulo.id))
			.map((item) => ({
				idObiettivo: String(item.idObiettivo),
				priorita: String(item.priorita)
			}))
	}

	const addObjectiveRow = () => {
		moduleObjectiveRows = [...moduleObjectiveRows, { idObiettivo: '', priorita: '1' }]
	}

	const removeObjectiveRow = (index: number) => {
		moduleObjectiveRows = moduleObjectiveRows.filter((_, rowIndex) => rowIndex !== index)
	}

	const syncModuleObjectives = async (moduleId: number) => {
		const desiredRows = moduleObjectiveRows
			.map((row) => ({
				idObiettivo: Number(row.idObiettivo),
				priorita: Number(row.priorita)
			}))
			.filter((row) => row.idObiettivo > 0)

		const objectiveIds = desiredRows.map((row) => row.idObiettivo)
		if (new Set(objectiveIds).size !== objectiveIds.length) {
			throw new Error('Ogni obiettivo puo\' essere associato una sola volta al modulo.')
		}
		if (desiredRows.some((row) => row.priorita < 1)) {
			throw new Error('La priorita\' degli obiettivi deve essere maggiore o uguale a 1.')
		}

		const existingRows = (detail?.obiettiviModulo ?? []).filter(
			(item) => Number(item.idModulo) === moduleId
		)
		const desiredByObjective = new Map(desiredRows.map((row) => [row.idObiettivo, row.priorita]))

		for (const existing of existingRows) {
			const desiredPriority = desiredByObjective.get(Number(existing.idObiettivo))
			if (desiredPriority === undefined) {
				await deleteRecord('ObiettiviModulo', existing.id)
				continue
			}

			if (Number(existing.priorita) !== desiredPriority) {
				await updateRecord('ObiettiviModulo', existing.id, {
					idModulo: moduleId,
					idObiettivo: Number(existing.idObiettivo),
					priorita: desiredPriority
				} as GenericRecord)
			}
			desiredByObjective.delete(Number(existing.idObiettivo))
		}

		for (const [idObiettivo, priorita] of desiredByObjective.entries()) {
			await createRecord('ObiettiviModulo', {
				idModulo: moduleId,
				idObiettivo,
				priorita
			} as GenericRecord)
		}
	}

	const saveModule = async () => {
		savingModule = true
		error = ''
		try {
			let targetId = Number(moduleForm.idTarget)
			const laboratoryId = Number(moduleForm.idLaboratorio)
			if (laboratoryId <= 0) {
				throw new Error('Seleziona un laboratorio per il modulo.')
			}

			if (creatingTarget) {
				if (detail === null) {
					throw new Error('Dettaglio progetto non disponibile per creare il target.')
				}
				targetId = await createRecord('Target', {
					idCurriculum: Number(targetForm.idCurriculum),
					idIstituto: Number(detail.project.idIstitutoCapofila),
					abbreviazione: targetForm.abbreviazione.trim(),
					target: targetForm.target.trim()
				} as GenericRecord)
				await loadLookups()
			}

			const payload = {
				idLaboratorio: laboratoryId,
				idTarget: targetId,
				modulo: moduleForm.modulo.trim(),
				descrizione: moduleForm.descrizione.trim() === '' ? null : moduleForm.descrizione.trim(),
				discipline: moduleForm.discipline.trim() === '' ? null : moduleForm.discipline.trim(),
				professione: moduleForm.professione.trim() === '' ? null : moduleForm.professione.trim()
			} as GenericRecord

			let moduleId = editingModuleId
			if (moduleId === null) {
				moduleId = await createRecord('Modulo', payload)
			} else {
				await updateRecord('Modulo', moduleId, payload)
			}

			await syncModuleObjectives(moduleId)
			selectedLaboratoryId = laboratoryId
			await refreshSelectedProject()
			currentSection = 'laboratorio'
			resetModuleForm()
		} catch (saveError) {
			error = saveError instanceof Error ? saveError.message : 'Errore nel salvataggio del modulo'
		} finally {
			savingModule = false
		}
	}

	const objectiveSummary = (moduleId: number) => {
		const objectives = (detail?.obiettiviModulo ?? []).filter(
			(item) => Number(item.idModulo) === Number(moduleId)
		)
		if (objectives.length === 0) {
			return 'Nessun obiettivo associato'
		}
		return objectives
			.map((item) => `P${item.priorita} · ${item.tipoObiettivo}`)
			.join(', ')
	}

	const detailedObjectiveSummary = (moduleId: number) => {
		return (detail?.obiettiviModulo ?? []).filter(
			(item) => Number(item.idModulo) === Number(moduleId)
		)
	}

	const detailTitle = () => {
		if (currentSection === 'laboratori') {
			return 'Laboratori del progetto'
		}
		if (currentSection === 'laboratorio') {
			return selectedLaboratory ? `Scheda laboratorio · ${selectedLaboratory.laboratorio}` : 'Scheda laboratorio'
		}
		return 'Progetto selezionato'
	}

	onMount(async () => {
		await loadProjects()
		await loadLookups()
	})
</script>

<section class="workspace">
	<header class="section-header">
		<div>
			<h2>Progetti</h2>
			<p>Seleziona un progetto e passa dalla scheda progetto alla progettazione del laboratorio.</p>
		</div>
		{#if user.isAdmin}
			<button class="secondary" type="button" on:click={() => (showProjectForm = !showProjectForm)}>
				{showProjectForm ? 'Chiudi creazione progetto' : 'Nuovo progetto'}
			</button>
		{/if}
	</header>

	{#if error}
		<p class="error">{error}</p>
	{/if}

	{#if user.isAdmin && showProjectForm}
		<form class="card project-form" on:submit|preventDefault={saveProject}>
			<h3>Crea progetto</h3>
			<div class="project-form-grid">
				<label class="field">
					<span>Finanziamento</span>
					{#if creatingFinancing}
						<div class="inline-note">Stai creando un nuovo finanziamento insieme al progetto.</div>
					{:else}
						<select bind:value={form.idFinanziamento} required>
							<option value="">Seleziona...</option>
							{#each finanziamenti as item}
								<option value={String(item.id)}>{item.label}</option>
							{/each}
						</select>
					{/if}
					<button
						class="secondary inline-toggle"
						type="button"
						on:click={() => {
							creatingFinancing = !creatingFinancing
							form.idFinanziamento = ''
						}}
					>
						{creatingFinancing ? 'Usa un finanziamento esistente' : 'Crea nuovo finanziamento'}
					</button>
				</label>

				<label class="field">
					<span>Istituto capofila</span>
					<select bind:value={form.idIstitutoCapofila} required>
						<option value="">Seleziona...</option>
						{#each istituti as item}
							<option value={String(item.id)}>{item.label}</option>
						{/each}
					</select>
				</label>

				<label class="field">
					<span>Codice progetto</span>
					<input bind:value={form.codice} required />
				</label>

				<label class="field">
					<span>Tipologia</span>
					<select bind:value={form.tipologia} required>
						<option value="laboratorio">laboratorio</option>
						<option value="campus">campus</option>
					</select>
				</label>

				<label class="field full-width">
					<span>Nome progetto</span>
					<input bind:value={form.progetto} required />
				</label>

				{#if creatingFinancing}
					<div class="card nested-card full-width">
						<h4>Nuovo finanziamento</h4>
						<div class="project-form-grid">
							<label class="field">
								<span>Tipo</span>
								<input bind:value={financingForm.tipo} required={creatingFinancing} placeholder="POC, PNRR..." />
							</label>

							<label class="field">
								<span>Importo</span>
								<input type="number" bind:value={financingForm.importo} min="0" step="0.01" required={creatingFinancing} />
							</label>

							<label class="field full-width">
								<span>Denominazione</span>
								<input bind:value={financingForm.denominazione} required={creatingFinancing} />
							</label>

							<label class="field full-width">
								<span>URL avviso</span>
								<input type="url" bind:value={financingForm.urlAvviso} />
							</label>
						</div>
					</div>
				{/if}

				<label class="field">
					<span>Ambienti minimi</span>
					<input type="number" bind:value={form.ambientiMinimi} min="1" required />
				</label>

				<label class="field">
					<span>Partecipanti minimi</span>
					<input type="number" bind:value={form.partecipantiMinimi} min="1" required />
				</label>

				<label class="field full-width">
					<span>Descrizione</span>
					<textarea bind:value={form.descrizione}></textarea>
				</label>
			</div>

			<div class="actions">
				<button type="submit" disabled={saving}>{saving ? 'Salvataggio...' : 'Crea progetto'}</button>
				<button class="secondary" type="button" on:click={resetForm}>Pulisci</button>
			</div>
		</form>
	{/if}

	<div class="workspace-grid">
		<section class="card project-list">
			<h3>Scelta progetto</h3>
			{#if loading}
				<p>Caricamento progetti...</p>
			{:else if projects.length === 0}
				<p>Nessun progetto disponibile.</p>
			{:else}
				<div class="project-list-items">
					{#each projects as project}
						<button
							class:selected={selectedProjectId === Number(project.idProgetto)}
							class="project-list-item"
							type="button"
							on:click={() => selectProject(Number(project.idProgetto))}
						>
							<strong>{project.progetto}</strong>
							<span>{project.codice}</span>
							<small>{project.finanziamento}</small>
						</button>
					{/each}
				</div>
			{/if}
		</section>

		<section class="card project-detail">
			{#if detailLoading}
				<p>Caricamento progetto...</p>
			{:else if detail}
				<header class="project-detail-header">
					<div>
						<p class="eyebrow">{detail.project.codice}</p>
						<h3>{detailTitle()}</h3>
						<p>
							<strong>{detail.project.progetto}</strong><br />
							{detail.project.finanziamento} · {detail.project.istitutoCapofila}
						</p>
					</div>
					<div class="project-detail-actions">
						<button class:active={currentSection === 'overview'} class="secondary" type="button" on:click={() => (currentSection = 'overview')}>Progetto</button>
						<button class:active={currentSection === 'laboratori'} class="secondary" type="button" on:click={() => (currentSection = 'laboratori')}>Laboratori</button>
						<button
							class:active={currentSection === 'laboratorio'}
							class="secondary"
							type="button"
							disabled={selectedLaboratoryId === null}
							on:click={() => (currentSection = 'laboratorio')}
						>
							Scheda laboratorio
						</button>
					</div>
				</header>

				{#if currentSection === 'overview'}
					<div class="stats-grid compact">
						<div class="stat-card">
							<span class="label">Tipologia</span>
							<strong>{detail.project.tipologia}</strong>
						</div>
						<div class="stat-card">
							<span class="label">Laboratori</span>
							<strong>{detail.project.ambienti}</strong>
						</div>
						<div class="stat-card">
							<span class="label">Moduli</span>
							<strong>{detail.project.moduli}</strong>
						</div>
						<div class="stat-card">
							<span class="label">Budget</span>
							<strong>{currency.format(Number(detail.project.budgetAllocato ?? 0))}</strong>
						</div>
					</div>

					<div class="project-meta">
						<p><strong>Campus:</strong> {detail.project.campus ?? 'non associato'}</p>
						<p><strong>Aggregazione:</strong> {detail.project.tipoAggregazione ?? 'non applicabile'}</p>
						<p>
							<strong>Vincoli strutturali:</strong>
							{detail.project.vincoliRispettati === 1 ? ' rispettati' : ' da completare'}
						</p>
						{#if selectedLaboratory}
							<p><strong>Laboratorio attivo:</strong> {selectedLaboratory.laboratorio}</p>
						{/if}
					</div>
				{:else if currentSection === 'laboratori'}
					<div class="editor-layout">
						<form class="card editor-card" on:submit|preventDefault={saveLaboratory}>
							<div class="section-header compact-header">
								<div>
									<h3>{editingLaboratoryId === null ? 'Nuovo laboratorio' : `Laboratorio #${editingLaboratoryId}`}</h3>
									<p>Apri un laboratorio esistente o creane uno nuovo nel progetto selezionato.</p>
								</div>
								<button class="secondary" type="button" on:click={resetLaboratoryForm}>Nuovo</button>
							</div>

							<label class="field">
								<span>Plesso</span>
								<select bind:value={laboratoryForm.idPlesso} required>
									<option value="">Seleziona...</option>
									{#each plessi as item}
										<option value={String(item.id)}>{item.label}</option>
									{/each}
								</select>
							</label>
							<label class="field">
								<span>Laboratorio</span>
								<input bind:value={laboratoryForm.laboratorio} required />
							</label>
							<label class="field">
								<span>Aula</span>
								<input bind:value={laboratoryForm.aula} />
							</label>
							<label class="field">
								<span>Descrizione</span>
								<textarea bind:value={laboratoryForm.descrizione}></textarea>
							</label>

							<div class="actions">
								<button type="submit" disabled={savingLaboratory}>
									{savingLaboratory ? 'Salvataggio...' : editingLaboratoryId === null ? 'Crea laboratorio' : 'Salva laboratorio'}
								</button>
							</div>
						</form>

						<div class="table-scroll">
							<table>
								<thead>
									<tr>
										<th>Laboratorio</th>
										<th>Plesso</th>
										<th>Aula</th>
										<th>Costo totale</th>
										<th>Azioni</th>
									</tr>
								</thead>
								<tbody>
									{#each detail.laboratori as laboratorio}
										<tr class:selected-row={selectedLaboratoryId === Number(laboratorio.id)}>
											<td>{laboratorio.laboratorio}</td>
											<td>{laboratorio.plesso}</td>
											<td>{laboratorio.aula ?? '—'}</td>
											<td>{currency.format(Number(laboratorio.costoTotale ?? 0))}</td>
											<td class="row-actions">
												<button class="secondary" type="button" on:click={() => startLaboratoryEdit(laboratorio)}>Modifica</button>
												<button class="secondary" type="button" on:click={() => openLaboratoryWorkspace(laboratorio)}>Scheda</button>
											</td>
										</tr>
									{/each}
								</tbody>
							</table>
						</div>
					</div>
				{:else if selectedLaboratory}
					<div class="laboratory-summary card nested-card">
						<div>
							<p class="eyebrow">Laboratorio attivo</p>
							<h4>{selectedLaboratory.laboratorio}</h4>
							<p>
								<strong>Plesso:</strong> {selectedLaboratory.plesso}
								{#if selectedLaboratory.aula}
									· <strong>Aula:</strong> {selectedLaboratory.aula}
								{/if}
							</p>
						</div>
						<div class="laboratory-summary-metrics">
							<span><strong>Moduli:</strong> {selectedLaboratoryModules.length}</span>
							<span><strong>Budget:</strong> {currency.format(Number(selectedLaboratory.costoTotale ?? 0))}</span>
						</div>
						{#if selectedLaboratory.descrizione}
							<p>{selectedLaboratory.descrizione}</p>
						{/if}
						<div class="laboratory-switcher">
							{#each detail.laboratori as laboratorio}
								<button
									class:selected={selectedLaboratoryId === Number(laboratorio.id)}
									class="secondary"
									type="button"
									on:click={() => {
										selectedLaboratoryId = Number(laboratorio.id)
										resetModuleForm()
									}}
								>
									{laboratorio.laboratorio}
								</button>
							{/each}
						</div>
					</div>

					<div class="editor-layout">
						<form class="card editor-card" on:submit|preventDefault={saveModule}>
							<div class="section-header compact-header">
								<div>
									<h3>{editingModuleId === null ? 'Nuovo modulo' : `Modulo #${editingModuleId}`}</h3>
									<p>Completa la scheda didattica del laboratorio con target e obiettivi prioritizzati.</p>
								</div>
								<button class="secondary" type="button" on:click={resetModuleForm}>Nuovo</button>
							</div>

							<label class="field">
								<span>Laboratorio</span>
								<select
									bind:value={moduleForm.idLaboratorio}
									required
									on:change={() => {
										selectedLaboratoryId = Number(moduleForm.idLaboratorio)
									}}
								>
									<option value="">Seleziona...</option>
									{#each detail.laboratori as laboratorio}
										<option value={String(laboratorio.id)}>{laboratorio.laboratorio}</option>
									{/each}
								</select>
							</label>

							<label class="field">
								<span>Target</span>
								{#if creatingTarget}
									<div class="inline-note">Stai creando un nuovo target per il progetto selezionato.</div>
								{:else}
									<select bind:value={moduleForm.idTarget} required>
										<option value="">Seleziona...</option>
										{#each targetOptions as item}
											<option value={String(item.id)}>{item.label}</option>
										{/each}
									</select>
								{/if}
								<button
									class="secondary inline-toggle"
									type="button"
									on:click={() => {
										creatingTarget = !creatingTarget
										moduleForm.idTarget = ''
									}}
								>
									{creatingTarget ? 'Usa un target esistente' : 'Crea nuovo target'}
								</button>
							</label>

							{#if creatingTarget}
								<div class="card nested-card">
									<h4>Nuovo target</h4>
									<label class="field">
										<span>Curriculum</span>
										<select bind:value={targetForm.idCurriculum} required={creatingTarget}>
											<option value="">Seleziona...</option>
											{#each curriculumOptions as item}
												<option value={String(item.id)}>{item.label}</option>
											{/each}
										</select>
									</label>
									<label class="field">
										<span>Abbreviazione</span>
										<input bind:value={targetForm.abbreviazione} required={creatingTarget} />
									</label>
									<label class="field">
										<span>Target</span>
										<input bind:value={targetForm.target} required={creatingTarget} />
									</label>
								</div>
							{/if}

							<label class="field">
								<span>Modulo</span>
								<input bind:value={moduleForm.modulo} required />
							</label>
							<label class="field">
								<span>Descrizione</span>
								<textarea bind:value={moduleForm.descrizione}></textarea>
							</label>
							<label class="field">
								<span>Discipline</span>
								<input bind:value={moduleForm.discipline} />
							</label>
							<label class="field">
								<span>Profilo professionale</span>
								<input bind:value={moduleForm.professione} />
							</label>

							<div class="objectives-editor">
								<div class="section-header compact-header">
									<div>
										<h4>Obiettivi del modulo</h4>
										<p>Associa uno o piu' obiettivi e assegna una priorita' esplicita.</p>
									</div>
									<button class="secondary" type="button" on:click={addObjectiveRow}>Aggiungi obiettivo</button>
								</div>

								{#if moduleObjectiveRows.length === 0}
									<p class="muted small-text">Nessun obiettivo associato. Puoi salvare il modulo o aggiungere gli obiettivi ora.</p>
								{/if}

								{#each moduleObjectiveRows as row, index}
									<div class="objective-row">
										<label class="field">
											<span>Obiettivo</span>
											<select bind:value={moduleObjectiveRows[index].idObiettivo} required>
												<option value="">Seleziona...</option>
												{#each obiettiviOptions as item}
													<option value={String(item.id)}>{item.label}</option>
												{/each}
											</select>
										</label>
										<label class="field priority-field">
											<span>Priorita'</span>
											<input type="number" bind:value={moduleObjectiveRows[index].priorita} min="1" step="1" required />
										</label>
										<button class="danger" type="button" on:click={() => removeObjectiveRow(index)}>Rimuovi</button>
									</div>
								{/each}
							</div>

							<div class="actions">
								<button type="submit" disabled={savingModule}>
									{savingModule ? 'Salvataggio...' : editingModuleId === null ? 'Crea modulo' : 'Salva modulo'}
								</button>
							</div>
						</form>

						<div class="table-scroll">
							<table>
								<thead>
									<tr>
										<th>Modulo</th>
										<th>Target</th>
										<th>Discipline</th>
										<th>Obiettivi</th>
										<th>Azioni</th>
									</tr>
								</thead>
								<tbody>
									{#if selectedLaboratoryModules.length === 0}
										<tr>
											<td colspan="5">Nessun modulo ancora associato a questo laboratorio.</td>
										</tr>
									{:else}
										{#each selectedLaboratoryModules as modulo}
											<tr class:selected-row={editingModuleId === Number(modulo.id)}>
												<td>
													<strong>{modulo.modulo}</strong>
													{#if modulo.professione}
														<div class="muted small-text">{modulo.professione}</div>
													{/if}
												</td>
												<td>{modulo.target}</td>
												<td>{modulo.discipline ?? '—'}</td>
												<td>
													<div>{objectiveSummary(modulo.id)}</div>
													{#if modulo.obiettiviCount > 0}
														<ul class="objective-summary-list">
															{#each detailedObjectiveSummary(modulo.id) as objective}
																<li>P{objective.priorita} · {objective.obiettivo}</li>
															{/each}
														</ul>
													{/if}
												</td>
												<td class="row-actions">
													<button class="secondary" type="button" on:click={() => startModuleEdit(modulo)}>Apri</button>
												</td>
											</tr>
										{/each}
									{/if}
								</tbody>
							</table>
						</div>
					</div>
				{:else}
					<p>Seleziona o crea un laboratorio per iniziare la progettazione didattica.</p>
				{/if}
			{:else}
				<p>Seleziona un progetto per vedere i dettagli.</p>
			{/if}
		</section>
	</div>
</section>
