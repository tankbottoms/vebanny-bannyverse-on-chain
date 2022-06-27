<script lang="ts">
	import Background from '$lib/Background.svelte';
	import { getLayeredSvgFromBannyIndex } from '$utils/layering';
	import { onMount } from 'svelte';

	let jbxRange: string;

	const lockPeriods = ['1 WEEK', '1 MONTH', '3 MONTHS', '6 MONTHS', '1 YEAR', '4 YEARS'];

	function getOptionsForLockPeriod(lockPeriod: number) {
		const options = [];
		for (let i = 1; i <= lockPeriod + 1; i++) {
			options.push(`planet${i}`);
		}
		for (let i = 1; i <= 4; i++) {
			options.push(`star${i}`);
			options.push(`dot${i}`);
		}
		return options;
	}

	onMount(async () => {
		const data = await getLayeredSvgFromBannyIndex(1);
		let tokens: HTMLCollectionOf<Element> | Element[] =
			document.getElementsByClassName('bannyPlaceholder');
		tokens = Array.from(tokens);
		tokens.forEach((token) => {
			token.innerHTML = data.image;
		});
		jbxRange = data.jbx_range;
	});
</script>

<section>
	{#each lockPeriods as lockPeriod, i}
		<Background
			topText={lockPeriod}
			bottomText={`${jbxRange || '...loading'} JBX`}
			options={getOptionsForLockPeriod(i)}
		>
			<g class="bannyPlaceholder" />
		</Background>
	{/each}
</section>

<style>
	section {
		display: grid;
		grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
		justify-items: center;
		grid-row-gap: 40px;
	}
</style>
