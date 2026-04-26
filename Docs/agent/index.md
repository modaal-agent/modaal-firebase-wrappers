# Agent Documentation — Using ModaalFirebase

This directory is for AI agents writing **app code that consumes ModaalFirebase**. It mirrors the human-facing docs under [`Docs/human/`](../human/) but is dense and rule-shaped — formatted for an agent's read-once pass.

For contributing to the wrapper library itself, see [`CONTRIBUTING.md`](../../CONTRIBUTING.md).

## Contents

- [coverage.md](coverage.md) — Per-module API coverage: what's wrapped, what's accessible via the public escape hatch, what's not yet covered. The first thing to consult when picking a Firebase API.
- [patterns.md](patterns.md) — Consumption patterns: which API form to use at the call site, how the two-tier surface works, when to prefer the Combine layer, snapshot-iteration typing, escape-hatch usage.
- [anti-patterns.md](anti-patterns.md) — Consumer-side mistakes that defeat the library's value (re-hosting behind a facade, importing raw Firebase outside the composition root, mixing real wrappers with mocks, etc.).

## Quick Reference

- **Package:** `https://github.com/modaal-agent/modaal-firebase-wrappers.git`
- **Minimum version:** `1.4.0`
- **Platform:** iOS 15+, Swift tools 5.9
- **8 modules:** `ModaalFirebaseCore`, `ModaalFirebaseAuth`, `ModaalFirebaseAnalytics`, `ModaalFirebaseCrashlytics`, `ModaalFirestore`, `ModaalCloudStorage`, `ModaalFirebaseMessaging`, `ModaalFirebaseRemoteConfig`
- **Construction:** every entry-point wrapper exposes `Wrapper.makeDefault()` (some with an optional `emulator: (host: String, port: Int)?` overload). Consumer code never needs `import Firebase*` for default-instance construction.
