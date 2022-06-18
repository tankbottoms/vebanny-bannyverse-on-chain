<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import CollapsibleModal from '$lib/CollapsibleModal.svelte';
	import { allIncompatibleAssets } from '../../store';

	let characters: any = {};
	let currentCharacter: any = {};
	let done = false;
	let layerOptions: any = {};

	const current = {
		baseUri: 'http://localhost:5500/',
		characterLayersDir: 'layers'
	};

	async function getLayerSvg({ layerValues = [] }) {
		let layers: any[] = [];
		let svgImageString = '';
		for (const [key, value] of Object.entries(layerValues)) {
			if (!value) continue;
			const src = `${current.baseUri}/${current.characterLayersDir}/${key}/${value}.png`;
			const response = await fetch(src);

			const reader = new FileReader();
			reader.readAsDataURL(await response.blob());
			await new Promise((resolve) => {
				reader.onloadend = function () {
					const base64data = reader.result;
					layers.push(base64data);
					svgImageString += `<image x="50%" y="50%" width="1000" xlink:href="${base64data}" style="transform: translate(-500px, -500px)" />`;
					resolve(true);
				};
			});
		}
		return { svgImageString, layers };
	}

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
		const charResponse = await fetch('http://localhost:5500/characters.json');
		characters = await charResponse.json();

		const layerResponse = await fetch('http://localhost:5500/layerOptions.json');
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
		{#await getLayerSvg({ layerValues: currentCharacter.layers })}
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
					{@html data.svgImageString}
				</g>
			</svg>
		{/await}

		{#each Object.keys(layerOptions) as category}
			<h1>{category.replaceAll('_', ' ')}</h1>
			{#each layerOptions[category] as layer}
				{#await getLayerSvg({ layerValues: { ...currentCharacter.layers, [category]: layer } })}
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
							{@html data.svgImageString}
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
