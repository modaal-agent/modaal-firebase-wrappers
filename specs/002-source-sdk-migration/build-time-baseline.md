# v1.x Build-Time Baseline

**Captured:** 2026-05-10 on `dev/v2` branch (HEAD `5cb11d2`, identical build graph to `main`/v1.4.1).
**Toolchain:** macOS 25.4.0 (arm64), Xcode 26.4 (Build 17E192), Swift 5.9+, Firebase CLI 15.15.0.
**Hardware:** local developer machine (results will be larger on CI's `macos-15` runner — see *Caveats*).
**Reproducer:** `rm -rf .build && /usr/bin/time -p scripts/build.sh`

## Headline numbers

| Run | wall (s) | user (s) | sys (s) | Notes |
|---|---:|---:|---:|---|
| Cold (`.build/` purged before run) | **104.36** | 30.55 | 32.85 | xcframework downloads + SPM resolve dominate. |
| Warm (immediately after a successful cold run) | **48.49** | 6.56 | 2.70 | All SourcePackages and DerivedData reused. |

Speedup: warm is **2.15x** of cold on a `.build/`-resident cache. This is the upper bound for what a CI cache can deliver under the current (xcframeworks) graph.

## Artifact footprint

After a successful build:

| Path | Size |
|---:|---:|
| `.build/SourcePackages` | 1.8 GB |
| `.build/DerivedData` | 1.1 GB |
| `.build/` total | 2.9 GB |

GitHub Actions per-repo cache budget is 10 GB, so the v1.x graph fits with room to spare. The v2.x graph will be larger (gRPC-Swift + BoringSSL source artifacts) — re-measure post-Phase-2.

## Step breakdown (warm run — banner positions in [`scripts/build.sh`](../../scripts/build.sh))

These are wall-clock-relative *anchor lines* in the warm log, not per-step deltas. They confirm the script still gates on every step:

| Step | Banner line in warm log |
|---|---:|
| Install prerequisites (mint bootstrap) | 3 |
| Validate generated mocks (sourcery regen + diff) | 10 |
| Build library targets (`ModaalFirebase-Package` scheme) | 34 |
| Build SampleApp (API-surface compile check) | 41 |
| Run tests (4 SPM testTargets, ~50 tests) | 52 |
| All steps passed | 201 |

Tests themselves are fast (every assertion < 0.005s); >95% of wall time is spent in `xcodebuild build` calls.

## Phase 5 gate (recap from [migration-plan.md](migration-plan.md))

| Outcome on v2.x warm CI | Decision |
|---|---|
| < 156s (1.5x v1.x cold) | ✅ Ship v2.0.0 as planned. |
| 156–312s (1.5–3x) | ⚠️ Acceptable but document the regression in CHANGELOG. |
| > 312s (3x) | ❌ Block release; revisit cache strategy. Options: prebuild gRPC + BoringSSL via separate workflow, raise the SPM `traits` question. |

## Caveats

- **Local-only number.** GitHub Actions `macos-15` runners are typically 1.3–1.8x slower than local arm64 dev machines. The cold v1.x CI baseline is therefore probably 140–190s. We'll capture the actual CI-side number when Phase 5 lands and the workflow runs.
- **Single sample.** No variance measurement. If a v2.x number lands close to the gate, run 3 samples and take the median.
- **xcframework download is on the critical path of cold.** Source SDK has no analogous step (it `git clone`s, which is faster), but compilation more than makes up for it.

## v2.x numbers — captured 2026-05-10 in Phase 2

Same machine, same toolchain. iOS deployment target stays at 15 (Decision #1 in [migration-plan.md](migration-plan.md)). Reproducer: `rm -rf .build && /usr/bin/time -p scripts/build.sh`.

| Run | wall (s) | user (s) | sys (s) | vs v1.x cold |
|---|---:|---:|---:|---:|
| v2 cold (`.build/` purged) | **153.84** | 35.42 | 27.92 | 1.47× |
| v2 warm (immediately after) | **105.15** | 17.64 | 6.00 | 1.01× ✅ |

Cache footprint:

| Path | v1.x | v2 |
|---:|---:|---:|
| `.build/SourcePackages` | 1.8 GB | 1.2 GB |
| `.build/DerivedData` | 1.1 GB | 2.3 GB |
| `.build/` total | 2.9 GB | **3.5 GB** |

**Why v2 grew DerivedData but shrank SourcePackages:** the upstream `firebase-ios-sdk` is a *hybrid* — it ships gRPC, FirebaseFirestoreInternal, GoogleAppMeasurement, abseil etc. as `.binaryTarget` xcframeworks via Google's CDN, and only the Swift wrapper layers are source-compiled. SourcePackages holds smaller source trees (the binary `.zip`s are extracted into the per-package `.xcframework/` directories under DerivedData). Net: DerivedData grew because *we* now have compiled Swift modules (FirebaseFirestore, FirebaseAuth, etc.) where v1.x had only consumed the binary mirror.

**Implication for Phase 5:** the original concern that source SDK would force compilation of gRPC + BoringSSL was unfounded. Those still ship as binaries upstream. The warm number (105.15s) already passes the migration gate (< 156s) on local hardware *without* any CI cache — meaning Phase 5 can be a relatively low-stakes optimisation rather than a release-blocker.

## Phase 5 gate — status under v2

| Outcome | Threshold | v2 warm result | Verdict |
|---|---:|---:|---|
| Pass | < 156s (1.5× v1.x cold) | 105.15s | ✅ |
| Acceptable | 156–312s | — | — |
| Block | > 312s | — | — |

CI runs may land somewhat slower (`macos-15` typical 1.3–1.8× factor → projected ~135–190s), so the cache step in Phase 5 may be needed to keep CI within the gate. Numbers will be re-captured on CI in Phase 5.
