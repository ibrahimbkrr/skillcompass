import 'package:flutter/material.dart';
import 'widgets/project_experience_card.dart';

class ProjectExperienceScreen extends StatelessWidget {
  const ProjectExperienceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proje Deneyimi'),
        elevation: 1,
      ),
      body: const Center(
        child: ProjectExperienceCard(),
      ),
    );
  }
} 