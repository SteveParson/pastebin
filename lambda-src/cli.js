require('dotenv').config();
const arg = require('arg');

const args = arg({
  '--entrypoint': String,
});

const entrypoint = args['--entrypoint'];

if (entrypoint === undefined) {
  console.error(
    `No entrypoint specified, options are: ${Object.keys(
      require(`./snippets`),
    ).join(', ')}`,
  );
  process.exit(1);
}

const func = require(`./snippets`)[entrypoint];

if (func) {
  (async () => {
    console.log(`Running ${entrypoint}\n`);
    console.log(await func(...args['_']));
    console.log(`\nFinished running ${entrypoint}`);
    process.exit(0);
  })();
} else {
  console.warn(`No entrypoint found for ${entrypoint}`);
  process.exit(1);
}
