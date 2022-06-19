<script lang="ts">
	import { onMount } from 'svelte';
	import BlinkingStar from './BlinkingStar.svelte';
	import { getAnimation, getFadeKeyframes, getMoveKeyframes } from '$utils/space';

	const colors = [
		'#14577c',
		'#0be3bd',
		'#118f96',
		'#0b6ae3',
		'#242885',
		'#3c1ab3',
		'#540be3',
		'#ffaaaa',
		'#aaffaa',
		'#aaaaff',
		'white',
		'orange',
		'yellow'
	];

	let bitStarPositions: any[] = [];
	let dynamicStyles = '';

	function getCenter(sky: Element) {
		const w = sky.clientWidth;
		const h = sky.clientHeight;
		return {
			x: w / 2,
			y: h / 2
		};
	}

	function getDot(x: number, y: number, group: number) {
		const size = Math.round(Math.random() * 8);
		if (size >= 4) {
			bitStarPositions = [
				...bitStarPositions,
				{
					// No need to set x,y here everytime, can be gotten once from the center
					x,
					y,
					animation: getAnimation(group)
				}
			];
			return;
		}
		const dot = document.createElement('span');
		dot.classList.add('stars-star', `stars-size-${size}`);
		const animation = getAnimation(group);
		dot.style.animation = animation;
		dot.style.top = `${y}px`;
		dot.style.left = `${x}px`;
		return dot.cloneNode();
	}

	function getStyles(star: { animation: any }) {
		const str = `
      animation: ${star.animation};
      color: ${colors[Math.floor(Math.random() * colors.length)]};
    `;
		return str;
	}

	onMount(() => {
		const sky = document.querySelector('#stars-sky');
		sky.innerHTML = '';
		const { x, y } = getCenter(sky);
		for (let i = 1; i < 720; i++) {
			const dot = getDot(x, y, i);
			if (dot) {
				sky.appendChild(dot);
			}
		}
		dynamicStyles += getFadeKeyframes();
		dynamicStyles += getMoveKeyframes();

		dynamicStyles = `<${''}style>${dynamicStyles}</${''}style>`;
	});
</script>

<svelte:head>
	{@html dynamicStyles}
</svelte:head>

<div class="stars-outer">
	<div id="stars-sky">
		{#each bitStarPositions as position}
			<BlinkingStar
				type="small"
				size={Math.floor(Math.random() * 8)}
				unit="px"
				top={position.y}
				left={position.x}
				styles={getStyles(position)}
				className={`stars-star`}
			/>
		{/each}
	</div>
</div>

<style lang="scss" global>
	.sky {
		-ms-overflow-style: none; /* IE and Edge */
		scrollbar-width: none; /* Firefox */
		width: 1000%;
		overflow-y: hidden;
		overflow-x: hidden;
		height: 100vh;
	}

	.sky-level {
		box-sizing: border-box;
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
	}

	.sky-level div {
		float: left;
		height: 4px;
		background: currentColor;
	}

	.stars-outer {
		width: 100%;
		height: 100%;
		background: rgb(0, 0, 0);
		background: radial-gradient(circle, rgba(0, 0, 0, 1) 0%, rgb(0, 10, 24) 100%);
	}

	#stars-sky {
		width: 100%;
		height: 100%;
		position: relative;
		overflow: hidden;
	}

	:global(.stars-star) {
		opacity: 0;
		transform-origin: 0, 0;
		position: absolute;
		z-index: 10;
		animation-timing-function: linear, linear !important;
		animation-iteration-count: infinite, infinite !important;
		animation-delay: -30s, -30s !important;
	}

	@keyframes fade-in {
		0% {
			opacity: 0;
		}
		100% {
			opacity: 1;
		}
	}

	.stars-size-0,
	.stars-size-1 {
		background: white;
		width: 0.5px;
		height: 0.5px;
	}

	.stars-size-2 {
		background: white;
		width: 1px;
		height: 1px;
	}

	.stars-size-3 {
		background: white;
		width: 2px;
		height: 2px;
	}

	.stars-size-4 {
		background: none;
		position: absolute;
		animation-timing-function: linear, linear !important;
		animation-iteration-count: infinite, infinite !important;
		animation-delay: -30s, -30s !important;
		z-index: 100;

		.star::after {
			content: '';
			position: absolute;
			top: 50%;
			left: 50%;
			transform: translate(-50%, -50%);
			background: currentColor;
			animation: grow 0.5s linear infinite;
		}
		.star__part {
			position: absolute;
			background: currentColor;
		}
		.star__part:nth-child(1) {
			left: 0;
			top: 50%;
			transform: translateY(-50%);
			width: 100%;
			height: 20%;
		}
		.star__part:nth-child(2) {
			left: 50%;
			top: 0;
			transform: translateX(-50%);
			width: 20%;
			height: 100%;
		}
	}
</style>
