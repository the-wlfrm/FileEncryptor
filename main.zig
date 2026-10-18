const std = @import("std");
const crypto = std.crypto;

fn printInfo() void {
    std.debug.print(
        \\Использование: main -- [mode] [keyfile] [input_file] [output_file]
        \\Моды:
        \\  enc - Зашифровать файл
        \\  dec - Расшифровать файл
        \\
    , .{});
}

// fn encryptFile(in_path: []const u8, out_path: []const u8, key: [KeyLen]u8) !void {
//     //
// }

pub fn main(init: std.process.Init) !void {
    const allocator = init.arena.allocator();
    const io = init.io;

    var buf: [4096]u8 = undefined;
    var out = std.Io.File.stdout().writerStreaming(io, &buf);
    try out.interface.print("Soon...", .{});

    const args = try init.minimal.args.toSlice(allocator);

    if (args.len < 5) {
        printInfo();
        return;
    }
}
