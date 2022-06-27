<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import CollapsibleModal from '$lib/CollapsibleModal.svelte';
	import { allIncompatibleAssets } from '../../store';
	import { layerOrdering, getLayeredSvg } from '$utils/layering';

	let characters: any = {};
	let currentCharacter: any = {};
	let done = false;
	let layerOptions: any = {};

	function handleIncompatibleAsset(category: string, asset: string) {
		const incompatibleAssets = $allIncompatibleAssets as any;
		let layers = incompatibleAssets[$page.params.banny];
		if (!layers[category]) {
			layers = { ...layers, [category]: [] };
		}
		// Check if already in list, if so remove
		const index = layers[category].indexOf(asset);
		if (index > -1) {
			layers = {
				...layers,
				[category]: layers[category].filter((a: string) => a !== asset)
			};
		} else {
			// Otherwise add the asset
			layers = {
				...layers,
				[category]: [...layers[category], asset]
			};
		}
		allIncompatibleAssets.update((current) => ({
			...current,
			[$page.params.banny]: layers
		}));
	}

	// Given a character, we want to display every asset on that character
	onMount(async () => {
		// Fetch the characters layers
		const charResponse = await fetch('/characters.json');
		characters = await charResponse.json();

		const layerResponse = await fetch('/layerOptions.json');
		layerOptions = await layerResponse.json();

		currentCharacter = characters[$page.params.banny];

		// Check if incompatible assets exist for current banny
		if (!$allIncompatibleAssets[$page.params.banny]) {
			allIncompatibleAssets.update((current) => ({
				...current,
				[$page.params.banny]: {}
			}));
		}

		done = true;
	});
</script>

<section>
	<a href="/secret">{'<'} Go back to Bannies</a>
	{#if done}
		{#await getLayeredSvg({ layers: currentCharacter.layers })}
			<p>...</p>
		{:then data}
			<h1>{currentCharacter.metadata.name.replaceAll('_', ' ')}</h1>
			<svg
				id="token"
				width="300"
				height="300"
				viewBox="0 0 1080 1080"
				fill="none"
				xmlns="http://www.w3.org/2000/svg"
			>
				<!-- NOTE: This is where we're adding Banny -->
				<g id="bannyPlaceholder">
					{@html data}
				</g>
			</svg>
		{/await}

		{#each layerOrdering as category}
			<h1>{category.replaceAll('_', ' ')}</h1>
			{#each layerOptions[category] as layer}
				{#await getLayeredSvg({ layers: { ...currentCharacter.layers, [category]: layer } })}
					<p>...</p>
				{:then data}
					<svg
						id="token"
						class:incompatible={$allIncompatibleAssets[$page.params.banny]?.[category]?.includes(
							layer
						)}
						on:click={() => handleIncompatibleAsset(category, layer)}
						width="300"
						height="300"
						viewBox="0 0 1080 1080"
						fill="none"
						xmlns="http://www.w3.org/2000/svg"
					>
						<!-- NOTE: This is where we're adding Banny -->
						<g id="bannyPlaceholder">
							{@html data}
						</g>
					</svg>
				{/await}
			{/each}
		{/each}
	{/if}
</section>
<CollapsibleModal assets={$allIncompatibleAssets} />

<style>
	h1 {
		font-family: monospace;
	}

	section {
		margin: 0 auto;
		padding: 20px;
	}

	.incompatible {
		opacity: 0.5;
	}
</style>
