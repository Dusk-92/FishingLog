FishingLog 1.3-FR8.0 — consolidation release

Objectif
- Regrouper les protections ajoutées depuis FR7.11 dans un préflight cohérent.
- Corriger les derniers cas limites du grand audit release sans ajouter une nouvelle couche de loader.

Sauvegardes et nombres
- Nouveau FL_ToNonNegativeInteger pour les compteurs et maîtrises.
- Les valeurs négatives, fractionnaires, NaN et infinies sont rejetées.
- FL_Totals, FL_Locs et FL_Profs sont nettoyés avant utilisation.
- Les totaux de lieux sont recalculés depuis les compteurs valides.
- Les quarantaines cumulatives sont limitées aux 25 entrées les plus récentes.

Fenêtre et lieux
- FL_Options.scale reste borné entre 0,5 et 2,0.
- FL_Options.pos1 est validé et borné avant la création de FL_Window.
- Les clés internes région;coordonnées sont remises en cohérence avec r/y/x avant la logique de sélection, ce qui évite un locTbl orphelin sur une vieille sauvegarde incohérente.

Équipement
- Les raccourcis refusés restent en pending et sont retentés.
- Un pending est encore récupérable si FL_Totals a disparu.
- Une canne résolue avec une mauvaise catégorie est retirée avant l’UI.
- Les nettoyages post-import sont persistés immédiatement.

Localisation
- FL_Names est désormais stocké par langue : FL_Names_FR / FL_Names_EN / FL_Names_DE.
- L’ancien FL_Names n’est migré automatiquement que vers le cache FR afin d’éviter une contamination croisée EN/DE.
- Une tentative automatique unique récupère les noms FR absents de la base statique ; /fl fr reste disponible.
- Le guide utilise un fallback anglais sur EN/DE au lieu d’imprimer des titres de prouesse ou de maîtrise français.

Sécurité runtime
- Les données ExamineItemInstance malformées sont protégées par pcall pour FishingLog.
- Les wrappers runtime sont chain-safe : l’unload n’écrase pas le wrapper d’un autre addon chargé après FishingLog.

Tests
- Ajout de tests purs pour FL_Number.lua.
- Ajout d’un workflow GitHub Actions : syntaxe Lua 5.1 + tests numériques.

Limite connue de l’API LOTRO
- SelfLoot ne fournit pas une origine fiable permettant de prouver qu’un objet générique vient de la pêche. FR8.0 conserve donc le comportement historique basé sur les IDs au lieu d’ajouter un filtre spéculatif susceptible de perdre de vraies prises.
