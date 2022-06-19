function remainder(origin: number, mod: number) {
	const q = Math.floor(origin / mod);
	return origin - mod * q;
}

export function getAnimation(index: number) {
	const t = Math.random() * 20000;
	const angle = index - remainder(index, 8);
	return `anim${angle} ${Math.ceil(t)}ms, fade${Math.ceil(
		Math.random() * 10
	)} ${Math.ceil(t)}ms`;
}

export function getFadeKeyframes() {
	let css = '';
	for (let n = 1; n <= 11; n++) {
		const start = Math.random() * 20;
		const end = start + 10;
		css += `@keyframes fade${n} {
            ${start + '%'} {
                opacity: 0;
            }
            ${end + '%'} {
                opacity: 1;
            }
            100% {
                opacity: 1;
            }
        }`;
	}
	return css;
}

export function getMoveKeyframes() {
	let css = '';
	for (let n = 1; n <= 181; n++) {
		const a = n * 8;
		const angle = (Math.PI * 2 * a) / 720;
		const y = 80 * Math.sin(angle);
		const x = 80 * Math.cos(angle);
		css += `@keyframes anim${a} {
            100% {
                transform: translate(${x}vw, ${y}vh);
            }
        }`;
	}
	return css;
}
