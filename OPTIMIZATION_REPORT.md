# BAO CAO TOI UU CODE

- **Du an**: Mini Market Chain Management System
- **Phien ban**: v1.0.0 (khoi tao + trien khai day du)
- **Ngay**: 24/06/2026
- **Nguoi thuc hien**: Claude

---

## 1. TONG QUAN

Du an duoc trien khai tu scaffold Flutter rong (chi co counter app mac dinh)
thanh ung dung hoan chinh theo dac ta trong `mini_market_implementation_guide.md`,
ap dung dong thoi 13 quy tac Clean Code (Phan B) ngay tu khi viet code.

| Chi so                              | Gia tri |
|-------------------------------------|---------|
| Tong so file Dart tao moi           | ~70     |
| Tang kien truc                      | core / models / data / providers / features / shared |
| Repository (Repository Pattern)     | 13      |
| Model domain                        | 13      |
| Man hinh (screen)                   | ~35     |
| Use Case trien khai                 | 27/27   |
| `flutter analyze`                   | 0 issue |
| `flutter test`                      | 10/10 pass |
| `flutter build web`                 | Thanh cong |

---

## 2. AP DUNG 13 QUY TAC CLEAN CODE

| Rule | Noi dung                          | Ap dung trong du an |
|------|-----------------------------------|---------------------|
| 1    | Dat ten co y nghia                | camelCase/PascalCase/snake_case dung quy uoc; ten ham la dong tu (`watchOrdersByBranch`, `validateVoucher`) |
| 2    | Widget/ham nho, SRP               | Tach widget con (`_CartItemTile`, `_StatCard`, `_ImageGallery`); tach service/repository/provider rieng |
| 3    | Khong lap code (DRY)              | `FirestorePaths`, `FirestoreUtils`, `Validators`, `CurrencyUtils`, widget dung chung (`LoadingWidget`, `ErrorView`, `EmptyStateWidget`, `DashboardGrid`) |
| 4    | Comment dung ly do                | Comment giai thich "tai sao" (vi du: snapshot gia tai thoi diem dat hang, circular reference khi seed) |
| 5    | Dinh dang nhat quan               | Import theo nhom; tuan thu `dart format`; `analysis_options.yaml` voi flutter_lints |
| 6    | Khong magic number/string         | `AppConstants` (lowStockThreshold, maxRating...), enum co `value`, `FirestorePaths` |
| 7    | Xu ly loi ro rang                 | Repository bat `FirebaseException` -> nem domain exception (`app_exceptions.dart`); UI hien thi qua `AppSnackbar`/`ErrorView` |
| 8    | Dieu kien ro rang                 | Bien boolean co ten (`isCancellable`, `isUsable`, `isStaffOrAbove`); guard clause trong `createOrder` |
| 9    | Giu don gian (KISS)               | StreamProvider cho realtime, FutureProvider cho one-time, AsyncNotifier cho flow phuc tap; khong dung code-gen khong can thiet |
| 10   | Refactor chu dong                 | Khong dead code; `const` cho widget co the const; analyze sach |
| 11   | Comment tieng Viet phan quan trong| Doc comment cho repository/ham nghiep vu (createOrder, cancelOrder, transaction) |
| 12   | Ky hieu chuyen nghiep, khong emoji| Dung `[!] [*] [v] [X] -->` trong comment/tai lieu |
| 13   | Kiem tra warning/bug              | `flutter analyze` = 0 issue truoc khi bao hoan tat |

---

## 3. FIREBASE-SPECIFIC PATTERNS DA AP DUNG

- **Transaction** cho thao tac atomic: dat hang (`createOrder`), huy don
  (`cancelOrder`), nhap hang (`createImportReceipt`), dieu chinh ton kho
  (`adjustQuantity`) - doc toan bo truoc, ghi sau, rollback neu ton kho khong du.
- **Batch** cho xoa gio hang (`clearCart`).
- **`FieldValue.serverTimestamp()`** thay client timestamp.
- **`FieldValue.increment()`** cho cap nhat luot voucher.
- **`get()`** cho one-time read, **`snapshots()`** cho realtime - tranh ton quota.
- **Null safety** voi `FirestoreUtils` khi parse `Map<String, dynamic>`.
- **AggregateQuery** (`count()`) cho thong ke (dashboard summary).
- Stream subscription tu dong huy boi Riverpod StreamProvider.

---

## 4. WARNING & BUG DA XU LY

| Loai  | Mo ta                                              | Cach fix |
|-------|----------------------------------------------------|----------|
| Error | `UserStatus` undefined o user_model/auth/user repo | Chuyen enum `UserStatus` sang `user_role.dart` cho dung domain |
| Error | `Order` ambiguous voi `Order` cua cloud_firestore  | `import cloud_firestore hide Order` trong order_repository |
| Error | Provider tra ve `Stream<List<dynamic>>`            | He qua cua ambiguous Order - tu het sau khi hide Order |
| Error | test mac dinh tham chieu `MyApp` da xoa            | Thay bang unit test logic domain (10 test) |
| W2    | `avoid_types_as_parameter_names` (`sum` trong fold)| Doi ten tham so thanh `acc` |
| W1    | `RadioListTile.groupValue/onChanged` deprecated    | Migrate sang `RadioGroup` ancestor (Flutter 3.41) |
| Info  | `unintended_html_in_doc_comment` (`<...>`)         | Boc trong backtick |
| Info  | `unnecessary_underscores` (`(_, __)`)              | Dat ten tham so ro rang |

---

## 5. VAN DE CON TON DONG (theo thiet ke, khong phai bug)

- **Firebase config that**: `firebase_options.dart` la template. Can chay
  `flutterfire configure` + dat `google-services.json` (xem README).
- **Tao tai khoan nhan vien**: `createUserWithEmailAndPassword` se sign-in user
  moi, lam logout phien hien tai -> can Admin SDK/Cloud Functions (ngoai pham vi).
  Hien tai: nhan vien dang ky, Admin gan role + chi nhanh.
- **Returns / SupportTickets**: model + rule thiet ke san, chua co UI day du.
- **Upload anh tren Web**: bo qua (dung `kIsWeb`) vi `image_picker` tra ve blob;
  Android/iOS upload binh thuong.

---

## 6. DE XUAT CHO LAN CAP NHAT TIEP THEO

- Tich hop thanh toan that (Momo/VNPay) thay mock PaymentStatus.
- Cloud Functions: tao tai khoan nhan vien, gui FCM khi don doi trang thai.
- Them barcode scanner (`mobile_scanner`), export bao cao PDF/Excel.
- Bo sung widget test cho cac man hinh chinh (hien chi co unit test logic).
- Can nhac chuyen sang freezed/riverpod_generator khi can scale lon.

---

## 7. LICH SU CAP NHAT

| Phien ban | Ngay       | Nguoi thuc hien | Noi dung chinh |
|-----------|------------|-----------------|----------------|
| v1.0.0    | 24/06/2026 | Claude          | Trien khai day du 27 UC, kien truc Layered + Repository, 0 analyze issue |
