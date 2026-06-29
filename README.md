# Mini Market Chain Management System

Ung dung Flutter + Firebase quan ly chuoi sieu thi mini tich hop ban hang online.
Tham khao mo hinh: WinMart+, Bach Hoa Xanh, Circle K, GS25.

## Cong nghe

- **Frontend**: Flutter (Dart), Material Design 3
- **State management**: Riverpod 2.x (provider thuan, khong code-gen)
- **Kien truc**: Layered Architecture + Repository Pattern
- **Backend**: Firebase Authentication, Cloud Firestore, Firebase Storage, FCM
- **Routing**: go_router (dieu huong + redirect theo phan quyen)

> [!] Du an dung **manual model (fromMap/toMap) + Riverpod thuan** thay vi
> freezed/riverpod_generator de tranh xung dot phien ban tren Dart 3.11,
> van giu nguyen kien truc Layered + Repository theo tai lieu.

## Yeu cau

- Flutter SDK >= 3.22 (da test tren Flutter 3.41 / Dart 3.11)
- Mot project Firebase (mien phi)
- Node.js (de cai Firebase CLI)

## Cai dat va chay

### 1. Cai dependencies

```bash
flutter pub get
```

### 2. Cau hinh Firebase (BAT BUOC de chay that)

File `lib/firebase_options.dart` hien tai chi la **template** voi gia tri
placeholder. App se hien thi man hinh "Firebase chua duoc cau hinh" cho den khi
ban cau hinh that:

```bash
# Cai cong cu
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Dang nhap Firebase
firebase login

# Tu dong sinh lai lib/firebase_options.dart cho project cua ban
flutterfire configure
```

Sau do bat cac dich vu trong **Firebase Console**:

- **Authentication** -> bat **Email/Password**.
- **Cloud Firestore** -> tao database (che do production).
- **Storage** -> bat (de upload anh san pham).
- Android: dat file `google-services.json` vao `android/app/`.

### 3. Trien khai Firestore Security Rules

File `firestore.rules` da co san. Trien khai bang:

```bash
firebase deploy --only firestore:rules
```

### 4. Chay app

```bash
flutter run
```

Lan dau chay o che do debug, [`SeedService`](lib/data/firebase/seed_service.dart)
tu tao **du lieu mau** (chi nhanh, danh muc, san pham, ton kho, voucher,
khuyen mai va 4 tai khoan demo). Cac lan sau tu bo qua neu da co du lieu.

## Tai khoan demo (sau khi seed)

| Vai tro        | Email                  | Mat khau |
|----------------|------------------------|----------|
| Admin          | admin@minimart.com     | 123456   |
| Branch Manager | manager@minimart.com   | 123456   |
| Staff          | staff@minimart.com     | 123456   |
| Customer       | customer@minimart.com  | 123456   |

> [!] Mat khau `123456` chi dung cho demo. Production phai dung mat khau manh.

## Kiem tra chat luong

```bash
flutter analyze   # khong con loi/canh bao
flutter test      # unit test logic domain
dart format lib/  # dinh dang code
```

## Cau truc thu muc

```
lib/
  main.dart                  # Khoi tao Firebase + ProviderScope + MaterialApp.router
  firebase_options.dart      # Template - thay bang flutterfire configure
  core/
    constants/               # FirestorePaths, enums (UserRole, OrderStatus...), AppConstants
    routes/                  # AppRoutes (path) + app_router.dart (GoRouter + redirect)
    theme/                   # Material 3 theme
    utils/                   # Validators, CurrencyUtils, DateUtils, FirestoreUtils
    errors/                  # Domain exceptions
  models/                    # Model thuan voi fromMap/toMap
  data/
    firebase/                # Service bao boc Auth/Storage/FCM + SeedService
    repositories/            # 1 repository / domain (Repository Pattern)
  providers/                 # Riverpod providers (firebase, repository, auth, cart, order...)
  features/                  # UI theo vai tro: auth, customer, staff, manager, admin
  shared/                    # Widget + dialog dung chung
```

## Pham vi & han che

- Thanh toan online la **mock** (chi cap nhat PaymentStatus), khong tich hop
  Momo/VNPay/Banking.
- Tao tai khoan nhan vien moi can Admin SDK / Cloud Functions (ngoai pham vi);
  nhan vien dang ky roi Admin gan vai tro + chi nhanh.
- Returns/SupportTickets thiet ke san, trien khai phase sau.
- Chua co barcode scanner, chua co web dashboard rieng.

Chi tiet dac ta xem `mini_market_implementation_guide.md`.
Lich su toi uu code xem `OPTIMIZATION_REPORT.md`.
