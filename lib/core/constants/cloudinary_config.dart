// Cấu hình Cloudinary để upload ảnh sản phẩm / avatar.
// Dùng unsigned upload preset (không nhúng API secret vào client).
// Xem hướng dẫn bên dưới để lấy Cloud Name và tạo Upload Preset.
/// Cấu hình Cloudinary — điền cloud_name sau khi tạo tài khoản.
///
/// Hướng dẫn:
///   1. Đăng nhập cloudinary.com
///   2. Dashboard → copy "Cloud Name"
///   3. Settings → Upload → Upload presets → tạo preset "prm_flutter" (Unsigned)
///   4. Dán Cloud Name vào cloudName bên dưới.
class CloudinaryConfig {
  static const String cloudName = 'dkebx9err';
  static const String uploadPreset = 'prm_flutter';
}
