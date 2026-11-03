/*
 * Tranh phong cảnh vườn Nhật kiểu anime, vẽ bằng canvas cho ba buổi: sáng, chiều, khuya.
 * Dùng khi chưa có ảnh nền trong data/backgrounds.js.
 */
(function () {
  'use strict';

  const PALETTES = {
    sang: {
      sky: [[0, '#3f8fdb'], [0.38, '#7fc0f2'], [0.72, '#cdeafa'], [1, '#fff4dd']],
      light: { x: 0.8, y: 0.13, r: 34, core: '#fffdf0', glow: [255, 248, 220], glowA: 0.55, sun: true },
      cloud: { lit: '#ffffff', mid: '#eef5fc', shade: '#a9c2e0', rim: '#fff9ec', alpha: 1 },
      mountains: ['#b8cde6', '#93b2d6', '#6f93bd'],
      snow: '#ffffff', snowShade: '#cadcf0',
      haze: '#eaf4fb',
      trees: ['#2f6b55', '#3f8466', '#56a07a'], treeRim: '#a6e0a0',
      pagoda: '#5d7fa3',
      water: ['#9fd0ee', '#5d9ccc', '#2f6a99'],
      glitter: [255, 255, 240],
      leaves: ['#3f9a4a', '#5cb85a', '#82cc62', '#2f7d40', '#a8dc78'], leafAlpha: 0.92, branch: '#3a2c22',
      rays: 0.16,
    },
    chieu: {
      sky: [[0, '#2c3f7f'], [0.3, '#7b5fa3'], [0.58, '#e7826e'], [0.82, '#ffb878'], [1, '#ffe2a4']],
      light: { x: 0.68, y: 0.6, r: 46, core: '#fff3c8', glow: [255, 190, 120], glowA: 0.7, sun: true },
      cloud: { lit: '#ffd9a6', mid: '#f3a58e', shade: '#8a5a8e', rim: '#fff0c4', alpha: 1 },
      mountains: ['#c08aa0', '#94688f', '#634a76'],
      snow: '#ffd7c4', snowShade: '#c68aa3',
      haze: '#f7b99c',
      trees: ['#2c2140', '#3c2a4f', '#4f3359'], treeRim: '#ff9d6a',
      pagoda: '#4e3863',
      water: ['#f2a789', '#a66a8a', '#3a2c55'],
      glitter: [255, 214, 150],
      leaves: ['#b7322a', '#d9502e', '#ef7a35', '#8f2229', '#f4a144'], leafAlpha: 0.95, branch: '#2a1820',
      rays: 0.2,
    },
    khuya: {
      sky: [[0, '#02040d'], [0.35, '#081634'], [0.72, '#16305e'], [1, '#2c4c80']],
      light: { x: 0.24, y: 0.17, r: 30, core: '#f6f3e2', glow: [190, 210, 255], glowA: 0.45, sun: false },
      cloud: { lit: '#8fa3cf', mid: '#3c4f7d', shade: '#151f3c', rim: '#d4e0ff', alpha: 0.85 },
      mountains: ['#2c4572', '#1f3359', '#142342'],
      snow: '#c9d8f2', snowShade: '#6e85b4',
      haze: '#2f4b7c',
      trees: ['#08101f', '#0d1830', '#13223f'], treeRim: '#5a78b0',
      pagoda: '#101c36',
      water: ['#24406f', '#13264a', '#060d1e'],
      glitter: [220, 230, 255],
      leaves: ['#0c1527', '#121f38', '#18294a', '#0a111f', '#1d3157'], leafAlpha: 1, branch: '#070b14',
      rays: 0,
      stars: true,
    },
  };

  function rng(seed) {
    let s = seed % 2147483647;
    if (s <= 0) s += 2147483646;
    return () => ((s = (s * 16807) % 2147483647) - 1) / 2147483646;
  }
  const rgba = (c, a) => `rgba(${c[0]},${c[1]},${c[2]},${a})`;
  function hex(h) { const n = parseInt(h.slice(1), 16); return [(n >> 16) & 255, (n >> 8) & 255, n & 255]; }
  // Cùng màu nhưng trong suốt, để dải chuyển màu không ngả xám.
  function clear(col) {
    if (col[0] === '#') { const v = hex(col); return `rgba(${v[0]},${v[1]},${v[2]},0)`; }
    const m = col.match(/\d+/g);
    return `rgba(${m[0]},${m[1]},${m[2]},0)`;
  }
  function mix(a, b, t) {
    const A = hex(a), B = hex(b);
    return `rgb(${Math.round(A[0] + (B[0] - A[0]) * t)},${Math.round(A[1] + (B[1] - A[1]) * t)},${Math.round(A[2] + (B[2] - A[2]) * t)})`;
  }

  function paint(canvas, period) {
    const P = PALETTES[period] || PALETTES.sang;
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const W = Math.max(canvas.clientWidth || window.innerWidth, 320);
    const H = Math.max(canvas.clientHeight || window.innerHeight, 480);
    canvas.width = Math.round(W * dpr);
    canvas.height = Math.round(H * dpr);
    const c = canvas.getContext('2d');
    c.setTransform(dpr, 0, 0, dpr, 0, 0);
    const R = rng(20241103);
    const between = (a, b) => a + (b - a) * R();
    const portrait = H > W * 1.1;

    const horizon = H * (portrait ? 0.6 : 0.62); // chân núi
    const shore = H * (portrait ? 0.7 : 0.72);   // mép nước
    const S = Math.max(W, H * 1.2) / 1440;       // tỉ lệ chung

    /* 1. Bầu trời */
    const sky = c.createLinearGradient(0, 0, 0, shore);
    P.sky.forEach(([o, col]) => sky.addColorStop(o, col));
    c.fillStyle = sky;
    c.fillRect(0, 0, W, H);

    /* 2. Sao và dải Ngân Hà */
    if (P.stars) {
      c.save();
      // dải Ngân Hà chéo
      c.translate(W * 0.55, H * 0.3);
      c.rotate(-0.5);
      for (let i = 0; i < 900; i++) {
        const x = between(-W * 0.9, W * 0.9);
        const spread = H * 0.09 * (1 + Math.sin(x / W * 3) * 0.3);
        const y = (R() + R() + R() - 1.5) * spread;
        c.fillStyle = `rgba(200,215,255,${between(0.03, 0.22)})`;
        c.fillRect(x, y, between(0.6, 1.6), between(0.6, 1.6));
      }
      const band = c.createLinearGradient(0, -H * 0.16, 0, H * 0.16);
      band.addColorStop(0, 'rgba(120,140,220,0)');
      band.addColorStop(0.5, 'rgba(150,165,235,.14)');
      band.addColorStop(1, 'rgba(120,140,220,0)');
      c.fillStyle = band;
      c.fillRect(-W, -H * 0.16, W * 2, H * 0.32);
      c.restore();
      for (let i = 0; i < 420; i++) {
        const x = R() * W, y = Math.pow(R(), 1.4) * horizon;
        const r = R() < 0.06 ? between(1, 1.7) : between(0.3, 0.9);
        c.fillStyle = `rgba(255,255,255,${between(0.35, 1)})`;
        c.beginPath(); c.arc(x, y, r, 0, Math.PI * 2); c.fill();
        if (r > 1.1) {
          const g = c.createRadialGradient(x, y, 0, x, y, r * 6);
          g.addColorStop(0, 'rgba(200,220,255,.35)'); g.addColorStop(1, 'rgba(200,220,255,0)');
          c.fillStyle = g; c.fillRect(x - r * 6, y - r * 6, r * 12, r * 12);
        }
      }
    }

    /* 3. Mặt trời / mặt trăng */
    const L = P.light;
    const lx = W * L.x, ly = H * L.y, lr = L.r * S;
    c.save();
    c.globalCompositeOperation = 'lighter';
    let g = c.createRadialGradient(lx, ly, 0, lx, ly, lr * 14);
    g.addColorStop(0, rgba(L.glow, L.glowA));
    g.addColorStop(0.15, rgba(L.glow, L.glowA * 0.45));
    g.addColorStop(1, rgba(L.glow, 0));
    c.fillStyle = g;
    c.fillRect(0, 0, W, H);
    c.restore();
    c.fillStyle = L.core;
    c.beginPath(); c.arc(lx, ly, lr, 0, Math.PI * 2); c.fill();
    if (!L.sun) {
      // vết trăng nhạt
      c.fillStyle = 'rgba(180,185,200,.25)';
      [[-0.3, -0.2, 0.22], [0.25, 0.1, 0.16], [-0.05, 0.35, 0.12], [0.35, -0.35, 0.1]].forEach(([dx, dy, rr]) => {
        c.beginPath(); c.arc(lx + dx * lr, ly + dy * lr, rr * lr, 0, Math.PI * 2); c.fill();
      });
    }

    /* Vẽ một khối (mây, tán cây) liền mạch: tô bóng trên cả khối thay vì từng hình tròn. */
    const off = document.createElement('canvas');
    off.width = canvas.width; off.height = canvas.height;
    const o = off.getContext('2d');
    function mass(circles, opts) {
      o.setTransform(1, 0, 0, 1, 0, 0);
      o.globalCompositeOperation = 'source-over';
      o.globalAlpha = 1;
      o.clearRect(0, 0, off.width, off.height);
      o.setTransform(dpr, 0, 0, dpr, 0, 0);
      let top = Infinity, bot = -Infinity, left = Infinity, right = -Infinity;
      o.fillStyle = opts.base;
      o.beginPath();
      circles.forEach(([x, y, r]) => {
        o.moveTo(x + r, y); o.arc(x, y, r, 0, Math.PI * 2);
        top = Math.min(top, y - r); bot = Math.max(bot, y + r);
        left = Math.min(left, x - r); right = Math.max(right, x + r);
      });
      if (opts.fillBelow != null) { o.rect(-10, opts.fillBelow, W + 20, H - opts.fillBelow); bot = H; left = Math.min(left, 0); right = Math.max(right, W); }
      o.fill();
      if (opts.flatBottom != null) o.clearRect(left - 10, opts.flatBottom, right - left + 20, bot - opts.flatBottom + 10);
      o.globalCompositeOperation = 'source-atop';
      // sáng trên, tối dưới
      const vg = o.createLinearGradient(0, top, 0, opts.flatBottom != null ? opts.flatBottom : bot);
      vg.addColorStop(0, opts.lit); vg.addColorStop(0.55, opts.base); vg.addColorStop(1, opts.shade);
      o.fillStyle = vg;
      o.fillRect(left, top, right - left, bot - top);
      // khối nhỏ: vùng sáng mềm phía nguồn sáng, bóng mềm phía đối diện
      circles.forEach(([x, y, r]) => {
        const dx = lx - x, dy = ly - y, d = Math.hypot(dx, dy) || 1;
        const hx = x + dx / d * r * 0.35, hy = y + dy / d * r * 0.35 - r * 0.25;
        let gr = o.createRadialGradient(hx, hy, 0, hx, hy, r * 0.95);
        gr.addColorStop(0, opts.hi); gr.addColorStop(1, clear(opts.hi));
        o.globalAlpha = opts.hiA;
        o.fillStyle = gr;
        o.fillRect(hx - r, hy - r, r * 2, r * 2);
        const sx = x - dx / d * r * 0.55, sy = y + r * 0.55;
        gr = o.createRadialGradient(sx, sy, 0, sx, sy, r * 0.8);
        gr.addColorStop(0, opts.shade); gr.addColorStop(1, clear(opts.shade));
        o.globalAlpha = opts.shA;
        o.fillStyle = gr;
        o.fillRect(sx - r, sy - r, r * 2, r * 2);
      });
      o.globalAlpha = 1;
      if (opts.texture) {
        for (let i = 0; i < opts.texture; i++) {
          const k = circles[Math.floor(R() * circles.length)];
          const a = R() * Math.PI * 2, rr = Math.sqrt(R()) * k[2];
          o.fillStyle = R() < 0.5 ? opts.hi : opts.shade;
          o.globalAlpha = between(0.05, 0.14);
          o.beginPath(); o.arc(k[0] + Math.cos(a) * rr, k[1] + Math.sin(a) * rr, between(1.5, 3.5) * S, 0, Math.PI * 2); o.fill();
        }
        o.globalAlpha = 1;
      }
      c.save();
      c.setTransform(1, 0, 0, 1, 0, 0);
      c.globalAlpha = opts.alpha == null ? 1 : opts.alpha;
      c.drawImage(off, 0, 0);
      c.restore();
    }

    /* 4. Mây */
    function cumulus(cx, cy, w, h) {
      const puffs = [];
      const n = Math.max(6, Math.round(w / 30));
      for (let i = 0; i < n; i++) {
        const t = i / (n - 1);
        const bell = Math.sin(t * Math.PI);
        const r = (h * 0.28 + h * 0.42 * bell) * between(0.8, 1.1);
        puffs.push([cx - w / 2 + t * w, cy - r * 0.5 - bell * h * between(0.15, 0.45), r]);
      }
      for (let i = 0; i < n * 0.7; i++) {
        const t = between(0.2, 0.8), bell = Math.sin(t * Math.PI);
        puffs.push([cx - w / 2 + t * w, cy - h * bell * between(0.75, 1.05), h * between(0.22, 0.4)]);
      }
      mass(puffs, {
        base: P.cloud.mid, lit: P.cloud.lit, shade: P.cloud.shade, hi: P.cloud.rim,
        hiA: 0.75, shA: 0.35, flatBottom: cy, alpha: P.cloud.alpha,
      });
    }
    function streak(cx, cy, w, h, alpha) {
      c.save();
      c.globalAlpha = alpha;
      for (let i = 0; i < 14; i++) {
        const x = cx + between(-w / 2, w / 2), y = cy + between(-h, h);
        const ww = w * between(0.25, 0.6), hh = h * between(0.25, 0.6);
        const gr = c.createLinearGradient(x - ww, 0, x + ww, 0);
        gr.addColorStop(0, clear(P.cloud.mid));
        gr.addColorStop(0.5, P.cloud.mid);
        gr.addColorStop(1, clear(P.cloud.mid));
        c.fillStyle = gr;
        c.beginPath(); c.ellipse(x, y, ww, hh, 0, 0, Math.PI * 2); c.fill();
        c.fillStyle = P.cloud.lit;
        c.globalAlpha = alpha * 0.5;
        c.beginPath(); c.ellipse(x, y - hh * 0.35, ww * 0.6, hh * 0.35, 0, 0, Math.PI * 2); c.fill();
        c.globalAlpha = alpha;
      }
      c.restore();
    }
    if (period === 'sang') {
      cumulus(W * 0.2, H * 0.36, 420 * S, 150 * S);
      cumulus(W * 0.62, H * 0.44, 560 * S, 170 * S);
      cumulus(W * 0.95, H * 0.3, 360 * S, 120 * S);
      cumulus(W * 0.42, H * 0.2, 240 * S, 70 * S);
      streak(W * 0.5, H * 0.08, W * 0.6, 14 * S, 0.5);
    } else if (period === 'chieu') {
      streak(W * 0.3, H * 0.18, W * 0.7, 18 * S, 0.65);
      streak(W * 0.75, H * 0.3, W * 0.6, 14 * S, 0.7);
      cumulus(W * 0.18, H * 0.48, 460 * S, 150 * S);
      cumulus(W * 0.9, H * 0.45, 420 * S, 140 * S);
      streak(W * 0.55, H * 0.52, W * 0.5, 8 * S, 0.6);
    } else {
      streak(W * 0.6, H * 0.22, W * 0.7, 14 * S, 0.55);
      cumulus(W * 0.85, H * 0.42, 420 * S, 120 * S);
      streak(W * 0.2, H * 0.4, W * 0.5, 10 * S, 0.45);
    }

    /* 5. Tia nắng */
    if (P.rays) {
      c.save();
      c.globalCompositeOperation = 'lighter';
      for (let i = 0; i < 7; i++) {
        const a = Math.PI * 0.5 + between(-0.9, 0.9) + (L.x > 0.5 ? 0.35 : -0.35);
        const spread = between(0.02, 0.06);
        const len = H * 1.4;
        const gr = c.createRadialGradient(lx, ly, lr, lx, ly, len);
        gr.addColorStop(0, rgba(L.glow, P.rays));
        gr.addColorStop(1, rgba(L.glow, 0));
        c.fillStyle = gr;
        c.beginPath();
        c.moveTo(lx, ly);
        c.lineTo(lx + Math.cos(a - spread) * len, ly + Math.sin(a - spread) * len);
        c.lineTo(lx + Math.cos(a + spread) * len, ly + Math.sin(a + spread) * len);
        c.closePath();
        c.fill();
      }
      c.restore();
    }

    /* 6. Núi xa, núi Phú Sĩ */
    function ridge(baseY, amp, color, seedOff, rough) {
      const r2 = rng(seedOff);
      const ph = [r2() * 6, r2() * 6, r2() * 6];
      c.fillStyle = color;
      c.beginPath();
      c.moveTo(0, H);
      for (let x = 0; x <= W + 8; x += 8) {
        const u = x / W;
        const y = baseY - amp * (0.55 + 0.3 * Math.sin(u * 5 + ph[0]) + 0.18 * Math.sin(u * 13 + ph[1]) + rough * Math.sin(u * 41 + ph[2]));
        c.lineTo(x, y);
      }
      c.lineTo(W, H);
      c.closePath();
      c.fill();
    }
    // núi xa nhất
    ridge(horizon, H * 0.1, P.mountains[0], 11, 0.05);
    // Phú Sĩ
    const fx = W * (portrait ? 0.5 : 0.6), fTop = horizon - H * (portrait ? 0.24 : 0.3), fHalf = W * (portrait ? 0.75 : 0.42);
    const fuji = new Path2D();
    fuji.moveTo(fx - fHalf, horizon + 10);
    fuji.bezierCurveTo(fx - fHalf * 0.45, horizon - 10, fx - fHalf * 0.2, fTop + H * 0.06, fx - fHalf * 0.09, fTop);
    fuji.lineTo(fx + fHalf * 0.09, fTop);
    fuji.bezierCurveTo(fx + fHalf * 0.2, fTop + H * 0.06, fx + fHalf * 0.45, horizon - 10, fx + fHalf, horizon + 10);
    fuji.closePath();
    const fg = c.createLinearGradient(fx - fHalf * 0.3, 0, fx + fHalf * 0.3, 0);
    const litLeft = lx < fx;
    fg.addColorStop(0, litLeft ? P.mountains[0] : P.mountains[1]);
    fg.addColorStop(1, litLeft ? P.mountains[1] : P.mountains[0]);
    c.fillStyle = fg;
    c.fill(fuji);
    // tuyết trên đỉnh
    c.save();
    c.clip(fuji);
    const snowY = fTop + (horizon - fTop) * 0.36;
    c.beginPath();
    c.moveTo(fx - fHalf, fTop - 10);
    c.lineTo(fx + fHalf, fTop - 10);
    let xs = fx + fHalf * 0.4;
    c.lineTo(xs, snowY);
    const teeth = 30;
    for (let i = 0; i <= teeth; i++) {
      const x = fx + fHalf * 0.4 - (i / teeth) * fHalf * 0.8;
      const deep = i % 2 ? between(0.01, 0.05) + (R() < 0.25 ? between(0.04, 0.12) : 0) : between(-0.04, 0);
      c.lineTo(x, snowY + deep * (horizon - fTop));
    }
    c.closePath();
    const sg = c.createLinearGradient(fx - fHalf * 0.2, 0, fx + fHalf * 0.2, 0);
    sg.addColorStop(0, litLeft ? P.snow : P.snowShade);
    sg.addColorStop(1, litLeft ? P.snowShade : P.snow);
    c.fillStyle = sg;
    c.fill();
    c.restore();
    // sương mù chân núi
    let hz = c.createLinearGradient(0, horizon - H * 0.12, 0, horizon + 4);
    hz.addColorStop(0, clear(P.haze));
    hz.addColorStop(1, P.haze);
    c.fillStyle = hz;
    c.globalAlpha = 0.85;
    c.fillRect(0, horizon - H * 0.12, W, H * 0.12 + 4);
    c.globalAlpha = 1;
    ridge(horizon + H * 0.03, H * 0.06, P.mountains[1], 23, 0.08);
    hz = c.createLinearGradient(0, horizon - H * 0.02, 0, horizon + H * 0.05);
    hz.addColorStop(0, clear(P.haze));
    hz.addColorStop(1, P.haze);
    c.globalAlpha = 0.6;
    c.fillStyle = hz;
    c.fillRect(0, horizon - H * 0.02, W, H * 0.07);
    c.globalAlpha = 1;

    /* 7. Tháp chùa năm tầng trên đồi */
    function pagoda(x, baseY, h, color) {
      c.fillStyle = color;
      const tiers = 5;
      const tierH = h * 0.15;
      let w = h * 0.36;
      let y = baseY;
      c.fillRect(x - w * 0.42, y - tierH * 0.6, w * 0.84, tierH * 0.6);
      y -= tierH * 0.6;
      for (let i = 0; i < tiers; i++) {
        const body = w * 0.42;
        c.fillRect(x - body / 2, y - tierH * 0.55, body, tierH * 0.55);
        y -= tierH * 0.55;
        // mái cong
        c.beginPath();
        c.moveTo(x - w / 2 - w * 0.06, y - tierH * 0.02);
        c.quadraticCurveTo(x - w * 0.3, y + tierH * 0.12, x - w * 0.2, y - tierH * 0.18);
        c.lineTo(x + w * 0.2, y - tierH * 0.18);
        c.quadraticCurveTo(x + w * 0.3, y + tierH * 0.12, x + w / 2 + w * 0.06, y - tierH * 0.02);
        c.lineTo(x + w * 0.16, y - tierH * 0.3);
        c.lineTo(x - w * 0.16, y - tierH * 0.3);
        c.closePath();
        c.fill();
        y -= tierH * 0.3;
        w *= 0.88;
      }
      c.fillRect(x - h * 0.008, y - h * 0.2, h * 0.016, h * 0.2); // chóp
      for (let k = 0; k < 6; k++) c.fillRect(x - h * 0.022, y - h * 0.04 - k * h * 0.026, h * 0.044, h * 0.008);
    }
    const hillY = horizon + H * 0.05;
    pagoda(W * (portrait ? 0.15 : 0.17), hillY - H * 0.005, H * (portrait ? 0.16 : 0.22), P.pagoda);

    /* 8. Hàng cây ven hồ: hai lớp tán liền khối */
    const treeTop = shore - H * 0.06;
    function treeRow(baseY, minR, maxR, freq, phase, cols, alpha) {
      const blobs = [];
      for (let x = -60; x < W + 60; x += between(14, 26) * S) {
        const big = Math.pow(Math.sin(x / W * freq + phase) * 0.5 + 0.5, 1.5);
        const r = (minR + (maxR - minR) * big * between(0.7, 1)) * S;
        blobs.push([x, baseY - r * between(0.2, 0.8), r]);
        if (big > 0.6 && R() < 0.5) blobs.push([x + between(-10, 10) * S, baseY - r * 1.3, r * 0.6]);
      }
      mass(blobs, { base: cols[1], lit: cols[2], shade: cols[0], hi: P.treeRim, hiA: period === 'khuya' ? 0.3 : 0.55, shA: 0.5, texture: 900, alpha, fillBelow: baseY });
    }
    treeRow(treeTop - H * 0.015, 14, 60, 7, 1, [P.trees[0], P.trees[1], mix(P.trees[1], P.mountains[2], 0.5)], 1);
    treeRow(treeTop + H * 0.03, 10, 34, 11, 4, [P.trees[0], P.trees[0], P.trees[1]], 1);

    /* 9. Mặt hồ */
    const wg = c.createLinearGradient(0, shore, 0, H);
    wg.addColorStop(0, P.water[0]);
    wg.addColorStop(0.5, P.water[1]);
    wg.addColorStop(1, P.water[2]);
    c.fillStyle = wg;
    c.fillRect(0, shore, W, H - shore);
    // phản chiếu cảnh vật (núi, trời) xuống mặt hồ
    c.save();
    c.beginPath(); c.rect(0, shore, W, H - shore); c.clip();
    c.globalAlpha = 0.42;
    c.translate(0, shore * 2);
    c.scale(1, -1);
    c.drawImage(canvas, 0, 0, canvas.width, Math.round(shore * dpr), 0, 0, W, shore);
    c.restore();
    const wv = c.createLinearGradient(0, shore, 0, H);
    wv.addColorStop(0, clear(P.water[2]));
    wv.addColorStop(1, P.water[2]);
    c.fillStyle = wv;
    c.fillRect(0, shore, W, H - shore);
    // bóng hàng cây dưới nước
    const rf = c.createLinearGradient(0, shore, 0, shore + H * 0.08);
    rf.addColorStop(0, P.trees[0]);
    rf.addColorStop(1, clear(P.trees[0]));
    c.globalAlpha = 0.75;
    c.fillStyle = rf;
    c.fillRect(0, shore, W, H * 0.08);
    c.globalAlpha = 1;
    // vệt sáng lấp lánh dưới mặt trời / trăng
    c.save();
    c.globalCompositeOperation = 'lighter';
    for (let i = 0; i < 160; i++) {
      const t = R();
      const y = shore + 4 + t * (H - shore);
      const spread = (20 + t * 160) * S * (L.sun && L.y > 0.4 ? 1.4 : 1);
      const x = lx + (R() + R() - 1) * spread;
      const w = between(8, 40) * S * (0.4 + t);
      c.fillStyle = rgba(P.glitter, between(0.08, 0.5) * (1 - t * 0.5));
      c.fillRect(x - w / 2, y, w, between(1, 2.2) * S);
    }
    // gợn nước
    for (let i = 0; i < 90; i++) {
      const y = shore + 6 + Math.pow(R(), 0.8) * (H - shore);
      const w = between(30, 160) * S;
      c.fillStyle = `rgba(255,255,255,${between(0.03, 0.09)})`;
      c.fillRect(R() * W - w / 2, y, w, 1.2 * S);
    }
    c.restore();
    // đèn lồng đá ven hồ ban đêm: chỉ là những đốm sáng ấm
    if (period === 'khuya') {
      [[0.08, 0], [0.45, 0.6], [0.72, 0.2]].forEach(([u, k]) => {
        const x = W * u, y = shore - H * 0.012;
        c.save(); c.globalCompositeOperation = 'lighter';
        const gl = c.createRadialGradient(x, y, 0, x, y, 60 * S);
        gl.addColorStop(0, 'rgba(255,200,110,.55)'); gl.addColorStop(1, 'rgba(255,200,110,0)');
        c.fillStyle = gl; c.fillRect(x - 60 * S, y - 60 * S, 120 * S, 120 * S);
        for (let j = 0; j < 9; j++) {
          const yy = shore + 6 + j * 7 * S * (1 + k * 0.5);
          const ww = between(6, 18) * S * (1 - j / 12);
          c.fillStyle = `rgba(255,190,100,${0.45 * (1 - j / 9)})`;
          c.fillRect(x - ww / 2 + between(-3, 3) * S, yy, ww, 1.6 * S);
        }
        c.restore();
        c.fillStyle = '#ffd690';
        c.beginPath(); c.arc(x, y, 3 * S, 0, Math.PI * 2); c.fill();
      });
    }

    /* 10. Cành phong che hai góc trên */
    function leaf(x, y, size, rot, color) {
      c.save();
      c.translate(x, y);
      c.rotate(rot);
      c.fillStyle = color;
      c.beginPath();
      const lobes = 7;
      for (let k = 0; k <= lobes; k++) {
        const a0 = -Math.PI / 2 + (k - lobes / 2) * (Math.PI * 1.5 / lobes);
        const len = size * (1 - Math.abs(k - lobes / 2) / lobes * 0.9);
        const tipX = Math.cos(a0) * len, tipY = Math.sin(a0) * len;
        const aIn = a0 + (Math.PI * 1.5 / lobes) / 2;
        const inX = Math.cos(aIn) * size * 0.3, inY = Math.sin(aIn) * size * 0.3;
        if (k === 0) c.moveTo(0, size * 0.05);
        c.quadraticCurveTo(Math.cos(a0 - 0.12) * len * 0.55, Math.sin(a0 - 0.12) * len * 0.55, tipX, tipY);
        if (k < lobes) c.quadraticCurveTo(Math.cos(a0 + 0.12) * len * 0.55, Math.sin(a0 + 0.12) * len * 0.55, inX, inY);
      }
      c.lineTo(0, size * 0.05);
      c.fill();
      c.restore();
    }
    function bough(x, y, ang, len, width, depth, rr) {
      const ex = x + Math.cos(ang) * len, ey = y + Math.sin(ang) * len;
      c.strokeStyle = P.branch;
      c.lineWidth = width;
      c.lineCap = 'round';
      c.beginPath();
      c.moveTo(x, y);
      c.quadraticCurveTo((x + ex) / 2 + Math.sin(ang) * len * 0.08, (y + ey) / 2 - Math.cos(ang) * len * 0.08, ex, ey);
      c.stroke();
      if (depth <= 0) {
        const n = 7 + Math.floor(rr() * 7);
        for (let i = 0; i < n; i++) {
          const size = (12 + rr() * 16) * S;
          const col = P.leaves[Math.floor(rr() * P.leaves.length)];
          c.globalAlpha = P.leafAlpha * (0.75 + rr() * 0.25);
          leaf(ex + (rr() - 0.5) * 70 * S, ey + (rr() - 0.3) * 50 * S, size, Math.PI + (rr() - 0.5) * 1.6, col);
        }
        c.globalAlpha = 1;
        return;
      }
      const kids = 2 + (rr() < 0.4 ? 1 : 0);
      for (let i = 0; i < kids; i++) {
        bough(ex, ey, ang + (rr() - 0.5) * 1.1 + 0.25, len * (0.62 + rr() * 0.18), width * 0.66, depth - 1, rr);
      }
    }
    const br = rng(99);
    const reach = Math.min(W * 0.36, 520 * S);
    bough(-20, H * 0.03, 0.12, reach * 0.42, 14 * S, 4, br);
    bough(-20, H * 0.24, -0.1, reach * 0.3, 10 * S, 3, br);
    c.save();
    c.translate(W, 0);
    c.scale(-1, 1);
    bough(-20, H * 0.06, 0.14, reach * 0.4, 13 * S, 4, br);
    c.restore();

    /* 11. Ánh sáng tổng thể */
    c.save();
    c.globalCompositeOperation = 'soft-light';
    g = c.createRadialGradient(lx, ly, 0, lx, ly, Math.max(W, H));
    g.addColorStop(0, rgba(L.glow, 0.45));
    g.addColorStop(1, 'rgba(0,0,0,.25)');
    c.fillStyle = g;
    c.fillRect(0, 0, W, H);
    c.restore();
  }

  window.IemaPainter = { paint, periods: Object.keys(PALETTES) };
})();
