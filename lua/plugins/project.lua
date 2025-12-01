return {
  "ahmedkhalf/project.nvim",
  opts = {
    -- Set manual_mode to false to allow automatic detection
    manual_mode = false,
    -- Explicitly define the detection methods
    detection_methods = { "git" }, -- Only look for the .git directory
    -- Optional: additional settings for the plugin
    patterns = { ".git" },
  },
  config = function() end,
}
