<p align="center">
  <a href="https://pub.dev/packages/audioplayers">
    <img alt="AudioPlayers" height="150px" src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/logo_ap_compact.svg">
  </a>
</p>

<p align="center">
  <b>Hardened Fork | Fork Robuste</b>
</p>

<p align="center">
  <a href="#-english">
    <img src="https://img.shields.io/badge/Lang-English-blue" alt="English">
  </a>
  <a href="#-français">
    <img src="https://img.shields.io/badge/Lang-Français-red" alt="Français">
  </a>
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/audioplayers"><img src="https://img.shields.io/pub/v/audioplayers.svg?style=popout&include_prereleases"/></a>
  <a title="Build Status" href="https://github.com/Sebastien-VZN/audioplayers/actions?query=workflow%3Abuild+branch%3Amain"><img src="https://github.com/Sebastien-VZN/audioplayers/actions/workflows/build.yml/badge.svg?branch=main"/></a>
</p>

---

<a id="-english"></a>
# 🇺🇸 English

## 🛡️ Audioplayers - Hardened Fork
**⚠️ PHILOSOPHY:** This fork prioritizes **Stability**, **Error Handling**, and **Production Safety** over theoretical purity or web-centric paradigms.

### Why this fork?
This version exists because the official repository prioritizes crashing applications for "testing purposes" rather than properly handling runtime I/O exceptions.

#### This fork is designed for:
*   **Native Mobile Developers** who understand that I/O operations (Audio, File, Hardware) are inherently unstable and must be handled gracefully.
*   **Production Applications** where a user crash is never an acceptable outcome.
*   **Engineers** who value C/C++/Dart system-level robustness over "JavaScript-style" promises.

#### The Core Technical Disagreement
This fork was born following the official repository's refusal to integrate error handlers (`try-catch`) around unstable native calls.
*   **Original Approach:** Let the application crash on error to "facilitate testing," applying Web (JavaScript) paradigms to native development.
*   **This Fork's Approach:** I believe that Audio and I/O rely on the OS and hardware (beyond our control). A production app must **never** crash due to an audio initialization failure. Errors must be caught, logged, and handled.

## 🤝 Code of Conduct & Mindset
I am a very patient maintainer who loves saving time for everyone, provided the discussion remains factual and humble.
I prioritize **performance**, **hardware resource optimization**, and **plugin stability** above all else.

*   **We are all human:** The golden rule here is to acknowledge mistakes. We all learn from our errors, myself included. I hold myself to these exact same standards.
*   **Facts over Ego:** I never seek to be "right" for the sake of winning an argument. My only goal is technical correctness, backed by facts, sources, and logic.

**Contribution Policy:** If you contribute, **bring your logs and your solutions**. Every contribution—no matter the size—is welcome, and I thank you fully for it. Regarding the **Web** platform: I do not actively maintain it; Web maintainers must handle their part exclusively without affecting native code. You can even propose to organize the project if you wish; I am open to any request.

**The Future:** If this robust approach proves its value in production, I intend to propose this fork as a reliable alternative for the Flutter ecosystem. I will do what I can to maintain it, despite being on another project. If I find errors on the 3 platforms I master (**Linux, Windows, and Android**), fixes will be applied immediately. Do not hesitate to open requests if you have any problems; I will do my best to respond.

**License & Open Source:** As this project is under the MIT License, the original LICENSE and the core README documentation remain strictly respected and unmodified. The codebase will always remain open and accessible to everyone.

---

## 📚 Standard Documentation (English)

<p align="center">
  A Flutter plugin to play multiple simultaneously audio files, works for Android, iOS, Linux, macOS, Windows, and web.
</p>

<a title="Sources" href="https://github.com/Sebastien-VZN/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/sources.dart"><img src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/screenshot_src.png" width="25%"/></a><a title="Controls" href="https://github.com/Sebastien-VZN/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/controls.dart"><img src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/screenshot_ctrl.png" width="25%"/></a><a title="Streams" href="https://github.com/Sebastien-VZN/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/streams.dart"><img src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/screenshot_stream.png" width="25%"/></a><a title="Audio Context" href="https://github.com/Sebastien-VZN/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/audio_context.dart"><img src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/screenshot_ctx.png" width="25%"/></a>
<p align="center"><i>Check out the live <a href="https://Sebastien-VZN.github.io/audioplayers/">example app</a>.</i></p>

**Note**: all the docs are kept up to date to reflect the content of the current newest release. If you are looking for older information and guidance, please checkout the [tag](https://github.com/Sebastien-VZN/audioplayers/tags) related to the version that you are looking for.

<!-- Specific CHANGELOG.md exists in the audioplayers packagage as well as in the root folder, too. So can link it relatively here -->
If you are interest in migrating major versions, please check the [changelog](CHANGELOG.md) and [our migration guide](https://github.com/Sebastien-VZN/audioplayers/blob/main/migration_guide.md).

### Getting Started

We tried to make audioplayers as simple to use as possible:

```dart
import 'package:audioplayers/audioplayers.dart';
// ...
final player = AudioPlayer();
await player.play(UrlSource('https://example.com/my-audio.wav'));
```

Please follow our [Getting Started tutorial](https://github.com/Sebastien-VZN/audioplayers/blob/main/getting_started.md) for all high-level information you need to know.

Then, if you want to dig deeper, our code is very well documented with dartdocs, so check [our API reference](https://pub.dev/documentation/audioplayers/latest/) or the codebase itself on your IDE (or on GitHub).

If something is not clear on our docs, please send a PR to help us improve.

### Help

If you have any problems, please follow these steps before opening an issue.

1. Carefully read the [Getting Started tutorial](https://github.com/Sebastien-VZN/audioplayers/blob/main/getting_started.md) before anything else. Re-read if necessary.
1. Check our [Troubleshooting Guide](https://github.com/Sebastien-VZN/audioplayers/blob/main/troubleshooting.md) for solutions for most problems.
1. If you have a missing feature report or feature request, please first check the [Feature Parity Table](https://github.com/Sebastien-VZN/audioplayers/blob/main/feature_parity_table.md) to understand our roadmap and what we know is missing. We love contributions!
1. If you are more comfortable with StackOverflow, you can also create a question there. Add the [flutter-audioplayers tag](https://stackoverflow.com/questions/tagged/flutter-audioplayers), so that anyone following the tag can help out.
1. If the issue still persists, go to the [create an issue](https://github.com/Sebastien-VZN/audioplayers/issues/new/choose) page and follow the step-by-step there before submitting.
1. If the step-by-step there doesn't give you any help, then proceed to create the issue **following the template**. Do not skip mandatory sections. Do not include the literal text of the template, rather replace the sections with what they should contain.

Any issues created not following the list above can be flagged or closed by our team.

### Feature Parity Table

Not all features are available on all platforms. [Click here](https://github.com/Sebastien-VZN/audioplayers/blob/main/feature_parity_table.md) to see a table relating what features can be used on each target.

Feel free to use it for ideas for possible PRs and contributions you can help with on our roadmap! If you are submitting a PR, don't forget to update the table.

### Contributing

All help is appreciated but if you have questions, bug reports, issues, feature requests, pull requests, etc, please first refer to our [Contributing Guide](https://github.com/Sebastien-VZN/audioplayers/blob/main/contributing.md).

Be sure to check the [Feature Parity Table](https://github.com/Sebastien-VZN/audioplayers/blob/main/feature_parity_table.md) to understand if your suggestion is already tracked, on the roadmap, or out of scope for this project.

Also, as always, please give us a star to help!

### Credits

This was originally a fork of [rxlabz's audioplayer](https://github.com/rxlabz/audioplayer), but since we have diverged and added more features.

Thanks for @rxlabz for the amazing work!

<br>
<br>

---

<a id="-français"></a>
# 🇫🇷 Français

## 🛡️ Audioplayers - Fork Robuste
**⚠️ PHILOSOPHIE :** Ce fork privilégie la **Stabilité**, la **Gestion d'Erreurs** et la **Sécurité en Production** par rapport à la pureté théorique ou aux paradigmes centrés sur le Web.

### Pourquoi ce fork ?
Cette version existe car le dépôt officiel privilégie le crash des applications pour des "besoins de tests" plutôt que de gérer correctement les exceptions d'E/S (Entrées/Sorties) au moment de l'exécution.

#### Ce fork est conçu pour :
*   **Les Développeurs Mobile Natifs** qui comprennent que les opérations d'E/S (Audio, Fichier, Matériel) sont intrinsèquement instables et doivent être gérées proprement.
*   **Les Applications en Production** où un crash utilisateur n'est jamais un résultat acceptable.
*   **Les Ingénieurs** qui valorisent la robustesse système C/C++/Dart plutôt que les promesses "style JavaScript".

#### Le Désaccord Technique Fondamental
Ce fork est né suite au refus du dépôt officiel d'intégrer des gestionnaires d'erreurs (`try-catch`) autour des appels natifs instables.
*   **L'approche originale :** Laisser l'application crasher en cas d'erreur pour "faciliter les tests", en appliquant des paradigmes Web (JavaScript) au développement natif.
*   **L'approche de ce fork :** Je considère que l'Audio et les E/S dépendent de l'OS et du matériel (hors de notre contrôle). Une application en production ne doit **jamais** crasher à cause d'un échec d'initialisation audio. L'erreur doit être capturée, logguée et gérée.

## 🤝 Code de Conduite & État d'Esprit
Je suis un mainteneur très patient, qui adore gagner du temps et en faire gagner à tout le monde, à condition que la discussion reste factuelle et humble.
Je privilégie la **performance**, l'**optimisation des ressources matérielles** et la **stabilité** du plugin avant tout.

*   **Nous sommes tous humains :** La règle d'or ici est de reconnaître ses erreurs. Nous apprenons tous de nos erreurs, moi y compris. Je m'applique ces mêmes standards rigoureux à moi-même.
*   **Les faits avant l'ego :** Je ne cherche jamais à avoir "raison" pour le plaisir de gagner un argument. Mon seul but est l'exactitude technique, étayée par des faits, des sources et de la logique.

**Politique de Contribution :** Si vous contribuez, **apportez vos logs et vos solutions**. Toute contribution — quelle que soit sa taille — est la bienvenue et je vous en remercie pleinement. 
Concernant la partie **Web** : je ne maintiens pas activement cette plateforme, les contributeurs Web devront s'occuper exclusivement de leur partie sans impacter le code natif. 
Pour toute personne impliqué dans ce fork, Vous pouvez même me proposer d'organiser le projet si vous en avez envie, je suis ouvert à toute demande.

**L'Avenir :** Si cette approche robuste prouve sa valeur en production, je compte proposer ce fork comme une alternative fiable pour l'écosystème Flutter. Je ferai ce que je peux pour le maintenir, bien qu'étant sur un autre projet. Si je trouve des erreurs sur les 3 plateformes que je maîtrise (**Linux, Windows et Android**), les correctifs seront apportés dans l'immédiat. N'hésitez pas à ouvrir des demandes si vous avez un quelconque problème, je ferai au mieux pour y répondre.

**Licence & Open Source :** Ce projet étant sous licence MIT, la LICENSE originale et la documentation README de base restent strictement respectées et non modifiées. La base de code restera toujours ouverte et accessible à tous.

---

## 📚 Documentation Standard (Français)

<p align="center">
  Un plugin Flutter pour lire plusieurs fichiers audio simultanément. Fonctionne sur Android, iOS, Linux, macOS, Windows et Web.
</p>

<a title="Sources" href="https://github.com/Sebastien-VZN/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/sources.dart"><img src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/screenshot_src.png" width="25%"/></a><a title="Controls" href="https://github.com/Sebastien-VZN/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/controls.dart"><img src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/screenshot_ctrl.png" width="25%"/></a><a title="Streams" href="https://github.com/Sebastien-VZN/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/streams.dart"><img src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/screenshot_stream.png" width="25%"/></a><a title="Audio Context" href="https://github.com/Sebastien-VZN/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/audio_context.dart"><img src="https://raw.githubusercontent.com/Sebastien-VZN/audioplayers/main/images/screenshot_ctx.png" width="25%"/></a>
<p align="center"><i>Découvrez l'application d'exemple <a href="https://Sebastien-VZN.github.io/audioplayers/">en direct</a>.</i></p>

**Note** : toute la documentation est maintenue à jour pour refléter le contenu de la dernière version. Si vous cherchez des informations plus anciennes, veuillez consulter les [tags](https://github.com/Sebastien-VZN/audioplayers/tags) correspondant à la version recherchée.

<!-- Specific CHANGELOG.md exists in the audioplayers packagage as well as in the root folder, too. So can link it relatively here -->
Si vous êtes intéressé par la migration entre versions majeures, veuillez consulter le [changelog](CHANGELOG.md) et [notre guide de migration](https://github.com/Sebastien-VZN/audioplayers/blob/main/migration_guide.md).

### Démarrage (Getting Started)

Nous avons essayé de rendre audioplayers aussi simple à utiliser que possible :

```dart
import 'package:audioplayers/audioplayers.dart';
// ...
final player = AudioPlayer();
await player.play(UrlSource('https://example.com/my-audio.wav'));
```

Veuillez suivre notre [tutoriel de démarrage](https://github.com/Sebastien-VZN/audioplayers/blob/main/getting_started.md) pour toutes les informations essentielles.

Ensuite, si vous souhaitez approfondir, notre code est très bien documenté avec dartdocs. Consultez [notre référence API](https://pub.dev/documentation/audioplayers/latest/) ou la base de code elle-même dans votre IDE (ou sur GitHub).

Si quelque chose n'est pas clair dans notre documentation, envoyez une PR pour nous aider à l'améliorer.

### Aide

Si vous rencontrez des problèmes, veuillez suivre ces étapes avant d'ouvrir un ticket (issue).

1. Lisez attentivement le [tutoriel de démarrage](https://github.com/Sebastien-VZN/audioplayers/blob/main/getting_started.md) avant toute chose. Relisez-le si nécessaire.
1. Consultez notre [Guide de Dépannage](https://github.com/Sebastien-VZN/audioplayers/blob/main/troubleshooting.md) pour trouver des solutions à la plupart des problèmes.
1. Si vous souhaitez signaler une fonctionnalité manquante ou faire une demande de fonctionnalité, vérifiez d'abord le [Tableau de Parité des Fonctionnalités](https://github.com/Sebastien-VZN/audioplayers/blob/main/feature_parity_table.md) pour comprendre notre feuille de route. Nous adorons les contributions !
1. Si vous êtes plus à l'aise avec StackOverflow, vous pouvez également y poser une question. Ajoutez le tag [flutter-audioplayers](https://stackoverflow.com/questions/tagged/flutter-audioplayers), afin que ceux qui suivent ce tag puissent vous aider.
1. Si le problème persiste, allez sur la page [créer un ticket](https://github.com/Sebastien-VZN/audioplayers/issues/new/choose) et suivez les étapes indiquées avant de soumettre.
1. Si les étapes ne vous aident pas, procédez à la création du ticket en **suivant le modèle**. Ne sautez pas les sections obligatoires. Ne laissez pas le texte littéral du modèle, remplacez les sections par ce qu'elles doivent contenir.

Tout ticket créé ne respectant pas la liste ci-dessus pourra être signalé ou fermé par notre équipe.

### Tableau de Parité des Fonctionnalités

Toutes les fonctionnalités ne sont pas disponibles sur toutes les plateformes. [Cliquez ici](https://github.com/Sebastien-VZN/audioplayers/blob/main/feature_parity_table.md) pour voir un tableau indiquant quelles fonctionnalités peuvent être utilisées sur chaque cible.

N'hésitez pas à l'utiliser pour trouver des idées de PRs et de contributions pour notre feuille de route ! Si vous soumettez une PR, n'oubliez pas de mettre à jour le tableau.

### Contribuer

Toute aide est appréciée, mais si vous avez des questions, des rapports de bugs, des problèmes, des demandes de fonctionnalités, des pull requests, etc., veuillez d'abord vous référer à notre [Guide de Contribution](https://github.com/Sebastien-VZN/audioplayers/blob/main/contributing.md).

Assurez-vous de vérifier le [Tableau de Parité des Fonctionnalités](https://github.com/Sebastien-VZN/audioplayers/blob/main/feature_parity_table.md) pour comprendre si votre suggestion est déjà suivie, sur la feuille de route, ou hors de portée de ce projet.

Aussi, comme toujours, donnez-nous une étoile pour nous aider !

### Crédits

Ceci était à l'origine un fork de [audioplayer de rxlabz](https://github.com/rxlabz/audioplayer), mais nous avons depuis divergé et ajouté plus de fonctionnalités.

Merci à @rxlabz pour ce travail incroyable !
