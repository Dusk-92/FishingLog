FishingLog 1.3-FR8.2 — couche normale de l’icône

Objectif
- Aligner le comportement de l’icône FishingLog sur TravelRef et LOTRO Events.

Correction
- `FL_IconWindow:SetZOrder(1000)` devient `FL_IconWindow:SetZOrder(0)`.
- L’icône reste visible, déplaçable et cliquable normalement.
- Les panneaux natifs LOTRO, notamment la carte du monde, peuvent désormais passer devant l’icône.

Portée
- Aucun changement du comptage, des sauvegardes, du chat, des lieux ou des Quickslots.
