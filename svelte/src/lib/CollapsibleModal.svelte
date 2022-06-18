<script lang="ts">
	export let assets: any = {};

	let open = true;
	let showCopied = false;

	function copy() {
		navigator.clipboard.writeText(JSON.stringify(assets, undefined, 2));

		showCopied = true;
		setTimeout(() => {
			showCopied = false;
		}, 1000);
	}
</script>

<div class:close={!open}>
	<svg
		on:click={() => {
			open = !open;
		}}
	>
		<circle cx="20px" cy="20px" r="20px" />
	</svg>
	<h2>Incompatible assets</h2>
	<p>✅ <i>Click on asset to add or remove from list.</i></p>
	<p>👁 <i>Click on this modal to collapse it to the side.</i></p>
	<pre>
        {JSON.stringify(assets, undefined, 2)}
	</pre>

	<button on:click|stopPropagation={copy}>Copy</button>
	{#if showCopied}
		<p>Copied to clipboard</p>
	{/if}
</div>

<style>
	h2,
	p {
		font-family: monospace;
	}

	div {
		padding: 20px;
		background-color: antiquewhite;
		position: fixed;
		top: 50px;
		right: 0;
		width: 250px;
	}

	svg {
		position: absolute;
		left: -20px;
		fill: antiquewhite;
	}

	button {
		float: right;
	}

	.close {
		/* Move off the screen */
		transform: translateX(100%);
	}

	.close svg {
		fill: gold;
	}
</style>
