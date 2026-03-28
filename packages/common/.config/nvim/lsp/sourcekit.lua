return {
    cmd = { "sourcekit-lsp" },
    filetypes = { "swift" },

    -- Root detection: SwiftPM first, then git
    root_markers = {
        "Package.swift",
        ".git",
    },

    -- If you're using a custom wrapper/alias for swift/swiftc in nix-shell,
    -- you want sourcekit-lsp to see the same target triple too.
    --
    -- This env is the practical hammer: it pushes flags to the compiler invocations
    -- that sourcekit-lsp triggers.
    cmd_env = {
        SWIFTFLAGS = "-target x86_64-unknown-linux-gnu",
    },

    -- SourceKit-LSP itself doesn't have a huge settings surface like pyright.
    -- Most behavior comes from Swift compiler flags + project structure (SwiftPM).
    settings = {},
}
