vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = "*",
  callback = function()
    if not vim.fn.did_filetype() and vim.fn.getline(1):match("^#!.*groovy") then
      vim.bo.filetype = "groovy"
    end
  end
})
