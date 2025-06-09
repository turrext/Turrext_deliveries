if Config.Framework == "ESX" then
    ESX = exports['es_extended']:getSharedObject()
end
if Config.Framework == "QB" then
    QBCore = exports['qb-core']:GetCoreObject()
end
Blips = {}
Peds = {}
Shipments = {}

CreateThread(function()

    while true do

        Wait(1000)
        if CheckIfTableEmpty(Blips) == true then
            -- blips table is empty
            print("Blips Emptu")
            ClBlipFunc() 
        end

        ClCoordsFunc()
    end

end)

RegisterNetEvent("turrext_deliveries:attemptDropCrate", function(id,coords)

    CrateDrop(id,200,coords)

end)

RegisterNetEvent("turrext_deliveries:updateZone", function(action, zone)

    ClUpdateZone(action, zone)

end)

RegisterNetEvent("turrext_deliveries:CreateIdBlip", function (id, x,y,z)
    print("id, x,y,z",id, x,y,z)
    AddBlip(vector3(x,y,z), 130, "Shipment", true, id, true)
end)

RegisterNetEvent("turrext_deliveries:syncPeds", function(pedtable)
    if Config.Debug then
        print("Syncing peds")
    end
    ClSyncPeds(pedtable)

end)

RegisterNetEvent("turrext_deliveries:removeShipment", function(id)
    for i, shipment in ipairs(Shipments) do
        if shipment.id == id then
            if shipment.localent ~= 0 then
                DeleteEntity(shipment.localent)
            end
            table.remove(Shipments, i)
            break
        end
    end
    for i, blip in ipairs(Blips) do
        if blip.blipId == id then
            RemoveBlip(blip.blip)
            table.remove(Blips, i)
            break
        end
    end

end)
RegisterNetEvent("turrext_deliveries:syncShipments", function(shipmenttable)
    if Config.Debug then
        print("syncing shipments")
    end
    ClSyncShipments(shipmenttable)

end)

RegisterNetEvent("turrext_deliveries:SetEntityInvisble", function(netid)

    SetEntityVisible(netid, false, false)


end)
RegisterNetEvent("turrext_deliveries:RegisterMenu", function(name, shop, NetId)
    local order = {}

    local options = {}

    for i, shopItem in ipairs(shop) do
        local values = {}
        local j = 0
        print(shopItem.count)
        while j < shopItem.count +1 do
            Wait(1)
            table.insert(values, j)
            j += 1
        end

        local option = {
            label = shopItem.label .. " $"..shopItem.price.."/Per Unit",
            values = values,
            defaultIndex = 0,
            args = {
                item = shopItem
            },
            close = false
        }
        table.insert(options, option)
    end
    local option =  {
        label = 'Confirm', args = {confirm = 'true'}, close = true
    }
    table.insert(options, option)
    print("Registered Menu:SHOP")
    lib.registerMenu({
        id = name,
        title = 'Order a Shipment',
        position = 'top-right',
        onSideScroll = function(selected, scrollIndex, args)
            if CheckIfTableEmpty(order) == true then
                -- order table is empty
                print("args.item.name", args.item.name)
                local myOrder = {
                    item = args,
                    count = scrollIndex -1
                }
                table.insert(order, myOrder)
            else
                -- Check if item is already in table
                local found = false
                for i, orderItem in ipairs(order) do
                    print("orderItem.item.name == args.item.name"  , orderItem.item.item.name, args.item.name)
                    if orderItem.item.item.name == args.item.name then
                        orderItem.count = scrollIndex -1
                        found = true
                    end
                end
                if found == false then
                    local myOrder = {
                        item = args,
                        count = scrollIndex -1
                    }
                    table.insert(order, myOrder)
                end
            end
        end,
        onSelected = function(selected, secondary, args)
            if not secondary then
                print("Normal button")
            else
                if args.isCheck then
                    print("Check button")
                end
     
                if args.isScroll then
                    print("Scroll button")
                    print(selected, secondary, json.encode(args, {indent=true}))
                    if CheckIfTableEmpty(order) == true then
                        -- order table is empty
                        print("args.item.name", args.item.name)
                        if secondary -1 > 0 then
                            local myOrder = {
                                item = args,
                                count = secondary -1
                            }
                            table.insert(order, myOrder)
                        end
                        
                    else
                        -- Check if item is already in table
                        local found = false
                        for i, orderItem in ipairs(order) do
                            print("orderItem.item.name == args.item.name"  , orderItem.item.item.name, args.item.name)
                            if orderItem.item.item.name == args.item.name then
                                orderItem.count = secondary -1
                                found = true
                            end
                        end
                        if found == false then
                            if secondary -1 > 0 then
                                local myOrder = {
                                    item = args,
                                    count = secondary -1
                                }
                                table.insert(order, myOrder)
                            end
                        end
                    end
                end
            end
        end,
        onCheck = function(selected, checked, args)
            print("Check: ", selected, checked, args)
        end,
        options = options 
    }, function(selected, scrollIndex, args)
        print("CB FUNC")
        local total = 0
        for i, orderItem in ipairs(order) do
            print(orderItem.item.item.name, orderItem.count)
            total += orderItem.item.item.price * orderItem.count
        end
        print("args.confirm",args.confirm)
        local confirmed = args.confirm
        if confirmed == "true" then
            print("Confirm")
            TriggerServerEvent("turrext_deliveries:ConfirmOrder", order, total, NetId)
        end
    end)
    TriggerServerEvent("turrext_deliveries:OpenMenu", name)
    

end)
RegisterNetEvent("turrext_deliveries:OpenMenu", function(name)

    lib.showMenu(name)
    

end)
RegisterCommand("start", function()
    
    
    
    
end, false)