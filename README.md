# FishingLog — adaptation française

Adaptation et maintenance française du plugin **FishingLog** de David Down pour *The Lord of the Rings Online*.

Version actuelle : **1.3-FR7.18**.

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
- FR7.14 : conversion numérique `FL_ToNumber` intégrée au cœur et au loader, normalisation des anciennes sauvegardes numériques, traitement `/loc` sécurisé sans monkeypatch global et suppression de la couche `FL_Loader713` ;
- FR7.15 : compteurs numériques corrompus mis en quarantaine et neutralisés, comptage des prouesses entièrement compatible `FL_ToNumber`, et routage de `/fl catch` limité à la commande `fl` ;
- FR7.16 : préflight avant chargement de l’UI pour sécuriser `FL_Totals` et `FL_Options.scale`, retrait immédiat des lieux structurellement invalides sur disque, puis restauration du loader PluginData normal ;
- FR7.17 : validation réelle des raccourcis d’équipement dans un Quickslot avant l’UI, sanitation du mode callback de `PluginData.Load`, et suppression des compteurs nuls hérités des anciennes réparations ;
- FR7.18 : quarantaines cumulatives sans écraser les anciennes réparations, raccourcis d’équipement temporairement indisponibles conservés dans `FL_PendingShortcuts` puis retentés aux chargements suivants, et rejet des nombres `NaN`/infinis par `FL_ToNumber`.

## Commandes utiles

- `/fl` : informations de pêche
- `/fl catch` : prises personnelles
- `/fl deeds` : progression des prouesses suivies
- `/fl zone` : poissons de prouesse connus pour la zone
- `/fl fr` : relancer la récupération des noms français
- `/fll list` : lieux enregistrés
- `/fll last` : prises du lieu actif
- `/flw` : ouvrir la fenêtre

## Crédits

Plugin original : **David Down** — FishingLog.

Maintenance de la version LOTROInterface 1.3 : **Vinny**.

Adaptation française et maintenance du fork : **Dusk-92**.

Page du fork : https://github.com/Dusk-92/FishingLog
