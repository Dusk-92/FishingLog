FishingLog 1.3-FR7.16 — préflight de démarrage

- Ajout de FL_Preflight.lua, exécuté avant FL_Loader, pour sécuriser les données critiques avant que FL_Main et FL_Window ne puissent les utiliser.
- FL_Totals.fp est converti avec FL_ToNumber avant l’affichage ; une valeur illisible est archivée puis supprimée.
- FL_Totals.rod, wpn et shl sont validés avant la création des Quickslots ; les valeurs non textuelles ou vides sont mises en quarantaine.
- Les compteurs de prises présents dans FL_Totals sont convertis avant le cœur ; les valeurs illisibles sont archivées puis remises à zéro.
- FL_Options.scale est converti puis limité entre 0,5 et 2,0 avant Options_Init.
- Les lieux structurellement invalides sont retirés avant le cœur, archivés dans FL_LocsPreload_Quarantine et le FL_Locs nettoyé est sauvegardé immédiatement.
- Le hook temporaire Turbine.PluginData.Load du préflight est toujours restauré après l’import de FL_Loader, y compris si celui-ci échoue.
