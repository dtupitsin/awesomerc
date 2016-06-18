local setmetatable = setmetatable
local io = require("io")
local textbox = require("wibox.widget.textbox")
local capi = {timer = timer}
local string = require("string")

local battery = { mt = {} }

function get_battery()
  local command = "acpi -a"
  local cmd = assert(io.popen(command))
  local acpi = cmd:read()
  cmd:close()
  
  local status = string.match(acpi,"on\.line")
  if status then
    return " [ <span color='green'>On AC</span> ]"
  end

  command = "acpi | cut -d, -f2,3"
  cmd = assert(io.popen(command))
  acpi = cmd:read()
  cmd:close()

  status, time = string.match(acpi,"(%d+)%%, (%d+:%d+)")
  status = tonumber(status)
  
  if status > 80 then
    color = 'green'
  elseif status > 30 then
    color = 'yellow'
  else
    color = 'red'
  end
  return " [ <span color='".. color  .."'>" .. status .."%</span> ("..time..") ]"
end

function battery.new(timeout)
  local timeout = timeout or 60
  local w = textbox()
  local timer = capi.timer {timeout = timeout}
  timer:connect_signal("timeout", function() w:set_markup(get_battery()) end)
  timer:start()
  timer:emit_signal("timeout")
  return w
end

function battery.mt:__call(...)
    return battery.new(...)
end

return setmetatable(battery, battery.mt)


-- print (get_battery())
