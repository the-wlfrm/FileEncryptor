const std = @import("std");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    std.debug.print("{}", .{allocator});
    std.debug.print("{}", .{io});
}
