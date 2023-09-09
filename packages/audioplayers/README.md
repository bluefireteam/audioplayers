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
  <a title="Build Status" href="https://github.com/bluefireteam/audioplayers/actions?query=workflow%3Abuild+branch%3Amain"><img src="https://github.com/bluefireteam/audioplayers/workflows/build/badge.svg?branch=main"/></a>
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
