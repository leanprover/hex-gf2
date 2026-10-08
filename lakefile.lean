import Lake
open System Lake DSL

package «hex-gf2» where
  leanOptions := #[⟨`doc.verso, true⟩, ⟨`doc.verso.suggestions, false⟩]

require HexBasic from git
  "https://github.com/leanprover/hex-basic.git" @ "v0.8.0"

private def clmulOTarget (pkg : Package) : FetchM (Job FilePath) := do
  let oFile := pkg.dir / defaultBuildDir / "HexGF2" / "ffi" / "clmul.o"
  let srcTarget ← inputTextFile <| pkg.dir / "HexGF2" / "ffi" / "clmul.c"
  buildFileAfterDep oFile srcTarget fun srcFile => do
    let flags := #["-I", (← getLeanIncludeDir).toString, "-fPIC", "-O3"]
    compileO oFile srcFile flags

extern_lib hexgf2ffi (pkg) := do
  let name := nameToStaticLib "hexgf2ffi"
  let oTarget ← clmulOTarget pkg
  buildStaticLib (pkg.staticLibDir / name) #[oTarget]

@[default_target]
lean_lib HexGF2 where
  precompileModules := true
