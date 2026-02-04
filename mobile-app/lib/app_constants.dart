import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const Color brandRed = Color(0xFFEF1815);
final apiBaseUrl = dotenv.get(
  'API_SERVER_URL',
  fallback: 'https://bombastic-banking.vercel.app',
);
final atmTagMatcher = RegExp(r'^\d+$');
