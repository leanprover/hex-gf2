import Lake

open System Lake DSL

package «hex-gf2» where
  leanOptions := #[⟨`doc.verso, true⟩, ⟨`doc.verso.suggestions, false⟩]

require HexBasic from git
  "https://github.com/leanprover/hex-basic.git" @ "da8a864cd17ccca780d8c76af403e88585bc4734"

private def clmulOTarget (pkg : Package) : FetchM (Job FilePath) := do
  let oFile := pkg.dir / defaultBuildDir / "HexGF2" / "ffi" / "clmul.o"
  let srcTarget ← inputTextFile <| pkg.dir / "HexGF2" / "ffi" / "clmul.c"
  buildFileAfterDep oFile srcTarget fun srcFile => do
    compileO oFile srcFile #["-I", (← getLeanIncludeDir).toString, "-fPIC", "-O3"]

extern_lib hexgf2ffi (pkg) := do
  let name := nameToStaticLib "hexgf2ffi"
  let oTarget ← clmulOTarget pkg
  buildStaticLib (pkg.staticLibDir / name) #[oTarget]

@[default_target]
lean_lib HexGF2 where
  precompileModules := true

-- The sync-managed bench registrations live at `bench/HexGF2/Bench.lean`, so
-- their module name falls inside the `HexGF2` library's namespace. Lake
-- resolves an import against the *last* library in the owning package that
-- claims it, so declaring the bench sources here, after `lean_lib HexGF2`,
-- is what makes `import HexGF2.Bench` find them. Declaring them in the bench
-- sub-project instead leaves the module claimed by two packages, which Lake
-- either resolves to the missing `HexGF2/Bench.lean` or reports as ambiguous.
-- Not a default target: it needs `lean-bench`, which only `bench/` requires.
lean_lib HexGF2BenchSupport where
  srcDir := "bench"
  globs := #[`HexGF2.Bench]
