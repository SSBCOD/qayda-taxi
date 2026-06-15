import 'package:latlong2/latlong.dart';

import '../../data/models/driver_info.dart';

/// Mock driver for the local dispatch demo (see [kMockDrivers]).
class MockDriver {
  final String id;
  final String name;
  final String phone;
  final double rating;
  final String carModel;
  final String carNumber;
  final String carColor;
  final double lat;
  final double lng;
  final bool isOnline;

  const MockDriver({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.carModel,
    required this.carNumber,
    required this.carColor,
    required this.lat,
    required this.lng,
    this.isOnline = false,
  });

  LatLng get position => LatLng(lat, lng);

  DriverInfo toDriverInfo() => DriverInfo(
        id: id,
        name: name,
        phone: phone,
        rating: rating,
        carModel: carModel,
        carColorRu: carColor,
        carColorKk: carColor,
        plate: carNumber,
      );
}

/// Demo drivers around Almaty. [isOnline] is the static pool default;
/// the logged-in session driver goes online via [MockDriverPool.setSessionOnline].
const List<MockDriver> kMockDrivers = [
  MockDriver(
    id: 'drv_arman',
    name: 'Арман',
    phone: '+7 777 111 22 33',
    rating: 4.9,
    carModel: 'Toyota Camry',
    carNumber: '011 ABC 02',
    carColor: 'Чёрный',
    lat: 43.2510,
    lng: 76.9285,
  ),
  MockDriver(
    id: 'drv_dias',
    name: 'Диас',
    phone: '+7 777 222 33 44',
    rating: 4.8,
    carModel: 'Hyundai Sonata',
    carNumber: '247 KZA 02',
    carColor: 'Белый',
    lat: 43.2305,
    lng: 76.8721,
    isOnline: true,
  ),
  MockDriver(
    id: 'drv_yerlan',
    name: 'Ерлан',
    phone: '+7 777 333 44 55',
    rating: 4.7,
    carModel: 'Kia K5',
    carNumber: '555 BAC 02',
    carColor: 'Серый',
    lat: 43.2447,
    lng: 76.9011,
    isOnline: true,
  ),
  MockDriver(
    id: 'drv_nurlan',
    name: 'Нұрлан',
    phone: '+7 777 444 55 66',
    rating: 5.0,
    carModel: 'Toyota Corolla',
    carNumber: '888 ABA 02',
    carColor: 'Серебристый',
    lat: 43.2218,
    lng: 76.8519,
  ),
  MockDriver(
    id: 'drv_timur',
    name: 'Тимур',
    phone: '+7 777 555 66 77',
    rating: 4.6,
    carModel: 'Volkswagen Polo',
    carNumber: '123 KBA 02',
    carColor: 'Синий',
    lat: 43.2602,
    lng: 76.9450,
  ),
];

/// @deprecated Use [kMockDrivers]. Kept for any legacy imports during migration.
typedef FakeDriver = MockDriver;

/// @deprecated Use [kMockDrivers].
const List<MockDriver> kFakeDrivers = kMockDrivers;
