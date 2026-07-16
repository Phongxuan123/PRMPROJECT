// Service upload ảnh lên Cloudinary thay cho Firebase Storage.
// Dùng unsigned upload preset nên không cần API secret phía client.
// Hỗ trợ cả File (mobile) và Uint8List (web) để đa nền tảng.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../../core/constants/cloudinary_config.dart';

/// Upload / xóa ảnh qua Cloudinary (thay thế Firebase Storage).
///
/// Dùng unsigned upload preset nên không cần API secret phía client.
class FirebaseStorageService {
  FirebaseStorageService({
    String? cloudName,
    String? uploadPreset,
  })  : _cloudName = cloudName ?? CloudinaryConfig.cloudName,
        _uploadPreset = uploadPreset ?? CloudinaryConfig.uploadPreset;

  final String _cloudName;
  final String _uploadPreset;

  String get _uploadUrl =>
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Upload ảnh sản phẩm, trả về URL tải xuống.
  Future<String> uploadProductImage({
    required File imageFile,
    required String productId,
    required int timestampMs,
  }) async {
    final bytes = await imageFile.readAsBytes();
    return _upload(
      bytes: bytes,
      folder: 'products/$productId',
      publicId: '$timestampMs',
    );
  }

  /// Upload ảnh từ byte data (dùng cho Flutter Web).
  Future<String> uploadProductImageBytes({
    required Uint8List bytes,
    required String productId,
    required int timestampMs,
  }) {
    return _upload(
      bytes: bytes,
      folder: 'products/$productId',
      publicId: '$timestampMs',
    );
  }

  /// Upload avatar người dùng, trả về URL tải xuống.
  Future<String> uploadAvatar({
    required File imageFile,
    required String uid,
  }) async {
    final bytes = await imageFile.readAsBytes();
    return _upload(
      bytes: bytes,
      folder: 'avatars',
      publicId: uid,
    );
  }

  /// Xóa ảnh theo URL — bỏ qua trong demo (cần API secret phía server).
  Future<void> deleteByUrl(String downloadUrl) async {}

  Future<String> _upload({
    required Uint8List bytes,
    required String folder,
    required String publicId,
  }) async {
    final uri = Uri.parse(_uploadUrl);
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..fields['public_id'] = publicId
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: '$publicId.jpg'),
      );

    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception('Cloudinary upload thất bại: $body');
    }

    final json = jsonDecode(body) as Map<String, dynamic>;
    final url = json['secure_url'];
    if (url is! String || url.isEmpty) {
      throw Exception('Cloudinary trả về thiếu secure_url: $body');
    }
    return url;
  }
}
