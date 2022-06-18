<script lang="ts">
	import { onMount } from 'svelte';
	import Tilt from 'vanilla-tilt';
	import Space from '$lib/Space.svelte';
	import HorizontalPixelized from '$lib/SpacePixelized.svelte';
	import BlinkingStar from '$lib/BlinkingStar.svelte';
	import ThroughSpacePixelized from '$lib/ThroughSpacePixelized.svelte';
	import Background from '$lib/Background.svelte';
	import { getLayeredSvgFromBannyIndex } from '$utils/layering';

	export let vibe: 'zoomy-stars' | 'horizontalPixelized' | 'pixelized' = 'pixelized';

	const barrierColors = ['beige', 'orange', 'green', '#32c8db', '#f5f5f5', 'gold'];
	const lockPeriods = ['1 WEEK', '1 MONTH', '3 MONTHS', '6 MONTHS', '1 YEAR', '4 YEARS'];

	let barrierColor = barrierColors[0];
	let front = '';
	let jbxRange = '';
	let lockPeriod = lockPeriods[0];
	let bannyElement: SVGGElement;
	let purse: HTMLElement;
	let spokes: string[] = getSpokes();

	function initializeTilt() {
		Tilt.init(purse, {
			max: 75,
			// @ts-ignore
			speed: !navigator?.userAgentData?.mobile ? 500 : 100,
			gyroscopeMinAngleX: -45, // This is the bottom limit of the device angle on X axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the left border of the element;
			gyroscopeMaxAngleX: 45, // This is the top limit of the device angle on X axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the right border of the element;
			gyroscopeMinAngleY: -15, // This is the bottom limit of the device angle on Y axis, meaning that a device rotated at this angle would tilt the element as if the mouse was on the top border of the element;
			gyroscopeMaxAngleY: 90
		});
	}

	function getParams() {
		const search = window.location.search;
		const urlSearchParams = new URLSearchParams(search);
		const tokenId = urlSearchParams.get('banny') || '1';
		let lock = urlSearchParams.get('lock');

		return { tokenId, lock };
	}

	function getSpokes(count = 16) {
		const degree = 360 / (count * 2);
		const spokes = [];
		for (let i = 1; i <= count; i++) {
			spokes.push(`transform: rotateY(90deg) rotateX(${degree * i}deg);`);
		}
		return spokes;
	}

	onMount(async () => {
		const { tokenId, lock } = getParams();
		let index: number | string = parseInt(tokenId);
		if (index < 10) {
			index = `0${index}`;
		}

		getLayeredSvgFromBannyIndex(Number(tokenId)).then((res) => {
			front = res.image;
			if (res.jbx_range) {
				jbxRange = `${res.jbx_range} JBX`;
			}
		});

		if (lock) {
			lockPeriod = lockPeriods[parseInt(lock)];
			barrierColor = barrierColors[parseInt(lock)];
		}
		initializeTilt();
	});

	function getRandomLeft() {
		const leftOfBanny = Math.random() > 0.5;
		if (leftOfBanny) {
			return Math.floor(Math.random() * 30) + 10;
		} else {
			return Math.floor(Math.random() * 20) + 60;
		}
	}

	function getBarrierGlowStyle(color: string) {
		return `box-shadow: -10px -10px 25px 0px ${color}, 10px -10px 25px 0px ${color},
			10px 10px 25px 0px ${color}, -10px 10px 25px 0px ${color}`;
	}

	$: bannyElement ? (bannyElement.innerHTML = front) : null;
</script>

<div class="purse">
	<div
		class="coin"
		bind:this={purse}
		data-tilt
		data-tilt-full-page-listening
		data-tilt-max="75"
		style="pointer-events: none"
	>
		<div id="background">
			<Background bottomText={jbxRange} topText={lockPeriod} size={320}>
				<g id="bannyPlaceholder" bind:this={bannyElement} />
			</Background>
		</div>

		<div class="barrier" style={getBarrierGlowStyle(barrierColor)} />

		<div class="side">
			{#each spokes as spoke}
				<div style={spoke} class="spoke" />
			{/each}
		</div>
		{#if vibe == 'zoomy-stars'}
			<div class="sparkles" style="pointer-events: none">
				<img src="./sparkles.gif" alt="" />
			</div>
		{:else}
			<div class="blinkingStars">
				<BlinkingStar type="small" top={35} left={25} />
				<BlinkingStar type="small" top={25} left={30} />
				<BlinkingStar type="small" top={40} left={65} />
				<BlinkingStar type="small" top={55} left={80} />
				<BlinkingStar type="small" top={55} left={20} />
				{#each Array.from({ length: 30 }, (_, i) => i) as i}
					<BlinkingStar type="dot" top={Math.random() * 60 + 20} left={getRandomLeft()} />
				{/each}
			</div>
		{/if}
	</div>
</div>

{#if vibe === 'zoomy-stars'}
	<Space />
{:else if vibe === 'pixelized'}
	<ThroughSpacePixelized />
{:else}
	<HorizontalPixelized />
{/if}

<style>
	:global(body) {
		background-color: #000;
		position: absolute;
		top: 0;
		bottom: 0;
		left: 0;
		right: 0;
		margin: 0;
		padding: 0;
	}

	#background {
		position: absolute;
		transform: translateZ(16px);
	}

	.blinkingStars {
		position: absolute;
		width: 100%;
		height: 100%;
		transform: translateZ(16px);
	}
	.purse {
		height: 320px;
		width: 320px;
		position: absolute;
		top: 50%;
		left: 50%;
		margin-top: -160px;
		margin-left: -160px;
		perspective: 1000px;
		filter: saturate(1.45) hue-rotate(2deg);
		z-index: 1000;
	}
	.coin {
		height: 320px;
		width: 320px;
		position: absolute;
		transform-style: preserve-3d;
		transform-origin: 50%;
		animation-timing-function: linear;
	}
	.purse .sparkles {
		width: 100%;
		height: 100%;
		position: absolute;
		z-index: 10000;
		border-radius: 50%;
		overflow: hidden;
		transform-style: preserve-3d;
		transform: translateZ(16px);
		mix-blend-mode: color-dodge;
	}
	.coin,
	.coin .barrier {
		position: absolute;
		height: 320px;
		width: 320px;
		border-radius: 50%;
		background-size: cover;
	}
	.coin .barrier {
		background: #222;
	}
	.coin {
		transform: translateZ(16px);
	}
	.coin .barrier {
		clip-path: circle(320px);
		left: 50%;
		top: 50%;
		position: absolute;
		transform: translate(-50%, -50%);
		z-index: -5;
		border-width: 5px;
		border-style: solid;
		box-shadow: -10px -10px 25px 0px #32c8db, 10px -10px 25px 0px #32c8db,
			10px 10px 25px 0px #32c8db, -10px 10px 25px 0px #32c8db;
		/* box-shadow: -10px -10px 25px 0px #ffff00bb, 10px -10px 25px 0px blue, 10px 10px 25px 0px red,
      -10px 10px 25px 0px green; */
		animation: spinin 25s linear infinite;
	}
	@keyframes spinin {
		from {
			transform: translate(-50%, -50%) rotateZ(0deg);
		}
		to {
			transform: translate(-50%, -50%) rotateZ(360deg);
		}
	}

	.coin .side {
		transform: translateX(144px);
		transform-style: preserve-3d;
		backface-visibility: hidden;
	}
	.coin .side .spoke {
		height: 320px;
		width: 32px;
		position: absolute;
		transform-style: preserve-3d;
		backface-visibility: hidden;
	}
	.coin .side .spoke:before,
	.coin .side .spoke:after {
		content: '';
		display: block;
		height: 31.365484905459px;
		width: 32px;
		position: absolute;
		transform: rotateX(84.375deg);
		background: #222222;
		background: linear-gradient(to bottom, #222222 0%, #222222 74%, #202020 75%, #000000 100%);
		background-size: 100% 6.9701077567688px;
	}
	.coin .side .spoke:before {
		transform-origin: top center;
	}
	.coin .side .spoke:after {
		bottom: 0;
		transform-origin: center bottom;
	}
	.coin.skeleton .side .spoke,
	.coin.skeleton .side .spoke:before,
	.coin.skeleton .side .spoke:after {
		backface-visibility: visible;
	}
	.coin.skeleton .side .spoke {
		background: rgba(170, 170, 170, 0.1);
	}
	.coin.skeleton .side .spoke:before {
		background: rgba(255, 170, 170, 0.2);
	}
	.coin.skeleton .side .spoke:after {
		background: rgba(204, 204, 255, 0.2);
	}
</style>
