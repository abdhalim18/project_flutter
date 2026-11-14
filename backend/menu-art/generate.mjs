// Menggambar ilustrasi menu (14 produk seed) sebagai SVG, lalu merendernya ke JPEG 800x800
// dengan Chrome headless. Hasil: db/menu-photos/<nama-produk>.jpg, diunggah ke database dengan
// npm run menu:photos.
//
// Jalankan: npm run menu:art   (butuh Google Chrome terpasang)
import { execFileSync } from "node:child_process";
import { existsSync, mkdirSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

const OUT = fileURLToPath(new URL("../db/menu-photos/", import.meta.url));
const SIZE = 800;

// Latar per kategori: krem (Kopi), lila (Non-Kopi), biru muda (Snack).
const BG = { kopi: "#F2E6D8", nonkopi: "#ECE4F3", snack: "#DDE9F3" };

// ---------------------------------------------------------------------------------------
// Bagian yang dipakai bersama
// ---------------------------------------------------------------------------------------

const svg = (bg, body, defs = "", zoom = 1) => `<svg xmlns="http://www.w3.org/2000/svg" width="${SIZE}" height="${SIZE}" viewBox="0 0 800 800">
<defs>
  <radialGradient id="glow" cx="50%" cy="38%" r="60%">
    <stop offset="0" stop-color="#fff" stop-opacity="0.6"/>
    <stop offset="1" stop-color="#fff" stop-opacity="0"/>
  </radialGradient>
  ${defs}
</defs>
<rect width="800" height="800" fill="${bg}"/>
<rect width="800" height="800" fill="url(#glow)"/>
<g transform="translate(400 440) scale(${zoom}) translate(-400 -440)">
${body}
</g>
</svg>`;

const shadow = (cx, cy, rx, ry, o = 0.16) =>
  `<ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}" fill="#3a2614" opacity="${o}"/>`;

const steam = (xs, top = 250, bottom = 360) =>
  xs
    .map(
      (x, i) =>
        `<path d="M ${x} ${bottom} C ${x - 22} ${bottom - 35}, ${x + 22} ${bottom - 60}, ${x} ${(bottom + top) / 2} S ${x - 20} ${top + 25}, ${x + 4} ${top}" fill="none" stroke="#fff" stroke-width="11" stroke-linecap="round" opacity="${0.75 - i * 0.08}"/>`,
    )
    .join("");

const ice = (x, y, s, rot) =>
  `<g transform="translate(${x} ${y}) rotate(${rot})">
    <rect x="${-s / 2}" y="${-s / 2}" width="${s}" height="${s}" rx="${s * 0.22}" fill="#fff" opacity="0.42"/>
    <rect x="${-s / 2 + 6}" y="${-s / 2 + 6}" width="${s * 0.38}" height="${s * 0.16}" rx="4" fill="#fff" opacity="0.7"/>
  </g>`;

// Saucer (piring kecil) untuk cangkir panas.
const saucer = (cy, rx) => `
  ${shadow(400, cy + 26, rx + 10, 40)}
  <ellipse cx="400" cy="${cy + 10}" rx="${rx}" ry="${rx * 0.24}" fill="#D9D1C6"/>
  <ellipse cx="400" cy="${cy}" rx="${rx}" ry="${rx * 0.24}" fill="#FFFFFF"/>
  <ellipse cx="400" cy="${cy - 4}" rx="${rx * 0.66}" ry="${rx * 0.15}" fill="#EFE9E1"/>`;

// Piring makan untuk snack.
const plate = (cy, rx = 270) => `
  ${shadow(400, cy + 30, rx + 10, 46, 0.14)}
  <ellipse cx="400" cy="${cy + 12}" rx="${rx}" ry="${rx * 0.27}" fill="#CBD6E1"/>
  <ellipse cx="400" cy="${cy}" rx="${rx}" ry="${rx * 0.27}" fill="#FFFFFF"/>
  <ellipse cx="400" cy="${cy - 2}" rx="${rx * 0.72}" ry="${rx * 0.19}" fill="#F1F5F9"/>`;

// Gelas plastik tinggi (es kopi susu, thai tea) dengan isi dari gradien `fillId`.
const plasticCup = (fillId, extraInside, strawColor) => `
  ${shadow(400, 640, 150, 30)}
  <clipPath id="cup"><path d="M 252 215 L 548 215 L 512 622 Q 510 632 500 632 L 300 632 Q 290 632 288 622 Z"/></clipPath>
  <rect x="${430}" y="70" width="24" height="200" rx="10" fill="${strawColor}" transform="rotate(12 442 170)"/>
  <g clip-path="url(#cup)">
    <rect x="240" y="250" width="320" height="400" fill="url(#${fillId})"/>
    ${extraInside}
    <rect x="240" y="215" width="320" height="38" fill="#fff" opacity="0.18"/>
  </g>
  <path d="M 252 215 L 548 215 L 512 622 Q 510 632 500 632 L 300 632 Q 290 632 288 622 Z" fill="#fff" opacity="0.08" stroke="#fff" stroke-width="6" stroke-opacity="0.9"/>
  <path d="M 282 245 L 312 600" stroke="#fff" stroke-width="16" stroke-linecap="round" opacity="0.35"/>
  <rect x="238" y="196" width="324" height="26" rx="12" fill="#fff" opacity="0.92"/>
  <rect x="238" y="214" width="324" height="8" rx="4" fill="#D8D2CC" opacity="0.6"/>`;

// Gelas kaca tinggi (latte, matcha).
const tallGlass = (fillId, fillTop, extraInside = "") => `
  ${shadow(400, 628, 120, 26)}
  <clipPath id="glass"><path d="M 300 210 L 500 210 L 486 608 Q 484 618 474 618 L 326 618 Q 316 618 314 608 Z"/></clipPath>
  <g clip-path="url(#glass)">
    <rect x="290" y="${fillTop}" width="220" height="${640 - fillTop}" fill="url(#${fillId})"/>
    ${extraInside}
    <rect x="290" y="588" width="220" height="40" fill="#fff" opacity="0.35"/>
  </g>
  <path d="M 300 210 L 500 210 L 486 608 Q 484 618 474 618 L 326 618 Q 316 618 314 608 Z" fill="#fff" opacity="0.1" stroke="#fff" stroke-width="6" stroke-opacity="0.9"/>
  <path d="M 325 240 L 336 585" stroke="#fff" stroke-width="14" stroke-linecap="round" opacity="0.4"/>
  <ellipse cx="400" cy="210" rx="100" ry="10" fill="none" stroke="#fff" stroke-width="5" opacity="0.9"/>`;

// Pseudo-random deterministik (gambar sama setiap kali dibuat).
function rng(seed) {
  return () => {
    seed = (seed + 0x6d2b79f5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const bean = (x, y, rot) =>
  `<g transform="translate(${x} ${y}) rotate(${rot})"><ellipse rx="22" ry="15" fill="#5B341C"/><path d="M -16 2 C -6 -6, 6 6, 16 -2" stroke="#3A1F0F" stroke-width="4" fill="none" stroke-linecap="round"/><ellipse cx="-6" cy="-6" rx="7" ry="3" fill="#7A4A2A"/></g>`;

// ---------------------------------------------------------------------------------------
// Ilustrasi per produk
// ---------------------------------------------------------------------------------------

const art = {
  Espresso: () =>
    svg(
      BG.kopi,
      `${bean(210, 650, -20)}${bean(600, 668, 25)}
      ${saucer(570, 210)}
      <path d="M 498 432 C 572 420, 586 512, 500 512" fill="none" stroke="#E4DDD3" stroke-width="26" stroke-linecap="round"/>
      <path d="M 498 432 C 562 424, 572 500, 500 504" fill="none" stroke="#FFFFFF" stroke-width="16" stroke-linecap="round"/>
      <path d="M 290 400 C 290 505, 322 572, 400 572 C 478 572, 510 505, 510 400 Z" fill="url(#cupShade)"/>
      <ellipse cx="400" cy="400" rx="110" ry="28" fill="#F7F3EE"/>
      <ellipse cx="400" cy="404" rx="96" ry="21" fill="#6B3A1E"/>
      <ellipse cx="400" cy="406" rx="84" ry="16" fill="#C07A3E"/>
      <ellipse cx="384" cy="402" rx="38" ry="6" fill="#DDA163" opacity="0.85"/>
      ${steam([370, 410, 445], 230, 370)}`,
      `<linearGradient id="cupShade" x1="0" x2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="0.6" stop-color="#F6F2EC"/><stop offset="1" stop-color="#DCD4C9"/></linearGradient>`,
      1.3,
    ),

  Americano: () =>
    svg(
      BG.kopi,
      `${shadow(400, 622, 165, 30)}
      <path d="M 498 380 C 596 372, 600 532, 498 524" fill="none" stroke="#24585C" stroke-width="32" stroke-linecap="round"/>
      <path d="M 300 330 L 300 565 Q 300 615 350 615 L 450 615 Q 500 615 500 565 L 500 330 Z" fill="url(#mug)"/>
      <rect x="318" y="350" width="16" height="220" rx="8" fill="#fff" opacity="0.18"/>
      <ellipse cx="400" cy="330" rx="100" ry="26" fill="#3F8A90"/>
      <ellipse cx="400" cy="334" rx="87" ry="19" fill="#24150D"/>
      <ellipse cx="380" cy="331" rx="34" ry="5" fill="#5A3A28" opacity="0.8"/>
      ${steam([368, 405, 440], 190, 300)}`,
      `<linearGradient id="mug" x1="0" x2="1"><stop offset="0" stop-color="#357C82"/><stop offset="0.65" stop-color="#2E6E73"/><stop offset="1" stop-color="#21525A"/></linearGradient>`,
      1.15,
    ),

  "Kopi Susu Gula Aren": () =>
    svg(
      BG.kopi,
      plasticCup(
        "ksga",
        `<path d="M 240 548 C 300 532, 340 560, 400 546 S 500 534, 560 550 L 560 650 L 240 650 Z" fill="#6E3B1A"/>
         <path d="M 240 552 C 300 538, 340 566, 400 552" stroke="#8E5428" stroke-width="5" fill="none" opacity="0.7"/>
         ${ice(320, 278, 66, -12)}${ice(415, 266, 70, 9)}${ice(365, 338, 62, 22)}${ice(478, 330, 60, -8)}`,
        "#2B1D16",
      ),
      `<linearGradient id="ksga" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#9C6440"/><stop offset="0.32" stop-color="#B98660"/>
        <stop offset="0.55" stop-color="#E9D7BE"/><stop offset="1" stop-color="#F3E7D5"/></linearGradient>`,
    ),

  Cappuccino: () =>
    svg(
      BG.kopi,
      `${saucer(585, 245)}
      <path d="M 520 420 C 600 412, 612 512, 516 512" fill="none" stroke="#E4DDD3" stroke-width="28" stroke-linecap="round"/>
      <path d="M 520 420 C 590 416, 598 502, 516 504" fill="none" stroke="#FFFFFF" stroke-width="17" stroke-linecap="round"/>
      <path d="M 268 395 C 268 515, 318 588, 400 588 C 482 588, 532 515, 532 395 Z" fill="url(#cupShade)"/>
      <ellipse cx="400" cy="395" rx="132" ry="50" fill="#F7F3EE"/>
      <ellipse cx="400" cy="399" rx="118" ry="41" fill="#B57744"/>
      <ellipse cx="400" cy="401" rx="112" ry="37" fill="#C0834F"/>
      <path d="M 400 428 C 336 398, 350 352, 400 382 C 450 352, 464 398, 400 428 Z" fill="#FBF4EA"/>
      <path d="M 400 414 C 368 396, 376 376, 400 390 C 424 376, 432 396, 400 414 Z" fill="#C0834F" opacity="0.9"/>
      <circle cx="340" cy="388" r="3" fill="#6F4022" opacity="0.5"/><circle cx="458" cy="410" r="3" fill="#6F4022" opacity="0.5"/>
      <circle cx="470" cy="386" r="2.5" fill="#6F4022" opacity="0.5"/><circle cx="330" cy="414" r="2.5" fill="#6F4022" opacity="0.5"/>`,
      `<linearGradient id="cupShade" x1="0" x2="1"><stop offset="0" stop-color="#FFFFFF"/><stop offset="0.6" stop-color="#F6F2EC"/><stop offset="1" stop-color="#DCD4C9"/></linearGradient>`,
      1.12,
    ),

  "Cafe Latte": () =>
    svg(
      BG.kopi,
      `${shadow(400, 640, 210, 34)}
      <ellipse cx="400" cy="626" rx="200" ry="44" fill="#D9D1C6"/>
      <ellipse cx="400" cy="616" rx="200" ry="44" fill="#FFFFFF"/>
      <ellipse cx="400" cy="613" rx="132" ry="26" fill="#EFE9E1"/>
      <g transform="rotate(-14 548 610)">
        <rect x="470" y="604" width="120" height="10" rx="5" fill="#B9C0C9"/>
        <ellipse cx="596" cy="609" rx="24" ry="13" fill="#C9CFD7"/>
        <ellipse cx="592" cy="606" rx="12" ry="5" fill="#E8ECF0"/>
      </g>
      <g transform="translate(0 -14)">${tallGlass("latte", 235)}</g>
      ${bean(220, 668, -15)}`,
      `<linearGradient id="latte" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#FBF5EC"/><stop offset="0.13" stop-color="#F3E7D6"/>
        <stop offset="0.19" stop-color="#A9713F"/><stop offset="0.42" stop-color="#C79766"/>
        <stop offset="0.6" stop-color="#EBDDC8"/><stop offset="1" stop-color="#F5ECDF"/></linearGradient>`,
    ),

  Mocha: () =>
    svg(
      BG.kopi,
      `${shadow(400, 628, 150, 28)}
      <path d="M 494 380 C 580 376, 584 520, 494 516" fill="none" stroke="#fff" stroke-width="22" stroke-opacity="0.85" stroke-linecap="round"/>
      <clipPath id="mug"><path d="M 292 330 L 508 330 L 508 560 Q 508 618 450 618 L 350 618 Q 292 618 292 560 Z"/></clipPath>
      <g clip-path="url(#mug)"><rect x="280" y="330" width="240" height="300" fill="url(#mocha)"/></g>
      <path d="M 292 330 L 508 330 L 508 560 Q 508 618 450 618 L 350 618 Q 292 618 292 560 Z" fill="#fff" opacity="0.08" stroke="#fff" stroke-width="6" stroke-opacity="0.9"/>
      <path d="M 314 360 L 314 560" stroke="#fff" stroke-width="14" stroke-linecap="round" opacity="0.35"/>
      <g>
        <ellipse cx="400" cy="330" rx="116" ry="26" fill="#EDE3D6"/>
        <circle cx="334" cy="310" r="44" fill="#F4ECE1"/><circle cx="466" cy="310" r="44" fill="#F4ECE1"/>
        <circle cx="398" cy="288" r="58" fill="#FFFDF8"/><circle cx="350" cy="292" r="40" fill="#FFFDF8"/>
        <circle cx="448" cy="294" r="40" fill="#FFFDF8"/><circle cx="404" cy="236" r="36" fill="#FFFDF8"/>
        <path d="M 404 196 C 430 206, 424 226, 404 228" fill="#FFFDF8"/>
      </g>
      <path d="M 314 312 C 334 290, 356 326, 380 304 S 424 286, 446 308 S 476 316, 488 300" fill="none" stroke="#5A2E1A" stroke-width="9" stroke-linecap="round"/>
      <path d="M 350 266 C 368 248, 392 280, 412 258 S 446 252, 456 266" fill="none" stroke="#5A2E1A" stroke-width="8" stroke-linecap="round"/>
      <path d="M 378 226 C 392 214, 410 236, 426 222" fill="none" stroke="#5A2E1A" stroke-width="7" stroke-linecap="round"/>
      <path d="M 320 318 Q 318 340 324 352" stroke="#5A2E1A" stroke-width="8" stroke-linecap="round" fill="none"/>
      <path d="M 470 314 Q 474 334 468 346" stroke="#5A2E1A" stroke-width="8" stroke-linecap="round" fill="none"/>
      <rect x="380" y="214" width="12" height="6" rx="2" fill="#4A2416" transform="rotate(20 386 217)"/>
      <rect x="414" y="230" width="12" height="6" rx="2" fill="#4A2416" transform="rotate(-30 420 233)"/>`,
      `<linearGradient id="mocha" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#7A4528"/><stop offset="1" stop-color="#3E2113"/></linearGradient>`,
      1.08,
    ),

  "Matcha Latte": () =>
    svg(
      BG.nonkopi,
      `<rect x="438" y="90" width="22" height="230" rx="9" fill="#6E9E4E" transform="rotate(11 449 205)"/>
      ${tallGlass("matcha", 240, `${ice(350, 270, 60, -10)}${ice(440, 262, 64, 12)}${ice(400, 322, 56, 25)}`)}`,
      `<linearGradient id="matcha" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#6B9B4A"/><stop offset="0.42" stop-color="#89B566"/>
        <stop offset="0.56" stop-color="#C9DDAE"/><stop offset="0.68" stop-color="#F3F1E3"/><stop offset="1" stop-color="#F7F5EB"/></linearGradient>`,
    ),

  Chocolate: () => {
    const mallow = (x, y, c, rot) =>
      `<g transform="translate(${x} ${y}) rotate(${rot})"><rect x="-22" y="-18" width="44" height="36" rx="10" fill="${c}"/><rect x="-22" y="-18" width="44" height="14" rx="7" fill="#fff" opacity="0.55"/></g>`;
    return svg(
      BG.nonkopi,
      `${shadow(400, 622, 165, 30)}
      <path d="M 498 380 C 596 372, 600 532, 498 524" fill="none" stroke="#A84431" stroke-width="32" stroke-linecap="round"/>
      <path d="M 300 330 L 300 565 Q 300 615 350 615 L 450 615 Q 500 615 500 565 L 500 330 Z" fill="url(#mug)"/>
      <rect x="318" y="350" width="16" height="220" rx="8" fill="#fff" opacity="0.2"/>
      <ellipse cx="400" cy="330" rx="100" ry="26" fill="#DC7A62"/>
      <ellipse cx="400" cy="334" rx="87" ry="19" fill="#4E2A1A"/>
      ${mallow(360, 322, "#FFFFFF", -14)}${mallow(420, 316, "#F9C9D3", 10)}${mallow(392, 336, "#FFF6EE", 4)}${mallow(448, 334, "#FFFFFF", -6)}
      ${steam([368, 405, 440], 170, 285)}`,
      `<linearGradient id="mug" x1="0" x2="1"><stop offset="0" stop-color="#D4614A"/><stop offset="0.65" stop-color="#C8553D"/><stop offset="1" stop-color="#A84431"/></linearGradient>`,
      1.15,
    );
  },

  "Thai Tea": () =>
    svg(
      BG.nonkopi,
      plasticCup(
        "thai",
        `<path d="M 240 300 C 300 285, 330 320, 390 302 S 500 285, 560 306 L 560 340 C 500 322, 450 352, 390 336 S 290 322, 240 338 Z" fill="#F7D9B5" opacity="0.9"/>
         ${ice(320, 284, 64, -10)}${ice(418, 270, 70, 12)}${ice(370, 350, 60, 20)}${ice(480, 340, 58, -6)}`,
        "#D7263D",
      ),
      `<linearGradient id="thai" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#F6D3A6"/><stop offset="0.16" stop-color="#F2A55E"/>
        <stop offset="0.32" stop-color="#EA852E"/><stop offset="1" stop-color="#D4641A"/></linearGradient>`,
    ),

  "Lemon Tea": () => {
    const slice = (x, y, r, rot, o = 1) => {
      const seg = Array.from({ length: 8 }, (_, i) => {
        const a = (i * Math.PI) / 4;
        return `<line x1="0" y1="0" x2="${(Math.cos(a) * r * 0.78).toFixed(1)}" y2="${(Math.sin(a) * r * 0.78).toFixed(1)}" stroke="#FFF7C2" stroke-width="${r * 0.08}"/>`;
      }).join("");
      return `<g transform="translate(${x} ${y}) rotate(${rot})" opacity="${o}"><circle r="${r}" fill="#F2C200"/><circle r="${r * 0.88}" fill="#FFF5C0"/><circle r="${r * 0.8}" fill="#FBE36B"/>${seg}</g>`;
    };
    return svg(
      BG.nonkopi,
      `${shadow(400, 630, 150, 28)}
      <g><rect x="436" y="130" width="22" height="230" rx="9" fill="#FFFFFF" transform="rotate(14 447 245)"/>
         <rect x="436" y="150" width="22" height="18" fill="#F2C200" transform="rotate(14 447 245)"/>
         <rect x="436" y="190" width="22" height="18" fill="#F2C200" transform="rotate(14 447 245)"/></g>
      <clipPath id="tumbler"><path d="M 272 300 L 528 300 L 508 606 Q 506 618 494 618 L 306 618 Q 294 618 292 606 Z"/></clipPath>
      <g clip-path="url(#tumbler)">
        <rect x="260" y="330" width="280" height="300" fill="url(#tea)"/>
        ${slice(350, 470, 46, 20, 0.75)}${slice(450, 540, 40, -15, 0.7)}
        ${ice(335, 360, 62, -12)}${ice(430, 352, 66, 10)}${ice(390, 412, 56, 24)}
        <rect x="260" y="590" width="280" height="40" fill="#fff" opacity="0.3"/>
      </g>
      <path d="M 272 300 L 528 300 L 508 606 Q 506 618 494 618 L 306 618 Q 294 618 292 606 Z" fill="#fff" opacity="0.08" stroke="#fff" stroke-width="6" stroke-opacity="0.9"/>
      <path d="M 298 330 L 314 590" stroke="#fff" stroke-width="14" stroke-linecap="round" opacity="0.38"/>
      ${slice(518, 306, 64, 0)}
      <path d="M 470 306 L 566 306" stroke="${BG.nonkopi}" stroke-width="0"/>`,
      `<linearGradient id="tea" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#E9AE47"/><stop offset="1" stop-color="#C47719"/></linearGradient>`,
    );
  },

  Croissant: () => {
    // Lobus croissant: elips bergaris lapisan, dari ujung tipis ke tengah yang paling tebal.
    const lobe = (cx, cy, rx, ry, rot) =>
      `<g transform="rotate(${rot} ${cx} ${cy})">
        <ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}" fill="url(#crust)" stroke="#A9621F" stroke-width="4"/>
        <ellipse cx="${cx}" cy="${cy - ry * 0.42}" rx="${rx * 0.55}" ry="${ry * 0.3}" fill="#F9D693" opacity="0.7"/>
        <path d="M ${cx - rx * 0.92} ${cy + ry * 0.05} Q ${cx} ${cy + ry * 0.42} ${cx + rx * 0.92} ${cy + ry * 0.05}" stroke="#B0682A" stroke-width="4" fill="none" opacity="0.55"/>
        <path d="M ${cx - rx * 0.75} ${cy + ry * 0.5} Q ${cx} ${cy + ry * 0.8} ${cx + rx * 0.75} ${cy + ry * 0.5}" stroke="#B0682A" stroke-width="4" fill="none" opacity="0.45"/>
      </g>`;
    return svg(
      BG.snack,
      `${plate(575, 290)}
      ${lobe(208, 548, 26, 50, -68)}${lobe(592, 548, 26, 50, 68)}
      ${lobe(262, 506, 44, 72, -46)}${lobe(538, 506, 44, 72, 46)}
      ${lobe(330, 466, 60, 92, -22)}${lobe(470, 466, 60, 92, 22)}
      ${lobe(400, 448, 74, 108, 0)}
      <circle cx="372" cy="388" r="3.5" fill="#FFF3D6"/><circle cx="426" cy="380" r="3" fill="#FFF3D6"/>
      <circle cx="470" cy="420" r="3" fill="#FFF3D6"/><circle cx="318" cy="430" r="3" fill="#FFF3D6"/>`,
      `<radialGradient id="crust" cx="45%" cy="30%" r="80%"><stop offset="0" stop-color="#F4C474"/><stop offset="0.55" stop-color="#E0A04B"/><stop offset="1" stop-color="#B9732C"/></radialGradient>`,
      1.08,
    );
  },

  "Donut Coklat": () => {
    const r = rng(7);
    const colors = ["#F25F5C", "#FFE066", "#70C1B3", "#FFFFFF", "#9B5DE5", "#4CC9F0"];
    let sprinkles = "";
    for (let n = 0; n < 60 && sprinkles.split("<rect").length < 34; n++) {
      const a = r() * Math.PI * 2;
      const d = 0.45 + r() * 0.5;
      const x = 400 + Math.cos(a) * 140 * d;
      const y = 452 + Math.sin(a) * 80 * d;
      sprinkles += `<rect x="${(x - 9).toFixed(1)}" y="${(y - 3).toFixed(1)}" width="18" height="6" rx="3" fill="${colors[n % colors.length]}" transform="rotate(${Math.round(r() * 180)} ${x.toFixed(1)} ${y.toFixed(1)})"/>`;
    }
    const drips = [[285, 492, 16], [330, 520, 13], [452, 522, 15], [505, 500, 12], [372, 532, 10]]
      .map(([x, y, s]) => `<ellipse cx="${x}" cy="${y}" rx="${s}" ry="${s * 1.3}" fill="#5A3220"/>`)
      .join("");
    return svg(
      BG.snack,
      `${plate(565)}
      <ellipse cx="400" cy="482" rx="172" ry="104" fill="#BF7B3B"/>
      <ellipse cx="400" cy="462" rx="172" ry="104" fill="#E3A866"/>
      ${drips}
      <ellipse cx="400" cy="454" rx="158" ry="90" fill="#5A3220"/>
      <path d="M 280 420 Q 330 378 400 376" stroke="#8A5A40" stroke-width="10" fill="none" stroke-linecap="round" opacity="0.7"/>
      ${sprinkles}
      <ellipse cx="400" cy="452" rx="58" ry="34" fill="#E3A866"/>
      <ellipse cx="400" cy="458" rx="44" ry="24" fill="#F1F5F9"/>
      <path d="M 356 452 Q 400 432 444 452" stroke="#C88A4B" stroke-width="6" fill="none"/>`,
    );
  },

  "Banana Bread": () => {
    const crumb = (x, y, w, h, rot) => `<g transform="rotate(${rot} ${x + w / 2} ${y + h / 2})">
        <rect x="${x}" y="${y}" width="${w}" height="${h}" rx="20" fill="#7E4A20"/>
        <rect x="${x + 9}" y="${y + 9}" width="${w - 18}" height="${h - 18}" rx="14" fill="url(#crumb)"/>
        <ellipse cx="${x + w * 0.32}" cy="${y + h * 0.3}" rx="11" ry="7" fill="#F5E2A0"/>
        <ellipse cx="${x + w * 0.66}" cy="${y + h * 0.58}" rx="12" ry="7" fill="#F5E2A0"/>
        <ellipse cx="${x + w * 0.36}" cy="${y + h * 0.78}" rx="9" ry="6" fill="#F5E2A0"/>
        <circle cx="${x + w * 0.7}" cy="${y + h * 0.25}" r="4" fill="#5A3418"/>
        <circle cx="${x + w * 0.24}" cy="${y + h * 0.56}" r="3.5" fill="#5A3418"/>
        <circle cx="${x + w * 0.62}" cy="${y + h * 0.86}" r="3.5" fill="#5A3418"/>
      </g>`;
    return svg(
      BG.snack,
      `${shadow(400, 636, 270, 34, 0.14)}
      <rect x="140" y="488" width="520" height="140" rx="36" fill="#A9733F"/>
      <rect x="140" y="474" width="520" height="134" rx="36" fill="#D6A36C"/>
      <path d="M 186 520 L 614 520 M 206 566 L 594 566" stroke="#C38D55" stroke-width="4" opacity="0.55"/>
      <path d="M 232 500 L 232 400 Q 232 372 260 368 L 520 368 Q 548 372 548 400 L 548 500 Z" fill="url(#loaf)"/>
      <path d="M 228 404 C 236 312, 544 312, 552 404 Q 553 414 544 410 C 470 384, 320 384, 236 410 Q 227 414 228 404 Z" fill="#9B5C27"/>
      <path d="M 252 384 C 300 340, 480 340, 528 384" stroke="#6A3A15" stroke-width="9" fill="none" stroke-linecap="round"/>
      <path d="M 300 360 C 340 372, 360 350, 392 362 C 424 374, 450 352, 486 364" stroke="#C88A4C" stroke-width="5" fill="none" stroke-linecap="round" opacity="0.8"/>
      ${crumb(196, 382, 112, 128, 0)}
      ${crumb(330, 448, 104, 120, -10)}
      <path d="M 458 598 C 540 628, 640 594, 680 500 C 672 486, 652 486, 644 494 C 608 544, 550 560, 466 556 C 448 566, 446 590, 458 598 Z" fill="#F4D35E"/>
      <path d="M 470 588 C 550 606, 628 580, 664 506" stroke="#E0B83C" stroke-width="8" fill="none" stroke-linecap="round"/>
      <path d="M 486 566 C 554 572, 606 552, 638 512" stroke="#FFF1A8" stroke-width="7" fill="none" stroke-linecap="round" opacity="0.85"/>
      <ellipse cx="456" cy="578" rx="11" ry="18" fill="#5B3B16"/>
      <path d="M 660 492 L 680 466" stroke="#7A5A2A" stroke-width="13" stroke-linecap="round"/>`,
      `<linearGradient id="loaf" x1="0" x2="1"><stop offset="0" stop-color="#A2652E"/><stop offset="1" stop-color="#7A4620"/></linearGradient>
       <linearGradient id="crumb" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#E6B87A"/><stop offset="1" stop-color="#CF9A5C"/></linearGradient>`,
      1.12,
    );
  },

  "French Fries": () => {
    const fry = (x, y, h, rot, c) =>
      `<g transform="rotate(${rot} ${x} ${y + h})"><rect x="${x - 13}" y="${y}" width="26" height="${h}" rx="8" fill="${c}"/><rect x="${x - 13}" y="${y}" width="26" height="14" rx="7" fill="#D99A2B"/><rect x="${x - 7}" y="${y + 18}" width="6" height="${h - 40}" rx="3" fill="#FFF0B8" opacity="0.6"/></g>`;
    const back = [[315, 230, 250, -16], [360, 200, 280, -7], [405, 185, 300, 2], [450, 205, 280, 10], [492, 235, 250, 18]];
    const front = [[338, 260, 230, -11], [385, 240, 250, -3], [428, 238, 252, 6], [470, 262, 230, 13]];
    return svg(
      BG.snack,
      `${shadow(400, 628, 170, 30)}
      <ellipse cx="596" cy="602" rx="68" ry="22" fill="#B9C6D3"/>
      <ellipse cx="596" cy="594" rx="68" ry="22" fill="#FFFFFF"/>
      <ellipse cx="596" cy="592" rx="52" ry="14" fill="#C0392B"/>
      <ellipse cx="582" cy="588" rx="18" ry="4" fill="#E26355"/>
      <path d="M 292 400 L 508 400 L 500 430 L 300 430 Z" fill="#9E2F20"/>
      ${back.map(([x, y, h, rot]) => fry(x, y, h, rot, "#EDB847")).join("")}
      ${front.map(([x, y, h, rot]) => fry(x, y, h, rot, "#F7CF5A")).join("")}
      <path d="M 282 405 Q 340 445 400 445 Q 460 445 518 405 L 488 628 L 312 628 Z" fill="url(#box)"/>
      <path d="M 300 470 L 318 610 M 500 470 L 482 610" stroke="#fff" stroke-width="10" stroke-linecap="round" opacity="0.85"/>
      <circle cx="400" cy="530" r="38" fill="#FFFFFF"/>
      <path d="M 383 548 L 383 516 M 400 552 L 400 508 M 417 548 L 417 516" stroke="#F2B634" stroke-width="9" stroke-linecap="round"/>`,
      `<linearGradient id="box" x1="0" x2="1"><stop offset="0" stop-color="#E05540"/><stop offset="0.6" stop-color="#D64933"/><stop offset="1" stop-color="#B23A28"/></linearGradient>`,
    );
  },
};

// ---------------------------------------------------------------------------------------
// Render
// ---------------------------------------------------------------------------------------

export const slug = (name) => name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

const CHROME = [
  process.env.CHROME_PATH,
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  "/usr/bin/google-chrome",
  "/usr/bin/chromium",
].find((p) => p && existsSync(p));

if (process.argv[1] === fileURLToPath(import.meta.url)) {
  if (!CHROME) {
    console.error("Google Chrome tidak ditemukan. Set CHROME_PATH ke executable Chrome/Chromium.");
    process.exit(1);
  }
  const only = process.argv.slice(2);
  const work = join(tmpdir(), `menu-art-${process.pid}`);
  mkdirSync(work, { recursive: true });
  mkdirSync(OUT, { recursive: true });
  try {
    for (const [name, draw] of Object.entries(art)) {
      if (only.length && !only.includes(slug(name))) continue;
      const svgPath = join(work, `${slug(name)}.svg`);
      const pngPath = join(work, `${slug(name)}.png`);
      writeFileSync(svgPath, draw());
      execFileSync(CHROME, [
        "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
        `--window-size=${SIZE},${SIZE}`, `--screenshot=${pngPath}`, `file://${svgPath}`,
      ], { stdio: "ignore" });
      const jpgPath = join(OUT, `${slug(name)}.jpg`);
      execFileSync("sips", ["-s", "format", "jpeg", "-s", "formatOptions", "86", pngPath, "--out", jpgPath], { stdio: "ignore" });
      console.log(`  ${name.padEnd(22)} → db/menu-photos/${slug(name)}.jpg`);
    }
  } finally {
    rmSync(work, { recursive: true, force: true });
  }
}
