const std = @import("std");

pub fn parse_digit(string: []const u8, parse_names: bool) ?struct { digit: u8, offset: usize } {
    if (string.len == 0) {
        return null;
    }
    if (std.ascii.isDigit(string[0])) {
        return .{ .digit = string[0] - '0', .offset = 1 };
    }
    if (parse_names) {
        // one two three four five six seven eight nine
        inline for (.{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" }, 1..) |str_digit, digit| {
            const len = str_digit.len;
            if (string.len >= len and std.mem.eql(u8, string[0..len], str_digit)) {
                return .{ .digit = digit, .offset = len };
            }
        }
    }
    return null;
}

const Part = enum { Part1, Part2 };
pub fn solve(file: *std.fs.File, part: Part, verbose: bool) !u32 {
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var answer: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var idx: usize = 0;
        const parse_names = part == Part.Part2;
        while (parse_digit(line[idx..], parse_names) == null) : (idx += 1) {}
        const first_digit = parse_digit(line[idx..], parse_names).?.digit;

        idx = line.len - 1;
        while (parse_digit(line[idx..], parse_names) == null) : (idx -= 1) {}
        const last_digit = parse_digit(line[idx..], parse_names).?.digit;

        const calibration_value = @as(u32, first_digit) * 10 + last_digit;
        answer += calibration_value;
        if (verbose) {
            std.debug.print("{d} ", .{calibration_value});
        }
    }
    return answer;
}

pub fn main() !void {
    {
        var file = try std.fs.cwd().openFile("data/day1.txt", .{});
        defer file.close();
        std.debug.print("Answer part I: {d}\n", .{try solve(&file, Part.Part1, false)});
    }
    {
        var file = try std.fs.cwd().openFile("data/day1.txt", .{});
        defer file.close();
        std.debug.print("Answer part II: {d}\n", .{try solve(&file, Part.Part2, false)});
    }
}
