---
name: Bug Report
about: If you found a bug, please use this template to report it.
title: ''
labels: bug
assignees: ''

---

["one liner" - concisely describe your bug with one very brief paragraph, preferably between 1-3 lines, in clear, correct and acceptable English]

**Full Description**
Describe in  what the bug is, exactly how, what and when it happens. In particular specifying what you thought should happen and what did happen, and how they differ, in detail. Unless the bug is abundantly clear by the "one liner" (rarely is), this is mandatory. Try to be concise but it's better to write too much than too little.

**Code to Reproduce**
A [minimal reproducible example](https://stackoverflow.com/help/minimal-reproducible-example), i.e., code that allows us to replicate the bug. This is **mandatory**. It can be one line, if it already is enough to reproduce (rarely is), or a bigger example with all your relevant code. You **must** use code blocks to put your code in. Don't send your whole project repo, please read the article linked and extract a **minimal** example, but feel free to link a newly created sample repo reproducing the issue instead of pasting code if necessary (rarely is). If you do link a repo, you must put in at least a little bit of the relevant code and where to find it in the repo.

**Log Errors**
If your problem involves log errors or messages, please put them here, in full, but feel free to highlight the parts that are relevant. You **must** use code blocks (or gists) to paste in log lines. An absolutely outstanding example would be to add a code block with 2-3 relevant log lines, followed by a link to a gist with the whole log from which the relevant lines were extracted.

**Files/URLs/Sources**
If your issue or bug involves specific files, you must provide them. If they are URLs they should already be somewhere in the code provided but please replicate those here. If they are private URLs or actual files, please upload them somewhere accessible and add them here. If your issue is with a stream, for example, provide the stream link or if the stream is private, create a similar stream that also causes the problem and is public, and add that. If you don't know if your issue involves specific resources, please download a few of the [mp3 sample files](https://github.com/luanpotter/audioplayers/tree/master/example/assets) present in the `example` app and test with those instead of whatever you are doing currently. If the issue persists, it does not involve specific files. Otherwise, this section is **mandatory**.

**Screenshots**
If applicable, add screenshots or video recordings to help explain your problem. This is totally optional.

**Platforms**
List in detail here **all** the platforms that you have tested, indicating which platforms the error occurs on. Please try to test on as many different platforms as possible to make our lives easier (this is optional). You must add at least one platform in which the problem occurs (evidently). For each platform listed, you must specify:

* OS: web, android, ios, macos, etc. if web, which browser was used.
* OS version: the android version, ios/macos versions or browser version used.
* Device: whether it was a physical device or emulator/simulator. If running on a physical device, what brand/model/kind of device was used. If running on an emulator, what host desktop was used. For web/desktop, what desktop OS and version was used.
* flutter version: what exact flutter version you used. If you think it might be a configuration/setup issue, feel free to add a link to a gist with the output of `flutter doctor -v` (this is optional).
* audioplayers version: what version on pub you used, or if you built it yourself what branch and was the latest commit hash
* release or not release: specify if you ran the app in release, profile or debug modes. Also specify here any additional flags or conditions that might be relevant (for example, if you ran flutter web with the skia use canvas flag set to true, please mention that here).
* does the error occur and does it have any peculiarities: of course if you only tested in one platform, clearly the error occurred there. But if you happened to test on several platforms, please include all of your tests, even the ones that succeeded here, as that info is super valuable. Add details of what was the result in each platform to the extent to which they differed.
