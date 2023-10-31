local M = {}

local Layout = require("nui.layout")
local Popup = require("nui.popup")
local Input = require("nui.input")

local response_buffer

M.opts = {
    model = 'mistral',
    autostart = false,
}

M.setup = function(opts)
    M.model = opts.model or 'mistral'
    M.autostart = opts.autostart or false

    if M.autostart then
        require("ollama.proc").start()
    end
end

M.show_prompt = function()
    local input, layout, response_window

    response_buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(response_buffer, 'filetype', 'markdown')

    response_window = Popup({
        border = {
            highlight = "FloatBorder",
            style = "rounded",
            text = {
                top = "Ollama",
                top_align = "center"
            },
        },
        bufnr = response_buffer,
    })

    input = Input({
        border = {
            highlight = "FloatBorder",
            style = "rounded",
            text = {
                top = " Prompt (empty prompt to exit)",
                top_align = "left",
            },
        },
        win_options = {
            winhighlight = "Normal:Normal",
        },
    }, {
        prompt = "> ",
        on_submit = vim.schedule_wrap(function(value)
            if string.len(value) == 0 then
                response_buffer = nil
                layout:unmount()
                return
            end

            -- Causes a slight flicker, but I almost prefer this
            -- than remapping <CR> and handling submit manually.
            vim.cmd("Ollama")

            -- Some buffer tasks.
            local input_buffer = vim.fn.bufnr('%')
            vim.api.nvim_buf_set_lines(input_buffer, 0, 1, false, { "" })

            local result_string = ""
            local cmd = "ollama run " .. M.model
            vim.fn.jobstart(cmd .. ' "' .. value .. '"', {
                on_stdout = function(_, data, _)
                    result_string = result_string .. table.concat(data, '\n')
                    local lines = require("ollama.utils").split_lines_in_table(vim.split(result_string, '\n', true),
                        response_window.win_config.width - 10)
                    vim.api.nvim_buf_set_lines(response_buffer, 0, -1, false, lines)
                end,
            })
        end),
        on_close = function()
            response_buffer = nil
        end,
    })

    layout = Layout(
        {
            position = "50%",
            size = {
                width = "90%",
                height = "80%",
            },
        },
        Layout.Box({
            Layout.Box(response_window, { grow = 1 }),
            Layout.Box(input, { size = 3 }),
        }, { dir = "col" })
    )

    -- add keymapping
    input:map("i", "<C-y>", function()
        local lines = vim.api.nvim_buf_get_lines(response_buffer, 0, -1, false)
        local msg = table.concat(lines, "\n")
        vim.fn.setreg("+", msg)
        vim.notify("Succesfully copied to yank register!", vim.log.levels.INFO)
    end, { noremap = true })

    -- mount prompt component
    layout:mount()
end

return M
