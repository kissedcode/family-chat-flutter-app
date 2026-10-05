# Fassenger — Спецификация

Версия документа: 2026-10-05
Текущая инсталляция: bundle `dev.za9c.fassenger` · Firebase project `fassenger-62009` · платформы: Android, macOS
Назначение: Приватный семейный мессенджер на ~20 родственников — один общий текстовый чат с профилями (имя + аватар), устойчивый к нестабильному интернету. Бэкенд на Firebase.

> Примечание по bundle id: по конвенции шаблона должно быть `code.kissed.<slug>`, но для этого приложения уже выпущены Firebase apps, signing-сертификат, provisioning profile и keychain-groups под `dev.za9c.fassenger`. Смена id сломала бы рабочую подпись и авторизацию, поэтому фактический id зафиксирован как осознанное исключение из конвенции.

## Оглавление

- [Часть 1. Пользовательская](#часть-1-пользовательская)
  - [Что это за приложение](#что-это-за-приложение)
  - [Целевые платформы](#целевые-платформы)
  - [Кто может пользоваться](#кто-может-пользоваться)
  - [Пользовательские сценарии](#пользовательские-сценарии)
  - [Экраны и навигация](#экраны-и-навигация)
  - [Границы функциональности](#границы-функциональности)
- [Часть 2. Техническая спецификация для реализации](#техническая-спецификация-для-реализации)

---

## Часть 1. Пользовательская

### Что это за приложение

Fassenger — закрытый семейный мессенджер для одной семьи (~20 человек). В версии v1 это один общий чат: все участники видят одну общую ленту текстовых сообщений в реальном времени. Приложение спроектировано с расчётом на нестабильный интернет (в т.ч. блокировки в России): сообщения кэшируются локально и досылаются, когда связь восстанавливается.

Главные возможности:

- Один общий текстовый чат для всей семьи.
- Вход по email/паролю или через Google.
- Профиль: своё отображаемое имя и аватар (картинка).
- Аватары и имена отправителей видны в чате рядом с сообщениями.
- Сообщения приходят в реальном времени.
- Работа в офлайне: набранное отправляется, как только вернётся сеть.
- Ограничение длины сообщения — 4096 символов (как в Telegram).

### Целевые платформы

- **Android** — основной мобильный клиент для родственников.
- **macOS** — десктоп-клиент; используется в т.ч. для разработки и отладки.
- **iOS** — не включён в v1 (можно добавить позже; Firebase iOS app и signing уже существуют).
- **Web** — не включён в v1 (можно добавить позже).
- **Windows/Linux** — не применимо.

### Кто может пользоваться

Доступ ограничен whitelist'ом по email — только адреса из списка могут читать и писать. Незалистенный пользователь может залогиниться, но не увидит переписку и не сможет отправить сообщение. Whitelist задаётся в Firestore Security Rules и деплоится вместе с ними.

### Пользовательские сценарии

#### Сценарий: Регистрация и вход

Пользователь открывает приложение. Если он ещё не вошёл — попадает на экран входа.

```
Заголовок экрана: "Fassenger"
Поле: "Email"
Поле: "Пароль"
Поле (только при регистрации): "Ваше имя"
Кнопка: "Войти"
Кнопка: "Зарегистрироваться"
Кнопка: "Войти через Google"
Ссылка: "Забыли пароль?"
Snackbar при ошибке входа: "Не удалось войти. Попробуйте ещё раз."
```

Он вводит email и пароль и нажимает «Войти» — либо переключается в режим регистрации, вводит имя и создаёт аккаунт, либо жмёт «Войти через Google». После успеха открывается общий чат.

#### Сценарий: Чтение и отправка сообщений

В общем чате пользователь видит ленту сообщений (свои — справа, чужие — слева, с именем отправителя и временем).

```
Заголовок экрана: "Семейный чат"
Поле ввода (подсказка): "Сообщение"
Кнопка отправки: иконка "отправить"
Счётчик длины у лимита: "N/4096"
Snackbar при ошибке отправки: "Не удалось отправить сообщение"
```

Он печатает текст и нажимает отправку. Сообщение сразу появляется в ленте (в статусе «отправляется», пока сервер не подтвердит). Если текст длиннее 4096 символов — отправка блокируется.

#### Сценарий: Офлайн-режим

Пользователь без сети открывает чат и видит ранее загруженные сообщения из локального кэша. Он может напечатать и «отправить» сообщение — оно ставится в очередь (статус «отправляется») и уходит на сервер автоматически, когда сеть вернётся.

#### Сценарий: Настройки профиля

Из чата пользователь может открыть настройки (иконка «шестерёнка» в app bar).

```
Заголовок экрана: "Настройки"
Секция: "Профиль"
Поле: "Имя" (текущее значение, редактируемое)
Кнопка: "Сохранить имя"
Аватар: круглая картинка (или инициал, если аватара нет)
Кнопка: "Изменить аватар"
Кнопка: "Удалить аватар" (если аватар есть)
Snackbar при успехе: "Сохранено"
Snackbar при ошибке: "Не удалось сохранить"
```

Пользователь редактирует имя и жмёт «Сохранить имя», или выбирает картинку через системный picker; она сжимается и загружается в облако, после чего аватар обновляется во всех сообщениях. Изменения видны всем участникам в реальном времени.

#### Сценарий: Выход

```
Пункт меню: "Выйти"
```

Из чата пользователь может выйти из аккаунта — приложение возвращает его на экран входа.

### Экраны и навигация

```
[Splash / проверка auth]
        │
        ├─ не вошёл ──→ [Вход/Регистрация]
        │                     │ (успех)
        └─ вошёл ────────────→ [Семейный чат] ──(выход)──→ [Вход/Регистрация]
```

| Экран            | Заходят откуда                       | Куда ведут действия              |
|------------------|--------------------------------------|----------------------------------|
| Splash           | старт приложения                     | Вход или Чат                     |
| Вход/Регистрация | Splash (если не вошёл), после выхода | Чат (после успеха)               |
| Семейный чат     | после входа                          | Вход (после выхода), Настройки   |
| Настройки        | Чат (иконка шестерёнки)              | Чат (назад)                      |

### Границы функциональности

- Приложение **не** делает медиа в сообщениях в v1: без фото, видео, файлов, голосовых (только текст). Аватары — исключение (это профильная картинка, не сообщение).
- Приложение **не** имеет нескольких чатов/каналов и личных переписок — только один общий чат.
- Приложение **не** шифрует сообщения end-to-end в v1.
- Приложение **не** редактирует и **не** удаляет отправленные сообщения.
- Приложение **не** заменяет полноценный мессенджер (Telegram/WhatsApp) — это узкий семейный инструмент.

---

## Техническая спецификация для реализации

### Детали: Цель и границы системы

- Реализуется один общий текстовый чат на Firestore с real-time лентой и офлайн-кэшем.
- Аутентификация: email/password + Google Sign-In.
- Whitelist участников по email — в Firestore-документе `config/access` (не в коде: репозиторий публичный); проверяется Security Rules.
- Профили пользователей (имя + аватар) — в Firestore `users/{uid}` + Firebase Storage для картинок.
- Out of scope v1: медиа в сообщениях, несколько чатов, личные сообщения, E2E-шифрование, push-нотификации.
- Cloud Functions не используются.

### Детали: Архитектура

- **Flutter:** stable channel (собрано на 3.41.x / Dart 3.11.x на маке Ивана).
- **Dart SDK:** `^3.5.0`.
- **State management:** Riverpod (`flutter_riverpod`, `riverpod_annotation`, code generation через `riverpod_generator`).
- **Router:** `go_router` с auth-redirect.
- **Backend:** Firebase — Auth (email/password + Google), Cloud Firestore (с офлайн-persistence). Storage и Cloud Functions в v1 не используются.
- **Модели:** `freezed` + `json_serializable`.
- **Логирование:** `logger` в dev.
- **Архитектурный стиль:** feature-first (`lib/features/<feature>/{data,domain,presentation}`) + общий `lib/core/`.
- **Платформы:** Android, macOS (без iOS/web/windows/linux в v1).
- Пакеты Firebase — актуальные мажорные версии, совместимые с рабочей сборкой: `firebase_core ^4`, `firebase_auth ^6`, `cloud_firestore ^6`, `google_sign_in ^7` (новый API `initialize()` + `authenticate()`). Это отклонение от версий из ассетов шаблона (там ^3/^5/^6), сделанное потому, что именно эти версии собираются и работают на маке.

### Детали: Bundle id / Application id

- **Android applicationId:** `dev.za9c.fassenger`
- **macOS bundle:** `dev.za9c.fassenger`
- **iOS:** `dev.za9c.fassenger` (Firebase iOS app и signing существуют, но платформа в v1 не заводится/не собирается)
- **Web:** не применимо в v1
- **Windows/Linux:** не применимо

### Детали: Модель данных Firestore

Коллекция `messages/{messageId}`:

| Поле              | Тип       | Обязательное | Описание                                                    |
|-------------------|-----------|--------------|-------------------------------------------------------------|
| `text`            | string    | да           | текст сообщения, 1..4096 символов                           |
| `senderId`        | string    | да           | uid отправителя (== `request.auth.uid`)                     |
| `senderName`      | string    | да           | снапшот: имя на момент отправки                         |
| `senderAvatarUrl` | string    | нет          | снапшот: URL аватара на момент отправки, `null` если нет |
| `createdAt`       | timestamp | да           | серверное время (`FieldValue.serverTimestamp()`)            |

Коллекция `users/{uid}` — один документ на пользователя (`uid` == Firebase Auth uid):

| Поле          | Тип       | Обязательное | Описание                                                       |
|---------------|-----------|--------------|----------------------------------------------------------------|
| `displayName` | string    | да           | текущее отображаемое имя (1..64 символов)                 |
| `avatarUrl`   | string    | нет          | URL текущего аватара в Firebase Storage, `null` если нет |
| `email`       | string    | да           | email из Firebase Auth (для диагностики)                    |
| `updatedAt`   | timestamp | да           | серверное время последнего обновления                    |

Документ создаётся/обновляется при первом входе и при каждом сохранении настроек. Базовое имя при создании — `displayName` из Firebase Auth (или email до `@`).

Индексы: составные индексы не требуются (запрос — `orderBy('createdAt', descending: true).limit(N)`, покрывается одиночным индексом по `createdAt`).

### Детали: Firebase Security Rules

**Whitelist** — документ Firestore `config/access`:

| Поле     | Тип      | Описание                                      |
|----------|----------|-----------------------------------------------|
| `emails` | string[] | email'ы членов семьи, которым разрешён доступ |

Клиентам документ недоступен (catch-all `allow read, write: if false`); правится только админом через Firebase Console или REST/Admin SDK. Rules читают его через `get()` (Firestore) и `firestore.get()` (Storage, cross-service rules).

**Firestore** (`firestore.rules`) — whitelist через `isFamily()`:

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {

    // Whitelist семьи хранится в документе config/access (поле emails: string[]).
    // Клиенты этот документ не читают — его правит только админ (Console/CLI).
    function isFamily() {
      return request.auth != null
        && request.auth.token.email in
           get(/databases/$(database)/documents/config/access).data.emails;
    }

    match /messages/{messageId} {
      allow read: if isFamily();

      allow create: if isFamily()
        && request.resource.data.senderId == request.auth.uid
        && request.resource.data.text is string
        && request.resource.data.text.size() > 0
        && request.resource.data.text.size() <= 4096
        && request.resource.data.senderName is string
        && request.resource.data.createdAt == request.time;

      // В v1 редактирование и удаление запрещены.
      allow update, delete: if false;
    }

    match /users/{uid} {
      allow read: if isFamily();

      allow write: if isFamily()
        && request.auth.uid == uid
        && request.resource.data.displayName is string
        && request.resource.data.displayName.size() > 0
        && request.resource.data.displayName.size() <= 64
        && (
          !('avatarUrl' in request.resource.data)
          || request.resource.data.avatarUrl == null
          || request.resource.data.avatarUrl is string
        )
        && request.resource.data.email == request.auth.token.email
        && request.resource.data.updatedAt == request.time;
    }

    // Всё остальное — запрещено по умолчанию.
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Storage** (`storage.rules`) — только аватары:

```
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {

    // Whitelist читается из Firestore: config/access.emails (cross-service rules).
    function isFamilyStorage() {
      return request.auth != null
        && request.auth.token.email in
           firestore.get(/databases/(default)/documents/config/access).data.emails;
    }

    // Аватары: читает любой из whitelist,
    // пишет — только в свой файл, до 5 МБ, image/*.
    match /avatars/{uid}/{fileName} {
      allow read: if isFamilyStorage();
      allow write: if isFamilyStorage()
        && request.auth.uid == uid
        && request.resource.size < 5 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }

    match /{allPaths=**} {
      allow read, write: if false;
    }
  }
}
```

### Детали: Модель доступа / аутентификация

- **Методы:** email/password + Google Sign-In. Anonymous не используется.
- **Whitelist:** массив `emails` в документе `config/access` (Firestore). Добавить члена семьи — дописать email в массив через Firebase Console; деплой rules не нужен. Сами email'ы в репозитории не хранятся.
- **Регистрация:** открытая (в рамках проекта семьи), но чтение/запись невозможны для незалистенных email'ов. При регистрации по email пользователь задаёт отображаемое имя (`updateDisplayName`).
- **Google на разных платформах:** `google_sign_in 7.x` — один раз `GoogleSignIn.instance.initialize(serverClientId: <Web client ID>)`, затем `authenticate()`. `authenticate()` работает на Android и macOS; web в v1 не поддерживается.
- **macOS keychain:** для работы Firebase Auth и Google Sign-In на macOS приложение подписывается development-сертификатом реальной команды и имеет entitlement `keychain-access-groups` (`$(AppIdentifierPrefix)dev.za9c.fassenger` и `$(AppIdentifierPrefix)com.google.GIDSignIn`). Без этого keychain-операции падают с `errSecMissingEntitlement (-34018)`.
- **Сессия:** Firebase Auth persistence — local (по дефолту), сессия не сбрасывается при закрытии приложения.

### Детали: Экраны и роуты

| Роут        | Экран          | Требует auth | Deep-link URL |
|-------------|----------------|--------------|---------------|
| `/auth`     | AuthScreen     | нет          | не применимо  |
| `/`         | ChatScreen     | да           | не применимо  |
| `/settings` | SettingsScreen | да           | не применимо  |

Redirect logic (в `core/router.dart`):

- Если `!signedIn` и роут не `/auth` → `/auth`.
- Если `signedIn` и текущий роут `/auth` → `/`.

### Детали: Riverpod-провайдеры

- `authRepositoryProvider` (`Provider<AuthRepository>`) — обёртка над `FirebaseAuth` + `GoogleSignIn` (email/Google вход, регистрация, reset, signOut).
- `authStateChangesProvider` (`StreamProvider<User?>`) — `FirebaseAuth.instance.authStateChanges()`; используется роутером для redirect.
- `chatRepositoryProvider` (`Provider<ChatRepository>`) — доступ к коллекции `messages` (стрим + отправка).
- `messagesStreamProvider` (`StreamProvider<List<Message>>`) — real-time лента последних сообщений.
- `authControllerProvider` (`AsyncNotifierProvider<AuthController, void>`) — бизнес-логика форм входа/регистрации (обработка ошибок, loading state).
- `userRepositoryProvider` (`Provider<UserRepository>`) — чтение/запись `users/{uid}` + загрузка/удаление аватаров в Firebase Storage.
- `myProfileProvider` (`StreamProvider<UserProfile?>`) — real-time профиль текущего пользователя.
- `userProfileProvider(uid)` (`FutureProvider.family<UserProfile?, String>`) — кэшированный read `users/{uid}` для чата (fallback когда в message нет senderAvatarUrl).
- `settingsControllerProvider` (`AsyncNotifierProvider<SettingsController, void>`) — бизнес-логика экрана настроек: save name, pick+upload avatar, delete avatar.

Все stateful-провайдеры создаются через `@riverpod` code generation.

### Детали: Основные пользовательские потоки

#### Поток: Регистрация нового пользователя (email)

1. На `/auth` пользователь вводит email + пароль + имя и нажимает «Зарегистрироваться».
2. Клиент вызывает `createUserWithEmailAndPassword(...)`, затем `updateDisplayName(name)` + `reload()`.
3. `go_router` redirect по `authStateChanges` отправляет на `/`.
4. При ошибке — snackbar `"Не удалось войти. Попробуйте ещё раз."`.

#### Поток: Вход через Google

1. На `/auth` пользователь нажимает «Войти через Google».
2. `GoogleSignIn.instance.initialize(serverClientId: ...)` (один раз), затем `authenticate()`.
3. Из результата берётся `idToken`, строится `GoogleAuthProvider.credential(idToken: ...)`, вызывается `signInWithCredential`.
4. Redirect на `/`.

#### Поток: Отправка сообщения

1. В `/` пользователь вводит текст и жмёт отправку.
2. Клиент триммит текст, проверяет: не пустой и `<= 4096` символов (иначе — локальная ошибка/блокировка).
3. Снапшотятся имя и аватар: `senderName` = `myProfile.displayName` (fallback: Firebase Auth `displayName` → email), `senderAvatarUrl` = `myProfile.avatarUrl` (или `null`).
4. Пишется документ в `messages` с `createdAt: FieldValue.serverTimestamp()`.
5. Пока `metadata.hasPendingWrites` — сообщение отображается со статусом «отправляется».
6. При ошибке записи — snackbar `"Не удалось отправить сообщение"`.

#### Поток: Показ аватара в чате

1. Для каждого сообщения сначала берётся `senderAvatarUrl` из самого message (снапшот).
2. Если снапшот отсутствует (старые сообщения) — читается `users/{senderId}.avatarUrl` через `userProfileProvider(senderId)` (кэшируется в памяти Riverpod).
3. Если и там нет — показывается круг с первой буквой `senderName` (fallback avatar).

#### Поток: Сохранение имени

1. На `/settings` пользователь редактирует поле «Имя» и жмёт «Сохранить имя».
2. Клиент триммит, проверяет 1..64 символов, вызывает `userRepository.updateProfile(displayName: name)`.
3. Репозиторий пишет `users/{uid}` с мержем (`SetOptions(merge: true)`) и обновляет `updatedAt: FieldValue.serverTimestamp()`.
4. Параллельно — `firebaseUser.updateDisplayName(name)` (синхрон Firebase Auth).
5. Snackbar `"Сохранено"`; при ошибке — `"Не удалось сохранить"`.

#### Поток: Загрузка аватара

1. На `/settings` пользователь жмёт «Изменить аватар».
2. `image_picker` открывает системный picker (галерея); выбранный файл читается в память.
3. Клиент сжимает через `package:image`: `decodeImage` → `copyResize(width: 512)` → `encodeJpg(quality: 85)`. Результат — `Uint8List`.
4. Заливается в Storage путём `avatars/{uid}/avatar_<timestamp>.jpg` (новое имя каждый раз — чтобы сбить CDN-кэш у читателей).
5. После upload — вызывается `getDownloadURL()`, сохраняется в `users/{uid}.avatarUrl`.
6. Старый файл (если был) удаляется best-effort через `ref.fromURL(oldUrl).delete()`.
7. Snackbar `"Сохранено"`; при ошибке — `"Не удалось сохранить"`.

#### Поток: Удаление аватара

1. Кнопка «Удалить аватар» → confirm dialog.
2. `users/{uid}` обновляется: `avatarUrl: null`.
3. Файл в Storage удаляется best-effort.
4. В UI показывается fallback (круг с инициалом).

#### Поток: Офлайн

- Firestore persistence включена (`Settings(persistenceEnabled: true, cacheSizeBytes: unlimited)`).
- Лента читается через `snapshots(includeMetadataChanges: true)`; при отсутствии сети показываются кэшированные сообщения, новые записи ставятся в очередь и досылаются автоматически.

### Детали: Внешние интеграции

Только Firebase; сторонних API нет. Используются Firebase Auth, Cloud Firestore и Firebase Storage (для аватаров). Ключи Firebase — в `lib/firebase_options.dart` и platform-конфигах (`macos/Runner/GoogleService-Info.plist`, `android/app/google-services.json`). Репозиторий публичный, поэтому эти файлы **не коммитятся** (в `.gitignore`): локально их генерирует `flutterfire configure`, в GitHub Actions они восстанавливаются из Secrets (base64): `FIREBASE_OPTIONS_DART`, `GOOGLE_SERVICES_JSON`, `GOOGLE_SERVICE_INFO_PLIST`. API-ключи дополнительно ограничены в Google Cloud Console (по приложению и списку Firebase API).

### Детали: Push-нотификации

Не применимо в v1. FCM нестабилен при блокировках в России и требует Cloud Function для отправки — отложено.

### Детали: Локализация

- Языки в v1: **`ru` (дефолт) и `en`**. Все тексты UI к оммиту в `main` — через `AppLocalizations`, без зашитых строк.
- Механизм: встроенный `flutter_localizations` + `intl` + генератор через `flutter gen-l10n` (включается `flutter: generate: true` в `pubspec.yaml`).
- Файлы: `lib/l10n/app_ru.arb` (template-arb-file), `lib/l10n/app_en.arb`; конфиг `l10n.yaml` в корне (вывод в `lib/l10n/generated/`).
- Стратегия выбора языка: следует системной локали; если системная не `ru` и не `en` — fallback на `ru` (дефолт семьи).
- Набор ключей на v1 покрывает: заголовки экранов, кнопки входа/регистрации/Google, плейсхолдеры полей, snackbar-ошибки, счётчик длины, пункт меню «Log out / Выйти».

### Детали: Нефункциональные требования

- **Безопасность:** Firestore rules ограничивают запись (senderId == uid, лимит длины, серверное время); никаких `allow read, write: if true`. Не логировать PII.
- **Надёжность:** Firestore offline persistence включена; ретраи записи — за счёт Firebase SDK.
- **Совместимость:** iOS >= 13, Android minSdk >= 21, macOS >= 10.15.
- **Производительность:** лента ограничена последними N (по умолчанию 100) сообщениями; при росте — пагинация через `startAfterDocument`.
- **UX:** Material 3, dark mode следует системе; свои/чужие сообщения визуально разделены; счётчик длины у лимита.

### Детали: Acceptance checklist

- [ ] `flutter analyze` проходит без ошибок и warning'ов.
- [ ] `flutter test` проходит.
- [ ] Приложение запускается на macOS (и заводится проект Android).
- [ ] Firestore rules задеплоены и совпадают с этой спекой (whitelist читается из `config/access`).
- [ ] Storage rules задеплоены и совпадают с этой спекой (avatars/{uid}/, whitelist).
- [ ] Экраны `/auth`, `/` и `/settings` доступны и корректно защищены auth-редиректом.
- [ ] Вход по email/паролю и через Google работает на macOS (keychain entitlement на месте).
- [ ] Отправка сообщения проходит; в сообщение снапшотятся senderName и senderAvatarUrl.
- [ ] В чате рядом с bubble показывается аватар отправителя (или инициал как fallback).
- [ ] На /settings можно изменить имя и загрузить/удалить аватар; изменения сразу отражаются в чате.
- [ ] Незалистенный email не может ни читать, ни писать (Firestore/Storage возвращают permission denied).
- [ ] Локализация работает: при системной локали `en` UI на английском, во всех остальных — на русском.
- [ ] В репозитории нет email'ов, Firebase-конфигов, ключей подписи.
- [ ] `SPEC.md` актуален (дата в шапке — сегодняшняя).

### Детали: Known current deployment state

- **Firebase project id:** `fassenger-62009` (messagingSenderId `847260960210`).
- **Firebase apps:**
  - Android: `1:847260960210:android:9b8e99e48c659b38beb40b`, package `dev.za9c.fassenger`, SHA-1 debug keystore `3A:2A:02:43:F3:C7:43:36:1F:4F:BA:57:CD:02:51:14:DF:22:11:43`, minSdk 23.
  - iOS/macOS: `1:847260960210:ios:b2f707b07d89f149beb40b` (один app используется для обеих Apple-платформ в v1).
  - Web: `1:847260960210:web:8500b2707de4188dbeb40b` (в v1 не заводится).
- **Bundle ids:** Android/macOS — `dev.za9c.fassenger`.
- **macOS signing:** development-сертификат `Apple Development` (личный Apple ID), personal team `4WG9VZ2A3N`, provisioning profile `5b0fd10d-...`; entitlement `keychain-access-groups` = `4WG9VZ2A3N.dev.za9c.fassenger` + `4WG9VZ2A3N.com.google.GIDSignIn`.
- **Web client ID (Google Sign-In serverClientId):** `847260960210-uajtht6usumegae19qhceij7glun9hhi.apps.googleusercontent.com`.
- **iOS/macOS CLIENT_ID:** `847260960210-u6svmd9gjaite4cvbiqt1ok65d2806i0.apps.googleusercontent.com` (REVERSED в URL scheme Info.plist).
- **Firestore rules:** задеплоены (whitelist из `config/access` в `isFamily()`).
- **Storage rules:** задеплоены (whitelist из `config/access` в `isFamilyStorage()`, `avatars/{uid}/{fileName}` ≤ 5 МБ image/*).
- **Whitelist:** 5 email'ов в `config/access` (Firestore).
- **Firebase App Distribution:** 6 тестеров, раздача через `--testers` (группы нет). Один из тестеров может ставить APK, но не в whitelist — читать/писать чат не может.
- **Последний release:** v0.2.0(2) — `371otvjq09kjo` (профиль: имя + аватар), 2026-10-05, раздан всем 6 тестерам.
- **Репозиторий:** публичный; CI — GitHub Actions (`.github/workflows/build.yml`): Android APK на каждый push/PR в `main`, артефакт в run'е.
