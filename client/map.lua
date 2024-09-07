-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSTART
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    setupCircleRadar()
end)

function setupCircleRadar()
    -- Remove North Blip
    SetBlipAlpha(GetNorthRadarBlip(), 0)

    DisplayRadar(false)

    RequestStreamedTextureDict("circlemap",false)
    while not HasStreamedTextureDictLoaded("circlemap") do
        Citizen.Wait(100)
    end

    AddReplaceTexture("platform:/textures/graphics","radarmasksm","circlemap","radarmasksm")

    SetMinimapClipType(1)
    SetMinimapComponentPosition("minimap","L","B",0.009,-0.0125,0.16,0.28)
    SetMinimapComponentPosition("minimap_mask","L","B",0.155,0.12,0.080,0.15)
    SetMinimapComponentPosition("minimap_blur","L","B",0.0095,0.015,0.229,0.311)

    SetBigmapActive(true,false)

    Citizen.Wait(5000)

    SetBigmapActive(false,false)
end

function string.split(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

function math.round(number)
    return math.ceil(number * 10) / 10
end

local aspects = {
    ["16/9"] = {
        -- ["1920:1080"] = 23.5,
        -- ["1680:1050"] = 24.5,
        -- ["1600:1080"] = 24, -- 1600/1200
        -- ["1600:1024"] = 24.2,
        -- ["1600:900"] = 24.2,
        -- ["1440:1080"] = 24.5, 
        -- ["1440:900"] = 25, 
        -- ["1366:768"] = 25,
        -- ["1360:768"] = 25,
        -- ["1280:1024"] = 24.2,
        -- ["1280:960"] = 24.1,
        -- ["1280:800"] = 25.7,
        -- ["1280:768"] = 25.5,
        -- ["1280:720"] = 25.5,
        -- ["1176:664"] = 25.6,
        -- ["1152:864"] = 25.5,
        ["1100:1080"] = 19.5, 
        -- ["1024:768"] = 24.2,
        -- ["800:600"] = 24,
    },
    ["5/4"] = {
        ["1920:1080"] = 23.5,
        ["1680:1050"] = 24.5,
        ["1600:1080"] = 24, -- 1600/1200
        ["1600:1024"] = 24.2,
        ["1600:900"] = 24.2,
        ["1440:1080"] = 24.5, 
        ["1440:900"] = 25, 
        ["1366:768"] = 25,
        ["1360:768"] = 25,
        ["1280:1024"] = 24.2,
        ["1280:960"] = 24.1,
        ["1280:800"] = 25.7,
        ["1280:768"] = 25.5,
        ["1280:720"] = 25.5,
        ["1176:664"] = 25.6,
        ["1152:864"] = 25.5,
        ["1100:1080"] = 24.5, 
        ["1024:768"] = 24.2,
        ["800:600"] = 24,
    },
    ["5/3"] = {
        ["1920:1080"] = 17.5,
        ["1680:1050"] = 15.8,
        ["1600:1080"] = 17, -- 1600/1200
        ["1600:1024"] = 17,
        ["1600:900"] = 18.2,
        ["1440:1080"] = 15, 
        ["1440:900"] = 17, 
        ["1366:768"] = 19.5,
        ["1360:768"] = 19.5,
        ["1280:1024"] = 13,
        ["1280:960"] = 14,
        ["1280:800"] = 17.8,
        ["1280:768"] = 18.2,
        ["1280:720"] = 20,
        ["1176:664"] = 20.5, 
        ["1152:864"] = 15,
        ["1100:1080"] = 19.3,
        ["1024:768"] = 14.7,
        ["800:600"] = 13, 
    },
    ["4/3"] = {
        ["1920:1080"] = 22,
        ["1680:1050"] = 22.5,
        ["1600:1080"] = 19, -- 1600/1200
        ["1600:1024"] = 23,
        ["1600:900"] = 22.8,
        ["1440:1080"] = 22, 
        ["1440:900"] = 23.5, 
        ["1366:768"] = 23.7,
        ["1360:768"] = 23.7,
        ["1280:1024"] = 21.7,
        ["1280:960"] = 21.7,
        ["1280:800"] = 24.2,
        ["1280:768"] = 24,
        ["1280:720"] = 24.2,
        ["1176:664"] = 24.5,
        ["1152:864"] = 23,
        ["1100:1080"] = 23.5,
        ["1024:768"] = 21.5,
        ["800:600"] = 21.5,
    },
    ["3/2"] = {
        ["1920:1080"] = 19.5,
        ["1680:1050"] = 18.5,
        ["1600:1080"] = 19, -- 1600/1200
        ["1600:1024"] = 20.2,
        ["1600:900"] = 20.5,
        ["1440:1080"] = 18, 
        ["1440:900"] = 20.2, 
        ["1366:768"] = 21.5,
        ["1360:768"] = 21.5,
        ["1280:1024"] = 16.5,
        ["1280:960"] = 18,
        ["1280:800"] = 20.7,
        ["1280:768"] = 21.5,
        ["1280:720"] = 21.9,
        ["1176:664"] = 22.5,
        ["1152:864"] = 18.5,
        ["1100:1080"] = 21.3,
        ["1024:768"] = 18,
        ["800:600"] = 17,
    }
}

local minimap = setmetatable({}, {
    __index = function(self, key)
        for k,v in pairs(aspects) do
            local number1, number2 = table.unpack(k:split("/"))
            if number1 and number2 and math.round((number1/number2)) == math.round(key) then
                rawset(self, key, v)
                return v
            end
        end
        return nil
    end
})

local cached = {
    vehicle = false,
    ratio = nil
}

function getRatio(ratio, resX, resY)
    local aspect = minimap[ratio]
    if type(aspect) == "table"  then
        --print(resX, resY)
        return aspect[resX..":"..resY] ~= nil and aspect[resX..":"..resY] or 0
    else
        return aspect
    end
end

Citizen.CreateThread(function()
    while true do
        local timeDistance = 1000
        if IsPedInAnyVehicle(PlayerPedId()) then
            timeDistance = 100
            cached.vehicle = true
            local res_x, res_y = GetActiveScreenResolution()
            local AspectRatio = GetAspectRatio(0)
            if AspectRatio then
                local minimapAspect = getRatio(AspectRatio, res_x, res_y)
                if minimapAspect then
                    cached.ratio = AspectRatio
                    SendNUIMessage({Action = "Bounds", Left = minimapAspect})
                elseif cached.ratio ~= AspectRatio then
                    SendNUIMessage({Action = "Bounds"})
                end
            end
        elseif cached.vehicle then
            cached.vehicle = false
            SendNUIMessage({Action = "Bounds"})
        end
        Wait(timeDistance)
    end
end)