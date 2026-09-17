FishingLog 1.3-FR8.3 — validation des cannes

Correction
- Suppression de la validation d’une canne via la catégorie numérique LOTRO `104`.
- La « Canne à pêche de base » et les autres cannes valides ne sont plus rejetées uniquement parce que l’API retourne une autre catégorie.
- Le préflight continue de vérifier que la donnée sauvegardée est un vrai raccourci LOTRO de type Item et conserve le système pending si l’objet n’est pas résolu.
- L’ancien contrôle de catégorie du loader est retiré.

Portée
- Aucun changement du comptage des prises, des lieux, du chat ou de l’icône FR8.2.
