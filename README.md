# FishingLog — adaptation française

Adaptation et maintenance française du plugin **FishingLog** de David Down pour *The Lord of the Rings Online*.

Version actuelle : **1.3-FR8.2**.

## Installation

Copier le dossier `Dusk` dans :

`Documents/The Lord of the Rings Online/Plugins/`

Puis charger **FishingLog** depuis le gestionnaire de plugins de LOTRO.

## Principales améliorations FR

- interface et aide en français ;
- noms français des poissons/objets connus, avec récupération complémentaire depuis le client LOTRO ;
- suivi des prises basé sur les IDs d’objets, indépendant de la langue du message de butin ;
- suivi des lieux de pêche et des prouesses ;
- icône déplaçable ;
- protection contre les doubles comptages après reload ;
- récupération sûre des anciennes sauvegardes ;
- FR7.11 : clés de lieux séparées par région, sélection déterministe du lieu le plus proche, autosauvegarde toutes les 10 prises et protection de la position de fenêtre ;
- FR7.12 : coordonnées des lieux existants figées, maîtrise de pêche sauvegardée immédiatement et fonctions de sortie préfixées `FL_` pour éviter les collisions dans l’Apartment `Dusk` ;
- FR7.13 : conversion des coordonnées compatible point/virgule, clés internes de lieux masquées dans le chat et sauvegarde immédiate de la canne, de l’arme et du second emplacement ;
- FR7.14 : conversion numérique `FL_ToNumber` intégrée au cœur et au loader, normalisation des anciennes sauvegardes numériques et suppression de la couche `FL_Loader713` ;
- FR7.15 à FR7.18 : quarantaines, préflight, validation réelle des Quickslots, pending récupérable et rejet de `NaN`/infinis ;
- **FR8.0** : consolidation release — compteurs strictement entiers, positions bornées avant création de l’UI, cohérence des clés de lieux, quarantaines bornées, pending récupéré même sans `FL_Totals`, cache de noms séparé par langue, protection des liens `ExamineItemInstance`, retry automatique des derniers noms FR manquants, guide sans fuite de libellés FR sur EN/DE, et tests Lua/CI ;
- **FR8.1** : bypass Shift de la canne conservé après redémarrage, faux messages de maîtrise hors canal Advancement ignorés, noms du guide adaptés à la langue, ancien cache FR8.0 assaini sans réutiliser le cache historique non typé, et clés de `FL_Profs` validées ;
- **FR8.2** : l’icône flottante utilise la couche UI normale (`ZOrder 0`) comme TravelRef et LOTRO Events, afin que la carte et les panneaux natifs LOTRO puissent passer devant.

## Commandes utiles

- `/fl` : informations de pêche
- `/fl catch` : prises personnelles
- `/fl deeds` : progression des prouesses suivies
- `/fl zone` : poissons de prouesse connus pour la zone
- `/fl fr` : relancer la récupération des noms français
- `/fll list` : lieux enregistrés
- `/fll last` : prises du lieu actif
- `/flw` : ouvrir la fenêtre

## Limite de l’API LOTRO

FishingLog reconnaît les prises via leur ID dans les messages `SelfLoot`. LOTRO ne fournit pas au plugin une origine fiable indiquant qu’un objet générique provient précisément de l’action de pêche. La FR8.2 n’ajoute donc pas de filtre spéculatif qui pourrait supprimer de vraies prises ; les données sont comptées selon la base d’IDs FishingLog existante.

## Qualité / tests

Le dépôt contient désormais un workflow GitHub Actions qui vérifie la syntaxe Lua des fichiers du plugin et exécute les tests purs de `FL_Number.lua` (point/virgule, `NaN`, infinis, entiers et valeurs invalides).

## Crédits

Plugin original : **David Down** — FishingLog.

Maintenance de la version LOTROInterface 1.3 : **Vinny**.

Adaptation française et maintenance du fork : **Dusk-92**.

Page du fork : https://github.com/Dusk-92/FishingLog
