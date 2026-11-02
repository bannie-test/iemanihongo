/*
 * Từ vựng theo chủ đề cho trang web Iemanihongo.
 *
 * Mỗi từ:
 *   w   – cách viết thông dụng (kanji hoặc kana)
 *   r   – cách đọc bằng hiragana (katakana và rōmaji được suy ra tự động)
 *   m   – nghĩa ngắn tiếng Việt
 *   hv  – âm Hán Việt (nếu có)
 *   pos – từ loại
 *   def – các định nghĩa
 *   use – chú thích cách dùng
 *   ex  – ví dụ [câu tiếng Nhật, nghĩa tiếng Việt]
 *   q   – trích dẫn văn thơ (hiển thị chữ dọc): t = nguyên văn ("\n" = sang cột mới),
 *         a = tác giả, s = nguồn, vi = bản dịch tiếng Việt, note = ghi chú
 */
window.TOPICS = [
  { id: 'nature',  jp: '自然',   vi: 'Thiên nhiên' },
  { id: 'seasons', jp: '四季',   vi: 'Bốn mùa' },
  { id: 'weather', jp: '天気',   vi: 'Thời tiết' },
  { id: 'animals', jp: '動物',   vi: 'Động vật' },
  { id: 'plants',  jp: '草木',   vi: 'Cây cỏ & hoa' },
  { id: 'family',  jp: '家族',   vi: 'Gia đình' },
  { id: 'food',    jp: '食',     vi: 'Ẩm thực' },
  { id: 'heart',   jp: '心',     vi: 'Cảm xúc' },
  { id: 'travel',  jp: '旅',     vi: 'Du lịch' },
];

window.WORDS = [
  /* ───────────── 自然 · Thiên nhiên ───────────── */
  {
    id: 'shizen', t: 'nature', w: '自然', r: 'しぜん', m: 'Thiên nhiên', hv: 'Tự nhiên', pos: 'Danh từ; tính từ đuôi な',
    def: [
      'Thế giới tự nhiên: núi sông, cây cỏ, cảnh vật không do con người tạo ra.',
      'Tự nhiên, không gượng ép (khi dùng như tính từ: 自然な).',
      'Tự phát, tự nó xảy ra (自然に = một cách tự nhiên).',
    ],
    use: [
      '自然 + の + danh từ: 自然の美しさ (vẻ đẹp của thiên nhiên).',
      '自然な + danh từ: 自然な日本語 (tiếng Nhật tự nhiên). 自然に + động từ: 自然に笑う (cười một cách tự nhiên).',
      'Từ ghép thường gặp: 自然保護 (bảo vệ thiên nhiên), 大自然 (thiên nhiên hùng vĩ), 不自然 (gượng gạo).',
    ],
    ex: [
      ['この村は自然が豊かです。', 'Ngôi làng này có thiên nhiên phong phú.'],
      ['もっと自然に話してください。', 'Hãy nói chuyện tự nhiên hơn.'],
    ],
  },
  {
    id: 'yama', t: 'nature', w: '山', r: 'やま', m: 'Núi', hv: 'Sơn', pos: 'Danh từ',
    def: ['Núi, đồi cao.', 'Một đống lớn, chồng chất (山のような宿題 = bài tập chất như núi).', 'Đỉnh điểm, cao trào (山場).'],
    use: [
      'Đếm núi: 一つの山, nhưng tên núi dùng âm On: 富士山 (ふじさん), 浅間山.',
      '山に登る: leo núi (trợ từ に chỉ đích đến).',
    ],
    ex: [
      ['週末、友達と山に登りました。', 'Cuối tuần tôi đã leo núi cùng bạn.'],
      ['机の上に本が山のようにある。', 'Trên bàn sách chất cao như núi.'],
    ],
    q: {
      t: '田子の浦に\nうち出でてみれば\n白妙の\n富士の高嶺に\n雪は降りつつ',
      a: 'Yamabe no Akahito (山部赤人)', s: 'Hyakunin Isshu, bài 4',
      vi: 'Ra đến bờ Tago, ngước nhìn — trên đỉnh Phú Sĩ trắng tinh, tuyết vẫn đang rơi mãi.',
    },
  },
  {
    id: 'kawa', t: 'nature', w: '川', r: 'かわ', m: 'Sông, suối', hv: 'Xuyên', pos: 'Danh từ',
    def: ['Dòng nước chảy tự nhiên trên mặt đất: sông, suối.'],
    use: [
      'Khi đứng sau tên riêng thường đọc がわ: 隅田川 (すみだがわ), 鴨川 (かもがわ).',
      '河 cũng đọc là かわ nhưng chỉ sông lớn; 川 là cách viết thông dụng.',
    ],
    ex: [
      ['川で魚を釣りました。', 'Tôi đã câu cá ở sông.'],
      ['川沿いの道を散歩する。', 'Đi dạo trên con đường dọc bờ sông.'],
    ],
    q: {
      t: 'ゆく河の流れは絶えずして、\nしかももとの水にあらず。',
      a: 'Kamo no Chōmei (鴨長明)', s: 'Phương Trượng Ký (方丈記), 1212',
      vi: 'Dòng sông trôi mãi không ngừng, mà nước kia đâu còn là nước cũ.',
      note: 'Câu mở đầu nổi tiếng nói về lẽ vô thường.',
    },
  },
  {
    id: 'mori', t: 'nature', w: '森', r: 'もり', m: 'Rừng', hv: 'Sâm', pos: 'Danh từ',
    def: ['Khu rừng rậm, nơi cây cối mọc um tùm.', 'Khu rừng thiêng quanh đền thần (鎮守の森).'],
    use: [
      '森 (もり) là rừng rậm, sâu; 林 (はやし) là rừng thưa, lùm cây.',
      'Chữ 森 gồm ba chữ 木 (cây) — nhiều cây hợp thành rừng.',
    ],
    ex: [
      ['森の中は涼しくて静かだ。', 'Trong rừng mát mẻ và yên tĩnh.'],
      ['森で道に迷った。', 'Tôi bị lạc đường trong rừng.'],
    ],
  },
  {
    id: 'umi', t: 'nature', w: '海', r: 'うみ', m: 'Biển', hv: 'Hải', pos: 'Danh từ',
    def: ['Biển, vùng nước mặn rộng lớn.', 'Một vùng mênh mông (火の海 = biển lửa).'],
    use: ['海へ行く / 海に行く: đi biển.', 'Từ ghép: 海辺 (うみべ, bờ biển), 海外 (かいがい, nước ngoài).'],
    ex: [
      ['夏休みに家族で海へ行きました。', 'Kỳ nghỉ hè cả nhà tôi đã đi biển.'],
      ['海の色がとてもきれいです。', 'Màu biển rất đẹp.'],
    ],
    q: {
      t: '春の海\n終日のたり\nのたりかな',
      a: 'Yosa Buson (与謝蕪村)', s: 'Haiku',
      vi: 'Biển mùa xuân — suốt ngày dài sóng lững lờ, lững lờ.',
    },
  },
  {
    id: 'sora', t: 'nature', w: '空', r: 'そら', m: 'Bầu trời', hv: 'Không', pos: 'Danh từ',
    def: ['Bầu trời.', 'Thời tiết, khí trời (空模様).', 'Thuộc lòng (空で言う = đọc thuộc lòng).'],
    use: [
      'Chữ 空 còn đọc là から (rỗng: 空の箱) và あく/あける (trống, bỏ trống).',
      '空を見上げる: ngước nhìn bầu trời.',
    ],
    ex: [
      ['今日は空が青くて気持ちがいい。', 'Hôm nay trời xanh, thật dễ chịu.'],
      ['空に雲ひとつない。', 'Trên trời không một gợn mây.'],
    ],
  },
  {
    id: 'kaze', t: 'nature', w: '風', r: 'かぜ', m: 'Gió', hv: 'Phong', pos: 'Danh từ',
    def: ['Gió.', 'Phong cách, dáng vẻ (đọc ふう: 日本風 = kiểu Nhật).'],
    use: [
      '風が吹く: gió thổi. 風が強い/弱い: gió mạnh/nhẹ.',
      'Đừng nhầm với 風邪 (かぜ): cảm lạnh — cùng cách đọc.',
      '風鈴 (ふうりん): chuông gió treo hiên nhà mùa hè.',
    ],
    ex: [
      ['窓を開けると涼しい風が入ってきた。', 'Mở cửa sổ ra là gió mát lùa vào.'],
      ['風鈴が風に揺れている。', 'Chiếc chuông gió đang đung đưa trong gió.'],
    ],
    q: {
      t: '秋来ぬと\n目にはさやかに\n見えねども\n風の音にぞ\nおどろかれぬる',
      a: 'Fujiwara no Toshiyuki (藤原敏行)', s: 'Cổ Kim Tập (古今和歌集), bài 169',
      vi: 'Thu đã sang chăng — mắt nhìn chưa thấy rõ ràng, mà giật mình nghe tiếng gió.',
    },
  },
  {
    id: 'tsuki', t: 'nature', w: '月', r: 'つき', m: 'Mặt trăng; tháng', hv: 'Nguyệt', pos: 'Danh từ',
    def: ['Mặt trăng.', 'Tháng (đọc がつ/げつ trong từ ghép: 一月, 月曜日).'],
    use: ['月見 (つきみ): ngắm trăng rằm tháng 8 âm lịch.', '満月 (まんげつ): trăng tròn; 三日月 (みかづき): trăng lưỡi liềm.'],
    ex: [
      ['今夜は月がきれいですね。', 'Đêm nay trăng đẹp nhỉ.'],
      ['月に一度、実家に帰ります。', 'Mỗi tháng một lần tôi về nhà bố mẹ.'],
    ],
    q: {
      t: '天の原\nふりさけ見れば\n春日なる\n三笠の山に\n出でし月かも',
      a: 'Abe no Nakamaro (阿倍仲麻呂)', s: 'Hyakunin Isshu, bài 7',
      vi: 'Ngửa trông trời rộng — phải chăng vầng trăng ấy, trăng từng mọc trên núi Mikasa ở Kasuga quê nhà.',
      note: 'Abe no Nakamaro từng làm quan nhà Đường và giữ chức An Nam đô hộ ở Việt Nam.',
    },
  },
  {
    id: 'hoshi', t: 'nature', w: '星', r: 'ほし', m: 'Ngôi sao', hv: 'Tinh', pos: 'Danh từ',
    def: ['Ngôi sao.', 'Dấu sao, điểm số (星三つ = ba sao).', 'Người nổi bật, ngôi sao (希望の星).'],
    use: ['流れ星 (ながれぼし): sao băng. 天の川 (あまのがわ): dải Ngân Hà.', 'Lễ Thất Tịch 七夕 (たなばた) gắn với hai vì sao Ngưu Lang – Chức Nữ.'],
    ex: [
      ['田舎では星がよく見える。', 'Ở quê nhìn thấy sao rất rõ.'],
      ['流れ星に願いごとをした。', 'Tôi đã ước nguyện với sao băng.'],
    ],
    q: {
      t: '荒海や\n佐渡によこたふ\n天河',
      a: 'Matsuo Bashō (松尾芭蕉)', s: 'Áo Chi Tế Đạo (おくのほそ道)',
      vi: 'Biển động dữ — vắt ngang trên đảo Sado, dải Ngân Hà.',
    },
  },
  {
    id: 'ishi', t: 'nature', w: '石', r: 'いし', m: 'Hòn đá', hv: 'Thạch', pos: 'Danh từ',
    def: ['Hòn đá, viên sỏi.', 'Đá quý (宝石 = ほうせき).'],
    use: ['石の上にも三年: “ngồi trên đá ba năm đá cũng ấm” — kiên trì thì sẽ thành công.', 'Trong vườn Nhật, đá (石灯籠 = đèn đá, 飛び石 = đá bước) là phần không thể thiếu.'],
    ex: [
      ['庭に大きな石がある。', 'Trong vườn có một tảng đá lớn.'],
      ['石の上にも三年と言うでしょう。', 'Người ta vẫn nói “kiên trì ắt thành” đấy thôi.'],
    ],
  },

  /* ───────────── 四季 · Bốn mùa ───────────── */
  {
    id: 'haru', t: 'seasons', w: '春', r: 'はる', m: 'Mùa xuân', hv: 'Xuân', pos: 'Danh từ',
    def: ['Mùa xuân (khoảng tháng 3 – 5 ở Nhật).', 'Thời kỳ tươi đẹp nhất, tuổi xuân (青春).'],
    use: ['春になる: trời vào xuân. 春休み: kỳ nghỉ xuân.', 'Ngày lập xuân 立春 (りっしゅん) khoảng 4/2.'],
    ex: [
      ['春になると桜が咲きます。', 'Đến mùa xuân hoa anh đào nở.'],
      ['春休みに京都へ行く予定だ。', 'Tôi định đi Kyoto vào kỳ nghỉ xuân.'],
    ],
    q: {
      t: '春はあけぼの。\nやうやう白くなりゆく山ぎは、\nすこしあかりて、\n紫だちたる雲の\nほそくたなびきたる。',
      a: 'Sei Shōnagon (清少納言)', s: 'Chẩm Thảo Tử (枕草子)',
      vi: 'Mùa xuân đẹp nhất lúc rạng đông. Đường núi dần ửng trắng, sáng lên đôi chút, những dải mây tím mảnh mai giăng ngang.',
    },
  },
  {
    id: 'natsu', t: 'seasons', w: '夏', r: 'なつ', m: 'Mùa hè', hv: 'Hạ', pos: 'Danh từ',
    def: ['Mùa hè (khoảng tháng 6 – 8 ở Nhật).'],
    use: ['夏祭り (なつまつり): lễ hội mùa hè. 夏休み: kỳ nghỉ hè.', 'Mùa hè Nhật nóng ẩm: 蒸し暑い (oi bức).'],
    ex: [
      ['日本の夏は蒸し暑い。', 'Mùa hè Nhật Bản oi bức.'],
      ['夏祭りで浴衣を着た。', 'Tôi mặc yukata đi lễ hội mùa hè.'],
    ],
    q: {
      t: '夏草や\n兵どもが\n夢の跡',
      a: 'Matsuo Bashō (松尾芭蕉)', s: 'Áo Chi Tế Đạo (おくのほそ道)',
      vi: 'Cỏ hè xanh mướt — dấu tích giấc mộng xưa của bao chiến binh.',
    },
  },
  {
    id: 'aki', t: 'seasons', w: '秋', r: 'あき', m: 'Mùa thu', hv: 'Thu', pos: 'Danh từ',
    def: ['Mùa thu (khoảng tháng 9 – 11 ở Nhật).'],
    use: ['読書の秋 (mùa thu đọc sách), 食欲の秋 (mùa thu ăn ngon), スポーツの秋 — mùa thu là mùa “của” nhiều thứ.', '秋晴れ (あきばれ): trời thu trong xanh.'],
    ex: [
      ['秋は紅葉がきれいな季節です。', 'Mùa thu là mùa lá đỏ đẹp.'],
      ['秋の夜は長い。', 'Đêm thu dài.'],
    ],
    q: {
      t: '月見れば\nちぢにものこそ\n悲しけれ\nわが身ひとつの\n秋にはあらねど',
      a: 'Ōe no Chisato (大江千里)', s: 'Hyakunin Isshu, bài 23',
      vi: 'Ngắm trăng mà lòng buồn trăm mối — dẫu thu này đâu phải của riêng một mình ta.',
    },
  },
  {
    id: 'fuyu', t: 'seasons', w: '冬', r: 'ふゆ', m: 'Mùa đông', hv: 'Đông', pos: 'Danh từ',
    def: ['Mùa đông (khoảng tháng 12 – 2 ở Nhật).'],
    use: ['冬休み: kỳ nghỉ đông. 冬至 (とうじ): ngày đông chí.', 'こたつ (bàn sưởi) và 鍋 (lẩu) là hình ảnh mùa đông quen thuộc.'],
    ex: [
      ['冬は寒いので、こたつから出たくない。', 'Mùa đông lạnh nên chẳng muốn ra khỏi kotatsu.'],
      ['北海道の冬は長い。', 'Mùa đông ở Hokkaido dài.'],
    ],
  },
  {
    id: 'sakura', t: 'seasons', w: '桜', r: 'さくら', m: 'Hoa anh đào', hv: 'Anh', pos: 'Danh từ',
    def: ['Cây anh đào; hoa anh đào.', 'Màu hồng phấn (桜色).'],
    use: ['花見 (はなみ): ngắm hoa anh đào. Trong thơ cổ, 花 thường ngầm chỉ hoa anh đào.', '桜前線: “đường biên hoa anh đào”, dự báo hoa nở từ nam lên bắc.'],
    ex: [
      ['桜が満開になりました。', 'Hoa anh đào đã nở rộ.'],
      ['公園で花見をしよう。', 'Đi ngắm hoa ở công viên nhé.'],
    ],
    q: {
      t: 'ひさかたの\n光のどけき\n春の日に\nしづ心なく\n花の散るらむ',
      a: 'Ki no Tomonori (紀友則)', s: 'Hyakunin Isshu, bài 33',
      vi: 'Nắng xuân hiền hòa, ngày xuân êm ả — sao hoa lại vội vã, chẳng yên lòng mà rơi?',
    },
  },
  {
    id: 'momiji', t: 'seasons', w: '紅葉', r: 'もみじ', m: 'Lá đỏ mùa thu', hv: 'Hồng diệp', pos: 'Danh từ',
    def: ['Lá cây chuyển đỏ, vàng vào mùa thu.', 'Cây phong (楓).'],
    use: ['Còn đọc là こうよう (cách đọc Hán, dùng trong văn viết, tin tức).', '紅葉狩り (もみじがり): đi ngắm lá đỏ.'],
    ex: [
      ['京都の紅葉を見に行きたい。', 'Tôi muốn đi ngắm lá đỏ ở Kyoto.'],
      ['山が紅葉で赤く染まった。', 'Núi nhuộm đỏ bởi lá thu.'],
    ],
    q: {
      t: 'ちはやぶる\n神代もきかず\n竜田川\nからくれなゐに\n水くくるとは',
      a: 'Ariwara no Narihira (在原業平)', s: 'Hyakunin Isshu, bài 17',
      vi: 'Từ thuở thần linh cũng chưa từng nghe: sông Tatsuta nhuộm nước thắm đỏ như vải thêu.',
      note: 'Hình ảnh lá phong đỏ phủ kín mặt sông Tatsuta.',
    },
  },
  {
    id: 'hanabi', t: 'seasons', w: '花火', r: 'はなび', m: 'Pháo hoa', hv: 'Hoa hỏa', pos: 'Danh từ',
    def: ['Pháo hoa.'],
    use: ['花火大会 (はなびたいかい): lễ hội pháo hoa mùa hè.', '線香花火 (せんこうはなび): que pháo hoa nhỏ cầm tay.'],
    ex: [
      ['浴衣を着て花火大会に行った。', 'Tôi mặc yukata đi xem lễ hội pháo hoa.'],
      ['夜空に大きな花火が上がった。', 'Một chùm pháo hoa lớn bắn lên bầu trời đêm.'],
    ],
  },
  {
    id: 'shougatsu', t: 'seasons', w: '正月', r: 'しょうがつ', m: 'Tết, năm mới', hv: 'Chính nguyệt', pos: 'Danh từ',
    def: ['Tết, những ngày đầu năm mới (Nhật ăn Tết theo dương lịch).', 'Tháng Giêng.'],
    use: ['Thường nói お正月. 正月休み: kỳ nghỉ Tết.', 'Chúc Tết: あけましておめでとうございます.'],
    ex: [
      ['お正月に家族で神社へ行きます。', 'Ngày Tết cả nhà tôi đi đền thần.'],
      ['正月にはお餅を食べる。', 'Ngày Tết ăn bánh mochi.'],
    ],
  },

  /* ───────────── 天気 · Thời tiết ───────────── */
  {
    id: 'ame', t: 'weather', w: '雨', r: 'あめ', m: 'Mưa', hv: 'Vũ', pos: 'Danh từ',
    def: ['Mưa; cơn mưa.'],
    use: ['雨が降る: trời mưa. 雨が止む: tạnh mưa.', 'Trong từ ghép đọc là さめ/あま: 春雨 (はるさめ), 雨戸 (あまど).', 'Đừng nhầm với 飴 (あめ): kẹo.'],
    ex: [
      ['雨が降りそうだから、傘を持っていこう。', 'Trời có vẻ sắp mưa, mang ô theo đi.'],
      ['雨の日は家で本を読みます。', 'Ngày mưa tôi ở nhà đọc sách.'],
    ],
  },
  {
    id: 'hare', t: 'weather', w: '晴れ', r: 'はれ', m: 'Trời nắng, quang đãng', hv: 'Tình', pos: 'Danh từ',
    def: ['Trời quang, nắng đẹp.', 'Long trọng, trang trọng (晴れ着 = áo mặc dịp lễ).'],
    use: ['Động từ: 晴れる (trời hửng). 明日は晴れるでしょう: ngày mai trời sẽ nắng.', '晴れ時々曇り: nắng, thỉnh thoảng có mây (dự báo thời tiết).'],
    ex: [
      ['明日は晴れだといいですね。', 'Mong là mai trời nắng nhỉ.'],
      ['雨がやんで、空が晴れた。', 'Mưa tạnh, trời hửng nắng.'],
    ],
  },
  {
    id: 'kumori', t: 'weather', w: '曇り', r: 'くもり', m: 'Trời nhiều mây', hv: 'Đàm', pos: 'Danh từ',
    def: ['Trời âm u, nhiều mây.', 'Sự mờ đục (眼鏡の曇り = kính bị mờ hơi nước).'],
    use: ['Động từ: 曇る (trời kéo mây; kính bị mờ).', 'Mây là 雲 (くも) — khác chữ nhưng cùng gốc nghĩa.'],
    ex: [
      ['今日は一日中曇りでした。', 'Hôm nay trời âm u cả ngày.'],
      ['寒い所から入ると眼鏡が曇る。', 'Từ chỗ lạnh bước vào thì kính bị mờ.'],
    ],
  },
  {
    id: 'kaminari', t: 'weather', w: '雷', r: 'かみなり', m: 'Sấm sét', hv: 'Lôi', pos: 'Danh từ',
    def: ['Sấm, sét.', 'Cơn thịnh nộ, bị mắng (雷が落ちる = bị mắng một trận).'],
    use: ['雷が鳴る: sấm rền. 雷が落ちる: sét đánh; (bóng) bị la mắng.', 'Theo nghĩa đen: 神鳴り — “tiếng thần gầm”.'],
    ex: [
      ['夜中に雷が鳴って目が覚めた。', 'Nửa đêm sấm rền làm tôi tỉnh giấc.'],
      ['遅刻して、先生の雷が落ちた。', 'Đi muộn nên bị thầy mắng một trận.'],
    ],
  },
  {
    id: 'taifuu', t: 'weather', w: '台風', r: 'たいふう', m: 'Bão', hv: 'Đài phong', pos: 'Danh từ',
    def: ['Bão nhiệt đới (ở Tây Bắc Thái Bình Dương).'],
    use: ['台風が来る / 上陸する: bão đến / đổ bộ. 台風○号: cơn bão số ○.', 'Mùa bão ở Nhật: tháng 8 – 9.'],
    ex: [
      ['台風で電車が止まった。', 'Tàu điện ngừng chạy vì bão.'],
      ['台風が近づいている。', 'Cơn bão đang đến gần.'],
    ],
  },
  {
    id: 'niji', t: 'weather', w: '虹', r: 'にじ', m: 'Cầu vồng', hv: 'Hồng', pos: 'Danh từ',
    def: ['Cầu vồng.'],
    use: ['虹が出る / 虹がかかる: cầu vồng xuất hiện / bắc ngang.', 'Người Nhật nói cầu vồng có 七色 (bảy màu).'],
    ex: [
      ['雨のあと、空に虹がかかった。', 'Sau cơn mưa, cầu vồng bắc ngang bầu trời.'],
      ['虹は七色だと言われている。', 'Người ta nói cầu vồng có bảy màu.'],
    ],
  },
  {
    id: 'kiri', t: 'weather', w: '霧', r: 'きり', m: 'Sương mù', hv: 'Vụ', pos: 'Danh từ',
    def: ['Sương mù.', 'Hơi nước phun dạng sương (霧吹き = bình xịt).'],
    use: ['霧が出る / かかる: sương mù xuất hiện. 霧が晴れる: sương tan.', '霧 thường dùng cho mùa thu, còn 霞 (かすみ) là sương mỏng mùa xuân.'],
    ex: [
      ['朝、山に霧がかかっていた。', 'Buổi sáng sương mù bao phủ núi.'],
      ['霧が晴れて、湖が見えてきた。', 'Sương tan, mặt hồ dần hiện ra.'],
    ],
  },
  {
    id: 'samidare', t: 'weather', w: '五月雨', r: 'さみだれ', m: 'Mưa dầm đầu hè', hv: 'Ngũ nguyệt vũ', pos: 'Danh từ',
    def: ['Mưa dầm tháng Năm âm lịch, tức mùa mưa 梅雨 (khoảng tháng 6 dương lịch).', 'Kéo dài, lai rai không dứt (五月雨式に = lắt nhắt từng đợt).'],
    use: ['Là từ thơ ca, quý ngữ (季語) mùa hè trong haiku.', '五月雨式に質問する: hỏi lai rai từng chút một.'],
    ex: [
      ['五月雨が降り続いている。', 'Mưa dầm đầu hè vẫn rơi không dứt.'],
      ['五月雨式で申し訳ありませんが…', 'Xin lỗi vì cứ hỏi lắt nhắt từng chút…'],
    ],
    q: {
      t: '五月雨を\nあつめて早し\n最上川',
      a: 'Matsuo Bashō (松尾芭蕉)', s: 'Áo Chi Tế Đạo (おくのほそ道)',
      vi: 'Gom hết mưa dầm tháng Năm — sông Mogami chảy xiết.',
    },
  },
  {
    id: 'yuki', t: 'weather', w: '雪', r: 'ゆき', m: 'Tuyết', hv: 'Tuyết', pos: 'Danh từ',
    def: ['Tuyết.', 'Màu trắng tinh như tuyết (雪のような肌).'],
    use: ['雪が降る / 積もる: tuyết rơi / tuyết phủ dày.', '雪だるま: người tuyết. 雪合戦: ném tuyết.'],
    ex: [
      ['朝起きたら、外は一面の雪だった。', 'Sáng dậy, bên ngoài phủ một màu tuyết.'],
      ['子どもたちが雪だるまを作っている。', 'Bọn trẻ đang đắp người tuyết.'],
    ],
    q: {
      t: 'いくたびも\n雪の深さを\n尋ねけり',
      a: 'Masaoka Shiki (正岡子規)', s: 'Haiku, 1896',
      vi: 'Hết lần này lần khác — lại hỏi tuyết đã dày bao nhiêu.',
      note: 'Shiki viết khi nằm liệt giường vì bệnh, không thể tự ra ngắm tuyết.',
    },
  },

  /* ───────────── 動物 · Động vật ───────────── */
  {
    id: 'neko', t: 'animals', w: '猫', r: 'ねこ', m: 'Con mèo', hv: 'Miêu', pos: 'Danh từ',
    def: ['Con mèo.'],
    use: ['猫を飼う: nuôi mèo. 猫舌 (ねこじた): người không ăn được đồ nóng.', '猫の手も借りたい: bận đến mức muốn mượn cả tay mèo.'],
    ex: [
      ['うちの猫はいつも窓のそばで寝ている。', 'Con mèo nhà tôi lúc nào cũng ngủ cạnh cửa sổ.'],
      ['忙しくて猫の手も借りたいくらいだ。', 'Bận đến mức muốn mượn cả tay mèo.'],
    ],
    q: {
      t: '吾輩は猫である。\n名前はまだ無い。',
      a: 'Natsume Sōseki (夏目漱石)', s: 'Tôi là con mèo (吾輩は猫である), 1905',
      vi: 'Tôi là con mèo. Tên thì chưa có.',
    },
  },
  {
    id: 'inu', t: 'animals', w: '犬', r: 'いぬ', m: 'Con chó', hv: 'Khuyển', pos: 'Danh từ',
    def: ['Con chó.', '(cũ) Kẻ do thám, tay sai.'],
    use: ['犬の散歩: dắt chó đi dạo. 子犬 (こいぬ): chó con.', '犬も歩けば棒に当たる: ra đường ắt gặp chuyện (may hoặc rủi).'],
    ex: [
      ['毎朝、犬と散歩します。', 'Sáng nào tôi cũng đi dạo cùng chó.'],
      ['渋谷にはハチ公という犬の像がある。', 'Ở Shibuya có tượng chú chó tên Hachikō.'],
    ],
  },
  {
    id: 'tori', t: 'animals', w: '鳥', r: 'とり', m: 'Con chim', hv: 'Điểu', pos: 'Danh từ',
    def: ['Chim, loài chim.', 'Gà; thịt gà (thường viết 鶏 hoặc とり肉).'],
    use: ['鳥が鳴く: chim hót. 小鳥 (ことり): chim nhỏ.', '一石二鳥 (いっせきにちょう): một mũi tên trúng hai đích.'],
    ex: [
      ['朝、鳥の声で目が覚めた。', 'Sáng nay tôi thức dậy bởi tiếng chim.'],
      ['これは一石二鳥のアイデアだ。', 'Đây là ý tưởng một mũi tên trúng hai đích.'],
    ],
  },
  {
    id: 'sakana', t: 'animals', w: '魚', r: 'さかな', m: 'Con cá', hv: 'Ngư', pos: 'Danh từ',
    def: ['Con cá; món cá.'],
    use: ['魚を釣る: câu cá. 魚屋 (さかなや): hàng cá.', 'Trong từ ghép đọc うお hoặc ぎょ: 金魚 (きんぎょ, cá vàng).'],
    ex: [
      ['日本人はよく魚を食べる。', 'Người Nhật hay ăn cá.'],
      ['この川にはたくさんの魚がいる。', 'Con sông này có rất nhiều cá.'],
    ],
  },
  {
    id: 'kaeru', t: 'animals', w: '蛙', r: 'かえる', m: 'Con ếch', hv: 'Oa', pos: 'Danh từ',
    def: ['Con ếch, con nhái.'],
    use: ['Thường viết bằng kana: カエル. Đồng âm với 帰る (trở về) nên là bùa may “bình an trở về”.', '蛙の子は蛙: “con ếch thì vẫn là ếch” — cha nào con nấy.'],
    ex: [
      ['田んぼで蛙が鳴いている。', 'Ếch đang kêu ngoài ruộng lúa.'],
      ['蛙の子は蛙だね。', 'Đúng là cha nào con nấy nhỉ.'],
    ],
    q: {
      t: '古池や\n蛙飛びこむ\n水の音',
      a: 'Matsuo Bashō (松尾芭蕉)', s: 'Haiku, 1686',
      vi: 'Ao xưa tĩnh lặng — chú ếch nhảy vào, tiếng nước xao.',
      note: 'Bài haiku nổi tiếng nhất nước Nhật.',
    },
  },
  {
    id: 'semi', t: 'animals', w: '蝉', r: 'せみ', m: 'Con ve sầu', hv: 'Thiền', pos: 'Danh từ',
    def: ['Con ve sầu.'],
    use: ['Thường viết bằng kana: セミ. 蝉が鳴く: ve kêu.', 'Tiếng ve là âm thanh đặc trưng của mùa hè Nhật Bản.'],
    ex: [
      ['夏になると蝉がうるさく鳴く。', 'Đến hè ve kêu inh ỏi.'],
      ['子どもの頃、よく蝉を取った。', 'Hồi nhỏ tôi hay bắt ve.'],
    ],
    q: {
      t: '閑さや\n岩にしみ入る\n蝉の声',
      a: 'Matsuo Bashō (松尾芭蕉)', s: 'Áo Chi Tế Đạo (おくのほそ道)',
      vi: 'Tĩnh lặng thay — tiếng ve thấm sâu vào lòng đá.',
    },
  },
  {
    id: 'shika', t: 'animals', w: '鹿', r: 'しか', m: 'Con hươu', hv: 'Lộc', pos: 'Danh từ',
    def: ['Con hươu, con nai.'],
    use: ['Hươu ở công viên Nara (奈良公園) được coi là sứ giả của thần.', 'Trong thơ cổ, tiếng hươu gọi bạn tình gợi nỗi buồn mùa thu.'],
    ex: [
      ['奈良公園で鹿にせんべいをあげた。', 'Tôi cho hươu ăn bánh senbei ở công viên Nara.'],
      ['山の中で鹿を見かけた。', 'Tôi bắt gặp một con hươu trong núi.'],
    ],
    q: {
      t: '奥山に\n紅葉踏みわけ\n鳴く鹿の\n声きく時ぞ\n秋は悲しき',
      a: 'Sarumaru Dayū (猿丸大夫)', s: 'Hyakunin Isshu, bài 5',
      vi: 'Trong núi sâu, hươu giẫm lá phong mà kêu — nghe tiếng ấy mới thấm thu buồn.',
    },
  },
  {
    id: 'hotaru', t: 'animals', w: '蛍', r: 'ほたる', m: 'Con đom đóm', hv: 'Huỳnh', pos: 'Danh từ',
    def: ['Con đom đóm.'],
    use: ['蛍狩り (ほたるがり): đi ngắm đom đóm đầu hè.', '蛍の光: bài hát chia tay quen thuộc (giai điệu Auld Lang Syne).'],
    ex: [
      ['川辺で蛍が光っている。', 'Đom đóm đang lập lòe bên bờ sông.'],
      ['子どもの頃は家の近くでも蛍が見られた。', 'Hồi bé, ngay gần nhà cũng thấy đom đóm.'],
    ],
    q: {
      t: '夏は夜。\n月の頃はさらなり、\n闇もなほ、\n蛍の多く飛びちがひたる。',
      a: 'Sei Shōnagon (清少納言)', s: 'Chẩm Thảo Tử (枕草子)',
      vi: 'Mùa hè đẹp nhất là đêm. Đêm trăng thì khỏi nói, mà đêm tối cũng đẹp, khi muôn đom đóm bay đan nhau.',
    },
  },
  {
    id: 'suzume', t: 'animals', w: '雀', r: 'すずめ', m: 'Chim sẻ', hv: 'Tước', pos: 'Danh từ',
    def: ['Chim sẻ.', '(bóng) Người hay nói, lắm điều (楽屋雀).'],
    use: ['雀の涙 (すずめのなみだ): “nước mắt chim sẻ” — rất ít ỏi.', '雀百まで踊り忘れず: thói quen hồi nhỏ già vẫn chưa bỏ.'],
    ex: [
      ['ボーナスは雀の涙ほどだった。', 'Tiền thưởng chỉ ít ỏi như nước mắt chim sẻ.'],
      ['庭に雀が来ている。', 'Có chim sẻ sà xuống vườn.'],
    ],
    q: {
      t: '雀の子\nそこのけそこのけ\n御馬が通る',
      a: 'Kobayashi Issa (小林一茶)', s: 'Haiku',
      vi: 'Sẻ con ơi — tránh ra, tránh ra, ngựa quan đang qua đấy.',
    },
  },

  /* ───────────── 草木 · Cây cỏ & hoa ───────────── */
  {
    id: 'hana', t: 'plants', w: '花', r: 'はな', m: 'Hoa', hv: 'Hoa', pos: 'Danh từ',
    def: ['Hoa, bông hoa.', 'Hoa anh đào (trong thơ ca cổ).', 'Tinh hoa, phần đẹp nhất (今が花 = đang thời đẹp nhất).'],
    use: ['花が咲く / 散る: hoa nở / rụng. 花を生ける: cắm hoa (生け花).', 'Đừng nhầm với 鼻 (はな): cái mũi.', '花より団子: “bánh hơn hoa” — chuộng thực tế hơn vẻ đẹp.'],
    ex: [
      ['母に花を贈りました。', 'Tôi đã tặng hoa cho mẹ.'],
      ['庭にいろいろな花が咲いている。', 'Trong vườn nở đủ loại hoa.'],
    ],
    q: {
      t: '花の色は\n移りにけりな\nいたづらに\nわが身世にふる\nながめせしまに',
      a: 'Ono no Komachi (小野小町)', s: 'Hyakunin Isshu, bài 9',
      vi: 'Sắc hoa đã phai rồi — trong khi ta mải trầm tư, đời trôi uổng phí theo những cơn mưa dài.',
      note: 'ふる vừa là “sống qua đời”, vừa là “mưa rơi”; ながめ vừa là “trầm tư”, vừa là “mưa dầm”.',
    },
  },
  {
    id: 'ki', t: 'plants', w: '木', r: 'き', m: 'Cây; gỗ', hv: 'Mộc', pos: 'Danh từ',
    def: ['Cây (thân gỗ).', 'Gỗ (木の机 = bàn gỗ).'],
    use: ['木を植える: trồng cây. 木の葉 (このは): lá cây.', 'Đừng nhầm với 気 (き): tinh thần, cảm giác.'],
    ex: [
      ['庭に桜の木を植えた。', 'Tôi đã trồng một cây anh đào trong vườn.'],
      ['この机は木でできている。', 'Chiếc bàn này làm bằng gỗ.'],
    ],
  },
  {
    id: 'take', t: 'plants', w: '竹', r: 'たけ', m: 'Cây tre', hv: 'Trúc', pos: 'Danh từ',
    def: ['Cây tre, cây trúc.'],
    use: ['竹林 (たけばやし / ちくりん): rừng tre. 竹の子 / 筍 (たけのこ): măng.', '竹を割ったような性格: tính cách thẳng thắn, rõ ràng như chẻ tre.'],
    ex: [
      ['嵐山の竹林はとても有名です。', 'Rừng tre Arashiyama rất nổi tiếng.'],
      ['彼は竹を割ったような人だ。', 'Anh ấy là người thẳng thắn, dứt khoát.'],
    ],
    q: {
      t: '今は昔、\n竹取の翁といふものありけり。\n野山にまじりて竹を取りつつ、\nよろづのことに使ひけり。',
      a: 'Khuyết danh', s: 'Truyện ông lão đốn tre (竹取物語), thế kỷ 9 – 10',
      vi: 'Thuở xưa có một ông lão đốn tre. Ông vào núi đồng chặt tre, dùng làm đủ mọi việc.',
    },
  },
  {
    id: 'nanohana', t: 'plants', w: '菜の花', r: 'なのはな', m: 'Hoa cải', hv: 'Thái hoa', pos: 'Danh từ',
    def: ['Hoa cải dầu, hoa cải vàng nở vào mùa xuân.', 'Món rau cải ngồng.'],
    use: ['菜の花畑: cánh đồng hoa cải. Là quý ngữ mùa xuân.'],
    ex: [
      ['一面の菜の花畑が黄色く輝いている。', 'Cả cánh đồng hoa cải rực vàng.'],
      ['菜の花のおひたしを作った。', 'Tôi làm món cải ngồng luộc trộn.'],
    ],
    q: {
      t: '菜の花や\n月は東に\n日は西に',
      a: 'Yosa Buson (与謝蕪村)', s: 'Haiku, 1774',
      vi: 'Đồng hoa cải — trăng lên phía đông, mặt trời lặn phía tây.',
    },
  },
  {
    id: 'asagao', t: 'plants', w: '朝顔', r: 'あさがお', m: 'Hoa bìm bìm', hv: 'Triêu nhan', pos: 'Danh từ',
    def: ['Hoa bìm bìm (hoa “gương mặt buổi sáng”), nở sáng sớm và héo trước trưa.'],
    use: ['Học sinh tiểu học Nhật thường trồng 朝顔 để quan sát vào mùa hè.', 'Là quý ngữ mùa thu trong haiku (theo lịch cũ).'],
    ex: [
      ['朝顔は朝早く咲く。', 'Hoa bìm bìm nở từ sáng sớm.'],
      ['小学生の時、朝顔の観察日記を書いた。', 'Hồi tiểu học tôi viết nhật ký quan sát hoa bìm bìm.'],
    ],
    q: {
      t: '朝顔に\n釣瓶とられて\nもらひ水',
      a: 'Kaga no Chiyo-ni (加賀千代女)', s: 'Haiku',
      vi: 'Dây bìm quấn mất gầu múc — đành sang nhà bên xin nước.',
      note: 'Không nỡ gỡ dây hoa khỏi gầu giếng, nhà thơ đi xin nước hàng xóm.',
    },
  },
  {
    id: 'sumire', t: 'plants', w: '菫', r: 'すみれ', m: 'Hoa violet', hv: 'Cận', pos: 'Danh từ',
    def: ['Hoa violet (hoa tím), cỏ hoa nhỏ mọc ven đường mùa xuân.'],
    use: ['Thường viết bằng kana: すみれ. すみれ色: màu tím violet.'],
    ex: [
      ['道ばたにすみれが咲いていた。', 'Bên vệ đường hoa violet đang nở.'],
      ['すみれ色のハンカチを買った。', 'Tôi mua một chiếc khăn tay màu tím violet.'],
    ],
    q: {
      t: '山路来て\n何やらゆかし\nすみれ草',
      a: 'Matsuo Bashō (松尾芭蕉)', s: 'Dã Tẩm Kỷ Hành (野ざらし紀行)',
      vi: 'Băng qua đường núi — sao mà thương mến thế, khóm violet nhỏ.',
    },
  },
  {
    id: 'kusa', t: 'plants', w: '草', r: 'くさ', m: 'Cỏ', hv: 'Thảo', pos: 'Danh từ',
    def: ['Cỏ, cây thân thảo.', '(tiền tố) Không chính thức, nghiệp dư (草野球 = bóng chày phong trào).'],
    use: ['草を取る / むしる: nhổ cỏ.', 'Trên mạng, 草 (hoặc www) nghĩa là “buồn cười” — vì chữ w trông như cỏ mọc.'],
    ex: [
      ['週末は庭の草取りをした。', 'Cuối tuần tôi nhổ cỏ trong vườn.'],
      ['草の上に寝転んで空を見た。', 'Tôi nằm dài trên cỏ ngắm trời.'],
    ],
  },
  {
    id: 'kaki', t: 'plants', w: '柿', r: 'かき', m: 'Quả hồng', hv: 'Thị', pos: 'Danh từ',
    def: ['Cây hồng; quả hồng.'],
    use: ['干し柿 (ほしがき): hồng treo gió (hồng khô).', 'Đừng nhầm với 牡蠣 (かき): con hàu.'],
    ex: [
      ['秋になると柿が赤く熟す。', 'Sang thu, hồng chín đỏ.'],
      ['祖母は毎年干し柿を作る。', 'Năm nào bà tôi cũng làm hồng khô.'],
    ],
    q: {
      t: '柿くへば\n鐘が鳴るなり\n法隆寺',
      a: 'Masaoka Shiki (正岡子規)', s: 'Haiku, 1895',
      vi: 'Vừa ăn quả hồng — chuông chùa Hōryūji ngân vang.',
    },
  },
  {
    id: 'matsu', t: 'plants', w: '松', r: 'まつ', m: 'Cây thông', hv: 'Tùng', pos: 'Danh từ',
    def: ['Cây thông.'],
    use: ['門松 (かどまつ): cây thông trang trí cửa ngày Tết.', 'Thông xanh quanh năm nên tượng trưng cho trường thọ; bộ ba may mắn 松竹梅 (thông – trúc – mai).'],
    ex: [
      ['お正月に門松を飾る。', 'Ngày Tết trưng cây thông trước cửa.'],
      ['海岸に松の木が並んでいる。', 'Hàng thông chạy dọc bờ biển.'],
    ],
  },

  /* ───────────── 家族 · Gia đình ───────────── */
  {
    id: 'kazoku', t: 'family', w: '家族', r: 'かぞく', m: 'Gia đình', hv: 'Gia tộc', pos: 'Danh từ',
    def: ['Gia đình, những người thân sống cùng nhau.'],
    use: ['ご家族: gia đình (của người khác, kính ngữ).', '家族旅行: du lịch gia đình. 家族連れ: đi cùng cả nhà.'],
    ex: [
      ['私は四人家族です。', 'Gia đình tôi có bốn người.'],
      ['ご家族はお元気ですか。', 'Gia đình anh/chị vẫn khỏe chứ ạ?'],
    ],
  },
  {
    id: 'haha', t: 'family', w: '母', r: 'はは', m: 'Mẹ (của mình)', hv: 'Mẫu', pos: 'Danh từ',
    def: ['Mẹ — dùng khi nói về mẹ mình với người ngoài.', 'Nguồn gốc, cội nguồn (必要は発明の母 = cái khó ló cái khôn).'],
    use: ['Mẹ người khác: お母さん. Gọi mẹ mình trong nhà cũng dùng お母さん.', '母の日: Ngày của Mẹ (Chủ nhật thứ hai tháng 5).'],
    ex: [
      ['母は料理が上手です。', 'Mẹ tôi nấu ăn giỏi.'],
      ['母の日にカーネーションを贈った。', 'Tôi tặng hoa cẩm chướng vào Ngày của Mẹ.'],
    ],
  },
  {
    id: 'chichi', t: 'family', w: '父', r: 'ちち', m: 'Bố (của mình)', hv: 'Phụ', pos: 'Danh từ',
    def: ['Bố — dùng khi nói về bố mình với người ngoài.', 'Người khai sinh một lĩnh vực (近代医学の父).'],
    use: ['Bố người khác: お父さん.', '父の日: Ngày của Cha (Chủ nhật thứ ba tháng 6).'],
    ex: [
      ['父は銀行で働いています。', 'Bố tôi làm việc ở ngân hàng.'],
      ['お父さんはお元気ですか。', 'Bố bạn vẫn khỏe chứ?'],
    ],
  },
  {
    id: 'kodomo', t: 'family', w: '子供', r: 'こども', m: 'Trẻ con; con cái', hv: 'Tử cung', pos: 'Danh từ',
    def: ['Trẻ em, đứa trẻ.', 'Con (của ai đó).'],
    use: ['Cũng viết 子ども để tránh chữ 供 (vốn nghĩa “hầu hạ”).', 'Con người khác: お子さん. こどもの日: Tết thiếu nhi 5/5.'],
    ex: [
      ['子供たちが公園で遊んでいる。', 'Lũ trẻ đang chơi trong công viên.'],
      ['お子さんは何歳ですか。', 'Con anh/chị mấy tuổi rồi?'],
    ],
    q: {
      t: '名月を\nとってくれろと\n泣く子かな',
      a: 'Kobayashi Issa (小林一茶)', s: 'Haiku',
      vi: 'Trăng rằm vằng vặc — đứa bé khóc đòi: “Hái cho con đi!”',
    },
  },
  {
    id: 'ani', t: 'family', w: '兄', r: 'あに', m: 'Anh trai (của mình)', hv: 'Huynh', pos: 'Danh từ',
    def: ['Anh trai — dùng khi nói về anh mình với người ngoài.'],
    use: ['Anh người khác hoặc gọi anh mình: お兄さん.', 'Em trai: 弟 (おとうと). 兄弟 (きょうだい): anh chị em.'],
    ex: [
      ['兄は東京の大学に通っています。', 'Anh trai tôi học đại học ở Tokyo.'],
      ['兄弟は何人いますか。', 'Bạn có mấy anh chị em?'],
    ],
  },
  {
    id: 'ane', t: 'family', w: '姉', r: 'あね', m: 'Chị gái (của mình)', hv: 'Tỷ', pos: 'Danh từ',
    def: ['Chị gái — dùng khi nói về chị mình với người ngoài.'],
    use: ['Chị người khác hoặc gọi chị mình: お姉さん.', 'Em gái: 妹 (いもうと).'],
    ex: [
      ['姉は結婚して大阪に住んでいます。', 'Chị gái tôi đã lấy chồng và sống ở Osaka.'],
      ['姉にセーターを借りた。', 'Tôi mượn áo len của chị.'],
    ],
  },
  {
    id: 'sobo', t: 'family', w: '祖母', r: 'そぼ', m: 'Bà (của mình)', hv: 'Tổ mẫu', pos: 'Danh từ',
    def: ['Bà nội, bà ngoại — khi nói về bà mình với người ngoài.'],
    use: ['Bà người khác hoặc gọi bà mình: おばあさん / おばあちゃん.', 'Ông: 祖父 (そふ) / おじいさん.'],
    ex: [
      ['祖母は田舎で一人で暮らしている。', 'Bà tôi sống một mình ở quê.'],
      ['夏休みはおばあちゃんの家に行く。', 'Kỳ nghỉ hè tôi về nhà bà.'],
    ],
  },
  {
    id: 'ie', t: 'family', w: '家', r: 'いえ', m: 'Ngôi nhà', hv: 'Gia', pos: 'Danh từ',
    def: ['Ngôi nhà.', 'Gia đình, dòng họ (家を継ぐ = nối dõi).'],
    use: ['Cũng đọc うち (nhà mình, mái ấm). うちに帰る: về nhà.', 'Trong từ ghép đọc か/け: 家族 (かぞく), 作家 (さっか), 〜家 (dòng họ).'],
    ex: [
      ['駅の近くに家を買った。', 'Tôi đã mua nhà gần ga.'],
      ['早く家に帰りたい。', 'Tôi muốn về nhà sớm.'],
    ],
  },

  /* ───────────── 食 · Ẩm thực ───────────── */
  {
    id: 'gohan', t: 'food', w: 'ご飯', r: 'ごはん', m: 'Cơm; bữa ăn', hv: 'Phạn', pos: 'Danh từ',
    def: ['Cơm (gạo đã nấu chín).', 'Bữa ăn (朝ご飯 = bữa sáng).'],
    use: ['ご飯を食べる: ăn cơm. ご飯ですよ: “Cơm xong rồi!”.', 'Cách nói thân mật của nam: めし (飯).'],
    ex: [
      ['朝ご飯を食べましたか。', 'Bạn ăn sáng chưa?'],
      ['一緒にご飯を食べに行こう。', 'Đi ăn cơm cùng nhau đi.'],
    ],
  },
  {
    id: 'sushi', t: 'food', w: '寿司', r: 'すし', m: 'Sushi', hv: 'Thọ ty', pos: 'Danh từ',
    def: ['Sushi: cơm trộn giấm ăn kèm cá sống, hải sản, rau…'],
    use: ['Hay gặp các cách viết 鮨, 鮓 và すし. お寿司 là cách nói lịch sự.', 'Trong từ ghép đọc ずし: 回転寿司 (かいてんずし, sushi băng chuyền), 巻き寿司.'],
    ex: [
      ['回転寿司に行きませんか。', 'Đi ăn sushi băng chuyền không?'],
      ['このお寿司は新鮮でおいしい。', 'Sushi này tươi và ngon.'],
    ],
  },
  {
    id: 'ocha', t: 'food', w: 'お茶', r: 'おちゃ', m: 'Trà', hv: 'Trà', pos: 'Danh từ',
    def: ['Trà (đặc biệt là trà xanh Nhật).', 'Giờ nghỉ uống trà (お茶にしましょう = nghỉ giải lao nhé).', 'Trà đạo (茶道).'],
    use: ['お茶を入れる / いれる: pha trà.', 'お茶する: đi uống nước, cà phê (thân mật).'],
    ex: [
      ['お茶をどうぞ。', 'Mời anh/chị dùng trà.'],
      ['ちょっとお茶しない？', 'Đi uống chút gì không?'],
    ],
  },
  {
    id: 'misoshiru', t: 'food', w: '味噌汁', r: 'みそしる', m: 'Canh miso', hv: 'Vị tăng trấp', pos: 'Danh từ',
    def: ['Canh nấu bằng tương miso, thường có đậu phụ, rong biển wakame, hành.'],
    use: ['Thường nói おみそ汁. Món không thể thiếu trong bữa cơm Nhật (一汁三菜).'],
    ex: [
      ['毎朝、味噌汁を飲みます。', 'Sáng nào tôi cũng ăn canh miso.'],
      ['母の味噌汁が一番おいしい。', 'Canh miso của mẹ là ngon nhất.'],
    ],
  },
  {
    id: 'dango', t: 'food', w: '団子', r: 'だんご', m: 'Bánh dango', hv: 'Đoàn tử', pos: 'Danh từ',
    def: ['Bánh viên làm từ bột gạo nếp, thường xiên que.'],
    use: ['花より団子: “bánh hơn hoa” — chuộng cái thực tế hơn vẻ đẹp.', '月見団子: bánh dango cúng trăng Trung thu.'],
    ex: [
      ['花見で団子を食べた。', 'Tôi ăn dango khi đi ngắm hoa.'],
      ['あの子は花より団子だね。', 'Đứa bé đó chuộng ăn hơn ngắm hoa nhỉ.'],
    ],
  },
  {
    id: 'mochi', t: 'food', w: '餅', r: 'もち', m: 'Bánh mochi', hv: 'Bính', pos: 'Danh từ',
    def: ['Bánh giầy làm từ gạo nếp giã nhuyễn.'],
    use: ['Thường nói お餅. 餅つき: giã bánh mochi (cuối năm).', '餅は餅屋: việc gì thì nên giao cho người chuyên.'],
    ex: [
      ['お正月にお餅を食べます。', 'Ngày Tết ăn bánh mochi.'],
      ['餅は餅屋だから、専門家に頼もう。', 'Việc của ai người nấy làm, nhờ chuyên gia thôi.'],
    ],
  },
  {
    id: 'mizu', t: 'food', w: '水', r: 'みず', m: 'Nước', hv: 'Thủy', pos: 'Danh từ',
    def: ['Nước (nước lạnh).', 'Chất lỏng nói chung.'],
    use: ['Nước nóng là お湯 (おゆ) — tiếng Nhật phân biệt rõ nước lạnh và nước nóng.', '水に流す: “thả trôi theo dòng nước” — bỏ qua chuyện cũ.'],
    ex: [
      ['水を一杯ください。', 'Cho tôi một cốc nước.'],
      ['昔のことは水に流そう。', 'Chuyện cũ hãy cho qua đi.'],
    ],
  },
  {
    id: 'bentou', t: 'food', w: '弁当', r: 'べんとう', m: 'Cơm hộp', hv: 'Biện đương', pos: 'Danh từ',
    def: ['Cơm hộp mang theo hoặc mua sẵn.'],
    use: ['Thường nói お弁当. 駅弁 (えきべん): cơm hộp bán ở ga tàu.', 'お弁当を作る / 詰める: làm / xếp cơm hộp.'],
    ex: [
      ['毎朝、お弁当を作っています。', 'Sáng nào tôi cũng làm cơm hộp.'],
      ['新幹線で駅弁を食べた。', 'Tôi ăn cơm hộp mua ở ga trên tàu Shinkansen.'],
    ],
  },

  /* ───────────── 心 · Cảm xúc ───────────── */
  {
    id: 'kokoro', t: 'heart', w: '心', r: 'こころ', m: 'Trái tim, tâm hồn', hv: 'Tâm', pos: 'Danh từ',
    def: ['Lòng, tâm hồn, tình cảm.', 'Tấm lòng, sự chân thành (心をこめる = dồn hết tâm huyết).'],
    use: ['心から: từ đáy lòng. 心配 (しんぱい): lo lắng.', 'Tim (cơ quan) là 心臓 (しんぞう).'],
    ex: [
      ['心からお礼を申し上げます。', 'Tôi xin chân thành cảm ơn từ đáy lòng.'],
      ['心をこめて手紙を書いた。', 'Tôi đã dồn hết tâm tình viết lá thư.'],
    ],
    q: {
      t: 'やまとうたは、\n人の心を種として、\nよろづの言の葉とぞ\nなれりける。',
      a: 'Ki no Tsurayuki (紀貫之)', s: 'Lời tựa Cổ Kim Tập (古今和歌集仮名序), 905',
      vi: 'Thơ waka lấy lòng người làm hạt giống, nảy thành muôn vàn lá lời.',
      note: '言の葉 (lá của lời) là gốc của từ 言葉 (từ ngữ).',
    },
  },
  {
    id: 'yume', t: 'heart', w: '夢', r: 'ゆめ', m: 'Giấc mơ; ước mơ', hv: 'Mộng', pos: 'Danh từ',
    def: ['Giấc mơ khi ngủ.', 'Ước mơ, hoài bão.', 'Điều hư ảo, phù du.'],
    use: ['夢を見る: nằm mơ. 夢がかなう: ước mơ thành hiện thực.', '夢中 (むちゅう): say mê, mải mê.'],
    ex: [
      ['昨日、不思議な夢を見た。', 'Hôm qua tôi nằm một giấc mơ kỳ lạ.'],
      ['日本で働くのが私の夢です。', 'Làm việc ở Nhật là ước mơ của tôi.'],
    ],
    q: {
      t: '旅に病んで\n夢は枯野を\nかけ廻る',
      a: 'Matsuo Bashō (松尾芭蕉)', s: 'Bài haiku cuối đời, 1694',
      vi: 'Ốm giữa hành trình — giấc mơ vẫn rong ruổi trên cánh đồng khô.',
    },
  },
  {
    id: 'ai', t: 'heart', w: '愛', r: 'あい', m: 'Tình yêu', hv: 'Ái', pos: 'Danh từ',
    def: ['Tình yêu, lòng yêu thương.'],
    use: ['愛する: yêu (trang trọng, văn viết). Trong hội thoại người Nhật hay dùng 好き.', '愛情 (あいじょう): tình thương. 恋 (こい): tình yêu đôi lứa, say đắm.'],
    ex: [
      ['母の愛は深い。', 'Tình mẹ thật sâu nặng.'],
      ['彼は家族を愛している。', 'Anh ấy yêu thương gia đình.'],
    ],
  },
  {
    id: 'ureshii', t: 'heart', w: '嬉しい', r: 'うれしい', m: 'Vui mừng', hv: 'Hi', pos: 'Tính từ đuôi い',
    def: ['Vui, mừng, sung sướng (khi điều tốt đến với mình).'],
    use: ['Thường viết bằng kana: うれしい.', '嬉しい chỉ niềm vui do sự việc mang lại; 楽しい chỉ sự vui thú khi làm việc gì đó.', 'Nói về người khác: 嬉しそう / 嬉しがる.'],
    ex: [
      ['合格して、とても嬉しい。', 'Đỗ rồi, vui quá!'],
      ['手紙をもらって嬉しかった。', 'Nhận được thư, tôi rất vui.'],
    ],
  },
  {
    id: 'kanashii', t: 'heart', w: '悲しい', r: 'かなしい', m: 'Buồn', hv: 'Bi', pos: 'Tính từ đuôi い',
    def: ['Buồn, đau buồn.'],
    use: ['Danh từ: 悲しみ (nỗi buồn). Nói về người khác: 悲しそう.', 'Trong cổ văn, かなし còn có nghĩa “thương yêu tha thiết” (愛し).'],
    ex: [
      ['友達と別れるのは悲しい。', 'Chia tay bạn bè thật buồn.'],
      ['悲しい映画を見て泣いた。', 'Xem phim buồn mà tôi khóc.'],
    ],
  },
  {
    id: 'sabishii', t: 'heart', w: '寂しい', r: 'さびしい', m: 'Cô đơn, hiu quạnh', hv: 'Tịch', pos: 'Tính từ đuôi い',
    def: ['Cô đơn, buồn vì thiếu vắng ai đó.', 'Vắng vẻ, hiu quạnh (寂しい道 = con đường vắng).'],
    use: ['Cũng nói さみしい (khẩu ngữ).', 'Liên quan đến mỹ cảm 侘び寂び (わびさび): vẻ đẹp của sự giản dị, cũ kỹ, tĩnh mịch.'],
    ex: [
      ['一人暮らしは少し寂しい。', 'Sống một mình hơi cô đơn.'],
      ['君がいないと寂しいよ。', 'Không có em thì anh buồn lắm.'],
    ],
    q: {
      t: 'さびしさに\n宿を立ち出でて\nながむれば\nいづこも同じ\n秋の夕暮れ',
      a: 'Ryōzen Hōshi (良暹法師)', s: 'Hyakunin Isshu, bài 70',
      vi: 'Vì cô quạnh, bước khỏi am nhìn ra — đâu đâu cũng một chiều thu như thế.',
    },
  },
  {
    id: 'natsukashii', t: 'heart', w: '懐かしい', r: 'なつかしい', m: 'Nhớ nhung, hoài niệm', hv: 'Hoài', pos: 'Tính từ đuôi い',
    def: ['Gợi nhớ thân thương về quá khứ; bồi hồi, hoài niệm.'],
    use: ['Thường thốt lên 懐かしい！ khi gặp lại thứ gì gợi kỷ niệm.', 'Không dùng để nói “nhớ một người đang ở xa” — khi đó dùng 会いたい / 恋しい.'],
    ex: [
      ['この歌、懐かしいね。', 'Bài hát này gợi nhớ ghê nhỉ.'],
      ['故郷の味が懐かしい。', 'Tôi nhớ hương vị quê nhà.'],
    ],
    q: {
      t: 'ふるさとは\n遠きにありて\n思ふもの\nそして悲しく\nうたふもの',
      a: 'Murō Saisei (室生犀星)', s: 'Tiểu cảnh dị tình (小景異情)',
      vi: 'Quê hương là nơi để nhớ khi ở thật xa, và để hát lên trong buồn thương.',
    },
  },
  {
    id: 'shizuka', t: 'heart', w: '静か', r: 'しずか', m: 'Yên tĩnh', hv: 'Tĩnh', pos: 'Tính từ đuôi な',
    def: ['Yên tĩnh, im lặng.', 'Điềm tĩnh, nhẹ nhàng (静かな人).'],
    use: ['静かにしてください: xin giữ trật tự.', '静かな + danh từ: 静かな町 (thị trấn yên tĩnh).'],
    ex: [
      ['図書館では静かにしてください。', 'Trong thư viện xin giữ yên lặng.'],
      ['ここは静かで落ち着く。', 'Chỗ này yên tĩnh, thấy lòng thư thái.'],
    ],
  },

  /* ───────────── 旅 · Du lịch ───────────── */
  {
    id: 'tabi', t: 'travel', w: '旅', r: 'たび', m: 'Chuyến đi, hành trình', hv: 'Lữ', pos: 'Danh từ',
    def: ['Chuyến đi xa, chuyến du hành.'],
    use: ['旅に出る: lên đường. 旅 mang sắc thái văn chương; 旅行 (りょこう) là từ thông dụng hằng ngày.', '旅は道連れ世は情け: đi đường cần bạn, ở đời cần tình.'],
    ex: [
      ['一人で旅に出たい。', 'Tôi muốn một mình lên đường.'],
      ['旅の思い出を写真に残す。', 'Lưu giữ kỷ niệm chuyến đi bằng ảnh.'],
    ],
    q: {
      t: '月日は百代の過客にして、\n行かふ年も又旅人也。',
      a: 'Matsuo Bashō (松尾芭蕉)', s: 'Áo Chi Tế Đạo (おくのほそ道), 1702',
      vi: 'Tháng ngày là khách qua đường của trăm đời, năm qua năm lại cũng là kẻ lữ hành.',
    },
  },
  {
    id: 'michi', t: 'travel', w: '道', r: 'みち', m: 'Con đường', hv: 'Đạo', pos: 'Danh từ',
    def: ['Con đường.', 'Đạo, con đường tu dưỡng (茶道, 書道, 柔道).', 'Cách thức, phương pháp (生きる道).'],
    use: ['道に迷う: lạc đường. 道を聞く: hỏi đường.', 'Trong từ ghép đọc どう: 北海道, 茶道 (さどう).'],
    ex: [
      ['すみません、駅へ行く道を教えてください。', 'Xin lỗi, chỉ giúp tôi đường ra ga với.'],
      ['この道をまっすぐ行ってください。', 'Hãy đi thẳng con đường này.'],
    ],
    q: {
      t: 'この道や\n行く人なしに\n秋の暮',
      a: 'Matsuo Bashō (松尾芭蕉)', s: 'Haiku, 1694',
      vi: 'Con đường này — chẳng một ai qua lại, chiều thu tàn.',
    },
  },
  {
    id: 'eki', t: 'travel', w: '駅', r: 'えき', m: 'Nhà ga', hv: 'Dịch', pos: 'Danh từ',
    def: ['Nhà ga, ga tàu.', '(xưa) Trạm dịch nghỉ chân trên đường cái.'],
    use: ['駅前: trước ga. 駅員: nhân viên nhà ga.', 'Chữ 駅 có bộ 馬 (ngựa) — vì xưa là trạm đổi ngựa.'],
    ex: [
      ['駅まで歩いて十分です。', 'Đi bộ đến ga mất mười phút.'],
      ['次の駅で降ります。', 'Tôi xuống ở ga tiếp theo.'],
    ],
  },
  {
    id: 'yado', t: 'travel', w: '宿', r: 'やど', m: 'Nhà trọ', hv: 'Túc', pos: 'Danh từ',
    def: ['Nhà trọ, chỗ nghỉ chân.', '(xưa) Nhà ở, chỗ ở.'],
    use: ['宿を取る / 予約する: đặt chỗ trọ. 民宿 (みんしゅく): nhà nghỉ kiểu homestay.', '旅館 (りょかん): nhà trọ truyền thống kiểu Nhật.'],
    ex: [
      ['温泉の近くに宿を取った。', 'Tôi đã đặt chỗ trọ gần suối nước nóng.'],
      ['今夜の宿はまだ決まっていない。', 'Chỗ ngủ tối nay vẫn chưa quyết.'],
    ],
  },
  {
    id: 'chizu', t: 'travel', w: '地図', r: 'ちず', m: 'Bản đồ', hv: 'Địa đồ', pos: 'Danh từ',
    def: ['Bản đồ.'],
    use: ['地図を見る / 描く: xem / vẽ bản đồ.', 'Chú ý: ず viết là ず (không phải づ) vì gốc 図 (ず).'],
    ex: [
      ['地図を見ながら歩いた。', 'Tôi vừa đi vừa xem bản đồ.'],
      ['この地図は古くて分かりにくい。', 'Tấm bản đồ này cũ nên khó đọc.'],
    ],
  },
  {
    id: 'kippu', t: 'travel', w: '切符', r: 'きっぷ', m: 'Vé (tàu, xe)', hv: 'Thiết phù', pos: 'Danh từ',
    def: ['Vé tàu, vé xe.', 'Phiếu, vé nói chung.'],
    use: ['切符を買う: mua vé. 片道 / 往復切符: vé một chiều / khứ hồi.', 'Vé xem phim, hòa nhạc thường dùng チケット.'],
    ex: [
      ['大阪までの切符を二枚ください。', 'Cho tôi hai vé đi Osaka.'],
      ['切符をなくしてしまった。', 'Tôi lỡ làm mất vé rồi.'],
    ],
  },
  {
    id: 'tera', t: 'travel', w: '寺', r: 'てら', m: 'Ngôi chùa', hv: 'Tự', pos: 'Danh từ',
    def: ['Chùa (Phật giáo).'],
    use: ['Thường nói お寺. Trong tên chùa thường đọc じ: 金閣寺 (きんかくじ); riêng 清水寺 đọc là きよみずでら.', 'Chùa thờ Phật; 神社 (じんじゃ) là đền thờ thần Shinto.'],
    ex: [
      ['京都には古いお寺がたくさんある。', 'Kyoto có rất nhiều ngôi chùa cổ.'],
      ['お寺の鐘が聞こえる。', 'Nghe thấy tiếng chuông chùa.'],
    ],
    q: {
      t: '祇園精舎の鐘の声、\n諸行無常の響きあり。',
      a: 'Khuyết danh', s: 'Truyện Heike (平家物語)',
      vi: 'Tiếng chuông tinh xá Kỳ Viên vang lên lẽ vô thường của vạn vật.',
    },
  },
  {
    id: 'jinja', t: 'travel', w: '神社', r: 'じんじゃ', m: 'Đền thờ thần', hv: 'Thần xã', pos: 'Danh từ',
    def: ['Đền thờ thần đạo Shinto.'],
    use: ['Cổng đền là 鳥居 (とりい). Cách lễ: 二礼二拍手一礼 (cúi hai lần, vỗ tay hai lần, cúi một lần).', '初詣 (はつもうで): đi lễ đền đầu năm.'],
    ex: [
      ['お正月に神社へ初詣に行った。', 'Đầu năm tôi đi lễ đền.'],
      ['神社でおみくじを引いた。', 'Tôi rút quẻ bói ở đền.'],
    ],
  },
];
