import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/models/address.dart';

/// Mock saved places + search history for the address-search feature, plus the
/// destination the passenger picks. Wired into the route/tariff order flow.
///
/// No backend: these are static demo addresses around Almaty (see
/// docs/backend.md — passenger data is mocked for the MVP demo).

/// Saved / favourite places shown as quick chips. [label] maps to an emoji in
/// the UI (home/work/place/airport).
const List<Address> kSavedPlaces = [
  Address(
    id: 'home',
    label: 'home',
    titleRu: 'Дом',
    titleKk: 'Үй',
    fullText: 'мкр. Самал-2, 33',
    lat: 43.2330,
    lng: 76.9560,
    type: 'favorite',
  ),
  Address(
    id: 'work',
    label: 'work',
    titleRu: 'Работа',
    titleKk: 'Жұмыс',
    fullText: 'БЦ «Нурлы Тау»',
    lat: 43.2240,
    lng: 76.9270,
    type: 'favorite',
  ),
  Address(
    id: 'dostyk',
    label: 'place',
    titleRu: 'Dostyk Plaza',
    titleKk: 'Dostyk Plaza',
    fullText: 'просп. Достык, 111',
    lat: 43.2335,
    lng: 76.9558,
    type: 'favorite',
  ),
  Address(
    id: 'airport',
    label: 'airport',
    titleRu: 'Аэропорт',
    titleKk: 'Әуежай',
    fullText: 'Международный аэропорт Алматы',
    lat: 43.3521,
    lng: 77.0405,
    type: 'favorite',
  ),
];

/// Recent searches.
const List<Address> kSearchHistory = [
  Address(
    id: 'cum',
    titleRu: 'ЦУМ',
    titleKk: 'ОҮД',
    fullText: 'просп. Жибек Жолы, 50',
    lat: 43.2618,
    lng: 76.9461,
    type: 'history',
  ),
  Address(
    id: 'park',
    titleRu: 'Парк Первого Президента',
    titleKk: 'Тұңғыш Президент саябағы',
    fullText: 'просп. Аль-Фараби',
    lat: 43.2010,
    lng: 76.8920,
    type: 'history',
  ),
];

/// Pickup chosen for the current trip (null → [kMockOrigin] on route/tariff).
final selectedOriginProvider = StateProvider<Address?>((ref) => null);

/// The destination the passenger has chosen. Read by the route/tariff screen
/// when creating the order; null falls back to the default mock destination.
final selectedDestinationProvider = StateProvider<Address?>((ref) => null);

Address pickupAddressFromCoordinates({
  required double lat,
  required double lng,
}) {
  final label = '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
  return Address(
    id: 'current_pickup',
    label: 'current',
    titleRu: 'Текущее местоположение',
    titleKk: 'Ағымдағы орын',
    fullText: label,
    lat: lat,
    lng: lng,
    type: 'current',
  );
}
