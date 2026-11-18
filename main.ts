// Package the Brainrot Tsunami Escape place and source for the competition hand-in.
import { copyFileSync, cpSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const projectDirectory = fileURLToPath(new URL('.', import.meta.url));
const outputDirectory = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const playPath = join(projectDirectory, 'PLAY.json');
const playData = JSON.parse(readFileSync(playPath, 'utf-8'));
const placeId = playData?.place_id;
if (!Number.isSafeInteger(placeId) || placeId <= 0) {
	throw new Error('Refusing hand-in: PLAY.json must name a published Roblox place (place 0 is the starter placeholder).');
}

const placeFile = join(projectDirectory, 'game.rbxl');
if (!existsSync(placeFile)) {
	throw new Error('Build game.rbxl with Rojo before running the hand-in.');
}

mkdirSync(outputDirectory, { recursive: true });

copyFileSync(placeFile, join(outputDirectory, 'game.rbxl'));
copyFileSync(playPath, join(outputDirectory, 'PLAY.json'));

// Exclude dotfiles and hidden folders at all directory levels during packaging.
const visibleEntry = (source: string) => !basename(source).startsWith('.');

cpSync(join(projectDirectory, 'src'), join(outputDirectory, 'src'), {
	recursive: true,
	filter: visibleEntry,
});

const outputScreenshots = join(outputDirectory, 'screenshots');
mkdirSync(outputScreenshots, { recursive: true });

const srcScreenshots = join(projectDirectory, 'screenshots');
if (existsSync(srcScreenshots)) {
	cpSync(srcScreenshots, outputScreenshots, {
		recursive: true,
		filter: visibleEntry,
	});
}

const dossierBytes = buildDossier(outputDirectory, {
	text_max_bytes: 65536,
	screenshots: { max: 4, max_bytes: 262144 },
	max_instances: 500000,
	scripts_max_source_bytes: 8388608,
	scripts_max_path_chars: 1048576,
});

writeFileSync(join(outputDirectory, 'dossier.json'), dossierBytes);
