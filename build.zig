const std = @import("std");
const Build = std.Build;

pub const targets: []const std.Target.Query = &.{
    .{ .cpu_arch = .x86, .os_tag = .linux, .abi = .gnu },
    .{ .cpu_arch = .x86, .os_tag = .linux, .abi = .musl },
    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .gnu },
    .{ .cpu_arch = .x86_64, .os_tag = .linux, .abi = .musl },
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .gnu },
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .musl },

    .{ .cpu_arch = .x86_64, .os_tag = .macos },
    .{ .cpu_arch = .aarch64, .os_tag = .macos },

    .{ .cpu_arch = .x86_64, .os_tag = .windows },
    .{ .cpu_arch = .aarch64, .os_tag = .windows },
};

pub fn build(b: *Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libyaml = b.addLibrary(.{
        .name = "yaml",
        .linkage = .static,
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        })
    });
    libyaml.root_module.addCMacro("YAML_VERSION_MAJOR", "0");
    libyaml.root_module.addCMacro("YAML_VERSION_MINOR", "2");
    libyaml.root_module.addCMacro("YAML_VERSION_PATCH", "5");
    libyaml.root_module.addCMacro("YAML_VERSION_STRING", "\"0.2.5\"");
    libyaml.root_module.addCMacro("YAML_DECLARE_STATIC", "1");
    libyaml.root_module.addIncludePath(b.path("include"));
    libyaml.root_module.addCSourceFiles(.{
        .files = &.{
            "src/api.c",
            "src/dumper.c",
            "src/emitter.c",
            "src/loader.c",
            "src/parser.c",
            "src/reader.c",
            "src/scanner.c",
            "src/writer.c",
        },
        .flags = &.{},
    });
    libyaml.installHeader(b.path("include/yaml.h"), "yaml.h");
    b.installArtifact(libyaml);

    // c-packages requires a test step, but it does nothing for this project
    // right now.
    _ = b.step("test", "Run tests");
}
