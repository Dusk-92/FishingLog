FishingLog 1.3-FR7.18 — récupération et durcissement

- Les fichiers de quarantaine deviennent cumulatifs : une nouvelle réparation n’écrase plus les données mises de côté lors d’un chargement précédent.
- Les raccourcis de canne, arme et 2e emplacement refusés temporairement par LOTRO ne sont plus perdus : ils sont déplacés dans FL_PendingShortcuts et retentés à chaque chargement suivant.
- FL_Totals conserve un marqueur false pendant qu’un raccourci est en attente, ce qui garde FL_Window sûre ; si le joueur efface volontairement le slot, le pending est abandonné au prochain chargement.
- Les anciennes quarantaines FR7.17 sont conservées comme entrée legacy lors de la première conversion vers le format d’historique FR7.18.
- Les quarantaines de secours encore émises par FL_Loader pendant son import sont également rendues cumulatives par le préflight, puis le wrapper Save normal est restauré.
- FL_ToNumber rejette maintenant NaN et les valeurs infinies, ce qui protège scale, positions, coordonnées, maîtrises et compteurs contre les nombres non finis.
- Les compteurs nuls restent supprimés par le préflight ; le cœur de comptage, les handlers de chat et la logique de lieux ne changent pas.
