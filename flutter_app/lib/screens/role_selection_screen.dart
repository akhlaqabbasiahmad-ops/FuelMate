import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final location = userProvider.location;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to FuelMate',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Select your role to get started',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildRoleButton(
                context,
                icon: '⛽',
                title: 'I Need Petrol',
                description: 'Request petrol delivery to your location',
                color: const Color(0xFF4CAF50),
                role: 'needy',
                location: location,
              ),
              const SizedBox(height: 20),
              _buildRoleButton(
                context,
                icon: '🚗',
                title: 'I Provide Petrol',
                description: 'Deliver petrol to nearby users',
                color: const Color(0xFFFF6B35),
                role: 'provider',
                location: location,
              ),
              if (location == null) ...[
                const SizedBox(height: 20),
                const Text(
                  '⚠️ Location permission required',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String icon,
    required String title,
    required String description,
    required Color color,
    required String role,
    required dynamic location,
  }) {
    return InkWell(
      onTap: () async {
        if (location == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enable location permissions to continue.'),
            ),
          );
          return;
        }

        // Clear old user ID when changing role
        await StorageService.clearUserData();

        // Navigate to name input screen
        if (context.mounted) {
          Navigator.pushNamed(
            context,
            '/name-input',
            arguments: {'role': role},
          );
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border(
            left: BorderSide(color: color, width: 5),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3.84,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


