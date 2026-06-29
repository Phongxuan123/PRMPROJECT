import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/validators.dart';
import '../../../../models/product_model.dart';
import '../../../../providers/catalog_providers.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../shared/widgets/app_snackbar.dart';

/// Form thêm / sửa sản phẩm kèm upload ảnh (UC13).
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.product});

  /// Null khi thêm mới, khác null khi chỉnh sửa.
  final Product? product;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _unitController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _descriptionController;

  String? _categoryId;
  bool _status = true;
  final List<XFile> _pickedImages = [];
  late List<String> _existingImages;
  bool _saving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController =
        TextEditingController(text: p == null ? '' : p.price.toStringAsFixed(0));
    _unitController = TextEditingController(text: p?.unit ?? '');
    _barcodeController = TextEditingController(text: p?.barcode ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _categoryId = p?.categoryId;
    _status = p?.status ?? true;
    _existingImages = List<String>.from(p?.images ?? const []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => _pickedImages.addAll(images));
    }
  }

  /// Upload ảnh mới chọn lên Storage, trả về danh sách URL.
  Future<List<String>> _uploadImages(String productId) async {
    if (_pickedImages.isEmpty || kIsWeb) return const [];
    final repo = ref.read(productRepositoryProvider);
    final urls = <String>[];
    var index = 0;
    for (final image in _pickedImages) {
      final url = await repo.uploadImage(
        imageFile: File(image.path),
        productId: productId,
        timestampMs: DateTime.now().millisecondsSinceEpoch + index,
      );
      urls.add(url);
      index++;
    }
    return urls;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      AppSnackbar.showError(context, 'Vui lòng chọn danh mục.');
      return;
    }

    setState(() => _saving = true);
    final repo = ref.read(productRepositoryProvider);

    try {
      final price = double.parse(_priceController.text.trim());
      final base = Product(
        id: widget.product?.id ?? '',
        name: _nameController.text.trim(),
        categoryId: _categoryId!,
        price: price,
        unit: _unitController.text.trim(),
        barcode: _barcodeController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        status: _status,
        images: _existingImages,
        createdAt: widget.product?.createdAt,
      );

      if (_isEditing) {
        final newUrls = await _uploadImages(base.id);
        await repo.updateProduct(
          base.copyWith(images: [..._existingImages, ...newUrls]),
        );
      } else {
        final newId = await repo.addProduct(base);
        final newUrls = await _uploadImages(newId);
        if (newUrls.isNotEmpty) {
          await repo
              .updateProduct(base.copyWith(images: newUrls).copyWithId(newId));
        }
      }

      if (mounted) {
        AppSnackbar.showSuccess(context, 'Đã lưu sản phẩm.');
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) AppSnackbar.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
              validator: (v) => Validators.required(v, field: 'Tên sản phẩm'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Giá (VND)'),
              keyboardType: TextInputType.number,
              validator: (v) => Validators.positiveNumber(v, field: 'Giá'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _unitController,
              decoration:
                  const InputDecoration(labelText: 'Đơn vị (chai, hộp, kg...)'),
              validator: (v) => Validators.required(v, field: 'Đơn vị'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _barcodeController,
              decoration: const InputDecoration(labelText: 'Barcode'),
              validator: (v) => Validators.required(v, field: 'Barcode'),
            ),
            const SizedBox(height: 12),
            categoriesAsync.maybeWhen(
              data: (categories) => DropdownButtonFormField<String>(
                initialValue: _categoryId,
                decoration: const InputDecoration(labelText: 'Danh mục'),
                items: categories
                    .map((c) =>
                        DropdownMenuItem(value: c.id, child: Text(c.name)))
                    .toList(),
                onChanged: (v) => setState(() => _categoryId = v),
              ),
              orElse: () => const LinearProgressIndicator(),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Mô tả'),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              value: _status,
              onChanged: (v) => setState(() => _status = v),
              title: const Text('Đang bán'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.image_outlined),
              label: Text('Chọn ảnh (${_pickedImages.length} mới)'),
            ),
            if (_existingImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Đã có ${_existingImages.length} ảnh.'),
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu sản phẩm'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiện ích gán id cho Product khi tạo mới (id chỉ có sau khi thêm vào Firestore).
extension on Product {
  Product copyWithId(String id) => Product(
        id: id,
        name: name,
        categoryId: categoryId,
        price: price,
        unit: unit,
        barcode: barcode,
        description: description,
        status: status,
        images: images,
        createdAt: createdAt,
      );
}
