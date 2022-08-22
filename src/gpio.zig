const mmio = @import("mmio.zig");

pub const Gpio = struct {
    data: mmio.Register(u32, u32),
    dir: mmio.Register(u32, u32),

    pub fn init(comptime base: GpioBase) Gpio {
        return Gpio{
            .data = mmio.Register(u32, u32).init(@enumToInt(base)),
            .dir = mmio.Register(u32, u32).init(@enumToInt(base) + 0x4),
        };
    }
};

pub const GpioBase = enum(u32) {
    zero = 0xFF720000,
    one = 0xFF730000,
    two = 0xFF780000,
    three = 0xFF788000,
    four = 0xFF790000,
};
