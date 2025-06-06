return {
  "windwp/nvim-autopairs",
  enabled = true,
  event = "InsertEnter",
  config = function()
    local autopairs_cmp = require("nvim-autopairs.completion.cmp")

    require("nvim-autopairs").setup({
      check_ts = true,
      ts_config = {
        lua = { "string", "source" },
        javascript = { "string", "template_string" },
        java = false,
      },
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0, -- Offset from pattern match
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "PmenuSel",
        highlight_grey = "LineNr",
      },
    })

    require("cmp").event:on(
      "confirm_done",
      autopairs_cmp.on_confirm_done({ map_char = { tex = "" } })
    )
  end,
}
