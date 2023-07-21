const std = @import("std");
var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = general_purpose_allocator.allocator();
const stdout = std.io.getStdOut().writer();
const parseInt = std.fmt.parseInt;

//this is unique to the NES!
fn encode_nes(addr: []const u8, data: []const u8, cmp: []const u8) !u32 {
    const address_u16 = try parseInt(u16, addr, 0);
    const data_u16 = try parseInt(u16, data, 0);

    var compare_u16: u16 = undefined;
    if (cmp.len > 0) compare_u16 = try parseInt(u16, cmp, 0);

    var gg: u32 = ((data_u16 & 0x80) >> 4) | (data_u16 & 0x7);
    gg <<= 4;
    gg |= ((address_u16 & 0x80) >> 4) | ((data_u16 & 0x70) >> 4);
    gg <<= 4;
    gg |= (address_u16 & 0x70) >> 4;

    if (cmp.len > 0) gg |= 0x8;

    gg <<= 4;
    gg |= (address_u16 & 0x8) | ((address_u16 & 0x7000) >> 12);
    gg <<= 4;
    gg |= ((address_u16 & 0x800) >> 8) | (address_u16 & 0x7);

    if (cmp.len > 0) {
        gg <<= 4;
        gg |= (compare_u16 & 0x8) | ((address_u16 & 0x700) >> 8);
        gg <<= 4;
        gg |= ((compare_u16 & 0x80) >> 4) | (compare_u16 & 0x7);
        gg <<= 4;
        gg |= (data_u16 & 0x8) | ((compare_u16 & 0x70) >> 4);
    } else {
        gg <<= 4;
        gg |= (data_u16 & 0x8) | ((address_u16 & 0x700) >> 8);
    }

    return gg;
}

//this char array is unique to the nes. If you would want to implement this foranother platform
//you should pass in the const array of chars as an argument, as the print logic remains the same
pub fn print_gg_nes(encoded: u32, is_eight: bool) !void {
    const CHR = [_]u8{ 'A', 'P', 'Z', 'L', 'G', 'I', 'T', 'Y', 'E', 'O', 'X', 'U', 'K', 'S', 'V', 'N' };
    var i: u5 = undefined;

    if (is_eight) i = 7 else i = 5;
    while (i > 0) : (i -= 1) {
        try stdout.print("{c}", .{CHR[(encoded >> i * 4 & 0xf)]});
    } else {
        try stdout.print("{c}", .{CHR[(encoded >> i * 4 & 0xf)]});
        try stdout.print("\n", .{});
    }
}

//this is the wrapper function that calls the encoding function and the print function on the encoding functio return value
pub fn gg_nes(addr: []const u8, data: []const u8, cmp: []const u8) !void {
    var encoded: u32 = undefined;

    var is_eight: bool = undefined;
    if (cmp.len > 0) is_eight = true else is_eight = false;

    if (!is_eight) {
        encoded = encode_nes(addr, data, "") catch |err| {
            try stdout.print("error: {}\n   Input needs to be  in range of 0x[8000-ffff] 0x[00-ff]\n", .{err});
            return;
        };
    } else {
        encoded = encode_nes(addr, data, cmp) catch |err| {
            try stdout.print("error: {}\n   Input needs to be  in range of 0x[8000-ffff] 0x[00-ff] 0x[00-ff]\n", .{err});
            return;
        };
    }

    print_gg_nes(encoded, is_eight) catch |err| {
        try stdout.print("error: {}\n whilst trying to pring GG code\n", .{err});
        return;
    };
}

fn is_hex_notation(value: []const u8) bool {
    return std.mem.startsWith(u8, value, "0x");
}

pub fn main() !void {
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);

    if (args.len < 3 or args.len > 4) {
        try stdout.print("Usage: {s} <0xaddress> <0xdata> [0xcompare]\nf.i (6 char code): {s} 0xf12d 0xdd\nf.i (8 char code) {s} 0xf12d 0xdd 0xf0\n", .{ args[0], args[0], args[0] });
        return;
    }

    if (!is_hex_notation(args[1]) or !is_hex_notation(args[2])) {
        try stdout.print("Address and data value needs to be in hex format and should start with 0x\n", .{});
        return;
    }

    if (args.len == 3) try gg_nes(args[1], args[2], "");

    if (args.len == 4) {
        if (!is_hex_notation(args[3])) {
            try stdout.print("Compare value needs to be in hex format and should start with 0x\n", .{});
            return;
        }
        try gg_nes(args[1], args[2], args[3]);
    }
}
