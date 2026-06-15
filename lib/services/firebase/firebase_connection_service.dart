import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseConnectionStatus {
  final String appName;
  final String? projectId;
  final String? appId;
  final bool authReady;
  final bool firestoreReady;

  const FirebaseConnectionStatus({
    required this.appName,
    required this.projectId,
    required this.appId,
    required this.authReady,
    required this.firestoreReady,
  });

  bool get initialized => projectId != null && appId != null;

  @override
  String toString() {
    return 'FirebaseConnectionStatus('
        'appName: $appName, '
        'projectId: $projectId, '
        'authReady: $authReady, '
        'firestoreReady: $firestoreReady'
        ')';
  }
}

class FirebaseConnectionService {
  const FirebaseConnectionService();

  FirebaseConnectionStatus currentStatus() {
    final app = Firebase.app();
    FirebaseAuth.instanceFor(app: app);
    FirebaseFirestore.instanceFor(app: app);

    return FirebaseConnectionStatus(
      appName: app.name,
      projectId: app.options.projectId,
      appId: app.options.appId,
      authReady: true,
      firestoreReady: true,
    );
  }
}
