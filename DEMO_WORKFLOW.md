# Demo Workflow — Hệ thống Quản lý Chuỗi Siêu thị Mini (PRM)

> **Stack:** Flutter 3.41.6 · Firebase Auth + Firestore · Cloudinary · Riverpod · GoRouter

---

## Tài khoản demo

| Vai trò | Email | Mật khẩu |
|---|---|---|
| Quản trị viên | admin@minimart.com | 123456 |
| Quản lý chi nhánh | manager@minimart.com | 123456 |
| Nhân viên | staff@minimart.com | 123456 |
| Khách hàng | customer@minimart.com | 123456 |

> Dữ liệu mẫu được tạo tự động lần đầu khởi động app (SeedService): 3 chi nhánh, 5 danh mục, 9 sản phẩm, tồn kho 100 đơn vị/sản phẩm/chi nhánh, 1 voucher `WELCOME10`, 1 khuyến mãi khai trương giảm 15%.

---

## Kiến trúc phân quyền

```
Khởi động app
     │
     ▼
SplashScreen
     │
     ├─ Chưa đăng nhập ──────────► LoginScreen / RegisterScreen
     │
     └─ Đã đăng nhập
          │
          ├─ role = admin        ──► /admin  (AdminDashboard)
          ├─ role = branchManager──► /manager (ManagerDashboard)
          ├─ role = staff        ──► /staff  (StaffDashboard)
          └─ role = customer     ──► /home   (CustomerHome)
```

GoRouter tự động redirect về đúng trang chủ theo role và chặn truy cập trái phép (trả về màn hình "Không có quyền").

---

## Workflow 1 — Khách hàng mua hàng

### Bước 1: Đăng nhập / Đăng ký
- Đăng nhập bằng `customer@minimart.com` / `123456`
- Hoặc đăng ký tài khoản mới (tự động gán role `customer`)

### Bước 2: Duyệt sản phẩm
```
CustomerHomeScreen
  ├── Tab "Tất cả" / lọc theo danh mục (Đồ uống, Bánh kẹo, ...)
  ├── Thanh tìm kiếm theo tên sản phẩm
  └── ProductCard → nhấn để vào ProductDetailScreen
```

### Bước 3: Xem chi tiết & đánh giá
- Xem ảnh, giá, mô tả, tồn kho
- Đọc đánh giá của khách hàng khác
- Nhấn **Thêm vào giỏ** (cập nhật badge giỏ hàng realtime)

### Bước 4: Giỏ hàng
```
CartScreen
  ├── Xem danh sách sản phẩm, điều chỉnh số lượng, xóa
  ├── Hiển thị tổng tiền
  └── Nhấn "Thanh toán" → CheckoutScreen
```

### Bước 5: Thanh toán
```
CheckoutScreen
  ├── Chọn địa chỉ giao hàng (quản lý tại /addresses)
  ├── Nhập mã voucher (ví dụ: WELCOME10 → giảm 10.000đ)
  ├── Chọn phương thức: COD hoặc Chuyển khoản (mô phỏng)
  └── Nhấn "Đặt hàng" → tạo đơn hàng trên Firestore, xóa giỏ hàng
```

### Bước 6: Theo dõi đơn hàng
```
OrderHistoryScreen → OrderDetailScreen
  Trạng thái: Chờ xử lý → Đã xác nhận → Đang giao → Hoàn thành
  (Có thể hủy khi còn ở Chờ xử lý hoặc Đã xác nhận)
```

### Bước 7: Sau khi nhận hàng
- Vào `OrderDetailScreen` → nhấn **Đánh giá sản phẩm**
- `ReviewProductScreen`: chấm sao (1–5) + nhận xét văn bản

---

## Workflow 2 — Nhân viên xử lý đơn hàng

Đăng nhập `staff@minimart.com` → vào `/staff`

```
StaffDashboard
  ├── Quản lý đơn hàng  (/staff/orders)
  │     ├── Danh sách đơn theo trạng thái
  │     ├── Xác nhận đơn: Chờ xử lý → Đã xác nhận
  │     ├── Cập nhật giao: Đã xác nhận → Đang giao
  │     └── Hoàn tất: Đang giao → Hoàn thành
  │
  ├── Quản lý sản phẩm  (/staff/products)
  │     ├── Xem danh sách sản phẩm
  │     ├── Thêm / sửa sản phẩm
  │     └── Upload ảnh qua Cloudinary (unsigned preset)
  │
  ├── Kiểm tra tồn kho  (/staff/inventory)
  │     └── Xem số lượng tồn kho theo chi nhánh, cảnh báo hàng thấp
  │
  └── Danh sách khách hàng (/staff/customers)
        └── Xem thông tin khách hàng đã đăng ký
```

### Quy trình xử lý đơn hàng (Staff)
```
Chờ xử lý
    │ [Xác nhận]
    ▼
Đã xác nhận
    │ [Bắt đầu giao]
    ▼
Đang giao
    │ [Hoàn tất]
    ▼
Hoàn thành
```
*(Có thể hủy ở bước 1 hoặc 2)*

---

## Workflow 3 — Quản lý chi nhánh

Đăng nhập `manager@minimart.com` → vào `/manager`

```
ManagerDashboard
  ├── Quản lý tồn kho      (/manager/inventory)
  │     ├── Xem tồn kho toàn chi nhánh
  │     └── Cảnh báo sản phẩm sắp hết hàng
  │
  ├── Phiếu nhập hàng      (/manager/import)
  │     ├── Tạo phiếu nhập từ nhà cung cấp
  │     ├── Nhập số lượng từng sản phẩm
  │     └── Lưu → tự động cộng tồn kho + ghi nhật ký
  │
  ├── Quản lý nhân viên    (/manager/employees)
  │     └── Xem / quản lý nhân viên thuộc chi nhánh
  │
  ├── Nhà cung cấp         (/manager/suppliers)
  │     └── Thêm / sửa / xóa nhà cung cấp
  │
  ├── Chi nhánh            (/manager/branches)
  │     └── Xem thông tin các chi nhánh
  │
  └── Báo cáo              (/manager/reports)
        ├── Doanh thu theo ngày / tháng
        ├── Số đơn hàng
        └── Tổng quan tồn kho
```

---

## Workflow 4 — Quản trị viên

Đăng nhập `admin@minimart.com` → vào `/admin`

```
AdminDashboard
  ├── Tài khoản & Phân quyền  (/admin/accounts)
  │     ├── Xem toàn bộ tài khoản hệ thống
  │     ├── Phân quyền (đổi role: customer ↔ staff ↔ branchManager)
  │     └── Kích hoạt / khóa tài khoản
  │
  ├── Danh mục sản phẩm       (/admin/categories)
  │     ├── Thêm / sửa / xóa danh mục
  │     └── Bật / tắt hiển thị danh mục
  │
  ├── Khuyến mãi & Voucher    (/admin/promotions)
  │     ├── Tab Khuyến mãi: tạo chương trình giảm giá theo % cho sản phẩm cụ thể
  │     ├── Tab Voucher: tạo mã giảm giá (điều kiện đơn tối thiểu, số lượng)
  │     └── Bật / tắt từng chương trình
  │
  └── Thống kê tổng           (/admin/statistics)
        ├── Tổng doanh thu toàn hệ thống
        ├── Tổng số đơn hàng
        ├── Số khách hàng
        └── Số sản phẩm đang bán
```

---

## Luồng dữ liệu kỹ thuật

```
Flutter App (Riverpod)
        │
        ├── Firebase Auth ──── Xác thực người dùng
        │
        ├── Firestore ──────── Dữ liệu realtime (Stream)
        │     collections: users, products, categories, orders,
        │                  inventory, importReceipts, invoices,
        │                  promotions, vouchers, branches,
        │                  suppliers, carts, notifications
        │
        └── Cloudinary ──────── Lưu trữ ảnh sản phẩm & avatar
              (unsigned upload, không cần API secret phía client)
```

---

## Thứ tự demo gợi ý (15 phút)

| # | Vai trò | Thao tác | Thời gian |
|---|---|---|---|
| 1 | Admin | Tạo danh mục "Đông lạnh", thêm voucher "DEMO20" | 2 phút |
| 2 | Staff | Thêm sản phẩm mới có ảnh (upload Cloudinary) | 2 phút |
| 3 | Manager | Tạo phiếu nhập hàng 50 đơn vị cho sản phẩm mới | 2 phút |
| 4 | Customer | Tìm sản phẩm → thêm giỏ → áp voucher → đặt hàng | 3 phút |
| 5 | Staff | Xác nhận → chuyển sang Đang giao → Hoàn thành | 2 phút |
| 6 | Customer | Đánh giá sản phẩm 5 sao | 1 phút |
| 7 | Admin | Xem thống kê tổng, kiểm tra doanh thu | 1 phút |
| 8 | Manager | Xem báo cáo chi nhánh, kiểm tra tồn kho | 2 phút |

---

## Ghi chú

- **Thanh toán**: mô phỏng, không tích hợp cổng thanh toán thật
- **Push notification**: FCM device token được lưu nhưng việc gửi thông báo cần server-side trigger
- **Xóa ảnh Cloudinary**: chỉ thực hiện được phía server (cần API Secret), client-side là no-op
- **Firestore rules**: hiện đang ở chế độ `allow read, write: if true` (môi trường dev) — cần triển khai rules thật trước khi production
