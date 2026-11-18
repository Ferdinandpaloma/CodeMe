# CodeMe

A SwiftUI iOS app for learning LeetCode-style problems by pattern. Every solution is in Python.

## Features
- **Roadmap**: 18 topics arranged as a tree (Arrays & Hashing → Two Pointers → … → Math & Geometry), each showing progress.
- **102 curated NeetCode 150 problems**, each with a description, examples, constraints, hints you reveal one at a time, a step-by-step approach, time and space complexity, and a Python solution.
- **Python syntax highlighting**: read-only code blocks with line numbers and a copy button, plus an editor with live highlighting, auto-indent, auto-closing brackets and quotes, smart backspace and a coding key bar. Your code is saved per problem.
- **Lessons**: 20 short lessons (Big-O, Python for Interviews, plus one per topic), each a few parts followed by quick-check questions.
- **Visual walkthroughs**: step-by-step animations of the algorithm on a sample input for 16 key problems. Pointers move, the window and stack update, and the current line of code is highlighted.
- **Key insight** for every problem: a one-line takeaway worth remembering.
- **Daily review**: solved problems come back on a spaced-repetition schedule (Again / Hard / Good / Easy).
- **Drills**: Pattern Trainer (name the pattern), Complexity Quiz (pick the Big-O), Fill the Blank (choose the missing line of a solution) and Line Order (rebuild a scrambled solution).
- **Mock interviews**: timed sessions (Phone Screen, Onsite, Final Round) with random unsolved problems, the topic hidden, hint tracking, a scored summary and history.
- **Daily goal and Problem of the Day** on the Roadmap.
- **Notes** on every problem, plus related problems from the same topic.
- **Reference**: Big-O cheat sheet, Python standard-library cheat sheet, and every pattern's signals and template on one page.
- **Achievements**: 20 badges with progress rings and an unlock toast.
- **Progress**: completion ring, Easy/Medium/Hard breakdown, streak, a 14-day chart, activity heatmap and mastery per topic.
- **Settings**: theme (system/light/dark), editor font size, auto-close brackets, daily goal, hiding solutions, interview length.
- Stars, search, filters, sorting, a random-problem button and swipe actions.

## Run
Requires Xcode 15+ (iOS 17 deployment target).

```sh
open CodeMe.xcodeproj    # then Run on any iPhone simulator
```

The project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `project.yml`. After adding files, run `xcodegen generate`.

## Adding problems
Add a `Problem(...)` to one of the files in `CodeMe/Data/`. The starter code for the editor is generated automatically from the solution's method signatures.

## Design system

`CodeMe/Views/DesignSystem.swift` holds the visual foundations:

- **OKLCH palettes:** every brand, semantic and topic colour is defined in OKLCH and rendered in Display P3. If a colour is out of gamut, only its chroma is reduced. Topic hues are spaced by the golden angle, and yellows get extra lightness.
- **OKLCH gradients:** ramps are interpolated in OKLCH (`OKGradient`, `Color.oklchGradient`), so they don't turn grey or muddy in the middle.
- **Concentric radii:** controls inside cards use `Radius.control`, and each container's radius is that value plus its padding (`Radius.outer`).
- **Alpha borders:** hairlines are translucent black in light mode and translucent white in dark mode.
- **Dark-mode depth:** surfaces get lighter at each elevation and have a lit top edge instead of shadows.
- **Multiple blending:** `AuroraBackground` stacks `.screen`, `.plusLighter`, `.softLight` and `.multiply` layers. Secondary text on hero cards uses `.plusLighter` vibrancy.
- **Masked edges:** `FadingScrollView` fades a horizontal edge only when there is more content to scroll to on that side.
- **Blurred icon swaps:** `SwapIcon` blurs and scales between symbols when the state changes.
- **Matched icon weights:** symbols use the same weight as the text next to them.
- **Dynamic viewport:** sizes and grid columns are derived from the available width and Dynamic Type.
