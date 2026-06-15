import 'package:flutter/material.dart';

/// FAQ category chip shown in the help-center bento grid.
class FaqCategory {
  final String id;
  final String labelRu;
  final String labelKk;
  final IconData icon;

  const FaqCategory({
    required this.id,
    required this.labelRu,
    required this.labelKk,
    required this.icon,
  });
}

/// A single bilingual FAQ entry with accordion answer.
class FaqItem {
  final String id;
  final String categoryId;
  final String questionRu;
  final String questionKk;
  final String answerRu;
  final String answerKk;
  final List<String> searchKeywords;

  const FaqItem({
    required this.id,
    required this.categoryId,
    required this.questionRu,
    required this.questionKk,
    required this.answerRu,
    required this.answerKk,
    this.searchKeywords = const [],
  });

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase();
    return questionRu.toLowerCase().contains(q) ||
        questionKk.toLowerCase().contains(q) ||
        answerRu.toLowerCase().contains(q) ||
        answerKk.toLowerCase().contains(q) ||
        searchKeywords.any((k) => k.toLowerCase().contains(q));
  }
}

const kFaqCategories = [
  FaqCategory(
    id: 'rides',
    labelRu: 'Поездки',
    labelKk: 'Сапарлар',
    icon: Icons.commute,
  ),
  FaqCategory(
    id: 'payment',
    labelRu: 'Оплата',
    labelKk: 'Төлем',
    icon: Icons.payments_outlined,
  ),
  FaqCategory(
    id: 'account',
    labelRu: 'Аккаунт',
    labelKk: 'Аккаунт',
    icon: Icons.account_circle_outlined,
  ),
  FaqCategory(
    id: 'safety',
    labelRu: 'Безопасность',
    labelKk: 'Қауіпсіздік',
    icon: Icons.verified_user_outlined,
  ),
];

/// Seed FAQ — adapted for the KZ market (₸, Kaspi, local banks).
const kFaqItems = [
  FaqItem(
    id: 'payment_change',
    categoryId: 'payment',
    questionRu: 'Как изменить способ оплаты?',
    questionKk: 'Төлем әдісін қалай өзгертуге болады?',
    answerRu: 'Откройте «Профиль» → «Способы оплаты» или нажмите строку оплаты '
        'перед заказом на экране тарифа. Доступны: Kaspi Gold, Freedom, Halyk '
        'и наличные (₸).',
    answerKk:
        '«Профиль» → «Төлем әдістері» бөлімін ашыңыз немесе тариф экранында '
        'тапсырыс бермес бұрын төлем жолын басыңыз. Kaspi Gold, Freedom, '
        'Halyk және қолма-қол ақша (₸) қолжетімді.',
    searchKeywords: ['kaspi', 'карта', 'төлем', 'оплата'],
  ),
  FaqItem(
    id: 'lost_item',
    categoryId: 'rides',
    questionRu: 'Что делать, если я забыл вещь?',
    questionKk: 'Егер затты ұмытып кетсем не істеу керек?',
    answerRu:
        'Свяжитесь с водителем в течение 24 часов через «История поездок». '
        'Если прошло больше времени — напишите в чат поддержки Qayda Care.',
    answerKk:
        '«Сапарлар тарихы» арқылы 24 сағат ішінде жүргізушімен хабарласыңыз. '
        'Уақыт көп өтсе — Qayda Care қолдау чатына жазыңыз.',
    searchKeywords: ['забыл', 'вещь', 'ұмыт', 'зат'],
  ),
  FaqItem(
    id: 'tariffs',
    categoryId: 'rides',
    questionRu: 'Как работают тарифы?',
    questionKk: 'Тарифтер қалай жұмыс істейді?',
    answerRu: 'Стоимость в тенге (₸) зависит от расстояния и времени в пути по '
        'тарифам Алматы: Эконом от 600 ₸, Комфорт от 900 ₸, Бизнес от '
        '1 800 ₸. Финальная цена показывается до подтверждения заказа.',
    answerKk: 'Баға теңгемен (₸) қашықтық пен жол уақытына байланысты: Эконом '
        '600 ₸-ден, Комфорт 900 ₸-ден, Бизнес 1 800 ₸-ден басталады. '
        'Соңғы баға тапсырысты растамас бұрын көрсетіледі.',
    searchKeywords: ['тариф', 'цена', 'тенге', 'баға', '₸'],
  ),
  FaqItem(
    id: 'kaspi_pay',
    categoryId: 'payment',
    questionRu: 'Как оплатить через Kaspi?',
    questionKk: 'Kaspi арқылы қалай төлеуге болады?',
    answerRu:
        'Привяжите карту Kaspi Gold в разделе «Способы оплаты». После поездки '
        'сумма спишется автоматически в тенге. Чек придёт в приложение Kaspi.',
    answerKk:
        '«Төлем әдістері» бөлімінде Kaspi Gold картасын тіркеңіз. Сапардан '
        'кейін сома теңгемен автоматты түрде есептен шығады. Түбіртек Kaspi '
        'қосымшасына келеді.',
    searchKeywords: ['kaspi', 'каспи', 'gold'],
  ),
  FaqItem(
    id: 'cancel_ride',
    categoryId: 'rides',
    questionRu: 'Как отменить поездку?',
    questionKk: 'Сапарды қалай болдырмауға болады?',
    answerRu: 'На экране ожидания или активной поездки нажмите «Отменить». '
        'При отмене после прибытия водителя может взиматься минимальная '
        'плата по правилам сервиса.',
    answerKk:
        'Күту немесе белсенді сапар экранында «Болдырмау» түймесін басыңыз. '
        'Жүргізуші келгеннен кейін болдырмағанда минималды төлем алынуы '
        'мүмкін.',
    searchKeywords: ['отмена', 'болдырмау', 'cancel'],
  ),
  FaqItem(
    id: 'safety',
    categoryId: 'safety',
    questionRu: 'Как обеспечивается безопасность?',
    questionKk: 'Қауіпсіздік қалай қамтамасыз етіледі?',
    answerRu: 'Все водители проходят верификацию (ИИН, документы). Поездка '
        'отслеживается на карте в реальном времени. В экстренной ситуации '
        'используйте кнопку «SOS» в активной поездке.',
    answerKk:
        'Барлық жүргізушілер тексеруден өтеді (ЖСН, құжаттар). Сапар нақты '
        'уақытта картада бақыланады. Шұғыл жағдайда белсенді сапарда «SOS» '
        'түймесін пайдаланыңыз.',
    searchKeywords: ['безопасность', 'қауіпсіздік', 'sos', 'иин'],
  ),
];
