import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:a4_iot/core/config/env.dart';
import 'package:a4_iot/core/config/app_theme.dart';
import 'package:a4_iot/presentation/views/login_view.dart';
import 'package:a4_iot/presentation/widget/main_layout.dart';
import 'package:a4_iot/utils/ble_listening.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseKey);

  await Hive.initFlutter();
  
  // Initialiser les locales françaises
  await initializeDateFormatting('fr_FR', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CESI IoT',
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (session != null) {
          return const BleLifecycleWrapper(child: MainLayout());
        } else {
          return const LoginView();
        }
      },
    );
  }
}

class BleLifecycleWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const BleLifecycleWrapper({super.key, required this.child});

  @override
  ConsumerState<BleLifecycleWrapper> createState() =>
      _BleLifecycleWrapperState();
}

class _BleLifecycleWrapperState extends ConsumerState<BleLifecycleWrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isConnectedProvider, (previous, isConnected) {
      if (isConnected) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Door Lock Connected!")));
      }
    });

    return widget.child;
  }
}
