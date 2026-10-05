import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/logger.dart';
import '../data/chat_repository.dart';

part 'chat_controller.g.dart';

/// Контроллер отправки сообщения (loading/error для UI кнопки).
@riverpod
class ChatController extends _$ChatController {
  @override
  FutureOr<void> build() {}

  Future<void> sendMessage(String text) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(chatRepositoryProvider).sendMessage(text);
    });
    final error = state.error;
    if (error != null) {
      appLogger.w('sendMessage failed', error: error);
    }
  }
}
