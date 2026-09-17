FishingLog 1.3-FR7.14 — consolidation du parsing et du loader

- Ajout de FL_Number.lua avec FL_ToNumber, conversion numérique compatible point/virgule sans remplacer le tonumber global de l’Apartment Dusk.
- FL_Main utilise désormais FL_ToNumber pour les coordonnées /loc, les lieux, la maîtrise et les compteurs sensibles aux anciennes sauvegardes texte.
- FL_Loader charge FL_Number avant FL_Main, ce qui sécurise aussi la validation de FL_Options et la migration des anciens lieux dès le démarrage.
- Les anciens champs numériques de FL_Locs, FL_Totals et FL_Profs sont normalisés lorsqu’ils peuvent être convertis proprement.
- Les clés internes région;coordonnées sont masquées directement dans FL_Main : plus besoin d’intercepter Turbine.Shell.WriteLine.
- La sauvegarde immédiate de la canne, de l’arme et du second emplacement est intégrée directement dans FL_Loader.
- FL_Loader713 est supprimé et FishingLog.plugin charge à nouveau directement Dusk.FishingLog.FL_Loader.
