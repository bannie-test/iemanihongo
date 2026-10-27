# JLPT N3 mock tests. Each question:
# (section, tag, sentence, [correct, distractor, distractor, distractor],
#  Vietnamese translation, Vietnamese explanation)
# Sections: kanji (読み), hyoki (表記), bunmyaku (文脈規定), iikae (言い換え),
#           bunpou (文法形式), narabe (文の組み立て, ★ marks the asked slot).
# [ ] marks the underlined word; （　） is the blank. The first option is the
# correct one; the app shuffles options deterministically.

TEST1 = [
 ("kanji", "Âm đục / âm trong", "彼の[意見]に賛成します。", ["いけん", "いげん", "いっけん", "いかん"],
  "Tôi tán thành ý kiến của anh ấy.",
  "✓ 意見（いけん – Ý KIẾN）: ý kiến, quan điểm. 見 đọc âm On là けん.\n"
  "✗ いげん: sai vì thêm âm đục; 見 không đọc là げん.\n"
  "✗ いっけん: là 一見（nhất kiến）‘thoạt nhìn’, khác từ.\n"
  "✗ いかん: là 遺憾（di hám）‘đáng tiếc’."),
 ("kanji", "Âm On của 人", "この町の[人口]は年々減っている。", ["じんこう", "にんこう", "じんく", "ひとくち"],
  "Dân số của thị trấn này giảm dần qua từng năm.",
  "✓ 人口（じんこう – NHÂN KHẨU）: dân số. 人 có hai âm On じん/にん; trong từ này đọc じん.\n"
  "✗ にんこう: chọn sai âm On của 人.\n"
  "✗ じんく: 口 đọc là こう (âm On), không phải く.\n"
  "✗ ひとくち: là 一口 ‘một miếng/một ngụm’."),
 ("kanji", "Âm đục / âm trong", "道が[混雑]していて、遅れました。", ["こんざつ", "こんさつ", "こうざつ", "こんぞう"],
  "Đường đông đúc nên tôi đã đến muộn.",
  "✓ 混雑（こんざつ – HỖN TẠP）: đông đúc, ùn tắc. 雑 đọc ざつ (có âm đục).\n"
  "✗ こんさつ: thiếu âm đục.\n"
  "✗ こうざつ: thêm trường âm sai ở 混（こん）.\n"
  "✗ こんぞう: 雑 có âm ぞう trong 雑巾（ぞうきん）nhưng không dùng ở đây."),
 ("kanji", "Âm Kun của động từ", "新しい仕事に[慣れる]まで時間がかかった。", ["なれる", "ねれる", "なける", "はれる"],
  "Phải mất thời gian cho đến khi quen với công việc mới.",
  "✓ 慣れる（なれる – QUÁN）: quen với. Mẫu: ～に慣れる.\n"
  "✗ ねれる: không phải cách đọc của 慣.\n"
  "✗ なける: là 泣ける ‘cảm động muốn khóc’.\n"
  "✗ はれる: là 晴れる ‘trời quang’ hoặc 腫れる ‘sưng’."),
 ("kanji", "Trường âm", "机の上を[整理]してください。", ["せいり", "せり", "せいりょう", "しょうり"],
  "Hãy sắp xếp gọn gàng trên bàn.",
  "✓ 整理（せいり – CHỈNH LÝ）: sắp xếp, dọn dẹp. 整 đọc せい (có trường âm い).\n"
  "✗ せり: thiếu trường âm.\n"
  "✗ せいりょう: 理 đọc り, không có âm ょう.\n"
  "✗ しょうり: là 勝利 ‘thắng lợi’."),
 ("kanji", "Cách đọc đặc biệt", "彼女は[笑顔]であいさつした。", ["えがお", "わらいがお", "えかお", "しょうがん"],
  "Cô ấy chào hỏi với khuôn mặt tươi cười.",
  "✓ 笑顔（えがお – TIẾU NHAN）: khuôn mặt tươi cười. Đây là cách đọc đặc biệt, phải học thuộc.\n"
  "✗ わらいがお: ghép âm Kun theo suy đoán, không tồn tại.\n"
  "✗ えかお: 顔 khi đứng sau biến thành がお (âm đục – rendaku).\n"
  "✗ しょうがん: đọc theo âm On, không dùng."),
 ("hyoki", "Chữ trông giống nhau", "毎朝、[しんぶん]を読みます。", ["新聞", "新問", "親聞", "新関"],
  "Mỗi sáng tôi đều đọc báo.",
  "✓ 新聞（TÂN VĂN）: báo. 聞 có bộ 耳 (tai) bên trong cửa 門 – ‘nghe’.\n"
  "✗ 新問: 問（VẤN）có 口 bên trong – ‘hỏi’.\n"
  "✗ 親聞: 親（THÂN）đọc しん nhưng nghĩa ‘thân thiết, cha mẹ’.\n"
  "✗ 新関: 関（QUAN）‘liên quan, cửa ải’, đọc かん."),
 ("hyoki", "Chữ cùng âm", "荷物を[あずけて]から買い物に行きます。", ["預けて", "予けて", "頂けて", "領けて"],
  "Tôi gửi hành lý rồi đi mua sắm.",
  "✓ 預ける（DỰ）: gửi, ký gửi (hành lý, tiền).\n"
  "✗ 予: cũng đọc よ (DỰ – dự định) nhưng không dùng cho động từ あずける.\n"
  "✗ 頂: là 頂く（いただく）‘nhận’.\n"
  "✗ 領（LĨNH）: lãnh thổ, nhận lãnh – không phải あずける."),
 ("hyoki", "Chữ cùng âm", "会議の[じゅんび]をしてください。", ["準備", "順備", "純備", "準傭"],
  "Hãy chuẩn bị cho cuộc họp.",
  "✓ 準備（CHUẨN BỊ）: chuẩn bị.\n"
  "✗ 順（THUẬN）: thứ tự (順番) – cũng đọc じゅん nhưng sai chữ.\n"
  "✗ 純（THUẦN）: thuần khiết (純粋).\n"
  "✗ 傭（DONG）: thuê mướn – trông giống 備 nhưng sai."),
 ("hyoki", "Động từ đồng âm", "父は駅前の銀行に[つとめて]います。", ["勤めて", "努めて", "務めて", "勉めて"],
  "Bố tôi làm việc ở ngân hàng trước nhà ga.",
  "✓ 勤める（CẦN）: làm việc tại một nơi (会社に勤める).\n"
  "✗ 努める（NỖ）: nỗ lực (解決に努める).\n"
  "✗ 務める（VỤ）: đảm nhận vai trò (司会を務める).\n"
  "✗ 勉める: không dùng; 勉 trong 勉強."),
 ("hyoki", "Chữ trông giống nhau", "この部屋は[せまい]です。", ["狭い", "挟い", "峡い", "侠い"],
  "Căn phòng này chật hẹp.",
  "✓ 狭い（HIỆP – bộ khuyển 犭）: hẹp.\n"
  "✗ 挟（bộ thủ 扌）: kẹp (挟む).\n"
  "✗ 峡（bộ sơn 山）: eo núi (海峡).\n"
  "✗ 侠（bộ nhân 亻）: hiệp khách. Cả bốn chữ đều đọc きょう nên rất dễ nhầm."),
 ("bunmyaku", "Từ vựng sự việc", "電車が遅れたので、会議に（　）しまった。", ["遅刻して", "延期して", "中止して", "停止して"],
  "Vì tàu đến trễ nên tôi đã đến cuộc họp muộn.",
  "✓ 遅刻する: đến muộn (người làm chủ thể). Hợp với ‘tàu trễ’.\n"
  "✗ 延期する: hoãn lại (sự kiện) – không dùng với chủ thể là ‘tôi đến họp’.\n"
  "✗ 中止する: hủy bỏ.\n"
  "✗ 停止する: dừng (máy móc, hoạt động)."),
 ("bunmyaku", "Từ gần nghĩa", "この服は大きすぎるので、もう少し小さいサイズと（　）もらえますか。", ["交換して", "交代して", "両替して", "変更して"],
  "Áo này rộng quá, có thể đổi giúp tôi sang cỡ nhỏ hơn được không?",
  "✓ 交換する: đổi (vật này lấy vật khác) – AとBを交換する.\n"
  "✗ 交代する: thay phiên, thay người.\n"
  "✗ 両替する: đổi tiền.\n"
  "✗ 変更する: thay đổi kế hoạch, nội dung – không đi với ‘と’ chỉ vật đổi."),
 ("bunmyaku", "Phó từ đi với phủ định", "試験の結果が心配で、昨夜は（　）眠れなかった。", ["なかなか", "ぐっすり", "しっかり", "すっかり"],
  "Vì lo lắng về kết quả thi nên tối qua tôi mãi không ngủ được.",
  "✓ なかなか＋phủ định: mãi mà không… (なかなか眠れない).\n"
  "✗ ぐっすり: ngủ say – đi với câu khẳng định (ぐっすり眠った).\n"
  "✗ しっかり: chắc chắn, đầy đủ.\n"
  "✗ すっかり: hoàn toàn (すっかり忘れた)."),
 ("bunmyaku", "Kết hợp từ (collocation)", "彼はいつも約束の時間を（　）ので、信頼されている。", ["守る", "破る", "過ごす", "済ませる"],
  "Anh ấy luôn giữ đúng giờ hẹn nên được tin tưởng.",
  "✓ 時間を守る: giữ đúng giờ – lý do để được tin tưởng.\n"
  "✗ 破る: phá (約束を破る = thất hứa) – trái nghĩa với ‘được tin tưởng’.\n"
  "✗ 過ごす: trải qua (thời gian).\n"
  "✗ 済ませる: làm xong."),
 ("bunmyaku", "Động từ trạng thái", "料理が（　）ので、電子レンジで温め直しました。", ["冷めた", "枯れた", "溶けた", "乾いた"],
  "Món ăn đã nguội nên tôi hâm lại bằng lò vi sóng.",
  "✓ 冷める: nguội đi (đồ nóng trở nên nguội) – hợp với ‘hâm lại’.\n"
  "✗ 枯れる: (cây) héo.\n"
  "✗ 溶ける: tan chảy.\n"
  "✗ 乾く: khô."),
 ("bunmyaku", "Từ gần nghĩa", "駅までの（　）を教えてください。", ["道順", "手順", "順番", "番号"],
  "Hãy chỉ cho tôi đường đi đến nhà ga.",
  "✓ 道順: lộ trình, đường đi.\n"
  "✗ 手順: trình tự thao tác (làm việc gì đó).\n"
  "✗ 順番: lượt, thứ tự.\n"
  "✗ 番号: số hiệu."),
 ("iikae", "Từ đồng nghĩa", "この問題は[やさしい]。", ["簡単だ", "親切だ", "難しい", "大切だ"],
  "Bài này dễ.",
  "✓ やさしい ở đây là 易しい ‘dễ’ = 簡単だ.\n"
  "✗ 親切だ: tốt bụng – nghĩa của 優しい, không hợp với ‘bài toán’. Đây là bẫy đồng âm.\n"
  "✗ 難しい: khó (trái nghĩa).\n"
  "✗ 大切だ: quan trọng."),
 ("iikae", "Phó từ tần suất", "彼は[たまに]ジムに行く。", ["ときどき", "いつも", "よく", "ぜんぜん"],
  "Thỉnh thoảng anh ấy đi tập gym.",
  "✓ たまに: thỉnh thoảng, đôi khi = ときどき (tần suất thấp).\n"
  "✗ いつも: lúc nào cũng.\n"
  "✗ よく: thường xuyên.\n"
  "✗ ぜんぜん: hoàn toàn không (đi với phủ định)."),
 ("iikae", "Diễn đạt tương đương", "会議は[延期になった]。", ["別の日に行うことになった", "中止になった", "予定より早く始まった", "予定どおり行われた"],
  "Cuộc họp đã bị hoãn.",
  "✓ 延期: dời sang ngày khác = 別の日に行う.\n"
  "✗ 中止: hủy hẳn – khác với hoãn.\n"
  "✗ Bắt đầu sớm hơn dự định: không liên quan.\n"
  "✗ Diễn ra đúng kế hoạch: trái nghĩa."),
 ("iikae", "Từ đồng nghĩa", "子どものころ、よく母に[しかられた]。", ["怒られた", "ほめられた", "呼ばれた", "頼まれた"],
  "Hồi nhỏ tôi hay bị mẹ mắng.",
  "✓ しかられる（叱られる）: bị mắng = 怒られる.\n"
  "✗ ほめられる: được khen (trái nghĩa).\n"
  "✗ 呼ばれる: được gọi.\n"
  "✗ 頼まれる: được nhờ."),
 ("bunpou", "Ngữ pháp: ～ため（nguyên nhân）", "大雨が降った（　）、試合は中止になった。", ["ため", "ように", "のに", "ながら"],
  "Vì mưa lớn nên trận đấu đã bị hủy.",
  "✓ ～ため（に）: vì (nguyên nhân, văn trang trọng). 降ったため＝降ったので.\n"
  "✗ ように: để mà / như là – không chỉ nguyên nhân.\n"
  "✗ のに: mặc dù – dùng khi kết quả trái kỳ vọng; ở đây mưa → hủy là hợp lý.\n"
  "✗ ながら: vừa… vừa…, cần thể ます bỏ ます (降りながら)."),
 ("bunpou", "Ngữ pháp: ～たばかり", "日本に来た（　）のころは、日本語が全然わからなかった。", ["ばかり", "ところ", "まま", "うち"],
  "Hồi mới đến Nhật, tôi hoàn toàn không hiểu tiếng Nhật.",
  "✓ Vた＋ばかり: vừa mới (cảm giác của người nói). 来たばかりのころ = thời mới đến.\n"
  "✗ たところ: ‘vừa xong’ tại đúng thời điểm, không đi với のころ.\n"
  "✗ まま: giữ nguyên trạng thái.\n"
  "✗ うち: trong lúc – không dùng với Vた ở đây."),
 ("bunpou", "Ngữ pháp: ～さえ", "子ども（　）できる簡単な問題だ。", ["でさえ", "にとって", "として", "によって"],
  "Đây là bài đơn giản mà ngay cả trẻ con cũng làm được.",
  "✓ Nでさえ: ngay cả N (nêu ví dụ cực đoan).\n"
  "✗ にとって: đối với (quan điểm của ai).\n"
  "✗ として: với tư cách là.\n"
  "✗ によって: tùy theo / bởi."),
 ("bunpou", "Ngữ pháp: ～わけにはいかない", "明日は大事な試験だから、今夜はゲームをする（　）。", ["わけにはいかない", "わけではない", "はずがない", "ことはない"],
  "Ngày mai có kỳ thi quan trọng nên tối nay không thể chơi game được.",
  "✓ Vる＋わけにはいかない: không thể làm (vì lý do đạo lý, hoàn cảnh), dù muốn.\n"
  "✗ わけではない: không hẳn là – phủ định một phần.\n"
  "✗ はずがない: không thể nào (suy đoán khả năng).\n"
  "✗ ことはない: không cần phải."),
 ("bunpou", "Ngữ pháp: ～はずだ", "この薬を飲めば、熱が下がる（　）です。", ["はず", "べき", "ため", "ところ"],
  "Nếu uống thuốc này thì chắc chắn sẽ hạ sốt.",
  "✓ はずだ: chắc chắn là (dự đoán có căn cứ).\n"
  "✗ べきだ: nên (nghĩa vụ) – ‘sốt nên hạ’ không tự nhiên.\n"
  "✗ ためです: là để/vì – không hợp.\n"
  "✗ ところです: sắp/đang – không đi với ～ば."),
 ("bunpou", "Bị động / sai khiến", "先生に（　）、レポートを書き直した。", ["言われて", "言わせて", "言って", "言わせられて"],
  "Bị thầy nhắc nên tôi đã viết lại bài báo cáo.",
  "✓ 言われる（bị động）: bị/được thầy nói → nên viết lại.\n"
  "✗ 言わせて（sai khiến）: bắt thầy nói – vô lý.\n"
  "✗ 言って: ‘nói với thầy rồi…’ – không giải thích lý do viết lại.\n"
  "✗ 言わせられて（sai khiến bị động）: bị bắt phải nói – sai nghĩa."),
 ("bunpou", "Ngữ pháp: ～ために（mục đích）", "健康の（　）、毎朝ジョギングをしている。", ["ために", "ように", "せいで", "おかげで"],
  "Tôi chạy bộ mỗi sáng vì sức khỏe.",
  "✓ Nの＋ために: vì mục đích N.\n"
  "✗ Nのように: giống như N.\n"
  "✗ せいで: do (nguyên nhân xấu).\n"
  "✗ おかげで: nhờ có (nguyên nhân tốt) – ‘nhờ sức khỏe mà chạy bộ’ không hợp."),
 ("narabe", "Sắp xếp câu", "あの店の ＿＿ ＿＿ ★ ＿＿ 行ってみたい。", ["と聞いたので", "ケーキは", "おいしい", "一度"],
  "Nghe nói bánh ở quán đó ngon nên tôi muốn đi thử một lần.",
  "Thứ tự đúng: あの店の ケーキは / おいしい / ★と聞いたので / 一度 行ってみたい。\n"
  "• ケーキは おいしい: chủ đề + tính từ.\n"
  "• と聞いた: trích dẫn điều nghe được → ので: nên.\n"
  "• 一度 bổ nghĩa cho 行ってみたい.\n"
  "Vị trí ★ là と聞いたので."),
 ("narabe", "Sắp xếp câu", "仕事が ＿＿ ＿＿ ★ ＿＿ 帰れない。", ["会社", "終わる", "までは", "から"],
  "Cho đến khi xong việc thì tôi không thể rời công ty về nhà.",
  "Thứ tự đúng: 仕事が 終わる / までは / ★会社 / から 帰れない。\n"
  "• Vる＋までは: cho đến khi.\n"
  "• 会社から帰る: về từ công ty (から chỉ điểm xuất phát).\n"
  "Vị trí ★ là 会社."),
]

TEST2 = [
 ("kanji", "Cách đọc đặc biệt", "彼は[正直]な人です。", ["しょうじき", "せいちょく", "しょうちょく", "せいじき"],
  "Anh ấy là người thật thà.",
  "✓ 正直（しょうじき – CHÍNH TRỰC）: thật thà. 正 có hai âm On せい/しょう, 直 có ちょく/じき; tổ hợp đúng là しょう＋じき.\n"
  "✗ せいちょく / しょうちょく / せいじき: ghép sai âm On, cần học thuộc từ này."),
 ("kanji", "Âm ngắt (っ)", "毎日、[日記]を書いています。", ["にっき", "にちき", "にき", "ひき"],
  "Tôi viết nhật ký mỗi ngày.",
  "✓ 日記（にっき – NHẬT KÝ）: にち＋き → にっき (âm ち biến thành っ).\n"
  "✗ にちき: không biến âm.\n"
  "✗ にき: thiếu âm ngắt っ.\n"
  "✗ ひき: đọc 日 theo âm Kun ひ – sai."),
 ("kanji", "Âm đục / âm trong", "交通[事故]に気をつけてください。", ["じこ", "じご", "しこ", "じっこ"],
  "Hãy cẩn thận tai nạn giao thông.",
  "✓ 事故（じこ – SỰ CỐ）: tai nạn.\n"
  "✗ じご: 故 không có âm đục ở đây (じご là 事後 ‘sau sự việc’).\n"
  "✗ しこ: 事 đọc じ.\n"
  "✗ じっこ: không có âm ngắt."),
 ("kanji", "Âm On / âm Kun", "夏休みに[海外]旅行をした。", ["かいがい", "うみがい", "かいそと", "かいかい"],
  "Kỳ nghỉ hè tôi đã đi du lịch nước ngoài.",
  "✓ 海外（かいがい – HẢI NGOẠI）: nước ngoài. Cả hai chữ đọc âm On; 外 đọc がい.\n"
  "✗ うみがい: 海 đọc âm Kun うみ – sai.\n"
  "✗ かいそと: 外 đọc âm Kun そと – sai.\n"
  "✗ かいかい: thiếu âm đục."),
 ("kanji", "Âm Kun của động từ", "部屋の電気を[消して]ください。", ["けして", "きえして", "しょうして", "けっして"],
  "Hãy tắt điện trong phòng.",
  "✓ 消す（けす – TIÊU）: tắt (tha động từ) → 消して.\n"
  "✗ きえして: lẫn với 消える（きえる）– tự động từ ‘tắt, biến mất’.\n"
  "✗ しょうして: âm On しょう dùng trong 消化, 消防.\n"
  "✗ けっして: là 決して ‘tuyệt đối không’."),
 ("kanji", "Âm On / âm Kun", "友達からの[返事]を待っている。", ["へんじ", "へんごと", "かえじ", "へんし"],
  "Tôi đang đợi hồi âm của bạn.",
  "✓ 返事（へんじ – PHẢN SỰ）: trả lời, hồi âm.\n"
  "✗ へんごと: 事 đọc âm Kun ごと (như 仕事) – sai ở từ này.\n"
  "✗ かえじ: 返 đọc âm Kun かえ (返す) – sai.\n"
  "✗ へんし: thiếu âm đục."),
 ("hyoki", "Chữ trông giống nhau", "これはとても[ふくざつ]な問題だ。", ["複雑", "復雑", "腹雑", "複殺"],
  "Đây là vấn đề rất phức tạp.",
  "✓ 複雑（PHỨC TẠP）: phức tạp. 複 có bộ 衤 (áo – nhiều lớp).\n"
  "✗ 復（PHỤC – bộ 彳）: phục hồi, quay lại.\n"
  "✗ 腹（PHÚC – bộ 月）: bụng.\n"
  "✗ 殺（SÁT）: giết – sai chữ thứ hai."),
 ("hyoki", "Chữ trông giống nhau", "試験に[ごうかく]した。", ["合格", "合各", "合確", "号格"],
  "Tôi đã thi đỗ.",
  "✓ 合格（HỢP CÁCH）: đỗ, đạt.\n"
  "✗ 各: thiếu bộ 木 (各 = mỗi).\n"
  "✗ 確（XÁC）: chắc chắn – đọc かく nhưng sai chữ.\n"
  "✗ 号（HIỆU）: số hiệu."),
 ("hyoki", "Động từ đồng âm", "駅の前で友達と[わかれた]。", ["別れた", "分かれた", "判れた", "解れた"],
  "Tôi chia tay bạn trước nhà ga.",
  "✓ 別れる（BIỆT）: chia tay, rời xa (người với người).\n"
  "✗ 分かれる（PHÂN）: chia ra, tách ra (道が分かれる, 意見が分かれる).\n"
  "✗ 判れる / 解れる: cách viết cũ hoặc không dùng cho nghĩa này."),
 ("hyoki", "Chữ trông giống nhau", "インターネットで新しいパソコンを[ちゅうもん]した。", ["注文", "柱文", "往文", "注問"],
  "Tôi đã đặt mua máy tính mới qua mạng.",
  "✓ 注文（CHÚ VĂN）: đặt hàng, gọi món.\n"
  "✗ 柱（TRỤ – bộ 木）: cái cột.\n"
  "✗ 往（VÃNG – bộ 彳）: đi.\n"
  "✗ 問: hỏi – đọc もん nhưng sai chữ."),
 ("hyoki", "Động từ đồng âm", "暑いので窓を[あけて]ください。", ["開けて", "空けて", "明けて", "閉けて"],
  "Trời nóng, hãy mở cửa sổ ra.",
  "✓ 開ける（KHAI）: mở (cửa, hộp).\n"
  "✗ 空ける（KHÔNG）: để trống (席を空ける).\n"
  "✗ 明ける（MINH）: (trời) sáng, (năm) mới.\n"
  "✗ 閉（BẾ）: đóng – trái nghĩa, đọc しめる."),
 ("bunmyaku", "Tự động từ / tha động từ", "財布を（　）しまったので、交番に届けた。", ["なくして", "なくなって", "落ちて", "消えて"],
  "Vì làm mất ví nên tôi đã đến đồn cảnh sát trình báo.",
  "✓ なくす: làm mất (tha động từ, đi với を) → 財布をなくした.\n"
  "✗ なくなる: bị mất (tự động từ, dùng 財布がなくなる).\n"
  "✗ 落ちる: rơi (tự động từ); phải dùng 落とす với を.\n"
  "✗ 消える: biến mất (tự động từ)."),
 ("bunmyaku", "Thể sai khiến", "彼はいつも冗談を言って、みんなを（　）。", ["笑わせる", "笑われる", "笑う", "笑える"],
  "Anh ấy lúc nào cũng nói đùa, làm mọi người cười.",
  "✓ 笑わせる（sai khiến）: làm cho ai cười – みんなを笑わせる.\n"
  "✗ 笑われる（bị động）: bị cười nhạo.\n"
  "✗ 笑う: tự mình cười – không đi với みんなを.\n"
  "✗ 笑える: có thể cười / buồn cười."),
 ("bunmyaku", "Phó từ đi với khẳng định", "この料理は（　）辛くて、食べられなかった。", ["あまりにも", "めったに", "決して", "ちっとも"],
  "Món này cay quá mức nên tôi không ăn được.",
  "✓ あまりにも＋Adj: quá mức – kéo theo kết quả ‘không ăn được’.\n"
  "✗ めったに, 決して, ちっとも: luôn đi với phủ định ngay sau (めったに辛くない), không hợp với 辛くて."),
 ("bunmyaku", "Diễn đạt cố định", "大事な書類なので、（　）コピーを取っておいた。", ["念のため", "せっかく", "わざと", "たまたま"],
  "Vì là giấy tờ quan trọng nên tôi đã photo sẵn cho chắc.",
  "✓ 念のため: để cho chắc, phòng khi.\n"
  "✗ せっかく: đã mất công (thường kèm tiếc nuối).\n"
  "✗ わざと: cố ý (làm điều không nên).\n"
  "✗ たまたま: tình cờ."),
 ("bunmyaku", "Từ ghép với 見", "空港まで友達を（　）に行った。", ["見送り", "見学", "見物", "見舞い"],
  "Tôi ra sân bay tiễn bạn.",
  "✓ 見送り: tiễn (ai đó lên đường).\n"
  "✗ 見学: tham quan học hỏi (nhà máy, trường).\n"
  "✗ 見物: ngắm cảnh, xem.\n"
  "✗ 見舞い: thăm người ốm."),
 ("bunmyaku", "Từ vựng trạng thái", "地震のときは、あわてずに（　）行動してください。", ["落ち着いて", "急いで", "驚いて", "ふざけて"],
  "Khi động đất, đừng hoảng hốt mà hãy hành động bình tĩnh.",
  "✓ 落ち着いて: bình tĩnh – phù hợp với あわてずに.\n"
  "✗ 急いで: vội vàng – mâu thuẫn với ‘đừng hoảng’.\n"
  "✗ 驚いて: ngạc nhiên.\n"
  "✗ ふざけて: đùa giỡn."),
 ("iikae", "Phó từ mức độ", "約束をしていたことを[すっかり]忘れていた。", ["完全に", "少し", "すぐに", "もう一度"],
  "Tôi đã quên sạch là có hẹn.",
  "✓ すっかり: hoàn toàn = 完全に.\n"
  "✗ 少し: một chút.\n"
  "✗ すぐに: ngay lập tức.\n"
  "✗ もう一度: thêm một lần."),
 ("iikae", "Từ đồng nghĩa", "雨のため、旅行の計画を[中止した]。", ["やめた", "始めた", "続けた", "変えた"],
  "Vì mưa nên chúng tôi đã hủy kế hoạch du lịch.",
  "✓ 中止する: hủy bỏ = やめる.\n"
  "✗ 始める: bắt đầu.\n"
  "✗ 続ける: tiếp tục.\n"
  "✗ 変える: thay đổi (vẫn thực hiện nhưng khác đi)."),
 ("iikae", "Từ đồng nghĩa", "彼女は[きちんとした]人だ。", ["ちゃんとした", "明るい", "静かな", "やさしい"],
  "Cô ấy là người chỉn chu, đàng hoàng.",
  "✓ きちんとした ≈ ちゃんとした: nghiêm chỉnh, gọn gàng, đúng mực.\n"
  "✗ 明るい: vui vẻ.\n"
  "✗ 静かな: trầm lặng.\n"
  "✗ やさしい: hiền."),
 ("iikae", "Phó từ", "出かけようとしたら、[あいにく]雨が降ってきた。", ["運悪く", "運よく", "突然", "久しぶりに"],
  "Vừa định ra ngoài thì không may trời đổ mưa.",
  "✓ あいにく: không may, tiếc là = 運悪く.\n"
  "✗ 運よく: may mắn (trái nghĩa).\n"
  "✗ 突然: đột nhiên – chỉ thời điểm, không có ý ‘không may’.\n"
  "✗ 久しぶりに: lâu lắm mới."),
 ("bunpou", "Ngữ pháp: ～わけだ", "「日本語が上手ですね。」「10年も日本に住んでいたんです。」「なるほど、上手な（　）ですね。」", ["わけ", "べき", "ところ", "もの"],
  "‘Tiếng Nhật của bạn giỏi nhỉ.’ ‘Tôi đã sống ở Nhật 10 năm.’ ‘Thảo nào giỏi thế.’",
  "✓ ～わけだ: thảo nào, hóa ra là vậy (kết luận hợp lý từ thông tin vừa nghe). Thường đi với なるほど.\n"
  "✗ べき: nên.\n"
  "✗ ところ: thời điểm.\n"
  "✗ ものだ: lẽ thường, hồi tưởng – không hợp."),
 ("bunpou", "Ngữ pháp: ～のに", "このかばんは高かった（　）、すぐに壊れてしまった。", ["のに", "ので", "ため", "から"],
  "Cái túi này đắt vậy mà hỏng ngay.",
  "✓ ～のに: vậy mà (kết quả trái với kỳ vọng, có ý bất mãn).\n"
  "✗ ので / ため / から: chỉ nguyên nhân – ‘vì đắt nên hỏng’ là vô lý."),
 ("bunpou", "Ngữ pháp: ～うちに", "暗くならない（　）、家に帰りましょう。", ["うちに", "前に", "ところに", "ばかりに"],
  "Hãy về nhà trước khi trời tối.",
  "✓ Vない＋うちに: trong khi chưa… (trước khi tình trạng thay đổi).\n"
  "✗ 前に: phải dùng thể từ điển: 暗くなる前に.\n"
  "✗ ところに: đúng lúc (có người đến…).\n"
  "✗ ばかりに: chỉ vì (dẫn đến kết quả xấu)."),
 ("bunpou", "Ngữ pháp: ～まま", "テレビをつけた（　）寝てしまった。", ["まま", "ばかり", "ところ", "うち"],
  "Tôi đã ngủ quên trong khi vẫn để ti vi bật.",
  "✓ Vた＋まま: giữ nguyên trạng thái mà làm việc khác.\n"
  "✗ たばかり: vừa mới.\n"
  "✗ たところ: vừa xong.\n"
  "✗ うち: trong lúc – không đi với Vた ở đây."),
 ("bunpou", "Kính ngữ / cho nhận", "先生のお宅に伺ったとき、奥様に駅まで車で送って（　）。", ["いただきました", "くださいました", "さしあげました", "なさいました"],
  "Khi đến thăm nhà thầy, tôi được phu nhân đưa ra ga bằng ô tô.",
  "✓ Aに Vて いただく: được A làm cho (khiêm nhường của もらう). Có 奥様に nên dùng いただく.\n"
  "✗ くださいました: phải là 奥様が送ってくださいました (dùng が).\n"
  "✗ さしあげました: tôi làm cho người khác.\n"
  "✗ なさいました: tôn kính của する."),
 ("bunpou", "Ngữ pháp: ～にもかかわらず", "彼は仕事が忙しい（　）、毎日ジムに通っている。", ["にもかかわらず", "からこそ", "せいで", "おかげで"],
  "Mặc dù công việc bận rộn, anh ấy vẫn đến phòng gym mỗi ngày.",
  "✓ ～にもかかわらず: mặc dù… nhưng vẫn.\n"
  "✗ からこそ: chính vì – ‘chính vì bận nên đi gym’ không tự nhiên.\n"
  "✗ せいで: tại vì (kết quả xấu).\n"
  "✗ おかげで: nhờ có (kết quả tốt)."),
 ("bunpou", "Ngữ pháp: ～ように言う", "医者に、お酒を（　）ように言われた。", ["飲まない", "飲まず", "飲まなくて", "飲めない"],
  "Tôi bị bác sĩ dặn là không được uống rượu.",
  "✓ Vない＋ように言われる: được dặn/nhắc là không làm gì.\n"
  "✗ 飲まず: dạng văn viết của ないで, không đi với ように.\n"
  "✗ 飲まなくて: thể て phủ định chỉ nguyên nhân.\n"
  "✗ 飲めない: không thể uống – sai nghĩa lời dặn."),
 ("narabe", "Sắp xếp câu", "この仕事は ＿＿ ＿＿ ★ ＿＿ 終わらないだろう。", ["もらわないと", "誰かに", "手伝って", "今日中に"],
  "Công việc này nếu không nhờ ai đó giúp thì chắc không xong trong hôm nay.",
  "Thứ tự đúng: この仕事は 誰かに / 手伝って / ★もらわないと / 今日中に 終わらないだろう。\n"
  "• 誰かに 手伝ってもらう: nhờ ai đó giúp.\n"
  "• ～ないと: nếu không… thì.\n"
  "• 今日中に bổ nghĩa cho 終わらない.\n"
  "Vị trí ★ là もらわないと."),
 ("narabe", "Sắp xếp câu", "駅に ＿＿ ＿＿ ★ ＿＿ 雨が降り出した。", ["いる", "向かって", "歩いて", "途中で"],
  "Trên đường đang đi bộ tới ga thì trời đổ mưa.",
  "Thứ tự đúng: 駅に 向かって / 歩いて / ★いる / 途中で 雨が降り出した。\n"
  "• 駅に向かう: hướng về ga.\n"
  "• 歩いている途中で: trong lúc đang đi bộ.\n"
  "Vị trí ★ là いる."),
]
