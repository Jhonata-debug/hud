-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRPS = Tunnel.getInterface("vRP")
vRP = Proxy.getInterface("vRP")

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONNECTION
-----------------------------------------------------------------------------------------------------------------------------------------
Hensa = {}
Tunnel.bindInterface("hud",Hensa)
vSERVER = Tunnel.getInterface("hud")

-----------------------------------------------------------------------------------------------------------------------------------------
-- GLOBAL
-----------------------------------------------------------------------------------------------------------------------------------------
Display = false

-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local Hood = false
local Gemstone = 0
local Pause = false

-----------------------------------------------------------------------------------------------------------------------------------------
-- PRINCIPAL
-----------------------------------------------------------------------------------------------------------------------------------------
local Health = 100
local Armour = 0

-----------------------------------------------------------------------------------------------------------------------------------------
-- THIRST
-----------------------------------------------------------------------------------------------------------------------------------------
local Thirst = 100 -- Ajustado para 100 para evitar perda imediata de vida
local ThirstTimer = 0
local ThirstAmount = 90000
local ThirstDelay = GetGameTimer()

-----------------------------------------------------------------------------------------------------------------------------------------
-- HUNGER
-----------------------------------------------------------------------------------------------------------------------------------------
local Hunger = 100 -- Ajustado para 100 para evitar perda imediata de vida
local HungerTimer = 0
local HungerAmount = 90000
local HungerDelay = GetGameTimer()

-----------------------------------------------------------------------------------------------------------------------------------------
-- STRESS
-----------------------------------------------------------------------------------------------------------------------------------------
local Stress = 0
local StressTimer = 0

-----------------------------------------------------------------------------------------------------------------------------------------
-- COUGH
-----------------------------------------------------------------------------------------------------------------------------------------
local Cough = 0
local CoughTimer = 0

-----------------------------------------------------------------------------------------------------------------------------------------
-- WANTED
-----------------------------------------------------------------------------------------------------------------------------------------
local Wanted = 0
local WantedMax = 0
local WantedTimer = 0

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPOSED
-----------------------------------------------------------------------------------------------------------------------------------------
local Reposed = 0
local ReposedMax = 0
local ReposedTimer = 0

-----------------------------------------------------------------------------------------------------------------------------------------
-- LUCK
-----------------------------------------------------------------------------------------------------------------------------------------
local Luck = 0
local LuckTimer = 0

-----------------------------------------------------------------------------------------------------------------------------------------
-- DEXTERITY
-----------------------------------------------------------------------------------------------------------------------------------------
local Dexterity = 0
local DexterityTimer = 0

-----------------------------------------------------------------------------------------------------------------------------------------
-- OXIGEN
-----------------------------------------------------------------------------------------------------------------------------------------
local Mask = nil
local Tank = nil
local Oxigen = 100
local OxigenTimers = GetGameTimer()
local Oxygen = 100

-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADTIMER
-----------------------------------------------------------------------------------------------------------------------------------------
CreateThread(function()
	while true do
		if LocalPlayer["state"]["Active"] then
			local Ped = PlayerPedId()

			if IsPauseMenuActive() then
				if not Pause and Display then
					SendNUIMessage({ Action = "Body", Status = false })
					Pause = true
				end
			else
				if Display then
					if Pause then
						SendNUIMessage({ Action = "Body", Status = true })
						Pause = false
					end

					local Coords = GetEntityCoords(Ped)
					local Armouring = GetPedArmour(Ped)
					local Healing = GetEntityHealth(Ped) - 100
					local Oxygening = GetPlayerUnderwaterTimeRemaining(PlayerId()) * 10

					if Health ~= Healing then
						if Healing < 0 then
							Healing = 0
						end

						SendNUIMessage({ Action = "Health", Number = Healing, Status = IsPedInAnyVehicle(Ped) })
						Health = Healing
					end

					if Armour ~= Armouring then
						SendNUIMessage({ Action = "Armour", Number = Armouring })
						Armour = Armouring
					end

					if Oxygen ~= Oxygening then
						SendNUIMessage({ Action = "Oxygen", Number = Oxygening })
						Oxygen = Oxygening
					end

					SendNUIMessage({ Action = "Clock", Hours = GlobalState["Hours"], Minutes = GlobalState["Minutes"] })

					if LocalPlayer["state"]["Location"] == "South" then
						SendNUIMessage({ Action = "Weather", Weather = ClassWeather(GlobalState["WeatherS"]) })
						SendNUIMessage({ Action = "Temperature", Temperature = GlobalState["TemperatureS"] })
					elseif LocalPlayer["state"]["Location"] == "North" then
						SendNUIMessage({ Action = "Weather", Weather = ClassWeather(GlobalState["WeatherN"]) })
						SendNUIMessage({ Action = "Temperature", Temperature = GlobalState["TemperatureN"] })
					end
				end
			end

			if Luck > 0 and LuckTimer <= GetGameTimer() then
				Luck = Luck - 1
				LuckTimer = GetGameTimer() + 1000
				SendNUIMessage({ Action = "Luck", Number = Luck })
			end

			if Dexterity > 0 and DexterityTimer <= GetGameTimer() then
				Dexterity = Dexterity - 1
				DexterityTimer = GetGameTimer() + 1000
				SendNUIMessage({ Action = "Dexterity", Number = Dexterity })
			end

			if Wanted > 0 and WantedTimer <= GetGameTimer() then
				Wanted = Wanted - 1
				WantedTimer = GetGameTimer() + 1000
				SendNUIMessage({ Action = "Wanted", Number = Wanted })
			end

			if Reposed > 0 and ReposedTimer <= GetGameTimer() then
				Reposed = Reposed - 1
				ReposedTimer = GetGameTimer() + 1000
				SendNUIMessage({ Action = "Reposed", Number = Reposed })
			end

			SendNUIMessage({ Action = "Stress", Number = Stress, Vehicle = IsPedInAnyVehicle(Ped) })
			SendNUIMessage({ Action = "Cough", Number = Cough, Vehicle = IsPedInAnyVehicle(Ped) })

			if GetEntityHealth(Ped) > 100 then
				if Hunger < 15 and HungerTimer <= GetGameTimer() then
					HungerTimer = GetGameTimer() + 10000
					ApplyDamageToPed(Ped, math.random(2), false)
					TriggerEvent("Notify", "hunger", "Sofrendo com a <b>Fome</b>.", "Fome", 2500)
				end

				if Thirst < 15 and ThirstTimer <= GetGameTimer() then
					ThirstTimer = GetGameTimer() + 10000
					ApplyDamageToPed(Ped, math.random(2), false)
					TriggerEvent("Notify", "thirst", "Sofrendo com a <b>Sede</b>.", "Sede", 2500)
				end

				if Stress >= 40 and StressTimer <= GetGameTimer() then
					StressTimer = GetGameTimer() + 10000
					TriggerEvent("Notify", "amarelo", "Sofrendo com o <b>Estresse</b>.", "Estresse", 2500)

					AnimpostfxPlay("MenuMGIn")
					SetTimeout(1500, function()
						AnimpostfxStop("MenuMGIn")
					end)
				end
				
				if Cough >= 20 and CoughTimer <= GetGameTimer() then
					CoughTimer = GetGameTimer() + 30000
					ApplyDamageToPed(Ped, math.random(2), false)
					TriggerEvent("Notify", "amarelo", "Sofrendo com a <b>Tosse</b>.", "Tosse", 2500)
				
					vRP.PlayAnim(true, { "timetable@gardener@smoking_joint", "idle_cough" }, true)
					SetTimeout(4000, function()
						vRP.Destroy("one")
						vSERVER.GetCough(math.random(3, 6))
					end)
				end				
			end
		end

		Wait(1000)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- STATUS COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("status", function(source, args)
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped) - 100
    local armour = GetPedArmour(ped)
    local hunger = Hunger
    local thirst = Thirst
    local stress = Stress
    local cough = Cough
    local colete = Colet or 0  -- Defina um valor padrão se necessário

    TriggerEvent("chat:addMessage", {
        args = {
            "Status:",
            string.format("Vida: %d", health),
            string.format("Armadura: %d", armour),
            string.format("Fome: %d", hunger),
            string.format("Sede: %d", thirst),
            string.format("Estresse: %d", stress),
            string.format("Tosse: %d", cough),
            string.format("Colete: %d", colete)
        }
    })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- PRINT STATUS COMMAND
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("printstatus", function(source, args)
    local ped = PlayerPedId()
    local health = GetEntityHealth(ped) - 100
    local armour = GetPedArmour(ped)
    local hunger = Hunger
    local thirst = Thirst
    local stress = Stress
    local cough = Cough
    local colete = Colet or 0  -- Defina um valor padrão se necessário

    print(string.format("Status Atual: \nVida: %d\nArmadura: %d\nFome: %d\nSede: %d\nEstresse: %d\nTosse: %d\nColete: %d",
        health, armour, hunger, thirst, stress, cough, colete))
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:VOIP
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Voip",function(Number)
	local Target = { "Baixo","Normal","Médio","Alto","Megafone" }

	SendNUIMessage({ Action = "Voip", Voip = Target[Number] })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:VOICE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Voice",function(Status)
	SendNUIMessage({ Action = "Voice", Status = Status and "#6fa9dc" or "#ccc" })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:WANTED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Wanted")
AddEventHandler("hud:Wanted",function(Seconds)
	WantedMax = Seconds
	Wanted = Seconds
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- WANTED
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Wanted", function()
	return Wanted > 0 and true or false
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:REPOSED
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Reposed")
AddEventHandler("hud:Reposed",function(Seconds)
	Reposed = Seconds
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPOSED
-----------------------------------------------------------------------------------------------------------------------------------------
exports("Reposed",function()
	return Reposed > 0 and true or false
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD:ACTIVE
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("hud:Active",function(Status)
	SendNUIMessage({ Action = "Body", Status = Status })
	Display = Status
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("hud",function()
	Display = not Display
	SendNUIMessage({ Action = "Body", Status = Display })

	if not Display then
		if IsMinimapRendering() then
			DisplayRadar(false)
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HEALTH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Health")
AddEventHandler("hud:Health",function(HealthStatus)
	Health = HealthStatus
	SendNUIMessage({ Action = "Health", Number = Health })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ARMOUR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Armour")
AddEventHandler("hud:Armour",function(ArmourStatus)
	Armour = ArmourStatus
	SendNUIMessage({ Action = "Armour", Number = Armour })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- OXYGEN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Oxygen")
AddEventHandler("hud:Oxygen",function(OxygenStatus)
	Oxygen = OxygenStatus
	SendNUIMessage({ Action = "Oxygen", Number = Oxygen })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- STRESS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Stress")
AddEventHandler("hud:Stress",function(StressStatus)
	Stress = StressStatus
	SendNUIMessage({ Action = "Stress", Number = Stress })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- COUGH
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Cough")
AddEventHandler("hud:Cough",function(CoughStatus)
	Cough = CoughStatus
	SendNUIMessage({ Action = "Cough", Number = Cough })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HUNGER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Hunger")
AddEventHandler("hud:Hunger",function(HungerStatus)
	Hunger = HungerStatus
	SendNUIMessage({ Action = "Hunger", Number = Hunger })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- THIRST
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Thirst")
AddEventHandler("hud:Thirst",function(ThirstStatus)
	Thirst = ThirstStatus
	SendNUIMessage({ Action = "Thirst", Number = Thirst })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- COLETE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("hud:Colet")
AddEventHandler("hud:Colet",function(ColetStatus)
	SendNUIMessage({ Action = "Colet", Number = ColetStatus })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- PROGRESS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("Progress")
AddEventHandler("Progress",function(Status)
	SendNUIMessage({ Action = "Progress", Status = Status })
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ANIMPOSTFX
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("animpostfx")
AddEventHandler("animpostfx",function(Name, Status)
	if Status then
		AnimpostfxPlay(Name)
	else
		AnimpostfxStop(Name)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CREATENEWPLAYER
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("createnewplayer", function(source, args)
	SendNUIMessage({ Action = "NewPlayer", Name = args[1] or "" })
end)
