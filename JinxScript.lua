util.require_natives("natives-1672190175-uno")
local response = false
local localVer = 3.51
local currentVer
async_http.init("raw.githubusercontent.com", "/Prisuhm/JinxScript/main/JinxScriptVersion", function(output)
    currentVer = tonumber(output)
    response = true
    if localVer ~= currentVer then
        util.toast("New JinxScript version is available, update the lua to get the newest version.")
        menu.action(menu.my_root(), "Update Lua", {}, "", function()
            async_http.init('raw.githubusercontent.com','/Prisuhm/JinxScript/main/JinxScript.lua',function(a)
                local err = select(2,load(a))
                if err then
                    util.toast("Script failed to download. Please try again later. If this continues to happen then manually update via github.")
                return end
                local f = io.open(filesystem.scripts_dir()..SCRIPT_RELPATH, "wb")
                f:write(a)
                f:close()
                util.toast("Successfully updated JinxScript. Restarting Script... :)")
                util.restart_script()
            end)
            async_http.dispatch()
        end)
    end
end, function() response = true end) 
async_http.dispatch()
repeat 
    util.yield()
until response


local function player_toggle_loop(root, pid, menu_name, command_names, help_text, callback)
    return menu.toggle_loop(root, menu_name, command_names, help_text, function()
        if not players.exists(pid) then util.stop_thread() end
        callback()
    end)
end

local spawned_objects = {}

local function BitTest(bits, place)
    return (bits & (1 << place)) ~= 0
end

local function IsPlayerUsingOrbitalCannon(player)
    return BitTest(memory.read_int(memory.script_global((2657589 + (player * 466 + 1) + 427))), 0) -- Global_2657589[PLAYER::PLAYER_ID() /*466*/].f_427), 0
end

local function IsPlayerFlyingAnyDrone(player)
   return BitTest(memory.read_int(memory.script_global(1853910 + (player * 862 + 1) + 267 + 365)), 26) -- Global_1853910[PLAYER::PLAYER_ID() /*862*/].f_267.f_365, 26
end

local function IsPlayerUsingGuidedMissile(player)
    return (memory.read_int(memory.script_global(2657589 + 1 + (player * 466) + 321 + 10)) ~= -1 and IsPlayerFlyingAnyDrone(player)) -- Global_2657589[PLAYER::PLAYER_ID() /*466*/].f_321.f_10 
end

local function IsPlayerInRcBandito(player)
    return BitTest(memory.read_int(memory.script_global(1853348 + (player * 834 + 1) + 267 + 348)), 29)  -- Global_1853348[PLAYER::PLAYER_ID() /*834*/].f_267.f_348, 29
end

local function IsPlayerInRcTank(player)
    return BitTest(memory.read_int(memory.script_global(1853348 + (player * 834 + 1) + 267 + 428 + 2)), 16) -- Global_1853910[PLAYER::PLAYER_ID() /*862*/].f_267.f_428.f_2
end

local function get_spawn_state(pid)
    return memory.read_int(memory.script_global(((2657589 + 1) + (pid * 466)) + 232)) -- Global_2657589[PLAYER::PLAYER_ID() /*466*/].f_232
end

local function get_interior_player_is_in(pid)
    return memory.read_int(memory.script_global(((2657589 + 1) + (pid * 466)) + 245)) -- Global_2657589[bVar0 /*466*/].f_245
end

local function is_player_in_interior(pid)
    return (memory.read_int(memory.script_global(2657589 + 1 + (pid * 466) + 245)) ~= 0)
end

local function IsPlayerInKosatka(player)
    return BitTest(memory.read_int(memory.script_global(1853910 + (player * 862 + 1 ) + 267 + 479)), 2) -- Global_1853910[PLAYER::PLAYER_ID() /*862*/].f_267.f_479, 2
end


local function setBit(addr, bitIndex)
    memory.write_int(addr, memory.read_int(addr) | (1<<bitIndex))
end

local function clearBit(addr, bitIndex)
    memory.write_int(addr, memory.read_int(addr) & ~(1<<bitIndex))
end

local function request_model(hash, timeout)
    timeout = timeout or 3
    STREAMING.REQUEST_MODEL(hash)
    local end_time = os.time() + timeout
    repeat
        util.yield()
    until STREAMING.HAS_MODEL_LOADED(hash) or os.time() >= end_time
    return STREAMING.HAS_MODEL_LOADED(hash)
end

local function request_animation(hash)
    STREAMING.REQUEST_ANIM_DICT(hash)
    while not STREAMING.HAS_ANIM_DICT_LOADED(hash) do
        util.yield()
    end
end


local function BlockSyncs(pid, callback)
    for _, i in ipairs(players.list(false, true, true)) do
        if i ~= pid then
            local outSync = menu.ref_by_rel_path(menu.player_root(i), "Outgoing Syncs>Block")
            menu.trigger_command(outSync, "on")
        end
    end
    util.yield(10)
    callback()
    for _, i in ipairs(players.list(false, true, true)) do
        if i ~= pid then
            local outSync = menu.ref_by_rel_path(menu.player_root(i), "Outgoing Syncs>Block")
            menu.trigger_command(outSync, "off")
        end
    end
end


local All_business_properties = {
    -- Clubhouses
    "1334 Roy Lowenstein Blvd",
    "7 Del Perro Beach",
    "75 Elgin Avenue",
    "101 Route 68",
    "1 Paleto Blvd",
    "47 Algonquin Blvd",
    "137 Capital Blvd",
    "2214 Clinton Avenue",
    "1778 Hawick Avenue",
    "2111 East Joshua Road",
    "68 Paleto Blvd",
    "4 Goma Street",
    -- Facilities
    "Grand Senora Desert",
    "Route 68",
    "Sandy Shores",
    "Mount Gordo",
    "Paleto Bay",
    "Lago Zancudo",
    "Zancudo River",
    "Ron Alternates Wind Farm",
    "Land Act Reservoir",
    -- Arcades
    "Pixel Pete's - Paleto Bay",
    "Wonderama - Grapeseed",
    "Warehouse - Davis",
    "Eight-Bit - Vinewood",
    "Insert Coin - Rockford Hills",
    "Videogeddon - La Mesa",
}

local small_warehouses = {
    [1] = "Pacific Bait Storage", 
    [2] = "White Widow Garage", 
    [3] = "Celltowa Unit", 
    [4] = "Convenience Store Lockup", 
    [5] = "Foreclosed Garage", 
    [9] = "Pier 400 Utility Building", 
}

local medium_warehouses = {
    [7] = "Derriere Lingerie Backlot", 
    [10] = "GEE Warehouse", 
    [11] = "LS Marine Building 3", 
    [12] = "Railyard Warehouse", 
    [13] = "Fridgit Annexe",
    [14] = "Disused Factory Outlet", 
    [15] = "Discount Retail Unit", 
    [21] = "Old Power Station", 
}

local large_warehouses = {
    [6] = "Xero Gas Factory",  
    [8] = "Bilgeco Warehouse", 
    [16] = "Logistics Depot", 
    [17] = "Darnell Bros Warehouse", 
    [18] = "Wholesale Furniture", 
    [19] = "Cypress Warehouses", 
    [20] = "West Vinewood Backlot", 
    [22] = "Walker & Sons Warehouse"
}


local weapon_stuff = {
    {"Firework", "weapon_firework"}, 
    {"Up N Atomizer", "weapon_raypistol"},
    {"Unholy Hellbringer", "weapon_raycarbine"},
    {"Rail Gun", "weapon_railgun"},
    {"Red Laser", "vehicle_weapon_enemy_laser"},
    {"Green Laser", "vehicle_weapon_player_laser"},
    {"P-996 Lazer", "vehicle_weapon_player_lazer"},
    {"RPG", "weapon_rpg"},
    {"Homing Launcher", "weapon_hominglauncher"},
    {"EMP Launcher", "weapon_emplauncher"},
    {"Flare Gun", "weapon_flaregun"},
    {"Shotgun", "weapon_bullpupshotgun"},
    {"Stungun", "weapon_stungun"},
    {"Smoke Gun", "weapon_smokegrenade"},
}

local proofs = {
    bullet = {name="Bullets",on=false},
    fire = {name="Fire",on=false},
    explosion = {name="Explosions",on=false},
    collision = {name="Collision",on=false},
    melee = {name="Melee",on=false},
    steam = {name="Steam",on=false},
    drown = {name="Drowning",on=false},
}


local visual_stuff = {
    {"Better Illumination", "AmbientPush"},
    {"Oversaturated", "rply_saturation"},
    {"Boost Everything", "LostTimeFlash"},
    {"Foggy Night", "casino_main_floor_heist"},
    {"Normal Fog", "Forest"},
    {"Heavy Fog", "nervousRON_fog"},
    {"Firewatch", "MP_Arena_theme_evening"},
    {"Warm", "mp_bkr_int01_garage"},
    {"Deepfried", "MP_deathfail_night"},
    {"Stoned", "stoned"},
    {"Underwater", "underwater"},
}

local modded_vehicles = {
    "dune2",
    "tractor",
    "asea2",
    "cutter",
    "mesa2",
    "jet",
    "policeold1",
    "policeold2",
    "armytrailer2",
    "towtruck",
    "towtruck2",
    "cargoplane",
}

local modded_weapons = {
    "weapon_railgun",
    "weapon_stungun",
    "weapon_digiscanner",
}

local doors = {
    "v_ilev_ta_door",
    "v_ilev_247door",
    "v_ilev_247door_r",
    "v_ilev_lostdoor",
    "v_ilev_bs_door",
    "v_ilev_cs_door01",
    "v_ilev_cs_door01_r",
    "v_ilev_gc_door03",
    "v_ilev_gc_door04",
    "v_ilev_clothmiddoor",
    "v_ilev_clothmiddoor"
}

local interiors = {
    {"Safe Space [AFK Room]", {x=-158.71494, y=-982.75885, z=149.13135}},
    {"Torture Room", {x=147.170, y=-2201.804, z=4.688}},
    {"Mining Tunnels", {x=-595.48505, y=2086.4502, z=131.38136}},
    {"Omegas Garage", {x=2330.2573, y=2572.3005, z=46.679367}},
    {"50 Car Garage", {x=520.0, y=-2625.0, z=-50.0}},
    {"Server Farm", {x=2474.0847, y=-332.58887, z=92.9927}},
    {"Character Creation", {x=402.91586, y=-998.5701, z=-99.004074}},
    {"Life Invader Building", {x=-1082.8595, y=-254.774, z=37.763317}},
    {"Mission End Garage", {x=405.9228, y=-954.1149, z=-99.6627}},
    {"Destroyed Hospital", {x=304.03894, y=-590.3037, z=43.291893}},
    {"Stadium", {x=-256.92334, y=-2024.9717, z=30.145584}},
    {"Comedy Club", {x=-430.00974, y=261.3437, z=83.00648}},
    {"Record A Studios", {x=-1010.6883, y=-49.127754, z=-99.40313}},
    {"Bahama Mamas Nightclub", {x=-1394.8816, y=-599.7526, z=30.319544}},
    {"Janitors House", {x=-110.20285, y=-8.6156025, z=70.51957}},
    {"Therapists House", {x=-1913.8342, y=-574.5799, z=11.435149}},
    {"Martin Madrazos House", {x=1395.2512, y=1141.6833, z=114.63437}},
    {"Floyds Apartment", {x=-1156.5099, y=-1519.0894, z=10.632717}},
    {"Michaels House", {x=-813.8814, y=179.07889, z=72.15914}},
    {"Franklins House (Strawberry)", {x=-14.239959, y=-1439.6913, z=31.101551}},
    {"Franklins House (Vinewood Hills)", {x=7.3125067, y=537.3615, z=176.02803}},
    {"Trevors House", {x=1974.1617, y=3819.032, z=33.436287}},
    {"Lesters House", {x=1273.898, y=-1719.304, z=54.771}},
    {"Lesters Warehouse", {x=713.5684, y=-963.64795, z=30.39534}},
    {"Lesters Office", {x=707.2138, y=-965.5549, z=30.412853}},
    {"Meth Lab", {x=1391.773, y=3608.716, z=38.942}},
    {"Acid Lab", {x=484.69, y=-2625.36, z=-49.0}},
    {"Morgue Lab", {x=495.0, y=-2560.0, z=-50.0}},
    {"Humane Labs", {x=3625.743, y=3743.653, z=28.69009}},
    {"Motel Room", {x=152.2605, y=-1004.471, z=-99.024}},
    {"Police Station", {x=443.4068, y=-983.256, z=30.689589}},
    {"Bank Vault", {x=263.39627, y=214.39891, z=101.68336}},
    {"Blaine County Bank", {x=-109.77874, y=6464.8945, z=31.626724}}, -- credit to fluidware for telling me about this one
    {"Tequi-La-La Bar", {x=-564.4645, y=275.5777, z=83.074585}},
    {"Scrapyard Body Shop", {x=485.46396, y=-1315.0614, z=29.2141}},
    {"The Lost MC Clubhouse", {x=980.8098, y=-101.96038, z=74.84504}},
    {"Vangelico Jewlery Store", {x=-629.9367, y=-236.41296, z=38.057056}},
    {"Airport Lounge", {x=-913.8656, y=-2527.106, z=36.331566}},
    {"Morgue", {x=240.94368, y=-1379.0645, z=33.74177}},
    {"Union Depository", {x=1.298771, y=-700.96967, z=16.131021}},
    {"Fort Zancudo Tower", {x=-2357.9187, y=3249.689, z=101.45073}},
    {"Agency Interior", {x=-1118.0181, y=-77.93254, z=-98.99977}},
    {"Agency Garage", {x=-1071.0494, y=-71.898506, z=-94.59982}},
    {"Terrobyte Interior", {x=-1421.015, y=-3012.587, z=-80.000}},
    {"Bunker Interior", {x=899.5518,y=-3246.038, z=-98.04907}},
    {"IAA Office", {x=128.20, y=-617.39, z=206.04}},
    {"FIB Top Floor", {x=135.94359, y=-749.4102, z=258.152}},
    {"FIB Floor 47", {x=134.5835, y=-766.486, z=234.152}},
    {"FIB Floor 49", {x=134.635, y=-765.831, z=242.152}},
    {"Big Fat White Cock", {x=-31.007448, y=6317.047, z=40.04039}},
    {"Strip Club DJ Booth", {x=121.398254, y=-1281.0024, z=29.480522}},
}

local station_name = {
    ["Blaine County Radio"] = "RADIO_11_TALK_02", 
    ["The Blue Ark"] = "RADIO_12_REGGAE",
    ["Worldwide FM"] = "RADIO_13_JAZZ",
    ["FlyLo FM"] = "RADIO_14_DANCE_02",
    ["The Lowdown 9.11"] = "RADIO_15_MOTOWN",
    ["The Lab"] = "RADIO_20_THELAB",
    ["Radio Mirror Park"] = "RADIO_16_SILVERLAKE",
    ["Space 103.2"] = "RADIO_17_FUNK",
    ["Vinewood Boulevard Radio"] = "RADIO_18_90S_ROCK",
    ["Blonded Los Santos 97.8 FM"] = "RADIO_21_DLC_XM17",
    ["Los Santos Underground Radio"] = "RADIO_22_DLC_BATTLE_MIX1_RADIO",
    ["iFruit Radio"] = "RADIO_23_DLC_XM19_RADIO",
    ["Motomami Lost Santos"] = "RADIO_19_USER",
    ["Los Santos Rock Radio"] = "RADIO_01_CLASS_ROCK",
    ["Non-Stop-Pop FM"] = "RADIO_02_POP",
    ["Radio Los Santos"] = "RADIO_03_HIPHOP_NEW",
    ["Channel X"] = "RADIO_04_PUNK",
    ["West Coast Talk Radio"] = "RADIO_05_TALK_01",
    ["Rebel Radio"] = "RADIO_06_COUNTRY", 
    ["Soulwax FM"] = "RADIO_07_DANCE_01",
    ["East Los FM"] = "RADIO_08_MEXICAN",
    ["West Coast Classics"] = "RADIO_09_HIPHOP_OLD",
    ["Media Player"] = "RADIO_36_AUDIOPLAYER",
    ["The Music Locker"] = "RADIO_35_DLC_HEI4_MLR",
    ["Kult FM"] = "RADIO_34_DLC_HEI4_KULT",
    ["Still Slipping Los Santos"] = "RADIO_27_DLC_PRHEI4",
}
local values = {
    [0] = 0,
    [1] = 50,
    [2] = 88,
    [3] = 160,
    [4] = 208,
}

local unreleased_vehicles = {
    "virtue",
    "broadway",
    "panthere",
    "everon2",
    "eudora",
    "boor"
}

local launch_vehicle = {"Launch Up", "Launch Forward", "Launch Backwards", "Launch Down", "Slingshot"}
local invites = {"Yacht", "Office", "Clubhouse", "Office Garage", "Custom Auto Shop", "Apartment"}
local style_names = {"Normal", "Semi-Rushed", "Reverse", "Ignore Lights", "Avoid Traffic", "Avoid Traffic Extremely", "Take Shortest Path", "Sometimes Overtake Traffic"}
local drivingStyles = {786603, 1074528293, 1076, 2883621, 786468, 6, 262144, 5}
local bones = {12844, 24816, 24817, 24818, 35731, 31086}
local interior_stuff = {0, 233985, 169473, 169729, 169985, 170241, 177665, 177409, 185089, 184833, 184577, 163585, 167425, 167169}

local self = menu.list(menu.my_root(), "Self")
local recovery = menu.list(menu.my_root(), "Recovery")
local players_list = menu.list(menu.my_root(), "Players")
local vehicles = menu.list(menu.my_root(), "Vehicles")
local missions = menu.list(menu.my_root(), "Missions")
local weapons = menu.list(menu.my_root(), "Weapons")
local visuals = menu.list(menu.my_root(), "Visuals")
local funfeatures = menu.list(menu.my_root(), "Fun Features")
local teleport = menu.list(menu.my_root(), "Teleport")
local detections = menu.list(menu.my_root(), "Detections")
local modder_detections = menu.list(detections, "Modder Detections")
local normal_detections = menu.list(detections, "Normal Detections")
local bailOnAdminJoin = false
local protections = menu.list(menu.my_root(), "Protections")
menu.toggle_loop(protections, "Bail On Admin Join", {}, "", function(on)
    bailOnAdminJoin = on
end)

local int_min = -2147483647
local int_max = 2147483647

local menus = {}
local function player_list(pid)
    if NETWORK.NETWORK_IS_SESSION_ACTIVE()then 
        menus[pid] = menu.list(players_list, players.get_name(pid), {}, "", function()
            menu.trigger_commands("jinxscript " .. players.get_name(pid))
        end)
    end
end

local function handle_player_list(pid) -- thanks to dangerman and aaron for showing me how to delete players properly
    local ref = menus[pid]
    if not players.exists(pid) then
        if ref then
            menu.delete(ref)
            menus[pid] = nil
        end
    end
end

players.on_join(player_list)
players.on_leave(handle_player_list)

util.toast("Hello, " .. SOCIALCLUB.SC_ACCOUNT_INFO_GET_NICKNAME() .. "! \nWelcome To JinxScript!\n" .. "Official Discord: https://discord.gg/hjs5S93kQv") 
local function player(pid) 
    if pid ~= players.user() and players.get_rockstar_id(pid) == 0xCB2A48C then
        util.toast(lang.get_string(0xD251C4AA, lang.get_current()):gsub("{(.-)}", {player = players.get_name(pid), reason = "JinxScript Developer \n(They might be a sussy impostor, watch out!)"}), TOAST_DEFAULT)
    end

    if pid ~= players.user() and players.get_rockstar_id(pid) == 0xAE8F8C2 then
        util.toast(lang.get_string(0xD251C4AA, lang.get_current()):gsub("{(.-)}", {player = players.get_name(pid), reason = "Based Gigachad\n(They are very based! Proceed with caution!)"}), TOAST_DEFAULT)
    end

    menu.divider(menu.player_root(pid), "JinxScript")
    local bozo = menu.list(menu.player_root(pid), "JinxScript", {"JinxScript"}, "")

    local friendly = menu.list(bozo, "Friendly", {}, "")
    menu.action(friendly, "Rank Them Up", {}, "Gives them ~175k RP. Can boost a lvl 1 ~25 levels.", function()
        menu.trigger_commands("givecollectibles" .. players.get_name(pid))
    end)

    local rpwarning
     rpwarning = menu.action(friendly, "Collectible RP Loop", {}, "Loops a bad collectible, don't use on legit players.", function(click_type)
        menu.show_warning(rpwarning, click_type, "Warning: This will kick legit players and hasn't been fully tested yet. Proceed with caution.", function()
            local rp_loop = menu.list(friendly, "Collectible RP Loop", {}, "")
            menu.delete(rpwarning)
            local rp_delay = 500
            menu.slider(rp_loop, "Delay", {"givedelay"}, "", 0, 2500, 500, 10, function(amount)
                rp_delay = amount
            end)

            menu.toggle_loop(rp_loop, "Enable RP Loop", {}, "Each collectible gives 1k RP", function()
                util.trigger_script_event(1 << pid, {1839167950, pid, 4, -1, 1, 1, 1})
                util.yield(rp_delay)
            end)
            menu.trigger_command(rp_loop)
        end)
    end)

    local player_jinx_army = {}
    local army_player = menu.list(friendly, "Jinx Army", {}, "")
    menu.click_slider(army_player, "Spawn Jinx Army", {}, "", 1, 256, 30, 1, function(val)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        pos.y = pos.y - 5
        pos.z = pos.z + 1
        local jinx = util.joaat("a_c_cat_01")
        request_model(jinx)
        for i = 1, val do
            player_jinx_army[i] = entities.create_ped(28, jinx, pos, 0)
            ENTITY.SET_ENTITY_INVINCIBLE(player_jinx_army[i], true)
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(player_jinx_army[i], true)
            PED.SET_PED_COMPONENT_VARIATION(player_jinx_army[i], 0, 0, 1, 0)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(player_jinx_army[i], ped, 0, -0.3, 0, 7.0, -1, 10, true)
            util.yield()
        end 
    end)

    menu.action(army_player, "Clear Jinxs", {}, "", function()
        for i, ped in ipairs(entities.get_all_peds_as_handles()) do
            if PED.IS_PED_MODEL(ped, util.joaat("a_c_cat_01")) then
                entities.delete_by_handle(ped)
            end
        end
    end)

    local griefing = menu.list(bozo, "Trolling & Griefing", {}, "")
    local glitch_player_list = menu.list(griefing, "Glitch Player", {"glitchdelay"}, "")
    local object_stuff = {
        names = {
            "Ferris Wheel",
            "UFO",
            "Cement Mixer",
            "Scaffolding",
            "Garage Door",
            "Big Bowling Ball",
            "Big Soccer Ball",
            "Big Orange Ball",
            "Stunt Ramp",

        },
        objects = {
            "prop_ld_ferris_wheel",
            "p_spinning_anus_s",
            "prop_staticmixer_01",
            "prop_towercrane_02a",
            "des_scaffolding_root",
            "prop_sm1_11_garaged",
            "stt_prop_stunt_bowling_ball",
            "stt_prop_stunt_soccer_ball",
            "prop_juicestand",
            "stt_prop_stunt_jump_l",
        }
    }

    local object_hash = util.joaat("prop_ld_ferris_wheel")
    menu.list_select(glitch_player_list, "Object", {"glitchplayer"}, "Object to use for Glitch Player.", object_stuff.names, 1, function(index)
        object_hash = util.joaat(object_stuff.objects[index])
    end)

    menu.slider(glitch_player_list, "Spawn Delay", {"spawndelay"}, "", 150, 3000, 150, 10, function(amount)
        delay = amount
    end)

    local glitchPlayer
    glitchPlayer = player_toggle_loop(glitch_player_list, pid, "Glitch Player", {"glitchplayer"}, "Blocked by menus with entity spam protections.", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        if not players.exists(pid) then 
            util.toast("Player doesn't exist. :/")
            menu.set_value(glitchPlayer, false)
        util.stop_thread() end

        if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 1000.0 
        and v3.distance(pos, players.get_cam_pos(players.user())) > 1000.0 then
            util.toast("Player is too far. :/")
            menu.set_value(glitchPlayer, false)
        return end

        local glitch_hash = object_hash
        local poopy_butt = util.joaat("rallytruck")
        request_model(glitch_hash)
        request_model(poopy_butt)
        local stupid_object = entities.create_object(glitch_hash, pos)
        local glitch_vehicle = entities.create_vehicle(poopy_butt, pos, 0)
        ENTITY.SET_ENTITY_VISIBLE(stupid_object, false)
        ENTITY.SET_ENTITY_VISIBLE(glitch_vehicle, false)
        ENTITY.SET_ENTITY_INVINCIBLE(stupid_object, true)
        ENTITY.SET_ENTITY_COLLISION(stupid_object, true, true)
        ENTITY.APPLY_FORCE_TO_ENTITY(glitch_vehicle, 1, 0.0, 10, 10, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
        util.yield(delay)
        entities.delete_by_handle(stupid_object)
        entities.delete_by_handle(glitch_vehicle)
        util.yield(delay)     
    end)

    local glitchVeh = false
    local glitchVehCmd
    glitchVehCmd = menu.toggle(griefing, "Glitch Vehicle", {"glitchvehicle"}, "", function(toggle) -- credits to soul reaper for base concept
        glitchVeh = toggle
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        local player_veh = PED.GET_VEHICLE_PED_IS_USING(ped)
        local veh_model = players.get_vehicle_model(pid)
        local object_hash = util.joaat("prop_ld_ferris_wheel")
        request_model(object_hash)
        
        while glitchVeh do
            if not players.exists(pid) then 
                util.toast("Player doesn't exist. :/")
                menu.set_value(glitchVehCmd, false);
            util.stop_thread() end

            if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 1000.0 
            and v3.distance(pos, players.get_cam_pos(players.user())) > 1000.0 then
                util.toast("Player is too far. :/")
                menu.set_value(glitchVehCmd, false);
            break end

            if not PED.IS_PED_IN_VEHICLE(ped, player_veh, false) then 
                util.toast("Player isn't in a vehicle. :/")
                menu.set_value(glitchVehCmd, false);
            break end

            if not VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(player_veh) then
                util.toast("No free seats are available. :/")
                menu.set_value(glitchVehCmd, false);
            break end

            local seat_count = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(veh_model)
            local glitch_obj = entities.create_object(object_hash, pos)
            local glitched_ped = PED.CREATE_RANDOM_PED(pos)
            local things = {glitched_ped, glitch_obj}
            
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(glitch_obj)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(glitched_ped)

            ENTITY.ATTACH_ENTITY_TO_ENTITY(glitch_obj, glitched_ped, 0, 0, 0, 0, 0, 0, 0, true, true, false, 0, true)

            for i, spawned_objects in ipairs(things) do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(spawned_objects)
                ENTITY.SET_ENTITY_VISIBLE(spawned_objects, false)
                ENTITY.SET_ENTITY_INVINCIBLE(spawned_objects, true)
            end

            for i = 0, seat_count -1 do
                if VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(player_veh) then
                    local emptyseat = i
                    for l = 1, 25 do
                        PED.SET_PED_INTO_VEHICLE(glitched_ped, player_veh, emptyseat)
                        ENTITY.SET_ENTITY_COLLISION(glitch_obj, true, true)
                        util.yield()
                    end
                end
            end
            if glitched_ped ~= nil then -- added a 2nd stage here because it didnt want to delete sometimes, this solved that lol.
                entities.delete_by_handle(glitched_ped) 
            end
            if glitch_obj ~= nil then 
                entities.delete_by_handle(glitch_obj)
            end
        end
    end)


    local glitchforcefield
    glitchforcefield = player_toggle_loop(griefing, pid, "Glitched Forcefield", {"forcefield"}, "Blocked by menus with entity spam protections.", function()
        local glitch_hash = util.joaat("p_spinning_anus_s")
        request_model(glitch_hash)

        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        
        if not players.exists(pid) then 
            util.toast("Player doesn't exist. :/")
            menu.set_value(glitchforcefield , false)
        util.stop_thread() end

        if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 1000.0 
        and v3.distance(pos, players.get_cam_pos(players.user())) > 1000.0 then
            util.toast("Player is too far. :/")
            menu.set_value(glitchforcefield, false)
        return end

        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            util.toast("Player is in a vehicle. :/")
            menu.set_value(glitchforcefield, false)
        return end

        local stupid_object = entities.create_object(glitch_hash, pos)
        ENTITY.SET_ENTITY_VISIBLE(stupid_object, false)
        util.yield()
        entities.delete_by_handle(stupid_object)
        util.yield()    
    end)

    local gravity = menu.list(griefing, "Gravitate Player", {}, "Works on all menus but can be detected. Also doesn't work on players with godmode.")
    local force = 1.00
    menu.slider_float(gravity, "Gravitational Force", {"force"}, "", 0, 100, 100, 10, function(value)
        force = value / 100
    end)

    local gravitate
    gravitate = player_toggle_loop(gravity, pid, "Gravitate Player", {"gravitate"}, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped)

        if not players.exists(pid) then 
            util.toast("Player doesn't exist. :/")
            menu.set_value(gravitate, false)
        util.stop_thread() end

        for _, id in ipairs(interior_stuff) do
            if players.is_godmode(pid) and (not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped)) and get_spawn_state(pid) ~= 0 and get_interior_player_is_in(pid) == id then
                util.toast("Player is in godmode. :/")
                menu.set_value(gravitate, false)
            return end
        end

        FIRE.ADD_EXPLOSION(players.get_position(pid), 29, force, false, true, 0.0, true)
    end)

    menu.action(griefing, "Hijack Vehicle", {"hijack"}, "Spawns a ped to take them out of their vehicle and drive away.", function()
        local veh = {1, 2, 3, 4, 5, 6, 7, 9, 10, 11, 12}
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local class = VEHICLE.GET_VEHICLE_CLASS(vehicle)
        local veh_speed = ENTITY.GET_ENTITY_SPEED(vehicle)

        if not PED.IS_PED_IN_VEHICLE(ped, vehicle, false) then
            util.toast("Player isn't in a vehicle. :/")
        return end
        
        for _, id in ipairs(veh) do
            if class == id and veh_speed > 3.0 then
                util.toast("This won't work right now. :/")
            return end
        end

        local spawned_ped = PED.CREATE_RANDOM_PED(pos.x, pos.y - 10, pos.z)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(spawned_ped)
        entities.set_can_migrate(entities.handle_to_pointer(spawned_ped), false)
        ENTITY.SET_ENTITY_INVINCIBLE(spawned_ped, true)
        ENTITY.SET_ENTITY_VISIBLE(spawned_ped, false)
        ENTITY.FREEZE_ENTITY_POSITION(spawned_ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(spawned_ped, true)
        PED.CAN_PED_RAGDOLL(spawned_ped, false)
        TASK.TASK_ENTER_VEHICLE(spawned_ped, vehicle, 1000, -1, 1.0, 2|8|16)
        util.yield(3000)
        TASK.TASK_VEHICLE_DRIVE_WANDER(spawned_ped, vehicle, 9999.0, 6)
        util.yield(5000)
        if not PED.IS_PED_IN_ANY_VEHICLE(spawned_ped, false) then
            entities.delete_by_handle(spawned_ped)
        end
        if PED.IS_PED_IN_VEHICLE(ped, vehicle, false) then
            util.toast("Failed to hijack players vehicle. :/")
        end
        TASK.TASK_VEHICLE_DRIVE_WANDER(spawned_ped, vehicle, 9999.0, 6) -- setting task a 2nd time since it seems to solve any issues of the ped not wandering off.
    end)

    menu.action(griefing, "Eviction Notice", {"evict"}, "", function()
        if players.is_in_interior(pid) then
            menu.trigger_commands("interiorkick" .. players.get_name(pid))
        else
            util.toast("Player is not in an interior. :/")
        end
    end)

    menu.action(griefing, "Ragdoll", {"ragdoll"}, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped)

        if not players.exists(pid) then 
            util.toast("Player doesn't exist. :/")
        util.stop_thread() end

        for _, id in ipairs(interior_stuff) do
            if players.is_godmode(pid) and (not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped)) and get_spawn_state(pid) ~= 0 and get_interior_player_is_in(pid) == id then
                util.toast("Player is in godmode. :/")
            return end
        end

        FIRE.ADD_EXPLOSION(players.get_position(pid), 29, 0.60, false, true, 0.0, true)
    end)

    menu.action(griefing,  "Force Player Out Of Interior", {}, "Works for most interiors.", function() -- very innovative!
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        local glitch_hash = util.joaat("p_spinning_anus_s")
        local poopy_butt = util.joaat("brickade2")
        request_model(glitch_hash)
        request_model(poopy_butt)
        for _, id in ipairs(interior_stuff) do
            if get_interior_player_is_in(pid) == id then
                util.toast("Player is not in an interior. :/")
            return end
        end
        for i = 1, 5 do
            local stupid_object = entities.create_object(glitch_hash, pos)
            local glitch_vehicle = entities.create_vehicle(poopy_butt, pos, 0)
            ENTITY.SET_ENTITY_VISIBLE(stupid_object, false)
            ENTITY.SET_ENTITY_VISIBLE(glitch_vehicle, false)
            ENTITY.SET_ENTITY_INVINCIBLE(glitch_vehicle, true)
            ENTITY.SET_ENTITY_COLLISION(stupid_object, true, true)
            ENTITY.APPLY_FORCE_TO_ENTITY(glitch_vehicle, 1, 0.0, 10, 10, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            util.yield(500)
            entities.delete_by_handle(stupid_object)
            entities.delete_by_handle(glitch_vehicle)
            util.yield(500)     
        end
    end)
    
    local freeze = menu.list(griefing, "Freeze Player", {}, "")
    player_toggle_loop(freeze, pid, "Hard Freeze", {"hardfreeze"}, "Freezes them along with their camera. Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {330622597, pid, 0, 0, 0, 0, 0})
        util.yield(500)
    end)

    player_toggle_loop(freeze, pid, "Blinking Freeze", {"blinkingfreeze"}, "Acts like hard freeze but blinks occasionally. Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {-1796714618, pid, 0, 1, 0, 0})
        util.yield(500)
    end)

    player_toggle_loop(freeze, pid, "Clear Ped Tasks", {}, "Basic freeze method. Blocked by most menus.", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(ped)
    end)
    
    local inf_loading = menu.list(griefing, "Infinite Loading Screen", {}, "")
    menu.action(inf_loading, "MC Teleport Method", {}, "Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {891653640, pid, 0, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
    end)

    menu.action(inf_loading, "Apartment Method", {}, "Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {-1796714618, pid, 0, 1, id})
    end)
        
    menu.action_slider(inf_loading, "Corrupted Phone Invite", {}, "", invites, function(index, name)
        switch name do
            case "Yacht":
                util.trigger_script_event(1 << pid, {36077543, pid, 1})
                util.toast("Yacht Invite Sent")
            break
            case "Office":
                util.trigger_script_event(1 << pid, {36077543, pid, 2})
                util.toast("Office Invite Sent")
            break
            case "Clubhouse":
                util.trigger_script_event(1 << pid, {36077543, pid, 3})
                util.toast("Clubhouse Invite Sent")
            break
            case "Office Garage":
                util.trigger_script_event(1 << pid, {36077543, pid, 4})
                util.toast("Office Garage Invite Sent")
            break
            case "Custom Auto Shop":
                util.trigger_script_event(1 << pid, {36077543, pid, 5})
                util.toast("Custom Auto Shop Invite Sent")
            break
            case "Apartment":
                util.trigger_script_event(1 << pid, {36077543, pid, 6})
                util.toast("Apartment Invite Sent")
            break
        end
    end)

    player_toggle_loop(griefing, pid, "Black Screen", {"blackscreen"}, "Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {891653640, pid, math.random(1, 32), 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
        util.yield(1000)
    end)

    local cage = menu.list(griefing, "Cage Player", {}, "")
    menu.action(cage, "Electric Cage", {"electriccage"}, "", function()
        local number_of_cages = 6
        local elec_box = util.joaat("prop_elecbox_12")
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        pos.z -= 0.5
        request_model(elec_box)
        local temp_v3 = v3.new(0, 0, 0)
        for i = 1, number_of_cages do
            local angle = (i / number_of_cages) * 360
            temp_v3.z = angle
            local obj_pos = temp_v3:toDir()
            obj_pos:mul(2.5)
            obj_pos:add(pos)
            for offs_z = 1, 5 do
                local electric_cage = entities.create_object(elec_box, obj_pos)
                spawned_objects[#spawned_objects + 1] = electric_cage
                ENTITY.SET_ENTITY_ROTATION(electric_cage, 90.0, 0.0, angle, 2, 0)
                obj_pos.z += 0.75
                ENTITY.FREEZE_ENTITY_POSITION(electric_cage, true)
            end
        end
    end)

    menu.action(cage, "Shipping Container", {"containercage"}, "", function()
        local container_hash = util.joaat("prop_container_ld_pu")
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        request_model(container_hash)
        pos.z -= 1
        local container = entities.create_object(container_hash, pos, 0)
        spawned_objects[#spawned_objects + 1] = container
        ENTITY.FREEZE_ENTITY_POSITION(container, true)
    end)

    menu.action(cage, "Vehicle Cage", {"vehiclecage"}, "", function()
        local container_hash = util.joaat("boxville3")
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        request_model(container_hash)
        local container = entities.create_vehicle(container_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 2.0, 0.0), ENTITY.GET_ENTITY_HEADING(ped))
        spawned_objects[#spawned_objects + 1] = container
        ENTITY.SET_ENTITY_VISIBLE(container, false)
        ENTITY.FREEZE_ENTITY_POSITION(container, true)
    end)

    menu.action(cage, "Delete Spawned Cages", {"clearcages"}, "", function()
        local entitycount = 0
        for i, object in ipairs(spawned_objects) do
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(object, false, false)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(object)
            entities.delete_by_handle(object)
            spawned_objects[i] = nil
            entitycount += 1
        end
        util.toast("Cleared " .. entitycount .. " Spawned Cage Objects")
    end) 

    local radio = menu.list(griefing, "Change Radio Station", {}, "")
    local stations = {}
    for station, name in pairs(station_name) do
        stations[#stations + 1] = station
    end
    menu.list_action(radio, "Radio Station", {}, "", stations, function(index, value)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = players.get_position(players.user())
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped)

        if not PED.IS_PED_IN_VEHICLE(ped, vehicle, false) then
            util.toast("Player isn't in a vehicle. :/")
        return end
        local radio_name = station_name[value]
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then 

            if not VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(vehicle) then
                util.toast("Failed to change players radio. :/")
            return end

            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(vehicle)
            if not PED.IS_PED_IN_VEHICLE(players.user_ped(), vehicle, false) then
                ENTITY.SET_ENTITY_VISIBLE(players.user_ped(), false)
                menu.trigger_commands("tpveh" .. players.get_name(pid))
                util.yield(250)
                AUDIO.SET_VEH_RADIO_STATION(vehicle, radio_name)
                util.yield(750)
                ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), pos, false, false, false)
            else
                util.yield(250)
                AUDIO.SET_VEH_RADIO_STATION(vehicle, radio_name)
            end
        end
    end)
    

    local control_veh
    control_veh = player_toggle_loop(griefing, pid, "Control Players Vehicle", {}, "Player must be in a normal vehicle for this to work.", function(toggle)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(ped)
        local class = VEHICLE.GET_VEHICLE_CLASS(vehicle)
        if not players.exists(pid) then util.stop_thread() end

        if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 1000.0 
        and v3.distance(pos, players.get_cam_pos(players.user())) > 1000.0 then
            util.toast("Player is too far. :/")
            menu.set_value(control_veh, false)
        return end

        if class == 15 then
            util.toast("Player is in a helicopter. :/")
            menu.set_value(control_veh, false)
        return end
        
        if class == 16 then
            util.toast("Player is in an airplane. :/")
            menu.set_value(control_veh, false)
        return end

        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            if PAD.IS_CONTROL_PRESSED(0, 34) then
                while not PAD.IS_CONTROL_RELEASED(0, 34) do
                    TASK.TASK_VEHICLE_TEMP_ACTION(ped, PED.GET_VEHICLE_PED_IS_IN(ped), 7, 100)
                    util.yield()
                end
            elseif PAD.IS_CONTROL_PRESSED(0, 35) then
                while not PAD.IS_CONTROL_RELEASED(0, 35) do
                    TASK.TASK_VEHICLE_TEMP_ACTION(ped, PED.GET_VEHICLE_PED_IS_IN(ped), 8, 100)
                    util.yield()
                end
            elseif PAD.IS_CONTROL_PRESSED(0, 32) then
                while not PAD.IS_CONTROL_RELEASED(0, 32) do
                    TASK.TASK_VEHICLE_TEMP_ACTION(ped, PED.GET_VEHICLE_PED_IS_IN(ped), 23, 100)
                    util.yield()
                end
            elseif PAD.IS_CONTROL_PRESSED(0, 33) then
                while not PAD.IS_CONTROL_RELEASED(0, 33) do
                    TASK.TASK_VEHICLE_TEMP_ACTION(ped, PED.GET_VEHICLE_PED_IS_IN(ped), 28, 100)
                    util.yield()
                end
            end
        else
            util.toast("Player is not in a vehicle. :/")
            menu.set_value(control_veh, false)
        end
        util.yield()
    end)

    local jesus_tgl = false
    local jesus_ped
    menu.toggle(griefing, "Griefer Jesus", {""}, "", function(toggled)
        if toggled then
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local pos = players.get_position(pid)
            local jesus = util.joaat("u_m_m_jesus_01")
            request_model(jesus)
    
            jesus_ped = entities.create_ped(26, jesus, pos, 0)
            ENTITY.SET_ENTITY_INVINCIBLE(jesus_ped, true)
            WEAPON.GIVE_WEAPON_TO_PED(jesus_ped, util.joaat("WEAPON_RAILGUN"), 9999, true, true)
            PED.SET_PED_HEARING_RANGE(jesus_ped, 9999.0)
            PED.SET_PED_CONFIG_FLAG(jesus_ped, 281, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(jesus_ped, 5, true)
            PED.SET_PED_COMBAT_ATTRIBUTES(jesus_ped, 46, true)
            PED.SET_PED_ACCURACY(jesus_ped, 100.0)
            PED.SET_PED_COMBAT_ABILITY(jesus_ped, 2)
            PED.SET_PED_CAN_RAGDOLL(jesus_ped, false)
            TASK.TASK_COMBAT_PED(jesus_ped, ped, 0, 16)
            
            while toggled do
                if PED.IS_PED_DEAD_OR_DYING(ped) then
                    repeat
                        util.yield()
                    until not PED.IS_PED_DEAD_OR_DYING(ped)
                    local new_pos = players.get_position(pid)
                    new_pos.y += 2
                    new_pos.z += 1 -- jesus kept sliding for some reason, doing this to prevent that.
                    util.yield(2500)
                    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(jesus_ped, new_pos, false, false, false)
                    WEAPON.REFILL_AMMO_INSTANTLY(jesus_ped)
                    TASK.TASK_COMBAT_PED(jesus_ped, ped, 0, 16)
                end
                util.yield()
            end
        end
        if jesus_ped ~= nil then
            entities.delete_by_handle(jesus_ped)
        end
    end)

    menu.action(griefing, "Kill Player Inside Interior", {}, "Works in most interiors other than apartment.", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)

        for _, id in ipairs(interior_stuff) do
            if get_interior_player_is_in(pid) == id then
                util.toast("Player is not in any interior. :/")
            return end
            if get_interior_player_is_in(pid) ~= id then
                util.trigger_script_event(1 << pid, {-1428749433, pid, 448051697, math.random(0, 9999)})
                util.yield(100)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 1000, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
            end
        end
    end)

    menu.action(griefing, "Send To Jail", {"arrest"}, "Blocked by most menus.", function()
        local my_pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))
        local my_ped = PLAYER.GET_PLAYER_PED(players.user())
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my_ped, 1628.5234, 2570.5613, 45.56485, true, false, false, false)
        menu.trigger_commands("givesh " .. players.get_name(pid))
        menu.trigger_commands("summon " .. players.get_name(pid))
        menu.trigger_commands("invisibility on")
        menu.trigger_commands("otr")
        util.yield(5000)
        menu.trigger_commands("invisibility off")
        menu.trigger_commands("otr")
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my_ped, my_pos)
    end)

    player_toggle_loop(griefing, pid, "Sound Spam", {}, "Blocked by some menus.", function()
        util.trigger_script_event(1 << pid, {36077543, pid, math.random(1, 6)})
        util.yield()
    end)

    menu.action(griefing, "Glitch Interior State", {}, "Can be undone by rejoining. Player must be in an apartment. Works on most menus.", function(s)
        if players.is_in_interior(pid) then
            util.trigger_script_event(1 << pid, {629813291, pid, pid, pid, pid, math.random(int_min, int_max), pid})
        else
            util.toast("Player isn't in an interior. :/")
        end
    end)

    menu.action(griefing, "Launch Player", {"launch"}, "Works on most menus.", function()
        local mdl = util.joaat("boxville3")
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        request_model(mdl)
                    
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            util.toast("Player is in a vehicle. :/")
        return end
        
        if TASK.IS_PED_WALKING(ped) then
            boxville = entities.create_vehicle(mdl, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, 2.0, 0.0), ENTITY.GET_ENTITY_HEADING(ped))
            ENTITY.SET_ENTITY_VISIBLE(boxville, false)
            util.yield(250)
            repeat
                if boxville ~= 0 and ENTITY.DOES_ENTITY_EXIST(boxville)then
                    ENTITY.APPLY_FORCE_TO_ENTITY(boxville, 1, 0.0, 0.0, 25.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                end
                util.yield()
                pos = ENTITY.GET_ENTITY_COORDS(ped)
            until pos.z > 10000.0
            util.yield(100)
            if boxville ~= 0 and ENTITY.DOES_ENTITY_EXIST(boxville) then 
                entities.delete_by_handle(boxville)
            end
        else
            util.toast("Player must be walking for this to work. :/")
        end
    end)
    
    menu.click_slider(griefing, "Fake Mug", {}, "", 0, 2147483647, 0, 1000, function(amount)
        util.trigger_script_event(1 << pid, {2041805809, players.user(), 244034214, amount, 0, 0, 0, 0, 0, 0, pid, players.user(), 0, 0})
        util.trigger_script_event(1 << players.user(), {2041805809, players.user(), 244034214, amount, 0, 0, 0, 0, 0, 0, pid, players.user(), 0, 0})
    end)

    player_toggle_loop(griefing, pid, "Taser Loop", {"tase"}, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        for i = 1, 50 do
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 0, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
        end
        util.yield()
    end)

    local antimodder = menu.list(bozo, "Anti-Modder", {}, "")
    menu.action(antimodder, "Stun", {"stun"}, "Works on menus that use entity proofs for godmode (Aka really bad menus).", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 99999, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
    end)
    
    menu.action(antimodder, "Kill Godmode Player", {"squish"}, "Squishes The Fuck Out Of Them Til' They Die. Works On Most Menus. (Note: Will not work if the target is using no ragdoll).", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped)
        local khanjali = util.joaat("khanjali")
        request_model(khanjali)

        if TASK.IS_PED_STILL(ped) then
            distance = 0.0
        elseif not TASK.IS_PED_STILL(ped) then
            distance = 2.0
        end

        local vehicle1 = entities.create_vehicle(khanjali, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0.0, distance, 2.8), ENTITY.GET_ENTITY_HEADING(ped))
        local vehicle2 = entities.create_vehicle(khanjali, pos, 0)
        local vehicle3 = entities.create_vehicle(khanjali, pos, 0)
        local vehicle4 = entities.create_vehicle(khanjali, pos, 0)
        local spawned_vehs = {vehicle1, vehicle2, vehicle3, vehicle4}
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle2, vehicle1, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, -180.0, 0, false, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle3, vehicle1, 0.0, 3.0, 3.0, 0.0, 0.0, 0.0, -180.0, 0, false, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle4, vehicle1, 0.0, 3.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0, false, true, false, 0, true)
        ENTITY.SET_ENTITY_VISIBLE(vehicle1, false)
        util.yield(5000)
        for i = 1, #spawned_vehs do
            entities.delete_by_handle(spawned_vehs[i])
        end
    end) 

    player_toggle_loop(antimodder, pid, "Remove Player Godmode", {}, "Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {-1428749433, pid, 448051697, math.random(0, 9999)})
    end)

    player_toggle_loop(antimodder, pid, "Remove Vehicle Godmode", {}, "Blocked by most menus.", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) and not PED.IS_PED_DEAD_OR_DYING(ped) then
            local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, true)
            ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
            ENTITY.SET_ENTITY_PROOFS(veh, false, false, false, false, false, 0, 0, false)
        end
    end)

    local tp_player = menu.list(bozo, "Teleport Player", {}, "Blocked by most menus.")
    local clubhouse = menu.list(tp_player, "Clubhouse", {}, "")
    local facility = menu.list(tp_player, "Facility", {}, "")
    local arcade = menu.list(tp_player, "Arcade", {}, "")
    local warehouse = menu.list(tp_player, "Warehouse", {}, "")
    local cayoperico = menu.list(tp_player, "Cayo Perico", {}, "")
    local interiors = menu.list(tp_player, "Interiors", {}, "") -- thx to aaron for sending me the labels and their numbers for most of the interiors <3

    for id, name in pairs(All_business_properties) do
        if id <= 12 then
            menu.action(clubhouse, name, {}, "", function()
                util.trigger_script_event(1 << pid, {891653640, pid, id, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, math.random(1, 10)})
            end)
        elseif id > 12 and id <= 21 then
            menu.action(facility, name, {}, "", function()
                util.trigger_script_event(1 << pid, {891653640, pid, id, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
            end)
        elseif id > 21 then
            menu.action(arcade, name, {}, "", function() 
                util.trigger_script_event(1 << pid, {891653640, pid, id, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1})
            end)
        end
    end

    local small = menu.list(warehouse, "Small Warehouse", {}, "")
    local medium = menu.list(warehouse, "Medium Warehouse", {}, "")
    local large = menu.list(warehouse, "Large Warehouse", {}, "")

    for id, name in pairs(small_warehouses) do
        menu.action(small, name, {}, "", function()
            util.trigger_script_event(1 << pid, {-1796714618, pid, 0, 1, id})
        end)
    end

    for id, name in pairs(medium_warehouses) do
        menu.action(medium, name, {}, "", function()
            util.trigger_script_event(1 << pid, {-1796714618, pid, 0, 1, id})
        end)
    end

    for id, name in pairs(large_warehouses) do
        menu.action(large, name, {}, "", function()
            util.trigger_script_event(1 << pid, {-1796714618, pid, 0, 1, id})
        end)
    end

    menu.action(tp_player, "Heist Passed Apartment Teleport", {}, "Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {-702866045, players.user(), pid, -1, 1, 1, 0, 1, 0}) 
    end) 
    
    menu.action(cayoperico, "Cayo Perico", {"tpcayo"}, "Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {330622597, pid, 0, 0, 3, 1})
    end)

    menu.action(cayoperico, "Cayo Perico v2", {"tpcayo2"}, "Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {-369672308, pid, 1})
    end)

    menu.action(cayoperico, "Cayo Perico (No Cutscene)", {"tpcayo2"}, "Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {330622597, pid, 0, 0, 4, 1})
    end)

    menu.action(cayoperico, "Leaving Cayo Perico", {"cayoleave"}, "Blocked by most menus. Player must be at cayo perico to trigger this.", function()
        util.trigger_script_event(1 << pid, {330622597, pid, 0, 0, 3})
    end)

    menu.action(cayoperico, "Kicked From Cayo Perico", {"cayokick"}, "Blocked by most menus.", function()
        util.trigger_script_event(1 << pid, {330622597, pid, 0, 0, 4, 0})
    end)

    local interior_tps = {
        [70] = "Bunker", -- 70 thru 80 are bunkers
        [81] = "Mobile Operations Center",
        [83] = "Hangar", -- 83 thru 87 are hangars
        [88] = "Avenger",
        [89] = "Facility", -- 89 thru 97 are facilities
        [102] = "Nightclub Garage",-- 102 thru 111 are garages
        [117] = "Terrorbyte",
        [122] = "Arena Workshop",
        [123] = "Casino",
        [124] = "Penthouse",
        [128] = "Arcade Garage", -- 128 thru 133 are garages
        [146] = "Nightclub",
        [147] = "Kosatka",
        [149] = "Auto Shop", -- 149 thru 153 are auto shops
        [155] = "Agency Office",
    }

    for id, name in pairs(interior_tps) do
        menu.action(interiors, name, {""}, "Blocked by most menus.", function()
            util.trigger_script_event(1 << pid, {1727896103, pid, id, 1, 0, 1, 1130429716, -1001012850, 1106067788, 0, 0, 1, 2123789977, 1, -1})
        end)
    end

    
    if bailOnAdminJoin then
        if players.is_marked_as_admin(pid) and not players.user() then
            util.toast(players.get_name(pid) .. " Is a Rockstar Admin. Bailing from the session.")
            menu.trigger_commands("quickbail")
            return
        end
    end
    
    local spec = menu.ref_by_rel_path(menu.player_root(pid), "Spectate")
    local spec_root = menu.list(spec, "Smart Method")
    local smart_spec
    smart_spec = menu.toggle_loop(spec_root, "Spectate", {"smartspectate"}, "Will automatically decide which spectate method to use.", function()
        if not players.exists(pid) then util.stop_thread() end

        local ninja_spec = menu.ref_by_rel_path(menu.player_root(pid), "Spectate>Ninja Method")
        local legit_spec = menu.ref_by_rel_path(menu.player_root(pid), "Spectate>Legit Method")

        if GRAPHICS.GET_TIMECYCLE_MODIFIER_INDEX() ~= -1 or get_interior_player_is_in(players.user()) ~= 0 then
            GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
        else
            GRAPHICS.CLEAR_TIMECYCLE_MODIFIER()
        end
        
        if legit_spec.value == false and ninja_spec.value == false and smart_spec.value == true then
            if get_interior_player_is_in(pid) == 0 then
                legit_spec.value = false
                ninja_spec.value = true
            else
                ninja_spec.value = false
                legit_spec.value = true
            end 
            util.yield(1000)
            if legit_spec.value == false and ninja_spec.value == false then
                smart_spec.value = false
            end
        end

    end, function()
        menu.trigger_commands("stopspectating")
    end)

    if menu.get_edition() > 1 then
        local esp_tgl
        esp_tgl = menu.toggle(spec_root, "Enable ESP", {""}, "", function(toggled)
            if toggled then
                while toggled do
                    if smart_spec.value == false then
                        util.toast("Spectate is disabled. :/")
                        esp_tgl.value = false
                    return end
                    util.yield()
                end
                menu.trigger_command(menu.ref_by_path("World>Inhabitants>Player ESP>Bone ESP>Low Latency Rendering"))
                menu.trigger_command(menu.ref_by_path("World>Inhabitants>Player ESP>Name ESP>Name ESP>Low Latency Rendering"))
                menu.trigger_commands("esptags off")
            else
                menu.trigger_command(menu.ref_by_path("World>Inhabitants>Player ESP>Bone ESP>Disabled"))
                menu.trigger_command(menu.ref_by_path("World>Inhabitants>Player ESP>Name ESP>Name ESP>Disabled"))
            end
        end)
    end


    local misc = menu.list(bozo, "Miscellaneous")
    player_toggle_loop(misc, pid, "Show Aim Lines", {"aimlines"}, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local weapon_ent = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(ped, false)
        local weapon_coords = ENTITY.GET_ENTITY_BONE_POSTION(weapon_ent, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(weapon_ent, "gun_muzzle"))
        local inst = v3.new()
        v3.set(inst, players.get_cam_rot(pid))
        local tmp = v3.toDir(inst)
        v3.set(inst, v3.get(tmp))
        v3.mul(inst, 1000)
        v3.set(tmp, players.get_cam_pos(pid))
        v3.add(inst, tmp)
        GRAPHICS.DRAW_LINE(weapon_coords, inst, 255, 255, 255, 255)
    end)

    local aimbor
    aimbor = player_toggle_loop(misc, pid, "Unfair Triggerbot", {"triggerbot"}, "", function()
        if pid == players.user() then 
            util.toast(lang.get_localised(-1974706693)) 
            aimbor.value = false
        return end
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local wpn = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
        local dmg = SYSTEM.ROUND(WEAPON.GET_WEAPON_DAMAGE(wpn, 0))
        local delay = WEAPON.GET_WEAPON_TIME_BETWEEN_SHOTS(wpn)
        local wpnEnt = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PLAYER.PLAYER_PED_ID(), false)
        local wpnCoords = ENTITY.GET_ENTITY_BONE_POSTION(wpnEnt, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(wpnEnt, "gun_muzzle"))
        if ENTITY.GET_ENTITY_ALPHA(ped) < 255 then return end
        if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(players.user(), ped) and not PED.IS_PED_RELOADING(players.user_ped()) then
            boneIndex = bones[math.random(#bones)]
            local pos = PED.GET_PED_BONE_COORDS(ped, boneIndex, 0.0, 0.0, 0.0)
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(wpnCoords, pos, dmg, true, wpn, players.user_ped(), true, false)
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 24, 1.0) -- shooting manually after so it has the effect of you shooting to seem more legit despite there being nothing legit about this
            util.yield(delay * 1000)
        end
    end)
end

players.on_join(player)
players.dispatch_on_join()
menu.toggle_loop(self, "Unlock 50 Car Garage", {}, "", function()
    if memory.read_byte(memory.script_global(262145 + 32688)) ~= 0 then
        memory.write_byte(memory.script_global(262145 + 32688), 0) 
    return end

    if memory.read_byte(memory.script_global(262145 + 32702)) ~= 1 then
        memory.write_byte(memory.script_global(262145 + 32702), 1)  
    end
end)

menu.toggle_loop(self, "Fast Respawn", {"fastrespawn"}, "", function()
    local gwobaw = memory.script_global(2672505 + 1685 + 756) -- Global_2672505.f_1685.f_756
    if PED.IS_PED_DEAD_OR_DYING(players.user_ped()) then
        GRAPHICS.ANIMPOSTFX_STOP_ALL()
        memory.write_int(gwobaw, memory.read_int(gwobaw) | 1 << 1)
    end
end,
    function()
    local gwobaw = memory.script_global(2672505 + 1685 + 756)
    memory.write_int(gwobaw, memory.read_int(gwobaw) &~ (1 << 1)) 
end)

local roll_speed = nil
menu.list_select(self, "Roll Speed", {}, "", {"Default", "1.25x", "1.5x", "1.75x", "2x"}, 1, function(index, value)
roll_speed = index
util.create_tick_handler(function()
    switch value do
        case "1.25x":
            STATS.STAT_SET_INT(util.joaat("MP"..util.get_char_slot().."_SHOOTING_ABILITY"), 115, true)
            break
        case "1.5x":
            STATS.STAT_SET_INT(util.joaat("MP"..util.get_char_slot().."_SHOOTING_ABILITY"), 125, true)
            break
        case "1.75x":
            STATS.STAT_SET_INT(util.joaat("MP"..util.get_char_slot().."_SHOOTING_ABILITY"), 135, true)
            break
        case "2x":
            STATS.STAT_SET_INT(util.joaat("MP"..util.get_char_slot().."_SHOOTING_ABILITY"), 150, true)
            break
        end
        return roll_speed == index
    end)
end)


local climb_speed = nil
menu.list_select(self, "Climb Speed", {}, "", {"Default", "1.25x", "1.5x", "2x",}, 1, function(index, value)
climb_speed = index
util.create_tick_handler(function()
    if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 1) then
        switch value do
            case "1.25x":
                PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
                util.yield(150)
                break
            case "1.5x":
                PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
                util.yield(75)
                break
            case "2x":
                PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
                util.yield(50)
                break
            end
        end
        return climb_speed == index
    end)
end)

menu.toggle_loop(self, "Ghost Armed Players", {"ghostarmedplayers"}, "Ghost players that have an sort of weapon out.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if WEAPON.IS_PED_ARMED(ped, 7) or TASK.GET_IS_TASK_ACTIVE(ped, 199) or TASK.GET_IS_TASK_ACTIVE(ped, 128) 
        or IsPlayerUsingGuidedMissile(pid) or IsPlayerInRcTank(pid) or IsPlayerInRcBandito(pid) or IsPlayerFlyingAnyDrone(pid) then
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
        else
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
        end
    end
end, function()
    for _, pid in ipairs(players.list(false, true, true)) do
        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
    end
end)

local orb = menu.list(self, "Anti-Orbital Cannon")
local ghost = menu.list(orb, "Ghost")
ghost_tgl = menu.toggle_loop(ghost, "Always", {"ghostorb"}, "Automatically ghost players that are using the orbital cannon", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local cam_pos = players.get_cam_pos(pid)
        if IsPlayerUsingOrbitalCannon(pid) and TASK.GET_IS_TASK_ACTIVE(ped, 135)
        and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), cam_pos) < 400
        and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), cam_pos) > 340 then
            util.toast(players.get_name(pid) .. " Is targeting you with the orbital cannon")
        end
       if IsPlayerUsingOrbitalCannon(pid) then
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
        else
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
        end
    end
end, function()
    for _, pid in ipairs(players.list(false, true, true)) do
        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
    end
end)

local tgl
tgl = menu.toggle_loop(ghost, "While Being Targeted", {}, "Automatically ghost players that are targetting you with the orbital cannon.", function()
    if menu.get_value(ghost_tgl) then
        menu.set_value(tgl, false)
    return end
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local cam_pos = players.get_cam_pos(pid)
        if IsPlayerUsingOrbitalCannon(pid) and TASK.GET_IS_TASK_ACTIVE(ped, 135) 
        and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), cam_pos) < 400
        and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), cam_pos) > 340 then
            util.toast(players.get_name(pid) .. " Is targeting you with the orbital cannon")
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
        else
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
        end
    end
end, function()
    for _, pid in ipairs(players.list(false, true, true)) do
        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
    end
end)


local annoy = menu.list(orb, "Annoy", {}, "Rapidly shows and removes your name from the targetable players list.")
local orb_delay = 1000
menu.list_select(annoy, "Delay", {}, "The speed in which your name will flicker at for orbital cannon users.", {"Slow", "Medium", "Fast"}, 1, function(index, value)
switch value do
    case "Slow":
        orb_delay = 1000
        break
    case "Medium":
        orb_delay = 500
        break
    case "Fast":
        orb_delay = 100
        break
    end
end)

local annoy_tgl
annoy_tgl = menu.toggle_loop(annoy, "Enable", {}, "", function()
    if menu.get_value(ghost_tgl) then
        menu.set_value(annoy_tgl, false)
        util.toast("Please don't enable Annoy and Ghost simultaneuosly. ;)")
    return end
    
    for _, pid in ipairs(players.list(false, true, true)) do
       if IsPlayerUsingOrbitalCannon(pid) then
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, true)
            util.yield(orb_delay)
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
            util.yield(orb_delay)
        else
            NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
        end
    end
end, function()
    for _, pid in ipairs(players.list(false, true, true)) do
        NETWORK.SET_REMOTE_PLAYER_AS_GHOST(pid, false)
    end
end)


menu.toggle_loop(self, "Friendly AI", {""}, "AIs won't target you.", function()
    PED.SET_PED_RESET_FLAG(players.user_ped(), 124, true)
end)

menu.toggle_loop(self, "Auto Accept Joining Games", {}, "Auto accepts join screens.", function() -- credits to soulreaper for sending me this :D
    local message_hash = HUD.GET_WARNING_SCREEN_MESSAGE_HASH()
    if message_hash == 15890625 then
        PAD.SET_CONTROL_VALUE_NEXT_FRAME(2, 201, 1.0)
        util.yield(50)
    end
end)

local proofsList = menu.list(self, "Invulnerabilities", {}, "")
local immortalityCmd = menu.ref_by_path("Self>Immortality")
for _,data in pairs(proofs) do
    menu.toggle(proofsList, data.name, {data.name:lower().."proof"}, "Makes you invulnerable to "..data.name:lower()..".", function(toggle)
        data.on = toggle
    end)
end
util.create_tick_handler(function()
    local local_player = players.user_ped()
    if not menu.get_value(immortalityCmd) then
        ENTITY.SET_ENTITY_PROOFS(local_player, proofs.bullet.on, proofs.fire.on, proofs.explosion.on, proofs.collision.on, proofs.melee.on, proofs.steam.on, false, proofs.drown.on)
    end
end)

menu.divider(recovery, "Acid Lab Manager")
menu.click_slider(recovery, "Product Capacity", {"productcapacity"}, "", 0, 1000, 160, 1, function(capacity)
    memory.write_int(memory.script_global(262145 + 18949), capacity) 
end)

menu.toggle(recovery, "Make Supplies Free", {"supplycost"}, "", function()
    memory.write_int(memory.script_global(262145 + 21869), 0)
end, function()
    memory.write_int(memory.script_global(262145 + 21869), 60000)
end)

menu.toggle(recovery, "Increase Production Speed", {"increaseproductionspeed"}, "", function()
    memory.write_int(memory.script_global(262145 + 17396), 100) 
end, function()
    memory.write_int(memory.script_global(262145 + 17396), 135000) 
end)

menu.action(recovery, "Resupply Acid", {"resupplyacid"}, "", function()
    local time = NETWORK.GET_CLOUD_TIME_AS_INT() - memory.read_int(memory.script_global(262145 + 18954))
    memory.write_int(memory.script_global(1648637 + 1 + 6), time)
end)

menu.click_slider(recovery, "Sell Value Multiplier", {"value"}, "Warning: Tested safe amount is ~2 million. Try not to exceed unless you're bored and don't care about your account.", 0, 10000, 1, 1, function(value)
    memory.write_int(memory.script_global(262145 + 17425), value * 1485) 
end)

menu.toggle_loop(missions, "Skip Dax Work Cooldown", {}, "", function() -- thx icedoomfist for the stat name <3
    STATS.STAT_SET_INT(util.joaat("MP"..util.get_char_slot().."_XM22JUGGALOWORKCDTIMER"), -1, true)
end)

menu.toggle_loop(missions, "Disable Block Entity Spam", {}, "Will automatically disable block entity spam while in missions to prevent them from messing up.", function()
    local EntitySpam = menu.ref_by_path("Online>Protections>Block Entity Spam>Block Entity Spam")
    if NETWORK.NETWORK_IS_ACTIVITY_SESSION() == true then
        if not menu.get_value(EntitySpam) then return end
        menu.trigger_command(EntitySpam, "off")
    else
        if menu.get_value(EntitySpam) then return end
        menu.trigger_command(EntitySpam, "on")
    end
end)

menu.action(missions, "Kill All Peds", {}, "", function()
    local counter = 0
    for _, ped in ipairs(entities.get_all_peds_as_handles()) do
        if HUD.GET_BLIP_COLOUR(HUD.GET_BLIP_FROM_ENTITY(ped)) == 1 or TASK.GET_IS_TASK_ACTIVE(ped, 352) then -- shitty way to go about it but hey, it works (most of the time).
            ENTITY.SET_ENTITY_HEALTH(ped, 0)
            counter += 1
            util.yield()
        end
    end
    if counter == 0 then
        util.toast("No Peds Found. :/")
    else
        util.toast("Killed ".. tostring(counter) .." Peds.")
    end
end)

menu.action(missions, "Teleport Pickups To Me", {}, "", function()
    local counter = 0
    local pos = players.get_position(players.user())
    for _, pickup in ipairs(entities.get_all_pickups_as_handles()) do
        ENTITY.SET_ENTITY_COORDS(pickup, pos, false, false, false, false)
        counter += 1
        util.yield()
    end
    if counter == 0 then
        util.toast("No Pickups Found. :/")
    else
        util.toast("Teleported ".. tostring(counter) .." Pickups.")
    end
end)

menu.toggle_loop(weapons, "Unfair Triggerbot", {"triggerbotall"}, "", function()
    local wpn = WEAPON.GET_SELECTED_PED_WEAPON(players.user_ped())
    local dmg = SYSTEM.ROUND(WEAPON.GET_WEAPON_DAMAGE(wpn, 0))
    local delay = WEAPON.GET_WEAPON_TIME_BETWEEN_SHOTS(wpn)
    local wpnEnt = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PLAYER.PLAYER_PED_ID(), false)
    local wpnCoords = ENTITY.GET_ENTITY_BONE_POSTION(wpnEnt, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(wpnEnt, "gun_muzzle"))
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if ENTITY.GET_ENTITY_ALPHA(ped) < 255 then return end
        boneIndex = bones[math.random(#bones)]
        local pos = PED.GET_PED_BONE_COORDS(ped, boneIndex, 0.0, 0.0, 0.0)
        if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(players.user(), ped) and not PED.IS_PED_RELOADING(players.user_ped()) then
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(wpnCoords, pos, dmg, true, wpn, players.user_ped(), true, false)
            PAD.SET_CONTROL_VALUE_NEXT_FRAME(0, 24, 1.0) -- shooting manually after so it has the effect of you shooting to seem more legit despite there being nothing legit about this
            util.yield(delay * 1000)
        end
    end
end)

local modifier = 1.00
menu.slider_float(weapons, "Melee Damage Modifier", {"meleedamage"}, "", 100, 1000, 100, 10, function(value)
    modifier = value / 100
    PLAYER.SET_PLAYER_MELEE_WEAPON_DAMAGE_MODIFIER(players.user(), modifier)
end)

menu.toggle_loop(weapons, "Max Lockon Range", {}, "Sets your players lockon range with homing missles and auto aim to the max.", function()
    PLAYER.SET_PLAYER_LOCKON_RANGE_OVERRIDE(players.user(), 99999999.0)
end)

local weapon_thing = menu.list(weapons, "Change Bullet Projectile", {}, "Change the bullet your gun shoots.")
for id, data in pairs(weapon_stuff) do
    local name = data[1]
    local weapon_name = data[2]
    local a = false
    menu.toggle(weapon_thing, name, {}, "", function(toggle)
        a = toggle
        while a do
            local weapon = util.joaat(weapon_name)
            projectile = weapon
            while not WEAPON.HAS_WEAPON_ASSET_LOADED(projectile) do
                WEAPON.REQUEST_WEAPON_ASSET(projectile, 31, false)
                util.yield(10)
            end
            local inst = v3.new()
            if PED.IS_PED_SHOOTING(PLAYER.PLAYER_PED_ID()) then
                if not WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(PLAYER.PLAYER_PED_ID(), memory.addrof(inst)) then
                    v3.set(inst,CAM.GET_FINAL_RENDERED_CAM_ROT(2))
                    local tmp = v3.toDir(inst)
                    v3.set(inst, v3.get(tmp))
                    v3.mul(inst, 1000)
                    v3.set(tmp, CAM.GET_FINAL_RENDERED_CAM_COORD())
                    v3.add(inst, tmp)
                end
                local x, y, z = v3.get(inst)
                local wpEnt = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PLAYER.PLAYER_PED_ID(), false)
                local wpCoords = ENTITY.GET_ENTITY_BONE_POSTION(wpEnt, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(wpEnt, "gun_muzzle"))
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(wpCoords.x, wpCoords.y, wpCoords.z, x, y, z, 1, true, weapon, PLAYER.PLAYER_PED_ID(), true, false, 1000.0)
            end
            util.yield()
        end
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(pos, 999999.0, 0)
    end)
end

menu.toggle_loop(weapons, "Fast Hands", {"fasthands"}, "Swaps your weapons faster.", function()
    if TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 56) then
        PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
    end
end)


menu.toggle_loop(weapons, "Lock On To Players", {}, "Allows you to lock on to players with the homing launcher.", function()
    for _, pid in ipairs(players.list(true, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        PLAYER.ADD_PLAYER_TARGETABLE_ENTITY(players.user(), ped)
        ENTITY.SET_ENTITY_IS_TARGET_PRIORITY(ped, false, 400.0)    
    end
end, function()
    for _, pid in ipairs(players.list(true, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        PLAYER.REMOVE_PLAYER_TARGETABLE_ENTITY(players.user(), ped)
    end
end)

if menu.get_edition() > 1 then
    menu.toggle_loop(weapons, "ESP While Aiming", {"aimesp"}, "", function()
        if PLAYER.IS_PLAYER_FREE_AIMING(players.user()) then
            menu.trigger_command(menu.ref_by_path("World>Inhabitants>Player ESP>Bone ESP>Low Latency Rendering"))
        else
            menu.trigger_command(menu.ref_by_path("World>Inhabitants>Player ESP>Bone ESP>Disabled"))
        end
    end, function()
        menu.trigger_command(menu.ref_by_path("World>Inhabitants>Player ESP>Bone ESP>Disabled"))
    end)
end

for id, data in pairs(visual_stuff) do
    local visual_name = data[1]
    local visual_thing = data[2]
    local visual = false
    local visual_toggle
    visual_toggle = menu.toggle(visuals, visual_name, {""}, "", function(toggled)
        visual = toggled
        if not menu.get_value(visual_toggle) then
            GRAPHICS.ANIMPOSTFX_STOP_ALL()
        return end

        while visual do
            repeat
            GRAPHICS.SET_TIMECYCLE_MODIFIER(visual_thing)
            menu.trigger_commands("shader off")
            util.yield()
            until GRAPHICS.GET_TIMECYCLE_MODIFIER_INDEX() ~= 728
            util.yield()
        end
        GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
    end)
end 

local veh_jump = menu.list(vehicles, "Vehicle Jump")
local force = 25.00
menu.slider_float(veh_jump, "Power", {"jumpiness"}, "", 0, 10000, 2500, 100, function(value)
    force = value / 100
end)
menu.toggle_loop(veh_jump, "Enable", {"vehiclejump"}, "Press spacebar to jump.", function()
    local veh = entities.get_user_vehicle_as_handle()
    if veh ~= 0 and ENTITY.DOES_ENTITY_EXIST(veh) and PAD.IS_CONTROL_JUST_RELEASED(0, 102) then
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, force/1.5, force, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
        repeat
            util.yield()
        until not ENTITY.IS_ENTITY_IN_AIR(veh)
    end
end)

local deformation = 1.00
menu.slider_float(vehicles, "Deformation", {"deformation"}, "", 0, 10000, 100, 100, function(value)
    deformation = value / 100
    menu.trigger_commands("vhdeformationmult " .. deformation)
end)

local seat_id = -1
local moved_seat = menu.click_slider(vehicles, "Move To Seat", {}, "", 1, 1, 1, 1, function(seat_id)
    TASK.TASK_WARP_PED_INTO_VEHICLE(players.user_ped(), entities.get_user_vehicle_as_handle(), seat_id - 2)
end)

menu.on_tick_in_viewport(moved_seat, function()
    if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        moved_seat.max_value = 0
    return end

    if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
        moved_seat.max_value = 0
    return end
    
    moved_seat.max_value = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(ENTITY.GET_ENTITY_MODEL(entities.get_user_vehicle_as_handle()))
end)

menu.toggle_loop(vehicles, "Fast Hotwire", {""}, "", function()
    if not VEHICLE.GET_IS_VEHICLE_ENGINE_RUNNING(entities.get_user_vehicle_as_handle()) and TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 150) then
        PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
    end
end)

menu.toggle_loop(vehicles, "Fast Enter/Exit", {"fastvehcleenter"}, "Enter vehicles faster.", function()
    if (TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 160) or TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 167) or TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 165)) and not TASK.GET_IS_TASK_ACTIVE(players.user_ped(), 195) then
        PED.FORCE_PED_AI_AND_ANIMATION_UPDATE(players.user_ped())
    end
end)

menu.toggle_loop(vehicles, "Disable Godmode On Exit", {""}, "", function()
    if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(entities.get_user_vehicle_as_handle()) then
        if not PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) then
            ENTITY.SET_ENTITY_CAN_BE_DAMAGED(PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), true), true)
        end
    end
end)

menu.toggle_loop(vehicles, "Wheelie Launch", {}, "Press ctrl and w to wheelie.", function(toggled)
    local veh = entities.get_user_vehicle_as_handle()
    if veh == 0 then return end
    local CAutomobile = entities.handle_to_pointer(veh)
    local CHandlingData = memory.read_long(CAutomobile + 0x0918)
    if util.is_key_down(0x57) and util.is_key_down(0x11) then 
       memory.write_float(CHandlingData + 0x00EC, -0.25)
    else
       memory.write_float(CHandlingData + 0x00EC, 0.5)
    end
end)

menu.toggle_loop(vehicles, "Bypass Anti-Lockon", {}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local veh = PED.GET_VEHICLE_PED_IS_USING(ped)
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            VEHICLE.SET_VEHICLE_ALLOW_HOMING_MISSLE_LOCKON_SYNCED(veh, true)
        end
    end
end)

menu.toggle_loop(vehicles, "Stick To Ground", {""}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
    local velocity = ENTITY.GET_ENTITY_VELOCITY(vehicle)
    local height = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(vehicle)
    local controls = {32, 33, 34, 35}
    if height < 5.0 then
        if ENTITY.IS_ENTITY_IN_AIR(vehicle) then
            VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
        end
    else
        for _, key in ipairs(controls) do
            if vehicle ~= 0 and PAD.IS_CONTROL_PRESSED(0, key) then
                while not PAD.IS_CONTROL_RELEASED(0, key) and ENTITY.IS_ENTITY_IN_AIR(vehicle) do
                    ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 2, 0, 0, -500 - velocity.z, 0, 0, 0, 0, true, false, true, false, true)
                    util.yield()
                end
            end
        end
    end
end)

menu.toggle_loop(vehicles, "Spinbot", {"spinbot"}, "", function()
    local vehicle = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
    local velocity = ENTITY.GET_ENTITY_VELOCITY(vehicle)
    local height = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(vehicle)
    if height < 5.0 and height > 0.1 then
        VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
    end
    if vehicle ~= 0 and not PED.IS_PED_DEAD_OR_DYING(players.user_ped()) and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
        ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 5, 0, 0, 150.0, 0, 0, 0, 0, true, false, true, false, true)
    end
end)

menu.action(funfeatures, "Broomstick Mk2", {""}, "Note: You will be invisible for other players.", function()
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
    local broomstick = util.joaat("prop_tool_broom")
    local oppressor = util.joaat("oppressor2")
    request_model(broomstick)
    request_model(oppressor)
    obj = entities.create_object(broomstick, pos)
    veh = entities.create_vehicle(oppressor, pos, 0)
    ENTITY.SET_ENTITY_VISIBLE(veh, false, false)
    PED.SET_PED_INTO_VEHICLE(players.user_ped(), veh, -1)
    ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, veh, 0, 0, 0, 0.3, -80.0, 0, 0, true, false, false, false, 0, true) -- thanks to chaos mod for doing the annoying rotation work for me :P
end)

local headlamp = menu.list(funfeatures, "Headlamp", {}, "Does not network with other players.")
local distance = 25.0
menu.slider_float(headlamp, "Distance", {"distance"}, "Distance that it will light up.", 100, 10000, 1500, 100, function(value)
    distance = value / 100
end)

local brightness = 10.0
menu.slider_float(headlamp, "Brightness", {"brightness"}, "Brightness of the light.", 100, 10000, 1000, 100, function(value)
    brightness = value / 100
end)

local radius = 15.0
menu.slider_float(headlamp, "Radius", {"radius"}, "Higher values will broaden the beam.", 100, 5000, 2000, 100, function(value)
    radius = value / 100
end)

local color = {r = 1, g = 235/255, b = 190/255, a = 0}
menu.colour(headlamp, "Colour", {"colour"}, "", color, true, function(value)
    color = value 
end)

menu.toggle_loop(headlamp, "Headlamp", {"headlamp"}, "", function()
    local head_pos = PED.GET_PED_BONE_COORDS(players.user_ped(), 31086, 0.0, 0.0, 0.0)
    local cam_rot = players.get_cam_rot(players.user())
    GRAPHICS.DRAW_SPOT_LIGHT(head_pos, cam_rot:toDir(), math.floor(color.r * 255), math.floor(color.g * 255), math.floor(color.b * 255), distance * 1.5, brightness, 0.0, radius, distance)
end)

menu.toggle(funfeatures, "Power Outage", {"poweroutage"}, "", function(toggled)
    GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(toggled)
end)

menu.toggle(funfeatures, "Blackout", {"blackout"}, "", function(toggled)
    menu.trigger_commands("time 1")
    GRAPHICS.SET_ARTIFICIAL_LIGHTS_STATE(toggled)
    if toggled then
        GRAPHICS.SET_TIMECYCLE_MODIFIER("dlc_island_vault")
    else
        GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
    end
end)

local obj
menu.toggle(funfeatures, "Forcefield", {}, "Attaches a UFO to your ped destroying anything in your path.", function(toggled)
    local mdl = util.joaat("p_spinning_anus_s")
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
    request_model(mdl)
    if toggled then
        obj = entities.create_object(mdl, pos)
        ENTITY.SET_ENTITY_VISIBLE(obj, false)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(obj, players.user_ped(), 0, 0, 0, 0, 0, 0, 0, false, false, true, false, 0, false, 0)
    else
        if obj ~= nil then 
            entities.delete_by_handle(obj)
        end
    end
end)

local jesus_main = menu.list(funfeatures, "Jesus Take The Wheel", {}, "Jesus take the wheeeeeeel!")
local style = 786603
menu.slider_text(jesus_main, "Driving Style", {}, "Click to select a style", style_names, function(index, value)
    style = value
end)

local speed = 20.00
menu.slider_float(jesus_main, "Driving Speed", {""}, "", 0, 10000, 2000, 100, function(value)
    speed = value / 100
end)

local toggled = false
local jesus_toggle
jesus_toggle = menu.toggle(jesus_main, "Enable", {}, "", function(toggle)
    toggled = toggle
    local ped = players.user_ped()
    local my_pos = ENTITY.GET_ENTITY_COORDS(ped, false)
    local vehicle = entities.get_user_vehicle_as_handle()
    jesus = util.joaat("u_m_m_jesus_01")
    request_model(jesus)

    if toggled then
        if not PED.IS_PED_IN_ANY_VEHICLE(ped, false) then 
            util.toast("Put your ass in/on a vehicle first. :)")
            menu.set_value(jesus_toggle, false)
        return end
        
        jesus_ped = entities.create_ped(26, jesus, my_pos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(jesus_ped, true)
        PED.SET_PED_INTO_VEHICLE(ped, vehicle, -2)
        PED.SET_PED_INTO_VEHICLE(jesus_ped, vehicle, -1)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(jesus_ped, true)
        PED.SET_PED_KEEP_TASK(jesus_ped, true)

        if HUD.IS_WAYPOINT_ACTIVE() then
            local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(jesus_ped, vehicle, pos, speed, style, 0.0)
        else
            TASK.TASK_VEHICLE_DRIVE_WANDER(jesus_ped, vehicle, 20.0, 786603)
            util.toast("Waypoint not found. Jesus will drive you around. :)")
        end
        util.yield()
    else
        if jesus_ped ~= nil then 
            entities.delete_by_handle(jesus_ped)
            PED.SET_PED_INTO_VEHICLE(ped, vehicle, -1)
        end
    end
    
    while toggled do
        local height = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(vehicle)
        local upright_value = ENTITY.GET_ENTITY_UPRIGHT_VALUE(vehicle)
        if height < 5.0 and upright_value < 0.0 then
            VEHICLE.SET_VEHICLE_ON_GROUND_PROPERLY(vehicle)
        end
        util.yield()
    end
end)

menu.toggle(funfeatures, "Tesla Autopilot", {}, "Elon Musk.", function(toggled)
    local ped = players.user_ped()
    local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
    local tesla_ai = util.joaat("u_m_y_baygor")
    local tesla = util.joaat("raiden")
    request_model(tesla_ai)
    request_model(tesla)
    if toggled then     
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            menu.trigger_commands("deletevehicle")
        end

        tesla_ai_ped = entities.create_ped(26, tesla_ai, pos, 0)
        tesla_vehicle = entities.create_vehicle(tesla, pos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(tesla_ai_ped, true) 
        ENTITY.SET_ENTITY_VISIBLE(tesla_ai_ped, false)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(tesla_ai_ped, true)
        PED.SET_PED_INTO_VEHICLE(ped, tesla_vehicle, -2)
        PED.SET_PED_INTO_VEHICLE(tesla_ai_ped, tesla_vehicle, -1)
        PED.SET_PED_KEEP_TASK(tesla_ai_ped, true)
        VEHICLE.SET_VEHICLE_COLOURS(tesla_vehicle, 111, 111)
        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 23, 8, false)
        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 15, 1, false)
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(tesla_vehicle, 111, 147)
        menu.trigger_commands("performance")

        if HUD.IS_WAYPOINT_ACTIVE() then
            local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(tesla_ai_ped, tesla_vehicle, pos, 20.0, 786603, 0)
        else
            TASK.TASK_VEHICLE_DRIVE_WANDER(tesla_ai_ped, tesla_vehicle, 20.0, 786603)
        end
    else
        if tesla_ai_ped ~= nil then 
            entities.delete_by_handle(tesla_ai_ped)
        end
        if tesla_vehicle ~= nil then 
            entities.delete_by_handle(tesla_vehicle)
        end
    end
end)

for index, data in pairs(interiors) do
    local location_name = data[1]
    local location_coords = data[2]
    menu.action(teleport, location_name, {}, "", function()
        menu.trigger_commands("doors on")
        menu.trigger_commands("nodeathbarriers on")
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(players.user_ped(), location_coords.x, location_coords.y, location_coords.z, false, false, false)
    end)
end

local finger_thing = menu.list(funfeatures, "Finger Gun", {}, "Shoot bullets from your finger. (Note: will not do damage to players)")
for id, data in pairs(weapon_stuff) do
    local name = data[1]
    local weapon_name = data[2]
    local projectile = util.joaat(weapon_name)
    while not WEAPON.HAS_WEAPON_ASSET_LOADED(projectile) do
        WEAPON.REQUEST_WEAPON_ASSET(projectile, 31, false)
        util.yield(10)
    end
    menu.toggle(finger_thing, name, {}, "", function(state)
        toggled = state
        while toggled do
            if memory.read_int(memory.script_global(4521801 + 930)) == 3 then
                memory.write_int(memory.script_global(4521801 + 935), NETWORK.GET_NETWORK_TIME())
                local inst = v3.new()
                v3.set(inst,CAM.GET_FINAL_RENDERED_CAM_ROT(2))
                local tmp = v3.toDir(inst)
                v3.set(inst, v3.get(tmp))
                v3.mul(inst, 1000)
                v3.set(tmp, CAM.GET_FINAL_RENDERED_CAM_COORD())
                v3.add(inst, tmp)
                local x, y, z = v3.get(inst)
                local fingerPos = PED.GET_PED_BONE_COORDS(players.user_ped(), 4089, 1.0, 0, 0)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(fingerPos, x, y, z, 1, true, projectile, 0, true, false, 500.0, players.user_ped(), 0)
            end
            util.yield(100)
        end
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(pos, 999999, 0)
    end)
end

local jinx_pet
jinx_toggle = menu.toggle_loop(funfeatures, "Personal Pet Jinx", {}, "", function()
    if not jinx_pet or not ENTITY.DOES_ENTITY_EXIST(jinx_pet) then
        local jinx = util.joaat("a_c_cat_01")
        request_model(jinx)
        local pos = players.get_position(players.user())
        jinx_pet = entities.create_ped(28, jinx, pos, 0)
        PED.SET_PED_COMPONENT_VARIATION(jinx_pet, 0, 0, 1, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(jinx_pet, true)
    end
    NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(jinx_pet)
    TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(jinx_pet, players.user_ped(), 0, -0.3, 0, 7.0, -1, 1.5, true)
    util.yield(2500)
end, function()
    entities.delete_by_handle(jinx_pet)
    jinx_pet = nil
end)

local jinx_army = {}
local army = menu.list(funfeatures, "Jinx Army", {}, "")
menu.click_slider(army, "Spawn Jinx Army", {}, "", 1, 256, 30, 1, function(val)
    local ped = players.user_ped()
    local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
    pos.y = pos.y - 5
    pos.z = pos.z + 1
    local jinx = util.joaat("a_c_cat_01")
    request_model(jinx)
     for i = 1, val do
        jinx_army[i] = entities.create_ped(28, jinx, pos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(jinx_army[i], true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(jinx_army[i], true)
        PED.SET_PED_COMPONENT_VARIATION(jinx_army[i], 0, 0, 1, 0)
        TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(jinx_army[i], ped, 0, -0.3, 0, 7.0, -1, 10, true)
        util.yield()
     end 
end)

menu.action(army, "Clear Jinxs", {}, "", function()
    for i, ped in ipairs(entities.get_all_peds_as_handles()) do
        if PED.IS_PED_MODEL(ped, util.joaat("a_c_cat_01")) then
            entities.delete_by_handle(ped)
        end
    end
end)

menu.action(funfeatures, "Find Jinx", {}, "", function()
    local ped = players.user_ped()
    local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
    if jinx_pet ~= nil then 
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(jinx_pet, pos, false, false, false)
    else
        util.toast("Jinx Wasn't Found. :/")
    end
end)


menu.toggle_loop(modder_detections, "Godmode", {}, "Detects if someone is using godmode.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        for _, id in ipairs(interior_stuff) do
            if players.is_godmode(pid) and not players.is_in_interior(pid) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and get_spawn_state(pid) == 99 and get_interior_player_is_in(pid) == id then
                util.draw_debug_text(players.get_name(pid) .. " Is In Godmode")
                break
            end
        end
    end 
end)

menu.toggle_loop(modder_detections, "Vehicle Godmode", {}, "Detects if someone is using a vehicle that is in godmode.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
        if PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            for _, id in ipairs(interior_stuff) do
                if not ENTITY.GET_ENTITY_CAN_BE_DAMAGED(vehicle) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) 
                and get_spawn_state(pid) == 99 and get_interior_player_is_in(pid) == id and pid == driver then
                    util.draw_debug_text(players.get_name(driver) ..  " Is In Vehicle Godmode")
                    break
                end
            end
        end
    end 
end)

menu.toggle_loop(modder_detections, "Unreleased Vehicle", {}, "Detects if someone is using a vehicle that has not been released yet.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local modelHash = players.get_vehicle_model(pid)
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
        for i, name in ipairs(unreleased_vehicles) do
            if modelHash == util.joaat(name) and PED.IS_PED_IN_ANY_VEHICLE(ped, false) and pid == driver then
                util.draw_debug_text(players.get_name(driver) .. " Is Driving An Unreleased Vehicle " .. "(" .. name .. ")")
            end
        end
    end
end)


menu.toggle_loop(modder_detections, "Modded Weapon", {}, "Detects if someone is using a weapon that can not be obtained in online.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for i, hash in ipairs(modded_weapons) do
            local weapon_hash = util.joaat(hash)
            if WEAPON.HAS_PED_GOT_WEAPON(ped, weapon_hash, false) and (WEAPON.IS_PED_ARMED(ped, 7) or TASK.GET_IS_TASK_ACTIVE(ped, 8) or TASK.GET_IS_TASK_ACTIVE(ped, 9)) then
                util.toast(players.get_name(pid) .. " Is Using A Modded Weapon " .. "(" .. hash .. ")")
                break
            end
        end
    end
end)

menu.toggle_loop(modder_detections, "Modded Vehicle", {}, "Detects if someone is using a vehicle that can not be obtained in online.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local modelHash = players.get_vehicle_model(pid)
        local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
        for i, name in ipairs(modded_vehicles) do
            if modelHash == util.joaat(name) and pid == driver then
                util.draw_debug_text(players.get_name(driver) .. " Is Driving A Modded Vehicle " .. "(" .. name .. ")")
                break
            end
        end
    end
end)

menu.toggle_loop(modder_detections, "Noclip", {}, "Detects if the player is using noclip aka levitation", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local ped_ptr = entities.handle_to_pointer(ped)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local oldpos = players.get_position(pid)
        util.yield()
        local currentpos = players.get_position(pid)
        local vel = ENTITY.GET_ENTITY_VELOCITY(ped)
        if not util.is_session_transition_active() and players.exists(pid)
        and get_interior_player_is_in(pid) == 0 and get_spawn_state(pid) ~= 0
        and not PED.IS_PED_IN_ANY_VEHICLE(ped, false) -- too many false positives occured when players where driving. so fuck them. lol.
        and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and not PED.IS_PED_DEAD_OR_DYING(ped)
        and not PED.IS_PED_CLIMBING(ped) and not PED.IS_PED_VAULTING(ped) and not PED.IS_PED_USING_SCENARIO(ped)
        and not TASK.GET_IS_TASK_ACTIVE(ped, 160) and not TASK.GET_IS_TASK_ACTIVE(ped, 2)
        and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) <= 395.0 -- 400 was causing false positives
        and ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(ped) > 5.0 and not ENTITY.IS_ENTITY_IN_AIR(ped) and entities.player_info_get_game_state(ped_ptr) == 0
        and oldpos.x ~= currentpos.x and oldpos.y ~= currentpos.y and oldpos.z ~= currentpos.z 
        and vel.x == 0.0 and vel.y == 0.0 and vel.z == 0.0 then
            util.toast(players.get_name(pid) .. " Is Noclipping")
            break
        end
    end
end)

menu.toggle_loop(modder_detections, "Super Drive", {}, "Detects if someone is using super drive or modded vehicle speed.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local vehicle = PED.GET_VEHICLE_PED_IS_USING(ped)
        local veh_speed = (ENTITY.GET_ENTITY_SPEED(vehicle)* 2.236936)
        local class = VEHICLE.GET_VEHICLE_CLASS(vehicle)
        local driver = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(VEHICLE.GET_PED_IN_VEHICLE_SEAT(vehicle, -1))
        if class ~= 15 and class ~= 16 and veh_speed >= 200 and (players.get_vehicle_model(pid) ~= util.joaat("oppressor") and players.get_vehicle_model(pid) ~= util.joaat("oppressor2")) and pid == driver then
            util.toast(players.get_name(driver) .. " Is Using Super Drive")
            break
        end
    end
end)

menu.toggle_loop(modder_detections, "Spectate", {}, "Detects if someone is spectating you.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if not PED.IS_PED_DEAD_OR_DYING(ped) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) then
            if v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_cam_pos(pid)) < 15.0 and v3.distance(ENTITY.GET_ENTITY_COORDS(players.user_ped(), false), players.get_position(pid)) > 50.0 then
                util.toast(players.get_name(pid) .. " Is Watching You")
                break
            end
        end
    end
end)

menu.toggle_loop(modder_detections, "Thunder Join", {}, "Detects if someone is using thunder join.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        if get_spawn_state(players.user()) == 0 then return end
        local old_sh = players.get_script_host()
        util.yield(100)
        local new_sh = players.get_script_host()
        if old_sh ~= new_sh then
            if get_spawn_state(pid) == 0 and players.get_script_host() == pid then
                util.toast(players.get_name(pid) .. " triggered a detection (Thunder Join) and is now classified as a Modder")
            end
        end
    end
end)

menu.toggle_loop(modder_detections, "Modded Orbital Cannon", {}, "Detects if someone is using a modded orbital cannon.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if IsPlayerUsingOrbitalCannon(pid) and not TASK.GET_IS_TASK_ACTIVE(ped, 135) then
            util.toast(players.get_name(pid) .. " Is using a modded orbital cannon")
        end
    end
end)

menu.toggle_loop(normal_detections, "Teleport", {}, "", function()
    for _, pid in ipairs(players.list(true, true, true)) do
        local old_pos = players.get_position(pid)
        util.yield(50)
        local cur_pos = players.get_position(pid)
        local distance_between_tp = v3.distance(old_pos, cur_pos)
        for _, id in ipairs(interior_stuff) do
            if get_interior_player_is_in(pid) == id and get_spawn_state(pid) ~= 0 and players.exists(pid) then
                util.yield(100)
                if distance_between_tp > 300.0 then
                    util.toast(players.get_name(pid) .. " Teleported " .. SYSTEM.ROUND(distance_between_tp) .. " Meters")
                end
            end
        end
    end
end)

menu.toggle_loop(normal_detections, "Orbital Cannon", {}, "Detects if someone is using an orbital cannon.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if IsPlayerUsingOrbitalCannon(pid) and TASK.GET_IS_TASK_ACTIVE(ped, 135) then
            util.draw_debug_text(players.get_name(pid) .. " Is at the orbital cannon")
        end
    end
end)

menu.toggle_loop(normal_detections, "Glitched Godmode", {}, "Detects if someone is using a glitch to obtain godmode.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(ped, false) 
        local height = ENTITY.GET_ENTITY_HEIGHT_ABOVE_GROUND(ped)
        for _, id in ipairs(interior_stuff) do
            if players.is_in_interior(pid) and players.is_godmode(pid) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(ped) and get_spawn_state(pid) == 99 and get_interior_player_is_in(pid) == id and height >= 0.0 then
                util.draw_debug_text(players.get_name(pid) .. " Is In Glitched Godmode")
                break
            end
        end
    end 
end)

local anti_mugger = menu.list(protections, "Block Muggers")
menu.toggle_loop(anti_mugger, "Myself", {}, "Prevents you from being mugged.", function() -- thx nowiry for improving my method :D
    if NETWORK.NETWORK_IS_SCRIPT_ACTIVE("am_gang_call", 0, true, 0) then
        local ped_netId = memory.script_local("am_gang_call", 63 + 10 + (0 * 7 + 1))
        local sender = memory.script_local("am_gang_call", 287)
        local target = memory.script_local("am_gang_call", 288)
        local player = players.user()

        util.spoof_script("am_gang_call", function()
            if (memory.read_int(sender) ~= player and memory.read_int(target) == player 
            and NETWORK.NETWORK_DOES_NETWORK_ID_EXIST(memory.read_int(ped_netId)) 
            and NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(memory.read_int(ped_netId))) then
                local mugger = NETWORK.NET_TO_PED(memory.read_int(ped_netId))
                entities.delete_by_handle(mugger)
                util.toast("Blocked mugger from " .. players.get_name(memory.read_int(sender)))
            end
        end)
    end
end)

menu.toggle_loop(anti_mugger, "Someone Else", {}, "Prevents others from being mugged.", function()
    if NETWORK.NETWORK_IS_SCRIPT_ACTIVE("am_gang_call", 0, true, 0) then
        local ped_netId = memory.script_local("am_gang_call", 63 + 10 + (0 * 7 + 1))
        local sender = memory.script_local("am_gang_call", 287)
        local target = memory.script_local("am_gang_call", 288)
        local player = players.user()

        util.spoof_script("am_gang_call", function()
            if memory.read_int(target) ~= player and memory.read_int(sender) ~= player
            and NETWORK.NETWORK_DOES_NETWORK_ID_EXIST(memory.read_int(ped_netId)) 
            and NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(memory.read_int(ped_netId)) then
                local mugger = NETWORK.NET_TO_PED(memory.read_int(ped_netId))
                entities.delete_by_handle(mugger)
                util.toast("Blocked mugger sent by " .. players.get_name(memory.read_int(sender)) .. " to " .. players.get_name(memory.read_int(target)))
            end
        end)
    end
end)


menu.toggle_loop(protections, "Anti-Beast", {}, "Prevents you from being turned into the beast but will also stop the event for others.", function()
    if util.spoof_script("am_hunt_the_beast", SCRIPT.TERMINATE_THIS_THREAD) then
        util.toast("Hunt the beast script detected. Terminating script...")
    end
end)

menu.toggle_loop(protections, "Block Transaction Error Script ", {}, "Blocks the destroy vehicle script from being used maliciously to give you a transaction error.", function()
    if util.spoof_script("am_destroy_veh", SCRIPT.TERMINATE_THIS_THREAD) then
        util.toast("Destroy Vehicle script detected. Terminating script...")
    end
end)

menu.toggle_loop(protections, "Anti-Cage", {"anticage"}, "", function() -- I really, really, really fucking hate doors now.
    local veh = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
    local my_ents = {user, veh}
    for i, obj in ipairs(entities.get_all_objects_as_handles()) do
        local obj_ptr = entities.handle_to_pointer(obj)
        local owner = entities.get_owner(obj_ptr)
        for _, pid in ipairs(players.list(false, true, true)) do
            for i, data in ipairs(my_ents) do
                if ENTITY.IS_ENTITY_TOUCHING_ENTITY(data, obj) then
                    ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(obj, data, false)
                    ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(data, obj, false)
                    if owner ~= players.user() and get_interior_player_is_in(owner) == 0 then
                        util.toast("Blocked Possible Cage From " .. players.get_name(owner))
                    end
                end
            end
        end
        SHAPETEST.RELEASE_SCRIPT_GUID_FROM_ENTITY(obj)
    end
end)

local block_orb
block_orb = menu.toggle_loop(protections,  "Block Orbital Cannon", {"blockorb"}, "Spawns a prop that blocks the orbital cannon room.", function() -- credit to lance, just cleaned it up a bit.
    local mdl = util.joaat("h4_prop_h4_garage_door_01a")
    request_model(mdl)
    if orb_obj == nil or not ENTITY.DOES_ENTITY_EXIST(orb_obj) then
        orb_obj = entities.create_object(mdl, v3(335.9, 4833.9, -59.0))
        entities.set_can_migrate(entities.handle_to_pointer(orb_obj), false)
        ENTITY.SET_ENTITY_HEADING(orb_obj, 125.0)
        ENTITY.FREEZE_ENTITY_POSITION(orb_obj, true)
        ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(players.user_ped(), orb_obj, false)
    end
    util.yield(50)
end, function()
    if orb_obj ~= nil then
        entities.delete_by_handle(orb_obj)
    end
end)

menu.list_action(protections, "Clear All...", {}, "", {"Peds", "Vehicles", "Objects", "Pickups", "Ropes", "Projectiles", "Sounds"}, function(index, name)
    util.toast("Clearing "..name:lower().."...")
    local counter = 0
    switch index do
        case 1:
            for _, ped in ipairs(entities.get_all_peds_as_handles()) do
                if ped ~= players.user_ped() and not PED.IS_PED_A_PLAYER(ped) then
                    entities.delete_by_handle(ped)
                    counter += 1
                    util.yield()
                end
            end
            break
        case 2:
            for _, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
                if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) and DECORATOR.DECOR_GET_INT(vehicle, "Player_Vehicle") == 0 and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
                    entities.delete_by_handle(vehicle)
                    counter += 1
                end
                util.yield()
            end
            break
        case 3:
            for _, object in ipairs(entities.get_all_objects_as_handles()) do
                entities.delete_by_handle(object)
                counter += 1
                util.yield()
            end
            break
        case 4:
            for _, pickup in ipairs(entities.get_all_pickups_as_handles()) do
                entities.delete_by_handle(pickup)
                counter += 1
                util.yield()
            end
            break
        case 5:
            local temp = memory.alloc(4)
            for i = 0, 101 do
                memory.write_int(temp, i)
                if PHYSICS.DOES_ROPE_EXIST(temp) then
                    PHYSICS.DELETE_ROPE(temp)
                    counter += 1
                end
                util.yield()
            end
            break
        case 6:
            local coords = players.get_position(players.user())
            MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, 1000, 0)
            counter = "all"
            break
        case 4:
            for i = 0, 99 do
                AUDIO.STOP_SOUND(i)
                util.yield()
            end
        break
    end
    util.toast("Cleared "..tostring(counter).." "..name:lower()..".")
end)

menu.action(protections, "Clear Area", {"cleanse"}, "", function()
    local cleanse_entitycount = 0
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ped ~= players.user_ped() and not PED.IS_PED_A_PLAYER(ped) then
            entities.delete_by_handle(ped)
            cleanse_entitycount += 1
            util.yield()
        end
    end
    util.toast("Cleared " .. cleanse_entitycount .. " Peds")
    cleanse_entitycount = 0
    for _, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
        if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) and DECORATOR.DECOR_GET_INT(vehicle, "Player_Vehicle") == 0 and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
            entities.delete_by_handle(vehicle)
            cleanse_entitycount += 1
            util.yield()
        end
    end
    util.toast("Cleared ".. cleanse_entitycount .." Vehicles")
    cleanse_entitycount = 0
    for _, object in pairs(entities.get_all_objects_as_handles()) do
        entities.delete_by_handle(object)
        cleanse_entitycount += 1
        util.yield()
    end
    util.toast("Cleared " .. cleanse_entitycount .. " Objects")
    cleanse_entitycount = 0
    for _, pickup in pairs(entities.get_all_pickups_as_handles()) do
        entities.delete_by_handle(pickup)
        cleanse_entitycount += 1
        util.yield()
    end
    util.toast("Cleared " .. cleanse_entitycount .. " Pickups")
    local temp = memory.alloc(4)
    for i = 0, 100 do
        memory.write_int(temp, i)
        PHYSICS.DELETE_ROPE(temp)
    end
    util.toast("Cleared All Ropes")
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_PROJECTILES(pos, 400, 0)
    util.toast("Cleared All Projectiles")
end)

local misc = menu.list(menu.my_root(), "Miscellaneous", {}, "")
menu.hyperlink(menu.my_root(), "Join The Discord", "https://discord.gg/hjs5S93kQv")
local credits = menu.list(misc, "Credits", {}, "")
local jinx = menu.list(credits, "Jinx", {}, "")
menu.hyperlink(jinx, "Tiktok", "https://www.tiktok.com/@bigfootjinx")
menu.hyperlink(jinx, "Twitter", "https://twitter.com/bigfootjinx")
menu.hyperlink(jinx, "Instagram", "https://www.instagram.com/bigfootjinx")
menu.hyperlink(jinx, "Youtube", "https://www.youtube.com/channel/UC-nkxad5MRDuyz7xstc-wHQ?sub_confirmation=1")
menu.action(credits, "ICYPhoenix", {}, "I would have never made this script or thought of making this script if he didn't change my role to \"OP Jinx Lua\"", function()
end)
menu.action(credits, "Sapphire", {}, "dealing with all my autism and helping a ton when I first started the lua as well as when I started learning stands api and natives", function()
end)
menu.action(credits, "aaronlink127", {}, "helping with math stuff and also helping with the auto updater and some other features", function()
end)
menu.action(credits, "Ren", {}, "dealing with all my autism and yelling at me to fix my code", function()
end)
menu.action(credits, "well in that case", {}, "for making pluto and allowing parts of my code to look nicer and run smoother", function()
end)
menu.action(credits, "jerry123", {}, "for cleaning my code in some spots and telling me what can be improved", function()
end)
menu.action(credits, "Scriptcat", {}, "being there since I started and telling me some useful lua tips and forcing me to start learning stands api and natives", function()
end)
menu.action(credits, "ERR_NET_ARRAY", {}, "helping with memory editing", function()
end)
menu.action(credits, "d6b.", {}, "gifting nitro because he is such a super gamer gigachad", function()
end)
util.keep_running()

