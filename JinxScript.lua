util.require_natives(1651208000)
util.toast("Welcome To JinxScript!\n" .. "Official Discord: https://discord.gg/6TWDGfGG64") 
local response = false
local localVer = 2.03
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
                util.toast("Successfully updated JinxScript, please restart the script :)")
                util.stop_script()
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


local function get_transition_state(pid)
    return memory.read_int(memory.script_global(((2689235 + 1) + (pid * 453)) + 230))
end

local function get_interior_player_is_in(pid)
    return memory.read_int(memory.script_global(((2689235 + 1) + (pid * 453)) + 243)) 
end

local function is_player_in_interior(pid)
    return (memory.read_int(memory.script_global(2689235 + 1 + (pid * 453) + 243)) ~= 0)
end

local function get_entity_owner(addr)
    if util.is_session_started() and not util.is_session_transition_active() then
        local netObject = memory.read_long(addr + 0xD0)
        if netObject == 0 then
            return -1
        end
        local owner = memory.read_byte(netObject + 0x49)
        return owner
    end
    return players.user()
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


local function get_blip_coords(blipId)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(blipId)
    if blip ~= 0 then return HUD.GET_BLIP_COORDS(blip) end
    return v3(0, 0, 0)
end

local function custom_alert(l1) -- totally not skidded from lancescript
    poptime = os.time()
    while true do
        if PAD.IS_CONTROL_JUST_RELEASED(18, 18) then
            if os.time() - poptime > 0.1 then
                break
            end
        end
        native_invoker.begin_call()
        native_invoker.push_arg_string("ALERT")
        native_invoker.push_arg_string("JL_INVITE_ND")
        native_invoker.push_arg_int(2)
        native_invoker.push_arg_string("")
        native_invoker.push_arg_bool(true)
        native_invoker.push_arg_int(-1)
        native_invoker.push_arg_int(-1)
        native_invoker.push_arg_string(l1)
        native_invoker.push_arg_int(0)
        native_invoker.push_arg_bool(true)
        native_invoker.push_arg_int(0)
        native_invoker.end_call("701919482C74B5AB")
        util.yield()
    end
end

local function request_model(hash)
    STREAMING.REQUEST_MODEL(hash)
    while not STREAMING.HAS_MODEL_LOADED(hash) do
        util.yield()
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

local effect_stuff = {
    {"Normal Drugged", "DrugsDrivingIn"}, 
    {"Drugged Trevor", "DrugsTrevorClownsFight"},
    {"Drugged Michael", "DrugsMichaelAliensFight"},
    {"Chop", "ChopVision"},
    {"Black & White", "DeathFailOut"},
    {"Boosted Black & White", "HeistCelebPassBW"},
    {"Rampage", "Rampage"},
    {"Where Are My Glasses?", "MenuMGSelectionIn"},
    {"Acid", "DMT_flight_intro"},
}


local visual_stuff = {
    {"Better Illumination", "AmbientPush"},
    {"Oversaturated", "rply_saturation"},
    {"Boost Everything", "LostTimeFlash"},
    {"Foggy Night", "casino_main_floor_heist"},
    {"Better Night Time", "dlc_island_vault"},
    {"Normal Fog", "Forest"},
    {"Heavy Fog", "nervousRON_fog"},
    {"Firewatch", "MP_Arena_theme_evening"},
    {"Warm", "mp_bkr_int01_garage"},
    {"Deepfried", "MP_deathfail_night"},
    {"Stoned", "stoned"},
    {"Underwater", "underwater"},
}

local drugged_effects = {
    "DRUG_2_drive",
    "drug_drive_blend01",
    "drug_flying_base",
    "DRUG_gas_huffin",
    "drug_wobbly",
    "NG_filmic02",
    "PPFilter",
    "spectator5",
}

local unreleased_vehicles = {
    "Kanjosj",
    "Postlude",
    "Rhinehart",
    "Tenf",
    "Tenf2",
    "Sentinel4",
    "Vigero2",
    "Weevil2",
}

local modded_vehicles = {
    "dune2",
    "tractor",
    "dilettante2",
    "asea2",
    "cutter",
    "mesa2",
    "jet",
    "skylift",
    "policeold1",
    "policeold2",
    "armytrailer2",
}

local modded_weapons = {
    "weapon_railgun",
    "weapon_stungun",
    "weapon_digiscanner",
}

local interiors = {
    {"Safe Space [AFK Room]", {x=-158.71494, y=-982.75885, z=149.13135}},
    {"Torture Room", {x=147.170, y=-2201.804, z=4.688}},
    {"Mining Tunnels", {x=-595.48505, y=2086.4502, z=131.38136}},
    {"Omegas Garage", {x=2330.2573, y=2572.3005, z=46.679367}},
    {"Server Farm", {x=2155.077, y=2920.9417, z=-81.075455}},
    {"Character Creation", {x=402.91586, y=-998.5701, z=-99.004074}},
    {"Life Invader Building", {x=-1082.8595, y=-254.774, z=37.763317}},
    {"Mission End Garage", {x=405.9228, y=-954.1149, z=-99.6627}},
    {"Destroyed Hospital", {x=304.03894, y=-590.3037, z=43.291893}},
    {"Stadium", {x=-256.92334, y=-2024.9717, z=30.145584}},
    {"Comedy Club", {x=-430.00974, y=261.3437, z=83.00648}},
    {"Bahama Mamas Nightclub", {x=-1394.8816, y=-599.7526, z=30.319544}},
    {"Janitors House", {x=-110.20285, y=-8.6156025, z=70.51957}},
    {"Therapists House", {x=-1913.8342, y=-574.5799, z=11.435149}},
    {"Martin Madrazos House", {x=1395.2512, y=1141.6833, z=114.63437}},
    {"Floyds Apartment", {x=-1156.5099, y=-1519.0894, z=10.632717}},
    {"Michaels House", {x=-813.8814, y=179.07889, z=72.15914}},
    {"Franklins House (Old)", {x=-14.239959, y=-1439.6913, z=31.101551}},
    {"Franklins House (New)", {x=7.3125067, y=537.3615, z=176.02803}},
    {"Trevors House", {x=1974.1617, y=3819.032, z=33.436287}},
    {"Lesters House", {x=1273.898, y=-1719.304, z=54.771}},
    {"Lesters Warehouse", {x=713.5684, y=-963.64795, z=30.39534}},
    {"Lesters Office", {x=707.2138, y=-965.5549, z=30.412853}},
    {"Meth Lab", {x=1391.773, y=3608.716, z=38.942}},
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
    {"Avenger Interior", {x=518.6444, y=4750.4644, z=-69.3235}},
    {"Terrobyte Interior", {x=-1421.015, y=-3012.587, z=-80.000}},
    {"Bunker Interior", {x=899.5518,y=-3246.038, z=-98.04907}},
    {"IAA Office", {x=128.20, y=-617.39, z=206.04}},
    {"FIB Top Floor", {x=135.94359, y=-749.4102, z=258.152}},
    {"FIB Floor 47", {x=134.5835, y=-766.486, z=234.152}},
    {"FIB Floor 49", {x=134.635, y=-765.831, z=242.152}},
    {"Big Fat White Cock", {x=-31.007448, y=6317.047, z=40.04039}},
    {"Marijuana Shop", {x=-1170.3048, y=-1570.8246, z=4.663622}},
    {"Strip Club DJ Booth", {x=121.398254, y=-1281.0024, z=29.480522}},
}


local values = {
    [0] = 0,
    [1] = 50,
    [2] = 88,
    [3] = 160,
    [4] = 208,
}

local launch_vehicle = {"Launch Up", "Launch Forward", "Launch Backwards", "Launch Down", "Slingshot"}
local invites = {"Yacht", "Office", "Clubhouse", "Office Garage", "Custom Auto Shop", "Apartment"}
local style_names = {"Normal", "Semi-Rushed", "Reverse", "Ignore Lights", "Avoid Traffic", "Avoid Traffic Extremely", "Sometimes Overtake Traffic"}
local drivingStyles = {786603, 1074528293, 8388614, 1076, 2883621, 786468, 262144, 786469, 512, 5, 6}
local interior_stuff = {0, 233985, 169473, 169729, 169985, 170241, 177665, 177409, 185089, 184833, 184577, 163585, 167425, 167169}


local self = menu.list(menu.my_root(), "Self", {}, "")
local vehicle = menu.list(menu.my_root(), "Vehicle", {}, "")
local session = menu.list(menu.my_root(), "Session", {}, "")
local visuals = menu.list(menu.my_root(), "Visuals", {}, "")
local funfeatures = menu.list(menu.my_root(), "Fun Features", {}, "")
local teleport = menu.list(menu.my_root(), "Teleport", {}, "")
local detections = menu.list(menu.my_root(), "Modder Detections", {}, "")
local bailOnAdminJoin = false
local protections = menu.list(menu.my_root(), "Protections", {}, "")
menu.toggle(protections, "Bail On Admin Join", {}, "", function(on)
    bailOnAdminJoin = on
end)

local spoofedrid = menu.ref_by_path("Online>Spoofing>RID Spoofing>Spoofed RID")
local spoofer = menu.ref_by_path("Online>Spoofing>RID Spoofing>RID Spoofing")
util.create_tick_handler(function()
    if menu.get_value(spoofedrid) == "213034124" and menu.get_value(spoofer) then
        util.toast("You silly little sausage...")
        menu.trigger_commands("forcequit")
        menu.set_value(spoofer, false)
    end
end)

local function player(pid)   
    if players.get_rockstar_id(pid) == 213034124 then
        util.toast(lang.get_string(-766393174, lang.get_current()):gsub("{(.-)}", {player = players.get_name(pid), reason = "JinxScript Developer \n(They might be a sussy impostor, watch out!)"}), TOAST_DEFAULT)
    end

    if players.get_rockstar_id(pid) == 115772212 then
        util.toast(lang.get_string(-766393174, lang.get_current()):gsub("{(.-)}", {player = players.get_name(pid), reason = "Based Gigachad\n (They are very based! Proceed with caution!)"}), TOAST_DEFAULT)
    end
    
    menu.divider(menu.player_root(pid), "Jinx Script")
    local bozo = menu.list(menu.player_root(pid), "Jinx Script", {"JinxScript"}, "")

    local friendly = menu.list(bozo, "Friendly", {}, "")
    local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
    menu.toggle_loop(friendly, "Give Stealth Vehicle Godmode", {}, "Won't be detected as vehicle godmode by most menus", function()
        ENTITY.SET_ENTITY_PROOFS(PED.GET_VEHICLE_PED_IS_IN(player), true, true, true, true, true, 0, 0, true)
        end, function() ENTITY.SET_ENTITY_PROOFS(PED.GET_VEHICLE_PED_IS_IN(player), false, false, false, false, false, 0, 0, false)
    end)

    menu.action(friendly, "Rank Them Up", {}, "Gives them ~175k RP. Can boost a lvl 1 ~25 levels.", function()
        util.trigger_script_event(1 << pid, {-1178972880, pid, 5, 0, 1, 1, 1})
        for i = 0, 9 do
            util.trigger_script_event(1 << pid, {-1178972880, pid, 0, i, 1, 1, 1})
            util.trigger_script_event(1 << pid, {-1178972880, pid, 1, i, 1, 1, 1})
            util.trigger_script_event(1 << pid, {-1178972880, pid, 3, i, 1, 1, 1})
            util.trigger_script_event(1 << pid, {-1178972880, pid, 10, i, 1, 1, 1})
        end
        for i = 0, 1 do
            util.trigger_script_event(1 << pid, {-1178972880, pid, 2, i, 1, 1, 1})
            util.trigger_script_event(1 << pid, {-1178972880, pid, 6, i, 1, 1, 1})
        end
        for i = 0, 19 do
            util.trigger_script_event(1 << pid, {-1178972880, pid, 4, i, 1, 1, 1})
        end
        for i = 0, 99 do
            util.trigger_script_event(1 << pid, {-1178972880, pid, 9, i, 1, 1, 1})
            util.yield()
        end
    end)

    local toggled = false    
    local animal_toggle
    animal_toggle = menu.toggle(friendly, "Turn Into Animal", {}, "A scuffed way of doing it but it shouldn't kill them.", function(toggle)
        -- hi there, if you're gonna steal this then at least credit me
        toggled = toggle
        while toggled do
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            if not PED.IS_PED_MODEL(player, 0x9C9EFFD8) and not PED.IS_PED_MODEL(player, 0x705E61F2) then
                util.toast("Player is already an animal. :/")
                menu.set_value(animal_toggle, false);
            break end
            util.trigger_script_event(1 << pid, {-1178972880, pid, 8, -1, 1, 1, 1})
            util.yield()
        end
    end)

    local halloween_loop = menu.list(friendly, "Halloween Collectible Loop", {}, "")
    local halloween_delay = 500
    menu.slider(halloween_loop, "Delay", {}, "", 0, 2500, 500, 10, function(amount)
        halloween_delay = amount
    end)
    player_toggle_loop(halloween_loop, pid, "Enable Loop", {}, "Should give them quite a bit of money and some other stuff", function()
        util.trigger_script_event(1 << pid, {-1178972880, pid, 8, -1, 1, 1, 1})
    end)

    local rpwarning
     rpwarning = menu.action(friendly, "Collectible RP Loop", {}, "", function(click_type)
        menu.show_warning(rpwarning, click_type, "Warning: This will kick legit players and hasn't been fully tested yet. Proceed with caution.", function()
            local rp_loop = menu.list(friendly, "Collectible RP Loop", {}, "")
            menu.delete(rpwarning)
            local delay = 500
            menu.slider(rp_loop, "Delay", {"givedelay"}, "", 0, 2500, 500, 10, function(amount)
                delay = amount
            end)

            menu.toggle_loop(rp_loop, "Enable RP Loop", {}, "Each collectible gives 1k RP", function()
                util.trigger_script_event(1 << pid, {-1178972880, pid, 4, -1, 1, 1, 1})
                util.yield(delay)
            end)
            menu.trigger_command(rp_loop)
        end)
    end)

    local funfeatures_player = menu.list(bozo, "Fun Features", {}, "")
    menu.action(funfeatures_player, "Custom Notification", {"customnotify"}, "Example: ~q~ <FONT SIZE=\"35\"> JINX SCRIPT ON TOP~", function(cl)
        menu.show_command_box_click_based(cl, "customnotify "..players.get_name(pid):lower().." ") end, function(input)
            local event_data = {-1908874529, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
            input = input:sub(1, 127)
            for i = 0, #input -1 do
                local slot = i // 8
                local byte = string.byte(input, i + 1)
                event_data[slot + 3] = event_data[slot + 3] | byte << ((i-slot * 8)* 8)
            end
            util.trigger_script_event(1 << pid, event_data)
        end)

    menu.action(funfeatures_player, "Custom Label", {"label"}, "", function() menu.show_command_box("label "..players.get_name(pid).." ") end, function(label)
        local event_data = {-791892894, players.user(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
        local out = label:sub(1, 127)
        for i = 0, #out -1 do
            local slot = i // 8
            local byte = string.byte(out, i + 1)
            event_data[slot + 3] = event_data[slot + 3] | byte << ( (i - slot * 8) * 8)
        end
        util.trigger_script_event(1 << pid, event_data)
    end)

    menu.hyperlink(funfeatures_player, "Label List", "https://gist.githubusercontent.com/aaronlink127/afc889be7d52146a76bab72ede0512c7/raw")

    local player_jinx_army = {}
    local army_player = menu.list(funfeatures_player, "Jinx Army", {}, "")
    menu.click_slider(army_player, "Spawn Jinx Army", {}, "", 1, 256, 30, 1, function(val)
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player, false)
        pos.y = pos.y - 5
        pos.z = pos.z + 1
        local jinx = util.joaat("a_c_cat_01")
        request_model(jinx)
        for i = 1, val do
            player_jinx_army[i] = entities.create_ped(28, jinx, pos, 0)
            ENTITY.SET_ENTITY_INVINCIBLE(player_jinx_army[i], true)
            PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(player_jinx_army[i], true)
            PED.SET_PED_COMPONENT_VARIATION(player_jinx_army[i], 0, 0, 1, 0)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(player_jinx_army[i], player, 0, -0.3, 0, 7.0, -1, 10, true)
            util.yield()
        end 
    end)

    menu.action(army_player, "Clear Jinxs", {}, "", function()
        for i, jinx in ipairs(player_jinx_army) do
            entities.delete_by_handle(player_jinx_army[i])
        end
    end)

    local trolling = menu.list(bozo, "Trolling & Griefing", {}, "")
    player_toggle_loop(trolling, pid, "Buggy Movement", {}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player, false)
        local glitch_hash = util.joaat("prop_shuttering03")
        request_model(glitch_hash)
        local dumb_object_front = entities.create_object(glitch_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 1, 0))
        local dumb_object_back = entities.create_object(glitch_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 0, 0))
        ENTITY.SET_ENTITY_VISIBLE(dumb_object_front, false)
        ENTITY.SET_ENTITY_VISIBLE(dumb_object_back, false)
        util.yield()
        entities.delete_by_handle(dumb_object_front)
        entities.delete_by_handle(dumb_object_back)
        util.yield()    
    end)
    
    local glitch_player_list = menu.list(trolling, "Glitch Player", {"glitchdelay"}, "")
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

    menu.slider(glitch_player_list, "Spawn Delay", {"spawndelay"}, "", 0, 3000, 50, 10, function(amount)
        delay = amount
    end)

    local glitchPlayer = false
    local glitchPlayer_toggle
    glitchPlayer_toggle = menu.toggle(glitch_player_list, "Glitch Player", {}, "", function(toggled)
        glitchPlayer = toggled

        while glitchPlayer do
            local glitch_hash = object_hash
            local poopy_butt = util.joaat("rallytruck")
            request_model(glitch_hash)
            request_model(poopy_butt)
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
            local stupid_object = entities.create_object(glitch_hash, playerpos)
            local vehicle = entities.create_vehicle(poopy_butt, playerpos, 0)
            ENTITY.SET_ENTITY_VISIBLE(stupid_object, false)
            ENTITY.SET_ENTITY_VISIBLE(vehicle, false)
            ENTITY.SET_ENTITY_INVINCIBLE(stupid_object, true)
            ENTITY.SET_ENTITY_COLLISION(stupid_object, true, true)
            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 10, 10, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            util.yield(delay)
            entities.delete_by_handle(stupid_object)
            entities.delete_by_handle(vehicle)
            util.yield(delay)    
        end
    end)

    local glitchVeh = false
    local glitchVehCmd
    glitchVehCmd = menu.toggle(trolling, "Glitch Vehicle", {"glitchvehicle"}, "", function(toggle) -- credits to soul reaper for base concept
        glitchVeh = toggle
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player, false)
        local player_veh = PED.GET_VEHICLE_PED_IS_USING(player)
        local veh_model = players.get_vehicle_model(pid)
        local ped_hash = util.joaat("a_m_m_acult_01")
        local object_hash = util.joaat("prop_ld_ferris_wheel")
        request_model(ped_hash)
        request_model(object_hash)
        
        while glitchVeh do
            if not PED.IS_PED_IN_VEHICLE(player, player_veh, false) then 
                util.toast("Player isn't in a vehicle. :/")
                menu.set_value(glitchVehCmd, false);
            break end

            if not VEHICLE.ARE_ANY_VEHICLE_SEATS_FREE(player_veh) then
                util.toast("No free seats are available. :/")
                menu.set_value(glitchVehCmd, false);
            break end

            local seat_count = VEHICLE.GET_VEHICLE_MODEL_NUMBER_OF_SEATS(veh_model)
            local glitch_obj = entities.create_object(object_hash, pos)
            local glitched_ped = entities.create_ped(26, ped_hash, pos, 0)
            local things = {glitched_ped, glitch_obj}

            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(glitch_obj)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(glitch_ped)

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
            util.yield()
            if not menu.get_value(glitchVehCmd) then
                entities.delete_by_handle(glitched_ped)
                entities.delete_by_handle(glitch_obj)
            end
            if glitched_ped ~= nil then -- added a 2nd stage here because it didnt want to delete sometimes, this solved that lol.
                entities.delete_by_handle(glitched_ped) 
            end
            if glitch_obj ~= nil then 
                entities.delete_by_handle(glitch_obj)
            end
        end
    end)

    local glitchForcefield = false
    local glitchforcefield_toggle
    glitchforcefield_toggle = menu.toggle(trolling, "Glitched Forcefield", {"forcefield"}, "", function(toggled)
        glitchForcefield = toggled
        local glitch_hash = util.joaat("p_spinning_anus_s")
        request_model(glitch_hash)

        while glitchForcefield do
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
            
            if PED.IS_PED_IN_ANY_VEHICLE(player, true) then
                util.toast("Player is in a vehicle. :/")
                menu.set_value(glitchforcefield_toggle, false);
            break end
            
            local stupid_object = entities.create_object(glitch_hash, playerpos)
            ENTITY.SET_ENTITY_VISIBLE(stupid_object, false)
            ENTITY.SET_ENTITY_INVINCIBLE(stupid_object, true)
            ENTITY.SET_ENTITY_COLLISION(stupid_object, true, true)
            util.yield()
            entities.delete_by_handle(stupid_object)
            util.yield()    
        end
    end)

    player_toggle_loop(trolling, pid, "Yeet Player", {}, "Works on vehicles as well", function() 
        local poopy_butt = util.joaat("adder")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        pos.z -= 10
        request_model(poopy_butt)
        local vehicle = entities.create_vehicle(poopy_butt, pos, 0)
        ENTITY.SET_ENTITY_VISIBLE(vehicle, false)
        util.yield(250)
        if vehicle ~= 0 then
            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 100, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
            util.yield(250)
            entities.delete_by_handle(vehicle)
        end
    end)

    menu.action(trolling, "Launch Player", {"launch"}, "", function() 
        local stinky_butt = util.joaat("adder")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        pos.z -= 10
        request_model(stinky_butt)
        local vehicle = entities.create_vehicle(stinky_butt, pos, 0)
        ENTITY.SET_ENTITY_VISIBLE(vehicle, false)
        util.yield(250)
        if vehicle ~= 0 then
            ENTITY.APPLY_FORCE_TO_ENTITY(vehicle, 1, 0.0, 0.0, 100, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
        end
        util.yield(150)
        entities.delete_by_handle(vehicle)
    end)

    menu.action(trolling, "Delete Vehicle", {}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local player_veh = PED.GET_VEHICLE_PED_IS_USING(player)
        if not PED.IS_PED_IN_ANY_VEHICLE(player, true) then
            util.toast("Player isn't in a vehicle. :/")
            return
        end
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(player_veh)
        util.yield(500)
        if NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(player_veh) then
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(player_veh, false, false)
            entities.delete_by_handle(player_veh)
        else
            util.toast("Failed to get control over the players vehicle. :/")
        end
    end)

    local freeze = menu.list(trolling, "Freeze Player", {}, "")
    player_toggle_loop(freeze, pid, "Hard Freeze", {}, "", function()
        util.trigger_script_event(1 << pid, {1214823473, pid, 0, 0, 0, 0, 0})
        util.yield(500)
    end)

    player_toggle_loop(freeze, pid, "Blinking Freeze", {}, "", function()
        util.trigger_script_event(1 << pid, {2130458390, pid, 0, 1, 0, 0, 0})
        util.yield(500)
    end)

    player_toggle_loop(freeze, pid, "Clear Ped Tasks", {}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        TASK.CLEAR_PED_TASKS_IMMEDIATELY(player)
    end)

    local inf_loading = menu.list(trolling, "Infinite Loading Screen", {}, "")
    menu.action(inf_loading, "MC Teleport Method", {}, "", function()
        util.trigger_script_event(1 << pid, {-555356783, pid, 0, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
    end)

    menu.action(inf_loading, "Apartment Method", {}, "", function()
        util.trigger_script_event(1 << pid, {-1390976345, pid, pid, -1, 1, 115, 0, 0, 0})
    end)
        
    menu.action_slider(inf_loading, "Corrupted Phone Invite", {}, "Click to select a style", invites, function(index, name)
        pluto_switch name do
            case 1:
                util.trigger_script_event(1 << pid, {1111927333, pid, 1})
                util.toast("Yacht Invite Sent")
            break
            case 2:
                util.trigger_script_event(1 << pid, {1111927333, pid, 2})
                util.toast("Office Invite Sent")
            break
            case 3:
                util.trigger_script_event(1 << pid, {1111927333, pid, 3})
                util.toast("Clubhouse Invite Sent")
            break
            case 4:
                util.trigger_script_event(1 << pid, {1111927333, pid, 4})
                util.toast("Office Garage Invite Sent")
            break
            case 5:
                util.trigger_script_event(1 << pid, {1111927333, pid, 5})
                util.toast("Custom Auto Shop Invite Sent")
            break
            case 6:
                util.trigger_script_event(1 << pid, {1111927333, pid, 6})
                util.toast("Apartment Invite Sent")
            break
        end
    end)

    player_toggle_loop(trolling, pid, "Black Screen", {"blackscreen"}, "", function()
        util.trigger_script_event(1 << pid, {-555356783, pid, math.random(1, 32), 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
        util.yield(1000)
    end)
	
    local cage = menu.list(trolling, "Cage Player", {}, "")
    menu.action(cage, "Electric Cage", {"electriccage"}, "", function(cl)
        local number_of_cages = 4
        local elec_box = util.joaat("prop_elecbox_12")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        pos.z -= 0.5
        request_model(elec_box)
        local temp_v3 = v3.new(0, 0, 0)
        for i = 1, number_of_cages do
            local angle = (i / number_of_cages) * 360
            temp_v3.z = angle
            local obj_pos = temp_v3:toDir()
            obj_pos:mul(2.1)
            obj_pos:add(pos)
            for offs_z = 1, 5 do
                local electric_cage = entities.create_object(elec_box, obj_pos)
                spawned_objects[#spawned_objects + 1] = electric_cage
                ENTITY.SET_ENTITY_ROTATION(electric_cage, 90, 0, angle, 2, 0)
                obj_pos.z += 0.75
                ENTITY.FREEZE_ENTITY_POSITION(electric_cage, true)
            end
        end
    end)
    
    menu.action(cage, "Basic Cage", {}, "", function()
        local ramp_hash = util.joaat("prop_jetski_ramp_01")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        local rot = ENTITY.GET_ENTITY_ROTATION(ped, 2)
        request_model(ramp_hash)
        local ramp_cage = OBJECT.CREATE_OBJECT(ramp_hash, pos.x, pos.y, pos.z, true, false, true)
        spawned_objects[#spawned_objects + 1] = ramp_cage
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ramp_cage)
    end)

    menu.action(cage, "Shipping Container", {"cage"}, "", function()
        local container_hash = util.joaat("prop_container_05a")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player, 0, 0, -1)
        local rot = ENTITY.GET_ENTITY_ROTATION(player, 2)
        request_model(container_hash)

        local container = OBJECT.CREATE_OBJECT(container_hash, pos.x, pos.y, pos.z, true, false, true)
        spawned_objects[#spawned_objects + 1] = container

        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(container)
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


    menu.click_slider(trolling, "Mug Player", {}, "", 0, 2000000000, 0, 1000, function(amount)
        util.trigger_script_event(1 << pid, {-1529596656, players.user(), -1296682161, amount, 0, 0, 0, 0, 0, 0, pid, players.user(), 0, 0})
        util.trigger_script_event(1 << players.user(), {-1529596656, players.user(), -1296682161, amount, 0, 0, 0, 0, 0, 0, pid, players.user(), 0, 0})
    end)

    menu.action(trolling, "Kill Player Inside Interior", {}, "Will not work in apartments", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)

        util.trigger_script_event(1 << pid, {-1388926377, pid, -1762807505, math.random(0, 9999)})
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 1000, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
    end)

    player_toggle_loop(trolling, pid, "Taser Loop", {}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        for i = 1, 50 do
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 0, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
        end
        util.yield(100)
    end)

    player_toggle_loop(trolling, pid, "Up N Atomizer Loop", {}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z - 0.3, pos.x, pos.y, pos.z, 0, true, util.joaat("weapon_raypistol"), players.user_ped(), true, false, 1.0)
        util.yield(250)
    end)

    local electrocute = false
    local electrocute_toggle
    electrocute_toggle = menu.toggle(trolling, "Electrocution Loop", {}, "", function(toggled)
        electrocute = toggled
        
        while electrocute do
            local elec_box = util.joaat("prop_elecbox_12")
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local pos = ENTITY.GET_ENTITY_COORDS(player)
            request_model(elec_box)

            if PED.IS_PED_IN_ANY_VEHICLE(player, false) then 
                util.toast("Player is in a vehicle. :/")
                menu.set_value(electrocute_toggle, false) 
            break end;
            
            local elecbox = OBJECT.CREATE_OBJECT(elec_box, pos.x, pos.y, pos.z + 2.41, true, false, true)
            ENTITY.SET_ENTITY_ROTATION(elecbox, 180, 0, 0, 2, true)
            ENTITY.FREEZE_ENTITY_POSITION(elecbox, true)
            ENTITY.SET_ENTITY_VISIBLE(elecbox, false)
            util.yield()
            entities.delete_by_handle(elecbox)
        end
    end)

    menu.action(trolling, "Send To Jail", {}, "", function()
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
        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(my_ped, my_pos.x, my_pos.y, my_pos.z)
    end)

    menu.action_slider(trolling, "Launch Player Vehicle", {}, "", launch_vehicle, function(index, value)
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local veh = PED.GET_VEHICLE_PED_IS_IN(player, false)
        if not PED.IS_PED_IN_ANY_VEHICLE(player, true) then
            util.toast("Player isn't in a vehicle. :/")
            return
        end

        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) do
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
            util.yield()
        end

        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) and count >= 100 then
            util.toast("Failed to get control of the vehicle. :/")
            return
        end

        pluto_switch value do
            case "Launch Up":
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 100000, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                break
            case "Launch Forward":
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 100000, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                break
            case "Launch Backwards":
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, -100000, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                break
            case "Launch Down":
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, -100000, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                break
            case "Slingshot":
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 100000, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 100000, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
                break
            end
        end)

    local soundspam = menu.list(trolling, "Sound Spam", {}, "")
    player_toggle_loop(soundspam, pid, "SMS Spam", {}, "", function()
        util.trigger_script_event(1 << pid, {1670832796, pid, math.random(-2147483647, 2147483647)})
    end)

    player_toggle_loop(soundspam, pid, "Interior Invite", {}, "", function()
        util.trigger_script_event(1 << pid, {1111927333, pid, math.random(1, 6)})
    end)

    player_toggle_loop(soundspam, pid, "Invite Notification", {}, "", function()
        util.trigger_script_event(1 << pid, {-668341698, pid, math.random(1, 150), -1, -1})
    end)

    player_toggle_loop(soundspam, pid, "Collected Checkpoint", {}, "", function()
        util.trigger_script_event(1 << pid, {-1529596656, pid, -547323955, 0, 0, 0, 0, 0, 0, 0, pid, 0, 0, 0})
        util.yield(25)
    end)

    player_toggle_loop(soundspam, pid, "Character Notification", {}, "", function()
        util.trigger_script_event(1 << pid, {-634789188, pid, math.random(0, 178), 0, 0, 0})
    end)

    player_toggle_loop(soundspam, pid, "Error Notification", {}, "", function()
        util.trigger_script_event(1 << pid, {-1251171789, pid, math.random(-2147483647, 2147483647)})
    end)    

    menu.action(trolling, "Spawn Ramp In Front Of Player", {}, "", function() 
        local ramp_hash = util.joaat("stt_prop_ramp_jump_l")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(player, 0, 10, -2)
        local rot = ENTITY.GET_ENTITY_ROTATION(player, 2)
        request_model(ramp_hash)

        local ramp = OBJECT.CREATE_OBJECT(ramp_hash, pos.x, pos.y, pos.z, true, false, true)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ramp)

        ENTITY.SET_ENTITY_VISIBLE(ramp, false)
        ENTITY.SET_ENTITY_ROTATION(ramp, rot.x, rot.y, rot.z + 90, 0, true)
        util.yield(1000)
        entities.delete_by_handle(ramp)
    end)

    menu.action(trolling, "Force Interior State", {}, "Can Be Undone By Rejoining. Player Must Be In An Apartment", function(s)
        if is_player_in_interior(pid) then
            util.trigger_script_event(1 << pid, {-1338917610, pid, pid, pid, pid, math.random(-2147483647, 2147483647), pid})
        else
            util.toast("Player isn't in an apartment. :/")
        end
    end)

    menu.action(trolling, "Disable Explosive Projectiles", {}, "Will Disable Explosive Projectiles For The Player.", function(toggle) 
        local baseball = util.joaat("weapon_ball")
        request_model(baseball)
        local id = PLAYER.PLAYER_PED_ID()
        local pos = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))

        for i = 1, 60 do
            WEAPON.GIVE_WEAPON_TO_PED(id, baseball, 1, false, false)
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(pos.x, pos.y, pos.z, pos.x, pos.y, pos.z + 5, 0, true, util.joaat("WEAPON_BALL"), PLAYER.PLAYER_PED_ID(), false, true, 0, ped, 0)
        end
        util.yield(500)
        MISC.CLEAR_AREA_OF_PROJECTILES(pos.x, pos.y, pos.z, 400, 0)
    end)

    menu.action(trolling, "Look For Who Asked", {}, "", function()
        local radar = util.joaat("prop_air_bigradar")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        request_model(radar)

        local radar_dish = entities.create_object(radar, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 20, -3), ENTITY.GET_ENTITY_HEADING(player))
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(radar_dish)
        chat.send_message("using nasa satellites to find who asked", false, true, true)
        util.yield(10000)
        entities.delete_by_handle(radar_dish)
    end)
    
    menu.click_slider(trolling, "Give Wanted Level", {}, "", 1, 5, 5, 1, function(val)
        local playerInfo = memory.read_long(entities.handle_to_pointer(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)) + 0x10C8)
        while memory.read_uint(playerInfo + 0x0888) < val do
            for i = 1, 46 do
                PLAYER.REPORT_CRIME(pid, i, val)
            end
            util.yield(75)
        end
    end)

    local antimodder = menu.list(bozo, "Anti-Modder", {}, "")
    local kill_godmode = menu.list(antimodder, "Kill Godmode Player", {}, "")
    menu.action(kill_godmode, "Stun", {""}, "Works on menus that use proofs for godmode", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        util.trigger_script_event(1 << pid, {-1388926377, pid, -1762807505, math.random(0, 9999)})
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 99999, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
    end)

    menu.slider_text(kill_godmode, "Squish", {}, "", {"Khanjali", "APC"}, function(index, veh)
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        local vehicle = util.joaat(veh)
        request_model(vehicle)

        pluto_switch veh do
            case "Khanjali":
            height = 2.8
            offset = 0
            break
            case "APC":
            height = 3.4
            offset = -1.5
            break
        end

        if TASK.IS_PED_STILL(player) then
            distance = 0
        elseif not TASK.IS_PED_STILL(player) then
            distance = 3
        end

        local vehicle1 = entities.create_vehicle(vehicle, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), offset, distance, height), ENTITY.GET_ENTITY_HEADING(player))
        local vehicle2 = entities.create_vehicle(vehicle, pos, 0)
        local vehicle3 = entities.create_vehicle(vehicle, pos, 0)
        local vehicle4 = entities.create_vehicle(vehicle, pos, 0)
        local spawned_vehs = {vehicle4, vehicle3, vehicle2, vehicle1}
        for i = 1, #spawned_vehs do
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(spawned_vehs[i])
        end
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle2, vehicle1, 0, 0, 3, 0, 0, 0, -180, 0, false, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle3, vehicle1, 0, 3, 3, 0, 0, 0, -180, 0, false, true, false, 0, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(vehicle4, vehicle1, 0, 3, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
        ENTITY.SET_ENTITY_VISIBLE(vehicle1, false)
        util.yield(5000)
        for i = 1, #spawned_vehs do
            entities.delete_by_handle(spawned_vehs[i])
        end
    end)   

    player_toggle_loop(kill_godmode, pid, "Explode", {}, "Blocked By Most Menus", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        if not PED.IS_PED_DEAD_OR_DYING(player) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) then
            util.trigger_script_event(1 << pid, {-1388926377, pid, -1762807505, math.random(0, 9999)})
            FIRE.ADD_OWNED_EXPLOSION(players.user_ped(), pos.x, pos.y, pos.z, 2, 50, true, false, 0.0)
        end
    end)

    player_toggle_loop(antimodder, pid, "Remove Player Godmode", {}, "Blocked By Most Menus", function()
        util.trigger_script_event(1 << pid, {-1388926377, pid, -1762807505, math.random(0, 9999)})
    end)

    menu.toggle_loop(antimodder, "Remove Godmode Gun", {}, "", function()
        for _, pid in ipairs (players.list(true, true, true)) do
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(players.user(), player) and players.is_godmode(pid) then
                util.trigger_script_event(1 << pid, {-1388926377, pid, -1762807505, math.random(0, 9999)})
            end
        end
    end)

    player_toggle_loop(antimodder, pid, "Remove Vehicle Godmode", {"removevgm"}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if PED.IS_PED_IN_ANY_VEHICLE(player, false) and not PED.IS_PED_DEAD_OR_DYING(player) then
            local veh = PED.GET_VEHICLE_PED_IS_IN(player, false)
            ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, true)
            ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
            ENTITY.SET_ENTITY_PROOFS(veh, false, false, false, false, false, 0, 0, false)
        end
    end)

    local tp_player = menu.list(bozo, "Teleport Player", {}, "")
    local clubhouse = menu.list(tp_player, "Clubhouse", {}, "")
    local facility = menu.list(tp_player, "Facility", {}, "")
    local arcade = menu.list(tp_player, "Arcade", {}, "")
    local cayoperico = menu.list(tp_player, "Cayo Perico", {}, "")

    for id, name in pairs(All_business_properties) do
        if id <= 12 then
            menu.action(clubhouse, name, {}, "", function()
                util.trigger_script_event(1 << pid, {-555356783, pid, id, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, math.random(1, 10)})
            end)
        elseif id > 12 and id <= 21 then
            menu.action(facility, name, {}, "", function()
                util.trigger_script_event(1 << pid, {-555356783, pid, id, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0})
            end)
        elseif id > 21 then
            menu.action(arcade, name, {}, "", function() 
                util.trigger_script_event(1 << pid, {-555356783, pid, id, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1})
            end)
        end
    end

    menu.action(tp_player, "Heist Passed Apartment Teleport", {}, "", function()
        util.trigger_script_event(1 << pid, {-1390976345, players.user(), pid, -1, 1, 1, 0, 1, 0}) 
    end)

    menu.action(cayoperico, "Cayo Perico", {"tpcayo"}, "", function()
        util.trigger_script_event(1 << pid, {1214823473, pid, 0, 0, 3, 1, 0})
    end)

    menu.action(cayoperico, "Cayo Perico (No Cutscene)", {"tpcayo2"}, "", function()
        util.trigger_script_event(1 << pid, {1214823473, pid, 0, 0, 4, 1, 0})
    end)

    menu.action(cayoperico, "Leaving Cayo Perico", {"cayoleave"}, "Player Must Be At Cayo Perico To Trigger This Event", function()
        util.trigger_script_event(1 << pid, {1214823473, pid, 0, 0, 3, 0, 0})
    end)

    menu.action(cayoperico, "Kicked From Cayo Perico", {"cayokick"}, "", function()
        util.trigger_script_event(1 << pid, {1214823473, pid, 0, 0, 4, 0, 0})
    end)

    local player_removals = menu.list(bozo, "Player Removals", {}, "")
    local kicks = menu.list(player_removals, "Kicks", {}, "")
    local crashes = menu.list(player_removals, "Crashes", {}, "")
    menu.action(kicks, "Freemode Death", {"freemodedeath"}, "Will kill their freemode and send them back to story mode", function()
        util.trigger_script_event(1 << pid, {111242367, pid, memory.script_global(2689235 + 1 + (pid * 453) + 318 + 7)})
    end)

    menu.action(kicks, "Network Bail", {"networkbail"}, "", function()
        util.trigger_script_event(1 << pid, {1674887089, players.user(), memory.read_int(memory.script_global(1892703 + 1 + (pid * 599) + 510))})
    end)

    menu.action(kicks, "Invalid Collectible", {"invalidcollectible"}, "", function()
        util.trigger_script_event(1 << pid, {-1178972880, pid, 8, -1, 1, 1, 1})
    end)

    if menu.get_edition() >= 2 then 
        menu.action(kicks, "Adaptive Kick", {"adaptivekick"}, "", function()
            util.trigger_script_event(1 << pid, {-1178972880, pid, 4, -1, 1, 1, 1})
            util.yield(250)
            if players.exists(pid) then
                util.trigger_script_event(1 << pid, {111242367, pid, memory.script_global(2689235 + 1 + (pid * 453) + 318 + 7)})
            end
            util.yield(250)
            if players.exists(pid) then
                util.trigger_script_event(1 << pid, {1674887089, players.user(), memory.read_int(memory.script_global(1892703 + 1 + (pid * 599) + 510))})
            end
            util.yield(250)
            if players.exists(pid) then
                menu.trigger_commands("breakup" .. players.get_name(pid))
            end
        end)
    else
        menu.action(kicks, "Adaptive Kick", {"adaptivekick"}, "", function()
            util.trigger_script_event(1 << pid, {-1178972880, pid, 4, -1, 1, 1, 1})
            util.yield(250)
            if players.exists(pid) then
                util.trigger_script_event(1 << pid, {111242367, pid, memory.script_global(2689235 + 1 + (pid * 453) + 318 + 7)})
            end
            util.yield(250)
            if players.exists(pid) then
                util.trigger_script_event(1 << pid, {1674887089, players.user(), memory.read_int(memory.script_global(1892703 + 1 + (pid * 599) + 510))})
            end
        end)
    end

    if menu.get_edition() >= 2 then 
        menu.action(kicks, "Block Join Kick", {"blast"}, "Will add them to blocked joins list, alternative to people who don't want to use block joins from every kicked player", function()
            menu.trigger_commands("historyblock " .. players.get_name(pid))
            menu.trigger_commands("breakup" .. players.get_name(pid))
        end)
    end

    menu.action(crashes, "Mother Nature Crash", {"opcrash"}, "", function()
        local user = players.user()
        local user_ped = players.user_ped()
        local model = util.joaat("h4_prop_bush_mang_ad") -- special op object so you dont have to be near them :D
        BlockSyncs(pid, function() -- blocking outgoing syncs to prevent the lobby from crashing :5head:
            util.yield(100)
            ENTITY.SET_ENTITY_VISIBLE(user_ped, false)
            for i = 0, 110 do
                PLAYER.SET_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user, model)
                PED.SET_PED_COMPONENT_VARIATION(user_ped, 5, i, 0, 0)
                util.yield(50)
                PLAYER.CLEAR_PLAYER_PARACHUTE_PACK_MODEL_OVERRIDE(user)
            end
            util.yield(250)
            for i = 1, 5 do
                util.spoof_script("freemode", SYSTEM.WAIT) -- preventing wasted screen
            end
            ENTITY.SET_ENTITY_HEALTH(user_ped, 0) -- killing ped because it will still crash others until you die (clearing tasks doesnt seem to do much)
            local pos = players.get_position(user)
            NETWORK.NETWORK_RESURRECT_LOCAL_PLAYER(pos.x, pos.y, pos.z, 0, false, false, 0)
            ENTITY.SET_ENTITY_VISIBLE(user_ped, true)
        end)
    end)

    if bailOnAdminJoin then
        if players.is_marked_as_admin(pid) then
            util.toast(players.get_name(pid) .. " Is a Rockstar Admin. Bailing from the session.")
            menu.trigger_commands("quickbail")
            return
        end
    end
end

players.on_join(player)
players.dispatch_on_join()


menu.toggle_loop(self, "Script Host Addict", {}, "A faster version of script host kleptomaniac", function()
    if players.get_script_host() ~= players.user() and get_transition_state(players.user()) ~= 0 then
        menu.trigger_command(menu.ref_by_path("Players>"..players.get_name_with_tags(players.user())..">Friendly>Give Script Host"))
    end
end)

local function bitTest(addr, offset)
    return (memory.read_int(addr) & (1 << offset)) ~= 0
end
menu.toggle_loop(self, "Auto Claim Destroyed Vehicles", {}, "Automatically claims destroyed vehicles so you won't have to.", function()
    local count = memory.read_int(memory.script_global(1585857))
    for i = 0, count do
        local canFix = (bitTest(memory.script_global(1585857 + 1 + (i * 142) + 103), 1) and bitTest(memory.script_global(1585857 + 1 + (i * 142) + 103), 2))
        if canFix then
            MISC.CLEAR_BIT(memory.script_global(1585857 + 1 + (i * 142) + 103), 1)
            MISC.CLEAR_BIT(memory.script_global(1585857 + 1 + (i * 142) + 103), 3)
            MISC.CLEAR_BIT(memory.script_global(1585857 + 1 + (i * 142) + 103), 16)
            util.toast("Your personal vehicle was destroyed. It has been automatically claimed.")
        end
    end
    util.yield(100)
end)

local muggerWarning
muggerWarning = menu.action(self, "Mugger Money Removal", {}, "", function(click_type)
    menu.show_warning(muggerWarning, click_type, "Warning: Don't Be Dumb, Once You Purchase A Mugger The Changes Can't Be Undone And Your Money Will Be Gone. Only Use If You Intend To Get Rid Of Your Money", function()
        menu.delete(muggerWarning)
        local muggerList = menu.list(self, "Mugger Money Removal")
        local price = 1000
        menu.click_slider(muggerList, "Mugger Price", {"muggerprice"}, "", 0, 2000000000, 0, 1000, function(value)
            price = value
        end)

        menu.toggle_loop(muggerList, "Change Mugger Price", {}, "", function()
            memory.write_int(memory.script_global(262145 + 4121), price) 
        end)
        menu.trigger_command(muggerList)
    end)
end)

local unlocks = menu.list(self, "Collectibles", {}, "")
menu.click_slider(unlocks, "Movie Props", {""}, "", 0, 9, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 0, i, 1, 1, 1})
end)

menu.click_slider(unlocks, "Hidden Caches", {""}, "", 0, 9, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 1, i, 1, 1, 1})
end)

menu.click_slider(unlocks, "Treasure Chests", {""}, "", 0, 1, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 2, i, 1, 1, 1})
end)

menu.click_slider(unlocks, "Radio Antennas", {""}, "", 0, 9, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 3, i, 1, 1, 1})
end)

menu.click_slider(unlocks, "Media USBs", {""}, "", 0, 19, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 4, i, 1, 1, 1})
end)

menu.action(unlocks, "Shipwreck", {""}, "", function()
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 5, 0, 1, 1, 1})
end)

menu.click_slider(unlocks, "Buried Stash", {""}, "", 0, 1, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 6, i, 1, 1, 1})
end)

menu.action(unlocks, "Halloween T-Shirt", {""}, "", function()
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 7, 1, 1, 1, 1})
end)

menu.click_slider(unlocks, "Jack O' Lanterns", {""}, "", 0, 9, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 8, i, 1, 1, 1})
end)

menu.click_slider(unlocks, "Lamar Davis Organics Product", {""}, "", 0, 99, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 9, i, 1, 1, 1})
end)

menu.click_slider(unlocks, "Junk Energy Skydive", {""}, "", 0, 9, 0, 1, function(i)
    util.trigger_script_event(1 << players.user(), {-1178972880, 0, 10, i, 1, 1, 1})
end)

local proofsList = menu.list(self, "Invulnerabilities", {}, "Custom Godmode")
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

local criminalDamageCmdRef = menu.ref_by_path("Online>Session>Session Scripts>Run Script>Freemode Activities>Criminal Damage")
menu.action(session, "Criminal Damage Speed Run", {}, "", function()
    if SCRIPT._GET_NUMBER_OF_REFERENCES_OF_SCRIPT_WITH_NAME_HASH(util.joaat("am_criminal_damage")) == 0 then
        menu.trigger_command(criminalDamageCmdRef)
        repeat
            util.yield_once()
        until SCRIPT._GET_NUMBER_OF_REFERENCES_OF_SCRIPT_WITH_NAME_HASH(util.joaat("am_criminal_damage")) ~= 0
    end
    util.yield(1000)
    repeat
        util.request_script_host("am_criminal_damage")
        util.yield_once()
    until NETWORK.NETWORK_GET_HOST_OF_SCRIPT("am_criminal_damage", -1, 0) == players.user()
    memory.write_int(memory.script_local("am_criminal_damage", 108 + 43), memory.read_int(memory.script_global(262145 + 11675)))
    util.yield(1000)
    memory.write_int(memory.script_local("am_criminal_damage", 103), 2147483647)
    util.yield(1000)
    memory.write_int(memory.script_local("am_criminal_damage", 108 + 39), memory.read_int(memory.script_global(262145 + 11674)))
end)


menu.toggle_loop(vehicle, "Stealth Vehicle Godmode", {}, "Won't be detected as vehicle godmode by most menus", function()
    ENTITY.SET_ENTITY_PROOFS(entities.get_user_vehicle_as_handle(), true, true, true, true, true, 0, 0, true)
    end, function() ENTITY.SET_ENTITY_PROOFS(PED.GET_VEHICLE_PED_IS_IN(player), false, false, false, false, false, 0, 0, false)
end)

menu.toggle_loop(vehicle, "Indicator Lights", {}, "", function()
    if(PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false)) then
        local vehicle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)

        local left = PAD.IS_CONTROL_PRESSED(34, 34)
        local right = PAD.IS_CONTROL_PRESSED(35, 35)
        local rear = PAD.IS_CONTROL_PRESSED(130, 130)

        if left and not right and not rear then
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, true)
        elseif right and not left and not rear then
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, true)
        elseif rear and not left and not right then
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, true)
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, true)
        else
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 0, false)
            VEHICLE.SET_VEHICLE_INDICATOR_LIGHTS(vehicle, 1, false)
        end
    end
end)

menu.click_slider_float(vehicle, "Suspension Height", {"suspensionheight"}, "", -100, 100, 0, 1, function(value)
    value/=100
    local player = players.user_ped()
    local pos = ENTITY.GET_ENTITY_COORDS(player, false)
    local VehicleHandle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if VehicleHandle == 0 then return end
    local CAutomobile = entities.handle_to_pointer(VehicleHandle)
    local CHandlingData = memory.read_long(CAutomobile + 0x0938)
    memory.write_float(CHandlingData + 0x00D0, value)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(VehicleHandle, pos.x, pos.y, pos.z + 2.8, false, false, false) -- Dropping vehicle so the suspension updates
end)

menu.click_slider_float(vehicle, "Torque Multiplier", {"torque"}, "", 0, 1000, 100, 10, function(value)
    value/=100
    local VehicleHandle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if VehicleHandle == 0 then return end
    local CAutomobile = entities.handle_to_pointer(VehicleHandle)
    local CHandlingData = memory.read_long(CAutomobile + 0x0938)
    memory.write_float(CHandlingData + 0x004C, value)
end)

menu.click_slider_float(vehicle, "Upshift Multiplier", {"upshift"}, "", 0, 500, 100, 10, function(value)
    value/=100
    local VehicleHandle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if VehicleHandle == 0 then return end
    local CAutomobile = entities.handle_to_pointer(VehicleHandle)
    local CHandlingData = memory.read_long(CAutomobile + 0x0938)
    memory.write_float(CHandlingData + 0x0058, value)
end)

menu.click_slider_float(vehicle, "Downshift Multiplier", {"downshift"}, "", 0, 500, 100, 10, function(value)
    value/=100
    local VehicleHandle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if VehicleHandle == 0 then return end
    local CAutomobile = entities.handle_to_pointer(VehicleHandle)
    local CHandlingData = memory.read_long(CAutomobile + 0x0938)
    memory.write_float(CHandlingData + 0x005C, value)
end)

menu.click_slider_float(vehicle, "Curve Ratio Multiplier", {"curve"}, "", 0, 500, 100, 10, function(value)
    value/=100
    local VehicleHandle = PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false)
    if VehicleHandle == 0 then return end
    local CAutomobile = entities.handle_to_pointer(VehicleHandle)
    local CHandlingData = memory.read_long(CAutomobile + 0x0938)
    memory.write_float(CHandlingData + 0x0094, value)
end)

menu.toggle_loop(vehicle, "Random Upgrades", {}, "Only works on vehicles you spawned in for some reason", function()
    local mod_types = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 12, 14, 15, 16, 23, 24, 25, 27, 28, 30, 33, 35, 38, 48}
    if PED.IS_PED_IN_ANY_VEHICLE(players.user_ped()) then
        for i, upgrades in ipairs(mod_types) do
            VEHICLE.SET_VEHICLE_MOD(entities.get_user_vehicle_as_handle(), upgrades, math.random(0, 20), false)
        end
    end
    util.yield(100)
end)

menu.click_slider(visuals, "Drunk Mode", {}, "", 0, 5, 1, 1, function(val)
    if val > 0 then
        CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", val)
        GRAPHICS.SET_TIMECYCLE_MODIFIER("Drunk")
    else
        GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
        CAM.SHAKE_GAMEPLAY_CAM("DRUNK_SHAKE", 0)
    end
end)

local visions = menu.list(visuals, "Screen Effects", {}, "")
for id, data in pairs(effect_stuff) do
    local effect_name = data[1]
    local effect_thing = data[2]
    menu.toggle(visions, effect_name, {""}, "", function(toggled)
        if toggled then
            GRAPHICS.ANIMPOSTFX_PLAY(effect_thing, 5, true)
        else
            GRAPHICS.ANIMPOSTFX_STOP_ALL()
        end
    end)
end

local visual_fidelity = menu.list(visuals, "Visual Enhancements", {}, "")
for id, data in pairs(visual_stuff) do
    local effect_name = data[1]
    local effect_thing = data[2]
    menu.toggle(visual_fidelity, effect_name, {""}, "", function(toggled)
        if toggled then
            GRAPHICS.SET_TIMECYCLE_MODIFIER(effect_thing)
            menu.trigger_commands("shader off")
        else
            GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
        end
    end)
end 

local drug_mode = menu.list(visuals, "Drugged Filters", {}, "")
for id, data in pairs(drugged_effects) do
    menu.toggle(drug_mode, data, {}, "", function(toggled)
        if toggled then
            GRAPHICS.SET_TIMECYCLE_MODIFIER(data)
            menu.trigger_commands("shader off")
        else
            GRAPHICS.SET_TIMECYCLE_MODIFIER("DEFAULT")
        end
    end)
end

menu.action(funfeatures, "Custom Fake Banner", {"banner"}, "", function(on_click) menu.show_command_box("banner ") end, function(text)
    custom_alert(text)
end)

local jesus_main = menu.list(funfeatures, "Jesus Take The Wheel", {}, "")
menu.slider_text(jesus_main, "Driving Style", {}, "Click to select a style", style_names, function(index, value)
    pluto_switch value do
        case 1:
            style = 786603
            break
        case 2:
            style = 1074528293
            break
        case 3:
            style = 8388614
            break
        case 4:
            style = 1076
            break
        case 5:
            style = 2883621
            break
        case 6:
            style = 786603
            break
        case 7:
            style = 6
            break
        case 8:
            style = 5
            break
        end
    end)
jesus_toggle = menu.toggle(jesus_main, "Take The Wheel", {}, "", function(toggled)
    if toggled then
        local player = players.user_ped()
        local pos = ENTITY.GET_ENTITY_COORDS(player, false)
        local player_veh = entities.get_user_vehicle_as_handle()

        if not PED.IS_PED_IN_ANY_VEHICLE(player, false) then 
            util.toast("Put your ass in/on a vehicle first. :)")
        return end

        local jesus = util.joaat("u_m_m_jesus_01")
        request_model(jesus)

        
        jesus_ped = entities.create_ped(26, jesus, pos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(jesus_ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(jesus_ped, true)
        PED.SET_PED_INTO_VEHICLE(player, player_veh, -2)
        PED.SET_PED_INTO_VEHICLE(jesus_ped, player_veh, -1)
        PED.SET_PED_KEEP_TASK(jesus_ped, true)

        if HUD.IS_WAYPOINT_ACTIVE() then
	    	local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(jesus_ped, player_veh, pos.x, pos.y, pos.z, 9999, style, 0)
        else
            util.toast("Waypoint not found. :/")
                menu.set_value(jesus_toggle, false)
        end
    else
        if jesus_ped ~= nil then 
            entities.delete_by_handle(jesus_ped)
        end
    end
end)

menu.toggle(funfeatures, "Tesla Autopilot", {}, "", function(toggled)
    local player = players.user_ped()
    local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
    local tesla_ai = util.joaat("u_m_y_baygor")
    local tesla = util.joaat("raiden")
    request_model(tesla_ai)
    request_model(tesla)
    if toggled then     
        if PED.IS_PED_IN_ANY_VEHICLE(player, true) then
            menu.trigger_commands("deletevehicle")
        end

        tesla_ai_ped = entities.create_ped(26, tesla_ai, playerpos, 0)
        tesla_vehicle = entities.create_vehicle(tesla, playerpos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(tesla_ai_ped, true)
        ENTITY.SET_ENTITY_VISIBLE(tesla_ai_ped, false)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(tesla_ai_ped, true)
        PED.SET_PED_INTO_VEHICLE(player, tesla_vehicle, -2)
        PED.SET_PED_INTO_VEHICLE(tesla_ai_ped, tesla_vehicle, -1)
        PED.SET_PED_KEEP_TASK(tesla_ai_ped, true)
        VEHICLE.SET_VEHICLE_COLOURS(tesla_vehicle, 111, 111)
        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 23, 8, false)
        VEHICLE.SET_VEHICLE_MOD(tesla_vehicle, 15, 1, false)
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(tesla_vehicle, 111, 147)
        menu.trigger_commands("performance")

        if HUD.IS_WAYPOINT_ACTIVE() then
	    	local pos = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(tesla_ai_ped, tesla_vehicle, pos.x, pos.y, pos.z, 20, 786603, 0)
        else
            TASK.TASK_VEHICLE_DRIVE_WANDER(tesla_ai_ped, tesla_vehicle, 20, 786603)
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


 menu.toggle_loop(funfeatures, "LA Traffic", {}, "", function()
    for i, ped in ipairs(entities.get_all_peds_as_handles()) do
        TASK.SET_DRIVE_TASK_DRIVING_STYLE(ped, math.random(1, #drivingStyles))
        PED.SET_PED_KEEP_TASK(ped, true)
    end
    util.yield(1000)
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

local rapid_khanjali
rapid_khanjali = menu.toggle_loop(vehicle, "Rapid Fire Khanjali", {}, "", function()
    local player_veh = PED.GET_VEHICLE_PED_IS_USING(players.user_ped())
    if ENTITY.GET_ENTITY_MODEL(player_veh) == util.joaat("khanjali") then
        VEHICLE.SET_VEHICLE_MOD(player_veh, 10, math.random(-1, 0), false)
    else
        util.toast("Please get in a khanjali.")
        menu.trigger_command(rapid_khanjali, "off")
    end
end)

local finger_thing = menu.list(funfeatures, "Finger Gun", {}, "")
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
                v3.free(tmp)
                local x, y, z = v3.get(inst)
                local fingerPos = PED.GET_PED_BONE_COORDS(players.user_ped(), 0xff9, 0, 0, 0)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(fingerPos.x, fingerPos.y, fingerPos.z, x, y, z, 1, true, projectile, 0, true, false, 500, players.user_ped(), 0)
            end
            util.yield(100)
        end
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(pos.x, pos.y, pos.z, 999999, 0)
    end)
end
local weapon_thing = menu.list(funfeatures, "Change Bullet Projectile", {}, "")
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
                if not WEAPON.GET_PED_LAST_WEAPON_IMPACT_COORD(PLAYER.PLAYER_PED_ID(), inst) then
                    v3.set(inst,CAM.GET_FINAL_RENDERED_CAM_ROT(2))
                    local tmp = v3.toDir(inst)
                    v3.set(inst, v3.get(tmp))
                    v3.mul(inst, 1000)
                    v3.set(tmp, CAM.GET_FINAL_RENDERED_CAM_COORD())
                    v3.add(inst, tmp)
                    v3.free(tmp)
                end
                local x, y, z = v3.get(inst)
                local wpEnt = WEAPON.GET_CURRENT_PED_WEAPON_ENTITY_INDEX(PLAYER.PLAYER_PED_ID(), false)
                local wpCoords = ENTITY._GET_ENTITY_BONE_POSITION_2(wpEnt, ENTITY.GET_ENTITY_BONE_INDEX_BY_NAME(wpEnt, "gun_muzzle"))
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(wpCoords.x, wpCoords.y, wpCoords.z, x, y, z, 1, true, weapon, PLAYER.PLAYER_PED_ID(), true, false, 1000)
            end
            util.yield()
        end
        local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(pos.x, pos.y, pos.z, 999999, 0)
    end)
end

local jinx_pet
menu.toggle_loop(funfeatures, "Personal Pet Jinx", {}, "", function()
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
    local player = players.user_ped()
    local pos = ENTITY.GET_ENTITY_COORDS(player, false)
    pos.y = pos.y - 5
    pos.z = pos.z + 1
    local jinx = util.joaat("a_c_cat_01")
    request_model(jinx)
     for i = 1, val do
        jinx_army[i] = entities.create_ped(28, jinx, pos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(jinx_army[i], true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(jinx_army[i], true)
        PED.SET_PED_COMPONENT_VARIATION(jinx_army[i], 0, 0, 1, 0)
        TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(jinx_army[i], player, 0, -0.3, 0, 7.0, -1, 10, true)
        util.yield()
     end 
end)

menu.action(army, "Clear Jinxs", {}, "", function()
    for i, jinx in ipairs(jinx_army) do
        entities.delete_by_handle(jinx_army[i])
    end
end)

menu.action(funfeatures, "Find Jinx", {}, "", function()
    local player = players.user_ped()
    local pos = ENTITY.GET_ENTITY_COORDS(player, false)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(jinx_pet, pos.x, pos.y, pos.z, false, false, false)
end)


menu.toggle_loop(detections, "Godmode", {}, "Players in godmode will show up as debug text.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player, false)
        for i, interior in ipairs(interior_stuff) do
            if (players.is_godmode(pid) or not ENTITY._GET_ENTITY_CAN_BE_DAMAGED(player)) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(player) and get_transition_state(pid) ~= 0 and get_interior_player_is_in(pid) == interior then
                util.draw_debug_text(players.get_name(pid) .. " Is In Godmode")
                break
            end
        end
    end 
end)

menu.toggle_loop(detections, "Vehicle Godmode", {}, "Players in vehicle godmode will show up as debug text.", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player, false)
        local player_veh = PED.GET_VEHICLE_PED_IS_USING(player)
        if PED.IS_PED_IN_ANY_VEHICLE(player, true) then
            for i, interior in ipairs(interior_stuff) do
                if not ENTITY._GET_ENTITY_CAN_BE_DAMAGED(player_veh) and not NETWORK.NETWORK_IS_PLAYER_FADING(pid) and ENTITY.IS_ENTITY_VISIBLE(player) and get_transition_state(pid) ~= 0 and get_interior_player_is_in(pid) == interior then
                    util.draw_debug_text(players.get_name(pid) .. " Is In Vehicle Godmode")
                    break
                end
            end
        end
    end 
end)

menu.toggle_loop(detections, "Unreleased Vehicle", {}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local modelHash = players.get_vehicle_model(pid)
        for i, name in ipairs(unreleased_vehicles) do
            if modelHash == util.joaat(name) then
                util.draw_debug_text(players.get_name(pid) .. " Is Driving An Unreleased Vehicle")
            end
        end
    end
end)

menu.toggle_loop(detections, "Modded Weapon", {}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        for i, hash in ipairs(modded_weapons) do
            local weapon_hash = util.joaat(hash)
            if WEAPON.HAS_PED_GOT_WEAPON(player, weapon_hash, false) then
                util.draw_debug_text(players.get_name(pid) .. " Is Using A Modded Weapon")
                break
            end
        end
    end
end)

menu.toggle_loop(detections, "Modded Vehicle", {}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local modelHash = players.get_vehicle_model(pid)
        for i, name in ipairs(modded_vehicles) do
            if modelHash == util.joaat(name) then
                util.draw_debug_text(players.get_name(pid) .. " Is Driving A Modded Vehicle")
                break
            end
        end
    end
end)

menu.toggle_loop(detections, "Weapon In Interior", {}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if players.is_in_interior(pid) and WEAPON.IS_PED_ARMED(player, 7) then
            util.draw_debug_text(players.get_name(pid) .. " Has A Weapon In An Interior")
            break
        end
    end
end)

---Improvements:
---1) It won't do anything if we're the sender
---2) Works just in case of mugger, not for mercenaries
---3) By deleting the ped (mugger) both scripts (senders and ours) will stop, not just ours.
---Also, Lamar will call the sender to tell them the mugger failed
menu.toggle_loop(protections, "Anti-Mugger", {}, "", function()
    if NETWORK.NETWORK_IS_SCRIPT_ACTIVE("am_gang_call", 0, true, 0) then
        local ped_netId = memory.script_local("am_gang_call", 63 + 10 + (0 * 7 + 1))
        local sender = memory.script_local("am_gang_call", 287)
        local target = memory.script_local("am_gang_call", 288)

        util.spoof_script("am_gang_call", function ()
            if memory.read_int(sender) ~= players.user() and memory.read_int(target) == players.user() and
            NETWORK.NETWORK_DOES_NETWORK_ID_EXIST(memory.read_int(ped_netId)) and
            NETWORK.NETWORK_REQUEST_CONTROL_OF_NETWORK_ID(memory.read_int(ped_netId)) then
                local mugger = NETWORK.NET_TO_PED(memory.read_int(ped_netId))
                entities.delete_by_handle(mugger)
                util.toast("Blocked mugger from " .. players.get_name(memory.read_int(sender)))
            end
        end)
    end
end)


menu.toggle_loop(protections, "Block PTFX", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped() , false);
    GRAPHICS.REMOVE_PARTICLE_FX_IN_RANGE(coords.x, coords.y, coords.z, 400)
    GRAPHICS.REMOVE_PARTICLE_FX_FROM_ENTITY(players.user_ped())
end)

menu.toggle_loop(protections, "Block Fire Lag", {}, "", function()
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped() , false);
    FIRE.STOP_FIRE_IN_RANGE(coords.x, coords.y, coords.z, 100)
    FIRE.STOP_ENTITY_FIRE(players.user_ped())
end)

local anticage = menu.list(protections, "Anti-Cage Protection", {}, "")
local alpha = 160
menu.slider(anticage, "Cage Alpha", {"cagealpha"}, "The ammount of transparency that objects will have", 0, #values, 3, 1, function(amount)
    alpha = values[amount]
end)

menu.toggle_loop(anticage, "Enable Anti-Cage", {"anticage"}, "", function()
    local user = players.user_ped()
    local veh = PED.GET_VEHICLE_PED_IS_USING(user)
    local my_ents = {user, veh}
    for i, obj_ptr in ipairs(entities.get_all_objects_as_pointers()) do
        local net_obj = memory.read_long(obj_ptr + 0xd0)
        if net_obj == 0 or memory.read_byte(net_obj + 0x49) == players.user() then
            continue
        end
        local obj_handle = entities.pointer_to_handle(obj_ptr)
        ENTITY.SET_ENTITY_ALPHA(obj_handle, alpha, false)
        CAM._DISABLE_CAM_COLLISION_FOR_ENTITY(obj_handle)
        for i, data in ipairs(my_ents) do
            if data ~= 0 then
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(obj_handle, data, false)
                ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(data, obj_handle, false)
            end
        end
        SHAPETEST.RELEASE_SCRIPT_GUID_FROM_ENTITY(obj_handle)
    end
end)

menu.toggle_loop(protections, "Ghost Objects", {"ghostobjects"}, "Disables collision with objects", function()
    local user = players.user_ped()
    local veh = PED.GET_VEHICLE_PED_IS_USING(user)
    local my_ents = {user, veh}
    for i, obj_ptr in ipairs(entities.get_all_objects_as_pointers()) do
        local net_obj = memory.read_long(obj_ptr + 0xd0)
        local obj_handle = entities.pointer_to_handle(obj_ptr)
        ENTITY.SET_ENTITY_ALPHA(obj_handle, 255, false)
        CAM._DISABLE_CAM_COLLISION_FOR_ENTITY(obj_handle)
        for i, data in ipairs(my_ents) do
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(obj_handle, data, false)
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(data, obj_handle, false)  
        end
        SHAPETEST.RELEASE_SCRIPT_GUID_FROM_ENTITY(obj_handle)
    end
end)

menu.toggle_loop(protections, "Ghost Vehicles", {"ghostvehicles"}, "Disables collision with vehicles", function()
    local user = players.user_ped()
    local veh = PED.GET_VEHICLE_PED_IS_USING(user)
    local my_ents = {user, veh}
    for i, veh_ptr in ipairs(entities.get_all_vehicles_as_pointers()) do
        local net_veh = memory.read_long(veh_ptr + 0xd0)
        local veh_handle = entities.pointer_to_handle(veh_ptr)
        ENTITY.SET_ENTITY_ALPHA(veh_handle, 255, false)
        CAM._DISABLE_CAM_COLLISION_FOR_ENTITY(veh_handle)
        for i, data in ipairs(my_ents) do
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(veh_handle, data, false)
            ENTITY.SET_ENTITY_NO_COLLISION_ENTITY(data, veh_handle, false)  
        end
        SHAPETEST.RELEASE_SCRIPT_GUID_FROM_ENTITY(veh_handle)
    end
end)

menu.list_action(protections, "Clear All...", {}, "", {"Peds", "Vehicles", "Objects", "Pickups", "Ropes", "Projectiles", "Sounds"}, function(index, name)
    util.toast("Clearing "..name:lower().."...")
    local counter = 0
    pluto_switch index do
        case 1:
            for _, ped in ipairs(entities.get_all_peds_as_handles()) do
                if ped ~= players.user_ped() and not PED.IS_PED_A_PLAYER(ped) and (not NETWORK.NETWORK_IS_ACTIVITY_SESSION() or NETWORK.NETWORK_IS_ACTIVITY_SESSION() and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped)) then
                    entities.delete_by_handle(ped)
                    counter += 1
                    util.yield_once()
                end
            end
            break
        case 2:
            for _, vehicle in ipairs(entities.get_all_vehicles_as_handles()) do
                if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) and DECORATOR.DECOR_GET_INT(vehicle, "Player_Vehicle") == 0 and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
                    entities.delete_by_handle(vehicle)
                    counter += 1
                end
                util.yield(25)
            end
            break
        case 3:
            for _, object in ipairs(entities.get_all_objects_as_handles()) do
                entities.delete_by_handle(object)
                counter += 1
                util.yield_once()
            end
            break
        case 4:
            for _, pickup in ipairs(entities.get_all_pickups_as_handles()) do
                entities.delete_by_handle(pickup)
                counter += 1
                util.yield_once()
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
                util.yield_once()
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
                util.yield_once()
            end
        break
    end
    util.toast("Cleared "..tostring(counter).." "..name:lower()..".")
end)

menu.action(protections, "Clear Everything", {"cleanse"}, "", function()
    local cleanse_entitycount = 0
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ped ~= players.user_ped() and not PED.IS_PED_A_PLAYER(ped) and (not NETWORK.NETWORK_IS_ACTIVITY_SESSION() or NETWORK.NETWORK_IS_ACTIVITY_SESSION() and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped)) then
            entities.delete_by_handle(ped)
            cleanse_entitycount += 1
        end
    end
    util.toast("Cleared " .. cleanse_entitycount .. " Peds")
    cleanse_entitycount = 0
    for _, veh in ipairs(entities.get_all_vehicles_as_handles()) do
        if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) and DECORATOR.DECOR_GET_INT(vehicle, "Player_Vehicle") == 0 and NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(vehicle) then
            entities.delete_by_handle(veh)
            cleanse_entitycount += 1
            util.yield()
        end
    end
    util.toast("Cleared ".. cleanse_entitycount .." Vehicles")
    cleanse_entitycount = 0
    for _, object in pairs(entities.get_all_objects_as_handles()) do
        entities.delete_by_handle(object)
        cleanse_entitycount += 1
    end
    util.toast("Cleared " .. cleanse_entitycount .. " Objects")
    cleanse_entitycount = 0
    for _, pickup in pairs(entities.get_all_pickups_as_handles()) do
        entities.delete_by_handle(pickup)
        cleanse_entitycount += 1
    end
    util.toast("Cleared " .. cleanse_entitycount .. " Pickups")
    local temp = memory.alloc(4)
    for i = 0, 100 do
        memory.write_int(temp, i)
        PHYSICS.DELETE_ROPE(temp)
    end
    util.toast("Cleared All Ropes")
    local pos = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_PROJECTILES(pos.x, pos.y, pos.z, 400, 0)
    util.toast("Cleared All Projectiles")
end)

local pool_limiter = menu.list(protections, "Pool Limiter", {}, "")
local ped_limit = 175
menu.slider(pool_limiter, "Ped Pool Limit", {"pedlimit"}, "", 0, 256, 175, 1, function(amount)
    ped_limit = amount
end)

local veh_limit = 200
menu.slider(pool_limiter, "Vehicle Pool Limit", {"vehlimit"}, "", 0, 300, 150, 1, function(amount)
    veh_limit = amount
end)

local obj_limit = 750
menu.slider(pool_limiter, "Object Pool Limit", {"objlimit"}, "", 0, 2300, 750, 1, function(amount)
    obj_limit = amount
end)

local projectile_limit = 25
menu.slider(pool_limiter, "Projectile Pool Limit", {"projlimit"}, "", 0, 50, 25, 1, function(amount)
    projectile_limit = amount
end)

menu.toggle_loop(pool_limiter, "Enable Pool Limiter", {}, "", function()
    local ped_count = 0
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        util.yield()
        if ped ~= players.user_ped() then
            ped_count += 1
        end
        if ped_count >= ped_limit then
            for _, ped in pairs(entities.get_all_peds_as_handles()) do
                util.yield()
                entities.delete_by_handle(ped)
            end
            util.toast("[Stand Essentials] Ped Pool Limit Hit. Clearing Peds...")
        end
    end
    local veh__count = 0
    for _, veh in ipairs(entities.get_all_vehicles_as_handles()) do
        util.yield()
        veh__count += 1
        if veh__count >= veh_limit then
            for _, veh in ipairs(entities.get_all_vehicles_as_handles()) do
                entities.delete_by_handle(veh)
            end
            util.toast("[Stand Essentials] Vehicle Pool Limit Hit. Clearing Vehicles...")
        end
    end
    local obj_count = 0
    for _, obj in pairs(entities.get_all_objects_as_handles()) do
        util.yield()
        obj_count += 1
        if obj_count >= obj_limit then
            for _, obj in pairs(entities.get_all_objects_as_handles()) do
                entities.delete_by_handle(obj)
            end
            util.toast("[Stand Essentials] Object Pool Limit Hit. Clearing Objects...")
        end
    end
end)

local misc = menu.list(menu.my_root(), "Miscellaneous", {}, "")
menu.hyperlink(menu.my_root(), "Join The Discord", "https://discord.gg/6TWDGfGG64")
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
menu.action(credits, "well in that case", {}, "for making pluto and allowing parts of my code look nicer and run smoother", function()
end)
menu.action(credits, "jerry123", {}, "for cleaning my code in some spots and telling me what can be improved", function()
end)
menu.action(credits, "Scriptcat", {}, "being there since I started and telling me some useful lua tips and forcing me to start learning stands api and natives", function()
end)
menu.action(credits, "ERR_NET_ARRAY", {}, "helping with memory editing", function()
end)
menu.action(credits, "d6b.", {}, "gifting nitro because he is such a super gamer gigachad", function()
end)

menu.action(menu.my_root(), "Take Me To Player Features", {}, "", function()
    menu.trigger_commands("jinxscript " .. players.get_name(players.user()))
end)
util.keep_running()
