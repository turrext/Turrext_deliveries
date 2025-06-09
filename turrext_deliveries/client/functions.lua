local PedBlip = nil
local nearShipment = false
local attemptingShipment = false
if Config.Framework == "ESX" then
    ESX = exports['es_extended']:getSharedObject()
end
if Config.Framework == "QB" then
    QBCore = exports['qb-core']:GetCoreObject()
end
function ClSyncShipments(shipmenttable)
    for i, shipment in pairs(shipmenttable) do

        local exists = false
        local loclshipment = nil
        for i, lshipment in pairs(Shipments) do
            if lshipment.id == shipment.id then
                exists = true
                loclshipment = lshipment
                if exists and loclshipment ~= nil then
                    if loclshipment.status ~= shipment.status then
                        if shipment.status ~= "dropped" then
                            print("Shipment Status Changed")
                            table.remove(Shipments, i)
                        end
                        loclshipment.status = shipment.status
                    end
                end
            end
        end
        if shipment.status == "dropped" then
            local shipmentlocid = NetworkGetEntityFromNetworkId(shipment.netent)
            if not IsEntityVisible(shipmentlocid) then
                print("Entity Was Invisible")
                print("Entity Was Invisible")
                print("Entity Was Invisible")
                Wait(6000)
                SetEntityVisible(shipmentlocid, true, false)

            end

            if shipment.expired == false and shipmentlocid ~= 0 and not exists then
                -- Check if shipment already exists locally
                local exists1 = false
                for i, dshipment in pairs(Shipments) do
                    if dshipment.id == shipment.id then
                        exists1 = true
                    end
                end
                if exists1 == false then
                    local shipment = {
                        id = shipment.id,
                        netent = shipment.netent,
                        status = shipment.status,
                        localent = shipmentlocid
                    }
                    print("shipment Added", shipment, shipment.id, shipment.netent, shipment.status, shipment.localent)
                    local coordsx = GetEntityCoords(shipmentlocid)
                    AddBlip(vector3(coordsx.x, coordsx.y, coordsx.z), 130, "Shipment", true, shipment.id, false)
                    table.insert(Shipments, shipment)
                end
            end
        end


    end

end
function ClSyncPeds(pedtable)
    for i, ped in ipairs(pedtable) do
        if ped.Status == "active" then
            -- check if peds is empty
            if CheckIfTableEmpty(Peds) == false then
                local exists = false
                for i, lped in pairs(Peds) do
                    if lped.NetPed == ped.Ped then
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        local dist = GetDistanceBetweenCoords(ped.PedInfo.Pos.x,ped.PedInfo.Pos.y,ped.PedInfo.Pos.z,playerCoords.x,playerCoords.y,playerCoords.z, true)
                        if dist <= Config.RenderDistance then
                            exists = true
                            --  Confirm PEDID CORRECT AFTER NEW PED IS SPAWNED
                            if DoesEntityExist(lped.Ped) == false then
                                local locID = NetworkGetEntityFromNetworkId(lped.NetPed)
                                print("locid", locID)
                                print(lped.NetPed)
                                if locID ~= nil or locID ~= 0 then
                                    if DoesEntityExist(locID) then
                                        lped.Ped = locID
                                        print("LOCID Updated x1")
                                    end
                                else
                                    if NetworkDoesEntityExistWithNetworkId(lped.NetPed) == 1 then
                                        local localpedid = 0
                                        local x=0
                                        while x < 5 do
                                            print("Waiting for ped to spawn 3")
                                            localpedid = NetworkGetEntityFromNetworkId(ped.Ped)
                                            if localpedid == 0 then
                                                Wait(100)
                                                x = x + 1
                                            else
                                                print("localpedid",localpedid)
                                                break
                                            end
                                         end
                                        if localpedid ~= 0 then
                                            lped.Ped = localpedid
                                            print("LOCID Updated x2")
                                        end
                                    end
                                    --print("DoesEntityExist", DoesEntityExist(NetworkGetEntityFromNetworkId(lped.NetPed)))
                                end
                            end
                            if ped.PedInfo.Actions.IgnoreEvents == true then
                                SetBlockingOfNonTemporaryEvents(lped.Ped, true)
                            end
                            if ped.PedInfo.Actions.FreezePed then
                                FreezeEntityPosition(lped.Ped,true)
                            end
                            if ped.PedInfo.Actions.Invincible == true then
                                SetEntityInvincible(lped.Ped, true)
                            end

                            if ped.PedInfo.Actions.Wandering == true then
                                local zonelm1 
                                for ee, zonecl1 in ipairs(Config.Zones) do
                                    for _, pedcl1 in ipairs(zonecl1.Peds.SpawnCoords) do
                                        if pedcl1.Pos.x == ped.PedInfo.Pos.x and pedcl1.Pos.y == ped.PedInfo.Pos.y and pedcl1.Pos.z == ped.PedInfo.Pos.z then
                                            zonelm1 = zonecl1
                                        end
                                    end

                                end
                                if zonelm1 ~= nil then
                                    SetBlockingOfNonTemporaryEvents(lped.Ped, true)
                                    TaskWanderInArea(lped.Ped, zonelm1.Blip.Pos.x+0.0,zonelm1.Blip.Pos.y+0.0,zonelm1.Blip.Pos.z+0.0, zonelm1.Radius - 2.0, Config.GlobalWanderDist, 5000)
                                end
                            end
                            if Config.ShowPedLoc == true then
                                if PedBlip ~= nil then
                                    RemoveBlip(PedBlip)
                                end
                                
                                PedBlip = AddBlip(GetEntityCoords(lped.Ped), 133, "Delivery Plug", false, nil, true)

                            end
                        end
                    end

                end
                if exists == false then
                    local playerCoords = GetEntityCoords(PlayerPedId())
                    local dist = GetDistanceBetweenCoords(ped.PedInfo.Pos.x,ped.PedInfo.Pos.y,ped.PedInfo.Pos.z,playerCoords.x,playerCoords.y,playerCoords.z, true)
                    if dist <= Config.RenderDistance then
                        local localpedid = ConfirmPedSpawnCl(ped.Ped, ped)
                        if localpedid ~= 0 then
                            local myPed = {
                                Ped = localpedid,
                                NetPed = ped.Ped,
                                Approach = ped.PedInfo.Actions.ApproachPlayer
                            }

                            table.insert(Peds, myPed)
                        end
                    end
                end
            else

                
                local localpedid = ConfirmPedSpawnCl(ped.Ped, ped)
                if localpedid ~= 0 then
                    local myPed = {
                        Ped = localpedid,
                        NetPed = ped.Ped,
                        Approach = ped.PedInfo.Actions.ApproachPlayer
                    }

                    table.insert(Peds, myPed)
                end
            end

        end
    end
end

function ConfirmPedSpawnCl(netid, table)
    local localpedid = 0
    local x=0
    while x < 5 do
        print("Waiting for ped to spawn 2")
        localpedid = NetworkGetEntityFromNetworkId(netid)
        if localpedid == 0 then
            Wait(100)
            x = x + 1
        else
            print("localpedid",localpedid)
            break
        end
    end
    return localpedid


end
function ClBlipFunc()   
    for _, Zone in ipairs(Config.Zones) do
        local exists = false

        for _, blipEntry in ipairs(Blips) do
            if blipEntry.zone ~= nil then
                if blipEntry.blipId == Zone.Id then
                    exists = true
                    break
                end
            end
        end

        if not exists then
            -- The blip with blipId matching Zone.Id does not exist
            if Zone.Blip.Showblip then
                AddBlipWithRadius(Zone)
                if Config.Debug then
                    print("Added blip with blipId " .. Zone.Id .. " and displayed radius")
                end
            else
                local myBlip = {
                    blipId = Zone.Id,
                    zone = Zone,
                    blip = nil,
                    blip2 = nil,
                    inZone = false
                }
                table.insert(Blips, myBlip)
            end
        end
    end
end

function ClUpdateZone(action, data)
    if action == "enteredzone" then
        for _, blipEntry in ipairs(Blips) do
            if blipEntry.zone ~= nil then
                if blipEntry.blipId == data.blipId then
                    blipEntry.inZone = true
                    if Config.Debug then
                        print("Entered zone: " .. data.blipId)
                    end
                end
            end
        end
    end
    if action == "exitedzone" then
        for _, blipEntry in ipairs(Blips) do
            if blipEntry.zone ~= nil then
                if blipEntry.blipId == data.blipId then
                    blipEntry.inZone = false
                    if Config.Debug then
                        print("Exited zone: " .. data.blipId)
                    end
                end
            end
        end
    end
end



function CrateDrop(id, planeSpawnDistance, dropCoords)
    if attemptingShipment == false then
        attemptingShipment = true
        local finalcoords = dropCoords
        Citizen.CreateThread(function()
            parachuteModel = "p_cargo_chute_s"
            requiredModels = {parachuteModel, "ex_prop_adv_case_sm", "cuban800", "titan", "s_m_m_pilot_02", "prop_drop_crate_01_set2"} -- parachute, pickup case, plane, pilot, crate
            local pedcoord = GetEntityCoords(PlayerPedId())
            for i = 1, #requiredModels do
                RequestModel(GetHashKey(requiredModels[i]))
                while not HasModelLoaded(GetHashKey(requiredModels[i])) do
                    Wait(0)
                end
            end

            RequestWeaponAsset(GetHashKey("weapon_flare")) -- flare won't spawn later in the script if we don't request it right now
            while not HasWeaponAssetLoaded(GetHashKey("weapon_flare")) do
                Wait(0)
            end

            local rHeading = math.random(0, 360) + 0.0
            local planeSpawnDistance = (planeSpawnDistance and tonumber(planeSpawnDistance) + 0.0) or 250.0 -- this defines how far away the plane is spawned
            local theta = (rHeading / 180.0) * 3.14
            local rPlaneSpawn = vector3(dropCoords.x, dropCoords.y, dropCoords.z) - vector3(math.cos(theta) * planeSpawnDistance, math.sin(theta) * planeSpawnDistance,-70.0) -- the plane is spawned at
            local wrongx = 0
            while GetDistanceBetweenCoords(pedcoord.x, pedcoord.y, pedcoord.z, rPlaneSpawn.x, rPlaneSpawn.y, rPlaneSpawn.z, true) >= 350 do
                rPlaneSpawn = vector3(dropCoords.x, dropCoords.y, dropCoords.z) - vector3(math.cos(theta) * planeSpawnDistance, math.sin(theta) * planeSpawnDistance,-70.0)
                pedcoord = GetEntityCoords(PlayerPedId())
                print("Plane Coords Wrong")
                wrongx = wrongx + 1
                Wait(100)
                if wrongx > 70 then
                    attemptingShipment = false
                    do return end
                    break
                end
            end
            if Config.Debug then
                print(("PLANE COORDS: X = %.4f; Y = %.4f; Z = %.4f"):format(rPlaneSpawn.x, rPlaneSpawn.y, rPlaneSpawn.z))
                print("PLANE SPAWN DISTANCE: " .. #(vector2(rPlaneSpawn.x, rPlaneSpawn.y) - vector2(dropCoords.x, dropCoords.y)))
            end

            local dx = dropCoords.x - rPlaneSpawn.x
            local dy = dropCoords.y - rPlaneSpawn.y
            local heading = GetHeadingFromVector_2d(dx, dy) -- determine plane heading from coordinates



            local crateSpawn = vector3(dropCoords.x, dropCoords.y, dropCoords.z + 80.0) -- crate will drop to the exact position as planned, not at the plane's current position
            print(rPlaneSpawn)
            TriggerServerEvent("turrext_deliveries:setupCrates", id, crateSpawn, planeSpawnDistance, heading, rPlaneSpawn, finalcoords, dropCoords)
        end)
    end
end

RegisterNetEvent("turrext_deliveries:finalizecrate", function(callbackobj, id, crateSpawn, heading, rPlaneSpawn, finalcoords, dropCoords)
                parachuteModel = "p_cargo_chute_s"
                requiredModels = {parachuteModel, "ex_prop_adv_case_sm", "cuban800", "titan", "s_m_m_pilot_02", "prop_drop_crate_01_set2"} -- parachute, pickup case, plane, pilot, crate
                local pedcoord = GetEntityCoords(PlayerPedId())
                for i = 1, #requiredModels do
                    RequestModel(GetHashKey(requiredModels[i]))
                    while not HasModelLoaded(GetHashKey(requiredModels[i])) do
                        Wait(0)
                    end
                end
                print("callbackobj IS NOT NIL", callbackobj)
                print("callbackobj IS NOT NIL", callbackobj)
                print("callbackobj IS NOT NIL", callbackobj)
                print("callbackobj IS NOT NIL", callbackobj)
                crate = NetToObj(callbackobj)
                if not DoesEntityExist(crate) or crate == 0 then
                    if Config.Debug then
                        print("DNE Crate")
                        print("DNE Crate")
                        print("DNE Crate")
                        print("DNE Crate")
                        print("DNE Crate")
                    end
                    TriggerServerEvent("turrext_deliveries:removeShipment", id)
                    attemptingShipment = false
                    do return end
                end
                print(rPlaneSpawn, heading)
                aircraft = CreateVehicle(GetHashKey("titan"), rPlaneSpawn, heading, true, true)
                SetEntityHeading(aircraft, heading)
                SetVehicleDoorsLocked(aircraft, 2) -- lock the doors so pirates don't get in
                SetEntityDynamic(aircraft, true)
                ActivatePhysics(aircraft)
                SetVehicleForwardSpeed(aircraft, 60.0)
                SetHeliBladesFullSpeed(aircraft) -- works for planes I guess
                SetVehicleEngineOn(aircraft, true, true, false)
                ControlLandingGear(aircraft, 3) -- retract the landing gear
                OpenBombBayDoors(aircraft) -- opens the hatch below the plane for added realism
                SetEntityProofs(aircraft, true, false, true, false, false, false, false, false)
                print(DoesEntityExist(aircraft))
                print(DoesEntityExist(crate))
                if crate == 0 or crate == nil then
                    print("CRATE IS NIL")
                    TriggerServerEvent("turrext_deliveries:removeShipment", id)
                    attemptingShipment = false
                    do return end
                end
                pilot = CreatePedInsideVehicle(aircraft, 1, GetHashKey("s_m_m_pilot_02"), -1, true, true)
                SetBlockingOfNonTemporaryEvents(pilot, true) -- ignore explosions and other shocking events
                SetPedRandomComponentVariation(pilot, false)
                SetPedKeepTask(pilot, true)
                SetPlaneMinHeightAboveTerrain(aircraft, 50) -- the plane shouldn't dip below the defined altitude
            
                TaskVehicleDriveToCoord(pilot, aircraft, vector3(dropCoords.x, dropCoords.y, dropCoords.z) + vector3(0.0, 0.0, 100.0), 40.0, 0, GetHashKey("cuban800"), 262144, 15.0, true) -- to the dropsite, could be replaced with a task sequence
            
                local droparea = vector2(dropCoords.x, dropCoords.y)
                local planeLocation = vector2(GetEntityCoords(aircraft).x, GetEntityCoords(aircraft).y)
                while not IsEntityDead(pilot) and #(planeLocation - droparea) > 5.0 do -- wait for when the plane reaches the dropCoords ± 5 units
                    Wait(100)
                    planeLocation = vector2(GetEntityCoords(aircraft).x, GetEntityCoords(aircraft).y) -- update plane coords for the loop
                end
            
                --[[if IsEntityDead(pilot) then -- I think this will end the script if the pilot dies, no idea how return works
                    print("PILOT: dead")
                    TriggerServerEvent("turrext_deliveries:removeShipment", id)
                    attemptingShipment = false
                    do return end
                end]]--
                if Config.Debug then
                    print("PILOT: alive")
                end
                TaskVehicleDriveToCoord(pilot, aircraft, 0.0, 0.0, 70.0, 120.0, 0, GetHashKey("cuban800"), 262144, -1.0, -1.0) -- disposing of the plane like Rockstar does, send it to 0; 0 coords with -1.0 stop range, so the plane won't be able to achieve its task
                SetEntityAsNoLongerNeeded(pilot)
                SetEntityAsNoLongerNeeded(aircraft)
                -- https://docs.esx-framework.org/legacy/Client/functions/triggerservercallback
                SetEntityVisible(crate, true, false)
                SetEntityLodDist(crate, 1000) -- so we can see it from the distance
                --ActivatePhysics(crate)
                --SetDamping(crate, 2, 0.1) -- no idea but Rockstar uses it
                SetEntityVelocity(crate, 0.0, 0.0, -0.05) -- I think this makes the crate drop down, not sure if it's needed as many times in the script as I'm using
                SetEntityInvincible(crate, true)
                if GetEntityCoords(crate) == vec3(0.0, 0.0, 0.0) then
                    print("Crate: 0.0, 0.0, 0.0")
                    TriggerServerEvent("turrext_deliveries:removeShipment", id)
                    attemptingShipment = false
                    do return end
                end
                crateSpawn = vector3(crateSpawn.x, crateSpawn.y, crateSpawn.z + 5.0)
                SetEntityCoords(crate, crateSpawn, true, true, true, true)
                FreezeEntityPosition(crate, true)
                if GetEntityCoords(crate) == vec3(0.0, 0.0, 0.0) then
                    print("Crate: 0.0, 0.0, 0.0")
                    TriggerServerEvent("turrext_deliveries:removeShipment", id)
                    attemptingShipment = false
                    do return end
                end

                parachute = CreateObject(GetHashKey(parachuteModel), crateSpawn, true, true, true) -- create the parachute for the crate, location isn't too important as it'll be later attached properly
                SetEntityLodDist(parachute, 1000)
                SetEntityVelocity(parachute, 0.0, 0.0, -0.05)
                if Config.Debug then
                    print("PARACHUTE: created", parachute)
                    print("PARACHUTE: spawned", parachute)
                end
                -- PlayEntityAnim(parachute, "P_cargo_chute_S_deploy", "P_cargo_chute_S", 1000.0, false, false, false, 0, 0)
                -- ForceEntityAiAndAnimationUpdate(parachute)



                soundID = GetSoundId() -- we need a sound ID for calling the native below, otherwise we won't be able to stop the sound later

                -- local crateBeacon = StartParticleFxLoopedOnEntity_2("scr_crate_drop_beacon", pickup, 0.0, 0.0, 0.2, 0.0, 0.0, 0.0, 1065353216, 0, 0, 0, 1065353216, 1065353216, 1065353216, 0)--1.0, false, false, false)
                -- SetParticleFxLoopedColour(crateBeacon, 0.8, 0.18, 0.19, false)

                FreezeEntityPosition(crate, false)
                if Config.Debug then
                    print("Crate: spawned")
                end

                local parachuteCoords = vector3(GetEntityCoords(parachute)) -- we get the parachute dropCoords so we know where to drop the flare
                ShootSingleBulletBetweenCoords(parachuteCoords, parachuteCoords - vector3(0.0001, 0.0001, 0.0001), 0, false, GetHashKey("weapon_flare"), 0, true, false, -1.0) -- flare needs to be dropped with dropCoords like that, otherwise it remains static and won't remove itself later
                DetachEntity(parachute, true, true)
                -- SetEntityCollision(parachute, false, true) pointless right now but would be cool if animations would work and you'll be able to walk through the parachute while it's disappearing
                -- PlayEntityAnim(parachute, "P_cargo_chute_S_crumple", "P_cargo_chute_S", 1000.0, false, false, false, 0, 0)
                local prop = 0



                StopSound(soundID) -- stop the crate beeping sound
                ReleaseSoundId(soundID) -- won't need this sound ID any longer
                if Config.Debug then
                    print("Crate: broken")
                end
                local dist = GetDistanceBetweenCoords(GetEntityCoords(crate), vector3(finalcoords.x, finalcoords.y, finalcoords.z), true)
                while dist > 5.0 do 
                    dist = GetDistanceBetweenCoords(GetEntityCoords(crate), vector3(finalcoords.x, finalcoords.y, finalcoords.z), true)
                    if Config.Debug then
                        print("Crate: dist", dist, GetEntityCoords(crate), crate, DoesEntityExist(crate), GetEntityCoords(crate) == vec3(0.0, 0.0, 0.0))

                    end
                    Wait(100)
                end
                DeleteEntity(parachute)
                Wait(15000)
                attemptingShipment = false
                for i = 1, #requiredModels do
                    Wait(0)
                    SetModelAsNoLongerNeeded(GetHashKey(requiredModels[i]))
                end

                RemoveWeaponAsset(GetHashKey("weapon_flare"))


end)
function ClCoordsFunc()
    local playerCoords = GetEntityCoords(PlayerPedId())
    if Config.Debug then
        print("Player is in ClCoordsFunc")
    end
    -- Iterate through the Blips table
    for _, blipEntry in ipairs(Blips) do
        if Config.Debug then
            print("Player is in BlipEntry", blipEntry.zone, blipEntry.blip, blipEntry.coords)
        end
        if blipEntry.zone == nil and blipEntry.coords ~= nil then
            local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, blipEntry.coords.x, blipEntry.coords.y, blipEntry.coords.z, false)
            if distance < Config.RenderDistance then
                -- The player is within the radius of the blip turrext_deliveries:sync
                TriggerServerEvent("turrext_deliveries:sync")
                if Config.Debug then
                    print("Player is within render distance of blip")
                end
            end

        end
        if blipEntry.zone ~= nil then
            local blip = blipEntry.zone
            local distance = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, blip.Blip.Pos.x, blip.Blip.Pos.y, blip.Blip.Pos.z, false)
            
            if distance < Config.RenderDistance then
                -- The player is within the radius of the blip turrext_deliveries:sync
                TriggerServerEvent("turrext_deliveries:sync")
                if Config.Debug then
                    print("Player is within render distance of blip")
                end
            end

            if blipEntry.inZone == false then
                -- Check if the distance is less than the radius
                if distance < blip.Radius then
                    local data = {
                        blipId = blipEntry.blipId
                    }
                    TriggerServerEvent("turrext_deliveries:sync", "enteredzone", data)
                    if Config.Debug then
                        print("Entered zone1: " .. blipEntry.blipId)
                    end
                end
            else
                -- Check if the distance is greater than the radius
                if distance > blip.Radius then
                    local data = {
                        blipId = blipEntry.blipId
                    }
                    TriggerServerEvent("turrext_deliveries:sync", "exitedzone", data)
                    if Config.Debug then
                        print("Exited zone: " .. blipEntry.blipId)
                    end
                end
            end
        end
    end

    for _, ped in ipairs(Peds) do
        if DoesEntityExist(ped.Ped) then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local pedCoords = GetEntityCoords(ped.Ped)
            local dist = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, pedCoords.x, pedCoords.y, pedCoords.z, true) 
            if Config.Debug then 
                print("DoesEntityExist(ped.Ped)", dist) 
            end 
            if dist < 10.0 then
                CheckPedThread(ped, ped.Approach) 
            end 
        end 
    end 

    for _, shipment in ipairs(Shipments) do
        if shipment.status == "dropped" then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local shipmentCoords = GetEntityCoords(shipment.localent)
            local dist = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, shipmentCoords.x, shipmentCoords.y, shipmentCoords.z, true)
            if Config.Debug then
                print("Shipment status: ", shipment.status, " dist: ", dist, "shipment.localent",shipment.localent, GetEntityCoords(shipment.localent), GetEntityCoords(PlayerPedId()))
            end
            if dist < 10.0 then
                if nearShipment == false then
                    nearShipment = true
                    if Config.Debug then
                        print("Nearby shipment detected")
                    end
                    ShipmentThread(shipment)
                end
            end
        end
    end

end


function ShipmentThread(shipment)
    local locid = shipment.localent
    CreateThread(function()
        while nearShipment == true do
            Wait(1)
            -- Config Debug
            if Config.Debug then
                print("locid:",locid)
            end
            -- Pl coords
            local plcoords = GetEntityCoords(PlayerPedId())
            -- Pd coords
            local pedcoords = GetEntityCoords(locid)
            local dist = GetDistanceBetweenCoords(plcoords.x, plcoords.y, plcoords.z, pedcoords.x, pedcoords.y, pedcoords.z, true)
            local expy = false
            while dist < 10 do
                Wait(1)
                -- Pl coords
                local plcoords = GetEntityCoords(PlayerPedId())
                -- Pd coords
                local pedcoords = GetEntityCoords(locid)
                local dist = GetDistanceBetweenCoords(plcoords.x, plcoords.y, plcoords.z, pedcoords.x, pedcoords.y, pedcoords.z, true)
                if dist < 2.0 then
                    if shipment.status == "dropped" then
                        if Config.Debug then
                            print("Shipment status x341: ", shipment.status, " dist: ", dist)
                        end
                        if DoesEntityExist(locid) then
                            if Config.Debug then
                                print("Shipment status x345: ", shipment.status, " dist: ", dist)
                            end
                            if expy == false then
                                exports.ox_target:addLocalEntity(locid, {
                                    name = 'Talk',
                                    icon = 'fas fa-handcuffs',
                                    label = 'Open Shipment',
                                    distance = 3,
                                    canInteract = function(entity)
                                        return entity
                                    end,
                                    onSelect = function(data)
                                        lib.notify({
                                            title = 'Shipment',
                                            description = 'Looting Shipment',
                                            type = 'success'
                                        })
                                        nearShipment = false
                                        exports.ox_target:removeLocalEntity(locid)
                                        exports.ox_target:disableTargeting(true)
                                        TriggerServerEvent("turrext_deliveries:InteractShipment", shipment)
                                        
                                        Wait(300)
                                        exports.ox_target:disableTargeting(false)
                                        --exports.ox_target:addLocalEntity(pedid)
                                        return
                                    end
                                
                                })
                                expy = true
                            end
                        else
                            nearShipment = false
                        end

                    end
                end
            end
            -- Pl coords
            local plcoords = GetEntityCoords(PlayerPedId())
            -- Pd coords
            local pedcoords = GetEntityCoords(locid)
            local dist = GetDistanceBetweenCoords(plcoords.x, plcoords.y, plcoords.z, pedcoords.x, pedcoords.y, pedcoords.z, true)
            if dist > 10.0 then
                nearShipment = false
            end

        end
    end)


end

RegisterNetEvent("turrext_deliveries:progressBar", function()

    lib.progressCircle({
        duration = 3000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
        },
    })
    
end)