/**
 * Taken this from the top script for the static Banny, was a major hassle to load
 * over the webserver... it's typescriptified here
 */

/**
Given an attributes list 

const attributes = [
    {
      "trait_type": "Body",
      "value": "Yellow"
    },
    {
      "trait_type": "Both Hands",
      "value": "Nothing"
    },
    {
      "trait_type": "Choker",
      "value": "Choker"
    },
    {
      "trait_type": "Face",
      "value": "Eye Mouth"
    },
    {
      "trait_type": "Headgear",
      "value": "Sakura Haruno"
    },
    {
      "trait_type": "Left Hand",
      "value": "Nothing"
    },
    {
      "trait_type": "Lower Accessory",
      "value": "Black Shoes"
    },
    {
      "trait_type": "Oral Fixation",
      "value": "Nothing"
    },
    {
      "trait_type": "Outfit",
      "value": "Sakura Haruno"
    },
    {
      "trait_type": "Right Hand",
      "value": "Nothing"
    },
    {
      "trait_type": "Comms",
      "value": 2
    },
    {
      "trait_type": "Grind",
      "value": 3
    },
    {
      "trait_type": "Perception",
      "value": 4
    },
    {
      "trait_type": "Strength",
      "value": 4
    },
    {
      "trait_type": "Shadowiness",
      "value": 3
    },
    {
      "trait_type": "Jbx Range",
      "value": "7,000-7,999"
    },
    {
      "trait_type": "Range Width",
      "value": 1000
    }
  ]

  Create an object of the form:
  const layers = {
    Body: "Yellow",
    Both_Hands: "Nothing",
    Choker: "Choker",
    Face: "Eye_Mouth",
    Headgear: "No_Hat",
    Left_Hand: "Nothing",
    Lower_Accessory: "Black_Shoes",
    Oral_Fixation: "Nothing",
    Outfit: "No_Outfit",
    Right_Hand: "Nothing",
  };

  Which will be used to create the layered svg.
*/

const baseUrl = '';
const layerList = [
	'Body',
	'Both_Hands',
	'Choker',
	'Face',
	'Headgear',
	'Left_Hand',
	'Lower_Accessory',
	'Oral_Fixation',
	'Outfit',
	'Right_Hand'
];

export const layerOrdering = [
	'Body',
	'Face',
	'Choker',
	'Lower_Accessory',
	'Outfit',
	'Oral_Fixation',
	'Headgear',
	'Left_Hand',
	'Right_Hand',
	'Both_Hands'
];

type Layers = { [trait: string]: string };
type Attributes = {
	trait_type: string;
	value: string;
}[];

async function getMetadata(bannyIndex: number) {
	const response = await fetch(`${baseUrl}/metadata/${bannyIndex}.json`);
	const json = await response.json();
	return json;
}

function createLayersObjectFromAttributes(attributes: Attributes) {
	const layers = {};
	attributes.forEach(attribute => {
		const trait_type = attribute.trait_type.replaceAll(' ', '_');

		if (layerList.includes(trait_type)) {
			const value = attribute.value.replaceAll(' ', '_');
			layers[trait_type] = value;
		}
	});
	return layers;
}

export async function getLayeredSvg({ layers }: { layers: Layers }) {
	let svgImageString = '';
	for (const key of layerOrdering) {
    const value = layers[key];
		if (!value) continue;
		// TODO: This is where we need to get the png from the contract
		// or like the blob data to pass to the file reader
		const src = `${baseUrl}/layers/${key}/${value}.png`;
		const response = await fetch(src);

		const reader = new FileReader();
		reader.readAsDataURL(await response.blob());
		svgImageString += await new Promise(resolve => {
			reader.onloadend = function() {
				const base64data = reader.result;
				const image = `<image x="50%" y="50%" width="1000" xlink:href="${base64data}" style="transform: translate(-500px, -500px)" />`;
				resolve(image);
			};
		});
	}
	return svgImageString;
}

async function getLayeredSvgFromAttributes(attributes: Attributes) {
	const layers = createLayersObjectFromAttributes(attributes);
	return getLayeredSvg({ layers });
}

export async function getLayeredSvgFromBannyIndex(bannyIndex: number) {
	const metadata = await getMetadata(bannyIndex);
	const image = await getLayeredSvgFromAttributes(metadata.attributes);
	// Check if a standard banny
	if (bannyIndex <= 60) {
		const jbx_range = metadata.attributes.find(
			(attribute: { trait_type: string }) => attribute.trait_type === 'Jbx Range'
		).value;
		return { image, jbx_range };
	}
	return { image };
}
