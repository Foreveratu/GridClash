# Blueprint du Jeu de Capture de Territoire

## Aperçu du Jeu

Ce document décrit le concept, les règles et les aspects techniques d'un jeu de capture de territoire basé sur une grille. Le jeu oppose deux joueurs s'efforçant de conquérir le territoire adverse en capturant des cases adjacentes à leur domaine existant.

## Style, Design, et Fonctionnalités Implémentés

*   **Logique de Jeu de Base :**
    *   Grille de jeu 15x20.
    *   Bases 3x3 pour chaque joueur.
    *   Capture de 5 cases par tour.
    *   Condition de victoire : capturer la base adverse.
    *   Logique de connectivité pour les territoires.
*   **Interface Utilisateur (UI) :**
    *   Grille de jeu visuelle avec `GridView.builder`.
    *   Affichage de l'état des cases (vide, joueur 1, joueur 2).
    *   Indicateurs visuels pour :
        *   Cases sélectionnées temporairement (croix de couleur).
        *   Cases de base (croix noire).
        *   Cases capturées définitivement (rond noir).
        *   Cases inaccessibles (contour rouge, plus claires).
    *   Écran de fin de partie avec le nom du gagnant et un bouton "Rejouer".
    *   Fond d'écran animé avec une thématique spatiale.
*   **Navigation et Aide :**
    *   **Bouton d'Aide :** Un bouton d'aide (`?`) est présent dans la barre d'application.
    *   **Écran des Règles :** Le bouton d'aide mène à un écran dédié affichant les règles détaillées du jeu.
    *   **Navigation :** La navigation entre l'écran de jeu et l'écran des règles est gérée par le package `go_router`, avec un bouton de retour sur l'écran des règles.
*   **Gestion de l'État :**
    *   Utilisation de `provider` (`ChangeNotifierProvider`) pour gérer l'état global du jeu (`GameState`).
*   **Qualité du Code :**
    *   Le code est formaté et analysé (`flutter analyze`) pour s'assurer qu'il n'y a pas d'erreurs ou d'avertissements.

## Plan de la modification actuelle

*   **Objectif :** Ajouter un bouton d'aide pour afficher les règles du jeu.
*   **Étapes réalisées :**
    1.  **Ajout de la dépendance `go_router` :** Intégration du package `go_router` pour gérer la navigation.
    2.  **Création de l'écran des règles :** Un nouveau widget `RulesScreen` a été créé dans `lib/rules_screen.dart` pour afficher le texte des règles du jeu.
    3.  **Configuration du routeur :**
        *   Le fichier `lib/main.dart` a été modifié pour utiliser `MaterialApp.router`.
        *   Un `GoRouter` a été configuré avec deux routes : `/` pour l'écran de jeu principal (`MyHomePage`) et `/rules` pour l'écran des règles (`RulesScreen`).
    4.  **Ajout du bouton d'aide :** Un `IconButton` avec une icône d'aide a été ajouté à l' `AppBar` de `MyHomePage`.
    5.  **Navigation :** Le bouton d'aide déclenche la navigation vers `/rules` en utilisant `context.go('/rules')`.
    6.  **Retour en arrière :** L' `AppBar` de `RulesScreen` contient un bouton de retour qui utilise `context.pop()` pour revenir à l'écran précédent.
    7.  **Correction et Analyse :** Le code a été analysé et corrigé pour assurer qu'aucune erreur de syntaxe ou d'analyse n'était présente.

## Règles de Développement

*   **Compilation et Analyse Automatisées :** Après chaque modification de code, ou lors de la reprise du projet, une compilation et une analyse complètes (`flutter analyze`) seront systématiquement effectuées pour identifier et corriger toutes les erreurs et tous les avertissements. Cette pratique garantit la stabilité et la propreté du code à chaque étape du développement.

## Plan de Développement Futur (TODO)

*   Affiner l'affichage des cases inaccessibles (résoudre le problème d'opacité ou trouver une alternative).
*   Clairifier et implémenter le comportement visuel de la croix pour les cases initialement vides qui sont capturées définitivement.
*   Ajouter une interface utilisateur pour afficher le score (nombre de cases possédées).
*   Améliorer l'interface utilisateur (esthétique, animations).
*   Ajouter des sons ou musiques.
