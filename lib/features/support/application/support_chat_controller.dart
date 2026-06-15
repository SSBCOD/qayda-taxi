import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A single chat bubble in the support conversation.
class ChatMessage {
  final String id;
  final bool isFromUser;
  final String text;
  final DateTime time;
  final bool read;

  const ChatMessage({
    required this.id,
    required this.isFromUser,
    required this.text,
    required this.time,
    this.read = false,
  });
}

class SupportChatState {
  final List<ChatMessage> messages;
  final bool agentTyping;

  const SupportChatState({
    this.messages = const [],
    this.agentTyping = false,
  });

  SupportChatState copyWith({
    List<ChatMessage>? messages,
    bool? agentTyping,
  }) {
    return SupportChatState(
      messages: messages ?? this.messages,
      agentTyping: agentTyping ?? this.agentTyping,
    );
  }
}

/// Fake support chat with agent «Aisulu» — local demo, no backend.
class SupportChatController extends Notifier<SupportChatState> {
  Timer? _replyTimer;
  int _msgSeq = 0;
  bool _disposed = false;

  static final _seed = [
    ChatMessage(
      id: 'seed_1',
      isFromUser: false,
      text: 'Здравствуйте, Арман! Чем могу помочь сегодня? / '
          'Сәлеметсіз бе, Арман! Бүгін сізге қалай көмектесе аламын?',
      time: DateTime(2024, 10, 14, 10, 15),
      read: true,
    ),
    ChatMessage(
      id: 'seed_2',
      isFromUser: true,
      text: 'Я оставил зонт в машине Бизнес-класса на прошлой поездке. / '
          'Мен соңғы сапарымда бизнес-класс көлігінде қолшатырымды ұмытып кетіппін.',
      time: DateTime(2024, 10, 14, 10, 16),
      read: true,
    ),
    ChatMessage(
      id: 'seed_3',
      isFromUser: false,
      text: 'Поняла. Сейчас свяжусь с водителем. Пришлите фото или описание '
          'зонта, пожалуйста. / Түсінікті. Жүргізушімен хабарласып көрейін. '
          'Қолшатырдың суретін немесе сипаттамасын жібере аласыз ба?',
      time: DateTime(2024, 10, 14, 10, 17),
      read: true,
    ),
  ];

  @override
  SupportChatState build() {
    ref.onDispose(() {
      _disposed = true;
      _replyTimer?.cancel();
    });
    return SupportChatState(messages: _seed);
  }

  void send(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = ChatMessage(
      id: 'user_${++_msgSeq}',
      isFromUser: true,
      text: trimmed,
      time: DateTime.now(),
      read: true,
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      agentTyping: true,
    );

    _replyTimer?.cancel();
    _replyTimer = Timer(const Duration(milliseconds: 1800), () {
      if (_disposed) return;
      final reply = ChatMessage(
        id: 'agent_${++_msgSeq}',
        isFromUser: false,
        text: _fakeReply(trimmed),
        time: DateTime.now(),
        read: true,
      );
      state = state.copyWith(
        messages: [...state.messages, reply],
        agentTyping: false,
      );
    });
  }

  String _fakeReply(String userText) {
    final lower = userText.toLowerCase();
    if (lower.contains('kaspi') ||
        lower.contains('каспи') ||
        lower.contains('төлем')) {
      return 'Оплата через Kaspi Gold работает автоматически в тенге (₸). '
          'Проверьте привязку карты в разделе «Способы оплаты». / '
          'Kaspi Gold арқылы төлем теңгемен (₸) автоматты жүргізіледі. '
          '«Төлем әдістері» бөлімінде картаның тіркелгенін тексеріңіз.';
    }
    if (lower.contains('отмен') || lower.contains('болдыр')) {
      return 'Отменить поездку можно на экране ожидания кнопкой «Отменить». / '
          'Сапарды күту экранында «Болдырмау» түймесімен болдырмауға болады.';
    }
    if (lower.contains('тариф') ||
        lower.contains('цен') ||
        lower.contains('баға') ||
        lower.contains('₸')) {
      return 'Тарифы рассчитываются в тенге по расстоянию и времени (Алматы). '
          'Цена видна до подтверждения заказа. / Тарифтер қашықтық пен уақыт '
          'бойынша теңгемен есептеледі (Алматы). Баға тапсырысты растамас '
          'бұрын көрсетіледі.';
    }
    return 'Спасибо за сообщение! Оператор Aisulu уже работает над вашим '
        'запросом. Ответим в течение нескольких минут. / Хабарламаңызға '
        'рахмет! Aisulu операторы сұрағыңызбен айналысып жатыр.';
  }

  /// Reset chat to the seeded demo thread (e.g. on sign-out).
  void reset() {
    _replyTimer?.cancel();
    _msgSeq = 0;
    _disposed = false;
    state = SupportChatState(messages: _seed);
  }
}

final supportChatControllerProvider =
    NotifierProvider<SupportChatController, SupportChatState>(
  SupportChatController.new,
);
