import adapter from '@sveltejs/adapter-static';
import preprocess from 'svelte-preprocess';
import path from 'path';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://github.com/sveltejs/svelte-preprocess
	// for more information about preprocessors
	preprocess: preprocess(),

	kit: {
		adapter: adapter(),
		prerender: {
			default: true
		},
		vite: {
			resolve: {
				alias: {
					$lib: path.resolve('./src/lib'),
					$data: path.resolve('./src/data'),
					$stores: path.resolve('./src/stores'),
					$utils: path.resolve('./src/utils'),
					$assets: path.resolve('./src/assets'),
					$constants: path.resolve('./src/constants')
				}
			}
		}
	},

};

export default config;
