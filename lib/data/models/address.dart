import 'package:latlong2/latlong.dart';

/// A place the passenger can travel from / to.
///
/// Conceptual schema in `docs/models.md`. Bilingual titles support the
/// RU/KK product requirement.
class Address {
  final String? id;
  final String? label; // 'home' | 'work' | 'custom'
  final String titleRu;
  final String? titleKk;
  final String fullText;
  final double lat;
  final double lng;
  final String type; // 'favorite' | 'history' | 'search'

  const Address({
    this.id,
    this.label,
    required this.titleRu,
    this.titleKk,
    required this.fullText,
    required this.lat,
    required this.lng,
    this.type = 'search',
  });

  LatLng get latLng => LatLng(lat, lng);
}
