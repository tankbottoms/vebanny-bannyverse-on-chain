<script lang="ts">
  export let type: 'dot' | 'small' | 'medium' | 'large' = 'large';
  export let blinking: boolean = false;
  export let top: number;
  export let left: number;
  export let unit: string = '%';
  export let size: number | undefined = undefined;
  export let className: string = '';

  const colors = [
    '#563C9B',
    '#8344BD',
    '#14577C',
    '#0BE3BD',
    '#145B7E',
    '#118F96',
    '#0B6AE3',
    '#242885',
    '#2C2394',
    '#3C1AB3',
    '#540BE3',
  ];

  function styleString() {
    // Choose a random color from the colors array
    const color = colors[Math.floor(Math.random() * colors.length)];

    let str = `
            top: ${top}${unit};
            left: ${left}${unit};
        `;
    if (type === 'dot') {
      str =
        str +
        `
                background-color: ${color};
            `;
      return str;
    }
    if (size) {
      str =
        str +
        `
                width: ${size}${unit};
                height: ${size}${unit};
            `;
    }
    str =
      str +
      `
        color: ${color};
        `;
    return str;
  }
</script>

<span
  class="star {className}"
  class:dot={type === 'dot'}
  class:dot--blinking={blinking}
  class:star--lg={type === 'large'}
  class:star--md={type === 'medium'}
  class:star--sm={type === 'small'}
  style={styleString()}
>
  <span class="star__part" />
  <span class="star__part" />
</span>

<style>
  .star {
    z-index: 100;
    position: absolute;
  }

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

  .dot {
    position: absolute;
    width: 4px;
    height: 4px;
    background: #fec8c9;
  }

  .dot--blinking {
    animation: blink 0.25s linear infinite;
  }
  .star {
    position: absolute;
    color: #fec8c9;
    /* animation: scale 0.5s linear infinite; */
  }

  .star--sm {
    width: 14px;
    height: 14px;
  }

  .star--md {
    width: 28px;
    height: 28px;
  }

  .star--lg {
    width: 48px;
    height: 48px;
  }

  @keyframes blink {
    0%,
    32%,
    67% {
      opacity: 1;
    }
    33%,
    66% {
      opacity: 0;
    }
  }
  @keyframes scale {
    0%,
    16.4%,
    83.6%,
    100% {
      transform: scale(0.75, 0.75);
    }
    16.5%,
    33%,
    66.6%,
    83.5% {
      transform: scale(1, 1);
    }
  }
  @keyframes grow {
    0%,
    16.4%,
    83.6%,
    100% {
      width: 20%;
      height: 20%;
    }
    16.5%,
    33%,
    66.6%,
    83.5% {
      width: 50%;
      height: 50%;
    }
    33.1%,
    50%,
    66.5% {
      width: 100%;
      height: 100%;
    }
  }
</style>
