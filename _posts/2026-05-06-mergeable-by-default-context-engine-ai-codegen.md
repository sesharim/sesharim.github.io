---
layout: post
title: "Mergeable by Default: Why AI Coding Needs a Context Engine, Not Just a Bigger Model"
date: 2026-05-06
author: Max Lukin
tags: [ai, software-engineering, context-engineering, agents, codegen, verification, productivity]
categories: [engineering, AI, software-engineering]
description: "A practical engineering take on the AI Engineer talk 'Mergeable by default: Building the context engine to save time and tokens' — why useful AI coding is less about generation and more about project context, team conventions, verification, and drift control."
---

> _"The hard part is no longer getting AI to generate code. The hard part is getting AI to generate code that belongs in your system."_

## TL;DR

AI coding tools are getting better, but most teams still lose time because generated code is only **almost right**.

The useful target is not:

> AI writes code.

The useful target is:

> AI writes code that is **mergeable by default**.

That requires a **context engine**: a reasoning layer that knows your codebase, conventions, previous decisions, permissions, docs, tests, ownership, and current task — then gives the agent only the context it actually needs.

This is the practical point from the talk:

- bigger context windows are not enough
- naive RAG is not enough
- random MCP servers are not enough
- code search alone is not enough
- AI without context creates review debt
- AI with the right context can reduce token cost, review cycles, and rework

For my own Rails / API / AI-assisted workflow, this maps almost directly to:

- `AGENTS.md`
- `PROMPT.md`
- `GUIDE.md`
- `doc/requirements/**`
- Flow docs
- PRDs
- `bin/verify`
- `bin/contract_audit`
- RSpec / rswag / Pundit / Blueprinter conventions

In other words: the best AI coding system is not just a model.  
It is an engineering operating system around the model.

---

## The YouTube talk worth knowing

The video is:

[Mergeable by default: Building the context engine to save time and tokens — Peter Werry, Unblocked](https://www.youtube.com/watch?v=5ID22ACI7IM)

The core description is simple:

> Agents can generate code. The hard part is generating code that's right for your system, team conventions, and past decisions.

That line is the whole problem.

Modern coding agents can produce code fast. But fast code is not automatically useful code. If the agent does not know your real system, it creates a second job for the team:

1. pay for generation in tokens
2. pay again in review, correction, and cleanup

That is why the talk focuses on a **context engine**: the layer that decides what the agent should know before it acts.

---

## Why this matters

Most AI coding demos optimize for the wrong thing.

They show:

- a prompt
- a generated file
- a green-looking result
- a fast demo loop

But production engineering is not a demo.

Production engineering has:

- old decisions
- team conventions
- naming rules
- API contracts
- permission boundaries
- security requirements
- test expectations
- serializer rules
- migration history
- review standards
- product requirements
- half-finished work
- legacy constraints

If AI ignores those, the generated code may look good and still be wrong.

That is the dangerous part: AI often fails in ways that are plausible.

It creates code that looks like something a developer would write, but it may not match the system.

---

## The real AI coding problem

The problem is not:

> Can the model write Ruby, Go, TypeScript, or Python?

It can.

The problem is:

> Does the model know what **correct** means inside this repo?

Correct is not only syntax.

Correct means:

- the endpoint follows the existing API shape
- the response uses the right envelope
- the serializer follows the project convention
- authorization is enforced in the expected way
- search uses the expected search library
- pagination follows the standard project pattern
- tests cover the contract
- docs are updated in the right place
- generated OpenAPI is produced from specs, not edited by hand
- no new representational drift is introduced

This is where AI coding becomes an engineering systems problem.

---

## Bigger context windows do not solve this alone

It is tempting to think the solution is:

> Just give the model more context.

But bigger context is not the same as better context.

A huge context window can still contain:

- irrelevant files
- outdated docs
- conflicting instructions
- stale decisions
- too many examples
- private information the agent should not see
- similar-but-wrong patterns
- code that should not be copied

More context can even make the output worse if the agent cannot tell which source has authority.

The real need is not maximum context.

The real need is **selected, ranked, permission-aware, task-specific context**.

That is what a context engine should do.

---

## Naive RAG is also not enough

Basic RAG usually means:

1. embed documents
2. search for similar chunks
3. paste the top results into the prompt

That helps, but it is not enough for serious engineering work.

Why?

Because code work often needs reasoning across sources:

- requirement says one thing
- Flow doc says another
- current controller does a third thing
- specs define the real contract
- old PR explains why the strange behavior exists
- security policy limits what can be touched

Simple similarity search does not know which source should win.

A useful context engine needs to answer:

- which document is authoritative?
- which code path is actually active?
- which convention is current?
- which files changed recently?
- who owns this area?
- what should be excluded?
- what is relevant to this exact task?

That is different from "search and paste."

---

## MCP servers are useful, but not magic

MCP-style tool access can connect agents to more systems:

- GitHub
- Linear / Jira
- docs
- Slack
- databases
- observability
- local tools

That is useful.

But tool access is not the same as understanding.

An agent with 20 tools can still fail if it does not know:

- when to use which tool
- which result is authoritative
- what the task boundary is
- what the team convention expects
- what must not be changed
- what proof is required before completion

Tools give the agent hands.

A context engine gives the agent judgment boundaries.

---

## What a context engine should contain

A useful engineering context engine should collect and reason over several layers.

| Layer | What it answers |
| --- | --- |
| Code context | What files, services, models, controllers, serializers, tests, and configs matter? |
| Product context | What requirement, PRD, or ticket defines the behavior? |
| Architecture context | What patterns does this repo already use? |
| Convention context | What naming, response, route, and test rules must be followed? |
| Decision context | Why was this built this way before? |
| Permission context | What is the agent allowed to read or change? |
| Ownership context | Who owns the area, or what review path matters? |
| Verification context | What command proves the change is safe? |
| Drift context | What kinds of changes are forbidden even if tests pass? |

The important word is **context**, not **documents**.

The engine is not just a folder of markdown files.  
It is the system that decides what matters for the current task.

---

## What "mergeable by default" really means

"Mergeable by default" does not mean AI code is automatically merged.

It means the AI output is shaped so that the default review path is:

> verify, review, merge

Not:

> rewrite, argue with the model, fix conventions, add missing tests, update docs, clean up payload shape, then maybe merge

A mergeable-by-default change has these properties:

| Property | Meaning |
| --- | --- |
| Contract-aware | It implements the actual requirement, not a guessed version |
| Convention-aware | It follows existing repo patterns |
| Test-backed | It includes relevant tests/specs |
| Permission-safe | It does not cross access boundaries |
| Drift-safe | It does not invent new response shapes or naming styles |
| Minimal | It touches only what the task requires |
| Explainable | It can point to why files changed |
| Verifiable | One command can prove the change is safe enough to review |

This is the difference between using AI as autocomplete and using AI as a controlled engineering assistant.

---

## The review-cost problem

Bad AI code is expensive because it creates hidden work.

The obvious cost is token usage.

The bigger cost is review drag:

- reviewers must detect subtle mismatch
- developers must check every convention manually
- specs may be missing or shallow
- docs may not reflect behavior
- generated code may duplicate existing logic
- authorization may be incomplete
- migration or serializer decisions may drift

This is why the talk's "save time and tokens" framing matters.

Tokens are not the main cost.

The real cost is the human correction loop after bad context.

---

## How this maps to my Rails workflow

This topic is especially relevant to my own Rails / API workflow because I already treat AI as part of a controlled delivery system.

In my setup, the closest equivalent of a context engine is not one tool. It is the combination of:

| Piece | Role |
| --- | --- |
| `AGENTS.md` | Operating rules and delivery discipline |
| `PROMPT.md` | Task execution flow |
| `GUIDE.md` | Examples and reusable patterns |
| `doc/requirements/**` | Source of truth for behavior |
| Flow docs | Implementation traceability |
| PRDs | Product context |
| RSpec | Behavior proof |
| rswag | API contract proof |
| Pundit policies | Authorization proof |
| Blueprinter | Response-shape discipline |
| Ransack + Kaminari | Search and pagination convention |
| `bin/verify` | Fast verification loop |
| `bin/contract_audit` | Drift prevention |

This is why the talk feels immediately practical.

It says: do not just buy a smarter model.  
Build the environment where the model can make fewer wrong assumptions.

That matches my own conclusion from AI-assisted backend work:

> AI productivity comes from externalized judgment, not prompt luck.

---

## A concrete Rails example

Imagine a task:

> Add a new nested API endpoint for profile awards with file attachments.

A generic AI agent may create:

- a controller
- a model
- a serializer
- a few routes
- maybe a spec

But a context-aware agent should know much more:

- endpoints must live under `/api/v1/profiles`
- JSON must stay snake_case
- list responses must return `{ data, meta }`
- uploads should use nested attributes in one request
- Blueprinter should serialize file URLs consistently
- Pundit authorization must be represented
- request specs must include multipart create/update tests
- Ransack and Kaminari are expected for searchable/paginated endpoints
- `ransackable_attributes` must be explicit
- Flow docs must follow the existing template
- rswag specs should drive OpenAPI generation
- `bin/verify` and contract audit must pass

That is not "more code."

That is project-specific correctness.

And this is exactly the kind of correctness that generic AI does not infer reliably unless the context system teaches it.

---

## The context engine as a compiler for engineering judgment

A good way to think about this:

| Traditional compiler | AI engineering system |
| --- | --- |
| Source code | Requirements + task |
| Language spec | `AGENTS.md` / conventions |
| Type checker | Tests + contracts |
| Linter | Style / naming / route rules |
| Static analyzer | Security + drift audit |
| Build output | Mergeable PR |

The model generates the draft.

The context engine controls the environment around the draft.

That is the serious version of AI-assisted development.

---

## Important lessons from the talk

### 1. Context must be task-specific

Do not dump the whole repo into the model.

Give it the files, docs, tests, decisions, and examples that matter for the task.

### 2. Authority matters

The agent must know which source wins when sources conflict.

For example:

1. current requirement
2. current tests/specs
3. current implementation
4. older docs
5. old examples

Without authority ranking, the agent can follow stale context confidently.

### 3. Permissions matter

A production context engine must respect access boundaries.

Not every agent should see every Slack thread, customer doc, security detail, or private dataset.

### 4. Personalization matters

Two engineers may ask the same question but need different context.

A backend engineer, frontend engineer, new hire, tech lead, and reviewer should not necessarily receive the same context bundle.

### 5. Review cycles are the hidden cost

The output should be optimized for fewer review corrections, not just faster generation.

### 6. The best context system learns from real mistakes

A good context engine improves when the team discovers:

- wrong files were retrieved
- stale docs were used
- permissions were too broad
- generated code missed a convention
- tests passed but contract drift appeared

That feedback should become system behavior, not tribal memory.

---

## What is worth mentioning from the YouTube link

If I had to reduce the video into a few points worth remembering:

1. **AI codegen is already capable enough to be dangerous.**  
   The remaining problem is whether it writes code that fits the system.

2. **Wrong context creates double cost.**  
   You pay once for generation and again during review/fix cycles.

3. **Bigger context windows are not a strategy.**  
   They help, but they do not solve authority, relevance, conflict, permissions, or freshness.

4. **Naive RAG is not the final answer.**  
   Search results need reasoning and ranking, especially across code, docs, history, and decisions.

5. **MCP/tool access is only plumbing.**  
   Tools expose information; they do not decide what matters.

6. **The real product is the context engine.**  
   It is the reasoning layer between the agent and the organization.

7. **"Mergeable by default" is the practical success metric.**  
   Not "did it generate code?", but "did it reduce the path to a safe merge?"

---

## What teams usually get wrong

### They treat prompts as architecture

A prompt is not enough.

If the repo does not have clear requirements, tests, conventions, and verification gates, the prompt becomes a wish list.

### They treat docs as optional

For AI-assisted work, docs are not bureaucracy.

Docs are training material for the engineering system.

Bad docs create bad AI behavior.

### They optimize for demo speed

Demo speed is not production speed.

Production speed includes review, verification, rollback risk, onboarding, maintenance, and future changes.

### They let AI invent conventions

This is one of the fastest ways to create long-term codebase drift.

AI should follow conventions, not create a new local style every task.

### They do not separate generation from verification

Generation is cheap.

Trust is expensive.

The system must make trust cheaper.

---

## What I would build next

For my own workflow, the next practical step is to make the context engine more explicit.

Today, much of it already exists as files and scripts.

The next version should behave more like a retrieval + reasoning layer.

### 1. Task classifier

Given a task like `WEB-142 Awards`, classify:

- endpoint work
- model work
- attachment work
- docs work
- authorization work
- specs work
- swagger work

Then load relevant rules automatically.

### 2. Context bundle generator

Produce a task-specific context bundle:

```text
Task: WEB-142 Awards

Authoritative sources:
- doc/requirements/WEB-142_*.md
- related Flow doc
- related PRD if present

Relevant implementation:
- app/controllers/api/v1/profiles/...
- app/models/award.rb
- app/blueprints/...
- spec/requests/...

Rules:
- snake_case only
- Ransack + Kaminari
- Blueprinter envelope
- Pundit authorization
- nested attachments in one request
- multipart request specs
```

### 3. Drift checker expansion

Extend `bin/contract_audit` to catch more AI-specific drift:

- new response shapes outside blueprints
- missing `ransackable_attributes`
- missing multipart specs for attachable models
- missing docs section updates
- inconsistent endpoint naming
- unauthorized direct JSON rendering

### 4. Retrieval audit

Every AI-generated change should be able to answer:

- what context did it use?
- which sources were authoritative?
- which files were intentionally ignored?
- what proof command passed?
- what contract did it implement?

This would make AI output much easier to trust.

---


## Software fundamentals matter more than ever in the AI era

Another strong talk that connects directly to the "mergeable by default" idea is:

> "Software Fundamentals Matter More Than Ever"

The message is extremely important because it explains *why* many AI-assisted codebases start degrading even when teams use powerful models.

The core point is simple:

> AI amplifies the quality of the engineering system around it.

That amplification works in both directions.

| Existing engineering quality | What AI does |
| --- | --- |
| Strong architecture + conventions | Accelerates delivery |
| Weak architecture + drift | Accelerates chaos |

This is why AI adoption often produces very different outcomes between teams using similar tools.

One team gets:
- faster delivery
- cleaner onboarding
- fewer repetitive tasks
- safer iteration

Another team gets:
- more review debt
- duplicated abstractions
- inconsistent APIs
- growing architectural entropy

The difference is rarely the model itself.

The difference is usually:
- system boundaries
- naming consistency
- decomposition quality
- verification
- contracts
- maintainability discipline

---

## AI amplifies entropy if the codebase is already chaotic

One of the strongest ideas from the second talk is:

> AI makes bad codebases worse faster.

That sounds obvious, but it has major implications.

Before AI:
- weak engineering practices slowed teams down
- messy systems evolved more slowly
- architectural damage accumulated gradually

Now:
- AI can generate large amounts of plausible code very quickly
- bad patterns replicate faster
- local shortcuts spread across the repo
- inconsistent abstractions become normalized

The dangerous part is that the output often *looks* reasonable.

That creates a false sense of progress.

A weak engineering system with AI can produce:
- more code
- more PRs
- more surface area

while simultaneously reducing long-term maintainability.

This is why software fundamentals suddenly matter *more*, not less.

---

## Why Rails works unusually well with AI

This also explains why Rails often performs surprisingly well in AI-assisted development compared to fragmented stacks.

Rails strongly reduces ambiguity through conventions:

| Concern | Rails convention |
| --- | --- |
| Models | `app/models/**` |
| Controllers | `app/controllers/**` |
| Request specs | `spec/requests/**` |
| Background jobs | `app/jobs/**` |
| Serialization | predictable serializer/blueprint layer |
| Naming | convention over configuration |
| Routing | consistent REST structure |

LLMs benefit heavily from predictability.

The less time the model spends asking:
> "How is this project organized?"

the more time it spends solving the actual task.

This is one reason why convention-heavy systems become powerful AI multipliers.

---

## Decomposition becomes critical

Another important point from the second talk:

> LLMs perform much better on small, deterministic tasks than vague, giant problems.

That has major implications for engineering workflows.

Good AI-assisted systems should encourage:
- bounded contexts
- small implementation scopes
- explicit requirements
- narrow responsibilities
- isolated verification loops

This maps directly to:
- feature decomposition
- Flow docs
- PRDs
- contract-first APIs
- verification-driven development

Without decomposition, AI receives:
- too much ambiguity
- too many unrelated files
- unclear authority
- mixed responsibilities

That increases hallucination and drift.

With decomposition:
- retrieval becomes cleaner
- verification becomes cheaper
- generated code becomes more deterministic
- review becomes faster

This is another reason why a context engine matters:
it reduces entropy before generation even starts.

---

## Verification matters more than generation

One of the biggest misconceptions in AI engineering is:

> faster generation = better engineering

In reality:

> verification quality matters more than generation speed.

AI is extremely good at producing:
- plausible code
- plausible architecture
- plausible explanations

But plausible is not the same as correct.

That is why systems like:
- `bin/verify`
- contract audits
- OpenAPI contracts
- request specs
- drift prevention
- architectural rules

become increasingly important in the AI era.

The stronger the generation becomes, the more important proof becomes.

Or more simply:

> verification > generation

---

## Senior engineers become more important, not less

The second talk also indirectly explains why strong senior engineers become *more* valuable in AI-assisted environments.

Junior engineers with AI can generate large amounts of code quickly.

But senior engineers contribute something different:
- architectural judgment
- decomposition
- boundary design
- tradeoff analysis
- drift detection
- maintainability intuition
- verification discipline

AI accelerates implementation.

Senior engineers define:
- what should exist
- what should not exist
- what should remain stable
- what correctness means

This is why the real leverage comes from:
- externalized engineering judgment
- codified conventions
- reusable verification systems
- structured context

Not from prompt tricks.

---

## The combined lesson from both talks

The two talks together point toward the same conclusion.

The future of AI-assisted engineering is not:
- bigger prompts
- more vibe coding
- infinite context dumping
- raw generation speed

The future is:
- explicit context systems
- deterministic workflows
- engineering conventions
- retrieval quality
- decomposition
- verification
- drift prevention
- mergeability

The model matters.

But the surrounding engineering operating system matters even more.



## Context retrieval is not enough without meaning

One of the most important missing ideas in many AI engineering discussions is this:

> retrieval alone does not explain system meaning.

A vector database can retrieve:
- files
- specs
- migrations
- tickets
- controllers
- docs

But retrieval alone does not explain:
- business semantics
- conceptual relationships
- authority hierarchy
- intent boundaries
- domain meaning
- organizational language

This is where conceptual modeling becomes critical for AI systems.

A useful phrase from recent discussions is:

> "Conceptual modeling is the context engineering nobody is doing."

That idea changes how we should think about AI-assisted engineering.

---

## Storage is not the same as meaning

Database schemas primarily describe storage.

Conceptual models describe meaning.

For example, a database may contain:

```sql
users
companies
recruiters
contracts
```

But the semantic/business layer explains things like:

- recruiter users must belong to verified non-agency companies
- contracts only apply to certain organization types
- some users are prospects while others are active customers
- access states affect workflow permissions
- ownership and approval rules differ across flows

The AI model often cannot infer those rules reliably from tables alone.

Without semantic structure:
- retrieval returns conflicting interpretations
- agents make incorrect assumptions
- local correctness breaks global meaning
- teams accumulate semantic drift

---

## Semantic drift is becoming a new category of engineering failure

One especially important idea is:

> code can technically work while system meaning is already broken.

This is semantic drift.

Examples:
- endpoint contracts technically pass, but business terminology changed
- authorization still works, but ownership semantics changed
- response structures remain valid, but workflow meaning shifted
- entities serialize correctly, but relationships no longer reflect reality

Traditional verification usually catches:
- syntax problems
- test failures
- runtime errors

But semantic drift is harder.

The system still compiles.
The tests may still pass.

Yet the business meaning has already degraded.

AI systems make this problem more important because they replicate patterns rapidly.

---

## Metadata suddenly became AI infrastructure

A surprising shift happening across the industry is that many metadata concepts are suddenly becoming foundational AI infrastructure.

Things like:
- glossaries
- ontologies
- semantic layers
- ownership metadata
- conceptual models
- lineage systems
- business vocabularies

are turning into:

> navigation systems for AI reasoning.

This is one reason why many data and metadata teams are suddenly becoming highly relevant to AI engineering workflows.

---

## The next stage of context engines

The first generation of AI engineering systems focused mostly on:
- code retrieval
- embeddings
- vector search
- file access
- larger context windows

The next stage is likely semantic-aware systems.

Instead of only asking:
> "Which files are relevant?"

the system will increasingly ask:
> "What does this system actually mean?"

A semantic-aware context system can explain:
- why a concept exists
- how concepts relate
- which definitions are authoritative
- which workflows matter
- which constraints are organizational vs technical
- what should remain stable across implementations

That is a much deeper level of context than code search alone.

---

## How this maps to my current workflow

Looking at my own Rails/API workflow, I already externalized a large amount of engineering judgment through:
- AGENTS.md
- Flow docs
- PRDs
- requirements
- verification systems
- contract audits

But conceptual modeling adds another important layer:

| Existing layer | Role |
| --- | --- |
| Requirements | behavioral intent |
| Flow docs | implementation semantics |
| AGENTS.md | engineering rules |
| Verification | correctness proof |
| Conceptual modeling | business meaning |

This changes the shape of the system.

It stops being only:
> an engineering operating system

and starts becoming:
> a semantic operating system for AI-assisted engineering.


## The final takeaway

The future of AI coding is not just smarter code generation.

It is better engineering context.

The best teams will not only ask:

> Which model should we use?

They will ask:

> What system makes the model correct inside our codebase?

That system will include:

- requirements
- conventions
- code search
- decision history
- permission control
- task-specific retrieval
- verification
- drift prevention
- review feedback loops

That is the real lesson from "Mergeable by default."

AI does not become valuable because it writes more code.

AI becomes valuable when the surrounding engineering system makes its output **safe enough, relevant enough, and consistent enough** to merge.

For me, that means the next stage of AI-assisted Rails development is clear:

> turn the existing verification-driven workflow into an explicit context engine.

Not more prompt magic.  
Not bigger context for the sake of bigger context.  
Not vibe-coded PRs.

A system that gives the agent the right context, blocks the wrong drift, proves the result, and makes the final state boring:

> all good — merge PR.

---

## References

- [Mergeable by default: Building the context engine to save time and tokens — YouTube](https://www.youtube.com/watch?v=5ID22ACI7IM)
- [AI Engineer Europe 2026 schedule](https://www.ai.engineer/europe/schedule)
- [Daily.dev listing for the talk](https://app.daily.dev/posts/mergeable-by-default-building-the-context-engine-to-save-time-and-tokens-peter-werry-unblocked-pmhqjsuzp)
