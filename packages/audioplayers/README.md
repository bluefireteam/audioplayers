# 🛡️ Audioplayers - Fork Robuste
**⚠️ PHILOSOPHIE :** Ce fork privilégie la **Stabilité**, la **Gestion d'Erreurs** et la **Sécurité en Production** par rapport à la pureté théorique ou aux paradigmes centrés sur le Web.

## Pourquoi ce fork ?
Cette version existe car le dépôt officiel privilégie le crash des applications pour des "besoins de tests" plutôt que de gérer correctement les exceptions d'E/S (Entrées/Sorties) au moment de l'exécution.

### Ce fork est conçu pour :
*   **Les Développeurs Mobile Natifs** qui comprennent que les opérations d'E/S (Audio, Fichier, Matériel) sont intrinsèquement instables et doivent être gérées proprement.
*   **Les Applications en Production** où un crash utilisateur n'est jamais un résultat acceptable.
*   **Les Ingénieurs** qui valorisent la robustesse système C/C++/Dart plutôt que les promesses "style JavaScript".

### Le Désaccord Technique Fondamental
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

# 🛡️ Audioplayers - Hardened Fork
**⚠️ PHILOSOPHY:** This fork prioritizes **Stability**, **Error Handling**, and **Production Safety** over theoretical purity or web-centric paradigms.

## Why this fork?
This version exists because the official repository prioritizes crashing applications for "testing purposes" rather than properly handling runtime I/O exceptions.

### This fork is designed for:
*   **Native Mobile Developers** who understand that I/O operations (Audio, File, Hardware) are inherently unstable and must be handled gracefully.
*   **Production Applications** where a user crash is never an acceptable outcome.
*   **Engineers** who value C/C++/Dart system-level robustness over "JavaScript-style" promises.

### The Core Technical Disagreement
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
_____________________________________________________________________________

<p align="center">
  <a href="https://pub.dev/packages/audioplayers">
    <img alt="AudioPlayers" height="150px" src="https://raw.githubusercontent.com/bluefireteam/audioplayers/main/images/logo_ap_compact.svg">
  </a>
</p>
<p align="center">
  A Flutter plugin to play multiple simultaneously audio files, works for Android, iOS, Linux, macOS, Windows, and web.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/audioplayers"><img src="https://img.shields.io/pub/v/audioplayers.svg?style=popout&include_prereleases"/></a>
  <a title="Build Status" href="https://github.com/bluefireteam/audioplayers/actions?query=workflow%3Abuild+branch%3Amain"><img src="https://github.com/bluefireteam/audioplayers/actions/workflows/build.yml/badge.svg?branch=main"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---

<a title="Sources" href="https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/sources.dart"><img src="https://raw.githubusercontent.com/bluefireteam/audioplayers/main/images/screenshot_src.png" width="25%"/></a><a title="Controls" href="https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/controls.dart"><img src="https://raw.githubusercontent.com/bluefireteam/audioplayers/main/images/screenshot_ctrl.png" width="25%"/></a><a title="Streams" href="https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/streams.dart"><img src="https://raw.githubusercontent.com/bluefireteam/audioplayers/main/images/screenshot_stream.png" width="25%"/></a><a title="Audio Context" href="https://github.com/bluefireteam/audioplayers/blob/main/packages/audioplayers/example/lib/tabs/audio_context.dart"><img src="https://raw.githubusercontent.com/bluefireteam/audioplayers/main/images/screenshot_ctx.png" width="25%"/></a>
<p align="center"><i>Check out the live <a href="https://bluefireteam.github.io/audioplayers/">example app</a>.</i></p>

**Note**: all the docs are kept up to date to reflect the content of the current newest release. If you are looking for older information and guidance, please checkout the [tag](https://github.com/bluefireteam/audioplayers/tags) related to the version that you are looking for.

<!-- Specific CHANGELOG.md exists in the audioplayers packagage as well as in the root folder, too. So can link it relatively here -->
If you are interest in migrating major versions, please check the [changelog](CHANGELOG.md) and [our migration guide](https://github.com/bluefireteam/audioplayers/blob/main/migration_guide.md).

## Getting Started

We tried to make audioplayers as simple to use as possible:

```dart
import 'package:audioplayers/audioplayers.dart';
// ...
final player = AudioPlayer();
await player.play(UrlSource('https://example.com/my-audio.wav'));
```

Please follow our [Getting Started tutorial](https://github.com/bluefireteam/audioplayers/blob/main/getting_started.md) for all high-level information you need to know.

Then, if you want to dig deeper, our code is very well documented with dartdocs, so check [our API reference](https://pub.dev/documentation/audioplayers/latest/) or the codebase itself on your IDE (or on GitHub).

If something is not clear on our docs, please send a PR to help us improve.

## Help

If you have any problems, please follow these steps before opening an issue.

1. Carefully read the [Getting Started tutorial](https://github.com/bluefireteam/audioplayers/blob/main/getting_started.md) before anything else. Re-read if necessary.
1. Check our [Troubleshooting Guide](https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md) for solutions for most problems.
1. If you have a missing feature report or feature request, please first check the [Feature Parity Table](https://github.com/bluefireteam/audioplayers/blob/main/feature_parity_table.md) to understand our roadmap and what we know is missing. We love contributions!
1. Join [Blue Fire's Discord server](https://discord.gg/5unKpdQD78) and ask for directions. Maybe it's not a bug, or it's a known issue.
1. If you are more comfortable with StackOverflow, you can also create a question there. Add the [flutter-audioplayers tag](https://stackoverflow.com/questions/tagged/flutter-audioplayers), so that anyone following the tag can help out.
1. If the issue still persists, go to the [create an issue](https://github.com/bluefireteam/audioplayers/issues/new/choose) page and follow the step-by-step there before submitting.
1. If the step-by-step there doesn't give you any help, then proceed to create the issue **following the template**. Do not skip mandatory sections. Do not include the literal text of the template, rather replace the sections with what they should contain.

Any issues created not following the list above can be flagged or closed by our team.

## Feature Parity Table

Not all features are available on all platforms. [Click here](https://github.com/bluefireteam/audioplayers/blob/main/feature_parity_table.md) to see a table relating what features can be used on each target.

Feel free to use it for ideas for possible PRs and contributions you can help with on our roadmap! If you are submitting a PR, don't forget to update the table.

## Support

The simplest way to show us your support is by giving the project a star! :star:

You can also support us monetarily by donating through OpenCollective:

<a href="https://opencollective.com/blue-fire/donate" target="_blank">
  <img src="https://opencollective.com/blue-fire/donate/button@2x.png?color=blue" width=200 />
</a>

Through GitHub Sponsors:

<a href="https://github.com/sponsors/bluefireteam" target="_blank">
  <img
    src="https://img.shields.io/badge/Github%20Sponsor-blue?style=for-the-badge&logo=github&logoColor=white"
    width=200
  />
</a>

Or by becoming a patron on Patreon:

<a href="https://www.patreon.com/bluefireoss" target="_blank">
  <img src="https://c5.patreon.com/external/logo/become_a_patron_button.png" width=200 />
</a>

**Note**: this software was made by the community, for the community, on our spare time, with no commercial affiliation.
It is provided as is and any positive contribution is appreciated.
Be kind and mindful of the free time that a battalion of people has gifted on behalf of the community to craft and maintain this.

## Contributing

All help is appreciated but if you have questions, bug reports, issues, feature requests, pull requests, etc, please first refer to our [Contributing Guide](https://github.com/bluefireteam/audioplayers/blob/main/contributing.md).

Be sure to check the [Feature Parity Table](https://github.com/bluefireteam/audioplayers/blob/main/feature_parity_table.md) to understand if your suggestion is already tracked, on the roadmap, or out of scope for this project.

Also, as always, please give us a star to help!

## Credits

This was originally a fork of [rxlabz's audioplayer](https://github.com/rxlabz/audioplayer), but since we have diverged and added more features.

Thanks for @rxlabz for the amazing work!