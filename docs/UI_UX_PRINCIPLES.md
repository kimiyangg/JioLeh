# UI/UX Principles

This document defines the usability and accessibility principles JioLeh should
follow when designing, implementing, and reviewing user interface changes.

Use these principles for new screens, feature changes, user flows, empty states,
loading states, error handling, and pull request review.

## Nielsen's 10 Usability Heuristics

| Principle | What to check in JioLeh |
|---|---|
| Visibility of system status | Keep users informed about what is happening with loading states, success messages, error messages, and save confirmation. |
| Match between system and real world | Use familiar language, icons, and flows. For example, use a map pin icon for saved locations. |
| User control and freedom | Let users cancel, go back, edit, delete, undo, or recover from mistakes where the action can be reversed safely. |
| Consistency and standards | Similar actions should look and behave the same across the app. For example, save actions should use consistent placement, wording, and style. |
| Error prevention | Prevent mistakes before they happen. Disable submit actions until required fields are valid, confirm destructive actions, and validate input early. |
| Recognition rather than recall | Show useful options and context clearly so users do not need to memorize information. For example, show saved locations on the map instead of requiring manual search. |
| Flexibility and efficiency of use | Support beginners with clear flows and experienced users with faster paths such as search, filters, recent items, and sensible defaults. |
| Aesthetic and minimalist design | Keep screens focused on the task. Avoid visual clutter, especially on map views where too many controls can hide important location context. |
| Help users recognize, diagnose, and recover from errors | Write error messages that explain the problem and the next step. Example: "Location permission is disabled. Enable it in settings to use nearby pins." |
| Help and documentation | Provide guidance when needed through empty-state hints, onboarding, tooltips, or help content without blocking experienced users. |

## WCAG Accessibility Principles

| Principle | What to check in JioLeh |
|---|---|
| Perceivable | Information must be easy to see or hear. Use readable text sizes, sufficient color contrast, meaningful labels, and alternatives for non-text content. |
| Operable | Interactive elements must be usable. Buttons and map controls should have comfortable tap targets, predictable focus behavior, and support assistive navigation. |
| Understandable | Screens, labels, and messages should be clear and predictable. Use simple wording, consistent navigation, and actionable feedback. |
| Robust | The app should work across supported devices, screen sizes, orientations, and assistive technologies. Prefer semantic UI elements and responsive layouts. |

## Pull Request Checklist

For visible user interface changes, check:

- Does the screen show clear loading, success, empty, and error states where relevant?
- Can users go back, cancel, edit, delete, or recover from common mistakes?
- Are labels, icons, and flows consistent with nearby screens?
- Are invalid or incomplete actions prevented before submission?
- Are important choices visible without requiring memory of a previous screen?
- Is the layout focused, readable, and free of unnecessary controls or text?
- Are error messages specific and actionable?
- Are tap targets large enough and spaced safely?
- Is text readable with sufficient contrast?
- Does the layout work on small and large screens?
- Are screenshots or screen recordings included in the pull request for visible changes?
