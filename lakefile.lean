import Lake
open Lake DSL
open System

/- Copyright 2026 Department of Code LLC.
   SPDX-License-Identifier: AGPL-3.0-or-later -/

package demo

@[default_target]
lean_lib demo where
  roots := #[`Example]
  /- The proof gate, made real. `lake build` only *warns* on `sorry`
  (`declaration uses 'sorry'`), so a plain build goes green with an incomplete
  proof. `-DwarningAsError=true` promotes that warning to an error, making the
  **compiler** the authority instead of a parallel `sorry` lint that could drift
  (`admit`, a tactic-generated `sorryAx`, ...).

  This line is what makes this README's "a build that encounters a `sorry` fails"
  (`:50`) and `default.nix`'s "the Lean proof-validation gate (`lake build` with no
  `sorry`)" true. **It was absent before 2026-11-06**, so the claim was false for
  every project scaffolded from this template until then; the flag belongs on the
  *library* so each project is fixed by construction. (The finding was recorded in
  the sibling `lean-codec` repo's `codec-audit-round-three` ledger §2.2.1 — cited
  here only as provenance; a fork cannot resolve that repo, which is why the
  sentence is self-contained.) Do not remove it. -/
  moreLeanArgs := #["-DwarningAsError=true"]

/-- The packaged command-line executable: `Example.Count.CLI.main`.  Mirrors
the F* template's `cli` deliverable (deliverable-named, not a `bench`).

`@[default_target]` is load-bearing, not cosmetic: `default.nix`'s `check` runs a
bare `lake build`, which builds the *default* targets only. Without this an
unproven `sorry` in `Example/Count/CLI.lean` would be invisible to `checks.lean`
and surface only under `nix build .#cli` — so the gate would be narrower than
"the build fails on `sorry`" implies. (`Example.lean` also imports the CLI
module, so the library build reaches it even if this is ever dropped.) -/
@[default_target]
lean_exe cli where
  root := `Example.Count.CLI
