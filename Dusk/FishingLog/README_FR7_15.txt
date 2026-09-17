FishingLog 1.3-FR7.15 — durcissement final des sauvegardes

- Les compteurs de prises illisibles dans FL_Locs et FL_Totals sont désormais archivés dans des clés de quarantaine puis remis à zéro afin d’éviter une erreur Lua lors de la prise suivante.
- Les maîtrises FL_Profs illisibles sont également archivées et neutralisées.
- Les totaux de lieux sont recalculés à partir des compteurs numériques valides, y compris pour d’anciens IDs de cinq caractères non présents dans la base actuelle.
- FL_Guide.CountCaught utilise désormais FL_ToNumber au lieu de tonumber, ce qui rend /fl deeds cohérent avec le parsing locale-safe du reste du plugin.
- L’interception de l’historique personnel est maintenant limitée à cmd == "fl" et args == "catch" ; les autres commandes ne sont plus détournées par un argument "catch".
- Le parseur brut /loc historique de FL_Main reste présent mais n’alimente plus la sélection ni la sauvegarde des lieux ; il est laissé inchangé pour éviter une réécriture risquée sans bénéfice runtime.
