import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Fassenger'**
  String get appTitle;

  /// No description provided for @authTitle.
  ///
  /// In ru, this message translates to:
  /// **'Fassenger'**
  String get authTitle;

  /// No description provided for @authEmail.
  ///
  /// In ru, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get authPassword;

  /// No description provided for @authName.
  ///
  /// In ru, this message translates to:
  /// **'Ваше имя'**
  String get authName;

  /// No description provided for @authSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get authSignIn;

  /// No description provided for @authSignUp.
  ///
  /// In ru, this message translates to:
  /// **'Зарегистрироваться'**
  String get authSignUp;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In ru, this message translates to:
  /// **'Войти через Google'**
  String get authSignInWithGoogle;

  /// No description provided for @authForgotPassword.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get authForgotPassword;

  /// No description provided for @authSwitchToSignUp.
  ///
  /// In ru, this message translates to:
  /// **'Нет аккаунта? Зарегистрироваться'**
  String get authSwitchToSignUp;

  /// No description provided for @authSwitchToSignIn.
  ///
  /// In ru, this message translates to:
  /// **'Уже есть аккаунт? Войти'**
  String get authSwitchToSignIn;

  /// No description provided for @authErrorGeneric.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось войти. Попробуйте ещё раз.'**
  String get authErrorGeneric;

  /// No description provided for @authResetPasswordSent.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка на сброс пароля отправлена'**
  String get authResetPasswordSent;

  /// No description provided for @authResetPasswordDialogTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сброс пароля'**
  String get authResetPasswordDialogTitle;

  /// No description provided for @authResetPasswordDialogHint.
  ///
  /// In ru, this message translates to:
  /// **'Введите email'**
  String get authResetPasswordDialogHint;

  /// No description provided for @authCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get authCancel;

  /// No description provided for @authOk.
  ///
  /// In ru, this message translates to:
  /// **'OK'**
  String get authOk;

  /// No description provided for @chatMessageHint.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение'**
  String get chatMessageHint;

  /// No description provided for @chatSendError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отправить сообщение'**
  String get chatSendError;

  /// No description provided for @chatLengthCounter.
  ///
  /// In ru, this message translates to:
  /// **'{current}/{max}'**
  String chatLengthCounter(int current, int max);

  /// No description provided for @chatLogOut.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get chatLogOut;

  /// No description provided for @chatEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет сообщений. Напишите первое'**
  String get chatEmpty;

  /// No description provided for @chatMessageSending.
  ///
  /// In ru, this message translates to:
  /// **'отправляется'**
  String get chatMessageSending;

  /// No description provided for @chatMessageFailed.
  ///
  /// In ru, this message translates to:
  /// **'не отправлено'**
  String get chatMessageFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get settingsTitle;

  /// No description provided for @settingsNameLabel.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get settingsNameLabel;

  /// No description provided for @settingsSaveName.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить имя'**
  String get settingsSaveName;

  /// No description provided for @settingsChangeAvatar.
  ///
  /// In ru, this message translates to:
  /// **'Изменить аватар'**
  String get settingsChangeAvatar;

  /// No description provided for @settingsRemoveAvatar.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get settingsRemoveAvatar;

  /// No description provided for @settingsRemoveAvatarTitle.
  ///
  /// In ru, this message translates to:
  /// **'Удалить аватар?'**
  String get settingsRemoveAvatarTitle;

  /// No description provided for @settingsRemoveAvatarConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Аватар будет удалён. Изменение сразу отразится в чате.'**
  String get settingsRemoveAvatarConfirm;

  /// No description provided for @settingsSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get settingsSaved;

  /// No description provided for @settingsSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить'**
  String get settingsSaveError;

  /// No description provided for @chatListTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чаты'**
  String get chatListTitle;

  /// No description provided for @chatGeneralTitle.
  ///
  /// In ru, this message translates to:
  /// **'Семейный чат'**
  String get chatGeneralTitle;

  /// No description provided for @chatListNoMessages.
  ///
  /// In ru, this message translates to:
  /// **'Нет сообщений'**
  String get chatListNoMessages;

  /// No description provided for @chatListYouPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Вы: '**
  String get chatListYouPrefix;

  /// No description provided for @chatListNewChat.
  ///
  /// In ru, this message translates to:
  /// **'Новый чат'**
  String get chatListNewChat;

  /// No description provided for @newChatTitle.
  ///
  /// In ru, this message translates to:
  /// **'Новый чат'**
  String get newChatTitle;

  /// No description provided for @newChatEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока никого нет. Родственники появятся здесь после первого входа в приложение'**
  String get newChatEmpty;

  /// No description provided for @unreadOverflow.
  ///
  /// In ru, this message translates to:
  /// **'99+'**
  String get unreadOverflow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
