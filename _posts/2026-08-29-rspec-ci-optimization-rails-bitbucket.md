---
layout: post
title: "Cutting Rails RSpec CI from 12–14 Minutes to Under 4—Without Removing Tests"
date: 2026-08-29
updated: 2026-08-29
author: Max Lukin
tags: [rails, rspec, ci-cd, bitbucket-pipelines, testing, performance, parallel-tests, factory-bot, test-prof]
categories: [engineering, rails, testing, devops]
description: "A measurement-driven Rails RSpec case study: runtime-balanced workers, safe fixture reduction, PostgreSQL template databases, and CI guardrails cut a growing Bitbucket pipeline to under four minutes without weakening coverage."
---

> **Public-example note:** domain objects, endpoints, and factories in this
> article use fictional MMORPG terminology. The timings, techniques, and
> engineering conclusions come from a real optimization session.

## TL;DR

A growing Rails API suite had reached 12–14 minutes in day-to-day CI. This was
not a single bug or one terrible spec; it was the accumulated cost of new
features, factories, contracts, database setup, and increasingly uneven worker
loads.

We approached it as a controlled performance investigation:

- froze the test selection before changing scheduling;
- measured pipeline, command, worker, file, factory, and SQL time separately;
- distributed files by measured runtime, not filename or file size;
- used six Unit workers and eight Integration workers after end-to-end A/B tests;
- folded 317 extended contracts into existing parallel capacity;
- prepared the Rails test schema once and cloned worker databases in under one second;
- ran RSwag's metadata-only work without a database and overlapped it with quality checks;
- removed only fixtures and side effects proven unrelated to the behavior under test;
- rejected changes when the expensive work was the contract itself.

The controlled Bitbucket baseline fell from **7m09 to 3m51 (-46.2%)**. In the
final accepted run, all **14,688 tests passed**, the documented pending count
did not grow, and five new guard examples had been added.

No test, assertion, production behavior, API contract, authorization rule, or
business rule was removed.

## Metrics at a Glance

| Metric | Before | After | Result |
| --- | ---: | ---: | ---: |
| Historically observed CI | 12–14 min | 3m51 final run | About 68–73% shorter; directional because runner conditions differed |
| Controlled Bitbucket baseline | 7m09 | 3m51 | **-3m18 / -46.2%** |
| Complete automated selection | 14,683 | 14,688 | **+5 guard examples** |
| Local fast + extended RSpec phase | 224.60s | 157.65s | **-29.8%** |
| Extended-contract selection | 114.66s | 44.74s | **-61.0%** |
| World-bootstrap contracts | 108.99–134.89s | 42.95s | **-60.6% to -68.2%** |
| Integration worker A/B | 59.94s at 6 workers | 50.17s at 8 | **-16.3%** |
| Worker database preparation | 6.10–9.57s | 0.91s | **-85.1% to -90.5%** |
| Sequential quality/RSwag lane | 4m17 | 3m13 | **-64s / -24.9%** |
| Runtime timing coverage | Partial fast-only data | 1,274 / 1,277 files | **99.8% measured** |
| Unit worker tail spread | 49.0s | 15.5s | **-68.4%** |

These numbers belong to one repository and one CI environment. The reusable
result is the method, not a promise that every Rails suite will reach the same
duration.

## 1. Purpose and Constraints

The purpose was simple: restore fast engineering feedback while the product and
its test base continued to grow.

Slow verification also changes engineering behavior. It encourages larger
commits, delayed checks, and more risk per feedback cycle. As AI-assisted
development makes patches faster to produce, trustworthy verification becomes
the bottleneck: generating more changes helps only when they can be proved
quickly.

The constraints were more important than the target:

1. no removed specs or assertions;
2. no increased pending or skipped count;
3. no production/API/business-logic changes;
4. no broad callback or provider stubbing just to gain speed;
5. no retries that could hide a failed first attempt;
6. no test file could disappear between CI partitions.

A faster suite with weaker contracts is not an optimization. It is deferred
risk.

## 2. Correct the Mental Model First

Several ideas in the original version of this article sounded reasonable but
did not survive measurement.

### RSwag was not executing requests twice

`rswag:specs:swaggerize` invokes RSpec in dry-run mode. It loads and discovers
request metadata, then writes OpenAPI output; it does not perform every request
again.

The useful question was therefore not “How do we remove duplicate tests?” It
was “Where can metadata loading run without extending the critical path?”

### File size and `let!` counts were only clues

A 1,000-line spec can be cheap. A 100-line spec can trigger thousands of SQL
events, callbacks, hashes, and factory cascades.

Likewise, `let!` can be wasteful, or it can be the exact precondition the test
needs. We ranked by measured runtime and traced fixture usage before editing.

### More workers were not automatically better

Workers add Rails boot, database setup, memory pressure, and scheduler overhead.
Six, seven, and eight Unit workers had almost identical end-to-end time, even
though eight made raw RSpec execution faster. Six was retained as the stable
point.

### One wall-clock number was not enough

One run gained roughly 53 seconds of provider-side startup delay while its
executed commands remained healthy. We separated:

| Layer | Question |
| --- | --- |
| Pipeline | What controls merge feedback time? |
| Step | Which parallel lane is the critical path? |
| Command | Is time spent installing, booting, preparing databases, scanning, or testing? |
| Worker | Is one shard keeping the other workers idle? |
| Spec file/example | Which behavioral area is expensive? |
| Setup internals | Is the cost factories, SQL, callbacks, crypto, time, or external boundaries? |

## 3. Freeze Coverage Before Changing Scheduling

The final suite had:

- **1,277 executable spec files**;
- **14,371 fast examples**;
- **317 extended examples**;
- **14,688 complete examples**;
- **four documented pending examples**, unchanged throughout the work.

A repository checker parsed the CI configuration and failed if:

- a spec file was unowned or selected more than once;
- Unit and Integration filters stopped being complementary;
- extended contracts became excluded or sequential again;
- live-external contracts entered ordinary CI;
- RSwag ran zero times or more than once;
- worker counts or database preparation drifted;
- timing-map coverage fell below 99%.

The final check reported **1,277 files covered exactly once**.

This guard was foundational. Without it, a faster pipeline could simply be a
pipeline running less work.

## 4. Use Runtime-Balanced Workers

The final Bitbucket pipeline had three parallel lanes:

~~~text
Pipeline wall time = the slowest lane, not the sum

├── Lint, Security & Swagger
├── Unit, Model & Extended Contracts   (6 workers)
└── Integration & Request Contracts    (8 workers)
~~~

The two database-backed lanes also used `parallel_tests`:

~~~bash
bundle exec parallel_rspec \
  -n "$PARALLEL_TEST_PROCESSORS" \
  --group-by runtime \
  --runtime-log config/ci/rspec_runtime.log \
  --allowed-missing 10 \
  -o '--tag ~live_external --fail-fast --format progress' \
  spec/models spec/policies spec/services
~~~

### Why keep a 1,274-line timing file?

`config/ci/rspec_runtime.log` is generated scheduling data, not hand-maintained
code. Each row maps a spec file to its measured runtime:

~~~text
spec/requests/api/v1/guilds/quests_spec.rb:7.733
spec/requests/api/v1/arenas_spec.rb:6.655
spec/services/arena/access/concurrency_spec.rb:3.941
~~~

The map reduced the slowest-worker spread from **49.0 seconds to 15.5 seconds**.
Only three live-external or zero-example files remained estimated.

We refreshed it from green fast and extended runs after material suite changes.
Failed or partial runs were not allowed to overwrite trusted timing data.

Could we store only the slow files? Yes. In this suite the full generated map
was small, deterministic, and measurably useful. Replacing it with an external
timing service or ephemeral cache would add more failure modes than it removed.

### Fill idle capacity before buying more capacity

The 317 extended contracts originally ran sequentially after Unit. Five prepared
workers sat idle.

Moving the same selection into the existing six-worker command reduced that
group from **114.66s to 44.74s**. Coverage did not change; scheduling did.

### A/B worker counts end to end

| Partition | Measurement | Decision |
| --- | --- | --- |
| Unit | 6, 7, and 8 workers had effectively equal preparation + execution time | Keep 6 |
| Integration | 59.94s at 6 workers vs 50.17s at 8, same 5,522 examples | Use 8 |

Do not choose worker count from raw RSpec time alone. Include process boot,
database preparation, memory pressure, and the slowest shard.

## 5. Prepare the Database Once

Parallel workers need isolated databases. Replaying the Rails schema for every
worker took **6.10–9.57 seconds**.

The improved flow was:

1. run canonical `db:prepare` once for the unsuffixed test databases;
2. let that Rails process close its connections;
3. clone primary and queue databases for workers 2–N using PostgreSQL templates;
4. start RSpec only after every clone succeeds.

~~~bash
export RAILS_ENV=test

time bin/rails db:prepare
time ruby bin/ci_clone_test_databases "$PARALLEL_TEST_PROCESSORS"
time bundle exec parallel_rspec ...
~~~

Cold cloning for eight workers took **0.91 seconds**.

Because the helper drops and recreates databases, it had narrow safety checks:

- `RAILS_ENV` must equal `test`;
- worker count must be between 1 and 16;
- source names are fixed test-only names;
- target names are derived worker suffixes;
- optional namespaces allow only letters, digits, and underscores;
- credentials remain in environment variables;
- any command failure fails the step.

This technique is PostgreSQL-specific. The rollback trigger was repeated
template contention or stale-schema evidence.

## 6. Schedule RSwag as Metadata Work

RSwag discovered **5,522 request examples**. It did not need a live database,
but Rails boot still attempted schema maintenance.

We skipped that check only for dry-run metadata collection:

~~~ruby
unless RSpec.configuration.dry_run?
  begin
    ActiveRecord::Migration.maintain_test_schema!
  rescue ActiveRecord::PendingMigrationError => e
    abort e.to_s.strip
  end
end
~~~

Every executable RSpec process still checked schema currency.

The proof used an intentionally unreachable PostgreSQL port:

- 5,522 examples discovered;
- zero failures;
- two already-documented pending examples;
- byte-identical generated OpenAPI output.

The local dry run took **3.53s**, but CI spent **50.08s**, including **35.99s**
loading files and less than one second in dry-run execution. That difference
was a useful lesson: optimize on the target runner, not from local intuition.

### Overlap independent checks, but wait for both

Sequential RuboCop, Brakeman, dependency audit, and RSwag made the quality lane
the 4m17 critical path. The runner had two cores, and the two groups were
independent, so we overlapped them while preserving both exit statuses:

~~~bash
(bundle exec rubocop &&
 bundle exec brakeman -q -w2 &&
 bundle exec bundle audit check --update) &
quality_pid=$!

(bundle exec rails rswag:specs:swaggerize) &
swagger_pid=$!

quality_status=0
swagger_status=0
wait "$quality_pid" || quality_status=$?
wait "$swagger_pid" || swagger_status=$?

test "$quality_status" -eq 0
test "$swagger_status" -eq 0
~~~

The lane fell from **4m17 to 3m13**. No check was removed or made optional.

## 7. Diagnose Slow Specs Without Weakening Them

A slow file tells you where to look, not what to change.

The most productive question was often:

> What did this example create that it never used?

We combined several views:

~~~bash
# Slow examples
bundle exec rspec spec/requests/api/v1/arenas_spec.rb --profile 10

# Factory cascades
FPROF=1 bundle exec rspec spec/requests/api/v1/arenas_spec.rb

# SQL volume by example
EVENT_PROF=sql.active_record EVENT_PROF_EXAMPLES=1 \
  bundle exec rspec spec/requests/api/v1/arenas_spec.rb

# Custom FactoryBot notification summary
FACTORY_PROF=1 bundle exec rspec spec/requests/api/v1/arenas_spec.rb
~~~

For each hotspot we recorded:

1. hypothesis;
2. exact focused command and random seed;
3. examples, failures, and pending count;
4. factory count and cumulative factory time;
5. SQL event count;
6. narrow proposed change;
7. after measurement;
8. accept, reject, or defer decision;
9. rollback trigger.

### Remove only proven setup waste

Setup strategy followed the behavior being proved:

| Behavior under test | Safe default |
| --- | --- |
| Pure predicate or serialization | Plain object or `build_stubbed` |
| Immutable shared baseline | Narrow reference context or `let_it_be` |
| Mutation, callback, uniqueness, scope, lock, or transaction | Persisted per-example records |

Useful techniques included:

- convert `let!` to `let` only when a real parameter, header, subject, or
  assertion already triggers the dependency;
- use `let_it_be(..., refind: true)` only for immutable, rollback-safe baselines;
- remove a duplicate Character only after proving the factory already creates
  the real Character used by the subject;
- disable an unrelated initial Oracle synchronization while retaining real
  commits, locks, callbacks, threads, state transitions, and reloads;
- consolidate repeated Rails seed setup while keeping independent assertions;
- load only the required World Catalog slice in app specs while separate
  world-bootstrap contracts prove the complete seed behavior;
- replace wall-clock sleeps with a scoped deterministic clock when time is only
  an input;
- move a pure combinatorial property to its owning unit layer while retaining a
  persisted integration proof.

### Representative measured improvements

| Fictionalized area | Before | After | What stayed real |
| --- | ---: | ---: | --- |
| Arena requests, 104 examples | 928 factories / 19,692 SQL events | 586 / 16,549 | Requests, auth, persistence, ordering, serialization |
| Party Chat, 96 examples | 362 factories / 16,712 SQL events | 172 / 12,772 | Rooms, members, messages, assertions |
| Matchmaking search, 119 examples | 712 factories / 9.37s | 616 / 8.41s | Independent filters and currencies |
| Arena effect processor, 12 examples | 110 factories / 4.93s | 99 / 3.93s | State transitions and recovery |
| Arena concurrency, 8 examples | 1.728s factory time / 4.38s | 0.768s / 3.77s | Commits, locks, callbacks, threads, reloads |
| World-bootstrap contracts, 277 examples | 108.99–134.89s | 42.95s | Real seed repair and all assertions |
| Character Portrait property | 28.76s combined | 6.10s | Unit property plus 20 persisted integration records |

### Keep behavior-bearing cost

One 24-example transaction-callback hotspot took 7.03s, but factories accounted
for only 0.919s. Real commits, rollbacks, locks, and thread ordering were the
contract, so we left it unchanged.

That is a successful profiling result. “Do not optimize this” is often the
correct conclusion.

## 8. Quality and Stability Guardrails

Every accepted performance change had to preserve:

| Guardrail | Evidence |
| --- | --- |
| Selection | 14,683 examples before → 14,688 after |
| Failures | Zero in complete local and CI gates |
| Pending | Four documented fast-suite pending examples, unchanged |
| Order safety | Randomized runs and multiple focused seeds |
| Schema safety | Checked in every executable RSpec process |
| OpenAPI contract | Byte-identical output in the database-free proof |
| Network isolation | Ordinary specs default-denied real outbound requests |
| Failure visibility | Per-worker JUnit and JSON metadata retained |
| Product surface | No application/API/business-logic changes |

The final local gate included RuboCop, fast and extended RSpec, Brakeman,
dependency audit, RSwag generation, and a real seed replant. Each accepted
stage was then checked in Bitbucket, ending with the 3m51 complete run.

## 9. Lessons from Rejected Ideas

The rejected hypotheses were as useful as the accepted ones:

| Idea | Measurement | Lesson |
| --- | --- | --- |
| Raise the CI timeout | Added safety margin but removed no work | Headroom is useful; it is not an optimization |
| Use 7–8 Unit workers | Raw RSpec improved; end-to-end time stayed flat | Include setup in worker A/B tests |
| Lazily load support files | 29 files loaded in 11.5ms | Do not create hidden dependencies to save milliseconds |
| Optimize transaction specs through factories | Factory work was only 0.919s of 7.03s | Preserve real transactional behavior |
| Broadly stub callbacks/providers | Would change what request/concurrency specs proved | Faster is not better if the contract changes |
| Split large files for scheduler cosmetics | Worker tail was already balanced | File splitting needs a measured indivisible tail |
| Add another Integration CI step | Could help wall time but duplicates bootstrap cost | Spend more CI capacity only for an explicit target |
| Build a custom CI image immediately | Warm install time was already short | Add ownership only when setup repeatedly dominates |
| Optimize from local Brakeman timing | Local reached 205s; CI was roughly 25–34s | Use target-environment evidence |
| Assume local RSwag timing applied to CI | 3.53s locally vs 50.08s in CI | Measure boot/load cost on the runner |
| Eliminate fixture disk I/O first | Factories, SQL, seeds, and scheduling were larger costs | Treat generic best practices as hypotheses |

## 10. Pipeline Evolution

The result was iterative, and restoring quality temporarily made the suite
slower before it became faster:

| Checkpoint | Wall time | Main lesson |
| --- | ---: | --- |
| Historically observed growth | 12–14 min | Cost accumulated across many features |
| Controlled baseline | 7m09 | Integration was the critical path |
| Runtime-balanced checkpoint | 4m13 | Measured file timing worked |
| Coverage-recovery checkpoint | 7m13 | Restored world-bootstrap contracts had real cost and had to remain |
| Sequential extended contracts | 5m02 | Prepared workers were idle |
| Cold-cache combined selection | 5m19 | Fast-only timing data caused a 2m44 worker tail |
| Merged fast/extended timing map | 3m46 | Worker spread fell from 49.0s to 15.5s |
| Provider-skewed sample | 4m41 | Startup delay must be separated from executed work |
| Template DB + sequential quality lane | 4m18 | Database cloning worked; quality became critical |
| Concurrent quality/RSwag acceptance | **3m51** | Same checks; all 14,688 tests passed |

Final lane timings:

~~~text
Lint, Security & Swagger  3m13
Unit + Extended            3m51  (9,166 tests)
Integration                3m26  (5,522 tests)
Overall                    3m51  (14,688 tests)
~~~

The important result is not only “7m09 to 3m51.” The final suite was also
larger: five guard examples were added and recovered contracts remained active.

## 11. A Reusable Playbook

1. **Freeze selection.** Record files, examples, pending, tags, and partition ownership.
2. **Collect comparable samples.** Keep commit, seed, workers, cache state, and runner size.
3. **Measure in layers.** Separate startup, commands, shards, files, factories, and SQL.
4. **Rank by runtime.** File size and `let!` counts are review signals only.
5. **Write one narrow hypothesis.** Define before/after evidence and a rollback trigger.
6. **Preserve behavior.** Remove only unused setup; retain real boundaries and integration proofs.
7. **A/B topology end to end.** Include process boot and database setup.
8. **Fill idle capacity.** Reschedule existing work before adding runners or steps.
9. **Guard the accepted architecture.** Make coverage and scheduling invariants executable.
10. **Stop when evidence weakens.** Maintenance cost and test quality matter more than a vanity target.

### Practical maintenance triggers

Refresh the runtime map after material suite growth, a new extended-contract
group, timing coverage below 99%, or repeated worker spread above 30 seconds.

Reopen CI optimization after two consecutive runs above the agreed executed-work
budget—not after one provider-skewed sample.

## Key Takeaways

- **Measure before editing.** A slow file is a location, not a diagnosis.
- **Preserve exact selection.** Speed must not come from running fewer tests.
- **Use measured runtime for scheduling.** The generated timing map earned its size.
- **A/B worker counts end to end.** More processes can be slower.
- **Prepare once, clone safely.** Repeated schema setup was removable work.
- **Understand dry-run tooling.** RSwag loaded metadata; it did not repeat request behavior.
- **Measure factories and SQL together.** Counts without context can mislead.
- **Keep expensive contracts real.** Transactions, locks, callbacks, and seed repair may be the test.
- **Record rejected ideas.** They prevent risky or unproductive work from returning.

The headline is a 46.2% controlled CI reduction. The engineering achievement is
that the suite became faster **without becoming smaller or less trustworthy**.

## Resources

- [parallel_tests](https://github.com/grosser/parallel_tests)
- [TestProf](https://test-prof.evilmartians.io/)
- [RSpec documentation](https://rspec.info/documentation/)
- [RSwag](https://github.com/rswag/rswag)
- [FactoryBot](https://github.com/thoughtbot/factory_bot)
- [Bitbucket Pipelines documentation](https://support.atlassian.com/bitbucket-cloud/docs/get-started-with-bitbucket-pipelines/)
- [PostgreSQL `createdb`](https://www.postgresql.org/docs/current/app-createdb.html)

---

*This article describes a real Rails RSpec optimization session using sanitized
MMORPG examples. The measurements belong to one suite and one CI environment;
the investigation and validation method is the portable result.*
