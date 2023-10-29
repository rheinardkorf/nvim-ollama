local ollama_session = nil

local function stop_ollama_process()
    if ollama_session then
        local _handle = io.popen("kill " .. ollama_session)
        if _handle ~= nil then
            _handle:close()
        end
        ollama_session = nil
    end
end

vim.api.nvim_create_user_command("OllamaStart", function()
    local job = vim.fn.jobpid(vim.fn.jobstart('ollama serve > /dev/null 2>&1 &'))
    if job then
        print("Ollama process started.")
        ollama_session = job + 1
    else
    end
end, {})

vim.api.nvim_create_user_command("OllamaStop", function()
    stop_ollama_process()
    print("Ollama process stopped.")
end, {})


vim.api.nvim_create_autocmd("VimLeavePre", { callback = stop_ollama_process })
