FishingLog 1.3-FR8.1 — final audit fixes

Objectif
- Corriger les cinq défauts fonctionnels/durcissements restants du contrôle final FR8.0.
- Garder l’architecture FR8.0 sans ajouter de nouvelle couche de loader.

Canne / Shift bypass
- Le bypass Shift volontaire de la canne est maintenant mémorisé via `rodBypass`.
- Au chargement, un raccourci bypassé est caché du vieux contrôle de catégorie puis restauré après le loader.
- Les changements ultérieurs du slot mettent immédiatement à jour le marqueur et `FL_Totals`.

Maîtrise de pêche
- Le texte anglais de montée de maîtrise n’est plus traité par FishingLog hors canal `Advancement`.
- Les autres addons/chat handlers continuent de recevoir le message grâce à une garde chain-safe.

Localisation
- Sur EN/DE, `/fl zone` utilise désormais les noms de la base active au lieu des libellés français du guide.
- L’ancien cache `FL_Names` non typé n’est plus migré automatiquement vers FR.
- Le cache `FL_Names_FR` créé par FR8.0 est assaini une seule fois, avec sauvegarde en quarantaine, puis repeuplé par le probe LOTRO.

Sauvegardes
- `FL_Profs` rejette désormais aussi les clés invalides/non textuelles, pas seulement les valeurs.

Validation
- Le workflow GitHub Actions continue de vérifier la syntaxe Lua 5.1 de tout le plugin et les tests numériques.
