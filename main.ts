import { copyFileSync, cpSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const projectDirectory = fileURLToPath(new URL('.', import.meta.url));
const outputDirectory = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const playPath = join(projectDirectory, 'PLAY.json');
const playData = JSON.parse(readFileSync(playPath, 'utf-8'));
if (playData.place_id === 0) {
	throw new Error('Refusing hand-in: PLAY.json still names place 0.');
}

mkdirSync(outputDirectory, { recursive: true });

copyFileSync(join(projectDirectory, 'game.rbxl'), join(outputDirectory, 'game.rbxl'));
copyFileSync(playPath, join(outputDirectory, 'PLAY.json'));

// Exclude dotfiles and hidden folders at all directory levels during packaging
const filter = (source: string) => !basename(source).startsWith('.');

cpSync(join(projectDirectory, 'src'), join(outputDirectory, 'src'), {
	recursive: true,
	filter,
});

const outputScreenshots = join(outputDirectory, 'screenshots');
mkdirSync(outputScreenshots, { recursive: true });

const srcScreenshots = join(projectDirectory, 'screenshots');
if (existsSync(srcScreenshots)) {
	cpSync(srcScreenshots, outputScreenshots, {
		recursive: true,
		filter,
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
