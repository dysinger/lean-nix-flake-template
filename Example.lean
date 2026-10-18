/- Copyright 2026 Department of Code LLC.
   SPDX-License-Identifier: AGPL-3.0-or-later -/

/-
# Example

A minimal, verified Lean 4 library skeleton.  This root module aggregates the
library's components — a small byte-counting example that mirrors the F*
template's three-layer shape (pure spec / pure algorithm / CLI entry), minus
the Pulse leaf (Lean 4 has no Pulse/`#lang-pulse`):

  * `Example.Count.Types` — the pure spec (`count` + its base-case lemma)
  * `Example.Count`       — the pure algorithm (`countAcc`) with a proved
    correspondence to the spec

See `Example.Count.CLI` for the executable that runs the algorithm, and the
repository `README.md` for the build workflow and the "Renaming" guide.
-/

import Example.Count.Types
import Example.Count
