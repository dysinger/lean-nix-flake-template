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
  `sorry`)" true. Until `codec-audit-round-three` §2.2.1 it was **absent**, so the
  claim was false for every project scaffolded from this template — and the flag
  belongs on the *library* so each is fixed by construction. Do not remove it. -/
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
