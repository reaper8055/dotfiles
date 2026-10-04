local home = os.getenv("HOME")

-- jdtls ships a separate `config_*` directory per platform and refuses to start
-- against the wrong one. This was hardcoded to "config_linux" on a Darwin/arm64
-- machine -- see the commented line further down.
local uname = vim.uv.os_uname()
local jdtls_config_dir = "config_linux"
if uname.sysname == "Darwin" then
    jdtls_config_dir = uname.machine == "arm64" and "config_mac_arm" or "config_mac"
elseif uname.sysname:find("Windows") then
    jdtls_config_dir = "config_win"
end

local workspace_path = home .. "/.local/share/nvim/jdtls-workspace/"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = workspace_path .. project_name

local status, jdtls = pcall(require, "jdtls")
if not status then return end
local extendedClientCapabilities = jdtls.extendedClientCapabilities

local config = {
    cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
        "-jar",
        vim.fn.glob(
            home
                .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"
        ),
        "-configuration",
        -- was: home .. "/.local/share/nvim/mason/packages/jdtls/config_linux",
        -- Hardcoded Linux path; this machine is Darwin/arm64, so jdtls would
        -- have been pointed at a config directory that does not exist.
        home .. "/.local/share/nvim/mason/packages/jdtls/" .. jdtls_config_dir,
        "-data",
        workspace_dir,
    },
    root_dir = require("jdtls.setup").find_root({
        ".git",
        "mvnw",
        "gradlew",
        "pom.xml",
        "build.gradle",
    }),

    settings = {
        java = {
            signatureHelp = { enabled = true },
            extendedClientCapabilities = extendedClientCapabilities,
            maven = {
                downloadSources = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            inlayHints = {
                parameterNames = {
                    enabled = "all", -- literals, all, none
                },
            },
            format = {
                enabled = false,
            },
        },
    },

    init_options = {
        bundles = {},
    },
}
require("jdtls").start_or_attach(config)

vim.keymap.set(
    "n",
    "<leader>co",
    "<Cmd>lua require'jdtls'.organize_imports()<CR>",
    { desc = "Organize Imports" }
)
vim.keymap.set(
    "n",
    "<leader>crv",
    "<Cmd>lua require('jdtls').extract_variable()<CR>",
    { desc = "Extract Variable" }
)
vim.keymap.set(
    "v",
    "<leader>crv",
    "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>",
    { desc = "Extract Variable" }
)
vim.keymap.set(
    "n",
    "<leader>crc",
    "<Cmd>lua require('jdtls').extract_constant()<CR>",
    { desc = "Extract Constant" }
)
vim.keymap.set(
    "v",
    "<leader>crc",
    "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>",
    { desc = "Extract Constant" }
)
vim.keymap.set(
    "v",
    "<leader>crm",
    "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>",
    { desc = "Extract Method" }
)
