FishingLog 1.3-FR7.17 — restauration sûre des raccourcis

- Les raccourcis sauvegardés de canne, arme et 2e emplacement sont désormais testés dans un Quickslot invisible avant la création de la fenêtre.
- Si LOTRO refuse un ancien raccourci ou s’il ne se restaure plus comme objet, sa donnée est mise en quarantaine puis retirée afin d’éviter « Invalid shortcut for quickslot specified » au chargement.
- Le wrapper temporaire PluginData.Load sanitise aussi les données transmises par callback, tout en conservant le comportement asynchrone si aucun résultat immédiat n’est renvoyé.
- Les compteurs de prises à 0 hérités d’anciennes réparations sont supprimés du fichier de sauvegarde afin de ne plus afficher de lignes « poisson : 0 ».
- Les compteurs négatifs ou illisibles sont archivés avant retrait ; les compteurs positifs valides sont conservés et normalisés.
- Les compteurs de lieux suivent la même règle avant le loader runtime.
