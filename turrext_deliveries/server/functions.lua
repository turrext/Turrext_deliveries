if Config.Framework == "ESX" then
    ESX = exports['es_extended']:getSharedObject()
end
if Config.Framework == "QB" then
    QBCore = exports['qb-core']:GetCoreObject()
end
function SvBlipFunc()
    -- populate blips with blips from config
    for _, zone in ipairs(Config.Zones) do
        local myBlip = {
            blipId = zone.Id,
            zone = zone,
            players = {},
            peds = {}
        }
        table.insert(Blips1, myBlip)
        if Config.Debug then
            print("Debug: Blip added with ID " .. zone.Id)
        end
    end
end

function AddShipment(src, order, netped, shipmentcoords)
    local Shipment = {
        id = GenerateRandomString(33),
        order = order,
        netped = netped,
        netplayer = src,
        status = "pending",
        interact = false,
        netent = 0,
        coords = shipmentcoords,
        expireTimer = GetGameTimer(),
        attemping = false,
        expired = false       
    }
    table.insert(Shipments, Shipment)
    if Config.Debug then
        for i, package in pairs(order) do
           print("Item: ", package.item.item.name," count: ",package.count)
        end
    end
    TriggerClientEvent("turrext_deliveries:CreateIdBlip", src, Shipment.id, shipmentcoords.x,shipmentcoords.y,shipmentcoords.z)
end

function SvUpdateZone(action, data, src) 
    if action == "enteredzone" then
        if Config.Debug then
            print("Debug: Player " .. src .. " entered zone " .. data.blipId)
        end
        for _, blipEntry in ipairs(Blips1) do
            -- Add Debug here for blipEntry
            if Config.Debug then
                print("Debug: BlipEntry " .. blipEntry.blipId)
            end
            if blipEntry.blipId == data.blipId then
                local playerExists = false
                for _, player in ipairs(blipEntry.players) do
                    if player == src then
                        playerExists = true
                        break
                    end
                end
                if not playerExists then
                    table.insert(blipEntry.players, src)
                    TriggerClientEvent("turrext_deliveries:updateZone", src, action, data)
                end
            end
        end
    elseif action == "exitedzone" then
        if Config.Debug then
            print("Debug: Player " .. src .. " exited zone " .. data.blipId)
        end
        for _, blipEntry in ipairs(Blips1) do
            if blipEntry.blipId == data.blipId then
                for i, player in ipairs(blipEntry.players) do
                    if player == src then
                        table.remove(blipEntry.players, i)
                        TriggerClientEvent("turrext_deliveries:updateZone", src, action, data)
                        break
                    end
                end
            end
        end
    end
end

function SvCheckShipmentSync(src)
    if src ~= nil or src ~= 0 then
        if CheckIfTableEmpty(Shipments) == false then
            for i, shipment in pairs(Shipments) do
                if Config.Debug then
                    print(i)
                    print("Shipment Status: ", shipment.status)
                end
                if shipment.status == "pending" then
                    -- check if player with source is still online
                    if GetGameTimer() - shipment.expireTimer >= Config.GlobalShipmentDropTimer then
                        shipment.status = "dropping"
                        if Config.Debug then
                            print("Dropping, Current Time: ",GetGameTimer() - shipment.expireTimer, " Drop Timer: ", Config.GlobalShipmentDropTimer)
                        end
                        shipment.expireTimer = GetGameTimer()
                        if Config.Debug then
                            print("Debug: shipment.expireTimer: ",GetGameTimer() - shipment.expireTimer)
                        end
                    end
                    
                end
                if shipment.status == "dropping" then
                    local playerPed = GetPlayerPed(src)
                    local playerCoords = GetEntityCoords(playerPed)
                    local distance = GetDistanceBetweenCoords1(playerCoords, shipment.coords)
                    if Config.Debug then
                        print("Distance: ",distance ,GetGameTimer() - shipment.expireTimer)
                    end
                    
                    if distance <= Config.RenderDistance - 50 then
                        -- minus shipment.expiretimer from current game time, and see if the result is greater than Config.GlobalShipmentDropTimer

                        if shipment.status == "dropping" then
                            shipment.status = "dropping1"
                        end
                    end
                end
                if shipment.status ~= "pending" then
                    if Config.Debug then
                        print("Time Since Shipment", GetGameTimer() - shipment.expireTimer >= Config.GlobalShipmentExpireTimer)
                    end
                    if GetGameTimer() - shipment.expireTimer >= Config.GlobalShipmentExpireTimer then
                        shipment.status = "expired"
                        shipment.expired = true
                    end
                end
                if shipment.interact == true then
                    shipment.status = "looted"
                end
                if shipment.status == "dropping1" then
                    local playerPed = GetPlayerPed(src)
                    local playerCoords = GetEntityCoords(playerPed)
                    local distance = GetDistanceBetweenCoords1(playerCoords, shipment.coords)
                    if distance <= Config.RenderDistance - 50 and shipment.attemping == false then
                        TriggerClientEvent("turrext_deliveries:attemptDropCrate", src, shipment.id, shipment.coords)
                    else
                        shipment.status = "dropping"
                    end
                end
                if shipment.status == "dropped" then
                    local spawnedPed = NetworkGetEntityFromNetworkId(shipment.netent)
                    local exists = DoesEntityExist(spawnedPed)
                    if not exists then
                        TriggerEvent("turrext_deliveries:removeShipment", shipment.id)
                    end
                    TriggerClientEvent("turrext_deliveries:syncShipments", src, Shipments)
                end
                if shipment.status == "looted" then
                    if Config.Debug then
                        print("Looted")
                    end
                    --TriggerServerEvent("turrext_deliveries:removeShipment", shipment.id)
                    Wait(60000)
                    shipment.expired = true
                end
                if shipment.expired then
                    local spawnedPed = NetworkGetEntityFromNetworkId(shipment.netent)
                    local exists = DoesEntityExist(spawnedPed)
                    if Config.Debug then
                        print("Expired")
                        print("Expired")
                        print("Expired")
                        print("Expired")
                    end
                    TriggerEvent("turrext_deliveries:removeShipment", shipment.id)
                end
            end
        end



    end

end

function AttemptSapawn(model, coords, heading, shipment)
    local obj2 = 0
    local obj
    local counter = 0
    while obj2 == 0 or obj2 == false do
        if shipment.status == "dropping2" then
            obj = CreateObjectNoOffset(model,coords, true, true, false)
            Wait(100)
            obj2 = DoesEntityExist(obj)
            print("Obj2: ",obj2, obj)
            TriggerClientEvent("turrext_deliveries:SetEntityInvisble", -1, obj, true)
        end
        counter = counter + 1
        if counter > 50 then
            return 0
        end
    end
    if obj2 == true or obj2 == 1 then
        SetEntityCoords(obj, coords)
        return obj
    end
    --[[ESX.OneSync.SpawnObject(model,coords, Heading, function(Object)
        print("In Spawn Objects")
        print("DoesEntityExist(Object)",DoesEntityExist(Object))
        Wait(100) -- While not needed, it is best to wait a few milliseconds to ensure the Object is available
        local Exists = DoesEntityExist(Object) -- returns true/false depending on if the Object exists.
        print("Exists: ", Exists)
        if obj == 0 and Exists then
          obj = Object
          shipment.netent = Object
          print("Object:",obj)
          print("Object:",obj)
          print("Object:",obj)
          print("Object:",obj)
          shipment.status = "dropped"
        else
          if DoesEntityExist(Object) then

              DeleteEntity(Object)
          end
          shipment.status = "dropping1"
        end
        return obj
      end)]]--


end

-- https://docs.esx-framework.org/legacy/Server/functions/registercommand
RegisterServerEvent("turrext_deliveries:setupCrates", function(id, Shipcoords, planeSpawnDistance, heading, rPlaneSpawn, finalcoords, dropCoords)
    local src = source
    local obj = nil
    while obj == nil do
        for i, shipment in pairs(Shipments) do
            if shipment.id == id then
                if shipment.attemping == false then
                    if Config.Debug then
                        print("In Turrext Derliveries")
                    end
                    shipment.attemping = true
                    if shipment.netent ~= 0 then
                        if Config.Debug then
                            print("Netent: ", shipment.netent)
                        end
                        shipment.status = "dropped"
                        break
                    end
                    --print("Shipment Statuss: ", shipment.status, shipment.netent)
                    if shipment.status == "dropping1" then
                        if Config.Debug then
                            print("shipment status", shipment.status)
                        end
                        shipment.status = "dropping2"
                        local model = 758360035 -- Model can be either a string or a hash
                        local coords = Shipcoords -- Coords Can either be vector or a table (such as {x = 0, y = 0, z = 0})
                        if Config.Debug then
                            print("Coords of shipment: ",coords.x,coords.y,coords.z)
                        end
                        local Heading = 0 -- Sets the Rotation/Heading the ped spawns at, can be any number
                        local result = nil
                        while result == nil do
                            result = AttemptSapawn(model, coords, Heading, shipment)
                            print("Result: ",NetworkGetNetworkIdFromEntity(result))
                            Wait(100)
                        end
                        if result == 0 then
                            shipment.status = "dropping1"
                            shipment.attemping = false
                        else 
                            local netid = NetworkGetNetworkIdFromEntity(result)
                            if netid ~= 0 and DoesEntityExist(result) then
                                shipment.status = "dropped"
                                shipment.netent = netid
                                obj = shipment.netent
                                TriggerClientEvent("turrext_deliveries:finalizecrate", src, obj, id, Shipcoords, heading, rPlaneSpawn, finalcoords, dropCoords)
                            else
                                shipment.status = "dropping1"
                                shipment.attempting = false
                                if DoesEntityExist(result) then
                                    DeleteEntity(result)
                                end
                            end
                        end
                        end
                    end
                else
                    break
                end
            end
        Wait(10)
    end


end)
if Config.Framework == "ESX" then
    ESX.RegisterServerCallback('turrext_deliveries:setupCrate', function(src, cb, id, Shipcoords)
        local obj = nil
        while obj == nil do
            for i, shipment in pairs(Shipments) do
                if shipment.id == id then
                    if shipment.attemping == false then
                        if Config.Debug then
                            print("In Turrext Derliveries")
                        end
                        shipment.attemping = true
                        if shipment.netent ~= 0 then
                            if Config.Debug then
                                print("Netent: ", shipment.netent)
                            end
                            shipment.status = "dropped"
                            break
                        end
                        --print("Shipment Statuss: ", shipment.status, shipment.netent)
                        if shipment.status == "dropping1" then
                            if Config.Debug then
                                print("shipment status", shipment.status)
                            end
                            shipment.status = "dropping2"
                            local model = 758360035 -- Model can be either a string or a hash
                            local coords = Shipcoords -- Coords Can either be vector or a table (such as {x = 0, y = 0, z = 0})
                            if Config.Debug then
                                print("Coords of shipment: ",coords.x,coords.y,coords.z)
                            end
                            local Heading = 0 -- Sets the Rotation/Heading the ped spawns at, can be any number
                            local result = nil
                            while result == nil do
                                result = AttemptSapawn(model, coords, Heading, shipment)
                                if Config.Debug then
                                    print("Result: ",result)
                                end
                                Wait(100)
                            end
                            if result == 0 then
                                shipment.status = "dropping1"
                                shipment.attemping = false
                            else 
                                local netid = NetworkGetNetworkIdFromEntity(result)
                                if netid ~= 0 and DoesEntityExist(result) then
                                    shipment.status = "dropped"
                                    shipment.netent = netid
                                    obj = shipment.netent

                                else
                                    shipment.status = "dropping1"
                                    shipment.attempting = false
                                    if DoesEntityExist(result) then
                                        DeleteEntity(result)
                                    end
                                end
                            end
                            end
                        end
                    else
                        cb("attempting")
                    end
                end
            Wait(10)
        end
        if Config.Debug then
            print("Calling Back Object:",obj)
            print("Calling Back Object:",obj)
            print("Calling Back Object:",obj)
            print("Calling Back Object:",obj)
        end
        cb(obj)

    end)
    -- https://docs.esx-framework.org/legacy/Server/functions/registerservercallback
end
if Config.Framework == "QB" then
    
    QBCore.Functions.CreateCallback('turrext_deliveries:setupCrate', function(src, cb, id, Shipcoords)
        local obj = nil
        while obj == nil do
            for i, shipment in pairs(Shipments) do
                if shipment.id == id then
                    if shipment.attemping == false then
                        if Config.Debug then
                            print("In Turrext Derliveries")
                        end
                        shipment.attemping = true
                        if shipment.netent ~= 0 then
                            if Config.Debug then
                                print("Netent: ", shipment.netent)
                            end
                            shipment.status = "dropped"
                            break
                        end
                        --print("Shipment Statuss: ", shipment.status, shipment.netent)
                        if shipment.status == "dropping1" then
                            if Config.Debug then
                                print("shipment status", shipment.status)
                            end
                            shipment.status = "dropping2"
                            local model = 758360035 -- Model can be either a string or a hash
                            local coords = Shipcoords -- Coords Can either be vector or a table (such as {x = 0, y = 0, z = 0})
                            if Config.Debug then
                                print("Coords of shipment: ",coords.x,coords.y,coords.z)
                            end
                            local Heading = 0 -- Sets the Rotation/Heading the ped spawns at, can be any number
                            local result = nil
                            while result == nil do
                                result = AttemptSapawn(model, coords, Heading, shipment)
                                print("Result: ",result)
                                Wait(100)
                            end
                            if result == 0 then
                                shipment.status = "dropping1"
                                shipment.attemping = false
                            else 
                                local netid = NetworkGetNetworkIdFromEntity(result)
                                if netid ~= 0 and DoesEntityExist(result) then
                                    shipment.status = "dropped"
                                    shipment.netent = netid
                                    obj = shipment.netent

                                else
                                    shipment.status = "dropping1"
                                    shipment.attempting = false
                                    if DoesEntityExist(result) then
                                        DeleteEntity(result)
                                    end
                                end
                            end
                            end
                        end
                    else
                        cb("attempting")
                    end
                end
            Wait(10)
        end
        if Config.Debug then
            print("Calling Back Object:",obj)
            print("Calling Back Object:",obj)
            print("Calling Back Object:",obj)
            print("Calling Back Object:",obj)
        end
        cb(obj)

    end)

end
function SvCheckPedSync(src)

    if SpawnedPedGl == false then
        local randomX = math.random(1, #Config.Zones)
        for y, blipEntry in ipairs(Blips1) do
            if y == randomX then

                if Config.Debug then
                    print("Debug: BlipEntry x2" .. blipEntry.blipId)
                end
                if CheckIfTableEmpty(blipEntry.peds) then

                    if Config.Debug then
                        print("Debug: BlipEntry x3" .. blipEntry.blipId)
                    end
                    SpawnPed(blipEntry, src)
                else
                    if Config.Debug then
                        for i, ped in ipairs(blipEntry.peds) do
                            print("Debug: BlipEntry x3" .. blipEntry.blipId, ped)
                        end
                    end
                end
            end
        end
    else
        if Config.Debug then
            print("Debug: BlipEntry x4")
        end
        for y, blipEntry in ipairs(Blips1) do
            if Config.Debug then
                print("Debug: BlipEntry x5", CheckIfTableEmpty(blipEntry.peds))
            end
                if not CheckIfTableEmpty(blipEntry.peds) then
                    TriggerClientEvent("turrext_deliveries:syncPeds", src, blipEntry.peds)
                    PedSyncStatusAtMaxPeds(blipEntry, src)
                end
        end
    end
end
