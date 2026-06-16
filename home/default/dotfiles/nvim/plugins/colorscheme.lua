local f = io.open(os.getenv("HOME") .. "/.cache/nvim-colorscheme", "r")
local scheme = f and f:read("*l") or "rose-pine-moon"
if f then f:close() end

return {
  { "rose-pine/neovim", name = "rose-pine" },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = scheme },
  },
}
