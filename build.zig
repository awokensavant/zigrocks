const version = @import("builtin").zig_version;
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = b.path("main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();
    exe.linkSystemLibrary("rocksdb");

    if (@hasDecl(@TypeOf(exe.*), "addLibraryPath")) {
        exe.addLibraryPath(b.path("./rocksdb/"));
        exe.addIncludePath(b.path("./rocksdb/include"));
    } else {
        exe.addLibraryPath(b.path("./rocksdb"));
        exe.addIncludePath(b.path("./rocksdb/include"));
    }

    if (exe.rootModuleTarget().isDarwin()) {
        b.installFile("./rocksdb/librocksdb.10.2.1.dylib", "../librocksdb.10.2.1.dylib");
        exe.addRPath(b.path("."));
    }

    b.installArtifact(exe);

    // And also the key-value store
    const kvExe = b.addExecutable(.{
        .name = "kv",
        .root_source_file = b.path("./rocksdb.zig"),
        .target = target,
        .optimize = optimize,
    });
    kvExe.linkLibC();
    kvExe.linkSystemLibrary("rocksdb");

    if (@hasDecl(@TypeOf(kvExe.*), "addLibraryPath")) {
        kvExe.addLibraryPath(b.path("./rocksdb"));
        kvExe.addIncludePath(b.path("./rocksdb/include"));
    } else {
        kvExe.addLibraryPath(b.path("./rocksdb"));
        kvExe.addIncludePath(b.path("./rocksdb/include"));
    }

    if (kvExe.rootModuleTarget().isDarwin()) {
        b.installFile("./rocksdb/librocksdb.10.2.1.dylib", "../librocksdb.10.2.1.dylib");
        kvExe.addRPath(b.path("."));
    }

    b.installArtifact(kvExe);
}
