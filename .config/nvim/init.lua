P = function(v)
  print(vim.inspect(v))
  return v
end

vim.env.PATH = vim.env.VIM_PATH or vim.env.PATH

require("core")
