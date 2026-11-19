import { copyFile, cp, mkdir, readFile, writeFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { join, resolve } from "node:path";
import { buildDossier } from "./vendor/makefun-roblox.ts";

const root = process.cwd();
const playPath = join(root, "PLAY.json");
const play = JSON.parse(await readFile(playPath, "utf8")) as { place_id?: unknown };
if (!Number.isInteger(play.place_id) || (play.place_id as number) <= 0) {
  throw new Error("PLAY.json must contain a positive integer place_id");
}

const gamePath = join(root, "game.rbxl");
if (!existsSync(gamePath)) {
  throw new Error("game.rbxl must exist before building the dossier");
}

const output = resolve(process.env.MAKEFUN_OUTPUT_DIR ?? "/output");
await mkdir(output, { recursive: true });
const screenshotsPath = join(root, "screenshots");
const screenshotsCopy = existsSync(screenshotsPath)
  ? cp(screenshotsPath, join(output, "screenshots"), { recursive: true, force: true })
  : mkdir(join(output, "screenshots"), { recursive: true });
await Promise.all([
  copyFile(gamePath, join(output, "game.rbxl")),
  copyFile(playPath, join(output, "PLAY.json")),
  cp(join(root, "src"), join(output, "src"), { recursive: true }),
  screenshotsCopy,
]);

const dossier = await buildDossier({
  outputDir: output,
  gamePath: join(output, "game.rbxl"),
  playPath: join(output, "PLAY.json"),
  sourceDir: join(output, "src"),
  screenshotsDir: join(output, "screenshots"),
});
await writeFile(join(output, "dossier.json"), JSON.stringify(dossier, null, 2) + "\n");
