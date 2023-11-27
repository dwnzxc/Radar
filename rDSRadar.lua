-- Inspired by Gir489 aka the god himself, Coded with love by: "https://www.youtube.com/@psychedelicsgotmegoingcrazy" 


local RadarFont = draw.CreateFont("Tahoma Bold", 14, 800)

local radar = {
    size = 300,
    x = 20,
    y = 20,
    backgroundColor = {0, 0, 0, 100},
    enemyColor = {255, 255, 255, 255},
    lineColor = {225, 151, 112, 255},
    maxDistance = 1000,
}

local function drawRadar()
    local localPlayer = entities.GetLocalPlayer();
    if not localPlayer:IsAlive() then return end

    local centerX = radar.x + radar.size / 2
    local centerY = radar.y + radar.size / 2

    draw.Color(radar.backgroundColor[1], radar.backgroundColor[2], radar.backgroundColor[3], radar.backgroundColor[4])
    draw.FilledRect(radar.x, radar.y, radar.x + radar.size, radar.y + radar.size)

    draw.Color(radar.lineColor[1], radar.lineColor[2], radar.lineColor[3], radar.lineColor[4])
    draw.Line(centerX - radar.size / 2, centerY, centerX + radar.size / 2, centerY)
    draw.Line(centerX, centerY - radar.size / 2, centerX, centerY + radar.size / 2)

    for _, ply in pairs(entities.FindByClass("CTFPlayer")) do
        if ply ~= localPlayer and ply:IsAlive() and ply:GetTeamNumber() ~= localPlayer:GetTeamNumber() then
            local playerPos = ply:GetAbsOrigin()

            local dx = playerPos.x - localPlayer:GetAbsOrigin().x
            local dy = playerPos.y - localPlayer:GetAbsOrigin().y

            local distance = math.sqrt(dx * dx + dy * dy)

            if distance <= radar.maxDistance then
                local rotatedX = centerX + (dx / radar.maxDistance) * (radar.size / 2)
                local rotatedY = centerY - (dy / radar.maxDistance) * (radar.size / 2)

                local rotation = engine.GetViewAngles().yaw + 270

                local rotatedXFinal = centerX + (rotatedX - centerX) * math.cos(math.rad(rotation)) - (rotatedY - centerY) * math.sin(math.rad(rotation))
                local rotatedYFinal = centerY + (rotatedX - centerX) * math.sin(math.rad(rotation)) + (rotatedY - centerY) * math.cos(math.rad(rotation))

                local color = radar.enemyColor
                draw.Color(color[1], color[2], color[3], color[4])

                local text = "X"
                local textWidth, textHeight = draw.GetTextSize(text, RadarFont)
                local textX = rotatedXFinal - textWidth / 2
                local textY = rotatedYFinal - textHeight / 2

                draw.TextShadow(math.floor(textX), math.floor(textY), text, RadarFont)
            end
        end
    end
end

callbacks.Register("Draw", drawRadar)

local current_fps = 0
local current_tickrate = 0

local function watermark()
    draw.SetFont(RadarFont)
    draw.Color(255, 255, 255, 255)

    if globals.FrameCount() % 100 == 0 then
        current_fps = math.floor(1 / globals.FrameTime())
        current_tickrate = math.floor(1 / globals.TickInterval())
    end

    local screen_width, _ = draw.GetScreenSize()
    local text_width, text_height = draw.GetTextSize("[reLuaStorm | fps: " .. current_fps .. " | tickrate: " .. current_tickrate .. "]")
    
    local x = screen_width - text_width - 5
    local y = 5

    draw.Text(x, y, "[reLuaStorm | fps: " .. current_fps .. " | tickrate: " .. current_tickrate .. "]")
end

callbacks.Register("Draw", "draw", watermark)
