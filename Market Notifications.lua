--================================================ [ ZAVISOMOSTI ] ================================================
--mimgui
--effil
--samp.lua
--ffi
--ssl/https
--FAwesome6_solid
--IniCfg
--=================================================================================================================

--================================================ [ INFO SCRIPT ] ================================================
script_name("Market Notifications");
script_authors("Jenna Ortega Fan");
--=================================================================================================================
--================================================ [ LOADED LIB ] =================================================
require "lib.moonloader";
local imgui = require "mimgui";
local effil = require "effil";
local sampev = require "lib.samp.events";
local ffi = require "ffi";


local encoding = require "encoding";
encoding.default = "CP1251";
local u8 = encoding.UTF8;

local fa = require "fAwesome6_solid";

local inicfg = require "inicfg";
local mainIni = inicfg.load({
    telegram = 
    {
        token = "",
        chatID = "",
    }
}, "mnotf.ini");
if not doesFileExist("mnotf.ini") then inicfg.save(mainIni, "mnotf.ini") end
--=================================================================================================================
--=================================================================================================================
-- Get ArizonaName
function getArizonaName()
	local server_name = sampGetCurrentServerName()
	server_name = server_name:match("^Arizona [^|]+ | ([^|]+) |") or server_name:match("^Arizona [^|]+ | ([^|]+)$")
	return server_name or ""
end

-- Get my ID
function sampGetMyNickname()
	local result, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
	if result then
		return sampGetPlayerNickname(id)
	else
		return ""
	end
end
--=================================================================================================================
local new = imgui.new;
local renderWindow = new.bool(false);
local sizeX, sizeY = getScreenResolution();
--================================================ [ FUNCTION MAIN ] ==============================================
function main()
    if not isSampfuncsLoaded() or not isSampLoaded() then return end
    repeat wait(0) until isSampAvailable();

    sampRegisterChatCommand("mhelp", function() renderWindow[0] = not renderWindow[0] end);

    sampRegisterChatCommand("testtg", function(arg)
        sendTelegram("Сообщение успешно отправлено.")
    end)
    
    wait(5000)
        sampAddChatMessage("{FF3333}============================================{ffffff}",-1);
        sampAddChatMessage("{ff3333}[/mhelp]{ffffff} Market Notifications успешно загружен.{ffffff}", -1);
        sampAddChatMessage("{ff3333}[/mhelp]{ffffff} Активация: {FF6C6C}/mhelp{ffffff}",-1)
        sampAddChatMessage("{FF3333}============================================{ffffff}",-1);
    while true do
        wait(0);

    end
end
--=================================================================================================================
--================================================ [ Function  SendTelegram ] =====================================
function sendTelegram(message)
    local function threadHandle(runner, url, args, resolve, reject)
        local t = runner(url, args)
        local r = t:get(0)
        while not r do
            r = t:get(0)
            wait(0)
        end
        local status = t:status()
        if status == 'completed' then
            local ok, result = r[1], r[2]
            if ok then resolve(result) else reject(result) end
        elseif err then
            reject(err)
        elseif status == 'canceled' then
            reject(status)
        end
        t:cancel(0)
    end
    local function requestRunner()
        return effil.thread(function(u, a)
            local https = require 'ssl.https'
            local ok, result = pcall(https.request, u, a)
            if ok then
                return {true, result}
            else
                return {false, result}
            end
        end)
    end
    local function async_http_request(url, args, resolve, reject)
        local runner = requestRunner()
        if not reject then reject = function() end end
        lua_thread.create(function()
            threadHandle(runner, url, args, resolve, reject)
        end)
    end
    local function encodeUrl(str)
        str = str:gsub(' ', '%+')
        str = str:gsub('\n', '%%0A')
        return u8:encode(str, 'CP1251')
    end
    local function sendTelegramNotification(msg)
        msg = msg:gsub('{......}', '')
        msg = encodeUrl(msg)
        async_http_request('https://api.telegram.org/bot' .. mainIni.telegram.token .. '/sendMessage?chat_id=' .. mainIni.telegram.chatID .. '&text='..msg,'', function(result) end)
    end
    if message and message:len() > 0 then
        local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
        if _ then
            local srv = getArizonaName()
            if not srv then
                srv = 'Err'
            end
            message = '['..srv..'] '..sampGetPlayerNickname(id)..'('..id..'):\n'..message
            sendTelegramNotification(message)
        else
            message = '[Err]Unknown_Name(nil):\n'..message
            sendTelegramNotification(message)
        end
    else
        sendTelegramNotification('[/mhelp]: Не удалось отправить команду')
    end
end
--=================================================================================================================
local menu = {
    true,
    false
}
function uu()
    for i = 0,2 do
        menu[i] = false
    end
end

--================================================ [ FUNCTIONS FOR IMGUI ] ========================================
function rainbow(speed)
    local r = math.floor(math.sin(os.clock() * speed) * 127 + 128 ) / 255;
    local g = math.floor(math.sin(os.clock() * speed + 2) * 127 + 128 ) / 255;
    local b = math.floor(math.sin(os.clock() * speed + 4) * 127 + 128 ) / 255;
    return r, g, b, 1
end
function imgui.TextQuestion(label, description)
    imgui.TextDisabled(label)

    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end
--=================================================================================================================
--================================================ [ IMGUI ] ======================================================
local tokenbot = new.char[256](u8(mainIni.telegram.token)) -- Token bot
local chatid = new.char[256](u8(mainIni.telegram.chatID)) -- ChatID User
--=================================================================================================================
imgui.OnInitialize(function()
    imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5);
    fa.Init();

    
    
        imgui.SwitchContext()
        --==[ STYLE ]==--
        imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
        imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
        imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
        imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
        imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
        imgui.GetStyle().IndentSpacing = 0
        imgui.GetStyle().ScrollbarSize = 10
        imgui.GetStyle().GrabMinSize = 10
    
        --==[ BORDER ]==--
        imgui.GetStyle().WindowBorderSize = 1
        imgui.GetStyle().ChildBorderSize = 1
        imgui.GetStyle().PopupBorderSize = 1
        imgui.GetStyle().FrameBorderSize = 1
        imgui.GetStyle().TabBorderSize = 1
    
        --==[ ROUNDING ]==--
        imgui.GetStyle().WindowRounding = 5
        imgui.GetStyle().ChildRounding = 5
        imgui.GetStyle().FrameRounding = 5
        imgui.GetStyle().PopupRounding = 5
        imgui.GetStyle().ScrollbarRounding = 5
        imgui.GetStyle().GrabRounding = 5
        imgui.GetStyle().TabRounding = 5
    
        --==[ ALIGN ]==--
        imgui.GetStyle().WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
        imgui.GetStyle().ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
        imgui.GetStyle().SelectableTextAlign = imgui.ImVec2(0.5, 0.5)
        
        --==[ COLORS ]==--
        imgui.GetStyle().Colors[imgui.Col.Text]                   = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TextDisabled]           = imgui.ImVec4(0.50, 0.50, 0.50, 1.00)
        imgui.GetStyle().Colors[imgui.Col.WindowBg]               = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ChildBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PopupBg]                = imgui.ImVec4(0.07, 0.07, 0.07, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Border]                 = imgui.ImVec4(0.25, 0.25, 0.26, 0.54)
        imgui.GetStyle().Colors[imgui.Col.BorderShadow]           = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
        imgui.GetStyle().Colors[imgui.Col.FrameBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.FrameBgHovered]         = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
        imgui.GetStyle().Colors[imgui.Col.FrameBgActive]          = imgui.ImVec4(0.25, 0.25, 0.26, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TitleBg]                = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TitleBgActive]          = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TitleBgCollapsed]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.MenuBarBg]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarBg]            = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarGrab]          = imgui.ImVec4(0.00, 0.00, 0.00, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabHovered]   = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ScrollbarGrabActive]    = imgui.ImVec4(0.51, 0.51, 0.51, 1.00)
        imgui.GetStyle().Colors[imgui.Col.CheckMark]              = imgui.ImVec4(1.00, 1.00, 1.00, 1.00)
        imgui.GetStyle().Colors[imgui.Col.SliderGrab]             = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
        imgui.GetStyle().Colors[imgui.Col.SliderGrabActive]       = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Button]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ButtonHovered]          = imgui.ImVec4(0.21, 0.20, 0.20, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ButtonActive]           = imgui.ImVec4(0.41, 0.41, 0.41, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Header]                 = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.HeaderHovered]          = imgui.ImVec4(0.20, 0.20, 0.20, 1.00)
        imgui.GetStyle().Colors[imgui.Col.HeaderActive]           = imgui.ImVec4(0.47, 0.47, 0.47, 1.00)
        imgui.GetStyle().Colors[imgui.Col.Separator]              = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.SeparatorHovered]       = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.SeparatorActive]        = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.ResizeGrip]             = imgui.ImVec4(1.00, 1.00, 1.00, 0.25)
        imgui.GetStyle().Colors[imgui.Col.ResizeGripHovered]      = imgui.ImVec4(1.00, 1.00, 1.00, 0.67)
        imgui.GetStyle().Colors[imgui.Col.ResizeGripActive]       = imgui.ImVec4(1.00, 1.00, 1.00, 0.95)
        imgui.GetStyle().Colors[imgui.Col.Tab]                    = imgui.ImVec4(0.12, 0.12, 0.12, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TabHovered]             = imgui.ImVec4(0.28, 0.28, 0.28, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TabActive]              = imgui.ImVec4(0.30, 0.30, 0.30, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TabUnfocused]           = imgui.ImVec4(0.07, 0.10, 0.15, 0.97)
        imgui.GetStyle().Colors[imgui.Col.TabUnfocusedActive]     = imgui.ImVec4(0.14, 0.26, 0.42, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotLines]              = imgui.ImVec4(0.61, 0.61, 0.61, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotLinesHovered]       = imgui.ImVec4(1.00, 0.43, 0.35, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotHistogram]          = imgui.ImVec4(0.90, 0.70, 0.00, 1.00)
        imgui.GetStyle().Colors[imgui.Col.PlotHistogramHovered]   = imgui.ImVec4(1.00, 0.60, 0.00, 1.00)
        imgui.GetStyle().Colors[imgui.Col.TextSelectedBg]         = imgui.ImVec4(1.00, 0.00, 0.00, 0.35)
        imgui.GetStyle().Colors[imgui.Col.DragDropTarget]         = imgui.ImVec4(1.00, 1.00, 0.00, 0.90)
        imgui.GetStyle().Colors[imgui.Col.NavHighlight]           = imgui.ImVec4(0.26, 0.59, 0.98, 1.00)
        imgui.GetStyle().Colors[imgui.Col.NavWindowingHighlight]  = imgui.ImVec4(1.00, 1.00, 1.00, 0.70)
        imgui.GetStyle().Colors[imgui.Col.NavWindowingDimBg]      = imgui.ImVec4(0.80, 0.80, 0.80, 0.20)
        imgui.GetStyle().Colors[imgui.Col.ModalWindowDimBg]       = imgui.ImVec4(0.00, 0.00, 0.00, 0.70)
    
end)

local newFrame = imgui.OnFrame(
    function() return renderWindow[0] end,
    function(player)
        imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5));
        imgui.SetNextWindowSize(imgui.ImVec2(680,200), imgui.Cond.FirstUseEver); -- Here you change the window size
        imgui.Begin(fa.SHIELD_HALVED .. " Market Notifications", renderWindow, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse);
            imgui.BeginChild("##nav", imgui.ImVec2(162,160), true)
                if imgui.Button(u8"Основное", imgui.ImVec2(149,28)) then uu() menu[1] = true end;
                imgui.Separator();
                if imgui.Button(u8"О скрипте", imgui.ImVec2(149,28)) then uu() menu[2] = true end;
            imgui.EndChild();
            imgui.SameLine();
            imgui.BeginChild("##navAnswer", imgui.ImVec2(500, 160), true)
                if menu [1] then
                    imgui.Text("Token");
                    if imgui.InputText("##Token", tokenbot, 256) then
                        mainIni.telegram.token = ffi.string(tokenbot)
                        inicfg.save(mainIni, "mnotf.ini")
                    end
                    imgui.SameLine();
                    imgui.TextQuestion("( ? )", u8"- Ищем в  Telegram бота <<@botfather>>\n- Чтобы создать бота отправляете команду - <</newbot>>\n- Когда бот будет создан вы увидите -  HTTP API, вам нужно его скопировать и ввести в это поле.")

                    imgui.Text("ChatID");
                    if imgui.InputText("##ChatID", chatid, 256) then
                        mainIni.telegram.chatID = ffi.string(chatid)
                        inicfg.save(mainIni, "mnotf.ini")
                    end
                    imgui.SameLine();
                    imgui.TextQuestion("( ? )", u8"- Ищем в  Telegram бота <<@getmyid_bot>>\n- После первого вашего сообщение, он вам отправит > <<Your user ID>> вам нужно его скопировать и вставить в это поле.")
                end
                if menu [2] then -- Button "About the script"
                    imgui.Text(u8"О скрипте >\n- При покупке/продаже в лавке, вам прийдет уведомление в Telegram.")
                    imgui.Separator();
                    imgui.Text(u8"Разработчик >");
                    imgui.SameLine();
                    imgui.TextColored(imgui.ImVec4(rainbow(2)), u8"Jenna Ortega Fan")
                end
            imgui.EndChild();
        imgui.End()
    end
)
--=================================================================================================================
--================================================ [ SAMPEV ] ======================================================
function sampev.onServerMessage(color, text)
    if text:find('^.+ купил у вас .+, вы получили %$%d+ от продажи %(комиссия %d процент%(а%)%)') then
        local name, product, money = text:match('^(.+) купил у вас (.+), вы получили %$(%d+) от продажи %(комиссия %d процент%(а%)%)')
        local reg_text = 'Вы продали: "'..product..'" за '..money..'$ \nИгроку: '..name..'.'
        sendTelegram(reg_text)
    end
    -- 
    if text:find("Вы купили (.+) у игрока (%w+.%w+) за %$(%d+)") then
        local product, name, money = text:match('Вы купили (.+) у игрока (%w+.%w+) за %$(%d+)')
        local reg_text = 'Вы купили: "'..product..'" за '..money..'$ У игрока: '..name..'.'
        sendTelegram(reg_text)
    end
end
--=================================================================================================================