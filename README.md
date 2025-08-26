# gridclash

Jeu de Capture de Territoire

Ce projet est une implémentation en Flutter d'un jeu de capture de territoire basé sur une grille. Deux joueurs s'affrontent pour conquérir le territoire adverse en capturant des cases adjacentes à leur domaine.

## Règles du Jeu

*   **Grille :** Le jeu se déroule sur une grille de 15x20 cases.
*   **Bases :** Chaque joueur commence avec une base de 3x3 cases, initialement occupées.
*   **But du Jeu :** Capturer les 9 cases de la base adverse.
*   **Tour de Jeu :** À chaque tour, un joueur sélectionne 5 cases adjacentes à ses cases déjà occupées pour les capturer.
*   **Premier Tour :** Les 5 cases doivent être adjacentes à la base.
*   **Capture :** Capture de cases vides ou de cases adverses adjacentes. Une case adverse capturée devient définitivement la propriété du joueur.
*   **Connectivité :** Toutes les cases capturées doivent rester connectées à la base principale. Les cases déconnectées deviennent inaccessibles.

## Affichage et Visuels

*   **Cases Temporairement Sélectionnées :** Affichent une croix de la couleur du joueur actuel.
*   **Bases :** Colorées selon le joueur et affichent une croix noire.
*   **Cases Définitivement Acquises :** Fond coloré selon le nouveau propriétaire, affichent un rond noir.
*   **Cases Inaccessibles :** Apparaissent plus claires avec un contour rouge.

## Getting Started

This project is a starting point for a Flutter application.

Pour vous aider à démarrer si c'est votre premier projet Flutter :

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Aspects Techniques

*   Développement en Flutter.
*   Utilisation de Provider pour la gestion de l'état (`GameState`).
*   Grille représentée par une liste de listes de `Cell` objets.
*   Logique de connectivité implémentée avec un algorithme de parcours en largeur (BFS).
*   Affichage de la grille avec `GridView.builder`.
