# Iemanihongo · Trang web từ vựng

Trang web tĩnh học từ vựng tiếng Nhật theo chủ đề. Không cần đăng nhập, không cần tài khoản.

- **Thẻ từ vựng** theo 9 chủ đề (77 từ). Mặt trước là chữ, nút **Gợi ý** hiện cách đọc.
  Mặt sau có hai tab:
  - **Nghĩa**: định nghĩa, cách dùng, ví dụ và trích dẫn văn thơ viết **chữ dọc** (nếu có), tất cả là mục thu gọn.
  - **Cách viết**: Kanji, Hiragana và Katakana, mỗi chữ có hoạt họa thứ tự nét; kèm âm Hán Việt, nghĩa và âm On/Kun của từng chữ Hán.
- **Từ vựng mỗi ngày**: mỗi ngày một từ ngẫu nhiên (cùng một từ cho mọi người trong ngày), và nút **Từ ngẫu nhiên khác**.
- **Yêu thích** được lưu trong trình duyệt (localStorage).
- Phong cảnh vườn Nhật với chuông gió đung đưa theo gió (có thể bật tiếng chuông), lá phong rơi;
  khi máy để giao diện tối thì chuyển sang vườn đêm có đom đóm.
- Phím tắt: ← → chuyển thẻ, Space lật thẻ, H gợi ý, F yêu thích. Trên điện thoại vuốt trái/phải để chuyển thẻ.

## Chạy thử

```bash
cd website && python3 -m http.server 8000
```

Rồi mở http://localhost:8000. Có thể đưa nguyên thư mục `website/` lên GitHub Pages, Netlify hoặc bất kỳ hosting tĩnh nào.

## Dữ liệu

- `data/words.js`: chủ đề và từ vựng (sửa trực tiếp để thêm từ).
- `data/chars.js`: nét chữ và thông tin chữ Hán, sinh tự động. Sau khi thêm từ, chạy lại:

```bash
python3 tool/build_web_chars.py
```

Nét chữ lấy từ [KanjiVG](https://kanjivg.tagaini.net/) (CC BY-SA 3.0).
