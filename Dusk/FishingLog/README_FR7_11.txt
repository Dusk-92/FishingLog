FishingLog 1.3-FR7.11 — corrections de l’audit

- Les lieux de pêche utilisent désormais en interne une clé région + coordonnées : deux régions peuvent donc avoir les mêmes coordonnées sans écraser leurs données.
- Les anciennes sauvegardes de lieux sont migrées automatiquement au chargement, sans changer l’affichage des coordonnées.
- Quand plusieurs lieux sont à moins de 1 unité, FishingLog sélectionne maintenant réellement le plus proche au lieu du premier retourné par pairs().
- Les prises sont autosauvegardées toutes les 10 prises reconnues pour limiter les pertes en cas de crash de LOTRO.
- La position sauvegardée de la fenêtre principale est validée puis ramenée à l’intérieur de l’écran après un changement de résolution ou de moniteur.
- Les listes de lieux restent compatibles avec les anciennes sauvegardes et masquent les nouvelles clés internes.
- Les métadonnées du plugin et du PluginCompendium pointent désormais vers le fork GitHub Dusk-92.
- Le wrapper historique Dusk.Common de PluginData n’est pas modifié dans cette version afin de préserver la compatibilité des anciennes sauvegardes.
