# Contributing

Thanks for using audioplayers and especially for your interest in contributing to the community!

Please read this document carefully before doing anything else!

## Environment Setup

Audioplayers is set up to run with the most recent `stable` version of Flutter, so make sure your version
matches that:

```bash
flutter channel stable
```

Also, audioplayers uses [Melos](https://github.com/invertase/melos) to manage the project and dependencies.

To install Melos, run the following command from your terminal:

```bash
flutter pub global activate melos
```

Next, at the root of your locally cloned repository bootstrap the projects dependencies:

```bash
melos bootstrap
```

The bootstrap command locally links all dependencies within the project without having to
provide manual [`dependency_overrides`](https://dart.dev/tools/pub/pubspec). 
This allows all plugins, examples and tests to build from the local clone project. 
You should only need to run this command once.

> You do not need to run `flutter pub get` once bootstrap has been completed.

### Current Development

If you want to use the most recent changes in your own project add following dependencies to your `pubspec.yaml` or `pubspec_overrrides.yaml`:

```yaml
dependency_overrides:
  audioplayers:
    git:
      url: https://github.com/bluefireteam/audioplayers.git
      path: 'packages/audioplayers'
  audioplayers_platform_interface:
    git:
      url: https://github.com/bluefireteam/audioplayers.git
      path: 'packages/audioplayers_platform_interface'
  audioplayers_web:
    git:
      url: https://github.com/bluefireteam/audioplayers.git
      path: 'packages/audioplayers_web'
  audioplayers_linux:
    git:
      url: https://github.com/bluefireteam/audioplayers.git
      path: 'packages/audioplayers_linux'
  audioplayers_android:
    git:
      url: https://github.com/bluefireteam/audioplayers.git
      path: 'packages/audioplayers_android'
  audioplayers_darwin:
    git:
      url: https://github.com/bluefireteam/audioplayers.git
      path: 'packages/audioplayers_darwin'
  audioplayers_windows:
    git:
      url: https://github.com/bluefireteam/audioplayers.git
      path: 'packages/audioplayers_windows'
```

## Old Issues/PRs

We have many existing open issues and a few open PRs that were created before this doc was created. We will try to respect their ignorance of this file's existence by doing our best effort to answer/address/fix/merge them as we normally would up to this point (i.e. as time permits). 
However, if an existing issue or PR is too blatant of an outlier from these rules, we reserve the right of asking, in the issue/PR for the author (or someone) to fix it so that it falls under the new rules (i.e. apply the templates, etc). 
If we need to do that, we will give two weeks for the issue/PR to be updated to follow the rules, otherwise it will be closed.

Of course, anyone is free to open a similar followup at any time, as long as the new one follows the rules.

With that particular comment in mind, consider the following rules to apply to all new issues only.

## General Rules

This document is divided in sections for each kind of contribution you have, but for any of them, basically for any form of communication between members of the community, you must follow these rules. 
I am adding them here at the top because they apply to all sections but also because they are the uttermost important thing for us.

* Read this doc, the readme and everything else required carefully
* Use clear, correct and acceptable English
* Be polite, thoughtful and appreciate other people's time
* Don't expect anyone to do anything for you, we are all helping each other to nourish a thriving community

Any issues, PRs, or messages that do not follow can be deleted by our moderators and under persistent bad behavior we reserve the right to ban people.

## Contribution Types

After you read and accepted the rules above, you need to decide what kind of inquiry do you have. Choose the most appropriate of the sections below.

### Questions

Questions are not bugs! Do not open issues for questions. Here are the channels to ask for help.

First of all, make sure you read *at least* the [Readme Document](README.md) and the [Getting Started tutorial](getting_started.md) in full. That is the basis of how this library work and its very well written with care and love by us. If you haven't read even the basics, don't expect us to answer a question that is already solved there.

Second, make sure you went through our FAQ, [Troubleshooting](troubleshooting.md). There are many questions we get asked all the time that we have put the time and effort to answer on that doc. So make sure your question is not already there.

Third, if your question is not there, try to searching for old issues. Even though we no longer use issues to track questions, we used to have A LOT of questions in the closed issues that are still there for documentation. Also maybe an old issue might give you context on how something works. In fact, if that doesn't work, try just searching google, stack overflow, discord logs. Maybe your question was already answered!

Lastly, try finding the answer in the source code. We try to keep our code clean and easy to understand, including docs explaining how things work. If our code/docs are not clear on something, this is a great opportunity to help with a PR (see feature requests below).

If you still have a question, then you might have a legit question! However issues are not the way to ask then. The ways in which we accept questions are:

 * [Our discord channel](https://discord.gg/ny7eThk): This is [Fire Slime Games](https://fireslime.xyz/) discord server, the people that are also behind Flame/audioplayers. We have a channel on the server dedicated for audioplayers questions. There you will be able to find many people, often knowing much more than we do, eager to help you out (as long as you followed all the steps). This is the quicker way to get help!

 * The `flutter-audioplayers` tag on [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter-audioplayers): Feel free to use the [flutter-audioplayers] tag on Stack Overflow to get people from the community to help. This might be a bit more involved than discord but if you make a properly acceptable Stack Overflow question, people will be much more willing to help you with hard problems. Also, you are leaving some documentation for future generations!

### Bugs / Issue Reports

If you found a bug or issue, please report it to us! If you are unsure if it's a bug or a question, feel free to ask on the discord channel first, or if you truly believe in good faith it's a bug, you can open an issue on GitHub.

But the first step is, again, to search for an existing issue. Maybe your issue was already reported, and we don't want duplicates. In fact, if it was already reported, the existing issues might have tips and tricks to circumvent the issue until we fix it.

Also, if it's about a specific feature not being implemented on a specific platform, we already track that on the [Feature Parity Table](feature_parity_table.md). PRs are welcome, but no need to report what we already know. We are progressing under our best effort to fulfill the most requested gaps.

Once you are certain your bug is legit and brand new, you can create an issue and select the `Bug Report` type. You **must** follow the template provided, read it carefully.

**Note**: read the template and *replace* the sections with your content. Do not *keep* the instructions on the final text of your PR. PRs that contains copied excerpts from the template (other than the titles, etc), will be closed without notice.

### Feature Requests / PRs

Unless your PR is super simple (i.e. typo fixes, documentation improvements, etc), please open a Feature Request issue before opening a PR. You can make it clear in your feature request that you are willing to contribute with a PR, but it's important to have some discussion before starting anything more complicated; we might have better suggestions of how to do things.

In order to open a Feature Request issue, just select the correct template under issue creation. You **must** follow the guidelines in the template.

Once your feature got approved to start developing, feel free to send your PRs! However, we have a few important PR rules:

 * Start your PR title with a [conventional commit](https://www.conventionalcommits.org) type (feat:, fix: etc).
 * Your build must pass. Please make sure everything is green!
 * Follow guidelines. For the Dart side, follow [Flame's official style guide](https://github.com/flame-engine/flame/blob/main/doc/development/style_guide.md). 
   We also provide code linting and formatting for the native side, where we take the [Flutter's formatting](https://github.com/flutter/packages/blob/main/script/tool/lib/src/format_command.dart) as reference:
   * C/C++: [Chromium coding style](https://chromium.googlesource.com/chromium/src/+/refs/heads/main/styleguide/c++/c++.md) via [clang-format](https://clang.llvm.org/docs/ClangFormatStyleOptions.html), available for [CLion](https://www.jetbrains.com/help/clion/clangformat-as-alternative-formatter.html) and [VSCode](https://code.visualstudio.com/docs/cpp/cpp-ide#_code-formatting)
   * Kotlin: [Kotlin style guide](https://developer.android.com/kotlin/style-guide) via [ktlint](https://github.com/pinterest/ktlint) and [EditorConfig](https://editorconfig.org/), available for [IntelliJ](https://www.jetbrains.com/help/idea/editorconfig.html) and [VSCode](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)
   * Swift: [Google Swift Style Guide](https://google.github.io/swift/) via [swift-format](https://github.com/apple/swift-format), available for [VSCode](https://marketplace.visualstudio.com/items?itemName=vknabel.vscode-apple-swift-format) or CLI with [native installation](https://github.com/apple/swift-format#getting-swift-format) or [Docker](https://github.com/mtgto/docker-swift-format/tree/main)
 * Write clean, beautiful and easy to understand code, with comments if necessary and docs if applicable.
 * Update our README/getting started/feature parity table/any other docs accordingly to your change, making it clear which platforms are supported.
 * Try to support all platforms where it makes sense. This is a hard thing to ask, and we understand and we will merge PRs that only work on one platform as well. But if you have the time, please help us with feature parity.
 * Make sure your change is testable on the `example` app. If necessary, add to it. This is **mandatory**. We need to be able to at least manually try your feature. Tests are even better of course (see below).
 * Try to add tests, if possible. We don't strive for 100% coverage, but we have very basic driver tests and unit tests where it makes sense (not all places can be tested for an audio player app).
 * Do not add a new version to the changelog, bump versions or anything like that. We will deal with the release process using `melos` whenever there is something to release.
