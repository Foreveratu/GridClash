# Blueprint du Jeu de Capture de Territoire

## Aperçu du Jeu

Ce document décrit le concept, les règles et les aspects techniques d'un jeu de capture de territoire basé sur une grille. Le jeu oppose deux joueurs s'efforçant de conquérir le territoire adverse en capturant des cases adjacentes à leur domaine existant.

## Règles du Jeu

*   **Grille :** Le jeu se joue sur une grille de 15 cases en largeur et 20 cases en hauteur.
*   **Bases :** Chaque joueur commence avec une base de 3x3 cases située aléatoirement sur la grille de jeu (par exemple, joueur 1 en bas à gauche, joueur 2 en haut à droite). Les cases de la base sont initialement occupées par le joueur correspondant.
*   **But du Jeu :** Le but est de capturer les 9 cases de la base adverse. Le joueur qui parvient à capturer toutes les cases de la base ennemie gagne la partie.
*   **Tour de Jeu :** À chaque tour, le joueur dont c'est le tour doit sélectionner et capturer 5 cases adjacentes à ses propres cases déjà occupées.
*   **Premier Tour :** Au tout premier tour de chaque joueur, les 5 cases sélectionnées doivent être adjacentes à l'une des 9 cases de leur base.
*   **Capture :**
    *   Une case vide adjacente à une case occupée par le joueur peut être capturée.
    *   Une case déjà occupée par l'adversaire et adjacente à une case occupée par le joueur peut être directement capturée en la sélectionnant. Elle devient alors définitivement la propriété du joueur qui l'a sélectionnée.
*   **Connectivité :** Toutes les cases occupées par un joueur doivent être connectées à sa base principale. Si une ligne de cases n'est plus reliée à la base du joueur (par exemple, si la connexion a été coupée par l'adversaire), le joueur ne peut plus placer de nouvelles cases sur cette ligne déconnectée tant qu'une connexion n'est pas rétablie. Les cases déconnectées sont marquées comme inaccessibles par la logique du jeu.

Ce jeu combine des éléments de placement stratégique et de contrôle de territoire, où la planification et la défense des lignes de connexion sont cruciales.

### Affichage et Visuels

*   **Cases Temporairement Sélectionnées :** Pendant le tour d'un joueur, les cases sélectionnées (avant validation des 5 cases) affichent une croix de la couleur du joueur actuel.
*   **Bases :** Les cases de base sont colorées selon le joueur propriétaire et affichent une croix noire.
*   **Cases Définitivement Acquises (non-bases ou bases) :** Lorsqu'une case est définitivement capturée (qu'elle était vide ou adverse), son fond prend la couleur du nouveau propriétaire et la croix devient un rond noir.
*   **Cases Inaccessibles :** Les cases marquées comme inaccessibles (déconnectées de la base) devraient apparaître visuellement plus claires avec un contour rouge.

## Aspects Techniques

*   Développement en Flutter.
*   Utilisation de Provider pour la gestion de l'état (`GameState`).
*   Grille représentée par une liste de listes de `Cell` objets.
*   Logique de connectivité implémentée avec un algorithme de parcours en largeur (BFS).
*   Affichage de la grille avec `GridView.builder`.

## Plan de Développement Futur (TODO)

*   Implémenter la condition de victoire (capture de la base adverse).
*   Affiner l'affichage des cases inaccessibles (résoudre le problème d'opacité ou trouver une alternative).
*   Clairifier et implémenter le comportement visuel de la croix pour les cases initialement vides qui sont capturées définitivement.
*   Ajouter une interface utilisateur pour afficher le score (nombre de cases possédées).
*   Ajouter la possibilité de recommencer une partie.
*   Améliorer l'interface utilisateur (esthétique, animations).
*   Ajouter des sons ou musiques.
