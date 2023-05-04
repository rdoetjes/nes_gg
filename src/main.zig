const std = @import("std");
var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = general_purpose_allocator.allocator();
const stdout = std.io.getStdOut().writer();
const parseInt = std.fmt.parseInt;
const CHR = [_]u8{ 'A', 'P', 'Z', 'L', 'G', 'I', 'T', 'Y', 'E', 'O', 'X', 'U', 'K', 'S', 'V', 'N' };

pub fn encode_nes(addr: []const u8, data: []const u8, cmp: []const u8) !u32 {
    const address_u16 = try parseInt(u16, addr, 0);
    const data_u16 = try parseInt(u16, data, 0);

    var compare_u16: u16 = undefined;
    if (cmp.len > 0) compare_u16 = try parseInt(u16, cmp, 0);

    var gg: u32 = ((data_u16 & 0x80) >> 4) | (data_u16 & 0x7);
    var temp: u32 = ((address_u16 & 0x80) >> 4) | ((data_u16 & 0x70) >> 4);
    gg <<= 4;
    gg |= temp;

    temp = (address_u16 & 0x70) >> 4;
    if (cmp.len > 0) temp |= 0x8;
    gg <<= 4;
    gg |= temp;

    temp = (address_u16 & 0x8) | ((address_u16 & 0x7000) >> 12);
    gg <<= 4;
    gg |= temp;

    temp = ((address_u16 & 0x800) >> 8) | (address_u16 & 0x7);
    gg <<= 4;
    gg |= temp;

    if (cmp.len > 0) {
        temp = (compare_u16 & 0x8) | ((address_u16 & 0x700) >> 8);
        gg <<= 4;
        gg |= temp;

        temp = ((compare_u16 & 0x80) >> 4) | (compare_u16 & 0x7);
        gg <<= 4;
        gg |= temp;

        temp = (data_u16 & 0x8) | ((compare_u16 & 0x70) >> 4);
        gg <<= 4;
        gg |= temp;
    } else {
        temp = (data_u16 & 0x8) | ((address_u16 & 0x700) >> 8);
        gg <<= 4;
        gg |= temp;
    }

    return gg;
}

pub fn print_gg_nes(encoded: u32, eight: bool) !void {
    var i: u8 = undefined;
    if (eight) i = 7 else i = 5;
    while (i >= 0) : (i -= 1) {
        try stdout.print("{c}", .{CHR[(encoded >> (@truncate(u5, i) * 4) & 0xf)]});
        if (i == 0) break;
    }
    try stdout.print("\n", .{});
}

pub fn main() !void {
    var encoded: u32 = undefined;
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len < 3) {
        try stdout.print("Usage: {s} <0xaddress> <0xdata> [0xcmp]\nf.i. {s} 0x812f 0xbd\n", .{ args[0], args[0] });
        return;
    }

    if (args.len == 3) {
        encoded = encode_nes(args[1], args[2], "") catch |err| {
            try stdout.print("error: {}\n Input needs to be respectively, 0x[0000-ffff], 0x[00-ff]", .{err});
            return;
        };
        print_gg_nes(encoded, false) catch |err| {
            try stdout.print("error: {}\n whilst trying to print GG code", .{err});
            return;
        };
    }

    if (args.len == 4) {
        encoded = encode_nes(args[1], args[2], args[3]) catch |err| {
            try stdout.print("error: {}\n Input needs to be respectively, 0x[0000-ffff], 0x[00-ff] 0x[00-ff]", .{err});
            return;
        };

        print_gg_nes(encoded, true) catch |err| {
            try stdout.print("error: {}\n whilst trying to print GG code", .{err});
            return;
        };
    }
}
