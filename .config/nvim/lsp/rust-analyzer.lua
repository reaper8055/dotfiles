return {
    cmd = { "rust-analyzer" },
    filetypes = { "rust" },
    root_markers = { "Cargo.toml", "rust-project.json", ".git" },

    settings = {
        ["rust-analyzer"] = {
            cargo = {
                allTargets = true,
                buildScripts = {
                    enable = true,
                },
            },

            procMacro = {
                enable = true,
            },

            check = {
                command = "clippy",
            },

            diagnostics = {
                enable = true,
                experimental = true,
            },

            completion = {
                autoself = {
                    enable = true,
                },
                autoimport = {
                    enable = true,
                },
            },

            inlayHints = {
                parameterHints = {
                    enable = false,
                },
                typeHints = {
                    hideClosureInitialization = false,
                    hideNamedConstructorHints = false,
                },
                closureReturnTypeHints = {
                    enable = "never",
                },
                lifetimeElisionHints = {
                    enable = "never",
                    useParameterNames = false,
                },
            },
        },
    },
}
