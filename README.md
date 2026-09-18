# 🎣 FishingLog

Carnet de pêche pour **The Lord of the Rings Online**, avec suivi des prises, progression des prouesses et guide de pêche intégré.

**🌍 Langues / Languages / Sprachen :** 🇫🇷 Français · 🇬🇧 English · 🇩🇪 Deutsch

---

## 🇫🇷 Français

### 📖 Présentation

**FishingLog** est une adaptation modernisée du plugin de David Down. Cette version réunit le carnet de pêche historique et les fonctions utiles de **FishingHelper** dans un seul plugin.

### ✨ Fonctionnalités

- Suivi des prises par identifiant d’objet LOTRO.
- Compteurs et lieux de pêche enregistrés.
- Niveau de pêche et titres du loisir.
- Fenêtre **Prouesses** avec poissons obtenus et manquants.
- **Guide pêche** intégré : cannes, maîtres du loisir, quêtes, poissons normaux, poissons rares, trophées et objets indésirables.
- Noms français canoniques prioritaires.
- Compatibilité avec les Carry-alls.
- Interface harmonisée avec BirdingLog.
- Sauvegardes renforcées et récupération des anciennes données.
- Interface et guide FR / EN / DE.

### 📦 Installation

Copie le dossier **Dusk** dans :

```text
Documents\The Lord of the Rings Online\Plugins\
```

Puis en jeu :

```text
/plugins refresh
/plugins load FishingLog
```

### 🎮 Utilisation

FishingLog enregistre les prises reconnues pendant tes sessions de pêche. La fenêtre principale permet de consulter le niveau, les prises et les lieux ; les boutons **Prouesses** et **Guide pêche** ouvrent les vues dédiées.

### ⌨️ Commandes

- `/fl` — niveau et informations de pêche.
- `/fl catch` — prises personnelles.
- `/fl guide` — ouvrir le Guide pêche.
- `/fl deeds` — résumé texte des prouesses.
- `/fl deed <nom>` — détail texte d’une prouesse.
- `/fl zone` — poissons de prouesse connus pour la zone active.
- `/fl fr` — relancer la récupération des noms français.
- `/fll list` — afficher les lieux enregistrés.
- `/fll last` — afficher les prises du lieu actif.
- `/flw` — ouvrir la fenêtre principale.

### ⚙️ Sauvegardes & réglages

FishingLog possède son propre espace Lua et protège les données historiques, les prises, les lieux et les réglages. Les fenêtres Guide et Prouesses suivent également les options d’échelle et de fermeture avec Échap.

### 🌍 Langues

L’interface et le guide sont disponibles en **français, anglais et allemand**.

### ⚠️ Limites / notes

L’API Lua LOTRO ne permet pas de déterminer de façon totalement fiable si certains objets génériques proviennent précisément d’un lancer de pêche.

FishingLog ne peut pas lire directement l’état du journal des prouesses. La progression affichée est donc reconstruite à partir des prises enregistrées par le plugin. Certains objectifs non liés à une prise doivent être vérifiés dans le journal du jeu.

### 🐛 Bugs & suggestions

Utilise les [Issues GitHub](https://github.com/Dusk-92/FishingLog/issues).

### 🙏 Crédits

- **David Down** — auteur original de FishingLog.
- **Vinny** — maintenance historique de la version LOTROInterface.
- **Homeopatix** — auteur de FishingHelper, dont des données utiles sont intégrées.
- **Dusk-92** — adaptation, fusion et maintenance de ce fork.

---

## 🇬🇧 English

### 📖 Overview

**FishingLog** is a modernized adaptation of David Down's plugin. This version combines the historical fishing log with useful **FishingHelper** features in a single plugin.

### ✨ Features

- Catch tracking using LOTRO item IDs.
- Saved fishing locations and counters.
- Fishing skill level and hobby titles.
- Dedicated **Deeds** window with collected and missing fish.
- Built-in **Fishing Guide** covering rods, hobby masters, quests, common fish, rare fish, trophies and junk.
- Canonical French names where relevant.
- Carry-all compatibility.
- Interface aligned with BirdingLog.
- Hardened saved data and legacy recovery.
- FR / EN / DE interface and guide.

### 📦 Installation

Copy the **Dusk** folder into:

```text
Documents\The Lord of the Rings Online\Plugins\
```

Then in game:

```text
/plugins refresh
/plugins load FishingLog
```

### 🎮 Usage

FishingLog records recognized catches during your fishing sessions. The main window provides skill, catch and location information; the **Deeds** and **Fishing Guide** buttons open their dedicated views.

### ⌨️ Commands

- `/fl` — fishing skill and information.
- `/fl catch` — personal catches.
- `/fl guide` — open the Fishing Guide.
- `/fl deeds` — text summary of deeds.
- `/fl deed <name>` — text details for one deed.
- `/fl zone` — known deed fish for the active region.
- `/fl fr` — retry French-name discovery.
- `/fll list` — show saved locations.
- `/fll last` — show catches from the active location.
- `/flw` — open the main window.

### ⚙️ Saved data & settings

FishingLog uses its own Lua data apartment and protects historical data, catches, locations and settings. The Guide and Deeds windows also follow scale and Escape-to-close options.

### 🌍 Languages

The interface and guide are available in **English, French and German**.

### ⚠️ Limitations / notes

The LOTRO Lua API cannot always determine with complete reliability whether some generic items came specifically from a fishing cast.

FishingLog also cannot read the game's deed journal directly. Displayed deed progress is therefore reconstructed from catches recorded by the plugin. Non-catch objectives still need to be checked in the in-game journal.

### 🐛 Bugs & suggestions

Use [GitHub Issues](https://github.com/Dusk-92/FishingLog/issues).

### 🙏 Credits

- **David Down** — original FishingLog author.
- **Vinny** — historical LOTROInterface maintenance.
- **Homeopatix** — FishingHelper author; useful data is integrated.
- **Dusk-92** — adaptation, merge and fork maintenance.

---

## 🇩🇪 Deutsch

### 📖 Übersicht

**FishingLog** ist eine modernisierte Anpassung des Plugins von David Down. Diese Version verbindet das historische Fangprotokoll mit nützlichen Funktionen von **FishingHelper**.

### ✨ Funktionen

- Erfassung von Fängen anhand interner LOTRO-Gegenstands-IDs.
- Gespeicherte Angelorte und Zähler.
- Angelstufe und Hobby-Titel.
- Eigenes **Taten**-Fenster mit gefangenen und fehlenden Fischen.
- Integrierter **Angel-Leitfaden** für Ruten, Hobby-Meister, Aufgaben, normale und seltene Fische, Trophäen und Ausschuss.
- Kanonische französische Namen, wo relevant.
- Carry-all-Kompatibilität.
- Mit BirdingLog harmonisierte Oberfläche.
- Robuste Speicherdaten und Wiederherstellung älterer Daten.
- Oberfläche und Leitfaden auf FR / EN / DE.

### 📦 Installation

Den Ordner **Dusk** nach folgendem Pfad kopieren:

```text
Documents\The Lord of the Rings Online\Plugins\
```

Danach im Spiel:

```text
/plugins refresh
/plugins load FishingLog
```

### 🎮 Verwendung

FishingLog speichert erkannte Fänge während der Angelsitzungen. Das Hauptfenster zeigt Fertigkeit, Fänge und Orte; die Schaltflächen **Taten** und **Angel-Leitfaden** öffnen die jeweiligen Ansichten.

### ⌨️ Befehle

- `/fl` — Angelstufe und Informationen.
- `/fl catch` — eigene Fänge.
- `/fl guide` — Angel-Leitfaden öffnen.
- `/fl deeds` — Textübersicht der Taten.
- `/fl deed <name>` — Details einer Tat.
- `/fl zone` — bekannte Taten-Fische der aktiven Region.
- `/fl fr` — französische Namenssuche erneut starten.
- `/fll list` — gespeicherte Orte anzeigen.
- `/fll last` — Fänge des aktiven Ortes anzeigen.
- `/flw` — Hauptfenster öffnen.

### ⚙️ Gespeicherte Daten & Einstellungen

FishingLog verwendet einen eigenen Lua-Datenbereich und schützt historische Daten, Fänge, Orte und Einstellungen. Leitfaden- und Tatenfenster folgen ebenfalls den Optionen für Skalierung und Schließen mit Escape.

### 🌍 Sprachen

Oberfläche und Leitfaden sind auf **Deutsch, Englisch und Französisch** verfügbar.

### ⚠️ Einschränkungen / Hinweise

Die LOTRO-Lua-API kann nicht immer zuverlässig feststellen, ob bestimmte allgemeine Gegenstände tatsächlich von einem Angelwurf stammen.

FishingLog kann außerdem den Tatenstatus des Spiels nicht direkt lesen. Der angezeigte Fortschritt wird deshalb aus den vom Plugin erfassten Fängen rekonstruiert. Ziele ohne Fang müssen weiterhin im Spieljournal geprüft werden.

### 🐛 Fehler & Vorschläge

Bitte die [GitHub Issues](https://github.com/Dusk-92/FishingLog/issues) verwenden.

### 🙏 Credits

- **David Down** — ursprünglicher Autor von FishingLog.
- **Vinny** — historische LOTROInterface-Wartung.
- **Homeopatix** — Autor von FishingHelper; nützliche Daten wurden integriert.
- **Dusk-92** — Anpassung, Zusammenführung und Wartung des Forks.
