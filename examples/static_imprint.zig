

pub const std = @import("std");
pub const zzz = @import("zzz");

const dragon = @embedFile("../example-data/dragon.zzz");

// Default transformer can handle enums by name or integer.
pub const AttackType = enum {
    Slashing,
    Fire,
    Magic
};

// Imprinting performs zero allocations, so any arrays must be fixed.
pub const MAX_ATTACKS = 10;

pub const MAX_TYPES = 2;

pub const Attack = struct {
    name: []const u8 = "",
    types: [MAX_TYPES]?AttackType = [_]?AttackType{null} ** MAX_TYPES,
    damage: [2]i32 = [_]i32{0, 0},
    range: i32 = 0,
    description: []const u8 = "",
};

// Structs should have default values to be imprinted onto.
pub const Monster = struct {
    name: []const u8 = "",
    health: i32 = 0,
    attacks: [MAX_ATTACKS]?Attack = [_]?Attack{null} ** MAX_ATTACKS,
    // Structs can be partially filled to defer more complex or dynamic structures.
    complex: ?*const zzz.ZStaticNode = null,
};

pub fn main() !void {
    // The dragon has exactly 35 nodes.
    var tree = zzz.ZStaticTree(1, 35){};
    // Append the text to the tree. This creates a new root.
    var node = try tree.appendText(dragon);
    // Apply the default transformer which converts any nodes to floats, integers, or bools.
    try node.transform(void, {}, zzz.defaultTransformer);
    // Debug print.
    tree.show();

    var monster = Monster{};
    // Imprint takes a pointer to a node and a struct.
    try zzz.imprint(node, zzz.ImprintChecks{}, &monster);

    std.debug.print("Name: {}\n", .{monster.name});
    std.debug.print("Health: {}\n", .{monster.health});
    var i: usize = 0;
    while (monster.attacks[i]) |att| : (i += 1) {
        std.debug.print("  Attack: {}\n", .{att.name});
        std.debug.print("    Types: {} {}\n", .{att.types[0], att.types[1]});
        std.debug.print("    Damage: {} {}\n", .{att.damage[0], att.damage[1]});
        std.debug.print("    Range: {}\n", .{att.range});
        std.debug.print("    Description: {}\n\n", .{att.description});
    }
    monster.complex.?.show();
}
