<script lang="ts">
  import { onMount } from 'svelte';
  import BlinkingStar from './BlinkingStar.svelte';
  import { stylesFromObject, setBackgroundLevelTransitions } from './utils';

  const levelColors = ['#F9329D', '#FE5EB4', '#FE6FBB', '#FE70EE', '#E270FE', '#BA70FE'];

  const dots = 55;
  const mdStars = 18;
  const smStars = 9;

  let transitions = {};
  let skylevels = [];

  let stars = [];

  function getRandomPosition() {
    const top = Math.floor(Math.random() * 90);
    const left = Math.floor(Math.random() * 100);
    return { top, left };
  }

  function getStars() {
    const stars = [];
    for (let i = 0; i < dots; i++) {
      const blinking = Math.random() < 0.33;
      const { top, left } = getRandomPosition();
      stars.push({ type: 'dot', blinking, top, left });
    }
    // for (let i = 0; i < lgStars; i++) {
    //   const { top, left } = getRandomPosition();
    //   stars.push({ type: 'large', top, left });
    // }
    for (let i = 0; i < mdStars; i++) {
      const { top, left } = getRandomPosition();
      stars.push({ type: 'medium', top, left });
    }
    for (let i = 0; i < smStars; i++) {
      const { top, left } = getRandomPosition();
      stars.push({ type: 'small', top, left });
    }
    return stars;
  }

  onMount(() => {
    const data = setBackgroundLevelTransitions(levelColors);
    transitions = data.transitions;
    skylevels = data.skylevels;
    stars = getStars();
  });
</script>

<div class="sky">
  {#each Object.keys(transitions) as skyLevelTransition, i}
    <div class="sky-level" style={stylesFromObject(skylevels[i])}>
      {#each transitions[skyLevelTransition] as transition}
        <div style={stylesFromObject(transition)} />
      {/each}
    </div>
  {/each}

  {#each stars as star}
    <BlinkingStar {...star} />
  {/each}
</div>

<style>
  :global(html, body, #app) {
    overflow: hidden;
    width: 100vw;
    height: 100vh;
  }
  .sky {
    -ms-overflow-style: none; /* IE and Edge */
    scrollbar-width: none; /* Firefox */
    width: 1000%;
    overflow-y: hidden;
    overflow-x: hidden;
    height: 100vh;
    position: relative;
    /* Animation moving background from left to right */
    animation: moveSky 8s linear infinite;
  }

  .sky::-webkit-scrollbar {
    display: none;
  }

  /* Keyframes for moveSky */
  @keyframes moveSky {
    from {
      transform: translateX(0);
    }
    to {
      transform: translateX(-80%);
    }
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
</style>
