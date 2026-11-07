# AGENTS.md

Guidance for AI coding agents working in a repository scaffolded from
`lean-nix-flake-template`. **A fork starts without this file; `basen` and `codec`
both have one, and this is the short version of theirs.** Replace the borrow-check
notes below with your own project's once you know what your codecs do.

## What this repo is

A Nix flake project: `nix develop` gives you a pinned `lean`/`lake`/`elan` +
`clang`, and `lake build` is the proof gate. The template ships one worked example
(`Example/Count`) and a CLI; it ships **no** codecs, so nothing here is in the
axiom gate until you add it.

## Non-negotiables (they are enforced, not advisory)

1. **Zero `sorry`.** `lakefile.lean`'s library carries
   `moreLeanArgs := #["-DwarningAsError=true"]`, so `sorry`'s warning is an
   **error** and `lake build` exits non-zero naming the declaration. Do not remove
   that line, and do not "temporarily" stub a theorem to `sorry` to get green —
   the build is where that stops. (If a proof will not compile, stub **that one
   theorem** deliberately and fix it next; never `git stash`/`git reset`/
   `git checkout -- <file>` to "start clean", which has destroyed verified work in
   these repos.)
2. **The axiom discipline.** Every law should be provable from `[propext,
Quot.sound]` only — never `Classical.choice`, never `native_decide`, never
   `sorryAx`. `#print axioms <name>` is the check; it is **not** machine-enforced
   in the template, so run it per law family. `native_decide` is fine in a bench
   lane and never in the library.
3. **Commit individual files, never `git add -A`.** Print
   `git diff --cached --name-only` before each commit. A pre-commit hook runs
   `nix fmt` and **rejects** the commit if it reformats a staged file; re-`git add`
   and commit again — that is normal, not a failure.
4. **`flake.lock` is tracked; `lake-manifest.json` is not.** The lock is the only
   reproducibility anchor. **The "only git-tracked files are visible" rule holds for
   the flake path specifically.** `default.nix`'s `src = ./.` is reached both ways,
   but `./.` means different things: through the flake it is the **git tree snapshot**
   in the Nix store, so a new `.c`/data file must be committed or `nix build .#…`
   will not see it; through a bare `nix-build` / `import ./default.nix` it is the
   **whole directory**, untracked files included. The unqualified sentence was
   therefore false for the second path (`codec-audit-round-six` R7-30).

## The two-layer trust posture

- **Layer 1** is the proved Lean: spec, decoder, encoder, and their laws. This is
  the only layer an axiom gate can see.
- **Layer 2** is any `@[extern]` / C seam. It is a **named runtime trust
  contract**, excluded from the gate by construction. `#print axioms` on a seam
  reports "no axioms" **because** `@[extern]` swaps only the emitted C — the kernel
  sees the Lean body. **"No axiom" is never "no trust."**
- **All format logic is pure Lean.** C is only generic bulk byte movement
  (`memcpy`/`memchr` shapes). **No per-format C, no C that parses digits, numbers,
  fields, or format structure.** A hand-written C parser used as a _benchmark
  yardstick_ is bench-only, has no `@[extern]`, and is not in the gate.

## Verification, and what each command actually proves

```bash
nix develop --command lake build          # the proof gate: zero sorry/warnings
```

- **This template ships no bench lane.** `default.nix` here has no `bench` package
  and `lakefile.lean` has no `bench` target, so an instruction to run
  `lake build bench` would name machinery a fork does not have
  (`codec-audit-round-six` R7-30). The paragraph that used to sit here described
  `default.nix`'s `bench` `installPhase` — that is `../lean-basen`'s derivation, not
  this one, and it is reproduced here only as guidance: **if** you add a lane whose
  checks value-compare known vectors, keep it a **package**, never a `checks` entry,
  because a value check is evidence, not proof and must not be able to fail the proof
  gate. Note that in `basen` those checks fire at _build_ time (`rfl` and
  `native_decide` both elaborate), so building the lane is what runs them.
- `nix flake check` is a **per-repo** command. Do not assume the parent project's
  checks set applies.
- `lake build` printing `Replayed` after you edited an imported module means it is
  reading a stale `.olean`. Delete the offending `.olean` (or `rm -rf .lake`) before
  believing a green result. A **segfault** right after a toolchain bump usually
  means the same stale-state problem — clean before diagnosing.
- `lean-toolchain` is effectively **inert** in these repos; nothing reads it. Check
  `lake build -v` for the toolchain actually in use.

## Cross-repo dependencies

A sibling repo is a **flake input** threaded into `default.nix`, which rewrites
`require <dep> from git …` into a local path dependency, so the sandboxed build
needs no network. Consequences:

- A `bad import '<Dep>.<Module>'` from a **sandboxed** build usually means the
  flake input's pin predates that module. Check the lock's rev against that repo's
  `git log --oneline -1 -- <Module file>`, then bump **targeted**
  (`nix flake update <dep>`, never all inputs) and re-gate. **Never "fix" it by
  editing the importing Lean file.**
- Quote the pinned revision from `flake.lock`, never from prose. Numbers written in
  documentation rot; the lock does not.

## Documentation discipline (this is where most defects have been)

- **A completeness claim must come from an environment walk, never `grep '^def'`.**
  A grep misses multi-line signatures and cannot see through an alias, and the
  sentence built on it then reads as an enumeration it is not.
- **A `Prop`-valued structure field is not a law.** `Iso.law`-shaped projections
  assert nothing beyond the type a caller supplies. Classify them uniformly or not
  at all.
- **A gate is only as strong as its narrowest unaudited step.** When you add a
  check, ask what removes things from _its_ input, and whether that removal is
  recorded. A name-based classifier that drops a declaration silently is the
  recurring defect in this ecosystem; give the classifier an allowlist **with
  reasons**, and audit the pattern list itself.
- **Never subtract two committed performance figures from different sessions.**
  Quote the table, name the run. Several defects of exactly this shape are on
  record.
- **A stated count of a sanctioned-but-ungated construct must be asserted by a
  build-time check**, or the prose deleted. It will drift silently otherwise,
  because the gate it escapes is not looking.

## Planning

These repos use **OpenSpec** (`openspec/`): a change is planned as
proposal/specs/design/tasks before it is implemented, and `tasks.md` is the ledger.
`[x]` means "in the tree AND evidence recorded in the ledger" — never tick on
intent, and never leave a finished task unticked. Re-derive state from
`openspec list --json`, not from prose.
