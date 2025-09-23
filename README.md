## Garden (Flutter) — README

Мобильное приложение (Flutter) для работы с бэкендом Agriculture Importer. Позволяет регистрироваться/входить, добавлять растения в «Мой сад», получать план ухода и подробные рекомендации.

## Стек
- Flutter (Dart)
- http, shared_preferences

## Требования
- Flutter SDK установлен
- Запущенный бэкенд на http://localhost:8080 (Android эмулятор использует http://10.0.2.2:8080)

## Запуск
1. Установить зависимости: `flutter pub get`
2. Android эмулятор:
   - API URL внутри приложения: `http://10.0.2.2:8080/api`
3. iOS симулятор / Web (при необходимости):
   - при необходимости поменяйте базовый URL в `lib/api/api_service.dart`
4. Запуск: `flutter run`

## Конфигурация API
- Базовый URL задаётся в `lib/api/api_service.dart`:
  - Android эмулятор: `http://10.0.2.2:8080/api`
  - iOS/Web: `http://localhost:8080/api`
- Токен авторизации хранится в SharedPreferences (`auth_token`).

## Основные экраны и потоки

- Регистрация/Вход (экраны могут быть в процессе интеграции с онбордингом):
  - Регистрация: POST `/api/auth/register`
  - Вход: POST `/api/auth/login`
  - Сброс пароля (MVP): POST `/api/auth/password/reset-request`, `/api/auth/password/reset-confirm`

- Мой сад — `lib/screens/my_garden_screen.dart`
  - Загружает список растений пользователя: GET `/api/plants`
  - Удаление растения: DELETE `/api/plants/{id}`
  - Добавление растения → переход в каталог/форму добавления

- Добавление растения — `lib/screens/add_plant_screen.dart`
  - POST `/api/plants`
  - Поля: culture (используем введённое имя), name, variety?, plantingDate, growthStage?
  - Регион и тип участка подтягиваются из профиля пользователя на бэкенде

- Детали растения — `lib/screens/plant_detail_screen.dart`
  - Кнопка «График подкормок (сводный)» → `FeedingScheduleScreen`
  - Кнопка «План ухода подробно» → `CarePlanDetailsScreen`

- График подкормок (сводный) — `lib/screens/feeding_schedule_screen.dart`
  - GET `/api/plants/{plantId}/care-plan`
  - Рендер динамической таблицы из `schedule` (`period/phase/fertilizer/method`)

- Подробный план ухода — `lib/screens/care_plan_details_screen.dart`
  - GET `/api/care-plans/by-params?culture=...&region=...&gardenType=...`
  - Маппинг JSON `operations[]` (type, fase, period, description, materials[], alternatives[])

## API-клиент
- `lib/api/api_service.dart` содержит:
  - Универсальный `_request()` (GET/POST/DELETE)
  - Auth: `register`, `login`, `resetRequest`, `resetConfirm`
  - Plants: `getUserPlants`, `addPlant`, `deletePlant`, `getPlantCarePlan`
  - Care plans (public): `getCarePlanByParams`, `getCarePlanByHash`

## Примечания по интеграции
- Для Android эмулятора используйте `10.0.2.2` вместо `localhost`.
- Пароль по политике бэкенда: длина 5–6 символов, буквы+цифры (валидацию выполняет бэкенд; на фронте рекомендуется добавить подсказку пользователю).
- План ухода в БД хранится как JSON; сводный график агрегируется на бэке и отдаётся через `/plants/{id}/care-plan`.

## TODO (рекомендации)
- Экран логина/регистрации — добавить полноценные формы и навигацию из онбординга
- Улучшить валидации форм на фронте
- Пагинация и лоадеры для списков
- Подтверждение удаления с анимациями/скелетонами
- Локализация строк

# garden

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
