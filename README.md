# Fassenger

Приватный семейный мессенджер для ~20 родственников. Один общий текстовый чат, устойчивый к нестабильному интернету. Flutter + Firebase.

Спецификация: [SPEC.md](SPEC.md) — источник правды для поведения приложения. Любое изменение поведения обновляет SPEC.md в том же коммите.

## Стек

- **Flutter** stable, Dart `^3.5.0`
- **State:** Riverpod (+ `riverpod_annotation`, codegen)
- **Router:** `go_router` с auth-редиректом
- **Backend:** Firebase Auth (email/password + Google) + Cloud Firestore (offline persistence)
- **Модели:** `freezed` + `json_serializable`
- **Локализация:** `flutter_localizations` + `intl`, языки `ru` (дефолт) и `en`

## Платформы

- **Android** — основной мобильный клиент.
- **macOS** — десктоп-клиент и dev-платформа.
- iOS, web, windows, linux в v1 не собираются.

Bundle id / applicationId: `dev.za9c.fassenger` (осознанное исключение из шаблонной конвенции `code.kissed.<slug>` — уже выпущены Firebase apps, signing и keychain-groups под этим id).

## Локальный запуск

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d macos     # или android-устройство/эмулятор
```

Codegen нужен для Riverpod, freezed и json_serializable — запускайте `dart run build_runner build --delete-conflicting-outputs` после `pub get` и после изменения аннотированных файлов.

## Firebase

Проект: `fassenger-62009`. Firebase-конфиги (`lib/firebase_options.dart`, `macos/Runner/GoogleService-Info.plist`, `android/app/google-services.json`) **не хранятся в репозитории**. Локально — сгенерировать через `flutterfire configure --project=fassenger-62009`. В CI — из GitHub Secrets.

Whitelist семьи — Firestore-документ `config/access` (поле `emails`), правится в Firebase Console.

Firestore rules — в `firestore.rules`. Деплой:

```bash
firebase deploy --only firestore:rules,storage
```

## Distribution

Firebase App Distribution, раздача тестерам через `--testers`.

```bash
./scripts/release.sh macos   # local build
./scripts/release.sh android # + distribute
```

## macOS signing

Development-сертификат `Apple Development` (личный Apple ID), personal team `4WG9VZ2A3N`. Entitlement `keychain-access-groups` с�� значениями `$(AppIdentifierPrefix)dev.za9c.fassenger` и `$(AppIdentifierPrefix)com.google.GIDSignIn` — обязательно для работы Firebase Auth и Google Sign-In (иначе `errSecMissingEntitlement`).

## CI (GitHub Actions)

`.github/workflows/build.yml` — на каждый push/PR в `main` собирает release APK и прикладывает его к run'у как артефакт. Нужные Secrets (base64):

| Secret | Файл |
|---|---|
| `FIREBASE_OPTIONS_DART` | `lib/firebase_options.dart` |
| `GOOGLE_SERVICES_JSON` | `android/app/google-services.json` |
| `GOOGLE_SERVICE_INFO_PLIST` | `macos/Runner/GoogleService-Info.plist` |
| `ANDROID_DEBUG_KEYSTORE` | `~/.android/debug.keystore` (тот же SHA-1, что зарегистрирован в Firebase — иначе не работает Google Sign-In) |
