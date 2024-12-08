return {
  dir = vim.fn.stdpath("config") .. "/lua/dev-containers",
  name = "dev-containers",
  opts = {},
  config = function()
    -- Main menu command
    vim.api.nvim_create_user_command(
      "Devcontainer",
      function() require("dev-containers").show_menu() end,
      {}
    )
    vim.api.nvim_create_user_command(
      "DevcontainerEditor",
      function() require("dev-containers").open_editor() end,
      {}
    )
    vim.api.nvim_create_user_command(
      "DevcontainerRemoteEdit",
      function() require("dev-containers").remote_edit() end,
      {}
    )
    vim.api.nvim_create_user_command(
      "DevcontainerInit",
      function() require("dev-containers").init() end,
      {}
    )

    vim.api.nvim_create_user_command(
      "DevcontainerInit",
      function() require("dev-containers").init() end,
      {}
    )

    vim.api.nvim_create_user_command(
      "DevcontainerAttach",
      function() require("dev-containers").attach() end,
      {}
    )

    vim.api.nvim_create_user_command(
      "DevcontainerTerminal",
      function() require("dev-containers").open_terminal() end,
      {}
    )

    vim.api.nvim_create_user_command(
      "DevcontainerEdit",
      function(opts) require("dev-containers").edit_file(opts.args) end,
      {
        nargs = 1,
        complete = "file",
      }
    )

    vim.api.nvim_create_user_command(
      "DevcontainerCleanup",
      function() require("dev-containers").cleanup() end,
      {}
    )
  end,
}
