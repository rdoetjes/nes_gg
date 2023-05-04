const std = @import("std");
var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = general_purpose_allocator.allocator();
const stdout = std.io.getStdOut().writer();
const parseInt = std.fmt.parseInt;
const CHR = [_]u8{ 'A', 'P', 'Z', 'L', 'G', 'I', 'T', 'Y', 'E', 'O', 'X', 'U', 'K', 'S', 'V', 'N' };

pub fn encode_nes_6(addr: []const u8, data: []const u8) !u24 {
    const address_u16 = try parseInt(u16, addr, 0);
    const data_u16 = try parseInt(u16, data, 0);

    var gg: u24 = ((data_u16 & 0x80) >> 4) | (data_u16 & 0x7);
    var temp: u24 = ((address_u16 & 0x80) >> 4) | ((data_u16 & 0x70) >> 4);
    gg <<= 4;
    gg |= temp;

    temp = (address_u16 & 0x70) >> 4;
    gg <<= 4;
    gg |= temp;

    temp = (address_u16 & 0x8) | ((address_u16 & 0x7000) >> 12);
    gg <<= 4;
    gg |= temp;

    temp = ((address_u16 & 0x800) >> 8) | (address_u16 & 0x7);
    gg <<= 4;
    gg |= temp;

    temp = (data_u16 & 0x8) | ((address_u16 & 0x700) >> 8);
    gg <<= 4;
    gg |= temp;

    return gg;
}

pub fn print_gg_nes_6(encoded: u24) !void {
    var i: u8 = 5;
    while (i >= 0) : (i -= 1) {
        try stdout.print("{c}", .{CHR[(encoded >> (@truncate(u5, i) * 4) & 0xf)]});
        if (i == 0) break;
    }
    try stdout.print("\n", .{});
}

pub fn main() !void {
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len < 3) {
        try stdout.print("Usage: {s} <0xaddress> <0xdata>\nf.i. {s} 0x812f 0xbd\n", .{ args[0], args[0] });
        return;
    }

    const encoded = encode_nes_6(args[1], args[2]) catch |err| {
        try stdout.print("error: {}\n Input needs to be respectively, 0x[0000-ffff], 0x[00-ff]", .{err});
        return;
    };

    print_gg_nes_6(encoded) catch |err| {
        try stdout.print("error: {}\n whilst trying to print GG code", .{err});
        return;
    };
}
