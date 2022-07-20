---
name: Bug Report
about: If you found a bug, please use this template to report it.
title: ''
labels: bug
assignees: ''

---

## Checklist
- [ ] I read the [troubleshooting guide](https://github.com/bluefireteam/audioplayers/blob/main/troubleshooting.md) before raising this issue
- [ ] I made sure that the issue I am raising doesn't already exist

<!-- "one liner" - concisely describe your bug with one very brief paragraph, preferably between 1-3 lines, in clear, correct and acceptable English -->

## Current bug behaviour
<!-- What is the current behaviour that you see? -->

## Expected behaviour
<!-- What behaviour did you expect? -->

## Steps to reproduce
<!-- Please include full steps to reproduce so that we can reproduce the problem. -->

1. Execute `flutter run` on the code sample <!-- (see "Code sample" section below) -->
2. ... <!-- describe steps to demonstrate bug -->
3. ... <!-- for example "Tap on X and see a crash" -->

<details>
<summary>Code sample</summary>

<!-- Provide a [minimal reproducible example](https://stackoverflow.com/help/minimal-reproducible-example), i.e., code that allows us to replicate the bug. 

     You have the following options:
     * "One liner", if it already is enough to reproduce (rarely is).
     * A bigger example with all your relevant code. You **must** use code blocks to put your code in. 
     * Link a newly created sample repo reproducing the issue:
       * Either use a newly created sample, e.g. via `flutter create my_bug`
       * Or use the existing example: https://github.com/bluefireteam/audioplayers/tree/main/packages/audioplayers/example
       * Don't send your whole project repo, please read the article linked and extract a **minimal** example.
       * You must put in at least a bit of the relevant code and where to find it in the repo. 
-->

```dart
void main() {
}
```

</details>

## Logs

<!-- Code block with 2-3 relevant log lines -->
```
my relevant logs
```

<details>
  <summary>Full Logs</summary>

  <!-- You **must** use code blocks (or link gists) to paste in log lines. -->

  ```
  my full logs or a link to a gist
  ```

  Flutter doctor:
  ```
  Output of: flutter doctor -v
  ```
</details>

## Audio Files/URLs/Sources
<!-- If your issue or bug involves specific files, you must provide them. 
     If they are URLs they should already be somewhere in the code provided but please replicate those here. 
     If they are private URLs or actual files, please upload them somewhere accessible and add them here. 
     If your issue is with a stream, for example, provide the stream link or if the stream is private, 
     create a similar stream that also causes the problem and is public, and add that. 
     If you don't know if your issue involves specific resources, please download a few of the 
     [mp3 sample files](https://github.com/luanpotter/audioplayers/tree/master/example/assets) 
     present in the `example` app and test with those instead of whatever you are doing currently. 
     If the issue persists, it does not involve specific files. Otherwise, this section is **mandatory**.
-->

- Sample Url: https://luan.xyz/files/audio/coins.wav
- Sample Stream: https://example.com/my_stream.m3u8

## Screenshots
<!-- If applicable, add screenshots or video recordings to help explain your problem. This is totally optional. 
     You can upload them directly on GitHub.
     Beware that video file size is limited to 10MB.
-->

## Environment information

* audioplayers version:
<!-- 
  * pub version 
  * or if you built it yourself what branch and was the latest commit hash 
-->

<!-- List in detail here **all** the platforms that you have tested, indicating which platforms the error occurs on. 
     Please try to test on as many different platforms as possible to make our lives easier (this is optional). 
     You must add at least one platform in which the problem occurs (evidently). For each platform listed, you must specify:
-->
Platform 1: <!-- web, android, ios, macos -->
* OS name and version: <!-- the android version, ios/macos versions or browser name and version used -->
* Device: 
<!-- 
  * physical device: brand/model/kind
  * emulator/simulator: desktop OS and version
  * web/desktop: desktop OS and version
-->
* build mode: `debug`
<!-- 
  * specify if you ran the app in `release`, `profile` or `debug` modes. 
  * specify any additional flags or conditions that might be relevant 
    (for example, if you ran flutter web with the skia use canvas flag set to true).
-->
* error peculiarities (optional): <!-- error peculiarities that only exist on this platform -->

<!-- If having the problem on multiple platforms please mention these:
     Platform 2: Device, build mode, error peculiarities, etc. 
-->

Platforms tested without any issue (optional): <!-- web, android, ios, macos, none -->
* test peculiarities:
<!-- How the results of successful tests differ from the platform on which the test fails.
     e.g. add logs of succeeded tests.
-->

## More information
<!-- Do you have any other useful information about this bug report? Please write it down here -->
<!-- Possible helpful information: references to other sites/repositories -->
<!-- Are you interested in working on a PR for this? -->
