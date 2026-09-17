FishingLog 1.3-FR7.13 — corrections du nouvel audit

- La conversion des coordonnées accepte désormais aussi bien le point que la virgule, y compris sur les clients LOTRO dont tonumber utilise le séparateur local.
- La compatibilité numérique est appliquée uniquement pendant la commande de définition d’un lieu afin de ne pas modifier globalement le comportement Lua de l’Apartment Dusk.
- Les clés internes de lieux de la forme région;coordonnées ne sont plus affichées dans les messages du chat.
- Les changements de canne à pêche, d’arme et de second emplacement sauvegardent immédiatement FL_Totals.
- FR7.13 est chargé par FL_Loader713, qui importe d’abord la couche FR7.12 puis applique uniquement ces correctifs ciblés.
