-- start of resolver.lua (credit: LuaGod for making orginal script on fourms)
-- Credit to XSovietDoggo (helped with alot)

--Start of Checkboxes
local enable = ui.new_checkbox("rage", "other", "Lua resolver")
local chat = ui.new_checkbox("RAGE", "Other", "Print into chat globaly")
local localchat = ui.new_checkbox("RAGE", "Other", "Print into chat locally")
local console = ui.new_checkbox("RAGE", "Other", "Print into console")
local clantag = ui.new_checkbox("RAGE", "Other", "Clantag")
local watermark = ui.new_checkbox("RAGE", "Other", "Watermark")
local jitterkey = ui.new_hotkey("RAGE", "Other", "Jitter on key (180 rand)")
--End of Checkboxes




-- End of color pickers
--Start of References


local resolver_ref = ui.reference("RAGE", "Other", "Anti-aim correction")
local sp_ref = ui.reference("RAGE", "Aimbot", "Prefer safe point")
local yawjit, yawjit_sl = ui.reference("AA", "Anti-aimbot angles", "Yaw jitter")
--End of References

--Start of Values
local angles = {
    [1] = -55,
    [2] = 55,
    [3] = 38,
    [4] = -38,
    [5] = -29,
    [6] = 29,
    [7] = -15,
    [8] = 15,
    [9] = 0
}
-- good values could be better
local last_angle = 0
local new_angle = 0
local switch1 = false
local switch2 = false
local i = 1
local screenX, screenY = client.screen_size()
local local_player = entity.get_local_player
local js = panorama["open"]()
local MyPersonaAPI, LobbyAPI, PartyListAPI, FriendsListAPI, GameStateAPI =
    js["MyPersonaAPI"],
    js["LobbyAPI"],
    js["PartyListAPI"],
    js["FriendsListAPI"],
    js["GameStateAPI"]

local SteamID = panorama.open().MyPersonaAPI.GetXuid() -- grabs steamID (probably a better way of grabbing it, but i couldn't find one.)
local tickrate = 1/globals.tickinterval()
local function draw_background(x, y, w, h, color1, color2, color3)
    renderer.rectangle(x, y, w, h)

    --top to bottom gradient
    renderer.rectangle(x, y, w, 2)
    renderer.rectangle(x, y + h, w, 2)

end
local function draw_text(x, y, flags, text, center_mode, color1, color2, color3)
    local measure = {renderer.measure_text(flags, text)}

    local pad = 4

    if center_mode == "center" then
        draw_background(x - measure[1]/2 - pad, y - pad, measure[1] + pad*2, measure[2] + pad*2, color1, color2, color3)
        renderer.text(x - measure[1]/2, y, 255, 255, 255, 255, flags, 0, text)
    elseif center_mode == "left" then
        draw_background(x - measure[1] - pad - 10, y - pad, measure[1] + pad*2, measure[2] + pad*2, color1, color2, color3)
        renderer.text(x - measure[1] - 10, y, 255, 255, 255, 255, flags, 0, text)
    end
end
local hours, minutes, seconds = client.system_time()

local frames = {}
local averaged_frames = 0

local function fps()
    local frametime = 1/globals.frametime()
    
    table.insert(frames, {frametime, globals.realtime() + 0.4})

    while #frames > 1000 do
        table.remove(frames, #frames)
    end

    for i=1, #frames do
        if frames[i] ~= nil and frames[i][2] < globals.realtime() then
            table.remove(frames, i)
        end
    end

    local average = 0

    for i=1, #frames do
        average = average + frames[i][1]
    end

    averaged_frames = average/#frames
end
local ffi = require("ffi")
ffi.cdef[[
typedef void***(__thiscall* FindHudElement_t)(void*, const char*);
typedef void(__cdecl* ChatPrintf_t)(void*, int, int, const char*, ...);
]]
local signature_gHud = "\xB9\xCC\xCC\xCC\xCC\x88\x46\x09"
local signature_FindElement = "\x55\x8B\xEC\x53\x8B\x5D\x08\x56\x57\x8B\xF9\x33\xF6\x39\x77\x28"
local match = client.find_signature("client_panorama.dll", signature_gHud) or error("sig1 not found")
local hud = ffi.cast("void**", ffi.cast("char*", match) + 1)[0] or error("hud is nil")
match = client.find_signature("client_panorama.dll", signature_FindElement) or error("FindHudElement not found")
local find_hud_element = ffi.cast("FindHudElement_t", match)
local hudchat = find_hud_element(hud, "CHudChat") or error("CHudChat not found")
local chudchat_vtbl = hudchat[0] or error("CHudChat instance vtable is nil")
local print_to_chat = ffi.cast("ChatPrintf_t", chudchat_vtbl[27])
local bChat = ui.new_checkbox("LUA", "B", "Log into chat")
local bConsole = ui.new_checkbox("LUA", "B", "Log into console")

local http = require "gamesense/http"
local gomilogscheck = ui.new_checkbox("LUA", "A", "Enable GomiLogs") -- pasted.



local background = {25, 25, 25, 125}
local function clamp(min, max, value)
    if min < max then
        return math.max(min, math.min(max, value))
    else
        return math.max(max, math.min(min, value))
    end
end
local screen = {client.screen_size()}
local center = {screen[1]/2, screen[2]/2}
local wtf = entity.get_steam64
local function print_chat(text)
	print_to_chat(hudchat, 0, 0, text)
end

local hitgroups = {'generic', 'head', 'chest', 'stomach', 'left arm', 'right arm', 'left leg', 'right leg', 'neck', '?', 'gear'}
local clantaglist = {
    [0] = "Niggerslaya",
    [1] = "Niggerslaya",
    [2] = "Niggerslay",
    [3] = "Niggersla",
    [4] = "Niggersl",
    [5] = "Niggers",
    [6] = "Nigger",
    [7] = "Nigge",
    [8] = "Nigg",
    [9] = "Nig",
    [10] = "Ni",
    [11] = "N", 
    [12] = " ",
    [13] = " ",
    [14] = " ",
    [15] = " ",
    [16] = "N",
    [17] = "Ni",
    [18] = "Nig",
    [19] = "Nigg",
    [20] = "Nigge",
    [21] = "Nigger",
    [22] = "Niggers",
    [23] = "Niggersl",
    [24] = "Niggersla",
    [25] = "Niggerslay",
    [26] = "Niggerslaya",
    [27] = "Niggerslaya" -- we are the nigga slayers :)
}
--End of Values
-- Premium clantag changer :0
local function resolve(player)
    plist.set(player, "Correction active", false) -- disable default correction because i have a superiority complex
    plist.set(player, "Force body yaw", true) -- enable the forcing of the body yaw

    if last_angle == -new_angle and switch1 then
        new_angle = -angles[i]
        if switch2 == true then
            switch1 = not switch1
        end
    else
        if i < #angles then
            i = i + 1
        else
            i = 1
        end
        new_angle = angles[i]
    end
    -- javascript monkey shit :monkey: (fucking sov)
    if ui.get(console) then
        client.log("[DEBUG] missed player: " ..entity.get_player_name(player) .. ", at angle: " .. last_angle .. ", bruteforced to: " .. new_angle)
    end
    if ui.get(localchat) then    
        print_chat("[DEBUG] missed player: " .. entity.get_player_name(player) .. ", at angle: " .. last_angle .. ", bruteforced to: " .. new_angle)
    end
    if ui.get(chat) then
        client.exec("say [DEBUG] missed player: " ..entity.get_player_name(player) .. ", at angle: " .. last_angle .. ", bruteforced to: " .. new_angle .. "")
    end
        
    plist.set(player, "Force body yaw value", new_angle) -- force yaw value to random
    last_angle = new_angle
    switch2 = false
end
local user_name = "unknown"
client.set_event_callback("aim_miss",function(info)
    if ui.get(enable) and info.reason == "?" then -- make sure we missed due to resolver and ui is on
        resolve(info.target) -- resolve that noob
    end
end)
local function on_aim_hit( event )
    if ui.get(enable) then
        switch2 = true
if ui.get(enable) then
        if ui.get(console) then 
        client.log("[DEBUG] hurt player: " ..entity.get_player_name(event.target) .. ", at angle: " .. new_angle)
        end
        if ui.get(localchat) then 
        print_chat("[DEBUG] hurt player: " ..entity.get_player_name(event.target).. ", at angle: " .. new_angle)
        end
        if ui.get(chat) then   
        client.exec("say [DEBUG] hurt player: " ..entity.get_player_name(event.target) .. ", at angle: " .. new_angle) 
            end
        end
    end
end
client.set_event_callback("aim_hit", on_aim_hit) -- if you want to actually log the players name upon hitting them, you have to make a funcion then call it with AIM_HIT.

local last_time = 0;
client.set_event_callback("setup_command", function()
    if ui.get(clantag) then
        local now = math.floor(globals.curtime() * 2)
        if now ~= last_time then
            last_time = now;
            local index = math.floor(now % #clantaglist)
            client.set_clan_tag(clantaglist[index])
        end
    end
end)
local function paint()
-- test watermark...
    if ui.get(watermark) then
        local ping = clamp(0, 1000, math.floor(client.latency() * 1000))
        local string = string.format("Resolver.lua | %s | Tick: %d | Latency: %d", username, 1/globals.tickinterval(), ping) -- username doesnt exist so it'll just be nil.
        draw_text(screen[1], 15, "", string, "left", color1_g, color2_g, background)
        draw_text(screen[1], 15, "", string, "left", background)
    end
end
local function set_callbacks(event, ...)
    local items = {...}
    for i=1, #items do
        client.set_event_callback(event, items[i])
    end
end

set_callbacks("paint", paint)
local hitgroup_names = {'generic', 'head', 'chest', 'stomach', 'left arm', 'right arm', 'left leg', 'right leg', 'neck', '?', 'gear'}


local function aim_miss2(e)
    if ui.get(gomilogscheck) then 
    local group = hitgroup_names[e.hitgroup + 1] or '?'
    print(string.format('Missed %s (%s) due to %s', entity.get_player_name(e.target), group, e.reason))
    end
end
local function grab_time() -- pasted, was going to try and use this for something, useless.
    http.get("https://quadrohvh.club/aa/clock.php", 
    function(success, response)
        if not success or response.status ~= 200 then
            return
        end
        wtf(
            response.body
        )
    end) 
end

-- when user loads script (not accurate)

local RefreshDelay = 5
if globals.curtime() < RefreshDelay then return end
RefreshDelay = globals.curtime() + 5


-- cool spooky webhook thingy (wouldnt recommend touching...)

local RefreshDelay = 5
if globals.curtime() < RefreshDelay then return end

RefreshDelay = globals.curtime() + 5





--- kool looking.

-- start of creating buttons for legendarys 16v16 and 8v8.



local console_cmd = client.exec
local console_log = client.log
local ui_get = ui.get

local servers = {
  {
    name = 'Legendary 16v16',
    ip = '108.170.36.131:27015'
  },
  {
    name = 'Legendary 8v8',
    ip = '173.44.133.186:22015'
  },
}

-- legendarys servers (mainly cuz i forget dem LMAO)

local _servers = {}
for _, v in pairs(servers) do
  _servers[#_servers + 1] = v.name
end

local join_server = ui.new_combobox('MISC', 'Settings', 'Server List', _servers)

local function connect()
  local server_name = ui_get(join_server)
  for _, v in pairs(servers) do
    if v.name == server_name then
      console_cmd('connect ', v.ip)
      console_log('Joined ', server_name)
    end
  end
end

local join_button = ui.new_button('MISC', 'Settings', 'Connect', connect)


-- smart!!!


legit_e_key = ui.new_checkbox("Rage", "Other", "Legit anti-aim (on E key)")
freestanding_body_yaw = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw")

client.set_event_callback("setup_command",function(e)
    local weaponn = entity.get_player_weapon()
    if ui.get(legit_e_key) then
        if weaponn ~= nil and entity.get_classname(weaponn) == "CC4" then
            if e.in_attack == 1 then
                e.in_attack = 0 
                e.in_use = 1
            end
        else
            if e.chokedcommands == 0 then
                e.in_use = 0
            end
        end
        ui.set(freestanding_body_yaw, true)
end
end)






-- begining of Update log.

fixes = { 'Update Log: Fixed hitting players logging "unknown"', "Fixed up resolver.", "Added discord webhooking when someone loads script", "Added Watermark", "Added indicators.", "Last Updated: 2/8/20 9:43 PM" }
for i = 1, #fixes do
    client.color_log(client.random_int(1, 255), client.random_int(1, 255), client.random_int(1, 255), "[Resolver.lua] "..fixes[i])
end


  


local http_libary =
    '{ ["patch"] = function: NULL,["options"] = function: NULL,["request"] = function: NULL,["put"] = function: NULL,["head"] = function: NULL,["delete"] = function: NULL,["post"] = function: NULL,["create_cookie_container"] = function: NULL,["get"] = function: NULL,} '
local check = 0
local ffi = require("ffi")
local js = panorama["open"]()
local MyPersonaAPI, LobbyAPI, PartyListAPI, FriendsListAPI, GameStateAPI =
    js["MyPersonaAPI"],
    js["LobbyAPI"],
    js["PartyListAPI"],
    js["FriendsListAPI"],
    js["GameStateAPI"]
ffi.cdef [[ typedef struct { int64_t pad_0; union { int xuid; struct { int xuidlow; int xuidhigh; }; }; char name[128]; int userid; char guid[33]; unsigned int friendsid; char friendsname[128]; bool fakeplayer; bool ishltv; unsigned int customfiles[4]; unsigned char filesdownloaded; } S_playerInfo_t; typedef bool(__thiscall* fnGetPlayerInfo)(void*, int, S_playerInfo_t*); typedef void(__thiscall* clientcmdun)(void*, const char* , bool); typedef bool(__thiscall* is_in_game)(void*); typedef bool(__thiscall* is_connected)(void*, bool); typedef int(__thiscall* get_local_player_ffi)(void*); typedef void*(__thiscall* get_net_channel_info_t)(void*); typedef float(__thiscall* get_avg_latency_t)(void*, int); typedef float(__thiscall* get_avg_loss_t)(void*, int); typedef float(__thiscall* get_avg_choke_t)(void*, int); ]]


local pEngineClient = ffi.cast(ffi.typeof("void***"), client.create_interface("engine.dll", "VEngineClient014"))
local fnGetPlayerInfo = ffi.cast("fnGetPlayerInfo", pEngineClient[0][8])
local clientcmdun = ffi.cast("clientcmdun", pEngineClient[0][114])
local pinfo_struct = ffi.new("S_playerInfo_t[1]")
local lp_entidx = entity.get_local_player()
local steamid = nil
local pritsteamid = nil

local print = client.log
if lp_entidx then
    fnGetPlayerInfo(pEngineClient, lp_entidx, pinfo_struct)
    steamid = pinfo_struct[0].xuid
    pritsteamid = ffi.string(pinfo_struct[0].guid)
end
local function steam_64(steamid3)
    local y
    local z
    if ((steamid3 % 2) == 0) then
        y = 0
        z = (steamid3 / 2)
    else
        y = 1
        z = ((steamid3 - 1) / 2)
    end
    return "7656119" .. ((z * 2) + (7960265728 + y))
end
local local_id = steamid
function dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end
if check == 1 then
    print(http == nil)
    print(http ~= nil)
    print(http_libary == dump(http))
    if type(http) == "table" then
        return print(type(http) == "table")
    end
end
--local function webhook(message)
  --  local embed = 
    --    [[ $.AsyncWebRequest("https://discord.com/api/webhooks/805271720637759559/WKwRzN5b7G0omDnmd2guH0vaA7F0ikWxfr9ljoVcR1RhzmLRow56jv245M7Atd3yOrcm", { type: "POST", data: { "content": "%s" } }) ]]
    --[[panorama.loadstring(string.format(embed, message))()
end
http.get(
    "https://quadrohvh.club/aa/clock.php",
    function(success, response)
        if not success or response.status ~= 200 then
            return
        end
        webhook(
            "`" ..
                response.body ..
                    "` ```ID: " .. SteamID .. "```|||| **" .. string.upper(GameStateAPI.GetServerName()) .. "**"
        )
    end
) 
--]]


client.set_event_callback("aim_miss", aim_miss2)



--vars
local time = 10
local r_h, g_h, b_h, a_h = 255, 0, 0, 255
local r_m, g_m, b_m, a_m = 255, 255, 255, 10

local hitgroup_data = {
    {0}, --head/neck
    {6, 5}, --chest
    {2, 3, 4}, --stomach/pelvis
    {15, 16}, --left arm
    {17, 18}, --right arm
    {7, 9, 11}, --left leg
    {8, 10, 12}, --right leg
    {1}, --neck
}

--refs
local ui_enabled = ui.new_checkbox("VISUALS", "Other ESP", "Detailed wireframe hit")
local ui_color_hit = ui.new_color_picker("VISUALS", "Other ESP", "Detailed wireframe hit", 255, 0, 0, 255)
local ui_color_miss = ui.new_color_picker("VISUALS", "Other ESP", "Detailed wireframe miss", 255, 255, 255, 10)
local ui_time = ui.new_slider("VISUALS", "Other ESP", "Detailed wireframe time", 5, 300, 10, true, "s", 0.1)

--util funcs
local function draw_hitgroup(entidx, hitgroup, tick)
    local hitboxes = hitgroup
    if hitgroup < 1 or hitgroup > 8 then 
        client.draw_hitboxes(entidx, time, 19, r_h, g_h, b_h, a_h, tick)
    else
        for i = 1, #hitgroup_data do 
            local r, g, b, a = r_m, g_m, b_m, a_m
            if hitgroup == i then 
                r, g, b, a = r_h, g_h, b_h, a_h
            end
            if a ~= 0 then 
                for n = 1, #hitgroup_data[i] do 
                    client.draw_hitboxes(entidx, time, hitgroup_data[i][n], r, g, b, a, tick)
                end
            end
        end
    end
end

--callback funcs
local function hurt_handler(event)
    if client.userid_to_entindex(event.attacker) == entity.get_local_player() or client.userid_to_entindex(event.attacker) == entity.get_prop(entity.get_local_player(), "m_hObserverTarget") then 
        draw_hitgroup(client.userid_to_entindex(event.userid), event.hitgroup, globals.tickcount())
    end
end

--ui callbacks
do  
    ui.set_callback(ui_enabled, function()
        local state = ui.get(ui_enabled)

        local update_callback = state and client.set_event_callback or client.unset_event_callback
        update_callback("player_hurt", hurt_handler)

        ui.set_visible(ui_color_hit, state)
        ui.set_visible(ui_color_miss, state)
        ui.set_visible(ui_time, state)
    end)

    local state = ui.get(ui_enabled)

    local update_callback = state and client.set_event_callback or client.unset_event_callback
    update_callback("player_hurt", hurt_handler)

    ui.set_visible(ui_color_hit, state)
    ui.set_visible(ui_color_miss, state)
    ui.set_visible(ui_time, state)

    ui.set_callback(ui_color_hit, function()
        r_h, g_h, b_h, a_h = ui.get(ui_color_hit)
    end)
    r_h, g_h, b_h, a_h = ui.get(ui_color_hit)

    ui.set_callback(ui_color_miss, function()
        r_m, g_m, b_m, a_m = ui.get(ui_color_miss)
    end)
    r_m, g_m, b_m, a_m = ui.get(ui_color_miss)

    ui.set_callback(ui_time, function()
        time = ui.get(ui_time)*0.1
    end)
    time = ui.get(ui_time)*0.1
end


legit_e_key = ui.new_checkbox("AA", "Anti-aimbot angles", "Legit anti-aim (on E key)")
freestanding_body_yaw = ui.reference("AA", "Anti-aimbot angles", "Freestanding body yaw")

client.set_event_callback("setup_command",function(e)
    local weaponn = entity.get_player_weapon()
    if ui.get(legit_e_key) then
        if weaponn ~= nil and entity.get_classname(weaponn) == "CC4" then
            if e.in_attack == 1 then
                e.in_attack = 0 
                e.in_use = 1
            end
        else
            if e.chokedcommands == 0 then
                e.in_use = 0
            end
        end
        ui.set(freestanding_body_yaw, true)
end
end)






local sp = ui.reference("RAGE", "Aimbot", "Force safe point")

local function on_paint() 
    if ui.get(sp) then
        renderer.indicator(126, 195, 12, 255, "SP")
    end
end




client.set_event_callback("paint", on_paint)



