// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Fassenger';

  @override
  String get authTitle => 'Fassenger';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authName => 'Ваше имя';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignUp => 'Зарегистрироваться';

  @override
  String get authSignInWithGoogle => 'Войти через Google';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authSwitchToSignUp => 'Нет аккаунта? Зарегистрироваться';

  @override
  String get authSwitchToSignIn => 'Уже есть аккаунт? Войти';

  @override
  String get authErrorGeneric => 'Не удалось войти. Попробуйте ещё раз.';

  @override
  String get authResetPasswordSent => 'Ссылка на сброс пароля отправлена';

  @override
  String get authResetPasswordDialogTitle => 'Сброс пароля';

  @override
  String get authResetPasswordDialogHint => 'Введите email';

  @override
  String get authCancel => 'Отмена';

  @override
  String get authOk => 'OK';

  @override
  String get chatTitle => 'Семейный чат';

  @override
  String get chatMessageHint => 'Сообщение';

  @override
  String get chatSendError => 'Не удалось отправить сообщение';

  @override
  String chatLengthCounter(int current, int max) {
    return '$current/$max';
  }

  @override
  String get chatLogOut => 'Выйти';

  @override
  String get chatEmpty => 'Пока нет сообщений. Напишите первое';

  @override
  String get chatMessageSending => 'отправляется';

  @override
  String get chatMessageFailed => 'не отправлено';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get settingsNameLabel => 'Имя';

  @override
  String get settingsSaveName => 'Сохранить имя';

  @override
  String get settingsChangeAvatar => 'Изменить аватар';

  @override
  String get settingsRemoveAvatar => 'Удалить';

  @override
  String get settingsRemoveAvatarTitle => 'Удалить аватар?';

  @override
  String get settingsRemoveAvatarConfirm =>
      'Аватар будет удалён. Изменение сразу отразится в чате.';

  @override
  String get settingsSaved => 'Сохранено';

  @override
  String get settingsSaveError => 'Не удалось сохранить';
}
