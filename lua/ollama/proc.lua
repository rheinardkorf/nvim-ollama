local Proc = {}

local ollama_session = nil

Proc.stop_ollama_process = function()
    if ollama_session then
        local _handle = io.popen("kill " .. ollama_session)
        if _handle ~= nil then
            _handle:close()
        end
        ollama_session = nil
    end
end

Proc.start = function()
    local job = vim.fn.jobpid(vim.fn.jobstart('ollama serve > /dev/null 2>&1 &'))
    if job then
        print("Ollama process started.")
        ollama_session = job + 1
    else
    end
end

Proc.stop = function()
    Proc.stop_ollama_process()
    print("Ollama process stopped.")
end

return Proc
