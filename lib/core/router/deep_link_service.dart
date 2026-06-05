import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

/// Service to handle deep linking via thiral:// and https://thiral.app/share/
class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  /// Initializes deep link streams and handlers
  void init(BuildContext context) {
    // Handle incoming link when app is closed / cold-started
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _handleDeepLink(context, uri);
      }
    });

    // Handle incoming links when app is running in background or foreground
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(context, uri);
    }, onError: (err) {
      debugPrint('Deep Link Service Error: $err');
    });
  }

  /// Cancels subscription to deep link events
  void dispose() {
    _linkSubscription?.cancel();
  }

  void _handleDeepLink(BuildContext context, Uri uri) {
    debugPrint('Processing Deep Link: $uri');
    
    final path = uri.path;
    final queryParameters = uri.queryParameters;

    if (uri.scheme == 'thiral' && uri.host == 'app') {
      // Direct deep link: thiral://app/some-route?param=val
      final routePath = Uri(path: path, queryParameters: queryParameters).toString();
      _navigateToRoute(context, routePath);
    } else if (uri.host == 'thiral.app' || uri.host == 'www.thiral.app') {
      // Universal/App link: https://thiral.app/share/some-route?param=val
      if (path.startsWith('/share')) {
        final actualPath = path.replaceFirst('/share', '');
        final routePath = Uri(path: actualPath, queryParameters: queryParameters).toString();
        _navigateToRoute(context, routePath);
      }
    }
  }

  void _navigateToRoute(BuildContext context, String routePath) {
    try {
      debugPrint('Deep Link redirecting to: $routePath');
      context.push(routePath);
    } catch (e) {
      debugPrint('Error navigating to deep link route: $e');
    }
  }
}
