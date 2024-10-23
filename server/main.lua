ESX = exports['es_extended']:getSharedObject()

TriggerEvent('esx_society:registerSociety', 'cardealer', 'cardealer', 'society_cardealer', 'society_cardealer', 'society_cardealer', {type = 'private'})

ESX.RegisterServerCallback('fh_cardealer:isPlateTaken', function(source, cb, plate)
	MySQL.Async.fetchAll('SELECT 1 FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = plate
	}, function(result)
		cb(result[1] ~= nil)
	end)
end)

ESX.RegisterServerCallback('fh_cardealer:sellVehicle', function(source, cb, playerID, model, plate, carname)
    local xPlayer = ESX.GetPlayerFromId(playerID)
    local zPlayer = ESX.GetPlayerFromId(source)

    local vehicle = MySQL.query.await('SELECT * FROM vehicles WHERE model = ?', {model})
    local price = vehicle[1].price

    local ExistingStock = MySQL.scalar.await('SELECT stock FROM vehicleshop_stock WHERE car = ?', {model})

    if tonumber(ExistingStock) == 0 then
        zPlayer.showNotification('Der er ikke nok på lager!')
        cb(false)
        return
    else
        TriggerClientEvent('fisk_bilforhandler:requestpurchase', playerID, model, price, plate, carname, source)
    end
end)

ESX.RegisterServerCallback('fh_cardealer:sellVehicle2', function(source, cb, playerID, model, plate, carname)
    local xPlayer = ESX.GetPlayerFromId(playerID)
    local zPlayer = ESX.GetPlayerFromId(source)

    local vehicle = MySQL.query.await('SELECT * FROM vehicles WHERE model = ?', {model})
    local price = vehicle[1].price

    local ExistingStock = MySQL.scalar.await('SELECT stock FROM vehicleshopmc_stock WHERE mc = ?', {model})

    if tonumber(ExistingStock) == 0 then
        zPlayer.showNotification('Der er ikke nok på lager!')
        cb(false)
        return
    else
        TriggerClientEvent('fisk_bilforhandler:requestpurchase2', playerID, model, price, plate, carname, source)
    end
end)

RegisterServerEvent('fisk_bilforhandler:purchasecar', function(model, price, plate, cardealer, carname, choice)
    local xPlayer = ESX.GetPlayerFromId(source)
    local zPlayer = ESX.GetPlayerFromId(cardealer)
    if choice then
        if xPlayer.getAccount('bank').money >= price then
            xPlayer.removeAccountMoney('bank', price)
            local SellerPrice = price * Config.SellerPercentage
            zPlayer.addAccountMoney('bank', SellerPrice)
            print(plate)
            MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored, parked, impounded, vehicleprops) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', { xPlayer.identifier, plate, model, "car", "ls1", 1, 0, json.encode({plate = plate, engineHealth = 1000.0, fuelLevel = 100})})
                xPlayer.showNotification(_U('bought_veh', model, plate, price))
                zPlayer.showNotification(_U('sold_veh', model, xPlayer.getName(), price))
                local ExistingStock = MySQL.scalar.await('SELECT stock FROM vehicleshop_stock WHERE car = ?', {model})
                MySQL.update.await('UPDATE vehicleshop_stock SET stock = ? WHERE car = ? ', {ExistingStock-1, model})
            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_cardealer', function(account)
                if account then
                   account.addMoney(price*1.5)
                else
                    xPlayer.showNotification('Society account ikke fundet.')
                end
                sendToDiscord(237973, "Bilforhandleren", "**".. zPlayer.getName() .. "** har solgt en **".. model .."** med nummerpladen **"..plate.."** til **" .. xPlayer.getName() .."** for **"..price.." DKK**" , "Bilforhandleren")
            end)
            cb(true)
        else
            xPlayer.showNotification(_U('not_enought_to', model))
            zPlayer.showNotification(_U('not_enought', xPlayer.getName(), model))
            cb(false)
        end
    end
    TriggerClientEvent('fisk_purchased:cardealer', cardealer, choice, carname, price)
end)

RegisterServerEvent('fisk_bilforhandler:purchasecar2', function(model, price, plate, cardealer, carname, choice)
    local xPlayer = ESX.GetPlayerFromId(source)
    local zPlayer = ESX.GetPlayerFromId(cardealer)
    if choice then
        if xPlayer.getAccount('bank').money >= price then
            xPlayer.removeAccountMoney('bank', price)
            local SellerPrice = price * Config.SellerPercentage
            zPlayer.addAccountMoney('bank', SellerPrice)
            print(plate)
            MySQL.insert.await('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored, parked, impounded, vehicleprops) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', { xPlayer.identifier, plate, model, "car", "ls1", 1, 0, json.encode({plate = plate, engineHealth = 1000.0, fuelLevel = 100})})
                xPlayer.showNotification(_U('bought_veh', model, plate, price))
                zPlayer.showNotification(_U('sold_veh', model, xPlayer.getName(), price))
                local ExistingStock = MySQL.scalar.await('SELECT stock FROM vehicleshopmc_stock WHERE mc = ?', {model})
                MySQL.update.await('UPDATE vehicleshopmc_stock SET stock = ? WHERE mc = ? ', {ExistingStock-1, model})
            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_cardealer', function(account)
                if account then
                   account.addMoney(price*1.5)
                else
                    xPlayer.showNotification('Society account ikke fundet.')
                end
                sendToDiscord(237973, "MCHandlern", "**".. zPlayer.getName() .. "** har solgt en **".. model .."** med nummerpladen **"..plate.."** til **" .. xPlayer.getName() .."** for **"..price.." DKK**" , "Bilforhandleren")
            end)
            cb(true)
        else
            xPlayer.showNotification(_U('not_enought_to', model))
            zPlayer.showNotification(_U('not_enought', xPlayer.getName(), model))
            cb(false)
        end
    end
    TriggerClientEvent('fisk_purchased:cardealer', cardealer, choice, carname, price)
end)

ESX.RegisterServerCallback('nat_cardealer:GetVehiclePrice', function(source, cb, model)

    local vehicle = MySQL.query.await('SELECT * FROM vehicles WHERE model = ?', {model})
    local price = vehicle[1].price
    cb(price)
end)

RegisterServerEvent('fh_cardealer:logdemo')
AddEventHandler('fh_cardealer:logdemo', function(model)
    local xPlayer = ESX.GetPlayerFromId(source)
	sendToDiscord2(237973, "Bilforhandleren", "**".. xPlayer.getName() .. "** har fremvist en **".. model.."**", "Bilforhandleren")
end)

ESX.RegisterServerCallback('fh_cardealer:GetVehicleStock', function(source, cb)
    MySQL.query('SELECT * FROM vehicleshop_stock', {}, function(result)
        if result then
            local options = {
                {
                    title = 'Køretøjer firmaet har i lager:',
                    icon = 'fa-solid fa-arrow-down',
                },
            }
            for k,v in pairs(result) do
                table.insert(options, {
                    title = 'Model: '..v.car..' | Stock: '..v.stock
                })
            end
            cb(options)
        end
    end)
end)

ESX.RegisterServerCallback('fh_cardealer:GetVehicleStock2', function(source, cb)
    MySQL.query('SELECT * FROM vehicleshopmc_stock', {}, function(result)
        if result then
            local options = {
                {
                    title = 'Køretøjer firmaet har i lager:',
                    icon = 'fa-solid fa-arrow-down',
                },
            }
            for k,v in pairs(result) do
                table.insert(options, {
                    title = 'Model: '..v.mc..' | Stock: '..v.stock
                })
            end
            cb(options)
        end
    end)
end)

ESX.RegisterServerCallback('fisk_vehicleshop:getNames', function(source, cb, target)
    if not ESX then return end
    local name = ESX.GetPlayerFromId(target).getName()
    if name == nil then
        name = "Ukendt"
    end    
    cb(name)
end)

ESX.RegisterServerCallback('fh_cardealer:AddStock', function(src, cb, model, newStock)
    local xPlayer = ESX.GetPlayerFromId(src)
    
    local vehicle = MySQL.query.await('SELECT * FROM vehicles WHERE model = ?', {model})

    if #vehicle == 0 then
        xPlayer.showNotification('Modellen kunne ikke findes')
        return
    end
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_cardealer', function(account)
        if account then
            print(account.money)
            if account.money >= vehicle[1].price*0.75 then
                print('1')
                account.removeMoney(vehicle[1].price*0.75)
                print('2')
            else
                xPlayer.showNotification('Der er ikke nok penge på firma kontoen!')
                return
                cb(false)
            end
                else
                    xPlayer.showNotification('Society account ikke fundet.')
                end
            local doesVehicleExistInDatabase = MySQL.query.await('SELECT * FROM vehicleshop_stock WHERE car = ?', {model})
            if #doesVehicleExistInDatabase > 0 then
                MySQL.update.await('UPDATE vehicleshop_stock SET stock = ? WHERE car = ? ', {doesVehicleExistInDatabase[1].stock+newStock, model})
                cb(true)
            else
                MySQL.insert.await('INSERT INTO vehicleshop_stock (car, stock) VALUES (?, ?) ', {model, tonumber(newStock)})
                cb(true)
            end
    end)
end)

ESX.RegisterServerCallback('fh_cardealer:AddStock2', function(src, cb, model, newStock)
    local xPlayer = ESX.GetPlayerFromId(src)
    
    local vehicle = MySQL.query.await('SELECT * FROM vehicles WHERE model = ?', {model})

    if #vehicle == 0 then
        xPlayer.showNotification('Modellen kunne ikke findes')
        return
    end
    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_cardealer', function(account)
        if account then
            print(account.money)
            if account.money >= vehicle[1].price*0.75 then
                print('1')
                account.removeMoney(vehicle[1].price*0.75)
                print('2')
            else
                xPlayer.showNotification('Der er ikke nok penge på firma kontoen!')
                return
                cb(false)
            end
                else
                    xPlayer.showNotification('Society account ikke fundet.')
                end
            local doesVehicleExistInDatabase = MySQL.query.await('SELECT * FROM vehicleshopmc_stock WHERE mc = ?', {model})
            if #doesVehicleExistInDatabase > 0 then
                MySQL.update.await('UPDATE vehicleshopmc_stock SET stock = ? WHERE mc = ? ', {doesVehicleExistInDatabase[1].stock+newStock, model})
                cb(true)
            else
                MySQL.insert.await('INSERT INTO vehicleshopmc_stock (mc, stock) VALUES (?, ?) ', {model, tonumber(newStock)})
                cb(true)
            end
    end)
end)

function sendToDiscord(color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message,
              ["footer"] = {
                  ["text"] = footer.. " ".. os.date("%x %X %p"),
              },
          }
        }
    PerformHttpRequest('https://discord.com/api/webhooks/1125718775145185332/hVBolvO9LNekv9hmNMi8ZXWFX8rFx-OUIQR3-UTuF8z-QKdJKyEHGK_-f6CNKq4dihjD', function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function sendToDiscord2(color, name, message, footer)
    local embed = {
          {
              ["color"] = color,
              ["title"] = "**".. name .."**",
              ["description"] = message,
              ["footer"] = {
                  ["text"] = footer.. " ".. os.date("%x %X %p"),
              },
          }
        }
    PerformHttpRequest('https://discord.com/api/webhooks/1125718775145185332/hVBolvO9LNekv9hmNMi8ZXWFX8rFx-OUIQR3-UTuF8z-QKdJKyEHGK_-f6CNKq4dihjD', function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end
