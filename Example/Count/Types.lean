/- Copyright 2026 Department of Code LLC.
   SPDX-License-Identifier: AGPL-3.0-or-later -/

/-
# Example.Count.Types

The pure spec for the template's example: counting how often a byte value
occurs in a byte string.  This mirrors the F* template's pure-spec layer — a
typed notion (`count`) with its base-case lemma — over `UInt8` (the codec
substrate's element type), so the example stays adjacent to the `codec` domain
rather than using an unrelated arithmetic toy.

There is no state and no extraction-relevant code here.
-/

namespace Example.Count.Types

/-- `count b xs` — the number of occurrences of byte `b` in the byte string
`xs`. -/
def count (b : UInt8) : List UInt8 → Nat
  | [] => 0
  | x :: xs => (if x = b then 1 else 0) + count b xs

/-- `count` of the empty string is zero (the base case). -/
theorem lemma_count_empty (b : UInt8) : count b [] = 0 := by
  rfl

end Example.Count.Types
