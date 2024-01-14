local Keys = {
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

local PlayerData              = {}
local HasAlreadyEnteredMarker = false
local LastZone                = nil
local CurrentAction           = nil
local CurrentActionMsg        = ''
local CurrentActionData       = {}
local Blips                   = {}

local isBarman                = false
local isInMarker              = false
local isInPublicMarker        = false
local hintIsShowed            = false
local MissionStarted = false
local Vehicle
local hintToDisplay           = "kein Hinweis zur Anzeige"

ESX                           = nil

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

function IsJobTrue()
    if PlayerData ~= nil then
        local IsJobTrue = false
        if PlayerData.job ~= nil and PlayerData.job.name == 'burgershot' then
            IsJobTrue = true
        end
        return IsJobTrue
    end
end

function IsGradeBoss()
    if PlayerData ~= nil then
        local IsGradeBoss = false
        if PlayerData.job.grade_name == 'boss'  then
            IsGradeBoss = true
        end
        return IsGradeBoss
    end
end

function SetVehicleMaxMods(vehicle)

  local props = {
    modEngine       = 0,
    modBrakes       = 0,
    modTransmission = 0,
    modSuspension   = 0,
    modTurbo        = false,
  }

  ESX.Game.SetVehicleProperties(vehicle, props)

end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)


function cleanPlayer(playerPed)
  ClearPedBloodDamage(playerPed)
  ResetPedVisibleDamage(playerPed)
  ClearPedLastWeaponDamage(playerPed)
  ResetPedMovementClipset(playerPed, 0)
end

function setClipset(playerPed, clip)
  RequestAnimSet(clip)
  while not HasAnimSetLoaded(clip) do
    Citizen.Wait(0)
  end
  SetPedMovementClipset(playerPed, clip, true)
end

function setUniform(job, playerPed)
  TriggerEvent('skinchanger:getSkin', function(skin)

    if skin.sex == 0 then
      if Config.Uniforms[job].male ~= nil then
        TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].male)
      else
        ESX.ShowNotification(_U('no_outfit'))
      end
      if job ~= 'citizen_wear' and job ~= 'barman_outfit' then
        setClipset(playerPed, "MOVE_M@POSH@")
      end
    else
      if Config.Uniforms[job].female ~= nil then
        TriggerEvent('skinchanger:loadClothes', skin, Config.Uniforms[job].female)
      else
        ESX.ShowNotification(_U('no_outfit'))
      end
      if job ~= 'citizen_wear' and job ~= 'barman_outfit' then
        setClipset(playerPed, "MOVE_F@POSH@")
      end
    end

  end)
end

function OpenCloakroomMenu()

  local playerPed = GetPlayerPed(-1)

  local elements = {
    { label = _U('citizen_wear'),     value = 'citizen_wear'},
    { label = _U('barman_outfit'),    value = 'barman_outfit'}
  }

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'cloakroom',
    {
      title    = _U('cloakroom'),
      align    = 'top-left',
      elements = elements,
    },
    function(data, menu)

      isBarman = false
      cleanPlayer(playerPed)

      if data.current.value == 'citizen_wear' then
        ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
          TriggerEvent('skinchanger:loadSkin', skin)
        end)
      end

      if data.current.value == 'barman_outfit' then
        setUniform(data.current.value, playerPed)
      end

      CurrentAction     = 'menu_cloakroom'
      CurrentActionMsg  = _U('open_cloackroom')
      CurrentActionData = {}

    end,
    function(data, menu)
      menu.close()
      CurrentAction     = 'menu_cloakroom'
      CurrentActionMsg  = _U('open_cloackroom')
      CurrentActionData = {}
    end
  )
end

function OpenVaultMenu()

    local elements = {
        {label = _U("salad") .. " (x1) -8$", value = 'lettuce'},
        {label = _U("tomato") .. " (x1) -8$", value = 'tomato'},
        {label = _U("cheese") .. " (x1) - 20$", value = 'cheese'},
        {label = _U("potato") .. " (x1) - 2$", value = 'potato'},
        {label = _U("frozen_beef_patty") .. " (x1) - 5$", value = 'fburger'},
        {label = _U("frozen_veggie_burger") .. " (x1) - 4$", value = 'fvburger'},
        {label = _U("bread") .. " (x1) - 3$", value = 'bread'},
        {label = _U("chicken_nugget") .. " (x1) - 1.5$", value = 'nugget'},
        {label = _U("cocacola") .. " (x1) - 3$", value = 'cocacola'},
        {label = _U("water") .. " (x1) - 2$", value = 'water'},
        {label = _U("gluten_free_bread") .. "(x1)- 3$", value = 'vbread'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'vault',
        {
            title    = _U('vault'),
            align    = 'top-left',
            elements = elements,
        },
        function(data, menu)
            local valor = 0

            if data.current.value == "water" then
                valor = 2
            end

            if data.current.value == "lettuce" then
                valor = 8
            end

            if data.current.value == "tomato" then
                valor = 8
            end

            if data.current.value == "cheese" then
                valor = 20
            end

            if data.current.value == "potato" then
                valor = 2
            end

            if data.current.value == "fburger" then
                valor = 5
            end

            if data.current.value == "fvburger" then
                valor = 4
            end

            if data.current.value == "bread" then
                valor = 3
            end

            if data.current.value == "vbread" then
                valor = 3
            end

            if data.current.value == "nugget" then
                valor = 1.5
            end

            if data.current.value == "cocacola" then
                valor = 3
            end

            TriggerServerEvent('bs_burgershotjob:shop', data.current.value, valor)
        end,

        function(data, menu)

            menu.close()

            CurrentAction     = 'menu_vault'
            CurrentActionMsg  = _U("press_to_buy_ingredients")
            CurrentActionData = {}
        end
    )

end

function OpenFridgeMenu()

    local elements = {
        {label = _U('get_object'), value = 'get_stock'},
        {label = _U('put_object'), value = 'put_stock'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'fridge',
        {
            title    = _U("fridge"),
            align    = 'top-left',
            elements = elements,
        },
        function(data, menu)

            if data.current.value == 'put_stock' then
                OpenPutFridgeStocksMenu()
            end

            if data.current.value == 'get_stock' then
                OpenGetFridgeStocksMenu()
            end

        end,

        function(data, menu)

            menu.close()

            CurrentAction     = 'menu_fridge'
            CurrentActionMsg  = _U("press_to_open_fridge")
            CurrentActionData = {}
        end
    )

end

function OpenCozinharMenu()

    local elements = {
        {label = _U("chopped_tomato"), value = 'ctomato'},
        {label = _U("chopped_lettuce"), value = 'clettuce'},
        {label = _U("cheese_slice"), value = 'ccheese'},
        {label = _U("simple_burger_bun"), value = 'shamburger'},
        {label = _U("quarter_pounder_with_cheese"), value = 'hamburger'},
        {label = _U("veggie_burger"), value = 'vhamburger'},
        {label = _U("chicken_nuggets_x4"), value = 'nuggets4'},
        {label = _U("chicken_nuggets_x10"), value = 'nuggets10'},
        {label = _U("fries"), value = 'chips'}
    }

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'cook',
        {
            title    = _U("cook_food"),
            align    = 'top-left',
            elements = elements,
        },
        function(data, menu)

            TriggerServerEvent('bs_burgershotjob:craftingCoktails', data.current.value)

        end,

        function(data, menu)

            menu.close()

            CurrentAction     = 'menu_cook'
            CurrentActionMsg  = _U("press_to_cook")
            CurrentActionData = {}
        end
    )

end

function ShowLoadingPromt(msg, time, type)
	CreateThread(function()
		Wait(0)

		BeginTextCommandBusyspinnerOn('STRING')
		AddTextComponentSubstringPlayerName(msg)
		EndTextCommandBusyspinnerOn(type)
		Wait(time)

		BusyspinnerOff()
	end)
end

function DrawSub(msg, time)
	ClearPrints()
	BeginTextCommandPrint('STRING')
	AddTextComponentSubstringPlayerName(msg)
	EndTextCommandPrint(time, 1)
end

function Display3DText(x, y, z, textInput,fontId,scaleX)
	if fontId == nil then
	fontId = 4
	end
	if scaleX == nil then
	scaleX = 0.05
	end
	
	local px,py,pz=table.unpack(GetGameplayCamCoords())
         local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)    
		 local cord = GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(-1)), vector3(x,y,z))
		 if cord < 1.75 then
         local scale = (1/dist)*20
         local fov = (1/GetGameplayCamFov())*100
         local scale = scale*fov 	
         SetTextScale(scaleX*scale, scaleX*scale)
         SetTextFont(fontId)
         SetTextProportional(1)
         SetTextColour(250, 250, 250, 255)		-- Hier kannst du die Farbe ändern
         SetTextDropshadow(1, 1, 1, 1, 255)
         SetTextEdge(2, 0, 0, 0, 150)
         SetTextDropShadow()
         SetTextOutline()
         SetTextEntry("STRING")
         SetTextCentre(1)
         AddTextComponentString(textInput)
         SetDrawOrigin(x,y,z+2, 0)
         DrawText(0.0, 0.0)
         ClearDrawOrigin()
		end
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        
        Citizen.Wait(1)
    end
end
local MissionDenied = false
local Peds = {"a_f_m_bevhills_02","a_f_m_business_02","a_f_m_eastsa_01","a_f_o_genstreet_01","a_f_y_bevhills_03","a_f_y_fitness_02","a_f_y_gencaspat_01","a_m_m_fatlatin_01","a_m_m_golfer_01","a_m_m_salton_01","a_m_m_tranvest_02","a_m_y_beachvesp_01","a_m_y_clubcust_01","a_m_y_epsilon_02","a_m_y_hippy_01","a_m_y_hipster_02","a_m_y_polynesian_01","a_m_y_stwhi_01","cs_amandatownley","cs_davenorton","cs_chengsr","cs_dreyfuss","cs_jewelass","cs_josh", "cs_mrsphillips","cs_orleans","cs_siemonyetarian","csb_denise_friend","csb_ramp_gang"}
local Coords = {vector4(-976.8295, -662.7225, 23.9590, 130.6230),vector4(-768.7364, -672.3965, 29.9757, 266.9799),vector4(-617.1075, -435.6331, 34.7412, 4.1820),vector4(-617.1075, -435.6331, 34.7412, 4.1820),vector4(-850.7010, 181.2155, 70.2788, 173.4478),vector4(-1453.4075, 98.4768, 52.2421, 162.7790),vector4(-1342.3387, -251.0781, 42.6804, 212.7793),vector4(-1174.0144, -678.7828, 22.5775, 220.4395),vector4(-1457.1277, -786.9354, 23.8780, 111.2967),vector4(-1266.2141, 275.6681, 64.7329, 132.0987),vector4(-556.2542, 270.5675, 83.0203, 179.3317),vector4(-245.0368, 248.5240, 92.0451, 7.3587),vector4(270.6234, 186.8952, 104.6958, 154.0035),vector4(658.8853, 7.9045, 85.0263, 330.1700),vector4(858.8842, 529.4296, 125.9152, 333.9669),vector4(916.6444, -148.5908, 75.8730, 332.6001),vector4(1284.6497, -671.5152, 66.4027, 269.8649),vector4(1149.0040, -1007.1625, 44.8624, 278.0854),vector4(1318.5039, -1609.2202, 52.5597, 297.3801),vector4(719.2936, -2409.3149, 20.3180, 244.8756),vector4(171.9615, -2029.3219, 18.2694, 148.9651),vector4(-236.3942, -2115.1389, 22.6510, 185.9447),vector4(-264.1767, -1493.8535, 30.1079, 64.0918),vector4(-524.7113, -1044.4978, 22.6526, 91.5710),vector4(-618.6920, -525.6962, 34.7634, 85.5644),vector4(-747.9081, -113.9400, 37.7188, 113.4867),vector4(-1221.9373, -286.5220, 37.7975, 195.3374),vector4(-1360.1057, -396.6779, 36.5823, 117.9002),vector4(-1329.9644, -660.6094, 26.5178, 223.5719),vector4(-1102.9800, -937.3054, 2.5951, 102.5121),vector4(-967.8528, -1202.0521, 4.8718, 286.1415),vector4(-625.1047, -979.6703, 21.3301, 98.8211)}
local FirstItems = {
	[1] = {Item = "shamburger", Price = 70, Label = _U("simple_burger") },
	[2] = {Item = "vhamburger", Price = 70, Label = _U("veggie_burger") },
	[3] = {Item = "nuggets4", Price = 70, Label = _U("chicken_nuggets_x4") },
	[4] = {Item = "nuggets10", Price = 70, Label = _U("chicken_nuggets_x10") },
	[5] = {Item = "hamburger", Price = 70, Label = _U("quarter_pounder_with_cheese") }
}

local Countdown = 0

function StartMission(Vehicle)
	MissionDenied = false
	local Vehicle = Vehicle
	local waittime = math.random(200, 6000)
	Wait(waittime)

	repeat
		Wait(50)
	until IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsIn(PlayerPedId(), false) == Vehicle or not MissionStarted

	repeat
		Citizen.Wait(1)
		Countdown = Countdown + 0.001
		print(Countdown)
		DrawSub("~g~Chef: ~w~" .. _U("mission_received_prompt"), 1)

		if Countdown > 2.0 then
			MissionDenied = true
		end
	until IsControlJustReleased(2, 38) or MissionDenied

	Countdown = 0

	if not MissionDenied then
		Countdown = 0
		MissionStarted = true

		local netPed = Peds[math.random(1, #Peds)]
		Citizen.Wait(math.random(1, 100))

		local PedModel = GetHashKey(netPed)
		local PedCoords = Coords[math.random(1, #Coords)]
		local pcoords = vector3(PedCoords.x, PedCoords.y, PedCoords.z)
		local cords = GetEntityCoords(GetPlayerPed(-1))
		local Item = FirstItems[math.random(1, #FirstItems)]
		local dist = GetDistanceBetweenCoords(cords, pcoords, true)

		local waittime2 = math.random(200, 3500)
		ShowLoadingPromt(_U("checking_current_jobs"), waittime2, 3)
		Wait(waittime2)

		local missionBlip
		missionBlip = AddBlipForCoord(pcoords)
		SetBlipRoute(missionBlip, true)
		SetBlipRouteColour(missionBlip, 28)
		SetBlipColour(missionBlip, 28)

		repeat
			Citizen.Wait(0)

			if IsPedInAnyVehicle(PlayerPedId(), false) and GetVehiclePedIsIn(PlayerPedId(), false) == Vehicle then
				local cords = GetEntityCoords(GetPlayerPed(-1))
				dist = GetDistanceBetweenCoords(cords, pcoords, true)
			end

			if missionBlip == nil or missionBlip == 0 then
				missionBlip = AddBlipForCoord(pcoords)
				SetBlipRoute(missionBlip, true)
				SetBlipRouteColour(missionBlip, 28)
				SetBlipColour(missionBlip, 28)
			end

			DrawSub("~g~Chef: ~w~" .. _U("mission_person_wants", Item.Label), 1)
		until dist < 60 or not MissionStarted

		RequestModel(GetHashKey(netPed))

		while not HasModelLoaded(GetHashKey(netPed)) do
			Citizen.Wait(1)
		end

		local Ped = CreatePed(4, GetHashKey(netPed), PedCoords.x, PedCoords.y, PedCoords.z, PedCoords.w, true, false)
		TaskStartScenarioInPlace(Ped, "CODE_HUMAN_CROSS_ROAD_WAIT", -1, false)

		while MissionStarted do
			DrawSub(_U("mission_person_wants", Item.Label), 1)
			local cords = GetEntityCoords(GetPlayerPed(-1))
			local pcords = GetEntityCoords(Ped)
			local dists = GetDistanceBetweenCoords(cords, pcords, true)

			if dists < 10 then
				Display3DText(pcords.x, pcords.y, pcords.z - 1.0, "~b~PERSON~w~\nDrücke ~r~E~w~, um der Person das Essen zu geben")
			end

			if IsControlJustReleased(2, 38) then
				if dists < 3 then
					ESX.TriggerServerCallback('bs_burgershotjob:RemoveMissionItems', function(cb, cb2, cb3)
						if cb then
							local price = Item.Price * 50.5
							local trinkgeld = math.random(50,40000)
							local gesamt = price + trinkgeld
							loadAnimDict('mp_common')
							TaskPlayAnim(PlayerPedId(), "mp_common", "givetake1_a", 8.0, 8.0, 20, 50, 0, false, false, false)
							TaskPlayAnim(Ped, "mp_common", "givetake1_a", 8.0, 8.0, 20, 50, 0, false, false, false)
							ESX.ShowNotification(_U("you_receive", price, trinkgeld))
							TriggerServerEvent('bs_burgershotjob:removeMoneyFromAccount', Item.Item, gesamt)
							RemoveBlip(missionBlip)
							MissionStarted = false
							local waittime = math.random(200, 6000)
							Wait(waittime)

							repeat
								Citizen.Wait(1)
								Countdown = Countdown + 0.001
								DrawSub("~g~Chef: ~w~" .. _U("mission_received_prompt"), 1)

								if Countdown > 2.0 then
									MissionDenied = true
								end
							until IsControlJustReleased(2, 38) and GetVehiclePedIsIn(PlayerPedId(), false) == Vehicle or MissionDenied

							Countdown = 0

							if not MissionDenied then
								MissionDenied = false
								StartMission(Vehicle)
							end
						else
							ESX.ShowNotification(_U("you_have_no", Item.Label))
						end
					end, Item.Item)
				else
					ESX.ShowNotification(_U("must_be_close"))
				end
			end

			Citizen.Wait(0)
		end
	end
end

function OpenVehicleSpawnerMenu()

  local vehicles = Config.Zones.Vehicles

  ESX.UI.Menu.CloseAll()

  if Config.EnableSocietyOwnedVehicles then

    local elements = {}

    ESX.TriggerServerCallback('esx_society:getVehiclesInGarage', function(garageVehicles)

      for i=1, #garageVehicles, 1 do
        table.insert(elements, {label = GetDisplayNameFromVehicleModel(garageVehicles[i].model) .. ' [' .. garageVehicles[i].plate .. ']', value = garageVehicles[i]})
      end

      ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'vehicle_spawner',
        {
          title    = _U('vehicle_menu'),
          align    = 'top-left',
          elements = elements,
        },
        function(data, menu)

          menu.close()

          local vehicleProps = data.current.value
          ESX.Game.SpawnVehicle(vehicleProps.model, vehicles.SpawnPoint, vehicles.Heading, function(vehicle)
			 Vehicle = vehicle
              ESX.Game.SetVehicleProperties(vehicle, vehicleProps)
			  local playerPed = GetPlayerPed(-1)
			  SetVehicleLivery(vehicle, 1)
			  
              
          end)            

          TriggerServerEvent('esx_society:removeVehicleFromGarage', 'burgershot', vehicleProps)

        end,
        function(data, menu)

          menu.close()

          CurrentAction     = 'menu_vehicle_spawner'
          CurrentActionMsg  = _U('vehicle_spawner')
          CurrentActionData = {}

        end
      )

    end, 'burgershot')

  else

    local elements = {}

    for i=1, #Config.AuthorizedVehicles, 1 do
      local vehicle = Config.AuthorizedVehicles[i]
      table.insert(elements, {label = vehicle.label, value = vehicle.name})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'vehicle_spawner',
      {
        title    = _U('vehicle_menu'),
        align    = 'top-left',
        elements = elements,
      },
      function(data, menu)

        menu.close()

        local model = data.current.value

        local vehicle = GetClosestVehicle(vehicles.SpawnPoint.x,  vehicles.SpawnPoint.y,  vehicles.SpawnPoint.z,  3.0,  0,  71)

        if not DoesEntityExist(vehicle) then

          local playerPed = GetPlayerPed(-1)
          if Config.MaxInService == -1 then

            ESX.Game.SpawnVehicle(model, {
              x = vehicles.SpawnPoint.x,
              y = vehicles.SpawnPoint.y,
              z = vehicles.SpawnPoint.z
            }, vehicles.Heading, function(vehicle)
              --TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1) -- teleport into vehicle
              SetVehicleMaxMods(vehicle)
              SetVehicleDirtLevel(vehicle, 0)
			  SetVehicleLivery(vehicle, 0)
			  StartMission(vehicle)
            end)

          else

            ESX.TriggerServerCallback('esx_service:enableService', function(canTakeService, maxInService, inServiceCount)

              if canTakeService then

                ESX.Game.SpawnVehicle(model, {
                  x = vehicles[partNum].SpawnPoint.x,
                  y = vehicles[partNum].SpawnPoint.y,
                  z = vehicles[partNum].SpawnPoint.z
                }, vehicles[partNum].Heading, function(vehicle)
                  --TaskWarpPedIntoVehicle(playerPed,  vehicle,  -1)  -- teleport into vehicle
                  SetVehicleMaxMods(vehicle)
                  SetVehicleDirtLevel(vehicle, 0)
                end)

              else
                ESX.ShowNotification(_U('service_max') .. inServiceCount .. '/' .. maxInService)
              end

            end, 'etat')

          end

        else
          ESX.ShowNotification(_U('vehicle_out'))
        end

      end,
      function(data, menu)

        menu.close()

        CurrentAction     = 'menu_vehicle_spawner'
        CurrentActionMsg  = _U('vehicle_spawner')
        CurrentActionData = {}

      end
    )

  end

end

function OpenSocietyActionsMenu()

  local elements = {}

  table.insert(elements, {label = _U('billing'),    value = 'billing'})

  ESX.UI.Menu.CloseAll()

  ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'burgershot_actions',
    {
      title    = "Billing",
      align    = 'top-left',
      elements = elements
    },
    function(data, menu)

      if data.current.value == 'billing' then
        OpenBillingMenu()
      end    
    end,
    function(data, menu)

      menu.close()

    end
  )

end

function OpenBillingMenu()

  ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'billing', {
    title = _U('billing_amount')
  }, function(data, menu)
    local amount = tonumber(data.value)

    if amount == nil or amount < 0 then
      ESX.ShowNotification(_U('amount_invalid'))
    else
      local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
      if closestPlayer == -1 or closestDistance > 3.0 then
        ESX.ShowNotification(_U('no_players_nearby'))
      else
        menu.close()
        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_burgershot', _U('burgershot'), amount)
      end
    end
  end, function(data, menu)
    menu.close()
  end)
end

function OpenGetStocksMenu()

  ESX.TriggerServerCallback('bs_burgershotjob:getStockItems', function(items)


    local elements = {}

    for i=1, #items, 1 do
      table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. items[i].label, value = items[i].name})
    end

    ESX.UI.Menu.Open(
      'default', GetCurrentResourceName(), 'stocks_menu',
      {
        title    = _U('burgershot_stock'),
        elements = elements
      },
      function(data, menu)

        local itemName = data.current.value

        ESX.UI.Menu.Open(
          'dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count',
          {
            title = _U('quantity')
          },
          function(data2, menu2)

            local count = tonumber(data2.value)

            if count == nil then
              ESX.ShowNotification(_U('invalid_quantity'))
            else
              menu2.close()
              menu.close()
              OpenGetStocksMenu()

              TriggerServerEvent('bs_burgershotjob:getStockItem', itemName, count)
            end

          end,
          function(data2, menu2)
            menu2.close()
          end
        )

      end,
      function(data, menu)
        menu.close()
      end
    )

  end)

end

function OpenPutStocksMenu()

ESX.TriggerServerCallback('bs_burgershotjob:getPlayerInventory', function(inventory)

    local elements = {}

    for i=1, #inventory.items, 1 do

        local item = inventory.items[i]

        if item.count > 0 then
            table.insert(elements, {label = _U(item.label) .. ' x' .. item.count, type = 'item_standard', value = item.name})
        end

    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'stocks_menu',
        {
            title    = _U('inventory'),
            elements = elements
        },
        function(data, menu)

            local itemName = data.current.value

            ESX.UI.Menu.Open(
                'dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count',
                {
                    title = _U('quantity')
                },
                function(data2, menu2)

                    local count = tonumber(data2.value)

                    if count == nil then
                        ESX.ShowNotification(_U('invalid_quantity'))
                    else
                        menu2.close()
                        menu.close()
                        OpenPutStocksMenu()

                        TriggerServerEvent('bs_burgershotjob:putStockItems', itemName, count)
                    end

                end,
                function(data2, menu2)
                    menu2.close()
                end
            )

        end,
        function(data, menu)
            menu.close()
        end
    )

end)

end

function OpenGetFridgeStocksMenu()

ESX.TriggerServerCallback('bs_burgershotjob:getFridgeStockItems', function(items)


    local elements = {}

    for i=1, #items, 1 do
        table.insert(elements, {label = 'x' .. items[i].count .. ' ' .. _U(items[i].label), value = items[i].name})
    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'fridge_menu',
        {
            title    = _U('burgershot_fridge_stock'),
            elements = elements
        },
        function(data, menu)

            local itemName = data.current.value

            ESX.UI.Menu.Open(
                'dialog', GetCurrentResourceName(), 'fridge_menu_get_item_count',
                {
                    title = _U('quantity')
                },
                function(data2, menu2)

                    local count = tonumber(data2.value)

                    if count == nil then
                        ESX.ShowNotification(_U('invalid_quantity'))
                    else
                        menu2.close()
                        menu.close()
                        OpenGetStocksMenu()

                        TriggerServerEvent('bs_burgershotjob:getFridgeStockItem', itemName, count)
                    end

                end,
                function(data2, menu2)
                    menu2.close()
                end
            )

        end,
        function(data, menu)
            menu.close()
        end
    )

end)

end

function OpenPutFridgeStocksMenu()

ESX.TriggerServerCallback('bs_burgershotjob:getPlayerInventory', function(inventory)

    local elements = {}

    for i=1, #inventory.items, 1 do

        local item = inventory.items[i]

        if item.count > 0 then
            table.insert(elements, {label = _U(item.label) .. ' x' .. item.count, type = 'item_standard', value = item.name})
        end

    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'fridge_menu',
        {
            title    = _U('fridge_inventory'),
            elements = elements
        },
        function(data, menu)

            local itemName = data.current.value

            ESX.UI.Menu.Open(
                'dialog', GetCurrentResourceName(), 'fridge_menu_put_item_count',
                {
                    title = _U('quantity')
                },
                function(data2, menu2)

                    local count = tonumber(data2.value)

                    if count == nil then
                        ESX.ShowNotification(_U('invalid_quantity'))
                    else
                        menu2.close()
                        menu.close()
                        OpenPutFridgeStocksMenu()

                        TriggerServerEvent('bs_burgershotjob:putFridgeStockItems', itemName, count)
                    end

                end,
                function(data2, menu2)
                    menu2.close()
                end
            )

        end,
        function(data, menu)
            menu.close()
        end
    )

end)

end

function OpenGetWeaponMenu()

ESX.TriggerServerCallback('bs_burgershotjob:getVaultWeapons', function(weapons)

    local elements = {}

    for i=1, #weapons, 1 do
        if weapons[i].count > 0 then
            table.insert(elements, {label = 'x' .. weapons[i].count .. ' ' .. _U(ESX.GetWeaponLabel(weapons[i].name)), value = weapons[i].name})
        end
    end

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'vault_get_weapon',
        {
            title    = _U('get_weapon_menu'),
            align    = 'top-left',
            elements = elements,
        },
        function(data, menu)

            menu.close()

            ESX.TriggerServerCallback('bs_burgershotjob:removeVaultWeapon', function()
                OpenGetWeaponMenu()
            end, data.current.value)

        end,
        function(data, menu)
            menu.close()
        end
    )

end)

end

function OpenPutWeaponMenu()

local elements   = {}
local playerPed  = GetPlayerPed(-1)
local weaponList = ESX.GetWeaponList()

for i=1, #weaponList, 1 do

    local weaponHash = GetHashKey(weaponList[i].name)

    if HasPedGotWeapon(playerPed,  weaponHash,  false) and weaponList[i].name ~= 'WEAPON_UNARMED' then
        local ammo = GetAmmoInPedWeapon(playerPed, weaponHash)
        table.insert(elements, {label = _U(weaponList[i].label), value = weaponList[i].name})
    end

end

ESX.UI.Menu.Open(
    'default', GetCurrentResourceName(), 'vault_put_weapon',
    {
        title    = _U('put_weapon_menu'),
        align    = 'top-left',
        elements = elements,
    },
    function(data, menu)

        menu.close()

        ESX.TriggerServerCallback('bs_burgershotjob:addVaultWeapon', function()
            OpenPutWeaponMenu()
        end, data.current.value)

    end,
    function(data, menu)
        menu.close()
    end
)

end

function OpenShopMenu(zone)
    local elements = {}
    for i=1, #Config.Zones[zone].Items, 1 do

        local item = Config.Zones[zone].Items[i]

        table.insert(elements, {
            label     = _U(item.label) .. ' - <span style="color:red;">$' .. item.price .. ' </span>',
            realLabel = item.label,
            value     = item.name,
            price     = item.price
        })

    end

    ESX.UI.Menu.CloseAll()

    ESX.UI.Menu.Open(
        'default', GetCurrentResourceName(), 'burgershot_shop',
        {
            title    = _U('shop'),
            elements = elements
        },
        function(data, menu)
            TriggerServerEvent('bs_burgershotjob:buyItem', data.current.value, data.current.price, data.current.realLabel)
        end,
        function(data, menu)
            menu.close()
        end
    )

end

function animsAction(animObj)
    Citizen.CreateThread(function()
        if not playAnim then
            local playerPed = GetPlayerPed(-1);
            if DoesEntityExist(playerPed) then -- Check if ped exist
                dataAnim = animObj

                -- Play Animation
                RequestAnimDict(dataAnim.lib)
                while not HasAnimDictLoaded(dataAnim.lib) do
                    Citizen.Wait(0)
                end
                if HasAnimDictLoaded(dataAnim.lib) then
                    local flag = 0
                    if dataAnim.loop ~= nil and dataAnim.loop then
                        flag = 1
                    elseif dataAnim.move ~= nil and dataAnim.move then
                        flag = 49
                    end

                    TaskPlayAnim(playerPed, dataAnim.lib, dataAnim.anim, 8.0, -8.0, -1, flag, 0, 0, 0, 0)
                    playAnimation = true
                end

                -- Wait end animation
                while true do
                    Citizen.Wait(0)
                    if not IsEntityPlayingAnim(playerPed, dataAnim.lib, dataAnim.anim, 3) then
                        playAnim = false
                        TriggerEvent('ft_animation:ClFinish')
                        break
                    end
                end
            end -- end ped exist
        end
    end)
end


AddEventHandler('bs_burgershotjob:hasEnteredMarker', function(zone)
 
    if zone == 'BossActions' and IsGradeBoss() then
        CurrentAction     = 'menu_boss_actions'
        CurrentActionMsg  = _U('open_bossmenu')
        CurrentActionData = {}
    end

    if zone == 'Cloakrooms' then
        CurrentAction     = 'menu_cloakroom'
        CurrentActionMsg  = _U('open_cloackroom')
        CurrentActionData = {}
    end

    if zone == 'Vaults' then
        CurrentAction     = 'menu_vault'
        CurrentActionMsg  = _U('menu_vault')
        CurrentActionData = {}
    end

    if zone == 'Fridge' then
        CurrentAction     = 'menu_fridge'
        CurrentActionMsg  = _U('open_fridge')
        CurrentActionData = {}
    end
	
    if zone == 'Cook' then
        CurrentAction     = 'menu_cook'
        CurrentActionMsg  = _U('menu_cook')
        CurrentActionData = {}
    end

    if zone == 'Flacons' or zone == 'NoAlcool' or zone == 'Apero' or zone == 'Ice' then
        CurrentAction     = 'menu_shop'
        CurrentActionMsg  = _U('shop_menu')
        CurrentActionData = {zone = zone}
    end
    
    if zone == 'Vehicles' then
        CurrentAction     = 'menu_vehicle_spawner'
        CurrentActionMsg  = _U('vehicle_spawner')
        CurrentActionData = {}
    end

    if zone == 'VehicleDeleters' then

        local playerPed = GetPlayerPed(-1)

        if IsPedInAnyVehicle(playerPed,  false) then

            local vehicle = GetVehiclePedIsIn(playerPed,  false)

            CurrentAction     = 'delete_vehicle'
            CurrentActionMsg  = _U('store_vehicle')
            CurrentActionData = {vehicle = vehicle}
        end

    end

    if Config.EnableHelicopters then
        if zone == 'Helicopters' then

            local helicopters = Config.Zones.Helicopters

            if not IsAnyVehicleNearPoint(helicopters.SpawnPoint.x, helicopters.SpawnPoint.y, helicopters.SpawnPoint.z,  3.0) then

                ESX.Game.SpawnVehicle('swift2', {
                    x = helicopters.SpawnPoint.x,
                    y = helicopters.SpawnPoint.y,
                    z = helicopters.SpawnPoint.z
                }, helicopters.Heading, function(vehicle)
                    SetVehicleModKit(vehicle, 0)
                    SetVehicleLivery(vehicle, 0)
                end)

            end

        end

        if zone == 'HelicopterDeleters' then

            local playerPed = GetPlayerPed(-1)

            if IsPedInAnyVehicle(playerPed,  false) then

                local vehicle = GetVehiclePedIsIn(playerPed,  false)

                CurrentAction     = 'delete_vehicle'
                CurrentActionMsg  = _U('store_vehicle')
                CurrentActionData = {vehicle = vehicle}
            end

        end
    end


end)

AddEventHandler('bs_burgershotjob:hasExitedMarker', function(zone)

    CurrentAction = nil
    ESX.UI.Menu.CloseAll()

end)

-- Create blips
Citizen.CreateThread(function()

    local blipMarker = Config.Blips.Blip
    local blipCoord = AddBlipForCoord(blipMarker.Pos.x, blipMarker.Pos.y, blipMarker.Pos.z)

    SetBlipSprite (blipCoord, blipMarker.Sprite)
    SetBlipDisplay(blipCoord, blipMarker.Display)
    SetBlipScale  (blipCoord, blipMarker.Scale)
    SetBlipColour (blipCoord, blipMarker.Colour)
    SetBlipAsShortRange(blipCoord, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_U("burgershot_blip"))
    EndTextCommandSetBlipName(blipCoord)

end)


-- Display markers
Citizen.CreateThread(function()
    while true do

        Wait(0)
        if IsJobTrue() then

            local coords = GetEntityCoords(GetPlayerPed(-1))

            for k,v in pairs(Config.Zones) do
                if(v.Type ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
                    DrawMarker(v.Type, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, false, 2, false, false, false, false)
                end
            end

        end

    end
end)

-- Enter / Exit marker events
Citizen.CreateThread(function()
    while true do

        Wait(0)
        if IsJobTrue() then

            local coords      = GetEntityCoords(GetPlayerPed(-1))
            local isInMarker  = false
            local currentZone = nil

            for k,v in pairs(Config.Zones) do
                if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
                    isInMarker  = true
                    currentZone = k
                end
            end

            if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
                HasAlreadyEnteredMarker = true
                LastZone                = currentZone
                TriggerEvent('bs_burgershotjob:hasEnteredMarker', currentZone)
            end

            if not isInMarker and HasAlreadyEnteredMarker then
                HasAlreadyEnteredMarker = false
                TriggerEvent('bs_burgershotjob:hasExitedMarker', LastZone)
            end

        end

    end
end)

-- Key Controls
Citizen.CreateThread(function()
  while true do

    Citizen.Wait(0)

    if CurrentAction ~= nil then

      SetTextComponentFormat('STRING')
      AddTextComponentString(CurrentActionMsg)
      DisplayHelpTextFromStringLabel(0, 0, 1, -1)

      if IsControlJustReleased(0,  Keys['E']) and IsJobTrue() then

        if CurrentAction == 'menu_cloakroom' then
            OpenCloakroomMenu()
        end

        if CurrentAction == 'menu_vault' then
            OpenVaultMenu()
        end

        if CurrentAction == 'menu_fridge' then
            OpenFridgeMenu()
        end
		
		if CurrentAction == 'menu_cook' then
            OpenCozinharMenu()
        end

        if CurrentAction == 'menu_shop' then
            OpenShopMenu(CurrentActionData.zone)
        end
        
        if CurrentAction == 'menu_vehicle_spawner' then
            OpenVehicleSpawnerMenu()
        end

        if CurrentAction == 'delete_vehicle' then

          if Config.EnableSocietyOwnedVehicles then

            local vehicleProps = ESX.Game.GetVehicleProperties(CurrentActionData.vehicle)
            TriggerServerEvent('esx_society:putVehicleInGarage', 'burgershot', vehicleProps)

          else

            if
              GetEntityModel(vehicle) == GetHashKey('rentalbus')
            then
              TriggerServerEvent('esx_service:disableService', 'burgershot')
            end

          end

          ESX.Game.DeleteVehicle(CurrentActionData.vehicle)
        end


        if CurrentAction == 'menu_boss_actions' and IsGradeBoss() then

          local options = {
            wash      = Config.EnableMoneyWash,
          }

          ESX.UI.Menu.CloseAll()

          TriggerEvent('esx_society:openBossMenu', 'burgershot', function(data, menu)

            menu.close()
            CurrentAction     = 'menu_boss_actions'
            CurrentActionMsg  = _U('open_bossmenu')
            CurrentActionData = {}

          end,options)

        end

        
        CurrentAction = nil

      end

    end


    if IsControlJustReleased(0,  Keys['F6']) and IsJobTrue() and not ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'burgershot_actions') then
        OpenSocietyActionsMenu()
    end


  end
end)

RegisterNetEvent('esx_burgershot:StartCookAnimation')
AddEventHandler('esx_burgershot:StartCookAnimation', function()
local ped = GetPlayerPed(-1)
local x,y,z = table.unpack(GetEntityCoords(playerPed, true))
  if not IsEntityPlayingAnim(ped, "anim@amb@business@weed@weed_sorting_seated@", "sorter_right_sort_v3_sorter02", 3) then
  FreezeEntityPosition(ped,true)
	
    RequestAnimDict("anim@amb@business@weed@weed_sorting_seated@")
      while not HasAnimDictLoaded("anim@amb@business@weed@weed_sorting_seated@") do
        Citizen.Wait(100)
      end
    Wait(100)
    TaskPlayAnim(ped, "anim@amb@business@weed@weed_sorting_seated@", "sorter_right_sort_v3_sorter02", 8.0, -8, -1, 49, 0, 0, 0, 0)
      Wait(2000)
  end
end)

RegisterNetEvent('esx_burgershot:StopCookAnimation')
AddEventHandler('esx_burgershot:StopCookAnimation', function()
local ped = GetPlayerPed(-1)
  ClearPedTasksImmediately(ped)
  FreezeEntityPosition(ped,false)
end)
