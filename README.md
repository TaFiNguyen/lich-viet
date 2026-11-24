# Lịch Việt

App lịch âm Việt Nam cho iOS 17+ (SwiftUI + WidgetKit). Không đăng nhập, không mạng: mở ra là xem lịch.

## Chạy
1. Mở `LichViet.xcodeproj` bằng Xcode.
2. Chọn target **LichViet** → Signing & Capabilities → chọn Team của bạn (làm tương tự cho **LichWidgetExtension**).
   Bundle id hiện tại là `com.tafinguyen.lichviet`; nếu đổi, id của widget phải là `<id app>.widget`.
3. Chạy trên iPhone hoặc simulator. Widget: giữ màn hình chính → “+” → tìm “Lịch Việt”.

## Cấu trúc
- `Shared/` — dùng chung cho app và widget: thuật toán âm lịch (Hồ Ngọc Đức, UTC+7), Can Chi, ngày lễ, theme theo mùa, phong cảnh vẽ bằng code.
- `App/` — màn hình Hôm nay (vuốt trái/phải để đổi ngày) và màn hình Tháng.
- `Widget/` — cấu hình widget; giao diện widget nằm trong `Shared/Widgets/` để app cũng xem trước được.
- `Tests/run.sh` — kiểm tra lõi lịch (Tết, tháng nhuận, Can Chi, đổi qua lại dương ↔ âm 1900–2100).

Font: Fraunces (số, tiêu đề) và Be Vietnam Pro (chữ), giấy phép OFL, nằm trong `Shared/Fonts/`.

Bấm widget “Tháng này” sẽ mở thẳng màn hình tháng (link `lichviet://month`); các widget khác mở màn hình hôm nay (`lichviet://today`).

Tham số khi chạy bản Debug (Edit Scheme → Arguments), dùng để kiểm tra giao diện:
- `-date 17/2/2026`: mở app ở một ngày bất kỳ để xem nền của từng mùa.
- `-openMonth`: mở sẵn màn hình tháng.
- `-widgetGallery`: xem trước mọi kiểu widget ngay trong app.

Thêm/sửa ngày lễ: `Shared/Holidays.swift`.

## Icon
Icon app được tạo bằng script `Tools/make-icon.swift` (lệnh chạy ghi ở đầu file): nền tranh Tết, tờ lịch số “1” viết bằng font Fraunces, và trăng non.

## Ảnh nền
Tranh cổ thuộc phạm vi công cộng của các bảo tàng, lấy qua Unsplash (Unsplash License). Bản lớn cho app nằm trong `App/Backgrounds/`, bản nhỏ cho widget nằm trong `Widget/Backgrounds/`.
- Xuân: “Misty mountains with a small house and blooming tree”, The Walters Art Museum — https://unsplash.com/photos/0k0ttlNAjMI
- Hạ: watercolor lake, Museum of New Zealand Te Papa Tongarewa — https://unsplash.com/photos/fTas5mhuV9A
- Thu: landscape painting, Art Institute of Chicago — https://unsplash.com/photos/vjrzHCu0ONk
- Đông: ink painting of misty mountains and pine, The Walters Art Museum — https://unsplash.com/photos/17cN3tYHJrI
- Tết: river with trees and mountains, The Cleveland Museum of Art — https://unsplash.com/photos/xvMkkWTUPv8
