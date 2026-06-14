# Software Engineering Principles and Practices

This document is a detailed study and project reference based on the CS2103/T Software Engineering textbook.

Sources:
- CS2103/T textbook index: https://nus-cs2103-ay2021s1.github.io/website/se-book-adapted/index.html
- CS2103/T printable textbook: https://nus-cs2103-ay2021s1.github.io/website/se-book-adapted/print.html

## 1. Software Engineering Overview

Software engineering is the disciplined development, operation, and maintenance of software. The useful mindset is:

- Build useful software for real users.
- Expect change in requirements, design, code, and team context.
- Use process and tools to manage complexity.
- Prefer working software, feedback, and incremental improvement.
- Keep software understandable so future changes are cheaper.

In practice, software engineering is not only coding. It includes:

- Requirements gathering and specification.
- Software design and architecture.
- Implementation and refactoring.
- Documentation.
- Testing and quality assurance.
- Version control and collaboration.
- Project planning and delivery.

## 2. Object-Oriented Programming Concepts

Object-Oriented Programming (OOP) organizes software as interacting objects.

### Object

An object combines:

- State: the data it stores.
- Behavior: the operations it can perform.

Objects interact by sending messages, usually through method calls.

### Interface and Implementation

Every object has:

- Interface: what other objects can use.
- Implementation: how the object actually performs the work.

Good design exposes a small, clear interface and hides implementation details.

### Abstraction

Abstraction means working at the right level of detail and suppressing lower-level complexity.

Example: a caller should use `fetchAreaName(latitude, longitude)` without needing to know how network requests, JSON parsing, retries, and fallback names work internally.

### Encapsulation

Encapsulation has two parts:

- Packaging: keep related data and behavior together.
- Information hiding: prevent direct access to internal details.

Good encapsulation lets code change internally without forcing callers to change.

### Class

A class defines how to create a kind of object. It specifies the object's data and behavior.

### Class-Level Members

Class-level members belong to the class rather than an individual object. In Java these are often called `static` members.

Use them carefully. Overuse can create hidden global state and make tests harder.

### Enumeration

An enumeration is a fixed set of possible values.

Use an enumeration when only a limited set of values is valid, such as:

- `LOW`, `MEDIUM`, `HIGH`
- `PENDING`, `APPROVED`, `REJECTED`
- `RESTAURANT`, `ACTIVITY`, `CUSTOM`

Enumerations make invalid values harder to represent.

### Association

An association is a long-term link between objects or classes.

Example: a `UserProfile` may be associated with many `UserInsertedPin` objects.

### Navigability

Navigability describes which class knows about another class.

If `MapPage` holds a `PinService`, then `MapPage` can navigate to `PinService`. That does not automatically mean `PinService` should know about `MapPage`.

### Multiplicity

Multiplicity describes how many objects may participate in an association.

Common values:

- `0..1`: optional, zero or one.
- `1`: exactly one.
- `*`: zero or more.
- `n..m`: between `n` and `m`.

### Dependency

A dependency is a temporary use relationship, not a long-term association.

Example: a method receives a formatter object as a parameter, uses it, and does not store it.

### Inheritance

Inheritance lets a subclass reuse and specialize behavior from a superclass.

Use inheritance when the subclass truly is substitutable for the superclass. Do not use inheritance only to share code.

### Polymorphism

Polymorphism allows code to use a common interface while different implementations provide different behavior.

Example: `Command.execute()` can run `AddCommand`, `DeleteCommand`, or `ListCommand` without the caller knowing the concrete command type.

## 3. Requirements

A software requirement specifies a need that the product must fulfill.

### Functional Requirement

A functional requirement describes what the system should do.

Example: "The app allows a user to add a pin to the map."

### Non-Functional Requirement

A non-functional requirement describes constraints or qualities under which the system operates.

Examples:

- Performance: "Search results should appear within two seconds."
- Reliability: "Saved pins should persist after app restart."
- Security: "Users can only access their own private data."
- Usability: "A new user can complete onboarding without help."
- Maintainability: "New pin types can be added without rewriting map rendering."
- Portability: "The app runs on both Android and iOS."

### Qualities of Good Requirements

Good individual requirements should be:

- Unambiguous.
- Testable or verifiable.
- Clear and concise.
- Correct.
- Understandable.
- Feasible.
- Independent.
- Atomic, meaning not divisible into smaller requirements.
- Necessary.
- Implementation-free.

The complete requirement set should be:

- Consistent.
- Non-redundant.
- Complete enough for the current stage.

### Requirement Prioritization

Requirements should be prioritized because time, budget, and people are limited.

Possible priority schemes:

- Must-have, should-have, could-have, will-not-have.
- Essential, typical, novel.
- High, medium, low.

### User Story

A user story describes value from a stakeholder's point of view.

Format:

```text
As a <user type>, I want <goal>, so that <benefit>.
```

Example:

```text
As a traveler, I want to save interesting places on a map, so that I can revisit them later.
```

### Use Case

A use case describes interactions between an actor and the system to achieve a goal.

Use cases are useful for:

- Clarifying behavior.
- Finding missing requirements.
- Designing system tests.
- Communicating user flows.

Avoid unnecessary user interface details in use cases unless the user interface is the requirement.

### Supplementary Requirements

Supplementary requirements capture requirements that do not fit cleanly into user stories or use cases, especially non-functional requirements.

### Glossary

A glossary defines important domain terms so that stakeholders and developers use the same language.

## 4. Software Design

Software design is the activity of deciding how the system should be structured to satisfy requirements.

### External Design

External design describes what users see and experience.

Examples:

- Features.
- User interface behavior.
- User workflows.
- Error messages.

### Internal Design

Internal design describes how the software is structured internally.

Examples:

- Components.
- Classes.
- Data models.
- APIs.
- Storage format.
- Error handling.

### Modeling

Modeling means creating simplified representations of a system.

Use models to:

- Think through design before coding.
- Communicate structure and behavior.
- Document important decisions.
- Find gaps or contradictions.

### Domain Model

A domain model represents real-world concepts in the problem domain.

It should focus on domain entities and relationships, not technical implementation details.

Good domain concepts:

- User.
- Place.
- Pin.
- Review.
- Friendship.

Technical details that usually do not belong in a domain model:

- Database client.
- HTTP request.
- JSON parser.
- Screen widget.

### Multi-Level Design

Large systems should be described at multiple levels.

Example levels:

- System architecture.
- Component design.
- Class design.
- Method-level logic.

Start broad, then drill down.

### Top-Down Design

Top-down design starts with the high-level structure and fills in details later.

Useful when:

- The system is large.
- The architecture must be stable.
- Multiple people need a shared direction.

### Bottom-Up Design

Bottom-up design starts with low-level components and assembles them into larger structures.

Useful when:

- Reusing existing components.
- Extending an existing system.
- Prototyping from known technical building blocks.

### Agile Design

Agile design avoids excessive upfront detail. It starts with enough architecture and modeling to proceed, then evolves as requirements and understanding improve.

The design should emerge intentionally, not accidentally.

## 5. Architecture

Software architecture is the high-level organization of a system: its major components, relationships, and design constraints.

### Layered or N-Tier Architecture

In layered architecture, higher layers use services from lower layers. Lower layers should not depend on higher layers.

Typical layers:

- User interface layer.
- Application or business logic layer.
- Data access layer.
- Storage or external service layer.

Benefits:

- Clear separation of concerns.
- Lower coupling.
- Easier testing.
- Easier replacement of lower-level details.

### Client-Server Architecture

Clients request services from servers.

Examples:

- Mobile app calls Supabase.
- Browser calls a web API.
- Frontend calls backend service.

### Service-Oriented Architecture

Service-Oriented Architecture (SOA) builds systems by combining independently accessible services.

Benefits:

- Services can be reused.
- Systems can be built from services written in different technologies.
- External organizations can expose services to each other.

### Event-Driven Architecture

Event-driven architecture uses events to control flow. Event emitters publish events, and event consumers react.

Common examples:

- Button clicked.
- Auth state changed.
- Location changed.
- Timer completed.

Benefits:

- Components do not need to constantly poll for changes.
- Publishers and subscribers can be loosely coupled.

## 6. Software Design Patterns

A design pattern is a reusable solution to a recurring design problem in a specific context.

### Singleton Pattern

Purpose: ensure a class has only one shared instance.

Typical implementation:

- Private constructor.
- Private class-level variable for the single instance.
- Public accessor method.

Benefits:

- Easy access to shared instance.
- Prevents accidental duplicate instances.

Costs:

- Acts like global state.
- Increases coupling.
- Makes tests harder because replacement with stubs or mocks is difficult.
- State can leak between tests.

Use only when multiple instances would cause real problems.

### Facade Pattern

Purpose: provide a simple interface over a complex subsystem.

Benefits:

- Callers do not need to know subsystem details.
- Reduces coupling.
- Makes code easier to read.

Example:

`GeocodingService.fetchAreaName()` can hide HTTP calls, API keys, response parsing, error handling, and fallback logic.

### Command Pattern

Purpose: represent an action as an object.

Useful when:

- Commands need to be queued.
- Commands need to be undone or redone.
- Different commands should be executed through the same interface.

Typical interface:

```text
Command
- execute()
```

Concrete commands:

- `AddCommand`.
- `DeleteCommand`.
- `ListCommand`.

### Model-View-Controller Pattern

Model-View-Controller (MVC) separates:

- Model: stores and maintains data.
- View: displays data and interacts with the user.
- Controller: handles user actions and coordinates changes.

Benefits:

- Reduces coupling between data and presentation.
- Makes user interface code easier to change.
- Keeps business logic out of visual rendering code.

### Observer Pattern

Purpose: notify interested objects when another object changes, without tightly coupling them.

Roles:

- Observable: object being observed.
- Observer: object that wants updates.

Typical flow:

1. Observer subscribes to observable.
2. Observable changes.
3. Observable notifies all observers.
4. Observers update themselves.

Example: an authentication state stream notifies the application when the user signs in or signs out.

## 7. Code Quality

Code quality is mostly about making code easy to understand, change, test, and reuse.

### Readability

Readable code is easier to maintain because developers spend more time reading code than writing it.

Guidelines:

- Keep methods short.
- Avoid deep nesting.
- Avoid complicated expressions.
- Use clear names.
- Use constants instead of magic literals.
- Keep code structure logical.
- Make control flow obvious.

### Short Methods

Long methods are harder to understand and test.

A method should usually do one clear thing.

If a method grows too large, consider:

- Extracting helper methods.
- Splitting responsibilities.
- Moving logic to a more appropriate class.

### Avoid Deep Nesting

Deep nesting makes code hard to scan.

Prefer guard clauses when they make the normal path clearer.

Example:

```dart
if (!isSignedIn) {
  return;
}

loadUserData();
```

### Avoid Complicated Expressions

Break complicated expressions into named intermediate values.

Example:

```dart
final isOwner = pin.userId == currentUserId;
final canEdit = isOwner && !pin.isArchived;
```

### Avoid Magic Literals

A magic literal is a number or string whose meaning is not obvious.

Prefer named constants.

Example:

```dart
const maxRating = 5;
```

### Single Level of Abstraction Principle

Single Level of Abstraction Principle (SLAP) means each method should contain statements at roughly the same abstraction level.

Bad:

- High-level workflow.
- Raw database query.
- String parsing.
- User interface update.

All mixed in one method.

Better:

- Method describes workflow.
- Helper methods handle low-level details.

### Keep It Simple, Stupid Principle

Keep It Simple, Stupid (KISS) means prefer simple solutions over clever ones.

Simple code is easier to review, debug, test, and change.

### Avoid Premature Optimization

Do not make code complex for hypothetical performance gains.

Better flow:

1. Make it work.
2. Make it correct and readable.
3. Measure performance.
4. Optimize only where needed.

### Follow Coding Standards

Coding standards make a codebase feel consistent.

Benefits:

- Less time spent debating style.
- Easier reviews.
- Easier onboarding.
- Less visual noise.

### Naming

Names should reveal intent.

Guidelines:

- Use nouns for classes and variables.
- Use verbs for methods that perform actions.
- Avoid misleading names.
- Avoid names that differ only slightly.
- Use standard words consistently.
- Do not abbreviate unless the abbreviation is widely known in the project.
- If an abbreviation is used in documentation, write the full form first.

### Avoid Unsafe Shortcuts

Avoid:

- Reusing variables for unrelated purposes.
- Modifying parameters unexpectedly.
- Empty `catch` blocks.
- Dead code.
- Overly broad variable scope.
- Duplicate rules or duplicated knowledge.

### Comments

Good code should explain the how. Comments should explain the what or why.

Use comments for:

- Public behavior contracts.
- Non-obvious rationale.
- External constraints.
- Important assumptions.

Avoid comments that merely repeat the code.

## 8. Refactoring

Refactoring improves internal structure without changing external behavior.

Refactoring is not:

- Rewriting from scratch.
- Fixing a bug.
- Adding a feature.

Benefits:

- Makes code easier to understand.
- Makes future changes safer.
- Can reveal hidden bugs.
- Can improve testability.

Common refactorings:

- Extract Method.
- Inline Method.
- Decompose Conditional.
- Consolidate Duplicate Conditional Fragments.
- Replace Magic Literal.
- Replace Nested Conditional with Guard Clauses.
- Split Loop.
- Split Temporary Variable.
- Rename Method, Variable, or Class.

Important rule: run regression tests after each small refactoring step.

## 9. Documentation

Documentation should help the reader do a job.

### Types of Developer Documentation

Developer-as-user documentation explains how to use a component.

Examples:

- Application Programming Interface (API) reference.
- Tutorials.
- How-to guides.

Developer-as-maintainer documentation explains how the system is designed, implemented, tested, and evolved.

Examples:

- Architecture overview.
- Design rationale.
- Component interaction diagrams.
- Testing strategy.

### Four Documentation Modes

Useful documentation can be split into:

- Tutorial: learning-oriented.
- How-to guide: task-oriented.
- Explanation: understanding-oriented.
- Reference: information-oriented.

### Documentation Guidelines

- Write top-down.
- Start with the big picture.
- Drill into details only when needed.
- Use diagrams for structure and interactions.
- Keep documentation close to the code when possible.
- Use text-based formats such as Markdown or PlantUML when version control matters.

## 10. Error Handling and Defensive Programming

### Exception

An exception represents an unusual situation that disrupts normal control flow.

Use exceptions for exceptional cases, not routine branching.

### Assertion

An assertion documents an assumption that should always be true if the code is correct.

Assertion failure usually means there is a bug.

### Logging

Logging records useful runtime information for debugging and monitoring.

Good logs help answer:

- What happened?
- When did it happen?
- Which input or state caused it?
- Which component was involved?

### Defensive Programming

Defensive programming means writing code that prevents or limits damage from incorrect use.

Examples:

- Validate inputs.
- Reject invalid state early.
- Return defensive copies for mutable internal data.
- Enforce required associations.
- Fail clearly when assumptions are violated.

Use defensive programming where the risk justifies the overhead.

## 11. Integration, Build Automation, and Reuse

### Integration

Integration is the process of combining software parts and making sure they work together.

Avoid big-bang integration, where all parts are integrated late. It creates a large debugging search space.

Prefer incremental integration:

- Integrate small pieces frequently.
- Test after each integration.
- Find interaction bugs early.

### Walking Skeleton

A walking skeleton is a minimal end-to-end version of the system.

It may have tiny features, but it exercises the full technical path.

Example:

- User interface opens.
- App calls service.
- Service returns data.
- Data appears on screen.

### Build Automation

Build automation uses tools to automate tasks such as:

- Compiling.
- Testing.
- Packaging.
- Dependency management.
- Deployment.

### Continuous Integration

Continuous Integration (CI) means building, integrating, and testing automatically after code changes.

Benefits:

- Finds integration problems early.
- Keeps the main branch healthier.
- Makes regression testing regular.

### Continuous Deployment

Continuous Deployment (CD) extends Continuous Integration by automatically deploying changes after passing checks.

### Reuse

Reuse means using existing code, libraries, frameworks, platforms, or services.

Benefits:

- Saves time.
- Uses tested components.
- Can improve reliability.

Costs and risks:

- Dependency may be too large or complex.
- Dependency may be unstable.
- Dependency may become unmaintained.
- License may be unsuitable.
- Security vulnerabilities may be introduced.
- Performance may suffer.

### Library

A library is code that your code calls.

### Framework

A framework calls your code. This is known as inversion of control.

## 12. Quality Assurance

Quality Assurance (QA) is the process of ensuring that software has the required level of quality.

Quality Assurance includes:

- Testing.
- Static analysis.
- Code reviews.
- Formal verification in critical systems.

### Validation

Validation asks: are we building the right system?

It checks whether requirements match user needs.

### Verification

Verification asks: are we building the system right?

It checks whether the implementation satisfies the requirements.

### Static Analysis

Static analysis checks code without running it.

It can detect:

- Style violations.
- Unused variables.
- Possible null errors.
- Possible memory leaks.
- Suspicious code patterns.

### Code Review

Code review is systematic examination of code by humans.

It helps find:

- Bugs.
- Missing tests.
- Bad design.
- Code quality problems.
- Inconsistent style.
- Risky changes.

Review methods:

- Pull request review.
- Pair programming.
- Formal inspection.

## 13. Testing

Testing executes software to find defects and build confidence.

### Developer Testing

Developer testing is testing performed by developers.

It should happen early because bugs are cheaper to fix when found early.

### Unit Testing

Unit testing checks a small unit in isolation.

Common units:

- Method.
- Class.
- Component.
- Service.

Unit tests should isolate the Software Under Test (SUT) from dependencies.

### Software Under Test

Software Under Test (SUT) means the part currently being tested.

### Test Double

A test double replaces a real dependency during testing.

Common test doubles:

- Stub: simple replacement with hard-coded responses.
- Mock: replacement that verifies expected interactions.
- Fake: working simplified implementation.
- Dummy: object passed only because a parameter is required.
- Spy: records how it was used.

### Integration Testing

Integration testing checks whether components work together correctly.

It is especially useful for finding bugs in:

- Glue code.
- Data flow.
- Misunderstood contracts.
- API boundaries.

### System Testing

System testing checks the complete integrated system against system requirements.

### Acceptance Testing

Acceptance testing checks whether the system satisfies stakeholder expectations.

### Alpha Testing

Alpha testing uses selected users under controlled conditions.

### Beta Testing

Beta testing uses selected real users in a more natural environment.

### Regression Testing

Regression testing checks that previously working behavior still works after changes.

It is most useful when automated and run frequently.

### Test Automation

Automated tests can be run programmatically and pass or fail programmatically.

Benefits:

- Reduces repeated manual effort.
- Improves precision.
- Supports frequent regression testing.
- Enables Continuous Integration.

### Graphical User Interface Testing

Graphical User Interface (GUI) testing is harder than Application Programming Interface (API) testing because:

- Many user operations can happen in many orders.
- Visual state can vary across devices.
- Automation is harder.

Good practice: move as much logic as possible out of the Graphical User Interface so it can be tested through stable Application Programming Interfaces.

### Test Coverage

Test coverage measures how much code or behavior is exercised by tests.

Common coverage types:

- Function or method coverage.
- Statement coverage.
- Decision or branch coverage.
- Condition coverage.
- Path coverage.
- Entry and exit coverage.

Coverage is useful, but high coverage does not guarantee high test quality.

## 14. Test Case Design

Good testing should be efficient and effective.

Efficient means finding more bugs with less testing effort.

Effective means finding the important bugs that matter.

### Black-Box Testing

Black-box testing designs test cases from external behavior and specifications, without looking at implementation.

### White-Box Testing

White-box testing designs test cases using implementation knowledge.

### Gray-Box Testing

Gray-box testing uses some implementation knowledge while still focusing mainly on external behavior.

### Equivalence Partitioning

Equivalence Partitioning (EP) groups inputs that are likely to be handled in the same way.

Example for `isValidMonth(month)`:

- Below valid range: `month <= 0`.
- Valid range: `1 <= month <= 12`.
- Above valid range: `month >= 13`.

Benefits:

- Avoids redundant tests.
- Helps ensure every meaningful input group is tested.

### Boundary Value Analysis

Boundary Value Analysis (BVA) tests values at and near boundaries because bugs often occur there.

For valid month `1..12`, useful boundary values include:

- `0`, `1`, `2`.
- `11`, `12`, `13`.

### Combining Test Inputs

When multiple inputs exist, testing every combination may be too expensive.

Strategies:

- All combinations: strongest but most expensive.
- Each valid input at least once: cheaper but weaker.
- Pairwise combinations: every pair of input choices appears at least once.

### Invalid Input Heuristic

Avoid putting many invalid inputs in one test case.

Reason: one invalid input can prevent later inputs from being processed, hiding bugs.

Prefer one invalid input per negative test case unless there is a reason to combine them.

### Scripted Testing

Scripted testing follows predefined test cases.

Benefits:

- Repeatable.
- Good for regression.
- Easy to document.

### Exploratory Testing

Exploratory testing designs and runs tests while learning about the system.

Benefits:

- Good for discovering unexpected issues.
- Useful when specifications are incomplete.
- Complements scripted testing.

## 15. Project Management and Collaboration

### Revision Control

Revision control tracks changes over time.

It records:

- What changed.
- Who changed it.
- When it changed.
- Why it changed.

Benefits:

- History.
- Collaboration.
- Recovery from mistakes.
- Branching and merging.
- Conflict resolution.

### Git

Git is a distributed revision control system.

Common concepts:

- Repository: stores project history.
- Working directory: current files.
- Commit: snapshot of changes.
- Branch: independent line of development.
- Merge: combine branches.
- Conflict: incompatible changes that need human resolution.
- Pull request: proposed change for review before merge.

### Project Planning

Project planning includes:

- Estimating effort.
- Scheduling tasks.
- Identifying milestones.
- Managing risks.
- Tracking progress.

Plans should be updated as new information appears.

### Team Structures

Common structures:

- Democratic or egoless team: shared ownership and collective decisions.
- Chief programmer team: strong technical lead coordinates work.
- Strict hierarchy team: clear reporting and task ownership.

The best structure depends on project size, complexity, team experience, and communication cost.

## 16. Software Development Life Cycle Process Models

Software Development Life Cycle (SDLC) describes stages such as requirements, analysis, design, implementation, testing, and deployment.

### Waterfall Model

The waterfall model is sequential. Each stage is completed before the next begins.

Works best when:

- Requirements are stable.
- Problem is well understood.
- Change is unlikely.

Main weakness: real-world requirements often change.

### Iterative and Incremental Model

Iterative and incremental development delivers the product in repeated cycles.

Each iteration may include:

- Requirements refinement.
- Design.
- Implementation.
- Testing.
- Feedback.

Benefits:

- Working software appears earlier.
- Feedback improves later iterations.
- Risk is discovered sooner.

### Breadth-First Iteration

Breadth-first iteration evolves many major components together.

Example: implement one complete feature across user interface, logic, and storage.

### Depth-First Iteration

Depth-first iteration focuses on fleshing out specific components.

Example: build backend support for a feature before the user interface is ready.

### Agile Models

Agile models emphasize:

- Individuals and interactions.
- Working software.
- Customer collaboration.
- Responding to change.

Agile development usually uses:

- Prioritized requirements.
- Evolving design.
- Frequent feedback.
- Transparency.
- Shared team responsibility.

### Extreme Programming

Extreme Programming (XP) emphasizes:

- Communication.
- Simplicity.
- Feedback.
- Respect.
- Courage.

Practices may include:

- Pair programming.
- Test-first development.
- Continuous integration.
- Simple design.
- Frequent releases.

### Scrum

Scrum organizes work into fixed-length iterations called sprints.

Common roles:

- Product Owner: represents stakeholders and prioritizes product work.
- Scrum Master: supports the process and removes obstacles.
- Development Team: builds the product.

Common artifacts:

- Product backlog.
- Sprint backlog.
- Product increment.

Common events:

- Sprint planning.
- Daily scrum.
- Sprint review.
- Sprint retrospective.

## 17. Core Software Engineering Principles

### Separation of Concerns Principle

Separation of Concerns (SoC) means separating code into distinct parts, each handling a separate concern.

Examples of concerns:

- User interface.
- Authentication.
- Location permissions.
- Data persistence.
- Business rules.
- Security.

Benefits:

- Reduces functional overlap.
- Limits ripple effects when changes happen.
- Improves cohesion.
- Reduces coupling.

One-line test:

```text
Is each concern in its own clear place?
```

### Coupling

Coupling measures how much one component depends on another.

Low coupling is good because it improves:

- Maintainability.
- Testability.
- Reusability.
- Integration flexibility.

High coupling is risky because:

- A change in one module can break others.
- Testing in isolation becomes harder.
- Integration becomes more complex.
- Reuse becomes less practical.

One-line test:

```text
If this component changes, how many other components must change too?
```

### Cohesion

Cohesion measures how strongly related the responsibilities of a component are.

High cohesion is good because:

- The component has a clear purpose.
- Code is easier to understand.
- Changes are more localized.
- Reuse is easier.

Low cohesion is risky because:

- A component changes for unrelated reasons.
- The component is hard to name clearly.
- Behavior is scattered or tangled.

One-line test:

```text
Does everything here belong together?
```

### Single Responsibility Principle

Single Responsibility Principle (SRP) means a class should have one reason to change.

Example violation:

A `TextUi` class both parses commands and formats output. It changes when command syntax changes and when user interface formatting changes.

Better:

- `CommandParser` handles parsing.
- `TextUi` handles user interaction.

One-line test:

```text
What single responsibility would I write in this class's job description?
```

### Open-Closed Principle

Open-Closed Principle (OCP) means a module should be open for extension but closed for modification.

In other words, you should be able to add behavior without editing stable existing code.

Example:

Add a new `Command` subclass instead of editing a large `switch` statement every time a new command is introduced.

Benefits:

- Lower regression risk.
- Better reuse.
- Cleaner extension points.

One-line test:

```text
Can I add a new case by adding code, rather than modifying working code?
```

### Liskov Substitution Principle

Liskov Substitution Principle (LSP) means objects of a subclass must be usable wherever objects of the superclass are expected.

A subclass violates this principle if it strengthens restrictions or breaks the superclass contract.

Example:

If `Rectangle.resize(height, width)` accepts different height and width values, a `Square` subclass that rejects unequal values is not safely substitutable.

One-line test:

```text
Can callers use the subclass without knowing it is not the superclass?
```

### Interface Segregation Principle

Interface Segregation Principle (ISP) means clients should not be forced to depend on methods they do not use.

Better to have smaller focused interfaces than one large general interface.

Example:

If payroll only needs salary behavior, it should depend on `SalariedStaff`, not a larger `AdminStaff` class that also includes unrelated meeting behavior.

One-line test:

```text
Does this caller depend only on the methods it actually needs?
```

### Dependency Inversion Principle

Dependency Inversion Principle (DIP) means:

- High-level modules should not depend on low-level modules.
- Both should depend on abstractions.
- Abstractions should not depend on details.
- Details should depend on abstractions.

Example:

`Payroll` should depend on a `Payee` interface, not directly on a concrete `Employee` class.

Benefits:

- More flexible design.
- Easier testing.
- Easier replacement of implementation details.

One-line test:

```text
Does important policy code depend on abstractions instead of concrete details?
```

### Do Not Repeat Yourself Principle

Do Not Repeat Yourself (DRY) means every piece of knowledge should have a single, authoritative representation.

This is not only about identical code. It is about duplicated knowledge.

Example:

If the maximum rating is `5`, define it once. Do not scatter `5` across validation, user interface labels, database checks, and tests without a shared meaning.

Caution:

Do not merge code just because it looks similar. If two snippets represent different concepts that may change independently, keep them separate.

One-line test:

```text
If this rule changes, is there only one place to update?
```

### Law of Demeter

Law of Demeter (LoD), also called the Principle of Least Knowledge, says an object should only talk to closely related objects.

A method should usually call methods on:

- Itself.
- Its parameters.
- Objects it creates.
- Objects it directly owns.

Avoid reaching through chains of objects.

Bad shape:

```text
user.getProfile().getAddress().getPostalCode()
```

Better shape:

```text
user.getPostalCode()
```

One-line test:

```text
Am I asking my collaborator to do work, or am I digging through its internals?
```

## 18. Unified Checklist

Use this checklist when reviewing code or design.

### Requirements

- Are the requirements clear and testable?
- Are non-functional requirements captured?
- Are requirements prioritized?
- Are user stories tied to real user value?

### Design

- Are responsibilities separated?
- Is the architecture understandable?
- Are dependencies flowing in a clean direction?
- Are abstractions useful rather than decorative?
- Are design patterns solving real recurring problems?

### Code Quality

- Are names clear?
- Are methods short and focused?
- Is nesting controlled?
- Are magic literals removed?
- Is duplication avoided without forcing false abstraction?
- Are comments explaining why, not repeating how?

### Testing

- Are important equivalence partitions covered?
- Are boundary values tested?
- Are unit tests isolated?
- Are integration points tested?
- Are regression tests automated?
- Is high-risk behavior tested more deeply?

### Maintainability

- Can this change be localized?
- Can this component be tested in isolation?
- Can this component be reused?
- Can a new developer understand the design from code and docs?

### Collaboration

- Are changes small enough to review?
- Is version control history meaningful?
- Are pull requests focused?
- Are code reviews checking behavior, design, tests, and readability?

