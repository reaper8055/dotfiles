return {
    cmd = { "pyright-langserver", "--stdio" }, -- Ensure this is on your PATH
    filetypes = { "python" },

    -- Project root detection (tweak to your taste)
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        ".git",
    },

    settings = {
        python = {
            analysis = {
                -- Turn this up/down depending on how masochistic you feel
                typeCheckingMode = "strict", -- "off" | "basic" | "strict"
                autoImportCompletions = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace", -- or "openFilesOnly"
                autoSearchPaths = true,
                indexDatabases = true,
                reportUnusedImport = "warning",
                reportUnusedVariable = "warning",
            },
        },
    },
}
