<script lang="ts">
	import Dashboard from './lib/components/Dashboard.svelte'
	import ResourceManager from './lib/components/ResourceManager.svelte'
	import { resourceGroups, resources } from './lib/resources'

	let current = 'dashboard'
	$: currentResource = resources.find((resource) => resource.key === current)
</script>

<div class="app-shell">
	<aside class="sidebar">
		<div class="brand">
			<p class="eyebrow">Ambienti laboratoriali</p>
			<h1>PHP + Svelte</h1>
			<p>Frontend Svelte con accesso dati tramite API REST e chiamate fetch.</p>
		</div>

		<nav>
			<button class:active={current === 'dashboard'} on:click={() => (current = 'dashboard')}>
				Dashboard
			</button>

			{#each resourceGroups as group}
				<section class="nav-group">
					<h2>{group.title}</h2>
					{#each group.keys as key}
						<button class:active={current === key} on:click={() => (current = key)}>
							{resources.find((resource) => resource.key === key)?.title}
						</button>
					{/each}
				</section>
			{/each}
		</nav>
	</aside>

	<main class="content">
		{#if current === 'dashboard'}
			<Dashboard />
		{:else if currentResource}
			{#key current}
				<ResourceManager resource={currentResource} />
			{/key}
		{/if}
	</main>
</div>
