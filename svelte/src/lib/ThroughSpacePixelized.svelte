<script lang="ts">
  import { onMount } from 'svelte';
  import BlinkingStar from './BlinkingStar.svelte';

  let bitStarPositions: any[] = [];

  function getCenter(sky: Element) {
    const w = sky.clientWidth;
    const h = sky.clientHeight;
    return {
      x: w / 2,
      y: h / 2,
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
          group,
        },
      ];
      return;
    }
    const dot = document.createElement('span');
    dot.classList.add('stars-star', `stars-axis-${group}`, `stars-size-${size}`);
    dot.style.top = `${y}px`;
    dot.style.left = `${x}px`;
    return dot.cloneNode();
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
  });
</script>

<div class="stars-outer">
  <div id="stars-sky">
    {#each bitStarPositions as position}
      <BlinkingStar
        type="small"
        size={Math.floor(Math.random() * 8)}
        unit="px"
        top={position.y}
        left={position.x}
        className={`stars-star stars-axis-${position.group}`}
      />
    {/each}
  </div>
</div>

<style lang="scss" global>
  @import './space.scss';

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
</style>
