-- ============================================================================
-- DODGED Proxy v1.3.0 — Creative Growtopia Embedded Lua API edition
-- Ported from the Bothax (github.com/dravenox/bothax) build.
-- ============================================================================

local helpers = {}

local function strip_colors(text)
    if not text then return "" end
    return tostring(text):gsub("`.", ""):gsub("^%s+", ""):gsub("%s+$", "")
end
helpers.StripColors = strip_colors

local ITEM_IDS = {
    WRENCH         = 32,
    WORLD_LOCK     = 242,
    DIAMOND_LOCK   = 1796,
    BLUE_GEM_LOCK  = 7188,
    BLACK_GEM_LOCK = 11550,
    CHAMPAGNE      = 1974,
    TELEPHONE      = 3898,
    GEMS           = 112
}

local DELAYS = {
    DROP_DELAY     = 350,
    WEAR_DELAY     = 250,
    WAIT_TIMEOUT   = 2000,
    POLL_INTERVAL  = 50
}

-- =========================== CONFIGURATION ===========================
-- No file persistence in the new API (io/load are unavailable). Edit here.
local config = {
    version                = "1.3.0",
    developer              = "dodgedgit",
    branding               = "`0[`eDODGED`0]",
    branding_title         = "`eDODGED",

    hotkey_f4_respawn          = true,
    hotkey_cmd_cooldown_ms     = 300,
    custom_hotkeys             = {
        [1] = { key = nil, cmd = "", enabled = false },
        [2] = { key = nil, cmd = "", enabled = false },
        [3] = { key = nil, cmd = "", enabled = false },
        [4] = { key = nil, cmd = "", enabled = false }
    },

    cbgcolor               = true,
    dialogBorder           = "0,200,255,255",
    dialogBg               = "30,30,30,225",
    dialogDefaultColor     = "`o",

    wrench_mode            = "off",
    pull                   = false, kick = false, ban = false,
    wrench_touch_pull      = false,
    wrench_msg_pull        = "`7Pulled `0{name}",
    wrench_msg_kick        = "`6Kicked `0{name}",
    wrench_msg_ban         = "`4Banned `0{name}",
    wrench_msg_showbal     = "`eChecking balance: `0{name}",

    tp_ctrl_click_enabled  = true,
    tp_shift_click_enabled = true,

    tpdisplay              = false,
    tpdisplay_mode         = "all_position",
    tpdisplay_return       = false,
    tpdisplay_delay        = 3000,

    modfly                 = false,
    ghost                  = false,

    sspin = false, leme = false, reme = false, qeme = false,
    lewa = false, sleme = false, ceme = false, hol = false,
    holSpins = {},

    showbal                = false,
    showbal_use_chat       = false,
    bsdb                   = false,
    cbgl                   = false,
    buydl                  = false,
    autoGemDetect          = false,
    rank_titles            = true,
    spin_titles            = true,
    show_ping              = true,
    vendfilter             = false,
    autocombine            = true,

    translator = {
        enabled              = false,
        outgoing_enabled     = false,
        api_key              = "AQ.Ab8RN6J1pArBA_ku1P2z_naW-to9tVCt7pvIQH0PT7t_Lg7SLw",
        target_lang          = "en",
        outgoing_target_lang = "en",
        show_bubble          = true,
        show_console         = true,
        skip_same_lang       = true,
        filter_slave         = true
    },

    autosb_copysign        = true,
    autosb_autostart       = false,
    autosb_text            = "",
    autosb_start_count     = 0,
    autosb_total           = 20,
    autosb_webhook_enabled = false,
    autosb_webhook_url     = "",
    autosb_tag             = "`e#DODGED",

    cmd_drop_wl            = "w",
    cmd_drop_dl            = "d",
    cmd_drop_bgl           = "b",
    cmd_drop_black         = "bb",

    antislave              = false,
    spam_enabled           = false,
    spam_rainbow           = false,
    spam_random_color      = false,
    spam_slots             = {
        { active = true, text = "HALLO 1", delay = 3000 },
        { active = true, text = "HALLO 2", delay = 3000 },
        { active = true, text = "HALLO 3", delay = 3000 }
    }
}

-- In-memory config persistor (no-op; kept for compat with existing call sites).
local function auto_save_config(_) end

local operation_flags = {
    is_converting_dl   = false,
    is_sending_auto_tr = false,
    is_smart_dropping  = false,
    collect_buffer     = { black = 0, bgl = 0, dl = 0, wl = 0 },
    collect_timer_token = 0
}

local autosb_state = {
    running = false, start_count = 0, total = 20, world_name = "",
    start_time = 0, last_success_time = 0, success_flag = false,
    gems_type = "Gems", gems_used = 0, gems_left = 0,
    bgems_used = 0, bgems_left = 0, total_gems_used = 0, total_bgems_used = 0
}

local player_spin_titles = {}
local name_overrides = {}

-- ==================== 3-TIER AUTH ====================
local whitelist_state = {
    is_authorized     = false,
    role              = nil,
    user_ids          = {},
    bypass_uids       = {},
    hosters           = {},
    workers           = {},
    authorized_user   = nil
}

local worker_modal_state = {
    enabled                 = true,
    webhook_base            = "",
    webhook_champ           = "",
    webhook_drop            = "",
    webhook_worker_donation = "",
    webhook_hoster_donation = "",
    webhook_worker_storage  = "",
    webhook_hoster_storage  = "",
    webhook_hoster_modal    = "",
    webhook_hoster_champ    = "",
    webhook_hoster_drop     = "",
    webhook_bypass          = "",
    bypass_threads          = {
        modal    = "1559499269629546512",
        champ    = "1559499272636866591",
        drop     = "1559499275883515994",
        donation = "1559499278039384097",
        storage  = "1559499281029926973"
    },
    thread_id               = "1556975242402861168",
    thread_champ            = "1556975235075670017",
    thread_drop             = "1557127564701466674",
    last_sent_time          = 0,
    interval_ms             = 7000,
    is_requesting_bank      = false,
    bank_bgl                = 0,
    loop_started            = false,
    last_snapshot           = nil
}

-- ==================== WHITELIST FETCH ====================
-- NOTE: In the new API, `MakeRequest` inside the top-level chunk is fine
-- (worker thread). Just keep it out of hooks/callbacks.
local WHITELIST_URL = "https://raw.githubusercontent.com/dodgedgit/whitelist/main/whitelist.txt"

function helpers.FetchWorkerWhitelist()
    if type(MakeRequest) ~= "function" then
        return false, "MakeRequest not supported"
    end
    local url = WHITELIST_URL .. "?t=" .. tostring(os.time())
    local ok, res = pcall(MakeRequest, url, "GET", { ["User-Agent"] = "DodgedProxy/1.3" }, "", 5000)
    if not ok or not res or res.error or not res.content or res.status ~= 200 then
        return false, "whitelist fetch failed"
    end
    local all_uids, hst_map = {}, {}
    for line in tostring(res.content):gmatch("[^\r\n]+") do
        line = line:gsub("#.*$", "")
        local uid = line:match("^%s*(%d+)%s*$")
        if uid then
            all_uids[uid] = true
            hst_map[uid] = {
                role = "HOSTER", growId = "UID " .. uid, userId = uid,
                threadModal = "", threadChamp = "", threadSetor = "",
                threadDrop = "", threadDonation = "", threadStorage = ""
            }
        end
    end
    whitelist_state.user_ids    = all_uids
    whitelist_state.bypass_uids = {}
    whitelist_state.hosters     = hst_map
    whitelist_state.workers     = {}
    return true
end

function helpers.CheckLocalAuthorization()
    local ok, me = pcall(GetLocal)
    if not ok or not me or not me.userid then return false, nil end
    local my_uid = tostring(math.floor(tonumber(me.userid) or 0))
    if my_uid == "0" then return false, my_uid end
    local profile = whitelist_state.user_ids[my_uid] and whitelist_state.hosters[my_uid]
    if profile then
        profile.growId = me.name or profile.growId
        whitelist_state.is_authorized   = true
        whitelist_state.role            = "HOSTER"
        whitelist_state.authorized_user = profile
        return true, profile
    end
    whitelist_state.is_authorized   = false
    whitelist_state.authorized_user = nil
    return false, my_uid
end

-- ==================== ITEM / INVENTORY HELPERS ====================
-- New API: GetItemInfo(id_or_name). Unknown returns blank id=0.
local function get_champagne_item_id()
    if type(GetItemInfo) == "function" then
        for _, n in ipairs({"champagne","Champagne","champ","Champ"}) do
            local ok, res = pcall(GetItemInfo, n)
            if ok and res and res.id and res.id ~= 0 then return res.id end
        end
    end
    return ITEM_IDS.CHAMPAGNE
end

local function get_safe_item_count(item_id)
    if not item_id or tonumber(item_id) == nil then return 0 end
    local target = tonumber(item_id)
    if type(GetInventory) ~= "function" then return 0 end
    local ok, inv = pcall(GetInventory)
    if not ok or type(inv) ~= "table" then return 0 end
    for _, it in ipairs(inv) do
        if it and tonumber(it.id) == target then
            return tonumber(it.amount) or 0
        end
    end
    return 0
end
helpers.GetItemCount = get_safe_item_count

local function escape_json_str(str)
    if not str then return "" end
    local s = tostring(str)
    s = s:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\r', '\\r')
    s = s:gsub('\n', '\\n'):gsub('\t', '\\t')
    s = s:gsub('[%z\1-\31]', function(c) return string.format('\\u%04x', string.byte(c)) end)
    return s
end

-- ==================== LOG ROUTER ====================
function helpers.GetLogDestination(log_type)
    local role = whitelist_state.role or "WORKER"
    local key_thread = "thread" .. log_type:sub(1,1):upper() .. log_type:sub(2)

    if role == "BYPASS" then
        local th = whitelist_state.authorized_user and whitelist_state.authorized_user[key_thread]
        th = (th and th ~= "") and th or worker_modal_state.bypass_threads[log_type]
        return { webhook = worker_modal_state.webhook_bypass, thread_id = (th and th ~= "") and th or nil }
    elseif role == "HOSTER" then
        local user = whitelist_state.authorized_user
        local th = (user and user[key_thread] and user[key_thread] ~= "") and user[key_thread] or nil
        return { webhook = worker_modal_state["webhook_hoster_" .. log_type], thread_id = th }
    else
        local th = nil
        if log_type == "modal" then th = worker_modal_state.thread_id
        elseif log_type == "champ" then th = worker_modal_state.thread_champ
        elseif log_type == "drop" then th = worker_modal_state.thread_drop end
        local wh
        if log_type == "modal" then wh = worker_modal_state.webhook_base
        elseif log_type == "champ" then wh = worker_modal_state.webhook_champ or worker_modal_state.webhook_base
        elseif log_type == "drop" then wh = worker_modal_state.webhook_drop
        elseif log_type == "donation" then wh = worker_modal_state.webhook_worker_donation or worker_modal_state.webhook_drop
        elseif log_type == "storage" then wh = worker_modal_state.webhook_worker_storage or worker_modal_state.webhook_drop
        end
        return { webhook = wh, thread_id = th }
    end
end

local function get_user_role_label()
    if whitelist_state.role == "BYPASS" then return "Bypass / Owner" end
    if whitelist_state.role == "HOSTER" then return "Hoster" end
    if whitelist_state.role == "WORKER" then return "Worker" end
    return "User"
end

local function get_clean_worker_name()
    local ok, me = pcall(GetLocal)
    if ok and me and me.name then
        local raw = strip_colors(me.name)
        raw = raw:gsub("%b[]", " "):gsub("%b()", " "):gsub("@", "")
        raw = raw:gsub("^%s+", ""):gsub("%s+$", "")
        local first = raw:match("(%S+)")
        if first and first ~= "" then return first end
    end
    return (whitelist_state.role == "HOSTER" and "Hoster") or "Worker"
end

-- Helper for webhook dispatch: new API forbids MakeRequest inside hooks.
-- We schedule on the main script worker via Script.After.
local function schedule(fn)
    if type(Script) == "table" and type(Script.After) == "function" then
        return Script.After(1, fn)
    end
    -- Last-resort: run inline
    local ok, err = pcall(fn)
    if not ok then Log("schedule: " .. tostring(err)) end
    return nil
end

local function iso_now()
    -- os.date is unavailable in the new sandbox.
    local t = os.time()
    return string.format("%d", t)
end

function helpers.SendWorkerModalWebhook()
    if type(MakeRequest) ~= "function" then return end
    local dest = helpers.GetLogDestination("modal")
    if not dest.webhook or dest.webhook == "" then return end

    local ok_w, world = pcall(GetWorld)
    local world_name = (ok_w and world and world.name and world.name ~= "") and world.name or "UNKNOWN"
    local worker_name = get_clean_worker_name()

    local champ_id  = get_champagne_item_id()
    local black_val = get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK)
    local bgl_val   = get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK)
    local dl_val    = get_safe_item_count(ITEM_IDS.DIAMOND_LOCK)
    local wl_val    = get_safe_item_count(ITEM_IDS.WORLD_LOCK)
    local bank_val  = worker_modal_state.bank_bgl or 0
    local champ_val = get_safe_item_count(champ_id)

    local snap = worker_modal_state.last_snapshot
    if snap
        and black_val == snap.black and bgl_val == snap.bgl
        and dl_val == snap.dl and wl_val == snap.wl
        and bank_val == snap.bank and champ_val == snap.champ
        and world_name == snap.world then
        return
    end
    worker_modal_state.last_snapshot = {
        black = black_val, bgl = bgl_val, dl = dl_val, wl = wl_val,
        bank = bank_val, champ = champ_val, world = world_name
    }

    local role_label = get_user_role_label()
    local title = "💰 LIVE MODAL REPORT • " .. worker_name .. " [" .. role_label:upper() .. "]"
    local desc = "<:black:1556814063449800804>: **" .. black_val .. "**\n"
              .. "<:bgl:1556814259478855690>: **" .. bgl_val .. "**\n"
              .. "<:dl:1556814401695252560>: **" .. dl_val .. "**\n"
              .. "<:wl:1556814610420473946>: **" .. wl_val .. "**\n\n"
              .. "BANK BGL: **" .. bank_val .. "**\n"
              .. "CHAMP: **" .. champ_val .. "**"

    local payload = '{"embeds":[{"title":"' .. escape_json_str(title) ..
        '","description":"' .. escape_json_str(desc) .. '","color":16766720,' ..
        '"fields":[{"name":"👤 ' .. role_label .. '","value":"`' .. escape_json_str(worker_name) ..
        '`","inline":true},{"name":"🌍 World","value":"`' .. escape_json_str(world_name) ..
        '`","inline":true}],"timestamp":"' .. iso_now() .. '"}]}'

    schedule(function()
        local post_url = dest.webhook
        if dest.thread_id and dest.thread_id ~= "" then
            post_url = post_url .. "?thread_id=" .. dest.thread_id
        end
        pcall(MakeRequest, post_url, "POST", { ["Content-Type"] = "application/json" }, payload, 4000)
    end)
end

function helpers.SendDropWebhook(detail)
    if type(MakeRequest) ~= "function" then return end
    local dest = helpers.GetLogDestination("drop")
    if not dest.webhook or dest.webhook == "" then return end
    local ok_w, world = pcall(GetWorld)
    local world_name = (ok_w and world and world.name and world.name ~= "") and world.name or "UNKNOWN"
    local role_label = get_user_role_label()
    local payload = '{"embeds":[{"title":"📦 DROP LOG • ' .. role_label:upper() ..
        '","description":"' .. escape_json_str(role_label .. ": " .. get_clean_worker_name() ..
        " Dropped " .. tostring(detail or "-")) ..
        '","color":3447003,"fields":[{"name":"🌍 World","value":"`' ..
        escape_json_str(world_name) .. '`","inline":true},{"name":"💰 Total","value":"' ..
        escape_json_str(tostring(detail or "-")) .. '","inline":false}],"timestamp":"' .. iso_now() .. '"}]}'
    schedule(function()
        local url = dest.webhook
        if dest.thread_id and dest.thread_id ~= "" then
            url = url .. "?thread_id=" .. dest.thread_id
        end
        pcall(MakeRequest, url, "POST", { ["Content-Type"] = "application/json" }, payload, 4000)
    end)
end

function helpers.SendDonationWebhook(detail)
    if type(MakeRequest) ~= "function" then return end
    local dest = helpers.GetLogDestination("donation")
    if not dest.webhook or dest.webhook == "" then return end
    local ok_w, world = pcall(GetWorld)
    local world_name = (ok_w and world and world.name and world.name ~= "") and world.name or "UNKNOWN"
    local role_label = get_user_role_label()
    local payload = '{"embeds":[{"title":"🎁 DONATION LOG • ' .. role_label:upper() ..
        '","description":"' .. escape_json_str(role_label .. ": " .. get_clean_worker_name() ..
        " placed " .. tostring(detail or "-") .. " into Donation Box") ..
        '","color":15844367,"fields":[{"name":"🌍 World","value":"`' ..
        escape_json_str(world_name) .. '`","inline":true},{"name":"🎁 Item","value":"' ..
        escape_json_str(tostring(detail or "-")) .. '","inline":false}],"timestamp":"' .. iso_now() .. '"}]}'
    schedule(function()
        local url = dest.webhook
        if dest.thread_id and dest.thread_id ~= "" then
            url = url .. "?thread_id=" .. dest.thread_id
        end
        pcall(MakeRequest, url, "POST", { ["Content-Type"] = "application/json" }, payload, 4000)
    end)
end

-- ==================== CORE MOVEMENT / DROP ====================
function helpers.Say(str)
    local s = tostring(str)
    if s:find(config.branding, 1, true) == 1 then
        s = s:sub(#config.branding + 1):gsub("^%s*:?%s*", "")
    end
    SendPacket(2, "action|input\n|text|" .. config.branding .. " " .. s .. "\n")
end

function helpers.SayClean(str)
    SendPacket(2, "action|input\n|text|" .. tostring(str) .. "\n")
end

function helpers.OnConsoleMessage(str)
    local s = tostring(str)
    if s:find(config.branding, 1, true) == 1 then
        s = s:sub(#config.branding + 1):gsub("^%s*:?%s*", "")
    end
    LogToConsole(config.branding .. ": `e" .. s)
end

function helpers.OnTextOverlay(str)
    SendVariantList({ [0] = "OnTextOverlay", [1] = tostring(str) }, -1)
end

function helpers.SendTileEffect(x, y)
    local p = { type = 17, netid = 88, snetid = -1, state = 0, value = 0,
                x = x, y = y, xspeed = 8, yspeed = 88, dropped = 0,
                padding1 = 0, padding2 = 88, padding4 = 0, padding5 = 0, px = 0, py = 0 }
    SendPacketRaw(false, p)
    SendPacketRaw(true, p)
end

function helpers.SendFloatingNumber(value, x, y)
    local count = tonumber(value) or 0
    if count == 0 then return end
    local posX = (x < 100 and y < 60) and (x * 32 + 16) or x
    local posY = (x < 100 and y < 60) and (y * 32 + 16) or y
    SendVariantList({
        [0] = "OnParticleEffect", [1] = 181,
        [2] = { x = posX, y = posY }, [3] = count * 1.0, [4] = 0.0,
        netid = -1
    }, -1)
end

function helpers.OnDroppedItem(id, amount)
    SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. tostring(id) .. "|\nitem_count|" .. tostring(amount))
end

function helpers.OnWear(id)
    SendPacketRaw(false, { type = 10, value = tonumber(id) or 0 })
end

function helpers.wait_lock_amount(item_id, minimum, timeout_ms)
    local timeout = tonumber(timeout_ms) or DELAYS.WAIT_TIMEOUT
    local waited = 0
    while waited < timeout do
        if get_safe_item_count(item_id) >= minimum then return true end
        Sleep(DELAYS.POLL_INTERVAL)
        waited = waited + DELAYS.POLL_INTERVAL
    end
    return get_safe_item_count(item_id) >= minimum
end

-- New API: Client.GetObjects() (not GetObjectList)
function helpers.TakeAtTile(tile_x, tile_y)
    if type(Client) ~= "table" or type(Client.GetObjects) ~= "function" then return false end
    local ok, objs = pcall(Client.GetObjects)
    if not ok or not objs then return false end
    local count = 0
    for _, obj in ipairs(objs) do
        if obj and obj.pos and obj.oid then
            local ox = math.floor(obj.pos.x / 32)
            local oy = math.floor(obj.pos.y / 32)
            if ox == tile_x and oy == tile_y then
                SendPacketRaw(false, {
                    type = 11, value = obj.oid,
                    x = ox * 32 + 16, y = oy * 32 + 16
                })
                count = count + 1
            end
        end
    end
    return count > 0
end

-- Ping: no direct API in the new binding.
function helpers.GetPing()
    return 0
end

-- ==================== ENSURE / DROP ENGINE ====================
function helpers.EnsureAutoBlackCount(required)
    required = math.max(0, math.floor(tonumber(required) or 0))
    if required <= 0 then return true end
    local attempts = 0
    while get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK) < required and attempts < 15 do
        local cur_black = get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK)
        local missing = required - cur_black
        local have_bgl = get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK)
        if have_bgl < missing * 100 then break end
        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
        helpers.wait_lock_amount(ITEM_IDS.BLACK_GEM_LOCK, cur_black + 1, 1000)
        attempts = attempts + 1
    end
    return get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK) >= required
end

function helpers.CombineFromLower(item_id)
    if item_id == ITEM_IDS.DIAMOND_LOCK then
        if get_safe_item_count(ITEM_IDS.WORLD_LOCK) >= 100 then
            local before = get_safe_item_count(ITEM_IDS.DIAMOND_LOCK)
            helpers.OnWear(ITEM_IDS.WORLD_LOCK)
            helpers.wait_lock_amount(ITEM_IDS.DIAMOND_LOCK, before + 1, 1000)
            return true
        end
    elseif item_id == ITEM_IDS.BLUE_GEM_LOCK then
        if get_safe_item_count(ITEM_IDS.DIAMOND_LOCK) >= 100 then
            local ok, me = pcall(GetLocal)
            if ok and me and me.pos then
                -- Find nearest telephone via Client.GetTiles (new API)
                local closest
                if type(Client.GetTiles) == "function" then
                    local ok_t, tiles = pcall(Client.GetTiles, 0, 0, 100, 60)
                    if ok_t and tiles then
                        local px, py = math.floor(me.pos.x / 32), math.floor(me.pos.y / 32)
                        local best = 9999
                        for _, t in ipairs(tiles) do
                            if t.fg == ITEM_IDS.TELEPHONE or t.fg == 3898 then
                                local d = math.abs(t.x - px) + math.abs(t.y - py)
                                if d < best then best = d; closest = { x = t.x, y = t.y } end
                            end
                        end
                    end
                end
                if closest then
                    local before = get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK)
                    SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" .. closest.x .. "|\ny|" .. closest.y .. "|\nbuttonClicked|bglconvert")
                    helpers.wait_lock_amount(ITEM_IDS.BLUE_GEM_LOCK, before + 1, 1200)
                    return true
                end
            end
        end
    elseif item_id == ITEM_IDS.BLACK_GEM_LOCK then
        if get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK) >= 100 then
            local before = get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK)
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
            helpers.wait_lock_amount(ITEM_IDS.BLACK_GEM_LOCK, before + 1, 1200)
            return true
        end
    end
    return false
end

function helpers.BreakFromHigher(item_id)
    if item_id == ITEM_IDS.BLUE_GEM_LOCK then
        if get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK) > 0 then
            local before = get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK)
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
            helpers.wait_lock_amount(ITEM_IDS.BLUE_GEM_LOCK, before + 1, 1200)
            return true
        end
    elseif item_id == ITEM_IDS.DIAMOND_LOCK then
        if get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK) > 0 then
            local before = get_safe_item_count(ITEM_IDS.DIAMOND_LOCK)
            helpers.OnWear(ITEM_IDS.BLUE_GEM_LOCK)
            helpers.wait_lock_amount(ITEM_IDS.DIAMOND_LOCK, before + 1, 1000)
            return true
        end
    elseif item_id == ITEM_IDS.WORLD_LOCK then
        if get_safe_item_count(ITEM_IDS.DIAMOND_LOCK) > 0 then
            local before = get_safe_item_count(ITEM_IDS.WORLD_LOCK)
            helpers.OnWear(ITEM_IDS.DIAMOND_LOCK)
            helpers.wait_lock_amount(ITEM_IDS.WORLD_LOCK, before + 1, 1000)
            return true
        end
    end
    return false
end

function helpers.EnsureLockCount(item_id, required)
    required = math.max(0, math.floor(tonumber(required) or 0))
    if required <= 0 then return true end
    if get_safe_item_count(item_id) >= required then return true end

    if item_id == ITEM_IDS.BLACK_GEM_LOCK then
        return helpers.EnsureAutoBlackCount(required)
    end

    local attempts = 0
    while get_safe_item_count(item_id) < required and attempts < 10 do
        if not helpers.CombineFromLower(item_id) then break end
        attempts = attempts + 1
    end
    if get_safe_item_count(item_id) >= required then return true end

    attempts = 0
    while get_safe_item_count(item_id) < required and attempts < 20 do
        if not helpers.BreakFromHigher(item_id) then break end
        attempts = attempts + 1
    end
    return get_safe_item_count(item_id) >= required
end

function helpers.ExecuteDropWithVerify(item_id, amount)
    amount = math.max(0, math.floor(tonumber(amount) or 0))
    if amount <= 0 then return 0 end
    local total = 0
    local remaining = amount
    while remaining > 0 do
        local cur = get_safe_item_count(item_id)
        if cur <= 0 then break end
        local chunk = math.min(remaining, math.min(cur, 100))
        local before = cur
        helpers.OnDroppedItem(item_id, chunk)
        local waited, confirmed = 0, false
        while waited < 450 do
            Sleep(50); waited = waited + 50
            if get_safe_item_count(item_id) <= (before - chunk) then confirmed = true; break end
        end
        local after = get_safe_item_count(item_id)
        local dropped = math.max(0, before - after)
        if dropped > 0 then
            total = total + dropped
            remaining = remaining - dropped
            if remaining > 0 then Sleep(DELAYS.DROP_DELAY) end
        else
            break
        end
    end
    return total
end

local function parse_positive_integer(raw)
    if type(raw) ~= "string" then raw = tostring(raw or "") end
    local v = raw:match("^%s*(%d+)%s*$")
    local n = tonumber(v)
    if n and n > 0 then return math.floor(n) end
    return nil
end

function helpers.DropWorldLock(count)
    if not count or count <= 0 then helpers.Say("`4Invalid amount!"); return end
    schedule(function()
        operation_flags.is_smart_dropping = true
        local dl = math.floor(count / 100)
        local wl = count % 100
        local bgl = math.floor(dl / 100); dl = dl % 100

        if (bgl > 0 or dl > 0) and get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK) == 0
           and get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK) == 0
           and get_safe_item_count(ITEM_IDS.DIAMOND_LOCK) == 0
           and get_safe_item_count(ITEM_IDS.WORLD_LOCK) >= count then
            bgl, dl, wl = 0, 0, count
        end

        local parts = {}
        if bgl > 0 and helpers.EnsureLockCount(ITEM_IDS.BLUE_GEM_LOCK, bgl) then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.BLUE_GEM_LOCK, bgl)
            if n > 0 then table.insert(parts, "**" .. n .. "** BGL"); Sleep(DELAYS.DROP_DELAY) end
        end
        if dl > 0 and helpers.EnsureLockCount(ITEM_IDS.DIAMOND_LOCK, dl) then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.DIAMOND_LOCK, dl)
            if n > 0 then table.insert(parts, "**" .. n .. "** DL"); Sleep(DELAYS.DROP_DELAY) end
        end
        if wl > 0 and helpers.EnsureLockCount(ITEM_IDS.WORLD_LOCK, wl) then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.WORLD_LOCK, wl)
            if n > 0 then table.insert(parts, "**" .. n .. "** WL") end
        end

        if #parts > 0 then
            helpers.SayClean(config.branding .. " `eDROPPED: " .. table.concat(parts, " "))
            helpers.SendDropWebhook(table.concat(parts, " "))
        else
            helpers.Say("`4Drop failed or insufficient locks.")
        end
        operation_flags.is_smart_dropping = false
    end)
end

function helpers.DropDiamondLock(count)
    if not count or count <= 0 then helpers.Say("`4Invalid amount!"); return end
    schedule(function()
        local bgl = math.floor(count / 100)
        local dl = count % 100
        if bgl > 0 and get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK) == 0
           and get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK) == 0
           and get_safe_item_count(ITEM_IDS.DIAMOND_LOCK) >= count then
            bgl, dl = 0, count
        end
        local parts = {}
        if bgl > 0 and helpers.EnsureLockCount(ITEM_IDS.BLUE_GEM_LOCK, bgl) then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.BLUE_GEM_LOCK, bgl)
            if n > 0 then table.insert(parts, "**" .. n .. "** BGL"); Sleep(DELAYS.DROP_DELAY) end
        end
        if dl > 0 and helpers.EnsureLockCount(ITEM_IDS.DIAMOND_LOCK, dl) then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.DIAMOND_LOCK, dl)
            if n > 0 then table.insert(parts, "**" .. n .. "** DL") end
        end
        if #parts > 0 then
            helpers.SayClean(config.branding .. " `eDROPPED: " .. table.concat(parts, " "))
            helpers.SendDropWebhook(table.concat(parts, " "))
        else helpers.Say("`4Drop failed.") end
    end)
end

function helpers.DropBlueGemLock(count)
    if not count or count <= 0 then helpers.Say("`4Invalid amount!"); return end
    schedule(function()
        local black_needed = math.floor(count / 100)
        local bgl_needed = count % 100
        local parts = {}
        if black_needed > 0 and helpers.EnsureLockCount(ITEM_IDS.BLACK_GEM_LOCK, black_needed) then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.BLACK_GEM_LOCK, black_needed)
            if n > 0 then table.insert(parts, "**" .. n .. "** BLACK"); Sleep(DELAYS.DROP_DELAY) end
        end
        if bgl_needed > 0 and helpers.EnsureLockCount(ITEM_IDS.BLUE_GEM_LOCK, bgl_needed) then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.BLUE_GEM_LOCK, bgl_needed)
            if n > 0 then table.insert(parts, "**" .. n .. "** BGL") end
        end
        if #parts > 0 then
            helpers.SayClean(config.branding .. " `eDROPPED: " .. table.concat(parts, " "))
            helpers.SendDropWebhook(table.concat(parts, " "))
        else helpers.Say("`4Drop failed.") end
    end)
end

function helpers.DropBlackLock(count)
    if not count or count <= 0 then helpers.Say("`4Invalid amount!"); return end
    schedule(function()
        if not helpers.EnsureLockCount(ITEM_IDS.BLACK_GEM_LOCK, count) then
            helpers.Say("`4Not enough BLACK to drop!"); return
        end
        local n = helpers.ExecuteDropWithVerify(ITEM_IDS.BLACK_GEM_LOCK, count)
        if n > 0 then
            helpers.SayClean(config.branding .. " `eDROPPED: **" .. n .. "** BLACK")
            helpers.SendDropWebhook("**" .. n .. "** BLACK")
        else helpers.Say("`4Drop failed.") end
    end)
end

function helpers.DropAllLocks()
    schedule(function()
        local black = get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK)
        local bgl   = get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK)
        local dl    = get_safe_item_count(ITEM_IDS.DIAMOND_LOCK)
        local wl    = get_safe_item_count(ITEM_IDS.WORLD_LOCK)
        local parts = {}
        if black > 0 then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.BLACK_GEM_LOCK, black)
            if n > 0 then table.insert(parts, "**" .. n .. "** BLACK"); Sleep(DELAYS.DROP_DELAY) end
        end
        if bgl > 0 then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.BLUE_GEM_LOCK, bgl)
            if n > 0 then table.insert(parts, "**" .. n .. "** BGL"); Sleep(DELAYS.DROP_DELAY) end
        end
        if dl > 0 then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.DIAMOND_LOCK, dl)
            if n > 0 then table.insert(parts, "**" .. n .. "** DL"); Sleep(DELAYS.DROP_DELAY) end
        end
        if wl > 0 then
            local n = helpers.ExecuteDropWithVerify(ITEM_IDS.WORLD_LOCK, wl)
            if n > 0 then table.insert(parts, "**" .. n .. "** WL") end
        end
        if #parts > 0 then
            helpers.SayClean(config.branding .. " `eDROP ALL: " .. table.concat(parts, " "))
            helpers.SendDropWebhook(table.concat(parts, " "))
        else helpers.Say("`4No locks to drop!") end
    end)
end

-- ==================== CONVERSIONS ====================
function helpers.ConvertBlackToBlue()
    schedule(function()
        if get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK) < 1 then
            helpers.OnTextOverlay("`4Not enough BLACK!")
            return
        end
        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
        helpers.Say("`2Converted `b1 BLACK `e-> `e100 BGL")
    end)
end

function helpers.ConvertBlueToBlack()
    schedule(function()
        if get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK) < 100 then
            helpers.OnTextOverlay("`4Need at least 100 BGL!")
            return
        end
        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
        helpers.Say("`2Converted `e100 BGL `e-> `b1 BLACK")
    end)
end

-- ==================== BANK ====================
function helpers.DepositBank(amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return end
    SendPacket(2, "action|dialog_return\ndialog_name|bank_deposit\nbgl_count|" .. amount .. "\n")
    helpers.Say("`eDeposited " .. amount .. " BGL to bank.")
end

function helpers.WithdrawBank(amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return end
    SendPacket(2, "action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|" .. amount .. "\n")
    helpers.Say("`eWithdrawn " .. amount .. " BGL from bank.")
end

-- ==================== AUTO-COMBINE / COLLECT ====================
function helpers.AutoCombineCollectedLocks()
    if not config.autocombine then return end
    schedule(function()
        Sleep(400)
        local wl = get_safe_item_count(ITEM_IDS.WORLD_LOCK)
        if wl >= 100 then
            local before = get_safe_item_count(ITEM_IDS.DIAMOND_LOCK)
            helpers.OnWear(ITEM_IDS.WORLD_LOCK)
            helpers.wait_lock_amount(ITEM_IDS.DIAMOND_LOCK, before + 1, 1500)
        end
        local bgl = get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK)
        if bgl >= 100 then
            local before = get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK)
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
            helpers.wait_lock_amount(ITEM_IDS.BLACK_GEM_LOCK, before + 1, 1500)
        end
    end)
end

function helpers.BufferCollectedItem(item_type, amount)
    local n = tonumber(amount) or 0
    if n <= 0 then return end
    operation_flags.collect_timer_token = operation_flags.collect_timer_token + 1
    local tok = operation_flags.collect_timer_token
    operation_flags.collect_buffer[item_type] =
        (operation_flags.collect_buffer[item_type] or 0) + n

    schedule(function()
        Sleep(500)
        if tok ~= operation_flags.collect_timer_token then return end
        local b = operation_flags.collect_buffer
        local parts = {}
        if b.black > 0 then table.insert(parts, b.black .. " BLACK") end
        if b.bgl > 0 then table.insert(parts, b.bgl .. " BGL") end
        if b.dl > 0 then table.insert(parts, b.dl .. " DL") end
        if b.wl > 0 then table.insert(parts, b.wl .. " WL") end
        if #parts > 0 then
            helpers.OnConsoleMessage("`eCollected `0" .. table.concat(parts, ", "))
            helpers.OnTextOverlay("`eCollected `0" .. table.concat(parts, ", "))
        end
        operation_flags.collect_buffer = { black = 0, bgl = 0, dl = 0, wl = 0 }
        helpers.AutoCombineCollectedLocks()
    end)
end

-- ==================== BANK DIALOG + MODAL LOOP ====================
function helpers.RequestBankBalance()
    local ok, world = pcall(GetWorld)
    if not ok or not world or not world.name or world.name == "" or world.name == "EXIT" then return end
    worker_modal_state.is_requesting_bank = true
    SendPacket(2, "action|dialog_return\ndialog_name|popup\nbuttonClicked|bgls\n")
    schedule(function()
        Sleep(1500)
        if worker_modal_state.is_requesting_bank then
            worker_modal_state.is_requesting_bank = false
            helpers.SendWorkerModalWebhook()
        end
    end)
end

function helpers.StartWorkerModalLoop()
    if worker_modal_state.loop_started then return end
    worker_modal_state.loop_started = true
    Script.Every(worker_modal_state.interval_ms, function()
        if worker_modal_state.enabled then
            local ok, world = pcall(GetWorld)
            if ok and world and world.name and world.name ~= "" and world.name ~= "EXIT" then
                helpers.RequestBankBalance()
            end
        end
    end)
end

-- ==================== TRANSLATOR ====================
function helpers.UrlEncode(str)
    if not str then return "" end
    str = tostring(str):gsub("\n", "\r\n")
    str = str:gsub("([^%w %-%_%.%~])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return (str:gsub(" ", "+"))
end

function helpers.EscapeJson(str)
    return escape_json_str(str)
end

local function extract_ai_text(json)
    if not json or json == "" then return nil end
    local parts_pos = json:find('"parts"%s*:%s*%[')
    local from = parts_pos or 1
    local s_start, s_end = json:find('"text"%s*:%s*"', from)
    if not s_start then
        s_start, s_end = json:find('"text"%s*:%s*"')
        if not s_start then return nil end
    end
    local idx = s_end + 1
    local res = {}
    while idx <= #json do
        local c = json:sub(idx, idx)
        if c == '\\' then
            table.insert(res, json:sub(idx, idx + 1))
            idx = idx + 2
        elseif c == '"' then break
        else
            table.insert(res, c); idx = idx + 1
        end
    end
    return table.concat(res)
end

function helpers.UnescapeJson(str)
    if not str then return "" end
    local res = str:gsub('\\u(%x%x%x%x)', function(hex)
        local code = tonumber(hex, 16)
        if not code then return "" end
        if code < 128 then return string.char(code) end
        if code < 2048 then return string.char(192 + math.floor(code / 64), 128 + (code % 64)) end
        return string.char(224 + math.floor(code / 4096), 128 + (math.floor(code / 64) % 64), 128 + (code % 64))
    end)
    res = res:gsub('\\"', '"'):gsub('\\\\', '\\'):gsub('\\/', '/')
    res = res:gsub('\\n', ' '):gsub('\\r', ''):gsub('\\t', ' ')
    return res:gsub("^%s*(.-)%s*$", "%1")
end

local ai_cache = {}
local ai_keys = {}
local MAX_CACHE = 500

function helpers.ApplyOriginalColorPattern(orig, trans)
    if not trans or trans == "" then return "" end
    if not orig or orig == "" then return "`0" .. trans end
    local cols = {}
    for c in tostring(orig):gmatch("(`%S)") do table.insert(cols, c) end
    if #cols == 0 then return "`0" .. trans end
    if #cols == 1 then return cols[1] .. trans end
    local out, ci = {}, 1
    for word in trans:gmatch("%S+") do
        table.insert(out, cols[ci] .. word)
        ci = (ci % #cols) + 1
    end
    return table.concat(out, " ")
end

function helpers.TranslateText(raw_text, target_lang)
    if not raw_text or raw_text == "" then return nil, nil end
    if type(MakeRequest) ~= "function" then return nil, nil end

    local target = (target_lang == "id") and "Indonesian" or "English"
    local tcode = (target_lang == "id") and "id" or "en"
    local clean = tostring(raw_text):gsub("`.", ""):gsub("^%s*(.-)%s*$", "%1")
    if clean == "" then return nil, nil end

    local key = tcode .. ":" .. tostring(raw_text)
    if ai_cache[key] then return ai_cache[key].text, ai_cache[key].lang end

    local api_key = (config.translator and config.translator.api_key ~= "" and config.translator.api_key)
        or "AQ.Ab8RN6J1pArBA_ku1P2z_naW-to9tVCt7pvIQH0PT7t_Lg7SLw"

    local prompt = "Translate the following Growtopia in-game chat to " .. target ..
        ". Preserve color codes (e.g. `2, `4). Output only the translation:\n" .. tostring(raw_text)

    local payload = '{"contents":[{"parts":[{"text":"' .. escape_json_str(prompt) .. '"}]}],"generationConfig":{"temperature":0.1,"maxOutputTokens":200}}'
    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=" .. api_key
    local ok, resp = pcall(MakeRequest, url, "POST", { ["Content-Type"] = "application/json", ["X-goog-api-key"] = api_key }, payload, 4000)

    if ok and resp and not resp.error and resp.content and resp.content ~= "" then
        local raw = extract_ai_text(resp.content)
        if raw and raw ~= "" then
            local translated = helpers.UnescapeJson(raw)
            if tostring(raw_text):find("`%S") and not translated:find("`%S") then
                translated = helpers.ApplyOriginalColorPattern(raw_text, translated)
            end
            -- Cache
            if not ai_cache[key] then
                table.insert(ai_keys, key)
                if #ai_keys > MAX_CACHE then
                    local old = table.remove(ai_keys, 1)
                    ai_cache[old] = nil
                end
            end
            ai_cache[key] = { text = translated, lang = nil }
            return translated, nil
        end
    end

    -- Fallback: Google Translate free endpoint
    local ok2, fb = pcall(MakeRequest,
        "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=" .. tcode ..
        "&dt=t&q=" .. helpers.UrlEncode(clean),
        "GET", { ["User-Agent"] = "Mozilla/5.0" }, "", 3000)
    if ok2 and fb and not fb.error and fb.content and fb.content ~= "" then
        local m = fb.content:match('^%[%[%["(.-)",')
        if m then
            local res = m:gsub('\\"', '"'):gsub('\\n', ' ')
            res = helpers.ApplyOriginalColorPattern(raw_text, res)
            ai_cache[key] = { text = res, lang = nil }
            return res, nil
        end
    end

    return nil, nil
end

-- ==================== SLASH COMMAND HANDLER ====================
local COMMAND_MAP = {}
local COMMAND_ALIASES = {}

local function normalize_command(raw)
    local v = tostring(raw or ""):lower()
    v = v:gsub("^%s*/+", ""):gsub("^%s+", ""):gsub("%s+$", "")
    return v
end

local function add_command(def)
    local name = normalize_command(def.name)
    if name == "" then return end
    def.name = name
    def.aliases = def.aliases or {}
    COMMAND_MAP[name] = def
    for _, a in ipairs(def.aliases) do
        local an = normalize_command(a)
        if an ~= "" and an ~= name then COMMAND_ALIASES[an] = name end
    end
end

local function resolve_command(token)
    local c = normalize_command(token)
    if COMMAND_MAP[c] then return c, COMMAND_MAP[c] end
    local canon = COMMAND_ALIASES[c]
    if canon and COMMAND_MAP[canon] then return canon, COMMAND_MAP[canon] end
    return nil, nil
end

local function parse_dialog_number(raw)
    return tonumber(tostring(raw or ""):gsub(",", ""):match("(%d+)")) or 0
end

-- ==================== INVENTORY PARSER ====================
local function parse_inventory_summary(dialog)
    local text = tostring(dialog or "")
    if text == "" then return nil end

    local name = text:match("|big|.-([^|]+)'s Inventory")
    if not name then name = text:match("([^|]+)'s Inventory") or "Unknown" end
    name = name:gsub("`.", ""):gsub("^%s+", ""):gsub("%s+$", "")

    local bgl_bank = parse_dialog_number(text:match("Blue Gem Locks in the Bank:.-([%d,]+)"))
    local black, bgl, dl, wl, champ = 0, 0, 0, 0, 0
    for line in text:gmatch("[^\n]+") do
        if line:find("|11550|", 1, true) then black = parse_dialog_number(line:match("|11550|([%d,]+)"))
        elseif line:find("|7188|", 1, true) then bgl = parse_dialog_number(line:match("|7188|([%d,]+)"))
        elseif line:find("|1796|", 1, true) then dl = parse_dialog_number(line:match("|1796|([%d,]+)"))
        elseif line:find("|242|", 1, true) then wl = parse_dialog_number(line:match("|242|([%d,]+)"))
        elseif line:find("Champagne", 1, true) then
            local g = parse_dialog_number(line:match("|%d+|([%d,]+)"))
            if g > champ then champ = g end
        end
    end

    local bgl_total = bgl + bgl_bank
    return {
        playername = name,
        total_blackgl = black + math.floor(bgl_total / 100),
        total_bgl = (bgl_total % 100) + math.floor(dl / 100),
        total_dl = (dl % 100) + math.floor(wl / 100),
        remaining_wl = wl % 100,
        champ_count = champ
    }
end

local function format_balance_msg(s)
    return " `0" .. s.playername .. " `eBalance: `aBLACK " .. s.total_blackgl ..
        " `eBGL " .. s.total_bgl .. " `1DL " .. s.total_dl ..
        " `6WL " .. s.remaining_wl .. " `tCHAMP: " .. s.champ_count
end

-- ==================== UTILITY DIALOGS (unchanged wire format) ====================
local function build_dialog_header()
    return {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|"
    }
end

function helpers.OpenMenuDialog()
    local lines = build_dialog_header()
    table.insert(lines, "add_label_with_icon|small|`eDODGED `9Automation & Worker Proxy``|left|11550|")
    table.insert(lines, "add_spacer|small|")
    table.insert(lines, "add_label_with_icon|small|`eAll Available Proxy Commands|left|658|")
    table.insert(lines, "add_spacer|small|")
    -- Enumerate registered commands
    local seen = {}
    for name, def in pairs(COMMAND_MAP) do
        if not seen[name] then
            seen[name] = true
            local usage = def.usage or ("/" .. name)
            table.insert(lines, "add_smalltext|`9• `2" .. usage .. " `9- " .. (def.description or "") .. "|left|")
        end
    end
    table.insert(lines, "add_spacer|small|")
    table.insert(lines, "add_quick_exit||")
    table.insert(lines, "end_dialog|bglproxy_menu|Close||")
    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(lines, "\n") }, -1)
end

function helpers.OpenOptionDialog()
    local lines = build_dialog_header()
    table.insert(lines, "add_label_with_icon|big|" .. config.branding .. " `eFeature Toggle Options``|left|7188|")
    table.insert(lines, "add_spacer|small|")
    table.insert(lines, "add_smalltext|`9Manage and toggle proxy features.|left|")
    table.insert(lines, "add_spacer|small|")

    local toggles = {
        { "opt_mf",  "`2Enable `1ModFly Movement", config.modfly },
        { "opt_tp",  "`2Enable `1Click Teleport", config.tpdisplay },
        { "opt_vendfilter", "`2Enable `1Vending Cost Filter", config.vendfilter },
        { "opt_bsdb", "`2Enable `1Block SDB", config.bsdb },
        { "opt_antislave", "`2Enable `1Auto Remove Spammer Slave", config.antislave },
        { "opt_cbgl", "`2Enable `1Telephone BGL Converter", config.cbgl },
        { "opt_buydl", "`2Enable `1Telephone Buy DL", config.buydl },
        { "opt_autocombine", "`2Enable `1Auto Combine Locks", config.autocombine },
        { "opt_cbgcolor", "`2Enable `1Custom Dialog Theme", config.cbgcolor },
        { "opt_tr_in",  "`2Enable `1Incoming Chat Translator", config.translator.enabled },
        { "opt_tr_out", "`2Enable `1Outgoing Chat Translator", config.translator.outgoing_enabled },
        { "opt_cpull", "`2Enable `1Click Pull Player", config.wrench_touch_pull },
        { "opt_smodal", "`2Enable `1Show Player Balance", config.showbal },
        { "opt_sspin", "`2Enable `1Short Spin", config.sspin },
        { "opt_gemdetect", "`2Enable `1Auto Gem Detector", config.autoGemDetect },
        { "opt_rank_titles", "`2Enable `1Player & Mod Titles", config.rank_titles },
        { "opt_spin_titles", "`2Enable `1Last Spin Title", config.spin_titles },
        { "opt_show_ping", "`2Enable `1Live Ping Tag", config.show_ping }
    }
    for _, t in ipairs(toggles) do
        table.insert(lines, "add_checkbox|" .. t[1] .. "|" .. t[2] .. "|" .. (t[3] and 1 or 0) .. "|")
    end

    table.insert(lines, "add_spacer|small|")
    table.insert(lines, "add_label_with_icon|small|`ePrimary Wrench Mode Action|left|32|")
    table.insert(lines, "add_custom_button|opt_wrm_pull|textLabel:`2PULL``;size:small;middle_colour:529240319;border_colour:529240319;display:block;|")
    table.insert(lines, "reset_placement_x|")
    table.insert(lines, "add_custom_button|opt_wrm_kick|textLabel:`6KICK``;size:small;middle_colour:3389566975;border_colour:3389566975;display:block;|")
    table.insert(lines, "reset_placement_x|")
    table.insert(lines, "add_custom_button|opt_wrm_ban|textLabel:`4BAN``;size:small;middle_colour:3434645503;border_colour:3434645503;display:block;|")
    table.insert(lines, "reset_placement_x|")
    table.insert(lines, "add_custom_button|opt_wrm_off|textLabel:`7OFF``;size:small;middle_colour:1178995455;border_colour:1178995455;display:block;|")
    table.insert(lines, "reset_placement_x|")

    table.insert(lines, "add_quick_exit||")
    table.insert(lines, "end_dialog|bglproxy_options|Cancel|`2Save Options|")
    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(lines, "\n") }, -1)
end

-- ==================== UI DASHBOARD (replaces ImGui) ====================
local GUI_STATE = {
    open = false,
    tab = "workers",
    worker_page = 1,
    last_sync = 0,
    api_status = "Idle",
    api_logs = {}
}

local function refresh_dashboard_ui()
    if not GUI_STATE.open then return end
    -- Placeholder: UI is refreshed on demand
end

local function sync_dashboard()
    if type(MakeRequest) ~= "function" then
        GUI_STATE.api_status = "MakeRequest unavailable"
        return
    end
    GUI_STATE.api_status = "Syncing..."
    schedule(function()
        pcall(helpers.FetchWorkerWhitelist)
        GUI_STATE.api_status = "Online"
        GUI_STATE.last_sync = os.time()
        refresh_dashboard_ui()
    end)
end

local function build_dashboard()
    UI.Clear()
    UI.Window("dodged_dash", { title = "DODGED PROXY • Dashboard", width = 640, height = 480 })

    -- Header
    local role = whitelist_state.role or "GUEST"
    local me_ok, me = pcall(GetLocal)
    local me_name = (me_ok and me and me.name) or "Player"
    UI.Text("hdr", { parent = "dodged_dash",
        text = "[" .. role .. "] " .. me_name .. "  •  API: " .. GUI_STATE.api_status })

    UI.Separator("sep1", { parent = "dodged_dash" })

    -- Buttons row
    UI.Button("b_menu",   { parent = "dodged_dash", text = "Command Menu" })
    UI.SameLine("s1",     { parent = "dodged_dash" })
    UI.Button("b_opt",    { parent = "dodged_dash", text = "Options" })
    UI.SameLine("s2",     { parent = "dodged_dash" })
    UI.Button("b_hotkey", { parent = "dodged_dash", text = "Hotkeys" })
    UI.SameLine("s3",     { parent = "dodged_dash" })
    UI.Button("b_sync",   { parent = "dodged_dash", text = "Refresh" })

    UI.Separator("sep2", { parent = "dodged_dash" })

    -- Whitelist listing
    local workers = {}
    for uid, w in pairs(whitelist_state.workers or {}) do
        table.insert(workers, { uid = uid, name = w.growId or "?" })
    end
    table.sort(workers, function(a, b) return a.name:lower() < b.name:lower() end)

    local per_page = 8
    local total_pages = math.max(1, math.ceil(#workers / per_page))
    local page = math.min(GUI_STATE.worker_page, total_pages)
    GUI_STATE.worker_page = page
    local start_i = (page - 1) * per_page + 1
    local end_i = math.min(start_i + per_page - 1, #workers)

    UI.Text("lbl_workers", { parent = "dodged_dash", text = "Whitelisted Workers (" .. #workers .. ")" })
    if #workers == 0 then
        UI.Text("empty", { parent = "dodged_dash", text = "  (none)" })
    else
        for i = start_i, end_i do
            UI.Text("w_" .. i, { parent = "dodged_dash",
                text = "  • " .. workers[i].name .. "  (UID: " .. workers[i].uid .. ")" })
        end
    end
    UI.Button("prev", { parent = "dodged_dash", text = "< Prev" })
    UI.SameLine("s4", { parent = "dodged_dash" })
    UI.Text("pageinfo", { parent = "dodged_dash", text = "Page " .. page .. " / " .. total_pages })
    UI.SameLine("s5", { parent = "dodged_dash" })
    UI.Button("next", { parent = "dodged_dash", text = "Next >" })

    UI.Separator("sep3", { parent = "dodged_dash" })

    -- Command reference
    UI.Text("cmd_hdr", { parent = "dodged_dash", text = "Registered commands: " .. (function()
        local n = 0; for _ in pairs(COMMAND_MAP) do n = n + 1 end; return n
    end)() })
end

function helpers.ToggleGui()
    GUI_STATE.open = not GUI_STATE.open
    if GUI_STATE.open then
        sync_dashboard()
        build_dashboard()
    else
        UI.Clear()
    end
end

Script.On("OnUI", "dodged_ui_events", function(id, event, value)
    if not GUI_STATE.open then return end
    if event == "click" then
        if id == "b_menu" then helpers.OpenMenuDialog()
        elseif id == "b_opt" then helpers.OpenOptionDialog()
        elseif id == "b_hotkey" then helpers.OpenHotkeyDialog()
        elseif id == "b_sync" then sync_dashboard()
        elseif id == "prev" then
            GUI_STATE.worker_page = math.max(1, GUI_STATE.worker_page - 1)
            build_dashboard()
        elseif id == "next" then
            GUI_STATE.worker_page = GUI_STATE.worker_page + 1
            build_dashboard()
        elseif id == "close" then
            GUI_STATE.open = false
            UI.Clear()
        end
    end
end)

-- ==================== HOTKEY MANAGER ====================
local hotkey_capture = { active = false, slot = nil, buffer = "" }

function helpers.OpenHotkeyDialog()
    local lines = build_dialog_header()
    table.insert(lines, "add_label_with_icon|big|`cCustom Hotkey Manager``|left|11550|")
    table.insert(lines, "add_spacer|small|")
    table.insert(lines, "add_textbox|`7Assign Growtopia keys to command slots.|left|")
    table.insert(lines, "add_spacer|small|")
    for i = 1, 4 do
        local hk = config.custom_hotkeys[i] or {}
        local kname = hk.key and ("Key #" .. tostring(hk.key)) or "Not Set"
        table.insert(lines, "add_smalltext|`0Slot " .. i .. ": `e" .. kname ..
            "`7 - " .. (hk.cmd ~= "" and hk.cmd or "no command") .. "|left|")
        table.insert(lines, "add_small_font_button|hk_set_" .. i .. "|`2[Set Key]|noflags|0|0|")
        table.insert(lines, "add_small_font_button|hk_clr_" .. i .. "|`4[Clear]|noflags|0|0|")
        table.insert(lines, "add_text_input|hk_cmd_" .. i .. "|`0Command:|" .. (hk.cmd or "") .. "|30|")
        table.insert(lines, "add_checkbox|hk_en_" .. i .. "|`0Enabled|" .. (hk.enabled and 1 or 0) .. "|")
        table.insert(lines, "add_spacer|small|")
    end
    table.insert(lines, "add_quick_exit||")
    table.insert(lines, "end_dialog|hotkey_dialog|Cancel|`2Save Settings|")
    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(lines, "\n") }, -1)
end

-- Capture key via OnInput (Windows key events)
Script.On("OnInput", "dodged_hotkey_capture", function(kind, x, y, finger)
    if not hotkey_capture.active then return end
    local types = Input.GetTypes()
    if kind == types.Key and y == 1 then
        local keycode = x
        if keycode == 27 then
            hotkey_capture.active = false
            helpers.OnTextOverlay("`7Hotkey capture cancelled.")
            return
        end
        if keycode == 8 or keycode == 46 then
            local slot = hotkey_capture.slot
            config.custom_hotkeys[slot] = { key = nil, cmd = "", enabled = false }
            hotkey_capture.active = false
            helpers.OnTextOverlay("`4Slot " .. slot .. " cleared.")
            return
        end
        local slot = hotkey_capture.slot
        for j = 1, 4 do
            if j ~= slot and config.custom_hotkeys[j] and config.custom_hotkeys[j].key == keycode then
                helpers.OnTextOverlay("`4Key already used in slot " .. j)
                return
            end
        end
        config.custom_hotkeys[slot].key = keycode
        config.custom_hotkeys[slot].enabled = true
        hotkey_capture.active = false
        helpers.OnTextOverlay("`2Slot " .. slot .. " assigned key #" .. keycode)
    end
end)

-- Key polling via Input.IsKeyDown (Windows only). Non-Windows: silently no-op.
local function start_hotkey_watcher()
    if type(Input) ~= "table" or type(Input.IsKeyDown) ~= "function" then
        LogToConsole("`9[Hotkeys] Input.IsKeyDown unavailable on this platform; custom hotkeys disabled.")
        return
    end
    local last_trigger = {}
    Script.Every(50, function()
        if hotkey_capture.active then return end
        local now = Script.GetTime()
        local cooldown = math.max(100, config.hotkey_cmd_cooldown_ms or 300)

        if config.hotkey_f4_respawn and Input.IsKeyDown(115) then
            if (now - (last_trigger.f4 or 0)) >= 1000 then
                last_trigger.f4 = now
                SendPacket(2, "action|respawn")
                helpers.OnTextOverlay("`4Instant Respawn (F4)")
            end
        end

        for slot = 1, 4 do
            local hk = config.custom_hotkeys[slot]
            if hk and hk.enabled and hk.key and hk.cmd and hk.cmd ~= "" then
                if Input.IsKeyDown(hk.key) and (now - (last_trigger[slot] or 0)) >= cooldown then
                    last_trigger[slot] = now
                    local cmd = hk.cmd
                    if cmd:sub(1, 1) ~= "/" then cmd = "/" .. cmd end
                    SendPacket(2, "action|input\n|text|" .. cmd .. "\n")
                end
            end
        end
    end)
end

-- ==================== WORLD TOUCH ====================
local function is_ctrl_held()
    if type(Input) ~= "table" or type(Input.IsKeyDown) ~= "function" then return false end
    return Input.IsKeyDown(17) or Input.IsKeyDown(162) or Input.IsKeyDown(163)
end
local function is_shift_held()
    if type(Input) ~= "table" or type(Input.IsKeyDown) ~= "function" then return false end
    return Input.IsKeyDown(16) or Input.IsKeyDown(160) or Input.IsKeyDown(161)
end

local function handle_world_touch(pos, start)
    if not (pos and pos.x and pos.y) or not start then return false end
    local cx, cy = math.floor(pos.x / 32), math.floor(pos.y / 32)

    if config.tp_ctrl_click_enabled and is_ctrl_held() then
        helpers.TakeAtTile(cx, cy)
        helpers.SendTileEffect(cx * 32 + 16, cy * 32 + 16)
        return true
    end
    if config.tp_shift_click_enabled and is_shift_held() and not is_ctrl_held() then
        helpers.SendTileEffect(cx * 32 + 16, cy * 32 + 16)
        pcall(FindPath, cx, cy)
        return true
    end

    -- Click-Pull
    if config.wrench_touch_pull then
        local ok, inv = pcall(GetPlayerInfo)
        local selected = ok and inv and inv.backpack and tonumber(inv.backpack.selected) or 0
        if selected == ITEM_IDS.WRENCH then
            -- New API doesn't expose a public player-at-tile helper; approximate
            -- using Client.GetPlayers.
            if type(Client) == "table" and type(Client.GetPlayers) == "function" then
                local ok_p, players = pcall(Client.GetPlayers)
                if ok_p and players then
                    for _, p in ipairs(players) do
                        if p and p.pos and p.netid then
                            local px, py = math.floor(p.pos.x / 32), math.floor(p.pos.y / 32)
                            if px == cx and py == cy then
                                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" ..
                                    p.netid .. "|\nbuttonClicked|pull")
                                return true
                            end
                        end
                    end
                end
            end
        end
    end

    -- Click-to-teleport
    if config.tpdisplay then
        local ok_t, tile = pcall(GetTile, cx, cy)
        local fg = (ok_t and tile and tile.fg) or 0
        local should = (config.tpdisplay_mode ~= "display_only") or (fg == 1422 or fg == 2488)
        if should then
            schedule(function()
                local sx, sy
                if config.tpdisplay_return then
                    local ok, me = pcall(GetLocal)
                    if ok and me and me.pos then
                        sx, sy = math.floor(me.pos.x / 32), math.floor(me.pos.y / 32)
                    end
                end
                helpers.SendTileEffect(cx * 32 + 16, cy * 32 + 16)
                pcall(FindPath, cx, cy)
                if config.tpdisplay_return and sx and sy then
                    local delay = math.max(80, math.min(10000, tonumber(config.tpdisplay_delay) or 3000))
                    Sleep(delay)
                    pcall(FindPath, sx, sy)
                end
            end)
            return true
        end
    end
    return false
end

-- ==================== SEND-PACKET HOOK (commands + outgoing translation) ====================
local function handle_send_packet(kind, text)
    if kind ~= 2 and kind ~= 3 then return false end
    local packet = tostring(text or "")

    -- Outgoing translation (returns true to suppress original; schedules resend)
    if kind == 2 and config.translator.outgoing_enabled and not operation_flags.is_sending_auto_tr
       and packet:find("action|input\n|text|") then
        local m = packet:match("action|input\n|text|([^\n]*)")
        if m and m ~= "" and m:sub(1, 1) ~= "/" and not m:find(config.branding, 1, true) then
            local captured = m
            operation_flags.is_sending_auto_tr = true
            schedule(function()
                local res = helpers.TranslateText(captured, config.translator.outgoing_target_lang)
                SendPacket(2, "action|input\n|text|" .. (res or captured) .. "\n")
                if res and config.translator.show_console then
                    helpers.OnConsoleMessage("`c[AI Out] `2" .. res)
                end
                Sleep(120)
                operation_flags.is_sending_auto_tr = false
            end)
            return true
        end
    end

    -- Slash commands
    local m = packet:match("action|input\n|text|([^\n]*)") or packet:match("|text|([^\n]*)")
    if m and m:sub(1, 1) == "/" then
        local body = m:sub(2)
        local token, args = body:match("^([^%s]+)%s*(.-)$")
        token = (token or ""):lower()
        args = tostring(args or ""):gsub("^%s*(.-)%s*$", "%1")

        if not whitelist_state.is_authorized then
            helpers.OnConsoleMessage("`4[Access Denied] Not whitelisted.")
            return true
        end

        -- Dynamic drop routing
        if token == config.cmd_drop_wl then
            local n = parse_positive_integer(args)
            if not n then helpers.Say("`4Invalid amount!"); return true end
            helpers.DropWorldLock(n); return true
        elseif token == config.cmd_drop_dl then
            local n = parse_positive_integer(args)
            if not n then helpers.Say("`4Invalid amount!"); return true end
            helpers.DropDiamondLock(n); return true
        elseif token == config.cmd_drop_bgl then
            local n = parse_positive_integer(args)
            if not n then helpers.Say("`4Invalid amount!"); return true end
            helpers.DropBlueGemLock(n); return true
        elseif token == config.cmd_drop_black then
            local n = parse_positive_integer(args)
            if not n then helpers.Say("`4Invalid amount!"); return true end
            helpers.DropBlackLock(n); return true
        end
        -- Multiplier (e.g. /w2 5 -> 10)
        local base, mult = token:match("^(%a+)(%d+)$")
        if base and mult then
            local m_int = tonumber(mult)
            local n = parse_positive_integer(args)
            if m_int and m_int >= 2 and n then
                if base == config.cmd_drop_wl then helpers.DropWorldLock(n * m_int); return true end
                if base == config.cmd_drop_dl then helpers.DropDiamondLock(n * m_int); return true
                if base == config.cmd_drop_bgl then helpers.DropBlueGemLock(n * m_int); return true
                if base == config.cmd_drop_black then helpers.DropBlackLock(n * m_int); return true
            end
        end

        local canon, def = resolve_command(token)
        if def and type(def.handler) == "function" then
            local ok, handled = pcall(def.handler, args, m)
            if not ok then
                helpers.OnConsoleMessage("`4[Command Error] /" .. token .. ": " .. tostring(handled))
                return true
            end
            if handled ~= nil then return handled end
            return true
        end
    end

    return false
end

-- ==================== VARIANT HOOK ====================
local function handle_on_variant(v)
    if not v or not v[0] then return false end

    -- OnSpawn → name override
    if v[0] == "OnSpawn" and v[1] and tostring(v[1]):find("spawn|avatar") then
        local spawn = tostring(v[1])
        local netid = tonumber(spawn:match("[nN]et[iI][dD]|(%d+)") or "")
        local uid   = tonumber(spawn:match("[uU]ser[iI][dD]|(%d+)") or "")
        local name  = spawn:match("[nN]ame|([^\n]+)") or ""
        if netid and name ~= "" then
            name_overrides[netid] = {
                base = strip_colors(name):gsub("^%s+",""):gsub("%s+$",""),
                world_id = 0, userid = uid or 0,
                is_mod = ((tonumber(spawn:match("mstate|(%d+)") or "0") or 0) > 1)
            }
        end
    end

    -- Block Super Duper Broadcast
    if v[0] == "OnSDBroadcast" and config.bsdb then
        helpers.OnTextOverlay(config.branding .. " `4Blocked `8S`6D`9B!")
        return true
    end

    -- Donation talk-bubble hook
    if v[0] == "OnTalkBubble" and v[2] then
        local bubble = tostring(v[2])
        if bubble:find("places") and bubble:find("into the Donation Box") then
            local flag = tonumber(v[4]) or 0
            local is_fake = bubble:find("`^", 1, true) ~= nil
            local ok_me, me = pcall(GetLocal)
            local my_netid = (ok_me and me and tonumber(me.netid)) or -1
            local speaker_netid = tonumber(v[1]) or -1
            if flag == 1 and not is_fake and speaker_netid == my_netid then
                local clean = bubble:gsub("`.", ""):gsub("^%s*(.-)%s*$", "%1")
                local _, amount_str, item_name = clean:match("(.-)%s+places%s+(%d+)%s+(.-)%s+into the Donation Box")
                if amount_str then
                    helpers.SendDonationWebhook("**" .. amount_str .. "** " .. (item_name or "item"))
                end
            end
        end
    end

    -- Console message hooks (anti-slave filter, ghost mode, bank parser, autosb confirm)
    if v[0] == "OnConsoleMessage" and v[1] then
        local msg = tostring(v[1])

        if config.antislave then
            local clean = msg:gsub("`.", ""):lower()
            local sender = msg:match("<(.-)>")
            if (sender and helpers.IsSlaveName(sender))
                or clean:find("spammer slave", 1, true)
                or clean:find("'s slave", 1, true)
                or msg:find("No spam text set") then
                return true
            end
        end

        if msg:find("quantum tunneling") and msg:find("Ghost in the shell") then
            config.ghost = true
            helpers.OnTextOverlay("`2Ghost Mode: `2ENABLED")
            return true
        end
        if msg:find("stops shimmering") and msg:find("Ghost in the shell") then
            config.ghost = false
            helpers.OnTextOverlay("`4Ghost Mode: `4DISABLED")
            return true
        end

        if autosb_state.running and msg:find("sent. Used") then
            autosb_state.success_flag = true
            if msg:find("Black") then
                autosb_state.gems_type = "BGems"
                local used = tonumber(msg:match("Used `%$(%d+)"))
                if used then autosb_state.bgems_used = used; autosb_state.total_bgems_used = autosb_state.total_bgems_used + used end
            else
                autosb_state.gems_type = "Gems"
                local used = tonumber(msg:match("Used `%$(%d+)"))
                if used then autosb_state.gems_used = used; autosb_state.total_gems_used = autosb_state.total_gems_used + used end
            end
        end
    end

    -- Bank dialog hook (BGL bank balance)
    if v[0] == "OnDialogRequest" and v[1]
       and (tostring(v[1]):find("BGLs in the Bank") or tostring(v[1]):find("The BGL Bank")) then
        local clean = strip_colors(v[1])
        local bank_str = clean:match("You have ([%d,]+) BGLs in the Bank")
                       or clean:match("([%d,]+) BGLs in the Bank")
        if bank_str then
            worker_modal_state.bank_bgl = parse_dialog_number(bank_str)
        end
        if worker_modal_state.is_requesting_bank then
            worker_modal_state.is_requesting_bank = false
            helpers.SendWorkerModalWebhook()
            return true
        end
    end

    -- Show balance parser
    if v[0] == "OnDialogRequest" and v[1] and tostring(v[1]):find("'s Inventory") then
        local summary = parse_inventory_summary(v[1])
        if summary and config.showbal then
            local msg = format_balance_msg(summary)
            helpers.OnTextOverlay(msg)
            helpers.OnConsoleMessage(msg)
            return true
        end
    end

    -- Wrench popup intercept
    if v[0] == "OnDialogRequest" and v[1] and tostring(v[1]):find("embed_data|netID|") then
        local target = tostring(v[1]):match("embed_data|netID|(%d+)")
        if target then
            local taken = false
            if config.wrench_mode == "pull" then
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. target .. "|\nbuttonClicked|pull")
                taken = true
            elseif config.wrench_mode == "ban" then
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. target .. "|\nbuttonClicked|worldban")
                taken = true
            elseif config.wrench_mode == "kick" then
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. target .. "|\nbuttonClicked|kick")
                taken = true
            end
            if config.showbal then
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. target .. "|\nbuttonClicked|viewinv")
                taken = true
            end
            if taken then return true end
        end
    end

    -- Dialog theme injector
    if v[0] == "OnDialogRequest" and config.cbgcolor and v[1] then
        v[1] = "set_default_color|`o\nset_border_color|" .. config.dialogBorder ..
               "|\nset_bg_color|" .. config.dialogBg .. "|\n" .. tostring(v[1])
        SendVariantList({ [0] = "OnDialogRequest", [1] = v[1], netid = -1 }, -1)
        return true
    end

    -- Dialog return handling (uses same wire format as before)
    if v[0] == "OnDialogReturn" then
        local pkt = tostring(v[1] or "")
        if pkt:find("dialog_name|bglproxy_options") then
            if not pkt:find("buttonClicked|Cancel") then
                config.modfly       = pkt:find("opt_mf|1") ~= nil
                config.tpdisplay    = pkt:find("opt_tp|1") ~= nil
                config.vendfilter   = pkt:find("opt_vendfilter|1") ~= nil
                config.bsdb         = pkt:find("opt_bsdb|1") ~= nil
                config.antislave    = pkt:find("opt_antislave|1") ~= nil
                config.cbgl         = pkt:find("opt_cbgl|1") ~= nil
                config.buydl        = pkt:find("opt_buydl|1") ~= nil
                config.autocombine  = pkt:find("opt_autocombine|1") ~= nil
                config.cbgcolor     = pkt:find("opt_cbgcolor|1") ~= nil
                config.wrench_touch_pull = pkt:find("opt_cpull|1") ~= nil
                config.showbal      = pkt:find("opt_smodal|1") ~= nil
                config.sspin        = pkt:find("opt_sspin|1") ~= nil
                config.autoGemDetect = pkt:find("opt_gemdetect|1") ~= nil
                config.rank_titles  = pkt:find("opt_rank_titles|1") ~= nil
                config.spin_titles  = pkt:find("opt_spin_titles|1") ~= nil
                config.show_ping    = pkt:find("opt_show_ping|1") ~= nil
                config.translator.enabled          = pkt:find("opt_tr_in|1") ~= nil
                config.translator.outgoing_enabled = pkt:find("opt_tr_out|1") ~= nil
                if type(EditToggle) == "function" then
                    pcall(EditToggle, "Ghost Fly", config.modfly)
                end
                helpers.OnTextOverlay(config.branding .. " `2Options saved.")
            end
            return true
        end
        if pkt:find("dialog_name|hotkey_dialog") then
            for slot = 1, 4 do
                if pkt:find("buttonClicked|hk_clr_" .. slot) then
                    config.custom_hotkeys[slot] = { key = nil, cmd = "", enabled = false }
                    return true
                end
                if pkt:find("buttonClicked|hk_set_" .. slot) then
                    hotkey_capture.active = true
                    hotkey_capture.slot = slot
                    helpers.OnTextOverlay("`ePress any key (ESC cancels).")
                    return true
                end
            end
            if not pkt:find("buttonClicked|Cancel") then
                for slot = 1, 4 do
                    local cmd_val = pkt:match("hk_cmd_" .. slot .. "|([^|\n]*)")
                    if cmd_val then config.custom_hotkeys[slot].cmd = cmd_val:gsub("^%s*(.-)%s*$", "%1") end
                    config.custom_hotkeys[slot].enabled = pkt:find("hk_en_" .. slot .. "|1") ~= nil
                end
            end
            return true
        end
    end

    return false
end

-- ==================== RAW PACKET HOOK (teleport block) ====================
local function handle_raw_packet(pkt)
    if not pkt then return false end
    if (is_ctrl_held() or is_shift_held()) and pkt.type == 3 then
        return true
    end
    -- Champagne use detection
    if pkt.type == 3 and pkt.value then
        local v = tonumber(pkt.value) or 0
        if v == 1974 then
            schedule(function()
                Sleep(200)
                local n = get_safe_item_count(get_champagne_item_id())
                if n > 0 then n = n - 1 end
                if type(MakeRequest) == "function" then
                    local dest = helpers.GetLogDestination("champ")
                    if dest.webhook and dest.webhook ~= "" then
                        local payload = '{"embeds":[{"title":"🍾 CHAMPAGNE LOG","description":"' ..
                            escape_json_str(get_clean_worker_name() .. " used 1 champagne (" .. n .. " left)") ..
                            '","color":16766720}]}'
                        schedule(function()
                            local url = dest.webhook
                            if dest.thread_id and dest.thread_id ~= "" then
                                url = url .. "?thread_id=" .. dest.thread_id
                            end
                            pcall(MakeRequest, url, "POST", { ["Content-Type"] = "application/json" }, payload, 4000)
                        end)
                    end
                end
            end)
        end
    end
    return false
end

-- ==================== WHEEL SPIN PARSER ====================
local function get_spin_result(num)
    if not num then return "" end
    if config.leme then
        local n1, n2 = math.floor(num / 10), num % 10
        local sum = tostring(n1 + n2):sub(-1)
        if num == 19 or num == 28 or num == 0 then return "`2" .. sum .. " X4" end
        if num == 1 or num == 29 or num == 10 then return "`2" .. sum .. " X3" end
        if num == 11 or num == 2 or num == 20 or num == 9 or num == 27 or num == 36 or num == 18 then
            return "`4" .. sum .. " LOSE"
        end
        return "`e" .. sum
    end
    if config.reme then
        local sum = tostring(math.floor(num / 10) + (num % 10)):sub(-1)
        if num == 19 or num == 28 or num == 0 then return "`2" .. sum .. " X3" end
        if num == 29 or num == 10 or num == 1 then return "`4" .. sum .. " LOSE" end
        return "`e" .. sum
    end
    if config.qeme then
        local r = tostring(num):sub(-1)
        if num == 0 or r == "1" then return "`4" .. r .. " LOSE" end
        if num == 10 or num == 20 or num == 30 then return "`2" .. r .. " X3" end
        return "`e" .. r
    end
    if config.lewa then
        local r = tostring(num):sub(-1)
        if num == 0 then return "`4" .. r .. " LOSE" end
        if num == 9 or num == 19 or num == 29 then return "`2" .. r .. " X3" end
        if num == 10 or num == 20 or num == 30 then return "`2" .. r .. " X4" end
        return "`e" .. r
    end
    if config.sleme then
        local sum = tostring(math.floor(num / 10) + (num % 10)):sub(-1)
        if num == 19 or num == 28 then return "`20 X5" end
        if num == 1 or num == 29 or num == 10 then return "`2" .. sum .. " X3" end
        if num == 11 or num == 2 or num == 20 or num == 9 or num == 27 or num == 36 or num == 18 or num == 3 or num == 12 or num == 30 or num == 21 or num == 0 then
            return "`4" .. sum .. " LOSE"
        end
        return "`e" .. sum
    end
    if config.ceme then
        local sum = tostring(math.floor(num / 10) + (num % 10)):sub(-1)
        if num == 19 or num == 28 or num == 0 then return "`20 X4" end
        if num == 1 or num == 29 or num == 10 or num == 2 or num == 11 or num == 20 then return "`2" .. sum .. " X3" end
        if num == 21 or num == 12 or num == 3 or num == 30 then return "`4" .. sum .. " HOST WIN" end
        if num == 9 or num == 27 or num == 36 or num == 18 then return "`4" .. sum .. " LOSE" end
        return "`e" .. sum
    end
    if config.hol then
        if num == 0 then config.holSpins["0"] = {}; return "`40 LOSE" end
        return "`e" .. num
    end
    return ""
end

-- ==================== WEBHOOK-FRIENDLY HELPERS ====================
function helpers.IsSlaveName(name)
    if not name or name == "" then return false end
    local c = tostring(name):gsub("`.", ""):lower()
    return c:find("spammer slave", 1, true) ~= nil
        or c:find("spammer_slave", 1, true) ~= nil
        or c:find("'s slave", 1, true) ~= nil
end

function helpers.RemoveAllSlaves()
    if type(Client) ~= "table" or type(Client.GetPlayers) ~= "function" then return 0 end
    local ok, players = pcall(Client.GetPlayers)
    if not ok or not players then return 0 end
    local count = 0
    for _, p in ipairs(players) do
        if p and p.netid and helpers.IsSlaveName(p.name) then
            SendVariantList({
                [0] = "OnRemove",
                [1] = "netID|" .. tostring(p.netid),
                [2] = "pId|1"
            }, -1)
            count = count + 1
        end
    end
    return count
end

function helpers.RestoreAllSlaves() return 0 end

function helpers.OpenProxyDialog()
    local lines = build_dialog_header()
    table.insert(lines, "add_label_with_icon|small|`eDODGED `9Automation Proxy``|left|11550|")
    table.insert(lines, "add_spacer|small|")
    table.insert(lines, "add_small_font_button|btn_open_menu|`eCommand Menu|noflags|0|0|")
    table.insert(lines, "add_small_font_button|btn_open_options|`eToggle Options|noflags|0|0|")
    table.insert(lines, "add_small_font_button|btn_open_hotkey|`eHotkey Manager|noflags|0|0|")
    table.insert(lines, "add_small_font_button|btn_open_gui|`cDashboard (F1)|noflags|0|0|")
    table.insert(lines, "add_spacer|small|")
    local role = whitelist_state.role or "UNAUTHORIZED"
    local name = (whitelist_state.authorized_user and whitelist_state.authorized_user.growId) or "Unknown"
    table.insert(lines, "add_smalltext|`9Role: `e" .. role .. " `7| `9User: `2" .. name .. "|left|")
    table.insert(lines, "add_quick_exit||")
    table.insert(lines, "end_dialog|bglproxy_main|Close||")
    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(lines, "\n") }, -1)
end

-- ==================== AUTO SB ====================
function helpers.StartAutoSB()
    if autosb_state.running then helpers.SayClean("`4Auto SB already running."); return end
    if config.autosb_text == "" then
        helpers.SayClean("`4Auto SB text is empty! Use /autosb or wrench a sign.")
        return
    end
    autosb_state.running = true
    autosb_state.start_time = os.time()
    autosb_state.total = config.autosb_total
    autosb_state.start_count = config.autosb_start_count

    local ok, w = pcall(GetWorld)
    autosb_state.world_name = (ok and w and w.name ~= "") and w.name or "UNKNOWN"

    helpers.OnTextOverlay("`2Auto SB Started (" .. autosb_state.start_count .. "/" .. autosb_state.total .. ")")
    schedule(function()
        while autosb_state.running do
            local okw, ww = pcall(GetWorld)
            if not okw or not ww or ww.name == "EXIT" or ww.name == "" then
                SendPacket(3, "action|join_request\nname|" .. autosb_state.world_name .. "\ninvitedWorld|0")
                Sleep(5000)
            else
                autosb_state.success_flag = false
                local sb = config.autosb_text
                if not sb:lower():find("^/sb") then sb = "/sb " .. sb end
                if not sb:find(config.autosb_tag, 1, true) then sb = sb .. " " .. config.autosb_tag end

                SendPacket(2, "action|input\n|text|" .. sb .. "\n")
                local start = os.time()
                while autosb_state.running and not autosb_state.success_flag and (os.time() - start) < 5 do
                    Sleep(100)
                end
                if autosb_state.success_flag then
                    autosb_state.start_count = autosb_state.start_count + 1
                    config.autosb_start_count = autosb_state.start_count
                    if autosb_state.start_count >= autosb_state.total then break end
                    local rem = 174000
                    while autosb_state.running and rem > 0 do
                        Sleep(math.min(1000, rem)); rem = rem - 1000
                    end
                else
                    Sleep(10000)
                end
            end
        end
        if autosb_state.start_count >= autosb_state.total then
            helpers.OnTextOverlay("`2Auto SB completed (" .. autosb_state.total .. ")")
        end
        autosb_state.running = false
    end)
end

function helpers.StopAutoSB()
    autosb_state.running = false
    helpers.OnTextOverlay("`4Auto SB stopped.")
end

-- ==================== COMMAND REGISTRATION ====================
add_command({ name = "gui", aliases = {"panel","dashboard","dev","imgui"},
    usage = "/gui", description = "Open UI dashboard",
    handler = function() helpers.ToggleGui(); return true end })

add_command({ name = "proxy", aliases = {"dproxy","dodged"},
    usage = "/proxy", description = "Open DODGED main control center",
    handler = function() helpers.OpenProxyDialog(); return true end })

add_command({ name = "menu", aliases = {"bgl","help","commands"},
    usage = "/menu", description = "List all commands",
    handler = function() helpers.OpenMenuDialog(); return true end })

add_command({ name = "option", aliases = {"opt","options"},
    usage = "/option", description = "Feature options dialog",
    handler = function() helpers.OpenOptionDialog(); return true end })

add_command({ name = "hotkey", aliases = {"hk","hotkeys"},
    usage = "/hotkey", description = "Hotkey manager",
    handler = function() helpers.OpenHotkeyDialog(); return true end })

add_command({ name = "blue", usage = "/blue", description = "1 BLACK -> 100 BGL",
    handler = function() helpers.ConvertBlackToBlue(); return true end })

add_command({ name = "black", usage = "/black", description = "100 BGL -> 1 BLACK",
    handler = function() helpers.ConvertBlueToBlack(); return true end })

add_command({ name = "daw", aliases = {"da"}, usage = "/daw",
    description = "Drop all locks",
    handler = function() helpers.DropAllLocks(); return true end })

add_command({ name = "bank", usage = "/bank", description = "Open BGL bank",
    handler = function() SendPacket(2, "action|dialog_return\ndialog_name|popup\nbuttonClicked|bgls"); return true end })

add_command({ name = "dp", aliases = {"depo","deposit"}, usage = "/dp [amount]",
    description = "Deposit BGL",
    handler = function(args)
        local n = parse_positive_integer(args)
        if n then helpers.DepositBank(n)
        else
            local total = get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK) + get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK) * 100
            if total > 0 then helpers.DepositBank(total) else helpers.OnTextOverlay("`4No BGL to deposit.") end
        end
        return true
    end })

add_command({ name = "wd", aliases = {"wt","withdraw"}, usage = "/wd <amount>",
    description = "Withdraw BGL",
    handler = function(args)
        local n = parse_positive_integer(args)
        if n then helpers.WithdrawBank(n)
        else helpers.OnTextOverlay("`4Usage: /wd <amount>") end
        return true
    end })

add_command({ name = "autosb", usage = "/autosb", description = "Auto SB control",
    handler = function(args)
        if args == "start" then helpers.StartAutoSB()
        elseif args == "stop" then helpers.StopAutoSB()
        else helpers.OnTextOverlay("`eUsage: /autosb start|stop") end
        return true
    end })

add_command({ name = "tr", usage = "/tr [en|id|out|on|off|key <key>|test <text>]",
    description = "AI translator",
    handler = function(args)
        local sub, rest = tostring(args):match("^([^%s]+)%s*(.-)$")
        sub = (sub or ""):lower()
        if sub == "en" then config.translator.enabled = true; config.translator.target_lang = "en"
            helpers.OnTextOverlay("`3Translator: ENGLISH (ON)")
        elseif sub == "id" then config.translator.enabled = true; config.translator.target_lang = "id"
            helpers.OnTextOverlay("`2Translator: INDONESIA (ON)")
        elseif sub == "out" then config.translator.outgoing_enabled = not config.translator.outgoing_enabled
            helpers.OnTextOverlay("`eOutgoing Translator: " .. (config.translator.outgoing_enabled and "ON" or "OFF"))
        elseif sub == "on" then config.translator.enabled = true; helpers.OnTextOverlay("`2Translator ON")
        elseif sub == "off" then config.translator.enabled = false; helpers.OnTextOverlay("`4Translator OFF")
        elseif sub == "key" and rest ~= "" then config.translator.api_key = rest; helpers.OnTextOverlay("`2API key updated")
        elseif sub == "test" and rest ~= "" then
            schedule(function()
                local r = helpers.TranslateText(rest, config.translator.target_lang)
                helpers.OnConsoleMessage("`e[TR Test] " .. (r or "failed"))
            end)
        else
            helpers.OnTextOverlay("`e/tr en|id|out|on|off|key <key>|test <text>")
        end
        return true
    end })

add_command({ name = "slave", aliases = {"antislave"}, usage = "/slave",
    description = "Toggle anti-spammer-slave",
    handler = function()
        config.antislave = not config.antislave
        if config.antislave then
            local n = helpers.RemoveAllSlaves()
            helpers.OnTextOverlay("`2Anti-Slave ON (" .. n .. " removed)")
        else
            helpers.OnTextOverlay("`4Anti-Slave OFF")
        end
        return true
    end })

add_command({ name = "mf", aliases = {"modfly"}, usage = "/mf", description = "Toggle Ghost Fly",
    handler = function()
        config.modfly = not config.modfly
        if type(EditToggle) == "function" then pcall(EditToggle, "Ghost Fly", config.modfly) end
        helpers.OnTextOverlay(config.modfly and "`2Ghost Fly ON" or "`4Ghost Fly OFF")
        return true
    end })

add_command({ name = "tp", usage = "/tp", description = "Toggle click-teleport",
    handler = function()
        config.tpdisplay = not config.tpdisplay
        helpers.OnTextOverlay("`eClick Teleport: " .. (config.tpdisplay and "`2ON" or "`4OFF"))
        return true
    end })

add_command({ name = "gemdetect", usage = "/gemdetect", description = "Toggle gem detector",
    handler = function()
        config.autoGemDetect = not config.autoGemDetect
        helpers.OnTextOverlay("`eGem Detector: " .. (config.autoGemDetect and "`2ON" or "`4OFF"))
        return true
    end })

add_command({ name = "bsdb", usage = "/bsdb", description = "Block SDB",
    handler = function()
        config.bsdb = not config.bsdb
        helpers.OnTextOverlay("`eBlock SDB: " .. (config.bsdb and "`2ON" or "`4OFF"))
        return true
    end })

add_command({ name = "pullall", aliases = {"pll"}, usage = "/pullall",
    description = "Pull all players (dangerous)",
    handler = function()
        if type(Client) ~= "table" or type(Client.GetPlayers) ~= "function" then return true end
        local ok, players = pcall(Client.GetPlayers)
        if not ok or not players then return true end
        local count = 0
        for _, p in ipairs(players) do
            if p and p.netid and p.userid and p.userid > 1 then
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. p.netid .. "|\nbuttonClicked|pull\n")
                count = count + 1
                Sleep(500)
            end
        end
        helpers.Say("`ePulled " .. count .. " players.")
        return true
    end })

-- ==================== PERIODIC TASKS ====================
-- Ping tag refresher
Script.Every(2500, function()
    if config.show_ping then
        -- No ping API in the new binding; kept as a no-op placeholder
    end
end)

-- Auto gem detector via Client.GetObjects polling
Script.Every(300, function()
    if not config.autoGemDetect then return end
    if type(Client) ~= "table" or type(Client.GetObjects) ~= "function" then return end
    local ok, objs = pcall(Client.GetObjects)
    if not ok or not objs then return end
    for _, obj in ipairs(objs) do
        if obj and obj.id == ITEM_IDS.GEMS and obj.pos then
            local tx, ty = math.floor(obj.pos.x / 32), math.floor(obj.pos.y / 32)
            -- Only emit when user stands on tile (best-effort)
            local ok_me, me = pcall(GetLocal)
            if ok_me and me and me.pos then
                if math.floor(me.pos.x / 32) == tx and math.floor(me.pos.y / 32) == ty then
                    helpers.SendFloatingNumber(obj.amount or 0, obj.pos.x, obj.pos.y)
                end
            end
        end
    end
end)

-- ==================== MAIN BOOTSTRAP ====================
Script.After(1, function()
    -- Whitelist
    helpers.FetchWorkerWhitelist()
    local ok_auth, info = helpers.CheckLocalAuthorization()
    if not ok_auth or not info then
        local ok, me = pcall(GetLocal)
        local uid = (ok and me and me.userid) and tostring(math.floor(tonumber(me.userid) or 0)) or "?"
        helpers.OnConsoleMessage("`4[Access Denied] UID (" .. uid .. ") not whitelisted.")
        helpers.OnTextOverlay("`4[DODGED] Access Denied: UID " .. uid)
        return
    end

    Script.On("OnSendPacket",     "dodged_cmd",   handle_send_packet)
    Script.On("OnVariant",        "dodged_var",   handle_on_variant)
    Script.On("OnSendPacketRaw",  "dodged_raw",   handle_raw_packet)
    Script.On("OnWorldChanged",   "dodged_world", function(current, previous)
        helpers.telecache = { world = "", tiles = {} }
        player_spin_titles = {}
        name_overrides = {}
    end)

    start_hotkey_watcher()
    helpers.StartWorkerModalLoop()
    helpers.RequestBankBalance()

    helpers.OnConsoleMessage("`2Script started successfully.")
    helpers.OnConsoleMessage("`2[Access Granted] `0" .. tostring(info.role) .. ": `e" .. tostring(info.growId))
    helpers.OnTextOverlay(config.branding_title .. " `2[" .. tostring(info.role) .. "] Loaded")
    Sleep(200)
    helpers.OpenProxyDialog()
end)

-- Keep the script alive
Sleep(-1)
