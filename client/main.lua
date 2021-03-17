Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

local FirstSpawn, PlayerLoaded = true, false
local InAction = false
IsDead = false
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end

	PlayerLoaded = true
	ESX.PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
	PlayerLoaded = true
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

AddEventHandler('playerSpawned', function()
	IsDead = false

	if FirstSpawn then
		exports.spawnmanager:setAutoSpawn(false) -- disable respawn
		FirstSpawn = false

		ESX.TriggerServerCallback('esx_ambulancejob:getDeathStatus', function(isDead)
			if isDead and Config.AntiCombatLog then
				while not PlayerLoaded do
					Citizen.Wait(1000)
				end

				ESX.ShowNotification(_U('combatlog_message'))
				RemoveItemsAfterRPDeath()
			end
		end)
	end
end)

-- Create blips
Citizen.CreateThread(function()
	for k,v in pairs(Config.Hospitals) do
		local blip = AddBlipForCoord(v.Blip.coords)

		SetBlipSprite(blip, v.Blip.sprite)
		SetBlipScale(blip, v.Blip.scale)
		SetBlipColour(blip, v.Blip.color)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(_U('hospital'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Disable most inputs when dead
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if IsDead then
			DisableAllControlActions(0)
			EnableControlAction(0, Keys['G'], true)
			EnableControlAction(0, Keys['T'], true)
			EnableControlAction(0, Keys['E'], true)
			EnableControlAction(0, Keys['F'], true)
            EnableControlAction(0, Keys['B'], true)
		else
			Citizen.Wait(500)
		end
	end
end)

function OnPlayerDeath()
	IsDead = true
	ESX.UI.Menu.CloseAll()
	TriggerServerEvent('esx_ambulancejob:setDeathStatus', true)

	StartDeathTimer()
	StartDistressSignal()

	StartScreenEffect('DeathFailOut', 0, false)
end

RegisterNetEvent('esx_ambulancejob:useItem')
AddEventHandler('esx_ambulancejob:useItem', function(itemName)
	ESX.UI.Menu.CloseAll()

	if itemName == 'medikit' then
		local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
		local playerPed = PlayerPedId()

		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

			Citizen.Wait(500)
			while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
				Citizen.Wait(0)
				DisableAllControlActions(0)
			end
	
			TriggerEvent('esx_ambulancejob:heal', 'big', true)
			ESX.ShowNotification(_U('used_medikit'))
		end)

	elseif itemName == 'bandage' then
		local lib, anim = 'anim@heists@narcotics@funding@gang_idle', 'gang_chatting_idle01' -- TODO better animations
		local playerPed = PlayerPedId()

		ESX.Streaming.RequestAnimDict(lib, function()
			TaskPlayAnim(playerPed, lib, anim, 8.0, -8.0, -1, 0, 0, false, false, false)

			Citizen.Wait(500)
			while IsEntityPlayingAnim(playerPed, lib, anim, 3) do
				Citizen.Wait(0)
				DisableAllControlActions(0)
			end

			TriggerEvent('esx_ambulancejob:heal', 'small', true)
			ESX.ShowNotification(_U('used_bandage'))
		end)
	end
end)

function StartDistressSignal()
	Citizen.CreateThread(function()
		local timer = Config.BleedoutTimer

		while timer > 0 and IsDead do
			Citizen.Wait(2)
			timer = timer - 30

			SetTextFont(7)
			SetTextScale(0.45, 0.45)
			SetTextColour(185, 185, 185, 255)
			SetTextDropshadow(0, 0, 0, 0, 255)
			SetTextEdge(1, 0, 0, 0, 255)
			SetTextDropShadow()
			SetTextOutline()
			BeginTextCommandDisplayText('STRING')
			AddTextComponentSubstringPlayerName(_U('distress_send'))
			EndTextCommandDisplayText(0.385, 0.025415)

			if IsControlPressed(0, Keys['G']) then
				SendDistressSignal()

				Citizen.CreateThread(function()
					Citizen.Wait(1000 * 60 * 5)
					if IsDead then
						StartDistressSignal()
					end
				end)

				break
			end
		end
	end)
end

function SendDistressSignal()
	local playerPed = PlayerPedId()
	PedPosition		= GetEntityCoords(playerPed)
	
	local PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z }

	ESX.ShowNotification(_U('distress_sent'))

    TriggerServerEvent('esx_addons_gcphone:startCall', 'ambulance', _U('distress_message'), PlayerCoords, {

		PlayerCoords = { x = PedPosition.x, y = PedPosition.y, z = PedPosition.z },
	})
end

function DrawGenericTextThisFrame()
    SetTextFont(4)
    SetTextScale(0.0, 0.5)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
end

function DrawGenericTextThisFrame2()
    SetTextFont(4)
    SetTextScale(0.0, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextCentre(true)
end

function DrawTextOnScreen(text, x, y, scale)
    SetTextFont(4)
    SetTextScale(scale, scale)
    SetTextCentre(true)
    SetTextDropshadow(2, 2, 0, 0, 0)
    SetTextEdge(1, 0, 0, 0, 205)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

function secondsToClock(seconds)
    local seconds, hours, mins, secs = tonumber(seconds), 0, 0, 0
    if seconds <= 0 then
        return 0, 0
    else
        local hours = string.format("%02.f", math.floor(seconds / 3600))
        local mins = string.format("%02.f", math.floor(seconds / 60 - (hours * 60)))
        local secs = string.format("%02.f", math.floor(seconds - hours * 3600 - mins * 60))
        return mins, secs
    end
end
function StartDeathTimer()
    local canPayFine = false
    if Config.EarlyRespawnFine then
        ESX.TriggerServerCallback(
            "esx_ambulancejob:checkBalance",
            function(canPay)
                canPayFine = canPay
            end
        )
    end
    local earlySpawnTimer = ESX.Math.Round(Config.EarlyRespawnTimer / 1000)
    local bleedoutTimer = ESX.Math.Round(Config.BleedoutTimer / 1000)
    Citizen.CreateThread(
        function()
            -- early respawn timer
            while earlySpawnTimer > 0 and IsDead do
                Citizen.Wait(1000)
                if earlySpawnTimer > 0 then
                    earlySpawnTimer = earlySpawnTimer - 1
                end
            end
            -- bleedout timer
            while bleedoutTimer > 0 and IsDead do
                Citizen.Wait(1000)
                if bleedoutTimer > 0 then
                    bleedoutTimer = bleedoutTimer - 1
                end
            end
        end
    )
    Citizen.CreateThread(
        function()
            local text, timeHeld
            -- early respawn timer
            while earlySpawnTimer > 0 and IsDead do
                Citizen.Wait(0)
                local mins, secs = secondsToClock(earlySpawnTimer)
                --text = _U("respawn_available_in", secondsToClock(earlySpawnTimer))
                --text = '~w~Respawn available in ~o~'..mins..' ~w~minutes & ~o~'..secs..' ~w~seconds.'
                --DrawGenericTextThisFrame()
                --SetTextEntry("STRING")
                --AddTextComponentString(text)
                --DrawText(0.5, 0.8)
                DrawTextOnScreen('~w~Respawn available in ~p~'..mins..' ~w~minutes & ~p~'..secs..' ~w~seconds.', 0.5, 0.8, 0.45)
            end
            -- bleedout timer
            while bleedoutTimer > 0 and IsDead do
                Citizen.Wait(0)
                local mins2, secs2 = secondsToClock(bleedoutTimer)
                if not Config.EarlyRespawnFine then
                    text = text.. '\nHold [~p~E~s~] to Respawn'
                    --text = text .. _U("respawn_bleedout_prompt")
                    --text2 = _U("respawn_bleedout_prompt2")
                    if IsControlPressed(0, Keys["E"]) and timeHeld > 60 then
                        RemoveItemsAfterRPDeath('grove')
                        break
                    elseif IsControlPressed(0, Keys["F"]) and timeHeld > 60 then
                        break
                    elseif IsControlPressed(0, Keys["B"]) and timeHeld > 60 then
                        break
                    end
                elseif Config.EarlyRespawnFine and canPayFine then
                   -- text = text .. _U("respawn_bleedout_fine", ESX.Math.GroupDigits(Config.EarlyRespawnFineAmount))
                   local reamount = ESX.Math.GroupDigits(Config.EarlyRespawnFineAmount)
                   local reamount2 = ESX.Math.GroupDigits(Config.KeepAPFineAmount)
                   --text = text.. '\nHold [~o~E~s~] to Respawn at Grove Street for ~o~$'..reamount..'~s~'
                    --text2 = _U("respawn_bleedout_fine2", 2500)
                    DrawTextOnScreen('\nYou will bleed out in ~p~'..mins2..' ~w~minutes and ~p~'..secs2..'~w~ seconds.', 0.5, 0.77, 0.45)
                    DrawTextOnScreen('\nHold [~p~E~s~] to Respawn at Grove Street for ~p~$'..reamount..'~s~', 0.5, 0.81, 0.45)
                    DrawTextOnScreen('\nHold [~p~F~s~] to Respawn at RZ Traintracks for ~p~$'..reamount..'~s~', 0.5, 0.85, 0.45)
                    DrawTextOnScreen('\nHold [~p~B~s~] to Respawn at Mirror Park with AP Pistol ~p~$'..reamount2..'~s~', 0.5, 0.89, 0.45)
                    if IsControlPressed(0, Keys["E"]) and timeHeld > 60 then
                        TriggerServerEvent("esx_ambulancejob:payFine")
                        RemoveItemsAfterRPDeath('grove')
                        break
                    elseif IsControlPressed(0, Keys["F"]) and timeHeld > 60 then
                        TriggerServerEvent("esx_ambulancejob:payFine")
                        RemoveItemsAfterRPDeath('rzgs')
                    elseif IsControlPressed(0, Keys["B"]) and timeHeld > 60 then
                        TriggerServerEvent("esx_ambulancejob:payFine2")
                        RemoveItemsAfterRPDeath('keepap')
                        break
                    end
                end
                if IsControlPressed(0, Keys["E"]) then
                    timeHeld = timeHeld + 1
                elseif IsControlPressed(0, Keys["F"]) then
                    timeHeld = timeHeld + 1
                elseif IsControlPressed(0, Keys["B"]) then
                    timeHeld = timeHeld + 1
                else
                    timeHeld = 0
                end
                --DrawGenericTextThisFrame2()
                --SetTextEntry("STRING")
                ---AddTextComponentString(text)
                --DrawText(0.5, 0.85)
                DrawTextOnScreen(text, 0.5, 0.8, 0.45)

                --DrawGenericTextThisFrame2()
                --SetTextEntry("STRING")
                --AddTextComponentString(text2)
                --DrawText(0.5, 0.93) --45
            end

            if bleedoutTimer < 1 and IsDead then
                RemoveItemsAfterRPDeath('grove')
            end
        end
    )
end
function RemoveItemsAfterRPDeath(location)
    TriggerServerEvent("esx_ambulancejob:setDeathStatus", false)
    Citizen.CreateThread(
        function()
            DoScreenFadeOut(800)
            while not IsScreenFadedOut() do
                Citizen.Wait(10)
            end
            ESX.TriggerServerCallback(
                "esx_ambulancejob:removeItemsAfterRPDeath",
                function()
                    local formattedCoords = {
                        x = Config.RespawnPoint.coords.x,
                        y = Config.RespawnPoint.coords.y,
                        z = Config.RespawnPoint.coords.z
                    }
                    local formattedCoords2 = {
                        x = Config.RespawnPoint2.coords.x,
                        y = Config.RespawnPoint2.coords.y,
                        z = Config.RespawnPoint2.coords.z
                    }
                    local formattedCoords3 = {
                        x = Config.RespawnPoint3.coords.x,
                        y = Config.RespawnPoint3.coords.y,
                        z = Config.RespawnPoint3.coords.z
                    }
                    if location == 'grove' then
                        ESX.SetPlayerData("lastPosition", formattedCoords)
                        ESX.SetPlayerData("loadout", {})
                        TriggerServerEvent("esx:updateLastPosition", formattedCoords)
                        RespawnPed(PlayerPedId(), formattedCoords, Config.RespawnPoint.heading)
                        StopScreenEffect("DeathFailOut")
                        DoScreenFadeIn(800)
                    elseif location == 'rzgs' then
                        ESX.SetPlayerData("lastPosition", formattedCoords2)
                        ESX.SetPlayerData("loadout", {})
                        TriggerServerEvent("esx:updateLastPosition", formattedCoords2)
                        RespawnPed(PlayerPedId(), formattedCoords2, Config.RespawnPoint2.heading)
                        StopScreenEffect("DeathFailOut")
                        DoScreenFadeIn(800)
                    elseif location == 'keepap' then
                        ESX.SetPlayerData("lastPosition", formattedCoords3)
                        TriggerServerEvent("esx:updateLastPosition", formattedCoords3)
                        RespawnPed(PlayerPedId(), formattedCoords3, Config.RespawnPoint3.heading)
                        StopScreenEffect("DeathFailOut")
                        DoScreenFadeIn(800)
                        ESX.SetPlayerData("loadout", {})
                    end
                end
            )
        end
    )
end
function RespawnPed(ped, coords, heading)
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, true, false)
    SetPlayerInvincible(ped, false)
    TriggerEvent("playerSpawned", coords.x, coords.y, coords.z)
    ClearPedBloodDamage(ped)
    ESX.UI.Menu.CloseAll()
end

AddEventHandler(
    "esx:onPlayerDeath",
    function(data)
        OnPlayerDeath()
    end
)

RegisterNetEvent("esx_ambulancejob:642352352352")
AddEventHandler(
    "esx_ambulancejob:642352352352",
    function()
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        TriggerServerEvent("esx_ambulancejob:setDeathStatus", false)
        Citizen.CreateThread(
            function()
                DoScreenFadeOut(800)
                while not IsScreenFadedOut() do
                    Citizen.Wait(50)
                end
                local formattedCoords = {
                    x = ESX.Math.Round(coords.x, 1),
                    y = ESX.Math.Round(coords.y, 1),
                    z = ESX.Math.Round(coords.z, 1)
                }
                ESX.SetPlayerData("lastPosition", formattedCoords)
                TriggerServerEvent("esx:updateLastPosition", formattedCoords)
                RespawnPed(playerPed, formattedCoords, 0.0)
                StopScreenEffect("DeathFailOut")
                DoScreenFadeIn(800)
            end
        )
    end
)

local cam = nil

local isDead = false

local angleY = 0.0
local angleZ = 0.0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        
        if (cam and isDead) then
            ProcessCamControls()
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        
        if (not isDead and NetworkIsPlayerActive(PlayerId()) and IsPedFatallyInjured(PlayerPedId())) then
            isDead = true
            
            StartDeathCam()
        elseif (isDead and NetworkIsPlayerActive(PlayerId()) and not IsPedFatallyInjured(PlayerPedId())) then
            isDead = false
            
            EndDeathCam()
        end
    end
end)

function StartDeathCam()
    ClearFocus()

    local playerPed = PlayerPedId()
    
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", GetEntityCoords(playerPed), 0, 0, 0, GetGameplayCamFov())

    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, false)
end

function EndDeathCam()
    ClearFocus()

    RenderScriptCams(false, false, 0, true, false)
    DestroyCam(cam, false)
    
    cam = nil
end

function ProcessCamControls()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    DisableFirstPersonCamThisFrame()

    local newPos = ProcessNewPosition()

    -- focus cam area
    SetFocusArea(newPos.x, newPos.y, newPos.z, 0.0, 0.0, 0.0)
    
    -- set coords of cam
    SetCamCoord(cam, newPos.x, newPos.y, newPos.z)
    
    -- set rotation
    PointCamAtCoord(cam, playerCoords.x, playerCoords.y, playerCoords.z + 0.5)
end

function ProcessNewPosition()
    local mouseX = 0.0
    local mouseY = 0.0
    
    -- keyboard
    if (IsInputDisabled(0)) then
        -- rotation
        mouseX = GetDisabledControlNormal(1, 1) * 8.0
        mouseY = GetDisabledControlNormal(1, 2) * 8.0
        
    -- controller
    else
        -- rotation
        mouseX = GetDisabledControlNormal(1, 1) * 1.5
        mouseY = GetDisabledControlNormal(1, 2) * 1.5
    end

    angleZ = angleZ - mouseX -- around Z axis (left / right)
    angleY = angleY + mouseY -- up / down
    -- limit up / down angle to 90°
    if (angleY > 89.0) then angleY = 89.0 elseif (angleY < -89.0) then angleY = -89.0 end
    
    local pCoords = GetEntityCoords(PlayerPedId())
    
    local behindCam = {
        x = pCoords.x + ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * (Config.radius + 0.5),
        y = pCoords.y + ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * (Config.radius + 0.5),
        z = pCoords.z + ((Sin(angleY))) * (Config.radius + 0.5)
    }
    local rayHandle = StartShapeTestRay(pCoords.x, pCoords.y, pCoords.z + 0.5, behindCam.x, behindCam.y, behindCam.z, -1, PlayerPedId(), 0)
    local a, hitBool, hitCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    
    local maxRadius = Config.radius
    if (hitBool and Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords) < Config.radius + 0.5) then
        maxRadius = Vdist(pCoords.x, pCoords.y, pCoords.z + 0.5, hitCoords)
    end
    
    local offset = {
        x = ((Cos(angleZ) * Cos(angleY)) + (Cos(angleY) * Cos(angleZ))) / 2 * maxRadius,
        y = ((Sin(angleZ) * Cos(angleY)) + (Cos(angleY) * Sin(angleZ))) / 2 * maxRadius,
        z = ((Sin(angleY))) * maxRadius
    }
    
    local pos = {
        x = pCoords.x + offset.x,
        y = pCoords.y + offset.y,
        z = pCoords.z + offset.z
    }
    
    
    -- Debug x,y,z axis
    --DrawMarker(1, pCoords.x, pCoords.y, pCoords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.03, 0.03, 5.0, 0, 0, 255, 255, false, false, 2, false, 0, false)
    --DrawMarker(1, pCoords.x, pCoords.y, pCoords.z, 0.0, 0.0, 0.0, 0.0, 90.0, 0.0, 0.03, 0.03, 5.0, 255, 0, 0, 255, false, false, 2, false, 0, false)
    --DrawMarker(1, pCoords.x, pCoords.y, pCoords.z, 0.0, 0.0, 0.0, -90.0, 0.0, 0.0, 0.03, 0.03, 5.0, 0, 255, 0, 255, false, false, 2, false, 0, false)
    
    return pos
end

Citizen.CreateThread(function()
    while true do

        Citizen.Wait(5)

        for i=1, #Config.revList do
            local revID   = Config.revList[i]
            local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), revID.coords.x, revID.coords.y, revID.coords.z, true)

            if distance < Config.MaxDistance and InAction == false then
		if not Config.AlwaysAllow then
		    ESX.TriggerServerCallback('revivescript:getConnectedEMS', function(amount)
			if amount < Config.ServiceCount then
			    --ESX.Game.Utils.DrawText3D({ x = revID.coords.x, y = revID.coords.y, z = revID.coords.z + 1 }, revID.text, 1.2, 2)
				DrawText3D({ x = revID.coords.x, y = revID.coords.y, z = revID.coords.z})

                	    if IsControlJustReleased(0, Keys['E']) then
                    		revActive(revID.coords.x, revID.coords.y, revID.coords.z, revID.heading, revID)
                    	    end						
			end
		    end)			
		else
		    ESX.Game.Utils.DrawText3D({ x = revID.coords.x, y = revID.coords.y, z = revID.coords.z + 1 }, revID.text, 0.5, 7)
				--DrawText3D({ x = revID.coords.x, y = revID.coords.y, z = revID.coords.z}, 'Test: ' .. revID.text)

                    if IsControlJustReleased(0, Keys['E']) then
                    	revActive(revID.coords.x, revID.coords.y, revID.coords.z, revID.heading, revID)
                    end				
		end
            end
        end
    end
end)

function RespawnPed(ped, coords, heading)
    SetEntityCoordsNoOffset(ped, 321.97, -590.64, 43.28, false, false, false, true)
    NetworkResurrectLocalPlayer(321.97, -590.64, 43.28, 157.03, true, false)
    SetPlayerInvincible(ped, false)
    TriggerEvent('playerSpawned', 321.97, -590.64, 43.28)
    ClearPedBloodDamage(ped)
end

function revActive(x, y, z, heading, source)
	ESX.TriggerServerCallback('revivescript:checkMoney', function(hasEnoughMoney)
	if hasEnoughMoney then
		InAction = true
		Citizen.CreateThread(function ()
			Citizen.Wait(5)
			local health = GetEntityHealth(PlayerPedId())
			if (health < 300)  then		
			if InAction == true then
				local formattedCoords = {
					x = 321.97,  
					y = -590.64,
					z = 43.28
				}

				local playerID = ESX.Game.GetPlayerServerId
			
				ESX.SetPlayerData('lastPosition', formattedCoords)
				ESX.SetPlayerData('loadout', {})
				TriggerServerEvent('esx_ambulancejob:revive', playerID)
				TriggerServerEvent('revivescript:pay')
				RespawnPed(PlayerPedId(), formattedCoords, 157.03)
				TriggerServerEvent('esx:updateLastPosition', formattedCoords)
				StopScreenEffect('DeathFailOut')
				DoScreenFadeIn(800)
				ESX.ShowNotification('You have been revived.')
				ClearPedTasks(GetPlayerPed(-1))
				FreezeEntityPosition(GetPlayerPed(-1), false)
				SetEntityCoords(GetPlayerPed(-1), x + 1.0, y, z)			
				InAction = false
			end

			elseif (health == 200) then
				ESX.ShowNotification('You do not need medical attention')
			end
		end)
	else
		ESX.ShowNotification('You do not have $' .. Config.Price .. ' to pay doctors.')
	end
	end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
    end
end)


--XAchse Westen Osten
--Yachse Norden Süden
--ZAchse oben unten

--gegenkathete = x
--ankathete = y
--hypotenuse = 1
--alpha = GetCamRot(cam).z
