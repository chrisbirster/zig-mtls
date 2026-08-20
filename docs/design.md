# zig-mtls design

## Problem

Zig 0.16.0's `std.crypto.tls.Client` supports normal server-authenticated TLS, including CA-chain and host-name verification, but it does not expose the application-facing client certificate/private-key path required for mutual TLS.

A server can send TLS `CertificateRequest`. A complete client implementation needs two behaviors:

1. no client identity configured: send an empty client `Certificate` message when the protocol/server permits it;
2. client identity configured: select an acceptable certificate/signature scheme, send the certificate chain, and produce `CertificateVerify` using the configured private key.

Bongo currently carries a narrow Zig 0.16 compatibility backport for case (1). `zig-mtls` is intended to move this class of TLS compatibility work out of MongoDB-specific code and implement case (2) generically.

## Design principles

- Never disable CA or host-name verification implicitly.
- Keep private-key ownership explicit.
- Avoid global state.
- Keep the TLS implementation generic; protocol adapters belong in consuming projects.
- Prefer small, reviewable deltas against Zig's active 0.16 TLS client over a ground-up TLS stack.
- Preserve Zig's MIT/Expat license notice for Zig-derived code.
- Keep changes structured so they can be proposed upstream to Zig.

## Proposed API shape

The exact API is intentionally not frozen yet, but the boundary should model an optional client identity and a signing operation rather than MongoDB-specific files/options.

```zig
pub const ClientIdentity = struct {
    certificate_chain: CertificateChain,
    signer: Signer,
};

pub const Options = struct {
    host: []const u8,
    ca: CaSource,
    client_identity: ?ClientIdentity = null,
};
```

`Signer` should make private-key ownership explicit and allow the handshake code to request a signature for a negotiated TLS signature scheme without requiring the TLS state machine to own arbitrary application key storage.

## Milestones

### M0 — bootstrap and licensing

- Zig 0.16.0 minimum version
- MIT/Expat project license
- preserve Zig contributor notice for derived code
- package/build skeleton

### M1 — characterize Zig 0.16 behavior

- fixture that does not request a client certificate
- fixture that optionally requests a client certificate
- fixture that requires a client certificate
- capture TLS 1.2 and TLS 1.3 behavior separately
- regression test for the empty-certificate response already required by Bongo's SCRAM-over-TLS fixture

### M2 — certificate and key model

- parse/load certificate chain input
- define supported private-key/signing abstraction
- define supported signature schemes
- ownership and zeroization rules for secret key material

### M3 — TLS 1.3 client authentication

- parse `CertificateRequest`
- select certificate/signature scheme
- send client `Certificate`
- generate `CertificateVerify`
- update transcript correctly
- send `Finished`
- positive and negative interoperability tests

### M4 — TLS 1.2 client authentication

- parse TLS 1.2 certificate request fields
- send client certificate chain
- generate TLS 1.2 `CertificateVerify`
- preserve transcript ordering
- positive and negative interoperability tests

### M5 — reusable package API

- expose a stable transport/client boundary
- document allocator and I/O ownership
- macOS and Linux CI on Zig 0.16.0
- no MongoDB dependency

### M6 — Bongo adapter

- replace Bongo's private TLS compatibility patch with `zig-mtls`
- add a real MongoDB mTLS/X.509 integration fixture
- keep normal TLS+SCRAM behavior unchanged

### M7 — upstream proposal

- isolate the generic stdlib delta
- add Zig-style tests for optional/required client certificates
- propose the functionality upstream to Zig
- if/when Zig ships equivalent support, reduce `zig-mtls` to a compatibility layer or retire it

## Out of scope for the first implementation

- custom certificate stores unrelated to the client-auth requirement
- server-side TLS
- protocol-specific authentication such as MongoDB X.509 commands
- replacing Zig's crypto primitives
