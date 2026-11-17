# CodeMe

A SwiftUI iOS app for learning LeetCode-style problems by pattern. Every solution is in Python.

## Features
- **Roadmap**: 18 topics arranged as a tree (Arrays & Hashing → Two Pointers → … → Math & Geometry), each showing progress.
- **56 curated problems**, each with a description, examples, constraints, hints you reveal one at a time, a step-by-step approach, time and space complexity, and a Python solution.
- **Python syntax highlighting**: read-only code blocks with line numbers and a copy button, plus an editor with live highlighting, auto-indent, smart backspace and a coding key bar. Your code is saved per problem.
- **Pattern Trainer**: read a problem statement and pick the pattern that solves it.
- **Progress**: completion ring, Easy/Medium/Hard breakdown, day streak, activity heatmap and mastery per topic.
- Stars, search, filters and swipe actions. Supports dark and light mode.

## Run
Requires Xcode 15+ (iOS 17 deployment target).

```sh
open CodeMe.xcodeproj    # then Run on any iPhone simulator
```

The project is generated with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `project.yml`. After adding files, run `xcodegen generate`.

## Adding problems
Add a `Problem(...)` to one of the files in `CodeMe/Data/`. The starter code for the editor is generated automatically from the solution's method signatures.
