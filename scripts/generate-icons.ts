import sharp from "sharp";
import path from "path";
import { fileURLToPath } from "url";
import fs from "fs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const publicDir = path.resolve(__dirname, "../ui/public");
const svgBuffer = fs.readFileSync(path.join(publicDir, "favicon.svg"));

const sizes = [
  { name: "favicon-16x16.png", size: 16 },
  { name: "favicon-32x32.png", size: 32 },
  { name: "apple-touch-icon.png", size: 180 },
  { name: "android-chrome-192x192.png", size: 192 },
  { name: "android-chrome-512x512.png", size: 512 },
  { name: "worktree-favicon-16x16.png", size: 16 },
  { name: "worktree-favicon-32x32.png", size: 32 },
];

for (const { name, size } of sizes) {
  await sharp(svgBuffer).resize(size, size).png().toFile(path.join(publicDir, name));
  console.log(`Generated ${name}`);
}

console.log("All icons generated!");