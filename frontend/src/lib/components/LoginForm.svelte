<script lang="ts">
	import { createEventDispatcher } from 'svelte'

	export let loading = false
	export let error = ''

	const dispatch = createEventDispatcher<{ login: { username: string; password: string } }>()

	let username = ''
	let password = ''

	const submit = () => {
		dispatch('login', { username, password })
	}
</script>

<section class="auth-shell">
	<form class="auth-card" on:submit|preventDefault={submit}>
		<p class="eyebrow">Accesso</p>
		<h1>Ambienti laboratoriali</h1>
		<p class="muted">Accedi con il tuo account locale per scegliere il progetto su cui lavorare.</p>

		{#if error}
			<p class="error">{error}</p>
		{/if}

		<label class="field">
			<span>Username</span>
			<input bind:value={username} autocomplete="username" required />
		</label>

		<label class="field">
			<span>Password</span>
			<input type="password" bind:value={password} autocomplete="current-password" required />
		</label>

		<button type="submit" disabled={loading}>{loading ? 'Accesso...' : 'Accedi'}</button>
	</form>
</section>
