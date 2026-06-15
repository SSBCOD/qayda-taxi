# 🚕 Qayda — Билингвальное такси-приложение

<p align="center">
  <b>Qayda</b> — MVP такси-приложения для Казахстана с поддержкой двух языков (RU / KZ)
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.44-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.12-0175C2?logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-connected-FFCA28?logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/Riverpod-2.6-blue" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Windows-green" />
</p>

---

## О проекте

**Qayda** (қайда — «куда?» на казахском) — дипломный проект MVP такси-приложения с двумя ролями:

| Роль | Возможности |
|------|-------------|
| 🧍 Пассажир | Поиск адреса, выбор тарифа, отслеживание водителя, история поездок, оплата |
| 🚗 Водитель | Панель управления, принятие заказов, KYC-верификация, заработок, кошелёк |

---

## Технологии

- **Flutter 3.44** + **Dart 3.12**
- **Riverpod 2.6** — управление состоянием
- **GoRouter 14** — навигация с RedirectGuard
- **Firebase** (Auth + Firestore) — backend
- **OpenStreetMap** (flutter_map + OSRM) — карты без API-ключей
- **Двуязычность** — RU / KZ через ARB-локализацию

---

## Архитектура

```
lib/
├── main.dart              # точка входа
├── app/                   # root widget, router, bootstrap
├── core/                  # тема, локализация, виджеты, утилиты
├── data/                  # модели, репозитории, datasources
├── services/              # firebase, геолокация, уведомления
└── features/
    ├── auth/              # вход через номер телефона + OTP
    ├── passenger/         # карта, поиск, поездка, история
    ├── driver/            # дашборд, заказы, KYC, кошелёк
    ├── payment/           # методы оплаты
    └── settings/          # настройки, тема, уведомления
```

---

## Запуск

```bash
# Установка зависимостей
flutter pub get

# Запуск на Android
flutter run -d android

# Запуск на Windows (для демо)
flutter run -d windows
```

> На Windows OTP-код виден прямо на экране в режиме разработки.

---

## Дипломный проект

Разработано как MVP для дипломной работы. Использует fake-сервисы для симуляции поездок и платежей.

---

<p align="center">Made with ❤️ in Kazakhstan 🇰🇿</p>
