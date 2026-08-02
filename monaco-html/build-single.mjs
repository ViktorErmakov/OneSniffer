/**
 * Build editor.single.html — self-contained Monaco page (same window API as multi-file).
 * Usage: node build-single.mjs
 */
import * as esbuild from 'esbuild';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const Dist = path.join(__dirname, 'dist');
const BundleJs = path.join(Dist, 'editor.single.bundle.js');
const OutHtml = path.join(Dist, 'editor.single.html');

if (!fs.existsSync(Dist)) {
  fs.mkdirSync(Dist, { recursive: true });
}

await esbuild.build({
  entryPoints: [path.join(__dirname, 'src', 'single-entry.js')],
  bundle: true,
  format: 'iife',
  outfile: BundleJs,
  platform: 'browser',
  target: ['es2015'],
  loader: {
    '.css': 'text',
    '.ttf': 'dataurl',
    '.woff': 'dataurl',
    '.woff2': 'dataurl',
  },
  logLevel: 'warning',
});

const js = fs.readFileSync(BundleJs, 'utf8');
const html = `<!DOCTYPE html>
<html lang="ru">
<head>
  <meta charset="UTF-8" />
  <meta http-equiv="X-UA-Compatible" content="IE=edge" />
  <title>OneSniffer Monaco Single</title>
  <style>
    html, body, #container {
      margin: 0;
      padding: 0;
      width: 100%;
      height: 100%;
      overflow: hidden;
      background: #fffffe;
    }
  </style>
</head>
<body>
  <div id="container"></div>
  <button id="V8_request" type="button" style="display:none"></button>
  <script>
${js}
  </script>
</body>
</html>
`;

fs.writeFileSync(OutHtml, html, 'utf8');
fs.unlinkSync(BundleJs);

const sizeMb = (fs.statSync(OutHtml).size / (1024 * 1024)).toFixed(2);
console.log(`OK: ${OutHtml} (${sizeMb} MB)`);
