# Contributing

Thanks for using audioplayers and especially for your interest in contributing to the community!

Please read this document carefully before doing anything else!

## Environment Setup

Audioplayers is set up to run with the most recent `stable` version of Flutter, so make sure your version
matches that:

```bash
flutter channel stable
```

Next, at the root of your locally cloned repository, get the dependencies for the entire workspace:

```bash
flutter pub get
```

This project uses [Dart Workspaces](https://dart.dev/tools/pub/workspaces), which automatically links all packages, examples, and tests within the project. This allows everything to build from the local clone without manual `dependency_overrides`.

### Current Development

If you want to use the most recent changes in your own project, add following dependencies to your `pubspec.yaml` or `pubspec_overrides.yaml`:

```yaml
dependency_overrides:
  audioplayers:
    git:
      url: https://github.com/Sebastien-VZN/audioplayers.git
      path: 'packages/audioplayers'
  audioplayers_platform_interface:
    git:
      url: https://github.com/Sebastien-VZN/audioplayers.git
      path: 'packages/audioplayers_platform_interface'
  audioplayers_web:
    git:
      url: https://github.com/Sebastien-VZN/audioplayers.git
      path: 'packages/audioplayers_web'
  audioplayers_linux:
    git:
      url: https://github.com/Sebastien-VZN/audioplayers.git
      path: 'packages/audioplayers_linux'
  audioplayers_android:
    git:
      url: https://github.com/Sebastien-VZN/audioplayers.git
      path: 'packages/audioplayers_android'
  audioplayers_darwin:
    git:
      url: https://github.com/Sebastien-VZN/audioplayers.git
      path: 'packages/audioplayers_darwin'
  audioplayers_windows:
    git:
      url: https://github.com/Sebastien-VZN/audioplayers.git
      path: 'packages/audioplayers_windows'
```

## General Rules

* Read this doc, the readme and everything else required carefully
* Use clear, correct and acceptable English
* Be polite, thoughtful and appreciate other people's time
* Don't expect anyone to do anything for you, we are all helping each other to nourish a thriving community

## Contribution Types

### Bugs / Issue Reports

If you found a bug or issue, please report it to us! 
Check for existing issues first. If it's about a specific feature not being implemented on a specific platform, we already track that on the [Feature Parity Table](feature_parity_table.md).

Once you are certain your bug is legit and brand new, create an issue using the `Bug Report` template.

### Feature Requests / PRs

Please open a Feature Request issue before opening a PR for non-trivial changes.

**PR Rules:**
 * Start your PR title with a [conventional commit](https://www.conventionalcommits.org) type (feat:, fix: etc).
 * Your build must pass.
 * Follow guidelines for Dart (Flame style guide) and Native (Chromium for C++, Kotlin style guide, Google Swift style guide).
 * Write clean code with comments and docs.
 * Update documentation (README, feature parity table) accordingly.
 * Ensure your change is testable on the `example` app. This is **mandatory**.
 * Add unit tests where it makes sense.
