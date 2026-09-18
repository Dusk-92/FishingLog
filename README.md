# FishingLog — adaptation française

**FishingLog 1.3-FR10.2** est une adaptation française et modernisée du plugin FishingLog de David Down pour *The Lord of the Rings Online*.

La FR10.2 réunit désormais le **carnet de pêche** et les fonctions utiles de **FishingHelper** dans un seul plugin.

## Installation

Copier le dossier `Dusk` dans :

`Documents/The Lord of the Rings Online/Plugins/`

Puis charger **FishingLog** depuis le gestionnaire de plugins de LOTRO.

## Fonctions principales

- suivi des prises par ID d'objet, indépendant de la langue du message de butin ;
- lieux de pêche enregistrés et compteurs par lieu ;
- niveau de pêche et titres du hobby ;
- fenêtre **Prouesses** avec poissons obtenus/manquants ;
- **Guide pêche** intégré : cannes, maîtres du hobby, quêtes, poissons normaux, poissons rares, trophées et ordures ;
- noms français canoniques de FishingLog prioritaires sur les anciennes traductions FishingHelper ;
- guide FR / EN / DE ;
- icône déplaçable ;
- sauvegardes durcies, récupération des anciennes données et quarantaines bornées ;
- compatibilité avec les Carry-alls ;
- interface principale harmonisée avec BirdingLog ;
- options d'échelle et de touche Échap appliquées aussi aux fenêtres Guide et Prouesses.

## Commandes

- `/fl` : niveau et informations de pêche ;
- `/fl catch` : prises personnelles ;
- `/fl guide` : ouvrir le Guide pêche ;
- `/fl deeds` : résumé texte des prouesses ;
- `/fl deed <nom>` : détail texte d'une prouesse ;
- `/fl zone` : poissons de prouesse connus pour la zone active ;
- `/fl fr` : relancer la récupération des noms français depuis LOTRO ;
- `/fll list` : lieux enregistrés ;
- `/fll last` : prises du lieu actif ;
- `/flw` : ouvrir la fenêtre principale.

Le bouton **Prouesses** de l'interface ouvre la fenêtre graphique. Les commandes texte historiques restent disponibles pour compatibilité.

## Limites de l'API LOTRO

FishingLog reconnaît les prises grâce aux IDs présents dans les messages `SelfLoot`. L'API Lua de LOTRO ne permet pas de déterminer de manière totalement fiable si certains objets génériques proviennent précisément d'un lancer de pêche.

De même, FishingLog ne peut pas lire directement l'état du journal des prouesses. La fenêtre Prouesses indique donc la progression reconstruite à partir des prises enregistrées par le plugin. Pour **Maître du lac**, la visite de la Ville du Lac doit être vérifiée dans le journal du jeu.

## Qualité / tests

GitHub Actions contrôle à chaque changement :

- l'isolation et la persistance du plugin ;
- la syntaxe Lua 5.1 de tous les fichiers ;
- les conversions numériques et le niveau de pêche 0–200 ;
- le parsing des messages de progression et de butin ;
- les données critiques des quêtes ;
- les données de prouesses ;
- la cohérence des bases FishingHelper FR / EN / DE ;
- la correspondance entre les listes FishingHelper et les IDs canoniques FishingLog ;
- les invariants de release.

## Crédits

- **David Down** — auteur original de FishingLog ;
- **Vinny** — maintenance de la version LOTROInterface 1.3 ;
- **Homeopatix** — auteur de FishingHelper, dont les données utiles sont intégrées sous licence MIT ;
- **Dusk-92** — adaptation française, fusion et maintenance de ce fork.

La licence FishingHelper est conservée dans `Dusk/FishingLog/FishingHelper_LICENSE.txt`.

## Historique

Voir [CHANGELOG.md](CHANGELOG.md).
