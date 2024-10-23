ESX = exports['es_extended']:getSharedObject()
-- pickup, deliveries, basic, random
local CreatePed                       = CreatePed
local FreezeEntityPosition            = FreezeEntityPosition
local SetEntityInvincible             = SetEntityInvincible
local SetBlockingOfNonTemporaryEvents = SetBlockingOfNonTemporaryEvents
local SetModelAsNoLongerNeeded        = SetModelAsNoLongerNeeded
local RegisterNetEvent                = RegisterNetEvent
local AddBlipForCoord                 = AddBlipForCoord
local SetBlipSprite                   = SetBlipSprite
local SetBlipDisplay                  = SetBlipDisplay
local SetBlipScale                    = SetBlipScale
local SetBlipColour                   = SetBlipColour
local SetBlipAsShortRange             = SetBlipAsShortRange
local BeginTextCommandSetBlipName     = BeginTextCommandSetBlipName
local AddTextComponentString          = AddTextComponentString
local EndTextCommandSetBlipName       = EndTextCommandSetBlipName


utils = {}
peds = {}

function utils.createPed(name, coords)
    local model = lib.requestModel(name)

    if not model then return end

    local ped = CreatePed(0, model, coords, false, false)

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(model)

    table.insert(peds, ped)

    return ped
end

function utils.showNotification(msg, type)
    lib.notify({
        title = 'Sortemarkede',
        description = msg,
        type = type and type or 'info'
    })
end

function utils.debug(msg)
    if Config.Debug then
        print(("^3DEBUG: %s ^7"):format(msg))
    end
end

function utils.getCurrentLocation()
    local playerPed = cache.coords and cache.coords or cache.ped
    local playerCoords = cache.coords or GetEntityCoords(playerPed)
    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    local currentArea = GetLabelText(tostring(GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)))
    local currentLocation = currentArea
    if not zone then zone = "UNKNOWN" end

    if currentStreetName and currentStreetName ~= "" then
        currentLocation = currentLocation .. ", " .. currentArea
    end

    return currentLocation
end

function utils.createBlip(data)
    local blip = AddBlipForCoord(data.pos)
    SetBlipSprite(blip, data.type)
    SetBlipDisplay(blip, 6)
    SetBlipScale(blip, data.scale)
    SetBlipColour(blip, data.colour)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data.name)
    EndTextCommandSetBlipName(blip)

    return blip
end

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    for k, v in pairs(peds) do
        if DoesEntityExist(v) then
            DeletePed(v)
        end
    end
end)

function debugPrint(...)
    if not Config.Debug then return end
    local args <const> = { ... }
  
    local appendStr = ''
    for _, v in ipairs(args) do
      appendStr = appendStr .. ' ' .. tostring(v)
    end
    local msgTemplate = '^3[%s]^0%s'
    local finalMsg = msgTemplate:format(GetCurrentResourceName(), appendStr)
    print(finalMsg)
  end
  

Citizen.CreateThread(function()
    while ESX == nil do
        ESX = exports["es_extended"]:getSharedObject()
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()

    local blip = utils.createBlip({
        pos = vector2(-33.0088, -1097.7568),
        type = 304,
        scale = 0.85,
        colour = 5,
        name = "PDM"
    })
    
    local blip = utils.createBlip({
        pos = vector2(289.2677, -1159.5129),
        type = 226,
        scale = 0.85,
        colour = 3,
        name = "Sanders MC"
    })
end)



CheckJob = function(job)
    if ESX.GetPlayerData().job.name == 'cardealer' then
        return true
    end
    return false
end

CheckGrade = function(job)
    if ESX.GetPlayerData().job.name == 'cardealer' then
    	if ESX.GetPlayerData().job.grade_name == 'boss' then
        	return true
    	end
    	return false
	end
end

RegisterNetEvent('fh_cardealer:price')
AddEventHandler('fh_cardealer:price', function()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'get_price', {
        title = 'Skriv modellen på køretøjet',
    }, function(data2, menu2)
        if data2.value then
            menu2.close()
            ESX.TriggerServerCallback('nat_cardealer:GetVehiclePrice', function(price)
                ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'fh_cardealer_price', {
                    title = 'Pris',
                    align = 'left',
                    elements = { label = data2.value .. " - Pris: " .. price}
                }, function(data, menu)
                end, function(data, menu)
                    menu.close()
                end)
            end, data2.value)
        end
    end, function(data2, menu2)
        menu2.close()
    end)
end)


RegisterNetEvent('fh_cardealer:open')
AddEventHandler('fh_cardealer:open', function()
    lib.registerContext({
        id = 'bilforhandler_menu',
        title = 'Bilforhandler | Oversigt',
        options = {
            {
                title = 'Chef interaktioner',
                description = 'Her kan chefen, ansætte, fyr, og meget mere indefor bilforhandlern.',
                icon = 'fa-solid fa-money-bill',
                onSelect = function()
                    if PlayerData.job.grade_name == 'boss' then
                        TriggerServerEvent("esx_jobs:openCompanyAdmin")
                        lib.notify({
                            title = ' ',
                            description = 'Du har åbnet boss menuen.',
                            position = 'top',
                            type = 'inform'
                        })
                    else
                        lib.notify({
                            title = ' ',
                            description = 'Du kan ikke åbne boss menuen.',
                            position = 'top',
                            type = 'inform'
                        })
                    end
                end
            },
            {
                title = 'Firma lagert',
                description = 'Check vilket biler der på lager hos firmaet, og se prisen på dem.',
                icon = 'fa-solid fa-box',
                onSelect = function()
                    ESX.TriggerServerCallback('fh_cardealer:GetVehicleStock', function(data)
                        lib.registerContext({
                            id = 'bilforhandler_firmalager',
                            title = 'Bilforhandler | Lagert',
                            menu = 'bilforhandler_menu',
                            options = data
                        })
                        lib.showContext('bilforhandler_firmalager')
                    end)
                end
            },
            {
                title = 'Indkøb bil til Fabrik',
                description = 'Indkøb en bil ind til firmaet fra Negation Biler A/S.',
                icon = 'fa-solid fa-cart-shopping',
                onSelect = function()
                    local input = lib.inputDialog('Indkøb bil til Fabrik', {
                        { type = 'input', label = 'Model:', required = true },
                        { type = 'number', label = 'Antal:', required = true, min = 1, max = 99 },
                        { type = 'checkbox', label = 'Er modelen godkendt af Negation A/S? (ligegyldig)' },
                        { type = 'date', label = 'Dato købt:', required = true, icon = 'fa-solid fa-calendar-check', default = true, format = 'MM/DD/YYYY'}
                    })

                    if not input[1] then return end

                    ESX.TriggerServerCallback('fh_cardealer:AddStock', function(cb)
                        if cb then
                            lib.notify({
                                title = '',
                                description = 'Du har bestilt '..input[2]..' '..input[1]..' hjem til firmaet ',
                                type = "success"
                            })
                        else
                            lib.notify({
                                title = '',
                                description = 'Du kunne ikke bestile '..input[2]..' '..input[1]..' hjem til firmaet ',
                                type = "error"
                            })
                        end
                    end, input[1], input[2])
                end
            },
            {
                title = 'Sælg et køretøj',
                description = 'Sælg et køretøj til den nærmeste person! Husk at personen skal være tæt på dig.',
                icon = 'fa-solid fa-car',
                onSelect = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
                    if closestPlayer ~= -1 and closestDistance <= 3.0 then
                        ESX.TriggerServerCallback('fisk_vehicleshop:getNames', function(name)
                            local input = lib.inputDialog('Sælg et Køretøj', {
                                { type = 'input', placeholder = name, label = 'Køber:', disabled = true },
                                { type = 'input', label = 'Model:', required = true },
                                { type = 'checkbox', label = 'Er købern kendt af Negation A/S', required = true },
                                { type = 'input', label = 'Køretøjs Navn:', required = true },
                                { type = 'checkbox', label = 'Er modelen godkendt af Negation A/S?', required = true },
                            })

                            if not input[2] then
                                lib.notify({
                                    title = '',
                                    description = 'Du skal udfylde alle felterne!',
                                    type = "error"
                                })
                            end

                            local plate = GeneratePlate()

                            ESX.TriggerServerCallback('fh_cardealer:sellVehicle', function(success)
                                return
                            end, GetPlayerServerId(closestPlayer), input[2], plate, input[4])
                        end, GetPlayerServerId(closestPlayer))
                    else
                        lib.notify({
                            title = '',
                            description = 'Der er ikke nogen personer tæt på dig!',
                            type = "error"
                        })
                    end
                end
            }
        }
    })
    lib.notify({
        title = '',
        description = 'Du har åbnet bilforhandler computern',
        type = 'success'
    })
    lib.showContext('bilforhandler_menu')
end)

RegisterNetEvent('fisk_bilforhandler:requestpurchase')
AddEventHandler('fisk_bilforhandler:requestpurchase', function(model, price, plate, carname, cardealer)
    local alert = lib.alertDialog({
        content = 'Ville du købe en '..carname..' for '..price..' DKK?',
    })

    if alert == 'confirm' then
        TriggerServerEvent('fisk_bilforhandler:purchasecar', model, price, plate, cardealer, carname, true)
    else
        TriggerServerEvent('fisk_bilforhandler:purchasecar', model, price, plate, cardealer, carname, false)
    end
end)

RegisterNetEvent('fisk_bilforhandler:requestpurchase2')
AddEventHandler('fisk_bilforhandler:requestpurchase2', function(model, price, plate, carname, cardealer)
    local alert = lib.alertDialog({
        content = 'Ville du købe en '..carname..' for '..price..' DKK?',
    })

    if alert == 'confirm' then
        TriggerServerEvent('fisk_bilforhandler:purchasecar2', model, price, plate, cardealer, carname, true)
    else
        TriggerServerEvent('fisk_bilforhandler:purchasecar2', model, price, plate, cardealer, carname, false)
    end
end)

RegisterNetEvent('fisk_purchased:cardealer', function(choice, carname, price)
    if choice then
        lib.notify({
            title = '',
            description = 'Vedkommne har købt en '..carname..' for '..price..' DKK!',
            type = 'success'
        })
    else
        lib.notify({
            title = '',
            description = 'Vedkommne valgte ikke at købe en '..carname,
            type = 'error'
        })
    end
end)

RegisterNetEvent('meka_cardealer:demomenu', function(demo)
    lib.registerContext({
        id = 'cardealer_showdemo',
        title = 'Bilforhandler | Demo',
        options = {
            {
                title = 'Fremvis et Køretøj',
                description = 'Fremvis et køretøj på platformen ud fra den indtastet model.',
                icon = 'fa-solid fa-car',
                onSelect = function()
                    TriggerEvent('meka_cardealer:spawndemo', demo.CarLoc)
                end
            },
            {
                title = 'Fjern Demo Køretøj',
                description = 'Fjern nærmeste demo køretøj til platformen.',
                icon = 'fa-solid fa-trash',
                onSelect = function()
                    TriggerEvent('meka_cardealer:removedemo', demo.CarLoc)
                end
            }
        }
    })
    lib.notify({
        title = '',
        description = 'Demo menu åbnet',
        position = 'top',
        type = 'success'
    })
    lib.showContext('cardealer_showdemo')
end)


RegisterNetEvent('meka_cardealer:spawndemo')
AddEventHandler('meka_cardealer:spawndemo', function(loc)

    local player = GetPlayerPed(-1)
    local playerCorods = GetEntityCoords(player)

    local coordsatspawn = vector3(loc.x, loc.y, loc.z)
    local headingatspawn = loc.h

    local input = lib.inputDialog('Skirv modellen på køretøjet', {
        {type = 'input', label = 'Model', required = true},
    })

    local alert = lib.alertDialog({
        header = "Bilforhandler",
        content = 'Er det den her model som du har valgt: ' .. input[1],
        centered = true
    })

    if not alert then return end

    if input then
        ESX.Game.SpawnVehicle(input[1], coordsatspawn, headingatspawn, function(vehicle)
            SetVehicleNumberPlateText(vehicle, 'DEMO')
            lib.notify({
                title = '',
                description = 'Køretøjet blev fremvist!',
                position = 'top',
                type = 'success'
            })
            exports['t1ger_keys']:GiveTemporaryKeys(GetVehicleNumberPlateText(vehicle), GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), "DEMO")
            local model = string.lower(input[1])
            TriggerServerEvent('fh_cardealer:logdemo', model)
        end)
    else
        lib.notify({
            title = '',
            description = 'Aktionen blev annulerret!',
            position = 'top',
            type = 'error'
        })
        lib.showContext('cardealer_showdemo')
    end
end)

local distanceToCheck = 1.0
local numRetries = 1

RegisterNetEvent( "meka_cardealer:removedemo" )
AddEventHandler( "meka_cardealer:removedemo", function(loc)
    local player = GetPlayerPed(-1)
    local playerCorods = GetEntityCoords(player)

    local coordsatspawn = vector3(loc.x, loc.y, loc.z)
    local headingatspawn = loc.h

    if ( DoesEntityExist( player ) and not IsEntityDead( player ) ) then 
        local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords( player, 0.0, distanceToCheck, 0.0 )
        local vehicle = GetVehicleInDirection( player, coordsatspawn, inFrontOfPlayer )
        print(coordsatspawn)
        print(vehicle)

        if ( DoesEntityExist( vehicle ) ) then 
            DeleteGivenVehicle( vehicle, numRetries )
        else 
            lib.notify({
                title = '',
                description = 'Der er ingen køretøjer i nærheden!',
                type = 'error',
                position = 'top'
            })
        end 
    end 
end)

function DeleteGivenVehicle( veh, timeoutMax )
    local timeout = 0 
    local plate = string.lower(GetVehicleNumberPlateText(veh))

    SetEntityAsMissionEntity( veh, true, true )

    if string.find(plate, 'demo') then
        ESX.Game.DeleteVehicle(veh)
        lib.notify({
            title = '',
            description = 'Køretøjet blev fjernet!',
            type = 'success'
        })
    else
        lib.notify({
            title = '',
            description = 'Fejl! Dette er ikke et DEMO køretøj!',
            type = 'error'
        })
    end
    if ( DoesEntityExist( veh ) ) then
        while ( DoesEntityExist( veh ) and timeout < timeoutMax ) do 
            if ( not DoesEntityExist( veh ) ) then 
            end 

            timeout = timeout + 1 
            Citizen.Wait( 500 )

            if ( DoesEntityExist( veh ) and ( timeout == timeoutMax - 1 ) ) then
                --exports['mythic_notify']:DoLongHudText('error', 'Der er ingen køretøjer i nærheden!')
                lib.notify({
                    title = '',
                    description = 'Der er ingen køretøjer i nærheden!',
                    type = 'error'
                })
            end 
        end 
    end 
end 

function GetVehicleInDirection( entFrom, coordFrom, coordTo )
	local rayHandle = StartShapeTestCapsule( coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 5.0, 10, entFrom, 7 )
    local _, _, _, _, vehicle = GetShapeTestResult( rayHandle )
    
    if ( IsEntityAVehicle( vehicle ) ) then 
        return vehicle
    end 
end

Citizen.CreateThread(function()
    for k,v in pairs(Config.Computers) do
        exports.ox_target:addBoxZone({
            coords = v,
            size = vec3(1, 1, 1),
            --rotation = 42,
            options = {
                {
                    event = "fh_cardealer:open",
                    icon = 'fa-solid fa-car',
                    label = 'Tilgå Papire',
                    groups = { 'cardealer' },
                },
            },
        })
    end
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Previews) do
        exports.ox_target:addBoxZone({
            coords = v.MenuLoc,
            size = vec3(3, 3, 3),
            --rotation = 42,
            options = {
                {
                    icon = 'fa-solid fa-car',
                    label = 'Tilgå Demo Preview',
                    groups = { 'cardealer' },
                    onSelect = function()
                        TriggerEvent('meka_cardealer:demomenu', v)
                    end
                }
            },
        })
    end
end)





-- SANDERS

local SandersDEMOVeh = {}
local SandersDemoVehTarget = {}

function spawnVehicle(veh)
    local model = GetHashKey(veh.Model)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end

    local heading = veh.Heading

    local vehicle = CreateVehicle(model, veh.Loc.x, veh.Loc.y, veh.Loc.z, heading, true, false)

    local oxtarget
    oxtarget = exports.ox_target:addBoxZone({
        coords = vector3(veh.Loc.x, veh.Loc.y, veh.Loc.z),
        size = vector3(1, 1, 1),
        drawSprite = false,
        options = {
            {
                event = "fh_cardealer:open",
                icon = 'fa-solid fa-motorcycle',
                label = 'Udstillings Menu',
                groups = { 'cardealer' },
                onSelect = function()
                    lib.registerContext({
                        id = 'sandersmc_showcase',
                        title = 'Udstillings Menu',
                        options = {
                            {
                                title = 'Nuværrende Model: '.. veh.Model,
                                description = 'Tryk for at ændre moddelen som bliver fremvist.',
                                icon = 'fa-solid fa-motorcycle',
                                onSelect = function()
                                    local input = lib.inputDialog('Indtast den nye Model', {'Model:'})

                                    if not input then return end

                                    local vehData = {Heading = veh.Heading, Loc = vector3(veh.Loc.x, veh.Loc.y, veh.Loc.z), Model = input[1]}
                                    DeleteVehicle(vehicle)
                                    spawnVehicle(vehData)
                                    exports.ox_target:removeZone(oxtarget)
                                end
                            }
                        }
                    })
                    lib.notify({
                        title = '',
                        description = 'Udstillings Menu åbnet',
                        position = 'top',
                        type = 'success'
                    })
                    lib.showContext('sandersmc_showcase')
                end
            }
        }
    })

    table.insert(SandersDEMOVeh, {veh = vehicle, tar = target})
end

Citizen.CreateThread(function()
    for k,v in pairs(Config.Sanders.Random) do
        spawnVehicle(v)
    end
end)

RegisterNetEvent('meka_cardealer:sanders:open')
AddEventHandler('meka_cardealer:sanders:open', function()
    lib.registerContext({
        id = 'sandersmc_menu',
        title = 'Sanders MC | Oversigt',
        options = {
            {
                title = 'Chef interaktioner',
                description = 'Her kan chefen, ansætte, fyr, og meget mere indefor bilforhandlern.',
                icon = 'fa-solid fa-money-bill',
                onSelect = function()
                    if PlayerData.job.grade_name == 'boss' then
                        TriggerServerEvent("esx_jobs:openCompanyAdmin")
                        lib.notify({
                            title = ' ',
                            description = 'Du har åbnet boss menuen.',
                            position = 'top',
                            type = 'inform'
                        })
                    else
                        lib.notify({
                            title = ' ',
                            description = 'Du kan ikke åbne boss menuen.',
                            position = 'top',
                            type = 'inform'
                        })
                    end
                end
            },
            {
                title = 'Firma lagert',
                description = 'Check vilket motorcykler der på lager hos firmaet, og se prisen på dem.',
                icon = 'fa-solid fa-box',
                onSelect = function()
                    ESX.TriggerServerCallback('fh_cardealer:GetVehicleStock2', function(data)
                        lib.registerContext({
                            id = 'bilforhandler_firmalager2',
                            title = 'Sanders MC | Lagert',
                            menu = 'sandersmc_menu',
                            options = data
                        })
                        lib.showContext('bilforhandler_firmalager2')
                    end)
                end
            },
            {
                title = 'Indkøb motercykel til Fabrik',
                description = 'Indkøb en bil ind til firmaet fra Negation Motercykler A/S.',
                icon = 'fa-solid fa-cart-shopping',
                onSelect = function()
                    local input = lib.inputDialog('Indkøb bil til Fabrik', {
                        { type = 'input', label = 'Model:', required = true },
                        { type = 'number', label = 'Antal:', required = true, min = 1, max = 99 },
                        { type = 'checkbox', label = 'Er modelen godkendt af Negation A/S? (ligegyldig)' },
                        { type = 'date', label = 'Dato købt:', required = true, icon = 'fa-solid fa-calendar-check', default = true, format = 'MM/DD/YYYY'}
                    })

                    if not input[1] then return end

                    ESX.TriggerServerCallback('fh_cardealer:AddStock2', function(cb)
                        if cb then
                            lib.notify({
                                title = '',
                                description = 'Du har bestilt '..input[2]..' '..input[1]..' hjem til firmaet ',
                                type = "success"
                            })
                        else
                            lib.notify({
                                title = '',
                                description = 'Du kunne ikke bestile '..input[2]..' '..input[1]..' hjem til firmaet ',
                                type = "error"
                            })
                        end
                    end, input[1], input[2])
                end
            },
            {
                title = 'Sælg et køretøj',
                description = 'Sælg et køretøj til den nærmeste person! Husk at personen skal være tæt på dig.',
                icon = 'fa-solid fa-motorcycle',
                onSelect = function()
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer(GetEntityCoords(PlayerPedId()))
                    if closestPlayer ~= -1 and closestDistance <= 3.0 then
                        ESX.TriggerServerCallback('fisk_vehicleshop:getNames', function(name)
                            local input = lib.inputDialog('Sælg et Køretøj', {
                                { type = 'input', placeholder = name, label = 'Køber:', disabled = true },
                                { type = 'input', label = 'Model:', required = true },
                                { type = 'checkbox', label = 'Er købern kendt af Negation A/S', required = true },
                                { type = 'input', label = 'Køretøjs Navn:', required = true },
                                { type = 'checkbox', label = 'Er modelen godkendt af Negation A/S?', required = true },
                            })

                            if not input[2] then
                                lib.notify({
                                    title = '',
                                    description = 'Du skal udfylde alle felterne!',
                                    type = "error"
                                })
                            end

                            local plate = GeneratePlate()

                            ESX.TriggerServerCallback('fh_cardealer:sellVehicle2', function(success)
                                return
                            end, GetPlayerServerId(closestPlayer), input[2], plate, input[4])
                        end, GetPlayerServerId(closestPlayer))
                    else
                        lib.notify({
                            title = '',
                            description = 'Der er ikke nogen personer tæt på dig!',
                            type = "error"
                        })
                    end
                end
            }
        }
    })
    lib.notify({
        title = '',
        description = 'Du har åbnet bilforhandler computern',
        type = 'success'
    })
    lib.showContext('sandersmc_menu')
end)

Citizen.CreateThread(function()
    for k,v in pairs(Config.Sanders.Computer) do
        exports.ox_target:addBoxZone({
            coords = v,
            size = vec3(.7, .7, .7),
            options = {
                {
                    event = "meka_cardealer:sanders:open",
                    icon = 'fa-solid fa-motorcycle',
                    label = 'Tilgå Computer',
                    groups = { 'cardealer' },
                },
            },
        })
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, vehicle in ipairs(SandersDEMOVeh) do
            if DoesEntityExist(vehicle.veh) then
                DeleteEntity(vehicle.veh)
            end
        end
    end
end)