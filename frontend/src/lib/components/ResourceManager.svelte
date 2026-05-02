<script lang="ts">
	import { onMount } from 'svelte'
	import { createRecord, deleteRecord, listRecords, updateRecord } from '../api'
	import type { GenericRecord, ResourceDefinition } from '../types'

	export let resource: ResourceDefinition

	let records: GenericRecord[] = []
	let lookups: Record<string, GenericRecord[]> = {}
	let form: Record<string, string> = {}
	let editingId: number | null = null
	let loading = true
	let saving = false
	let error = ''

	const createEmptyForm = () =>
		Object.fromEntries(resource.fields.map((field) => [field.key, '']))

	const lookupFields = () => resource.fields.filter((field) => field.lookup)

	const load = async () => {
		loading = true
		error = ''
		try {
			const [resourceResponse, ...lookupResponses] = await Promise.all([
				listRecords(resource.table),
				...lookupFields().map((field) => listRecords(field.lookup!))
			])

			records = resourceResponse.records
			lookups = {}
			lookupFields().forEach((field, index) => {
				lookups[field.lookup!] = lookupResponses[index].records
			})
		} catch (loadError) {
			error = loadError instanceof Error ? loadError.message : 'Errore di caricamento'
		} finally {
			loading = false
		}
	}

	const resetForm = () => {
		form = createEmptyForm()
		editingId = null
	}

	const toPayload = () =>
		Object.fromEntries(
			resource.fields.map((field) => {
				const rawValue = form[field.key]
				if (field.type === 'number' || field.type === 'select') {
					return [field.key, rawValue === '' ? null : Number(rawValue)]
				}
				return [field.key, rawValue === '' ? null : rawValue]
			})
		) as GenericRecord

	const startEdit = (record: GenericRecord) => {
		editingId = Number(record.id)
		form = Object.fromEntries(
			resource.fields.map((field) => [field.key, record[field.key]?.toString() ?? ''])
		)
	}

	const lookupLabel = (fieldKey: string, value: string | number | null | undefined) => {
		const field = resource.fields.find((entry) => entry.key === fieldKey)
		if (!field?.lookup || value === null || value === undefined) {
			return value ?? '—'
		}

		const items = lookups[field.lookup] ?? []
		const optionValue = field.optionValue ?? 'id'
		const optionLabel = field.optionLabel ?? 'id'
		const match = items.find((item) => String(item[optionValue]) === String(value))
		return match?.[optionLabel] ?? value
	}

	const save = async () => {
		saving = true
		error = ''
		try {
			if (editingId === null) {
				await createRecord(resource.table, toPayload())
			} else {
				await updateRecord(resource.table, editingId, toPayload())
			}
			await load()
			resetForm()
		} catch (saveError) {
			error = saveError instanceof Error ? saveError.message : 'Errore di salvataggio'
		} finally {
			saving = false
		}
	}

	const remove = async (record: GenericRecord) => {
		if (!confirm(`Eliminare "${record.id}" da ${resource.title}?`)) {
			return
		}
		try {
			await deleteRecord(resource.table, Number(record.id))
			await load()
			if (editingId === Number(record.id)) {
				resetForm()
			}
		} catch (removeError) {
			error = removeError instanceof Error ? removeError.message : 'Errore di eliminazione'
		}
	}

	onMount(async () => {
		resetForm()
		await load()
	})
</script>

<section class="resource">
	<header class="section-header">
		<div>
			<h2>{resource.title}</h2>
			<p>{resource.description}</p>
		</div>
		<button class="secondary" type="button" on:click={load}>Aggiorna</button>
	</header>

	{#if error}
		<p class="error">{error}</p>
	{/if}

	<div class="resource-grid">
		<form
			class="editor card"
			on:submit|preventDefault={save}
		>
			<h3>{editingId === null ? 'Nuovo record' : `Modifica #${editingId}`}</h3>
			{#each resource.fields as field}
				<label class="field">
					<span>{field.label}</span>
					{#if field.type === 'textarea'}
						<textarea bind:value={form[field.key]} placeholder={field.placeholder ?? ''}></textarea>
					{:else if field.type === 'select'}
						<select bind:value={form[field.key]} required={field.required}>
							<option value="">Seleziona...</option>
							{#each lookups[field.lookup ?? ''] ?? [] as option}
								<option value={String(option[field.optionValue ?? 'id'])}>
									{option[field.optionLabel ?? 'id']}
								</option>
							{/each}
						</select>
					{:else}
						<input
							type={field.type}
							bind:value={form[field.key]}
							placeholder={field.placeholder ?? ''}
							required={field.required}
							min={field.min}
							step={field.step}
						/>
					{/if}
				</label>
			{/each}

			<div class="actions">
				<button type="submit" disabled={saving}>{saving ? 'Salvataggio...' : 'Salva'}</button>
				<button class="secondary" type="button" on:click={resetForm}>Pulisci</button>
			</div>
		</form>

		<div class="table-wrapper card">
			{#if loading}
				<p>Caricamento...</p>
			{:else}
				<div class="table-scroll">
					<table>
						<thead>
							<tr>
								<th>ID</th>
								{#each resource.fields as field}
									<th>{field.label}</th>
								{/each}
								<th>Azioni</th>
							</tr>
						</thead>
						<tbody>
							{#each records as record}
								<tr>
									<td>{record.id}</td>
									{#each resource.fields as field}
										<td>{lookupLabel(field.key, record[field.key])}</td>
									{/each}
									<td class="row-actions">
										<button class="secondary" type="button" on:click={() => startEdit(record)}>Modifica</button>
										<button class="danger" type="button" on:click={() => remove(record)}>Elimina</button>
									</td>
								</tr>
							{/each}
						</tbody>
					</table>
				</div>
			{/if}
		</div>
	</div>
</section>
