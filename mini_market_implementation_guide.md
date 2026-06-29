# MINI MARKET CHAIN MANAGEMENT SYSTEM
## Tai lieu trien khai toan dien — Flutter + Firebase
## Phien ban: 2.0 | Cap nhat: 24/06/2026

---

> [!] HUONG DAN SU DUNG FILE NAY
> Day la tai lieu duy nhat can biet de trien khai toan bo project.
> Claude hay bat dau bang cach doc toan bo file nay truoc khi viet bat ky dong code nao.
> PHAN A: Dac ta du an — dung lam gi, co bao nhieu man hinh, du lieu the nao.
> PHAN B: Quy tac clean code + Firebase patterns — viet code theo tieu chuan nao.
> Ca hai phan deu bat buoc, khong duoc bo qua phan nao.

---

## MUC LUC

PHAN A — DAC TA DU AN
  1.  Gioi thieu du an
  2.  Muc tieu du an
  3.  Pham vi du an
  4.  Cong nghe su dung
  5.  Kien truc he thong
  6.  Actor trong he thong
  7.  Use Case trien khai (27 UC)
  8.  Use Case duoc gop hoac mo phong
  9.  Thiet ke Firestore Database
  10. Luong nghiep vu chinh
  11. Cau truc thu muc de xuat
  12. Man hinh chinh can trien khai
  13. Quy tac phan quyen
  14. Xu ly du lieu quan trong
  15. Validation du lieu
  16. Trang thai du lieu
  17. Bao cao va thong ke
  18. Du lieu mau (Seed Data)
  19. Tieu chi hoan thanh
  20. Han che cua he thong
  21. Huong phat trien tuong lai
  22. Stack chot

PHAN B — QUY TRINH TOI UU CODE
  23. Quy trinh Clean Code cho du an nay
  24. 13 Quy tac Clean Code (Dart/Flutter)
  25. Firebase-specific Patterns
  26. Quy trinh xu ly Warning & Bug
  27. Dinh dang output cho tung file
  28. Bao cao toi uu OPTIMIZATION_REPORT.md

---
================================================================================
# PHAN A — DAC TA DU AN
================================================================================

---

## 1. GIOI THIEU DU AN

Tên dự án   : Hệ thống quản lý chuỗi thương hiệu siêu thị mini tích hợp bán hàng online
Loại dự án  : Project/Demo ứng dụng di động
Nền tảng    : Android (primary), iOS (secondary)
Frontend    : Flutter
Ngôn ngữ   : Dart
Database    : Firebase Firestore (cloud, NoSQL document model)
Auth        : Firebase Authentication
Storage     : Firebase Storage
Thông báo   : Firebase Cloud Messaging (FCM)

Dự án xây dựng ứng dụng hỗ trợ quản lý chuỗi siêu thị mini, bao gồm quản lý sản phẩm,
danh mục, kho hàng, chi nhánh, đơn hàng, khách hàng, nhân viên và các chức năng mua
hàng online cơ bản. Mô hình tham khảo: WinMart+, Bách Hóa Xanh, Circle K, GS25.

---

## 2. MUC TIEU DU AN

### 2.1. Mục tiêu nghiệp vụ

- Số hóa quy trình quản lý siêu thị mini.
- Hỗ trợ khách hàng xem sản phẩm và đặt hàng online.
- Hỗ trợ nhân viên xử lý đơn hàng, sản phẩm và tồn kho.
- Hỗ trợ quản lý chi nhánh theo dõi kho, nhân viên, nhà cung cấp và báo cáo.
- Hỗ trợ admin quản lý tài khoản, phân quyền, danh mục và thống kê tổng quan.

### 2.2. Mục tiêu kỹ thuật

- Xây dựng ứng dụng Flutter có giao diện rõ ràng, dễ sử dụng.
- Áp dụng Layered Architecture + Repository Pattern.
- Sử dụng Firebase (Firestore + Auth + Storage + FCM).
- Thiết kế Firestore collections theo mô hình document phù hợp.
- Triển khai các Use Case quan trọng, không dàn trải.
- Đảm bảo project có khả năng mở rộng sau này.

---

## 3. PHAM VI DU AN

### 3.1. Phạm vi triển khai

- Đăng ký, đăng nhập và phân quyền người dùng (Firebase Auth).
- Quản lý sản phẩm, danh mục và hình ảnh sản phẩm (Firebase Storage).
- Quản lý giỏ hàng và đặt hàng.
- Quản lý đơn hàng, trạng thái đơn hàng và lịch sử mua hàng.
- Quản lý kho hàng theo chi nhánh.
- Quản lý nhân viên, khách hàng, chi nhánh và nhà cung cấp.
- Quản lý khuyến mãi, voucher và đánh giá sản phẩm.
- Xem báo cáo doanh thu, tồn kho và dashboard tổng quan.
- Thông báo realtime qua FCM.

### 3.2. Phạm vi không triển khai

- Thanh toán online chỉ mô phỏng bằng trạng thái (mock payment status).
- Không tích hợp Momo, VNPay hoặc Banking API.
- Không triển khai hệ thống bán hàng online production.

---

## 4. CONG NGHE SU DUNG

| Thành phần         | Công nghệ                                    |
|--------------------|----------------------------------------------|
| IDE chính          | Android Studio / VS Code                     |
| Frontend/App       | Flutter                                      |
| Ngôn ngữ           | Dart                                         |
| Auth               | Firebase Authentication                      |
| Database           | Cloud Firestore                              |
| File Storage       | Firebase Storage                             |
| Notifications      | Firebase Cloud Messaging (FCM)               |
| State management   | Riverpod 2.x                                 |
| Kiến trúc          | Layered Architecture + Repository Pattern    |
| UI Design          | Material Design 3                            |
| Platform chính     | Android                                      |
| Code generation    | freezed, json_serializable, riverpod_generator|
| Testing            | Unit Test, Widget Test cơ bản                |

### 4.1. pubspec.yaml — Firebase dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase core (bat buoc khoi tao truoc)
  firebase_core: ^3.6.0

  # Authentication
  firebase_auth: ^5.3.1

  # Database
  cloud_firestore: ^5.4.4

  # File & image storage
  firebase_storage: ^12.3.2

  # Push notifications
  firebase_messaging: ^15.1.3

  # State management
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # Model generation
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0

  # Image picker (de upload anh san pham)
  image_picker: ^1.1.2

  # Routing
  go_router: ^14.2.7

  # UI utilities
  cached_network_image: ^3.4.1
  flutter_svg: ^2.0.10+1

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.12
  freezed: ^2.5.7
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.3
  custom_lint: ^0.6.7
  riverpod_lint: ^2.3.13
```

### 4.2. Vì sao chọn Firebase thay SQLite?

Firebase phù hợp hơn SQLite cho dự án này vì:

- Firebase Auth quản lý hoàn toàn đăng nhập, token, reset password — không cần tự xây.
- Firestore hỗ trợ realtime sync, multi-device — dữ liệu luôn nhất quán.
- Firebase Storage upload ảnh sản phẩm trực tiếp từ app.
- FCM gửi push notification thật không cần backend server riêng.
- Offline persistence built-in: Firestore tự cache dữ liệu khi mất mạng.
- Phù hợp demo và dễ scale lên production sau này.

[!] SQLite chỉ phù hợp nếu project là local-only, không cần multi-user, không cần server.
    Dự án này có nhiều actor dùng chung dữ liệu → Firebase là lựa chọn đúng.

---

## 5. KIEN TRUC HE THONG

### 5.1. Kiến trúc tổng quan

```
+------------------------------+
|        Flutter UI Layer      |
|  Screens, Widgets, Forms     |
+--------------+---------------+
               |
               v
+------------------------------+
|    State Management Layer    |
|  Riverpod Providers          |
|  AsyncNotifier, StreamProvider|
+--------------+---------------+
               |
               v
+------------------------------+
|      Repository Layer        |
|  AuthRepository              |
|  ProductRepository           |
|  OrderRepository             |
|  InventoryRepository         |
|  ... (one per domain)        |
+--------------+---------------+
               |
               v
+------------------------------+
|   Firebase Services Layer    |
|  FirebaseAuth                |
|  CloudFirestore              |
|  FirebaseStorage             |
|  FirebaseMessaging           |
+------------------------------+
```

### 5.2. Lý do dùng Repository Pattern với Firebase

Repository Pattern giúp:
- Tách UI khỏi logic truy xuất Firestore.
- Dễ mock trong unit test.
- Nếu sau này chuyển sang REST API, chỉ cần thay Repository implementation.
- Tập trung xử lý lỗi Firestore tại một chỗ, không rải khắp UI.

### 5.3. Luồng dữ liệu realtime

```
Firestore document thay doi
  -> Repository nhan StreamSnapshot
    -> Riverpod StreamProvider cap nhat
      -> ConsumerWidget tu dong rebuild
```

---

## 6. ACTOR TRONG HE THONG

| Actor          | Mô tả                                                  |
|----------------|--------------------------------------------------------|
| Guest          | Người dùng chưa đăng nhập                             |
| Customer       | Khách hàng mua hàng online                            |
| Staff          | Nhân viên xử lý đơn hàng, sản phẩm, tồn kho          |
| BranchManager  | Quản lý chi nhánh                                      |
| Admin          | Quản trị viên hệ thống                                 |

---

## 7. USE CASE TRIEN KHAI (27 UC)

[*] Gộp từ 40 UC gốc xuống 27 UC để phù hợp phạm vi project/demo.

### 7.1. Nhóm Guest (4 UC)

| Mã UC | Use Case                                     | Mô tả                                                       |
|-------|----------------------------------------------|-------------------------------------------------------------|
| UC01  | Đăng ký tài khoản                            | Guest tạo tài khoản mới qua Firebase Auth                  |
| UC02  | Đăng nhập                                    | Guest đăng nhập bằng email/password qua Firebase Auth      |
| UC03  | Duyệt, tìm kiếm và xem chi tiết sản phẩm    | Gộp: xem danh sách + tìm kiếm + xem chi tiết sản phẩm     |
| UC04  | Xem khuyến mãi                               | Guest xem các chương trình khuyến mãi đang hoạt động       |

[*] UC "Quên mật khẩu" xử lý hoàn toàn bởi Firebase Auth (sendPasswordResetEmail).
    Không cần UC riêng, không cần bảng PasswordResets.

### 7.2. Nhóm Customer (7 UC)

| Mã UC | Use Case                           | Mô tả                                                                  |
|-------|------------------------------------|------------------------------------------------------------------------|
| UC05  | Quản lý hồ sơ cá nhân             | Cập nhật thông tin cá nhân, số điện thoại, avatar                     |
| UC06  | Quản lý địa chỉ giao hàng         | Thêm, sửa, xóa địa chỉ giao hàng                                     |
| UC07  | Quản lý giỏ hàng                  | Thêm, sửa, xóa sản phẩm trong giỏ hàng                               |
| UC08  | Đặt hàng / Checkout               | Chọn địa chỉ, áp voucher, chọn phương thức thanh toán, tạo đơn        |
| UC09  | Xem và theo dõi đơn hàng          | Xem lịch sử đơn hàng, trạng thái đơn, tracking giao hàng             |
| UC10  | Hủy đơn hàng                      | Hủy đơn nếu trạng thái còn Pending hoặc Confirmed                    |
| UC11  | Đánh giá sản phẩm                 | Đánh giá sản phẩm đã mua (rating + comment)                          |

[*] UC "Nhận thông báo" xử lý bởi FCM. Customer xem danh sách notification
    trong app qua màn hình Notification List (xem Mục 12.1).

### 7.3. Nhóm Staff (5 UC)

| Mã UC | Use Case                           | Mô tả                                                      |
|-------|------------------------------------|------------------------------------------------------------|
| UC12  | Xử lý đơn hàng                    | Xác nhận đơn, cập nhật trạng thái đơn hàng               |
| UC13  | Quản lý sản phẩm                  | Thêm, sửa, xóa, tìm kiếm sản phẩm + upload ảnh           |
| UC14  | Kiểm tra và cập nhật tồn kho      | Xem số lượng tồn kho, cập nhật khi cần                   |
| UC15  | Quản lý khách hàng                | Xem danh sách và thông tin khách hàng                     |
| UC16  | Xem hóa đơn                       | Xem thông tin hóa đơn của đơn hàng đã hoàn thành         |

### 7.4. Nhóm Branch Manager (6 UC)

| Mã UC | Use Case                          | Mô tả                                                     |
|-------|-----------------------------------|-----------------------------------------------------------|
| UC17  | Quản lý kho hàng                  | Theo dõi tồn kho theo chi nhánh                          |
| UC18  | Tạo phiếu nhập hàng               | Tạo phiếu nhập từ nhà cung cấp, cập nhật Inventory       |
| UC19  | Quản lý nhân viên                 | Thêm, sửa, xóa nhân viên thuộc chi nhánh                |
| UC20  | Quản lý chi nhánh                 | Xem và cập nhật thông tin chi nhánh                      |
| UC21  | Quản lý nhà cung cấp              | Thêm, sửa, xóa nhà cung cấp                             |
| UC22  | Xem báo cáo doanh thu và tồn kho  | Xem thống kê theo chi nhánh                              |

### 7.5. Nhóm Admin (5 UC)

| Mã UC | Use Case                          | Mô tả                                                     |
|-------|-----------------------------------|-----------------------------------------------------------|
| UC23  | Quản lý tài khoản                 | Quản lý toàn bộ tài khoản trong hệ thống                |
| UC24  | Phân quyền người dùng             | Gán role cho user                                        |
| UC25  | Quản lý danh mục                  | Thêm, sửa, xóa danh mục sản phẩm                        |
| UC26  | Quản lý khuyến mãi và voucher     | Quản lý chương trình giảm giá và mã giảm giá            |
| UC27  | Xem dashboard thống kê tổng       | Tổng số đơn, doanh thu, sản phẩm, tồn kho toàn hệ thống|

---

## 8. USE CASE DUOC GOP HOAC MO PHONG

| Use Case gốc                                             | Cách xử lý trong project                                          |
|----------------------------------------------------------|-------------------------------------------------------------------|
| Xem danh sách SP + tìm kiếm + xem chi tiết             | Gộp thành UC03                                                    |
| Thêm vào giỏ hàng + quản lý giỏ hàng                   | Gộp thành UC07                                                    |
| Đặt hàng + thanh toán + áp mã giảm giá + lưu địa chỉ  | Gộp thành UC08                                                    |
| Theo dõi đơn hàng + xem lịch sử mua hàng               | Gộp thành UC09                                                    |
| Xác nhận đơn hàng + cập nhật trạng thái                | Gộp thành UC12                                                    |
| Quên mật khẩu                                           | Firebase Auth: sendPasswordResetEmail() — không cần UC riêng     |
| Thanh toán online                                       | Mock bằng PaymentStatus field trong Orders                        |
| In hóa đơn                                              | Đổi thành "xem hóa đơn" trong app (UC16)                        |
| Xử lý hoàn trả hàng                                    | Optional, thiết kế collection sẵn — triển khai sau              |
| Nhận thông báo                                          | FCM, Customer xem danh sách tại Notification List screen         |
| Liên hệ hỗ trợ                                         | Collection SupportTickets thiết kế sẵn — triển khai sau         |

---

## 9. THIET KE FIRESTORE DATABASE

[!] Day la mo hinh Firestore (document/collection), KHONG phai SQL.
    Khong co JOIN. Du lieu can duoc denormalize hop ly.
    ID cua moi document la String (Firestore auto-generate hoac custom).

### 9.1. So do tong quat Firestore Collections

```
/users
/categories
/products
/branches
/suppliers
/inventory
/carts
/orders
/invoices
/returns
/importReceipts
/promotions
/vouchers
```

---

### 9.2. Collection: users/{uid}

[*] uid lay tu Firebase Auth (String, auto-generated khi dang ky).

```
users/{uid}
  - uid          : String    (= Firebase Auth UID)
  - fullName     : String
  - email        : String
  - phone        : String?
  - avatarUrl    : String?   (URL tu Firebase Storage)
  - role         : String    ('admin'|'branchManager'|'staff'|'customer')
  - branchId     : String?   (null neu la Admin hoac Customer)
  - status       : String    ('active'|'inactive'|'blocked')
  - createdAt    : Timestamp
  - updatedAt    : Timestamp

  subcollection: addresses/{addressId}
    - receiverName  : String
    - phoneNumber   : String
    - addressDetail : String
    - isDefault     : bool

  subcollection: notifications/{notificationId}
    - title     : String
    - content   : String
    - isRead    : bool
    - createdAt : Timestamp
```

[!] KHONG luu GoogleID, RefreshToken, PasswordResetToken vao Firestore.
    Firebase Auth tu quan ly toan bo authentication state.

---

### 9.3. Collection: categories/{categoryId}

```
categories/{categoryId}
  - categoryId  : String   (Firestore auto ID)
  - name        : String
  - description : String?
  - status      : bool     (true = active)
```

---

### 9.4. Collection: products/{productId}

```
products/{productId}
  - productId   : String
  - name        : String
  - categoryId  : String   (reference den categories)
  - description : String?
  - price       : double
  - unit        : String   (VD: 'chai', 'hop', 'kg')
  - barcode     : String
  - status      : bool
  - images      : List<String>   (danh sach URL Firebase Storage)
  - createdAt   : Timestamp

  subcollection: reviews/{reviewId}
    - userId    : String
    - userName  : String   (denormalized de hien thi nhanh)
    - rating    : int      (1-5)
    - comment   : String
    - createdAt : Timestamp
```

[*] images la mang URL thay vi bang ProductImages rieng biet.
    Firestore doc model phu hop de embed du lieu nho, it thay doi nhu vay.

---

### 9.5. Collection: branches/{branchId}

```
branches/{branchId}
  - branchId  : String
  - name      : String
  - address   : String
  - phone     : String
  - managerId : String?   (uid cua BranchManager)
  - status    : bool
```

[!] Luu y: branches.managerId va users.branchId co the gay circular reference khi seed.
    Giai phap: seed branches truoc (managerId = null), sau do seed users,
    roi update branches.managerId sau.

---

### 9.6. Collection: suppliers/{supplierId}

```
suppliers/{supplierId}
  - supplierId : String
  - name       : String
  - phone      : String
  - address    : String
  - email      : String
```

---

### 9.7. Collection: inventory/{inventoryId}

[*] inventoryId = '{branchId}_{productId}' de de query va tranh duplicate.

```
inventory/{inventoryId}
  - inventoryId : String   (format: 'branchId_productId')
  - branchId    : String
  - productId   : String
  - quantity    : int
  - lastUpdated : Timestamp

  subcollection: logs/{logId}
    - changeType      : String   ('import'|'sale'|'return'|'adjustment')
    - quantityChanged : int      (so duong = them, so am = tru)
    - createdBy       : String   (uid cua user thuc hien)
    - createdAt       : Timestamp
    - note            : String?
```

---

### 9.8. Collection: carts/{userId}

[*] Moi user chi co 1 cart document. CartItems la subcollection.
    Phai dang nhap moi co cart — Guest khong co cart.

```
carts/{userId}
  - userId    : String
  - createdAt : Timestamp

  subcollection: items/{itemId}
    - productId    : String
    - productName  : String   (denormalized)
    - productPrice : double   (gia tai thoi diem them vao gio)
    - imageUrl     : String   (anh chinh cua san pham)
    - quantity     : int
```

---

### 9.9. Collection: orders/{orderId}

[*] OrderDetails la subcollection.
    Thong tin giao hang (DeliveryTracking) duoc nhung vao document chinh.
    Thong tin thanh toan duoc nhung vao document chinh.

```
orders/{orderId}
  - orderId         : String
  - userId          : String
  - branchId        : String
  - orderDate       : Timestamp
  - totalAmount     : double
  - discountAmount  : double     (mac dinh 0 neu khong dung voucher)
  - voucherId       : String?    (null neu khong ap voucher)
  - status          : String     ('pending'|'confirmed'|'shipping'|'completed'|'cancelled')
  - shippingAddress : String
  - phoneNumber     : String
  - paymentMethod   : String     ('cod'|'mock_transfer')
  - paymentStatus   : String     ('unpaid'|'paid'|'failed'|'refunded')

  - deliveryTracking: List<Map>  (nhung toan bo lich su tracking)
    [
      { status: String, updatedAt: Timestamp, location: String? }
    ]

  subcollection: details/{detailId}
    - productId   : String
    - productName : String   (denormalized — snapshot gia tri tai thoi diem dat hang)
    - quantity    : int
    - price       : double   (snapshot — khong thay doi du product price thay doi)
```

---

### 9.10. Collection: invoices/{invoiceId}

```
invoices/{invoiceId}
  - orderId     : String
  - staffId     : String   (uid cua staff tao hoa don)
  - invoiceDate : Timestamp
  - totalAmount : double
```

---

### 9.11. Collection: returns/{returnId}

[*] Optional — thiet ke san, trien khai o phase sau.

```
returns/{returnId}
  - orderId   : String
  - userId    : String
  - reason    : String
  - status    : String   ('requested'|'approved'|'rejected'|'completed')
  - createdAt : Timestamp

  subcollection: details/{detailId}
    - productId : String
    - quantity  : int
```

---

### 9.12. Collection: importReceipts/{receiptId}

```
importReceipts/{receiptId}
  - supplierId : String
  - branchId   : String
  - createdBy  : String    (uid cua BranchManager)
  - importDate : Timestamp
  - totalAmount: double

  subcollection: details/{detailId}
    - productId   : String
    - productName : String   (denormalized)
    - quantity    : int
    - importPrice : double
```

---

### 9.13. Collection: promotions/{promotionId}

```
promotions/{promotionId}
  - name           : String
  - discountPercent: int
  - startDate      : Timestamp
  - endDate        : Timestamp
  - status         : bool
  - productIds     : List<String>   (mang productId, thay vi bang lien ket rieng)
```

[*] productIds la mang thay vi PromotionProducts table rieng biet.
    Firestore array-contains query ho tro truy van 'tim khuyen mai cua san pham X'.

---

### 9.14. Collection: vouchers/{voucherId}

```
vouchers/{voucherId}
  - code            : String
  - discountValue   : double
  - minOrderAmount  : double
  - expiredDate     : Timestamp
  - quantity        : int
  - status          : bool
```

---

### 9.15. Quy tắc Firestore Security Rules (tóm tắt)

```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Users: chi doc duoc profile cua chinh minh
    // Admin co the doc tat ca
    match /users/{uid} {
      allow read, write: if request.auth.uid == uid
                         || isAdmin();
    }

    // Products: ai cung doc duoc, chi staff/admin moi sua
    match /products/{productId} {
      allow read: if true;
      allow write: if isStaffOrAbove();
    }

    // Orders: customer chi doc duoc don cua minh
    match /orders/{orderId} {
      allow read: if request.auth.uid == resource.data.userId
                  || isStaffOrAbove();
      allow create: if request.auth != null;
      allow update: if isStaffOrAbove();
    }

    // Inventory: chi staff tro len moi doc/sua
    match /inventory/{inventoryId} {
      allow read, write: if isStaffOrAbove();
    }

    function isAdmin() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid))
             .data.role == 'admin';
    }

    function isStaffOrAbove() {
      let role = get(/databases/$(database)/documents/users/$(request.auth.uid))
                 .data.role;
      return role in ['staff', 'branchManager', 'admin'];
    }
  }
}
```

---

## 10. LUONG NGHIEP VU CHINH

### 10.1. Luồng đăng nhập và phân quyền

```
Guest mo app
  -> Nhap email/password
  -> Firebase Auth.signInWithEmailAndPassword()
  -> Lay uid tu FirebaseAuth.currentUser
  -> Doc users/{uid} tu Firestore
  -> Lay role tu document
  -> Dieu huong den man hinh tuong ung:
       'customer'       -> Customer Home
       'staff'          -> Staff Dashboard
       'branchManager'  -> Manager Dashboard
       'admin'          -> Admin Dashboard
```

### 10.2. Luồng mua hàng

```
Customer dang nhap
  -> Xem danh sach san pham (query products where status == true)
  -> Tim kiem / loc theo danh muc
  -> Xem chi tiet san pham
  -> Them vao gio hang (write to carts/{uid}/items/)
  -> Kiem tra gio hang
  -> Chon dia chi giao hang (doc tu users/{uid}/addresses/)
  -> Ap voucher neu co (query vouchers by code, kiem tra dieu kien)
  -> Chon phuong thuc thanh toan (COD / mock transfer)
  -> Tao don hang:
       1. Kiem tra ton kho (read inventory/{branchId}_{productId})
       2. Write orders/{orderId} + subcollection details
       3. Tru inventory moi san pham (batch write)
       4. Ghi inventory logs
       5. Tao invoice
       6. Xoa CartItems
       7. Cap nhat voucher.quantity - 1 (neu co)
```

[!] PHAI dung Firestore Batch Write hoac Transaction cho buoc tao don hang.
    Dam bao atomic: hoac toan bo thanh cong, hoac rollback het.

### 10.3. Luồng xử lý đơn hàng (Staff)

```
Staff dang nhap
  -> Xem danh sach don hang Pending
     (query orders where status == 'pending' and branchId == staff.branchId)
  -> Xem chi tiet don
  -> Xac nhan don hang (update status -> 'confirmed')
  -> Cap nhat trang thai dan:
       pending -> confirmed -> shipping -> completed
  -> Moi lan cap nhat: them vao deliveryTracking array
  -> Khi completed: tao invoice (write invoices/{invoiceId})
```

### 10.4. Luồng nhập hàng (Branch Manager)

```
Branch Manager dang nhap
  -> Chon nha cung cap
  -> Chon chi nhanh nhap hang
  -> Them san pham va so luong nhap
  -> Tao phieu nhap:
       1. Write importReceipts/{receiptId} + subcollection details
       2. Voi moi san pham: cap nhat inventory (cong them quantity)
       3. Ghi inventory logs (changeType = 'import', createdBy = managerUid)
```

### 10.5. Luồng hủy đơn hàng

```
Chi cho phep huy neu status la 'pending' hoac 'confirmed'.
KHONG cho huy neu da 'shipping', 'completed', 'cancelled'.

Khi huy:
  1. Update orders.status = 'cancelled'
  2. Hoan lai inventory moi san pham trong OrderDetails
  3. Ghi inventory logs (changeType = 'return')
  4. Update paymentStatus = 'refunded' neu da thanh toan
  5. Hoan lai voucher.quantity + 1 neu co dung voucher
```

### 10.6. Luồng báo cáo

```
Manager / Admin mo Dashboard
  -> Chon khoang thoi gian hoac chi nhanh
  -> Query orders theo dieu kien (where branchId, where orderDate, where status)
  -> Su dung Firestore AggregateQuery (count(), sum()) hoac tinh client-side
  -> Hien thi:
       Tong doanh thu
       So don hang theo trang thai
       San pham ban chay (tu OrderDetails)
       Ton kho thap (tu inventory where quantity < threshold)
       Doanh thu theo chi nhanh (Admin)
```

[*] Firestore AggregateQuery (count, sum) kha dung tu phien ban SDK 2023+.
    Voi bao cao phuc tap hon: tinh client-side khi load du lieu.

---

## 11. CAU TRUC THU MUC DE XUAT

```
lib/
  main.dart
  firebase_options.dart        <- tu dong sinh boi FlutterFire CLI

  core/
    constants/
      app_constants.dart       <- magic numbers/strings
      firestore_paths.dart     <- ten collection Firestore
      order_status.dart        <- enum OrderStatus
      user_role.dart           <- enum UserRole
    routes/
      app_router.dart          <- GoRouter config
    theme/
      app_theme.dart
    utils/
      date_utils.dart
      currency_utils.dart
      validators.dart

  data/
    firebase/
      firebase_auth_service.dart
      firebase_storage_service.dart
      fcm_service.dart
    repositories/
      auth_repository.dart
      product_repository.dart
      cart_repository.dart
      order_repository.dart
      inventory_repository.dart
      import_receipt_repository.dart
      report_repository.dart
      promotion_repository.dart
      user_repository.dart
      branch_repository.dart
      supplier_repository.dart

  models/
    user_model.dart             <- @freezed
    product_model.dart          <- @freezed
    order_model.dart            <- @freezed
    order_detail_model.dart
    cart_item_model.dart
    inventory_model.dart
    import_receipt_model.dart
    promotion_model.dart
    voucher_model.dart
    review_model.dart
    notification_model.dart

  providers/
    auth_provider.dart          <- @riverpod
    user_provider.dart
    product_provider.dart
    cart_provider.dart
    order_provider.dart
    inventory_provider.dart
    report_provider.dart

  features/
    auth/
      screens/
        login_screen.dart
        register_screen.dart
      widgets/
        auth_form_field.dart

    customer/
      home/
      product/
        screens/
          product_list_screen.dart
          product_detail_screen.dart
      cart/
        screens/
          cart_screen.dart
      checkout/
        screens/
          checkout_screen.dart
      order_history/
        screens/
          order_history_screen.dart
          order_detail_screen.dart
      profile/
        screens/
          profile_screen.dart
          address_management_screen.dart
          notification_list_screen.dart

    staff/
      dashboard/
      order_management/
      product_management/
      inventory_check/
      customer_list/
      invoice_detail/

    manager/
      dashboard/
      inventory_management/
      import_receipt/
      employee_management/
      supplier_management/
      branch_management/
      reports/

    admin/
      dashboard/
      account_management/
      role_management/
      category_management/
      promotion_management/

  shared/
    widgets/
      loading_widget.dart
      error_widget.dart
      empty_state_widget.dart
      product_card.dart
      order_status_badge.dart
    layouts/
      main_scaffold.dart
    dialogs/
      confirm_dialog.dart
```

---

## 12. MAN HINH CHINH CAN TRIEN KHAI

### 12.1. Guest / Customer

- Splash Screen
- Login Screen
- Register Screen
- Product List Screen
- Product Detail Screen
- Cart Screen
- Checkout Screen
- Order History Screen
- Order Detail Screen (co delivery tracking)
- Profile Screen
- Address Management Screen
- Notification List Screen          <- [MO I]
- Review Product Screen
- Promotion Screen

### 12.2. Staff

- Staff Dashboard
- Order Management Screen
- Order Detail / Update Status Screen
- Product Management Screen
- Inventory Check Screen
- Customer List Screen
- Invoice Detail Screen

### 12.3. Branch Manager

- Manager Dashboard
- Inventory Management Screen
- Import Receipt Screen
- Employee Management Screen
- Branch Management Screen
- Supplier Management Screen
- Revenue Report Screen
- Stock Report Screen

### 12.4. Admin

- Admin Dashboard
- Account Management Screen
- Role Management Screen
- Category Management Screen
- Promotion / Voucher Management Screen
- System Statistics Screen

---

## 13. QUY TAC PHAN QUYEN

| Role          | Quyền chính                                                                       |
|---------------|-----------------------------------------------------------------------------------|
| Guest         | Xem sản phẩm, tìm kiếm, xem khuyến mãi, đăng ký, đăng nhập                     |
| Customer      | Mua hàng, giỏ hàng, đặt hàng, hủy đơn, đánh giá, xem đơn, xem notification     |
| Staff         | Xử lý đơn hàng, quản lý sản phẩm, kiểm tra kho, xem khách hàng, tạo invoice    |
| BranchManager | Quản lý kho, nhân viên, chi nhánh, nhà cung cấp, nhập hàng, báo cáo chi nhánh  |
| Admin         | Quản lý tài khoản, phân quyền, danh mục, khuyến mãi, dashboard tổng hệ thống   |

Mỗi màn hình kiểm tra role trước khi truy cập:

```dart
// Trong GoRouter redirect
redirect: (context, state) {
  final user = ref.read(currentUserProvider);
  if (user == null) return '/login';
  if (state.uri.path.startsWith('/admin') && user.role != UserRole.admin) {
    return '/unauthorized';
  }
  return null;
}
```

---

## 14. XU LY DU LIEU QUAN TRONG

### 14.1. Khi đặt hàng (Firestore Transaction bắt buộc)

```dart
// Su dung FirebaseFirestore.instance.runTransaction()
await FirebaseFirestore.instance.runTransaction((transaction) async {
  // 1. Kiem tra gio hang khong rong
  // 2. Kiem tra ton kho du cho tung san pham
  //    -> Doc inventory/{branchId}_{productId}
  // 3. Write orders/{orderId}
  // 4. Write orders/{orderId}/details/ (batch)
  // 5. Tru quantity trong inventory moi san pham
  // 6. Ghi inventory logs
  // 7. Write invoices/{invoiceId}
  // 8. Delete cart items
  // 9. Giam voucher.quantity neu co ap
});
```

[!] Dung Transaction de dam bao atomic. Neu ton kho khong du, rollback toan bo.

### 14.2. Khi nhập hàng

```
1. Write importReceipts/{receiptId}
2. Write importReceipts/{receiptId}/details/ (batch)
3. Voi moi san pham trong phieu nhap:
   - Doc inventory/{branchId}_{productId}
   - Cong them quantity
   - Ghi inventory log (changeType = 'import', createdBy = uid)
```

### 14.3. Khi hủy đơn

```
Dieu kien cho phep huy:
  - status == 'pending' HOAC status == 'confirmed'

Khong cho huy:
  - status == 'shipping' | 'completed' | 'cancelled'

Quy trinh huy (Transaction):
  1. Update orders.status = 'cancelled'
  2. Hoan tra inventory moi san pham trong order details
  3. Ghi inventory logs (changeType = 'return')
  4. Neu paymentStatus == 'paid': set paymentStatus = 'refunded'
  5. Neu co voucherId: tang voucher.quantity + 1
```

---

## 15. VALIDATION DU LIEU

### 15.1. User

- Email khong duoc trong, phai dung dinh dang email.
- Password toi thieu 6 ky tu.
- So dien thoai dung dinh dang Viet Nam (10 chu so, bat dau 0).
- Role phai thuoc enum UserRole.

### 15.2. Product

- Ten san pham khong duoc trong.
- Gia phai > 0.
- Barcode khong duoc trung (query Firestore truoc khi them).
- CategoryId phai ton tai trong categories collection.
- Phai co it nhat 1 anh.

### 15.3. Order

- Gio hang khong duoc rong.
- So luong moi san pham phai > 0.
- Dia chi giao hang khong duoc trong.
- Tong tien phai > 0.
- Status phai thuoc enum OrderStatus.
- Voucher: kiem tra han su dung, so luong con lai, so tien toi thieu.

### 15.4. Inventory

- Quantity khong duoc am.
- Khong duoc tru kho vuot qua so luong hien co.
- branchId va productId phai ton tai.

---

## 16. TRANG THAI DU LIEU

### 16.1. Trạng thái đơn hàng (OrderStatus)

```dart
enum OrderStatus {
  pending,    // Cho xu ly
  confirmed,  // Da xac nhan
  shipping,   // Dang giao hang
  completed,  // Giao thanh cong
  cancelled,  // Da huy
}
```

### 16.2. Trạng thái thanh toán (PaymentStatus)

```dart
enum PaymentStatus {
  unpaid,
  paid,
  failed,
  refunded,
}
```

### 16.3. Trạng thái hoàn trả (ReturnStatus)

```dart
enum ReturnStatus {
  requested,
  approved,
  rejected,
  completed,
}
```

### 16.4. Trạng thái tài khoản (UserStatus)

```dart
enum UserStatus {
  active,
  inactive,
  blocked,
}
```

### 16.5. Loại thay đổi tồn kho (InventoryChangeType)

```dart
enum InventoryChangeType {
  import,       // Nhap hang
  sale,         // Ban hang (tru kho khi dat don)
  returnItem,   // Hoan tra / huy don
  adjustment,   // Chinh sua thu cong
}
```

---

## 17. BAO CAO VA THONG KE

[*] Voi Firebase Firestore, khong co SQL GROUP BY / SUM nhu SQL.
    Dung cac phuong phap sau:

### 17.1. Firestore Aggregation Queries (de)

```dart
// Dem tong so don hang cua 1 chi nhanh
final countQuery = await FirebaseFirestore.instance
  .collection('orders')
  .where('branchId', isEqualTo: branchId)
  .where('status', isEqualTo: 'completed')
  .count()
  .get();
// countQuery.count

// Tinh tong doanh thu (Firebase SDK >= 2023, sum() kha dung)
final sumQuery = await FirebaseFirestore.instance
  .collection('orders')
  .where('branchId', isEqualTo: branchId)
  .where('status', isEqualTo: 'completed')
  .aggregate(sum('totalAmount'))
  .get();
```

### 17.2. Client-side aggregation (khi can bao cao phuc tap hon)

```dart
// Load orders trong khoang thoi gian, tinh client-side
final snapshot = await FirebaseFirestore.instance
  .collection('orders')
  .where('orderDate', isGreaterThanOrEqualTo: startDate)
  .where('orderDate', isLessThanOrEqualTo: endDate)
  .where('branchId', isEqualTo: branchId)
  .get();

final totalRevenue = snapshot.docs
  .where((doc) => doc['status'] == 'completed')
  .fold(0.0, (sum, doc) => sum + (doc['totalAmount'] as double));
```

### 17.3. Danh sách báo cáo cần hỗ trợ

- Tong doanh thu theo ngay / thang / chi nhanh.
- Tong so don hang theo trang thai.
- San pham ban chay (dem so lan xuat hien trong OrderDetails).
- San pham ton kho thap (query inventory where quantity < threshold).
- Ton kho theo chi nhanh.
- Tong so khach hang (count users where role == 'customer').
- Tong so san pham dang ban (count products where status == true).

---

## 18. DU LIEU MAU (Seed Data)

[*] Seed data duoc trien khai trong `lib/data/firebase/seed_service.dart`.
    Chi chay 1 lan luc khoi dong app o moi truong dev.

### 18.1. Roles (luu vao users.role field)

- admin, branchManager, staff, customer

### 18.2. Branches (3 chi nhanh)

```
{ name: 'Siêu thị Quận 1',     address: '123 Nguyễn Trãi, Q1, TP.HCM' }
{ name: 'Siêu thị Bình Thạnh', address: '45 Xô Viết Nghệ Tĩnh, BT, TP.HCM' }
{ name: 'Siêu thị Thủ Đức',   address: '89 Kha Vạn Cân, TĐ, TP.HCM' }
```

### 18.3. Categories (5 danh mục)

Đồ uống, Bánh kẹo, Thực phẩm tươi sống, Gia dụng, Mỹ phẩm

### 18.4. Products (9 sản phẩm mẫu)

Coca Cola, Pepsi, Bánh Oreo, Sữa tươi Vinamilk, Mì Hảo Hảo,
Nước suối Lavie, Khăn giấy, Dầu gội, Kem đánh răng

### 18.5. Users mẫu

| Role          | Email                  | Password |
|---------------|------------------------|----------|
| Admin         | admin@minimart.com     | 123456   |
| BranchManager | manager@minimart.com   | 123456   |
| Staff         | staff@minimart.com     | 123456   |
| Customer      | customer@minimart.com  | 123456   |

[!] Password 123456 chi dung cho seed/demo. Production phai dung password manh.

---

## 19. TIEU CHI HOAN THANH

Project duoc xem la hoan thien tot neu dat:

- [v] Dang nhap Firebase Auth hoat dong.
- [v] Dieu huong theo role dung.
- [v] CRUD san pham, danh muc, chi nhanh, nha cung cap.
- [v] Luong mua hang day du: xem SP -> gio hang -> checkout -> tao don.
- [v] Luong xu ly don hang cho Staff.
- [v] Cap nhat ton kho khi dat hang va nhap hang.
- [v] Bao cao doanh thu / ton kho co ban.
- [v] Validation du lieu.
- [v] Seed data de demo.
- [v] Upload anh san pham len Firebase Storage.
- [v] Thong bao FCM hoat dong.
- [v] Cau truc project ro rang, de bao tri.
- [v] README huong dan chay project.
- [v] flutter analyze khong con warning nghiem trong.

---

## 20. HAN CHE CUA HE THONG

- Thanh toan online chi la mo phong (mock).
- Khong tich hop cong thanh toan Momo / VNPay.
- Returns / SupportTickets thiet ke san nhung chua trien khai day du.
- Bao cao phuc tap (pivot, drill-down) chua co.
- Khong co web dashboard.
- Chua co barcode scanner (can may quyet).

---

## 21. HUONG PHAT TRIEN TUONG LAI

- Tich hop thanh toan: Momo, VNPay, Banking API.
- Them web dashboard bang Flutter Web hoac Next.js.
- Thiet lap Cloud Functions de xu ly logic phuc tap server-side.
- Them barcode scanner (mobile_scanner package).
- Bao cao nang cao + export PDF / Excel.
- Multi-language support.
- Them he thong loyalty points cho khach hang.
- Them barcode / QR generator cho san pham.

---

## 22. STACK CHOT

```
IDE          : Android Studio / VS Code
Frontend     : Flutter (Dart)
Auth         : Firebase Authentication
Database     : Cloud Firestore
Storage      : Firebase Storage
Messaging    : Firebase Cloud Messaging (FCM)
State        : Riverpod 2.x
Architecture : Layered + Repository Pattern
Platform     : Android (primary)
```

---
================================================================================
# PHAN B — QUY TRINH TOI UU CODE
================================================================================

> [!] PHAN NAY LA BAT BUOC khi trien khai va khi review code.
>     Doc phan nay truoc khi viet bat ky file Dart nao.
>     Muc dich: dam bao toan bo codebase nhat quan, de doc, de bao tri.

---

## 23. QUY TRINH CLEAN CODE CHO DU AN NAY

### 23.1. Thông tin dự án

```
Ten du an         : Mini Market Chain Management System
Phien ban hien tai: v1.0.0
Ngon ngu          : Dart
Framework         : Flutter
Moi truong        : Flutter SDK >= 3.22, Dart >= 3.4
Pham vi toi uu    : Toan bo lib/
Kien truc         : Layered Architecture + Repository Pattern
```

Mức độ thay đổi cho phép:
  [v] Doi ten bien, ham
  [v] Duoc tach / gop ham
  [v] Duoc refactor cau truc file
  [v] Duoc thay doi toan bo (tru logic nghiep vu)

### 23.2. Quy trình bắt buộc (theo thứ tự)

```
BUOC 1 — Khao sat & lap danh sach
  - Doc toan bo code trong pham vi lib/.
  - Lap danh sach cac file can toi uu.
  - Ghi nhan so bo cac van de phat hien duoc.
  - Bao cao danh sach truoc khi bat dau sua.

BUOC 2 — Ap dung 13 quy tac Clean Code (Muc 24)
  - Xu ly tung file theo thu tu uu tien.
  - Sau moi file: bao cao nhung thay doi da thuc hien.
  - Neu khong chac -> hoi lai, khong tu y sua logic.

BUOC 3 — Kiem tra Warning & Bug (Muc 26)
  - Chay: flutter analyze
  - Phan loai va xu ly warning theo quy trinh 3 buoc.

BUOC 4 — Tao bao cao toi uu
  - Xuat OPTIMIZATION_REPORT.md (xem Muc 28).
```

---

## 24. 13 QUY TAC CLEAN CODE (Dart/Flutter)

### Quy tắc 1 — Đặt tên có ý nghĩa

Ten bien, ham, class phai mo ta ro chuc nang va muc dich.

```
[X] Tranh: x, y, temp, data, foo, a1, b2, list, map
[v] Dung : totalRevenue, currentUserUid, fetchOrdersByBranch, isPaymentValid

Quy uoc ten trong Dart/Flutter:
  - Bien / ham / parameter : camelCase    -> totalAmount, getUserById
  - Class / Widget         : PascalCase   -> OrderDetailScreen, ProductCard
  - File                   : snake_case   -> order_detail_screen.dart
  - Constant               : lowerCamelCase -> maxRetryCount, defaultPageSize
  - Enum                   : PascalCase value -> OrderStatus.pending
  - Private member         : _prefixCamelCase -> _isLoading, _fetchData()
```

Ap dung cho: bien, ham, class, file, constant, enum, Widget, Provider.

---

### Quy tắc 2 — Widget và hàm nhỏ, một trách nhiệm (SRP)

Moi ham / Widget chi lam dung mot viec.

```
[X] Tranh: Widget lon vua xu ly UI, vua goi Firebase, vua tinh logic
[v] Dung : Tach thanh Widget con + Repository + Provider rieng biet

Nguong tach:
  - Ham > 20 dong -> xet tach.
  - Widget build() > 50 dong -> tach Widget con.
  - Widget co nhieu Column/Row long nhau > 3 cap -> tach.

Ten ham la dong tu mo ta hanh dong:
  fetchOrders(), calculateTotalRevenue(), sendOrderConfirmation()
  buildProductCard(), handleCheckout(), validateVoucherCode()
```

Vi du tach Widget:

```dart
// [X] Sai — build() qua lon, lam nhieu viec
class OrderDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 100+ dong code vua hien thi info, vua hien thi items, vua co nut...
  }
}

// [v] Dung — tach ro rang
class OrderDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          OrderInfoSection(order: order),   // Widget rieng
          OrderItemsSection(order: order),  // Widget rieng
          OrderActionsBar(order: order),    // Widget rieng
        ],
      ),
    );
  }
}
```

---

### Quy tắc 3 — Không lặp code (DRY)

Doan code xuat hien >= 2 lan -> trich xuat thanh ham / Widget / extension.

```
Cac cho de bi lap trong Flutter/Firebase:
  - Xu ly loi Firestore (try/catch) -> trich xuat vao base repository
  - Widget loading indicator -> LoadingWidget trong shared/widgets/
  - Dinh dang tien, ngay thang -> CurrencyUtils, DateUtils trong core/utils/
  - Validation logic -> Validators class trong core/utils/
  - Firestore collection paths -> FirestorePaths class trong core/constants/
```

Vi du FirestorePaths (tranh magic string):

```dart
// [v] core/constants/firestore_paths.dart
class FirestorePaths {
  static String users() => 'users';
  static String user(String uid) => 'users/$uid';
  static String userAddresses(String uid) => 'users/$uid/addresses';
  static String products() => 'products';
  static String product(String id) => 'products/$id';
  static String orders() => 'orders';
  static String orderDetails(String orderId) => 'orders/$orderId/details';
  static String inventory() => 'inventory';
  static String inventoryLogs(String id) => 'inventory/$id/logs';
}
```

---

### Quy tắc 4 — Comment đúng chỗ, đúng lý do

Comment giai thich LY DO (why), khong giai thich CAI GI (what).

```
[X] Tranh: // Lay don hang  ->  final order = await getOrder(id);
[v] Dung : // Phai snapshot gia san pham tai thoi diem dat hang
           // de dam bao lich su chinh xac du sau nay gia thay doi.
           final snapshotPrice = product.price;
```

Dung Dart doc comments (///) cho public API cua Repository:

```dart
/// Lay danh sach don hang theo chi nhanh va khoang thoi gian.
///
/// Tra ve [Stream] de tu dong cap nhat khi co thay doi tren Firestore.
/// [branchId] la ID chi nhanh can truy van.
/// [startDate] va [endDate] gioi han khoang thoi gian.
Stream<List<Order>> watchOrdersByBranch({
  required String branchId,
  required DateTime startDate,
  required DateTime endDate,
}) { ... }
```

---

### Quy tắc 5 — Định dạng nhất quán

```
[v] Dart format: chay 'dart format lib/' truoc khi commit.
[v] Do dai dong: toi da 80 ky tu (mac dinh cua dart format).
[v] Import theo nhom (dung comment phan cach):

    // Flutter / Dart SDK
    import 'dart:async';
    import 'package:flutter/material.dart';

    // Third-party packages
    import 'package:cloud_firestore/cloud_firestore.dart';
    import 'package:flutter_riverpod/flutter_riverpod.dart';

    // Internal — data layer
    import '../data/repositories/order_repository.dart';

    // Internal — models
    import '../models/order_model.dart';

[*] Tao file analysis_options.yaml voi lint rules phu hop:
    include: package:flutter_lints/flutter.yaml
    Khong tu tat cac lint rule quan trong.
```

---

### Quy tắc 6 — Không dùng Magic Numbers / Magic Strings

So hoac chuoi cung co y nghia dac biet -> dat thanh constant.

```dart
// [X] Sai
if (order.status == 'pending') { ... }
const timeout = Duration(seconds: 30);
if (quantity < 5) { showLowStockWarning(); }

// [v] Dung — core/constants/app_constants.dart
class AppConstants {
  static const int lowStockThreshold = 5;
  static const int maxImagesPerProduct = 5;
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int defaultPageSize = 20;
}

// core/constants/order_status.dart
enum OrderStatus {
  pending('pending'),
  confirmed('confirmed'),
  shipping('shipping'),
  completed('completed'),
  cancelled('cancelled');

  const OrderStatus(this.value);
  final String value;
}

// Su dung:
if (order.status == OrderStatus.pending.value) { ... }
if (inventory.quantity < AppConstants.lowStockThreshold) { ... }
```

---

### Quy tắc 7 — Xử lý lỗi rõ ràng

Moi thao tac Firestore / Auth phai co error handling.
Khong de loi im lang (empty catch block).

```dart
// [X] Sai
Future<Order?> getOrder(String id) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('orders').doc(id).get();
    return Order.fromMap(doc.data()!);
  } catch (e) {
    // Bo qua loi — SAI
  }
  return null;
}

// [v] Dung
Future<Order> getOrder(String id) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection(FirestorePaths.orders())
        .doc(id)
        .get();

    if (!doc.exists || doc.data() == null) {
      throw OrderNotFoundException(orderId: id);
    }

    return Order.fromMap(doc.data()!);
  } on FirebaseException catch (e) {
    // Log loi voi du context
    debugPrint('[OrderRepository] getOrder failed: ${e.code} — ${e.message}');
    throw OrderFetchException(code: e.code, message: e.message ?? '');
  }
}
```

Quy tac xu ly loi theo tang:
  - Repository: catch FirebaseException, throw domain exception.
  - Provider: catch domain exception, tra ve AsyncError.
  - UI: hien thi thong bao loi ro rang cho user, khong log stack trace ra UI.

---

### Quy tắc 8 — Điều kiện rõ ràng, dễ đọc

Tach dieu kien phuc tap thanh bien boolean co ten.
Tranh nested if qua 3 cap -> dung early return / guard clause.

```dart
// [X] Sai — kho hieu
if (order.status == 'pending' || order.status == 'confirmed'
    && currentUser.role == 'customer'
    && order.userId == currentUser.uid) { ... }

// [v] Dung
final isCancellableStatus = order.status == OrderStatus.pending.value
    || order.status == OrderStatus.confirmed.value;
final isOrderOwner = order.userId == currentUser.uid;
final isCustomer = currentUser.role == UserRole.customer.value;
final canCancel = isCancellableStatus && isOrderOwner && isCustomer;

if (!canCancel) return;
// Xu ly huy don...
```

Guard clause thay the nested if:

```dart
// [X] Sai — nested
Future<void> createOrder() async {
  if (cartItems.isNotEmpty) {
    if (selectedAddress != null) {
      if (hasEnoughStock) {
        // tao don...
      }
    }
  }
}

// [v] Dung — guard clause
Future<void> createOrder() async {
  if (cartItems.isEmpty) throw EmptyCartException();
  if (selectedAddress == null) throw NoAddressSelectedException();
  if (!hasEnoughStock) throw InsufficientStockException();
  // Tao don...
}
```

---

### Quy tắc 9 — Giữ mọi thứ đơn giản (KISS)

Uu tien giai phap don gian nhat dat duoc muc tieu.
Khong ap dung design pattern phuc tap khi khong can thiet.

```
[v] Voi state don gian (loading flag, form input): dung StateProvider / simple state.
[v] Voi state phuc tap (order flow, checkout): dung AsyncNotifier.
[v] Voi data tu Firestore realtime: dung StreamProvider.
[X] Tranh tao abstract factory / generic repository base class phuc tap
    neu chi co 1 implementation.
```

Vi du — StreamProvider cho realtime data:

```dart
// [v] Don gian, hieu qua
@riverpod
Stream<List<Order>> pendingOrders(PendingOrdersRef ref, String branchId) {
  return ref.watch(orderRepositoryProvider).watchPendingOrders(branchId);
}

// Widget tu dong rebuild khi Firestore thay doi
class OrderListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(pendingOrdersProvider(branchId));
    return orders.when(
      data: (list) => OrderListView(orders: list),
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorWidget(message: e.toString()),
    );
  }
}
```

---

### Quy tắc 10 — Refactor chủ động

Sau khi toi uu tung rule, xem lai va hoi: "Co the don gian hon khong?"

```
[v] Xoa: code thua, dead code, bien khong dung, import khong dung.
[v] Dam bao khong con TODO / FIXME cu bi bo sot.
[v] Chay 'flutter analyze' va fix toan bo warning truoc khi coi la hoan thanh.
[v] Dung 'const' cho moi Widget / constructor co the const duoc.
[v] Ghi lai moi thay doi refactor vao bao cao (Muc 28).
```

---

### Quy tắc 11 — Comment tiếng Việt cho các phần quan trọng

Truoc moi class lon, module, ham nghiep vu quan trong:
viet comment tieng Viet co dau mo ta doan nay lam gi va tai sao.

```dart
/// Quan ly toan bo luong dat hang cua khach hang.
///
/// Xu ly: kiem tra ton kho, tao order document, tru kho,
/// ghi log ton kho, tao hoa don, xoa gio hang.
/// Su dung Firestore Transaction de dam bao tinh atomic.
class OrderRepository {

  /// Tao don hang moi tu gio hang cua khach hang.
  ///
  /// [userId] la UID cua khach hang dat don.
  /// [branchId] la chi nhanh xu ly don hang.
  /// Throws [InsufficientStockException] neu ton kho khong du.
  /// Throws [OrderCreationException] neu Firestore Transaction that bai.
  Future<String> createOrder({
    required String userId,
    required String branchId,
    required String? voucherId,
    required String shippingAddress,
    required String paymentMethod,
  }) async { ... }
}
```

---

### Quy tắc 12 — Không dùng emoji, chỉ dùng ký hiệu chuyên nghiệp

Trong code, comment va tai lieu:

```
[v]  -> Dung / Nen lam
[X]  -> Sai / Khong nen lam
[!]  -> Canh bao / Luu y quan trong
[*]  -> Ghi chu bo sung
-->  -> Dan den / Ket qua
---  -> Phan cach cac khoi noi dung
```

Ly do: emoji gay loi encoding tren terminal, log server, IDE cu va lam giam
tinh chuyen nghiep cua codebase.

---

### Quy tắc 13 — Kiểm tra và xử lý Warning / Bug

[A] Xu ly Warning — sau khi hoan tat toi uu, chay:

```bash
flutter analyze
dart fix --apply
```

Phan loai warning:

```
[W1] Deprecation warning   -> cap nhat len API / widget moi
[W2] Unused variable       -> xoa hoac su dung
[W3] Type mismatch         -> sua kieu du lieu, dung null safety dung
[W4] Performance warning   -> them const, tranh rebuild thua
[W5] Missing await         -> them await cho Future
[W6] Security warning      -> uu tien xu ly ngay
```

Moi warning phai duoc ghi nhan va xu ly hoac giai thich ly do bo qua.

[B] Xu ly Bug — Quy trinh 3 buoc bat buoc:

```
Buoc 1 — Xac dinh loai loi:
  + Mo ta trieu chung: loi xay ra khi nao, o dau
  + Phan loai: Logic bug / Runtime error / Firebase error /
               UI bug / Performance bug / Null safety bug
  + Xac dinh nguyen nhan goc re (root cause)

Buoc 2 — Len ke hoach fix:
  + De xuat 1-3 phuong an fix kha thi
  + Danh gia rui ro cua tung phuong an
  + Chon phuong an toi uu nhat, giai thich ly do
  + Xac dinh cac file / module bi anh huong

Buoc 3 — Thuc hien fix:
  + Ap dung phuong an da chon
  + Kiem tra lai sau khi fix: dam bao khong tao bug moi
  + Ghi lai: bug gi, fix nhu the nao, file nao bi thay doi
```

---

## 25. FIREBASE-SPECIFIC PATTERNS

### 25.1. Dùng const constructor cho Widget

```dart
// [v] Luon them const khi co the — giam rebuild khong can thiet
const LoadingWidget();
const SizedBox(height: 16);
const Divider(thickness: 1);
```

### 25.2. Chọn đúng cách đọc Firestore

```dart
// One-time read (khong can realtime) — dung get()
final doc = await FirebaseFirestore.instance
    .collection('products').doc(id).get();

// Realtime subscription — dung snapshots()
final stream = FirebaseFirestore.instance
    .collection('orders')
    .where('status', isEqualTo: 'pending')
    .snapshots();
```

[!] Khong dung snapshots() cho du lieu khong can realtime — ton quota Firebase.
    Dung get() khi chi can doc 1 lan (VD: xem chi tiet san pham, load gio hang).

### 25.3. Batch Write cho thao tác nhiều document

```dart
// [v] Dung WriteBatch cho nhieu write doc lap
final batch = FirebaseFirestore.instance.batch();

for (final item in orderDetails) {
  final detailRef = FirebaseFirestore.instance
      .collection('orders/$orderId/details')
      .doc();
  batch.set(detailRef, item.toMap());
}

await batch.commit();
```

### 25.4. Transaction cho thao tác cần atomic

```dart
// [v] Dung Transaction khi phai doc truoc roi moi ghi
// VD: dat hang can kiem tra ton kho roi moi tru
await FirebaseFirestore.instance.runTransaction((transaction) async {
  final inventoryDoc = await transaction.get(inventoryRef);
  final currentQuantity = inventoryDoc.data()?['quantity'] as int? ?? 0;

  if (currentQuantity < requiredQuantity) {
    throw InsufficientStockException(productId: productId);
  }

  transaction.update(inventoryRef, {
    'quantity': currentQuantity - requiredQuantity,
    'lastUpdated': FieldValue.serverTimestamp(),
  });
});
```

### 25.5. Sử dụng FieldValue thay vì client timestamp

```dart
// [X] Sai — client timestamp co the sai do lech gio thiet bi
'createdAt': DateTime.now()

// [v] Dung — Firestore server timestamp chinh xac
'createdAt': FieldValue.serverTimestamp()
```

### 25.6. Null safety với Firestore data

```dart
// [!] Firestore tra ve Map<String, dynamic>? — phai xu ly null
// [v] Dung extension de an toan

extension DocumentSnapshotX on DocumentSnapshot {
  T? getField<T>(String field) {
    final data = this.data() as Map<String, dynamic>?;
    return data?[field] as T?;
  }
}

// Trong model fromMap:
factory Order.fromMap(Map<String, dynamic> map, String docId) {
  return Order(
    id: docId,
    userId: map['userId'] as String? ?? '',
    totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
    // Xu ly Timestamp -> DateTime
    orderDate: (map['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}
```

### 25.7. Dispose stream subscription

```dart
// [v] Voi StreamProvider trong Riverpod, tu dong cancel khi provider bi dispose
// Khong can tu quan ly subscription

@riverpod
Stream<List<Order>> pendingOrders(PendingOrdersRef ref, String branchId) {
  // Riverpod tu dong cancel stream nay khi provider khong con duoc watch
  return orderRepository.watchPendingOrders(branchId);
}
```

### 25.8. Xử lý Firebase Auth state

```dart
// [v] Provider theo doi trang thai dang nhap
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  return FirebaseAuth.instance.authStateChanges();
}

// GoRouter redirect dua tren auth state
redirect: (context, state) async {
  final user = await ref.read(authStateProvider.future);
  final isLoggedIn = user != null;
  final isOnLoginPage = state.uri.path == '/login';

  if (!isLoggedIn && !isOnLoginPage) return '/login';
  if (isLoggedIn && isOnLoginPage) return '/home';
  return null;
}
```

### 25.9. Upload ảnh lên Firebase Storage

```dart
// [v] Quy trinh upload anh san pham
Future<String> uploadProductImage(File imageFile, String productId) async {
  final ref = FirebaseStorage.instance
      .ref()
      .child('products/$productId/${DateTime.now().millisecondsSinceEpoch}.jpg');

  final uploadTask = await ref.putFile(
    imageFile,
    SettableMetadata(contentType: 'image/jpeg'),
  );

  return await uploadTask.ref.getDownloadURL();
}
```

---

## 26. QUY TRINH XU LY WARNING & BUG

### 26.1. Sau mỗi phiên code

```bash
# 1. Kiem tra toan bo lint warning
flutter analyze

# 2. Tu dong fix cac van de co the fix
dart fix --apply

# 3. Dinh dang code
dart format lib/

# 4. Chay test
flutter test
```

### 26.2. Phân loại và xử lý bug

```
Buoc 1 — Xac dinh:
  [B-Logic]    Logic bug   : tinh tong tien sai, trang thai sai
  [B-Runtime]  Runtime     : null pointer, type cast fail, Firebase exception
  [B-Data]     Data bug    : Firestore data bi loi, sai kieu du lieu
  [B-UI]       UI bug      : hien thi sai, layout van de
  [B-Perf]     Performance : rebuild thua, query Firestore qua nhieu lan
  [B-Security] Security    : security rules sai, data bi lo

Buoc 2 — Ke hoach fix:
  - De xuat toi da 3 phuong an
  - Chon phuong an it rui ro nhat
  - Xac dinh file bi anh huong

Buoc 3 — Thuc hien:
  - Fix va viet unit test cho truong hop do
  - Chay flutter analyze lai
  - Ghi vao OPTIMIZATION_REPORT.md
```

---

## 27. DINH DANG OUTPUT CHO TUNG FILE

Voi moi file duoc toi uu, tra ve theo cau truc:

```
### [Ten file] — [Ngay xu ly]

Nhung thay doi da thuc hien:
- Rule X  : [mo ta thay doi cu the]
- Rule Y  : [mo ta thay doi cu the]

Warning da xu ly:
- [W1] [mo ta warning] -> [cach da fix]

Bug da xu ly:
- [Loai bug] : [mo ta] -> [phuong an fix] -> [ket qua]

Code truoc:
[code goc]

Code sau:
[code da toi uu]
```

---

## 28. BAO CAO TOI UU — OPTIMIZATION_REPORT.md

Sau khi hoan tat, tao file `OPTIMIZATION_REPORT.md` voi cau truc:

```markdown
# BAO CAO TOI UU CODE
# Du an    : Mini Market Chain Management System
# Phien ban: [v1.0.0 -> v1.1.0]
# Ngay     : [DD/MM/YYYY]
# Nguoi thuc hien: [Ten / Claude]

## 1. TONG QUAN
- Tong so file duoc ra soat   : [N]
- Tong so file duoc chinh sua : [N]
- Tong so thay doi thuc hien  : [N]
- Tong so warning da xu ly    : [N]
- Tong so bug da fix          : [N]

## 2. CHI TIET TUNG FILE
| File | Rule ap dung | Warning | Bug | Ghi chu |
|------|-------------|---------|-----|---------|
| ...  | ...         | ...     | ... | ...     |

## 3. DANH SACH THAY DOI THEO RULE
- Rule 1  : [N cho doi ten] — VD: x -> totalRevenue (file A, dong 12)
- Rule 2  : [N ham duoc tach] — VD: processOrder() tach thanh 3 ham
- Rule 6  : [N magic string doi thanh constant]
- ...

## 4. WARNING & BUG DA XU LY
| Loai  | Mo ta | File | Dong | Cach fix | Ket qua |
|-------|-------|------|------|----------|---------|
| ...   | ...   | ...  | ...  | ...      | ...     |

## 5. VAN DE CON TON DONG
- [Mo ta van de] — Ly do chua fix — De xuat huong xu ly

## 6. DE XUAT CHO LAN CAP NHAT TIEP THEO
- [De xuat cai thien 1]
- [De xuat cai thien 2]
- [Ky thuat / thu vien nen xem xet ap dung]

## 7. LICH SU CAP NHAT
| Phien ban | Ngay       | Nguoi thuc hien | Noi dung chinh     |
|-----------|------------|-----------------|--------------------|
| v1.0.0    | DD/MM/YYYY | [Ten]           | [Khoi tao du an]   |
| v1.1.0    | DD/MM/YYYY | [Ten]           | [Lan toi uu nay]   |
```

[!] KHONG tao file bao cao moi moi lan chay — chi cap nhat vao file hien co.
    Bo sung vao muc LICH SU CAP NHAT va cac muc lien quan.

---

## RANG BUOC QUAN TRONG

```
[1] KHONG thay doi logic nghiep vu — chi cai thien chat luong code.
[2] Neu khong chac ve mot thay doi -> hoi lai, khong tu y sua.
[3] Neu rule nay mau thuan rule kia -> uu tien theo thu tu so nho hon.
[4] Neu code qua lon -> xu ly tung file, thong bao tien do sau moi file.
[5] Moi thay doi deu phai duoc ghi nhan vao OPTIMIZATION_REPORT.md.
[6] Moi lan doc file nay: chay 'flutter analyze' va fix warning truoc tien.
[7] Dam bao 'flutter analyze' khong con loi nghiem trong truoc khi bao hoan tat.
[8] Moi Firestore write quan trong (dat hang, nhap hang, huy don)
    PHAI dung Transaction hoac Batch — khong duoc write doc lap.
```

---

## CHECKLIST TRUOC KHI PUSH CODE

```
[ ] flutter analyze -- khong con error / warning nghiem trong
[ ] dart format lib/ -- code da duoc format
[ ] flutter test     -- test pass
[ ] Khong con TODO / FIXME cu bi bo sot
[ ] Moi Firestore write quan trong dung Transaction / Batch
[ ] Moi Firebase call co try/catch voi error handling ro rang
[ ] Khong co magic number / magic string trong code
[ ] Moi Widget co the 'const' da duoc them 'const'
[ ] Import duoc sap xep theo nhom
[ ] Khong co unused import / unused variable
```
