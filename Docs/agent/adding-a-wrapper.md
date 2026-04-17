# Adding a New Firebase Service Wrapper

Step-by-step guide for wrapping a new Firebase service (e.g., Firebase Database, Firebase Functions).

## Prerequisites

- Verify the Firebase product exists in `firebase-ios-sdk-xcframeworks` at the current version
- Check if the product name matches the service (e.g., `FirebaseDatabase`, `FirebaseFunctions`)

## Steps

### 1. Add to Package.swift

```swift
// Add library product
.library(name: "ModaalFirebaseDatabase", targets: ["ModaalFirebaseDatabase"]),

// Add target
.target(
  name: "ModaalFirebaseDatabase",
  dependencies: [
    "ModaalFirebaseCore",
    .product(name: "FirebaseDatabase", package: firebaseSDK),
  ]
),
```

### 2. Create directory structure

```
Sources/ModaalFirebaseDatabase/
├── Protocols/
│   └── FirebaseDatabaseProtocol.swift
├── Combine/
│   └── Database+Combine.swift
└── Wrappers/
    └── FirebaseDatabaseWrapper.swift
```

### 3. Define protocols

- One protocol per Firebase class you need to wrap
- Use completion handlers with `Result<T, Error>` — not Firebase's `(T?, Error?)` pattern
- No `import Firebase*` in protocol files
- Mirror any Firebase-specific enums as Modaal types
- Add convenience overloads as protocol extensions (for default parameter values)

### 4. Implement wrappers

- Entry-point wrapper: `public final class` with `public let` underlying Firebase type (escape hatch)
- Sub-wrappers: `internal final class`
- Follow the `FirebaseAuthWrapper` template as the canonical example
- Use force-cast (`as!`) for protocol-to-concrete bridging in sub-wrappers

### 5. Add Combine extensions

- `Future<T, Error>` for every completion-handler method
- `AnyPublisher<T, Error>` for any listener/observer-based APIs
- Put in `Combine/` subdirectory

### 6. Add SampleApp usage

- Create `Examples/SampleApp/SampleApp/<Service>Usage.swift`
- Exercise every protocol method, property, and enum case
- Include a Combine section exercising every `Future` and streaming publisher
- Add wrapper instantiation exercise (`let _: Wrapper.Type = Wrapper.self`)
- Update `Examples/SampleApp/xcodegen.yml` to add the product dependency

### 7. Verify

```bash
./scripts/build.sh
```

### 8. Update documentation

- Update `Docs/agent/coverage.md` with the new module's coverage table
- Update `README.md` module table
- Update `CHANGELOG.md`

## Checklist

- [ ] Package.swift updated (product + target)
- [ ] Protocol(s) defined — no raw Firebase types, no Combine imports
- [ ] Wrapper(s) implemented — escape hatch on entry-point wrapper
- [ ] Combine extensions added
- [ ] Mirrored types created (if any Firebase enums appear in the protocol surface)
- [ ] SampleApp usage file — 100% method/property/enum coverage + Combine
- [ ] xcodegen.yml updated
- [ ] `./scripts/build.sh` passes
- [ ] coverage.md updated
- [ ] README.md module table updated
- [ ] CHANGELOG.md updated
