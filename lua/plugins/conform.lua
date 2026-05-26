return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      json = { "deno_fmt_json" },
      jsonc = { "deno_fmt_json" },
      markdown = {},
      yaml = {},
      go = { "goimports", "gofmt" },
      javascript = { "deno_fmt_js" },
    },
    lsp_format = "never",
    formatters = {
      deno_fmt_json = {
        command = "deno",
        args = { "fmt", "--ext=json", "-" },
      },
      deno_fmt_js = {
        command = "deno",
        args = { "fmt", "--ext=js", "-" },
      },
      deno_fmt_md = {
        command = "deno",
        args = { "fmt", "--ext=md", "--options-line-width=2000", "-" },
      },
    },
  },
}
