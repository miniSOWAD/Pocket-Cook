import 'package:firebase_core/firebase_core.dart';

/// Intentional configuration guard. Demo/emulator builds do not use this file.
/// Replace it by running `flutterfire configure` for your Firebase project.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => throw StateError(
    'Firebase is not configured. Run flutterfire configure, enable Email/Password '
    'authentication, and deploy the database rules. Or run without USE_FIREBASE '
    'to use the local demo. See docs/FIREBASE_SETUP.md.',
  );
}
