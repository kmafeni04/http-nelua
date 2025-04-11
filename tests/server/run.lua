-- Bootleg hot reloading

local luamon = require("luamon")

luamon(nil, function()
  os.execute("killall 'app' &")
  os.execute("nelua app.nelua &")
end, {
  exclude_file_types = { "lua" },
})
