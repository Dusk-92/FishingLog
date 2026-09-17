FishingLog 1.3-FR7.12 — corrections du re-audit

- Les lieux existants conservent désormais leurs coordonnées d’origine quand « Définir lieu » est utilisé à proximité : le centre du spot ne dérive plus au fil des clics.
- Les changements de maîtrise de pêche sont sauvegardés immédiatement, en complément de l’autosauvegarde toutes les 10 prises.
- Les fonctions génériques print/printh/printe ne sont plus exportées dans l’Apartment Dusk ; FishingLog expose FL_Print/FL_PrintH/FL_PrintE et garde uniquement des alias locaux dans FL_Main.
- Les variables legacy player, pname, pos, help et OP sont gardées locales lorsqu’elles n’ont pas besoin d’être partagées.
- Le fichier FishingLog.plugincompendium a été supprimé : son ID 1238 correspond à la fiche LOTROInterface upstream et ne doit pas être réutilisé pour le fork GitHub.
- L’Apartment reste Dusk afin d’éviter de multiplier les environnements Lua ; la cohabitation est assurée par le préfixage des symboles.
