# Fassenger — Спецификация

Версия документа: 2026-10-06
Текущая инсталляция: bundle `dev.za9c.fassenger` · Firebase project `fassenger-62009` · платформы: Android, macOS
Назначение: Приватный семейный мессенджер на ~20 родственников — общий семейный чат и личные чаты 1-на-1, с профилями (имя + аватар), устойчивый к нестабильному интернету. Бэкенд на Firebase.

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

Fassenger — закрытый семейный мессенджер для одной семьи (~20 человек). Главный экран — список чатов: сверху общий семейный чат, где все видят одну ленту, ниже — личные переписки 1-на-1 между двумя членами семьи. Сообщения приходят в реальном времени. Приложение спроектировано с расчётом на нестабильный интернет (в т.ч. блокировки в России): сообщения кэшируются локально и досылаются, когда связь восстанавливается.

Главные возможности:

- Список чатов: общий семейный чат закреплён сверху, ниже — личные чаты, свежие сверху.
- Личные чаты 1-на-1 с любым членом семьи (кнопка «+»).
- Счётчик непрочитанных сообщений у каждого чата.
- В строке чата — начало последнего сообщения и время.
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

#### Сценарий: Список чатов

После входа открывается список чатов.

```
Заголовок экрана: "Чаты"
Первая строка (всегда, закреплена): "Семейный чат"
Ниже: личные чаты — аватар и имя собеседника
В каждой строке: начало последнего сообщения и время (сегодня — "14:05", раньше — дата "05.10")
  Своё последнее сообщение — с префиксом: "Вы: "
  В общем чате чужое — с именем: "Мама: …"
  Сообщений ещё нет: "Нет сообщений"
Счётчик непрочитанных: кружок с числом справа ("1"…"99", больше — "99+"); нет непрочитанных — кружка нет
Кнопка (FAB, подсказка): "Новый чат"
Иконки в app bar (подсказки): "Настройки", "Выйти"
```

Личные чаты отсортированы по времени последнего сообщения (свежие сверху). Личный чат появляется в списке у обоих собеседников после первого сообщения.

#### Сценарий: Начать личный чат

Пользователь нажимает «+» и попадает на экран выбора собеседника.

```
Заголовок экрана: "Новый чат"
Список: все члены семьи, кроме себя — аватар и имя, по алфавиту
Пустой список: "Пока никого нет. Родственники появятся здесь после первого входа в приложение"
```

Тап по человеку открывает личный чат с ним (если переписка уже есть — открывается она же). Если ничего не написать и вернуться назад, чат в списке не появится.

#### Сценарий: Непрочитанные

Когда в чат приходит чужое сообщение, а пользователь этот чат не открыл, у чата в списке растёт счётчик. Открытие чата сбрасывает счётчик; пока чат открыт, новые сообщения сразу считаются прочитанными. Свои сообщения непрочитанными не считаются. Счётчик синхронизируется между устройствами пользователя.

#### Сценарий: Чтение и отправка сообщений

Общий и личные чаты выглядят и работают одинаково. В app bar — стрелка «назад» к списку чатов и название: `"Семейный чат"` или аватар и имя собеседника. В личном чате имя отправителя над чужими сообщениями не показывается (и так понятно, кто пишет).

В чате пользователь видит ленту сообщений: свои — справа, чужие — слева. У каждого сообщения — круглый аватар отправителя (или первая буква имени, если аватара нет), время; у чужих — ещё имя отправителя над текстом.

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

Из списка чатов пользователь может открыть настройки (иконка «шестерёнка» в app bar, подсказка `"Настройки"`). Назад — стрелкой в app bar.

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
Иконка в app bar списка чатов (подсказка): "Выйти"
```

Из списка чатов пользователь может выйти из аккаунта — приложение сразу возвращает его на экран входа (без подтверждения).

### Экраны и навигация

```
[Splash / проверка auth]
        │
        ├─ не вошёл ──→ [Вход/Регистрация]
        │                     │ (успех)
        └─ вошёл ────────────→ [Список чатов] ──(выход)──→ [Вход/Регистрация]
                                 │    │    │
                     (шестерёнка)│    │    │(тап по чату)
                                 ▼    │    ▼
                         [Настройки]  │  [Чат: общий или личный]
                                   (+)│    ▲
                                      ▼    │(тап по человеку)
                                  [Новый чат]
```

Со всех экранов, кроме списка чатов, — «назад» возвращает на предыдущий экран.

| Экран            | Заходят откуда                       | Куда ведут действия              |
|------------------|--------------------------------------|----------------------------------|
| Splash           | старт приложения                     | Вход или Список чатов            |
| Вход/Регистрация | Splash (если не вошёл), после выхода | Список чатов (после успеха)      |
| Список чатов     | после входа                          | Чат, Новый чат, Настройки, Вход (после выхода) |
| Чат (общий/личный) | Список чатов, Новый чат            | Список чатов (назад)             |
| Новый чат        | Список чатов (кнопка «+»)            | Личный чат, Список чатов (назад) |
| Настройки        | Список чатов (иконка шестерёнки)     | Список чатов (назад)             |

### Границы функциональности

- Приложение **не** делает медиа в сообщениях в v1: без фото, видео, файлов, голосовых (только текст). Аватары — исключение (это профильная картинка, не сообщение).
- Приложение **не** имеет групповых чатов, кроме одного общего семейного, и каналов. Личные чаты — строго на двоих.
- Чат **нельзя** удалить, скрыть, закрепить или выключить в нём звук.
- Приложение **не** присылает push-уведомления: о новых сообщениях видно только по счётчику внутри приложения.
- Личные сообщения видят только двое участников (другие члены семьи их не видят). Но шифрования end-to-end нет: технически администратор Firebase-проекта может прочитать любую переписку через консоль.
- Приложение **не** показывает «доставлено/прочитано» собеседником и «печатает…».
- Приложение **не** редактирует и **не** удаляет отправленные сообщения.
- Приложение **не** заменяет полноценный мессенджер (Telegram/WhatsApp) — это узкий семейный инструмент.

---

## Техническая спецификация для реализации

### Детали: Цель и границы системы

- Реализуются общий семейный чат и личные чаты 1-на-1 на Firestore с real-time лентами, списком чатов, счётчиками непрочитанных и офлайн-кэшем.
- Аутентификация: email/password + Google Sign-In.
- Whitelist участников по email — в Firestore-документе `config/access` (не в коде: репозиторий публичный); проверяется Security Rules.
- Профили пользователей (имя + аватар) — в Firestore `users/{uid}` + Firebase Storage для картинок.
- Out of scope: медиа в сообщениях, групповые чаты кроме общего, удаление/скрытие чатов, E2E-шифрование, push-нотификации, read receipts.
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

Коллекция `messages/{messageId}` — сообщения **общего** чата (оставлена на верхнем уровне без миграции: клиенты v0.1–v0.2 продолжают в неё писать):

| Поле              | Тип       | Обязательное | Описание                                                    |
|-------------------|-----------|--------------|-------------------------------------------------------------|
| `text`            | string    | да           | текст сообщения, 1..4096 символов                           |
| `senderId`        | string    | да           | uid отправителя (== `request.auth.uid`)                     |
| `senderName`      | string    | да           | снапшот: имя на момент отправки                         |
| `senderAvatarUrl` | string    | нет          | снапшот: URL аватара на момент отправки, `null` если нет |
| `createdAt`       | timestamp | да           | серверное время (`FieldValue.serverTimestamp()`)            |

Коллекция `chats/{chatId}` — **личные** чаты. `chatId` = `<uidA>_<uidB>`, где `uidA < uidB` (лексикографически) — детерминированный id, поэтому у пары ровно один чат и его не нужно искать. Для общего чата документа нет.

| Поле          | Тип           | Обязательное | Описание                                                    |
|---------------|---------------|--------------|-------------------------------------------------------------|
| `members`     | array<string> | да           | `[uidA, uidB]`, отсортированы; неизменяемо                  |
| `createdAt`   | timestamp     | да           | серверное время создания (первое сообщение)                 |
| `lastMessage` | map           | да           | `{text, senderId, senderName, createdAt}` — копия последнего сообщения для списка чатов; `text` обрезан до 200 символов |

Подколлекция `chats/{chatId}/messages/{messageId}` — сообщения личного чата, схема полей та же, что у `messages`.

Подколлекция `users/{uid}/reads/{chatId}` — отметка «прочитано до» для счётчика непрочитанных; `chatId` = `general` для общего чата или id личного чата:

| Поле         | Тип       | Обязательное | Описание                                   |
|--------------|-----------|--------------|--------------------------------------------|
| `lastReadAt` | timestamp | да           | серверное время последнего открытия/просмотра чата |

Коллекция `users/{uid}` — один документ на пользователя (`uid` == Firebase Auth uid):

| Поле          | Тип       | Обязательное | Описание                                                       |
|---------------|-----------|--------------|----------------------------------------------------------------|
| `displayName` | string    | да           | текущее отображаемое имя (1..64 символов)                 |
| `avatarUrl`   | string    | нет          | URL текущего аватара в Firebase Storage, `null` если нет |
| `email`       | string    | да           | email из Firebase Auth (для диагностики)                    |
| `updatedAt`   | timestamp | да           | серверное время последнего обновления                    |

Документ создаётся при первом открытии чата (`ensureMyProfile()`, идемпотентно) и перезаписывается при каждом сохранении настроек. Базовое имя при создании — `displayName` из Firebase Auth (или email до `@`). Каждая запись — полный `set()` всех четырёх полей (rules валидируют весь документ, merge не используется).

Совместимость: сообщения v0.1 хранили аватар в поле `senderPhotoUrl`; при чтении `Message.fromDoc` берёт `senderAvatarUrl ?? senderPhotoUrl`.

Индексы (`firestore.indexes.json`):

- `chats`: `members` ARRAY_CONTAINS + `lastMessage.createdAt` DESC — для списка личных чатов (`where('members', arrayContains: myUid).orderBy('lastMessage.createdAt', descending: true)`).
- Ленты (`orderBy('createdAt', descending: true).limit(N)`) и запросы непрочитанных (`where('createdAt', isGreaterThan: lastReadAt).orderBy('createdAt')`) покрываются одиночными индексами.

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

    // Валидация нового сообщения (общая для общего и личных чатов).
    function isValidNewMessage() {
      return request.resource.data.senderId == request.auth.uid
        && request.resource.data.text is string
        && request.resource.data.text.size() > 0
        && request.resource.data.text.size() <= 4096
        && request.resource.data.senderName is string
        && request.resource.data.createdAt == request.time;
    }

    // Личный чат: id = "<uidA>_<uidB>", uidA < uidB. Участник — тот, чей uid в id.
    // Проверка по id (а не по resource) работает и для ещё не созданного документа.
    function isDirectMember(chatId) {
      return request.auth.uid in chatId.split('_');
    }

    // ── Общий чат ───────────────────────────────────────────────
    match /messages/{messageId} {
      allow read: if isFamily();
      allow create: if isFamily() && isValidNewMessage();
      allow update, delete: if false;
    }

    // ── Личные чаты ─────────────────────────────────────────────
    match /chats/{chatId} {
      // get — по id (работает и для несуществующего чата);
      // list — по members (запрос where members array-contains myUid).
      allow get: if isFamily() && isDirectMember(chatId);
      allow list: if isFamily() && request.auth.uid in resource.data.members;

      allow create: if isFamily()
        && request.resource.data.keys().hasOnly(['members', 'createdAt', 'lastMessage'])
        && request.resource.data.members is list
        && request.resource.data.members.size() == 2
        && request.resource.data.members[0] < request.resource.data.members[1]
        && chatId == request.resource.data.members[0] + '_' + request.resource.data.members[1]
        && request.auth.uid in request.resource.data.members
        && request.resource.data.createdAt == request.time;

      // Обновлять можно только lastMessage, и только своим сообщением.
      allow update: if isFamily()
        && isDirectMember(chatId)
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['lastMessage'])
        && request.resource.data.lastMessage.senderId == request.auth.uid
        && request.resource.data.lastMessage.createdAt == request.time;

      allow delete: if false;

      match /messages/{messageId} {
        allow read: if isFamily() && isDirectMember(chatId);
        allow create: if isFamily() && isDirectMember(chatId) && isValidNewMessage();
        allow update, delete: if false;
      }
    }

    // ── Профили ─────────────────────────────────────────────────
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

      // Отметки «прочитано до» — только свои.
      match /reads/{chatId} {
        allow read: if isFamily() && request.auth.uid == uid;
        allow write: if isFamily()
          && request.auth.uid == uid
          && request.resource.data.keys().hasOnly(['lastReadAt'])
          && request.resource.data.lastReadAt == request.time;
      }
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
| `/`         | ChatListScreen | да           | не применимо  |
| `/chat/:chatId` | ChatScreen (`chatId` = `general` или id личного чата) | да | не применимо |
| `/new-chat` | NewChatScreen  | да           | не применимо  |
| `/settings` | SettingsScreen | да           | не применимо  |

Redirect logic (в `core/router.dart`):

- Если `!signedIn` и роут не `/auth` → `/auth`.
- Если `signedIn` и текущий роут `/auth` → `/`.

### Детали: Riverpod-провайдеры

- `authRepositoryProvider` (`Provider<AuthRepository>`) — обёртка над `FirebaseAuth` + `GoogleSignIn` (email/Google вход, регистрация, reset, signOut).
- `authStateChangesProvider` (`StreamProvider<User?>`) — `FirebaseAuth.instance.authStateChanges()`; используется роутером для redirect.
- `chatRepositoryProvider` (`Provider<ChatRepository>`) — сообщения общего (`messages`) и личных (`chats/{id}/messages`) чатов: стримы, отправка, `lastMessage`, отметки прочтения.
- `messagesStreamProvider(chatId)` (`StreamProvider.family<List<Message>, String>`) — real-time лента последних 100 сообщений чата.
- `directChatsProvider` (`StreamProvider<List<DirectChat>>`) — личные чаты текущего пользователя, отсортированы по `lastMessage.createdAt` desc.
- `generalLastMessageProvider` (`StreamProvider<Message?>`) — последнее сообщение общего чата (`messages` orderBy createdAt desc limit 1) для превью.
- `unreadCountProvider(chatId)` (`StreamProvider.family<int, String>`) — число чужих сообщений с `createdAt > lastReadAt` (до 100; UI показывает `99+`).
- `familyMembersProvider` (`StreamProvider<List<UserProfile>>`) — все `users`, кроме себя, по `displayName` — для экрана «Новый чат» и имён собеседников.
- `chatControllerProvider(chatId)` — отправка сообщения (loading/error).
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

#### Поток: Список чатов

1. После входа открывается `/`. В `initState` (post-frame) вызывается `userRepository.ensureMyProfile()`: если `users/{uid}` нет — создаётся с именем из Firebase Auth (или email до `@`), `avatarUrl: null`. Ошибки игнорируются.
2. Первая строка — общий чат: превью из `generalLastMessageProvider`, счётчик из `unreadCountProvider('general')`.
3. Ниже — `directChatsProvider`. Для каждого: собеседник = `members` без себя; имя/аватар — `userProfileProvider(otherUid)`; превью — `lastMessage`; счётчик — `unreadCountProvider(chatId)`.
4. Превью: `"Вы: "` + текст для своих; в общем чате для чужих — `"<senderName>: "` + текст; одна строка с многоточием. Время: сегодня — `HH:mm`, иначе `dd.MM`.

#### Поток: Новый личный чат

1. FAB «+» → `/new-chat`, список из `familyMembersProvider`.
2. Тап по человеку: `chatId = [myUid, otherUid]..sort()..join('_')` → `context.pushReplacement('/chat/$chatId')`. Документ `chats/{chatId}` **не** создаётся заранее.
3. Чат создаётся при первом сообщении (см. «Отправка сообщения»).

#### Поток: Открытие чата

1. `/chat/:chatId` → подписка на `messagesStreamProvider(chatId)` — последние 100 сообщений по `createdAt desc`, лента `ListView(reverse: true)`. Для `general` — коллекция `messages`, иначе `chats/{chatId}/messages`.
2. Заголовок: `general` → `"Семейный чат"`; иначе аватар + имя собеседника (uid из `chatId.split('_')` без себя).
3. Сразу при открытии и при каждом новом snapshot ленты, пока экран открыт, — отметка прочтения (см. «Непрочитанные»).

#### Поток: Отправка сообщения

1. В `/` пользователь вводит текст и жмёт отправку.
2. Клиент триммит текст, проверяет: не пустой и `<= 4096` символов (иначе — локальная ошибка/блокировка).
3. Снапшотятся имя и аватар: `ChatRepository` читает `users/{uid}` через `UserRepository.fetchProfile`; `senderName` = `displayName` профиля (fallback при отсутствии/ошибке: Firebase Auth `displayName` → email → `"Без имени"`), `senderAvatarUrl` = `avatarUrl` профиля (fallback: `user.photoURL`).
4. Общий чат: пишется документ в `messages` с `createdAt: FieldValue.serverTimestamp()`.
5. Личный чат: один `WriteBatch` — (a) новый документ в `chats/{chatId}/messages`; (b) `chats/{chatId}`: если документа ещё нет (проверка `get()` из кэша/сервера) — `set` с `members`, `createdAt`, `lastMessage`; иначе — `update({lastMessage})`. `lastMessage.createdAt` = `serverTimestamp()`, `text` обрезается до 200 символов. Batch атомарен и работает офлайн (досылается целиком).
6. Пока `metadata.hasPendingWrites` — сообщение отображается со статусом «отправляется».
7. При ошибке записи — snackbar `"Не удалось отправить сообщение"`.

#### Поток: Непрочитанные

1. Отметка прочтения: `users/{myUid}/reads/{chatId}` ← `{lastReadAt: serverTimestamp()}` (`set`). Пишется при открытии чата и при новых сообщениях в открытом чате (не чаще раза в 2 секунды).
2. Подсчёт (`unreadCountProvider(chatId)`): слушается `reads/{chatId}`; затем лента чата `where('createdAt', isGreaterThan: lastReadAt).orderBy('createdAt').limit(100)`, из результата отбрасываются свои (`senderId == myUid`). Нет документа `reads` → считаются последние 100 сообщений (для чатов, которые пользователь ни разу не открывал).
3. Работает офлайн по локальному кэшу; синхронизируется между устройствами через `reads`.
4. Сообщения клиентов v0.2 в общем чате тоже учитываются (подсчёт идёт по самой ленте, а не по счётчикам).

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
- Новые ключи v0.3: `chatListTitle` («Чаты»), `chatGeneralTitle` («Семейный чат»), `chatListNoMessages` («Нет сообщений»), `chatListYouPrefix` («Вы: »), `chatListNewChat` («Новый чат»), `newChatTitle` («Новый чат»), `newChatEmpty` («Пока никого нет. Родственники появятся здесь после первого входа в приложение»), `unreadOverflow` («99+»).
- Набор ключей покрывает: заголовки экранов, кнопки входа/регистрации/Google, плейсхолдеры полей, snackbar-ошибки, счётчик длины, кнопку выхода, экран настроек (имя, аватар, диалог удаления, snackbar'ы).

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
- **Производительность:** лента ограничена последними 100 сообщениями (пагинация — позже через `startAfterDocument`). Список чатов: 1 listener на список + по 2 (reads + лента непрочитанных, limit 100) на чат; при ~20 чатах это приемлемо.
- **UX:** Material 3, dark mode следует системе; свои/чужие сообщения визуально разделены; счётчик длины у лимита.

### Детали: Acceptance checklist

- [ ] `flutter analyze` проходит без ошибок и warning'ов.
- [ ] `flutter test` проходит.
- [ ] CI (`Build Android APK`) зелёный на последнем коммите `main`.
- [ ] Приложение запускается на macOS (и заводится проект Android).
- [ ] Firestore rules задеплоены и совпадают с этой спекой (whitelist читается из `config/access`).
- [ ] Storage rules задеплоены и совпадают с этой спекой (avatars/{uid}/, whitelist).
- [ ] Экраны `/auth`, `/`, `/chat/:chatId`, `/new-chat` и `/settings` доступны и корректно защищены auth-редиректом.
- [ ] Список чатов: общий чат всегда первым, личные — по времени последнего сообщения; превью и время корректны.
- [ ] Из «Новый чат» открывается личный чат; без сообщений он не появляется в списке; после первого сообщения — у обоих.
- [ ] Третий член семьи не может прочитать чужой личный чат (permission denied) — проверено rules-тестом или вручную.
- [ ] Счётчик непрочитанных растёт от чужих сообщений, обнуляется при открытии чата, не растёт от своих.
- [ ] Composite index `chats (members, lastMessage.createdAt desc)` задеплоен.
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
- **Firestore rules:** задеплоены (whitelist из `config/access` в `isFamily()`). Включают личные чаты (`chats/**`) и отметки прочтения (`users/*/reads/*`); проверены в эмуляторе (20 кейсов доступа).
- **Firestore indexes:** `chats (members CONTAINS, lastMessage.createdAt DESC)` — READY.
- **Storage rules:** задеплоены (whitelist из `config/access` в `isFamilyStorage()`, `avatars/{uid}/{fileName}` ≤ 5 МБ image/*).
- **Whitelist:** 5 email'ов в `config/access` (Firestore).
- **Firebase App Distribution:** 6 тестеров, раздача через `--testers` (группы нет). Один из тестеров может ставить APK, но не в whitelist — читать/писать чат не может.
- **Releases (Android, Firebase App Distribution):**
  - v0.3.0(4) — 2026-10-06 — список чатов, личные чаты 1-на-1, счётчики непрочитанных. Раздан всем 6 тестерам. **Текущий.**
  - v0.2.1(3) — `10iueje1n379o`, 2026-10-06 — новая иконка приложения.
  - v0.2.0(2) — `371otvjq09kjo`, 2026-10-05 — профиль: имя + аватар.
  - v0.1.0(1) — `7ervu48hfbia0` — первый релиз, общий чат.
- **macOS:** собирается локально, не распространяется.
- **Репозиторий:** [kissedcode/family-chat-flutter-app](https://github.com/kissedcode/family-chat-flutter-app), публичный с 2026-10-05 (история до этого не переносилась). CI — см. «Сборка, CI и distribution».
