// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fassenger';

  @override
  String get authTitle => 'Fassenger';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authName => 'Your name';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignUp => 'Sign up';

  @override
  String get authSignInWithGoogle => 'Sign in with Google';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authSwitchToSignUp => 'No account? Sign up';

  @override
  String get authSwitchToSignIn => 'Already have an account? Sign in';

  @override
  String get authErrorGeneric => 'Could not sign in. Please try again.';

  @override
  String get authResetPasswordSent => 'Password reset link sent';

  @override
  String get authResetPasswordDialogTitle => 'Reset password';

  @override
  String get authResetPasswordDialogHint => 'Enter email';

  @override
  String get authCancel => 'Cancel';

  @override
  String get authOk => 'OK';

  @override
  String get chatTitle => 'Family chat';

  @override
  String get chatMessageHint => 'Message';

  @override
  String get chatSendError => 'Could not send message';

  @override
  String chatLengthCounter(int current, int max) {
    return '$current/$max';
  }

  @override
  String get chatLogOut => 'Sign out';

  @override
  String get chatEmpty => 'No messages yet. Be the first to write';

  @override
  String get chatMessageSending => 'sending';

  @override
  String get chatMessageFailed => 'failed';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsNameLabel => 'Name';

  @override
  String get settingsSaveName => 'Save name';

  @override
  String get settingsChangeAvatar => 'Change avatar';

  @override
  String get settingsRemoveAvatar => 'Remove';

  @override
  String get settingsRemoveAvatarTitle => 'Remove avatar?';

  @override
  String get settingsRemoveAvatarConfirm =>
      'The avatar will be removed. The change appears in chat immediately.';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get settingsSaveError => 'Could not save';
}
