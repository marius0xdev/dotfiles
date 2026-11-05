-- Omarchy-style tweaks (see https://github.com/omacom/omarchy-lazyvim).
-- Neo-tree is enabled as a LazyVim extra in lazyvim.json.
return {
  -- Catppuccin Mocha matches the Ghostty theme (Omarchy uses its own theme system).
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
  {
    "folke/snacks.nvim",
    opts = {
      scroll = {
        enabled = false, -- Disable scrolling animations
      },
    },
  },
}
