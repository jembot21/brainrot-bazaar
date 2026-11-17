// Package the built Roblox place and its source into the make.fun hand-in directory.
import { copyFileSync, cpSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const projectDirectory = fileURLToPath(new URL('.', import.meta.url));
const outputDirectory = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';
const playMetadata = JSON.parse(readFileSync(join(projectDirectory, 'PLAY.json'), 'utf8')) as { place_id?: number };
if (playMetadata.place_id === 0) {
  throw new Error('Refusing hand-in: PLAY.json still names place 0.');
}
mkdirSync(outputDirectory, { recursive: true });

// Hidden entries are excluded at every level of recursive directory copies.
const includeVisible = (path: string): boolean => !basename(path).startsWith('.');
for (const filename of ['game.rbxl', 'PLAY.json']) {
  copyFileSync(join(projectDirectory, filename), join(outputDirectory, filename));
}
cpSync(join(projectDirectory, 'src'), join(outputDirectory, 'src'), {
  recursive: true,
  filter: includeVisible,
});
mkdirSync(join(outputDirectory, 'screenshots'), { recursive: true });
if (existsSync(join(projectDirectory, 'screenshots'))) {
  cpSync(join(projectDirectory, 'screenshots'), join(outputDirectory, 'screenshots'), {
    recursive: true,
    filter: includeVisible,
  });
}

// Keep the dossier limits aligned with the submission gate.
writeFileSync(
  join(outputDirectory, 'dossier.json'),
  buildDossier(outputDirectory, {
    text_max_bytes: 65536,
    screenshots: { max: 4, max_bytes: 262144 },
    max_instances: 500000,
    scripts_max_source_bytes: 8388608,
    scripts_max_path_chars: 1048576,
  }),
);
