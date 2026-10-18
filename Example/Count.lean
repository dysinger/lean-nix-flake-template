/- Copyright 2026 Department of Code LLC.
   SPDX-License-Identifier: AGPL-3.0-or-later -/

/-
# Example.Count

The pure algorithm layer of the template's example: counting a byte's
occurrences with a tail-recursive accumulator scan, plus the correctness
theorem that the accumulator version equals the spec `count`.  This is the
analog of the F* template's pure algorithm module — a total function with a
*proved* correspondence to the spec, in a few lines.

There is no Pulse leaf (Lean 4 has no Pulse/`#lang-pulse`); the extractable leaf
is the `cli` executable's C-extraction seam.
-/

import Example.Count.Types

namespace Example.Count

open Example.Count.Types

/-- `countAcc b xs acc` — count occurrences of `b` in `xs`, carrying the
running total `acc` (tail-recursive). -/
def countAcc (b : UInt8) : List UInt8 → Nat → Nat
  | [], acc => acc
  | x :: xs, acc => countAcc b xs (if x = b then acc + 1 else acc)

/-- The tail-recursive accumulator equals `acc + count b xs`. -/
theorem countAcc_eq (b : UInt8) (xs : List UInt8) (acc : Nat) :
    countAcc b xs acc = acc + count b xs := by
  induction xs generalizing acc with
  | nil => rfl
  | cons x xs ih =>
    simp [countAcc, count]
    by_cases h : x = b
    · simp [h, ih]
      omega
    · simp [h, ih]

/-- `countAcc` from zero is exactly the spec `count`. -/
theorem countAcc_eq_count (b : UInt8) (xs : List UInt8) :
    countAcc b xs 0 = count b xs := by
  simpa using countAcc_eq b xs 0

end Example.Count
