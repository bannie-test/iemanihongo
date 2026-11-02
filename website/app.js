/* Iemanihongo · thẻ từ vựng theo chủ đề và từ vựng mỗi ngày. Không cần tài khoản. */
(function () {
  'use strict';

  const TOPICS = window.TOPICS;
  const WORDS = window.WORDS;
  const STROKES = window.STROKES || {};
  const KANJI = window.KANJI || {};
  const topicById = Object.fromEntries(TOPICS.map(t => [t.id, t]));
  const $ = id => document.getElementById(id);

  /* ───────────── Lưu trữ trên trình duyệt (không bắt buộc) ───────────── */
  const store = {
    get(key, fallback) {
      try { const v = localStorage.getItem('iema.' + key); return v === null ? fallback : JSON.parse(v); } catch (e) { return fallback; }
    },
    set(key, value) {
      try { localStorage.setItem('iema.' + key, JSON.stringify(value)); } catch (e) { /* bỏ qua */ }
    },
  };
  const favs = new Set(store.get('favs', []));

  /* ───────────── Kana & rōmaji ───────────── */
  const toKatakana = s => s.replace(/[ぁ-ゖ]/g, c => String.fromCharCode(c.charCodeAt(0) + 0x60));
  const ROMA = {
    あ: 'a', い: 'i', う: 'u', え: 'e', お: 'o', か: 'ka', き: 'ki', く: 'ku', け: 'ke', こ: 'ko',
    さ: 'sa', し: 'shi', す: 'su', せ: 'se', そ: 'so', た: 'ta', ち: 'chi', つ: 'tsu', て: 'te', と: 'to',
    な: 'na', に: 'ni', ぬ: 'nu', ね: 'ne', の: 'no', は: 'ha', ひ: 'hi', ふ: 'fu', へ: 'he', ほ: 'ho',
    ま: 'ma', み: 'mi', む: 'mu', め: 'me', も: 'mo', や: 'ya', ゆ: 'yu', よ: 'yo',
    ら: 'ra', り: 'ri', る: 'ru', れ: 're', ろ: 'ro', わ: 'wa', を: 'o', ん: 'n',
    が: 'ga', ぎ: 'gi', ぐ: 'gu', げ: 'ge', ご: 'go', ざ: 'za', じ: 'ji', ず: 'zu', ぜ: 'ze', ぞ: 'zo',
    だ: 'da', ぢ: 'ji', づ: 'zu', で: 'de', ど: 'do', ば: 'ba', び: 'bi', ぶ: 'bu', べ: 'be', ぼ: 'bo',
    ぱ: 'pa', ぴ: 'pi', ぷ: 'pu', ぺ: 'pe', ぽ: 'po', ぁ: 'a', ぃ: 'i', ぅ: 'u', ぇ: 'e', ぉ: 'o',
  };
  const SMALL_Y = { ゃ: 'a', ゅ: 'u', ょ: 'o' };
  function romaji(kana) {
    let out = '';
    for (let i = 0; i < kana.length; i++) {
      const c = kana[i];
      if (c === 'っ') {
        const next = romaji(kana.slice(i + 1, i + 3)).charAt(0);
        out += next === 'c' ? 't' : next;
        continue;
      }
      let r = ROMA[c];
      if (r === undefined) { out += c; continue; }
      const n = kana[i + 1];
      if (SMALL_Y[n]) {
        const stem = r.slice(0, -1);
        r = (stem === 'sh' || stem === 'ch' || stem === 'j') ? stem + SMALL_Y[n] : stem + 'y' + SMALL_Y[n];
        i++;
      }
      if (c === 'ん' && /^[aiueoy]/.test(romaji(kana.slice(i + 1, i + 2)))) r = "n'";
      out += r;
    }
    return out;
  }

  /* ───────────── Trạng thái ───────────── */
  const state = {
    mode: 'cards',
    topic: store.get('topic', 'all'),
    shuffle: store.get('shuffle', false),
    order: [],
    pos: 0,
    flipped: false,
    hint: false,
    tab: 'mean',
    dailyIdx: 0,
    isToday: true,
    current: null,
  };
  if (state.topic !== 'all' && state.topic !== 'fav' && !topicById[state.topic]) state.topic = 'all';

  function wordsForTopic(topic) {
    if (topic === 'all') return WORDS.map((_, i) => i);
    if (topic === 'fav') return WORDS.map((w, i) => (favs.has(w.id) ? i : -1)).filter(i => i >= 0);
    return WORDS.map((w, i) => (w.t === topic ? i : -1)).filter(i => i >= 0);
  }
  function shuffled(arr) {
    const a = arr.slice();
    for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(Math.random() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; }
    return a;
  }
  function buildOrder(keepId) {
    const base = wordsForTopic(state.topic);
    state.order = state.shuffle ? shuffled(base) : base;
    const at = keepId ? state.order.findIndex(i => WORDS[i].id === keepId) : -1;
    state.pos = at >= 0 ? at : 0;
  }

  /* Từ của hôm nay: chọn theo ngày, giống nhau cho mọi người trong cùng một ngày. */
  function todayKey(d = new Date()) {
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
  }
  function dailyIndex(key) {
    let h = 2166136261;
    for (const ch of 'iemanihongo:' + key) { h ^= ch.charCodeAt(0); h = Math.imul(h, 16777619); }
    return (h >>> 0) % WORDS.length;
  }

  /* ───────────── Mẫu HTML ───────────── */
  const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  // Bọc các đoạn chữ Nhật bằng font tiếng Nhật.
  const jp = s => esc(s).replace(/([　-ヿ㐀-鿿！-｠々〆〜ー・]+)/g, '<span class="jp-inline" lang="ja">$1</span>');
  const CHEV = '<svg class="chev" viewBox="0 0 24 24" aria-hidden="true"><path d="M6 9l6 6 6-6"/></svg>';

  function section(icon, title, body, open, badge) {
    return `<details class="sec"${open ? ' open' : ''}>
      <summary><span class="ico" aria-hidden="true">${icon}</span>${title}${badge ? ` <span class="badge">${badge}</span>` : ''}${CHEV}</summary>
      <div class="body">${body}</div>
    </details>`;
  }

  function meaningPanel(w) {
    let html = '';
    html += section('義', 'Định nghĩa',
      `<ol>${w.def.map(d => `<li>${jp(d)}</li>`).join('')}</ol>`, true, esc(w.pos));
    if (w.use && w.use.length) {
      html += section('法', 'Cách dùng', `<ul>${w.use.map(u => `<li>${jp(u)}</li>`).join('')}</ul>`, false);
    }
    if (w.ex && w.ex.length) {
      html += section('例', 'Ví dụ',
        w.ex.map(([j, v]) => `<p class="ex"><span class="jp" lang="ja">${esc(j)}</span><br><span class="vi">${esc(v)}</span></p>`).join(''), false);
    }
    if (w.q) {
      const lines = w.q.t.split('\n');
      const stagger = lines.every(l => l.length <= 9);
      const cols = lines.map((l, i) => `<span style="--i:${stagger ? [0, 1, 2, 1, 2][i % 5] : 0}">${esc(l)}</span>`).join('');
      html += section('詩', 'Trích dẫn văn thơ', `
        <div class="quote"><p class="tategaki" lang="ja">${cols}</p><span class="seal" lang="ja">${stagger ? '詩歌' : '古典'}</span></div>
        <div class="quote-meta"><b>${esc(w.q.a)}</b> · ${jp(w.q.s)}</div>
        <div class="quote-vi">“${esc(w.q.vi)}”</div>
        ${w.q.note ? `<div class="quote-note">${jp(w.q.note)}</div>` : ''}`, false, 'chữ dọc');
    }
    return html;
  }

  function strokeBox(ch) {
    const d = STROKES[ch];
    if (!d) return `<div class="box fallback" lang="ja" aria-label="${esc(ch)}">${esc(ch)}</div>`;
    const guide = d.p.map(p => `<path d="${p}"/>`).join('');
    const ink = d.p.map(p => `<path d="${p}" pathLength="1"/>`).join('');
    const nums = (d.n || []).map(([x, y], i) => `<text class="num" x="${x}" y="${y}">${i + 1}</text>`).join('');
    return `<div class="box" role="img" aria-label="${esc(ch)}, ${d.p.length} nét">
      <svg viewBox="0 0 109 109"><g class="guide">${guide}</g><g class="ink">${ink}</g><g>${nums}</g></svg>
      <span class="count">${d.p.length} nét</span></div>`;
  }

  const PLAY = '<svg viewBox="0 0 12 12" aria-hidden="true"><path d="M3 1.5v9l7.5-4.5z"/></svg>';
  function formBlock(label, sub, text) {
    return `<div class="form">
      <div class="form-head">
        <span class="form-label">${label}<small>${sub}</small></span>
        <button class="play" data-play>${PLAY}Thứ tự nét</button>
        <span class="form-text" lang="ja">${esc(text)}</span>
      </div>
      <div class="boxes">${Array.from(text).map(strokeBox).join('')}</div>
    </div>`;
  }

  function writingPanel(w) {
    const kata = toKatakana(w.r);
    const hasKanji = /[㐀-鿿]/.test(w.w);
    let html = '<div class="forms">';
    html += formBlock(hasKanji ? 'Kanji' : 'Chữ thường dùng', hasKanji ? '漢字' : '', w.w);
    html += formBlock('Hiragana', 'ひらがな', w.r);
    html += formBlock('Katakana', 'カタカナ', kata);
    html += '</div>';
    html += `<div class="romaji-line">Rōmaji: <b>${esc(romaji(w.r))}</b></div>`;
    const kanjiChars = Array.from(new Set(Array.from(w.w).filter(c => /[㐀-鿿]/.test(c))));
    if (kanjiChars.length) {
      html += '<div class="subhead">Chữ Hán trong từ</div><div class="kanji-list">';
      kanjiChars.forEach(c => {
        const k = KANJI[c];
        const strokes = STROKES[c] ? STROKES[c].p.length : (k && k.s);
        html += `<div class="kanji-item"><span class="big" lang="ja">${esc(c)}</span><div>`;
        if (k) {
          html += `<div><span class="hv">${esc(k.hv)}</span>${strokes ? ` · <span class="km">${strokes} nét</span>` : ''}</div>`;
          html += `<div class="km">${esc(k.m)}</div>`;
          const on = (k.on || []).slice(0, 3).map(toKatakana).join('、');
          const kun = (k.kun || []).slice(0, 3).join('、');
          html += `<div class="rd">${on ? `Âm On: <span class="jp-inline">${esc(on)}</span>` : ''}${on && kun ? ' · ' : ''}${kun ? `Âm Kun: <span class="jp-inline">${esc(kun)}</span>` : ''}</div>`;
        } else {
          html += `<div>${strokes ? `<span class="km">${strokes} nét</span>` : ''}</div><div class="km">Chữ Hán ít gặp (ngoài bảng thường dụng).</div>`;
        }
        html += '</div></div>';
      });
      html += '</div>';
    }
    return html;
  }

  function playStrokes(form) {
    let delay = 0;
    form.querySelectorAll('.box').forEach(box => {
      box.classList.add('numbers');
      box.querySelectorAll('.ink path').forEach(p => {
        p.classList.remove('anim');
        void p.getBoundingClientRect();
        const len = 0.38;
        p.style.setProperty('--sd', len + 's');
        p.style.setProperty('--sdl', delay + 's');
        p.classList.add('anim');
        delay += len + 0.12;
      });
      delay += 0.25;
    });
  }

  /* ───────────── Hiển thị ───────────── */
  function topicLabel(w) {
    const t = topicById[w.t];
    return `<span class="jp" lang="ja">${esc(t.jp)}</span>${esc(t.vi)}`;
  }

  function renderFront(w) {
    $('frontTopic').innerHTML = topicLabel(w);
    const fw = $('frontWord');
    fw.textContent = w.w;
    fw.className = 'front-word' + (w.w.length >= 3 ? ' len-' + Math.min(w.w.length, 5) : '');
    $('hintKana').textContent = w.r;
    $('hintRomaji').textContent = romaji(w.r);
    $('favMark').hidden = !favs.has(w.id);
  }
  function renderBack(w) {
    $('backWord').textContent = w.w;
    $('backReading').textContent = w.r === w.w ? '' : w.r;
    $('backMeaning').innerHTML = `${esc(w.m)}${w.hv ? `<small>Hán Việt: ${esc(w.hv)}</small>` : ''}`;
    $('panel-mean').innerHTML = meaningPanel(w);
    $('panel-write').innerHTML = writingPanel(w);
    $('panel-mean').scrollTop = 0;
    $('panel-write').scrollTop = 0;
  }
  function renderEmpty() {
    $('frontTopic').innerHTML = '<span class="jp" lang="ja">星</span>Yêu thích';
    const fw = $('frontWord');
    fw.className = 'front-word';
    fw.innerHTML = '<div class="empty"><div class="big">☆</div><div>Chưa có từ yêu thích nào.<br>Nhấn <b>Yêu thích</b> ở một thẻ bất kỳ để lưu lại.</div></div>';
    $('hintKana').textContent = '';
    $('hintRomaji').textContent = '';
    $('favMark').hidden = true;
  }

  let swapToken = 0;
  function show(w, animate = true) {
    const card = $('card');
    const wasFlipped = state.flipped;
    state.current = w;
    setFlipped(false);
    setHint(false);
    const token = ++swapToken;
    const apply = () => {
      if (token !== swapToken) return;
      if (w) { renderFront(w); } else { renderEmpty(); }
    };
    const applyBack = () => { if (token === swapToken && w) renderBack(w); };
    if (wasFlipped) {
      apply();
      setTimeout(applyBack, 420); // đợi mặt sau quay khuất rồi mới đổi nội dung
    } else if (animate) {
      card.classList.remove('swap');
      void card.offsetWidth;
      card.classList.add('swap');
      setTimeout(() => { apply(); applyBack(); }, 180);
    } else {
      apply(); applyBack();
    }
    updateControls();
  }

  function setFlipped(on) {
    if (on && !state.current) return;
    state.flipped = on;
    $('card').classList.toggle('flipped', on);
    $('front').setAttribute('aria-hidden', on ? 'true' : 'false');
    $('back').setAttribute('aria-hidden', on ? 'false' : 'true');
    $('front').tabIndex = on ? -1 : 0;
  }
  function setHint(on) {
    state.hint = on && !!state.current;
    $('hint').classList.toggle('show', state.hint);
    $('hintBtn').setAttribute('aria-pressed', String(state.hint));
  }
  function setTab(tab) {
    state.tab = tab;
    ['mean', 'write'].forEach(t => {
      const on = t === tab;
      $('tab-' + t).setAttribute('aria-selected', String(on));
      $('tab-' + t).tabIndex = on ? 0 : -1;
      $('panel-' + t).hidden = !on;
    });
  }

  function updateControls() {
    const w = state.current;
    const isFav = !!w && favs.has(w.id);
    $('favBtn').setAttribute('aria-pressed', String(isFav));
    $('favBtn').querySelector('span').textContent = isFav ? 'Đã thích' : 'Yêu thích';
    $('favBtn').disabled = !w;
    $('hintBtn').disabled = !w;
    if (w) $('favMark').hidden = !isFav;

    if (state.mode === 'cards') {
      const n = state.order.length;
      $('prevBtn').disabled = n < 2;
      $('nextBtn').disabled = n < 2;
      const pct = n ? ((state.pos + 1) / n) * 100 : 0;
      $('progress').innerHTML = n
        ? `<span>Thẻ ${state.pos + 1} / ${n}</span><span class="bar"><i style="width:${pct}%"></i></span>
           <button id="shuffleBtn" aria-pressed="${state.shuffle}" title="Trộn ngẫu nhiên thứ tự thẻ">Trộn thẻ</button>`
        : '';
      const sb = $('shuffleBtn');
      if (sb) sb.onclick = () => { state.shuffle = !state.shuffle; store.set('shuffle', state.shuffle); buildOrder(state.current && state.current.id); show(WORDS[state.order[state.pos]]); };
    }
    renderChips();
  }

  function renderChips() {
    const items = [{ id: 'all', jp: '全部', vi: 'Tất cả', n: WORDS.length }]
      .concat(TOPICS.map(t => ({ id: t.id, jp: t.jp, vi: t.vi, n: WORDS.filter(w => w.t === t.id).length })))
      .concat([{ id: 'fav', jp: '★', vi: 'Yêu thích', n: favs.size }]);
    $('chips').innerHTML = items.map(it =>
      `<button class="chip" role="tab" data-topic="${it.id}" aria-selected="${it.id === state.topic}">
         <span class="jp" lang="ja">${esc(it.jp)}</span>${esc(it.vi)} <span class="count">${it.n}</span></button>`).join('');
  }

  /* ───────────── Hai chế độ ───────────── */
  function setMode(mode, push = true) {
    state.mode = mode;
    document.querySelectorAll('.nav-btn').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.mode === mode)));
    const daily = mode === 'daily';
    document.body.classList.toggle('is-daily', daily);
    $('toolbar').hidden = daily;
    $('dailyHead').hidden = !daily;
    $('randomZone').hidden = !daily;
    $('progress').hidden = daily;
    $('prevBtn').hidden = daily;
    $('nextBtn').hidden = daily;
    if (push) {
      const hash = daily ? '#moi-ngay' : '';
      if (location.hash !== hash) history.replaceState(null, '', location.pathname + location.search + hash);
    }
    if (daily) {
      showToday();
    } else {
      buildOrder(store.get('lastId', null));
      show(state.order.length ? WORDS[state.order[state.pos]] : null);
    }
  }

  function showToday() {
    const now = new Date();
    state.dailyIdx = dailyIndex(todayKey(now));
    state.isToday = true;
    $('dailyDate').textContent = now.toLocaleDateString('vi-VN', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' });
    $('todayBtn').hidden = true;
    document.querySelector('.daily-kicker').textContent = 'Từ vựng hôm nay';
    show(WORDS[state.dailyIdx]);
  }
  function showRandom() {
    let i;
    do { i = Math.floor(Math.random() * WORDS.length); } while (WORDS.length > 1 && WORDS[i] === state.current);
    state.isToday = false;
    $('todayBtn').hidden = false;
    document.querySelector('.daily-kicker').textContent = 'Từ ngẫu nhiên';
    if (window.IemaScene) window.IemaScene.gust();
    show(WORDS[i]);
  }

  function step(delta) {
    if (state.mode !== 'cards' || state.order.length < 2) return;
    state.pos = (state.pos + delta + state.order.length) % state.order.length;
    const w = WORDS[state.order[state.pos]];
    store.set('lastId', w.id);
    show(w);
  }

  function toggleFav() {
    const w = state.current;
    if (!w) return;
    if (favs.has(w.id)) favs.delete(w.id); else favs.add(w.id);
    store.set('favs', Array.from(favs));
    updateControls();
    if (state.mode === 'cards' && state.topic === 'fav' && !favs.has(w.id)) {
      // Bỏ thích khi đang xem danh sách yêu thích: chuyển sang thẻ khác.
      buildOrder();
      state.pos = Math.min(state.pos, Math.max(state.order.length - 1, 0));
      show(state.order.length ? WORDS[state.order[state.pos]] : null);
    }
  }

  /* ───────────── Phát âm ───────────── */
  const canSpeak = 'speechSynthesis' in window;
  function speak() {
    const w = state.current;
    if (!w || !canSpeak) return;
    speechSynthesis.cancel();
    const u = new SpeechSynthesisUtterance(w.r);
    u.lang = 'ja-JP';
    u.rate = 0.85;
    const voice = speechSynthesis.getVoices().find(v => /^ja/i.test(v.lang));
    if (voice) u.voice = voice;
    speechSynthesis.speak(u);
  }
  if (!canSpeak) document.querySelectorAll('[data-speak]').forEach(b => { b.hidden = true; });

  /* ───────────── Sự kiện ───────────── */
  document.querySelectorAll('.nav-btn').forEach(b => b.addEventListener('click', () => setMode(b.dataset.mode)));
  $('brand').addEventListener('click', e => { e.preventDefault(); setMode('cards'); });
  $('chips').addEventListener('click', e => {
    const chip = e.target.closest('.chip');
    if (!chip) return;
    state.topic = chip.dataset.topic;
    store.set('topic', state.topic);
    buildOrder();
    if (state.order.length) store.set('lastId', WORDS[state.order[0]].id);
    show(state.order.length ? WORDS[state.order[0]] : null);
    chip.scrollIntoView({ block: 'nearest', inline: 'center', behavior: 'smooth' });
  });

  $('front').addEventListener('click', e => {
    if (e.target.closest('button')) return;
    setFlipped(true);
  });
  $('front').addEventListener('keydown', e => {
    if ((e.key === 'Enter' || e.key === ' ') && e.target === $('front')) { e.preventDefault(); setFlipped(true); }
  });
  $('flipBack').addEventListener('click', () => { setFlipped(false); $('front').focus({ preventScroll: true }); });
  document.querySelectorAll('[data-speak]').forEach(b => b.addEventListener('click', e => { e.stopPropagation(); speak(); }));

  $('tab-mean').addEventListener('click', () => setTab('mean'));
  $('tab-write').addEventListener('click', () => setTab('write'));
  document.querySelector('.tabs').addEventListener('keydown', e => {
    if (e.key === 'ArrowRight' || e.key === 'ArrowLeft') {
      e.preventDefault();
      e.stopPropagation();
      const next = state.tab === 'mean' ? 'write' : 'mean';
      setTab(next);
      $('tab-' + next).focus();
    }
  });
  $('panel-write').addEventListener('click', e => {
    const btn = e.target.closest('[data-play]');
    if (btn) playStrokes(btn.closest('.form'));
  });

  $('prevBtn').addEventListener('click', () => step(-1));
  $('nextBtn').addEventListener('click', () => step(1));
  $('hintBtn').addEventListener('click', () => { if (state.flipped) setFlipped(false); setHint(!state.hint); });
  $('favBtn').addEventListener('click', toggleFav);
  $('randomBtn').addEventListener('click', showRandom);
  $('todayBtn').addEventListener('click', showToday);

  const soundBtn = $('soundBtn');
  const syncSound = () => {
    const on = !!(window.IemaScene && window.IemaScene.soundOn);
    soundBtn.setAttribute('aria-pressed', String(on));
    soundBtn.title = on ? 'Tắt tiếng chuông gió' : 'Bật tiếng chuông gió';
    soundBtn.setAttribute('aria-label', soundBtn.title);
  };
  soundBtn.addEventListener('click', () => {
    if (!window.IemaScene) return;
    window.IemaScene.setSound(!window.IemaScene.soundOn);
    syncSound();
  });
  syncSound();

  document.addEventListener('keydown', e => {
    if (e.altKey || e.ctrlKey || e.metaKey) return;
    const tag = (e.target.tagName || '').toLowerCase();
    if (tag === 'input' || tag === 'textarea') return;
    const onButton = tag === 'button' || tag === 'summary';
    switch (e.key) {
      case 'ArrowRight': if (state.mode === 'cards') step(1); else showRandom(); break;
      case 'ArrowLeft': if (state.mode === 'cards') step(-1); break;
      case ' ': case 'Enter':
        if (onButton || e.target === $('front')) return;
        e.preventDefault(); setFlipped(!state.flipped); break;
      case 'h': case 'H': setHint(!state.hint); break;
      case 'f': case 'F': toggleFav(); break;
      default: return;
    }
  });

  // Vuốt trái/phải trên điện thoại để chuyển thẻ.
  let touch = null;
  $('card').addEventListener('touchstart', e => { const t = e.touches[0]; touch = { x: t.clientX, y: t.clientY }; }, { passive: true });
  $('card').addEventListener('touchend', e => {
    if (!touch) return;
    const t = e.changedTouches[0];
    const dx = t.clientX - touch.x, dy = t.clientY - touch.y;
    touch = null;
    if (Math.abs(dx) < 60 || Math.abs(dx) < Math.abs(dy) * 1.5) return;
    if (state.mode === 'cards') step(dx < 0 ? 1 : -1); else if (dx < 0) showRandom();
  }, { passive: true });

  window.addEventListener('hashchange', () => setMode(location.hash === '#moi-ngay' ? 'daily' : 'cards', false));

  /* ───────────── Khởi động ───────────── */
  setTab('mean');
  setMode(location.hash === '#moi-ngay' ? 'daily' : 'cards', false);
})();
