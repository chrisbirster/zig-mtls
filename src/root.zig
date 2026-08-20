const std = @import("std");

/// zig-mtls is still in its bootstrap/design phase. These types establish the
/// intended generic boundary without claiming that client-certificate TLS is
/// implemented yet.
pub const ClientIdentity = struct {
    certificate_chain_pem: []const u8,
    private_key_pem: []const u8,
};

pub const Options = struct {
    client_identity: ?ClientIdentity = null,
};

test "client identity is optional" {
    const options: Options = .{};
    try std.testing.expect(options.client_identity == null);
}

test "client identity keeps certificate and key inputs explicit" {
    const identity: ClientIdentity = .{
        .certificate_chain_pem = "certificate",
        .private_key_pem = "private-key",
    };
    const options: Options = .{ .client_identity = identity };

    try std.testing.expectEqualStrings(
        "certificate",
        options.client_identity.?.certificate_chain_pem,
    );
    try std.testing.expectEqualStrings(
        "private-key",
        options.client_identity.?.private_key_pem,
    );
}
