--[[
    Credits:
    Aaronlink127 & Sapphire for helping with a good portion of the lua at the beginning when I was still learning
    GameCrunch: For being a total chad and very based
]]

util.require_natives(1640181023)
util.toast("Welcome To Jinx Script!\n" .. "Official Discord: https://discord.gg/6TWDGfGG64" )
local function player_toggle_loop(root, pid, menu_name, command_names, help_text, callback)
    return menu.toggle_loop(root, menu_name, command_names, help_text, function()
        if not players.exists(pid) then util.stop_thread() end
        callback()
    end)
end

local function get_interior_player_is_in(pid)
    return memory.read_int(memory.script_global(((2689224 + 1) + (pid * 451)) + 242)) 
end

local function is_player_in_interior(pid)
    return (memory.read_int(memory.script_global(2689224 + 1 + (pid * 451) + 242 )) ~= 0)
end

local function get_entity_owner(addr)
    return memory.read_byte(memory.read_long(addr + 0xD0) + 0x49)
end

local function get_blip_coords(blipId)
    local blip = HUD.GET_FIRST_BLIP_INFO_ID(blipId)
    if blip ~= 0 then return HUD.GET_BLIP_COORDS(blip) end
    return v3(0, 0, 0)
end

local function custom_alert(l1) --Credit to whoever sent me this
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

local cleanse = {
    "Clear Peds",
    "Clear Vehicles",
    "Clear Objects",
    "Clear Pickups",
    "Clear Ropes",
    "Clear Projectiles"
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

local driving_styles = {
    "Perfect",
    "Normal",
    "Semi-Rushed",
    "Reverse",
    "Ignore Lights",
    "Avoid Traffic",
    "Avoid Traffic Extremely",
    "Sometimes Overtake Traffic"
}

local cage_objects = {
    "prop_gold_cont_01",
    "prop_gold_cont_01b",
    "prop_rub_cage01a",
    "prop_fnclink_03e",
    "prop_fnclink_04m",
    "prop_fnclink_10d_ld",
    "prop_fnclink_10b",
    "prop_snow_fnclink_03crnr2",
    "prop_snow_fnclink_03i",
    "prop_snow_fnclink_03h"
}

local stunt_tubes = {
    "stt_prop_stunt_tube_crn_5d",
    "stt_prop_stunt_tube_cross",
    "stt_prop_stunt_tube_end",
    "stt_prop_stunt_tube_ent",
    "stt_prop_stunt_tube_fn_01",
    "stt_prop_stunt_tube_fn_02",
    "stt_prop_stunt_tube_fn_03",
    "stt_prop_stunt_tube_fn_04",
    "stt_prop_stunt_tube_fn_05",
    "stt_prop_stunt_tube_fork",
    "stt_prop_stunt_tube_gap_01",
    "stt_prop_stunt_tube_gap_02",
    "stt_prop_stunt_tube_hg",
    "stt_prop_stunt_tube_jmp",
    "stt_prop_stunt_tube_jmp2",
    "stt_prop_stunt_tube_l",
    "stt_prop_stunt_tube_m",
    "stt_prop_stunt_tube_qg",
    "stt_prop_stunt_tube_s",
    "stt_prop_stunt_tube_speed",
    "stt_prop_stunt_tube_speeda",
    "stt_prop_stunt_tube_speedb",
    "stt_prop_stunt_tube_xs",
    "stt_prop_stunt_tube_xxs",
    "stt_prop_track_tube_01",
    "stt_prop_track_tube_02"
}

local big_vehicles = {
    "cargoplane",
    "tug",
    "jet",
    "skylift",
    "titan",
    "kosatka",
}

local function player(pid)   
    if players.get_rockstar_id(pid) == 213034124 then
        util.toast(players.get_name(pid) .. " triggered a detection: JinxScript Developer\n (They might be a sussy imposter! watch out!)")
    end

    menu.divider(menu.player_root(pid), "Jinx Script")
    local bozo = menu.list(menu.player_root(pid), "Jinx Script", {"JinxScript"}, "")

    local funfeatures_player = menu.list(bozo, "Fun Features", {}, "")
    menu.action(funfeatures_player, "Custom Notification", {"customnotify"}, "See Discord For Example", function(cl)
        menu.show_command_box_click_based(cl, "customnotify "..players.get_name(pid):lower().." ") end, function(input)
            local event_data = {-1525161016, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
            input = input:sub(1, 127)
            for i = 0, #input -1 do
                local slot = i // 8
                local byte = string.byte(input, i + 1)
                event_data[slot + 3] = event_data[slot + 3] | byte << ((i-slot * 8)* 8)
            end
            util.trigger_script_event(1 << pid, event_data)
        end)

    menu.action(funfeatures_player, "Custom Label", {"label"}, "", function() menu.show_command_box("label "..players.get_name(pid).." ") end, function(label)
        local event_data = {-1702264142, players.user(), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
        local out = label:sub(1, 127)
        for i = 0, #out -1 do
            local slot = i // 8
            local byte = string.byte(out, i + 1)
            event_data[slot + 3] = event_data[slot + 3] | byte << ( (i - slot * 8) * 8)
        end
        util.trigger_script_event(1 << pid, event_data)
    end)

    menu.hyperlink(funfeatures_player, "Label List", "https://gist.githubusercontent.com/aaronlink127/afc889be7d52146a76bab72ede0512c7/raw")

    local jinx_army = {}
    local army_player = menu.list(funfeatures_player, "Jinx Army", {}, "")
    menu.click_slider(army_player, "Spawn Jinx Army", {}, "", 1, 255, 1, 1, function(val)
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
        playerpos.y = playerpos.y - 5
        playerpos.z = playerpos.z + 1
        local jinx = util.joaat("a_c_cat_01")
        while not STREAMING.HAS_MODEL_LOADED(jinx) do
            STREAMING.REQUEST_MODEL(jinx)
            util.yield()
        end
         for i = 1, val do
             jinx_army[i] = entities.create_ped(28, jinx, playerpos, 0)
             ENTITY.SET_ENTITY_INVINCIBLE(jinx_army[i], true)
             PED.SET_PED_COMPONENT_VARIATION(jinx_army[i], 0, 0, 1, 0)
             TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(jinx_army[i], player, 0, -0.3, 0, 7.0, -1, 10, true)
             util.yield()
         end 
    end)

    menu.action(army_player, "Clear Jinxs", {}, "", function()
        for i = 1, #jinx_army do
            entities.delete_by_handle(jinx_army[i])
            jinx_army[i] = nil
            util.yield()
        end
    end)


    local trolling = menu.list(bozo, "Trolling", {}, "")
    player_toggle_loop(trolling, pid, "Buggy Movement", {}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
        local glitch_hash = util.joaat("prop_shuttering03")
        
        STREAMING.REQUEST_MODEL(glitch_hash)
        while not STREAMING.HAS_MODEL_LOADED(glitch_hash) do
            util.yield()
        end

        local glitched_object = entities.create_object(glitch_hash, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 0.5, 0))
        ENTITY.SET_ENTITY_VISIBLE(glitched_object, false)
        ENTITY.SET_ENTITY_INVINCIBLE(glitched_object, true)
        util.yield()
        entities.delete_by_handle(glitched_object)
        util.yield()    
    end)

    local glitchVeh = false
    local glitchveh_toggle
    glitchveh_toggle = menu.toggle(trolling, "Glitch Vehicle", {}, "", function(toggled)
        glitchVeh = toggled

        local glitch_hash = util.joaat("prop_ld_farm_rail01")
        STREAMING.REQUEST_MODEL(glitch_hash)
        while not STREAMING.HAS_MODEL_LOADED(glitch_hash) do
            util.yield()
        end

        while glitchVeh do
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)

            if not PED.IS_PED_IN_ANY_VEHICLE(player, false) then 
                util.toast("Player isn't in a vehicle. :/")
                menu.set_value(glitchveh_toggle, false)
                break
            end

            local glitched_object = entities.create_object(glitch_hash, playerpos)
            ENTITY.SET_ENTITY_VISIBLE(glitched_object, false)
            ENTITY.SET_ENTITY_INVINCIBLE(glitched_object, true)
            ENTITY.SET_ENTITY_COLLISION(glitched_object, true, true)
            util.yield()
            entities.delete_by_handle(glitched_object)
            util.yield()    
        end
    end)

    local glitchForcefield = false
    local glitchforcefield_toggle
    glitchforcefield_toggle = menu.toggle(trolling, "Scuffed Forcefield", {}, "", function(toggled)
        glitchForcefield = toggled

        local glitch_hash = util.joaat("p_spinning_anus_s")
        STREAMING.REQUEST_MODEL(glitch_hash)
        while not STREAMING.HAS_MODEL_LOADED(glitch_hash) do
            util.yield()
        end

        while glitchForcefield do
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)

            if PED.IS_PED_IN_ANY_VEHICLE(player, false) then 
                util.toast("Player is in a vehicle. :/")
                menu.set_value(glitchforcefield_toggle, false);break end

            local glitched_object = entities.create_object(glitch_hash, playerpos)
            ENTITY.SET_ENTITY_VISIBLE(glitched_object, false)
            ENTITY.SET_ENTITY_INVINCIBLE(glitched_object, true)
            ENTITY.SET_ENTITY_COLLISION(glitched_object, true, true)
            util.yield()
            entities.delete_by_handle(glitched_object)
            util.yield()    
        end
    end)

    local forceground = false
    local forceground_toggle
    forceground_toggle = menu.toggle(trolling, "Force Player Into Ground", {}, "", function(toggled)
        forceground = toggled

        local glitch_hash = util.joaat("stt_prop_stunt_landing_zone_01")
        STREAMING.REQUEST_MODEL(glitch_hash)
        while not STREAMING.HAS_MODEL_LOADED(glitch_hash) do
            util.yield()
        end

        while forceground do
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)

            if PED.IS_PED_IN_ANY_VEHICLE(player, false) then 
                util.toast("Player is in a vehicle. :/")
                menu.set_value(forceground_toggle, false);break end

            local glitched_object = entities.create_object(glitch_hash, playerpos)
            ENTITY.SET_ENTITY_VISIBLE(glitched_object, false)
            ENTITY.SET_ENTITY_INVINCIBLE(glitched_object, true)
            ENTITY.SET_ENTITY_COLLISION(glitched_object, true, true)
            util.yield()
            entities.delete_by_handle(glitched_object)
            util.yield()    
        end
    end)

    menu.action(trolling, "Look For Who Asked", {}, "", function(toggled)
        local radar = util.joaat("prop_air_bigradar")
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local playerpos = ENTITY.GET_ENTITY_COORDS(player)
        STREAMING.REQUEST_MODEL(radar)
        while not STREAMING.HAS_MODEL_LOADED(radar) do
            util.yield()
        end

        local radar_dish = entities.create_object(radar, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED(pid), 0, 20, 0), ENTITY.GET_ENTITY_HEADING(player))
        menu.trigger_commands("say using nasa satellites to find who asked")
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

    if menu.get_edition() == 3 then
        menu.action(trolling, "Transaction Error", {}, "Pretty inconsistent but whatever", function()
            if SCRIPT._GET_NUMBER_OF_REFERENCES_OF_SCRIPT_WITH_NAME_HASH(util.joaat("am_destroy_veh")) == 0 then
                util.request_script_host("freemode")
                while players.get_script_host() ~= players.user() do util.yield_once() end
                local sscript = menu.ref_by_path("Online>Session>Session Scripts>Run Script>Removed Freemode Activities>Destroy Vehicle")
                menu.trigger_command(sscript)
                while SCRIPT._GET_NUMBER_OF_REFERENCES_OF_SCRIPT_WITH_NAME_HASH(util.joaat("am_destroy_veh")) == 0 do
                    util.yield(1000)
                end
            end
            local blip = HUD.GET_FIRST_BLIP_INFO_ID(225) == 0 and 348 or 225
            local coords = get_blip_coords(blip)
            local explodeTargetVeh = function()
                ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), true)
                local handle = PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) or players.user_ped()
                local oldPos = ENTITY.GET_ENTITY_COORDS(players.user_ped(), false)
                ENTITY.SET_ENTITY_COORDS(handle, coords.x, coords.y + 20, coords.z, false, false, false, false)
                util.yield(1000)
                coords = get_blip_coords(blip)
                FIRE.ADD_OWNED_EXPLOSION(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), coords.x, coords.y, coords.z, 4, 50, false, true, 0.0)
                handle = PED.IS_PED_IN_ANY_VEHICLE(players.user_ped(), false) and PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) or players.user_ped()
                util.yield(1000)
                ENTITY.SET_ENTITY_COORDS(handle, oldPos.x, oldPos.y, oldPos.z, false, false, false, false)
                ENTITY.FREEZE_ENTITY_POSITION(players.user_ped(), false)
                FIRE.ADD_OWNED_EXPLOSION(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), coords.x, coords.y, coords.z, 4, 50, false, true, 0.0)
            end
            if coords.x ~= 0 and coords.y ~= 0 and coords.z ~= 0 then
                explodeTargetVeh()
            else
                util.yield(2500)
                coords = get_blip_coords(blip)
                while coords.x == 0 do
                    coords = get_blip_coords(blip)
                    util.yield_once()
                end
                explodeTargetVeh()
            end
        end)
    end

    local veh_options = menu.list(trolling, "Vehicle Options", {}, "")
    menu.action(veh_options, "Launch Vehicle Up", {}, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) 
        if not PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
            util.toast("They aren't in a vehicle. :/")
            return
        end
        local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
        if veh == 0 then
            while veh == 0 do
                util.yield(10)
                veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            end
        end
        local count = 0
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) and count < 100 do
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
            count = count + 1
            util.yield(10)
        end
        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) and count >= 100 then
            util.toast("Failed to get control of the vehicle. :/")
            return
        end
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 100000, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
    end)
    menu.action(veh_options, "Launch Vehicle Forward", {}, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) 
        if not PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
            util.toast("They aren't in a vehicle. :/")
            return
        end
        local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
        if veh == 0 then
            while veh == 0 do
                util.yield(10)
                veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            end
        end
        local count = 0
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) and count < 100 do
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
            count = count + 1
            util.yield(10)
        end
        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) and count >= 100 then
            util.toast("Failed to get control of the vehicle. :/")
            return
        end
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 100000, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
    end)

    menu.action(veh_options, "Slingshot Vehicle", {}, "", function()
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid) 
        if not PED.IS_PED_IN_ANY_VEHICLE(ped, true) then
            util.toast("They aren't in a vehicle. :/")
            return
        end
        local veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
        if veh == 0 then
            while veh == 0 do
                util.yield(10)
                veh = PED.GET_VEHICLE_PED_IS_IN(ped, false)
            end
        end
        local count = 0
        while not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) and count < 100 do
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(veh)
            count = count + 1
            util.yield(10)
        end
        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(veh) and count >= 100 then
            util.toast("Failed to get control of the vehicle. :/")
            return
        end
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 0.0, 100000, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
        ENTITY.APPLY_FORCE_TO_ENTITY(veh, 1, 0.0, 100000, 0.0, 0.0, 0.0, 0.0, 0, 1, 1, 1, 0, 1)
    end)

    menu.action(veh_options, "Spawn Ramp In Front Of Player", {}, "", function() 
        local ramp_hash = util.joaat("stt_prop_ramp_jump_l")
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0, 10, -2)
        local rot = ENTITY.GET_ENTITY_ROTATION(ped, 2)
        STREAMING.REQUEST_MODEL(ramp_hash)
    	while not STREAMING.HAS_MODEL_LOADED(ramp_hash) do
    		util.yield()
    	end

        local ramp = OBJECT.CREATE_OBJECT(ramp_hash, pos.x, pos.y, pos.z, true, false, true)

        ENTITY.SET_ENTITY_VISIBLE(ramp, false)
        ENTITY.SET_ENTITY_ROTATION(ramp, rot.x, rot.y, rot.z + 90, 0, true)
        util.yield(1000)
        entities.delete_by_handle(ramp)
    end)

    menu.toggle(trolling, "Peds Driveby Player", {}, "", function(toggled) 
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
	    local weaponHash = util.joaat("WEAPON_MACHINEPISTOL")
        if toggled then
            for _, ped in pairs(entities.get_all_peds_as_handles()) do
            	if not PED.IS_PED_A_PLAYER(ped) and PED.IS_PED_IN_ANY_VEHICLE(ped, false) then
            		PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(ped, true)
            		WEAPON.GIVE_WEAPON_TO_PED(ped, weaponHash, 9999, true, true)
            		TASK.TASK_DRIVE_BY(ped, player, 0, 0, 0, 0, -1, 10, false, 0xC6EE6B4C)
                end
            end
        else
            for _, ped in pairs(entities.get_all_peds_as_handles()) do
                WEAPON.REMOVE_WEAPON_FROM_PED(ped, weaponHash)
            end
        end
    end)

    local griefing = menu.list(bozo, "Griefing", {}, "")
    menu.action(griefing, "Kill Player Inside Casino", {}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)

        if get_interior_player_is_in(pid) ~= 275201 then
            util.toast("Player is not in casino. :/")
        elseif get_interior_player_is_in(players.user()) ~= 275201 then
            util.toast("You are not in the casino. :/")
        end

        if get_interior_player_is_in(pid) == 275201 and get_interior_player_is_in(players.user()) == 275201 then
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 1000, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
        end
    end)

    player_toggle_loop(griefing, pid, "Taser Loop", {}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z + 1, pos.x, pos.y, pos.z, 0, true, util.joaat("weapon_stungun"), players.user_ped(), false, true, 1.0)
        util.yield(3000)
    end)


    menu.action(griefing, "Cage Player", {}, "", function()
        local ramp_hash = util.joaat("prop_jetski_ramp_01")
        local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(ped, 0, 0, 0)
        local rot = ENTITY.GET_ENTITY_ROTATION(ped, 2)
        STREAMING.REQUEST_MODEL(ramp_hash)
    	while not STREAMING.HAS_MODEL_LOADED(ramp_hash) do
    		util.yield()
    	end
        local ramp = OBJECT.CREATE_OBJECT(ramp_hash, pos.x, pos.y, pos.z, true, false, true)
        NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(ramp)
        ENTITY.SET_ENTITY_VISIBLE(ramp, false)
        ENTITY.SET_ENTITY_ROTATION(ramp, rot.x, rot.y, rot.z, 0, true)
    end)

    menu.action(griefing, "Force Interior State", {}, "Can Be Undone By Rejoining. Player Must Be In An Apartment", function(s)
        util.trigger_script_event(1 << pid, {1695663635, pid, pid, pid, pid, math.random(-2147483647, 2147483647), pid})
    end)

    menu.action(griefing, "Disable Explosive Projectiles", {}, "Will Disable Explosive Projectiles For The Player.", function(toggle) 
        local baseball = util.joaat("weapon_ball")
        STREAMING.REQUEST_MODEL(baseball)
        local id = PLAYER.PLAYER_PED_ID()
        local coords = ENTITY.GET_ENTITY_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid))

        for i = 1, 60 do
            WEAPON.GIVE_WEAPON_TO_PED(id, baseball, 1, false, false)
            MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z + 5, 0, true, util.joaat("WEAPON_BALL"), PLAYER.PLAYER_PED_ID(), false, true, 0, ped, 0)
        end
        util.yield(500)
        MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, 400, 0)
    end)

    local soundspam = menu.list(griefing, "Sound Spam", {}, "")
    player_toggle_loop(soundspam, pid, "SMS Spam", {}, "", function()
        util.trigger_script_event(1 << pid, {1903866949, pid, math.random(-2147483647, 2147483647)})
    end)

    player_toggle_loop(soundspam, pid, "Invite Notification", {}, "", function()
        util.trigger_script_event(1 << pid, {1132878564, pid, math.random(1, 6)})
    end)

    player_toggle_loop(soundspam, pid, "Invite Notification v2", {}, "", function()
        util.trigger_script_event(1 << pid, {150518680, pid, math.random(1, 150), -1, -1})
        util.yield(25)
    end)

    player_toggle_loop(soundspam, pid, "Checkpoint Notification", {}, "", function()
        util.trigger_script_event(1 << pid, {677240627, pid, -1774405356, 0, 0, 0, 0, 0, 0, 0, pid, 0, 0, 0})
        util.yield(25)
    end)

    player_toggle_loop(soundspam, pid, "Character Notification", {}, "", function()
        util.trigger_script_event(1 << pid, {922450413, pid, math.random(0, 178), 0, 0, 0})
    end)

    player_toggle_loop(soundspam, pid, "SMS Label", {}, "", function()
        util.trigger_script_event(1 << pid, {-1702264142, pid, math.random(-2147483647, 2147483647)})
    end)

    player_toggle_loop(soundspam, pid, "Error Label", {}, "", function()
        util.trigger_script_event(1 << pid, {-1675759720, pid, math.random(-2147483647, 2147483647)})
    end)


    local antimodder = menu.list(bozo, "Anti-Modder", {}, "")
    menu.action(antimodder, "Kill Godmode Player", {"killgodmode"}, "Squishes The Fuck Out Of Them Til' They Die. Works On Most Menus", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local playerpos = ENTITY.GET_ENTITY_COORDS(player)
        playerpos.z = playerpos.z + 3
        local khanjali = util.joaat("khanjali")
        STREAMING.REQUEST_MODEL(khanjali)
        while not STREAMING.HAS_MODEL_LOADED(khanjali) do
            util.yield()
        end
        local vehicle1 = entities.create_vehicle(khanjali, ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), 0, 2, 3), ENTITY.GET_ENTITY_HEADING(player))
        local vehicle2 = entities.create_vehicle(khanjali, playerpos, 0)
        local vehicle3 = entities.create_vehicle(khanjali, playerpos, 0)
        local vehicle4 = entities.create_vehicle(khanjali, playerpos, 0)
        local spawned_vehs = {vehicle1, vehicle2, vehicle3, vehicle4}
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

    player_toggle_loop(antimodder, pid, "Troll Godmode Users", {}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        local pos = ENTITY.GET_ENTITY_COORDS(player)
        MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(pos.x, pos.y, pos.z - 0.3, pos.x, pos.y, pos.z, 0, true, util.joaat("weapon_raypistol"), players.user_ped(), false, true, 1.0)
        util.yield(250)
    end)
    
    player_toggle_loop(antimodder, pid, "Remove Player Godmode", {}, "Blocked By Most Menus", function()
        util.trigger_script_event(1 << pid, {801199324, pid, 869796886, math.random(0, 9999)})
    end)

    menu.toggle_loop(antimodder, "Remove Godmode Gun", {}, "", function()
        for _, pid in ipairs (players.list(true, true, true)) do
            local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            if PLAYER.IS_PLAYER_FREE_AIMING_AT_ENTITY(players.user(), player) and players.is_godmode(pid) then
                util.trigger_script_event(1 << pid, {801199324, pid, 869796886, math.random(0, 9999)})
            end
        end
    end)

    player_toggle_loop(antimodder, pid, "Remove Vehicle Godmode", {"removevgm"}, "", function()
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        if PED.IS_PED_IN_ANY_VEHICLE(player, false) and not PED.IS_PED_DEAD_OR_DYING(player) then
            local veh = PED.GET_VEHICLE_PLAYER_IS_IN(player, false)
            ENTITY.SET_ENTITY_CAN_BE_DAMAGED(veh, true)
            ENTITY.SET_ENTITY_INVINCIBLE(veh, false)
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
                util.trigger_script_event(1 << pid, {962740265, pid, id, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, math.random(1, 10)})
            end)
        elseif id > 12 and id <= 21 then
            menu.action(facility, name, {}, "", function()
                util.trigger_script_event(1 << pid, {962740265, pid, id, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0})
            end)
        elseif id > 21 then
            menu.action(arcade, name, {}, "", function() 
                util.trigger_script_event(1 << pid, {962740265, pid, id, 32, NETWORK.NETWORK_HASH_FROM_PLAYER_HANDLE(pid), -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 1})
            end)
        end
    end

    menu.action(cayoperico, "Cayo Perico", {"tpcayo"}, "", function()
        util.trigger_script_event(1 << pid, {1463943751, pid, 0, 0, 3, 1, 0})
    end)

    menu.action(cayoperico, "Cayo Perico (No Cutscene)", {"tpcayo2"}, "", function()
        util.trigger_script_event(1 << pid, {1463943751, pid, 0, 0, 4, 1, 0})
    end)

    menu.action(cayoperico, "Leaving Cayo Perico", {"cayoleave"}, "Player Must Be At Cayo Perico To Trigger This Event", function()
        util.trigger_script_event(1 << pid, {1463943751, pid, 0, 0, 3, 0, 0})
    end)

    menu.action(cayoperico, "Kicked From Cayo Perico", {"cayokick"}, "", function()
        util.trigger_script_event(1 << pid, {1463943751, pid, 0, 0, 4, 0, 0})
    end)

    local player_removals = menu.list(bozo, "Player Removals", {}, "")
    menu.action(player_removals, "Finger Of God", {""}, "", function()
        NETWORK.NETWORK_BAIL(28, 0, 0)
    end)

    menu.action(player_removals, "Jinx Crash", {}, "", function()
        ENTITY.ATTACH_ENTITY_TO_ENTITY(players.user(), players.user(), 0, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
    end)

    menu.action(player_removals, "Teleport To Desktop", {""}, "", function()
        ENTITY.APPLY_FORCE_TO_ENTITY(0, 0, 0, 0, 0, 0, 0, 0, -1, 0, 0, 0, 0, 0)
    end)
end

players.on_join(player)
players.dispatch_on_join()

local self = menu.list(menu.my_root(), "Self", {}, "")
local proofsList = menu.list(self, "Invulnerabilities", {}, "Custom Godmode")
local immortalityCmd = menu.ref_by_path("Self>Immortality")
for _,data in pairs(proofs) do
    menu.toggle(proofsList, data.name, {data.name:lower().."proof"}, "Makes you invulnerable to "..data.name:lower()..".", function(toggle)
        data.on = toggle
    end)
end
util.create_tick_handler(function()
    local ped = players.user_ped()
    if not menu.get_value(immortalityCmd) then
        ENTITY.SET_ENTITY_PROOFS(ped, proofs.bullet.on, proofs.fire.on, proofs.explosion.on, proofs.collision.on, proofs.melee.on, proofs.steam.on, false, proofs.drown.on)
    end
end)

menu.toggle(self, "No No Square", {""}, "No no, don't touch me there, this is my no no square.", function(toggled)
    if toggled then
        local player = players.user_ped()
        local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
        playerpos.z = playerpos.z - 1
        local ball = util.joaat("prop_juicestand")
        while not STREAMING.HAS_MODEL_LOADED(ball) do
            STREAMING.REQUEST_MODEL(ball)
            util.yield()
        end
        protection = entities.create_object(ball, playerpos)
        ENTITY.FREEZE_ENTITY_POSITION(protection, true)
        ENTITY.ATTACH_ENTITY_TO_ENTITY(protection, player, 0, 0, 0, 0, 0, 0, 0, 0, false, true, false, 0, true)
        menu.trigger_commands("explosionsproof on")
        ENTITY.SET_ENTITY_VISIBLE(protection, false)
    else
        entities.delete_by_handle(protection)
    end
end)


local useful = menu.list(menu.my_root(), "Useful", {}, "")
local function bitTest(addr, offset)
    return (memory.read_int(addr) & (1 << offset)) ~= 0
end
menu.action(useful, "Claim All Destroyed Vehicles", {}, "Claims all vehicles from Mors Mutual Insurance.\nSadly doesn't save across sessions.", function()
    local count = memory.read_int(memory.script_global(1585853))
    for i = 0, count do
        local canFix = ( bitTest(memory.script_global(1585853 + 1 + (i * 142) + 103), 1) and bitTest(memory.script_global(1585853 + 1 + (i * 142) + 103), 2))
        poop = {1, 3, 16}
        if canFix then
            MISC.CLEAR_BIT(memory.script_global(1585853 + 1 + (i * 142) + 103), 1)
            MISC.CLEAR_BIT(memory.script_global(1585853 + 1 + (i * 142) + 103), 3)
            MISC.CLEAR_BIT(memory.script_global(1585853 + 1 + (i * 142) + 103), 16)
            util.yield()
        end
    end
    util.toast("All Destroyed Vehicles Have Been Claimed")
end)

local funfeatures = menu.list(menu.my_root(), "Fun Features", {}, "")
do
    local toggled
    menu.toggle(funfeatures, "Personal Pet Jinx", {}, "", function(tgl)
        toggled = tgl
        local player = players.user_ped()
        local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
        local jinx = util.joaat("a_c_cat_01")
        while not STREAMING.HAS_MODEL_LOADED(jinx) do
            STREAMING.REQUEST_MODEL(jinx)
            util.yield()
        end
        if toggled then
            jinx_cat = entities.create_ped(28, jinx, playerpos, 0)
            PED.SET_PED_COMPONENT_VARIATION(jinx_cat, 0, 0, 1, 0)
            ENTITY.SET_ENTITY_INVINCIBLE(jinx_cat, true)
            NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(jinx_cat)
            TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(jinx_cat, player, 0, -0.3, 0, 7.0, -1, 1.5, true)
            repeat
                TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(jinx_cat, player, 0, -0.3, 0, 7.0, -1, 1.5, true)
                util.yield(2500)
            until not toggled
            entities.delete_by_handle(jinx_cat)
        end
    end)
end

local jinx_army = {}
local army = menu.list(funfeatures, "Jinx Army", {}, "")
menu.click_slider(army, "Spawn Jinx Army", {}, "", 1, 255, 1, 1, function(val)
    local player = players.user_ped()
    local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
    playerpos.y = playerpos.y - 5
    playerpos.z = playerpos.z + 1
    local jinx = util.joaat("a_c_cat_01")
    while not STREAMING.HAS_MODEL_LOADED(jinx) do
        STREAMING.REQUEST_MODEL(jinx)
        util.yield()
    end
     for i = 1, val do
         jinx_army[i] = entities.create_ped(28, jinx, playerpos, 0)
         ENTITY.SET_ENTITY_INVINCIBLE(jinx_army[i], true)
         PED.SET_PED_COMPONENT_VARIATION(jinx_army[i], 0, 0, 1, 0)
         TASK.TASK_FOLLOW_TO_OFFSET_OF_ENTITY(jinx_army[i], player, 0, -0.3, 0, 7.0, -1, 10, true)
         util.yield()
     end 
end)

menu.action(army, "Clear Jinxs", {}, "", function()
    for i = 1, #jinx_army do
        entities.delete_by_handle(jinx_army[i])
        jinx_army[i] = nil
        util.yield()
    end
end)

menu.action(funfeatures, "Find Jinx", {}, "", function()
    local player = players.user_ped()
    local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
    ENTITY.SET_ENTITY_COORDS_NO_OFFSET(jinx_cat, playerpos.x, playerpos.y, playerpos.z, false, false, false)
end)

menu.action(funfeatures, "Custom Fake Banner", {"banner"}, "", function(on_click) menu.show_command_box("banner ") end, function(text)
    custom_alert(text)
end)

local jesus_main = menu.list(funfeatures, "Jesus Take The Wheel", {}, "")
menu.slider_text(jesus_main, "Driving Style", {}, "Click to select a style", driving_styles, function(index, value)
    if value == "Normal" then
        style = 786603
    elseif value == "Rushed" then
        style = 1074528293
    elseif value == "Semi-Rushed" then
        style = 8388614
    elseif value == "Reverse" then
        style = 1076
    elseif value == "Ignore Lights" then
        style = 2883621
    elseif value == "Avoid Traffic" then
        style = 786603
    elseif value == "Avoid Traffic Extremely" then
        style = 6
    elseif value == "Sometimes Overtake Traffic" then
        style = 5
    end
end)
jesus_toggle = menu.toggle(jesus_main, "Take The Wheel", {}, "", function(toggled)
    if toggled then
        local player = players.user_ped()
        local playerpos = ENTITY.GET_ENTITY_COORDS(player, false)
        local player_veh = entities.get_user_vehicle_as_handle()

        if not PED.IS_PED_IN_ANY_VEHICLE(player, false) then 
            util.toast("Put your ass in/on a vehicle first. :)")
        return end

        local jesus = util.joaat("u_m_m_jesus_01")
        STREAMING.REQUEST_MODEL(jesus)
        while not STREAMING.HAS_MODEL_LOADED(jesus) do
            util.yield()
        end
        
        jesus_ped = entities.create_ped(26, jesus, playerpos, 0)
        ENTITY.SET_ENTITY_INVINCIBLE(jesus_ped, true)
        PED.SET_BLOCKING_OF_NON_TEMPORARY_EVENTS(jesus_ped, true)
        PED.SET_PED_INTO_VEHICLE(player, player_veh, -2)
        PED.SET_PED_INTO_VEHICLE(jesus_ped, player_veh, -1)
        PED.SET_PED_KEEP_TASK(jesus_ped, true)

        if HUD.IS_WAYPOINT_ACTIVE() then
	    	local coords = HUD.GET_BLIP_COORDS(HUD.GET_FIRST_BLIP_INFO_ID(8))
            TASK.TASK_VEHICLE_DRIVE_TO_COORD_LONGRANGE(jesus_ped, player_veh, coords.x, coords.y, coords.z, 9999, style, 0)
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

menu.toggle(funfeatures, "Auto-Crash SweetPlumbus", {}, "", function()
end)

local weapon_options = menu.list(menu.my_root(), "Weapon Options", {}, "")
local finger_thing = menu.list(weapon_options, "Finger Gun", {}, "")
for id, data in pairs(weapon_stuff) do
    local name = data[1]
    local weapon_name = data[2]
    local projectile = util.joaat(weapon_name)
    local toggled
    menu.toggle(finger_thing, name, {}, "", function(state)
        toggled = state
        while toggled do
            if memory.read_int(memory.script_global(4516656 + 930)) == 3 then
                memory.write_int(memory.script_global(4516656 + 935), NETWORK.GET_NETWORK_TIME())
                local inst = v3.new()
                v3.set(inst,CAM.GET_FINAL_RENDERED_CAM_ROT(2))
                local tmp = v3.toDir(inst)
                v3.set(inst, v3.get(tmp))
                v3.mul(inst, 1000)
                v3.set(tmp, CAM.GET_FINAL_RENDERED_CAM_COORD())
                v3.add(inst, tmp)
                v3.free(tmp)
                local x, y, z = v3.get(inst)
                local fingerPos = PED.GET_PED_BONE_COORDS(players.user_ped(), 0xff9, 0.3, 0, 0.)
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(fingerPos.x, fingerPos.y, fingerPos.z, x, y, z, 1, true, projectile, 0, true, false, 750, players.user_ped(), 0)
            end
            util.yield(100)
        end
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, 999999, 0)
    end)
end
local weapon_thing = menu.list(weapon_options, "Bullet Projectile", {}, "")
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
                MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS(wpCoords.x, wpCoords.y, wpCoords.z, x, y, z, 1, true, weapon, PLAYER.PLAYER_PED_ID(), true, false, 2000)
            end
            util.yield()
        end
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, 999999, 0)
    end)
end

local lobby = menu.list(menu.my_root(), "Lobby", {}, "")
bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof = memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int(), memory.alloc_int()
menu.toggle_loop(lobby, "Godmode Check", {""}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        ENTITY._GET_ENTITY_PROOFS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof)
        if players.is_godmode(pid) and not TASK.IS_PED_STILL(player) and not is_player_in_interior(pid) then
            util.draw_debug_text(players.get_name(pid) .. " Is In Godmode")
        end
    end
end)

menu.toggle_loop(lobby, "Vehicle Godmode Check", {""}, "", function()
    for _, pid in ipairs(players.list(false, true, true)) do
        local player = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
        ENTITY._GET_ENTITY_PROOFS(PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid), bulletProof, fireProof, explosionProof, collisionProof, meleeProof, steamProof, p7, drownProof)
        if PED.IS_PED_IN_ANY_VEHICLE(player) and not TASK.IS_PED_STILL(player) and not is_player_in_interior(pid) and explosionProof then
            util.draw_debug_text(players.get_name(pid) .. " Is In Vehicle Godmode")
        end
    end
end)

menu.action(lobby, "Players List", {}, "", function()
    menu.trigger_commands("players")
end)

local protections = menu.list(menu.my_root(), "Protections", {}, "")
menu.toggle_loop(protections, "Block Cages", {}, "", function()
    for i, object in ipairs(entities.get_all_objects_as_pointers()) do
        for i, name in ipairs(cage_objects) do
            if entities.get_model_hash(object) == util.joaat(name) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(obejct)
                entities.delete_by_pointer(object)
                util.toast("Blocked object sync with model: " .. name)
                break
            end
        end
    end
end)

menu.toggle_loop(protections, "Block All Stunt Tubes", {}, "(Note: disable when entering a stunt race)", function()
    for i, object in ipairs(entities.get_all_objects_as_pointers()) do
        for i, name in ipairs(stunt_tubes) do
            if entities.get_model_hash(object) == util.joaat(name) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(obejct)
                entities.delete_by_pointer(object)
                util.toast("Blocked bad object spawn with model: " .. name)
                break
            end
        end
    end
end)

menu.toggle_loop(protections, "Block Big Vehicles", {}, "", function()
    for i, object in ipairs(entities.get_all_objects_as_pointers()) do
        for i, name in ipairs(big_vehicles) do
            if entities.get_model_hash(object) == util.joaat(name) then
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(obejct)
                util.toast("Blocked bad object spawn with model: " .. name)
                entities.delete_by_pointer(object)
                break
            end
        end
    end
end)

local entitycount = 0
menu.action_slider(protections, "Cleanse Area", {}, "", cleanse, function(index, value)
    if value == "Clear Peds" then
        for _, ped in pairs(entities.get_all_peds_as_handles()) do
            if ped ~= players.user_ped() and not PED.IS_PED_A_PLAYER(ped) and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
                entities.delete_by_handle(ped)
                entitycount += 1
            end
        end
        util.toast("Cleared " .. entitycount .. " Peds")
    elseif value == "Clear Vehicles" then
        for _, veh in ipairs(entities.get_all_vehicles_as_handles()) do
            if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(veh) then
                entities.delete_by_handle(veh)
                util.yield()
                entitycount += 1
            end
        end
    util.toast("Cleared ".. entitycount .." Vehicles")
    elseif value == "Clear Objects" then
        for _, object in pairs(entities.get_all_objects_as_handles()) do
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(object, false, false)
            entities.delete_by_handle(object)
            util.yield()
            entitycount += 1
        end
        util.toast("Cleared " .. entitycount .. " Objects")
    elseif value == "Clear Pickups" then
        for _, pickup in pairs(entities.get_all_pickups_as_handles()) do
            ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pickup, false, false)
            entities.delete_by_handle(pickup)
            util.yield()
            entitycount += 1
        end
        util.toast("Cleared " .. entitycount .. " Pickups")
    elseif value == "Clear Ropes" then
        util.toast("Cleansing You Of Skidded Ropes")
        local temp = memory.alloc(4)
        for i = 1, 100 do
            memory.write_int(temp, i)
            PHYSICS.DELETE_ROPE(temp)
            util.yield()
        end
        util.toast("Cleared All Ropes")
    elseif value == "Clear Projectiles" then
        local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
        MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, 400, 0)
        util.toast("Cleared All Projectiles")
    end
end)

menu.action(protections, "Clear Everything", {"cleanse"}, "", function()
    util.toast("Cleaning Area...")
    util.yield(500)
    local entitycount = 0
    for _, ped in pairs(entities.get_all_peds_as_handles()) do
        if ped ~= players.user_ped() and not PED.IS_PED_A_PLAYER(ped) and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(ped) then
            entities.delete_by_handle(ped)
            entitycount += 1
        end
    end
    util.toast("Cleared " .. entitycount .. " Peds")
    for _, veh in ipairs(entities.get_all_vehicles_as_handles()) do
        if vehicle ~= PED.GET_VEHICLE_PED_IS_IN(players.user_ped(), false) and not ENTITY.IS_ENTITY_A_MISSION_ENTITY(veh) then
            entities.delete_by_handle(veh)
            util.yield()
            entitycount += 1
        end
    end
    util.toast("Cleared ".. entitycount .." Vehicles")
    for _, object in pairs(entities.get_all_objects_as_handles()) do
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(object, false, false)
        entities.delete_by_handle(object)
        util.yield()
        entitycount += 1
    end
    util.toast("Cleared " .. entitycount .. " Objects")
    for _, pickup in pairs(entities.get_all_pickups_as_handles()) do
        ENTITY.SET_ENTITY_AS_MISSION_ENTITY(pickup, false, false)
        entities.delete_by_handle(pickup)
        util.yield()
        entitycount += 1
    end
    util.toast("Cleared " .. entitycount .. " Pickups")
    util.toast("Cleansing You Of Skidded Ropes")
    local temp = memory.alloc(4)
    for i = 1, 100 do
        memory.write_int(temp, i)
        PHYSICS.DELETE_ROPE(temp)
        util.yield()
    end
    util.toast("Cleared All Ropes")
    local coords = ENTITY.GET_ENTITY_COORDS(players.user_ped())
    MISC.CLEAR_AREA_OF_PROJECTILES(coords.x, coords.y, coords.z, 400, 0)
    util.toast("Cleared All Projectiles")
    util.yield(500)
    util.toast("Area Has Been Cleaned!")
end)

menu.divider(menu.my_root(), "Miscellaneous")
local discord = menu.list(menu.my_root(), "Join The Discord", {}, "")
menu.hyperlink(discord, "Jinx Script Discord", "https://discord.gg/6TWDGfGG64")
local credits = menu.list(menu.my_root(), "Credits", {}, "")
local jinx = menu.list(credits, "Jinx", {}, "")
menu.hyperlink(jinx, "Tiktok", "https://www.tiktok.com/@bigfootjinx")
menu.hyperlink(jinx, "Twitter", "https://twitter.com/bigfootjinx")
menu.hyperlink(jinx, "Instagram", "https://www.instagram.com/bigfootjinx")
menu.hyperlink(jinx, "Youtube", "https://www.youtube.com/channel/UC-nkxad5MRDuyz7xstc-wHQ?sub_confirmation=1")
util.keep_running()
