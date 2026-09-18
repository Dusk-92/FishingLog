# Changelog

## 1.3-FR10.2

Gros audit de consolidation après la fusion FishingHelper.

- noms FR connus fournis par la base FishingLog au lieu des anciennes traductions FishingHelper ;
- pont stable entre les listes FishingHelper et les IDs FishingLog ;
- vraie fenêtre graphique **Prouesses** ;
- Guide et Prouesses héritent de l'échelle FishingLog et de l'option Échap ;
- dimensions de préflight corrigées pour la fenêtre 360×315 ;
- marqueurs de release harmonisés ;
- suppression du parsing /loc mort et de variables inutilisées ;
- suppression des tableaux de coordonnées FishingHelper qui n'étaient pas utilisés ;
- tests de cohérence FR / EN / DE et du pont d'IDs ;
- documentation historique regroupée ici.

## 1.3-FR10.1

- interface principale harmonisée avec BirdingLog ;
- grille 2×3 de boutons 135×20 ;
- libellés cohérents ;
- bouton Guide pêche recentré.

## 1.3-FR10.0

- fusion de FishingHelper dans FishingLog ;
- ajout du Guide pêche avec cannes, maîtres, quêtes, poissons normaux, poissons rares, trophées et ordures ;
- données FR / EN / DE intégrées sous licence MIT.

## 1.3-FR9.1

- consolidation du niveau de pêche ;
- parser de progression FR / EN / DE ;
- compatibilité Carry-all ;
- durcissement de l'icône, des options et des invariants CI.

## FR8.x

- Apartment Lua dédié à FishingLog ;
- persistance locale durcie ;
- quarantaines et restauration des anciennes sauvegardes ;
- niveau de pêche borné et normalisé ;
- suppression des validations d'équipement fragiles ;
- introduction des tests Lua et de GitHub Actions.

## FR7.x et antérieures

- localisation française progressive ;
- suivi des lieux et compteurs ;
- sauvegardes intermédiaires ;
- migration des anciennes clés de lieux ;
- conversions numériques compatibles point/virgule ;
- fiabilisation des raccourcis d'équipement et de l'icône.
