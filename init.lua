local M = {}
local function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

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
        ya.manager_emit("escape", {})
    end
    return paths, default_name
end)

local function invoke_compress_command(paths, name)
    local cmd_output, err_code = Command("mkdwarfs")
        :args({ "-i", table.concat(paths, " "), "-o", name })
        :stderr(Command.PIPED)
        :output()
    if err_code ~= nil then
        ya.notify({
            title = "Failed to run dwarfs command",
            content = "Status: " .. err_code,
            timeout = 5.0,
            level = "error",
        })
    elseif not cmd_output.status.success then
        ya.notify({
            title = "Compression failed: status code " .. cmd_output.status.code,
            content = cmd_output.stderr,
            timeout = 5.0,
            level = "error",
        })
    end
end

local function invoke_mount_command(name, mount_point)
    local cmd_output, err_code = Command("dwarfs")
        :args({ name, mount_point })
        :stderr(Command.PIPED)
        :output()
    if err_code ~= nil then
        ya.notify({
            title = "Failed to run dwarfs command",
            content = "Status: " .. err_code,
            timeout = 5.0,
            level = "error",
        })
    elseif not cmd_output.status.success then
        ya.notify({
            title = "Compression failed: status code " .. cmd_output.status.code,
            content = cmd_output.stderr,
            timeout = 5.0,
            level = "error",
        })
    end
end

function M:entry(args)
    local action = args[1]
    local default_fmt = args[2]
    if action == "mkdwarfs" then
        local paths, default_name = get_compression_target()
        local output_name, name_event = ya.input({
            title = "Create dwarfs:",
            value = default_name .. "." .. default_fmt,
            position = { "top-center", y = 3, w = 40 },
        })
        if name_event ~= 1 then
            return
        end
        if file_exists(output_name) then
            local confirm, confirm_event = ya.input({
                title = "Overwrite " .. output_name .. "? (y/N)",
                position = { "top-center", y = 3, w = 40 },
            })
            if not (confirm_event == 1 and confirm:lower() == "y") then
                return
            end
        end
        invoke_compress_command(paths, output_name)
    elseif action == "dwarfs" then
        local _, default_name = get_compression_target()
        local mount_point, mount_event = ya.input({
            title = "Enter mount point path:",
            value = "j:",
            position = { "top-center", y = 3, w = 40 },
        })
        if mount_event ~= 1 then
            return
        end
        invoke_mount_command(default_name, mount_point)
    else
        ya.notify({
            title = "Invalid action",
            content = "Unknown action: " .. action,
            timeout = 5.0,
            level = "error",
        })
    end
end

return M
