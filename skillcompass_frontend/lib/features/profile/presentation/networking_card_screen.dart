import 'package:flutter/material.dart';
import 'widgets/networking_card.dart';
import 'widgets/common/themed_back_button.dart';

class NetworkingCardScreen extends StatelessWidget {
  const NetworkingCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: ThemedBackButton(),
      ),
      body: const Center(
        child: NetworkingCard(),
      ),
    );
  }
} 