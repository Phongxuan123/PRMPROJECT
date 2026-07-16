// Màn hình quản lý địa chỉ giao hàng (UC06): thêm, sửa, xóa, đặt địa chỉ mặc định.
// Địa chỉ được lưu vào subcollection users/{uid}/addresses trong Firestore.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/validators.dart';
import '../../../../models/user_model.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/repository_providers.dart';
import '../../../../providers/user_provider.dart';
import '../../../../shared/dialogs/confirm_dialog.dart';
import '../../../../shared/widgets/app_snackbar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_widget.dart';

/// Quản lý địa chỉ giao hàng (UC06).
class AddressManagementScreen extends ConsumerWidget {
  const AddressManagementScreen({super.key});

  Future<void> _editAddress(
      BuildContext context, WidgetRef ref, String uid, Address? existing) async {
    final receiverController =
        TextEditingController(text: existing?.receiverName ?? '');
    final phoneController =
        TextEditingController(text: existing?.phoneNumber ?? '');
    final detailController =
        TextEditingController(text: existing?.addressDetail ?? '');
    var isDefault = existing?.isDefault ?? false;
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(existing == null ? 'Thêm địa chỉ' : 'Sửa địa chỉ'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: receiverController,
                    decoration:
                        const InputDecoration(labelText: 'Tên người nhận'),
                    validator: (v) =>
                        Validators.required(v, field: 'Tên người nhận'),
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration:
                        const InputDecoration(labelText: 'Số điện thoại'),
                    keyboardType: TextInputType.phone,
                    validator: Validators.phone,
                  ),
                  TextFormField(
                    controller: detailController,
                    decoration: const InputDecoration(labelText: 'Địa chỉ'),
                    validator: (v) =>
                        Validators.required(v, field: 'Địa chỉ'),
                  ),
                  CheckboxListTile(
                    value: isDefault,
                    onChanged: (v) => setState(() => isDefault = v ?? false),
                    title: const Text('Đặt làm mặc định'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      final repo = ref.read(userRepositoryProvider);
      final address = Address(
        id: existing?.id ?? '',
        receiverName: receiverController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        addressDetail: detailController.text.trim(),
        isDefault: isDefault,
      );
      try {
        if (existing == null) {
          await repo.addAddress(uid, address);
        } else {
          await repo.updateAddress(uid, address);
        }
        if (context.mounted) {
          AppSnackbar.showSuccess(context, 'Đã lưu địa chỉ.');
        }
      } catch (e) {
        if (context.mounted) AppSnackbar.showError(context, e.toString());
      }
    }
    receiverController.dispose();
    phoneController.dispose();
    detailController.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressesAsync = ref.watch(myAddressesProvider);
    final user = ref.watch(currentUserProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ giao hàng')),
      floatingActionButton: user == null
          ? null
          : FloatingActionButton(
              onPressed: () => _editAddress(context, ref, user.uid, null),
              child: const Icon(Icons.add),
            ),
      body: addressesAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorView(message: e.toString()),
        data: (addresses) {
          if (addresses.isEmpty) {
            return const EmptyStateWidget(
              message: 'Chưa có địa chỉ nào.',
              icon: Icons.location_off_outlined,
            );
          }
          return ListView(
            children: addresses
                .map((a) => Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.location_on_outlined),
                        title: Row(
                          children: [
                            Text(a.receiverName),
                            if (a.isDefault)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: Chip(
                                  label: Text('Mặc định'),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text('${a.phoneNumber}\n${a.addressDetail}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: user == null
                                  ? null
                                  : () => _editAddress(
                                      context, ref, user.uid, a),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: user == null
                                  ? null
                                  : () async {
                                      final confirm = await showConfirmDialog(
                                        context,
                                        title: 'Xóa địa chỉ',
                                        message:
                                            'Bạn chắc chắn muốn xóa địa chỉ này?',
                                        isDestructive: true,
                                      );
                                      if (!confirm) return;
                                      try {
                                        await ref
                                            .read(userRepositoryProvider)
                                            .deleteAddress(user.uid, a.id);
                                        if (context.mounted) {
                                          AppSnackbar.showSuccess(
                                              context, 'Đã xóa địa chỉ.');
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          AppSnackbar.showError(
                                              context, e.toString());
                                        }
                                      }
                                    },
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}
