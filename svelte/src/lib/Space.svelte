<script lang="ts">
  import { onMount } from 'svelte';

  export let amount: number = 2500;
  export let speed: number = 3;

  const id = Math.floor(Math.random() * Number.MAX_SAFE_INTEGER).toString(36);

  let canvas: HTMLCanvasElement;
  let context: CanvasRenderingContext2D;
  let radius = '0.' + Math.floor(Math.random() * 9) + 1;
  let focalLength;
  let warp = 0;
  let centerX, centerY;
  let stars = [];
  let star;
  let i;
  let animation: number;
  const colors = ['#ffaaaa', '#aaffaa', '#aaaaff', 'white', 'orange', 'yellow'];

  onMount(() => {
    context = canvas.getContext('2d');
    focalLength = canvas.width * 2;
    initializeStars();
    animation = Math.floor(Math.random() * Number.MAX_SAFE_INTEGER);
    executeFrame(animation);
  });

  function executeFrame(id: number) {
    if (!canvas) return;
    if (animation === id) {
      requestAnimationFrame(() => executeFrame(id));
      moveStars();
      drawStars();
    } else {
      animation = 0;
    }
  }

  function initializeStars() {
    if (!canvas) return;
    centerX = canvas.width / 2;
    centerY = canvas.height / 2;

    stars = [];
    for (i = 0; i < amount; i++) {
      star = {
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        z: Math.random() * canvas.width,
        o: '0.' + Math.floor(Math.random() * 99) + 1,
        color: colors[Math.floor(Math.random() * colors.length)],
      };
      stars.push(star);
    }
    console.log(stars.length, amount);
  }

  function moveStars() {
    if (!canvas) return;
    for (let i = 0; i < amount; i++) {
      let star = stars[i];
      star.z = Math.max(0, star.z - Math.round(speed));

      if (star.z <= 0) {
        star.z = canvas.width;
      }
    }
  }

  function drawStars() {
    if (!canvas) return;
    var pixelX, pixelY, pixelRadius;

    // Resize to the screen
    if (canvas.width != window.innerWidth || canvas.width != window.innerWidth) {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
      initializeStars();
    }
    if (warp == 0) {
      context.fillStyle = 'rgba(0,10,20,1)';
      context.fillRect(0, 0, canvas.width, canvas.height);
    }
    context.fillStyle = 'rgba(209, 255, 255, ' + radius + ')';
    for (i = 0; i < amount; i++) {
      star = stars[i];

      pixelX = (star.x - centerX) * (focalLength / star.z);
      pixelX += centerX;
      pixelY = (star.y - centerY) * (focalLength / star.z);
      pixelY += centerY;
      pixelRadius = 1 * (focalLength / star.z);

      context.beginPath();
      context.arc(pixelX, pixelY, pixelRadius, 0, 2 * Math.PI, false);
      context.fillStyle = star.color;
      context.fill();
      context.fillStyle = 'rgba(209, 255, 255, ' + star.o + ')';
    }
  }
</script>

<svelte:window />

<canvas id="space" bind:this={canvas} />

<style>
  #space {
    width: 100%;
  }
</style>
