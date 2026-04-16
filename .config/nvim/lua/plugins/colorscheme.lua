return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "moon",
      dark_variant = "moon",
      styles = {
        transparency = false,
      },
      palette = {
        moon = {
          base = "#13131D",
          overlay = "#1e1e2e",
        },
      },
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "rose-pine-moon",
    },
  },
}
