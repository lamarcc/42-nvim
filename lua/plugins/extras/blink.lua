return {
  "saghen/blink.cmp",
  build = "cargo build --release",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = {
      preset = "default",
      ["<Up>"]     = { "fallback" },
      ["<Down>"]   = { "fallback" },
      ["<C-Up>"]   = { "select_prev", "fallback" },
      ["<C-Down>"] = { "select_next", "fallback" },
      ["<S-Tab>"]  = { "snippet_backward", "fallback" },
      ["<Tab>"]    = { "snippet_forward", "fallback" },
      ["<CR>"]     = { "accept", "fallback" },
      ["<PageUp>"]   = { "scroll_documentation_up", "fallback" },
      ["<PageDown>"] = { "scroll_documentation_down", "fallback" },
    },
    completion = { list = { selection = { preselect = false, auto_insert = false } } },
  },
}
