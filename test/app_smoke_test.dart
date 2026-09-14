import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_cook/app/app.dart';
import 'package:pocket_cook/app/app_providers.dart';
import 'package:pocket_cook/app/dependencies.dart';
import 'package:pocket_cook/core/storage/key_value_store.dart';
void main() {
  testWidgets('demo home renders at mobile size without a Firebase project', (tester) async {
    tester.view.physicalSize = const Size(390, 844); tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
    final dependencies = AppDependencies.demo(MemoryKeyValueStore());
    await tester.pumpWidget(AppProviders(dependencies: dependencies, child: const PocketCookApp()));
    await tester.pumpAndSettle();
    expect(find.text("Pocket Cook"), findsOneWidget); expect(find.text('LOCAL DEMO'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget); expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink()); await dependencies.dispose();
  });
  testWidgets('wide layouts use navigation rail and honor dark preference', (tester) async {
    tester.view.physicalSize = const Size(1280, 900); tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
    final storage = MemoryKeyValueStore(); await storage.write('pocket_cook.theme', 'dark');
    final dependencies = AppDependencies.demo(storage);
    await tester.pumpWidget(AppProviders(dependencies: dependencies, child: const PocketCookApp()));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(Theme.of(tester.element(find.text("Pocket Cook"))).brightness, Brightness.dark);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink()); await dependencies.dispose();
  });
  testWidgets('saved page prompts guests rather than exposing a workspace', (tester) async {
    final dependencies = AppDependencies.demo(MemoryKeyValueStore());
    await tester.pumpWidget(AppProviders(dependencies: dependencies, child: const PocketCookApp()));
    await tester.pumpAndSettle(); await tester.tap(find.text('Saved')); await tester.pumpAndSettle();
    expect(find.text('Make this kitchen yours'), findsOneWidget);
    expect(find.text('Enter demo workspace'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink()); await dependencies.dispose();
  });
}
