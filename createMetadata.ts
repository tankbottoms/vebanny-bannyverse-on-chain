import fs from "fs";

type Attribute = {
  trait_type: string;
  value: string | number;
};

function capitalizeFirstLetter(string: string) {
  const listOfWords = string.split("_");
  const capitalized = listOfWords.map((item) => {
    return item.charAt(0).toUpperCase() + item.slice(1);
  });
  return capitalized.join(" ");
}

function format(str: string) {
  return str.replaceAll("_", " ").trim();
}

function createAttributesFromObject(obj) {
  const attributes: Attribute[] = [];
  Object.keys(obj).forEach((key) => {
    if (obj[key]) {
      const item: Attribute = { trait_type: "", value: "" };
      item["trait_type"] = format(key);
      // Check if obj[key] is a number
      if (typeof obj[key] === "number") {
        item["value"] = obj[key];
      } else {
        item["value"] = format(obj[key]);
      }
      attributes.push(item);
    }
  });
  return attributes;
}

const charactersJsonFilePath = "./characters.json";

// Create metadata directory if it doesn't exist
if (!fs.existsSync("./metadata")) {
  fs.mkdirSync("./metadata");
}

// Read the characters json file
const charactersJson = fs.readFileSync(charactersJsonFilePath, "utf8");
const characters = JSON.parse(charactersJson);

// Iterate over the characters and create a metadata file for each character
Object.keys(characters).forEach((character) => {
  const metadata = {};
  const data = characters[character];

  // Combine the layers and metadata into a single array of objects
  // Start with the layers
  const layerAttributes = createAttributesFromObject(data.layers);

  // Get a subset of the metadata keys that are relevant for the attributes
  const subset = [
    "arcana",
    "comms",
    "grind",
    "perception",
    "strength",
    "shadowiness",
    "jbx_range",
    "range_width",
  ].reduce((result, key) => {
    if (key === "jbx_range") {
      result[capitalizeFirstLetter(key)] = data.metadata[key];
    } else {
      result[capitalizeFirstLetter(key)] = Number(data.metadata[key]);
    }
    return result;
  }, {});

  const metadataAttributes = createAttributesFromObject(subset);

  // Combine the layers and metadata into a single array of objects
  const attributes = layerAttributes.concat(metadataAttributes);

  metadata["name"] = format(data.metadata.name);
  // TODO: Add the rest of the metadata
  metadata["external_link"] = "";
  metadata["description"] = data.metadata.history;
  metadata["attributes"] = attributes;

  // Write the metadata file
  const metadataFilePath = `./metadata/${character}.json`;
  fs.writeFileSync(metadataFilePath, JSON.stringify(metadata, null, 2));
});
