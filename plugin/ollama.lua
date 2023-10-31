local proc = require("ollama.proc")
local ollama = require("ollama")

vim.api.nvim_create_user_command("OllamaStart", function()
    proc.start()
end, {})

vim.api.nvim_create_user_command("OllamaStop", function()
    proc.stop()
end, {})


vim.api.nvim_create_autocmd("VimLeavePre", { callback = function ()
    proc.stop()
end })

vim.api.nvim_create_user_command("Ollama", ollama.show_prompt, {})

