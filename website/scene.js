/* Phong cảnh: đốm sáng, lá phong, chuông gió đung đưa, gió thổi, lá rơi, đom đóm. */
(function () {
  'use strict';
  const reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // Số ngẫu nhiên có hạt giống để phong cảnh giống nhau mỗi lần tải.
  let seed = 7;
  const rnd = () => ((seed = (seed * 16807) % 2147483647) - 1) / 2147483646;
  const between = (a, b) => a + (b - a) * rnd();
  const SVGNS = 'http://www.w3.org/2000/svg';

  /* Đốm sáng nhòe (bokeh) */
  const bokeh = document.getElementById('bokeh');
  for (let i = 0; i < 34; i++) {
    const s = document.createElement('span');
    const size = between(10, 70);
    s.style.cssText = `left:${between(0, 100)}%;top:${between(2, 62)}%;width:${size}px;height:${size}px;--t:${between(5, 12)}s;animation-delay:${-between(0, 10)}s`;
    bokeh.appendChild(s);
  }

  /* Tán lá phong ở hai góc trên */
  const foliage = document.getElementById('foliage');
  const W = 1440, H = 900;
  foliage.setAttribute('viewBox', `0 0 ${W} ${H}`);
  const leafColors = ['var(--leaf-1)', 'var(--leaf-2)', 'var(--leaf-3)', 'var(--leaf-4)'];

  function branch(x0, y0, x1, y1, dir, count, spread, pivotX, pivotY, dur) {
    const g = document.createElementNS(SVGNS, 'g');
    g.setAttribute('class', 'branch');
    g.style.transformOrigin = `${pivotX}px ${pivotY}px`;
    g.style.setProperty('--bd', dur + 's');
    const twig = document.createElementNS(SVGNS, 'path');
    const cx = (x0 + x1) / 2, cy = Math.min(y0, y1) + 40;
    twig.setAttribute('d', `M${x0} ${y0} Q${cx} ${cy} ${x1} ${y1}`);
    twig.setAttribute('fill', 'none');
    twig.setAttribute('stroke', '#3d2f1d');
    twig.setAttribute('stroke-width', '4');
    twig.setAttribute('opacity', '.75');
    g.appendChild(twig);
    for (let i = 0; i < count; i++) {
      const t = rnd();
      const bx = (1 - t) * (1 - t) * x0 + 2 * (1 - t) * t * cx + t * t * x1;
      const by = (1 - t) * (1 - t) * y0 + 2 * (1 - t) * t * cy + t * t * y1;
      const size = between(36, 78);
      const lx = bx + between(-spread, spread);
      const ly = by + between(-spread * .4, spread);
      const u = document.createElementNS(SVGNS, 'use');
      u.setAttribute('href', '#maple');
      u.setAttribute('x', lx - size / 2);
      u.setAttribute('y', ly - size / 2);
      u.setAttribute('width', size);
      u.setAttribute('height', size);
      u.setAttribute('transform', `rotate(${between(-60, 60) + dir * 20} ${lx} ${ly})`);
      u.style.fill = leafColors[Math.floor(rnd() * leafColors.length)];
      u.style.opacity = between(.78, 1).toFixed(2);
      g.appendChild(u);
    }
    foliage.appendChild(g);
  }
  // trái
  branch(-40, 30, 420, 120, 1, 70, 70, -40, 30, 7);
  branch(-30, 200, 260, 250, 1, 38, 55, -30, 200, 8.5);
  branch(80, -20, 520, 30, 1, 40, 50, 80, -20, 6.5);
  // phải
  branch(W + 40, 40, 1000, 140, -1, 70, 70, W + 40, 40, 7.5);
  branch(W + 30, 230, 1170, 300, -1, 36, 55, W + 30, 230, 9);
  branch(W - 60, -20, 920, 20, -1, 40, 50, W - 60, -20, 6);

  /* Chuông gió */
  const chimes = document.getElementById('chimes');
  const papers = ['#a9d3f0', '#f6c1c9', '#b6e3c4', '#d6c4f0', '#f7d2a6', '#bfe6ef', '#f3b8b0'];
  const motifs = ['#e05a7a', '#3c78c8', '#e88f2a', '#7a52c7', '#2f9e8f', '#d0443c'];
  const words = ['風', '涼', '夏', '鈴', '空', '夢', '和', '音'];
  // x (vw), dây dài (px), tỉ lệ, độ mờ
  const spots = [
    [5, 300, .95, 0], [15, 180, 1.05, 0], [24, 120, .8, 1.2], [29, 210, .7, 1.6],
    [70, 200, .7, 1.6], [76, 120, .85, 1], [86, 250, 1, 0], [95, 150, .9, 0],
  ];
  function makeFurin(container, [x, cord, s, blur], i) {
    const f = document.createElement('div');
    f.className = 'furin';
    const paper = papers[i % papers.length];
    const motif = motifs[i % motifs.length];
    f.style.cssText = [
      `--x:${x}vw`, `--cord:${cord}px`, `--s:${s}`,
      `--d:${between(3.2, 5.2).toFixed(2)}s`, `--delay:${(-between(0, 4)).toFixed(2)}s`,
      `--amp:${between(2, 4.5).toFixed(1)}deg`, `--td:${between(1.8, 3).toFixed(2)}s`,
      `--fd:${between(1.2, 2.2).toFixed(2)}s`, `--th:${Math.round(between(64, 92))}px`,
      `--gd:${(x / 100 * .9).toFixed(2)}s`, `--paper-c:${paper}`,
      blur ? `--blur:blur(${blur}px)` : '',
    ].join(';');
    if (x > 22 && x < 78) f.classList.add('inner');
    f.innerHTML = `
      <div class="sway"><div class="gust">
        <span class="cord"></span>
        <svg class="bell" viewBox="0 0 60 56" aria-hidden="true">
          <path d="M7 52 C6 22 16 6 30 6 C44 6 54 22 53 52 Z" fill="url(#g-glass)" stroke="rgba(255,255,255,.85)" stroke-width="1.2"/>
          <g fill="${motif}" opacity=".85">
            <circle cx="20" cy="34" r="3.2"/><circle cx="24.5" cy="31" r="3.2"/><circle cx="25" cy="37" r="3.2"/><circle cx="19.5" cy="39.5" r="3"/><circle cx="16.5" cy="35.5" r="3"/>
            <circle cx="39" cy="26" r="2.4"/><circle cx="42.5" cy="23.5" r="2.4"/><circle cx="43" cy="28.5" r="2.4"/><circle cx="38.6" cy="30.5" r="2.2"/>
          </g>
          <circle cx="21" cy="35.6" r="1.6" fill="#ffe27a"/><circle cx="40.7" cy="26.8" r="1.2" fill="#ffe27a"/>
          <path d="M14 46 Q22 44 30 47 T46 45" fill="none" stroke="${motif}" stroke-width="1.2" opacity=".5"/>
          <path d="M15 40 C15 22 22 12 28 10" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" opacity=".75"/>
          <ellipse cx="30" cy="52" rx="23" ry="3.4" fill="rgba(255,255,255,.55)" stroke="rgba(255,255,255,.9)" stroke-width="1"/>
          <rect x="27" y="2" width="6" height="5" rx="1.5" fill="#d8d1bb"/>
        </svg>
        <div class="tail">
          <span class="clapper"></span>
          <span class="line"></span>
          <div class="tanzaku"><span>${words[i % words.length]}</span></div>
        </div>
      </div></div>`;
    container.appendChild(f);
    return f;
  }
  spots.forEach((spot, i) => makeFurin(chimes, spot, i));
  // Trên điện thoại: hai chuông nhỏ treo trước khung tre để luôn nhìn thấy.
  const front = document.getElementById('chimesFront');
  if (front) [[3.4, 190, .55, 0], [96.6, 300, .55, 0]].forEach((spot, i) => makeFurin(front, spot, i + 1));

  // Ẩn bớt chuông ở giữa trên màn hình hẹp (thẻ che mất).
  const narrow = window.matchMedia('(max-width: 760px)');
  const applyNarrow = () => chimes.querySelectorAll('.furin.inner').forEach(el => { el.style.display = narrow.matches ? 'none' : ''; });
  applyNarrow();
  narrow.addEventListener('change', applyNarrow);

  /* Đom đóm (chỉ hiện ở giao diện tối) */
  const ff = document.getElementById('fireflies');
  for (let i = 0; i < 22; i++) {
    const s = document.createElement('span');
    s.style.cssText = `left:${between(2, 98)}%;top:${between(40, 95)}%;--t:${between(6, 12)}s;--dl:${-between(0, 8)}s;--dx:${between(-80, 80)}px;--dy:${between(-60, 40)}px`;
    ff.appendChild(s);
  }

  /* Lá rơi */
  const falling = document.getElementById('falling');
  function dropLeaf() {
    if (document.hidden || falling.childElementCount > 8) return;
    const svg = document.createElementNS(SVGNS, 'svg');
    svg.setAttribute('viewBox', '0 0 100 100');
    const u = document.createElementNS(SVGNS, 'use');
    u.setAttribute('href', '#maple');
    u.style.fill = leafColors[Math.floor(Math.random() * leafColors.length)];
    svg.appendChild(u);
    const size = 14 + Math.random() * 16;
    svg.style.cssText = `left:${Math.random() * 100}vw;width:${size}px;height:${size}px;--fd:${10 + Math.random() * 8}s;--dx:${(Math.random() * 2 - .6) * 220}px;--rot:${(Math.random() > .5 ? 1 : -1) * (360 + Math.random() * 540)}deg`;
    falling.appendChild(svg);
    svg.addEventListener('animationend', () => svg.remove());
  }

  /* Âm thanh chuông gió (tổng hợp bằng Web Audio, mặc định tắt) */
  let audio = null, soundOn = false;
  try { soundOn = localStorage.getItem('iema.sound') === '1'; } catch (e) { /* bỏ qua */ }
  function tinkle(when) {
    if (!audio) return;
    const base = [1568, 1760, 2093, 2349, 2637][Math.floor(Math.random() * 5)];
    const t0 = audio.currentTime + when;
    [1, 2.76, 5.4].forEach((mult, k) => {
      const o = audio.createOscillator();
      const g = audio.createGain();
      o.type = 'sine';
      o.frequency.value = base * mult;
      g.gain.setValueAtTime(0.0001, t0);
      g.gain.exponentialRampToValueAtTime([0.09, 0.035, 0.015][k], t0 + 0.006);
      g.gain.exponentialRampToValueAtTime(0.0001, t0 + [2.4, 1.2, 0.6][k]);
      o.connect(g).connect(audio.destination);
      o.start(t0);
      o.stop(t0 + 2.5);
    });
  }
  window.IemaScene = {
    get soundOn() { return soundOn; },
    setSound(on) {
      soundOn = on;
      try { localStorage.setItem('iema.sound', on ? '1' : '0'); } catch (e) { /* bỏ qua */ }
      if (on) {
        if (!audio) {
          const AC = window.AudioContext || window.webkitAudioContext;
          if (AC) audio = new AC();
        }
        if (audio && audio.state === 'suspended') audio.resume();
        tinkle(0); tinkle(0.25);
      }
    },
    gust,
  };

  /* Gió thổi */
  let gustTimer = null;
  function gust() {
    if (reduceMotion) return;
    const body = document.body;
    body.classList.remove('gust');
    void body.offsetWidth; // khởi động lại animation
    body.classList.add('gust');
    clearTimeout(gustTimer);
    gustTimer = setTimeout(() => body.classList.remove('gust'), 4800);
    for (let i = 0; i < 3; i++) setTimeout(dropLeaf, i * 500 + Math.random() * 600);
    if (soundOn && audio) {
      const n = 3 + Math.floor(Math.random() * 4);
      for (let i = 0; i < n; i++) tinkle(0.15 + Math.random() * 1.6);
    }
  }
  function scheduleGust() {
    setTimeout(() => { if (!document.hidden) gust(); scheduleGust(); }, 7000 + Math.random() * 9000);
  }
  if (!reduceMotion) {
    setTimeout(gust, 1800);
    scheduleGust();
    setInterval(dropLeaf, 3800);
  }
})();
