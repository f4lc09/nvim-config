return {
  "19bischof/nvim-ansible-vault",
  config = function()
    require("ansible-vault").setup({
      -- Omit ansible_cfg_directory to auto-detect nearest ansible.cfg (or .ansible.cfg)
      -- ansible_cfg_directory = "/path/to/ansible",        -- optionally set explicitly
      vault_password_file = "/home/falcon/Desktop/ansible-vault-pass", -- optional if ansible_cfg_directory resolves vault-ids
      -- vault_executable = "/absolute/path/to/ansible-vault", -- optional, defaults to "ansible-vault"
    })
  end,
}
