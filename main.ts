import { copyFileSync, cpSync, existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { basename, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const projectDirectory = fileURLToPath(new URL('.', import.meta.url));
const outputDirectory = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

const playJsonPath = join(projectDirectory, 'PLAY.json');
const playData = JSON.parse(readFileSync(playJsonPath, 'utf-8'));

if (playData.place_id === 0) {
  throw new Error('Refusing hand-in: PLAY.json still names place 0.');
}

mkdirSync(outputDirectory, { recursive: true });

copyFileSync(join(projectDirectory, 'game.rbxl'), join(outputDirectory, 'game.rbxl'));
copyFileSync(playJsonPath, join(outputDirectory, 'PLAY.json'));

const filterNoHidden = (source: string) => {
  return !basename(source).startsWith('.');
};

cpSync(join(projectDirectory, 'src'), join(outputDirectory, 'src'), {
  recursive: true,
  filter: filterNoHidden,
});

const screenshotsDir = join(projectDirectory, 'screenshots');
const outputScreenshotsDir = join(outputDirectory, 'screenshots');
mkdirSync(outputScreenshotsDir, { recursive: true });

if (existsSync(screenshotsDir)) {
  cpSync(screenshotsDir, outputScreenshotsDir, {
    recursive: true,
    filter: filterNoHidden,
  });
}

const dossier = buildDossier(outputDirectory, {
  text_max_bytes: 65536,
  screenshots: { max: 4, max_bytes: 262144 },
  max_instances: 500000,
  scripts_max_source_bytes: 8388608,
  scripts_max_path_chars: 1048576,
});

writeFileSync(join(outputDirectory, 'dossier.json'), dossier);
