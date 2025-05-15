import 'package:flutter/material.dart';
import 'widgets/networking_card.dart';

class NetworkingCardScreen extends StatelessWidget {
  const NetworkingCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentorship & Networking'),
        elevation: 1,
      ),
      body: const Center(
        child: NetworkingCard(),
      ),
    );
  }
} 