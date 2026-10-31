# JLPT N1 mock tests. Same layout as jlpt_n3.py.

TEST1 = [
 ("kanji", "Âm đặc biệt (滑)", "両国の交渉は[円滑]に進んでいる。", ["えんかつ", "えんこつ", "えんがつ", "えんかち"],
  "Đàm phán giữa hai nước đang tiến triển suôn sẻ.",
  "✓ 円滑（えんかつ – VIÊN HOẠT）: trơn tru, suôn sẻ. 滑 đọc かつ (âm On); âm Kun là すべる.\n"
  "✗ えんこつ: こつ là âm của 骨 (xương), dễ nhầm vì hình dạng giống.\n"
  "✗ えんがつ: thêm âm đục sai.\n"
  "✗ えんかち: sai âm cuối."),
 ("kanji", "Âm đục / âm trong", "人手不足が[深刻]になっている。", ["しんこく", "しんごく", "ふかこく", "しんかく"],
  "Tình trạng thiếu nhân lực đang trở nên nghiêm trọng.",
  "✓ 深刻（しんこく – THÂM KHẮC）: nghiêm trọng.\n"
  "✗ しんごく: thêm âm đục sai.\n"
  "✗ ふかこく: 深 đọc âm Kun ふか – sai trong từ Hán.\n"
  "✗ しんかく: 刻 đọc こく."),
 ("kanji", "Âm Kun tính từ", "今年は売り上げが[著しく]伸びた。", ["いちじるしく", "あきらかしく", "ちょしく", "めざましく"],
  "Năm nay doanh số tăng trưởng rõ rệt.",
  "✓ 著しい（いちじるしい – TRỨ）: rõ rệt, đáng kể.\n"
  "✗ あきらかしく: không tồn tại (明らか là tính từ な).\n"
  "✗ ちょしく: ちょ là âm On (著者).\n"
  "✗ めざましく: 目覚ましい ‘ngoạn mục’ – nghĩa gần nhưng là từ khác."),
 ("kanji", "Âm On", "政府は規制を[緩和]する方針だ。", ["かんわ", "えんわ", "かんか", "ゆうわ"],
  "Chính phủ có chủ trương nới lỏng quy định.",
  "✓ 緩和（かんわ – HOÃN HÒA）: nới lỏng, giảm nhẹ.\n"
  "✗ えんわ: 緩 không đọc えん (dễ nhầm với 援, 媛).\n"
  "✗ かんか: 和 đọc わ.\n"
  "✗ ゆうわ: là 融和 ‘hòa hợp’."),
 ("kanji", "Âm Kun tính từ", "彼は自分の非を[潔く]認めた。", ["いさぎよく", "きよく", "こころよく", "けっぱく"],
  "Anh ấy đã thẳng thắn thừa nhận lỗi của mình.",
  "✓ 潔い（いさぎよい – KHIẾT）: dứt khoát, đàng hoàng (không biện minh).\n"
  "✗ きよく: 清く ‘trong sạch’.\n"
  "✗ こころよく: 快く ‘vui lòng’.\n"
  "✗ けっぱく: 潔白 ‘trong sạch, vô tội’ – là danh từ."),
 ("kanji", "Âm Kun động từ", "空に[漂う]雲をぼんやり眺めていた。", ["ただよう", "さまよう", "うかぶ", "ゆらぐ"],
  "Tôi thẫn thờ ngắm những đám mây trôi lững lờ trên bầu trời.",
  "✓ 漂う（ただよう – PHIÊU）: trôi nổi, lơ lửng.\n"
  "✗ さまよう: 彷徨う ‘lang thang’.\n"
  "✗ うかぶ: 浮かぶ ‘nổi lên’ – nghĩa gần nhưng là chữ khác.\n"
  "✗ ゆらぐ: 揺らぐ ‘dao động’."),
 ("hyoki", "Chữ trông giống nhau", "今月は予算を大きく[ちょうか]してしまった。", ["超過", "越過", "調過", "超課"],
  "Tháng này đã vượt ngân sách rất nhiều.",
  "✓ 超過（SIÊU QUÁ）: vượt quá.\n"
  "✗ 越（VIỆT）: vượt qua – nghĩa gần nhưng đọc えつ.\n"
  "✗ 調（ĐIỀU）: đọc ちょう nhưng nghĩa ‘điều chỉnh’.\n"
  "✗ 課（KHÓA）: bài, phòng ban – đọc か."),
 ("hyoki", "Chữ trông giống nhau", "利用者の立場に立って、細かい点まで[はいりょ]する。", ["配慮", "配虜", "排慮", "配虚"],
  "Đứng ở vị trí người dùng và chu đáo đến từng chi tiết nhỏ.",
  "✓ 配慮（PHỐI LỰ）: quan tâm, chu đáo. 慮 có bộ 心 (lo nghĩ).\n"
  "✗ 虜（LỖ）: tù binh – có bộ 力 thay vì 心.\n"
  "✗ 排（BÀI）: bài trừ – đọc はい nhưng sai nghĩa.\n"
  "✗ 虚（HƯ）: hư không."),
 ("hyoki", "Chữ trông giống nhau", "予算をめぐって会議が[ふんきゅう]した。", ["紛糾", "粉糾", "紛叫", "噴糾"],
  "Cuộc họp trở nên rối ren xoay quanh vấn đề ngân sách.",
  "✓ 紛糾（PHÂN CỦ）: rối ren, tranh cãi. Cả hai chữ có bộ 糸 (sợi chỉ – rối).\n"
  "✗ 粉（PHẤN – bộ 米）: bột.\n"
  "✗ 叫（KHIẾU – bộ 口）: kêu la.\n"
  "✗ 噴（PHÚN）: phun."),
 ("hyoki", "Chữ trông giống nhau", "インタビュー記事を雑誌に[けいさい]する。", ["掲載", "掲栽", "掲裁", "渇載"],
  "Đăng bài phỏng vấn lên tạp chí.",
  "✓ 掲載（YẾT TẢI）: đăng tải. 載 có bộ 車 (xe – chở, đăng).\n"
  "✗ 栽（TÀI – bộ 木）: trồng cây (盆栽).\n"
  "✗ 裁（TÀI – bộ 衣）: cắt may, phán xử (裁判).\n"
  "✗ 渇（KHÁT）: khát – hình dạng giống 掲."),
 ("hyoki", "Chữ trông giống nhau", "法律に[のっとって]厳正に処理する。", ["則って", "側って", "測って", "惻って"],
  "Xử lý nghiêm minh theo đúng pháp luật.",
  "✓ 則る（のっとる – TẮC）: tuân theo (quy tắc).\n"
  "✗ 側（TRẮC – bộ 亻）: bên cạnh.\n"
  "✗ 測（TRẮC – bộ 氵）: đo (はかる).\n"
  "✗ 惻（TRẮC – bộ 忄）: thương xót. Ba chữ cùng phần 則 nên rất dễ nhầm."),
 ("bunmyaku", "Quán ngữ", "長年の努力が（　）、ついに新薬の開発に成功した。", ["実を結び", "根を下ろし", "花を添え", "芽を摘み"],
  "Nỗ lực nhiều năm đã đơm hoa kết trái, cuối cùng đã phát triển thành công thuốc mới.",
  "✓ 実を結ぶ: kết trái → nỗ lực có kết quả.\n"
  "✗ 根を下ろす: bén rễ, định cư.\n"
  "✗ 花を添える: thêm hoa → làm tăng vẻ đẹp.\n"
  "✗ 芽を摘む: ngắt chồi → dập tắt từ trong trứng."),
 ("bunmyaku", "Tính từ đánh giá", "彼の（　）な発言が、交渉を決裂させた。", ["軽率", "謙虚", "慎重", "誠実"],
  "Phát ngôn hấp tấp của anh ta đã làm đàm phán đổ vỡ.",
  "✓ 軽率: khinh suất, thiếu suy nghĩ – dẫn đến kết quả xấu.\n"
  "✗ 謙虚: khiêm tốn.\n"
  "✗ 慎重: thận trọng.\n"
  "✗ 誠実: thành thật – đều là phẩm chất tốt, không gây đổ vỡ."),
 ("bunmyaku", "Từ Hán gần nghĩa", "時代の変化に（　）できない企業は生き残れない。", ["対応", "適用", "応対", "反映"],
  "Doanh nghiệp không thể thích ứng với biến đổi của thời đại sẽ không tồn tại được.",
  "✓ Nに対応する: ứng phó, thích ứng với.\n"
  "✗ 適用: áp dụng (luật, quy định).\n"
  "✗ 応対: tiếp đón (khách).\n"
  "✗ 反映: phản ánh."),
 ("bunmyaku", "Động từ ghép 差し～", "被災地に、全国から支援の手が（　）。", ["差し伸べられた", "差し押さえられた", "差し控えられた", "差し支えられた"],
  "Bàn tay hỗ trợ từ khắp cả nước đã chìa ra với vùng bị thiên tai.",
  "✓ 手を差し伸べる: chìa tay giúp đỡ.\n"
  "✗ 差し押さえる: tịch thu (tài sản).\n"
  "✗ 差し控える: kiềm chế, tạm không làm.\n"
  "✗ 差し支える: gây trở ngại."),
 ("bunmyaku", "Danh từ cảm xúc", "彼の作品からは、細部にまで作者の（　）が感じられる。", ["こだわり", "わだかまり", "いたわり", "かかわり"],
  "Từ tác phẩm của anh ấy có thể cảm nhận sự tỉ mỉ, tâm huyết của tác giả đến từng chi tiết.",
  "✓ こだわり: sự chăm chút, tâm huyết với chi tiết.\n"
  "✗ わだかまり: khúc mắc trong lòng.\n"
  "✗ いたわり: sự quan tâm, an ủi.\n"
  "✗ かかわり: mối liên quan."),
 ("bunmyaku", "Quán ngữ", "両社の交渉は（　）に乗り上げた。", ["暗礁", "軌道", "頂点", "土台"],
  "Đàm phán giữa hai công ty đã rơi vào bế tắc.",
  "✓ 暗礁に乗り上げる: mắc cạn vào đá ngầm → bế tắc.\n"
  "✗ 軌道に乗る: đi vào quỹ đạo (thuận lợi) – động từ khác.\n"
  "✗ 頂点 / 土台: không tạo quán ngữ với 乗り上げる."),
 ("iikae", "Tính từ đánh giá", "彼の仕事は[ずさん]だった。", ["いいかげんだった", "丁寧だった", "難しかった", "簡潔だった"],
  "Công việc của anh ta thật cẩu thả.",
  "✓ ずさん（杜撰）: cẩu thả, sơ sài = いいかげん.\n"
  "✗ 丁寧: cẩn thận – trái nghĩa.\n"
  "✗ 難しい / 簡潔: không liên quan."),
 ("iikae", "Từ Hán", "資金不足で計画は[頓挫した]。", ["途中でだめになった", "予定より早く終わった", "大成功した", "延期された"],
  "Vì thiếu vốn, kế hoạch đã đổ vỡ giữa chừng.",
  "✓ 頓挫する: thất bại giữa chừng = 途中でだめになる.\n"
  "✗ 延期: hoãn lại – kế hoạch vẫn còn, khác với ‘đổ vỡ’.\n"
  "✗ Các lựa chọn khác mang nghĩa tích cực."),
 ("iikae", "Phó từ thái độ", "彼女は[ひたむきに]練習を続けた。", ["一生懸命に", "いやいや", "こっそり", "たまに"],
  "Cô ấy tiếp tục luyện tập một cách miệt mài.",
  "✓ ひたむき: miệt mài, hết lòng = 一生懸命.\n"
  "✗ いやいや: miễn cưỡng.\n"
  "✗ こっそり: lén lút.\n"
  "✗ たまに: thỉnh thoảng."),
 ("iikae", "Cách nói", "語学が得意な彼には[うってつけ]の仕事だ。", ["ぴったりの", "退屈な", "危険な", "簡単な"],
  "Đó là công việc rất hợp với anh ấy – người giỏi ngoại ngữ.",
  "✓ うってつけ: vừa khít, rất thích hợp = ぴったり.\n"
  "✗ 退屈 / 危険 / 簡単: không mang nghĩa ‘phù hợp’."),
 ("bunpou", "Ngữ pháp: ～なり", "息子は家に帰ってくる（　）、自分の部屋に閉じこもってしまった。", ["なり", "ものの", "ゆえに", "とあって"],
  "Con trai tôi vừa về đến nhà là chui ngay vào phòng mình.",
  "✓ Vる＋なり: vừa… là ngay lập tức (hành động bất ngờ của người khác).\n"
  "✗ ものの: tuy… nhưng.\n"
  "✗ ゆえに: vì (văn viết).\n"
  "✗ とあって: vì là dịp đặc biệt."),
 ("bunpou", "Ngữ pháp: ～ともなると", "一流の料理人（　）、素材選びにも一切妥協しない。", ["ともなると", "ともなく", "とはいえ", "ならいざしらず"],
  "Đã là đầu bếp hạng nhất thì không bao giờ thỏa hiệp ngay cả khi chọn nguyên liệu.",
  "✓ Nともなると: một khi đã ở mức N thì đương nhiên.\n"
  "✗ ともなく: vô thức làm gì.\n"
  "✗ とはいえ: tuy nói là… nhưng.\n"
  "✗ ならいざしらず: nếu là… thì không nói, nhưng."),
 ("bunpou", "Ngữ pháp: ～のみならず", "このゲームは子ども（　）、大人まで夢中にさせている。", ["のみならず", "はおろか", "ならでは", "をよそに"],
  "Trò chơi này không chỉ trẻ em mà cả người lớn cũng mê mẩn.",
  "✓ Nのみならず: không chỉ N (= だけでなく).\n"
  "✗ はおろか: ngay cả… cũng không (đi với phủ định).\n"
  "✗ ならでは: chỉ có ở.\n"
  "✗ をよそに: bất chấp."),
 ("bunpou", "Ngữ pháp: ～をよそに", "親の心配（　）、彼は一人で危険な山へ出かけた。", ["をよそに", "をもって", "をめぐって", "を踏まえて"],
  "Mặc kệ nỗi lo của bố mẹ, anh ấy một mình đi lên ngọn núi nguy hiểm.",
  "✓ Nをよそに: phớt lờ, bất chấp N.\n"
  "✗ をもって: bằng / vào thời điểm.\n"
  "✗ をめぐって: xoay quanh.\n"
  "✗ を踏まえて: dựa trên."),
 ("bunpou", "Ngữ pháp: ～ならでは", "このまろやかな味は、老舗（　）のものだ。", ["ならでは", "ばかり", "にかぎり", "ゆえ"],
  "Vị đậm đà dịu ngọt này chỉ cửa hàng lâu đời mới có.",
  "✓ Nならではの: chỉ N mới có (khen ngợi).\n"
  "✗ ばかり / にかぎり / ゆえ: không tạo thành ‘～のもの’ với nghĩa này."),
 ("bunpou", "Ngữ pháp: ～よりほかない", "終電を逃してしまったので、タクシーで帰る（　）。", ["よりほかなかった", "までもなかった", "にすぎなかった", "に足りなかった"],
  "Vì lỡ chuyến tàu cuối nên tôi chẳng còn cách nào ngoài đi taxi về.",
  "✓ Vる＋よりほかない: không còn cách nào khác ngoài.\n"
  "✗ までもない: không cần thiết phải.\n"
  "✗ にすぎない: chỉ là.\n"
  "✗ に足りない: không đáng."),
 ("bunpou", "Ngữ pháp: ～に値する", "困難に負けなかった彼の努力は、称賛（　）。", ["に値する", "にほかならない", "ではいられない", "に越したことはない"],
  "Nỗ lực không chịu khuất phục khó khăn của anh ấy đáng được khen ngợi.",
  "✓ Nに値する: đáng để N (称賛に値する = đáng khen).\n"
  "✗ にほかならない: chính là.\n"
  "✗ ではいられない: không thể không.\n"
  "✗ に越したことはない: tốt nhất là."),
 ("narabe", "Sắp xếp câu", "この問題は ＿＿ ＿＿ ★ ＿＿ 解決できるものではない。", ["努力", "とうてい", "一個人の", "だけで"],
  "Vấn đề này hoàn toàn không thể giải quyết chỉ bằng nỗ lực của một cá nhân.",
  "Thứ tự đúng: この問題は とうてい / 一個人の / ★努力 / だけで 解決できるものではない。\n"
  "• とうてい～ない: hoàn toàn không thể (đặt đầu, ứng với ではない cuối câu).\n"
  "• 一個人の努力だけで: chỉ bằng nỗ lực của một cá nhân.\n"
  "Vị trí ★ là 努力."),
 ("narabe", "Sắp xếp câu", "その発言は ＿＿ ＿＿ ★ ＿＿ 言いようがない。", ["だ", "あまりにも", "無責任", "としか"],
  "Phát ngôn đó chỉ có thể nói là quá vô trách nhiệm.",
  "Thứ tự đúng: その発言は あまりにも / 無責任 / ★だ / としか 言いようがない。\n"
  "• ～としか言いようがない: chỉ có thể nói là.\n"
  "• Trước としか cần một câu hoàn chỉnh: 無責任だ.\n"
  "Vị trí ★ là だ."),
]

TEST2 = [
 ("kanji", "Âm On lặp", "混乱した事態を[収拾]する。", ["しゅうしゅう", "しゅうじゅう", "しゅしゅう", "しゅうしょう"],
  "Dàn xếp tình trạng hỗn loạn.",
  "✓ 収拾（しゅうしゅう – THU THẬP）: dàn xếp, ổn định tình hình. 拾 đọc しゅう (âm On), âm Kun là ひろう.\n"
  "✗ しゅうじゅう: thêm âm đục sai.\n"
  "✗ しゅしゅう: thiếu trường âm ở 収.\n"
  "✗ しゅうしょう: 拾 không đọc しょう."),
 ("kanji", "Âm On", "専門家は環境への影響に[懸念]を示した。", ["けねん", "けんねん", "けんえん", "かねん"],
  "Các chuyên gia bày tỏ lo ngại về ảnh hưởng đến môi trường.",
  "✓ 懸念（けねん – HUYỀN NIỆM）: lo ngại. 懸 thường đọc けん nhưng trong từ này đọc け.\n"
  "✗ けんねん: đọc theo âm thường けん – sai ở từ này.\n"
  "✗ けんえん: 念 đọc ねん.\n"
  "✗ かねん: 懸 không đọc か."),
 ("kanji", "Âm đục / âm trong", "原油価格の[高騰]が続いている。", ["こうとう", "こうどう", "たかとう", "こうよう"],
  "Giá dầu thô tiếp tục tăng vọt.",
  "✓ 高騰（こうとう – CAO ĐẰNG）: tăng vọt (giá cả).\n"
  "✗ こうどう: 行動 ‘hành động’ – sai âm đục.\n"
  "✗ たかとう: 高 đọc âm Kun たか – sai.\n"
  "✗ こうよう: 高揚 ‘dâng cao (tinh thần)’."),
 ("kanji", "Âm đục / âm trong", "材料を慎重に[吟味]して選ぶ。", ["ぎんみ", "きんみ", "ごんみ", "ぎんあじ"],
  "Lựa chọn nguyên liệu sau khi cân nhắc kỹ lưỡng.",
  "✓ 吟味（ぎんみ – NGÂM VỊ）: xem xét kỹ, nếm thử kỹ.\n"
  "✗ きんみ: thiếu âm đục.\n"
  "✗ ごんみ: 吟 đọc ぎん.\n"
  "✗ ぎんあじ: 味 đọc âm Kun あじ – sai trong từ Hán."),
 ("kanji", "Âm Kun động từ", "犯した罪を一生かけて[償う]。", ["つぐなう", "おぎなう", "うしなう", "ともなう"],
  "Dành cả đời để chuộc lại tội lỗi đã gây ra.",
  "✓ 償う（つぐなう – THƯỜNG）: đền bù, chuộc (lỗi).\n"
  "✗ おぎなう: 補う ‘bổ sung’.\n"
  "✗ うしなう: 失う ‘đánh mất’.\n"
  "✗ ともなう: 伴う ‘đi kèm’. Cả bốn đều kết thúc bằng ～なう nên dễ nhầm."),
 ("kanji", "Âm Kun động từ", "答えにくい質問をされて、彼は言葉を[濁した]。", ["にごした", "よごした", "ぼかした", "こがした"],
  "Bị hỏi câu khó trả lời, anh ấy đã nói lấp lửng.",
  "✓ 濁す（にごす – TRỌC）: làm đục → 言葉を濁す: nói lấp lửng, nói tránh.\n"
  "✗ よごした: 汚す ‘làm bẩn’.\n"
  "✗ ぼかした: ぼかす ‘làm mờ’ – nghĩa gần nhưng không phải cách đọc của 濁.\n"
  "✗ こがした: 焦がす ‘làm cháy’."),
 ("hyoki", "Chữ cùng âm", "彼は100メートル走で世界新記録を[じゅりつ]した。", ["樹立", "寿立", "授立", "樹律"],
  "Anh ấy đã lập kỷ lục thế giới mới ở cự ly 100m.",
  "✓ 樹立（THỤ LẬP）: thiết lập (kỷ lục, chính quyền).\n"
  "✗ 寿（THỌ）/ 授（THỤ – trao）: đọc じゅ nhưng sai nghĩa.\n"
  "✗ 律（LUẬT）: đọc りつ nhưng sai chữ."),
 ("hyoki", "Từ đồng âm", "自分の失敗の責任を部下に[てんか]するのは卑怯だ。", ["転嫁", "添加", "転稼", "転家"],
  "Đổ trách nhiệm về thất bại của mình cho cấp dưới là hèn nhát.",
  "✓ 転嫁（CHUYỂN GIÁ）: đổ (trách nhiệm) cho người khác.\n"
  "✗ 添加（THIÊM GIA）: thêm vào (chất phụ gia) – đồng âm てんか, bẫy phổ biến.\n"
  "✗ 稼（GIÁ – kiếm tiền）/ 家（GIA）: hình dạng/âm gần nhưng sai."),
 ("hyoki", "Chữ trông giống nhau", "まず計画の[がいよう]を説明します。", ["概要", "慨要", "既要", "概用"],
  "Trước tiên tôi xin giải thích khái quát kế hoạch.",
  "✓ 概要（KHÁI YẾU）: khái quát, tóm tắt. 概 bộ 木.\n"
  "✗ 慨（KHÁI – bộ 忄）: cảm khái.\n"
  "✗ 既（KÝ）: đã (既に).\n"
  "✗ 用（DỤNG）: đọc よう nhưng sai chữ."),
 ("hyoki", "Chữ trông giống nhau", "その問題をめぐって、両者の意見が[たいりつ]している。", ["対立", "待立", "帯立", "対律"],
  "Ý kiến hai bên đang đối lập nhau xung quanh vấn đề đó.",
  "✓ 対立（ĐỐI LẬP）: đối lập.\n"
  "✗ 待（ĐÃI）/ 帯（ĐỚI）: đọc たい nhưng sai nghĩa.\n"
  "✗ 律（LUẬT）: đọc りつ nhưng sai chữ."),
 ("hyoki", "Động từ đồng âm", "住民が話し合う場を[もうける]ことにした。", ["設ける", "儲ける", "説ける", "没ける"],
  "Đã quyết định lập ra nơi để cư dân thảo luận.",
  "✓ 設ける（THIẾT）: thiết lập, tạo ra (場, 規則).\n"
  "✗ 儲ける（TRỮ）: kiếm lời – đồng âm もうける, bẫy kinh điển.\n"
  "✗ 説（THUYẾT）/ 没（MỘT）: hình dạng gần giống 設."),
 ("bunmyaku", "Động từ phủ định văn viết", "彼女は周囲の反対にも（　）、自分の夢を貫いた。", ["屈せず", "応じず", "及ばず", "頼らず"],
  "Cô ấy không khuất phục trước sự phản đối của mọi người và theo đuổi đến cùng ước mơ.",
  "✓ Nに屈せず: không khuất phục trước N – hợp với 夢を貫く.\n"
  "✗ 応じず: không đáp ứng (yêu cầu) – ‘không đáp ứng sự phản đối’ không tự nhiên.\n"
  "✗ 及ばず: không bằng / không cần.\n"
  "✗ 頼らず: không dựa vào."),
 ("bunmyaku", "Từ Hán gần nghĩa", "新しいシステムの導入で、作業時間が大幅に（　）された。", ["短縮", "縮小", "削除", "省略"],
  "Nhờ áp dụng hệ thống mới, thời gian làm việc đã được rút ngắn đáng kể.",
  "✓ 時間を短縮する: rút ngắn thời gian.\n"
  "✗ 縮小: thu nhỏ quy mô.\n"
  "✗ 削除: xóa bỏ.\n"
  "✗ 省略: lược bỏ."),
 ("bunmyaku", "Danh từ Hán", "この論文は、彼の長年の研究の（　）と言える。", ["集大成", "大前提", "先入観", "一段落"],
  "Luận văn này có thể nói là sự tổng hợp hoàn chỉnh của nhiều năm nghiên cứu của ông ấy.",
  "✓ 集大成: tập đại thành, tổng hợp hoàn chỉnh.\n"
  "✗ 大前提: tiền đề lớn.\n"
  "✗ 先入観: định kiến.\n"
  "✗ 一段落: tạm xong một giai đoạn."),
 ("bunmyaku", "Diễn đạt trang trọng", "その件については、（　）コメントを控えさせていただきます。", ["現時点では", "至急", "早急に", "即座に"],
  "Về vụ việc đó, tại thời điểm hiện tại chúng tôi xin phép không bình luận.",
  "✓ 現時点では: ở thời điểm hiện tại – cách nói né tránh trong họp báo.\n"
  "✗ 至急 / 早急に / 即座に: gấp, ngay lập tức – mâu thuẫn với ‘không bình luận’."),
 ("bunmyaku", "Từ tượng thái", "無口な彼が急に冗談を言ったので、みんな（　）とした。", ["きょとん", "うっとり", "にっこり", "ぐったり"],
  "Anh ấy vốn ít nói bỗng dưng nói đùa nên mọi người ngơ ngác.",
  "✓ きょとんとする: ngơ ngác, không hiểu chuyện gì.\n"
  "✗ うっとり: say mê, mơ màng.\n"
  "✗ にっこり: mỉm cười – thường dùng にっこりする/笑う.\n"
  "✗ ぐったり: mệt rã rời."),
 ("bunmyaku", "Từ Hán 念", "予算の都合で、計画の一部を（　）せざるを得なかった。", ["断念", "執念", "懸念", "記念"],
  "Vì ngân sách, chúng tôi buộc phải từ bỏ một phần kế hoạch.",
  "✓ 断念する: từ bỏ (đành phải bỏ).\n"
  "✗ 執念: sự cố chấp.\n"
  "✗ 懸念: lo ngại.\n"
  "✗ 記念: kỷ niệm."),
 ("iikae", "Quán ngữ", "その話はどうも[まゆつば]だ。", ["疑わしい", "面白い", "感動的だ", "有名だ"],
  "Câu chuyện đó có vẻ đáng ngờ.",
  "✓ 眉唾（まゆつば）: đáng nghi ngờ, khó tin = 疑わしい.\n"
  "✗ Các lựa chọn khác không mang nghĩa ‘nghi ngờ’."),
 ("iikae", "Phó từ", "面接の間、彼は[しきりに]時計を見ていた。", ["何度も", "一度だけ", "ぼんやり", "じっと"],
  "Trong buổi phỏng vấn, anh ta liên tục nhìn đồng hồ.",
  "✓ しきりに: liên tục, nhiều lần = 何度も.\n"
  "✗ 一度だけ: chỉ một lần.\n"
  "✗ ぼんやり: thẫn thờ.\n"
  "✗ じっと: chăm chú, bất động (nhìn liên tục một lần)."),
 ("iikae", "Từ Hán", "試験の準備は[万全だ]。", ["完璧だ", "不十分だ", "途中だ", "簡単だ"],
  "Việc chuẩn bị cho kỳ thi đã hoàn hảo.",
  "✓ 万全: vẹn toàn, chu đáo = 完璧.\n"
  "✗ 不十分: chưa đủ – trái nghĩa.\n"
  "✗ 途中: dở dang.\n"
  "✗ 簡単: đơn giản."),
 ("iikae", "Phó từ", "事故の原因を[つぶさに]調べた。", ["詳しく", "急いで", "少しだけ", "こっそり"],
  "Đã điều tra tường tận nguyên nhân tai nạn.",
  "✓ つぶさに（具に）: tường tận, chi tiết = 詳しく.\n"
  "✗ 急いで: vội.\n"
  "✗ 少しだけ: một chút.\n"
  "✗ こっそり: lén lút."),
 ("bunpou", "Ngữ pháp: ～をもってすれば", "彼の才能（　）、この難題も解決できるだろう。", ["をもってすれば", "をものともせず", "をよそに", "をおいて"],
  "Với tài năng của anh ấy thì vấn đề khó này chắc cũng giải quyết được.",
  "✓ Nをもってすれば: nếu dùng N (năng lực mạnh) thì có thể.\n"
  "✗ をものともせず: bất chấp (khó khăn).\n"
  "✗ をよそに: phớt lờ.\n"
  "✗ をおいて: ngoài N ra không có."),
 ("bunpou", "Ngữ pháp: ～をおいて", "この仕事を任せられるのは、彼（　）ほかにいない。", ["をおいて", "をもって", "をよそに", "を限りに"],
  "Người có thể giao công việc này thì ngoài anh ấy ra không còn ai.",
  "✓ Nをおいてほかにない: ngoài N ra không có (đánh giá cao).\n"
  "✗ をもって: bằng / vào lúc.\n"
  "✗ をよそに: bất chấp.\n"
  "✗ を限りに: lấy… làm mốc cuối cùng."),
 ("bunpou", "Ngữ pháp: ～をものともせず", "彼女は足のけが（　）、最後まで走り抜いた。", ["をものともせず", "をいいことに", "を皮切りに", "をめぐって"],
  "Bất chấp chấn thương ở chân, cô ấy đã chạy đến đích.",
  "✓ Nをものともせず: không coi khó khăn N ra gì (khen ngợi).\n"
  "✗ をいいことに: lợi dụng.\n"
  "✗ を皮切りに: bắt đầu từ.\n"
  "✗ をめぐって: xoay quanh."),
 ("bunpou", "Ngữ pháp: ～を皮切りに", "東京公演（　）、全国各地でコンサートが開かれる。", ["を皮切りに", "をよそに", "をもって", "をおいて"],
  "Bắt đầu từ buổi diễn ở Tokyo, các buổi hòa nhạc sẽ được tổ chức khắp cả nước.",
  "✓ Nを皮切りに: khởi đầu bằng N, rồi lần lượt.\n"
  "✗ をよそに / をもって / をおいて: không mang nghĩa ‘khởi đầu’."),
 ("bunpou", "Ngữ pháp: ～をもって", "本日（　）、当店は閉店いたします。", ["をもって", "をよそに", "をおいて", "をめぐって"],
  "Cửa hàng chúng tôi xin đóng cửa kể từ hôm nay.",
  "✓ Nをもって: vào thời điểm N (thông báo trang trọng: 本日をもって).\n"
  "✗ をよそに: bất chấp.\n"
  "✗ をおいて: ngoài… ra.\n"
  "✗ をめぐって: xoay quanh."),
 ("bunpou", "Ngữ pháp: ～ないことには", "実際に使ってみない（　）、良いかどうか判断できない。", ["ことには", "ことなく", "ことから", "ことだし"],
  "Nếu không dùng thử thực tế thì không thể đánh giá tốt hay không.",
  "✓ Vない＋ことには～ない: nếu không… thì không thể.\n"
  "✗ ことなく: mà không (làm gì).\n"
  "✗ ことから: vì (căn cứ).\n"
  "✗ ことだし: vì (lý do nhẹ)."),
 ("bunpou", "Ngữ pháp: ～どころか", "彼はミスをしても謝る（　）、人のせいにした。", ["どころか", "ばかりか", "ものの", "ながらも"],
  "Mắc lỗi mà anh ta chẳng những không xin lỗi, còn đổ cho người khác.",
  "✓ ～どころか: chẳng những không… mà ngược lại.\n"
  "✗ ばかりか: không chỉ… mà còn (cùng chiều) – ‘không chỉ xin lỗi mà còn đổ lỗi’ là mâu thuẫn.\n"
  "✗ ものの / ながらも: tuy… nhưng."),
 ("narabe", "Sắp xếp câu", "彼の ＿＿ ＿＿ ★ ＿＿ ものがある。", ["目を", "日々の", "努力には", "見張る"],
  "Nỗ lực hằng ngày của anh ấy thật đáng kinh ngạc.",
  "Thứ tự đúng: 彼の 日々の / 努力には / ★目を / 見張る ものがある。\n"
  "• 目を見張る: tròn mắt kinh ngạc.\n"
  "• ～ものがある: có cái gì đó (cảm thán).\n"
  "Vị trí ★ là 目を."),
 ("narabe", "Sắp xếp câu", "いくら ＿＿ ＿＿ ★ ＿＿ 許されることではない。", ["としても", "理由が", "あった", "うそをつくことは"],
  "Dù có lý do đi nữa thì việc nói dối cũng không thể được tha thứ.",
  "Thứ tự đúng: いくら 理由が / あった / ★としても / うそをつくことは 許されることではない。\n"
  "• いくら～としても: dù… đến đâu đi nữa.\n"
  "• うそをつくことは là chủ đề của vế sau.\n"
  "Vị trí ★ là としても."),
]

TEST3 = [
 ("kanji", "Âm On", "議論は 次第に [白熱]して いった。", ["はくねつ", "びゃくねつ", "はっねつ", "はくねち"],
  "Cuộc tranh luận dần trở nên nảy lửa.",
  "✓ 白熱（はくねつ – BẠCH NHIỆT）: nóng bỏng, gay cấn.\n✗ びゃくねつ: 白 đọc びゃく trong 白夜, 黒白.\n✗ はっねつ / はくねち: sai."),
 ("kanji", "Phó từ đặc biệt", "今回の 対応は [甚だ] 遺憾で ある。", ["はなはだ", "はなだ", "じんだ", "はたはだ"],
  "Cách xử lý lần này vô cùng đáng tiếc.",
  "✓ 甚だ（はなはだ – THẬM）: vô cùng (văn viết).\n✗ はなだ / はたはだ: sai.\n✗ じんだ: 甚 đọc じん trong 甚大.",
  "Hay gặp trong cặp cố định: 甚だ遺憾 / 甚大な被害."),
 ("kanji", "Âm đục / âm trong", "労使の 交渉は [難航]して いる。", ["なんこう", "なんごう", "むずこう", "なんぎょう"],
  "Đàm phán giữa chủ và thợ đang gặp nhiều trở ngại.",
  "✓ 難航（なんこう – NAN HÀNG）: tiến triển khó khăn.\n✗ なんごう: thêm âm đục.\n✗ むずこう: 難 đọc Kun むずかしい – sai.\n✗ なんぎょう: 難行 tu khổ hạnh."),
 ("kanji", "Âm Kun động từ", "社会の 秩序を [乱す] 行為は 許されない。", ["みだす", "あらす", "ちらす", "くずす"],
  "Hành vi làm rối loạn trật tự xã hội không được chấp nhận.",
  "✓ 乱す（みだす – LOẠN）: làm rối loạn.\n✗ あらす: 荒らす tàn phá.\n✗ ちらす: 散らす làm tản ra.\n✗ くずす: 崩す làm sụp đổ."),
 ("kanji", "Âm On", "同社は [潤沢]な 資金を 持って いる。", ["じゅんたく", "じゅんだく", "かんたく", "うるたく"],
  "Công ty đó có nguồn vốn dồi dào.",
  "✓ 潤沢（じゅんたく – NHUẬN TRẠCH）: dồi dào.\n✗ じゅんだく: thêm âm đục.\n✗ かんたく: lẫn 潤 với 閑.\n✗ うるたく: 潤 đọc Kun うるおう – sai."),
 ("kanji", "Âm On", "記事の 誤りを [訂正]した。", ["ていせい", "ちょうせい", "ていしょう", "てんせい"],
  "Đã đính chính sai sót trong bài báo.",
  "✓ 訂正（ていせい – ĐÍNH CHÍNH）.\n✗ ちょうせい: 調整 điều chỉnh.\n✗ ていしょう: 提唱 đề xướng.\n✗ てんせい: 転生 chuyển sinh."),
 ("hyoki", "Chữ trông giống nhau", "事件の [けいい]を 説明して ください。", ["経緯", "経違", "軽緯", "径緯"],
  "Hãy giải thích đầu đuôi sự việc.",
  "✓ 経緯（KINH VĨ）: đầu đuôi, diễn biến.\n✗ 違（VI）: sai khác – cùng phần 韋 nhưng bộ 辶.\n✗ 軽 / 径: giống 経 nhưng khác bộ."),
 ("hyoki", "Chữ trông giống nhau", "結論は ひとまず [ほりゅう]に する。", ["保留", "保流", "補留", "保瑠"],
  "Kết luận tạm thời để treo đó.",
  "✓ 保留（BẢO LƯU）.\n✗ 流: dòng chảy – đọc りゅう nhưng sai.\n✗ 補（BỔ）: đọc ほ nhưng sai.\n✗ 瑠: chữ trong 瑠璃."),
 ("hyoki", "Chữ trông giống nhau", "国会で 法案を [しんぎ]する。", ["審議", "審義", "新議", "申議"],
  "Thẩm định dự luật tại Quốc hội.",
  "✓ 審議（THẨM NGHỊ）.\n✗ 義（NGHĨA）: thiếu bộ 言.\n✗ 新 / 申: đọc しん nhưng sai."),
 ("hyoki", "Chữ trông giống nhau", "本番で 実力を [はっき]した。", ["発揮", "発輝", "発指", "発軍"],
  "Đã phát huy thực lực trong buổi thi chính thức.",
  "✓ 発揮（PHÁT HUY）: bộ 扌.\n✗ 輝（HUY – rực rỡ）: đọc き, giống phần phải 軍.\n✗ 指 / 軍: sai."),
 ("hyoki", "Chữ trông giống nhau", "自然の [めぐみ]に 感謝する。", ["恵み", "恩み", "患み", "悪み"],
  "Biết ơn những ân huệ của thiên nhiên.",
  "✓ 恵み（HUỆ）: ân huệ.\n✗ 恩（ÂN）/ 患（HOẠN）/ 悪（ÁC）: cùng bộ 心 nhưng khác phần trên."),
 ("bunmyaku", "Động từ", "彼の 提案は 斬新だが、実現性に（　）。", ["欠ける", "富む", "満ちる", "及ぶ"],
  "Đề xuất của anh ấy mới lạ nhưng thiếu tính khả thi.",
  "✓ 〜に欠ける: thiếu.\n✗ 富む / 満ちる: giàu / tràn đầy – mâu thuẫn với だが.\n✗ 及ぶ: lan tới.",
  "Chú ý だが: vế sau phải trái nghĩa với vế trước (斬新 = điểm tốt → vế sau là điểm xấu)."),
 ("bunmyaku", "Danh từ Hán", "不祥事が 相次ぎ、会社の 信用は（　）した。", ["失墜", "墜落", "低迷", "転落"],
  "Bê bối liên tiếp xảy ra khiến uy tín công ty sụp đổ.",
  "✓ 信用が失墜する: mất uy tín (kết hợp cố định).\n✗ 墜落: rơi (máy bay).\n✗ 低迷: trì trệ (thị trường, thành tích).\n✗ 転落: rơi xuống, tụt hạng."),
 ("bunmyaku", "Từ tượng thái", "彼は 記者の 質問を（　）かわした。", ["のらりくらりと", "はきはきと", "きびきびと", "ずけずけと"],
  "Anh ta lảng tránh câu hỏi của phóng viên một cách lấp lửng.",
  "✓ のらりくらり: lấp lửng, né tránh – hợp với かわす (né).\n✗ はきはき: rõ ràng, dứt khoát.\n✗ きびきび: nhanh nhẹn.\n✗ ずけずけ: nói thẳng thừng."),
 ("bunmyaku", "Phó từ mức độ", "両国の 関係は この 10年で（　）改善した。", ["著しく", "甚だしく", "細かく", "厳しく"],
  "Quan hệ hai nước đã cải thiện rõ rệt trong 10 năm qua.",
  "✓ 著しく: rõ rệt (dùng cho cả tốt và xấu).\n✗ 甚だしく: thái quá – thường dùng cho điều xấu (甚だしい誤解).\n✗ 細かく / 厳しく: tỉ mỉ / nghiêm khắc."),
 ("bunmyaku", "Danh từ Hán 落〜", "期待が 大きかった だけに、（　）も 大きい。", ["落胆", "落第", "落選", "落下"],
  "Vì kỳ vọng lớn nên thất vọng cũng lớn.",
  "✓ 落胆: thất vọng, nản lòng.\n✗ 落第: thi trượt, lưu ban.\n✗ 落選: trượt bầu cử.\n✗ 落下: rơi xuống."),
 ("bunmyaku", "Cụm cố định", "大方の 予想に（　）、試合は 一方的な 展開と なった。", ["反して", "対して", "沿って", "応じて"],
  "Trái với dự đoán của đa số, trận đấu diễn ra một chiều.",
  "✓ 予想に反して: trái với dự đoán.\n✗ 対して / 沿って / 応じて: đối với / theo / tùy theo."),
 ("iikae", "Tính từ", "彼は [ぞんざいな] 口調で 答えた。", ["乱暴で 丁寧で ない", "静かで 落ち着いた", "明るく 元気な", "自信の ない"],
  "Anh ta trả lời bằng giọng cộc lốc.",
  "✓ ぞんざい: cẩu thả, thiếu lịch sự = 乱暴で丁寧でない."),
 ("iikae", "Phó từ", "計画は [おおむね] 順調だ。", ["だいたい", "まったく", "ほとんど", "ぎりぎり"],
  "Kế hoạch nhìn chung là suôn sẻ.",
  "✓ おおむね（概ね）: nhìn chung, đại khái = だいたい.\n✗ まったく: hoàn toàn.\n✗ ほとんど: hầu hết (nghĩa gần nhưng nhấn mức độ khác).\n✗ ぎりぎり: sát nút."),
 ("iikae", "Động từ bị động", "長年の 努力が [報われた]。", ["結果に つながった", "無駄に なった", "人に 知られた", "終わった"],
  "Nỗ lực nhiều năm đã được đền đáp.",
  "✓ 報われる: được đền đáp = dẫn đến kết quả.\n✗ 無駄になった: uổng phí – trái nghĩa."),
 ("iikae", "Phó từ cổ", "彼は [やにわに] 立ち上がった。", ["突然", "ゆっくり", "ようやく", "仕方なく"],
  "Anh ta bất thình lình đứng bật dậy.",
  "✓ やにわに: đột ngột = 突然."),
 ("bunpou", "〜を通り越して", "彼の 失礼な 態度には、怒り（　）呆れて しまった。", ["を通り越して", "をもって", "をよそに", "に即して"],
  "Thái độ vô lễ của anh ta khiến tôi vượt cả mức tức giận mà sang ngán ngẩm.",
  "✓ 〜を通り越して: vượt quá mức (chuyển sang trạng thái mạnh hơn).\n✗ をもって / をよそに / に即して: không tạo nghĩa ‘vượt quá’."),
 ("bunpou", "〜たる者", "大臣（　）者が、そのような 発言を するべきでは ない。", ["たる", "ゆえの", "ならではの", "がてら"],
  "Người ở cương vị bộ trưởng không nên phát ngôn như thế.",
  "✓ Nたる者: người ở cương vị N (phải xứng đáng).\n✗ ゆえの: vì.\n✗ ならではの: chỉ có ở.\n✗ がてら: nhân tiện."),
 ("bunpou", "〜にあたって", "新製品の 発売（　）、記者会見が 開かれた。", ["にあたって", "にひきかえ", "をよそに", "いかんで"],
  "Nhân dịp ra mắt sản phẩm mới, một buổi họp báo đã được tổ chức.",
  "✓ 〜にあたって: nhân dịp, khi (sự kiện quan trọng).\n✗ にひきかえ: trái ngược với.\n✗ をよそに: bất chấp.\n✗ いかんで: tùy theo."),
 ("bunpou", "〜をおして", "彼は 体調不良（　）、試合に 出場した。", ["をおして", "にひきかえ", "に至っては", "とあいまって"],
  "Bất chấp sức khỏe không tốt, anh ấy vẫn ra sân thi đấu.",
  "✓ 〜をおして（押して）: bất chấp (khó khăn của bản thân).\n✗ にひきかえ: trái ngược với.\n✗ に至っては: đến mức như.\n✗ とあいまって: kết hợp với."),
 ("bunpou", "〜極まりない", "雨の 日の 長時間の 外出は 面倒（　）。", ["極まりない", "にかたくない", "ではすまない", "に足る"],
  "Ra ngoài lâu vào ngày mưa thật vô cùng phiền phức.",
  "✓ Adj な ＋ 極まりない: vô cùng.\n✗ にかたくない: không khó để (想像).\n✗ ではすまない: không thể cho qua.\n✗ に足る: đáng để."),
 ("bunpou", "〜といったらない", "子どもでも できる 問題が 解けない とは、情けない（　）。", ["ったらない", "ばかりか", "までだ", "ものを"],
  "Bài trẻ con làm được mà không giải được, thật không còn gì đáng xấu hổ hơn.",
  "✓ Adj ＋ (と)いったらない / ったらない: không gì sánh bằng (cảm xúc mạnh).\n✗ ばかりか / までだ / ものを: không đi với 情けない theo nghĩa này."),
 ("bunpou", "〜ようが", "雨が 降ろう（　）、試合は 予定どおり 行う。", ["が", "ものの", "ので", "のに"],
  "Dù trời có mưa, trận đấu vẫn diễn ra theo kế hoạch.",
  "✓ V(よ)うが: dù có… đi nữa (cũng tương tự 〜ようと).\n✗ ものの / ので / のに: không đi với thể ý chí."),
 ("narabe", "Sắp xếp câu", "この ＿＿ ＿＿ ★ ＿＿ 一歩で ある。", ["ながらも", "成功は", "小さい", "大きな"],
  "Thành công này tuy nhỏ nhưng là một bước tiến lớn.",
  "Thứ tự đúng: この 成功は / 小さい / ★ながらも / 大きな 一歩である。\n• Adj い ＋ ながらも: tuy… nhưng.\nVị trí ★ là ながらも."),
 ("narabe", "Sắp xếp câu", "彼女は ＿＿ ＿＿ ★ ＿＿ 涙を 流した。", ["うれしさの", "合格の", "知らせに", "あまり"],
  "Nhận tin đỗ, cô ấy vui quá mà rơi nước mắt.",
  "Thứ tự đúng: 彼女は 合格の / 知らせに / ★うれしさの / あまり 涙を流した。\n• Nのあまり: vì quá….\nVị trí ★ là うれしさの."),
]
