return {
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      -- Load telescope extension for lazygit
      require("telescope").load_extension("lazygit")
    end,
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "Open LazyGit" },
      { "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit Current File" },
      { "<leader>gc", "<cmd>LazyGitConfig<cr>", desc = "LazyGit Config" },
      { "<leader>gl", "<cmd>Telescope lazygit<cr>", desc = "Telescope LazyGit" },
    },
  },
}
