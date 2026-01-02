import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/request_provider.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';
import 'screens/role_selection_screen.dart';
import 'screens/name_input_screen.dart';
import 'screens/login_screen.dart';
import 'screens/requests_screen.dart';
import 'screens/history_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Setup background message handler (must be before any other Firebase calls)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize notification service
  await NotificationService().initialize();
  
  // Initialize FCM service
  await FCMService().initialize();
  
  runApp(const FuelMateApp());
}

class FuelMateApp extends StatelessWidget {
  const FuelMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
      ],
      child: MaterialApp(
        title: 'FuelMate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
          primaryColor: const Color(0xFFFF6B35),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFFF6B35),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF6B35),
            primary: const Color(0xFFFF6B35),
          ),
        ),
        home: const InitializationScreen(),
        routes: {
          '/role-selection': (context) => const RoleSelectionScreen(),
          '/requests': (context) => const RequestsScreen(),
          '/history': (context) => const HistoryScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/name-input') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => NameInputScreen(role: args['role'] as String),
            );
          }
          if (settings.name == '/login') {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => LoginScreen(
                username: args['username'] as String,
                role: args['role'] as String,
              ),
            );
          }
          if (settings.name == '/chat') {
            final requestId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ChatScreen(requestId: requestId),
            );
          }
          return null;
        },
      ),
    );
  }
}

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initializeApp();

    // Navigate to appropriate screen
    if (mounted) {
      if (userProvider.userId != null && userProvider.userRole != null) {
        Navigator.pushReplacementNamed(context, '/requests');
      } else {
        Navigator.pushReplacementNamed(context, '/role-selection');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFFF6B35)),
            SizedBox(height: 20),
            Text(
              'Initializing FuelMate...',
              style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
            ),
            SizedBox(height: 10),
            Text(
              'Checking user registration...',
              style: TextStyle(fontSize: 14, color: Color(0xFF999999)),
            ),
          ],
        ),
      ),
    );
  }
}


