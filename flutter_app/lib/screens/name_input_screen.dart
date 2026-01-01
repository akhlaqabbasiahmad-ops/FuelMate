import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';
import '../services/storage_service.dart';

class NameInputScreen extends StatefulWidget {
  final String role;

  const NameInputScreen({super.key, required this.role});

  @override
  State<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends State<NameInputScreen> {
  final TextEditingController _nameController = TextEditingController();
  String? _suggestedName;
  bool _isChecking = false;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _checkExistingUser();
  }

  Future<void> _checkExistingUser() async {
    final existingName = await StorageService.getUserName();
    if (existingName != null) {
      _nameController.text = existingName;
    }
  }

  Future<void> _checkNameAvailability(String name) async {
    if (name.trim().length < 2) {
      setState(() => _suggestedName = null);
      return;
    }

    setState(() => _isChecking = true);

    try {
      final result = await UserService.checkName(name.trim());
      setState(() => _suggestedName = result.suggestedName);
    } catch (error) {
      print('Error checking name: $error');
    } finally {
      setState(() => _isChecking = false);
    }
  }

  Future<void> _handleContinue() async {
    final trimmedName = _nameController.text.trim();

    if (trimmedName.isEmpty) {
      _showDialog('Name Required', 'Please enter your name to continue.');
      return;
    }

    if (trimmedName.length < 2) {
      _showDialog('Invalid Name', 'Name must be at least 2 characters long.');
      return;
    }

    setState(() => _isRegistering = true);

    try {
      // Register or login user
      final result = await UserService.registerUser(trimmedName, widget.role);

      // Verify user was created
      try {
        final verifiedUser = await UserService.getUserById(result.user.id);
        if (verifiedUser.id != result.user.id) {
          throw Exception('User verification failed');
        }
        print('✅ User verified: ${verifiedUser.name}');
      } catch (verifyError) {
        print('❌ User verification failed: $verifyError');
        if (mounted) {
          _showDialog('Registration Error', 'Failed to verify user registration. Please try again.');
        }
        return;
      }

      // Save user data
      await StorageService.saveUserId(result.user.id);
      await StorageService.saveUserName(result.user.name);
      await StorageService.saveUserRole(widget.role);

      // Update provider
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setUserId(result.user.id);
        await userProvider.setUserName(result.user.name);
        await userProvider.setUserRole(widget.role);
      }

      print('✅ User registered: ${result.user.id}, ${result.user.name}');

      // Navigate to requests screen
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/requests');
      }
    } catch (error) {
      print('Registration error: $error');
      if (mounted) {
        _showDialog('Error', 'Failed to register. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.role == 'needy' ? '⛽' : '🚗';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Enter Your Name'),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$icon Welcome!',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Please enter your name so others can see who you are',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Name',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter your name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    maxLength: 50,
                    enabled: !_isRegistering,
                    onChanged: (value) {
                      // Debounce name check
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_nameController.text == value) {
                          _checkNameAvailability(value);
                        }
                      });
                    },
                  ),
                  if (_isChecking)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Checking availability...',
                            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                          ),
                        ],
                      ),
                    ),
                  if (!_isChecking && _suggestedName != null && _nameController.text.trim().length >= 2)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF5F2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFFE0D6)),
                      ),
                      child: _suggestedName != _nameController.text.trim().toLowerCase()
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '"${_nameController.text.trim()}" is already taken',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFFF6B35),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Suggested: "$_suggestedName"',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF333333),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              '✓ "${_nameController.text.trim()}" is available!',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nameController.text.trim().length >= 2 && !_isRegistering
                      ? _handleContinue
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    disabledBackgroundColor: const Color(0xFFCCCCCC),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isRegistering
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Registering...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}


