import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/app_providers.dart';
import 'app/bootstrap.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final dependencies = await bootstrap();
    runApp(AppProviders(dependencies: dependencies, child: const LizasKitchenApp()));
  } catch (error) {
    // Deliberately do not silently fall back to demo after a Firebase failure.
    runApp(MaterialApp(theme: AppTheme.build(Brightness.light), home: Scaffold(
      appBar: AppBar(title: const Text("Liza's Kitchen setup")),
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(28),
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 600), child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.build_circle_outlined, size: 54), const SizedBox(height: 20),
            const Text('A setup step needs attention', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
            const SizedBox(height: 14), SelectableText(error.toString()),
            const SizedBox(height: 20),
            const Text('Read README.md and docs/FIREBASE_SETUP.md. Restart the app after fixing the configuration.'),
          ]))),
    ))));
  }
}
