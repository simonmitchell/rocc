# Contributing to Rocc

👋🏻 Hi there, we're super excited that you want to contribute to Rocc! 📸

Rocc is a project I have worked on over the past 12 months; it is used primarily in the app I created (Camrote) which means I will be fairly stringent with contributions before accepting them, especially when they involve vast changes to the codebase! That being said, I'm very keen to have contributions and general input, and will be working on the framework in my free-time so I will be checking in for PRs and issues regularly!

## The vision for the framework

From the start my development style has been to rely on as few 3rd party frameworks as possible whilst developing and writing things from scratch if necessary (And if I feel I can understand them). This started from a very early stage in my career as a means to understand various Apple APIs and SDKs better. I felt the need to do this as I came to coding fairly late in comparison to a lot of my colleagues; so felt I needed to play catch-up!

That being said, you will notice there are a few bits of Open Source code included in the project (And I hope I haven't forgotten to include any licenses - Please PR or create an issue if I have as this is entirely unintentional!) where I felt it necessary. For this reason, I won't accept PRs that rely heavily on large 3rd party Frameworks; I want this framework to remain a single codebase as much as possible (With a few exceptions) as package management can be a PITA, and well; it's just the way I like it!

My main aim with this framework is for it to become **the** swift framework for interfacing with cameras from all manufacturers. If you have some knowledge of the APIs running on certain manufacturers, or just have a camera lying around and know something about Swift (Or coding in another language) please don't hesitate to have a play around; it could be the case that you only need to make small changes to the existing codebase to get things up and running! 

## How can I contribute

Before you get started, please take a look at [code of conduct](CODE_OF_CONDUCT.md), and make sure to adhere to it ☮️.

### Reporting Bugs

- Ensure the bug hasn't already been reported in GitHub under [Issues](https://github.com/simonmitchell/rocc/issues)
- If you can't find a bug which seems to match yours, or you're unsure (Don't worry I'll flag it as a dupe if I've already seen it!) please create a [new one] (https://github.com/simonmitchell/rocc/issues/new)

### Fixing Bugs

- Please if you find a bug, don't just submit a PR, also [create an issue](https://github.com/simonmitchell/rocc/issues/new) so I have a view over it and can help you with a solution or guide you where to look!
- Once you have fixed a bug, please submit it as a pull request, we want to make this project as stable as possible which is why we're open-sourcing it!

### Fixing whitespacing/formatting or making a cosmetic patch

- Please go ahead and fix whitespacing (I indent using spaces, please also do this... even if you don't agree!)
- If you can see ways to improve method signatures or re-use code please do this, but if you change public facing API I may ask you to re-consider (Unless we're reaching a major release)

### Adding Functionality / Features

Please go ahead and add new functionality and features, however it may be wise to [create an issue](https://github.com/simonmitchell/rocc/issues/new) (Or check the open [issues](https://github.com/simonmitchell/rocc/issues)) first to make sure I (Or someone else) isn't already on it, and also so I can advise as to whether I'm happy it fits within the scope of Rocc or should be it's own entity/framework.

### Adding support for new manufacturers

If you want to add support for a new manufacturer, please create a [new issue] (https://github.com/simonmitchell/rocc/issues/new) to allow for discussion around the process. I don't have access (At the moment) to devices from other manufacturers, and there are still some changes that need to happen to make things more generic (At time of writing the only place I can thing of is with Live View Streaming, but there may be others!).

I'm happy for it to be an open discussion around how we add further support, but have tried to structure the project in a way that it should "Just Work"™️! If we need to make changes to the public facing API, then this is one case where I'm happy to do so, as it's the fundamental use-case of the framework!

---

Thank you for showing an interest in contributing, I look forward to seeing what you can all do for this framework! ❤️