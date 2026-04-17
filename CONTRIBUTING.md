# Contributing

## Development Rules

1. **Every new wrapped service ships as a complete PR:** protocol + wrapper + Combine extensions + SampleApp usage + documentation updates. Partial PRs are rejected.

2. **No raw Firebase types in any protocol surface** (return or parameter). Violations are a review-blocker. Use mirrored enums for Firebase-specific types.

3. **No `import Combine` in protocol files.** Combine extensions live in `Sources/<Module>/Combine/`.

4. **Follow the established template.** New wrappers model after Auth (wrapper class pattern) or Crashlytics (direct conformance pattern). Deviate only when the service's shape genuinely requires it.

5. **Update `Docs/agent/coverage.md`** in the same PR that adds or modifies a service wrapper.

6. **Keep the SampleApp working.** Every PR that touches the public API must update the SampleApp usage file and verify it still builds.

7. **Keep CI green.** Run `./scripts/build.sh` before pushing. Breakages on main block all PRs until fixed.

## Adding a New Service

See [Docs/agent/adding-a-wrapper.md](Docs/agent/adding-a-wrapper.md) for the step-by-step guide.

## Building

```bash
./scripts/build.sh
```

This runs three steps:
1. Build all library targets
2. Generate and build the SampleApp (XcodeGen + xcodebuild)
3. Run tests (if configured)

## Project Structure

```
Sources/<Module>/
├── Protocols/     # Protocol definitions (no Firebase imports)
├── Combine/       # Combine extensions (Future, AnyPublisher)
├── Wrappers/      # Firebase SDK bridging
└── Types/         # Mirrored enums, value types
```

## Code Style

- Copyright header: `// Copyright (c) 2026 Modaal.dev`
- MIT license reference in header
- `public` on protocols, entry-point wrappers, and types
- `internal` (default) on sub-wrappers
- Completion handlers use `Result<T, Error>`
- Combine extensions use `Future<T, Error>` (one-shot) or `AnyPublisher<T, Error>` (streaming)
