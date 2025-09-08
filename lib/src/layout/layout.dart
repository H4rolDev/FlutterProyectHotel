import 'package:flutter/material.dart';
import 'package:hospedaje_f1/src/layout/header.dart';
import 'package:hospedaje_f1/core/colors.dart';
import 'package:hospedaje_f1/src/chatbot/screens/chatbot_screen.dart';

class Layout extends StatelessWidget {
  final Widget child;

  const Layout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: Container(
        color: AppColors.secondary500,
        child: child,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary700,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true, // Modal-style animation
              builder: (_) => const ChatbotScreen(),
            ),
          );
        },
        child: const Icon(Icons.smart_toy_outlined, color: AppColors.primary500, size: 44),
      ),
    );
  }
}
