import { buildDossier } from './vendor/makefun-roblox.ts';
import { cp, mkdir, readFile, stat, writeFile } from 'node:fs/promises';
import { join, resolve } from 'node:path';

const root = process.cwd();
const output = resolve(process.env.MAKEFUN_OUTPUT_DIR || '/output');
const play = JSON.parse(
  await readFile(join(root, 'PLAY.json'), 'utf8'),
);

// Check the source and destination before packaging the submission.
if (!Number.isSafeInteger(play.place_id) || play.place_id <= 0) {
  throw new Error('PLAY.json must contain a positive integer place_id.');
}
if (!(await stat(join(root, 'game.rbxl'))).isFile()) {
  throw new Error('Build game.rbxl with Rojo before assembling the dossier.');
}
if (output === root || output.startsWith(join(root, 'src') + '/')) {
  throw new Error('Choose an output directory outside the source tree.');
}

await mkdir(output, { recursive: true });
for (const entry of ['game.rbxl', 'PLAY.json', 'src', 'screenshots']) {
  await cp(join(root, entry), join(output, entry), {
    recursive: true,
    force: true,
  });
}

const comparisonPath = '/tmp/brainrot-r8.rbxl';
const comparison = await stat(comparisonPath).catch(() => null);
if (comparison?.isFile()) {
  const [repositoryBytes, verifiedBytes] = await Promise.all([
    readFile(join(root, 'game.rbxl')),
    readFile(comparisonPath),
  ]);
  if (!repositoryBytes.equals(verifiedBytes)) {
    throw new Error('The repository and verification place builds differ.');
  }
  console.log('Verified byte-identical place builds (' + repositoryBytes.length + ' bytes).');
}

const dossier = buildDossier(output, { text_max_bytes: 200000 });
await writeFile(join(output, 'dossier.json'), dossier);
const dossierText = Buffer.from(dossier).toString('utf8');
const document = JSON.parse(dossierText);
console.log(document.text.split('\n').slice(0, 10).join('\n'));

const localOutput = await stat(join(root, 'out')).catch(() => null);
if (localOutput) {
  throw new Error('Remove the in-repository out/ directory before submission.');
}
console.log('Dossier assembled in ' + output);
