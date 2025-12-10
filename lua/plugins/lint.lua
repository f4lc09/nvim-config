return {
  "mfussenegger/nvim-lint",
  opts = {
    linters = {
      golangcilint = {
        cmd = "golangci-lint",
        args = {
          "run",
          "--config=/home/falcon/.config/nvim/.golangci.yml",
          "--output.json.path=stdout",
          "--issues-exit-code=0",
          "--show-stats=false",
          "./...",
        },
        parser = require("lint.parser").from_json({}),
      },
    },
    linters_by_ft = {
      go = { "golangcilint" }, -- ЯВНО указываем использовать ТОЛЬКО этот линтер для Go
    },
  },
}
