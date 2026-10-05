import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/user_repository.dart';

part 'settings_controller.g.dart';

/// Контроллер экрана настроек. Держит `AsyncValue<void>` — loading/error
/// на время активной операции.
@riverpod
class SettingsController extends _$SettingsController {
  @override
  Future<void> build() async {}

  Future<void> saveDisplayName(String name) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateDisplayName(name);
    });
  }

  /// Показать системный picker, выбрать фото, сжать и загрузить.
  /// Возвращает `true`, если пользователь выбрал файл (даже если upload упал —
  /// ошибка попадёт в [state]). Возвращает `false`, если пользователь отменил.
  Future<bool> pickAndUploadAvatar({
    ImagePicker? picker,
  }) async {
    final effectivePicker = picker ?? ImagePicker();
    final xfile = await effectivePicker.pickImage(
      source: ImageSource.gallery,
      requestFullMetadata: false,
    );
    if (xfile == null) return false;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final bytes = await xfile.readAsBytes();
      await ref
          .read(userRepositoryProvider)
          .uploadAvatar(Uint8List.fromList(bytes));
    });
    return true;
  }

  Future<void> deleteAvatar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).deleteAvatar();
    });
  }
}
