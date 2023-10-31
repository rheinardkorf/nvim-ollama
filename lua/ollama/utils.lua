local Utils = {}

Utils.split_string = function(input, max_length, preserve_empty)
    preserve_empty = preserve_empty or true
    local lines = {}
    local line = ""

    for word in input:gmatch("%S+") do
        if #line + #word + 1 > max_length then
            table.insert(lines, line)
            line = ""
        end
        line = line .. (line == "" and "" or " ") .. word
    end

    if #line > 0 or preserve_empty then
        table.insert(lines, line)
    end

    return lines
end

Utils.split_lines_in_table = function(input, max_line_length)
    local result = {}

    for _, line in ipairs(input) do
        local lines = Utils.split_string(line, max_line_length)
        for _, splitLine in ipairs(lines) do
            table.insert(result, splitLine)
        end
    end

    return result
end

return Utils
