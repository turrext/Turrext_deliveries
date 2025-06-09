local nearPed = false
function CheckIfTableEmpty( table )
    local empty = true
    for next in pairs(table) do
        empty = false
    end
    return empty
end

function CheckPedThread(ped)
    if nearPed == false then 
        nearPed = true 
        if Config.Debug then 
            print("Nearby ped detected") 
        end 
        PedThread(ped, ped.Approach)
    end 
end

function AddBlip(coords, sprite, name, inserttable, id, show)
    local blip
    if show == true then
        blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                SetBlipSprite(blip, sprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 1.0)
                SetBlipColour(blip, 1)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(name)
                EndTextCommandSetBlipName(blip)
    else
        blip = nil
    end

    if inserttable then
        local myBlip = {
            blipId = id,
            blip = blip,
            coords = coords,
        }
        table.insert(Blips, myBlip)

    end
    return blip

end
function AddBlipWithRadius(zone)
    Citizen.CreateThread(function()
        if zone.Blip.Drawradius then
            local blip = AddBlipForRadius(zone.Blip.Pos.x, zone.Blip.Pos.y,zone.Blip.Pos.z,zone.Radius) 
            print("Adding BLips with Radius")
            
            SetBlipColour(blip,zone.Color)
            SetBlipAlpha(blip,80)
           
            local blip2 = AddBlipForCoord(zone.Blip.Pos.x, zone.Blip.Pos.y, zone.Blip.Pos.z)
            SetBlipSprite(blip2, zone.Blip.Type)
            SetBlipDisplay(blip2, 4)
            SetBlipScale(blip2, 1.0)
            SetBlipColour(blip2, zone.Blip.Color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.Blip.Blipname)
            EndTextCommandSetBlipName(blip2)
            -- Draw a radius around the blip if drawRadius is true
            
            -- Rotate the blip if Rotate is true
            if zone.Blip.Rotate then
                SetBlipRotation(blip, GetGameTimer() * 0.005)
            end
            

    
              local myBlip = {
                blipId = zone.Id,
                zone = zone,
                blip = blip2,
                blip2 = blip,
                inZone = false
            }
            table.insert(Blips, myBlip)
        
        else
            local blip = AddBlipForCoord(zone.Blip.Pos.x, zone.Blip.Pos.y, zone.Blip.Pos.z)
            SetBlipSprite(blip, zone.Blip.Type)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 1.0)
            SetBlipColour(blip, zone.Blip.Color)
            print("Setting blip color with RGB values:", zone.Blip.Color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(zone.Blip.Blipname)
            EndTextCommandSetBlipName(blip)
            
            -- Draw a radius around the blip if drawRadius is true
            
            -- Rotate the blip if Rotate is true
            if zone.Rotate then
                SetBlipRotation(blip, GetGameTimer() * 0.005)
            end
            local myBlip = {
                blipId = zone.Id,
                zone = zone,
                blip = blip,
                blip2 = nil,
                inZone = false
            }
            table.insert(Blips, myBlip)
        end
    end)
end



function PedThread(ped, approach)
    local pedid = ped.Ped
    while nearPed == true do
        Wait(1)
        -- Config Debug
        if Config.Debug then
            print("PEDID:",pedid)
        end
        local playerCoords = GetEntityCoords(PlayerPedId())
        local pedCoords = GetEntityCoords(pedid)
        local dist = GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, pedCoords.x, pedCoords.y, pedCoords.z, true)
        if DoesEntityExist(pedid) then
            local expy = false
            if dist < 15.0 then
                while dist < 12 do
                    local interface = false
                    local plcoords = GetEntityCoords(PlayerPedId())
                    local pedcoords = GetEntityCoords(pedid)
                    dist = GetDistanceBetweenCoords(plcoords.x, plcoords.y, plcoords.z, pedcoords.x, pedcoords.y, pedcoords.z , true)
                    if approach then
                        TaskTurnPedToFaceEntity(pedid, PlayerPedId(), 2000)
                    end
                    while dist < 10 and dist > 2 do
                        -- Get Pl and Pd coords
                        local plcoords = GetEntityCoords(PlayerPedId())
                        local pedcoords = GetEntityCoords(pedid)
                        dist = GetDistanceBetweenCoords(plcoords.x, plcoords.y, plcoords.z, pedcoords.x, pedcoords.y, pedcoords.z, true)

                        interface = true
                        if expy == false then
                            exports.ox_target:addLocalEntity(pedid, {
                                name = 'Talk',
                                icon = 'fas fa-handcuffs',
                                label = 'Talk to Person',
                                distance = 3,
                                canInteract = function(entity)
                                    return entity
                                end,
                                onSelect = function(data)
                                    lib.notify({
                                        title = 'Talking',
                                        description = 'Talking to Person',
                                        type = 'success'
                                    })
                                    
                                    --exports.ox_target:removeLocalEntity(pedid)
                                    exports.ox_target:disableTargeting(true)
                                    TaskTurnPedToFaceEntity(pedid, PlayerPedId(), 2000)
                                    TaskTurnPedToFaceEntity(PlayerPedId(), pedid, 2000)
                                    Wait(10)
                                    -- Get Pl and Pd coords
                                    local plcoords = GetEntityCoords(PlayerPedId())
                                    local pedcoords = GetEntityCoords(pedid)
                                    dist = GetDistanceBetweenCoords(plcoords.x, plcoords.y, plcoords.z, pedcoords.x, pedcoords.y, pedcoords.z, true)
                                    local x = 1
                                    if dist <= 2 then
                                        x = 5
                                    end
                                    while x < 5 do
                                        x = x + 1
                                        if dist > 2.0 then
                                            print("In While")
                                            local plcoords = GetEntityCoords(PlayerPedId())
                                            local pedcoords = GetEntityCoords(pedid)
                                            dist = GetDistanceBetweenCoords(plcoords.x, plcoords.y, plcoords.z, pedcoords.x, pedcoords.y, pedcoords.z, true)
                                            if approach then
                                               TaskGoToCoordAnyMeans(pedid, plcoords.x, plcoords.y, plcoords.z, 0.5, 0,false,786603,0xbf800000)
                                            else
                                                TaskGoToEntity(PlayerPedId(), pedid,1000, 1.8, 1.0,0,0)
                                                --TaskGoStraightToCoord(PlayerPedId(), pedcoords1.x, pedcoords1.y, pedcoords1.z, 0.7, 0,false,786603,0xbf800000)
                                            end
                                            local plcoords = GetEntityCoords(PlayerPedId())
                                            local pedcoords = GetEntityCoords(pedid)
                                            dist = GetDistanceBetweenCoords(plcoords.x, plcoords.y, plcoords.z, pedcoords.x, pedcoords.y, pedcoords.z, true)
                                        
                                        end
                                        Wait(10)
                                    end
                                    TriggerServerEvent("turrext_deliveries:InteractShop", ped.NetPed, ped.Ped)
                                    Wait(300)
                                    exports.ox_target:disableTargeting(false)
                                    --exports.ox_target:addLocalEntity(pedid)
                                    return
                                end
    
                            })
                            expy = true
                        end
                        if approach then
                            TaskGoToCoordAnyMeans(pedid, plcoords.x, plcoords.y, plcoords.z, 1.0, 0,false,786603,0xbf800000)
                        end
                        Wait(100)
                        ClearPedTasks(pedid)
                    end
                    while interface == true do
                        -- Pl coords
                        local plcoords = GetEntityCoords(PlayerPedId())
                        -- Pd coords
                        local pedcoords = GetEntityCoords(pedid)
                        dist = GetDistanceBetweenCoords(plcoords.x, plcoords.y, plcoords.z, pedcoords.x, pedcoords.y, pedcoords.z, true)
                        if dist > 3 then
                            exports.ox_target:removeLocalEntity(pedid)
                            interface = false
                            expy = false
                            Wait(2000)
                            break
                        end
                        if approach then
                            TaskTurnPedToFaceEntity(pedid, PlayerPedId(), 2000)
                        end
                        Wait(100)
                    end
                    Wait(1000)
                end


            else
                nearPed = false
                break
            end
        else
            nearPed = false
        end
        
    end


end