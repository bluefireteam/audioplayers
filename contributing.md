# Contributing

Thanks for using audioplayers and especially for your interest in contributing to the community!

Please read this document carefully before doing anything else!

## Old Issues/PRs

We have many existing open issues and a few open PRs that were created before this doc was created. We will try to respect their innocence of this file existence by doing our best effort to answer/address/fix/merge them as we normally would up to this point (i.e. as time permits). However, if an existing issue or PR is too blatant of an outlier from these rules, we reserve the right of asking, in the issue/PR for the author (or someone) to fix it so that it falls under the new rules (i.e. apply the templates, etc). If we need to do that, we will give two weeks for the issue/PR to be updated to follow the rules, otherwise it will be closed.

Of course, anyone is free to open a similar followup at any time, as long as the new one follows the rules.

With that particular comment in mind, consider the following rules to apply to new issues only.

## General Rules

This document is divided in sections for each kind of contribution you have, but for any of them, basically for any form of communication between members of the community, you must follow these rules. I am adding them here at the top because they apply to all sections but also because they are the uttermost important thing for us.

* Read this doc, the readme and everything else required carefully
* Use clear, correct and acceptable English
* Be polite, thoughtful and appreciate other people's time
* Don't expect anyone to do anything for you, we are all helping each other to nourish a thriving community

Any issues, PRs, or messages that do not follow can be deleted by our moderators and under persistent bad behavior we reserve the right to ban people.

## Contribution Types

After you read and accepted the rules above, you need to decide what kind of inquiry do you have. Choose the most appropriate of the sections below.

### Questions

Questions are not bugs! Do not open issues for questions. Here are the channels to ask for help.

First of all, make sure you read *at least* the [Readme Document](README.md) in full. That is the basis of how this library work and its very well written with care and love by us. If you haven't read even the readme, don't expect us to answer a question that is already solved there.

Second, make sure you went through our FAQ, [Troubleshooting](troubleshooting.md). There are many questions we get asked all the time that we have put the time and effort to answer on that doc. So make sure your question is not already there.

Third, if your question is not there, try to searching for old issues. Even though we no longer use issues to track questions, we used to have A LOT of questions in the closed issues that are still there for documentation. Also maybe an old issue might give you context on how something works. In fact, if that doesn't work, try just searching google, stack overflow, discord logs. Maybe your question was already answered!

Lastly, try finding the answer in the source code. We try to keep our code clean and easy to understand, including docs explaining how things work. If our code/docs are not clear on something, this is a great opportunity to help with a PR (see feature requests below).

If you still have a question, then you might have a legit question! However issues are not the way to ask then. The ways in which we accept questions are:

 * [Our discord channel](https://discord.gg/ny7eThk): This is [Fire Slime Games](https://fireslime.xyz/) discord server, the people that are also behind Flame/audioplayers. We have a channel on the server dedicated for audioplayers questions. There you will be able to find many people, often knowing much more than we do, eager to help you out (as long as you followed all the steps). This is the quicker way to get help!

 * The `flame` tag on [Stack Overflow](https://stackoverflow.com/questions/tagged/flame): Since audioplayers is part of the flame project, feel free to use the [flame] tag on Stack Overflow to get people from the community to help. This might be a bit more involved than discord but if you make a properly acceptable Stack Overflow question, people will be much more willing to help you with hard problems. Also, you are leaving some documentation for future generations!

### Bugs / Issue Reports

If you found a bug or issue, please report it to us! If you are unsure if it's a bug or a question, feel free to ask on the discord channel first, or if you truly believe in good faith it's a bug, you can open an issue on GitHub.

But the first step is, again, to search for an existing issue. Maybe your issue was already reported, and we don't want duplicates. In fact, if it was already reported, the existing issues might have tips and tricks to circumvent the issue until we fix it.

Once you are certain your bug is brand new, you can create an issue and select the `Bug Report` type. You **must** follow the template provided, read it carefully.

### Feature Requests / PRs

Unless your PR is super simple (i.e. typo fixes, documentation improvements, etc), please open a Feature Request issue before opening a PR. You can make it clear in your feature request that you are willing to contribute with a PR, but it's important to have some discussion before starting anything more complicated; we might have better suggestions of how to do things.

In order to open a Feature Request issue, just select the correct template under issue creation. You **must** follow the guidelines in the template.

Once your feature got approved to start developing, feel free to send your PRs! However, we have a few important PR rules:

 * Your build must pass. Please make sure everything is green!
 * Follow guidelines. We don't have a code analyzer for the native side (yet!), but please follow the code around you to make it properly formatted and linted. For Java, please follow an acceptable standard [like this one](https://google.github.io/styleguide/javaguide.html). There is nothing worse than badly formatted code!
 * Write clean, beautiful and easy to understand code, with comments if necessary and docs if possible.
 * Update our README/docs accordingly to your change, making it clear which platforms are supported.
 * Try to support all platforms where it makes sense. This is a hard thing to ask, and we understand and we will merge PRs that only work on one platform as well. But if you have the time, please help us with feature parity.
 * Make sure your change is testable on the `example` app. If necessary, add it. This is **mandatory**. We need to be able to at least manually try your feature. Tests are even better of course (see below).
 * Try to add tests. We (sadly) have very little test coverage. If any new feature had some tests, it would help us a great deal. But this is also a hard ask because we don't have the easiest infrastructure to test, in fact, audio is hard to test.
 * Add your change to the CHANGELOG under the `[next]` section.
 * Do not add a new version to the changelog, bump versions or anything like that. We will deal with the release process and decide the next version after things are merged.
