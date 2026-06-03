import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../firebase_options.dart';
import 'core/theme/admin_theme.dart';
import 'core/router/admin_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
