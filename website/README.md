# Iemanihongo · Trang web từ vựng

Trang web tĩnh học từ vựng tiếng Nhật theo chủ đề. Không cần đăng nhập, không cần tài khoản.

- **Thẻ từ vựng** theo 9 chủ đề (77 từ). Mặt trước là chữ, nút **Gợi ý** hiện cách đọc.
  Mặt sau có hai tab:
  - **Nghĩa**: định nghĩa, cách dùng, ví dụ và trích dẫn văn thơ viết **chữ dọc** (nếu có), tất cả là mục thu gọn.
  - **Cách viết**: Kanji, Hiragana và Katakana, mỗi chữ có hoạt họa thứ tự nét; kèm âm Hán Việt, nghĩa và âm On/Kun của từng chữ Hán.
- **Từ vựng mỗi ngày**: mỗi ngày một từ ngẫu nhiên (cùng một từ cho mọi người trong ngày), và nút **Từ ngẫu nhiên khác**.
- **Yêu thích** được lưu trong trình duyệt (localStorage).
- **Nền đổi theo giờ**: sáng (05:00–10:59), chiều (11:00–17:59), khuya (18:00–04:59), chuyển mượt khi sang buổi mới.
  Nút ☀ trên thanh trên cùng đổi tay giữa Tự động / Sáng / Chiều / Khuya. Chuông gió đung đưa theo gió (có thể bật tiếng),
  lá rơi; buổi khuya có đom đóm.
- Phím tắt: ← → chuyển thẻ, Space lật thẻ, H gợi ý, F yêu thích. Trên điện thoại vuốt trái/phải để chuyển thẻ.

## Chạy thử

```bash
cd website && python3 -m http.server 8000
```

Rồi mở http://localhost:8000. Có thể đưa nguyên thư mục `website/` lên GitHub Pages, Netlify hoặc bất kỳ hosting tĩnh nào.

## Ảnh nền anime

Khi chưa có ảnh, trang tự vẽ một bức tranh phong cảnh (núi Phú Sĩ, tháp chùa, mặt hồ, cành phong) cho từng buổi.
Để dùng ảnh anime của riêng bạn:

1. Đặt ảnh vào `website/assets/bg/`, ví dụ `sang.webp`, `chieu.webp`, `khuya.webp`
   (ảnh ngang, khoảng 2400×1350, nên dưới 600 KB; phần giữa ảnh sẽ bị thẻ che nên chọn ảnh có cảnh đẹp ở hai bên).
2. Ghi đường dẫn vào `website/data/backgrounds.js`:

```js
window.BACKGROUNDS = { sang: 'assets/bg/sang.webp', chieu: 'assets/bg/chieu.webp', khuya: 'assets/bg/khuya.webp' };
```

Buổi nào để trống thì vẫn dùng tranh vẽ. Hãy dùng ảnh bạn có quyền sử dụng.

## Đưa lên GitHub Pages

Workflow `.github/workflows/pages.yml` tự đưa thư mục `website/` lên GitHub Pages mỗi khi nhánh mặc định có thay đổi trong `website/`
(hoặc chạy tay ở tab **Actions → Deploy website to GitHub Pages → Run workflow**). Chỉ cần bật một lần:
**Settings → Pages → Build and deployment → Source: GitHub Actions**. Địa chỉ trang sẽ là `https://<tên-tài-khoản>.github.io/<tên-repo>/`.

## Dữ liệu

- `data/words.js`: chủ đề và từ vựng (sửa trực tiếp để thêm từ).
- `data/chars.js`: nét chữ và thông tin chữ Hán, sinh tự động. Sau khi thêm từ, chạy lại:

```bash
python3 tool/build_web_chars.py
```

Nét chữ lấy từ [KanjiVG](https://kanjivg.tagaini.net/) (CC BY-SA 3.0).
