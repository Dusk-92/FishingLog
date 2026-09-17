FishingLog 1.3-FR7.2 — Guide régional & prouesses

Principe
--------
FishingLog reste un carnet de prises et de spots de pêche. La pêche n'est pas
transformée artificiellement en copie de BirdingLog. Le nouveau guide ajoute
uniquement les informations fiables qui sont réellement liées aux régions et
aux prouesses de pêche.

Nouveautés
----------
- Le lieu actif affiche maintenant « zone — coordonnées » au lieu des seules
  coordonnées.
- Le vieux message de debug « Région=... N/S=... » du /loc brut est supprimé.
- /loc brut ne peut plus désynchroniser le lieu actif de FishingLog.
- Nouveau bouton « Poissons région » : affiche les poissons de prouesse connus
  pour la zone, le niveau de pêche requis, s'ils ont été enregistrés par
  FishingLog et combien de fois.
- Nouveau bouton « Prouesses » : résumé Dards 9, Esturgeons 9, Truites 9,
  Maître du lac 20 + visite Ville du Lac, Saumon de 25 kg, et maîtrise 200.
- /fl zone : même guide régional.
- /fl deeds : résumé des prouesses.
- /fl deed dard|esturgeon|truite|lac|saumon : détail d'une prouesse.

Important
---------
FishingLog ne peut pas lire directement l'état des prouesses LOTRO. Il marque
comme « pris » uniquement les poissons réellement enregistrés par FishingLog
sur ce personnage. Une prise faite avant l'installation du plugin peut donc
être déjà validée dans LOTRO sans apparaître comme prise dans ce suivi.

Sources de données croisées
---------------------------
- Base d'IDs et noms FR officiels déjà intégrée à FishingLog FR6/FR7.
- FishingHelper 1.16 (DATA_FR/DATA_EN) pour contrôle des familles, régions et
  niveaux historiques.
- Lotro-wiki.fr, page Pêche (mise à jour 2025) comme référence principale pour
  les groupes régionaux, niveaux et listes de prouesses.
- Lotro-Wiki.com / Fishing comme référence complémentaire signalée par
  l'utilisateur ; la structure intégrée reste volontairement conservatrice.

Toutes les corrections FR7.1 sont conservées. BirdingLog n'est ni inclus ni
modifié.
