return {
  "lukas-reineke/indent-blankline.nvim",
  config = function()
    local highlight = {
      "LightGray",
    }

    local hooks = require("ibl.hooks")
    hooks.register(
      hooks.type.HIGHLIGHT_SETUP,
      function() vim.api.nvim_set_hl(0, "LightGray", { fg = "#ABB2BF" }) end
    )

    require("ibl").setup({
      indent = {
        char = "│",
        tab_char = "│",
        -- char = "┃",
        smart_indent_cap = true,
      },
      scope = {
        highlight = highlight,
        injected_languages = false,
        show_start = false,
        show_end = false,
        include = {
          node_type = {
            ["*"] = { "*" },
          },
        },
      },
    })
  end,
}
