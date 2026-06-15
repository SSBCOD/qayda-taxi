import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:qayda/data/models/enums.dart';
import 'package:qayda/services/accounts/account_repository.dart';
import 'package:qayda/services/accounts/user_account_data.dart';
import 'package:qayda/services/storage/prefs_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('accounts are isolated by phone', () async {
    final prefs = PrefsService(await SharedPreferences.getInstance());
    final repo = AccountRepository(prefs);

    final a = repo.loadOrCreate('+77071234567').copyWith(role: UserRole.driver);
    final b = repo.loadOrCreate('+77077777777').copyWith(role: UserRole.passenger);

    repo.save(a);
    repo.save(b);

    final loadedA = repo.loadOrCreate('+77071234567');
    final loadedB = repo.loadOrCreate('+77077777777');

    expect(loadedA.role, UserRole.driver);
    expect(loadedB.role, UserRole.passenger);
    expect(repo.knownPhones(), containsAll(['+77071234567', '+77077777777']));
  });

  test('defaults include favorites and trip history', () {
    final data = UserAccountData.defaults('+77071234567');
    expect(data.favorites, isNotEmpty);
    expect(data.tripHistory, isNotEmpty);
  });
}
