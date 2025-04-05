--[[
  Requirement: [luafilesystem](https://lunarmodules.github.io/luafilesystem)
]]

local lfs = require("lfs")
local current_time = os.time()

---@param file_path string
---@param callback function
local function check_modification(file_path, callback)
  local file_attrs, _, _ = lfs.attributes(file_path)
  if file_attrs then
    local mod = file_attrs.modification
    if mod > current_time then
      current_time = mod
      print(lfs.currentdir() .. "/" .. file_path .. " has been modified")
      callback()
    end
  end
end

--- For files without extensions or full file_names, an `_` can be used in front of the filename. e.g. `_lua` or `_luamon.lua`
--- Fields `exclude_file_types` and `only_file_types` can not be present at the same time
---@class Config
---@field exclude_file_types? string[] An array of file types to be ignored when monitoring
---@field only_file_types? string[] An array of file types to only be monitored
---@field recursive? boolean Whether or not subdirectories should be checked, Default: `true`

---@param directory string?
---@param callback function
---@param config? Config
local function check_dir(directory, callback, config)
  local recursive = true
  for file_path in lfs.dir(directory) do
    if file_path ~= ".." and file_path ~= "." then
      file_path = directory .. "/" .. file_path
      if config then
        assert(
          not (config.exclude_file_types and config.only_file_types),
          "`exclude_file_types` and `only_file_types` fields can not be present at the same time"
        )
        recursive = config.recursive and config.recursive or recursive
        if config.exclude_file_types then
          for _, file_type in ipairs(config.exclude_file_types) do
            local file_match = (
              file_path:match("^.*%." .. file_type .. "$")
              or file_path == directory .. "/" .. file_type:sub(2)
            )
                and true
              or false

            local ignore_bck = file_path:match(".*%.bck")

            if not file_match and not ignore_bck then
              check_modification(file_path, callback)
              break
            end
          end
        elseif config.only_file_types then
          for _, file_type in ipairs(config.only_file_types) do
            local file_match = (
              file_path:match("^.*%." .. file_type .. "$")
              or file_path == directory .. "/" .. file_type:sub(2)
            )
                and true
              or false

            local ignore_bck = file_path:match(".*%.bck")

            if file_match and not ignore_bck then
              check_modification(file_path, callback)
              break
            end
          end
        else
          check_modification(file_path, callback)
        end
      else
        check_modification(file_path, callback)
      end

      if recursive then
        local file_attrs, _, _ = lfs.attributes(file_path)
        if file_attrs and file_attrs.mode == "directory" then
          lfs.chdir(file_path)
          check_dir(".", callback, config)
          lfs.chdir("..")
        end
      end
    end
  end
end

--[[
  Monitors for file changes in a directory and calls a callback function on any file modification

  Usage:
  ```lua
  local luamon = require("luamon")
  luamon("/home/username/Desktop", function()
    print("A file has changed")
  end)

  -- If the directory is nil, it will use the current directory of the running process
  local luamon = require("luamon")
  luamon(nil, function()
    print("A file has changed")
  end)

  -- A third parameter `config` can be passed to customise how the monitoring behaves
  local config = {
    exclude_file_types = { "lua", "_luamon.lua" }
  }
  luamon(nil, function()
    print("A file has changed")
  end, config)
  ```
]]
---@param directory? string
---@param callback function
---@param config? Config
local function luamon(directory, callback, config)
  if directory then
    assert(directory:match("^/.*"), "Directory must be an absolute path but was provided: '" .. directory .. "'")
  else
    local err
    directory, err = lfs.currentdir()
    assert(directory, err)
  end
  local changed_dir, err = lfs.chdir(directory)
  assert(changed_dir, err)
  callback()

  while true do
    check_dir(directory, callback, config)
  end
end

return luamon
