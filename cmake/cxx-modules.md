# cmake-cxxmodules(7)

[cmake-cxxmodules(7) — CMake 4.5.0 Documentation](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html)



C++ 20 introduced the concept of "[modules](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-C-module)" to the language. The design requires [build systems](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-system) to order compilations to satisfy `import` statements reliably. CMake's implementation asks the compiler to scan source files for module dependencies during the build, collates scanning results to infer ordering constraints, and tells the [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) how to dynamically update the build graph.

## Compilation Strategy

With C++ modules, compiling a set of C++ sources is no longer [embarrassingly parallel](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-embarrassingly-parallel). That is, any given source may require the compilation of another source file first in order to provide a "BMI" (or "CMI") that C++ compilers use to satisfy `import` statements in other sources. With included headers, sources could share their declarations so that any consumers could compile independently. With modules, the compiler now generates [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files during compilation based on the contents of the source file and its `export` statements. This means that, to ensure a correct build without having to regenerate the build graph (by running configure and generate steps) for every source change, the correct ordering must be determined from the source files during the build phase.

[Build systems](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-system) must be able to order these compilations within the build graph. There are multiple strategies that are suitable for this, but each has advantages and disadvantages. CMake uses a "scanning" step strategy, which is the most visible modules-related change for CMake users in the context of the build. CMake provides multiple ways to control the scanning behavior of source files.



## Scanning Control

Whether or not sources get scanned for C++ module usage is dependent on the following queries. The first query that provides a decision of whether to scan or not is used.

- If the source file belongs to a file set of type `CXX_MODULES`, it will be scanned.
- If the target does not use at least C++ 20, it will not be scanned.
- If the source file is not the language `CXX`, it will not be scanned.
- If the source file belongs to a file set that is not of type `CXX_MODULES`, and the [`CXX_SCAN_FOR_MODULES`](https://cmake.org/cmake/help/latest/prop_fs/CXX_SCAN_FOR_MODULES.html#prop_fs:CXX_SCAN_FOR_MODULES) file set property is set, its value will be used.
- If the [`CXX_SCAN_FOR_MODULES`](https://cmake.org/cmake/help/latest/prop_sf/CXX_SCAN_FOR_MODULES.html#prop_sf:CXX_SCAN_FOR_MODULES) source file property is set in the target's directory, its value will be used.
- If the [`CXX_SCAN_FOR_MODULES`](https://cmake.org/cmake/help/latest/prop_tgt/CXX_SCAN_FOR_MODULES.html#prop_tgt:CXX_SCAN_FOR_MODULES) target property is set, its value will be used. Set the [`CMAKE_CXX_SCAN_FOR_MODULES`](https://cmake.org/cmake/help/latest/variable/CMAKE_CXX_SCAN_FOR_MODULES.html#variable:CMAKE_CXX_SCAN_FOR_MODULES) variable to initialize this property on all targets as they are created.
- Otherwise, the source file will be scanned if the compiler and generator support scanning. See policy [`CMP0155`](https://cmake.org/cmake/help/latest/policy/CMP0155.html#policy:CMP0155).

Note that any scanned source will be excluded from any unity build (see [`UNITY_BUILD`](https://cmake.org/cmake/help/latest/prop_tgt/UNITY_BUILD.html#prop_tgt:UNITY_BUILD)) because module-related statements can only happen at one place within a C++ translation unit.

## Compiler Support

The list of compilers for which CMake supports scanning sources for C++ modules includes:

- MSVC toolset 14.34 and newer (provided with Visual Studio 17.4 and newer)

- LLVM/Clang 16.0 and newer

  *Added in version 4.4:* `clang-cl` version 19.1 and newer, except with the [Visual Studio Generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html#visual-studio-generators) (i.e., the `ClangCl` [`toolset`](https://cmake.org/cmake/help/latest/variable/CMAKE_GENERATOR_TOOLSET.html#variable:CMAKE_GENERATOR_TOOLSET)).

- GCC 14 and newer

## `import std` Support

*Added in version 4.5.*

Support for `import std` is limited to the following toolchain and standard library combinations:

- Clang 18.1.2 and newer with standard library `libc++` or `libstdc++`

- MSVC toolset 14.36 and newer (provided with Visual Studio 17.6 and newer)

- GCC 15 and newer, with the exception of MacOS

- GCC 16 and newer on MacOS

  Note

  Ubuntu prior to 26.04 ships broken `libstdc++.modules.json` files. See [Ubuntu issue 2141579](https://bugs.launchpad.net/ubuntu/+source/gcc-15/+bug/2141579).

Only the [Ninja Generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html#ninja-generators) currently support `import std` because [Visual Studio Generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html#visual-studio-generators) do not support building [BMIs](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) for `IMPORTED` targets.

`import std` is available for all language standards which support C++ module scanning (ie, C++20 and newer).

## Generator Support

The list of generators which support scanning sources for C++ modules includes:

- [`Ninja`](https://cmake.org/cmake/help/latest/generator/Ninja.html#generator:Ninja)
- [`Ninja Multi-Config`](https://cmake.org/cmake/help/latest/generator/Ninja Multi-Config.html#generator:Ninja Multi-Config)
- [`Visual Studio 17 2022`](https://cmake.org/cmake/help/latest/generator/Visual Studio 17 2022.html#generator:Visual Studio 17 2022)
- [`Visual Studio 18 2026`](https://cmake.org/cmake/help/latest/generator/Visual Studio 18 2026.html#generator:Visual Studio 18 2026)

Note that the [Ninja Generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html#ninja-generators) require `ninja` 1.11 or newer.

### Limitations

There are a number of known limitations of the current C++ module support in CMake. Known limitations or bugs in compilers are not listed here, as these can change over time.

For all generators:

- [Header units](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-header-unit) are not supported.

For the [Visual Studio Generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html#visual-studio-generators):

- Only Visual Studio 2022 and MSVC toolsets 14.34 (Visual Studio 17.4) and newer are supported.
- Exporting or installing [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) or module information is not supported.
- Compiling [BMIs](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) from `IMPORTED` targets with C++ modules (including `import std`) is not supported.
- Use of modules provided by `PRIVATE` sources from `PUBLIC` module sources is not diagnosed.

Separately, as a design choice, CMake does not express configuration-agnostic module maps for imported targets. The [`IMPORTED_CXX_MODULES_`](https://cmake.org/cmake/help/latest/prop_tgt/IMPORTED_CXX_MODULES_CONFIG.html#prop_tgt:IMPORTED_CXX_MODULES_) target property is always tied to a specific configuration. This can lead to some friction when importing/exporting targets from/to configuration-unaware build systems. Future work will alleviate this restriction.

## Usage

### Troubleshooting CMake

This section aims to answer common questions about CMake's implementation and to help diagnose or explain errors in CMake's C++ modules support.

#### File Extension Support

CMake imposes no requirements upon file extensions for modules of any unit type. While there are preferences that differ between toolchains (e.g., `.ixx` on MSVC and `.cppm` on Clang), there is no universally agreed-upon extension. As such, CMake only requires that the file be recognized as a `CXX`-language source file. By default, any recognized extension will suffice, but the [`LANGUAGE`](https://cmake.org/cmake/help/latest/prop_sf/LANGUAGE.html#prop_sf:LANGUAGE) property may be used with any other extension as well.

#### File Name Requirements

The name of a module has no relation to the name or path of the file in which its declaration resides. The C++ standard has no requirements here and neither does CMake. However, it may be useful to have some pattern in use within a project for easier navigation within environments that lack IDE-like "find symbol" functionality (e.g., on code review platforms).

#### Scanning Without Modules

A common problem for projects that have not yet adopted modules is unnecessary scanning of sources. This typically happens when a C++20 project becomes aware of CMake 3.28, or a 3.28-aware project starts using C++20. Either case ends up setting [`CMP0155`](https://cmake.org/cmake/help/latest/policy/CMP0155.html#policy:CMP0155) to `NEW`, which enables scanning of C++ sources with C++20 or newer by default. The easiest way for projects to turn this off is to add:

```
set(CMAKE_CXX_SCAN_FOR_MODULES 0)
```



near the top of their top-level `CMakeLists.txt` file. Note that it should **not** be in the cache, as it may otherwise affect projects using it via `FetchContent`. Attention should also be paid to vendored projects which may want to enable scanning for their own sources, as this would change the default for them as well.

### Debugging Module Builds

This section aims to help diagnose or explain common errors that may arise on the build side of CMake's C++ modules support.

#### Import Cycles

The C++ standard does not allow for cycles in the `import` graph of a [translation unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-translation-unit); therefore, CMake does not either. Currently, CMake will leave it to the [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) to detect this based on the [dynamic dependencies](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-dynamic-dependencies) used to order module compilations. [CMake Issue 26119](https://gitlab.kitware.com/cmake/cmake/-/issues/26119) tracks the desire to improve the user experience in this case.

#### Internal Module Partition Extension

When the implementation of building C++ modules was first investigated, it appeared as though there existed a type of [translation unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-translation-unit) that represented the intersection of a [partition unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-partition-unit) and an [implementation unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-implementation-unit). Initial CMake designs included specific support for these translation units; however, after a closer reading of the standard, these did not actually exist. These units would have had `module M:part;` as their module declaration statement. The problem is that this is also the exact syntax also used for declaring module partitions that do not contribute to the external interface of the primary module. Only MSVC supports this distinction. Other compilers do not and will treat such files as an [internal partition unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-internal-partition-unit) and CMake will raise an error that a module-providing C++ source must be in a `FILE_SET` of type `CXX_MODULES`.

The fix is to not use the extension, as it provides no further expressivity over not using the extension. All [implementation unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-implementation-unit) source files should instead only use `module M;` as their module declaration statement regardless of what partition the defined entities are declared within. As an example:

```
// module-interface.cpp
export module M;
export int foo();

// module-impl.cpp
module M:part; // module M:part; looks like an internal partition
int foo() { return 42; }
```



Instead use explicit interface/implementation separation:

```
// module-interface.cpp
export module M;
export int foo();

// module-impl.cpp
module M;
int foo() { return 42; }
```



#### Module Visibility

CMake enforces [module visibility](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-visibility) between and within targets. This essentially means that a module (say, `I`) provided from a `PRIVATE` `FILE_SET` on a target `T` may not be imported by:

- other targets depending on `T`; or
- modules provided from a `PUBLIC` `FILE_SET` on target `T` itself.

This is because, in general, all imported entities from a module must also be importable by all potential importers of that module. Even if module `I` is only used within parts of a module without the `export` keyword, it may affect things within it in such a way that consumers of the module need to be able to transitively `import` it to work correctly. As CMake uses the module visibility to determine whether to install [module interface units](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-interface-unit), a `PRIVATE` module interface unit will not be installed, meaning that usage of any installed module which imports `I` would not work.

Instead, import `PRIVATE` C++ modules only from within an [implementation unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-implementation-unit), as these are not exposed to consumers of any module.

## Design

The design of CMake's C++ module support makes a number of trade-offs compared to other designs. First, CMake's chosen design will be covered. Later sections cover alternative designs that were not chosen for CMake's implementation.

Overall, the designs fall somewhere along two axes:

| Explicit Dynamic | Explicit Static | Explicit Fixed |
| ---------------- | --------------- | -------------- |
| Implicit Dynamic | Implicit Static | Implicit Fixed |

- **Explicit** builds control which modules are visible to each translation unit directly. For example, when compiling a source requiring a module `M`, the compiler will be given information which states the exact BMI file to use when importing the `M` module.
- **Implicit** builds can control module visibility as well, but do so by instead grouping [BMIs](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) into directories which are then searched for files to satisfy `import` statements in the source file.
- **Static** builds use a static set of build commands in order to complete the build. There must be support to add edges between nodes at build time.
- **Dynamic** builds may create new build commands during the build and schedule any discovered work during the build.
- **Fixed** builds are generated with all module dependencies already known.

### Design Goals

CMake's implementation of building C++ modules focuses on the following design goals:

1. [Correct Builds](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-correct-builds)
2. [Deterministic Builds](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-deterministic-builds)
3. [Support Generated Sources](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-generated-sources)
4. [Static Communication](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-static-communication)
5. [Minimize Regeneration](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-minimize-regeneration)



#### Correct Builds

Above all else, an incorrect build is a frustrating experience for all involved. A build which does not detect errors and instead lets a build with detectable problems run to completion is a good way to start wild goose chase debugging sessions. CMake errs on the side of avoiding such situations.



#### Deterministic Builds

Given an on-disk state of a build, it should be possible to determine what steps will happen next. This does not mean that the exact order of rules within the build that can be run concurrently is deterministic, but instead that the set of work to be done and its results are deterministic. For example, if there is no dependency between tasks `A` and `B`, `A` should have no effects on the execution of `B` and vice versa.



#### Support Generated Sources

Code generation is prevalent in the C++ ecosystem, so only supporting modules in files whose content is known at configure time is not suitable. Without supporting generated sources which use or provide modules, code generation tools are effectively cut off from the use of modules, and any dependencies of generated sources must also provide non-modular ways of using their interfaces (i.e., provide headers). Given that all C++ implementations use [strong module ownership](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-strong-module-ownership) for symbol mangling, this is problematic when such interfaces end up referring to compiled symbols in other libraries.



#### Static Communication

All communication between different steps of the build should be handled statically. Given the [build tools](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) that CMake supports, it is challenging to establish a controlled lifetime for a companion tool that needs to interact during compilation. Neither `make` nor `ninja` offer a way to start a tool at the beginning of a build and ensure it is stopped at the end. Instead, communication with compilers is managed through input and output files, using dependencies in the [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) to keep everything up-to-date. This approach enables standard debugging strategies for builds and allows developers to run build commands directly when investigating issues, without needing to account for other tools running in the background.



#### Minimize Regeneration

Active development of a build with modules should not require the build graph to be regenerated on every change. This means that the module dependencies must be constructed after the build graph is available. Without this, a [correct build](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-correct-builds) would need to regenerate the build graph any time a module-aware source file is edited, as any changes may alter module dependencies.

It also means that all module-aware sources must be known at configure time (even if they do not yet exist) so that the build graph can include the commands to [scan](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-scan) for their dependencies.

Note

There is a known issue with `ninja` which can result in an erroneous detection of a dependency cycle when the dependency order between two sources reverses (i.e., `a` importing `b` becomes `b` importing `a`) between two builds. See [ninja issue 2666](https://github.com/ninja-build/ninja/issues/2666) for details.

### Use Case Considerations

The design goals described above constrain the implementation. Additionally, mixed configurations are supported by CMake via multi-config generators such as [`Ninja Multi-Config`](https://cmake.org/cmake/help/latest/generator/Ninja Multi-Config.html#generator:Ninja Multi-Config) and [Visual Studio Generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html#visual-studio-generators). This section describes how CMake addresses these constraints.

### Selected Design

The general strategy CMake uses is to "[scan](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-scan)" sources to extract the ordering dependency information and update the build graph with new edges between existing edges. This is done by taking the per-source scan results (represented by [P1689R5](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2022/p1689r5.html) files) and then "[collating](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate)" them for each target with information from its dependencies. The primary task of the collator is to generate "[module map](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-map)" files to pass to each compile rule with the paths to the [BMIs](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) needed to satisfy `import` statements, and to inform the [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) of dependencies needed to satisfy those `import` statements during the compilation. The collator also uses the build-time information to generate `install` rules for the module interface units, their [BMIs](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI), and properties for any exported targets with C++ modules. It also enforces that `PRIVATE` modules may not be used by other targets or by any `PUBLIC` [module interface unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-interface-unit) within the target.

### Implementation Details

Warning

The implementation details are not a stable interface. Each version of CMake may revise them without any attempt at providing compatibility. External toolchain maintainers are responsible for updating their implementations for each version of CMake they support.

This section describes how CMake actually structures the build graph, the data passed between various parts, and the files which contain that data. It is intended to be used both as functional documentation and as a guide to help those debugging a module build to understand where to locate various bits of data.

Note

This section documents internal implementation details that may be useful for [`toolchain file`](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html#manual:cmake-toolchains(7)) authors or during debugging of a module-related issue. Projects should not need to inspect or modify any of the variables, properties, files, or targets mentioned here.

#### Toolchain (scanning)

Compilers which support modules must also provide a scanning tool. This will usually be either the compiler itself with some extra flags or a tool shipped with the compiler. The command template for scanning is stored in the `CMAKE_CXX_SCANDEP_SOURCE` variable. The command is expected to write [P1689R5](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2022/p1689r5.html) results to the `<DYNDEP_FILE>` placeholder. Additionally, the command should provide any [discovered dependencies](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-discovered-dependencies) to the `<DEP_FILE>` placeholder. This allows [build tools](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) to rerun the scan if any of the dependencies of the scanning command change.

Additionally, toolchains should set the following variables:

- `CMAKE_CXX_MODULE_MAP_FORMAT`: The format of the [module map](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-map) describing where dependent [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files for imported modules exist during compilation. Must be one of `gcc`, `clang`, or `msvc`.
- `CMAKE_CXX_MODULE_MAP_FLAG`: The arguments used to inform the compiler of the [module map](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-map) file. It should use the `<MODULE_MAP_FILE>` placeholder.
- `CMAKE_CXX_COMPILE_BMI`: The command template to compile a [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) file from a [module interface unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-interface-unit). Used when `CMAKE_CXX_MODULE_BMI_ONLY_FLAG` is not completely additive to an object compilation template.
- `CMAKE_CXX_MODULE_BMI_ONLY_FLAG`: The arguments used to compile only a [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) file from a [module interface unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-interface-unit). This is used when consuming modules from external projects to compile [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files for use within the current build.

If a toolchain does not provide the `CMAKE_CXX_COMPILE_BMI` or `CMAKE_CXX_MODULE_BMI_ONLY_FLAG` variables, it will not be able to consume modules provided by `IMPORTED` targets.

#### Configure

During the configure step, CMake needs to track which sources care about modules at all. See [Scanning Control](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#cxxmodules-scanning-control) for how each source determines whether it cares about modules or not. CMake tracks these in its internal target representation structure (`cmTarget`). The set of sources which need to be scanned may be modified using the [`target_sources()`](https://cmake.org/cmake/help/latest/command/target_sources.html#command:target_sources), [`target_compile_features()`](https://cmake.org/cmake/help/latest/command/target_compile_features.html#command:target_compile_features), and [`set_property()`](https://cmake.org/cmake/help/latest/command/set_property.html#command:set_property) commands.

#### Generate

During generation, CMake needs to add additional rules to ensure that the sources providing modules can be built before sources that import those modules. Since CMake uses a [static build](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-static-build), the build graph must contain all possible commands for scanning and module generation. The dependency edges between commands to ensure that modules are provided will then ensure that the build graph executes correctly. This means that, while all sources may get scanned, only modules that are actually used will be generated.

The first step CMake performs is to generate any [synthetic targets](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-synthetic-target) needed for a module-providing target. These targets are based on the module provider, but produce only [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files for consumers rather than object files. This is necessary because the compatibility of [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files is extremely narrow and cannot be shared between arbitrary `import` instances.

Due to the internal workings of toolchains, there can generally only be a single set of settings for a variety of flags for any one compilation, including [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files for imported modules. As an example, the C++ standard in use needs to be consistent across all modules imported to a given translation unit, mixing standards will cause incompatibilities.

> *Added in version 4.4:* Prior to CMake 4.4, CMake assumed all usages were compatible and would only create one set of [BMIs](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) for each module-providing target. This could cause build failures due to incompatible [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) usage.
>
> In CMake 4.4 and later, CMake attempts to determine [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) compatibility on a target-by-target basis and will generate [synthetic targets](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-synthetic-target) to provide compatible [BMIs](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) for consumers.

The generated [synthetic target](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-synthetic-target) has a mix of properties from both the provider of the module and the consumer. [`COMPILE_FEATURES`](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_FEATURES.html#prop_tgt:COMPILE_FEATURES) and [`COMPILE_OPTIONS`](https://cmake.org/cmake/help/latest/prop_tgt/COMPILE_OPTIONS.html#prop_tgt:COMPILE_OPTIONS) are adopted from the consumer, while all other relevant properties are inherited from the provider.

Once all of the [synthetic targets](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-synthetic-target) are created, CMake looks at each target that has any source that might use C++ modules and creates a command to [scan](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-scan) each of them. This command will output a [P1689R5](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2022/p1689r5.html)-formatted file describing the C++ modules it uses and provides (if any). It will also create a command to [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) module dependencies for the eligible compilations. This command depends on the [scan](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-scan) results of all eligible sources, information about the target itself, as well as the [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) results of any dependent targets which provide C++ modules. The [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) step uses a target-specific `CXXDependInfo.json` file which contains the following information:

- `compiler-*`: basic compiler information (`id`, `frontend-variant`, and `simulate-id`) which is used to generate correctly formatted paths when generating paths for the compiler
- `cxx-modules`: a map of object files to the `FILE_SET` information, which is used to enforce [module visibility](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-visibility) and generate install rules for [module interface unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-interface-unit) sources
- `module-dir`: where to place [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files for this target
- `dir-{cur,top}-{src,bld}`: the source (`src`) and build (`bld`) directories for the current directory (`cur`) and the top (`top`) of the project, used to compute accurate relative paths for the [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) dynamic dependencies
- `exports`: The list of exports which both contain the target and are providing C++ module information, used to provide accurate module properties on `IMPORTED` targets from the exported targets.
- `bmi-installation`: installation information, used to generate install scripts for [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files
- `database-info`: information required to generate [build database](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-database) information if requested by [`EXPORT_BUILD_DATABASE`](https://cmake.org/cmake/help/latest/prop_tgt/EXPORT_BUILD_DATABASE.html#prop_tgt:EXPORT_BUILD_DATABASE)
- `sources`: list of other source files in the target, used to add to the [build database](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-database) if requested
- `config`: the configuration for the target, used to set the appropriate properties in generated export files
- `language`: the language (e.g., C++ or Fortran) the [collation](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) metadata file is describing
- `include-dirs` and `forward-modules-from-target-dirs`: unused for C++

Each entry in the `cxx-modules` map records the following:

- `bmi-only` (bool): True if only the BMI, not the source of the BMI, is available
- `compile-features` (list[string]): [`cmake-compile-features(7)`](https://cmake.org/cmake/help/latest/manual/cmake-compile-features.7.html#manual:cmake-compile-features(7)) used to build the object
- `compile-options` (list[string]): compilation options/flags used to build the object, except for those derived from `compile-features`
- `definitions` (list[string]): preprocessor defines used to build the object
- `destination` (string): intended install destination of the source file
- `include-directories` (list[string]): include directories used to build the object
- `name` (string): name of the file set which owns the source file
- `relative-directory` (string): base path relative to which the source file will be relocated into the install destination
- `source` (string): path to the source file
- `type` (string): type of the file set which owns the source file
- `visibility` (string): visibility of the file set which owns the source file

For each compilation, CMake will also provide a [module map](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-map) which will be created during the build by the [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) command. How this is provided to the compiler is specified by the `CMAKE_CXX_MODULE_MAP_FORMAT` and `CMAKE_CXX_MODULE_MAP_FLAG` toolchain variables.

#### Scan

The compiler is expected to implement the [scan](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-scan) command. This is because only the compiler itself can reliably answer preprocessor predicates like `__has_builtin` in order to provide accurate module usage information in the face of arbitrary flags that may be used when compiling sources.

CMake names these files with the `.ddi` extension, which stands for "dynamic dependency information". These files are in [P1689R5](https://www.open-std.org/jtc1/sc22/wg21/docs/papers/2022/p1689r5.html) format and are used by the [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) command to perform its tasks.

#### Collate

The [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) command performs the bulk of the work to make C++ modules work within the build graph. It consumes the following files as input:

- `CXXDependInfo.json` from the generate step
- `.ddi` files from the [scanning](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-scan) results of the target's sources
- `CXXModules.json` files output from eligible dependent targets' [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) commands

It uses the information from these files to generate:

- `CXX.dd` files to inform the [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) of dependencies that exist between the compilation of a source and the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files of the modules that it imports
- `CXXModules.json` files for use in [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) commands of depending targets
- `*.modmap` files for each compilation to find [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files for imported modules
- `install-cxx-module-bmi-$<CONFIG>.cmake` scripts for the installation of any [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files (included by the `install` scripts)
- `target-*-$<CONFIG>.cmake` export files for any exports of the target to provide the [`IMPORTED_CXX_MODULES_`](https://cmake.org/cmake/help/latest/prop_tgt/IMPORTED_CXX_MODULES_CONFIG.html#prop_tgt:IMPORTED_CXX_MODULES_) properties
- `CXX_build_database.json` [build database](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-database) files for the target when the its [`EXPORT_BUILD_DATABASE`](https://cmake.org/cmake/help/latest/prop_tgt/EXPORT_BUILD_DATABASE.html#prop_tgt:EXPORT_BUILD_DATABASE) property is set

During its processing, it enforces the following guarantees:

- [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) usage is consistent
- [module visibility](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-visibility) is respected

C++ modules have the rule that only a single module of a given name may exist within a program. This is not exactly enforceable with the existence of private modules, but it is enforceable for public modules. The enforcement is done by the [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) command. Part of the `CXXModules.json` files is the set of modules that are transitively imported by each module it provides. When a module is then imported, the [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) command ensures that all modules with a given name agree upon a given [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) file to provide that module.

#### Compile

Compilation uses the [module map](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-map) file generated by the [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) command to find imported modules during compilation. Because CMake only provides the locations of modules that are discovered by the [scan](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-scan) command, any modules missed by it will not be provided to the compilation.

#### Install

During installation, install scripts which have been written by the [collate](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-collate) command during the build are included so that any [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files are installed as needed. These need to be generated, as it is not known what the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) file names will be during CMake's generation (because CMake names the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files after the module name itself). These install scripts are included with the `OPTIONAL` keyword, so an incomplete build may result in an incomplete installation as well.

### Alternative Designs

There are alternative designs that CMake does not implement. This section aims to give a brief overview and to explain why they were not chosen for CMake's implementation.

#### Implicit Builds

An implicit build performs module builds using compile-time search paths to make the implementation of the build simpler. This is certainly something that can be made to work. However, CMake's goals exclude it as a solution.

When a build uses search directory management, the compiler is directed to place module output files into a specified directory. These directories are then provided as search paths to any compilation allowed to use the modules within them.

This strategy risks running into problems with the [Correct Builds](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-correct-builds) goal. This stems from the hazard of stale files being present in the search directories. Since the build system is unaware of the actual files being written, it is difficult to know which files are allowed to be deleted (e.g., using `ninja -t cleandead` to remove outputs `ninja` has encountered but are no longer generated). Removal of intermediate files may also cause the build to become stuck if the outputs are not known to the build system beyond consumers reporting "usage of file X".

There is also a need to at least do some level of ordering of [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) generation commands which share an output directory. Separate directories may be used to order groups of modules (e.g., one directory per target); otherwise, modules within the same directory may not assume that other modules writing to the shared directory will complete first. If module paths are grouped accurately according to the module dependency graph, it is a small step to being an explicit build where the files are directly specified.

#### Static Scanning

A [fixed build](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-fixed-build) performs a scan while generating the build graph and includes the necessary dependencies up-front. In CMake's case, it would look at the source files during the generate phase and add the dependencies directly to the build graph. This is more likely to be suitable for a [build system](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-system) that is also its own [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) where build graph manipulation can be done cooperatively.

No matter whether it is integrated or not, this strategy necessitates either a suitable C++ parser to extract the information in the first place, or toolchain cooperation to obtain it. While module dependency information is available to a simpler C++ parser, dependencies may be hidden behind preprocessor conditionals that need to be understood in order to be accurate. Of course, choosing to not support preprocessor conditionals around `import` statements is also an option, but this may severely limit external library support.

For CMake, this strategy would mean that any change to a module-aware source file may need to trigger regeneration of the build graph. A benign edit would at least need to trigger the *check* for changed imports, but may skip actually regenerating if it is unchanged. This may be less critical for a [build system](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-system) which is also its own [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool), but it is a direct violation of the [Minimize Regeneration](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-minimize-regeneration) goal.

Additionally, CMake's [Support Generated Sources](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-generated-sources) goal would be unsupportable with this strategy. CMake could defer scanning until the generated files are available, but those sources cannot be compiled until such a scan has been performed. This would mean that there would be some unbounded (but finite) number of regenerations of the build graph as sources become available.

#### Module Mapping Service

Another strategy is to run a service alongside the build that can act as an oracle for where to place and discover modules. The compiler is instructed to query the service with questions such as "this source is exporting module X" and "this source is importing module Y" and receive the path to either create or find the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI), respectively. In this case, the service dynamically implements the collation logic.

Of particular note, this conflicts with the [Deterministic Builds](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-deterministic-builds) and [Static Communication](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-static-communication) goals because the on-disk state may not match the actual state, and coordinating the lifetime of the [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) itself with the service is difficult. The primary missing feature is some signal when a build session starts and ends so that such a service can know in what context it is answering requests. There also needs to be a way to resume a session and detect when a session is invalidated. No [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) that CMake supports today has such features.

There are also hazards which conflict with the [Correct Builds](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#design-goal-correct-builds) goal. When a module is imported, the compiler waits for a response before continuing. However, there is no guarantee that a (visible) module of that name even exists, so it may wait indefinitely. While waiting for a compilation to report that it creates that module, it may run into a dependency cycle which leaves the compilations hanging until some resource limit is reached (probably time, or that all possible providers of the module have not reported a module of that name). While these compilations are waiting on answers, there is the question of how they affect the parallelism limits of the [build tool](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-tool) in use. Do compilations waiting on an answer count towards the limit and block other compilations from launching to potentially discover the module? If they do not, what about other resources that may be held in use by those compilations (e.g., memory or available file descriptors)?

## Possible Future Enhancements

This section documents possible future enhancements to CMake's support of C++ modules. Nothing here is a guarantee of future implementation, and the ordering is arbitrary.

### Batch Scanning

It is possible to scan all sources within a target at once, which should be faster when sources share transitive includes. This does have side effects for incremental builds, as the update of any source in the target means that all sources in the target are scanned again. Given how much faster scanning can be, it should be negligible to do such "extra" scanning assuming that unchanged results do not trigger recompilations.

### BMI Modification Optimization

Currently, as with object files, compilers always update a [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) file even if the contents have not changed. Because modules increase the potential scope of "non-changes" to cause (conceptually) unnecessary recompilation, it might be useful to avoid recompilation of module consumers if the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) file has not changed. This might be achieved by wrapping the compilation to juggle the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) through a `cmake -E copy_if_different` pass with `ninja`'s `restat = 1` feature to avoid recompiling importers if the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) file doesn't actually change.



### Easier Source Specification

The initial implementation of CMake's module support had used the "just list sources; CMake will figure it out" pattern. However, this ran into issues related to other metadata requirements. These were discovered while implementing CMake support beyond just building the modules-using code.

Conflicts with [Separate BMI Generation](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#separate-bmi-generation) on a single target, as that requires knowledge of all [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI)-generating rules at generate time.



### Separate BMI Generation

CMake currently uses a single rule to generate both the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) and the object file for a compilation. At least Clang supports compiling an object directly from the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI). This would be beneficial because [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) generation is typically faster than compilation and generating the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) as a separate step allows importers to start compiling without waiting for the object to also be generated.

This is not supported in the current implementation as only Clang supports generating an object directly from the [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI). Other compilers either do not support such a two-phase generation (GCC) or need to start object compilation from the source again.

Conflicts with [Easier Source Specification](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#easier-source-specification) on a single target because CMake must know all [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI)-generating sources at generate time rather than build time to create the two-phase rules.

## Module Compilation Glossary

- BMI

  Built Module Interface. A compiler-generated binary representation of a C++ module's interface that is required by consumers of the module. File extensions vary by compiler.

- CMI

  Compiled Module Interface. Alternative name for [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) used by some compilers.

- build database

  A JSON file containing compilation commands, module dependencies, and grouping information. Used for IDE integration and build analysis.

- build system

  A tool that facilitates the building of software which includes a model of how components of the build relate to each other. For example, CMake, Meson, build2, and more.

- build tool

  A build graph execution tool. For example, ninja and make. Some build tools are also their own [build system](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-system).

- C++ module

  A C++20 language feature for describing the API of a piece of software. Intended as a replacement for headers for this purpose.

- collate

  The process of aggregating module information from scanned sources to ensure correct compilation order and to provide metadata for other parts of the build (e.g., installation or a [build database](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-build-database)).

- discovered dependencies

  Dependencies found during the processing of a command that do not need to be explicitly declared.

- dynamic dependencies

  Dependencies which require a separate command to detect so that a further command may have its dependencies satisfied.

- embarrassingly parallel

  A set of tasks which, due to having minimal dependencies between them, can be easily divided into many independent tasks that can be executed concurrently.

- explicit build

  A build strategy where module dependencies are explicitly specified rather than discovered.

- fixed build

  A build strategy where all module dependencies are computed and inserted directly into the build graph.

- header unit

  A header file which is used via an `import` statement rather than an `#include` preprocessor directive. Implementations may provide support for treating `#include` as `import` as well.

- implementation unit

  A C++ [translation unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-translation-unit) that implements module entities declared in a module interface unit.

- implicit build

  A build strategy where module dependencies are discovered by searching for [BMI](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) files during compilation.

- internal partition unit

  A [translation unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-translation-unit) which contains a partition name and is not exported from the [primary module interface unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-primary-module-interface-unit).

- module interface unit

  A [translation unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-translation-unit) that declares a module's public interface using `export module`. Such a unit may or may not be also be a [partition unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-partition-unit).

- module map

  A compiler-specific file mapping module names to BMI locations.

- module visibility

  CMake's enforcement of access rules for modules based on their declaration scope (PUBLIC/PRIVATE).

- ODR

  One Definition Rule. The C++ requirement that any entity be defined exactly once per program.

- partition unit

  A [translation unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-translation-unit) which describes a module with a partition name (i.e., module MODNAME:PARTITION;). The partition may or may not use the `export` keyword. If it does, it is also a [module interface unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-interface-unit); otherwise, it is a [internal partition unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-internal-partition-unit).

- primary module interface unit

  A [module interface unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-module-interface-unit) which exports a named module that is not a [partition unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-partition-unit).

- scan

  The process of analyzing a [translation unit](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-translation-unit) to discover module imports and exports.

- static build

  A build configuration where all compilation rules are determined at generate time.

- strong module ownership

  C++ implementations have settled on a model where the module "owns" the symbols declared within it. In practice, this means that the module name is included into the symbol mangling of entities declared within it.

- synthetic target

  A CMake-generated build target used to supply [BMIs](https://cmake.org/cmake/help/latest/manual/cmake-cxxmodules.7.html#term-BMI) to a specific user of a module-providing target.

- translation unit

  The smallest component of a compilation for a C++ program. Generally, there is one translation unit per source file. C++ source files which do not use C++ modules may be combined into a single translation unit.
