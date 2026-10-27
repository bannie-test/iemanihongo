# JLPT N2 mock tests. Same layout as jlpt_n3.py.

TEST1 = [
 ("kanji", "Trường âm", "新しい制度を[導入]することになった。", ["どうにゅう", "どうにゅ", "とうにゅう", "どうにゅうう"],
  "Đã quyết định đưa vào áp dụng chế độ mới.",
  "✓ 導入（どうにゅう – ĐẠO NHẬP）: đưa vào, áp dụng. 導 đọc どう (âm đục + trường âm), 入 đọc にゅう.\n"
  "✗ どうにゅ: thiếu trường âm ở 入.\n"
  "✗ とうにゅう: thiếu âm đục ở 導 (とうにゅう là 豆乳 ‘sữa đậu nành’).\n"
  "✗ どうにゅうう: thừa âm."),
 ("kanji", "Âm On", "毎月の生活費を[節約]している。", ["せつやく", "せちやく", "せいやく", "せつあく"],
  "Tôi đang tiết kiệm chi phí sinh hoạt hằng tháng.",
  "✓ 節約（せつやく – TIẾT ƯỚC）: tiết kiệm.\n"
  "✗ せちやく: 節 có âm せち chỉ trong 御節（おせち）.\n"
  "✗ せいやく: là 制約 ‘hạn chế’ hoặc 誓約 ‘lời thề’.\n"
  "✗ せつあく: 約 đọc やく."),
 ("kanji", "Âm đục / âm trong", "景気が少しずつ[回復]してきた。", ["かいふく", "かいぶく", "かいふっく", "えふく"],
  "Kinh tế đã dần dần phục hồi.",
  "✓ 回復（かいふく – HỒI PHỤC）: hồi phục.\n"
  "✗ かいぶく: thêm âm đục sai.\n"
  "✗ かいふっく: thêm âm ngắt sai.\n"
  "✗ えふく: 回 có âm え chỉ trong 回向 (ít dùng)."),
 ("kanji", "Âm Kun bộ phận cơ thể", "彼の失礼な態度には[腹]が立った。", ["はら", "むね", "こし", "かた"],
  "Tôi đã nổi giận vì thái độ vô lễ của anh ta.",
  "✓ 腹（はら – PHÚC）: bụng. 腹が立つ = tức giận (quán ngữ).\n"
  "✗ むね: 胸 ‘ngực’.\n"
  "✗ こし: 腰 ‘hông’.\n"
  "✗ かた: 肩 ‘vai’."),
 ("kanji", "Âm đục / âm trong", "詳しい資料をメールに[添付]して送ります。", ["てんぷ", "てんぶ", "そうふ", "てんぷう"],
  "Tôi sẽ gửi tài liệu chi tiết đính kèm trong email.",
  "✓ 添付（てんぷ – THIÊM PHÓ）: đính kèm. 付 sau ん biến thành ぷ.\n"
  "✗ てんぶ: sai âm đục.\n"
  "✗ そうふ: là 送付 ‘gửi đi’ – dễ nhầm vì cùng ngữ cảnh gửi tài liệu.\n"
  "✗ てんぷう: thừa trường âm."),
 ("kanji", "Âm Kun của động từ", "失敗を[恐れて]いては、何もできない。", ["おそれて", "こわれて", "おぼれて", "おくれて"],
  "Nếu cứ sợ thất bại thì chẳng làm được gì.",
  "✓ 恐れる（おそれる – KHỦNG）: sợ hãi.\n"
  "✗ こわれて: 壊れる ‘bị hỏng’.\n"
  "✗ おぼれて: 溺れる ‘chết đuối’.\n"
  "✗ おくれて: 遅れる ‘muộn’."),
 ("hyoki", "Chữ trông giống nhau", "会議で新しい[ていあん]をした。", ["提案", "堤案", "程案", "提安"],
  "Tôi đã đưa ra đề xuất mới trong cuộc họp.",
  "✓ 提案（ĐỀ ÁN）: đề xuất. 提 bộ 扌 (tay – đưa ra).\n"
  "✗ 堤（ĐÊ – bộ 土）: con đê.\n"
  "✗ 程（TRÌNH – bộ 禾）: mức độ.\n"
  "✗ 安（AN）: thiếu bộ 木 của 案."),
 ("hyoki", "Chữ cùng âm", "自然環境を[ほご]しなければならない。", ["保護", "補護", "保獲", "捕護"],
  "Phải bảo vệ môi trường tự nhiên.",
  "✓ 保護（BẢO HỘ）: bảo vệ.\n"
  "✗ 補（BỔ）: bổ sung – cũng đọc ほ.\n"
  "✗ 獲（HOẠCH）: bắt được (獲得) – trông giống 護.\n"
  "✗ 捕（BỘ）: bắt (逮捕) – cũng đọc ほ."),
 ("hyoki", "Chữ trông giống nhau", "待たされて、時間を[むだ]にしてしまった。", ["無駄", "無太", "舞駄", "無駅"],
  "Bị bắt chờ nên tôi đã lãng phí thời gian.",
  "✓ 無駄（VÔ ĐÀ）: lãng phí, vô ích.\n"
  "✗ 太: đọc た nhưng nghĩa ‘béo’ – sai.\n"
  "✗ 舞（VŨ）: múa – đọc ぶ/まい.\n"
  "✗ 駅: nhà ga – cùng bộ 馬, trông giống 駄."),
 ("hyoki", "Chữ trông giống nhau", "出張の予定を[へんこう]した。", ["変更", "変吏", "返更", "変史"],
  "Tôi đã thay đổi lịch công tác.",
  "✓ 変更（BIẾN CANH）: thay đổi.\n"
  "✗ 吏（LẠI）/ 史（SỬ）: hình dạng gần giống 更.\n"
  "✗ 返（PHẢN）: trả lại – cũng đọc へん nhưng sai nghĩa."),
 ("hyoki", "Động từ đồng âm", "事故の責任は自分が[おう]と言った。", ["負う", "追う", "折う", "織う"],
  "Anh ấy nói chính mình sẽ chịu trách nhiệm về tai nạn.",
  "✓ 負う（PHỤ）: gánh vác (責任を負う).\n"
  "✗ 追う（TRUY）: đuổi theo.\n"
  "✗ 折（CHIẾT）: đọc おる ‘gập, bẻ’.\n"
  "✗ 織（CHỨC）: đọc おる ‘dệt’."),
 ("bunmyaku", "Danh từ trừu tượng", "彼の話は（　）がなくて、何が言いたいのか分からない。", ["まとまり", "ゆとり", "しまり", "つながり"],
  "Câu chuyện của anh ấy không mạch lạc, không hiểu muốn nói gì.",
  "✓ まとまりがない: rời rạc, không mạch lạc – dẫn đến ‘không hiểu muốn nói gì’.\n"
  "✗ ゆとりがない: không có sự dư dả (thời gian, tiền).\n"
  "✗ しまりがない: lỏng lẻo, uể oải (nét mặt, tính cách).\n"
  "✗ つながりがない: không liên quan – nói về mối quan hệ giữa hai thứ, không phải cả câu chuyện."),
 ("bunmyaku", "Từ láy (畳語)", "締め切りに間に合うよう、作業を（　）進めている。", ["着々と", "堂々と", "続々と", "転々と"],
  "Chúng tôi đang tiến hành công việc từng bước vững chắc để kịp hạn.",
  "✓ 着々と: đều đặn, chắc chắn từng bước.\n"
  "✗ 堂々と: đường hoàng.\n"
  "✗ 続々と: lần lượt nối tiếp (người, vật kéo đến).\n"
  "✗ 転々と: lang bạt chỗ này chỗ khác."),
 ("bunmyaku", "Từ gần nghĩa (好～)", "新製品の売れ行きは（　）だ。", ["好調", "好評", "好意", "好物"],
  "Doanh số sản phẩm mới đang rất thuận lợi.",
  "✓ 好調: thuận lợi, tốt đẹp (tình hình, phong độ) – dùng cho 売れ行き.\n"
  "✗ 好評: được đánh giá tốt (評判) – nói về sản phẩm, không nói về ‘tình hình bán’.\n"
  "✗ 好意: thiện cảm.\n"
  "✗ 好物: món ăn yêu thích."),
 ("bunmyaku", "Từ Hán gần âm", "子どもの安全を（　）して、公園に柵を作った。", ["考慮", "遠慮", "反省", "観察"],
  "Cân nhắc đến an toàn của trẻ em, người ta đã làm hàng rào ở công viên.",
  "✓ 考慮する: cân nhắc, tính đến.\n"
  "✗ 遠慮する: ngại ngùng, từ chối khéo.\n"
  "✗ 反省する: tự kiểm điểm.\n"
  "✗ 観察する: quan sát."),
 ("bunmyaku", "Hành động", "彼は上司の指示を（　）、勝手に行動した。", ["無視して", "承知して", "尊重して", "確認して"],
  "Anh ta phớt lờ chỉ thị của cấp trên và tự ý hành động.",
  "✓ 無視する: phớt lờ – hợp với 勝手に行動した (tự tiện).\n"
  "✗ 承知する: chấp thuận, hiểu rõ.\n"
  "✗ 尊重する: tôn trọng.\n"
  "✗ 確認する: xác nhận – đều mâu thuẫn với ‘tự tiện’."),
 ("bunmyaku", "Quán ngữ cơ thể", "長時間パソコンを使っていたら、肩が（　）しまった。", ["こって", "ゆるんで", "とけて", "かれて"],
  "Dùng máy tính nhiều giờ nên tôi bị mỏi cứng vai.",
  "✓ 肩がこる: mỏi cứng vai.\n"
  "✗ ゆるむ: lỏng ra.\n"
  "✗ とける: tan chảy.\n"
  "✗ かれる: héo / khàn (声がかれる)."),
 ("iikae", "Phó từ tần suất", "彼は[たびたび]会議に遅刻する。", ["何度も", "一度も", "ずっと", "急に"],
  "Anh ấy thường xuyên đến họp muộn.",
  "✓ たびたび: nhiều lần, thường xuyên = 何度も.\n"
  "✗ 一度も: chưa lần nào (đi với phủ định).\n"
  "✗ ずっと: suốt.\n"
  "✗ 急に: đột nhiên."),
 ("iikae", "Quán ngữ", "反対が多く、計画は[白紙に戻った]。", ["最初からやり直すことになった", "完成した", "予定より早く進んだ", "成功した"],
  "Do có nhiều phản đối, kế hoạch đã trở về con số không.",
  "✓ 白紙に戻る: quay về tờ giấy trắng = làm lại từ đầu.\n"
  "✗ Các lựa chọn còn lại đều mang nghĩa tích cực, trái với ngữ cảnh ‘nhiều phản đối’."),
 ("iikae", "Cảm xúc", "毎日同じ話を聞かされて、[うんざりした]。", ["嫌になった", "感動した", "驚いた", "安心した"],
  "Ngày nào cũng phải nghe cùng một chuyện nên tôi phát ngán.",
  "✓ うんざりする: chán ngấy, phát ngán = 嫌になる.\n"
  "✗ 感動する: cảm động.\n"
  "✗ 驚く: ngạc nhiên.\n"
  "✗ 安心する: yên tâm."),
 ("iikae", "Từ Hán", "この件は[至急]対応してください。", ["大急ぎで", "慎重に", "後で", "丁寧に"],
  "Vụ này hãy xử lý gấp.",
  "✓ 至急（CHÍ CẤP）: khẩn cấp = 大急ぎで.\n"
  "✗ 慎重に: thận trọng.\n"
  "✗ 後で: để sau.\n"
  "✗ 丁寧に: cẩn thận, lịch sự."),
 ("bunpou", "Ngữ pháp: ～一方（で）", "彼女は歌手として活躍する（　）、女優としても人気がある。", ["一方で", "くせに", "からには", "わりに"],
  "Cô ấy vừa hoạt động với tư cách ca sĩ, đồng thời cũng nổi tiếng với vai trò diễn viên.",
  "✓ ～一方で: mặt khác, đồng thời (nêu hai mặt song song).\n"
  "✗ くせに: vậy mà (chê trách).\n"
  "✗ からには: một khi đã… thì phải.\n"
  "✗ わりに: so với… thì (bất ngờ)."),
 ("bunpou", "Ngữ pháp: ～以上（は）", "仕事を引き受けた（　）、最後まで責任を持ってやるべきだ。", ["以上", "とたん", "あげく", "ものの"],
  "Một khi đã nhận việc thì phải có trách nhiệm làm đến cùng.",
  "✓ Vた＋以上: một khi đã… thì (quyết tâm, nghĩa vụ), thường đi với べきだ/なければならない.\n"
  "✗ とたん: vừa… thì (sự việc bất ngờ).\n"
  "✗ あげく: sau một hồi… cuối cùng (kết quả xấu).\n"
  "✗ ものの: tuy… nhưng."),
 ("bunpou", "Ngữ pháp: ～あげく", "さんざん迷った（　）、結局何も買わなかった。", ["あげく", "うえで", "以上", "とたん"],
  "Sau khi đắn đo mãi, rốt cuộc tôi chẳng mua gì.",
  "✓ Vた＋あげく: sau một quá trình dài (vất vả)… rốt cuộc. Hay đi với 結局, さんざん.\n"
  "✗ うえで: sau khi làm A rồi mới B (có chủ đích).\n"
  "✗ 以上: một khi đã.\n"
  "✗ とたん: vừa mới… thì."),
 ("bunpou", "Ngữ pháp: ～はもちろん", "このレストランは味（　）、サービスもすばらしい。", ["はもちろん", "にしては", "に限って", "に対して"],
  "Nhà hàng này hương vị thì khỏi phải nói, dịch vụ cũng tuyệt vời.",
  "✓ Nはもちろん、～も: N thì đương nhiên, ngay cả… cũng.\n"
  "✗ にしては: so với… thì (ngạc nhiên).\n"
  "✗ に限って: riêng… thì (thường xấu).\n"
  "✗ に対して: đối với / trái lại."),
 ("bunpou", "Ngữ pháp: ～とたん（に）", "社長の姿を見た（　）、社員たちは急に真剣に働き始めた。", ["とたん", "うちに", "あげく", "以上"],
  "Vừa thấy bóng giám đốc là nhân viên đột nhiên bắt đầu làm việc nghiêm túc.",
  "✓ Vた＋とたん（に）: vừa… thì ngay lập tức (thay đổi bất ngờ).\n"
  "✗ うちに: trong lúc.\n"
  "✗ あげく: rốt cuộc.\n"
  "✗ 以上: một khi đã."),
 ("bunpou", "Ngữ pháp: ～なしには", "彼の協力（　）、このプロジェクトは成功しなかっただろう。", ["なしには", "をはじめ", "に限らず", "にとって"],
  "Nếu không có sự hợp tác của anh ấy, dự án này có lẽ đã không thành công.",
  "✓ Nなしには～ない: nếu không có N thì không thể.\n"
  "✗ をはじめ: tiêu biểu là.\n"
  "✗ に限らず: không chỉ.\n"
  "✗ にとって: đối với."),
 ("bunpou", "Kính ngữ: お忙しいところ", "お忙しい（　）、わざわざ来てくださってありがとうございます。", ["ところ", "うちに", "ばかりに", "もので"],
  "Cảm ơn anh đã cất công đến trong lúc bận rộn.",
  "✓ お忙しいところ: trong lúc (anh) đang bận – cách nói lịch sự cố định.\n"
  "✗ うちに: trong khi (còn).\n"
  "✗ ばかりに: chỉ vì.\n"
  "✗ もので: vì (giải thích lý do của bản thân)."),
 ("narabe", "Sắp xếp câu", "彼は ＿＿ ＿＿ ★ ＿＿ 、一度も会社を休んだことがない。", ["以来", "この会社に", "入社して", "10年間"],
  "Kể từ khi vào công ty này, suốt 10 năm anh ấy chưa nghỉ làm ngày nào.",
  "Thứ tự đúng: 彼は この会社に / 入社して / ★以来 / 10年間、一度も…\n"
  "• Vて＋以来: kể từ khi.\n"
  "• 10年間 bổ nghĩa cho 一度も休んだことがない.\n"
  "Vị trí ★ là 以来."),
 ("narabe", "Sắp xếp câu", "今回の失敗を ＿＿ ＿＿ ★ ＿＿ 考えるべきだ。", ["繰り返さない", "もとに", "同じミスを", "対策を"],
  "Nên dựa vào thất bại lần này để nghĩ ra biện pháp không lặp lại lỗi tương tự.",
  "Thứ tự đúng: 今回の失敗を もとに / 同じミスを / ★繰り返さない / 対策を 考えるべきだ。\n"
  "• Nをもとに: dựa trên N.\n"
  "• 同じミスを繰り返さない là mệnh đề bổ nghĩa cho 対策.\n"
  "Vị trí ★ là 繰り返さない."),
]

TEST2 = [
 ("kanji", "Trường âm", "父は[貿易]会社に勤めている。", ["ぼうえき", "ぼえき", "ぼうやく", "ぼうい"],
  "Bố tôi làm việc ở công ty thương mại.",
  "✓ 貿易（ぼうえき – MẬU DỊCH）: thương mại, xuất nhập khẩu.\n"
  "✗ ぼえき: thiếu trường âm.\n"
  "✗ ぼうやく: 易 đọc えき (dịch) hoặc い (dễ), không đọc やく.\n"
  "✗ ぼうい: 易 đọc い trong 容易, không dùng ở đây."),
 ("kanji", "Âm đục / âm trong", "その案については、もう少し[検討]が必要だ。", ["けんとう", "けんどう", "けいとう", "けんと"],
  "Về phương án đó cần xem xét thêm một chút.",
  "✓ 検討（けんとう – KIỂM THẢO）: xem xét, cân nhắc.\n"
  "✗ けんどう: là 剣道 ‘kiếm đạo’.\n"
  "✗ けいとう: là 系統 ‘hệ thống’.\n"
  "✗ けんと: thiếu trường âm."),
 ("kanji", "Âm bán đục (ぱ)", "最近、彼とは[頻繁]に連絡を取っている。", ["ひんぱん", "ひんばん", "びんぱん", "ひんはん"],
  "Gần đây tôi thường xuyên liên lạc với anh ấy.",
  "✓ 頻繁（ひんぱん – TẦN PHỒN）: thường xuyên. 繁 (はん) sau ん biến thành ぱん.\n"
  "✗ ひんばん / ひんはん: sai biến âm.\n"
  "✗ びんぱん: 頻 không có âm đục."),
 ("kanji", "Âm Kun của động từ", "会社の予算が大幅に[削られた]。", ["けずられた", "さけられた", "そられた", "きられた"],
  "Ngân sách công ty đã bị cắt giảm mạnh.",
  "✓ 削る（けずる – TƯỚC）: gọt, cắt giảm → bị động 削られる.\n"
  "✗ さける: 避ける ‘tránh’ / 裂ける ‘rách’.\n"
  "✗ そる: 剃る ‘cạo’.\n"
  "✗ きる: 切る ‘cắt’ – nghĩa gần nhưng không phải cách đọc của 削."),
 ("kanji", "Âm ngắt (っ)", "[率直]な意見を聞かせてください。", ["そっちょく", "そちょく", "りっちょく", "そつじき"],
  "Hãy cho tôi nghe ý kiến thẳng thắn.",
  "✓ 率直（そっちょく – SUẤT TRỰC）: thẳng thắn. 率 đọc そつ → そっ trước ちょく.\n"
  "✗ そちょく: thiếu âm ngắt.\n"
  "✗ りっちょく: 率 đọc りつ trong 確率, không dùng ở đây.\n"
  "✗ そつじき: 直 đọc ちょく."),
 ("kanji", "Âm Kun ghép", "詳しくは担当者に[問い合わせて]ください。", ["といあわせて", "もんあわせて", "といあせて", "とうあわせて"],
  "Chi tiết xin hãy liên hệ với người phụ trách.",
  "✓ 問い合わせる（といあわせる）: hỏi, liên hệ để hỏi thông tin.\n"
  "✗ もんあわせて: 問 đọc âm On もん – sai.\n"
  "✗ といあせて: thiếu わ.\n"
  "✗ とうあわせて: 問 đọc とう chỉ trong 問う (hỏi), không có trong từ ghép này."),
 ("hyoki", "Động từ đồng âm", "決勝戦で強豪チームに[やぶれた]。", ["敗れた", "破れた", "被れた", "彼れた"],
  "Chúng tôi đã thua đội mạnh trong trận chung kết.",
  "✓ 敗れる（BẠI）: thua trận.\n"
  "✗ 破れる（PHÁ）: rách (紙が破れる), tan vỡ (夢が破れる) – cùng âm, rất dễ nhầm.\n"
  "✗ 被（BỊ）/ 彼（BỈ）: hình dạng giống 破 nhưng không đọc やぶれる."),
 ("hyoki", "Chữ trông giống nhau", "台所はいつも[せいけつ]にしておきましょう。", ["清潔", "清結", "精潔", "晴潔"],
  "Hãy luôn giữ nhà bếp sạch sẽ.",
  "✓ 清潔（THANH KHIẾT）: sạch sẽ. Cả hai chữ có bộ 氵 (nước).\n"
  "✗ 結（KẾT）: buộc, kết – đọc けつ nhưng sai.\n"
  "✗ 精（TINH）/ 晴（TÌNH）: đọc せい nhưng sai bộ."),
 ("hyoki", "Chữ cùng âm", "この薬はすぐに[こうか]が現れる。", ["効果", "効価", "交果", "校果"],
  "Thuốc này có hiệu quả ngay.",
  "✓ 効果（HIỆU QUẢ）: hiệu quả.\n"
  "✗ 価（GIÁ）: giá trị – đọc か nhưng sai.\n"
  "✗ 交（GIAO）/ 校（HIỆU – trường）: đọc こう nhưng sai chữ."),
 ("hyoki", "Chữ trông giống nhau", "エレベーターが[こしょう]して、階段を使った。", ["故障", "故章", "固障", "古障"],
  "Thang máy bị hỏng nên tôi đã đi thang bộ.",
  "✓ 故障（CỐ CHƯỚNG）: hỏng hóc. 障 có bộ 阝 (gò đất – chướng ngại).\n"
  "✗ 章（CHƯƠNG）: chương – thiếu bộ 阝.\n"
  "✗ 固（CỐ）/ 古（CỔ）: đọc こ nhưng sai chữ."),
 ("hyoki", "Chữ trông giống nhau", "プレゼントに手紙を[そえて]渡した。", ["添えて", "沿えて", "浅えて", "漆えて"],
  "Tôi trao quà kèm theo một lá thư.",
  "✓ 添える（THIÊM）: đính kèm, thêm vào.\n"
  "✗ 沿（DUYÊN）: đọc そう ‘dọc theo’ (川に沿う).\n"
  "✗ 浅（THIỂN）: nông. ✗ 漆（TẤT）: sơn mài – chỉ giống hình dạng."),
 ("bunmyaku", "Từ Hán hành chính", "彼の提案は現実的ではないとして、（　）された。", ["却下", "撤去", "削除", "解除"],
  "Đề xuất của anh ấy bị bác bỏ vì cho là không thực tế.",
  "✓ 却下する: bác bỏ (đơn, đề xuất).\n"
  "✗ 撤去: dỡ bỏ (công trình, vật).\n"
  "✗ 削除: xóa (dữ liệu, câu chữ).\n"
  "✗ 解除: hủy bỏ (hợp đồng, cảnh báo)."),
 ("bunmyaku", "Tự động từ", "大きな地震のため、電車のダイヤが（　）。", ["乱れた", "崩れた", "散らかった", "荒れた"],
  "Do trận động đất lớn, lịch chạy tàu bị xáo trộn.",
  "✓ ダイヤが乱れる: lịch tàu bị rối loạn – kết hợp cố định.\n"
  "✗ 崩れる: sụp đổ (建物, 天気).\n"
  "✗ 散らかる: bừa bộn (phòng).\n"
  "✗ 荒れる: (biển) động, (da) sần."),
 ("bunmyaku", "Tính cách", "彼は（　）性格で、どんな人ともすぐに仲良くなれる。", ["社交的な", "消極的な", "神経質な", "保守的な"],
  "Anh ấy có tính cách hòa đồng nên dễ thân với bất kỳ ai.",
  "✓ 社交的: hòa đồng, giỏi giao tiếp.\n"
  "✗ 消極的: thụ động.\n"
  "✗ 神経質: hay lo lắng, khó tính.\n"
  "✗ 保守的: bảo thủ."),
 ("bunmyaku", "Động từ tài chính", "将来に備えて、毎月少しずつお金を（　）いる。", ["蓄えて", "費やして", "支払って", "両替して"],
  "Để chuẩn bị cho tương lai, mỗi tháng tôi tích lũy một ít tiền.",
  "✓ 蓄える: tích trữ, để dành.\n"
  "✗ 費やす: tiêu tốn.\n"
  "✗ 支払う: chi trả.\n"
  "✗ 両替する: đổi tiền."),
 ("bunmyaku", "Phó từ đi với phủ định", "雨の日が続いて、洗濯物が（　）乾かない。", ["なかなか", "いよいよ", "せっかく", "とうとう"],
  "Ngày mưa kéo dài nên quần áo phơi mãi không khô.",
  "✓ なかなか～ない: mãi mà không.\n"
  "✗ いよいよ: sắp sửa, cuối cùng thì (thời điểm đến).\n"
  "✗ せっかく: đã mất công.\n"
  "✗ とうとう: rốt cuộc (đã xảy ra)."),
 ("bunmyaku", "Từ Katakana", "このチームはメンバー全員の（　）がとれている。", ["バランス", "チャンス", "スタート", "レベル"],
  "Đội này có sự cân bằng giữa tất cả các thành viên.",
  "✓ バランスがとれる: cân bằng, hài hòa.\n"
  "✗ チャンス: cơ hội.\n"
  "✗ スタート: khởi đầu.\n"
  "✗ レベル: trình độ – không đi với とれる."),
 ("iikae", "Cách nói", "彼はいつも[おおげさに]話す。", ["実際より大きく", "小さな声で", "正直に", "早口で"],
  "Anh ta lúc nào cũng nói phóng đại.",
  "✓ おおげさ（大袈裟）: phóng đại = 実際より大きく.\n"
  "✗ 小さな声で: nói nhỏ.\n"
  "✗ 正直に: thật thà.\n"
  "✗ 早口で: nói nhanh."),
 ("iikae", "Ngữ pháp: ～おそれがある", "今夜は大雨になる[おそれがある]。", ["可能性がある", "心配はない", "予定だ", "はずがない"],
  "Đêm nay có khả năng mưa lớn.",
  "✓ ～おそれがある: có nguy cơ (điều xấu) = 可能性がある.\n"
  "✗ 心配はない: không cần lo – trái nghĩa.\n"
  "✗ 予定だ: dự định (hành động có ý chí).\n"
  "✗ はずがない: không thể nào."),
 ("iikae", "Từ tượng thái", "彼女は[あっさり]負けを認めた。", ["簡単に", "しぶしぶ", "泣きながら", "長い時間をかけて"],
  "Cô ấy dễ dàng thừa nhận thua cuộc.",
  "✓ あっさり: dễ dàng, nhẹ nhàng, dứt khoát = 簡単に.\n"
  "✗ しぶしぶ: miễn cưỡng – trái nghĩa.\n"
  "✗ 泣きながら / 長い時間をかけて: không có trong nghĩa của あっさり."),
 ("iikae", "Động từ", "雑用が多くて、仕事が[はかどらない]。", ["順調に進まない", "終わってしまう", "見つからない", "始まらない"],
  "Nhiều việc vặt nên công việc không tiến triển.",
  "✓ はかどる: tiến triển thuận lợi → はかどらない = 順調に進まない.\n"
  "✗ Các lựa chọn khác không mang nghĩa ‘tiến độ’."),
 ("bunpou", "Ngữ pháp: ～ものの", "大学を卒業した（　）、まだ就職先が決まっていない。", ["ものの", "ものだから", "ものなら", "ものか"],
  "Tuy đã tốt nghiệp đại học nhưng vẫn chưa có chỗ làm.",
  "✓ ～ものの: tuy… nhưng (kết quả không như mong đợi).\n"
  "✗ ものだから: vì (biện minh).\n"
  "✗ ものなら: nếu có thể… thì.\n"
  "✗ ものか: làm sao mà… (phủ định mạnh)."),
 ("bunpou", "Ngữ pháp: ～という", "彼が犯人だ（　）証拠はどこにもない。", ["という", "といった", "とは", "として"],
  "Không có bằng chứng nào cho thấy anh ta là thủ phạm.",
  "✓ AというN: N nói rằng A (nội dung của 証拠).\n"
  "✗ といった: như là (liệt kê ví dụ).\n"
  "✗ とは: cái gọi là / không ngờ.\n"
  "✗ として: với tư cách là."),
 ("bunpou", "Ngữ pháp: ～でなければ", "この仕事は経験者（　）、とても務まらない。", ["でなければ", "ならでは", "だけあって", "からには"],
  "Công việc này nếu không phải người có kinh nghiệm thì khó mà đảm đương được.",
  "✓ Nでなければ～ない: nếu không phải N thì không thể.\n"
  "✗ ならでは: chỉ N mới có (khen ngợi).\n"
  "✗ だけあって: quả đúng là.\n"
  "✗ からには: một khi đã."),
 ("bunpou", "Ngữ pháp: ～かいがあって", "毎日練習した（　）、本番で優勝できた。", ["かいがあって", "あまり", "くせに", "とたん"],
  "Nhờ luyện tập mỗi ngày không uổng công, tôi đã vô địch trong trận chính thức.",
  "✓ Vた＋かいがあって: công sức bỏ ra đã được đền đáp.\n"
  "✗ あまり: vì quá… (kết quả xấu).\n"
  "✗ くせに: vậy mà (chê).\n"
  "✗ とたん: vừa… thì."),
 ("bunpou", "Ngữ pháp: ～だけあって", "父は医者だ（　）、健康には人一倍気をつけている。", ["だけあって", "わりには", "くせに", "ものの"],
  "Đúng là bác sĩ có khác, bố tôi chú ý đến sức khỏe hơn người.",
  "✓ ～だけあって: quả đúng là… nên (đánh giá phù hợp với vị trí).\n"
  "✗ わりには: so với… thì bất ngờ.\n"
  "✗ くせに: vậy mà (chê).\n"
  "✗ ものの: tuy… nhưng."),
 ("bunpou", "Ngữ pháp: ～ば～ほど", "彼の話は、聞けば聞く（　）わからなくなる。", ["ほど", "まで", "ばかり", "しか"],
  "Chuyện của anh ấy càng nghe càng không hiểu.",
  "✓ Vば Vる ほど: càng… càng.\n"
  "✗ まで / ばかり / しか: không tạo thành mẫu này."),
 ("bunpou", "Ngữ pháp: ～ようか～まいか", "新しいスマホを買おうか（　）、まだ迷っている。", ["どうか", "なにか", "それとも", "だろうか"],
  "Tôi vẫn đang phân vân có nên mua điện thoại mới hay không.",
  "✓ Vよう（か）どうか迷う: phân vân có nên làm hay không.\n"
  "✗ なにか: cái gì đó.\n"
  "✗ それとも: hay là (nối hai lựa chọn đầy đủ).\n"
  "✗ だろうか: liệu có… không – không nối được với 迷っている."),
 ("narabe", "Sắp xếp câu", "この地域は ＿＿ ＿＿ ★ ＿＿ 人気がある。", ["ことから", "自然が", "豊かな", "観光客に"],
  "Vùng này được khách du lịch yêu thích vì thiên nhiên phong phú.",
  "Thứ tự đúng: この地域は 自然が / 豊かな / ★ことから / 観光客に 人気がある。\n"
  "• 自然が豊かな: thiên nhiên phong phú.\n"
  "• ～ことから: vì (căn cứ).\n"
  "• 観光客に人気がある: được du khách ưa chuộng.\n"
  "Vị trí ★ là ことから."),
 ("narabe", "Sắp xếp câu", "親の ＿＿ ＿＿ ★ ＿＿ 留学を決めた。", ["彼女は", "反対を", "押し切って", "アメリカへの"],
  "Bất chấp sự phản đối của bố mẹ, cô ấy đã quyết định đi du học Mỹ.",
  "Thứ tự đúng: 親の 反対を / 押し切って / ★彼女は / アメリカへの 留学を決めた。\n"
  "• 反対を押し切る: bất chấp sự phản đối.\n"
  "• アメリカへの留学: du học sang Mỹ.\n"
  "Vị trí ★ là 彼女は."),
]
