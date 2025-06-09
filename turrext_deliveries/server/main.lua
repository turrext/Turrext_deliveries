if Config.Framework == "ESX" then
    ESX = exports['es_extended']:getSharedObject()
end
if Config.Framework == "QB" then
    QBCore = exports['qb-core']:GetCoreObject()
end

Blips1 = {}
SpawnedPedGl = false
Shop = {}
Shipments = {}
Srces2 = {}
--Register Command to Delete all Server Entities that are not players
-- GetAllEntities()

RegisterServerEvent("turrext_deliveries:InteractShipment", function(locshipment)
    local src = source
    for i, shipment in ipairs(Shipments) do
        if shipment.id == locshipment.id then
            if shipment.netent ~= nil then
                local spawnedPed = NetworkGetEntityFromNetworkId(shipment.netent)
                local exists = DoesEntityExist(spawnedPed)
                if exists then
                    if shipment.status == "dropped" then
                        if shipment.interact == false then
                            shipment.interact = true
                            shipment.status = "looted"
                            -- Add Items to player inventory
                            
                            for i, package in pairs(shipment.order) do
                                if Config.Debug then
                                    print("Item: ", package.item.item.name," count: ",package.count, "package.item.item.type", package.item.item.type,"package.item.type", package.item.type)
                                end
                                TriggerClientEvent("turrext_deliveries:progressBar", src)
                                Citizen.Wait(3000)
                                if Config.Inventory == "OX" then
                                    local success, response = exports.ox_inventory:AddItem(src, package.item.item.name, package.count, package.item.item.type)
                                    if success then
                                        lib.notify(src, {
                                            title = "Shipment",
                                            description = "Item added to inventory, Item: "..package.item.item.name.." Amount: "..package.count,
                                            type = "success"
                                        })
                                    else
                                        lib.notify(src, {
                                            title = "Shipment",
                                            description = "Error Adding Item to Inv: "..response..". Item: "..package.item.item.name.." Count: "..package.count,
                                            type = "error"
                                        })
                                    end
                                end
                                if Config.Inventory == "QB" then
                                    local xPlayer = QBCore.Functions.GetPlayer(src)
                                    local success = xPlayer.Functions.AddItem(package.item.item.name, package.count, package.item.item.type)
                                    if success then
                                        lib.notify(src, {
                                            title = "Shipment",
                                            description = "Item added to inventory, Item: "..package.item.item.name.." Amount: "..package.count,
                                            type = "success"
                                        })
                                    else
                                        lib.notify(src, {
                                            title = "Shipment",
                                            description = "Error Adding Item to inventory Item: "..package.item.item.name.." Count: "..package.count,
                                            type = "error"
                                        })
                                    end
                                end
                                --[[
                                    _, function(success, response)
                                if success then
                                    lib.notify(src, {
                                        title = "Shipment",
                                        description = "Item added to inventory",
                                        type = "success"
                                    })
                                else
                                    lib.notify(src, {
                                        title = "Shipment",
                                        description = "Error Adding Item to Inv: "..response,
                                        type = "error"
                                    })
                                end
                                
                                end)
                                ]]
                            end
                        end
                    end
                

                end
            end
        end
    end


end)
RegisterCommand("deleteall", function(source, args)
        -- Loop through all server entities
        for _, entity in ipairs(GetAllPeds()) do
        
            -- Check if entity is not a player
            if GetEntityType(entity) ~= 0 then
                -- Delete entity
                DeleteEntity(entity)
            end
        end
        -- Loop thorugh object
        for _, entity in ipairs(GetAllObjects()) do
            -- Check if entity is not a player
            if GetEntityType(entity) ~= 0 then
                -- Delete entity
                DeleteEntity(entity)
            end
        end

end, false)
RegisterServerEvent("turrext_deliveries:sync", function(action, data)
    local src = source
    --check if blips empty
    if CheckIfTableEmpty(Blips1) == true then
        SvBlipFunc()
    else 
        -- Config Debug
        if Config.Debug then
            print("CheckIfTableEmpty(Blips1) == false")
        end
        if src ~= nil then
            SvCheckPedSync(src)
        end
    end
    if action == "enteredzone" or "exitedzone" then
        SvUpdateZone(action, data, src)

    end
    if CheckIfTableEmpty(Shipments) == false then
        if Config.Debug then
            print("CheckIfTableEmpty(Shipments)")
        end
        SvCheckShipmentSync(src)
    end
    for _, blipEntry in ipairs(Blips1) do
            if CheckIfTableEmpty(blipEntry) == false then
                for _, player in ipairs(blipEntry.players) do
                end
            end
    end
end)

RegisterServerEvent("turrext_deliveries:shipmentpending", function(src, order, netped, shipmentcoords)

    AddShipment(src, order, netped, shipmentcoords)


end)
RegisterServerEvent("turrext_deliveries:ConfirmOrder", function(order, total, netped)

    local src = source
    local pedfound = false
    local pedtable = nil
    local pedbliptable = nil
    print(netped)
    for i, BlipEntries in ipairs(Blips1) do
        local empty = true
       
        for next in pairs(BlipEntries.peds) do
            empty = false
        end
        if empty == false then
            for x, ped in ipairs(BlipEntries.peds) do
                if ped.Ped == netped then
                    pedfound = true
                    pedtable = ped
                    pedbliptable = BlipEntries
                end
            end
        end
        
    end
    if pedfound == true and pedtable ~= nil and src ~= nil then
        if CheckIfTableEmpty(Shop) == false then
            if pedtable.TaskComplete == false then
                if Config.Framework == "ESX" then
                    local xPlayer = ESX.GetPlayerFromId(src)
                    local identifier = GetPlayerIdentifier(src)
                    if xPlayer.getAccount(Config.Account).money >= total then
                        xPlayer.removeAccountMoney(Config.Account, total)
                        --[[TriggerClientEvent('ox_lib:alertDialog', src, {
                            header = 'Success',
                            content = 'You have Paid $'..total..' from your Bank Account. You have been sent the shipment location, it will be dropping in 30 minutes, please make it there before then.',
                            cancel = true,
                            labels = {
                                cancel = "Close"
                            }
                        })]]--
                        lib.notify(src, {
                            title = 'Success',
                            description = 'You have Paid $'..total..' from your Bank Account. You have been sent the shipment location, it will be dropping in 30 minutes, please make it there before then.',
                            type = 'success',
                            duration = 8000
                        })
                        local random = math.random(1, #Config.ShipmentCoords)
                        local shipmentcoords = Config.ShipmentCoords[random]
                        if Config.EnableQSPhone then
                            local phone = exports['qs-smartphone-pro']:GetPhoneNumberFromIdentifier(identifier, false) -- Sender phone number
                            local message = 'You have Paid $'..total..' from your Bank Account. You have been sent the shipment location, it will be dropping in 30 minutes, please make it there before then.'
                            local appName = 'Shipment Plug'
                            exports['qs-smartphone-pro']:sendNewMessageFromApp(src, phone, message, appName)
                            if rand <= Config.GlobalPoliceChange then
                                local phoneNumber = exports['qs-smartphone-pro']:GetPhoneNumberFromIdentifier(identifier, false) -- Sender phone number
                                local job = 'police'
                                local coords = GetEntityCoords(GetPlayerPed(src))
                                exports['qs-smartphone-pro']:sendSOSMessage(phoneNumber, job, json.encode(shipmentcoords), 'location, There is a illegal shipment in the area')


                            end
                        end

                        pedtable.TaskComplete = true
                        print(shipmentcoords.x)
                        TriggerEvent("turrext_deliveries:shipmentpending", src, order, netped, shipmentcoords)
                    else
                        lib.notify(src, {
                            title = 'Error',
                            description = 'You don\'t have enough money! E42x8',
                            type = 'error'
                        })
                    end
                end
                if Config.Framework == "QB" then
                    local xPlayer = QBCore.Functions.GetPlayer(src)
                    local identifier = GetPlayerIdentifier(src)
                    if xPlayer.Functions.GetMoney(Config.Account) >= total then
                        xPlayer.Functions.RemoveMoney(Config.Account, total)
                        --[[TriggerClientEvent('ox_lib:alertDialog', src, {
                            header = 'Success',
                            content = 'You have Paid $'..total..' from your Bank Account. You have been sent the shipment location, it will be dropping in 30 minutes, please make it there before then.',
                            cancel = true,
                            labels = {
                                cancel = "Close"
                            }
                        })]]--
                        lib.notify(src, {
                            title = 'Success',
                            description = 'You have Paid $'..total..' from your Bank Account. You have been sent the shipment location, it will be dropping in 30 minutes, please make it there before then.',
                            type = 'success',
                            duration = 8000
                        })
                        local random = math.random(1, #Config.ShipmentCoords)
                        local shipmentcoords = Config.ShipmentCoords[random]
                        if Config.EnableQSPhone then
                            local phone = exports['qs-smartphone-pro']:GetPhoneNumberFromIdentifier(identifier, false) -- Sender phone number
                            local message = 'You have Paid $'..total..' from your Bank Account. You have been sent the shipment location, it will be dropping in 30 minutes, please make it there before then.'
                            local appName = 'Shipment Plug'
                            exports['qs-smartphone-pro']:sendNewMessageFromApp(src, phone, message, appName)
                            if rand <= Config.GlobalPoliceChange then
                                local phoneNumber = exports['qs-smartphone-pro']:GetPhoneNumberFromIdentifier(identifier, false) -- Sender phone number
                                local job = 'police'
                                local coords = GetEntityCoords(GetPlayerPed(src))
                                exports['qs-smartphone-pro']:sendSOSMessage(phoneNumber, job, json.encode(shipmentcoords), 'location, There is a illegal shipment in the area')


                            end
                        end

                        pedtable.TaskComplete = true
                        print(shipmentcoords.x)
                        TriggerEvent("turrext_deliveries:shipmentpending", src, order, netped, shipmentcoords)
                    else
                        lib.notify(src, {
                            title = 'Error',
                            description = 'You don\'t have enough money! E42x8',
                            type = 'error'
                        })
                    end


                end
            else

                lib.notify(src, {
                    title = 'Error',
                    description = 'Does not want to talk to you! E43x8',
                    type = 'error'
                })
            end
        end
    end

end)

RegisterServerEvent("turrext_deliveries:removeShipment", function(shipmentID)
    TriggerClientEvent("turrext_deliveries:removeShipment", -1, shipmentID)
    if Config.Debug then
        print("Shipment Removed")
    end
    for i, shipment in ipairs(Shipments) do
        if shipment.id == shipmentID then
            if shipment.netent ~= nil then
                local spawnedPed = NetworkGetEntityFromNetworkId(shipment.netent)
                local exists = DoesEntityExist(spawnedPed)
                if exists then
                    DeleteEntity(spawnedPed)
                end
            end
            table.remove(Shipments, i)
        end
    end

end)
RegisterServerEvent("turrext_deliveries:InteractShop", function(netped,localped)
    local src = source
    local pedfound = false
    local pedtable = nil
    local pedbliptable = nil
    local zone
    local coords
    local xPlayer
    if Config.Framework == "ESX" then
        xPlayer = ESX.GetPlayerFromId(src)
    end
    if Config.Framework == "QB" then
        xPlayer = QBCore.Functions.GetPlayer(src)
    end
    print(netped)
    for i, BlipEntries in ipairs(Blips1) do
        local empty = true
       
        for next in pairs(BlipEntries.peds) do
            empty = false
        end
        if empty == false then
            for x, ped in ipairs(BlipEntries.peds) do
                if ped.Ped == netped then
                    pedfound = true
                    pedtable = ped
                    pedbliptable = BlipEntries
                    zone = BlipEntries.zoneTerritory
                    coords = BlipEntries.zone.Blip.Pos
                end
            end
        end
        
    end
    if pedfound == true and pedtable ~= nil and src ~= nil then
        if CheckIfTableEmpty(Shop) == false then
            print("Theres a SHop!")
            if pedtable.TaskComplete == false then
                local zoned = exports['rcore_gangs']:GetZoneAtPosition(coords)
                local endone = exports['rcore_gangs']:GetGangAtZone(zoned)
                local exists = false
                if endone ~= nil then
                    
                    for i, member in ipairs(endone.members) do
                        if Config.Framework == "QB" then
                            xPlayer.identifier = xPlayer.PlayerData.citizenid
                        end
                        if Config.Debug == true then
                            print(member)
                            print(member.name)
                            print(member.identifier)
                            print("IDentifier: ",xPlayer.PlayerData.citizenid)
                        end
                        if xPlayer.identifier == member.identifier then
                            exists = true
                        end
                    end
                    if exists == true then
                        TriggerClientEvent("turrext_deliveries:RegisterMenu", src, "shop", Shop, netped)
                        Wait(1000)
                        --TriggerClientEvent("turrext_deliveries:OpenMenu", src, 'shop')
                    else
                        lib.notify(src, {
                            title = 'Error',
                            description = 'You are not respected in this area.',
                            type = 'error'
                        })
                    end

                else
                    lib.notify(src, {
                        title = 'Error',
                        description = 'You are not respected in this area.',
                        type = 'error'
                    })

                end
            else
                local zoned = exports['rcore_gangs']:GetZoneAtPosition(coords)
                local endone = exports['rcore_gangs']:GetGangAtZone(zoned)
                local exists = false
                local plgang = exports['rcore_gangs']:GetPlayerGang(src)
                if endone ~= nil and plgang ~= nil then
                    if endone.name ~= plgang.name then
                            local ranintg = math.random(0, 100)
                            if pedtable.Interrogated == true then
                                if GetGameTimer() - pedtable.InterrogationTimer >= Config.RivalGangInterrogateTimer then
                                    pedtable.Interrogated = false
                                end
                            end
                            print("status of interrogation: ",pedtable.Interrogated,GetGameTimer() - pedtable.InterrogationTimer, GetGameTimer() - pedtable.InterrogationTimer >= Config.RivalGangInterrogateTimer)
                            if pedtable.Interrogated == false then
                                pedtable.Interrogated = true
                                pedtable.InterrogationTimer = GetGameTimer()
                                if ranintg <= Config.RivalGangInterrogateChance then

                                    lib.notify(src, {
                                        title = 'Confidential Information',
                                        description = 'There is a shipment collection, ive sent you the location.',
                                        type = 'info'
                                    })
                                    if CheckIfTableEmpty(Shipments) == false then
                                        for i, shipment in pairs(Shipments) do
                                            if shipment.netped == pedtable.Ped then
                                                TriggerClientEvent("turrext_deliveries:CreateIdBlip", src, shipment.id, shipment.coords.x,shipment.coords.y,shipment.coords.z)
                                            end
                                        end
                                    end

                                else 
                                    lib.notify(src, {
                                        title = 'Interrogation Failed',
                                        description = 'Does not want to talk to you.',
                                        type = 'error'
                                    })
                                end

                            else
                                lib.notify(src, {
                                    title = 'Failed',
                                    description = 'Does not want to talk to you.',
                                    type = 'error'
                                })
                            end

                    end

                else
                    lib.notify(src, {
                        title = 'Error',
                        description = 'Does not want to talk to you!',
                        type = 'error'
                    })


                end
            end
        end
    else
        print("Didnt Find ped")
    end

end)

RegisterServerEvent("turrext_deliveries:OpenMenu", function(name)
    local src = source
    TriggerClientEvent("turrext_deliveries:OpenMenu", src, name)


end)