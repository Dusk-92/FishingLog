FishingLog 1.3-FR9.1 — consolidation finale

- La maîtrise du personnage et FL_Profs sont réconciliées en conservant toujours la valeur valide la plus élevée (0–200), afin qu’une ancienne sauvegarde ne fasse jamais régresser le niveau connu.
- Le parsing des messages de progression est centralisé dans FL_Parse.lua : anglais strict, FR/DE limités au contexte pêche et rejet des messages contenant plusieurs nombres.
- L’extraction des liens IIDDID est indépendante du préfixe du message et possède désormais un test de régression explicite pour le format "Gathered ... into the Fish Carry-all".
- FL_Loader ne remplace plus, même temporairement, Turbine.PluginData.Load. Toute la persistance FishingLog reste locale via FL_PluginDataLoad/Save.
- /fl utilise la même table de titres que le guide : Apprenti/Compagnon/Expert/Maître pêcheur à la ligne et Seigneur des Ruisseaux.
- Les coordonnées de l’icône sont validées avec FL_ToNumber et les valeurs hors écran sont resauvegardées après clamp.
- Les anciennes formes de FL_Options.auto/esc sont normalisées avant création de l’interface.
- Le vieux symbole FishingPole=104 et les commentaires associés sont supprimés définitivement.
- La CI couvre parser, Carry-all, titres, données de quêtes, bornes numériques et invariants de release.
