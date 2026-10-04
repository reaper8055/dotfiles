-- =============================================================================
-- Deriving a Swift target triple, platform-agnostically
-- =============================================================================
--
-- The previous `cmd_env = { SWIFTFLAGS = ... }` did not work, and not because of
-- the hardcoded Linux triple -- sourcekit-lsp never reads SWIFTFLAGS at all.
-- The string does not appear anywhere in the binary:
--
--     strings "$(xcrun --find sourcekit-lsp)" | grep -i swiftflags   # no output
--
-- The supported mechanism is the `-Xswiftc` *command-line* flag ("Pass flag
-- through to all Swift compiler invocations", per `sourcekit-lsp --help`), so it
-- has to go in `cmd`, not in the environment.
--
-- This is opt-in rather than always-on, for two reasons:
--
--   1. This file is evaluated on EVERY nvim startup -- core/lsp.lua enables all
--      lsp/*.lua servers up front -- so shelling out unconditionally would add
--      ~130ms to every launch, including launches that never touch Swift.
--   2. Forcing -target where it is not needed is harmful. On a healthy toolchain
--      sourcekit-lsp infers the triple correctly, and on macOS an explicit
--      versioned triple (arm64-apple-macosx28.0) can override the deployment
--      target a SwiftPM package declares for itself.
--
-- Usage:
--   unset                        -> no -target; the host toolchain decides.
--                                   Correct on macOS and on a normal Linux install.
--   NVIM_SWIFT_TARGET=auto       -> ask the *active* swift for its own triple.
--                                   This is the platform-agnostic case: it picks
--                                   up whatever toolchain is in scope, which is
--                                   what the nix-shell wrapper needed.
--   NVIM_SWIFT_TARGET=<triple>   -> use that triple verbatim.

--- Ask the active Swift toolchain which target triple it defaults to.
--- Platform-agnostic by construction: the toolchain answers for itself rather
--- than us mapping uname -> triple and guessing.
--- @return string|nil triple, string|nil err
local function toolchain_target_triple()
    if vim.fn.executable("swift") ~= 1 then return nil, "no `swift` on PATH" end

    local proc = vim.system({ "swift", "-print-target-info" }, { text = true }):wait(5000)
    if proc.code ~= 0 then
        return nil, string.format("`swift -print-target-info` exited %d", proc.code)
    end

    local ok, info = pcall(vim.json.decode, proc.stdout)
    if not ok or type(info) ~= "table" or type(info.target) ~= "table" then
        return nil, "could not parse `swift -print-target-info` output"
    end

    -- `unversionedTriple` (arm64-apple-macosx) over `triple`
    -- (arm64-apple-macosx28.0): the unversioned form pins architecture and OS
    -- without also pinning a deployment version over the project's own.
    -- On Linux the two are identical (x86_64-unknown-linux-gnu).
    return info.target.unversionedTriple or info.target.triple
end

local cmd = { "sourcekit-lsp" }

local requested = vim.env.NVIM_SWIFT_TARGET
if requested and requested ~= "" then
    local triple, err
    if requested == "auto" then
        triple, err = toolchain_target_triple()
    else
        triple = requested
    end

    if triple then
        vim.list_extend(cmd, { "-Xswiftc", "-target", "-Xswiftc", triple })
    else
        vim.notify(
            ("sourcekit: NVIM_SWIFT_TARGET=auto but %s; falling back to the toolchain default"):format(
                err or "target detection failed"
            ),
            vim.log.levels.WARN,
            { title = "LSP" }
        )
    end
end

return {
    cmd = cmd,
    filetypes = { "swift" },

    -- Root detection: SwiftPM first, then git
    root_markers = {
        "Package.swift",
        ".git",
    },

    -- ORIGINAL, kept for review. Disabled because SWIFTFLAGS is not a thing
    -- sourcekit-lsp reads (see the header), and the triple was pinned to
    -- x86_64 Linux regardless of host.
    --
    -- If you're using a custom wrapper/alias for swift/swiftc in nix-shell,
    -- you want sourcekit-lsp to see the same target triple too.
    --
    -- This env is the practical hammer: it pushes flags to the compiler invocations
    -- that sourcekit-lsp triggers.
    -- cmd_env = {
    --     SWIFTFLAGS = "-target x86_64-unknown-linux-gnu",
    -- },

    -- SourceKit-LSP itself doesn't have a huge settings surface like pyright.
    -- Most behavior comes from Swift compiler flags + project structure (SwiftPM).
    settings = {},
}
