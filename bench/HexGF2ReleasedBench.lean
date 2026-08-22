/-
Copyright (c) 2026 Lean FRO, LLC. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kim Morrison
-/

import HexGF2.Bench

/-!
Executable root for the released `hexgf2_bench`.

`HexGF2/Bench.lean` is sync-managed: it holds every `hex-gf2` benchmark
registration and deliberately has no `main`. In the development monorepo the
executable roots at a driver that also registers cross-library `GF2Poly` versus
`FpPoly 2` comparisons; that driver depends on `HexPolyFp`, which is not a
dependency of this repository, so it is not published here.

This wrapper lives outside the sync-managed `bench/HexGF2/` directory and adds
only the `lean-bench` CLI entry point over the library-owned registrations. The
`HexGF2.Bench` import resolves through `lean_lib HexGF2BenchSupport` in the root
lakefile; see the comment there.
-/

def main (args : List String) : IO UInt32 :=
  LeanBench.Cli.dispatch args
