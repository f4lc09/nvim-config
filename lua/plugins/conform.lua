return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      json = { "deno_fmt" },
      jsonc = { "deno_fmt" },
      yaml = {},
    },
    formatters = {
      deno_fmt = {
        command = "deno",
        args = { "fmt", "--ext=json", "-" },
      },
    },
  },
}
