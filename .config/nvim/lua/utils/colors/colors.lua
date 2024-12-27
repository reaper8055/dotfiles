local M = {}

function M.print_table(tbl, indent)
  indent = indent or 0
  local function print_indent() io.write(string.rep(" ", indent)) end

  if type(tbl) ~= "table" then
    print_indent()
    print("Input is not a table")
    return
  end

  print_indent()
  print("{")
  for key, value in pairs(tbl) do
    print_indent()
    if type(value) == "table" then
      print(key .. " = ")
      M.print_table(value, indent + 2)
    else
      print(key .. " = " .. tostring(value))
    end
  end
  print_indent()
  print("}")
end

-- Function to convert color from decimal to hexadecimal
function M.to_hex(color)
  if color then return string.format("#%06X", color) end
  -- Return nil if color is not set
  return nil
end

function M.get_hlg_colors(hlg_name)
  -- Check if the group_name is provided and is a string
  local hlg_name = hlg_name or "Normal"

  if type(hlg_name) ~= "string" then
    error("The highlight group name must be a string.")
    return nil
  end

  -- Get the properties of the highlight group
  local hlg = vim.api.nvim_get_hl_by_name(hlg_name, true)

  -- Function to convert color from decimal to hexadecimal
  local function to_hex(color)
    if color then return string.format("#%06X", color) end
    -- Return nil if color is not set
    return nil
  end

  -- Convert numerical colors to hexadecimal
  local colors = {
    fg = to_hex(hlg.foreground),
    bg = to_hex(hlg.background),
  }

  -- Include additional styling attributes if they exist
  for _, attr in ipairs({
    "bold",
    "italic",
    "underline",
    "undercurl",
    "strikethrough",
    "reverse",
    "inverse",
    "standout",
    "none",
  }) do
    if hlg[attr] then colors[attr] = hlg[attr] end
  end

  return colors
end

return M
