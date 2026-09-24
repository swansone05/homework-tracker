import 'package:flutter/material.dart';

import '../presenters/auth_presenter.dart';

class ProfileScreen extends StatelessWidget {
  final AuthPresenter _authPresenter = AuthPresenter();

  ProfileScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    try {
      await _authPresenter.logout();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to log out. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _authPresenter.currentUserEmail;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 30),

          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Profile',
            style: Theme.of(context).textTheme.headlineMedium,
          ),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.email),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail ?? 'No user logged in',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ),
        ],
      ),
    );
  }
}