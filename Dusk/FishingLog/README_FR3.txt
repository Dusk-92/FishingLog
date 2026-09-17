FishingLog 1.3-FR3 — adaptation française Dusk

Cette version conserve le fonctionnement et les données du plugin original de David Down.

Améliorations FR :
- compatibilité avec le client LOTRO français ;
- interface principale traduite ;
- catégories, paliers et messages principaux traduits ;
- détection des prises par ID, indépendante de la langue du message ;
- récupération automatique et progressive des noms localisés depuis LOTRO à partir des IDs connus ;
- 8 IDs traités par image pour éviter un gros blocage au chargement ;
- noms français mémorisés dans FL_Names pour les reconnexions suivantes ;
- si l’API ne résout pas un ID, le nom exact est appris automatiquement quand LOTRO l’affiche dans le chat ;
- plus de 50 noms français officiels de poissons sont préchargés en secours ;
- icône en jeu conservée.

Commande utile :
/fl fr  -> relance manuellement l’analyse automatique des noms français.

Le scan automatique ne se lance normalement qu’une fois par version de la base, puis les résultats sont conservés.
