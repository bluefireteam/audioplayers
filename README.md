# 🚀 Audioplayers Stable (Fork)

[![Build Check](https://github.com/Sebastien-VZN/audioplayers/actions/workflows/build_check.yml/badge.svg)](https://github.com/Sebastien-VZN/audioplayers/actions/workflows/build_check.yml)

Ce fork de `bluefireteam/audioplayers` a été créé pour transformer un plugin fragmenté et vieillissant en un outil **industriel, stable et performant**. L'objectif est de fournir une base de code saine, débarrassée de l'obsolescence et protégée par une suite de tests rigoureuse.

## 🛠️ Pourquoi ce fork ? (Décisions Techniques)

Le dépôt d'origine souffrait d'une fragmentation excessive et d'une dette technique accumulée. Ce fork apporte les corrections structurelles suivantes :

### 1. Modernisation Android (Media3 / ExoPlayer)
- **Migration Totale :** Passage complet à `androidx.media3:exoplayer`. L'ancienne implémentation basée sur le `MediaPlayer` natif (souvent instable sur les flux distants) a été supprimée.
- **Unification :** Fusion des packages `audioplayers_android` et `audioplayers_android_exo`. Plus de redondance, une seule base de code Android moderne et performante.
- **Nettoyage Natif :** Suppression des classes obsolètes (`SoundPoolPlayer`, `MediaPlayerWrapper`, etc.) pour réduire la surface de bugs.

### 2. Stratégie de Tests & CI Industrielle
Contrairement aux tests d'intégration originaux, lents et souvent fragiles, ce fork impose une rigueur de niveau production :
- **Mocks Professionnels :** Utilisation systématique de `mocktail` pour isoler la logique Dart des dépendances natives. Les tests sont **déterministes** et s'exécutent en moins d'une seconde.
- **Couverture Critique :** Chaque commande (`play`, `pause`, `stop`, `seek`, `dispose`) et chaque source (`Url`, `Asset`, `Bytes`) est testée unitairement.
- **CI Béton :** GitHub Actions valide désormais l'analyse statique (Linter strict), le formatage, les tests unitaires et la **compilation réelle** sur toutes les plateformes (Android, iOS, macOS, Windows, Linux, Web) à chaque commit.

### 3. Décrassage & Optimisation
- **Zéro Code Mort :** Suppression massive des abstractions inutiles et du "code juste au cas où" qui compliquait la maintenance.
- **Linter Strict :** Application de règles de linting rigoureuses pour garantir une base de code uniforme et lisible.
- **Stabilité de l'API :** Focus sur la fiabilité des fonctions de base plutôt que sur l'ajout effréné de fonctionnalités instables.

## 🎯 Philosophie

Ce fork s'adresse aux développeurs qui ne "rigolent pas" avec la stabilité de leurs applications. Ici, on privilégie la **prévisibilité** du comportement et la **vitesse de développement** (via des tests rapides) plutôt que la complexité inutile.
