FishingLog 1.3-FR9.0 — consolidation finale

- FishingLog utilise désormais son propre Apartment "FishingLog" au lieu de l’Apartment partagé "Dusk". Les globals historiques comme Locs et Region ne peuvent donc plus entrer en collision avec TravelRef ou BirdingLog.
- Le niveau de pêche est strictement validé entre 0 et 200 dans les anciennes sauvegardes, FL_Profs, le chat et la fenêtre.
- Si Totals.fp manque mais que FL_Profs connaît déjà le niveau du personnage courant, la valeur est restaurée avant la création de la fenêtre.
- Les messages de progression ne sont acceptés que dans le canal Advancement et ne peuvent pas faire reculer la maîtrise enregistrée.
- La vieille validation de canne par catégorie numérique et le bypass Shift associé sont définitivement supprimés.
- Les Quickslots conservent leur payload Item même si LOTRO n’a pas encore résolu l’objet au moment du dépôt ; la restauration UI est protégée par pcall.
- Le clamp de fenêtre tient désormais compte de l’échelle réelle, y compris sous 100 %.
- Les données de "Fishing for Advice" et "The Fishing-hole" ont été remises sur les bons PNJ, lieux, régions et coordonnées.
- Les quarantaines sont marquées FR9.0 et restent bornées.
- La CI exécute désormais tous les tests tests/test_fl_*.lua : nombres, niveau 0–200, données de quêtes et invariants de release.
