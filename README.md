# NTPGame v3 — Shop Acc Game & Dịch Vụ

Phiên bản này được thiết kế lại theo phong cách shop trong ảnh tham khảo: nền xanh navy, gradient cyan/purple, hero lớn, danh mục, card sản phẩm, dịch vụ, FAQ, tài khoản, giỏ hàng, checkout và admin.

## Tính năng
- Trang chủ hiện đại, responsive mobile/desktop.
- Shop acc: tìm kiếm, lọc game, lọc giá, sắp xếp.
- Trang chi tiết sản phẩm.
- Dịch vụ cày thuê + Instagram/Facebook/TikTok/X/YouTube/Website.
- Giỏ hàng localStorage.
- Đăng ký / đăng nhập Supabase Auth.
- Checkout tạo đơn bằng RPC `create_order`.
- Đơn hàng người dùng.
- Admin dashboard, thêm/ẩn/hiện sản phẩm, cập nhật trạng thái đơn.
- RLS Supabase.

## Cài đặt
1. Tạo project Supabase.
2. Mở SQL Editor và chạy `supabase/schema.sql`.
3. Mở `assets/config.js` và thay:
   - `SUPABASE_URL`
   - `SUPABASE_KEY`
4. Đăng ký tài khoản.
5. Chạy SQL:
   `update public.profiles set role='admin' where email='EMAIL_ADMIN';`
6. Upload toàn bộ file lên GitHub.
7. Có thể bật GitHub Pages để chạy frontend tĩnh.

## Lưu ý bảo mật
Không đặt service_role/secret key vào frontend. Chỉ dùng publishable/anon key. Thông tin nhạy cảm của acc nên được xử lý ở backend/Edge Function hoặc cơ chế giao hàng an toàn; không nên hard-code mật khẩu vào HTML/JS.

## Deploy GitHub Pages
Repository > Settings > Pages > Deploy from branch > main > /(root) > Save.

Sau khi deploy, website sẽ có dạng:
https://TEN-USER.github.io/TEN-REPO/

## Thanh toán
Bản v3 có khu vực VietQR/chuyển khoản ở checkout nhưng chưa tự động xác nhận giao dịch. Có thể tích hợp cổng thanh toán/webhook ở phiên bản tiếp theo.
