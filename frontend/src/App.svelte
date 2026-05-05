<script lang="ts">
	import { onMount } from 'svelte'
	import { getSession, login, logout } from './lib/api'
	import LoginForm from './lib/components/LoginForm.svelte'
	import ProjectWorkspace from './lib/components/ProjectWorkspace.svelte'
	import type { SessionUser } from './lib/types'

	let user: SessionUser | null = null
	let loadingSession = true
	let loginLoading = false
	let error = ''

	const loadSession = async () => {
		loadingSession = true
		try {
			const session = await getSession()
			user = session.user
		} catch (sessionError) {
			error = sessionError instanceof Error ? sessionError.message : 'Errore nel recupero della sessione'
		} finally {
			loadingSession = false
		}
	}

	const handleLogin = async (event: CustomEvent<{ username: string; password: string }>) => {
		loginLoading = true
		error = ''
		try {
			const session = await login(event.detail.username, event.detail.password)
			user = session.user
		} catch (loginError) {
			error = loginError instanceof Error ? loginError.message : 'Errore di autenticazione'
		} finally {
			loginLoading = false
		}
	}

	const handleLogout = async () => {
		await logout()
		user = null
		error = ''
	}

	onMount(loadSession)
</script>

{#if loadingSession}
	<section class="auth-shell">
		<div class="auth-card">
			<h1>Caricamento sessione...</h1>
		</div>
	</section>
{:else if user === null}
	<LoginForm loading={loginLoading} error={error} on:login={handleLogin} />
{:else}
	<div class="app-shell">
		<aside class="sidebar">
			<div class="brand">
				<p class="eyebrow">Ambienti laboratoriali</p>
				<h1>Sprint 1</h1>
				<p>Selezione progetto, login locale e navigazione verso laboratori e moduli.</p>
			</div>

			<div class="card user-card">
				<p class="eyebrow">Utente</p>
				<h2>{user.nome}</h2>
				<p>@{user.username}</p>
				<p>Ruoli: {user.roles.join(', ')}</p>
				<button class="secondary" type="button" on:click={handleLogout}>Esci</button>
			</div>
		</aside>

		<main class="content">
			<ProjectWorkspace {user} />
		</main>
	</div>
{/if}
