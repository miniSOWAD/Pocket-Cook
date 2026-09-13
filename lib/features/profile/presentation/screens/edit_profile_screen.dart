import 'package:flutter/material.dart';
import 'profile_screen.dart';

/// Kept for backwards-compatible routing. Profile editing now lives directly
/// on the Profile screen so users can see their information and save state in
/// one place.
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Your profile')),
        body: const SafeArea(child: ProfileScreen()),
      );
}
