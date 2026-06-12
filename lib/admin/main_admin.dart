import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../firebase_options.dart';
import '../core/config/secrets.dart';
import 'core/theme/admin_theme.dart';
import 'core/router/admin_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env (must happen before any secret access)
  await dotenv.load(fileName: '.env');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: TNPSCAdminApp()));
}

class TNPSCAdminApp extends ConsumerWidget {
  const TNPSCAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);

    return MaterialApp.router(
      title: 'TNPSC Admin Console',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.theme,
      routerConfig: router,
    );
  }
}
