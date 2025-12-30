import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Règles du Jeu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'But du Jeu',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Le but est de capturer les 9 cases de la base adverse.',
            ),
            const SizedBox(height: 16),
            Text(
              'Déroulement',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              '''• Le jeu se déroule sur une grille de 15x20 cases.
• Chaque joueur commence avec une base de 3x3 cases.
• À chaque tour, un joueur sélectionne 5 cases adjacentes à son territoire pour les capturer.
• Les cases sélectionnées peuvent être vides ou appartenir à l'adversaire.''',
            ),
            const SizedBox(height: 16),
            Text(
              'Capture',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              '''• Une case adverse capturée devient définitivement la vôtre.
• Toutes les cases que vous capturez doivent rester connectées à votre base principale.''',
            ),
            const SizedBox(height: 16),
            Text(
              'Visuels',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              '''• Cases sélectionnées (temporaire): Croix de votre couleur.
• Cases de base: Fond de votre couleur avec une croix noire.
• Cases capturées (définitif): Fond de votre couleur avec un rond noir.
• Cases inaccessibles: Plus claires avec un contour rouge.''',
            ),
          ],
        ),
      ),
    );
  }
}
