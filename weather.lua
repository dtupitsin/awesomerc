-- test for weather
local setmetatable = setmetatable
local io = require("io")
local textbox = require("wibox.widget.textbox")
local capi = {timer = timer}
local http = require("socket.http")
local json = require("cjson")

local weather = { mt = {} }

j = json.decode_max_depth(1500)
--[[
function print_all(table)
    for k,v in pairs(table) do
        print (k,v)
    end
end
]]--

function get_weather()
    local url = "http://api.wunderground.com/api/1d6290008a908c73/conditions/lang:en/q/autoip.json"
    --local url = "http://ll.tt"
    r, code = http.request(url)
    local weather_data

    -- current_observation
    if (code == 200) then
        weather_data = json.decode(r)
        -- print_all(weather.current_observation)
        -- print_all(weather.current_observation.display_location)

        temp = weather_data.current_observation.temp_c
        state = weather_data.current_observation.weather
        city = weather_data.current_observation.display_location.city
    else
        state = "NA"
        temp = "NA"
    end
    return "[ "..state..":"..temp.." ]"
end

-- print (city, temp, state)
--print (state.." "..temp.."\n"..city)


function weather.new(timeout)
  local timeout = timeout or 3600
  local w = textbox()
  local timer = capi.timer {timeout = timeout}
  timer:connect_signal("timeout", function() w:set_markup(get_weather()) end)
  timer:start()
  timer:emit_signal("timeout")
  return w
end

function weather.mt:__call(...)
    return weather.new(...)
end

return setmetatable(weather, weather.mt)
