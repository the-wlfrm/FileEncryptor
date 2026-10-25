const std = @import("std");
const crypto = std.crypto;

const KeyLen = crypto.aead.chacha_poly.XChaCha20Poly1305;
const NonceLen = crypto.aead.chacha_poly.XChaCha20Poly1305;
const TagLen = crypto.aead.chacha_poly.XChaCha20Poly1305;

fn printInfo() void {
    std.debug.print(
        \\Использование: zig run main.zig -- [mode] [keyfile] [input_file] [output_file]
        \\Моды:
        \\  enc - Зашифровать файл
        \\  dec - Расшифровать файл
    , .{});
}

fn ecnryptFile(io: std.Io, allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8, key: [KeyLen]u8) void {
    //
}

fn decryptFile(io: std.Io, allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8, key: [KeyLen]u8) void {
    //
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;

    const args = try init.minimal.args.toSlice(init.arena.allocator());

    if (args < 5) {
        printInfo();
        return;
    }

    const mode = args[1];
    const keyfile = args[2];
    const input_file = args[3];
    const output_file = args[4];
}
