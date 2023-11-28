-- Inspired by Gir489 aka the god himself, Coded with love by: "https://www.youtube.com/@psychedelicsgotmegoingcrazy" 

local radar = {
    size = 300,
    x = 20,
    y = 20,
    backgroundColor = {0, 0, 0, 100},
    enemyColor = {255, 255, 255, 255},
    lineColor = {225, 151, 112, 255},
    distance = 1000
};



local TEXT_SHADOW = draw.TextShadow;
local FILLED_RECT = draw.FilledRect;
local SET_FONT = draw.SetFont;
local COLOR = draw.Color;
local LINE = draw.Line;

local FLOOR = math.floor;
local RAD = math.rad;
local COS = math.cos;
local SIN = math.sin;

local CLAMP = function(a,b,c)return(a<b)and b or(a>c)and c or a;end;
local STORE_COLOR = function(tbl) local r, g, b, a = tbl[1], tbl[2], tbl[3], tbl[4]; return function() COLOR(r, g, b, a); end end;



local g_clrWhite = STORE_COLOR({255, 255, 255, 255});
local g_clrBackground = STORE_COLOR(radar.backgroundColor);
local g_clrLine = STORE_COLOR(radar.lineColor);
local g_clrEnemy = STORE_COLOR(radar.enemyColor);

local g_iHalfSize = FLOOR(radar.size / 2);
local g_iSize = g_iHalfSize * 2;
local g_iCenterX, g_iCenterY = radar.x + g_iHalfSize, radar.y + g_iHalfSize;

local g_iFont = draw.CreateFont("Tahoma Bold", 14, 800);



local DrawIcon;
do
    SET_FONT(g_iFont);

    local cIcon = 'X';

    local iCharOffsetX, iCharOffsetY = draw.GetTextSize(cIcon);
    iCharOffsetX, iCharOffsetY = FLOOR(iCharOffsetX / 2), FLOOR(iCharOffsetY / 2);

    function DrawIcon(iX, iY)
        TEXT_SHADOW(iX - iCharOffsetX, iY - iCharOffsetY, cIcon);
    end
end

local function drawRadar()
    local pLocalPlayer = entities.GetLocalPlayer();

    if not pLocalPlayer or not pLocalPlayer:IsAlive() then
        return;
    end

    local fOriginX, fOriginY = pLocalPlayer:GetAbsOrigin():Unpack();
    local iLocalTeam = pLocalPlayer:GetTeamNumber();

    local fCosRot, fSinRot;
    do
        local fYaw = RAD(engine.GetViewAngles().yaw - 90);
        fCosRot, fSinRot = COS(fYaw), SIN(fYaw);
    end

    g_clrBackground();
    FILLED_RECT(radar.x, radar.y, radar.x + g_iSize, radar.y + g_iSize);

    g_clrLine();
    LINE(g_iCenterX - g_iHalfSize, g_iCenterY, g_iCenterX + g_iHalfSize, g_iCenterY)
    LINE(g_iCenterX, g_iCenterY - g_iHalfSize, g_iCenterX, g_iCenterY + g_iHalfSize)

    g_clrEnemy();

    local aPlayers = entities.FindByClass("CTFPlayer");
    aPlayers[pLocalPlayer:GetIndex()] = nil;
    for _, pPlayer in pairs(aPlayers) do
        if pPlayer:IsAlive() and pPlayer:GetTeamNumber() ~= iLocalTeam then
            
            local fDX, fDY = pPlayer:GetAbsOrigin():Unpack();
            fDX, fDY = fDX - fOriginX, fDY - fOriginY;

            DrawIcon(
                FLOOR(g_iCenterX + CLAMP((fDX * fCosRot + fDY * fSinRot) / radar.distance, -1, 1) * g_iHalfSize), 
                FLOOR(g_iCenterY - CLAMP((fDY * fCosRot - fDX * fSinRot) / radar.distance, -1, 1) * g_iHalfSize)
            );

        end
    end
end

local aRecords = {};
local iMaxRecords = 256;
local fAverage = 0;

for i = 1, iMaxRecords do
    aRecords[i] = 0;
end

local function watermark()
    g_clrWhite();

    local iRecordIndex = globals.FrameCount() % iMaxRecords + 1;

    fAverage = fAverage - aRecords[iRecordIndex];
    aRecords[iRecordIndex] = globals.FrameTime() / iMaxRecords;
    fAverage = fAverage + aRecords[iRecordIndex];
    
    local sWatermarkText = ("[reLuaStorm] | Fps: %0.0f | Tps: %0.02f"):format(1 / fAverage, 1 / globals.TickInterval());

    local screen_width, _ = draw.GetScreenSize()
    local text_width, text_height = draw.GetTextSize(sWatermarkText)

    draw.Text(screen_width - text_width - 5, 5, sWatermarkText)
end

callbacks.Register("Draw", function()
    SET_FONT(g_iFont)
    drawRadar();
    watermark();
end)
