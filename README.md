# zig-mtls

Experimental mutual-TLS client support for Zig 0.16.x.

`zig-mtls` exists because Zig 0.16.0's `std.crypto.tls.Client` can verify a server certificate and host name, but it does not expose the client-certificate/private-key handshake path required for mutual TLS. Bongo encountered this while implementing MongoDB `MONGODB-X509`, but this package is intentionally **not MongoDB-specific**.

## Status

Bootstrap / design phase. The package does **not** claim working mTLS yet.

The first supported target is Zig 0.16.0. The implementation will be kept generic enough to use from MongoDB, HTTP, SMTP, or any other TLS client protocol.

## Goals

- optional client certificate chain
- explicit private-key/signing ownership
- TLS 1.2 and TLS 1.3 `CertificateRequest` handling
- protocol-correct empty client `Certificate` response when no identity is configured and the server permits it
- client `Certificate` + `CertificateVerify` when an identity is configured
- CA-chain and host-name verification compatible with Zig's normal TLS client behavior
- tests against servers that do not request, optionally request, and require client certificates
- a small transport-facing API that Bongo can consume without MongoDB-specific code in this repository

## Non-goals

- MongoDB authentication commands or wire protocol
- HTTP semantics
- replacing Zig's entire TLS stack
- silently weakening certificate or host-name verification

## Implementation strategy

The initial design targets the active Zig 0.16 standard-library TLS client rather than inventing a second TLS implementation from scratch. Any Zig-derived source must retain Zig's MIT/Expat copyright and license notice. The long-term goal is to make the client-certificate work upstreamable to Zig so this package can shrink or disappear when the standard library exposes the required API.

See [`docs/design.md`](docs/design.md).

## License

MIT/Expat, intentionally matching Zig's project license to keep reuse and potential upstream contribution straightforward.

If source is copied or substantially derived from Zig, the original Zig contributor notice must be retained. See [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) and [`LICENSES/Zig-MIT.txt`](LICENSES/Zig-MIT.txt).
