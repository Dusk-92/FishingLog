FishingLog 1.3-FR7.9 — correction reload/chat

- Nouveau FL_Loader : FL_Main reste inchangé, mais son hook de chat est protégé par génération.
- Un ancien FishingLog resté enfoui sous BirdingLog après un unload/reload devient inactif et transmet seulement l’événement à la chaîne précédente.
- Évite le double comptage des prises après certains ordres de reload.
- À l’unload, le handler précédent est restauré quand FishingLog est encore au sommet de la chaîne.
- FL_Options est validé avant le chargement du module principal.
- Le scan FR automatique est neutralisé au démarrage ; /fl fr reste disponible pour un scan manuel.
- Les correctifs FR7.8 (bouton Définir lieu et interface) sont conservés.
