local M = {}

-- 检查文件是否存在
local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

-- 获取需要压缩的文件列表和默认的归档文件名
local get_compression_target = ya.sync(function()
    local tab = cx.active
    local default_name
    local paths = {}
    if #tab.selected == 0 then
        if tab.current.hovered then
            local name = tab.current.hovered.name
            default_name = name
            table.insert(paths, name)
        else
            return
        end
    else
        default_name = tab.current.cwd:name()
        for _, url in pairs(tab.selected) do
            table.insert(paths, tostring(url))
        end
        -- 取消选中的文件
        ya.manager_emit("escape", {})
    end
    return paths, default_name
end)

-- 调用压缩命令
local function invoke_compress_command(paths, name)
    local cmd_output, err_code = Command("mkdwarfs")
        :args({ "-i", table.concat(paths, " "), "-o", name }) -- 设置压缩命令参数
        :stderr(Command.PIPED)                            -- 将标准错误重定向到管道
        :output()                                         -- 执行命令并获取输出

    if err_code ~= nil then
        -- 如果命令执行失败，显示错误通知
        ya.notify({
            title = "Failed to run dwarfs command",
            content = "Status: " .. err_code,
            timeout = 5.0,
            level = "error",
        })
    elseif not cmd_output.status.success then
        -- 如果命令执行失败，显示错误通知
        ya.notify({
            title = "Compression failed: status code " .. cmd_output.status.code,
            content = cmd_output.stderr,
            timeout = 5.0,
            level = "error",
        })
    end
end

-- entry 函数用于处理用户输入并创建归档文件
function M:entry(args)
    local default_fmt = args[1] -- 获取默认的归档格式

    -- 获取需要压缩的文件列表和默认的归档文件名
    local paths, default_name = get_compression_target()

    -- 获取用户输入的归档文件名
    local output_name, name_event = ya.input({
        title = "Create dwarfs:",
        value = default_name .. "." .. default_fmt,
        position = { "top-center", y = 3, w = 40 },
    })
    if name_event ~= 1 then
        return -- 如果用户取消输入，退出
    end

    -- 如果文件已存在，请求用户确认是否覆盖
    if file_exists(output_name) then
        local confirm, confirm_event = ya.input({
            title = "Overwrite " .. output_name .. "? (y/N)",
            position = { "top-center", y = 3, w = 40 },
        })
        if not (confirm_event == 1 and confirm:lower() == "y") then
            return -- 如果用户选择不覆盖，退出
        end
    end

    -- 调用压缩命令
    invoke_compress_command(paths, output_name)
end

return M
