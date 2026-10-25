const std = @import("std");
const crypto = std.crypto;

const KeyLen = crypto.aead.chacha_poly.XChaCha20Poly1305.key_length;
const NonceLen = crypto.aead.chacha_poly.XChaCha20Poly1305.nonce_length;
const TagLen = crypto.aead.chacha_poly.XChaCha20Poly1305.tag_length;

fn printInfo() void {
    std.debug.print(
        \\Использование: zig run main.zig -- [mode] [keyfile] [input_file] [output_file]
        \\Моды:
        \\  enc - Зашифровать файл
        \\  dec - Расшифровать файл
    , .{});
}

fn encryptFile(io: std.Io, allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8, key: [KeyLen]u8) !void {
    const in_file = try std.Io.Dir.cwd().openFile(io, input_path, .{});
    defer in_file.close(io);

    const stat = try in_file.stat(io);
    const plaintext = try allocator.alloc(u8, stat.size);
    defer allocator.free(plaintext);

    _ = try in_file.readPositionalAll(io, plaintext, 0);

    var nonce: [NonceLen]u8 = undefined;
    io.random(&nonce);

    const ciphertext = try allocator.alloc(u8, plaintext.len);
    defer allocator.free(ciphertext);
    var tag: [TagLen]u8 = undefined;

    crypto.aead.chacha_poly.XChaCha20Poly1305.encrypt(
        ciphertext,
        &tag,
        plaintext,
        "",
        nonce,
        key,
    );

    const out_file = try std.Io.Dir.cwd().createFile(io, output_path, .{});
    defer out_file.close(io);

    try out_file.writeStreamingAll(io, &nonce);
    try out_file.writeStreamingAll(io, ciphertext);
    try out_file.writeStreamingAll(io, &tag);
}

fn decryptFile(io: std.Io, allocator: std.mem.Allocator, input_path: []const u8, output_path: []const u8, key: [KeyLen]u8) !void {
    const in_file = try std.Io.Dir.cwd().openFile(io, input_path, .{});
    defer in_file.close(io);

    const stat = try in_file.stat(io);
    const file_size = stat.size;
    if (file_size < NonceLen + TagLen) return error.EncryptedFileTooShort;

    var nonce: [NonceLen]u8 = undefined;
    _ = try in_file.readPositionalAll(io, &nonce, 0);

    const ciphertext_len = file_size - NonceLen - TagLen;
    const ciphertext = try allocator.alloc(u8, ciphertext_len);
    defer allocator.free(ciphertext);
    _ = try in_file.readPositionalAll(io, ciphertext, NonceLen);

    var tag: [TagLen]u8 = undefined;
    const tag_offset = file_size - TagLen;
    _ = try in_file.readPositionalAll(io, &tag, tag_offset);

    const plaintext = try allocator.alloc(u8, ciphertext_len);
    defer allocator.free(plaintext);

    crypto.aead.chacha_poly.XChaCha20Poly1305.decrypt(
        plaintext,
        ciphertext,
        tag,
        "",
        nonce,
        key,
    ) catch |err| {
        return err;
    };
    const out_file = try std.Io.Dir.cwd().createFile(io, output_path, .{});
    defer out_file.close(io);
    try out_file.writeStreamingAll(io, plaintext);
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
    const key_path = args[2];
    const input_path = args[3];
    const output_path = args[4];

    var key: [KeyLen]u8 = undefined;
    var key_file = try std.Io.File.cwd().openFile(io, key_path, .{});
    defer key_file.close(io);

    var key_buf: [KeyLen]u8 = undefined;
    var key_reader = key_file.reader(io, &key_buf);
    try key_reader.interface.readSliceAll(&key);

    if (std.mem.eql(u8, mode, "enc")) {
        try encryptFile(io, allocator, input_path, output_path, key);
        std.debug.print("Файл успешно зашифрован! ({s})\n", .{output_path});
    } else if (std.mem.eql(u8, mode, "dec")) {
        try decryptFile(io, allocator, input_path, output_path, key);
        std.debug.print("Файл успешно расифрован! ({s})\n", .{output_path});
    } else {
        printInfo();
    }
}
