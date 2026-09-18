FishingLog 1.3-FR8.5

- Utilise désormais un appartement Lua dédié FishingLog.
- Ne remplace plus globalement Turbine.PluginData.Load/Save.
- Les sauvegardes historiques encodées avec les marqueurs $/# sont relues sur FR/DE/EN, y compris une ancienne double couche d’encodage.
- Une clé qui échoue à la lecture n’est pas réécrite pendant la session.
- Les accès persistants de FishingLog passent par FL_PluginDataLoad/Save uniquement.
