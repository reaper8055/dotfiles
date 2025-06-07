-- Dev Containers plugin
local M = {}

-- Window and buffer handling
local function create_float()
  -- Calculate window size (80% of editor size)
  local width = math.floor(vim.api.nvim_get_option("columns") * 0.8)
  local height = math.floor(vim.api.nvim_get_option("lines") * 0.8)

  -- Calculate starting position
  local row = math.floor((vim.api.nvim_get_option("lines") - height) / 2)
  local col = math.floor((vim.api.nvim_get_option("columns") - width) / 2)

  -- Create a new buffer for the float
  local buf = vim.api.nvim_create_buf(false, true)

  -- Buffer options
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "modifiable", true)

  -- Window options
  local opts = {
    style = "minimal",
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    border = "rounded",
    title = " DevContainer Progress ",
    title_pos = "center",
  }

  -- Create and return window handle
  local win = vim.api.nvim_open_win(buf, true, opts)
  vim.api.nvim_win_set_option(win, "wrap", true)
  vim.api.nvim_win_set_option(win, "cursorline", true)

  -- Add keymaps for the float window
  vim.api.nvim_buf_set_keymap(buf, "n", "q", ":close<CR>", { noremap = true, silent = true })
  vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":close<CR>", { noremap = true, silent = true })

  return {
    buf = buf,
    win = win,
  }
end

-- Function to update float content
local function update_float(float, content)
  if vim.api.nvim_win_is_valid(float.win) then
    vim.api.nvim_buf_set_option(float.buf, "modifiable", true)
    vim.api.nvim_buf_set_lines(float.buf, -1, -1, false, { content })
    vim.api.nvim_buf_set_option(float.buf, "modifiable", false)
    -- Scroll to bottom
    vim.api.nvim_win_set_cursor(float.win, { vim.api.nvim_buf_line_count(float.buf), 0 })
  end
end

-- Execute command and stream output to float
local function exec_with_output(cmd, float)
  update_float(float, "Running: " .. cmd)
  update_float(float, "")

  -- Create temporary files for output
  local stdout_file = os.tmpname()
  local stderr_file = os.tmpname()

  -- Modify command to redirect output
  local full_cmd = string.format("%s > %s 2> %s", cmd, stdout_file, stderr_file)

  -- Run command
  local exit_code = os.execute(full_cmd)

  -- Read output files
  local stdout = io.open(stdout_file, "r")
  local stderr = io.open(stderr_file, "r")

  if stdout then
    for line in stdout:lines() do
      update_float(float, line)
    end
    stdout:close()
  end

  if stderr then
    update_float(float, "")
    update_float(float, "Errors/Warnings:")
    for line in stderr:lines() do
      update_float(float, line)
    end
    stderr:close()
  end

  -- Clean up temp files
  os.remove(stdout_file)
  os.remove(stderr_file)

  update_float(float, "")
  update_float(float, string.format("Command finished with exit code: %s", exit_code))

  return exit_code
end

-- Get list of running containers
local function get_containers()
  local handle = io.popen('docker ps --format "{{.Names}}"')
  local result = handle:read("*a")
  handle:close()

  local containers = {}
  for name in result:gmatch("[^\n]+") do
    table.insert(containers, name)
  end
  return containers
end

-- Prompt user for input with vim.ui
local function prompt_input(title, callback)
  vim.ui.input({
    prompt = title,
    default = "",
  }, function(input)
    if input then callback(input) end
  end)
end

-- Prompt user to select from list with vim.ui
local function prompt_select(title, items, callback)
  vim.ui.select(items, {
    prompt = title,
    format_item = function(item) return item end,
  }, function(choice)
    if choice then callback(choice) end
  end)
end

-- Function to find git root directory
local function find_git_root()
  local float = create_float()
  update_float(float, "Looking for git root...")

  local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if handle then
    local result = handle:read("*a")
    handle:close()
    local root = result:gsub("%s+$", "")
    update_float(float, "Found git root: " .. root)
    return root, float
  end

  update_float(float, "Error: Not in a git repository")
  return nil, float
end

-- Function to start container with custom name
local function start_container(config, project_root, container_name, float)
  -- Check if container exists
  local check_cmd =
    string.format('docker ps -a --filter "name=%s" --format "{{.Names}}"', container_name)
  update_float(float, "Checking for existing container...")
  local handle = io.popen(check_cmd)
  local existing = handle:read("*a")
  handle:close()

  if existing:find(container_name) then
    update_float(float, "Container exists, starting it...")
    exec_with_output(string.format("docker start %s", container_name), float)
  else
    update_float(float, "Creating new container...")
    local cmd = string.format(
      "docker run -d --name %s -v %s:%s ubuntu:24.04 tail -f /dev/null",
      container_name,
      project_root,
      config.workspaceFolder
    )
    exec_with_output(cmd, float)
  end

  return container_name
end

-- Main function to initialize devcontainer
function M.init()
  local root_dir, float = find_git_root()
  if not root_dir then return end

  -- Basic config (you can expand this to read from devcontainer.json)
  local config = {
    image = "ubuntu:24.04",
    workspaceFolder = "/workspace",
  }

  -- Prompt for container name
  prompt_input(
    "Enter container name (default: devcontainer-" .. root_dir:match("([^/]+)$") .. "): ",
    function(input)
      local container_name = input ~= "" and input or "devcontainer-" .. root_dir:match("([^/]+)$")
      local started_container = start_container(config, root_dir, container_name, float)
      update_float(float, "DevContainer initialized: " .. started_container)

      -- Store container info
      M.current_container = started_container
      M.workspace_folder = config.workspaceFolder
    end
  )
end

-- Function to attach to existing container
function M.attach()
  local containers = get_containers()
  if #containers == 0 then
    vim.notify("No running containers found", vim.log.levels.ERROR)
    return
  end

  prompt_select("Select container to attach to:", containers, function(container_name)
    M.current_container = container_name
    -- Try to detect workspace folder from container
    local handle = io.popen(
      string.format(
        'docker inspect --format "{{range .Mounts}}{{.Destination}}{{end}}" %s',
        container_name
      )
    )
    local workspace = handle:read("*a")
    handle:close()

    M.workspace_folder = workspace ~= "" and workspace or "/workspace"
    vim.notify("Attached to container: " .. container_name)
  end)
end

-- Function to open terminal in container
function M.open_terminal()
  if not M.current_container then
    vim.notify("No active devcontainer", vim.log.levels.ERROR)
    return
  end

  -- Create new buffer with terminal
  vim.cmd("new") -- Open new split
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_name(buf, "DevContainer Terminal")

  -- Start terminal with docker exec
  local term_cmd = string.format("docker exec -it %s /bin/bash", M.current_container)
  vim.fn.termopen(term_cmd, {
    on_exit = function() vim.cmd("bdelete!") end,
  })

  -- Enter insert mode automatically
  vim.cmd("startinsert")
end

-- Function to edit file in container
function M.edit_file(file_path)
  if not M.current_container or not M.workspace_folder then
    vim.notify("No active devcontainer", vim.log.levels.ERROR)
    return
  end

  -- Convert local path to container path
  local root_dir = find_git_root()
  local relative_path = file_path:gsub(root_dir .. "/", "")
  local container_path = M.workspace_folder .. "/" .. relative_path

  -- Open file in new buffer
  vim.cmd("edit " .. file_path)
end

-- Function to cleanup container
function M.cleanup()
  if not M.current_container then
    print("No active devcontainer")
    return
  end

  local float = create_float()
  update_float(float, "Cleaning up container: " .. M.current_container)

  exec_with_output(string.format("docker stop %s", M.current_container), float)
  exec_with_output(string.format("docker rm %s", M.current_container), float)

  M.current_container = nil
  M.workspace_folder = nil

  update_float(float, "DevContainer cleaned up successfully")
end

-- Add this function to open neovim in container terminal
function M.open_editor()
  if not M.current_container then
    vim.notify("No active devcontainer", vim.log.levels.ERROR)
    return
  end

  -- Debug prints
  print("Current container:", M.current_container)
  print("Workspace folder:", M.workspace_folder)

  -- Build the container command
  local container_cmd = string.format(
    "docker exec -it %s /bin/bash -c 'nvim %s'",
    M.current_container,
    M.workspace_folder
  )
  print("Container command:", container_cmd)

  -- Check if we're in tmux
  local in_tmux = os.getenv("TMUX") ~= nil
  print("In tmux:", in_tmux)

  local term_cmd
  if in_tmux then
    -- Create new tmux window with the container command
    term_cmd = string.format("tmux new-window %s", container_cmd)
  else
    if vim.fn.executable("wezterm") == 1 then
      term_cmd = string.format("wezterm start --new-tab -- bash -c %s", container_cmd)
    elseif vim.fn.executable("kitty") == 1 then
      term_cmd = string.format("kitty @ new-tab bash -c %s", container_cmd)
    elseif vim.fn.executable("alacritty") == 1 then
      term_cmd = string.format("alacritty --command bash -c %s", container_cmd)
    else
      term_cmd = string.format("x-terminal-emulator -e bash -c %s", container_cmd)
    end
  end
  print("Terminal command:", term_cmd)

  -- Execute the command directly with os.execute to see output
  local success, exit_type, code = os.execute(term_cmd)
  print("Command result:", success, exit_type, code)

  if not success then
    vim.notify("Failed to open terminal: " .. (code or "unknown error"), vim.log.levels.ERROR)
  end
end

-- Create a dashboard for dev container operations
local function create_dashboard()
  local dashboard = create_float()

  -- Available commands
  local commands = {
    { label = "Initialize New Container", cmd = "init" },
    { label = "Attach to Existing Container", cmd = "attach" },
    { label = "Open Terminal in Container", cmd = "terminal" },
    { label = "Open Editor in Container", cmd = "editor" },
    { label = "Cleanup Container", cmd = "cleanup" },
    { label = "Exit", cmd = "exit" },
  }

  -- Set buffer options
  vim.api.nvim_buf_set_option(dashboard.buf, "modifiable", true)

  -- Create the header
  local header = {
    "",
    "  Dev Container Operations",
    "  ───────────────────────",
    "",
  }

  -- Create the command list with numbers
  local content = {}
  for i, cmd in ipairs(commands) do
    table.insert(content, string.format("  %d. %s", i, cmd.label))
  end

  -- Add footer
  local footer = {
    "",
    "  Press number to select operation",
    "",
  }

  -- Combine all content
  local final_content = vim.list_extend(header, content)
  final_content = vim.list_extend(final_content, footer)

  -- Set the content
  vim.api.nvim_buf_set_lines(dashboard.buf, 0, -1, false, final_content)
  vim.api.nvim_buf_set_option(dashboard.buf, "modifiable", false)

  -- Add keymaps for selection
  for i, cmd in ipairs(commands) do
    vim.api.nvim_buf_set_keymap(
      dashboard.buf,
      "n",
      tostring(i),
      string.format(":lua require('devcontainer').execute_command('%s')<CR>", cmd.cmd),
      { noremap = true, silent = true }
    )
  end

  -- Add keymap for closing
  vim.api.nvim_buf_set_keymap(
    dashboard.buf,
    "n",
    "q",
    ":close<CR>",
    { noremap = true, silent = true }
  )
  vim.api.nvim_buf_set_keymap(
    dashboard.buf,
    "n",
    "<Esc>",
    ":close<CR>",
    { noremap = true, silent = true }
  )

  return dashboard
end

-- Function to execute selected command
function M.execute_command(cmd)
  if cmd == "exit" then
    vim.cmd("close")
    return
  end

  -- Close the dashboard
  vim.cmd("close")

  -- Execute the selected command
  if cmd == "init" then
    M.init()
  elseif cmd == "attach" then
    M.attach()
  elseif cmd == "terminal" then
    M.open_terminal()
  elseif cmd == "editor" then
    M.open_editor()
  elseif cmd == "cleanup" then
    M.cleanup()
  end
end

-- Main entry point for the plugin
function M.show_dashboard() create_dashboard() end

local function show_main_menu()
  local commands = {
    { label = "Initialize New Container", cmd = "init" },
    { label = "Attach to Existing Container", cmd = "attach" },
    { label = "Open Terminal in Container", cmd = "terminal" },
    { label = "Open Editor in Container", cmd = "editor" },
    { label = "Cleanup Container", cmd = "cleanup" },
  }

  vim.ui.select(commands, {
    prompt = "Select DevContainer Operation:",
    format_item = function(item) return item.label end,
  }, function(choice)
    if choice then
      -- Execute the selected command
      if choice.cmd == "init" then
        M.init()
      elseif choice.cmd == "attach" then
        M.attach()
      elseif choice.cmd == "terminal" then
        M.open_terminal()
      elseif choice.cmd == "editor" then
        M.open_editor()
      elseif choice.cmd == "cleanup" then
        M.cleanup()
      end
    end
  end)
end

-- Add this to the M table
function M.show_menu() show_main_menu() end

return M
