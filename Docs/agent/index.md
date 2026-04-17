# Agent Documentation — ModaalFirebase

This directory contains documentation for AI agents working on the ModaalFirebase wrapper library.

## Contents

- [coverage.md](coverage.md) — Per-module coverage audit: what's wrapped, what's accessible via escape hatch, what's not covered
- [patterns.md](patterns.md) — Wrapper implementation patterns (protocol design, wrapper classes, type conversions, Combine extensions)
- [anti-patterns.md](anti-patterns.md) — What NOT to do when working on this library
- [adding-a-wrapper.md](adding-a-wrapper.md) — Step-by-step guide for adding a new Firebase service wrapper

## Quick Reference

- **Package name:** `ModaalFirebase`
- **Repo:** `modaal-firebase-wrappers`
- **Firebase SDK:** `akaffenberger/firebase-ios-sdk-xcframeworks` from `"12.12.0"` (binary xcframeworks, not source)
- **SPM package identity:** `firebase-ios-sdk-xcframeworks` (URL-derived)
- **Platform:** iOS 15+, Swift tools 5.9
- **Build:** `./scripts/build.sh` (builds library + SampleApp + tests)
- **8 modules:** Core, Auth, Analytics, Crashlytics, Firestore, CloudStorage, Messaging, RemoteConfig
