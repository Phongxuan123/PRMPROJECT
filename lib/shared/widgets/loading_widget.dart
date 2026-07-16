// Widget hiển thị CircularProgressIndicator dùng chung cho trạng thái đang tải.
// Có thể truyền message tùy chỉnh để hiển thị bên dưới spinner.
import 'package:flutter/material.dart';

/// Hiển thị trạng thái đang tải dùng chung.
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!),
          ],
        ],
      ),
    );
  }
}
