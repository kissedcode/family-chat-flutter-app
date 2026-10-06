# Fassenger — Спецификация

Версия документа: 2026-10-06
Текущая инсталляция: bundle `dev.za9c.fassenger` · Firebase project `fassenger-62009` · платформы: Android, macOS
Назначение: Приватный семейный мессенджер на ~20 родственников — один общий текстовый чат с профилями (имя + аватар), устойчивый к нестабильному интернету. Бэкенд на Firebase.

## Оглавление

- [Часть 1. Пользовательская](#часть-1-пользовательская)
  - [Что это за приложение](#что-это-за-приложение)
  - [Целевые платформы](#целевые-платформы)
  - [Кто может пользоваться](#кто-может-пользоваться)
  - [Пользовательские сценарии](#пользовательские-сценарии)
  - [Экраны и навигация](#экраны-и-навигация)
  - [Границы функциональности](#границы-функциональности)
- [Часть 2. Техническая спецификация для реализации](#техническая-спецификация-для-реализации)
  - [Цель и границы системы](#детали-цель-и-границы-системы)
  - [Архитектура](#детали-архитектура)
  - [Bundle id / Application id](#детали-bundle-id--application-id)
  - [Иконка приложения](#детали-иконка-приложения)
  - [Модель данных Firestore](#детали-модель-данных-firestore)
  - [Firebase Security Rules](#детали-firebase-security-rules)
  - [Модель доступа / аутентификация](#детали-модель-доступа--аутентификация)
  - [Экраны и роуты](#детали-экраны-и-роуты)
  - [Riverpod-провайдеры](#детали-riverpod-провайдеры)
  - [Основные пользовательские потоки](#детали-основные-пользовательские-потоки)
  - [Внешние интеграции](#детали-внешние-интеграции)
  - [Push-нотификации](#детали-push-нотификации)
  - [Локализация](#детали-локализация)
  - [Сборка, CI и distribution](#детали-сборка-ci-и-distribution)
  - [Нефункциональные требования](#детали-нефункциональные-требования)
  - [Acceptance checklist](#детали-acceptance-checklist)
  - [Known current deployment state](#детали-known-current-deployment-state)

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
- Узнаваемая иконка: белое облачко-сообщение с домиком и сердцем на коралловом фоне.

### Целевые платформы

- **Android** — основной мобильный клиент для родственников.
- **macOS** — десктоп-клиент; используется в т.ч. для разработки и отладки.
- **iOS** — не включён в v1 (можно добавить позже; Firebase iOS app и signing уже существуют).
- **Web** — не включён в v1 (можно добавить позже).
- **Windows/Linux** — не применимо.

### Кто может пользоваться

Доступ ограничен whitelist'ом по email — только адреса из списка могут читать и писать. Незалистенный пользователь может залогиниться, но не увидит переписку и не сможет отправить сообщение. Список ведёт администратор (Иван); чтобы добавить родственника, обновлять приложение не нужно.

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

В общем чате пользователь видит ленту сообщений: свои — справа, чужие — слева. У каждого сообщения — круглый аватар отправителя (или первая буква имени, если аватара нет), время; у чужих — ещё имя отправителя над текстом.

```
Заголовок экрана: "Семейный чат"
Пустая лента: "Пока нет сообщений. Напишите первое"
Поле ввода (подсказка): "Сообщение"
Кнопка отправки: иконка "отправить" (неактивна, если поле пустое или текст длиннее лимита)
Счётчик длины (появляется после 80% лимита): "N/4096"
Статус неподтверждённого сообщения: "отправляется"
Snackbar при ошибке отправки: "Не удалось отправить сообщение"
```

Он печатает текст и нажимает отправку. Сообщение сразу появляется в ленте (в статусе «отправляется», пока сервер не подтвердит). Если текст длиннее 4096 символов — отправка блокируется.

#### Сценарий: Офлайн-режим

Пользователь без сети открывает чат и видит ранее загруженные сообщения из локального кэша. Он может напечатать и «отправить» сообщение — оно ставится в очередь (статус «отправляется») и уходит на сервер автоматически, когда сеть вернётся.

#### Сценарий: Настройки профиля

Из чата пользователь может открыть настройки (иконка «шестерёнка» в app bar, подсказка `"Настройки"`). Назад в чат — стрелкой в app bar.

```
Заголовок экрана: "Настройки"
Аватар: большая круглая картинка (или первая буква имени, если аватара нет)
Кнопка: "Изменить аватар"
Кнопка: "Удалить" (только если аватар есть)
Поле: "Имя" (текущее значение, до 64 символов, со счётчиком)
Кнопка: "Сохранить имя"
Диалог удаления аватара:
  Заголовок: "Удалить аватар?"
  Текст: "Аватар будет удалён. Изменение сразу отразится в чате."
  Кнопки: "Отмена" / "Удалить"
Snackbar при успехе: "Сохранено"
Snackbar при ошибке: "Не удалось сохранить"
```

Пользователь редактирует имя и жмёт «Сохранить имя», или выбирает картинку из галереи — она обрезается до квадрата, сжимается и загружается в облако. Новые сообщения уходят уже с новым именем и аватаром; старые сообщения сохраняют имя и аватар на момент отправки.

#### Сценарий: Выход

```
Иконка в app bar чата (подсказка): "Выйти"
```

Из чата пользователь может выйти из аккаунта — приложение сразу возвращает его на экран входа (без подтверждения).

### Экраны и навигация

```
[Splash / проверка auth]
        │
        ├─ не вошёл ──→ [Вход/Регистрация]
        │                     │ (успех)
        └─ вошёл ────────────→ [Семейный чат] ──(выход)──→ [Вход/Регистрация]
                                    │  ▲
                        (шестерёнка)│  │(назад)
                                    ▼  │
                                [Настройки]
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
- **Backend:** Firebase — Auth (email/password + Google), Cloud Firestore (с офлайн-persistence), Firebase Storage (аватары). Cloud Functions не используются.
- **Модели:** `freezed` + `json_serializable`.
- **Логирование:** `logger` (`lib/core/logger.dart`, `appLogger`). Crashlytics не подключён.
- **Медиа:** `image_picker` (выбор из галереи), `image` (обрезка/сжатие на клиенте).
- **Иконки:** `flutter_launcher_icons` (dev dependency).
- **Архитектурный стиль:** feature-first (`lib/features/<feature>/{data,domain,presentation}`) + общий `lib/core/`.
- **Платформы:** Android, macOS (без iOS/web/windows/linux в v1).
- Пакеты Firebase — актуальные мажорные версии, совместимые с рабочей сборкой: `firebase_core ^4`, `firebase_auth ^6`, `cloud_firestore ^6`, `firebase_storage ^13`, `google_sign_in ^7` (новый API `initialize()` + `authenticate()`). Это отклонение от версий из ассетов шаблона (там ^3/^5/^6), сделанное потому, что именно эти версии собираются и работают на маке.

### Детали: Bundle id / Application id

- **Android applicationId:** `dev.za9c.fassenger`
- **macOS bundle:** `dev.za9c.fassenger`
- **iOS:** `dev.za9c.fassenger` (Firebase iOS app и signing существуют, но платформа в v1 не заводится/не собирается)
- **Web:** не применимо в v1
- **Windows/Linux:** не применимо

### Детали: Иконка приложения

- Исходники: `assets/icon/icon.png` (1024×1024, белый символ «облачко-сообщение с домиком и сердцем» на коралловом фоне `#E85D4A`) и `assets/icon/icon_foreground.png` (символ на прозрачном фоне, ~50% площади — safe zone adaptive icon).
- Генерация: `dart run flutter_launcher_icons` (конфиг — секция `flutter_launcher_icons` в `pubspec.yaml`): Android legacy + adaptive (`adaptive_icon_background: #E85D4A`), macOS AppIcon.

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

Документ создаётся при первом открытии чата (`ensureMyProfile()`, идемпотентно) и перезаписывается при каждом сохранении настроек. Базовое имя при создании — `displayName` из Firebase Auth (или email до `@`). Каждая запись — полный `set()` всех четырёх полей (rules валидируют весь документ, merge не используется).

Совместимость: сообщения v0.1 хранили аватар в поле `senderPhotoUrl`; при чтении `Message.fromDoc` берёт `senderAvatarUrl ?? senderPhotoUrl`.

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

#### Поток: Открытие чата

1. После входа открывается `/`.
2. В `initState` (post-frame) вызывается `userRepository.ensureMyProfile()`: если `users/{uid}` нет — создаётся с именем из Firebase Auth (или email до `@`), `avatarUrl: null`. Ошибки игнорируются.
3. Подписка на `messagesStreamProvider` — последние 100 сообщений по `createdAt desc`, лента `ListView(reverse: true)`.

#### Поток: Отправка сообщения

1. В `/` пользователь вводит текст и жмёт отправку.
2. Клиент триммит текст, проверяет: не пустой и `<= 4096` символов (иначе — локальная ошибка/блокировка).
3. Снапшотятся имя и аватар: `ChatRepository` читает `users/{uid}` через `UserRepository.fetchProfile`; `senderName` = `displayName` профиля (fallback при отсутствии/ошибке: Firebase Auth `displayName` → email → `"Без имени"`), `senderAvatarUrl` = `avatarUrl` профиля (fallback: `user.photoURL`).
4. Пишется документ в `messages` с `createdAt: FieldValue.serverTimestamp()`.
5. Пока `metadata.hasPendingWrites` — сообщение отображается со статусом «отправляется».
6. При ошибке записи — snackbar `"Не удалось отправить сообщение"`.

#### Поток: Показ аватара в чате

1. Для каждого сообщения сначала берётся `senderAvatarUrl` из самого message (снапшот).
2. Если снапшот отсутствует (старые сообщения) — читается `users/{senderId}.avatarUrl` через `userProfileProvider(senderId)` (кэшируется в памяти Riverpod).
3. Если и там нет — показывается круг с первой буквой `senderName` (fallback avatar).

#### Поток: Сохранение имени

1. На `/settings` пользователь редактирует поле «Имя» и жмёт «Сохранить имя».
2. Пустое имя (после trim) игнорируется; длина ограничена полем (64). Вызывается `SettingsController.saveDisplayName` → `UserRepository.updateDisplayName(name)`.
3. Репозиторий читает текущий `avatarUrl` и пишет полный документ `users/{uid}` (`displayName`, `avatarUrl`, `email`, `updatedAt: serverTimestamp()`).
4. Затем — `firebaseUser.updateDisplayName(name)` (синхрон Firebase Auth).
5. Snackbar `"Сохранено"`; при ошибке — `"Не удалось сохранить"`.

#### Поток: Загрузка аватара

1. На `/settings` пользователь жмёт «Изменить аватар».
2. `image_picker` открывает системный picker (галерея); выбранный файл читается в память.
3. Проверка размера исходника (≤ 5 МБ), затем сжатие через `package:image`: `decodeImage` → `copyResizeCropSquare(size: 512)` → `encodeJpg(quality: 85)`. Результат — `Uint8List`.
4. Заливается в Storage путём `avatars/{uid}/avatar_<timestamp>.jpg` (новое имя каждый раз — чтобы сбить CDN-кэш у читателей).
5. После upload (`putData`, `contentType: image/jpeg`) — `getDownloadURL()`; полный документ `users/{uid}` перезаписывается с новым `avatarUrl`.
6. Старый файл (если был) удаляется best-effort через `refFromURL(oldUrl).delete()`.
7. Snackbar `"Сохранено"`; при ошибке — `"Не удалось сохранить"`.

#### Поток: Удаление аватара

1. Кнопка «Удалить аватар» → confirm dialog.
2. Полный документ `users/{uid}` перезаписывается с `avatarUrl: null`.
3. Файл в Storage удаляется best-effort.
4. В UI показывается fallback (круг с инициалом).

#### Поток: Офлайн

- Firestore persistence включена (`Settings(persistenceEnabled: true, cacheSizeBytes: unlimited)`).
- Лента читается через `snapshots(includeMetadataChanges: true)`; при отсутствии сети показываются кэшированные сообщения, новые записи ставятся в очередь и досылаются автоматически.

### Детали: Внешние интеграции

Только Firebase; сторонних API нет. Используются Firebase Auth, Cloud Firestore и Firebase Storage (для аватаров). Ключи Firebase — в `lib/firebase_options.dart` и platform-конфигах (`macos/Runner/GoogleService-Info.plist`, `android/app/google-services.json`). Репозиторий публичный, поэтому эти файлы **не коммитятся** (в `.gitignore`): локально их генерирует `flutterfire configure`, в GitHub Actions они восстанавливаются из Secrets (base64): `FIREBASE_OPTIONS_DART`, `GOOGLE_SERVICES_JSON`, `GOOGLE_SERVICE_INFO_PLIST`. API-ключи ограничены в Google Cloud Console: все — списком Firebase API; Android-ключ — дополнительно пакетом `dev.za9c.fassenger` + SHA-1 debug keystore. Apple-ключ по bundle id не ограничен (риск сломать macOS-клиент).

### Детали: Push-нотификации

Не применимо в v1. FCM нестабилен при блокировках в России и требует Cloud Function для отправки — отложено.

### Детали: Локализация

- Языки в v1: **`ru` (дефолт) и `en`**. Все тексты UI — через `AppLocalizations`, без зашитых строк.
- Механизм: встроенный `flutter_localizations` + `intl` + генератор через `flutter gen-l10n` (включается `flutter: generate: true` в `pubspec.yaml`).
- Файлы: `lib/l10n/app_ru.arb` (template-arb-file), `lib/l10n/app_en.arb`; конфиг `l10n.yaml` в корне (вывод в `lib/l10n/generated/`).
- Стратегия выбора языка: следует системной локали; если системная не `ru` и не `en` — fallback на `ru` (дефолт семьи).
- Набор ключей на v1 покрывает: заголовки экранов, кнопки входа/регистрации/Google, плейсхолдеры полей, snackbar-ошибки, счётчик длины, кнопку выхода, экран настроек (имя, аватар, диалог удаления, snackbar'ы).

### Детали: Сборка, CI и distribution

- **Локально (мак):** `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs` (после изменения аннотированных файлов) → `flutter build apk --release`.
- **JDK:** Android Studio поставляет JDK 25, который Gradle 8.14 не поддерживает → в `android/gradle.properties` зафиксирован `org.gradle.java.home` на Homebrew `openjdk@17`. В CI переопределяется user-level `~/.gradle/gradle.properties`.
- **Подпись release:** debug keystore (`signingConfigs.debug`); его SHA-1 зарегистрирован в Firebase для Google Sign-In.
- **CI:** `.github/workflows/build.yml` (GitHub Actions, `ubuntu-latest`, Temurin 17, Flutter stable) — на push/PR в `main` и вручную: восстановление конфигов из Secrets → `pub get` → `flutter analyze` → `flutter build apk --release` → артефакт на 14 дней. `build_runner` в CI не запускается — сгенерированные `*.g.dart`, `*.freezed.dart` и l10n закоммичены.
- **GitHub Secrets (base64):** `FIREBASE_OPTIONS_DART`, `GOOGLE_SERVICES_JSON`, `GOOGLE_SERVICE_INFO_PLIST`, `ANDROID_DEBUG_KEYSTORE`.
- **Distribution:** `firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk --app <Android app id> --testers '<6 email>' --release-notes '...'` с мака (Firebase CLI залогинен под владельцем проекта).
- **Версия:** `version` в `pubspec.yaml` (`X.Y.Z+build`); build number увеличивается с каждым релизом.

### Детали: Нефункциональные требования

- **Безопасность:** Firestore rules ограничивают запись (senderId == uid, лимит длины, серверное время); никаких `allow read, write: if true`. Не логировать PII. Репозиторий публичный — в нём нет email'ов, Firebase-конфигов и ключей подписи.
- **Надёжность:** Firestore offline persistence включена; ретраи записи — за счёт Firebase SDK.
- **Совместимость:** Android `minSdk = flutter.minSdkVersion` (дефолт Flutter), macOS >= 10.15. iOS не собирается в v1.
- **Производительность:** лента ограничена последними N (по умолчанию 100) сообщениями; при росте — пагинация через `startAfterDocument`.
- **UX:** Material 3, dark mode следует системе; свои/чужие сообщения визуально разделены; счётчик длины у лимита.

### Детали: Acceptance checklist

- [ ] `flutter analyze` проходит без ошибок и warning'ов.
- [ ] `flutter test` проходит.
- [ ] CI (`Build Android APK`) зелёный на последнем коммите `main`.
- [ ] Приложение запускается на macOS (и заводится проект Android).
- [ ] Firestore rules задеплоены и совпадают с этой спекой (whitelist читается из `config/access`).
- [ ] Storage rules задеплоены и совпадают с этой спекой (avatars/{uid}/, whitelist).
- [ ] Экраны `/auth`, `/` и `/settings` доступны и корректно защищены auth-редиректом.
- [ ] Вход по email/паролю и через Google работает на macOS (keychain entitlement на месте).
- [ ] Отправка сообщения проходит; в сообщение снапшотятся senderName и senderAvatarUrl.
- [ ] Иконка приложения на Android (в т.ч. adaptive) и macOS — из `assets/icon/`.
- [ ] В чате рядом с bubble показывается аватар отправителя (или инициал как fallback).
- [ ] На /settings можно изменить имя и загрузить/удалить аватар; изменения сразу отражаются в чате.
- [ ] Незалистенный email не может ни читать, ни писать (Firestore/Storage возвращают permission denied).
- [ ] Локализация работает: при системной локали `en` UI на английском, во всех остальных — на русском.
- [ ] В репозитории нет email'ов, Firebase-конфигов, ключей подписи.
- [ ] `SPEC.md` актуален (дата в шапке — сегодняшняя).

### Детали: Known current deployment state

- **Firebase project id:** `fassenger-62009` (messagingSenderId `847260960210`).
- **Firebase apps:**
  - Android: `1:847260960210:android:9b8e99e48c659b38beb40b`, package `dev.za9c.fassenger`, SHA-1 debug keystore `3A:2A:02:43:F3:C7:43:36:1F:4F:BA:57:CD:02:51:14:DF:22:11:43`.
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
- **Releases (Android, Firebase App Distribution):**
  - v0.2.1(3) — `10iueje1n379o`, 2026-10-06 — новая иконка приложения. Раздан всем 6 тестерам. **Текущий.**
  - v0.2.0(2) — `371otvjq09kjo`, 2026-10-05 — профиль: имя + аватар.
  - v0.1.0(1) — `7ervu48hfbia0` — первый релиз, общий чат.
- **macOS:** собирается локально, не распространяется.
- **Репозиторий:** [kissedcode/family-chat-flutter-app](https://github.com/kissedcode/family-chat-flutter-app), публичный с 2026-10-05 (история до этого не переносилась). CI — см. «Сборка, CI и distribution».
