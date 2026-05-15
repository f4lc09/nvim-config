return {
  "nvim-mini/mini.pairs",
  enabled = true,
  opts = {
    modes = { command = false },
    mappings = {
      ["("] = { action = "open", pair = "()", neigh_pattern = "^[^\\]" },
      ["["] = { action = "open", pair = "[]", neigh_pattern = "^[^\\]" },
      ["{"] = { action = "open", pair = "{}", neigh_pattern = "^[^\\]" },

      [")"] = { action = "close", pair = "()", neigh_pattern = "^[^\\]" },
      ["]"] = { action = "close", pair = "[]", neigh_pattern = "^[^\\]" },
      ["}"] = { action = "close", pair = "{}", neigh_pattern = "^[^\\]" },
      ["'"] = {
        action = "closeopen",
        pair = "''",
        neigh_pattern = "^[^%w\\]",
        register = { cr = false },
      },
      ['"'] = {
        action = "closeopen",
        pair = '""',
        neigh_pattern = "^[^%w\\]",
        register = { cr = false },
      },
      ["`"] = {
        action = "closeopen",
        pair = "``",
        neigh_pattern = "^[^%w\\]",
        register = { cr = false },
      },
    },
  },
}
