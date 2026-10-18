import Lake
open Lake DSL
open System

/- Copyright 2026 Department of Code LLC.
   SPDX-License-Identifier: AGPL-3.0-or-later -/

package demo

@[default_target]
lean_lib demo where
  roots := #[`Example]

/-- The packaged command-line executable: `Example.Count.CLI.main`.  Mirrors
the F* template's `cli` deliverable (deliverable-named, not a `bench`). -/
lean_exe cli where
  root := `Example.Count.CLI
