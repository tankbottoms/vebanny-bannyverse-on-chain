export function stylesFromObject(obj: { [x: string]: any }) {
  return Object.keys(obj)
    .map(key => `${key}: ${obj[key]};`)
    .join(' ');
}

/**
 * Util for bit-fying a sharp gradient background
 * @param {number} levelColors - The colors in the gradient
 * @param {number} transition - The number of transitions
 *
 * @returns {object} - The transitions and styles
 */
export function setBackgroundLevelTransitions(levelColors: string[], transition = 40) {
  // For each level in the background, add 40 random divs
  // that will transition to the next level.
  const transitions = {};
  const skylevels = [];
  for (let i = 0; i < levelColors.length; i++) {
    //   Initialize the transition array
    transitions[i] = [];
    // Calculate the sky level styles
    skylevels[i] = {
      background: 'currentColor',
      'z-index': levelColors.length - i,
      height: `${(100 / levelColors.length) * i}vh`,
      'padding-top': `${(100 / levelColors.length) * (i + 1)}vh`,
      color: levelColors[i],
    };
    // Add the transitions
    const p = Math.ceil(20 / transition);
    for (let j = 0; j < transition; j++) {
      const r = p * (transition - j + 1);
      transitions[i][j] = {
        width: Math.floor(Math.random() * r) + '%',
        'margin-left': Math.floor(Math.random() * 25) + '%',
      };
    }
  }
  return { transitions, skylevels };
}
