function CheckIfTableEmpty( table )
    local empty = true
    for next in pairs(table) do
        empty = false
    end
    return empty
end

function GetDistanceBetweenCoords1(coord1, coord2)
    local dx = coord2.x - coord1.x
    local dy = coord2.y - coord1.y
    local dz = coord2.z - coord1.z

    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function GenerateRandomString(length)
    local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local randomString = ''
    local charsLength = string.len(chars)
    
    for i = 1, length do
        local randomIndex = math.random(1, charsLength)
        randomString = randomString .. string.sub(chars, randomIndex, randomIndex)
    end
    
    return randomString
end

function SpawnPed(blipEntry, src)
    local pedIndex = math.random(1, #blipEntry.zone.Peds.SpawnCoords)
    local lpPed = GenerateRandomString(32)
    local myPed = {
        Ped = lpPed,
        Status = "spawning",
        PedInfo = blipEntry.zone.Peds.SpawnCoords[pedIndex],
        TaskComplete = false,
        ExpireTimer = GetGameTimer(),
        Interrogated = false,
        InterrogationTimer = GetGameTimer(),
        Expired = false
    }
    table.insert(blipEntry.peds, myPed)
    SpawnedPedGl = true
end

function PedAlreadyExists(blipEntry, pedIndex)
    for _, existingPed in pairs(blipEntry.peds) do
        if existingPed.PedInfo == blipEntry.zone.Peds.SpawnCoords[pedIndex] then
            return true
        end
    end
    return false
end

function SpawnPedLib(model, coords, heading, cb)
	if type(model) == 'string' then model = joaat(model) end
	CreateThread(function()
		local entity = CreatePed(0, model, coords.x, coords.y, coords.z, heading, true, true)
		while not DoesEntityExist(entity) do Wait(50) end
		cb(NetworkGetNetworkIdFromEntity(entity))
	end)
end


function PedSyncStatusAtMaxPeds(blipEntry, src)

    for i, peds in ipairs(blipEntry.peds) do
        if Config.Debug then
            print("PedSyncStatusAtMaxPeds peds.Status", peds.Status)
        end
        local pedId = NetworkGetEntityFromNetworkId(peds.Ped)
        if peds.Status == "spawning" then
            local playerPed = GetPlayerPed(src)
            local playerCoords = GetEntityCoords(playerPed)
            local distance = GetDistanceBetweenCoords1(playerCoords, peds.PedInfo.Pos)

            if distance <= Config.RenderDistance then
                peds.Status = "inspawning"
                if Config.Framework == "ESX" then
                    ESX.OneSync.SpawnPed(peds.PedInfo.Model, peds.PedInfo.Pos, 0, function(netId)
                        Wait(250)
                        local spawnedPed = NetworkGetEntityFromNetworkId(netId)
                        local exists = DoesEntityExist(spawnedPed)

                        if exists then
                            SetEntityHeading(spawnedPed, peds.PedInfo.Heading)
                            peds.Status = "active"
                            peds.Ped = netId
                            CreateShop(src, netId)
                        else
                            if spawnedPed ~= nil and spawnedPed ~= 0 then
                                DeleteEntity(spawnedPed)
                            end
                            peds.Status = "spawning1"
                        end
                    end)
                end
                if Config.Framework == "QB" then
                    SpawnPedLib(peds.PedInfo.Model, peds.PedInfo.Pos, 0, function(netId)
                        Wait(250)
                        local spawnedPed = NetworkGetEntityFromNetworkId(netId)
                        local exists = DoesEntityExist(spawnedPed)

                        if exists then
                            SetEntityHeading(spawnedPed, peds.PedInfo.Heading)
                            peds.Status = "active"
                            peds.Ped = netId
                            CreateShop(src, netId)
                        else
                            if spawnedPed ~= nil and spawnedPed ~= 0 then
                                DeleteEntity(spawnedPed)
                            end
                            peds.Status = "spawning1"
                        end
                    end)
                end
            end
        end

        if peds.TaskComplete == true then
            peds.expired = true
        end
        if peds.Status == "active" then
            if Config.Debug then
                print("Ped Active")
            end
            if not DoesEntityExist(pedId) or (Config.InstantRespawnAfterPedDeath and GetEntityHealth(pedId) <= 0) then
                TriggerClientEvent("turrext_sellv2:confirmDeath", src, peds.Ped)
                --[[if CheckIfTableEmpty(Srces2) == true then
                    TriggerClientEvent("turrext_deliveries:RegisterMenu", src, "shop", Shop, peds.Ped)
                    table.insert(Srces2, src)
                end
                for i, pl in pairs(Srces2) do
                    if pl == src then
                        exists == true
                    end
                    TriggerClientEvent("turrext_deliveries:RegisterMenu", src, "shop", Shop, peds.Ped)
                    table.insert(Srces2, src)
                end]]--
                SpawnedPedGl = false
                table.remove(blipEntry.peds, i)
                break
            end

            local pedCoords = GetEntityCoords(pedId)
            if GetDistanceBetweenCoords1(pedCoords, blipEntry.zone.Blip.Pos) > blipEntry.zone.Radius then
                DeleteEntity(pedId)
                SpawnedPedGl = false
                table.remove(blipEntry.peds, i)
                break
            end

            if peds.Expired then
                local empty = true
                for next in pairs(blipEntry.players) do
                    empty = false
                end
                if empty == false then
                    -- Someone in zone but ped expired
                else
                    print("Zone empty and ped expired")
                    DeleteEntity(pedId)
                    SpawnedPedGl = false
                    table.remove(blipEntry.peds, i)
                end
            end
        end

        if not peds.Expired then
            local currentTime = GetGameTimer()
            local timeSince = currentTime - peds.ExpireTimer
            if Config.Debug then
                print("Time Since", timeSince)
            end
            if timeSince >= peds.PedInfo.Actions.ExpireTimer * 1000 then
                peds.Expired = true
            end
        end

    end
end

function CreateShop(src, netId)
    Shop = {}
    for i, item in ipairs(Config.Items) do
        local myItem = {
            name = item.name,
            price = item.price,
            count = item.maxAmount,
            label = item.label,
            type = item.type,
            sold = 0
        }
        table.insert(Shop, myItem)
    end
    
end