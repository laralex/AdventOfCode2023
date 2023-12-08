const std = @import("std");

pub fn find_char_offset(string: []const u8, find_char: u8) usize {
    for (string, 0..) |char, offset| {
        if (char == find_char) {
            return offset;
        }
    }
    return std.math.maxInt(usize);
}

const Game = struct {
    const MAX_NUM_SETS: usize = 64;
    game_id: u32 = 0,
    num_sets: usize = 0,
    red_sets: [Game.MAX_NUM_SETS]u32 = undefined,
    green_sets: [Game.MAX_NUM_SETS]u32 = undefined,
    blue_sets: [Game.MAX_NUM_SETS]u32 = undefined,
};

pub fn parse_game(line_string: []const u8) !Game {
    var game_string = line_string;
    var game = Game{
        .red_sets = std.mem.zeroes([Game.MAX_NUM_SETS]u32),
        .green_sets = std.mem.zeroes([Game.MAX_NUM_SETS]u32),
        .blue_sets = std.mem.zeroes([Game.MAX_NUM_SETS]u32),
    };
    game_string = game_string["Game ".len..];
    const game_id_idx = find_char_offset(game_string, ':');
    //std.debug.print("{d}:{s}\n", .{ game_id_idx, game_string[0..game_id_idx] });
    game.game_id = try std.fmt.parseInt(u32, game_string[0..game_id_idx], 10);
    game_string = game_string[game_id_idx + 2 ..];
    game.num_sets = 1;
    while (game_string.len > 0) {
        const num_cubes_idx = find_char_offset(game_string, ' ');
        //std.debug.print("{d}:{s}\n", .{ num_cubes_idx, game_string[0..num_cubes_idx] });
        const num_cubes = try std.fmt.parseInt(u32, game_string[0..num_cubes_idx], 10);
        game_string = game_string[num_cubes_idx + 1 ..];
        inline for (.{ "red", "green", "blue" }, .{ &game.red_sets, &game.green_sets, &game.blue_sets }) |color_name, set_array| {
            if (game_string.len >= color_name.len and std.mem.eql(u8, game_string[0..color_name.len], color_name)) {
                set_array[game.num_sets - 1] = num_cubes;
                game_string = game_string[color_name.len..];
                break;
            }
        }
        if (game_string.len > 0) {
            if (game_string[0] == ';') {
                game.num_sets += 1;
            }
            game_string = game_string[2..];
        }
    }
    return game;
}

pub fn solve_1(file: *std.fs.File, verbose: bool) !u32 {
    _ = verbose;
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var answer: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const game = try parse_game(line);
        const max_red = 12;
        const max_green = 13;
        const max_blue = 14;
        var game_ok = true;
        for (game.red_sets, game.green_sets, game.blue_sets) |r, g, b| {
            if (r > max_red or g > max_green or b > max_blue) {
                game_ok = false;
                break;
            }
        }
        if (game_ok) {
            answer += game.game_id;
        }
    }
    return answer;
}

pub fn solve_2(file: *std.fs.File, verbose: bool) !u32 {
    _ = verbose;
    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var answer: u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const game = try parse_game(line);
        var max_red: u32 = 0;
        var max_green: u32 = 0;
        var max_blue: u32 = 0;
        for (game.red_sets[0..game.num_sets], game.green_sets[0..game.num_sets], game.blue_sets[0..game.num_sets]) |r, g, b| {
            max_red = @max(max_red, r);
            max_green = @max(max_green, g);
            max_blue = @max(max_blue, b);
        }
        answer += max_red * max_green * max_blue;
    }
    return answer;
}

pub fn main() !void {
    {
        var file = try std.fs.cwd().openFile("data/day2.txt", .{});
        defer file.close();
        std.debug.print("Answer part I: {d}\n", .{try solve_1(&file, false)});
    }
    {
        var file = try std.fs.cwd().openFile("data/day2.txt", .{});
        defer file.close();
        std.debug.print("Answer part II: {d}\n", .{try solve_2(&file, false)});
    }
}
