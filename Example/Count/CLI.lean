/- Copyright 2026 Department of Code LLC.
   SPDX-License-Identifier: AGPL-3.0-or-later -/

/-
# Example.Count.CLI

The command-line entry point, mirroring the F* template's CLI module: `main`
runs the byte-count scan over a fixed byte string and returns a process exit
status — `0` when the count matches the expected value, `1` otherwise.

In Lean there is no Pulse/global-array leaf, so the input is a plain
`List UInt8` and `main` exercises `countAcc` through the C-extraction + link
pipeline.
-/

import Example.Count

/-- The fixed byte string under test. -/
def bytes : List UInt8 := [0, 1, 0, 2, 0, 1, 0]

/-- `main` — count `0` in the fixed `bytes` (expect `4`) and exit `0`/`1`. -/
def main : IO UInt32 := do
  let n := Example.Count.countAcc (0 : UInt8) bytes 0
  let expected : Nat := 4
  IO.println s!"countAcc 0 {bytes} = {n}"
  if n == expected then
    IO.println "count: found expected count 4"
    return 0
  else
    return 1
