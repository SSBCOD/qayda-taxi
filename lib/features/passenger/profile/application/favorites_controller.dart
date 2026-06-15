import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A saved favourite place for the current account.
class FavoritePlace {
  final String iconName;
  final String titleRu;
  final String titleKk;
  final String address;

  const FavoritePlace({
    required this.iconName,
    required this.titleRu,
    required this.titleKk,
    required this.address,
  });

  IconData get icon => switch (iconName) {
        'home' => Icons.home,
        'work' => Icons.work,
        'fitness_center' => Icons.fitness_center,
        _ => Icons.place,
      };
}

class FavoritesController extends Notifier<List<FavoritePlace>> {
  @override
  List<FavoritePlace> build() => const [];

  void restore(List<FavoritePlace> items) => state = List.of(items);

  void remove(FavoritePlace item) {
    state = state.where((e) => e != item).toList();
  }

  void add(FavoritePlace item) {
    state = [...state, item];
  }

  void reset() => state = const [];
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, List<FavoritePlace>>(
  FavoritesController.new,
);
