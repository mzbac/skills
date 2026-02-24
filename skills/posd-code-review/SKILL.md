---
name: posd-code-review
description: >
  Review a codebase, directory, or PR diff using John Ousterhout’s “A Philosophy of Software Design”
  principles. Use when the user wants design/maintainability feedback: complexity (dependencies/obscurity),
  deep modules, information hiding/leakage, interface design (common case), layering, error-handling strategy,
  comments and naming/obviousness. Do NOT use for formatting-only or lint-only requests, or when the user is
  explicitly asking for performance benchmarking, a pure security audit, or purely stylistic rewrites.
---

# POSD Code Review Skill

## Goal
Produce a review that reduces *software complexity* by:
- Identifying **dependencies** and **obscurity**.
- Mapping findings to symptoms: **change amplification**, **cognitive load**, and **unknown unknowns**.
- Proposing refactors that create **deep modules**, strengthen **information hiding**, and make **interfaces**
  simpler for the most common use cases.
- Offering practical, incremental improvements (“small investments”), not a wholesale rewrite.

## Inputs (infer if missing)
- **Scope**: PR diff / commit range / paths / whole repo.
- **Constraints**: backwards compatibility, “no behavior change”, deadlines, style guides, API stability.
- **Audience**: maintainers vs new contributors (affects how much explanation to include).

If scope is ambiguous, default to: **review the touched area + immediate neighbors (callers/callees)**.

## Operating mode
- Default to **read-only review**: do not edit files unless asked.
- Use evidence: cite file paths, symbols, and concrete examples.
- Prefer small, staged refactors that can be landed safely.

---

## Workflow

### Step 0 — Build a quick mental model
1. Identify the system’s main responsibilities and “shape”:
   - Key entrypoints, main services/packages, public APIs, domain layer, IO boundaries.
2. Identify the primary modules/components and their interfaces:
   - What does each module *promise*?
   - What does the caller have to know (including “informal” constraints)?

### Step 1 — Find complexity hotspots (evidence-driven)
Pick 3–10 candidate hotspots based on:
- High churn / frequently changed files
- High fan-in (many callers) or fan-out (many dependencies)
- Lots of conditionals/special cases
- Repeated logic across modules
- High “setup tax” to use an API (many parameters, flags, ordering rules)

Suggested commands (optional, adapt to repo/tooling):
- `git status`, `git diff`, `git log --stat`
- `rg -n "TODO|FIXME|HACK|workaround"`
- `rg -n "throws | catch | Exception | Result<|Either<|panic!|unwrap\\("`
- Language-specific: `eslint`, `ruff`, `golangci-lint`, `mvn test`, etc. (only if requested/appropriate)

### Step 2 — Review using POSD lenses (checklists below)
For each hotspot/module, analyze:
- What complexity does it remove for callers?
- What complexity does it *push outward*?
- Where is knowledge duplicated across modules?

### Step 3 — “Design it twice” for top issues
For the top 2–3 most impactful findings:
- Provide **two alternative designs**.
- Pick one and justify why it reduces overall complexity.

### Step 4 — Produce an actionable report
Use the output template below. Prioritize issues that:
- Reduce change amplification across multiple files
- Reduce cognitive load for common tasks
- Eliminate unknown unknowns by improving interfaces/docs
- Shrink exception surface area

---

## POSD Review Checklists

### A) Complexity (dependencies + obscurity)
**Look for:**
- Call chains that require reading multiple files to understand one change.
- Implicit ordering constraints (“call A before B”).
- Hidden invariants (only “known” by tribal knowledge).
- Names that don’t reveal intent; missing “why” documentation.

**Fix strategies:**
- Pull related knowledge into one module.
- Make invariants explicit in interfaces and comments.
- Replace “temporal coupling” with data-driven or capability-based APIs.

### B) Deep modules vs shallow modules
**Shallow module signals:**
- Big/complex interface for little functionality.
- Wrappers that mostly forward calls (“pass-through” methods).
- Many tiny classes that add interfaces without hiding complexity.

**Deep module goals:**
- Small, stable interface; substantial internal work hidden behind it.
- Callers can use the module without understanding its internals.

**Fix strategies:**
- Merge overly-fragmented modules when they share knowledge.
- Replace multiple special-purpose methods with one general-purpose method + simple parameters.
- Move complexity *into* the module if it simplifies the caller.

### C) Information hiding & information leakage
**Leakage signals:**
- Same file format / protocol / validation rules implemented in multiple modules.
- Duplicated constants, field names, parsing rules.
- Two modules that must be changed together for one “design decision”.

**Fix strategies:**
- Consolidate the “knowledge” into one module.
- Introduce a focused module that owns the leaking decision.
- Remove getters that expose internal structures; offer intention-revealing methods instead.

### D) Interfaces designed for the common case
**Look for:**
- APIs that require rare options to be understood to do common tasks (“overexposure”).
- Too many parameters / flags / configuration knobs.
- Interfaces that “punt” hard cases to the caller.

**Fix strategies:**
- Provide good defaults.
- Replace flag soups with a smaller number of cohesive operations.
- Make common-case code short and obvious; move uncommon complexity behind optional APIs.

### E) Layering: different layers, different abstractions
**Look for:**
- Upper layers duplicating lower-layer APIs.
- Pass-through methods/variables across multiple layers.
- Decorator stacks that multiply shallow interfaces.

**Fix strategies:**
- Collapse layers that don’t add a distinct abstraction.
- Reassign responsibilities so each layer adds real value.
- Expose lower-level APIs directly when the upper layer adds no abstraction.

### F) Error handling: reduce exception surface area
**Look for:**
- Defensive “throw everywhere” patterns.
- Exceptions that callers can’t realistically handle.
- Many special-case checks scattered across the codebase.
- Exception-handling branches that are untested/unreachable.

**Fix strategies:**
- **Define errors out of existence** by changing semantics so the “error” cannot occur (or becomes normal behavior).
- **Mask/collapse** related failures into fewer handling sites.
- If an error is unrecoverable, prefer a clear “panic/fail fast” boundary rather than half-handling everywhere.
- Before introducing a new error/exception: describe exactly how the caller will handle it.

### G) Comments & documentation (abstraction + non-obvious info)
**Look for:**
- Public methods without an interface/contract comment.
- Comments that restate code (noise).
- Missing “why” on non-obvious algorithms, invariants, or tricky edge cases.
- Implementation details leaking into interface docs (wrong abstraction level).

**Fix strategies:**
- Add header/interface comments that define the contract.
- Add “why” comments for non-obvious design decisions.
- Remove comments that merely repeat code and refactor code to be more obvious.

### H) Naming, consistency, obviousness
**Look for:**
- Vague names; “hard to name” entities that likely hide an unclear abstraction.
- Local inconsistencies (same concept named differently across files).
- Non-obvious code where the reader must simulate mentally to understand.

**Fix strategies:**
- Rename to encode intent and invariants.
- Align naming and patterns within a subsystem.
- Rewrite small sections for clarity; prefer readability over cleverness.

---

## Output template (required)

### Executive summary
- 3–7 bullets: biggest complexity drivers, where they show up, what to do next.

### Scorecard (0–5)
Rate each area briefly with 1–2 sentences:
- Deep modules
- Information hiding/leakage
- Interface common-case usability
- Layering/abstraction boundaries
- Error handling strategy
- Comments/contracts
- Naming/consistency/obviousness

### Findings (prioritized)
For each finding:
1. **Title** (short)
2. **Principle violated** (e.g., information leakage, shallow module, overexposure)
3. **Evidence** (files/symbols; concrete snippet description)
4. **Impact**
   - Change amplification? Cognitive load? Unknown unknowns?
5. **Recommendation**
   - Smallest safe change first
6. **Design-it-twice alternatives** (required for top 2–3 findings)
7. **Risk & test plan**
   - What to verify; what tests to add/run

### Suggested investment plan
- Quick wins (small refactors/docs)
- Medium refactors (module/interface reshaping)
- Long-term (architecture boundary shifts)

---

## Quality bar
- Prefer fewer, deeper findings over a long list of nits.
- Every recommendation must reduce overall complexity for future changes.
- If you claim something is “complex”, explain what it forces readers/callers to know.
