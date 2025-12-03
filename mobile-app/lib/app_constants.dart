import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color brandRed = Color(0xFFEF1815);
var apiBaseUrl = dotenv.get(
  'API_SERVER_URL',
  fallback: 'https://bombastic-banking.vercel.app',
);

/// Slide transition helper
Route slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (context, anim, secAnim, child) {
      final tween = Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: anim.drive(tween), child: child);
    },
  );
}
