<script lang="ts">
	import { goto } from '$app/navigation';
	import { onMount } from 'svelte';

	const indices = Array.from(Array(60).keys()).map((i) => i + 1);

	async function getCharacter({ bannyIndex }: { bannyIndex: number }) {
		let index: number | string = bannyIndex;
		if (index < 10) {
			index = `0${index}`;
		}

		const src = `./characters/${index}.png`;
		const response = await fetch(src);
		const reader = new FileReader();
		reader.readAsDataURL(await response.blob());
		const svgImageString = await new Promise((resolve) => {
			reader.onloadend = function () {
				const base64data = reader.result;
				const svgImageString = `<image x="50%" y="50%" width="1000" xlink:href="${base64data}" style="transform: translate(-500px, -500px)" />`;
				resolve(svgImageString);
			};
		});
		return { svgImageString };
	}

	onMount(async () => {
		// Fetch the characters layers
		const charResponse = await fetch('/characters.json');
	});
</script>

{#each indices as banny}
	{#await getCharacter({ bannyIndex: banny })}
		<p>...</p>
	{:then data}
		<svg
			id="token"
			width="300"
			height="300"
			viewBox="0 0 1080 1080"
			fill="none"
			on:click={() => {
				goto(`secret/${banny}`);
			}}
			xmlns="http://www.w3.org/2000/svg"
		>
			<!-- NOTE: This is where we're adding Banny -->
			<g id="bannyPlaceholder">
				{@html data.svgImageString}
			</g>
		</svg>
	{/await}
{/each}
