
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

local KeyCodes = {
    Lbutton = 1,
    Rbutton = 2,
    Cancel = 3,
    Mbutton = 4,
    Xbutton1 = 5,
    Xbutton2 = 6,
    Back = 8,
    Tab = 9,
    Clear = 12,
    Return = 13,
    Shift = 16,
    Control = 17,
    Menu = 18,
    Pause = 19,
    Capital = 20,
    Escape = 27,
    Space = 32,
    Prior = 33,
    Next = 34,
    End = 35,
    Home = 36,
    Left = 37,
    Up = 38,
    Right = 39,
    Down = 40,
    Select = 41,
    Print = 42,
    Execute = 43,
    Snapshot = 44,
    Insert = 45,
    Delete = 46,
    Help = 47,
    Num0 = 48, Num1 = 49, Num2 = 50, Num3 = 51, Num4 = 52,
    Num5 = 53, Num6 = 54, Num7 = 55, Num8 = 56, Num9 = 57,
    A = 65, B = 66, C = 67, D = 68, E = 69, F = 70, G = 71,
    H = 72, I = 73, J = 74, K = 75, L = 76, M = 77, N = 78,
    O = 79, P = 80, Q = 81, R = 82, S = 83, T = 84, U = 85,
    V = 86, W = 87, X = 88, Y = 89, Z = 90,
    Lwin = 91, Rwin = 92, Apps = 93,
    Numpad0 = 96, Numpad1 = 97, Numpad2 = 98, Numpad3 = 99, Numpad4 = 100,
    Numpad5 = 101, Numpad6 = 102, Numpad7 = 103, Numpad8 = 104, Numpad9 = 105,
    Multiply = 106, Add = 107, Separator = 108, Subtract = 109, Decimal = 110, Divide = 111,
    F1 = 112, F2 = 113, F3 = 114, F4 = 115, F5 = 116, F6 = 117,
    F7 = 118, F8 = 119, F9 = 120, F10 = 121, F11 = 122, F12 = 123,
    Lshift = 160, Rshift = 161,
    Lcontrol = 162, Rcontrol = 163,
    Lmenu = 164, Rmenu = 165
}

local KEY_NAMES = {
    [8] = "BACKSPACE",
    [9] = "TAB",
    [13] = "ENTER",
    [16] = "SHIFT",
    [17] = "CTRL",
    [18] = "ALT",
    [19] = "PAUSE",
    [20] = "CAPS LOCK",
    [27] = "ESC",
    [32] = "SPACE",
    [33] = "PAGE UP",
    [34] = "PAGE DOWN",
    [35] = "END",
    [36] = "HOME",
    [37] = "LEFT",
    [38] = "UP",
    [39] = "RIGHT",
    [40] = "DOWN",
    [45] = "INSERT",
    [46] = "DELETE",
    [96] = "NUMPAD 0",
    [97] = "NUMPAD 1",
    [98] = "NUMPAD 2",
    [99] = "NUMPAD 3",
    [100] = "NUMPAD 4",
    [101] = "NUMPAD 5",
    [102] = "NUMPAD 6",
    [103] = "NUMPAD 7",
    [104] = "NUMPAD 8",
    [105] = "NUMPAD 9",
    [106] = "NUM *",
    [107] = "NUM +",
    [109] = "NUM -",
    [110] = "NUM .",
    [111] = "NUM /",
    [112] = "F1",
    [113] = "F2",
    [114] = "F3",
    [115] = "F4",
    [116] = "F5",
    [117] = "F6",
    [118] = "F7",
    [119] = "F8",
    [120] = "F9",
    [121] = "F10",
    [122] = "F11",
    [123] = "F12",
    [160] = "Left SHIFT",
    [161] = "Right SHIFT",
    [162] = "Left CTRL",
    [163] = "Right CTRL",
    [164] = "Left ALT",
    [165] = "Right ALT",
    [48] = "0", [49] = "1", [50] = "2", [51] = "3", [52] = "4",
    [53] = "5", [54] = "6", [55] = "7", [56] = "8", [57] = "9",
    [65] = "A", [66] = "B", [67] = "C", [68] = "D", [69] = "E",
    [70] = "F", [71] = "G", [72] = "H", [73] = "I", [74] = "J",
    [75] = "K", [76] = "L", [77] = "M", [78] = "N", [79] = "O",
    [80] = "P", [81] = "Q", [82] = "R", [83] = "S", [84] = "T",
    [85] = "U", [86] = "V", [87] = "W", [88] = "X", [89] = "Y",
    [90] = "Z"
}

local function get_key_name(keycode)
    return KEY_NAMES[keycode] or ("Key #" .. tostring(keycode))
end

local hotkey_assign_state = { waiting = false, target_slot = nil }
local hotkey_last_trigger = {}

-- =========================== CONFIGURATION ===========================
local config = {
    version                = "1.2.2",
    developer              = "dodgedgit",
    branding               = "`0[`eDODGED`0]",
    branding_title         = "`eDODGED",
    api_url                = "http://154.12.118.154:1088",
    api_url_fallback       = "http://154.12.118.154:1088",

    -- Hotkey Configuration (ExProxy Style)
    hotkey_f4_respawn          = true,
    hotkey_cmd_cooldown_ms     = 300,
    custom_hotkeys             = {
        [1] = { key = nil, cmd = "", enabled = false },
        [2] = { key = nil, cmd = "", enabled = false },
        [3] = { key = nil, cmd = "", enabled = false },
        [4] = { key = nil, cmd = "", enabled = false }
    },

    -- Dialog Parser Theme
    cbgcolor               = true,
    dialogBorder           = "0,200,255,255",
    dialogBg               = "30,30,30,225",
    dialogDefaultColor     = "`o",

    -- Wrench Actions & Custom Chat Messages
    wrench_mode            = "off",
    pull                   = false,
    kick                   = false,
    ban                    = false,
    wrench_touch_pull      = false,
    wrench_msg_pull        = "`7Pulled `0{name}",
    wrench_msg_kick        = "`6Kicked `0{name}",
    wrench_msg_ban         = "`4Banned `0{name}",
    wrench_msg_showbal     = "`eChecking balance: `0{name}",

    -- Ctrl (Remote Collect) & Shift (Pathfind Teleport)
    tp_ctrl_click_enabled  = true,
    tp_shift_click_enabled = true,

    -- Teleport & Pathfinding Settings (/tp & /tpset)
    tpdisplay              = false,
    tpdisplay_mode         = "all_position",
    tpdisplay_return       = false,
    tpdisplay_delay        = 3000,

    -- ModFly Free Flight Movement (/mf)
    modfly                 = false,

    -- Ghost Mode Tracking (/g)
    ghost                  = false,

    -- Casino & Wheel Spin Games
    sspin                  = false,
    leme                   = false,
    reme                   = false,
    qeme                   = false,
    lewa                   = false,
    sleme                  = false,
    ceme                   = false,
    hol                    = false,
    holSpins               = {},

    -- Show Modal / Balance Player
    showbal                = false,
    showbal_use_chat       = false,

    -- Block Super Duper Broadcast (SDB)
    bsdb                   = false,

    -- Auto Convert BGL & Buy DL via Telephone
    cbgl                   = false,
    buydl                  = false,

    -- Auto Gem Detector (/gemdetect)
    autoGemDetect          = false,

    -- Custom Rank Titles, Last Spin Title & Ping
    rank_titles            = true,
    spin_titles            = true,
    show_ping              = true,

    -- Vending Machine Cost Filter
    vendfilter             = false,

    -- Auto Collect & Combine
    autocombine            = true,

    -- Realtime In-Game Chat Translator (/tr - Smart AI)
    translator             = {
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

    -- Auto Super Broadcast (/autosb)
    autosb_copysign        = true,
    autosb_autostart       = false,
    autosb_text            = "",
    autosb_start_count     = 0,
    autosb_total           = 20,
    autosb_webhook_enabled = false,
    autosb_webhook_url     = "",
    autosb_tag             = "`e#DODGED",

    -- Smart Drop Command Names
    cmd_drop_wl            = "w",
    cmd_drop_dl            = "d",
    cmd_drop_bgl           = "b",
    cmd_drop_black         = "bb",

    -- Auto Remove Spammer Slave (/slave)
    antislave              = false,

    -- Auto Chat Spam (/spam)
    spam_enabled           = false,
    spam_rainbow           = false,
    spam_random_color      = false,
    spam_slots             = {
        { active = true, text = "HALLO 1", delay = 3000 },
        { active = true, text = "HALLO 2", delay = 3000 },
        { active = true, text = "HALLO 3", delay = 3000 }
    }
}

-- Runtime flags
local operation_flags = {
    is_converting_dl    = false,
    is_sending_auto_tr  = false,
    is_smart_dropping   = false,
    collect_buffer      = { black = 0, bgl = 0, dl = 0, wl = 0 },
    collect_timer_token = 0
}

-- Auto SB Runtime State
local autosb_state = {
    running           = false,
    start_count       = 0,
    total             = 20,
    world_name        = "",
    start_time        = 0,
    last_success_time = 0,
    success_flag      = false,
    gems_type         = "Gems",
    gems_used         = 0,
    gems_left         = 0,
    bgems_used        = 0,
    bgems_left        = 0,
    total_gems_used   = 0,
    total_bgems_used  = 0
}

-- Player Name & Spin Title State
local player_spin_titles = {}
local name_overrides = {}

-- ==================== 3-TIER AUTH & WHITELIST ENGINE (BYPASS / HOSTER / WORKER) ====================
local bypass_uids = {
    ["1038257"] = true
}

local whitelist_state = {
    is_authorized     = false,
    role              = nil,        -- "BYPASS" | "HOSTER" | "WORKER"
    user_ids          = {},         -- set of all authorized UIDs
    bypass_uids       = {},         -- set of bypass UIDs
    hosters           = {},         -- map of hoster profiles { [uid] = profile }
    workers           = {},         -- map of worker profiles { [uid] = profile }
    last_fetch        = 0,
    authorized_user   = nil,        -- active profile of local player
    authorized_worker = nil         -- backward compatibility alias
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
    thread_id               = "1556975242402861168", -- default modal thread fallback
    thread_champ            = "1556975235075670017", -- default champ thread fallback
    thread_drop             = "1557127564701466674", -- default drop thread fallback
    last_sent_time          = 0,
    interval_ms             = 7000,                  -- loop interval 7 detik (5-10 detik)
    is_requesting_bank      = false,                 -- flag waiting for bank dialog
    bank_bgl                = 0,                     -- cached bank BGL amount
    loop_started            = false,
    last_snapshot           = nil                    -- tracks modal state to only send on changes
}

local heartbeat_state = {
    enabled        = false, -- heartbeat to the old bot server disabled
    interval_ms    = 15000, -- kirim heartbeat tiap 15 detik
    last_sent_time = 0
}

local function normalize_api_url(url, default_val)
    local u = tostring(url or default_val or "http://154.12.118.154:1088")
    u = u:gsub("^%s+", ""):gsub("%s+$", "")
    u = u:gsub("/api/worker/userid/?$", "")
    u = u:gsub("/api/worker/?$", "")
    u = u:gsub("/api/hoster/userid/?$", "")
    u = u:gsub("/api/hoster/?$", "")
    u = u:gsub("/api/bypass/?$", "")
    u = u:gsub("/api/?$", "")
    u = u:gsub("/+$", "")
    return (u ~= "") and u or "http://154.12.118.154:1088"
end

function helpers.GetApiBaseUrls()
    local p = normalize_api_url(config and config.api_url, "http://154.12.118.154:1088")
    local f = normalize_api_url(config and config.api_url_fallback, "http://154.12.118.154:1088")
    return p, f
end

-- ==================== GITHUB UID WHITELIST ====================
-- Set this to the RAW url of your whitelist file (one UID per line, public repo).
-- Example: https://raw.githubusercontent.com/YourName/YourRepo/main/whitelist.txt
local WHITELIST_URL = "https://raw.githubusercontent.com/dodgedgit/whitelist/main/whitelist.txt"

function helpers.FetchWorkerWhitelist()
    if type(MakeRequest) ~= "function" then
        return false, "MakeRequest not supported"
    end

    -- ?t= avoids stale cached copies of the file
    local url = WHITELIST_URL .. "?t=" .. tostring(os.time())
    local ok, res = pcall(MakeRequest, url, "GET", { ["User-Agent"] = "DodgedProxy/1.0" }, "", 5000)
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
                role           = "HOSTER",
                growId         = "UID " .. uid,
                userId         = uid,
                threadModal    = "",
                threadChamp    = "",
                threadSetor    = "",
                threadDrop     = "",
                threadDonation = "",
                threadStorage  = ""
            }
        end
    end

    whitelist_state.user_ids    = all_uids
    whitelist_state.bypass_uids = {}
    whitelist_state.hosters     = hst_map
    whitelist_state.workers     = {}
    whitelist_state.last_fetch  = os.time()
    return true
end

function helpers.CheckLocalAuthorization()
    local ok_local, localPlayer = pcall(GetLocal)
    if not ok_local or not localPlayer or not localPlayer.userid then
        return false, nil
    end
    local my_uid = tostring(math.floor(tonumber(localPlayer.userid) or 0))
    if my_uid == "0" then
        return false, my_uid
    end

    local profile = whitelist_state.user_ids and whitelist_state.user_ids[my_uid]
        and whitelist_state.hosters and whitelist_state.hosters[my_uid]
    if profile then
        profile.growId = localPlayer.name or profile.growId
        whitelist_state.is_authorized     = true
        whitelist_state.role              = "HOSTER"
        whitelist_state.authorized_user   = profile
        whitelist_state.authorized_worker = profile
        return true, profile
    end

    whitelist_state.is_authorized     = false
    whitelist_state.role              = nil
    whitelist_state.authorized_user   = nil
    whitelist_state.authorized_worker = nil
    return false, my_uid
end

-- ==================== WORKER MODAL LOGGER & WEBHOOK MODULE ====================
-- (worker_modal_state defined above near whitelist_state)

local function get_champagne_item_id()
    if type(GetItemByName) == "function" then
        local names = { "champagne", "Champagne", "champ", "Champ" }
        for _, name in ipairs(names) do
            local ok, res = pcall(GetItemByName, name)
            if ok and res then
                if type(res) == "table" and res.id then
                    return tonumber(res.id) or 1974
                elseif type(res) == "number" then
                    return res
                end
            end
        end
    end
    return ITEM_IDS.CHAMPAGNE or 1974
end

local function get_safe_item_count(item_id)
    if not item_id or tonumber(item_id) == nil then return 0 end
    local target_id = tonumber(item_id)

    -- 1. Native Bothax GetInventory() (returns table of items with .id and .amount/.count)
    if type(GetInventory) == "function" then
        local ok_inv, inv = pcall(GetInventory)
        if ok_inv and type(inv) == "table" then
            for _, it in pairs(inv) do
                if type(it) == "table" and tonumber(it.id) == target_id then
                    return tonumber(it.amount or it.count) or 0
                end
            end
        end
    end

    -- 2. Native Bothax GetItemCount
    if type(GetItemCount) == "function" then
        local ok, cnt = pcall(GetItemCount, target_id)
        if ok and cnt and tonumber(cnt) then
            return tonumber(cnt)
        end
    end

    -- 3. Native Bothax GetPlayerItems
    if type(GetPlayerItems) == "function" then
        local ok_items, p_items = pcall(GetPlayerItems)
        if ok_items and p_items then
            local items_list = p_items.items or p_items.backpack or p_items
            if type(items_list) == "table" then
                for _, it in pairs(items_list) do
                    if type(it) == "table" and tonumber(it.id) == target_id then
                        return tonumber(it.count or it.amount) or 0
                    end
                end
            end
        end
    end

    return 0
end

local function escape_json_str(str)
    if not str then return "" end
    local s = tostring(str)
    s = s:gsub('\\', '\\\\')
    s = s:gsub('"', '\\"')
    s = s:gsub('\r', '\\r')
    s = s:gsub('\n', '\\n')
    s = s:gsub('\t', '\\t')
    s = s:gsub('[%z\1-\31]', function(c)
        return string.format('\\u%04x', string.byte(c))
    end)
    return s
end

-- Router Terpusat: Otomatis memilih Webhook & Thread sesuai Role (Zero Crossover)
function helpers.GetLogDestination(log_type)
    -- log_type: "modal", "champ", "drop", "donation", "storage"
    local role = whitelist_state.role or "WORKER"
    local my_uid = ""
    local ok_local, localPlayer = pcall(GetLocal)
    if ok_local and localPlayer and localPlayer.userid then
        my_uid = tostring(math.floor(tonumber(localPlayer.userid) or 0))
    end

    local key_thread = "thread" .. log_type:sub(1,1):upper() .. log_type:sub(2)

    -- 1. BYPASS ROLE (Owner / Dev / VIP) -> Dedicated channel & threads di #bypass-logs
    if role == "BYPASS" then
        local th_id = (whitelist_state.authorized_user and whitelist_state.authorized_user[key_thread] and whitelist_state.authorized_user[key_thread] ~= "")
                      and whitelist_state.authorized_user[key_thread]
                      or (worker_modal_state.bypass_threads and worker_modal_state.bypass_threads[log_type])
        return {
            webhook   = worker_modal_state.webhook_bypass,
            thread_id = (th_id and th_id ~= "") and th_id or nil
        }

    -- 2. HOSTER ROLE -> Dedicated Hoster Webhooks & Hoster Threads
    elseif role == "HOSTER" then
        local user_data = whitelist_state.authorized_user
        if not user_data and whitelist_state.hosters then
            user_data = whitelist_state.hosters[my_uid]
        end
        local th_id = (user_data and user_data[key_thread] and user_data[key_thread] ~= "") and user_data[key_thread] or nil
        local wh_url = worker_modal_state["webhook_hoster_" .. log_type]
        return {
            webhook   = wh_url,
            thread_id = th_id -- NIL jika belum punya thread: terkirim ke channel induk Hoster, TIDAK BOLEH ke Worker!
        }

    -- 3. WORKER ROLE -> Dedicated Worker Webhooks & Worker Threads
    else
        local user_data = whitelist_state.authorized_user
        if not user_data and whitelist_state.workers then
            user_data = whitelist_state.workers[my_uid]
        end
        local th_id = (user_data and user_data[key_thread] and user_data[key_thread] ~= "") and user_data[key_thread] or nil
        if not th_id or th_id == "" then
            if log_type == "modal" then th_id = worker_modal_state.thread_id or "1556975242402861168"
            elseif log_type == "champ" then th_id = worker_modal_state.thread_champ or "1556975235075670017"
            elseif log_type == "drop" then th_id = worker_modal_state.thread_drop or "1557127564701466674"
            end
        end

        local wh_url = nil
        if log_type == "modal" then
            wh_url = worker_modal_state.webhook_base
        elseif log_type == "champ" then
            wh_url = worker_modal_state.webhook_champ or worker_modal_state.webhook_base
        elseif log_type == "drop" then
            wh_url = worker_modal_state.webhook_drop
        elseif log_type == "donation" then
            wh_url = worker_modal_state.webhook_worker_donation or worker_modal_state.webhook_drop
        elseif log_type == "storage" then
            wh_url = worker_modal_state.webhook_worker_storage or worker_modal_state.webhook_drop
        end

        return {
            webhook   = wh_url,
            thread_id = th_id
        }
    end
end

-- Backward compatibility helpers
function helpers.GetWorkerModalThreadId()
    local dest = helpers.GetLogDestination("modal")
    return dest.thread_id or ""
end

function helpers.GetWorkerChampThreadId()
    local dest = helpers.GetLogDestination("champ")
    return dest.thread_id or ""
end

function helpers.GetWorkerDropThreadId()
    local dest = helpers.GetLogDestination("drop")
    return dest.thread_id or ""
end

function helpers.GetWorkerDonationThreadId()
    local dest = helpers.GetLogDestination("donation")
    return dest.thread_id or ""
end

function helpers.GetWorkerStorageThreadId()
    local dest = helpers.GetLogDestination("storage")
    return dest.thread_id or ""
end

local function get_user_role_label()
    if whitelist_state.role == "BYPASS" then
        return "Bypass / Owner"
    elseif whitelist_state.role == "HOSTER" then
        return "Hoster"
    elseif whitelist_state.role == "WORKER" then
        return "Worker"
    end
    return "User"
end

local function get_clean_worker_name()
    local ok_local, me = pcall(GetLocal)
    if ok_local and me and me.userid then
        local my_uid = tostring(math.floor(tonumber(me.userid) or 0))
        if whitelist_state and whitelist_state.authorized_user and whitelist_state.authorized_user.growId then
            return whitelist_state.authorized_user.growId
        end
        if whitelist_state and whitelist_state.hosters and whitelist_state.hosters[my_uid] then
            return whitelist_state.hosters[my_uid].growId
        end
        if whitelist_state and whitelist_state.workers and whitelist_state.workers[my_uid] then
            return whitelist_state.workers[my_uid].growId
        end
    end
    if ok_local and me and me.name then
        local raw = strip_colors(me.name)
        raw = raw:gsub("%b[]", " "):gsub("%b()", " "):gsub("@", ""):gsub("^%s+", ""):gsub("%s+$", "")
        local first_token = raw:match("(%S+)")
        if first_token and first_token ~= "" then
            return first_token
        end
    end
    return (whitelist_state.role == "HOSTER" and "Hoster") or "Worker"
end

function helpers.SendWorkerModalWebhook()
    if type(MakeRequest) ~= "function" then
        return
    end

    local dest = helpers.GetLogDestination("modal")
    local target_webhook = dest.webhook
    local thread_id = dest.thread_id
    if not target_webhook or target_webhook == "" then
        return
    end

    local ok_world, world = pcall(GetWorld)
    local world_name = (ok_world and world and world.name and world.name ~= "") and world.name or "UNKNOWN"

    local worker_name = get_clean_worker_name()

    local champ_id  = get_champagne_item_id()
    local black_val = get_safe_item_count(ITEM_IDS.BLACK_GEM_LOCK or 11550)
    local bgl_val   = get_safe_item_count(ITEM_IDS.BLUE_GEM_LOCK or 7188)
    local dl_val    = get_safe_item_count(ITEM_IDS.DIAMOND_LOCK or 1796)
    local wl_val    = get_safe_item_count(ITEM_IDS.WORLD_LOCK or 242)
    local bank_val  = worker_modal_state.bank_bgl or 0
    local champ_val = get_safe_item_count(champ_id)

    -- Cek perubahan: jika snapshot ada dan nilainya sama semua, skip pengiriman
    local snap = worker_modal_state.last_snapshot
    if snap then
        local is_changed = (black_val ~= snap.black)
                        or (bgl_val   ~= snap.bgl)
                        or (dl_val    ~= snap.dl)
                        or (wl_val    ~= snap.wl)
                        or (bank_val  ~= snap.bank)
                        or (champ_val ~= snap.champ)
                        or (world_name ~= snap.world)
        if not is_changed then
            return -- Skip pengiriman jika tidak ada perubahan modal
        end
    end

    -- Update snapshot nilai modal terkini
    worker_modal_state.last_snapshot = {
        black = black_val,
        bgl   = bgl_val,
        dl    = dl_val,
        wl    = wl_val,
        bank  = bank_val,
        champ = champ_val,
        world = world_name
    }

    -- Format embed: Title diperbaiki (dengan icon dan clean user name & role)
    local role_label = get_user_role_label()
    local embed_title = "💰 LIVE MODAL REPORT • " .. worker_name .. " [" .. role_label:upper() .. "]"
    local desc = "<:black:1556814063449800804>: **" .. tostring(black_val) .. "**\n" ..
                 "<:bgl:1556814259478855690>: **" .. tostring(bgl_val) .. "**\n" ..
                 "<:dl:1556814401695252560>: **" .. tostring(dl_val) .. "**\n" ..
                 "<:wl:1556814610420473946>: **" .. tostring(wl_val) .. "**\n\n" ..
                 "<:bgl:1556814259478855690> (Bank): **" .. tostring(bank_val) .. "**\n" ..
                 "<:champ:1556813501195096174>: **" .. tostring(champ_val) .. "**"

    local esc_title  = escape_json_str(embed_title)
    local esc_desc   = escape_json_str(desc)
    local esc_worker = escape_json_str(worker_name)
    local esc_world  = escape_json_str(world_name)
    local iso_time   = os.date("!%Y-%m-%dT%H:%M:%SZ")

    local payload = '{\n' ..
        '  "embeds": [{\n' ..
        '    "title": "' .. esc_title .. '",\n' ..
        '    "description": "' .. esc_desc .. '",\n' ..
        '    "color": 16766720,\n' ..
        '    "fields": [\n' ..
        '      { "name": "👤 ' .. role_label .. '", "value": "`' .. esc_worker .. '`", "inline": true },\n' ..
        '      { "name": "🌍 World", "value": "`' .. esc_world .. '`", "inline": true }\n' ..
        '    ],\n' ..
        '    "footer": { "text": "DODGED Modal Logger • Auto Realtime" },\n' ..
        '    "timestamp": "' .. iso_time .. '"\n' ..
        '  }]\n' ..
        '}'

    RunThread(function()
        local headers = { ["Content-Type"] = "application/json" }
        local post_url = target_webhook
        if thread_id and thread_id ~= "" then
            post_url = post_url .. "?thread_id=" .. thread_id
        end
        local ok_post, res_post = pcall(MakeRequest, post_url, "POST", headers, payload, 4000)

        if ok_post and res_post and not res_post.error and (not res_post.content or not res_post.content:find('"code"%s*:%s*%d+')) then
            worker_modal_state.last_sent_time = os.time()
        end
    end)
end
helpers.SendModalWebhook = helpers.SendWorkerModalWebhook

function helpers.SendChampagneWebhook(count_left)
    if type(MakeRequest) ~= "function" then return end

    local dest = helpers.GetLogDestination("champ")
    local target_webhook = dest.webhook
    local thread_id = dest.thread_id
    if not target_webhook or target_webhook == "" then return end

    local ok_world, world = pcall(GetWorld)
    local world_name = (ok_world and world and world.name and world.name ~= "") and world.name or "UNKNOWN"

    local worker_name = get_clean_worker_name()
    local role_label  = get_user_role_label()

    local left_num = tonumber(count_left) or 0
    local desc = role_label .. ": **" .. worker_name .. "** Used 1 <:champ:1556813501195096174> (" .. tostring(left_num) .. " <:champ:1556813501195096174> left)"

    local esc_desc   = escape_json_str(desc)
    local esc_worker = escape_json_str(worker_name)
    local esc_world  = escape_json_str(world_name)
    local iso_time   = os.date("!%Y-%m-%dT%H:%M:%SZ")

    local payload = '{\n' ..
        '  "embeds": [{\n' ..
        '    "title": "🍾 CHAMPAGNE LOG • ' .. role_label:upper() .. '",\n' ..
        '    "description": "' .. esc_desc .. '",\n' ..
        '    "color": 16766720,\n' ..
        '    "fields": [\n' ..
        '      { "name": "👤 ' .. role_label .. '", "value": "`' .. esc_worker .. '`", "inline": true },\n' ..
        '      { "name": "🌍 World", "value": "`' .. esc_world .. '`", "inline": true }\n' ..
        '    ],\n' ..
        '    "footer": { "text": "DODGED Champagne Logger" },\n' ..
        '    "timestamp": "' .. iso_time .. '"\n' ..
        '  }]\n' ..
        '}'

    RunThread(function()
        local headers = { ["Content-Type"] = "application/json" }
        local post_url = target_webhook
        if thread_id and thread_id ~= "" then
            post_url = post_url .. "?thread_id=" .. thread_id
        end
        pcall(MakeRequest, post_url, "POST", headers, payload, 4000)
    end)
end

function helpers.SendDropWebhook(drop_detail)
    if type(MakeRequest) ~= "function" then return end

    local dest = helpers.GetLogDestination("drop")
    local target_webhook = dest.webhook
    local thread_id = dest.thread_id
    if not target_webhook or target_webhook == "" then return end

    local ok_world, world = pcall(GetWorld)
    local world_name = (ok_world and world and world.name and world.name ~= "") and world.name or "UNKNOWN"

    local worker_name = get_clean_worker_name()
    local role_label  = get_user_role_label()

    local desc = role_label .. ": **" .. worker_name .. "** Dropped " .. tostring(drop_detail or "Items")

    local esc_desc   = escape_json_str(desc)
    local esc_worker = escape_json_str(worker_name)
    local esc_world  = escape_json_str(world_name)
    local esc_detail = escape_json_str(tostring(drop_detail or "-"))
    local iso_time   = os.date("!%Y-%m-%dT%H:%M:%SZ")

    local payload = '{\n' ..
        '  "embeds": [{\n' ..
        '    "title": "📦 DROP LOG • ' .. role_label:upper() .. '",\n' ..
        '    "description": "' .. esc_desc .. '",\n' ..
        '    "color": 3447003,\n' ..
        '    "fields": [\n' ..
        '      { "name": "👤 ' .. role_label .. '", "value": "`' .. esc_worker .. '`", "inline": true },\n' ..
        '      { "name": "🌍 World", "value": "`' .. esc_world .. '`", "inline": true },\n' ..
        '      { "name": "💰 Total Drop", "value": "' .. esc_detail .. '", "inline": false }\n' ..
        '    ],\n' ..
        '    "footer": { "text": "DODGED Drop Logger" },\n' ..
        '    "timestamp": "' .. iso_time .. '"\n' ..
        '  }]\n' ..
        '}'

    RunThread(function()
        local headers = { ["Content-Type"] = "application/json" }
        local post_url = target_webhook
        if thread_id and thread_id ~= "" then
            post_url = post_url .. "?thread_id=" .. thread_id
        end
        pcall(MakeRequest, post_url, "POST", headers, payload, 4000)
    end)
end

function helpers.SendDonationWebhook(donation_detail)
    if type(MakeRequest) ~= "function" then return end

    local dest = helpers.GetLogDestination("donation")
    local target_webhook = dest.webhook
    local thread_id = dest.thread_id
    if not target_webhook or target_webhook == "" then return end

    local role_label = get_user_role_label()

    local ok_world, world = pcall(GetWorld)
    local world_name = (ok_world and world and world.name and world.name ~= "") and world.name or "UNKNOWN"

    local user_name  = get_clean_worker_name()
    local user_id    = ""
    local ok_local, localPlayer = pcall(GetLocal)
    if ok_local and localPlayer and localPlayer.userid then
        user_id = tostring(math.floor(tonumber(localPlayer.userid) or 0))
    end

    local desc = role_label .. ": **" .. user_name .. "** places " .. tostring(donation_detail or "-") .. " into the Donation Box"

    local esc_desc   = escape_json_str(desc)
    local esc_user   = escape_json_str(user_name)
    local esc_uid    = escape_json_str(user_id)
    local esc_world  = escape_json_str(world_name)
    local esc_detail = escape_json_str(tostring(donation_detail or "-"))
    local iso_time   = os.date("!%Y-%m-%dT%H:%M:%SZ")

    local payload = '{\n' ..
        '  "embeds": [{\n' ..
        '    "title": "🎁 DONATION LOG • ' .. role_label:upper() .. '",\n' ..
        '    "description": "' .. esc_desc .. '",\n' ..
        '    "color": 15844367,\n' ..
        '    "fields": [\n' ..
        '      { "name": "👤 ' .. role_label .. '", "value": "`' .. esc_user .. '` (UID: `' .. esc_uid .. '`)", "inline": true },\n' ..
        '      { "name": "🌍 World", "value": "`' .. esc_world .. '`", "inline": true },\n' ..
        '      { "name": "🎁 Item Donasi", "value": "' .. esc_detail .. '", "inline": false },\n' ..
        '      { "name": "🛡️ Status", "value": "✅ `VERIFIED SYSTEM ACTION`", "inline": true }\n' ..
        '    ],\n' ..
        '    "footer": { "text": "DODGED Donation Logger • Anti-Fake Protected" },\n' ..
        '    "timestamp": "' .. iso_time .. '"\n' ..
        '  }]\n' ..
        '}'

    RunThread(function()
        local headers = { ["Content-Type"] = "application/json" }
        local post_url = target_webhook
        if thread_id and thread_id ~= "" and thread_id ~= "1557624196698349649" and thread_id ~= "1557624216717631570" then
            post_url = target_webhook .. "?thread_id=" .. thread_id
        end
        pcall(MakeRequest, post_url, "POST", headers, payload, 4000)
    end)
end

-- ==================== STORAGE MODULE HELPERS ====================
helpers.storage_cache = {
    tiles = {},
    last_type19 = nil,
    last_type13 = nil
}

function helpers.FormatStorageItem(item_id, count)
    local count_num = tonumber(count) or 1
    local lock_str = ""
    local emoji = ""
    local name = ""

    local id = tonumber(item_id) or 0
    if id == ITEM_IDS.DIAMOND_LOCK or id == 1796 then
        emoji = "<:dl:1556814401695252560>"
        name = "Diamond Lock"
        lock_str = "**" .. count_num .. "** " .. emoji .. " " .. name
    elseif id == ITEM_IDS.BLUE_GEM_LOCK or id == 7188 then
        emoji = "<:bgl:1556814259478855690>"
        name = "Blue Gem Lock"
        lock_str = "**" .. count_num .. "** " .. emoji .. " " .. name
    elseif id == ITEM_IDS.BLACK_GEM_LOCK or id == 11550 then
        emoji = "<:black:1556814063449800804>"
        name = "Black Gem Lock"
        lock_str = "**" .. count_num .. "** " .. emoji .. " " .. name
    elseif id == ITEM_IDS.WORLD_LOCK or id == 242 then
        emoji = "<:wl:1556814610420473946>"
        name = "World Lock"
        lock_str = "**" .. count_num .. "** " .. emoji .. " " .. name
    else
        name = "Item #" .. tostring(id)
        if type(GetItemById) == "function" then
            local ok_it, iobj = pcall(GetItemById, id)
            if ok_it and iobj and iobj.name then
                name = iobj.name
            end
        end
        lock_str = "**" .. count_num .. "x** " .. name
    end

    return lock_str, name, emoji
end

function helpers.HandleStorageTankPacket(packet)
    if not packet or type(packet) ~= "table" then return false end

    -- TankPacket Type 19: Storage tile interaction / open
    if packet.type == 19 then
        local px = tonumber(packet.x) or 0
        local py = tonumber(packet.y) or 0
        local tx = math.floor(px / 32)
        local ty = math.floor(py / 32)
        local item_id = tonumber(packet.tilex) or 0

        if item_id > 0 then
            local key = tx .. "_" .. ty
            helpers.storage_cache.tiles[key] = {
                x = tx,
                y = ty,
                item_id = item_id,
                timestamp = os.time()
            }
            helpers.storage_cache.last_type19 = {
                x = tx,
                y = ty,
                item_id = item_id,
                timestamp = os.time()
            }
        end
    end

    -- TankPacket Type 13: Item slot confirmation
    if packet.type == 13 then
        local val = tonumber(packet.value) or 0
        if val > 0 then
            helpers.storage_cache.last_type13 = {
                item_id = val,
                timestamp = os.time()
            }
        end
    end

    return false
end

function helpers.SendStorageWebhook(storage_data)
    if type(MakeRequest) ~= "function" then return end

    local dest = helpers.GetLogDestination("storage")
    local target_webhook = dest.webhook
    local thread_id = dest.thread_id
    if not target_webhook or target_webhook == "" then return end

    local role_label = get_user_role_label()

    local ok_world, world = pcall(GetWorld)
    local world_name = (ok_world and world and world.name and world.name ~= "") and world.name or "UNKNOWN"

    local user_name  = get_clean_worker_name()
    local user_id    = ""
    local ok_local, localPlayer = pcall(GetLocal)
    if ok_local and localPlayer and localPlayer.userid then
        user_id = tostring(math.floor(tonumber(localPlayer.userid) or 0))
    end

    -- Parsing table atau fallback string
    local is_table = (type(storage_data) == "table")
    local action   = is_table and (storage_data.action or "TRANSACTION") or "TRANSACTION"
    local count    = is_table and (storage_data.count or 1) or 1
    local lock_str = is_table and (storage_data.item_formatted or tostring(storage_data.item_id or "-")) or tostring(storage_data or "-")
    local tile_x   = is_table and (storage_data.tile_x or 0) or 0
    local tile_y   = is_table and (storage_data.tile_y or 0) or 0

    local action_title = (action == "STORE") and "📥 STORAGE DEPOSIT (STORE)" or ((action == "WITHDRAW") and "📤 STORAGE WITHDRAW" or "🗄️ STORAGE TRANSACTION")
    local action_verb  = (action == "STORE") and "menyimpan" or ((action == "WITHDRAW") and "mengambil" or "mentransaksikan")
    local embed_color  = (action == "STORE") and 3066993 or ((action == "WITHDRAW") and 15105570 or 3447003)

    local desc = role_label .. ": **" .. user_name .. "** " .. action_verb .. " " .. lock_str .. " di Storage Box (" .. tile_x .. ", " .. tile_y .. ")"

    local esc_desc   = escape_json_str(desc)
    local esc_user   = escape_json_str(user_name)
    local esc_uid    = escape_json_str(user_id)
    local esc_world  = escape_json_str(world_name)
    local esc_detail = escape_json_str(lock_str)
    local esc_act    = escape_json_str(action_title)
    local iso_time   = os.date("!%Y-%m-%dT%H:%M:%SZ")

    local payload = '{\n' ..
        '  "embeds": [{\n' ..
        '    "title": "' .. esc_act .. ' • ' .. role_label:upper() .. '",\n' ..
        '    "description": "' .. esc_desc .. '",\n' ..
        '    "color": ' .. tostring(embed_color) .. ',\n' ..
        '    "fields": [\n' ..
        '      { "name": "👤 ' .. role_label .. '", "value": "`' .. esc_user .. '` (UID: `' .. esc_uid .. '`)", "inline": true },\n' ..
        '      { "name": "🌍 Lokasi", "value": "`' .. esc_world .. '` (Tile: ' .. tile_x .. ', ' .. tile_y .. ')", "inline": true },\n' ..
        '      { "name": "📦 Detail Barang", "value": "' .. esc_detail .. '", "inline": false },\n' ..
        '      { "name": "🛡️ Status", "value": "✅ `VERIFIED STORAGE ACTION`", "inline": true }\n' ..
        '    ],\n' ..
        '    "footer": { "text": "DODGED Storage Logger • Anti-Fake Protected" },\n' ..
        '    "timestamp": "' .. iso_time .. '"\n' ..
        '  }]\n' ..
        '}'

    RunThread(function()
        local headers = { ["Content-Type"] = "application/json" }
        local post_url = target_webhook
        if thread_id and thread_id ~= "" and thread_id ~= "1557624198690504734" and thread_id ~= "1557624218630357065" then
            post_url = target_webhook .. "?thread_id=" .. thread_id
        end
        pcall(MakeRequest, post_url, "POST", headers, payload, 4000)
    end)
end

function helpers.RequestBankBalance()
    local ok_world, world = pcall(GetWorld)
    if not ok_world or not world or not world.name or world.name == "" or world.name == "EXIT" then
        return
    end

    worker_modal_state.is_requesting_bank = true
    SendPacket(2, "action|dialog_return\ndialog_name|popup\nbuttonClicked|bgls\n")

    -- Fallback: if server doesn't respond with dialog within 1.5s, send webhook with current cached bank balance
    RunThread(function()
        Sleep(1500)
        if worker_modal_state.is_requesting_bank then
            worker_modal_state.is_requesting_bank = false
            helpers.SendWorkerModalWebhook()
        end
    end)
end

-- ==================== ONLINE STATUS & HEARTBEAT MODULE ====================
-- (heartbeat_state defined above near whitelist_state)

function helpers.SendHeartbeat()
    if type(MakeRequest) ~= "function" then return end

    local ok_local, localPlayer = pcall(GetLocal)
    if not ok_local or not localPlayer or not localPlayer.userid then return end
    local my_uid = tostring(math.floor(tonumber(localPlayer.userid) or 0))
    if my_uid == "0" or my_uid == "" then return end

    local ok_world, world = pcall(GetWorld)
    local world_name = (ok_world and world and world.name and world.name ~= "") and world.name or "UNKNOWN"
    local my_name = get_clean_worker_name()
    local my_role = whitelist_state.role or "WORKER"

    local payload = string.format('{"userId":"%s","growId":"%s","role":"%s","world":"%s"}',
        escape_json_str(my_uid),
        escape_json_str(my_name),
        escape_json_str(my_role),
        escape_json_str(world_name)
    )

    local headers = {
        ["Content-Type"] = "application/json",
        ["User-Agent"]   = "DodgedProxy/1.0"
    }

    RunThread(function()
        local base_primary, base_fallback = helpers.GetApiBaseUrls()
        local urls = { base_primary .. "/api/heartbeat", base_fallback .. "/api/heartbeat" }
        for _, url in ipairs(urls) do
            local ok, res = pcall(MakeRequest, url, "POST", headers, payload, 3000)
            if ok and res and not res.error then
                heartbeat_state.last_sent_time = os.time()
                break
            end
        end
    end)
end

function helpers.StartWorkerModalLoop()
    if worker_modal_state.loop_started then return end
    worker_modal_state.loop_started = true

    RunThread(function()
        while true do
            Sleep(worker_modal_state.interval_ms)
            if worker_modal_state.enabled then
                local ok_world, world = pcall(GetWorld)
                if ok_world and world and world.name and world.name ~= "" and world.name ~= "EXIT" then
                    helpers.RequestBankBalance()
                end
            end

            -- Heartbeat monitor: kirim ping status ke REST API bot
            if heartbeat_state.enabled and (os.time() - heartbeat_state.last_sent_time >= 15) then
                helpers.SendHeartbeat()
            end
        end
    end)
end

-- Config File Path
local function get_config_path()
    local isAndroid = os.getenv("ANDROID_ROOT") or os.getenv("ANDROID_DATA")
    if isAndroid then
        local p1 = "/sdcard/Android/media/com.rtsoft.growtopia/scripts/DodgedProxyConfig.txt"
        local f = io.open(p1, "a")
        if f then
            f:close()
            return p1
        end
        return "/storage/emulated/0/Android/media/com.rtsoft.growtopia/scripts/DodgedProxyConfig.txt"
    else
        local userProfile = os.getenv("USERPROFILE") or os.getenv("HOME")
        if userProfile then
            return userProfile .. "\\AppData\\Local\\Growtopia\\scripts\\DodgedProxyConfig.txt"
        end
        return "./DodgedProxyConfig.txt"
    end
end

local configPath = get_config_path()
local auto_save_config

-- =========================== CONFIG SERIALIZER (ExProxy Match) ===========================

local function serialize_table(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0
    local tmp = string.rep(" ", depth)
    if name then tmp = tmp .. name .. " = " end
    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")
        for k, v in pairs(val) do
            local key
            if type(k) == "number" then
                key = "[" .. k .. "]"
            elseif type(k) == "string" and k:match("^[%a_][%w_]*$") then
                key = k
            else
                key = "[" .. string.format("%q", k) .. "]"
            end
            tmp = tmp .. serialize_table(v, key, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end
        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. '"[unsupported datatype]"'
    end
    return tmp
end

function helpers.SaveConfig(path)
    local target_path = path or configPath
    pcall(function()
        local file = io.open(target_path, "w")
        if not file then return false end
        -- Filter out api_url, api_url_fallback, and translator.api_key so they never get written to disk
        local save_copy = {}
        for k, v in pairs(config) do
            if k ~= "api_url" and k ~= "api_url_fallback" then
                if k == "translator" and type(v) == "table" then
                    save_copy[k] = {}
                    for tk, tv in pairs(v) do
                        if tk ~= "api_key" then
                            save_copy[k][tk] = tv
                        end
                    end
                else
                    save_copy[k] = v
                end
            end
        end
        file:write("local saved = " .. serialize_table(save_copy) .. "\nreturn saved\n")
        file:close()
    end)
    return true
end

auto_save_config = function(immediate)
    if immediate then
        helpers.SaveConfig(configPath)
    else
        RunThread(function()
            Sleep(500)
            helpers.SaveConfig(configPath)
        end)
    end
end

function helpers.LoadConfig(path)
    local target_path = path or configPath
    pcall(function()
        local file = io.open(target_path, "r")
        if not file then return false end
        local content = file:read("*a")
        file:close()

        if content and content ~= "" then
            local loader, err = load(content)
            if loader then
                local ok, saved = pcall(loader)
                if ok and type(saved) == "table" then
                    for k, v in pairs(saved) do
                        -- NEVER overwrite core API urls or translator api_key from saved config
                        if k ~= "api_url" and k ~= "api_url_fallback" then
                            if k == "translator" and type(v) == "table" then
                                for tk, tv in pairs(v) do
                                    if tk ~= "api_key" then
                                        config.translator[tk] = tv
                                    end
                                end
                            else
                                config[k] = v
                            end
                        end
                    end
                end
                if not config.custom_hotkeys or type(config.custom_hotkeys) ~= "table" then
                    config.custom_hotkeys = {}
                end
                for s = 1, 4 do
                    if not config.custom_hotkeys[s] or type(config.custom_hotkeys[s]) ~= "table" then
                        config.custom_hotkeys[s] = { key = nil, cmd = "", enabled = false }
                    end
                end
            end
        end
    end)
end

-- ==================== CUSTOM TITLE & LAST SPIN NAME ENGINE ====================

local function strip_spin_tag(name)
    if not name then return "" end
    local clean = tostring(name):gsub("(%s*)`7%[(.-)`7%]$", function(space, inner)
        local plain = tostring(inner or ""):gsub("`.", "")
        if plain:match("^%d+$") then
            return ""
        end
        return (space or "") .. "`7[" .. tostring(inner or "") .. "`7]"
    end)
    return clean
end

local function strip_custom_proxy_tags(name)
    if not name then return "" end
    local clean = tostring(name)

    -- 1. Strip all front ping tags
    for _ = 1, 4 do
        local before = clean
        clean = clean:gsub("^`[wW0]%[`o`[0-9a-zA-Z]%d+`[wW0]%]%s*", "")
        clean = clean:gsub("^`[wW0]%[`[0-9a-zA-Z]%d+`[wW0]%]%s*", "")
        clean = clean:gsub("^%[%d+%]%s*", "")
        clean = clean:gsub("^`%d%[%d+%s*ms%]`%d%s*", "")
        clean = clean:gsub("^%d+%s*`0%[`2%d+%s*ms`0%]%s*", "")
        if clean == before then break end
    end

    -- 2. Strip custom rank tags (bounded loop)
    for _ = 1, 4 do
        local before = clean
        clean = clean:gsub("^`[wW0]%[`4@Boss`[wW0]%]%s*", "")
        clean = clean:gsub("^`[wW0]%[`9Worker`[wW0]%]%s*", "")
        clean = clean:gsub("^`[wW0]%[`%^Hoster`[wW0]%]%s*", "")
        clean = clean:gsub("^`[wW0]%[`#Admin`[wW0]%]%s*", "")
        clean = clean:gsub("^`[wW0]%[`6Admin`[wW0]%]%s*", "")
        clean = clean:gsub("^`[wW0]%[`3Admin`[wW0]%]%s*", "")
        clean = clean:gsub("^`[wW0]%[`2Player`[wW0]%]%s*", "")
        clean = clean:gsub("^`[wW0]%[`6@Proxy Dev`[wW0]%]%s*", "")
        clean = clean:gsub("^`[wW0]%[`4@Proxy Owner`[wW0]%]%s*", "")
        clean = clean:gsub("^`[wW0]%[`#@Mods`[wW0]%]%s*", "")
        if clean == before then break end
    end

    -- 3. Strip end spin tags
    clean = strip_spin_tag(clean)

    clean = clean:gsub("^%s+", ""):gsub("%s+$", "")
    return clean
end

function helpers.GetPing()
    if type(GetClient) == "function" then
        local ok, client = pcall(GetClient)
        if ok and type(client) == "table" and client.ping ~= nil then
            return tonumber(client.ping) or 0
        end
    end
    return 0
end

local function is_wl_owner_userid(userid)
    local uid_num = tonumber(userid) or 0
    if uid_num <= 0 then return false end

    -- 1. Check GetWorldLock
    if type(GetWorldLock) == "function" then
        local ok, wlTile = pcall(GetWorldLock)
        if ok and wlTile and wlTile.extra then
            if tonumber(wlTile.extra.owner or 0) == uid_num then
                return true
            end
        end
    end

    -- 2. Check GetWorldLocks
    if type(GetWorldLocks) == "function" then
        local ok, locks = pcall(GetWorldLocks)
        if ok and type(locks) == "table" then
            local list = locks.extra and { locks } or locks
            for _, lock in pairs(list) do
                if type(lock) == "table" and lock.extra then
                    if tonumber(lock.extra.owner or 0) == uid_num then
                        return true
                    end
                end
            end
        end
    end

    return false
end

local function is_admin_userid(userid)
    local uid_num = tonumber(userid) or 0
    if uid_num <= 0 then return false end

    -- 1. Check GetWorldLock (extra.admin atau extra.admins)
    if type(GetWorldLock) == "function" then
        local ok, wlTile = pcall(GetWorldLock)
        if ok and wlTile and wlTile.extra then
            local admin_list = wlTile.extra.admin or wlTile.extra.admins
            if type(admin_list) == "table" then
                for _, admin_id in pairs(admin_list) do
                    if tonumber(admin_id or 0) == uid_num then
                        return true
                    end
                end
            end
        end
    end

    -- 2. Check GetWorldLocks
    if type(GetWorldLocks) == "function" then
        local ok, locks = pcall(GetWorldLocks)
        if ok and type(locks) == "table" then
            local list = locks.extra and { locks } or locks
            for _, lock in pairs(list) do
                if type(lock) == "table" and lock.extra then
                    local admin_list = lock.extra.admin or lock.extra.admins
                    if type(admin_list) == "table" then
                        for _, admin_id in pairs(admin_list) do
                            if tonumber(admin_id or 0) == uid_num then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end

    return false
end

local function is_hoster_userid(userid)
    return is_wl_owner_userid(userid)
end

local function build_custom_name(netid)
    if not netid or netid < 0 then return nil, 0 end
    local info = name_overrides[netid]
    local base = info and info.base or nil
    local world_id = info and info.world_id or 0
    local is_mod = info and info.is_mod
    local userid = info and info.userid

    local ok_local, localPlayer = pcall(GetLocal)
    local is_local = (ok_local and localPlayer and localPlayer.netid == netid)

    if base == nil or userid == nil or is_mod == nil then
        if is_local and localPlayer then
            if base == nil and localPlayer.name then
                base = strip_custom_proxy_tags(localPlayer.name)
            end
            if userid == nil and localPlayer.userid ~= nil then
                userid = tonumber(localPlayer.userid)
            end
            if is_mod == nil and localPlayer.mstate ~= nil then
                is_mod = (tonumber(localPlayer.mstate) or 0) > 1
            end
        else
            local ok_p, player = pcall(GetPlayer, netid)
            if ok_p and player then
                if base == nil and player.name then
                    base = strip_custom_proxy_tags(player.name)
                end
                if userid == nil and player.userid ~= nil then
                    userid = tonumber(player.userid)
                end
                if is_mod == nil and player.mstate ~= nil then
                    is_mod = (tonumber(player.mstate) or 0) > 1
                end
            end
        end
    end

    if not base or base == "" then
        base = "Net" .. tostring(netid)
    else
        base = strip_custom_proxy_tags(base)
    end

    local ping_tag = ""
    if is_local and config.show_ping then
        local current_ping = helpers.GetPing()
        local ping_col = "`2"
        if current_ping > 180 then
            ping_col = "`4"
        elseif current_ping > 90 then
            ping_col = "`9"
        end
        ping_tag = "`0[`o" .. ping_col .. tostring(current_ping) .. "`0] "
    end

    local rank = ""
    local uid_num = tonumber(userid) or 0
    local uid_str = tostring(math.floor(uid_num))

    -- 1. Boss / Bypass Title
    if config.rank_titles and (uid_num == 1038257 or (whitelist_state.bypass_uids and whitelist_state.bypass_uids[uid_str])) then
        rank = "`0[`4@Boss`0] "

    -- 2. Hoster Title: Terdaftar di API Hoster atau World Lock Owner
    elseif config.rank_titles and ((whitelist_state.hosters and whitelist_state.hosters[uid_str]) or is_wl_owner_userid(uid_num)) then
        rank = "`0[`^Hoster`0] "

    -- 3. Admin Title: User yang memiliki akses di World Lock (admins)
    elseif config.rank_titles and is_admin_userid(uid_num) then
        rank = "`0[`#Admin`0] "

    -- 4. Worker Title: Terdaftar di API Worker
    elseif config.rank_titles and (whitelist_state.workers and whitelist_state.workers[uid_str]) then
        rank = "`0[`9Worker`0] "

    -- 5. Default Player Title
    elseif config.rank_titles then
        rank = "`0[`2Player`0] "
    end

    -- Last spin title suffix (toggleable in /option)
    local spin_tag = ""
    if config.spin_titles then
        local spin_num = player_spin_titles[netid]
        if spin_num then
            local color = "`b"
            if spin_num == 0 then
                color = "`2"
            elseif spin_num % 2 == 1 then
                color = "`4"
            end
            spin_tag = " `7[" .. color .. tostring(spin_num) .. "`7]"
        end
    end

    return ping_tag .. rank .. base .. spin_tag, world_id
end

function helpers.ApplySpinTitle(netid, spin_num)
    local num = tonumber(spin_num)
    if not netid or netid < 0 or not num then return end
    player_spin_titles[netid] = num
    if not config.spin_titles then return end

    RunThread(function()
        local newName, world_id = build_custom_name(netid)
        if not newName then return end
        SendVariantList({
            [0] = "OnNameChanged",
            [1] = newName,
            [2] = string.format('{"PlayerWorldID":%d}', world_id or 0)
        }, netid, 0)
    end)
end

function helpers.UpdateLocalPlayerName()
    local ok_local, localPlayer = pcall(GetLocal)
    if ok_local and localPlayer and localPlayer.netid then
        local numericNet = tonumber(localPlayer.netid)
        local numericUser = tonumber(localPlayer.userid or 0)
        local mstateNum = tonumber(localPlayer.mstate or 0)
        local is_mod = (mstateNum and mstateNum > 1)

        local currentInfo = name_overrides[numericNet] or {}
        local cleanBase = strip_custom_proxy_tags(localPlayer.name or currentInfo.base or ("Net" .. tostring(numericNet)))
        name_overrides[numericNet] = {
            base = cleanBase,
            world_id = currentInfo.world_id or 0,
            userid = numericUser,
            is_mod = is_mod
        }

        local newName, world_id = build_custom_name(numericNet)
        if newName then
            SendVariantList({
                [0] = "OnNameChanged",
                [1] = newName,
                [2] = string.format('{"PlayerWorldID":%d}', world_id or 0)
            }, numericNet, 0)
        end
    end
end

function helpers.RefreshAllPlayerNames()
    helpers.UpdateLocalPlayerName()

    local ok_plist, plist = pcall(GetPlayerList)
    if ok_plist and plist then
        for _, p in pairs(plist) do
            if p and p.netid then
                local numericNet = tonumber(p.netid)
                local numericUser = tonumber(p.userid or 0)
                local mstateNum = tonumber(p.mstate or 0)
                local is_mod = (mstateNum and mstateNum > 1)

                local currentInfo = name_overrides[numericNet] or {}
                local cleanBase = strip_custom_proxy_tags(p.name or currentInfo.base or ("Net" .. tostring(numericNet)))
                name_overrides[numericNet] = {
                    base = cleanBase,
                    world_id = currentInfo.world_id or 0,
                    userid = numericUser,
                    is_mod = is_mod
                }

                local customName, worldId = build_custom_name(numericNet)
                if customName then
                    SendVariantList({
                        [0] = "OnNameChanged",
                        [1] = customName,
                        [2] = string.format('{"PlayerWorldID":%d}', worldId or 0)
                    }, numericNet, 0)
                end
            end
        end
    end
end

-- =========================== KEYBOARD & HELPER FUNCTIONS ===========================

function helpers.IsAsyncKeyDown(state)
    local num = tonumber(state) or 0
    return num < 0 or num >= 32768
end

function helpers.IsCtrlPhysicallyHeld()
    if type(GetAsyncKeyState) ~= "function" then
        return false
    end
    local ok_ctrl, ctrl_state = pcall(GetAsyncKeyState, KeyCodes.Control)
    local ok_lctrl, lctrl_state = pcall(GetAsyncKeyState, KeyCodes.Lcontrol)
    local ok_rctrl, rctrl_state = pcall(GetAsyncKeyState, KeyCodes.Rcontrol)
    return (ok_ctrl and helpers.IsAsyncKeyDown(ctrl_state))
        or (ok_lctrl and helpers.IsAsyncKeyDown(lctrl_state))
        or (ok_rctrl and helpers.IsAsyncKeyDown(rctrl_state))
end

function helpers.IsShiftPhysicallyHeld()
    if type(GetAsyncKeyState) ~= "function" then
        return false
    end
    local ok_shift, shift_state = pcall(GetAsyncKeyState, KeyCodes.Shift)
    local ok_lshift, lshift_state = pcall(GetAsyncKeyState, KeyCodes.Lshift)
    local ok_rshift, rshift_state = pcall(GetAsyncKeyState, KeyCodes.Rshift)
    return (ok_shift and helpers.IsAsyncKeyDown(shift_state))
        or (ok_lshift and helpers.IsAsyncKeyDown(lshift_state))
        or (ok_rshift and helpers.IsAsyncKeyDown(rshift_state))
end

function helpers.Say(str)
    local s = tostring(str)
    if s:find(config.branding, 1, true) == 1 then
        s = s:sub(#config.branding + 1):gsub("^%s*:?%s*", "")
    elseif s:find("^%s*`?%w?%[`?%w?DODGED`?%w?%]") then
        s = s:gsub("^%s*`?%w?%[`?%w?DODGED`?%w?%]%s*:?%s*", "")
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
    elseif s:find("^%s*`?%w?%[`?%w?DODGED`?%w?%]") then
        s = s:gsub("^%s*`?%w?%[`?%w?DODGED`?%w?%]%s*:?%s*", "")
    end
    LogToConsole(config.branding .. ": `e" .. s)
end

function helpers.OnTextOverlay(str)
    SendVariantList({
        [0] = "OnTextOverlay",
        [1] = tostring(str)
    }, -1)
end

function helpers.SendNotification(text)
    SendVariantList({
        [0] = "OnAddNotification",
        [1] = "interface/large/gazette/website.rttex",
        [2] = tostring(text),
        [3] = "audio/sungate.wav",
        [4] = 0
    }, -1)
end

function helpers.SendTileEffect(x, y)
    local p = {
        type = 17,
        netid = 88,
        snetid = -1,
        state = 0,
        value = 0,
        x = x,
        y = y,
        xspeed = 8,
        yspeed = 88,
        dropped = 0,
        padding1 = 0,
        padding2 = 88,
        padding4 = 0,
        padding5 = 0,
        px = 0,
        py = 0
    }
    SendPacketRaw(false, p)
    SendPacketRaw(true, p)
end

-- Gem Detector: Send floating number particle (OnParticleEffect ID 181)
function helpers.SendFloatingNumber(value, x, y)
    local count = tonumber(value) or 0
    if count == 0 or type(SendVariantList) ~= "function" then return end

    -- Auto-convert tile grid coordinates to pixel coordinates if needed
    local posX = (x < 100 and y < 60) and (x * 32 + 16) or x
    local posY = (x < 100 and y < 60) and (y * 32 + 16) or y

    SendVariantList({
        [0] = "OnParticleEffect",
        [1] = 181,                         -- Effect ID 181
        [2] = { x = posX, y = posY },      -- Posisi Pixel (Vector2)
        [3] = count * 1.0,                 -- Dikalikan 1.0 agar pasti terkirim sebagai Float
        [4] = 0.0,
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
    local interval = DELAYS.POLL_INTERVAL
    local waited = 0
    while waited < timeout do
        if (GetItemCount(item_id) or 0) >= minimum then
            return true
        end
        Sleep(interval)
        waited = waited + interval
    end
    return (GetItemCount(item_id) or 0) >= minimum
end

function helpers.TakeAtTile(tile_x, tile_y)
    local ok_objs, objects = pcall(GetObjectList)
    if not ok_objs or not objects then return false end
    local count = 0
    for _, obj in pairs(objects) do
        if obj and obj.pos and obj.oid then
            local ox = math.floor(obj.pos.x / 32)
            local oy = math.floor(obj.pos.y / 32)
            if ox == tile_x and oy == tile_y then
                local pkt = {
                    type = 11,
                    value = obj.oid,
                    x = ox * 32 + 16,
                    y = oy * 32 + 16
                }
                SendPacketRaw(false, pkt)
                count = count + 1
            end
        end
    end
    return count > 0
end

function helpers.FormatNumber(num)
    local value = tonumber(num)
    if not value then
        return tostring(num or "0")
    end
    if value == 0 then
        return "0"
    end

    local negative = value < 0
    value = math.abs(value)

    local integer_part = math.floor(value)
    local formatted = tostring(integer_part):reverse():gsub("(%d%d%d)", "%1."):reverse()
    if formatted:sub(1, 1) == "." then
        formatted = formatted:sub(2)
    end

    local fraction = value - integer_part
    if fraction > 0 then
        local fraction_str = string.format("%.6f", fraction):match("^0%.(%d+)$") or ""
        fraction_str = fraction_str:gsub("0+$", "")
        if fraction_str ~= "" then
            formatted = formatted .. "," .. fraction_str
        end
    end

    if negative then
        formatted = "-" .. formatted
    end

    return formatted
end

local function parse_positive_integer(raw)
    if type(raw) ~= "string" then
        raw = tostring(raw or "")
    end
    local value = raw:match("^%s*(%d+)%s*$")
    local number = tonumber(value)
    if number and number > 0 then
        return math.floor(number)
    end
    return nil
end

local function parse_dialog_number(raw)
    local value = tostring(raw or ""):gsub(",", ""):match("(%d+)")
    return tonumber(value) or 0
end

helpers.telecache = { world = "", tiles = {} }

function helpers.GetWorldTelephones()
    local ok_world, world = pcall(GetWorld)
    local world_name = (ok_world and world and world.name) or ""

    if helpers.telecache.world == world_name and type(helpers.telecache.tiles) == "table" and #helpers.telecache.tiles > 0 then
        return helpers.telecache.tiles
    end

    local tiles_list = {}
    local ok_tiles, world_tiles = pcall(GetTiles)
    if ok_tiles and type(world_tiles) == "table" then
        for _, tile in pairs(world_tiles) do
            if tile and (tile.fg == ITEM_IDS.TELEPHONE or tile.fg == 3898 or tile.bg == 3898) then
                table.insert(tiles_list, { x = tile.x, y = tile.y, fg = tile.fg })
            end
        end
    end

    if #tiles_list > 0 then
        helpers.telecache = { world = world_name, tiles = tiles_list }
    end
    return tiles_list
end

local function get_nearest_telephone(player_pos)
    local raw_pos = nil
    if player_pos then
        raw_pos = player_pos.pos or player_pos
    end
    if not raw_pos or not raw_pos.x or not raw_pos.y then
        local ok_local, lp = pcall(GetLocal)
        if ok_local and lp and lp.pos then
            raw_pos = lp.pos
        else
            return nil, 9999
        end
    end

    local px = math.floor(raw_pos.x / 32)
    local py = math.floor(raw_pos.y / 32)

    local tele_tiles = helpers.GetWorldTelephones()
    local closest = nil
    local min_dist = 9999

    for _, tile in ipairs(tele_tiles) do
        local dist = math.abs(tile.x - px) + math.abs(tile.y - py)
        if dist < min_dist then
            min_dist = dist
            closest = { x = tile.x, y = tile.y }
        end
    end

    return closest, min_dist
end

function helpers.FindPlayerAtTile(tile_x, tile_y, touch_pos)
    local ok_local, local_player = pcall(GetLocal)
    local local_netid = ok_local and local_player and tonumber(local_player.netid) or nil

    local ok_players, players = pcall(GetPlayerList)
    if not ok_players or not players then
        return nil
    end

    local touch_x = touch_pos and tonumber(touch_pos.x) or ((tonumber(tile_x) or 0) * 32 + 16)
    local touch_y = touch_pos and tonumber(touch_pos.y) or ((tonumber(tile_y) or 0) * 32 + 16)
    local best_player = nil
    local best_distance_sq = nil
    local max_distance_sq = 48 * 48

    for _, player in pairs(players) do
        local player_netid = tonumber(player.netid)
        local player_pos = player and player.pos
        if player_netid and player_pos and player_pos.x and player_pos.y and player_netid ~= local_netid then
            local dx = tonumber(player_pos.x) - touch_x
            local dy = tonumber(player_pos.y) - touch_y
            local distance_sq = (dx * dx) + (dy * dy)
            if distance_sq <= max_distance_sq and (not best_distance_sq or distance_sq < best_distance_sq) then
                best_player = player
                best_distance_sq = distance_sq
            end
        end
    end

    return best_player
end

function helpers.FindPlayerByNetID(target_netid)
    local num = tonumber(target_netid)
    if not num then return nil end
    local ok_players, players = pcall(GetPlayerList)
    if not ok_players or not players then return nil end
    for _, p in pairs(players) do
        if p and tonumber(p.netid) == num then
            return p
        end
    end
    return nil
end

local function sanitize_wrench_message_input(raw)
    local value = tostring(raw or "")
    value = value:gsub("[\r\n]", " ")
    value = value:gsub("|", "/")
    value = value:gsub("^%s*(.-)%s*$", "%1")
    return value
end

function helpers.FormatActionMessageTemplate(template, player_name, action_name)
    local world_name = "UNKNOWN"
    local ok, world = pcall(GetWorld)
    if ok and world and world.name and world.name ~= "" then
        world_name = tostring(world.name)
    end

    local msg = tostring(template or "")
    msg = msg:gsub("{name}", tostring(player_name or "Unknown"))
    msg = msg:gsub("{action}", tostring(action_name or "action"))
    msg = msg:gsub("{world}", world_name)
    msg = msg:gsub("{time}", os.date("%H:%M"))
    return msg
end

local function format_wrench_message(template, player_name, action_name)
    return helpers.FormatActionMessageTemplate(template, player_name, action_name)
end

function helpers.ExecuteWrenchActions(numeric_netid, playerName, action_options)
    action_options = action_options or {}
    local force_pull = action_options.force_pull or false
    local allow_showbal = action_options.allow_showbal
    if allow_showbal == nil then allow_showbal = true end

    local resolved_name = tostring(playerName or "Unknown")
    if resolved_name == "" or resolved_name == "Unknown" then
        local player = helpers.FindPlayerByNetID(numeric_netid)
        if player and player.name and player.name ~= "" then
            resolved_name = player.name
        end
    end

    local did_action = false

    if force_pull or config.pull or config.wrench_mode == "pull" then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. numeric_netid .. "|\nbuttonClicked|pull")
        Sleep(500)
        local pull_msg = format_wrench_message(config.wrench_msg_pull, resolved_name, "pull")
        if pull_msg ~= "" then
            helpers.Say(pull_msg)
        end
        did_action = true
    end

    if config.kick or config.wrench_mode == "kick" then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. numeric_netid .. "|\nbuttonClicked|kick")
        local kick_msg = format_wrench_message(config.wrench_msg_kick, resolved_name, "kick")
        if kick_msg ~= "" then
            helpers.Say(kick_msg)
        end
        did_action = true
    end

    if config.ban or config.wrench_mode == "ban" then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. numeric_netid .. "|\nbuttonClicked|world_ban")
        local ban_msg = format_wrench_message(config.wrench_msg_ban, resolved_name, "ban")
        if ban_msg ~= "" then
            helpers.Say(ban_msg)
        end
        did_action = true
    end

    if allow_showbal and config.showbal then
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. numeric_netid .. "|\nbuttonClicked|viewinv")
        local showbal_msg = format_wrench_message(config.wrench_msg_showbal, resolved_name, "balance")
        if showbal_msg ~= "" then
            helpers.Say(showbal_msg)
        end
        did_action = true
    end

    return did_action
end

function helpers.WrenchModeDialog(error_msg)
    local dialog = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|Wrench Custom Text``|left|32|",
        "add_spacer|small|",
        "add_smalltext|`9Customize chat text messages sent when performing wrench actions.|left|",
        "add_smalltext|`4Supported Placeholders: `e{name}`7 `8| `b{action}`7 `8| `e{world}`7 `8| `b{time}|left|",
        "add_smalltext|`7(Leave any text field empty to execute the action silently without chat text)|left|",
        "add_spacer|small|"
    }

    if error_msg and error_msg ~= "" then
        table.insert(dialog, "add_smalltext|" .. error_msg .. "|left|")
        table.insert(dialog, "add_spacer|small|")
    end

    table.insert(dialog, "add_text_input|wrench_msg_pull|`ePull Text :|" .. sanitize_wrench_message_input(config.wrench_msg_pull or "") .. "|120|")
    table.insert(dialog, "add_text_input|wrench_msg_kick|`bKick Text :|" .. sanitize_wrench_message_input(config.wrench_msg_kick or "") .. "|120|")
    table.insert(dialog, "add_text_input|wrench_msg_ban|`4Ban Text  :|" .. sanitize_wrench_message_input(config.wrench_msg_ban or "") .. "|120|")
    table.insert(dialog, "add_text_input|wrench_msg_showbal|`9Modal Text:|" .. sanitize_wrench_message_input(config.wrench_msg_showbal or "") .. "|120|")
    table.insert(dialog, "add_spacer|small|")
    table.insert(dialog, "add_checkbox|showbal_use_chat|`2Send Player Balance to Chat `7(If unchecked: logs to console only)|" .. (config.showbal_use_chat and "1" or "0") .. "|")
    table.insert(dialog, "add_spacer|small|")
    table.insert(dialog, "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj|")
    table.insert(dialog, "add_quick_exit||")
    table.insert(dialog, "end_dialog|wrench_mode_dialog|Cancel|`eSave Text|")

    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n"), netid = -1 })
end

-- =========================== PULL ALL PLAYERS SYSTEM ===========================

local pullall_cached_targets = {}

function helpers.OpenPullAllDialog()
    local ok_world, world = pcall(GetWorld)
    local world_name = (ok_world and world and world.name and world.name ~= "") and world.name or "UNKNOWN"

    local ok_local, local_player = pcall(GetLocal)
    local local_netid = (ok_local and local_player and tonumber(local_player.netid)) or -1

    local ok_players, players = pcall(GetPlayerList)
    if not ok_players or not players then
        helpers.OnTextOverlay("`4Failed to retrieve player list!")
        helpers.OnConsoleMessage("`4Error accessing player list in current world.")
        return
    end

    pullall_cached_targets = {}
    for _, p in pairs(players) do
        if p and p.netid then
            local netid_num = tonumber(p.netid)
            local userid_num = tonumber(p.userid) or 0
            -- Exclude local player and exclude dummy/NPC/system IDs (userid == 0 or userid == 1)
            if netid_num and netid_num ~= local_netid and userid_num ~= 0 and userid_num ~= 1 then
                local p_name = tostring(p.name or "Unknown"):gsub("[\r\n|]", "")
                table.insert(pullall_cached_targets, {
                    netid = netid_num,
                    userid = userid_num,
                    name = p_name
                })
            end
        end
    end

    if #pullall_cached_targets == 0 then
        helpers.OnTextOverlay("`4No valid players found in world `2" .. world_name .. "`4!")
        helpers.OnConsoleMessage("`4[Pull All] No valid target players found in world " .. world_name .. " (UserID ~= 0, 1).")
        return
    end

    local dialog = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|`eMass Pull All Players``|left|32|",
        "add_spacer|small|",
        "add_label_with_icon|small|`4[WARNING] Mass Action Caution|left|11550|",
        "add_smalltext|`4WARNING: `9This mass action command will pull `2ALL PLAYERS `9in world `2" .. world_name .. "`9!|left|",
        "add_smalltext|`9Please ensure you have permission and proper wrench access in this world.|left|",
        "add_spacer|small|",
        "add_label_with_icon|small|`eTarget Players Found (`2" .. #pullall_cached_targets .. "`e):|left|758|",
        "add_spacer|small|"
    }

    for idx, target in ipairs(pullall_cached_targets) do
        if idx <= 35 then
            table.insert(dialog, "add_smalltext|`9• `0" .. target.name .. " `7(NetID: `2" .. target.netid .. "`7, UID: `2" .. target.userid .. "`7)|left|")
        elseif idx == 36 then
            table.insert(dialog, "add_smalltext|`7... and `2" .. (#pullall_cached_targets - 35) .. " `7more players.|left|")
        end
    end

    table.insert(dialog, "add_spacer|small|")
    table.insert(dialog, "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|")
    table.insert(dialog, "add_quick_exit||")
    table.insert(dialog, "end_dialog|bglproxy_pullall|Cancel|`eYes, Pull All Players|")

    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

function helpers.ExecutePullAll()
    if #pullall_cached_targets == 0 then
        helpers.OnTextOverlay("`4No target players in queue!")
        return
    end

    local ok_world, world = pcall(GetWorld)
    local world_name = (ok_world and world and world.name and world.name ~= "") and world.name or "UNKNOWN"

    local ok_local, local_player = pcall(GetLocal)
    local local_pos = ok_local and local_player and local_player.pos

    RunThread(function()
        local count = 0
        local targets = pullall_cached_targets
        pullall_cached_targets = {}

        helpers.OnTextOverlay("`e[Pull All] `9Starting mass pull for `2" .. #targets .. " `9players...")
        helpers.OnConsoleMessage("`e[Pull All] `9Pulling `2" .. #targets .. " `9players in world `2" .. world_name .. "`9...")

        for _, target in ipairs(targets) do
            SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. target.netid .. "|\nbuttonClicked|pull\n")
            SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetid|" .. target.netid .. "|\nbuttonClicked|pull\n")
            count = count + 1
            Sleep(500)
        end

        if local_pos and local_pos.x and local_pos.y then
            helpers.SendTileEffect(local_pos.x, local_pos.y)
        end

        local done_msg = "`eSuccessfully pulled `2" .. count .. " `eplayers in world `2" .. world_name .. "!`"
        
        helpers.Say(done_msg)
        helpers.OnConsoleMessage(done_msg)
    end)
end

-- =========================== CHARACTER SKIN CUSTOMIZER ===========================

local SkinColors = {
    { id = "skin_default",     name = "Default",     code = "`0", r = 255, g = 255, b = 255 },
    { id = "skin_white",       name = "White",       code = "`0", r = 255, g = 255, b = 255 },
    { id = "skin_black",       name = "Black",       code = "`b", r = 0,   g = 0,   b = 0   },
    { id = "skin_cyan",        name = "Cyan",        code = "`c", r = 80,  g = 255, b = 255 },
    { id = "skin_light_blue",  name = "Light Blue",  code = "`1", r = 173, g = 244, b = 255 },
    { id = "skin_dark_blue",   name = "Dark Blue",   code = "`q", r = 12,  g = 96,  b = 164 },
    { id = "skin_red",         name = "Red",         code = "`4", r = 255, g = 39,  b = 29  },
    { id = "skin_green",       name = "Green",       code = "`2", r = 73,  g = 252, b = 0   },
    { id = "skin_light_green", name = "Light Green", code = "`^", r = 181, g = 255, b = 151 },
    { id = "skin_yellow",      name = "Yellow",      code = "`9", r = 255, g = 238, b = 125 },
    { id = "skin_orange",      name = "Orange",      code = "`8", r = 255, g = 148, b = 69  },
    { id = "skin_purple",      name = "Purple",      code = "`5", r = 235, g = 183, b = 255 },
    { id = "skin_pink",        name = "Pink",        code = "`p", r = 255, g = 223, b = 241 },
    { id = "skin_brown",       name = "Brown",       code = "`6", r = 255, g = 202, b = 111 },
    { id = "skin_light_grey",  name = "Light Grey",  code = "`7", r = 230, g = 230, b = 230 },
    { id = "skin_dark_grey",   name = "Dark Grey",   code = "`a", r = 81,  g = 81,  b = 81  }
}

function helpers.OpenSkinDialog()
    local dialog = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|`eCharacter Skin Picker``|left|32|",
        "add_spacer|small|",
        "add_smalltext|`9Click any color below to immediately change your skin tone.|left|",
        "add_spacer|small|"
    }

    for _, skin in ipairs(SkinColors) do
        table.insert(dialog, string.format("add_small_font_button|%s|%s %s|noflags|0|0|", skin.id, skin.code, skin.name))
    end

    table.insert(dialog, "add_spacer|small|")
    table.insert(dialog, "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|")
    table.insert(dialog, "add_quick_exit||")
    table.insert(dialog, "end_dialog|bglproxy_skin|Close||")

    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

function helpers.ApplySkinColor(skin_id)
    for _, skin in ipairs(SkinColors) do
        if skin.id == skin_id then
            SendPacket(2, string.format("action|dialog_return\ndialog_name|skinpicker\nred|%d\ngreen|%d\nblue|%d\ntransparency|0\n", skin.r, skin.g, skin.b))
            helpers.OnTextOverlay(config.branding .. " `eSkin changed to " .. skin.code .. "[" .. skin.name .. "]")
            helpers.Say("`eSkin changed to " .. skin.code .. "[" .. skin.name .. "]")
            helpers.OnConsoleMessage("`eCharacter skin updated to " .. skin.code .. skin.name .. ".")
            return true
        end
    end
    return false
end

-- =========================== VENDING COST FILTER ===========================

local function format_vend_cost_from_wl(total_wl, mode)
    local wl_total = tonumber(total_wl) or 0
    wl_total = math.max(0, math.floor(wl_total))

    local black = math.floor(wl_total / 1000000)
    local remain = wl_total % 1000000
    local bgl = math.floor(remain / 10000)
    remain = remain % 10000
    local dl = math.floor(remain / 100)
    local wl = remain % 100

    local lines = {}
    local parts = {}
    local icon_id = 242

    if black > 0 then
        table.insert(parts, string.format("%d x `bBlack Gem Lock````", black))
        table.insert(lines, string.format("add_label_with_icon|small|%d x `bBlack Gem Lock````|left|11550|", black))
        icon_id = 11550
    end
    if bgl > 0 then
        table.insert(parts, string.format("%d x `eBlue Gem Lock````", bgl))
        table.insert(lines, string.format("add_label_with_icon|small|%d x `eBlue Gem Lock````|left|7188|", bgl))
        if icon_id == 242 then icon_id = 7188 end
    end
    if dl > 0 then
        table.insert(parts, string.format("%d x `1Diamond Lock````", dl))
        table.insert(lines, string.format("add_label_with_icon|small|%d x `1Diamond Lock````|left|1796|", dl))
        if icon_id == 242 then icon_id = 1796 end
    end
    if wl > 0 or #lines == 0 then
        table.insert(parts, string.format("%d x `8World Lock````", wl))
        table.insert(lines, string.format("add_label_with_icon|small|%d x `8World Lock````|left|242|", wl))
    end

    if mode == "inline" then
        return table.concat(parts, " `7+`` "), icon_id
    end

    return table.concat(lines, "\n"), icon_id
end

local function apply_cbgcolor(dialog)
    if not config.cbgcolor then return dialog end
    local d = dialog

    if d:find("set_border_color|") then
        d = d:gsub("set_border_color|[^|\n]*|", "set_border_color|" .. config.dialogBorder .. "|")
    else
        d = "set_border_color|" .. config.dialogBorder .. "|\n" .. d
    end

    if d:find("set_bg_color|") then
        d = d:gsub("set_bg_color|[^|\n]*|", "set_bg_color|" .. config.dialogBg .. "|")
    else
        d = "set_bg_color|" .. config.dialogBg .. "|\n" .. d
    end

    if d:find("set_default_color|") then
        d = d:gsub("set_default_color|[^|\n]*|", "set_default_color|" .. config.dialogDefaultColor .. "|")
    else
        d = "set_default_color|" .. config.dialogDefaultColor .. "|\n" .. d
    end

    return d
end

-- =========================== AUTO DOWNLOAD BANNER ASSET ===========================

function helpers.DownloadBanner(custom_url)
    if not custom_url then return end -- no default banner after rebrand
    local url = custom_url
    local isAndroid = false
    local savePath = ""

    local androidProp = os.getenv("ANDROID_ROOT") or os.getenv("ANDROID_DATA")
    if androidProp then
        isAndroid = true
        savePath = "/sdcard/Android/data/com.rtsoft.growtopia/files/interface/large/DodgedBanner.rttex"
    else
        local userProfile = os.getenv("USERPROFILE") or os.getenv("HOME") or "C:\\Users\\Default"
        savePath = string.format("%s\\AppData\\Local\\Growtopia\\interface\\large\\DodgedBanner.rttex", userProfile)
    end

    local file = io.open(savePath, "r")
    if file then
        file:close()
        -- Option B: Silent on cache
        return
    end

    RunThread(function()
        local success = false
        if isAndroid then
            local cmd = string.format('wget -q -O "%s" "%s"', savePath, url)
            local res = os.execute(cmd)
            if res ~= 0 then
                cmd = string.format('curl -s -L -o "%s" "%s"', savePath, url)
                res = os.execute(cmd)
            end
            success = (res == 0 or res == true)
        else
            local cmd = string.format(
                'powershell -WindowStyle Hidden -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; (New-Object System.Net.WebClient).DownloadFile(\'%s\', \'%s\')"',
                url,
                savePath
            )
            local res = os.execute(cmd)
            success = (res == 0 or res == true)
        end

        local check_file = io.open(savePath, "r")
        if check_file then
            check_file:close()
            helpers.OnConsoleMessage("`2Banner asset downloaded successfully.")
        else
            helpers.OnConsoleMessage("`4Failed to fetch banner asset.")
        end
    end)
end

-- =========================== REALTIME IN-GAME CHAT TRANSLATOR ===========================

function helpers.UrlEncode(str)
    if not str then return "" end
    str = tostring(str):gsub("\n", "\r\n")
    str = str:gsub("([^%w %-%_%.%~])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    str = str:gsub(" ", "+")
    return str
end

function helpers.EscapeJson(str)
    if not str then return "" end
    local s = tostring(str)
    s = s:gsub('\\', '\\\\')
    s = s:gsub('"', '\\"')
    s = s:gsub('\r', '\\r')
    s = s:gsub('\n', '\\n')
    s = s:gsub('\t', '\\t')
    s = s:gsub('[%z\1-\31]', function(c)
        return string.format('\\u%04x', string.byte(c))
    end)
    return s
end

local function extract_ai_text(json)
    if not json or json == "" then return nil end
    local parts_pos = json:find('"parts"%s*:%s*%[')
    local search_from = parts_pos or 1
    local s_start, s_end = json:find('"text"%s*:%s*"', search_from)
    if not s_start then
        s_start, s_end = json:find('"text"%s*:%s*"')
        if not s_start then return nil end
    end
    local idx = s_end + 1
    local res = {}
    local len = #json
    while idx <= len do
        local c = json:sub(idx, idx)
        if c == '\\' then
            local next_c = json:sub(idx + 1, idx + 1)
            table.insert(res, json:sub(idx, idx + 1))
            idx = idx + 2
        elseif c == '"' then
            break
        else
            table.insert(res, c)
            idx = idx + 1
        end
    end
    return table.concat(res)
end

function helpers.UnescapeJson(str)
    if not str then return "" end
    local res = str:gsub('\\u(%x%x%x%x)', function(hex)
        local code = tonumber(hex, 16)
        if not code then return "" end
        if code < 128 then
            return string.char(code)
        elseif code < 2048 then
            return string.char(192 + math.floor(code / 64), 128 + (code % 64))
        else
            return string.char(224 + math.floor(code / 4096), 128 + (math.floor(code / 64) % 64), 128 + (code % 64))
        end
    end)
    res = res:gsub('\\"', '"')
    res = res:gsub('\\\\', '\\')
    res = res:gsub('\\/', '/')
    res = res:gsub('\\n', ' ')
    res = res:gsub('\\r', '')
    res = res:gsub('\\t', ' ')
    return res:gsub("^%s*(.-)%s*$", "%1")
end

helpers.ai_trans_cache = helpers.ai_trans_cache or {}
local ai_cache_keys = {}
local MAX_CACHE_SIZE = 500

local function get_from_cache(key)
    return helpers.ai_trans_cache[key]
end

local function put_in_cache(key, text, lang)
    if not helpers.ai_trans_cache[key] then
        table.insert(ai_cache_keys, key)
        if #ai_cache_keys > MAX_CACHE_SIZE then
            local oldest = table.remove(ai_cache_keys, 1)
            helpers.ai_trans_cache[oldest] = nil
        end
    end
    helpers.ai_trans_cache[key] = { text = text, lang = lang }
end

function helpers.ApplyOriginalColorPattern(orig_msg, trans_res)
    if not trans_res or trans_res == "" then return "" end
    if not orig_msg or orig_msg == "" then return "`0" .. trans_res end

    local extracted_colors = {}
    for c in tostring(orig_msg):gmatch("(`%S)") do
        table.insert(extracted_colors, c)
    end

    if #extracted_colors == 0 then
        return "`0" .. trans_res
    end

    if #extracted_colors == 1 then
        return extracted_colors[1] .. trans_res
    end

    local clean_orig_text = tostring(orig_msg):gsub("`.", ""):gsub("%s+", "")
    local orig_len = math.max(1, #clean_orig_text)
    local density = #extracted_colors / orig_len

    if density >= 0.4 then
        local mapped_result = ""
        local color_index = 1
        for i = 1, #trans_res do
            local char_piece = trans_res:sub(i, i)
            if char_piece:match("%s") then
                mapped_result = mapped_result .. char_piece
            else
                mapped_result = mapped_result .. extracted_colors[color_index] .. char_piece
                color_index = (color_index % #extracted_colors) + 1
            end
        end
        return mapped_result
    else
        local mapped_words = {}
        local word_color_index = 1
        for word in trans_res:gmatch("%S+") do
            table.insert(mapped_words, extracted_colors[word_color_index] .. word)
            word_color_index = (word_color_index % #extracted_colors) + 1
        end
        return table.concat(mapped_words, " ")
    end
end

helpers.slave_netids = helpers.slave_netids or {}
helpers.hidden_slaves = helpers.hidden_slaves or {}

function helpers.IsSlaveName(name)
    if not name or name == "" then return false end
    local clean = tostring(name):gsub("`.", ""):lower()
    if clean:find("'s spammer slave", 1, true)
       or clean:find("spammer slave", 1, true)
       or clean:find("spammer_slave", 1, true)
       or clean:find("'s slave", 1, true) then
        return true
    end
    return false
end

function helpers.RemoveAllSlaves()
    local removed_count = 0
    local ok_p, plist = pcall(GetPlayerList)
    if ok_p and plist then
        for _, plr in pairs(plist) do
            if plr and plr.netid and plr.name then
                if helpers.IsSlaveName(plr.name) then
                    local nid = tonumber(plr.netid)
                    helpers.slave_netids[nid] = true

                    -- Save spawn data for instant restore if not already saved
                    if not helpers.hidden_slaves[nid] then
                        local px = (plr.pos and plr.pos.x) and math.floor(plr.pos.x) or 0
                        local py = (plr.pos and plr.pos.y) and math.floor(plr.pos.y) or 0
                        local puid = tonumber(plr.userid) or 1
                        local pname = tostring(plr.name or "Spawning...")
                        local pcountry = tostring(plr.country or "us")
                        local invis = (plr.invisible and 1) or 0
                        local mstate = (plr.mstate and 1) or 0
                        local smstate = (plr.smstate and 1) or 0
                        helpers.hidden_slaves[nid] = string.format("spawn|avatar\nnetID|%d\nuserID|%d\ncolrect|0|0|20|30\nposXY|%d|%d\nname|%s\ncountry|%s\ninvis|%d\nmstate|%d\nsmstate|%d",
                            nid, puid, px, py, pname, pcountry, invis, mstate, smstate)
                    end

                    SendVariantList({
                        [0] = "OnRemove",
                        [1] = "netID|" .. nid,
                        [2] = "pId|1"
                    }, -1)
                    removed_count = removed_count + 1
                end
            end
        end
    end
    return removed_count
end

function helpers.RestoreAllSlaves()
    local restored_count = 0
    if helpers.hidden_slaves then
        for nid, spawn_str in pairs(helpers.hidden_slaves) do
            if spawn_str and spawn_str ~= "" then
                local numeric_nid = tonumber(nid) or -1

                -- 1. Respawn avatar entity
                SendVariantList({
                    [0] = "OnSpawn",
                    [1] = spawn_str
                }, -1)

                -- 2. Restore clothing & default skin color
                SendVariantList({
                    [0] = "OnSetClothing",
                    [1] = { x = 0.0, y = 0.0, z = 0.0, 0, 0, 0 },
                    [2] = { x = 0.0, y = 0.0, z = 0.0, 0, 0, 0 },
                    [3] = { x = 0.0, y = 0.0, z = 0.0, 0, 0, 0 },
                    [4] = 2190853119,
                    [5] = { x = 0.0, y = 0.0, z = 0.0, 0, 0, 0 }
                }, numeric_nid)

                -- 3. Restore visibility (un-invis)
                SendVariantList({
                    [0] = "OnInvis",
                    [1] = 0
                }, numeric_nid)

                restored_count = restored_count + 1
            end
        end
    end
    helpers.hidden_slaves = {}
    helpers.slave_netids = {}
    return restored_count
end

function helpers.TranslateText(raw_text, target_lang)
    if not raw_text or raw_text == "" then return nil, nil end
    local target = (target_lang == "id") and "Indonesian" or "English"
    local target_code = (target_lang == "id") and "id" or "en"

    local clean_check = tostring(raw_text):gsub("`.", ""):gsub("^%s*(.-)%s*$", "%1")
    if clean_check == "" then return nil, nil end

    local cache_key = target_code .. ":" .. tostring(raw_text)
    local cached = get_from_cache(cache_key)
    if cached then
        return cached.text, cached.lang
    end

    local api_key = (config.translator and config.translator.api_key and config.translator.api_key ~= "")
        and config.translator.api_key
        or "AQ.Ab8RN6J1pArBA_ku1P2z_naW-to9tVCt7pvIQH0PT7t_Lg7SLw"

    local prompt_instruction = "Translate the following Growtopia in-game chat to " .. target .. ". CRITICAL RULES:\n"
        .. "1. Preserve all Growtopia color codes (e.g. `2, `8, `w, `4, `c, `p, `9, `b, `1, `3, `5, `6, `7, `0) attached to their translated words!\n"
        .. "2. If the text is already in " .. target .. ", output the original text unchanged.\n"
        .. "3. Output ONLY the translated text with color codes intact, no explanations, no quotes, no markdown:\n"
        .. tostring(raw_text)

    local escaped_prompt = helpers.EscapeJson(prompt_instruction)
    local payload = '{"contents":[{"parts":[{"text":"' .. escaped_prompt .. '"}]}],"generationConfig":{"temperature":0.1,"maxOutputTokens":200,"thinkingConfig":{"thinkingBudget":0}}}'

    local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=" .. api_key
    local headers = {
        ["Content-Type"] = "application/json",
        ["X-goog-api-key"] = api_key
    }

    local ok_req, resp = pcall(MakeRequest, url, "POST", headers, payload, 4000)
    if ok_req and resp and not resp.error and resp.content and resp.content ~= "" then
        local raw_text_part = extract_ai_text(resp.content)
        if raw_text_part and raw_text_part ~= "" then
            local translated_text = helpers.UnescapeJson(raw_text_part)
            if tostring(raw_text):find("`%S") and not translated_text:find("`%S") then
                translated_text = helpers.ApplyOriginalColorPattern(raw_text, translated_text)
            end

            local detected = nil
            local clean_res = translated_text:gsub("`.", ""):gsub("%s+", ""):lower()
            local clean_orig = tostring(raw_text):gsub("`.", ""):gsub("%s+", ""):lower()
            if clean_res == clean_orig then
                detected = target_code
            end

            put_in_cache(cache_key, translated_text, detected)
            return translated_text, detected
        end
    end

    -- Secondary Fallback: Alternative translator if primary AI fails or quota exceeded
    local ok_fb, fb_res, fb_det = pcall(function()
        local encoded_q = helpers.UrlEncode(clean_check)
        local fb_url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=" .. target_code .. "&dt=t&q=" .. encoded_q
        local fb_ok, fb_resp = pcall(MakeRequest, fb_url, "GET", { ["User-Agent"] = "Mozilla/5.0" }, "", 3000)
        if fb_ok and fb_resp and not fb_resp.error and fb_resp.content and fb_resp.content ~= "" then
            local primary_match = fb_resp.content:match('^%[%[%["(.-)",')
            if primary_match then
                local res_clean = primary_match:gsub('\\"', '"'):gsub('\\n', ' '):gsub('\\r', '')
                local colored = helpers.ApplyOriginalColorPattern(raw_text, res_clean)
                local det_lang = fb_resp.content:match('%],null,"([%a%-]+)"') or fb_resp.content:match(',"([%a%-]+)",null,null')
                return colored, det_lang
            end
        end
        return nil, nil
    end)
    if ok_fb and fb_res and fb_res ~= "" then
        put_in_cache(cache_key, fb_res, fb_det)
        return fb_res, fb_det
    end

    return nil, nil
end

function helpers.OpenTranslatorDialog()
    local tr = config.translator or {}
    local is_id = (tr.target_lang == "id")
    local is_out_id = (tr.outgoing_target_lang == "id")

    local dialog = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|`eTranslator``|left|14922|",
        "add_spacer|small|",
        "add_smalltext|`9Realtime intelligent chat translation engine with instant response.|left|",
        "add_spacer|small|",
        "add_checkbox|tr_enabled|`2Enable Incoming Chat Translator (Translate Others)|" .. (tr.enabled and 1 or 0) .. "|",
        "add_checkbox|tr_outgoing|`2Enable Outgoing Chat Translator (Translate My Chat)|" .. (tr.outgoing_enabled and 1 or 0) .. "|",
        "add_spacer|small|",
        "add_label_with_icon|small|`eIncoming Translation Target Language|left|1436|",
        "max_checks|1|",
        "add_checkbox|tr_lang_en|`3English `7(Translate other players to English)|" .. (is_id and 0 or 1) .. "|",
        "add_checkbox|tr_lang_id|`2Bahasa Indonesia `7(Translate other players to Indonesian)|" .. (is_id and 1 or 0) .. "|",
        "max_checks|9999|",
        "add_spacer|small|",
        "add_label_with_icon|small|`eOutgoing Translation Target Language|left|1436|",
        "max_checks|1|",
        "add_checkbox|tr_out_en|`3English `7(Translate my chat to English)|" .. (is_out_id and 0 or 1) .. "|",
        "add_checkbox|tr_out_id|`2Bahasa Indonesia `7(Translate my chat to Indonesian)|" .. (is_out_id and 1 or 0) .. "|",
        "max_checks|9999|",
        "add_spacer|small|",
        "add_label_with_icon|small|`eOutput & Filter Preferences|left|6128|",
        "add_checkbox|tr_show_bubble|`2Show Translated TalkBubble Over Player's Head|" .. (tr.show_bubble and 1 or 0) .. "|",
        "add_checkbox|tr_show_console|`2Log Translation to Chat Console|" .. (tr.show_console and 1 or 0) .. "|",
        "add_checkbox|tr_skip_same|`2Smart Skip (Do not re-translate if language matches)|" .. (tr.skip_same_lang and 1 or 0) .. "|",
        "add_checkbox|tr_filter_slave|`2Filter Spammer Slaves (Ignore spammer bots)|" .. ((tr.filter_slave ~= false) and 1 or 0) .. "|",
        "add_spacer|small|",
        "add_label_with_icon|small|`eAI Engine API Key Configuration|left|1000|",
        "add_text_input|tr_api_key|`2AI API Key:|" .. (tr.api_key or "") .. "|64|",
        "add_smalltext|`7Enter custom AI key for ultra-fast translation response|left|",
        "add_spacer|small|",
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_quick_exit||",
        "end_dialog|bglproxy_tr|Cancel|`2Save Settings|"
    }

    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

function helpers.HandleTranslatorDialogPacket(str)
    config.translator = config.translator or {}
    config.translator.enabled = (str:find("tr_enabled|1") ~= nil)
    config.translator.outgoing_enabled = (str:find("tr_outgoing|1") ~= nil)

    if str:find("tr_lang_id|1") then
        config.translator.target_lang = "id"
    else
        config.translator.target_lang = "en"
    end

    if str:find("tr_out_id|1") then
        config.translator.outgoing_target_lang = "id"
    else
        config.translator.outgoing_target_lang = "en"
    end

    config.translator.show_bubble = (str:find("tr_show_bubble|1") ~= nil)
    config.translator.show_console = (str:find("tr_show_console|1") ~= nil)
    config.translator.skip_same_lang = (str:find("tr_skip_same|1") ~= nil)
    config.translator.filter_slave = (str:find("tr_filter_slave|1") ~= nil)

    local key_val = str:match("tr_api_key|([^|\r\n]+)")
    if key_val and key_val ~= "" then
        config.translator.api_key = key_val:gsub("^%s*(.-)%s*$", "%1")
    end

    local in_status = config.translator.enabled and "`2ON (" .. config.translator.target_lang:upper() .. ")`e" or "`4OFF`e"
    local out_status = config.translator.outgoing_enabled and "`2ON (" .. config.translator.outgoing_target_lang:upper() .. ")`e" or "`4OFF`e"

    helpers.OnTextOverlay(config.branding .. " `eTranslator: Incoming " .. in_status .. " `eOutgoing " .. out_status)
    auto_save_config()
end

-- =========================== ROULETTE / CASINO GAMES LOGIC ===========================

function helpers.isReme(number)
    number = tonumber(number)
    if not number then return "", "" end

    local num1 = math.floor(number / 10)
    local num2 = number % 10
    local sum = num1 + num2
    local result = tostring(sum):sub(-1)

    if number == 19 or number == 28 or number == 0 then
        return "`2" .. result, "`b[`2 X3 `b]"
    elseif number == 29 or number == 10 or number == 1 then
        return "`4" .. result, "`b[`4 LOSE `b]"
    else
        return "`e" .. result, ""
    end
end

function helpers.isLeme(number)
    number = tonumber(number)
    if not number then return "", "" end

    local num1 = math.floor(number / 10)
    local num2 = number % 10
    local sum = num1 + num2
    local result = tostring(sum):sub(-1)

    if number == 19 or number == 28 or number == 0 then
        return "`20", "`b[`2 X4 `b]"
    elseif number == 1 or number == 29 or number == 10 then
        return "`2" .. result, "`b[`2 X3 `b]"
    elseif number == 11 or number == 2 or number == 20 or number == 9 or number == 27 or number == 36 or number == 18 then
        return "`4" .. result, "`b[`4 LOSE `b]"
    else
        return "`e" .. result, ""
    end
end

function helpers.isQeme(number)
    number = tonumber(number)
    if not number then return "", "" end

    local result = (number >= 10) and tostring(number):sub(-1) or tostring(number)

    if number == 0 or result == "1" then
        return "`4" .. result, "`b[`4 LOSE `b]"
    elseif number == 10 or number == 20 or number == 30 then
        return "`2" .. result, "`b[`2 X3 `b]"
    else
        return "`e" .. result, ""
    end
end

function helpers.isLewa(number)
    number = tonumber(number)
    if not number then return "", "" end

    local result = (number >= 10) and tostring(number):sub(-1) or tostring(number)

    if number == 0 then
        return "`4" .. result, "`b[`4 LOSE `b]"
    elseif number == 9 or number == 19 or number == 29 then
        return "`2" .. result, "`b[`2 X3 `b]"
    elseif number == 10 or number == 20 or number == 30 then
        return "`2" .. result, "`b[`2 X4 `b]"
    else
        return "`e" .. result, ""
    end
end

function helpers.isSleme(number)
    number = tonumber(number)
    if not number then return "", "" end

    local num1 = math.floor(number / 10)
    local num2 = number % 10
    local sum = num1 + num2
    local result = tostring(sum):sub(-1)

    if number == 19 or number == 28 then
        return "`20", "`b[`2 X5 `b]"
    elseif number == 1 or number == 29 or number == 10 then
        return "`2" .. result, "`b[`2 X3 `b]"
    elseif number == 11 or number == 2 or number == 20 or number == 9 or number == 27 or number == 36 or number == 18 or number == 3 or number == 12 or number == 30 or number == 21 or number == 0 then
        return "`4" .. result, "`b[`4 LOSE `b]"
    else
        return "`e" .. result, ""
    end
end

function helpers.isCeme(number)
    number = tonumber(number)
    if not number then return "", "" end

    local num1 = math.floor(number / 10)
    local num2 = number % 10
    local sum = num1 + num2
    local result = tostring(sum):sub(-1)

    if number == 19 or number == 28 or number == 0 then
        return "`20", "`b[`2 X4 `b]"
    elseif number == 1 or number == 29 or number == 10 or number == 2 or number == 11 or number == 20 then
        return "`2" .. result, "`b[`2 X3 `b]"
    elseif number == 21 or number == 12 or number == 3 or number == 30 then
        return "`4" .. result, "`b[`2 HOST WIN `b]"
    elseif number == 9 or number == 27 or number == 36 or number == 18 then
        return "`4" .. result, "`b[`4 LOSE `b]"
    else
        return "`e" .. result, ""
    end
end

function helpers.isHOL(number, playerKey)
    number = tonumber(number)
    if not number or not playerKey then return "", "" end

    if number == 0 then
        config.holSpins[playerKey] = {}
        return "`40", "`b[`4 LOSE `b]"
    end

    if not config.holSpins[playerKey] then
        config.holSpins[playerKey] = {}
    end

    local spins = config.holSpins[playerKey]
    table.insert(spins, number)
    if #spins > 3 then
        table.remove(spins, 1)
    end

    if #spins == 3 then
        local total = spins[1] + spins[2] + spins[3]
        config.holSpins[playerKey] = {}

        if total == 55 or total > 99 then
            return "`4" .. total, "`b[`4 LOSE `b]"
        elseif total >= 56 and total <= 99 then
            return "`2" .. total, "`b[`2 HIGH `b]"
        elseif total >= 1 and total <= 54 then
            return "`4" .. total, "`b[`4 LOW `b]"
        end
    end

    return "`e" .. number, "`0[" .. #spins .. "/3]"
end

local function coloredLabel(lbl)
    local colors = { "`e", "`c" }
    local parts = {}
    for i = 1, #lbl do
        parts[#parts + 1] = (colors[(i - 1) % #colors + 1]) .. lbl:sub(i, i)
    end
    return table.concat(parts)
end

function helpers.getGame(num, playerKey)
    local number = tonumber(num)
    if not number then return "" end

    local active_label = nil
    local result = ""
    local status = ""

    if config.leme then
        active_label = "LEME"
        result, status = helpers.isLeme(number)
    elseif config.reme then
        active_label = "REME"
        result, status = helpers.isReme(number)
    elseif config.qeme then
        active_label = "QEME"
        result, status = helpers.isQeme(number)
    elseif config.lewa then
        active_label = "LEWA"
        result, status = helpers.isLewa(number)
    elseif config.sleme then
        active_label = "SLEME"
        result, status = helpers.isSleme(number)
    elseif config.ceme then
        active_label = "CEME"
        result, status = helpers.isCeme(number)
    elseif config.hol then
        active_label = "HOL"
        result, status = helpers.isHOL(number, playerKey)
    end

    if not active_label then return "" end

    if status and status ~= "" then
        if status:find("WIN") or status:find("HIGH") or status:find("X") then
            status = status .. " `0(lol)`0"
        elseif status:find("LOSE") or status:find("LOW") then
            status = status .. " `0(cry)`0"
        end
    end

    return string.format("`b[%s: %s`b] %s", coloredLabel(active_label), result, status or "")
end

local function reset_all_games(except_key)
    local games = { "leme", "reme", "qeme", "lewa", "sleme", "ceme", "hol" }
    for _, g in ipairs(games) do
        if g ~= except_key then
            config[g] = false
        end
    end
end

-- =========================== SMART ENSURE & DROP ENGINE ===========================

function helpers.EnsureAutoBlackCount(required_count)
    local required = math.max(0, math.floor(tonumber(required_count) or 0))
    if required <= 0 then return true end

    local attempts = 0
    while (GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0) < required and attempts < 15 do
        local current_black = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
        local missing = required - current_black
        local have_bgl = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
        if have_bgl < (missing * 100) then
            break
        end
        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
        helpers.wait_lock_amount(ITEM_IDS.BLACK_GEM_LOCK, current_black + 1, 1000)
        attempts = attempts + 1
    end
    return (GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0) >= required
end

function helpers.BreakFromHigher(item_id)
    if item_id == ITEM_IDS.BLUE_GEM_LOCK then
        if (GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0) > 0 then
            local bgl_before = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
            helpers.wait_lock_amount(ITEM_IDS.BLUE_GEM_LOCK, bgl_before + 1, 1200)
            return true
        end

    elseif item_id == ITEM_IDS.DIAMOND_LOCK then
        if (GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0) > 0 then
            local dl_before = GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0
            helpers.OnWear(ITEM_IDS.BLUE_GEM_LOCK)
            helpers.wait_lock_amount(ITEM_IDS.DIAMOND_LOCK, dl_before + 1, 1000)
            return true
        end
        if (GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0) > 0 then
            local bgl_before = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
            helpers.wait_lock_amount(ITEM_IDS.BLUE_GEM_LOCK, bgl_before + 1, 1200)
            if (GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0) > 0 then
                Sleep(DELAYS.WEAR_DELAY)
                local dl_before = GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0
                helpers.OnWear(ITEM_IDS.BLUE_GEM_LOCK)
                helpers.wait_lock_amount(ITEM_IDS.DIAMOND_LOCK, dl_before + 1, 1000)
                return true
            end
        end

    elseif item_id == ITEM_IDS.WORLD_LOCK then
        if (GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0) > 0 then
            local wl_before = GetItemCount(ITEM_IDS.WORLD_LOCK) or 0
            helpers.OnWear(ITEM_IDS.DIAMOND_LOCK)
            helpers.wait_lock_amount(ITEM_IDS.WORLD_LOCK, wl_before + 1, 1000)
            return true
        end
        if (GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0) > 0 then
            local dl_before = GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0
            helpers.OnWear(ITEM_IDS.BLUE_GEM_LOCK)
            helpers.wait_lock_amount(ITEM_IDS.DIAMOND_LOCK, dl_before + 1, 1000)
            if (GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0) > 0 then
                Sleep(DELAYS.WEAR_DELAY)
                local wl_before = GetItemCount(ITEM_IDS.WORLD_LOCK) or 0
                helpers.OnWear(ITEM_IDS.DIAMOND_LOCK)
                helpers.wait_lock_amount(ITEM_IDS.WORLD_LOCK, wl_before + 1, 1000)
                return true
            end
        end
        if (GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0) > 0 then
            local bgl_before = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
            helpers.wait_lock_amount(ITEM_IDS.BLUE_GEM_LOCK, bgl_before + 1, 1200)
            if (GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0) > 0 then
                Sleep(DELAYS.WEAR_DELAY)
                local dl_before = GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0
                helpers.OnWear(ITEM_IDS.BLUE_GEM_LOCK)
                helpers.wait_lock_amount(ITEM_IDS.DIAMOND_LOCK, dl_before + 1, 1000)
                if (GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0) > 0 then
                    Sleep(DELAYS.WEAR_DELAY)
                    local wl_before = GetItemCount(ITEM_IDS.WORLD_LOCK) or 0
                    helpers.OnWear(ITEM_IDS.DIAMOND_LOCK)
                    helpers.wait_lock_amount(ITEM_IDS.WORLD_LOCK, wl_before + 1, 1000)
                    return true
                end
            end
        end
    end

    return false
end

function helpers.CombineFromLower(item_id)
    if item_id == ITEM_IDS.DIAMOND_LOCK then
        if (GetItemCount(ITEM_IDS.WORLD_LOCK) or 0) >= 100 then
            local dl_before = GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0
            helpers.OnWear(ITEM_IDS.WORLD_LOCK)
            helpers.wait_lock_amount(ITEM_IDS.DIAMOND_LOCK, dl_before + 1, 1000)
            return true
        end

    elseif item_id == ITEM_IDS.BLUE_GEM_LOCK then
        if (GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0) >= 100 then
            local ok_loc, player_pos = pcall(GetLocal)
            if ok_loc and player_pos and player_pos.pos then
                local closest, min_d = get_nearest_telephone(player_pos.pos)
                if closest and min_d <= 5 then
                    local bgl_before = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
                    SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" .. closest.x .. "|\ny|" .. closest.y .. "|\nbuttonClicked|bglconvert")
                    helpers.wait_lock_amount(ITEM_IDS.BLUE_GEM_LOCK, bgl_before + 1, 1200)
                    return true
                end
            end
        end

    elseif item_id == ITEM_IDS.BLACK_GEM_LOCK then
        if (GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0) >= 100 then
            local black_before = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
            helpers.wait_lock_amount(ITEM_IDS.BLACK_GEM_LOCK, black_before + 1, 1200)
            return true
        end
    end

    return false
end

function helpers.EnsureLockCount(item_id, required_count)
    local required = math.max(0, math.floor(tonumber(required_count) or 0))
    if required <= 0 then return true end

    if (GetItemCount(item_id) or 0) >= required then
        return true
    end

    local converted = false

    if item_id == ITEM_IDS.BLACK_GEM_LOCK then
        local black_before = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
        local ok = helpers.EnsureAutoBlackCount(required)
        if (GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0) > black_before then
            Sleep(200)
        end
        return ok
    end

    -- 1. Try combining lower locks first (e.g. WL >= 100 -> DL)
    local combine_attempts = 0
    while (GetItemCount(item_id) or 0) < required and combine_attempts < 10 do
        if not helpers.CombineFromLower(item_id) then
            break
        end
        converted = true
        combine_attempts = combine_attempts + 1
    end

    if (GetItemCount(item_id) or 0) >= required then
        if converted then Sleep(200) end
        return true
    end

    -- 2. Try breaking higher locks (e.g. Black -> BGL -> DL -> WL) with multi-attempt loop
    local break_attempts = 0
    while (GetItemCount(item_id) or 0) < required and break_attempts < 20 do
        if not helpers.BreakFromHigher(item_id) then
            break
        end
        converted = true
        break_attempts = break_attempts + 1
    end

    if converted then
        Sleep(200)
    end

    return (GetItemCount(item_id) or 0) >= required
end

function helpers.ExecuteDropWithVerify(item_id, amount)
    local target_amount = math.max(0, math.floor(tonumber(amount) or 0))
    if target_amount <= 0 then return 0 end

    local total_confirmed_dropped = 0
    local remaining = target_amount

    while remaining > 0 do
        local current_inv = GetItemCount(item_id) or 0
        if current_inv <= 0 then break end

        local chunk = math.min(remaining, math.min(current_inv, 100))
        if chunk <= 0 then break end

        local before_chunk = current_inv
        helpers.OnDroppedItem(item_id, chunk)

        -- Verification polling (up to 450ms, checking every 50ms)
        local confirmed = false
        local waited = 0
        while waited < 450 do
            Sleep(50)
            waited = waited + 50
            if (GetItemCount(item_id) or 0) <= (before_chunk - chunk) then
                confirmed = true
                break
            end
        end

        -- If not confirmed, 1x retry after brief buffer
        if not confirmed then
            Sleep(200)
            local after_wait = GetItemCount(item_id) or 0
            local still_to_drop = after_wait - (before_chunk - chunk)
            if still_to_drop > 0 then
                helpers.OnDroppedItem(item_id, math.min(still_to_drop, 100))
                local retry_waited = 0
                while retry_waited < 500 do
                    Sleep(50)
                    retry_waited = retry_waited + 50
                    if (GetItemCount(item_id) or 0) <= (before_chunk - chunk) then
                        confirmed = true
                        break
                    end
                end
            else
                confirmed = true
            end
        end

        local after_chunk = GetItemCount(item_id) or 0
        local dropped_in_chunk = math.max(0, before_chunk - after_chunk)
        if dropped_in_chunk > 0 then
            total_confirmed_dropped = total_confirmed_dropped + dropped_in_chunk
            remaining = remaining - dropped_in_chunk
            if remaining > 0 then
                Sleep(DELAYS.DROP_DELAY)
            end
        else
            -- Drop failed for this item (server rejected or lagged)
            break
        end
    end

    return total_confirmed_dropped
end

function helpers.DropWorldLock(count)
    if not count or count <= 0 then
        helpers.Say("`4Invalid amount!")
        return
    end

    RunThread(function()
        operation_flags.is_smart_dropping = true
        local dl = math.floor(count / 100)
        local wl = count % 100
        local bgl = math.floor(dl / 100)
        dl = dl % 100

        local have_bgl = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
        local have_black = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
        local have_dl = GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0
        local have_wl = GetItemCount(ITEM_IDS.WORLD_LOCK) or 0

        if (bgl > 0 or dl > 0) and (have_bgl == 0 and have_black == 0 and have_dl == 0) and have_wl >= count then
            bgl = 0
            dl = 0
            wl = count
        end

        local bgl_dropped = 0
        local dl_dropped = 0
        local wl_dropped = 0

        if bgl > 0 then
            if not helpers.EnsureLockCount(ITEM_IDS.BLUE_GEM_LOCK, bgl) then
                helpers.Say("`4Not enough BGL to drop!`0")
                operation_flags.is_smart_dropping = false
                return
            end
            bgl_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.BLUE_GEM_LOCK, bgl)
            if bgl_dropped > 0 and (dl > 0 or wl > 0) then
                Sleep(DELAYS.DROP_DELAY)
            end
        end

        if dl > 0 then
            if not helpers.EnsureLockCount(ITEM_IDS.DIAMOND_LOCK, dl) then
                helpers.Say("`4Not enough DL to drop!`0")
                operation_flags.is_smart_dropping = false
                return
            end
            dl_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.DIAMOND_LOCK, dl)
            if dl_dropped > 0 and wl > 0 then
                Sleep(DELAYS.DROP_DELAY)
            end
        end

        if wl > 0 then
            if not helpers.EnsureLockCount(ITEM_IDS.WORLD_LOCK, wl) then
                helpers.Say("`4Not enough WL to drop!`0")
                operation_flags.is_smart_dropping = false
                return
            end
            wl_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.WORLD_LOCK, wl)
        end

        local total_dropped = bgl_dropped + dl_dropped + wl_dropped
        if total_dropped == 0 then
            helpers.Say("`4Drop failed! Server lagged or blocked drop packet.`0")
            helpers.OnTextOverlay("`4Drop failed! No items dropped.")
            operation_flags.is_smart_dropping = false
            return
        end

        local msg = config.branding .. " `eDROPPED: "
        local drop_parts = {}
        if bgl_dropped > 0 then
            msg = msg .. "`0" .. bgl_dropped .. " `eBGL "
            table.insert(drop_parts, "**" .. bgl_dropped .. "** <:bgl:1556814259478855690> BGL")
        end
        if dl_dropped > 0 then
            msg = msg .. "`0" .. dl_dropped .. " `1DL "
            table.insert(drop_parts, "**" .. dl_dropped .. "** <:dl:1556814401695252560> DL")
        end
        if wl_dropped > 0 then
            msg = msg .. "`0" .. wl_dropped .. " `6WL "
            table.insert(drop_parts, "**" .. wl_dropped .. "** <:wl:1556814610420473946> WL")
        end
        msg = msg .. "`8(wl)"
        helpers.SayClean(msg)
        if #drop_parts > 0 then
            helpers.SendDropWebhook(table.concat(drop_parts, " "))
        end
        operation_flags.is_smart_dropping = false
    end)
end

function helpers.DropDiamondLock(count)
    if not count or count <= 0 then
        helpers.Say("`4Invalid amount!")
        return
    end

    RunThread(function()
        operation_flags.is_smart_dropping = true
        local bgl = math.floor(count / 100)
        local dl = count % 100

        local have_bgl = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
        local have_black = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
        local have_dl = GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0

        if bgl > 0 and (have_bgl == 0 and have_black == 0) and have_dl >= count then
            bgl = 0
            dl = count
        end

        local bgl_dropped = 0
        local dl_dropped = 0

        if bgl > 0 then
            if not helpers.EnsureLockCount(ITEM_IDS.BLUE_GEM_LOCK, bgl) then
                helpers.Say("`4Not enough BGL to drop!`0")
                operation_flags.is_smart_dropping = false
                return
            end
            bgl_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.BLUE_GEM_LOCK, bgl)
            if bgl_dropped > 0 and dl > 0 then
                Sleep(DELAYS.DROP_DELAY)
            end
        end

        if dl > 0 then
            if not helpers.EnsureLockCount(ITEM_IDS.DIAMOND_LOCK, dl) then
                helpers.Say("`4Still not enough DL to drop!`0")
                operation_flags.is_smart_dropping = false
                return
            end
            dl_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.DIAMOND_LOCK, dl)
        end

        local total_dropped = bgl_dropped + dl_dropped
        if total_dropped == 0 then
            helpers.Say("`4Drop failed! Server lagged or blocked drop packet.`0")
            helpers.OnTextOverlay("`4Drop failed! No items dropped.")
            operation_flags.is_smart_dropping = false
            return
        end

        local msg = config.branding .. " `eDROPPED: "
        local drop_parts = {}
        if bgl_dropped > 0 then
            msg = msg .. "`0" .. bgl_dropped .. " `eBGL "
            table.insert(drop_parts, "**" .. bgl_dropped .. "** <:bgl:1556814259478855690> BGL")
        end
        if dl_dropped > 0 then
            msg = msg .. "`0" .. dl_dropped .. " `1DL "
            table.insert(drop_parts, "**" .. dl_dropped .. "** <:dl:1556814401695252560> DL")
        end
        msg = msg .. "`8(wl)"
        helpers.SayClean(msg)
        if #drop_parts > 0 then
            helpers.SendDropWebhook(table.concat(drop_parts, " "))
        end
        operation_flags.is_smart_dropping = false
    end)
end

function helpers.DropBlueGemLock(count)
    if not count or count <= 0 then
        helpers.Say("`4Invalid amount!")
        return
    end

    RunThread(function()
        operation_flags.is_smart_dropping = true
        local black_needed = math.floor(count / 100)
        local bgl_needed = count % 100

        local have_black = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
        local have_bgl = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0

        if black_needed > 0 and (have_black == 0) and have_bgl >= count then
            black_needed = 0
            bgl_needed = count
        end

        local black_dropped = 0
        local bgl_dropped = 0

        if black_needed > 0 then
            if not helpers.EnsureLockCount(ITEM_IDS.BLACK_GEM_LOCK, black_needed) then
                helpers.Say("`4Not enough BLACK to drop!`0")
                operation_flags.is_smart_dropping = false
                return
            end
            black_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.BLACK_GEM_LOCK, black_needed)
            if black_dropped > 0 and bgl_needed > 0 then
                Sleep(DELAYS.DROP_DELAY)
            end
        end

        if bgl_needed > 0 then
            if not helpers.EnsureLockCount(ITEM_IDS.BLUE_GEM_LOCK, bgl_needed) then
                helpers.Say("`4Not enough BGL to drop!`0")
                operation_flags.is_smart_dropping = false
                return
            end
            bgl_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.BLUE_GEM_LOCK, bgl_needed)
        end

        local total_dropped = black_dropped + bgl_dropped
        if total_dropped == 0 then
            helpers.Say("`4Drop failed! Server lagged or blocked drop packet.`0")
            helpers.OnTextOverlay("`4Drop failed! No items dropped.")
            operation_flags.is_smart_dropping = false
            return
        end

        local msg = config.branding .. " `eDROPPED: "
        local drop_parts = {}
        if black_dropped > 0 then
            msg = msg .. "`0" .. black_dropped .. " `bBLACK "
            table.insert(drop_parts, "**" .. black_dropped .. "** <:black:1556814063449800804> BLACK")
        end
        if bgl_dropped > 0 then
            msg = msg .. "`0" .. bgl_dropped .. " `eBGL "
            table.insert(drop_parts, "**" .. bgl_dropped .. "** <:bgl:1556814259478855690> BGL")
        end
        msg = msg .. "`8(wl)"
        helpers.SayClean(msg)
        if #drop_parts > 0 then
            helpers.SendDropWebhook(table.concat(drop_parts, " "))
        end
        operation_flags.is_smart_dropping = false
    end)
end

function helpers.DropBlackLock(count)
    if not count or count <= 0 then
        helpers.Say("`4Invalid amount!")
        return
    end

    RunThread(function()
        operation_flags.is_smart_dropping = true

        if not helpers.EnsureLockCount(ITEM_IDS.BLACK_GEM_LOCK, count) then
            helpers.Say("`4Not enough BLACK to drop!`0")
            operation_flags.is_smart_dropping = false
            return
        end

        local black_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.BLACK_GEM_LOCK, count)
        if black_dropped == 0 then
            helpers.Say("`4Drop failed! Server lagged or blocked drop packet.`0")
            helpers.OnTextOverlay("`4Drop failed! No items dropped.")
            operation_flags.is_smart_dropping = false
            return
        end

        helpers.SayClean(config.branding .. " `eDROPPED: `0" .. black_dropped .. " `bBLACK `8(wl)")
        helpers.SendDropWebhook("**" .. black_dropped .. "** <:black:1556814063449800804> BLACK")
        operation_flags.is_smart_dropping = false
    end)
end

function helpers.DropAllLocks()
    RunThread(function()
        operation_flags.is_smart_dropping = true
        local black_count = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
        local bgl_count   = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
        local dl_count    = GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0
        local wl_count    = GetItemCount(ITEM_IDS.WORLD_LOCK) or 0

        if black_count == 0 and bgl_count == 0 and dl_count == 0 and wl_count == 0 then
            helpers.OnTextOverlay("`4No locks found in inventory!")
            helpers.OnConsoleMessage("`4No locks to drop!")
            operation_flags.is_smart_dropping = false
            return
        end

        local black_dropped = 0
        local bgl_dropped   = 0
        local dl_dropped    = 0
        local wl_dropped    = 0

        if black_count > 0 then
            black_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.BLACK_GEM_LOCK, black_count)
            if black_dropped > 0 and (bgl_count > 0 or dl_count > 0 or wl_count > 0) then
                Sleep(DELAYS.DROP_DELAY)
            end
        end
        if bgl_count > 0 then
            bgl_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.BLUE_GEM_LOCK, bgl_count)
            if bgl_dropped > 0 and (dl_count > 0 or wl_count > 0) then
                Sleep(DELAYS.DROP_DELAY)
            end
        end
        if dl_count > 0 then
            dl_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.DIAMOND_LOCK, dl_count)
            if dl_dropped > 0 and wl_count > 0 then
                Sleep(DELAYS.DROP_DELAY)
            end
        end
        if wl_count > 0 then
            wl_dropped = helpers.ExecuteDropWithVerify(ITEM_IDS.WORLD_LOCK, wl_count)
        end

        local total_dropped = black_dropped + bgl_dropped + dl_dropped + wl_dropped
        if total_dropped == 0 then
            helpers.Say("`4Drop failed! Server lagged or blocked drop packet.`0")
            helpers.OnTextOverlay("`4Drop failed! No items dropped.")
            operation_flags.is_smart_dropping = false
            return
        end

        local msg = config.branding .. " `eDROP ALL: "
        local drop_parts = {}
        if black_dropped > 0 then
            msg = msg .. "`0" .. black_dropped .. " `bBLACK "
            table.insert(drop_parts, "**" .. black_dropped .. "** <:black:1556814063449800804> BLACK")
        end
        if bgl_dropped > 0 then
            msg = msg .. "`0" .. bgl_dropped .. " `eBGL "
            table.insert(drop_parts, "**" .. bgl_dropped .. "** <:bgl:1556814259478855690> BGL")
        end
        if dl_dropped > 0 then
            msg = msg .. "`0" .. dl_dropped .. " `1DL "
            table.insert(drop_parts, "**" .. dl_dropped .. "** <:dl:1556814401695252560> DL")
        end
        if wl_dropped > 0 then
            msg = msg .. "`0" .. wl_dropped .. " `6WL "
            table.insert(drop_parts, "**" .. wl_dropped .. "** <:wl:1556814610420473946> WL")
        end

        msg = msg .. "`8(wl)"
        helpers.SayClean(msg)
        helpers.OnTextOverlay("`eDropped All Locks!")
        if #drop_parts > 0 then
            helpers.SendDropWebhook(table.concat(drop_parts, " "))
        end
        operation_flags.is_smart_dropping = false
    end)
end

-- =========================== LOCK CONVERSIONS (/blue & /black) ===========================

function helpers.ConvertBlackToBlue()
    RunThread(function()
        local black_count = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
        if black_count < 1 then
            helpers.OnConsoleMessage("`4Not enough BLACK! Need at least 1 BLACK.")
            helpers.OnTextOverlay("`4Not enough BLACK! Need at least 1 BLACK.")
            return
        end
        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
        helpers.Say("`2Successfully Converted `b1 BLACK `e-> `e100 BGL")
        helpers.OnConsoleMessage("`2Converted `b1 BLACK `e-> `e100 BGL.")
    end)
end

function helpers.ConvertBlueToBlack()
    RunThread(function()
        local bgl_count = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
        if bgl_count < 100 then
            helpers.OnConsoleMessage("`4Not enough BGL! Need at least 100 BGL.")
            helpers.OnTextOverlay("`4Not enough BGL! Need at least 100 BGL.")
            return
        end
        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
        helpers.Say("`2Successfully Converted `e100 BGL `e-> `b1 BLACK")
        helpers.OnConsoleMessage("`2Converted `e100 BGL `e-> `b1 BLACK.")
    end)
end

-- =========================== BGL BANK (Deposit & Withdraw) ===========================

function helpers.DepositBank(amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return end

    SendPacket(2, "action|dialog_return\ndialog_name|bank_deposit\nbgl_count|" .. amount .. "\n")

    local black = math.floor(amount / 100)
    local bgl = amount % 100
    local msg_parts = {}
    if black > 0 then table.insert(msg_parts, "`b" .. black .. " BLACK`e") end
    if bgl > 0 then table.insert(msg_parts, "`e" .. bgl .. " BGL`e") end

    local final_msg = "`eDeposited " .. table.concat(msg_parts, " ") .. " to bank."
    helpers.Say(final_msg)
end

function helpers.WithdrawBank(amount)
    amount = tonumber(amount) or 0
    if amount <= 0 then return end

    SendPacket(2, "action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|" .. amount .. "\n")

    local black = math.floor(amount / 100)
    local bgl = amount % 100
    local msg_parts = {}
    if black > 0 then table.insert(msg_parts, "`b" .. black .. " BLACK`e") end
    if bgl > 0 then table.insert(msg_parts, "`e" .. bgl .. " BGL`e") end

    local final_msg = "`eWithdrawn " .. table.concat(msg_parts, " ") .. " from bank."
    helpers.Say(final_msg)
end

-- =========================== AUTO COLLECT & COMBINE ===========================

function helpers.AutoCombineCollectedLocks()
    if not config.autocombine then return end

    RunThread(function()
        -- Wait 400ms for GT client inventory sync
        Sleep(400)

        -- 1. Check WL -> DL
        local wl_count = GetItemCount(ITEM_IDS.WORLD_LOCK) or 0
        if wl_count >= 100 then
            local dl_before = GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0
            helpers.OnWear(ITEM_IDS.WORLD_LOCK)
            helpers.wait_lock_amount(ITEM_IDS.DIAMOND_LOCK, dl_before + 1, 1500)
        end

        -- 2. Check DL -> BGL (Telephone convert if nearby <= 5 tiles)
        local dl_count = GetItemCount(ITEM_IDS.DIAMOND_LOCK) or 0
        if dl_count >= 100 then
            local ok_loc, player_pos = pcall(GetLocal)
            if ok_loc and player_pos and player_pos.pos then
                local closest, min_d = get_nearest_telephone(player_pos.pos)
                if closest and min_d <= 5 then
                    local bgl_before = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
                    operation_flags.is_converting_dl = true
                    SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" .. closest.x .. "|\ny|" .. closest.y .. "|\nbuttonClicked|bglconvert")
                    helpers.wait_lock_amount(ITEM_IDS.BLUE_GEM_LOCK, bgl_before + 1, 1500)
                    operation_flags.is_converting_dl = false
                end
            end
        end

        -- 3. Check BGL -> Black
        local bgl_count = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
        if bgl_count >= 100 then
            local black_before = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
            helpers.wait_lock_amount(ITEM_IDS.BLACK_GEM_LOCK, black_before + 1, 1500)
        end
    end)
end

function helpers.BufferCollectedItem(item_type, amount)
    local count_num = tonumber(amount) or 0
    if count_num <= 0 then return end

    operation_flags.collect_timer_token = operation_flags.collect_timer_token + 1
    local current_token = operation_flags.collect_timer_token

    if item_type == "black" then
        operation_flags.collect_buffer.black = operation_flags.collect_buffer.black + count_num
    elseif item_type == "bgl" then
        operation_flags.collect_buffer.bgl = operation_flags.collect_buffer.bgl + count_num
    elseif item_type == "dl" then
        operation_flags.collect_buffer.dl = operation_flags.collect_buffer.dl + count_num
    elseif item_type == "wl" then
        operation_flags.collect_buffer.wl = operation_flags.collect_buffer.wl + count_num
    end

    RunThread(function(token)
        Sleep(500)
        if token ~= operation_flags.collect_timer_token then
            return
        end

        local buf = operation_flags.collect_buffer
        local parts = {}

        if buf.black > 0 then table.insert(parts, "`b" .. buf.black .. " BLACK`0") end
        if buf.bgl > 0 then table.insert(parts, "`e" .. buf.bgl .. " BGL`0") end
        if buf.dl > 0 then table.insert(parts, "`1" .. buf.dl .. " DL`0") end
        if buf.wl > 0 then table.insert(parts, "`6" .. buf.wl .. " WL`0") end

        if #parts > 0 then
            local combined = table.concat(parts, ", ")
            helpers.OnConsoleMessage("`eCollected `0" .. combined)
            helpers.OnTextOverlay("`eCollected `0" .. combined)
        end

        operation_flags.collect_buffer = { black = 0, bgl = 0, dl = 0, wl = 0 }
        helpers.AutoCombineCollectedLocks()
    end, current_token)
end

-- =========================== EXACT CALCULATOR ENGINE (ExProxy Match) ===========================

function helpers.Calculator()
    local usage = "`9Usage: `0/calcu 28x28 `7| `0/calcu 12.5x5.2 `7| `0/calcu 12,5x5,2"
    helpers.OnTextOverlay("`eCalculator: `0Use /calcu with expression.")
    helpers.OnConsoleMessage(usage)
end

function helpers.ParseCalcuNumber(raw)
    local text = tostring(raw or ""):gsub("%s+", "")
    if text == "" or not text:match("^%d[%d%.,]*$") then
        return nil
    end

    local dot_count = select(2, text:gsub("%.", ""))
    local comma_count = select(2, text:gsub(",", ""))

    if dot_count > 0 and comma_count > 0 then
        local last_dot = text:match(".*()%.")
        local last_comma = text:match(".*(),")
        if last_dot and last_comma then
            if last_dot > last_comma then
                text = text:gsub(",", "")
            else
                text = text:gsub("%.", "")
                text = text:gsub(",", ".")
            end
        end
    elseif comma_count > 0 then
        local left, right = text:match("^(%d+),(%d+)$")
        if comma_count == 1 and left and right then
            if #right == 3 and #left <= 3 then
                text = left .. right
            else
                text = left .. "." .. right
            end
        else
            text = text:gsub(",", "")
        end
    elseif dot_count > 0 then
        local left, right = text:match("^(%d+)%.(%d+)$")
        if dot_count == 1 and left and right then
            if #right == 3 and #left <= 3 then
                text = left .. right
            else
                text = left .. "." .. right
            end
        else
            text = text:gsub("%.", "")
        end
    end

    return tonumber(text)
end

function helpers.HandleCalculatorCommand(args)
    local expr = tostring(args or ""):gsub("^%s+", ""):gsub("%s+$", "")

    if expr == "" then
        helpers.Calculator()
        return
    end

    local left_raw, operator_raw, right_raw = expr:match("^([%d%.,%s]+)([%+%-%*/xX])([%d%.,%s]+)$")
    if not left_raw or not operator_raw or not right_raw then
        helpers.OnTextOverlay("`4Invalid /calcu expression!")
        helpers.OnConsoleMessage("`4Usage: `0/calcu 28x28 `7| `0/calcu 12.5x5.2 `7| `0/calcu 12,5x5,2")
        return
    end

    local num1 = helpers.ParseCalcuNumber(left_raw)
    local num2 = helpers.ParseCalcuNumber(right_raw)
    if not num1 or not num2 then
        helpers.OnTextOverlay("`4Error: Invalid number format!")
        helpers.OnConsoleMessage("`4Calculator accepts decimal or thousands separators with `0. `4or `0,")
        return
    end

    local operator = operator_raw
    local result = 0

    if operator_raw == "+" then
        result = num1 + num2
    elseif operator_raw == "-" then
        result = num1 - num2
    elseif operator_raw == "/" then
        operator = "/"
        if num2 == 0 then
            helpers.OnTextOverlay("`4Cannot divide by zero!")
            helpers.OnConsoleMessage("`4Calculator division by zero is not allowed.")
            return
        end
        result = num1 / num2
    else
        operator = "x"
        result = num1 * num2
    end

    local formatted_msg = "`e[Calcu] `0" .. helpers.FormatNumber(num1) .. " " .. operator .. " " .. helpers.FormatNumber(num2) .. " `7= `2" .. helpers.FormatNumber(result)
    helpers.Say(formatted_msg)
    helpers.OnTextOverlay("`e[Calcu] `0" .. helpers.FormatNumber(num1) .. " " .. operator .. " " .. helpers.FormatNumber(num2) .. " = `2" .. helpers.FormatNumber(result))
    helpers.OnConsoleMessage(formatted_msg)
end

-- =========================== EXACT INVENTORY PARSER (ExProxy Match) ===========================

local function parse_inventory_summary_from_dialog(dialog)
    local text = tostring(dialog or "")
    if text == "" then
        return nil
    end

    local playername = text:match("|big|.-([^|]+)'s Inventory")
    if not playername then
        playername = text:match("([^|]+)'s Inventory") or "Unknown"
    end
    playername = playername:gsub("`.", ""):gsub("^%s+", ""):gsub("%s+$", "")

    local bglbank = parse_dialog_number(text:match("Blue Gem Locks in the Bank:.-([%d,]+)"))
    local blackgl_count = 0
    local bgl_count = 0
    local dl_count = 0
    local wl_count = 0
    local champ_count = 0

    for line in text:gmatch("[^\n]+") do
        if line:find("Black", 1, true) and line:find("|11550|", 1, true) then
            blackgl_count = parse_dialog_number(line:match("|11550|([%d,]+)"))
        elseif line:find("Blue", 1, true) and line:find("|7188|", 1, true) then
            bgl_count = parse_dialog_number(line:match("|7188|([%d,]+)"))
        elseif line:find("Diamond", 1, true) and line:find("|1796|", 1, true) then
            dl_count = parse_dialog_number(line:match("|1796|([%d,]+)"))
        elseif line:find("World", 1, true) and line:find("|242|", 1, true) then
            wl_count = parse_dialog_number(line:match("|242|([%d,]+)"))
        elseif line:find("Champagne", 1, true) then
            local guessed = parse_dialog_number(line:match("|%d+|([%d,]+)"))
            if guessed > champ_count then
                champ_count = guessed
            end
        end
    end

    local bgl_total = bgl_count + bglbank
    local total_modal_wl = wl_count + (dl_count * 100) + (bgl_total * 10000) + (blackgl_count * 1000000)

    local total_blackgl = blackgl_count + math.floor(bgl_total / 100) + math.floor(dl_count / 10000) + math.floor(wl_count / 1000000)
    local remaining_bgl = bgl_total % 100
    local total_bgl = remaining_bgl + math.floor(dl_count / 100) + math.floor(wl_count / 10000)
    local remaining_dl = dl_count % 100
    local total_dl = remaining_dl + math.floor(wl_count / 100)
    local remaining_wl = wl_count % 100

    return {
        playername     = playername,
        blackgl_count  = blackgl_count,
        bgl_count      = bgl_total,
        bgl_bag        = bgl_count,
        bgl_bank       = bglbank,
        dl_count       = dl_count,
        wl_count       = wl_count,
        champ_count    = champ_count,
        total_blackgl  = total_blackgl,
        total_bgl      = total_bgl,
        total_dl       = total_dl,
        remaining_wl   = remaining_wl,
        total_modal_wl = total_modal_wl
    }
end

local function format_inventory_balance_message(summary)
    return " `0" .. summary.playername
        .. " `eBalance: `aBLACK " .. summary.total_blackgl
        .. " `eBGL " .. summary.total_bgl
        .. " `1DL " .. summary.total_dl
        .. " `6WL " .. summary.remaining_wl
        .. " `tCHAMP: " .. summary.champ_count
end

-- =========================== CUSTOM COMMAND DIALOG ===========================

function helpers.CustomCommandDialog()
    local dialog = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|" .. config.branding .. " `eCustom Drop Triggers``|left|242|",
        "add_spacer|small|",
        "add_smalltext|`9Customize your custom shortcut prefix commands for dropping locks instantly.|left|",
        "add_smalltext|`9How to use: Type `2/<cmd> <amount>`9 in chat (e.g. `2/" .. config.cmd_drop_wl .. " 50`9 drops 50 WL).|left|",
        "add_smalltext|`9Multipliers: Type `2/<cmd>2 10`9 to drop double (e.g. `2/" .. config.cmd_drop_wl .. "2 10`9 = 20 WL).|left|",
        "add_spacer|small|",

        "add_label_with_icon|small|`6World Lock (WL) Drop Command|left|242|",
        "add_text_input|cmd_wl|Prefix :|" .. config.cmd_drop_wl .. "|10|",
        "add_spacer|small|",

        "add_label_with_icon|small|`1Diamond Lock (DL) Drop Command|left|1796|",
        "add_text_input|cmd_dl|Prefix :|" .. config.cmd_drop_dl .. "|10|",
        "add_spacer|small|",

        "add_label_with_icon|small|`cBlue Gem Lock (BGL) Drop Command|left|7188|",
        "add_text_input|cmd_bgl|Prefix :|" .. config.cmd_drop_bgl .. "|10|",
        "add_spacer|small|",

        "add_label_with_icon|small|`bBlack Gem Lock (BLACK) Drop Command|left|11550|",
        "add_text_input|cmd_black|Prefix :|" .. config.cmd_drop_black .. "|10|",
        "add_spacer|small|",

        "add_label_with_icon|small|`eConfiguration Rules|left|3494|",
        "add_smalltext|`4• `7Do NOT include the slash (`0/`7) in the box; it is added automatically.|left|",
        "add_smalltext|`4• `7Each command trigger must be unique and contain no spaces or symbols.|left|",
        "add_spacer|small|",

        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_quick_exit||",
        "end_dialog|custom_cmd_dialog|Cancel|`2Save Changes|"
    }
    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

-- =========================== DIALOG BUILDERS ===========================

function helpers.OpenProxyDialog()
    local role_str = (whitelist_state.role == "HOSTER" and "HOSTER") or ((whitelist_state.role == "BYPASS" and "OWNER / BYPASS") or "WORKER")
        local role_col = (whitelist_state.role == "HOSTER" and "`^") or ((whitelist_state.role == "BYPASS" and "`4") or "`2")
        local auth_obj = whitelist_state.authorized_user or whitelist_state.authorized_worker
        local auth_name = tostring((auth_obj and auth_obj.growId) or "Authorized")
        local auth_uid = tostring((auth_obj and auth_obj.userId) or "Verified")

        local dialog = {
            "set_default_color|" .. config.dialogDefaultColor,
            "set_border_color|" .. config.dialogBorder,
            "set_bg_color|" .. config.dialogBg,
            "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
            "add_label_with_icon|small|`eDODGED `9Automation Proxy``|left|11550|",
            "add_spacer|small|",
            "add_small_font_button|btn_open_menu|`eCommand Menu|noflags|0|0|",
            "add_small_font_button|btn_open_options|`eToggle Options|noflags|0|0|",
            "add_small_font_button|btn_open_wrm|`eWrench Menu|noflags|0|0|",
            "add_small_font_button|btn_open_hotkey|`eHotkey Manager|noflags|0|0|",
            "add_small_font_button|btn_open_gui|`cDashboard & Dev (F1)|noflags|0|0|",
            "add_small_font_button|btn_open_spam|`eAuto Spam (/spam)|noflags|0|0|",
            "add_spacer|small|",
            "add_label_with_icon|small|`eDODGED Account Information|left|5016|",
            "add_spacer|small|",
            "add_smalltext|`9Proxy ini dikhususkan untuk `eWorker, Hoster & Owner DODGED`9.|left|",
            "add_smalltext|`9Digunakan untuk otomatisasi drop, modal, champ, donasi, storage, dan bot Discord.|left|",
            "add_smalltext|`9Role: " .. role_col .. role_str .. " `7• `0Name: `2" .. auth_name .. " `7(UID: `e" .. auth_uid .. "`7)|left|",
        "add_spacer|small|",
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_quick_exit||",
        "end_dialog|bglproxy_main|Close||"
    }
    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

-- =========================== MODERN IMGUI DASHBOARD & DEV PANEL ===========================

-- Safe ImGui Flags & Enum Fallbacks (BotHax Environment Compatibility)
local ImGuiWindowFlags_NoCollapse = (type(rawget(_G, "ImGuiWindowFlags_NoCollapse")) == "number") and _G.ImGuiWindowFlags_NoCollapse or 32
local ImGuiCond_FirstUseEver = (type(rawget(_G, "ImGuiCond_FirstUseEver")) == "number") and _G.ImGuiCond_FirstUseEver or 4
local ImGuiCol_Text = (type(rawget(_G, "ImGuiCol_Text")) == "number") and _G.ImGuiCol_Text or 0
local ImGuiCol_Button = (type(rawget(_G, "ImGuiCol_Button")) == "number") and _G.ImGuiCol_Button or 21
local ImGuiTableFlags_RowBg = (type(rawget(_G, "ImGuiTableFlags_RowBg")) == "number") and _G.ImGuiTableFlags_RowBg or 64
local ImGuiTableFlags_Borders = (type(rawget(_G, "ImGuiTableFlags_Borders")) == "number") and _G.ImGuiTableFlags_Borders or 1920
local DEFAULT_TABLE_FLAGS = ImGuiTableFlags_Borders + ImGuiTableFlags_RowBg

local GUI_STATE = {
    open = false,
    tab = 0,
    worker_page = 1,
    worker_per_page = 6,
    worker_search = "",
    selected_worker = nil,
    hoster_page = 1,
    hoster_per_page = 6,
    hoster_search = "",
    selected_hoster = nil,
    log_page = 1,
    log_per_page = 8,
    log_search = "",
    log_filter = 0,
    api_stats = {
        totalModalBgl = 0,
        totalChamp = 0,
        activeWorkers = 0,
        activeHosters = 0,
        totalSetors = 0,
        last_updated = 0
    },
    api_logs = {},
    api_status = "Ready",
    api_status_color = ImVec4(0.2, 0.9, 0.2, 1.0),
    is_syncing = false,
    dev_packet_input = "action|input\n|text|Hello from Dodged\n",
    dev_last_action_msg = "",
    last_toggle_time = 0,
    show_raw_threads = false
}

local GUI_LOCAL_LOGS = {}
local MAX_LOCAL_LOGS = 100

function helpers.AddDevLog(cat, msg)
    local entry = {
        time = os.date("%H:%M:%S"),
        type = tostring(cat or "SYSTEM"):upper(),
        detail = tostring(msg or ""),
        user = "Local"
    }
    table.insert(GUI_LOCAL_LOGS, 1, entry)
    if #GUI_LOCAL_LOGS > MAX_LOCAL_LOGS then
        table.remove(GUI_LOCAL_LOGS)
    end
end

local function filter_and_paginate(items, search_term, page, per_page, search_fields)
    local filtered = {}
    local query = tostring(search_term or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    for _, item in ipairs(items) do
        if query == "" then
            table.insert(filtered, item)
        else
            local matched = false
            for _, field in ipairs(search_fields) do
                local val = tostring(item[field] or ""):lower()
                if val:find(query, 1, true) then
                    matched = true
                    break
                end
            end
            if matched then
                table.insert(filtered, item)
            end
        end
    end
    local total_items = #filtered
    local total_pages = math.max(1, math.ceil(total_items / per_page))
    local cur_page = math.max(1, math.min(page, total_pages))
    local start_idx = (cur_page - 1) * per_page + 1
    local end_idx = math.min(start_idx + per_page - 1, total_items)
    local page_items = {}
    for i = start_idx, end_idx do
        table.insert(page_items, filtered[i])
    end
    return page_items, cur_page, total_pages, total_items
end

local function render_pagination(id_suffix, current_page, total_pages, on_change)
    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()
    local prev_disabled = (current_page <= 1)
    if prev_disabled then
        ImGui.PushStyleColor(ImGuiCol_Button, ImVec4(0.2, 0.2, 0.2, 0.4))
        ImGui.PushStyleColor(ImGuiCol_Text, ImVec4(0.5, 0.5, 0.5, 1.0))
    end
    if ImGui.Button("< Prev##" .. id_suffix, ImVec2(75, 26)) and not prev_disabled then
        on_change(current_page - 1)
    end
    if prev_disabled then
        ImGui.PopStyleColor(2)
    end

    ImGui.SameLine()
    ImGui.Text(string.format("  Page %d of %d  ", current_page, total_pages))
    ImGui.SameLine()

    local next_disabled = (current_page >= total_pages)
    if next_disabled then
        ImGui.PushStyleColor(ImGuiCol_Button, ImVec4(0.2, 0.2, 0.2, 0.4))
        ImGui.PushStyleColor(ImGuiCol_Text, ImVec4(0.5, 0.5, 0.5, 1.0))
    end
    if ImGui.Button("Next >##" .. id_suffix, ImVec2(75, 26)) and not next_disabled then
        on_change(current_page + 1)
    end
    if next_disabled then
        ImGui.PopStyleColor(2)
    end
end

function helpers.SyncDashboardData()
    if GUI_STATE.is_syncing then return end
    GUI_STATE.is_syncing = true
    GUI_STATE.api_status = "Syncing..."
    GUI_STATE.api_status_color = ImVec4(0.95, 0.77, 0.15, 1.0)

    RunThread(function()
        helpers.FetchWorkerWhitelist()

        local base_url = config.api_url or "http://154.12.118.154:1088"
        if type(MakeRequest) == "function" then
            local ok_s, res_s = pcall(MakeRequest, base_url .. "/api/stats", "GET", { ["User-Agent"] = "DodgedProxy/1.0" }, "", 3000)
            if ok_s and res_s and res_s.content and not res_s.error then
                local bgl = res_s.content:match('"totalModalBgl"%s*:%s*([%d%.]+)')
                local chp = res_s.content:match('"totalChamp"%s*:%s*(%d+)')
                local wrk = res_s.content:match('"activeWorkers"%s*:%s*(%d+)')
                local hst = res_s.content:match('"activeHosters"%s*:%s*(%d+)')
                local str = res_s.content:match('"totalSetors"%s*:%s*(%d+)')
                if bgl or chp or wrk then
                    GUI_STATE.api_stats.totalModalBgl = tonumber(bgl) or 0
                    GUI_STATE.api_stats.totalChamp = tonumber(chp) or 0
                    GUI_STATE.api_stats.activeWorkers = tonumber(wrk) or 0
                    GUI_STATE.api_stats.activeHosters = tonumber(hst) or 0
                    GUI_STATE.api_stats.totalSetors = tonumber(str) or 0
                    GUI_STATE.api_stats.last_updated = os.time()
                end
            end

            local ok_l, res_l = pcall(MakeRequest, base_url .. "/api/logs", "GET", { ["User-Agent"] = "DodgedProxy/1.0" }, "", 3000)
            if ok_l and res_l and res_l.content and not res_l.error then
                local logs_section = res_l.content:match('"logs"%s*:%s*%[(.-)%]')
                if logs_section then
                    local fetched = {}
                    for item in logs_section:gmatch("%b{}") do
                        local l_type = item:match('"type"%s*:%s*"([^"]+)"') or "LOG"
                        local l_user = item:match('"user"%s*:%s*"([^"]+)"') or "-"
                        local l_detail = item:match('"detail"%s*:%s*"([^"]+)"') or ""
                        local l_time = item:match('"time"%s*:%s*"([^"]+)"') or "-"
                        table.insert(fetched, {
                            type = l_type,
                            user = l_user,
                            detail = l_detail,
                            time = l_time
                        })
                    end
                    if #fetched > 0 then
                        GUI_STATE.api_logs = fetched
                    end
                end
            end
            GUI_STATE.api_status = "Online (Ready)"
            GUI_STATE.api_status_color = ImVec4(0.2, 0.9, 0.2, 1.0)
        else
            GUI_STATE.api_status = "MakeRequest Offline"
            GUI_STATE.api_status_color = ImVec4(0.9, 0.2, 0.2, 1.0)
        end
        GUI_STATE.is_syncing = false
    end)
end

function helpers.ToggleGui()
    GUI_STATE.open = not GUI_STATE.open
    if GUI_STATE.open then
        helpers.SyncDashboardData()
        helpers.AddDevLog("SYSTEM", "ImGui Dashboard dibuka")
    end
end

local function render_workers_tab()
    ImGui.TextColored(ImVec4(0.2, 0.8, 1.0, 1.0), "Daftar Worker Terdaftar di Database")
    ImGui.Spacing()

    ImGui.Text("Cari Worker:")
    ImGui.SameLine()
    ImGui.PushItemWidth(200)
    local s_ch, s_txt = ImGui.InputText("##workerSearch", GUI_STATE.worker_search, 40)
    if s_ch then
        GUI_STATE.worker_search = s_txt
        GUI_STATE.worker_page = 1
    end
    ImGui.PopItemWidth()
    ImGui.SameLine()
    if ImGui.SmallButton("Reset##wrkReset") then
        GUI_STATE.worker_search = ""
        GUI_STATE.worker_page = 1
    end

    local worker_list = {}
    if whitelist_state.workers then
        for uid, w in pairs(whitelist_state.workers) do
            table.insert(worker_list, {
                growId = w.growId or "Worker",
                userId = tostring(uid),
                role = w.role or "WORKER",
                threadModal = w.threadModal or "-",
                threadChamp = w.threadChamp or "-",
                threadSetor = w.threadSetor or "-",
                threadDrop = w.threadDrop or "-",
                threadDonation = w.threadDonation or "-",
                threadStorage = w.threadStorage or "-"
            })
        end
    end
    table.sort(worker_list, function(a, b) return a.growId:lower() < b.growId:lower() end)

    local page_items, cur_page, total_pages, total_count = filter_and_paginate(
        worker_list,
        GUI_STATE.worker_search,
        GUI_STATE.worker_page,
        GUI_STATE.worker_per_page,
        {"growId", "userId"}
    )
    GUI_STATE.worker_page = cur_page

    ImGui.SameLine()
    ImGui.TextColored(ImVec4(0.7, 0.7, 0.7, 1.0), string.format("| Total: %d Worker", total_count))

    ImGui.Spacing()

    local table_flags = DEFAULT_TABLE_FLAGS
    if ImGui.BeginTable("WorkerTable", 5, table_flags) then
        ImGui.TableSetupColumn("#", 0, 30)
        ImGui.TableSetupColumn("GrowID", 0, 140)
        ImGui.TableSetupColumn("User ID", 0, 100)
        ImGui.TableSetupColumn("Threads Log", 0, 160)
        ImGui.TableSetupColumn("Action", 0, 120)
        ImGui.TableHeadersRow()

        if #page_items == 0 then
            ImGui.TableNextRow()
            ImGui.TableSetColumnIndex(1)
            ImGui.TextColored(ImVec4(0.8, 0.5, 0.2, 1.0), "Tidak ada data worker.")
        else
            for idx, w in ipairs(page_items) do
                local global_idx = (cur_page - 1) * GUI_STATE.worker_per_page + idx
                ImGui.TableNextRow()

                ImGui.TableSetColumnIndex(0)
                ImGui.Text(tostring(global_idx))

                ImGui.TableSetColumnIndex(1)
                ImGui.TextColored(ImVec4(0.3, 0.9, 0.4, 1.0), w.growId)

                ImGui.TableSetColumnIndex(2)
                ImGui.Text(w.userId)

                ImGui.TableSetColumnIndex(3)
                local has_th = (w.threadSetor ~= "-" and w.threadSetor ~= "") or (w.threadModal ~= "-" and w.threadModal ~= "")
                if has_th then
                    ImGui.TextColored(ImVec4(0.4, 0.8, 1.0, 1.0), "Tersedia")
                else
                    ImGui.TextColored(ImVec4(0.6, 0.6, 0.6, 1.0), "-")
                end

                ImGui.TableSetColumnIndex(4)
                if ImGui.SmallButton("Copy UID##w" .. w.userId) then
                    if type(ImGui.SetClipboardText) == "function" then
                        ImGui.SetClipboardText(w.userId)
                        helpers.OnTextOverlay("`2Copied UID: " .. w.userId)
                    end
                end
                ImGui.SameLine()
                if ImGui.SmallButton("Info##w" .. w.userId) then
                    GUI_STATE.selected_worker = w
                end
            end
        end
        ImGui.EndTable()
    end

    if GUI_STATE.selected_worker then
        local sw = GUI_STATE.selected_worker
        ImGui.Spacing()
        ImGui.SeparatorText("Detail Worker: " .. sw.growId)
        ImGui.TextColored(ImVec4(0.2, 0.8, 1.0, 1.0), "GrowID: " .. sw.growId)
        ImGui.SameLine()
        ImGui.TextColored(ImVec4(0.7, 0.7, 0.7, 1.0), "| UserID: " .. sw.userId)

        ImGui.Spacing()
        ImGui.TextColored(ImVec4(0.95, 0.77, 0.15, 1.0), "Status Channel Thread Discord (Log Routing):")

        local ok_col = ImVec4(0.2, 0.9, 0.3, 1.0)
        local no_col = ImVec4(0.5, 0.5, 0.5, 1.0)

        local function check_th(v)
            return v and v ~= "-" and v ~= "" and v ~= "null"
        end

        if not GUI_STATE.show_raw_threads then
            local s_ok = check_th(sw.threadSetor)
            local m_ok = check_th(sw.threadModal)
            local c_ok = check_th(sw.threadChamp)
            local d_ok = check_th(sw.threadDrop)
            local do_ok = check_th(sw.threadDonation)
            local st_ok = check_th(sw.threadStorage)

            ImGui.BulletText("Setor: ")
            ImGui.SameLine()
            ImGui.TextColored(s_ok and ok_col or no_col, s_ok and "Terhubung" or "Belum Ada")
            ImGui.SameLine()
            ImGui.Text(" | Modal: ")
            ImGui.SameLine()
            ImGui.TextColored(m_ok and ok_col or no_col, m_ok and "Terhubung" or "Belum Ada")
            ImGui.SameLine()
            ImGui.Text(" | Champ: ")
            ImGui.SameLine()
            ImGui.TextColored(c_ok and ok_col or no_col, c_ok and "Terhubung" or "Belum Ada")

            ImGui.BulletText("Drop: ")
            ImGui.SameLine()
            ImGui.TextColored(d_ok and ok_col or no_col, d_ok and "Terhubung" or "Belum Ada")
            ImGui.SameLine()
            ImGui.Text(" | Donasi: ")
            ImGui.SameLine()
            ImGui.TextColored(do_ok and ok_col or no_col, do_ok and "Terhubung" or "Belum Ada")
            ImGui.SameLine()
            ImGui.Text(" | Storage: ")
            ImGui.SameLine()
            ImGui.TextColored(st_ok and ok_col or no_col, st_ok and "Terhubung" or "Belum Ada")
        else
            local function render_th_row(label, val, tag)
                local is_ok = check_th(val)
                ImGui.BulletText(label .. ": ")
                ImGui.SameLine()
                if is_ok then
                    ImGui.TextColored(ok_col, "Terhubung")
                    ImGui.SameLine()
                    ImGui.TextColored(ImVec4(0.6, 0.6, 0.6, 1.0), "[" .. tostring(val) .. "]")
                    ImGui.SameLine()
                    if ImGui.SmallButton("Copy##" .. tag) then
                        if type(ImGui.SetClipboardText) == "function" then
                            ImGui.SetClipboardText(tostring(val))
                            helpers.OnTextOverlay("`2Copied ID: " .. tostring(val))
                        end
                    end
                else
                    ImGui.TextColored(no_col, "Belum Ada")
                end
            end

            render_th_row("Log Setor", sw.threadSetor, "wSetor" .. sw.userId)
            render_th_row("Log Modal", sw.threadModal, "wModal" .. sw.userId)
            render_th_row("Log Champ", sw.threadChamp, "wChamp" .. sw.userId)
            render_th_row("Log Drop", sw.threadDrop, "wDrop" .. sw.userId)
            render_th_row("Log Donasi", sw.threadDonation, "wDon" .. sw.userId)
            render_th_row("Log Storage", sw.threadStorage, "wStore" .. sw.userId)
        end

        ImGui.Spacing()
        if ImGui.SmallButton("Tutup Detail##closeWDetail") then
            GUI_STATE.selected_worker = nil
        end
        ImGui.SameLine()
        local chk_id, new_chk = ImGui.Checkbox("Tampilkan ID Snowflake Discord##showWId", GUI_STATE.show_raw_threads or false)
        if chk_id then
            GUI_STATE.show_raw_threads = new_chk
        end
    end

    render_pagination("wrk", cur_page, total_pages, function(p)
        GUI_STATE.worker_page = p
    end)
end

local function render_hosters_tab()
    ImGui.TextColored(ImVec4(0.95, 0.77, 0.15, 1.0), "Daftar Hoster Terdaftar di Database")
    ImGui.Spacing()

    ImGui.Text("Cari Hoster:")
    ImGui.SameLine()
    ImGui.PushItemWidth(200)
    local s_ch, s_txt = ImGui.InputText("##hosterSearch", GUI_STATE.hoster_search, 40)
    if s_ch then
        GUI_STATE.hoster_search = s_txt
        GUI_STATE.hoster_page = 1
    end
    ImGui.PopItemWidth()
    ImGui.SameLine()
    if ImGui.SmallButton("Reset##hstReset") then
        GUI_STATE.hoster_search = ""
        GUI_STATE.hoster_page = 1
    end

    local hoster_list = {}
    if whitelist_state.hosters then
        for uid, h in pairs(whitelist_state.hosters) do
            table.insert(hoster_list, {
                growId = h.growId or "Hoster",
                userId = tostring(uid),
                role = h.role or "HOSTER",
                threadModal = h.threadModal or "-",
                threadChamp = h.threadChamp or "-",
                threadDrop = h.threadDrop or "-",
                threadDonation = h.threadDonation or "-",
                threadStorage = h.threadStorage or "-"
            })
        end
    end
    table.sort(hoster_list, function(a, b) return a.growId:lower() < b.growId:lower() end)

    local page_items, cur_page, total_pages, total_count = filter_and_paginate(
        hoster_list,
        GUI_STATE.hoster_search,
        GUI_STATE.hoster_page,
        GUI_STATE.hoster_per_page,
        {"growId", "userId"}
    )
    GUI_STATE.hoster_page = cur_page

    ImGui.SameLine()
    ImGui.TextColored(ImVec4(0.7, 0.7, 0.7, 1.0), string.format("| Total: %d Hoster", total_count))

    ImGui.Spacing()

    local table_flags = DEFAULT_TABLE_FLAGS
    if ImGui.BeginTable("HosterTable", 5, table_flags) then
        ImGui.TableSetupColumn("#", 0, 30)
        ImGui.TableSetupColumn("GrowID", 0, 140)
        ImGui.TableSetupColumn("User ID", 0, 100)
        ImGui.TableSetupColumn("Role", 0, 160)
        ImGui.TableSetupColumn("Action", 0, 120)
        ImGui.TableHeadersRow()

        if #page_items == 0 then
            ImGui.TableNextRow()
            ImGui.TableSetColumnIndex(1)
            ImGui.TextColored(ImVec4(0.8, 0.5, 0.2, 1.0), "Tidak ada data hoster.")
        else
            for idx, h in ipairs(page_items) do
                local global_idx = (cur_page - 1) * GUI_STATE.hoster_per_page + idx
                ImGui.TableNextRow()

                ImGui.TableSetColumnIndex(0)
                ImGui.Text(tostring(global_idx))

                ImGui.TableSetColumnIndex(1)
                ImGui.TextColored(ImVec4(0.95, 0.77, 0.15, 1.0), h.growId)

                ImGui.TableSetColumnIndex(2)
                ImGui.Text(h.userId)

                ImGui.TableSetColumnIndex(3)
                ImGui.TextColored(ImVec4(0.7, 0.5, 0.9, 1.0), "Hoster Official")

                ImGui.TableSetColumnIndex(4)
                if ImGui.SmallButton("Copy UID##h" .. h.userId) then
                    if type(ImGui.SetClipboardText) == "function" then
                        ImGui.SetClipboardText(h.userId)
                        helpers.OnTextOverlay("`2Copied UID: " .. h.userId)
                    end
                end
                ImGui.SameLine()
                if ImGui.SmallButton("Info##h" .. h.userId) then
                    GUI_STATE.selected_hoster = h
                end
            end
        end
        ImGui.EndTable()
    end

    if GUI_STATE.selected_hoster then
        local sh = GUI_STATE.selected_hoster
        ImGui.Spacing()
        ImGui.SeparatorText("Detail Hoster: " .. sh.growId)
        ImGui.TextColored(ImVec4(0.95, 0.77, 0.15, 1.0), "GrowID: " .. sh.growId)
        ImGui.SameLine()
        ImGui.TextColored(ImVec4(0.7, 0.7, 0.7, 1.0), "| UserID: " .. sh.userId)

        ImGui.Spacing()
        ImGui.TextColored(ImVec4(0.95, 0.77, 0.15, 1.0), "Status Channel Thread Discord (Log Routing):")

        local ok_col = ImVec4(0.2, 0.9, 0.3, 1.0)
        local no_col = ImVec4(0.5, 0.5, 0.5, 1.0)

        local function check_th(v)
            return v and v ~= "-" and v ~= "" and v ~= "null"
        end

        if not GUI_STATE.show_raw_threads then
            local m_ok = check_th(sh.threadModal)
            local c_ok = check_th(sh.threadChamp)
            local d_ok = check_th(sh.threadDrop)
            local do_ok = check_th(sh.threadDonation)
            local st_ok = check_th(sh.threadStorage)

            ImGui.BulletText("Modal: ")
            ImGui.SameLine()
            ImGui.TextColored(m_ok and ok_col or no_col, m_ok and "Terhubung" or "Belum Ada")
            ImGui.SameLine()
            ImGui.Text(" | Champ: ")
            ImGui.SameLine()
            ImGui.TextColored(c_ok and ok_col or no_col, c_ok and "Terhubung" or "Belum Ada")
            ImGui.SameLine()
            ImGui.Text(" | Drop: ")
            ImGui.SameLine()
            ImGui.TextColored(d_ok and ok_col or no_col, d_ok and "Terhubung" or "Belum Ada")

            ImGui.BulletText("Donasi: ")
            ImGui.SameLine()
            ImGui.TextColored(do_ok and ok_col or no_col, do_ok and "Terhubung" or "Belum Ada")
            ImGui.SameLine()
            ImGui.Text(" | Storage: ")
            ImGui.SameLine()
            ImGui.TextColored(st_ok and ok_col or no_col, st_ok and "Terhubung" or "Belum Ada")
        else
            local function render_th_row(label, val, tag)
                local is_ok = check_th(val)
                ImGui.BulletText(label .. ": ")
                ImGui.SameLine()
                if is_ok then
                    ImGui.TextColored(ok_col, "Terhubung")
                    ImGui.SameLine()
                    ImGui.TextColored(ImVec4(0.6, 0.6, 0.6, 1.0), "[" .. tostring(val) .. "]")
                    ImGui.SameLine()
                    if ImGui.SmallButton("Copy##" .. tag) then
                        if type(ImGui.SetClipboardText) == "function" then
                            ImGui.SetClipboardText(tostring(val))
                            helpers.OnTextOverlay("`2Copied ID: " .. tostring(val))
                        end
                    end
                else
                    ImGui.TextColored(no_col, "Belum Ada")
                end
            end

            render_th_row("Log Modal", sh.threadModal, "hModal" .. sh.userId)
            render_th_row("Log Champ", sh.threadChamp, "hChamp" .. sh.userId)
            render_th_row("Log Drop", sh.threadDrop, "hDrop" .. sh.userId)
            render_th_row("Log Donasi", sh.threadDonation, "hDon" .. sh.userId)
            render_th_row("Log Storage", sh.threadStorage, "hStore" .. sh.userId)
        end

        ImGui.Spacing()
        if ImGui.SmallButton("Tutup Detail##closeHDetail") then
            GUI_STATE.selected_hoster = nil
        end
        ImGui.SameLine()
        local chk_id, new_chk = ImGui.Checkbox("Tampilkan ID Snowflake Discord##showHId", GUI_STATE.show_raw_threads or false)
        if chk_id then
            GUI_STATE.show_raw_threads = new_chk
        end
    end

    render_pagination("hst", cur_page, total_pages, function(p)
        GUI_STATE.hoster_page = p
    end)
end

local function render_logs_tab()
    ImGui.TextColored(ImVec4(0.2, 0.9, 0.4, 1.0), "Riwayat Aktivitas & Transaksi (Live Feed)")
    ImGui.Spacing()

    -- Filter Buttons (Clean & Dedicated Buttons)
    ImGui.Text("Filter Kategori:")
    ImGui.SameLine()

    local btn_all = (GUI_STATE.log_filter == 0) and "[ SEMUA ]" or "Semua"
    local btn_setor = (GUI_STATE.log_filter == 1) and "[ SETOR ]" or "Setor"
    local btn_modal = (GUI_STATE.log_filter == 2) and "[ MODAL & CHAMP ]" or "Modal & Champ"
    local btn_sys = (GUI_STATE.log_filter == 3) and "[ SYSTEM ]" or "System"

    if ImGui.Button(btn_all, ImVec2(80, 26)) then
        GUI_STATE.log_filter = 0
        GUI_STATE.log_page = 1
    end
    ImGui.SameLine()
    if ImGui.Button(btn_setor, ImVec2(80, 26)) then
        GUI_STATE.log_filter = 1
        GUI_STATE.log_page = 1
    end
    ImGui.SameLine()
    if ImGui.Button(btn_modal, ImVec2(130, 26)) then
        GUI_STATE.log_filter = 2
        GUI_STATE.log_page = 1
    end
    ImGui.SameLine()
    if ImGui.Button(btn_sys, ImVec2(80, 26)) then
        GUI_STATE.log_filter = 3
        GUI_STATE.log_page = 1
    end

    ImGui.Spacing()

    -- Search filter (Row 2)
    ImGui.Text("Cari Log:")
    ImGui.SameLine()
    ImGui.PushItemWidth(180)
    local s_ch, s_txt = ImGui.InputText("##logSearchBox", GUI_STATE.log_search, 40)
    if s_ch then
        GUI_STATE.log_search = s_txt
        GUI_STATE.log_page = 1
    end
    ImGui.PopItemWidth()

    ImGui.SameLine()
    if ImGui.Button("Reset Pencarian", ImVec2(120, 26)) then
        GUI_STATE.log_search = ""
        GUI_STATE.log_page = 1
    end

    ImGui.SameLine()
    if ImGui.Button("Clear Log Lokal", ImVec2(120, 26)) then
        GUI_LOCAL_LOGS = {}
        helpers.OnTextOverlay("`2Local logs cleared.")
    end

    local combined = {}
    if type(GUI_LOCAL_LOGS) == "table" then
        for _, l in ipairs(GUI_LOCAL_LOGS) do
            if type(l) == "table" then table.insert(combined, l) end
        end
    end
    if type(GUI_STATE.api_logs) == "table" then
        for _, l in ipairs(GUI_STATE.api_logs) do
            if type(l) == "table" then table.insert(combined, l) end
        end
    end

    local cat_filtered = {}
    for _, item in ipairs(combined) do
        local keep = true
        local l_type = tostring(item.type or "LOG"):upper()
        if GUI_STATE.log_filter == 1 and l_type ~= "SETOR" then
            keep = false
        elseif GUI_STATE.log_filter == 2 and l_type ~= "MODAL" and l_type ~= "CHAMP" then
            keep = false
        elseif GUI_STATE.log_filter == 3 and l_type ~= "SYSTEM" then
            keep = false
        end
        if keep then
            table.insert(cat_filtered, item)
        end
    end

    local page_items, cur_page, total_pages, total_count = filter_and_paginate(
        cat_filtered,
        GUI_STATE.log_search,
        GUI_STATE.log_page,
        GUI_STATE.log_per_page,
        {"detail", "user", "type"}
    )
    GUI_STATE.log_page = cur_page

    ImGui.Spacing()

    local table_flags = DEFAULT_TABLE_FLAGS
    if ImGui.BeginTable("LogsTable", 4, table_flags) then
        ImGui.TableSetupColumn("Waktu", 0, 75)
        ImGui.TableSetupColumn("Tipe", 0, 85)
        ImGui.TableSetupColumn("User", 0, 110)
        ImGui.TableSetupColumn("Keterangan Log", 0, 260)
        ImGui.TableHeadersRow()

        if #page_items == 0 then
            ImGui.TableNextRow()
            ImGui.TableSetColumnIndex(0)
            ImGui.Text("-")
            ImGui.TableSetColumnIndex(1)
            ImGui.Text("-")
            ImGui.TableSetColumnIndex(2)
            ImGui.Text("-")
            ImGui.TableSetColumnIndex(3)
            ImGui.TextColored(ImVec4(0.6, 0.6, 0.6, 1.0), "Belum ada catatan log.")
        else
            for _, l in ipairs(page_items) do
                ImGui.TableNextRow()

                ImGui.TableSetColumnIndex(0)
                ImGui.TextColored(ImVec4(0.7, 0.7, 0.7, 1.0), tostring(l.time or "-"))

                ImGui.TableSetColumnIndex(1)
                local col = ImVec4(0.6, 0.6, 0.6, 1.0)
                local l_type = tostring(l.type or "LOG"):upper()
                if l_type == "SETOR" then col = ImVec4(0.2, 0.9, 0.2, 1.0)
                elseif l_type == "MODAL" then col = ImVec4(0.95, 0.77, 0.15, 1.0)
                elseif l_type == "CHAMP" then col = ImVec4(0.2, 0.8, 1.0, 1.0)
                elseif l_type == "SYSTEM" then col = ImVec4(0.8, 0.4, 0.9, 1.0)
                end
                ImGui.TextColored(col, "[" .. l_type .. "]")

                ImGui.TableSetColumnIndex(2)
                ImGui.Text(tostring(l.user or "-"))

                ImGui.TableSetColumnIndex(3)
                ImGui.Text(tostring(l.detail or ""))
            end
        end
        ImGui.EndTable()
    end

    render_pagination("log", cur_page, total_pages, function(p)
        GUI_STATE.log_page = p
    end)
end

local function render_finance_tab()
    ImGui.TextColored(ImVec4(0.95, 0.77, 0.15, 1.0), "Ringkasan Keuangan Kas & Stok Modal")
    ImGui.Spacing()

    local stats = GUI_STATE.api_stats

    ImGui.BeginGroup()
    ImGui.TextColored(ImVec4(0.2, 0.8, 1.0, 1.0), "MODAL GUDANG:")
    ImGui.TextColored(ImVec4(0.95, 0.77, 0.15, 1.0), string.format("  %.2f BGL", stats.totalModalBgl or 0))
    ImGui.EndGroup()

    ImGui.SameLine(180)
    ImGui.BeginGroup()
    ImGui.TextColored(ImVec4(0.2, 0.8, 1.0, 1.0), "STOK CHAMP:")
    ImGui.TextColored(ImVec4(0.3, 0.9, 0.4, 1.0), string.format("  %s Champ", helpers.FormatNumber(stats.totalChamp or 0)))
    ImGui.EndGroup()

    ImGui.SameLine(340)
    ImGui.BeginGroup()
    ImGui.TextColored(ImVec4(0.2, 0.8, 1.0, 1.0), "ACTIVE WORKERS:")
    ImGui.Text(string.format("  %d Worker", stats.activeWorkers or 0))
    ImGui.EndGroup()

    ImGui.SameLine(480)
    ImGui.BeginGroup()
    ImGui.TextColored(ImVec4(0.2, 0.8, 1.0, 1.0), "TOTAL TRANSAKSI:")
    ImGui.Text(string.format("  %d Setoran", stats.totalSetors or 0))
    ImGui.EndGroup()

    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()

    ImGui.SeparatorText("Isi Backpack / Inventory Akun Saat Ini")
    local wl_cnt = helpers.GetItemCount(242)
    local dl_cnt = helpers.GetItemCount(1796)
    local bgl_cnt = helpers.GetItemCount(7188)
    local blk_cnt = helpers.GetItemCount(11550)

    ImGui.BulletText("World Lock (WL)    : " .. helpers.FormatNumber(wl_cnt))
    ImGui.BulletText("Diamond Lock (DL)  : " .. helpers.FormatNumber(dl_cnt))
    ImGui.BulletText("Blue Gem Lock (BGL): " .. helpers.FormatNumber(bgl_cnt))
    ImGui.BulletText("Black Gem Lock     : " .. helpers.FormatNumber(blk_cnt))

    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()

    if ImGui.Button("Sinkronisasi Ulang Kas dari Bot API##syncKas", ImVec2(240, 32)) then
        helpers.SyncDashboardData()
        helpers.OnTextOverlay("`2Syncing financial stats...")
    end
end

local function render_developer_tab()
    ImGui.TextColored(ImVec4(0.9, 0.3, 0.3, 1.0), "[OWNER / BYPASS EXCLUSIVE] Developer & Diagnostics")
    ImGui.Spacing()

    local ok_loc, me = pcall(GetLocal)
    local ok_w, world = pcall(GetWorld)

    ImGui.SeparatorText("Status Karakter & World")
    local px = (ok_loc and me and me.pos) and math.floor(me.pos.x) or 0
    local py = (ok_loc and me and me.pos) and math.floor(me.pos.y) or 0
    local tx = math.floor(px / 32)
    local ty = math.floor(py / 32)
    local w_name = (ok_w and world and world.name) and world.name or "OFFLINE"
    local p_count = (ok_w and world and world.players) and #world.players or 0

    ImGui.Text(string.format("World: %s | Players: %d | Ping: %d ms", w_name, p_count, helpers.GetPing()))
    ImGui.Text(string.format("Pos: (%d, %d) | Tile: (%d, %d)", px, py, tx, ty))

    if ok_w and world and tx >= 0 and ty >= 0 then
        local ok_tile, tile = pcall(GetTile, tx, ty)
        if ok_tile and tile then
            ImGui.TextColored(ImVec4(0.4, 0.8, 1.0, 1.0), string.format("Tile Injak: FG=%d | BG=%d", tile.fg or 0, tile.bg or 0))
        end
    end

    ImGui.Spacing()
    ImGui.SeparatorText("Packet Injector")
    ImGui.PushItemWidth(-1)
    local p_ch, p_val = ImGui.InputText("##devPktInp", GUI_STATE.dev_packet_input, 150)
    if p_ch then GUI_STATE.dev_packet_input = p_val end
    ImGui.PopItemWidth()

    if ImGui.Button("Send Packet (Type 2)##sendPkt2", ImVec2(160, 28)) then
        SendPacket(2, GUI_STATE.dev_packet_input)
        GUI_STATE.dev_last_action_msg = "Sent Type 2 Packet"
        helpers.AddDevLog("PACKET", "Sent Type 2: " .. GUI_STATE.dev_packet_input:gsub("\n", " "))
    end
    ImGui.SameLine()
    if ImGui.Button("Send Action (Type 3)##sendPkt3", ImVec2(160, 28)) then
        SendPacket(3, GUI_STATE.dev_packet_input)
        GUI_STATE.dev_last_action_msg = "Sent Type 3 Packet"
        helpers.AddDevLog("PACKET", "Sent Type 3: " .. GUI_STATE.dev_packet_input:gsub("\n", " "))
    end

    if GUI_STATE.dev_last_action_msg ~= "" then
        ImGui.SameLine()
        ImGui.TextColored(ImVec4(0.2, 0.9, 0.2, 1.0), GUI_STATE.dev_last_action_msg)
    end

    ImGui.Spacing()
    ImGui.SeparatorText("Engine & Performa Lua")
    local mem_kb = collectgarbage("count")
    ImGui.Text(string.format("Memori Script: %.2f KB (%.2f MB)", mem_kb, mem_kb / 1024))

    if ImGui.Button("Force Garbage Collection##forceGc", ImVec2(180, 28)) then
        collectgarbage("collect")
        GUI_STATE.dev_last_action_msg = "Garbage Collected"
        helpers.AddDevLog("SYSTEM", "Memory cleaned via GC")
        helpers.OnTextOverlay("`2Lua Garbage Collected!")
    end

    ImGui.SameLine()
    if ImGui.Button("Emergency Panic Stop##panicStop", ImVec2(180, 28)) then
        if autosb_state then autosb_state.running = false end
        GUI_STATE.dev_last_action_msg = "Automation Stopped"
        helpers.AddDevLog("SYSTEM", "Panic Stop Triggered")
        helpers.OnTextOverlay("`4Emergency Panic Stop Triggered!")
    end
end

function helpers.RenderImGuiDashboard(deltatime)
    local ok_render, err_render = pcall(function()
        if type(GetAsyncKeyState) == "function" then
            local now = os.time()
            if GetAsyncKeyState(0x70) ~= 0 and (now - GUI_STATE.last_toggle_time >= 1) then -- VK_F1 (112)
                GUI_STATE.last_toggle_time = now
                helpers.ToggleGui()
            end
        end

        if not GUI_STATE.open then return end

        local ok_local, me = pcall(GetLocal)
        local my_uid_num = (ok_local and me and me.userid) and math.floor(tonumber(me.userid) or 0) or 0
        local my_uid_str = tostring(my_uid_num)

        local is_boss = (my_uid_num == 1038257 or (whitelist_state.bypass_uids and whitelist_state.bypass_uids[my_uid_str]))
        local is_hoster = (whitelist_state.hosters and whitelist_state.hosters[my_uid_str]) ~= nil
        local is_worker = (whitelist_state.workers and whitelist_state.workers[my_uid_str]) ~= nil
        local is_auth = is_boss or is_hoster or is_worker

        ImGui.SetNextWindowSize(ImVec2(660, 520), ImGuiCond_FirstUseEver)

        local win_open, win_vis = ImGui.Begin("DODGED PROXY - MANAGEMENT & DEV DASHBOARD###DodgedMainGUI", GUI_STATE.open, ImGuiWindowFlags_NoCollapse)
        GUI_STATE.open = win_open

        if win_vis then
            if not is_auth then
                ImGui.TextColored(ImVec4(0.9, 0.2, 0.2, 1.0), "ACCESS DENIED: User ID (" .. my_uid_str .. ") tidak terdaftar!")
                ImGui.Text("Silakan hubungi admin Discord atau gunakan /addworker.")
                ImGui.Separator()
                if ImGui.Button("Tutup Window##closeAuthDenied", ImVec2(120, 30)) then
                    GUI_STATE.open = false
                end
                ImGui.End()
                return
            end

            local role_label = is_boss and "OWNER / BYPASS" or (is_hoster and "HOSTER" or "WORKER")
            local role_col = is_boss and ImVec4(0.95, 0.25, 0.25, 1.0) or (is_hoster and ImVec4(0.95, 0.77, 0.15, 1.0) or ImVec4(0.2, 0.85, 0.3, 1.0))

            ImGui.TextColored(ImVec4(0.2, 0.8, 1.0, 1.0), "DODGED PROXY")
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0.6, 0.6, 0.6, 1.0), "|")
            ImGui.SameLine()
            ImGui.TextColored(role_col, "[" .. role_label .. "]")
            ImGui.SameLine()
            ImGui.TextColored(ImVec4(0.8, 0.8, 0.8, 1.0), tostring(me and me.name or "Player") .. " (UID: " .. my_uid_str .. ")")

            ImGui.SameLine()
            ImGui.SetCursorPosX(ImGui.GetWindowWidth() - 170)
            if ImGui.SmallButton(GUI_STATE.is_syncing and "Syncing...##syncBtn" or "Refresh Data##syncBtn") then
                helpers.SyncDashboardData()
            end
            ImGui.SameLine()
            ImGui.TextColored(GUI_STATE.api_status_color, GUI_STATE.api_status)

            ImGui.Separator()

            if ImGui.BeginTabBar("DodgedTabs") then
                if ImGui.BeginTabItem("Workers##tab") then
                    render_workers_tab()
                    ImGui.EndTabItem()
                end

                if ImGui.BeginTabItem("Hosters##tab") then
                    render_hosters_tab()
                    ImGui.EndTabItem()
                end

                if ImGui.BeginTabItem("Activity Logs##tab") then
                    render_logs_tab()
                    ImGui.EndTabItem()
                end

                if ImGui.BeginTabItem("Kas & Stats##tab") then
                    render_finance_tab()
                    ImGui.EndTabItem()
                end

                if is_boss then
                    if ImGui.BeginTabItem("Developer Tools##tab") then
                        render_developer_tab()
                        ImGui.EndTabItem()
                    end
                end

                ImGui.EndTabBar()
            end
        end

        ImGui.End()
    end)
    if not ok_render and err_render then
        if not GUI_STATE._last_err or GUI_STATE._last_err ~= tostring(err_render) then
            GUI_STATE._last_err = tostring(err_render)
            helpers.OnConsoleMessage("`4[ImGui Error] `0" .. tostring(err_render))
        end
    end
end

-- =========================== HOTKEY MANAGER (EXPROXY STYLE) ===========================

function helpers.HotkeyDialog(error_msg)
    local dialog = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|`cCustom Hotkey Manager``|left|11550|",
        "add_spacer|small|",
        "add_textbox|`7Assign keyboard keys to automatically execute custom commands.|left|",
        "add_spacer|small|",
        "add_small_font_button|open_system_shortcuts|`9[ System & Preset Shortcuts ]|noflags|0|0|",
        "add_spacer|small|"
    }

    if error_msg then
        table.insert(dialog, "add_smalltext|" .. tostring(error_msg) .. "|left|")
        table.insert(dialog, "add_spacer|small|")
    end

    for i = 1, 4 do
        local hk = config.custom_hotkeys and config.custom_hotkeys[i] or {}
        local key_name = hk.key and get_key_name(hk.key) or "Not Set"
        local cmd_val = tostring(hk.cmd or ""):gsub("[|\n\r]", "")
        local enabled_val = (hk.enabled and hk.key) and "1" or "0"
        local status_color = hk.key and ("`2[`e" .. key_name .. "`2]") or "`4[Not Set]"
        local cmd_display = (cmd_val ~= "") and ("`0Command: `9" .. cmd_val) or "`7No Command"

        table.insert(dialog, "add_label_with_icon|small|`0Slot " .. i .. ": " .. status_color .. " `e- " .. cmd_display .. "|left|32|")
        table.insert(dialog, "add_small_font_button|hk_set_" .. i .. "|`2[Set Key]|noflags|0|0|")
        table.insert(dialog, "add_small_font_button|hk_clr_" .. i .. "|`4[Clear]|noflags|0|0|")
        table.insert(dialog, "add_text_input|hk_cmd_" .. i .. "|`0Command: |" .. cmd_val .. "|30|")
        table.insert(dialog, "add_checkbox|hk_en_" .. i .. "|`0Enabled|" .. enabled_val .. "|")
        table.insert(dialog, "add_spacer|small|")
    end

    table.insert(dialog, "add_label_with_icon|small|`#Timing Configuration``|left|934|")
    table.insert(dialog, "add_spacer|small|")
    table.insert(dialog, "add_text_input|hk_cooldown|`0Repeat Cooldown (ms): |" .. tostring(config.hotkey_cmd_cooldown_ms or 300) .. "|6|")
    table.insert(dialog, "add_smalltext|`7Minimum repeat delay when key is held down (min: 100ms)|left|")
    table.insert(dialog, "add_spacer|small|")
    table.insert(dialog, "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|")
    table.insert(dialog, "add_quick_exit||")
    table.insert(dialog, "end_dialog|hotkey_dialog|Cancel|`2Save Settings|")

    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

function helpers.SystemShortcutsDialog()
    local dialog = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|`cSystem & Preset Shortcuts``|left|758|",
        "add_spacer|small|",
        "add_textbox|`7Toggle built-in teleport, utility, and wrench shortcut behaviors.|left|",
        "add_spacer|small|",
        "add_label_with_icon|small|`!Teleport & Navigation``|left|758|",
        "add_spacer|small|",
        "add_checkbox|hotkey_ctrl_click|`9CTRL + Click `o(Remote Collect & Drop)|" .. (config.tp_ctrl_click_enabled and "1" or "0") .. "|",
        "add_checkbox|hotkey_shift_click|`9SHIFT + Click `o(Auto Pathfind to clicked tile)|" .. (config.tp_shift_click_enabled and "1" or "0") .. "|",
        "add_spacer|small|",
        "add_label_with_icon|small|`^Actions & Combat``|left|1796|",
        "add_spacer|small|",
        "add_checkbox|hotkey_f4_respawn|`9F4 `o(Instant Fast Respawn)|" .. (config.hotkey_f4_respawn and "1" or "0") .. "|",
        "add_spacer|small|",
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_quick_exit||",
        "end_dialog|system_shortcuts_dialog|Cancel|`2Save Shortcuts|"
    }
    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

function helpers.StartHotkeyAssignCapture(slot)
    if not slot or slot < 1 or slot > 4 then return end
    hotkey_assign_state.waiting = true
    hotkey_assign_state.target_slot = slot

    local current_cmd = (config.custom_hotkeys and config.custom_hotkeys[slot] and config.custom_hotkeys[slot].cmd ~= "") and config.custom_hotkeys[slot].cmd or ("Slot " .. slot)
    helpers.OnTextOverlay("`ePress Any Key for `9" .. current_cmd .. "`o...")
    helpers.OnConsoleMessage("`e[Hotkey] Press any key on your keyboard to assign to Slot " .. slot .. " (ESC: cancel, DEL/BS: clear)...")

    RunThread(function()
        Sleep(250)
        while hotkey_assign_state.waiting and hotkey_assign_state.target_slot == slot do
            Sleep(10)
            if type(GetAsyncKeyState) == "function" then
                for k = 8, 222 do
                    if k ~= 1 and k ~= 2 and k ~= 4 and k ~= 5 and k ~= 6 then
                        local ok_k, k_state = pcall(GetAsyncKeyState, k)
                        if ok_k and k_state and k_state < 0 then
                            -- ESC: Cancel
                            if k == 27 then
                                hotkey_assign_state.waiting = false
                                hotkey_assign_state.target_slot = nil
                                helpers.OnTextOverlay("`7Hotkey assignment cancelled.")
                                RunThread(function()
                                    Sleep(150)
                                    helpers.HotkeyDialog()
                                end)
                                return
                            end

                            -- Backspace / Delete: Clear
                            if k == 8 or k == 46 then
                                config.custom_hotkeys[slot] = { key = nil, cmd = "", enabled = false }
                                hotkey_assign_state.waiting = false
                                hotkey_assign_state.target_slot = nil
                                auto_save_config()
                                helpers.OnTextOverlay("`4Slot " .. slot .. " cleared!")
                                helpers.OnConsoleMessage("`4[Hotkey] Slot " .. slot .. " reset to [Not Set].")
                                RunThread(function()
                                    Sleep(150)
                                    helpers.HotkeyDialog()
                                end)
                                return
                            end

                            -- Duplicate check
                            local is_dup = false
                            for j = 1, 4 do
                                if j ~= slot and config.custom_hotkeys and config.custom_hotkeys[j] and config.custom_hotkeys[j].key == k then
                                    helpers.OnTextOverlay("`4Key already used in Slot " .. j .. "! Press another key.")
                                    is_dup = true
                                    Sleep(400)
                                    break
                                end
                            end

                            if not is_dup then
                                if not config.custom_hotkeys then config.custom_hotkeys = {} end
                                if not config.custom_hotkeys[slot] then
                                    config.custom_hotkeys[slot] = { key = nil, cmd = "", enabled = true }
                                end
                                config.custom_hotkeys[slot].key = k
                                config.custom_hotkeys[slot].enabled = true
                                hotkey_assign_state.waiting = false
                                hotkey_assign_state.target_slot = nil
                                auto_save_config()

                                local key_label = get_key_name(k)
                                helpers.OnTextOverlay("`2Slot " .. slot .. " assigned: `e" .. key_label)
                                helpers.OnConsoleMessage("`2[Hotkey] Slot " .. slot .. " assigned to `e" .. key_label)

                                RunThread(function()
                                    Sleep(150)
                                    helpers.HotkeyDialog()
                                end)
                                return
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function start_custom_hotkeys_async_watcher()
    RunThread(function()
        while true do
            Sleep(15)
            if not hotkey_assign_state.waiting and type(GetAsyncKeyState) == "function" then
                local now_ms = math.floor(os.clock() * 1000)
                local cooldown = math.max(100, math.floor(tonumber(config.hotkey_cmd_cooldown_ms) or 300))

                -- F4 Instant Fast Respawn
                if config.hotkey_f4_respawn then
                    local ok_f4, f4_st = pcall(GetAsyncKeyState, 115) -- F4
                    if ok_f4 and f4_st and f4_st < 0 then
                        local last_f4 = hotkey_last_trigger["f4"] or 0
                        if (now_ms - last_f4) >= 1000 then
                            hotkey_last_trigger["f4"] = now_ms
                            SendPacket(2, "action|respawn")
                            helpers.OnTextOverlay("`4Instant Respawn (F4)")
                        end
                    end
                end

                -- Custom Hotkeys Slots 1 to 4
                for slot = 1, 4 do
                    local hk = config.custom_hotkeys and config.custom_hotkeys[slot]
                    if type(hk) == "table" and hk.enabled and hk.key and hk.cmd and hk.cmd ~= "" then
                        local ok_st, k_st = pcall(GetAsyncKeyState, hk.key)
                        if ok_st and k_st and k_st < 0 then
                            local last = hotkey_last_trigger[slot] or 0
                            if (now_ms - last) >= cooldown then
                                hotkey_last_trigger[slot] = now_ms
                                local cmd_text = tostring(hk.cmd)
                                local ok, result = pcall(helpers.InvokeRegisteredCommand, cmd_text)
                                if not ok or result == false then
                                    if cmd_text:sub(1, 1) ~= "/" then cmd_text = "/" .. cmd_text end
                                    SendPacket(2, "action|input\n|text|" .. cmd_text .. "\n")
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

-- =========================== COMMAND REGISTRY SYSTEM ===========================

local COMMAND_MAP = {}
local COMMAND_DEFS = {}
local COMMAND_ALIASES = {}

local function normalize_command_name(raw)
    local value = tostring(raw or ""):lower()
    value = value:gsub("^%s*/+", "")
    value = value:gsub("^%s+", ""):gsub("%s+$", "")
    return value
end

local function add_command(def)
    if type(def) ~= "table" then return end
    local name = normalize_command_name(def.name)
    if name == "" then return end

    def.name = name
    def.aliases = def.aliases or {}
    COMMAND_MAP[name] = def
    table.insert(COMMAND_DEFS, def)

    for _, alias in ipairs(def.aliases) do
        local alias_name = normalize_command_name(alias)
        if alias_name ~= "" and alias_name ~= name then
            COMMAND_ALIASES[alias_name] = name
        end
    end
end

local function resolve_registered_command(token)
    local cmd = normalize_command_name(token)
    if cmd == "" then return nil, nil end
    if COMMAND_MAP[cmd] then return cmd, COMMAND_MAP[cmd] end
    local canonical = COMMAND_ALIASES[cmd]
    if canonical and COMMAND_MAP[canonical] then
        return canonical, COMMAND_MAP[canonical]
    end
    return nil, nil
end

function helpers.InvokeRegisteredCommand(full_cmd)
    local raw = tostring(full_cmd or ""):gsub("^/+", "")
    local token, args = raw:match("^([^%s]+)%s*(.-)$")
    token = token or raw
    args = args or ""
    local canonical, def = resolve_registered_command(token)
    if not canonical or not def or type(def.handler) ~= "function" then
        return false, "not_found"
    end
    local ok, handled = pcall(def.handler, args, full_cmd)
    if not ok then return false, handled end
    return true, handled
end

-- =========================== DYNAMIC MENU DIALOG ===========================

function helpers.OpenMenuDialog()
    local dialog = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|small|`eDODGED `9Automation & Worker Proxy``|left|11550|",
        "add_spacer|small|",
        "add_label_with_icon|small|`eAll Available Proxy Commands|left|658|",
        "add_spacer|small|"
    }

    -- Auto-generate from registered commands in COMMAND_DEFS (flat list, no categories)
    for _, cmd in ipairs(COMMAND_DEFS) do
        local alias_text = ""
        if cmd.aliases and #cmd.aliases > 0 then
            local formatted = {}
            for _, al in ipairs(cmd.aliases) do
                table.insert(formatted, "`7/ `2/" .. al)
            end
            alias_text = " " .. table.concat(formatted, " ")
        end

        local usage = cmd.usage or ("/" .. cmd.name)
        if cmd.name == "w" and config.cmd_drop_wl then usage = "/" .. config.cmd_drop_wl .. " <amt>" end
        if cmd.name == "d" and config.cmd_drop_dl then usage = "/" .. config.cmd_drop_dl .. " <amt>" end
        if cmd.name == "b" and config.cmd_drop_bgl then usage = "/" .. config.cmd_drop_bgl .. " <amt>" end
        if cmd.name == "bb" and config.cmd_drop_black then usage = "/" .. config.cmd_drop_black .. " <amt>" end
        local desc = cmd.description or ""
        table.insert(dialog, "add_smalltext|`9• `2" .. usage .. alias_text .. " `9- " .. desc .. "|left|")
    end

    table.insert(dialog, "add_spacer|small|")
    table.insert(dialog, "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|")
    table.insert(dialog, "add_quick_exit||")
    table.insert(dialog, "end_dialog|bglproxy_menu|Close||")

    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

function helpers.OpenColorDialog()
    local dialog = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|" .. config.branding .. " `eDialog Theme Customizer``|left|3494|",
        "add_spacer|small|",
        "add_label_with_icon|small|`eTheme Options|left|758|",
        "add_spacer|small|",
        "add_checkbox|cbgcolor_toggle|`2Enable Custom Dialog Theme `9(Injects custom RGB to all dialogs)|" .. (config.cbgcolor and "1" or "0") .. "|",
        "add_spacer|small|",
        "add_label_with_icon|small|`bColor Presets|left|3494|",
        "add_spacer|small|",
        "add_small_font_button|preset_neon_cyan|`c[ Cyan ]|noflags|0|0|",
        "add_small_font_button|preset_deep_purple|`5[ Purple ]|noflags|0|0|",
        "add_small_font_button|preset_dark_gold|`6[ Orange ]|noflags|0|0|",
        "add_small_font_button|preset_midnight|`b[ Black ]|noflags|0|0|",
        "add_small_font_button|preset_emerald|`2[ Green ]|noflags|0|0|",
        "add_small_font_button|preset_crimson|`4[ Red ]|noflags|0|0|",
        "add_spacer|small|",
        "add_label_with_icon|small|`9Custom Color (RGBA)|left|1368|",
        "add_smalltext|`9Format: `2Red,Green,Blue,Alpha `9(e.g. `20,200,255,255`9)|left|",
        "add_spacer|small|",
        "add_text_input|inp_border|`eBorder RGBA :|" .. config.dialogBorder .. "|30|",
        "add_text_input|inp_bg|`bBackgr RGBA :|" .. config.dialogBg .. "|30|",
        "add_spacer|small|",
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_quick_exit||",
        "end_dialog|bglproxy_colors|Cancel|`eSave Custom Theme|"
    }
    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

function helpers.OpenTpSettingsDialog()
    local is_disp = (config.tpdisplay_mode == "display_only")
    local dialog = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|" .. config.branding .. " `eTeleport & Pathfind Settings``|left|7188|",
        "add_spacer|small|",
        "add_smalltext|`9Configure click-to-teleport behavior, display block filters, and auto-return.|left|",
        "add_smalltext|`4Note: `7Hold SHIFT while clicking on any tile to fast pathfind anytime.|left|",
        "add_spacer|small|",
        "add_checkbox|tp_enabled|`2Enable Click-to-Teleport `7(Master Toggle /tp)|" .. (config.tpdisplay and "1" or "0") .. "|",
        "add_spacer|small|",
        "add_label_with_icon|small|`e1. Target Destination Mode|left|2480|",
        "max_checks|1|",
        "add_checkbox|tp_mode_all|`2All Positions `7(Teleport to any clicked tile or coordinates)|" .. (is_disp and "0" or "1") .. "|",
        "add_checkbox|tp_mode_disp|`3Display Blocks Only `7(Only activate on Display Box & Exhibition)|" .. (is_disp and "1" or "0") .. "|",
        "max_checks|9999|",
        "add_spacer|small|",
        "add_label_with_icon|small|`e2. Auto Return Settings|left|1422|",
        "add_checkbox|tp_return|`2Auto Return To Starting Position `7(Automatically return after teleport)|" .. (config.tpdisplay_return and "1" or "0") .. "|",
        "add_text_input|tp_delay|Return Delay (ms):|" .. tostring(config.tpdisplay_delay or 3000) .. "|5|",
        "add_smalltext|`4Range: 80 - 10000 ms (1000 ms = 1 sec)|left|",
        "add_spacer|small|",
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_quick_exit||",
        "end_dialog|bglproxy_tpset|Cancel|`2Save Settings|"
    }
    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

function helpers.OpenOptionDialog()
    local is_tr_in = (config.translator and config.translator.enabled) and 1 or 0
    local is_tr_out = (config.translator and config.translator.outgoing_enabled) and 1 or 0

    local active_wrench_str = "`7None (OFF)"
    if config.pull or config.wrench_mode == "pull" then
        active_wrench_str = "`2PULL"
    elseif config.kick or config.wrench_mode == "kick" then
        active_wrench_str = "`6KICK"
    elseif config.ban or config.wrench_mode == "ban" then
        active_wrench_str = "`4BAN"
    end

    local lines = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|" .. config.branding .. " `eFeature Toggle Options``|left|7188|",
        "add_spacer|small|",
        "add_smalltext|`9Manage and toggle all proxy features with instant 1-click configuration.|left|",
        "add_spacer|small|",

        "add_checkbox|opt_mf|`2Enable `1ModFly Movement|" .. (config.modfly and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Enable zero-gravity free-flight movement anywhere in the world (/mf)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_tp|`2Enable `1Click Teleport|" .. (config.tpdisplay and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Touch or click any tile to pathfind and teleport instantly (/tp)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_vendfilter|`2Enable `1Vending Cost Filter|" .. (config.vendfilter and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Display exact lock breakdown in vending purchase and info dialogs (/vendfilter)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_bsdb|`2Enable `1Block SDB|" .. (config.bsdb and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Intercept and block Super Duper Broadcast spam messages (/bsdb)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_antislave|`2Enable `1Auto Remove Spammer Slave|" .. (config.antislave and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Automatically hide and block spammer slave bots in the world (/slave)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_cbgl|`2Enable `1Telephone BGL Converter|" .. (config.cbgl and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Instantly convert 100 DL into 1 BGL via Telephone (/cbgl)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_buydl|`2Enable `1Telephone Buy DL|" .. (config.buydl and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Instantly buy 1 DL from Telephone (/buydl)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_autocombine|`2Enable `1Auto Combine Locks|" .. (config.autocombine and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Automatically convert 100 collected locks into the next tier|left|",
        "add_spacer|small|",

        "add_checkbox|opt_cbgcolor|`2Enable `1Custom Dialog Theme|" .. (config.cbgcolor and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Inject aesthetic custom colors and borders into game dialogs (/cbgcolor)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_tr_in|`2Enable `1Incoming Chat Translator|" .. is_tr_in .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Automatically translate other players' chat bubbles in realtime (/tr)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_tr_out|`2Enable `1Outgoing Chat Translator|" .. is_tr_out .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Automatically translate your typed outgoing chat messages (/tr out)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_cpull|`2Enable `1Click Pull Player|" .. (config.wrench_touch_pull and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Click or touch players while holding wrench to pull them (/cpull)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_smodal|`2Enable `1Show Player Balance|" .. (config.showbal and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Show detailed player lock balances when opened with wrench (/smodal)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_sspin|`2Enable `1Short Spin|" .. (config.sspin and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Display shortened and fast roulette wheel spin result bubble (/sspin)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_gemdetect|`2Enable `1Auto Gem Detector|" .. (config.autoGemDetect and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Show floating number particle of dropped gems on touch and spawn (/gemdetect)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_rank_titles|`2Enable `1Player & Mod Titles|" .. (config.rank_titles and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Show [@Mods] and [Player] tags above other players' heads (/titles)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_spin_titles|`2Enable `1Last Spin Title in Name|" .. (config.spin_titles and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Display latest roulette wheel spin result [0-36] next to player names (/spintitle)|left|",
        "add_spacer|small|",

        "add_checkbox|opt_show_ping|`2Enable `1Live Ping Tag in Name|" .. (config.show_ping and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Display real-time connection ping tag [`o`2XX`0] in front of your name (/pingtag)|left|",
        "add_spacer|small|",

        "add_label_with_icon|small|`ePrimary Wrench Mode Action|left|32|",
        "add_smalltext|`7Current Active Mode: " .. active_wrench_str .. "`7 (Click to switch)|left|",
        "add_spacer|small|",
        "add_custom_button|opt_wrm_pull|textLabel:`2PULL``;size:small;middle_colour:529240319;border_colour:529240319;display:block;|",
        "reset_placement_x|",
        "add_spacer|small|",
        "add_custom_margin|x:0;y:16|",
        "add_custom_button|opt_wrm_kick|textLabel:`6KICK``;size:small;middle_colour:3389566975;border_colour:3389566975;display:block;|",
        "reset_placement_x|",
        "add_spacer|small|",
        "add_custom_margin|x:0;y:16|",
        "add_custom_button|opt_wrm_ban|textLabel:`4BAN``;size:small;middle_colour:3434645503;border_colour:3434645503;display:block;|",
        "reset_placement_x|",
        "add_spacer|small|",
        "add_custom_margin|x:0;y:16|",
        "add_custom_button|opt_wrm_off|textLabel:`7OFF (Disable)``;size:small;middle_colour:1178995455;border_colour:1178995455;display:block;|",
        "reset_placement_x|",
        "add_spacer|small|",
        "add_custom_margin|x:0;y:16|",
        "add_custom_button|opt_wrm_cfg|textLabel:`9Configure Wrench Text (/wrm)``;size:small;middle_colour:431888895;border_colour:431888895;display:block;|",
        "reset_placement_x|",
        "add_spacer|small|",
        "add_custom_margin|x:0;y:16|",
        "add_custom_button|opt_open_hotkey|textLabel:`cConfigure Hotkeys (/hotkey)``;size:small;middle_colour:16755200;border_colour:16755200;display:block;|",
        "reset_placement_x|",
        "add_spacer|small|",

        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_quick_exit||",
        "end_dialog|bglproxy_options|Cancel|`2Save Options|"
    }
    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(lines, "\n") }, -1)
end

-- ==================== AUTO SUPER BROADCAST SYSTEM (/autosb) ====================

function helpers.FormatAutoSbTime(sec)
    local s = math.max(0, math.floor(tonumber(sec) or 0))
    local days = math.floor(s / 86400)
    local hours = math.floor((s % 86400) / 3600)
    local minutes = math.floor((s % 3600) / 60)
    local seconds = math.floor(s % 60)

    if days > 0 then
        return string.format("%dd %dh", days, hours)
    elseif hours > 0 then
        return string.format("%dh %dm", hours, minutes)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, seconds)
    else
        return string.format("%ds", seconds)
    end
end

function helpers.GemsToLocks(gems, is_bgems)
    local count = tonumber(gems) or 0
    if count <= 0 then return "0 WL" end

    local total_wl = is_bgems and (count * 10000) or math.floor(count / 900)
    if total_wl <= 0 then return "0 WL" end

    local wl = total_wl % 100
    local dl = math.floor(total_wl / 100) % 100
    local bgl = math.floor(total_wl / 10000) % 100
    local blk = math.floor(total_wl / 1000000)

    local parts = {}
    if blk > 0 then table.insert(parts, blk .. " BLK") end
    if bgl > 0 then table.insert(parts, bgl .. " BGL") end
    if dl > 0 then table.insert(parts, dl .. " DL") end
    if wl > 0 or #parts == 0 then table.insert(parts, wl .. " WL") end

    return table.concat(parts, " ")
end

function helpers.SendAutoSbWebhook(text_sb, remaining_sb, time_left)
    if type(MakeRequest) ~= "function" then return end
    local url = config.autosb_webhook_url
    if not url or url == "" or not url:find("https://") then return end

    RunThread(function()
        local ok_local, local_player = pcall(GetLocal)
        local raw_name = (ok_local and local_player and local_player.name) and tostring(local_player.name) or "Unknown"
        local clean_name = raw_name:gsub("`.", ""):match("%S+") or "Player"
        local world_str = autosb_state.world_name or (GetWorld() and GetWorld().name) or "UNKNOWN"

        local is_bgems = (autosb_state.gems_type == "BGems")
        local type_label = is_bgems and "BGems" or "Gems"
        local used_num = is_bgems and autosb_state.bgems_used or autosb_state.gems_used
        local left_num = is_bgems and autosb_state.bgems_left or autosb_state.gems_left
        local total_used_num = is_bgems and autosb_state.total_bgems_used or autosb_state.total_gems_used
        local lock_cost_str = helpers.GemsToLocks(total_used_num, is_bgems)

        local clean_sb_text = tostring(text_sb or ""):gsub("`.", ""):gsub('"', '\\"'):gsub("\n", " ")
        local uptime_str = helpers.FormatAutoSbTime(os.time() - (autosb_state.start_time > 0 and autosb_state.start_time or os.time()))

        local payload = string.format([[
{
  "embeds": [{
    "author": { "name": "DODGED - Auto Super Broadcast" },
    "color": 3447003,
    "fields": [
      { "name": "👤 Account", "value": "%s", "inline": true },
      { "name": "🌍 World | Time Left", "value": "%s | %s", "inline": true },
      { "name": "📜 Broadcast Text", "value": "%s", "inline": false },
      { "name": "📢 Progress", "value": "Sent: **%d**\\nTarget: **%d**\\nRemaining: **%d**", "inline": true },
      { "name": "💎 Gems Info (%s)", "value": "Owned: **%s**\\nLast Used: **%s**\\nTotal Used: **%s**", "inline": true },
      { "name": "🔒 Equivalent Lock Cost", "value": "%s", "inline": true }
    ],
    "footer": { "text": "DODGED Auto SB • Uptime: %s" }
  }]
}]],
            clean_name,
            world_str,
            tostring(time_left or "0s"),
            clean_sb_text,
            autosb_state.start_count,
            autosb_state.total,
            tonumber(remaining_sb) or 0,
            type_label,
            helpers.FormatNumber(left_num),
            helpers.FormatNumber(used_num),
            helpers.FormatNumber(total_used_num),
            lock_cost_str,
            uptime_str
        )

        pcall(MakeRequest, url, "POST", { ["Content-Type"] = "application/json" }, payload)
    end)
end

function helpers.StartAutoSB()
    if autosb_state.running then
        helpers.SayClean("`4Auto SB is already running!")
        return
    end

    local raw_text = (config.autosb_text or ""):gsub("^%s*(.-)%s*$", "%1")
    if raw_text == "" then
        helpers.SayClean("`4Auto SB text is empty! Set text in /autosb or wrench a sign.")
        helpers.OnTextOverlay("`4Auto SB text is empty!")
        helpers.OpenAutoSbDialog()
        return
    end

    autosb_state.running = true
    autosb_state.start_time = os.time()
    autosb_state.start_count = tonumber(config.autosb_start_count) or 0
    autosb_state.total = tonumber(config.autosb_total) or 20
    if autosb_state.total <= 0 then autosb_state.total = 20 end

    local ok_w, cur_w = pcall(GetWorld)
    autosb_state.world_name = (ok_w and cur_w and cur_w.name and cur_w.name ~= "") and cur_w.name or "UNKNOWN"

    helpers.OnTextOverlay("`2Auto SB Started! `9(" .. autosb_state.start_count .. " / " .. autosb_state.total .. ")")
    helpers.SayClean("`2[AutoSB] Started! Target: `0" .. autosb_state.total .. " `2SB in World: `0" .. autosb_state.world_name)
    helpers.OnConsoleMessage("`2[AutoSB] Running broadcast loop. Target: " .. autosb_state.total .. " SBs.")

    RunThread(function()
        while autosb_state.running do
            -- 1. Auto Reconnection check
            local ok_world, world_obj = pcall(GetWorld)
            if not ok_world or not world_obj or world_obj.name == "EXIT" or world_obj.name == "" then
                helpers.OnTextOverlay("`eRe-entering world " .. autosb_state.world_name .. "...")
                SendPacket(3, "action|join_request\nname|" .. autosb_state.world_name .. "\ninvitedWorld|0")
                Sleep(5000)
            else
                local target_tag = (config.autosb_tag and config.autosb_tag ~= "") and config.autosb_tag or "`e#DODGED"
                local sb_msg = config.autosb_text
                if not sb_msg:lower():find("^/sb") then
                    sb_msg = "/sb " .. sb_msg
                end
                if not sb_msg:find(target_tag, 1, true) then
                    sb_msg = sb_msg .. " " .. target_tag
                end

                autosb_state.success_flag = false
                SendPacket(2, "action|input\n|text|" .. config.branding .. " `2Broadcasting SB...\n")
                Sleep(1000)
                if not autosb_state.running then break end
                SendPacket(2, "action|input\n|text|" .. sb_msg .. "\n")

                -- Wait up to 5s for server console response
                local wait_start = os.clock()
                while autosb_state.running and not autosb_state.success_flag and (os.clock() - wait_start) < 5.0 do
                    Sleep(100)
                end

                if autosb_state.success_flag then
                    autosb_state.start_count = autosb_state.start_count + 1
                    config.autosb_start_count = autosb_state.start_count
                    auto_save_config()

                    local remaining = math.max(0, autosb_state.total - autosb_state.start_count)
                    local time_left_sec = remaining * 3 * 60
                    local time_left_str = helpers.FormatAutoSbTime(time_left_sec)

                    local is_bgems = (autosb_state.gems_type == "BGems")
                    local used_num = is_bgems and autosb_state.bgems_used or autosb_state.gems_used
                    local total_used_num = is_bgems and autosb_state.total_bgems_used or autosb_state.total_gems_used
                    local type_label = is_bgems and " `sBGems" or " `8Gems"

                    Sleep(800)
                    if not autosb_state.running then break end
                    SendPacket(2, "action|input\n|text|" .. config.branding .. " `9SB TOTAL: `b[`2" .. autosb_state.start_count .. "/" .. autosb_state.total .. "`b]\n")
                    Sleep(1000)
                    if not autosb_state.running then break end
                    SendPacket(2, "action|input\n|text|" .. config.branding .. " `cUsed: `9" .. helpers.FormatNumber(used_num) .. type_label .. " `4// `cTotal: `9" .. helpers.FormatNumber(total_used_num) .. type_label .. "\n")
                    Sleep(1000)
                    if not autosb_state.running then break end
                    SendPacket(2, "action|input\n|text|" .. config.branding .. " `b[`2" .. time_left_str .. "`b] `9Left `b// `9Remaining: `b[`2" .. remaining .. "`b]\n")

                    if config.autosb_webhook_enabled and config.autosb_webhook_url and config.autosb_webhook_url ~= "" then
                        helpers.SendAutoSbWebhook(sb_msg, remaining, time_left_str)
                    end

                    if autosb_state.start_count >= autosb_state.total then
                        break
                    end

                    -- Safe interruptible sleep for ~174s cooldown
                    local sleep_rem = 174000
                    while autosb_state.running and sleep_rem > 0 do
                        Sleep(math.min(1000, sleep_rem))
                        sleep_rem = sleep_rem - 1000
                    end
                else
                    helpers.OnTextOverlay("`4SB not confirmed! Retrying in 10s...")
                    helpers.OnConsoleMessage("`4[AutoSB] Server didn't confirm SB. Waiting 10s before retry...")
                    local retry_rem = 10000
                    while autosb_state.running and retry_rem > 0 do
                        Sleep(1000)
                        retry_rem = retry_rem - 1000
                    end
                end
            end
        end

        if autosb_state.running and autosb_state.start_count >= autosb_state.total then
            Sleep(800)
            SendPacket(2, "action|input\n|text|" .. config.branding .. " `2Auto SB Completed! Thanks for using DODGED Proxy.\n")
            helpers.OnTextOverlay("`2Auto SB Completed! (" .. autosb_state.total .. " SBs Sent)")
            helpers.OnConsoleMessage("`2[AutoSB] Finished sending all " .. autosb_state.total .. " broadcasts.")
        end

        autosb_state.running = false
    end)
end

function helpers.StopAutoSB()
    if not autosb_state.running then
        helpers.SayClean("`4Auto SB is not running.")
        return
    end
    autosb_state.running = false
    helpers.OnTextOverlay("`4Auto SB Stopped!")
    helpers.SayClean("`4[AutoSB] Stopped by user.")
    helpers.OnConsoleMessage("`4[AutoSB] Broadcast loop terminated.")
end

function helpers.ResetAutoSBStats()
    autosb_state.start_count = 0
    config.autosb_start_count = 0
    autosb_state.total_gems_used = 0
    autosb_state.total_bgems_used = 0
    autosb_state.gems_used = 0
    autosb_state.bgems_used = 0
    autosb_state.gems_left = 0
    autosb_state.bgems_left = 0
    auto_save_config()
    helpers.OnTextOverlay("`eAuto SB stats & counter reset!")
    helpers.SayClean("`e[AutoSB] Stats and counters reset to 0.")
    helpers.OnConsoleMessage("`e[AutoSB] Counter and gem statistics reset.")
end

function helpers.OpenAutoSbDialog()
    local is_running = autosb_state.running
    local status_str = is_running and ("`2RUNNING `8(" .. autosb_state.start_count .. " / " .. autosb_state.total .. ")") or "`4IDLE"
    local cur_w = (GetWorld() and GetWorld().name and GetWorld().name ~= "") and GetWorld().name or "UNKNOWN"

    local remaining = math.max(0, (tonumber(config.autosb_total) or 20) - (tonumber(config.autosb_start_count) or 0))
    local time_left_str = helpers.FormatAutoSbTime(remaining * 3 * 60)

    local clean_text = (config.autosb_text or ""):gsub("\n", " ")
    local clean_tag = config.autosb_tag or "`c#BGL`#Proxy"
    local clean_url = config.autosb_webhook_url or ""

    local lines = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|`2Auto Super Broadcast|left|2480|",
        "add_spacer|small|",
        "add_smalltext|`7Status: " .. status_str .. " `7| World: `0" .. cur_w .. " `7| Est. Time Left: `9" .. time_left_str .. "|left|",
        "add_spacer|small|",

        "add_checkbox|autosb_copysign|`2Scan text when wrenching Sign|" .. (config.autosb_copysign and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Wrench any sign to automatically capture text into this dialog|left|",
        "add_spacer|small|",

        "add_checkbox|autosb_autostart|`4Auto-start immediately after scanning sign|" .. (config.autosb_autostart and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Default OFF (Safe). When ON, wrenching a sign starts broadcasting instantly|left|",
        "add_spacer|small|",

        "add_text_input|autosb_text|`9SB Text Message:|`0" .. clean_text .. "|128|",
        "add_spacer|small|",

        "add_text_input|autosb_tag|`eCustom SB Tag:|`0" .. clean_tag .. "|30|",
        "add_spacer|small|",

        "add_text_input|autosb_start|`2Start Counter (Offset):|`0" .. tostring(config.autosb_start_count or 0) .. "|5|",
        "add_spacer|small|",

        "add_text_input|autosb_total|`eTotal Target Broadcasts:|`0" .. tostring(config.autosb_total or 20) .. "|5|",
        "add_spacer|small|",

        "add_checkbox|autosb_webhook|`2Enable Discord Webhook Report|" .. (config.autosb_webhook_enabled and 1 or 0) .. "|",
        "add_custom_margin|x:0;y:-35|",
        "add_smalltext|`7Sends rich embed with progress, gems used, and lock cost to Discord|left|",
        "add_spacer|small|",

        "add_text_input|autosb_webhook_url|`bDiscord Webhook URL:|`0" .. clean_url .. "|150|",
        "add_spacer|small|",

        "add_label_with_icon|small|`eBroadcast Actions|left|658|",
        "add_spacer|small|"
    }

    if is_running then
        table.insert(lines, "add_custom_button|autosb_btn_stop|textLabel:`4STOP AUTO SB``;size:small;middle_colour:3434645503;border_colour:3434645503;display:block;|")
    else
        table.insert(lines, "add_custom_button|autosb_btn_start|textLabel:`2START AUTO SB``;size:small;middle_colour:529240319;border_colour:529240319;display:block;|")
    end
    table.insert(lines, "reset_placement_x|")
    table.insert(lines, "add_spacer|small|")
    table.insert(lines, "add_custom_margin|x:0;y:16|")
    table.insert(lines, "add_custom_button|autosb_btn_reset|textLabel:`6RESET COUNTER & STATS``;size:small;middle_colour:3389566975;border_colour:3389566975;display:block;|")
    table.insert(lines, "reset_placement_x|")
    table.insert(lines, "add_spacer|small|")
    table.insert(lines, "add_custom_margin|x:0;y:16|")
    table.insert(lines, "add_custom_button|autosb_btn_log|textLabel:`9VIEW FULL STATS & LOGS (/sblog)``;size:small;middle_colour:431888895;border_colour:431888895;display:block;|")
    table.insert(lines, "reset_placement_x|")
    table.insert(lines, "add_spacer|small|")

    table.insert(lines, "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj|")
    table.insert(lines, "add_quick_exit||")
    table.insert(lines, "end_dialog|bglproxy_autosb|Cancel|`2Save Settings|")

    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(lines, "\n") }, -1)
end

function helpers.OpenAutoSbLogDialog()
    local is_running = autosb_state.running
    local status_str = is_running and "`2RUNNING" or "`4IDLE"
    local cur_w = (GetWorld() and GetWorld().name and GetWorld().name ~= "") and GetWorld().name or "UNKNOWN"

    local is_bgems = (autosb_state.gems_type == "BGems")
    local type_label = is_bgems and " `sBGems" or " `8Gems"
    local used_num = is_bgems and autosb_state.bgems_used or autosb_state.gems_used
    local left_num = is_bgems and autosb_state.bgems_left or autosb_state.gems_left
    local total_used_num = is_bgems and autosb_state.total_bgems_used or autosb_state.total_gems_used
    local lock_cost = helpers.GemsToLocks(total_used_num, is_bgems)

    local remaining = math.max(0, (tonumber(config.autosb_total) or 20) - (tonumber(config.autosb_start_count) or 0))
    local time_left_str = helpers.FormatAutoSbTime(remaining * 3 * 60)
    local uptime_str = helpers.FormatAutoSbTime(os.time() - (autosb_state.start_time > 0 and autosb_state.start_time or os.time()))

    local lines = {
        "set_default_color|" .. config.dialogDefaultColor,
        "set_border_color|" .. config.dialogBorder,
        "set_bg_color|" .. config.dialogBg,
        "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj|",
        "add_label_with_icon|big|`0Super Broadcast Statistics||2480|",
        "add_spacer|small|",
        "add_label_with_icon|small|`2Status `b: " .. status_str .. "|left|482|",
        "add_label_with_icon|small|`2Target World `b: `c" .. cur_w .. "|left|482|",
        "add_label_with_icon|small|`2Broadcast Progress `b: `9" .. autosb_state.start_count .. " `bof `9" .. (config.autosb_total or 20) .. " `4SB|left|482|",
        "add_label_with_icon|small|`2Remaining `b: `9" .. remaining .. " `4SB `cII `9" .. time_left_str .. " `cleft|left|482|",
        "add_label_with_icon|small|`2Last SB Gems `b: `9" .. helpers.FormatNumber(used_num) .. type_label .. "|left|482|",
        "add_label_with_icon|small|`2Total Gems Used `b: `9" .. helpers.FormatNumber(total_used_num) .. type_label .. "|left|482|",
        "add_label_with_icon|small|`2Gems Remaining `b: `9" .. helpers.FormatNumber(left_num) .. type_label .. "|left|482|",
        "add_label_with_icon|small|`2Equivalent Lock Costs `b: `9" .. lock_cost .. "|left|482|",
        "add_label_with_icon|small|`2Session Uptime `b: `9" .. uptime_str .. "|left|482|",
        "add_spacer|small|",
        "add_smalltext|`bPowered By `eDODGED `9Proxy|",
        "add_quick_exit||",
        "end_dialog|bglproxy_sblog|Close||"
    }

    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(lines, "\n") }, -1)
end

-- =========================== AUTO SPAM ENGINE (/spam) ===========================

helpers.SpamThreadRunning = false

local SPAM_COLORS = { "`2", "`3", "`4", "`5", "`6", "`7", "`8", "`9", "`b", "`p", "`c", "`e", "`o" }

function helpers.FormatSpamText(raw_text)
    if not raw_text or raw_text == "" then return "" end
    if config.spam_rainbow then
        local out = {}
        local col_idx = 1
        local len = #raw_text
        for i = 1, len do
            local ch = raw_text:sub(i, i)
            if ch == " " or ch == "\t" then
                table.insert(out, ch)
            else
                local col = SPAM_COLORS[col_idx]
                table.insert(out, col .. ch)
                col_idx = (col_idx % #SPAM_COLORS) + 1
            end
        end
        return table.concat(out)
    elseif config.spam_random_color then
        local rnd_col = SPAM_COLORS[math.random(1, #SPAM_COLORS)]
        return rnd_col .. raw_text
    else
        return raw_text
    end
end

function helpers.StartSpamThread()
    if helpers.SpamThreadRunning then return end
    helpers.SpamThreadRunning = true
    RunThread(function()
        local slot_idx = 1
        while config.spam_enabled do
            local slots = config.spam_slots
            if not slots or #slots == 0 then
                Sleep(1000)
            else
                local active_slots = {}
                for _, s in ipairs(slots) do
                    if s.active ~= false and s.text and s.text ~= "" then
                        table.insert(active_slots, s)
                    end
                end

                if #active_slots == 0 then
                    Sleep(500)
                else
                    if slot_idx > #active_slots then
                        slot_idx = 1
                    end
                    local current_slot = active_slots[slot_idx]
                    local text = current_slot.text or ""
                    local formatted = helpers.FormatSpamText(text)
                    SendPacket(2, "action|input\n|text|" .. formatted .. "\n")

                    local delay = tonumber(current_slot.delay) or 3000
                    if delay < 200 then delay = 200 end

                    slot_idx = slot_idx + 1
                    if slot_idx > #active_slots then
                        slot_idx = 1
                    end

                    local elapsed = 0
                    while config.spam_enabled and elapsed < delay do
                        local step = math.min(100, delay - elapsed)
                        Sleep(step)
                        elapsed = elapsed + step
                    end
                end
            end
        end
        helpers.SpamThreadRunning = false
    end)
end

function helpers.StopSpamThread()
    config.spam_enabled = false
    helpers.SpamThreadRunning = false
end

function helpers.ToggleSpam(state)
    if state == nil then
        state = not config.spam_enabled
    end
    config.spam_enabled = state
    if config.spam_enabled then
        helpers.OnTextOverlay(config.branding .. " `2Auto-Spam STARTED")
        helpers.OnConsoleMessage("`2[Spam] Auto-Spam is now STARTED.")
        helpers.StartSpamThread()
    else
        helpers.OnTextOverlay(config.branding .. " `4Auto-Spam STOPPED")
        helpers.OnConsoleMessage("`4[Spam] Auto-Spam is now STOPPED.")
        helpers.StopSpamThread()
    end
    auto_save_config(true)
end

function helpers.ShowSpamDialog()
    if not config.spam_slots or type(config.spam_slots) ~= "table" or #config.spam_slots == 0 then
        config.spam_slots = {
            { active = true, text = "HALLO 1", delay = 3000 },
            { active = true, text = "HALLO 2", delay = 3000 },
            { active = true, text = "HALLO 3", delay = 3000 }
        }
    end

    local spam_badge = config.spam_enabled and "`2[RUNNING]" or "`4[STOPPED]"
    local pwr_btn = config.spam_enabled and "add_button|btn_toggle_spam|`4[ STOP SPAM ]|noflags|0|0|" or "add_button|btn_toggle_spam|`2[ START SPAM ]|noflags|0|0|"

    local dialog = {
        "set_default_color|" .. (config.dialogDefaultColor or "`o"),
        "set_border_color|" .. (config.dialogBorder or "0,200,255,255"),
        "set_bg_color|" .. (config.dialogBg or "30,30,30,225"),
        "add_label_with_icon|big|`eDODGED `0:: Automation Spam|left|16824|",
        "add_smalltext|`7Multi-slot automated chat spammer with per-message delay|left|",
        "add_spacer|small|",
        "add_textbox|`0Status: " .. spam_badge .. " `0| Total Slots: `9" .. #config.spam_slots .. "|left|",
        pwr_btn,
        "add_spacer|small|",
        "add_checkbox|chk_rainbow|Enable Rainbow Spam|" .. (config.spam_rainbow and 1 or 0) .. "|",
        "add_checkbox|chk_random|Enable Spam Random Color|" .. (config.spam_random_color and 1 or 0) .. "|",
        "add_spacer|small|",
        "add_label_with_icon|small|`0Message Slots & Delays|left|16824|"
    }

    for i = 1, #config.spam_slots do
        local slot = config.spam_slots[i]
        local is_act = (slot.active ~= false) and 1 or 0
        table.insert(dialog, "add_checkbox|chk_slot_active_" .. i .. "|Use Text " .. i .. "|" .. is_act .. "|")
        table.insert(dialog, "add_text_input|input_spam_text_" .. i .. "|Message " .. i .. ":|" .. (slot.text or "") .. "|64|")
        table.insert(dialog, "add_text_input|input_spam_delay_" .. i .. "|Delay " .. i .. " (ms):|" .. (slot.delay or 3000) .. "|6|")
        table.insert(dialog, "add_spacer|small|")
    end

    table.insert(dialog, "add_small_font_button|btn_add_spam_field|`2[+] Add More Slot|noflags|0|0|")
    if #config.spam_slots > 1 then
        table.insert(dialog, "add_small_font_button|btn_rem_spam_field|`4[-] Remove Last Slot|noflags|0|0|")
    end

    table.insert(dialog, "add_spacer|small|")
    table.insert(dialog, "add_button|btn_save_spam|`9Save Configuration|noflags|0|0|")
    table.insert(dialog, "add_spacer|small|")
    table.insert(dialog, "text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjjjj|")
    table.insert(dialog, "add_quick_exit||")
    table.insert(dialog, "add_button|menuu|Back|noflags|0|0|")
    table.insert(dialog, "end_dialog|dodged_spam|Close||")

    SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") }, -1)
end

-- =========================== WORLD TOUCH & TELEPORT HOOKS ===========================

function HandleWorldTouch(pos, start)
    if not (pos and pos.x and pos.y) or not start then
        return false
    end

    local clickX = math.floor(pos.x / 32)
    local clickY = math.floor(pos.y / 32)

    -- 1. CTRL + CLICK (Instant Remote Collect Only)
    if config.tp_ctrl_click_enabled and helpers.IsCtrlPhysicallyHeld() then
        local ok_loc, localPlayer = pcall(GetLocal)
        if ok_loc and localPlayer and localPlayer.netid then
            helpers.TakeAtTile(clickX, clickY)
            helpers.SendTileEffect(clickX * 32 + 16, clickY * 32 + 16)
            return true
        end
    end

    -- 2. SHIFT + CLICK (Smooth Pathfind Teleport)
    if config.tp_shift_click_enabled and helpers.IsShiftPhysicallyHeld() and not helpers.IsCtrlPhysicallyHeld() then
        local ok_loc, localPlayer = pcall(GetLocal)
        if ok_loc and localPlayer and localPlayer.netid then
            helpers.SendTileEffect(clickX * 32 + 16, clickY * 32 + 16)
            pcall(FindPath, clickX, clickY)
            return true
        end
    end

    -- 3. Click Player Pull (/cp / /cpull)
    if config.wrench_touch_pull then
        local ok_items, player_items = pcall(GetPlayerItems)
        local selected_item = ok_items and player_items and player_items.backpack and tonumber(player_items.backpack.selected) or 0
        if selected_item == ITEM_IDS.WRENCH then
            local target_player = helpers.FindPlayerAtTile(clickX, clickY, pos)
            if target_player and target_player.netid then
                helpers.SendTileEffect(pos.x, pos.y)
                
                RunThread(function()
                    helpers.ExecuteWrenchActions(target_player.netid, target_player.name or "Unknown", {
                        force_pull = true,
                        allow_showbal = true
                    })
                end)
                return true
            end
        end
    end

    -- 4. Click-to-Teleport (/tp & /tpset)
    if config.tpdisplay then
        local target_tile = GetTile(clickX, clickY)
        local target_fg = target_tile and target_tile.fg or 0

        local should_tp = false
        if config.tpdisplay_mode == "display_only" then
            if target_fg == 1422 or target_fg == 2488 then
                should_tp = true
            end
        else
            should_tp = true
        end

        if should_tp then
            RunThread(function(tx, ty)
                local start_x, start_y = nil, nil
                if config.tpdisplay_return then
                    local ok, localPlayer = pcall(GetLocal)
                    if ok and localPlayer and localPlayer.pos then
                        start_x = math.floor(localPlayer.pos.x / 32)
                        start_y = math.floor(localPlayer.pos.y / 32)
                    end
                end

                helpers.SendTileEffect(tx * 32 + 16, ty * 32 + 16)
                pcall(FindPath, tx, ty)

                if config.tpdisplay_return and start_x and start_y then
                    local delay_ms = math.max(80, math.min(10000, tonumber(config.tpdisplay_delay) or 3000))
                    Sleep(delay_ms)
                    pcall(FindPath, start_x, start_y)
                end
            end, clickX, clickY)
            return true
        end
    end

    return false
end

-- ==================== GEM DETECTOR HOOK HANDLERS ====================
local gem_touch_last_trigger = {}
function HandleGemWorldTouch(pos, start)
    if not config.autoGemDetect or not start then return false end
    if not pos or not pos.x or not pos.y then return false end

    local tileX = math.floor(pos.x / 32)
    local tileY = math.floor(pos.y / 32)

    local now_ms = math.floor(os.clock() * 1000)
    local key = tileX .. "_" .. tileY
    if (now_ms - (gem_touch_last_trigger[key] or 0)) < 250 then
        return false
    end

    local ok_objs, objs = pcall(GetObjectList)
    if ok_objs and objs then
        local total = 0
        for _, o in pairs(objs) do
            if o and o.id == ITEM_IDS.GEMS and o.pos and math.floor(o.pos.x / 32) == tileX and math.floor(o.pos.y / 32) == tileY then
                total = total + (tonumber(o.amount) or 0)
            end
        end
        if total > 0 then
            gem_touch_last_trigger[key] = now_ms
            helpers.SendFloatingNumber(total, tileX, tileY)
        end
    end
    return false
end

local last_champagne_logged_time = 0

function HandleTeleportBlock(packet)
    if not packet then
        return false
    end

    helpers.HandleStorageTankPacket(packet)

    local ctrl_active = config.tp_ctrl_click_enabled and helpers.IsCtrlPhysicallyHeld()
    local shift_active = config.tp_shift_click_enabled and helpers.IsShiftPhysicallyHeld()

    -- Block game punch/place action packet while Ctrl or Shift is active
    if (ctrl_active or shift_active) and packet.type == 3 then
        return true
    end

    -- Hook: Champagne use detection (TankPacket type: 3 and value: champagne ID)
    if packet.type == 3 and packet.value then
        local p_val = tonumber(packet.value) or 0
        local champ_id = get_champagne_item_id()
        if p_val == champ_id or p_val == 17062 or p_val == 1974 then
            local now = os.time()
            if (now - last_champagne_logged_time) >= 1 then
                last_champagne_logged_time = now
                local count_before = get_safe_item_count(champ_id)
                RunThread(function()
                    Sleep(200)
                    local count_after = get_safe_item_count(champ_id)
                    local left = count_after
                    if left >= count_before and count_before > 0 then
                        left = count_before - 1
                    end
                    helpers.SendChampagneWebhook(left)
                end)
            end
        end
    end

    return false
end

-- Gem Detector Tank Update Hook
local pendingGems = {}
function HandleGemDetector(packet)
    if packet then
        helpers.HandleStorageTankPacket(packet)
    end
    if not config.autoGemDetect or not packet then
        return false
    end

    if packet.type == 14 and packet.value == ITEM_IDS.GEMS then
        local tx = math.floor((packet.x or 0) / 32)
        local ty = math.floor((packet.y or 0) / 32)
        local key = tx .. "_" .. ty

        if not pendingGems[key] then
            pendingGems[key] = { x = tx, y = ty, amt = 0, done = false, px = packet.x, py = packet.y }
        end

        pendingGems[key].amt = pendingGems[key].amt + math.floor(packet.padding4 or 0)
        pendingGems[key].px = packet.x
        pendingGems[key].py = packet.y

        if not pendingGems[key].done then
            pendingGems[key].done = true
            RunDelayed(200, function()
                local d = pendingGems[key]
                if d then
                    local total = 0
                    local ok_objs, objs = pcall(GetObjectList)
                    if ok_objs and objs then
                        for _, o in pairs(objs) do
                            if o and o.id == ITEM_IDS.GEMS and o.pos and math.floor(o.pos.x / 32) == d.x and math.floor(o.pos.y / 32) == d.y then
                                total = total + (tonumber(o.amount) or 0)
                            end
                        end
                    end
                    if total > 0 then
                        helpers.SendFloatingNumber(total, d.px, d.py)
                    end
                    pendingGems[key] = nil
                end
            end)
        end
    end
    return false
end

-- =========================== REGISTERED PROXY COMMANDS (add_command) ===========================

add_command({
    name = "gui",
    aliases = { "panel", "dashboard", "dev", "imgui" },
    usage = "/gui",
    description = "Open Modern ImGui Dashboard & Developer Panel (F1)",
    handler = function(args, full_cmd)
        helpers.ToggleGui()
        return true
    end
})

add_command({
    name = "proxy",
    aliases = { "dproxy", "dodged" },
    usage = "/proxy",
    description = "Open DODGED main control center",
    handler = function(args, full_cmd)
        helpers.OpenProxyDialog()
        return true
    end
})

add_command({
    name = "spam",
    aliases = {},
    usage = "/spam",
    description = "Open automated chat spammer dialog",
    handler = function(args, full_cmd)
        helpers.ShowSpamDialog()
        return true
    end
})

add_command({
    name = "menu",
    aliases = { "bgl", "help", "commands" },
    usage = "/menu",
    description = "Display all available proxy commands",
    handler = function(args, full_cmd)
        helpers.OpenMenuDialog()
        return true
    end
})

add_command({
    name = "option",
    aliases = { "opt", "options" },
    usage = "/option",
    description = "Quick 1-click feature options dialog",
    handler = function(args, full_cmd)
        helpers.OpenOptionDialog()
        return true
    end
})

add_command({
    name = "hotkey",
    aliases = { "hk", "hotkeys" },
    usage = "/hotkey",
    description = "Custom hotkey manager and key bindings",
    handler = function(args, full_cmd)
        helpers.HotkeyDialog()
        return true
    end
})

add_command({
    name = "wrm",
    aliases = { "wrench" },
    usage = "/wrm",
    description = "Configure custom wrench action messages",
    handler = function(args, full_cmd)
        helpers.WrenchModeDialog()
        return true
    end
})

add_command({
    name = "setcmd",
    aliases = { "customcmd", "cmdset" },
    usage = "/setcmd",
    description = "Configure custom drop command prefixes",
    handler = function(args, full_cmd)
        helpers.CustomCommandDialog()
        return true
    end
})

add_command({
    name = "cbgcolor",
    aliases = { "theme" },
    usage = "/cbgcolor",
    description = "Customize dialog border and background RGBA colors",
    handler = function(args, full_cmd)
        helpers.OpenColorDialog()
        return true
    end
})

add_command({
    name = "skin",
    aliases = {},
    usage = "/skin",
    description = "Open 16-color instant skin tone picker",
    handler = function(args, full_cmd)
        helpers.OpenSkinDialog()
        return true
    end
})

add_command({
    name = "vendfilter",
    aliases = { "vf" },
    usage = "/vendfilter",
    description = "Toggle automatic lock converter for Vending purchases",
    handler = function(args, full_cmd)
        config.vendfilter = not config.vendfilter
        local status = config.vendfilter and "`2ENABLED" or "`4DISABLED"
        helpers.OnTextOverlay(config.branding .. " `eVending Cost Filter: " .. status)
        helpers.Say("`eVending Cost Filter: " .. status)
        helpers.OnConsoleMessage("`eVending Cost Filter: " .. status)
        auto_save_config()
        return true
    end
})

add_command({
    name = "blue",
    aliases = {},
    usage = "/blue",
    description = "Convert 1 Black Gem Lock into 100 Blue Gem Locks",
    handler = function(args, full_cmd)
        helpers.ConvertBlackToBlue()
        return true
    end
})

add_command({
    name = "black",
    aliases = {},
    usage = "/black",
    description = "Convert 100 Blue Gem Locks into 1 Black Gem Lock",
    handler = function(args, full_cmd)
        helpers.ConvertBlueToBlack()
        return true
    end
})

add_command({
    name = "tr",
    aliases = { "translate", "trans" },
    usage = "/tr <en|id|out|on|off|slave|key|test>",
    description = "Realtime AI chat translator",
    handler = function(args_clean, full_cmd)
        local sub_arg, extra_arg = tostring(args_clean or ""):match("^([^%s]+)%s*(.-)$")
        sub_arg = (sub_arg or ""):lower():gsub("^%s*(.-)%s*$", "%1")
        extra_arg = tostring(extra_arg or ""):gsub("^%s*(.-)%s*$", "%1")

        config.translator = config.translator or {
            enabled              = false,
            outgoing_enabled     = false,
            api_key              = "AQ.Ab8RN6J1pArBA_ku1P2z_naW-to9tVCt7pvIQH0PT7t_Lg7SLw",
            target_lang          = "en",
            outgoing_target_lang = "en",
            show_bubble          = true,
            show_console         = true,
            skip_same_lang       = true,
            filter_slave         = true
        }

        if sub_arg == "en" or sub_arg == "english" then
            config.translator.enabled = true
            config.translator.target_lang = "en"
            config.translator.outgoing_target_lang = "en"
            helpers.OnTextOverlay(config.branding .. " `3Translator: ENGLISH (ON)")
            helpers.Say("`2[Translator] Target set to `3English `7(ID -> EN)`2. Status: `2ON")
            helpers.OnConsoleMessage("`2[Translator] Target set to `3English`2. Status: `2ON")
            auto_save_config()
            return true
        elseif sub_arg == "id" or sub_arg == "indo" or sub_arg == "indonesia" or sub_arg == "indonesian" then
            config.translator.enabled = true
            config.translator.target_lang = "id"
            config.translator.outgoing_target_lang = "id"
            helpers.OnTextOverlay(config.branding .. " `2Translator: INDONESIA (ON)")
            helpers.Say("`2[Translator] Target set to `2Indonesian `7(EN -> ID)`2. Status: `2ON")
            helpers.OnConsoleMessage("`2[Translator] Target set to `2Indonesian`2. Status: `2ON")
            auto_save_config()
            return true
        elseif sub_arg == "out" or sub_arg == "outgoing" then
            config.translator.outgoing_enabled = not config.translator.outgoing_enabled
            local out_st = config.translator.outgoing_enabled and "`2ON" or "`4OFF"
            helpers.OnTextOverlay(config.branding .. " `eOutgoing Translator: " .. out_st)
            helpers.Say("`eOutgoing Translator: " .. out_st)
            helpers.OnConsoleMessage("`eOutgoing Translator toggled: " .. out_st)
            auto_save_config()
            return true
        elseif sub_arg == "on" or sub_arg == "1" or sub_arg == "enable" then
            config.translator.enabled = true
            helpers.OnTextOverlay(config.branding .. " `2Translator: ENABLED (" .. config.translator.target_lang:upper() .. ")")
            helpers.Say("`2[Translator] Status: `2ON `0| Target: `e" .. config.translator.target_lang:upper())
            helpers.OnConsoleMessage("`2[Translator] Status: `2ON | Target: " .. config.translator.target_lang:upper())
            auto_save_config()
            return true
        elseif sub_arg == "off" or sub_arg == "0" or sub_arg == "disable" then
            config.translator.enabled = false
            helpers.OnTextOverlay(config.branding .. " `4Translator: DISABLED")
            helpers.Say("`4[Translator] Status: `4OFF")
            helpers.OnConsoleMessage("`4[Translator] Status: `4OFF")
            auto_save_config()
            return true
        elseif sub_arg == "slave" or sub_arg == "filterslave" or sub_arg == "spammer" then
            config.translator.filter_slave = not (config.translator.filter_slave ~= false)
            local sl_st = config.translator.filter_slave and "`2ON" or "`4OFF"
            helpers.OnTextOverlay(config.branding .. " `eFilter Spammer Slave: " .. sl_st)
            helpers.Say("`eFilter Spammer Slave: " .. sl_st)
            helpers.OnConsoleMessage("`eFilter Spammer Slave toggled: " .. sl_st)
            auto_save_config()
            return true
        elseif sub_arg == "key" and extra_arg ~= "" then
            config.translator.api_key = extra_arg
            helpers.OnTextOverlay(config.branding .. " `2AI API Key Updated!")
            helpers.Say("`2[Translator] AI API Key has been updated.")
            helpers.OnConsoleMessage("`2[Translator] AI API Key has been updated.")
            auto_save_config()
            return true
        elseif sub_arg == "test" and extra_arg ~= "" then
            helpers.OnConsoleMessage("`e[Translator] Testing AI translation for: \"" .. extra_arg .. "\"...")
            RunThread(function(test_text)
                local target_l = config.translator.target_lang or "id"
                local t_res = helpers.TranslateText(test_text, target_l)
                if t_res then
                    helpers.OnConsoleMessage("`2[Translator Result (" .. target_l:upper() .. ")] " .. t_res)
                    helpers.OnTextOverlay("`2[TR Test] " .. t_res)
                else
                    helpers.OnConsoleMessage("`4[Translator Error] Failed to translate.")
                end
            end, extra_arg)
            return true
        else
            helpers.OpenTranslatorDialog()
            return true
        end
    end
})

add_command({
    name = "slave",
    aliases = { "antislave" },
    usage = "/slave",
    description = "Toggle auto remove & restore spammer slaves",
    handler = function(args, full_cmd)
        config.antislave = not config.antislave
        if config.antislave then
            local count = helpers.RemoveAllSlaves()
            local status_overlay = config.branding .. " `2Anti-Slave: ENABLED (`e" .. count .. " `2removed)"
            helpers.OnTextOverlay(status_overlay)
            helpers.Say("`2[Anti-Slave] Status: `2ON `0| Removed `e" .. count .. " `2slave(s)")
            helpers.OnConsoleMessage("`2[Anti-Slave] Enabled! Removed " .. count .. " spammer slave(s).")
        else
            local restored = helpers.RestoreAllSlaves()
            local status_overlay = config.branding .. " `4Anti-Slave: DISABLED" .. (restored > 0 and (" `2(`e" .. restored .. " `2restored)") or "")
            helpers.OnTextOverlay(status_overlay)
            helpers.Say("`4[Anti-Slave] Status: `4OFF" .. (restored > 0 and (" `0| Restored `e" .. restored .. " `2slave(s)") or ""))
            helpers.OnConsoleMessage("`4[Anti-Slave] Disabled! Restored " .. restored .. " spammer slave(s).")
        end
        auto_save_config()
        return true
    end
})

add_command({
    name = "mf",
    aliases = { "modfly" },
    usage = "/mf",
    description = "Toggle zero-gravity ModFly free flight movement",
    handler = function(args, full_cmd)
        local current_state = false
        if type(GetValue) == "function" then
            local ok, val = pcall(GetValue, "[C] Modfly")
            if ok and val ~= nil then
                current_state = (val == true or val == 1)
            else
                current_state = config.modfly or false
            end
        else
            current_state = config.modfly or false
        end

        local new_state = not current_state
        config.modfly = new_state
        if type(ChangeValue) == "function" then
            pcall(ChangeValue, "[C] Modfly", new_state)
            pcall(ChangeValue, "[C] ModFly", new_state)
        end
        local status_overlay = new_state and "`2ModFly Enabled" or "`4ModFly Disabled"
        helpers.OnTextOverlay(status_overlay)
        helpers.Say(status_overlay)
        helpers.OnConsoleMessage(status_overlay)
        auto_save_config()
        return true
    end
})

add_command({
    name = "tp",
    aliases = {},
    usage = "/tp",
    description = "Toggle click-to-teleport and auto-return",
    handler = function(args, full_cmd)
        config.tpdisplay = not config.tpdisplay
        local status_text = config.tpdisplay and "`2ENABLED" or "`4DISABLED"
        helpers.OnTextOverlay(config.branding .. " `eClick-to-Teleport: " .. status_text)
        helpers.Say("`eClick-to-Teleport: " .. status_text)
        helpers.OnConsoleMessage("`eClick-to-Teleport: " .. status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "tpset",
    aliases = {},
    usage = "/tpset",
    description = "Configure teleport delay, mode, and auto-return",
    handler = function(args, full_cmd)
        helpers.OpenTpSettingsDialog()
        return true
    end
})

add_command({
    name = "g",
    aliases = {},
    usage = "/g",
    description = "Shortcut to toggle ghost mode (/ghost)",
    handler = function(args, full_cmd)
        SendPacket(2, "action|input\n|text|/ghost")
        return true
    end
})

add_command({
    name = "gemdetect",
    aliases = {},
    usage = "/gemdetect",
    description = "Toggle auto floating gem detector",
    handler = function(args, full_cmd)
        config.autoGemDetect = not config.autoGemDetect
        local status_overlay = config.autoGemDetect and "`2Enabled Gem Detector" or "`4Disabled Gem Detector"
        local status_say = config.autoGemDetect and "`2Gem Detector: `eON" or "`4Gem Detector: `cOFF"
        helpers.OnTextOverlay(status_overlay)
        helpers.Say(status_say)
        helpers.OnConsoleMessage(status_say)
        auto_save_config()
        return true
    end
})

add_command({
    name = "autosb",
    aliases = {},
    usage = "/autosb",
    description = "Open Auto Super Broadcast configuration dialog",
    handler = function(args, full_cmd)
        helpers.OpenAutoSbDialog()
        return true
    end
})

add_command({
    name = "sblog",
    aliases = {},
    usage = "/sblog",
    description = "View Auto Super Broadcast live statistics",
    handler = function(args, full_cmd)
        helpers.OpenAutoSbLogDialog()
        return true
    end
})

add_command({
    name = "sbstart",
    aliases = {},
    usage = "/sbstart",
    description = "Start running Auto Super Broadcast cycle",
    handler = function(args, full_cmd)
        helpers.StartAutoSB()
        return true
    end
})

add_command({
    name = "sbstop",
    aliases = {},
    usage = "/sbstop",
    description = "Stop running Auto Super Broadcast cycle",
    handler = function(args, full_cmd)
        helpers.StopAutoSB()
        return true
    end
})

add_command({
    name = "titles",
    aliases = { "title" },
    usage = "/titles",
    description = "Toggle player & mod rank titles in name",
    handler = function(args, full_cmd)
        config.rank_titles = not config.rank_titles
        local status_str = config.rank_titles and "`2ENABLED" or "`4DISABLED"
        helpers.OnTextOverlay(config.branding .. " `ePlayer & Mod Titles: " .. status_str)
        helpers.Say("`ePlayer & Mod Titles: " .. status_str)
        helpers.OnConsoleMessage("`ePlayer & Mod Titles: " .. status_str)
        helpers.RefreshAllPlayerNames()
        auto_save_config()
        return true
    end
})

add_command({
    name = "spintitle",
    aliases = { "spintitles" },
    usage = "/spintitle",
    description = "Toggle last wheel spin number title in name",
    handler = function(args, full_cmd)
        config.spin_titles = not config.spin_titles
        local status_str = config.spin_titles and "`2ENABLED" or "`4DISABLED"
        helpers.OnTextOverlay(config.branding .. " `eLast Spin Title: " .. status_str)
        helpers.Say("`eLast Spin Title: " .. status_str)
        helpers.OnConsoleMessage("`eLast Spin Title: " .. status_str)
        helpers.RefreshAllPlayerNames()
        auto_save_config()
        return true
    end
})

add_command({
    name = "ping",
    aliases = {},
    usage = "/ping",
    description = "Display your live latency ping in ms",
    handler = function(args, full_cmd)
        local current_ping = helpers.GetPing()
        local ping_col = "`2"
        if current_ping > 180 then
            ping_col = "`4"
        elseif current_ping > 90 then
            ping_col = "`9"
        end
        helpers.OnTextOverlay(config.branding .. " `eLive Ping: " .. ping_col .. tostring(current_ping) .. " ms")
        helpers.Say("`eLive Ping: " .. ping_col .. tostring(current_ping) .. " ms")
        helpers.OnConsoleMessage("`eLive Ping: " .. ping_col .. tostring(current_ping) .. " ms")
        return true
    end
})

add_command({
    name = "pingtag",
    aliases = { "showping" },
    usage = "/pingtag",
    description = "Toggle realtime ping tag in player name",
    handler = function(args, full_cmd)
        config.show_ping = not config.show_ping
        local status_str = config.show_ping and "`2ENABLED" or "`4DISABLED"
        helpers.OnTextOverlay(config.branding .. " `eLive Ping Tag: " .. status_str)
        helpers.Say("`eLive Ping Tag: " .. status_str)
        helpers.OnConsoleMessage("`eLive Ping Tag: " .. status_str)
        helpers.UpdateLocalPlayerName()
        auto_save_config()
        return true
    end
})

add_command({
    name = "rl",
    aliases = { "relog" },
    usage = "/rl",
    description = "Fast relog to current world",
    handler = function(args, full_cmd)
        local ok, world = pcall(GetWorld)
        local world_name = (ok and world and world.name) and tostring(world.name) or ""
        if world_name == "" or world_name:upper() == "EXIT" then
            helpers.OnTextOverlay(config.branding .. " `4Unable to relog: You are not in a world!")
            helpers.OnConsoleMessage("`4Unable to relog: You are not in a world.")
            return true
        end
        helpers.OnTextOverlay(config.branding .. " `eRelogging to world `2" .. world_name .. "`e...")
        helpers.OnConsoleMessage("`eRelogging to world `2" .. world_name .. "`e...")
        SendPacket(3, "action|join_request\nname|" .. world_name .. "|\ninvitedWorld|0")
        return true
    end
})

add_command({
    name = "bsdb",
    aliases = {},
    usage = "/bsdb",
    description = "Toggle block Super Duper Broadcasts",
    handler = function(args, full_cmd)
        config.bsdb = not config.bsdb
        local status = config.bsdb and "`2ENABLED" or "`4DISABLED"
        helpers.OnTextOverlay(config.branding .. " `eBlock SDB: " .. status)
        helpers.Say("`eBlock SDB: " .. status)
        helpers.OnConsoleMessage("`eBlock SDB: " .. status)
        auto_save_config()
        return true
    end
})

add_command({
    name = "bank",
    aliases = {},
    usage = "/bank",
    description = "Open remote BGL bank deposit/withdraw menu",
    handler = function(args, full_cmd)
        SendPacket(2, "action|dialog_return\ndialog_name|popup\nbuttonClicked|bgls")
        return true
    end
})

add_command({
    name = "dp",
    aliases = { "depo", "deposit" },
    usage = "/dp [amount]",
    description = "Deposit Blue Gem Locks to bank",
    handler = function(args_clean, full_cmd)
        local amount = parse_positive_integer(args_clean)
        if amount and amount > 0 then
            RunThread(function()
                local bgl_count = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
                local black_count = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
                local total_bgl = black_count * 100 + bgl_count
                if amount > total_bgl then
                    helpers.OnConsoleMessage("`4Not enough BGL! Available in bag: " .. total_bgl)
                    helpers.OnTextOverlay("`4Not enough BGL! Available: " .. total_bgl)
                    return
                end
                helpers.DepositBank(amount)
            end)
        else
            RunThread(function()
                local bgl_count = GetItemCount(ITEM_IDS.BLUE_GEM_LOCK) or 0
                local black_count = GetItemCount(ITEM_IDS.BLACK_GEM_LOCK) or 0
                local total_bgl = black_count * 100 + bgl_count
                if total_bgl > 0 then
                    helpers.DepositBank(total_bgl)
                else
                    helpers.OnConsoleMessage("`4No BGL or BLACK to deposit!")
                    helpers.OnTextOverlay("`4No BGL in inventory!")
                end
            end)
        end
        return true
    end
})

add_command({
    name = "wd",
    aliases = { "wt", "withdraw" },
    usage = "/wd <amount>",
    description = "Withdraw Blue Gem Locks from bank",
    handler = function(args_clean, full_cmd)
        local amount = parse_positive_integer(args_clean)
        if amount and amount > 0 then
            RunThread(function()
                helpers.WithdrawBank(amount)
            end)
        else
            helpers.OnConsoleMessage("`4Usage: /wd <amount> (e.g. /wd 100)")
            helpers.OnTextOverlay("`4Usage: /wd <amount>")
        end
        return true
    end
})

add_command({
    name = "pullall",
    aliases = { "pll" },
    usage = "/pullall",
    description = "Open safe mass player pull confirmation dialog",
    handler = function(args, full_cmd)
        helpers.OpenPullAllDialog()
        return true
    end
})

add_command({
    name = "daw",
    aliases = { "da" },
    usage = "/daw",
    description = "Fast drop all World Locks",
    handler = function(args, full_cmd)
        helpers.DropAllLocks()
        return true
    end
})

add_command({
    name = "cbgl",
    aliases = {},
    usage = "/cbgl",
    description = "Toggle auto convert 100 DL to 1 BGL",
    handler = function(args, full_cmd)
        config.cbgl = not config.cbgl
        local status_text = config.cbgl and "`2Enabled Convert BGL" or "`4Disabled Convert BGL"
        helpers.OnTextOverlay(status_text)
        helpers.Say(status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "buydl",
    aliases = { "cdl" },
    usage = "/buydl",
    description = "Toggle auto buy Diamond Locks from Telephone",
    handler = function(args, full_cmd)
        config.buydl = not config.buydl
        local status_text = config.buydl and "`2Enabled Auto Buy DL from Telephone" or "`4Disabled Auto Buy DL from Telephone"
        helpers.OnTextOverlay(status_text)
        helpers.Say(status_text)
        helpers.OnConsoleMessage(status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "sspin",
    aliases = {},
    usage = "/sspin",
    description = "Toggle short wheel spin animation",
    handler = function(args, full_cmd)
        config.sspin = not config.sspin
        local status_text = config.sspin and "`2Enabled Short Spin" or "`4Disabled Short Spin"
        helpers.OnTextOverlay(status_text)
        helpers.Say(status_text)
        helpers.OnConsoleMessage(status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "leme",
    aliases = {},
    usage = "/leme",
    description = "Toggle Leme wheel spin counter",
    handler = function(args, full_cmd)
        config.leme = not config.leme
        if config.leme then reset_all_games("leme") end
        local status_text = config.leme and "`2Enabled Leme Spin" or "`4Disabled Leme Spin"
        helpers.OnTextOverlay(status_text)
        helpers.Say(status_text)
        helpers.OnConsoleMessage(status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "reme",
    aliases = {},
    usage = "/reme",
    description = "Toggle Reme wheel spin counter",
    handler = function(args, full_cmd)
        config.reme = not config.reme
        if config.reme then reset_all_games("reme") end
        local status_text = config.reme and "`2Enabled Reme Spin" or "`4Disabled Reme Spin"
        helpers.OnTextOverlay(status_text)
        helpers.Say(status_text)
        helpers.OnConsoleMessage(status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "qeme",
    aliases = {},
    usage = "/qeme",
    description = "Toggle Qeme wheel spin counter",
    handler = function(args, full_cmd)
        config.qeme = not config.qeme
        if config.qeme then reset_all_games("qeme") end
        local status_text = config.qeme and "`2Enabled Qeme Spin" or "`4Disabled Qeme Spin"
        helpers.OnTextOverlay(status_text)
        helpers.Say(status_text)
        helpers.OnConsoleMessage(status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "lewa",
    aliases = {},
    usage = "/lewa",
    description = "Toggle Lewa wheel spin counter",
    handler = function(args, full_cmd)
        config.lewa = not config.lewa
        if config.lewa then reset_all_games("lewa") end
        local status_text = config.lewa and "`2Enabled Lewa Spin" or "`4Disabled Lewa Spin"
        helpers.OnTextOverlay(status_text)
        helpers.Say(status_text)
        helpers.OnConsoleMessage(status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "sleme",
    aliases = { "lemesuper" },
    usage = "/sleme",
    description = "Toggle Leme Super wheel spin counter",
    handler = function(args, full_cmd)
        config.sleme = not config.sleme
        if config.sleme then reset_all_games("sleme") end
        local status_text = config.sleme and "`2Enabled Leme Super Spin" or "`4Disabled Leme Super Spin"
        helpers.OnTextOverlay(status_text)
        helpers.Say(status_text)
        helpers.OnConsoleMessage(status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "ceme",
    aliases = {},
    usage = "/ceme",
    description = "Toggle Ceme wheel spin counter",
    handler = function(args, full_cmd)
        config.ceme = not config.ceme
        if config.ceme then reset_all_games("ceme") end
        local status_text = config.ceme and "`2Enabled Ceme Spin" or "`4Disabled Ceme Spin"
        helpers.OnTextOverlay(status_text)
        helpers.Say(status_text)
        helpers.OnConsoleMessage(status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "hol",
    aliases = {},
    usage = "/hol",
    description = "Toggle High-or-Low (HOL) wheel spin game",
    handler = function(args, full_cmd)
        config.hol = not config.hol
        if config.hol then reset_all_games("hol") end
        local status_text = config.hol and "`2Enabled HOL Spin (High or Low)" or "`4Disabled HOL Spin"
        helpers.OnTextOverlay(status_text)
        helpers.Say(status_text)
        helpers.OnConsoleMessage(status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "holr",
    aliases = {},
    usage = "/holr",
    description = "Reset HOL wheel spin history",
    handler = function(args, full_cmd)
        config.holSpins = {}
        helpers.OnTextOverlay("`3Reset HOL Spins!")
        helpers.Say("`3Reset HOL Spins!")
        helpers.OnConsoleMessage("`3[HOL] Spin tracking reset.")
        return true
    end
})

add_command({
    name = "cp",
    aliases = { "cpull" },
    usage = "/cp",
    description = "Toggle touch player to pull",
    handler = function(args, full_cmd)
        config.wrench_touch_pull = not config.wrench_touch_pull
        local status_text = config.wrench_touch_pull and "`2ENABLED" or "`4DISABLED"
        helpers.OnTextOverlay("`e[Click Pull] Touch Pull: " .. status_text)
        helpers.Say("`e[Click Pull] Touch Pull: " .. status_text)
        helpers.OnConsoleMessage("`e[Click Pull] Touch Pull: " .. status_text)
        auto_save_config()
        return true
    end
})

add_command({
    name = "smodal",
    aliases = { "showbal" },
    usage = "/smodal",
    description = "Toggle show balance modal on player wrench",
    handler = function(args, full_cmd)
        config.showbal = not config.showbal
        local status_text = config.showbal and "`2Enabled Show Modal Player" or "`4Disabled Show Modal Player"
        helpers.OnTextOverlay(status_text)
        helpers.OnConsoleMessage(status_text)
        auto_save_config()
        return true
    end
})


add_command({
    name = "wrp",
    aliases = {},
    usage = "/wrp",
    description = "Toggle wrench mode: Pull",
    handler = function(args, full_cmd)
        if config.wrench_mode == "pull" then
            config.wrench_mode = "off"
        else
            config.wrench_mode = "pull"
        end
        local status = (config.wrench_mode == "pull") and "`2ENABLED" or "`4DISABLED"
        helpers.OnTextOverlay("`e[Wrench Mode] PULL: " .. status)
        helpers.Say("`e[Wrench Mode] PULL: " .. status)
        auto_save_config()
        return true
    end
})

add_command({
    name = "wrb",
    aliases = {},
    usage = "/wrb",
    description = "Toggle wrench mode: Ban",
    handler = function(args, full_cmd)
        if config.wrench_mode == "ban" then
            config.wrench_mode = "off"
        else
            config.wrench_mode = "ban"
        end
        local status = (config.wrench_mode == "ban") and "`2ENABLED" or "`4DISABLED"
        helpers.OnTextOverlay("`4[Wrench Mode] BAN: " .. status)
        helpers.Say("`4[Wrench Mode] BAN: " .. status)
        auto_save_config()
        return true
    end
})

add_command({
    name = "wrk",
    aliases = {},
    usage = "/wrk",
    description = "Toggle wrench mode: Kick",
    handler = function(args, full_cmd)
        if config.wrench_mode == "kick" then
            config.wrench_mode = "off"
        else
            config.wrench_mode = "kick"
        end
        local status = (config.wrench_mode == "kick") and "`2ENABLED" or "`4DISABLED"
        helpers.OnTextOverlay("`6[Wrench Mode] KICK: " .. status)
        helpers.Say("`6[Wrench Mode] KICK: " .. status)
        auto_save_config()
        return true
    end
})

add_command({
    name = "calcu",
    aliases = { "calc" },
    usage = "/calcu <expr>",
    description = "Evaluate mathematical calculation",
    handler = function(args_clean, full_cmd)
        helpers.HandleCalculatorCommand(args_clean)
        return true
    end
})

add_command({
    name = "w",
    aliases = {},
    usage = "/w <amt>",
    description = "Fast drop World Locks (configurable)",
    handler = function(args_clean, full_cmd)
        local amount = parse_positive_integer(args_clean)
        if not amount then
            helpers.Say("`4Invalid amount!")
            return true
        end
        helpers.DropWorldLock(amount)
        return true
    end
})

add_command({
    name = "d",
    aliases = {},
    usage = "/d <amt>",
    description = "Fast drop Diamond Locks (configurable)",
    handler = function(args_clean, full_cmd)
        local amount = parse_positive_integer(args_clean)
        if not amount then
            helpers.Say("`4Invalid amount!")
            return true
        end
        helpers.DropDiamondLock(amount)
        return true
    end
})

add_command({
    name = "b",
    aliases = {},
    usage = "/b <amt>",
    description = "Fast drop Blue Gem Locks (configurable)",
    handler = function(args_clean, full_cmd)
        local amount = parse_positive_integer(args_clean)
        if not amount then
            helpers.Say("`4Invalid amount!")
            return true
        end
        helpers.DropBlueGemLock(amount)
        return true
    end
})

add_command({
    name = "bb",
    aliases = {},
    usage = "/bb <amt>",
    description = "Fast drop Black Gem Locks (configurable)",
    handler = function(args_clean, full_cmd)
        local amount = parse_positive_integer(args_clean)
        if not amount then
            helpers.Say("`4Invalid amount!")
            return true
        end
        helpers.DropBlackLock(amount)
        return true
    end
})

-- =========================== PACKET HANDLERS ===========================

function HandleSendPacket(pkt_type, packet)
    if pkt_type ~= 2 and pkt_type ~= 3 then
        return false
    end

    -- ==================== WORLD JOIN / EXIT TELECACHE TRACKER ====================
    if pkt_type == 3 and packet then
        if packet:find("action|join_request") or packet:find("action|quit_to_exit") or packet:find("action|quit") then
            helpers.telecache = { world = "", tiles = {} }
        end
    end

    -- ==================== MANUAL DROP DIALOG INTERCEPT ====================
    if pkt_type == 2 and packet and packet:find("action|dialog_return") and packet:find("dialog_name|drop") and not operation_flags.is_smart_dropping then
        local drop_id = tonumber(packet:match("item_drop|(%d+)"))
        local drop_count = tonumber(packet:match("item_count|(%d+)"))
        if drop_id and drop_count and drop_count > 0 then
            local desc_drop = nil
            if drop_id == ITEM_IDS.WORLD_LOCK then
                desc_drop = "**" .. drop_count .. "** <:wl:1556814610420473946> WL"
            elseif drop_id == ITEM_IDS.DIAMOND_LOCK then
                desc_drop = "**" .. drop_count .. "** <:dl:1556814401695252560> DL"
            elseif drop_id == ITEM_IDS.BLUE_GEM_LOCK then
                desc_drop = "**" .. drop_count .. "** <:bgl:1556814259478855690> BGL"
            elseif drop_id == ITEM_IDS.BLACK_GEM_LOCK then
                desc_drop = "**" .. drop_count .. "** <:black:1556814063449800804> BLACK"
            else
                local iname = "Item #" .. tostring(drop_id)
                if type(GetItemById) == "function" then
                    local ok_it, iobj = pcall(GetItemById, drop_id)
                    if ok_it and iobj and iobj.name then iname = iobj.name end
                end
                desc_drop = "**" .. drop_count .. "x** " .. iname
            end
            helpers.SendDropWebhook(desc_drop)
        end
    end

    -- ==================== STORAGE DIALOG INTERCEPT (STORE & WITHDRAW) ====================
    if pkt_type == 2 and packet and packet:find("action|dialog_return") and packet:find("dialog_name|storage") then
        local btn = packet:match("buttonClicked|([^|\n]+)")
        local tx = tonumber(packet:match("x|(%d+)")) or 0
        local ty = tonumber(packet:match("y|(%d+)")) or 0
        local count = tonumber(packet:match("item_count|(%d+)")) or 1
        local item_id = tonumber(packet:match("item|(%d+)"))

        local action = nil
        if btn == "store_confirm" then
            action = "STORE"
        elseif btn == "withdraw" then
            action = "WITHDRAW"
        end

        if action and count > 0 then
            -- Resolving Item ID:
            -- If not in text (withdraw), find from storage cache by tile coords or recent type19/type13
            if not item_id or item_id == 0 then
                local tile_key = tx .. "_" .. ty
                if helpers.storage_cache and helpers.storage_cache.tiles and helpers.storage_cache.tiles[tile_key] then
                    item_id = helpers.storage_cache.tiles[tile_key].item_id
                elseif helpers.storage_cache and helpers.storage_cache.last_type19 then
                    item_id = helpers.storage_cache.last_type19.item_id
                elseif helpers.storage_cache and helpers.storage_cache.last_type13 then
                    item_id = helpers.storage_cache.last_type13.item_id
                end
            end

            local final_item_id = item_id or ITEM_IDS.DIAMOND_LOCK -- default DL if unknown
            local lock_str, item_name, emoji = helpers.FormatStorageItem(final_item_id, count)

            helpers.SendStorageWebhook({
                action         = action,
                count          = count,
                item_id        = final_item_id,
                item_name      = item_name,
                item_formatted = lock_str,
                tile_x         = tx,
                tile_y         = ty
            })

            local action_color = (action == "STORE") and "`2[STORAGE STORE]`0" or "`3[STORAGE WITHDRAW]`0"
            helpers.OnConsoleMessage(action_color .. " " .. action .. ": " .. lock_str .. " at Tile (" .. tx .. ", " .. ty .. ")")
        end
    end

    -- ==================== ACTION WRENCH INTERCEPT ====================
    local is_wrench_active = (config.wrench_mode == "pull" or config.wrench_mode == "kick" or config.wrench_mode == "ban" or config.pull or config.kick or config.ban)
    if packet:find("action|wrench") and (is_wrench_active or config.showbal) then
        local netid = tonumber(packet:match("netid|(%d+)"))
        local success, localPlayer = pcall(GetLocal)
        if success and localPlayer and tonumber(localPlayer.netid) == netid then
            return false
        end

        if netid then
            RunThread(function()
                helpers.ExecuteWrenchActions(netid, "Unknown", {
                    force_pull = false,
                    allow_showbal = true
                })
            end)
            return true
        end
    end

    local text = packet:match("action|input\n|text|([^\n]*)") or packet:match("|text|([^\n]*)")
    if not text then
        text = packet:gsub("\r", ""):gsub("^%s+", ""):gsub("%s+$", "")
    end

    -- ==================== OUTGOING CHAT AUTO-TRANSLATE (OnSendPacket Hook) ====================
    if pkt_type == 2 and config.translator and config.translator.outgoing_enabled and not operation_flags.is_sending_auto_tr and packet:find("action|input\n|text|") then
        local raw_chat = text:gsub("^%s*(.-)%s*$", "%1")
        -- If not empty, not a slash command, and not a proxy system message
        if raw_chat ~= "" and raw_chat:sub(1, 1) ~= "/" and not raw_chat:find(config.branding, 1, true) and not raw_chat:find("DODGED") and not raw_chat:find("BGLProxy") then
            RunThread(function(chat_content)
                local target_l = (config.translator and config.translator.outgoing_target_lang) or (config.translator and config.translator.target_lang) or "en"
                local trans_res = helpers.TranslateText(chat_content, target_l)
                if trans_res and trans_res ~= "" then
                    operation_flags.is_sending_auto_tr = true
                    SendPacket(2, "action|input\n|text|" .. trans_res .. "\n")
                    helpers.OnConsoleMessage("`c[AI Out: " .. target_l:upper() .. "] `2\"" .. trans_res .. "\" `7(Orig: \"" .. chat_content .. "\")")
                    Sleep(120)
                    operation_flags.is_sending_auto_tr = false
                else
                    operation_flags.is_sending_auto_tr = true
                    SendPacket(2, "action|input\n|text|" .. chat_content .. "\n")
                    Sleep(120)
                    operation_flags.is_sending_auto_tr = false
                end
            end, raw_chat)
            return true -- BLOCK TEXT ASLI (TIDAK DIKIRIM KE SERVER, RESEND VERSI TERJEMAHAN VIA SENDPACKET)
        end
    end

    -- ==================== SLASH COMMANDS ====================
    if text:sub(1, 1) == "/" then
        local raw_body = text:sub(2)
        local cmd_token, raw_args = raw_body:match("^([^%s]+)%s*(.-)$")
        cmd_token = (cmd_token or ""):lower()
        local args_clean = tostring(raw_args or ""):gsub("^%s*(.-)%s*$", "%1")

        -- Whitelist authorization check for all commands (3-Tier: Bypass, Hoster, Worker)
        if not whitelist_state.is_authorized then
            helpers.OnConsoleMessage("`4[Access Denied] `0Akses ditolak! User ID belum terdaftar di Discord bot (Worker / Hoster / Bypass).")
            helpers.OnTextOverlay("`4[DODGED] Access Denied: Not Whitelisted!")
            return true
        end

        -- ==================== SMART DROP ROUTING (DYNAMIC PREFIXES & MULTIPLIERS) ====================
        local wl_cmd    = config.cmd_drop_wl
        local dl_cmd    = config.cmd_drop_dl
        local bgl_cmd   = config.cmd_drop_bgl
        local black_cmd = config.cmd_drop_black

        local amount_num = parse_positive_integer(args_clean)

        -- 1. Check direct dynamic drop commands
        if cmd_token == wl_cmd then
            if not amount_num then
                helpers.Say("`4Invalid amount!")
                return true
            end
            helpers.DropWorldLock(amount_num)
            return true
        elseif cmd_token == dl_cmd then
            if not amount_num then
                helpers.Say("`4Invalid amount!")
                return true
            end
            helpers.DropDiamondLock(amount_num)
            return true
        elseif cmd_token == bgl_cmd then
            -- If user typed plain "/b" without trailing space -> pass through to server
            if not has_space_after_cmd and args_clean == "" then
                return false
            end
            if not amount_num then
                helpers.Say("`4Invalid amount!")
                return true
            end
            helpers.DropBlueGemLock(amount_num)
            return true
        elseif cmd_token == black_cmd then
            if not amount_num then
                helpers.Say("`4Invalid amount!")
                return true
            end
            helpers.DropBlackLock(amount_num)
            return true
        end

        -- 2. Check multiplier drop commands (e.g. /w2 5 -> 10 WL, /d5 2 -> 10 DL, /b2 10 -> 20 BGL)
        local base_cmd, multiplier_str = cmd_token:match("^(%a+)(%d+)$")
        local multiplier = tonumber(multiplier_str)
        if base_cmd and multiplier then
            if multiplier < 2 or multiplier > 100 then
                helpers.OnTextOverlay("`4Invalid multiplier! Use 2-100 only.")
                helpers.Say("`4Multiplier must be between 2-100!")
                return true
            end

            if not amount_num then
                helpers.Say("`4Invalid amount!")
                return true
            end

            local total_count = amount_num * multiplier
            if base_cmd == wl_cmd then
                helpers.DropWorldLock(total_count)
                return true
            elseif base_cmd == dl_cmd then
                helpers.DropDiamondLock(total_count)
                return true
            elseif base_cmd == bgl_cmd then
                helpers.DropBlueGemLock(total_count)
                return true
            elseif base_cmd == black_cmd then
                helpers.DropBlackLock(total_count)
                return true
            end
        end

        -- 3. Resolve modular registered command via add_command registry
        local canonical, def = resolve_registered_command(cmd_token)
        if def and type(def.handler) == "function" then
            local ok_h, handled = pcall(def.handler, args_clean, text)
            if not ok_h then
                helpers.OnConsoleMessage("`4[Command Error] /" .. tostring(canonical or cmd_token) .. ": " .. tostring(handled))
                return true
            end
            if handled ~= nil then
                return handled
            end
            return true
        end
    end

    -- ==================== DIALOG RETURNS ====================
    if packet:find("action|dialog_return") then
        -- Wrench Custom Text Dialog Save (/wrm)
        if packet:find("dialog_name|wrench_mode_dialog") then
            if not packet:find("buttonClicked|Cancel") and not packet:find("buttonClicked|cancel") then
                local showbal_use_chat = (packet:find("showbal_use_chat|1") ~= nil)
                local msg_pull_input = packet:match("wrench_msg_pull|([^|\n]*)")
                local msg_kick_input = packet:match("wrench_msg_kick|([^|\n]*)")
                local msg_ban_input = packet:match("wrench_msg_ban|([^|\n]*)")
                local msg_showbal_input = packet:match("wrench_msg_showbal|([^|\n]*)")

                config.showbal_use_chat = showbal_use_chat

                if msg_pull_input ~= nil then config.wrench_msg_pull = sanitize_wrench_message_input(msg_pull_input) end
                if msg_kick_input ~= nil then config.wrench_msg_kick = sanitize_wrench_message_input(msg_kick_input) end
                if msg_ban_input ~= nil then config.wrench_msg_ban = sanitize_wrench_message_input(msg_ban_input) end
                if msg_showbal_input ~= nil then config.wrench_msg_showbal = sanitize_wrench_message_input(msg_showbal_input) end

                auto_save_config(true)
                helpers.OnTextOverlay(config.branding .. " `2Wrench Text Settings Saved!")
                helpers.Say("`2Wrench text settings saved!")
                helpers.OnConsoleMessage("`2Wrench text settings updated successfully.")
            end
            return true
        end

        -- Custom Command Dialog Save
        if packet:find("dialog_name|custom_cmd_dialog") then
            local n_wl    = packet:match("cmd_wl|([^|\n]+)")
            local n_dl    = packet:match("cmd_dl|([^|\n]+)")
            local n_bgl   = packet:match("cmd_bgl|([^|\n]+)")
            local n_black = packet:match("cmd_black|([^|\n]+)")

            if not n_wl or n_wl:match("^%s*$") then n_wl = "w" end
            if not n_dl or n_dl:match("^%s*$") then n_dl = "d" end
            if not n_bgl or n_bgl:match("^%s*$") then n_bgl = "b" end
            if not n_black or n_black:match("^%s*$") then n_black = "bb" end

            n_wl    = n_wl:gsub("[%s%p]", ""):lower()
            n_dl    = n_dl:gsub("[%s%p]", ""):lower()
            n_bgl   = n_bgl:gsub("[%s%p]", ""):lower()
            n_black = n_black:gsub("[%s%p]", ""):lower()

            local cmds = { n_wl, n_dl, n_bgl, n_black }
            local seen = {}
            local has_duplicate = false
            for _, c in ipairs(cmds) do
                if seen[c] then has_duplicate = true break end
                seen[c] = true
            end

            if has_duplicate then
                helpers.OnTextOverlay("`4Error: Commands must be unique!")
                helpers.OnConsoleMessage("`4Error: All drop commands must be different!")
                return true
            end

            config.cmd_drop_wl    = n_wl
            config.cmd_drop_dl    = n_dl
            config.cmd_drop_bgl   = n_bgl
            config.cmd_drop_black = n_black
            auto_save_config(true)

            helpers.OnTextOverlay("`2Custom drop commands saved!")
            helpers.OnConsoleMessage("`2Updated commands: /" .. n_wl .. " | /" .. n_dl .. " | /" .. n_bgl .. " | /" .. n_black)
            return true
        end

        -- Main Menu Buttons
        if packet:find("dialog_name|bglproxy_main") then
            if packet:find("buttonClicked|btn_open_menu") then
                helpers.OpenMenuDialog()
                return true
            elseif packet:find("buttonClicked|btn_open_options") then
                helpers.OpenOptionDialog()
                return true
            elseif packet:find("buttonClicked|btn_open_wrm") then
                helpers.WrenchModeDialog()
                return true
            elseif packet:find("buttonClicked|btn_open_customcmd") then
                helpers.CustomCommandDialog()
                return true
            elseif packet:find("buttonClicked|btn_open_colors") then
                helpers.OpenColorDialog()
                return true
            elseif packet:find("buttonClicked|btn_open_hotkey") then
                helpers.HotkeyDialog()
                return true
            elseif packet:find("buttonClicked|btn_open_gui") or packet:find("buttonClicked|btn_open_imgui") then
                helpers.ToggleGui()
                return true
            elseif packet:find("buttonClicked|btn_open_spam") then
                helpers.ShowSpamDialog()
                return true
            end
        end

        -- Color Theme Save & Presets
        if packet:find("dialog_name|bglproxy_colors") then
            if packet:find("buttonClicked|preset_neon_cyan") then
                config.dialogBorder = "0,200,255,255"
                config.dialogBg = "30,30,30,225"
                auto_save_config()
                helpers.OpenColorDialog()
                return true
            elseif packet:find("buttonClicked|preset_deep_purple") then
                config.dialogBorder = "180,50,255,255"
                config.dialogBg = "35,20,50,230"
                auto_save_config()
                helpers.OpenColorDialog()
                return true
            elseif packet:find("buttonClicked|preset_dark_gold") then
                config.dialogBorder = "255,200,50,255"
                config.dialogBg = "40,35,25,230"
                auto_save_config()
                helpers.OpenColorDialog()
                return true
            elseif packet:find("buttonClicked|preset_midnight") then
                config.dialogBorder = "80,80,80,255"
                config.dialogBg = "15,15,15,240"
                auto_save_config()
                helpers.OpenColorDialog()
                return true
            elseif packet:find("buttonClicked|preset_emerald") then
                config.dialogBorder = "50,255,100,255"
                config.dialogBg = "20,40,25,230"
                auto_save_config()
                helpers.OpenColorDialog()
                return true
            elseif packet:find("buttonClicked|preset_crimson") then
                config.dialogBorder = "255,50,60,255"
                config.dialogBg = "45,20,20,235"
                auto_save_config()
                helpers.OpenColorDialog()
                return true
            elseif packet:find("cbgcolor_toggle|") or packet:find("inp_border|") then
                config.cbgcolor = (packet:find("cbgcolor_toggle|1") ~= nil)
                local b_val = packet:match("inp_border|([^|\n]*)")
                local bg_val = packet:match("inp_bg|([^|\n]*)")
                if b_val and b_val ~= "" then config.dialogBorder = b_val end
                if bg_val and bg_val ~= "" then config.dialogBg = bg_val end
                auto_save_config()
                helpers.OnTextOverlay("`2Color Settings Saved!")
                helpers.OnConsoleMessage("`2Dialog color theme updated successfully.")
                return true
            end
        end

        -- Pull All Confirmation Return
        if packet:find("dialog_name|bglproxy_pullall") then
            if not packet:find("buttonClicked|Cancel") and not packet:find("buttonClicked|cancel") then
                helpers.ExecutePullAll()
            end
            return true
        end

        -- Skin Picker Return
        if packet:find("dialog_name|bglproxy_skin") then
            local clicked_btn = packet:match("buttonClicked|(skin_[%w_]+)")
            if clicked_btn then
                helpers.ApplySkinColor(clicked_btn)
                helpers.OpenSkinDialog()
            end
            return true
        end

        -- Translator Settings Dialog Return
        if packet:find("dialog_name|bglproxy_tr") then
            if not packet:find("buttonClicked|Cancel") and not packet:find("buttonClicked|cancel") then
                helpers.HandleTranslatorDialogPacket(packet)
            end
            return true
        end

        -- Teleport Settings Dialog Return
        if packet:find("dialog_name|bglproxy_tpset") then
            if not packet:find("buttonClicked|Cancel") and not packet:find("buttonClicked|cancel") then
                config.tpdisplay = (packet:find("tp_enabled|1") ~= nil)
                if packet:find("tp_mode_disp|1") then
                    config.tpdisplay_mode = "display_only"
                else
                    config.tpdisplay_mode = "all_position"
                end
                config.tpdisplay_return = (packet:find("tp_return|1") ~= nil)

                local delay_val = tonumber(packet:match("tp_delay|([%d]+)")) or 3000
                if delay_val < 80 then delay_val = 80 end
                if delay_val > 10000 then delay_val = 10000 end
                config.tpdisplay_delay = delay_val

                local tp_st = config.tpdisplay and "`2ON" or "`4OFF"
                local mode_st = config.tpdisplay_mode == "display_only" and "`3Display Only" or "`2All Positions"
                local ret_st = config.tpdisplay_return and ("`2Enabled (" .. config.tpdisplay_delay .. "ms)") or "`4Disabled"

                helpers.OnTextOverlay(config.branding .. " `eTeleport Settings Saved!")
                helpers.Say("`eTeleport: " .. tp_st .. " `7| `eMode: " .. mode_st .. " `7| `eReturn: " .. ret_st)
                helpers.OnConsoleMessage("`eTeleport Settings Updated: " .. tp_st .. " | Mode: " .. mode_st .. " | Return: " .. ret_st)
                auto_save_config()
            end
            return true
        end

        -- Feature Options Dialog Return
        if packet:find("dialog_name|bglproxy_options") then
            if packet:find("buttonClicked|opt_wrm_pull") then
                config.pull = true
                config.kick = false
                config.ban = false
                config.wrench_mode = "pull"
                auto_save_config()
                helpers.OnTextOverlay(config.branding .. " `eWrench Mode: `2PULL")
                helpers.Say("`eWrench Mode: `2PULL")
                helpers.OnConsoleMessage("`eWrench Mode set to PULL.")
                helpers.OpenOptionDialog()
                return true
            elseif packet:find("buttonClicked|opt_wrm_kick") then
                config.pull = false
                config.kick = true
                config.ban = false
                config.wrench_mode = "kick"
                auto_save_config()
                helpers.OnTextOverlay(config.branding .. " `eWrench Mode: `6KICK")
                helpers.Say("`6Wrench Mode: `6KICK")
                helpers.OnConsoleMessage("`6Wrench Mode set to KICK.")
                helpers.OpenOptionDialog()
                return true
            elseif packet:find("buttonClicked|opt_wrm_ban") then
                config.pull = false
                config.kick = false
                config.ban = true
                config.wrench_mode = "ban"
                auto_save_config()
                helpers.OnTextOverlay(config.branding .. " `eWrench Mode: `4BAN")
                helpers.Say("`4Wrench Mode: `4BAN")
                helpers.OnConsoleMessage("`4Wrench Mode set to BAN.")
                helpers.OpenOptionDialog()
                return true
            elseif packet:find("buttonClicked|opt_wrm_off") then
                config.pull = false
                config.kick = false
                config.ban = false
                config.wrench_mode = "off"
                auto_save_config()
                helpers.OnTextOverlay(config.branding .. " `eWrench Mode: `7OFF")
                helpers.Say("`7Wrench Mode: `7OFF")
                helpers.OnConsoleMessage("`7Wrench Mode disabled.")
                helpers.OpenOptionDialog()
                return true
            elseif packet:find("buttonClicked|opt_wrm_cfg") then
                helpers.WrenchModeDialog()
                return true
            elseif packet:find("buttonClicked|opt_open_hotkey") then
                helpers.HotkeyDialog()
                return true
            end

            if not packet:find("buttonClicked|Cancel") and not packet:find("buttonClicked|cancel") then
                config.modfly               = (packet:find("opt_mf|1") ~= nil)
                if type(ChangeValue) == "function" then
                    pcall(ChangeValue, "[C] Modfly", config.modfly)
                    pcall(ChangeValue, "[C] ModFly", config.modfly)
                end
                config.tpdisplay            = (packet:find("opt_tp|1") ~= nil)
                config.vendfilter           = (packet:find("opt_vendfilter|1") ~= nil)
                config.bsdb                 = (packet:find("opt_bsdb|1") ~= nil)
                local prev_antislave        = config.antislave
                config.antislave            = (packet:find("opt_antislave|1") ~= nil)
                if config.antislave and not prev_antislave then
                    helpers.RemoveAllSlaves()
                elseif not config.antislave and prev_antislave then
                    helpers.RestoreAllSlaves()
                end
                config.cbgl                 = (packet:find("opt_cbgl|1") ~= nil)
                config.buydl                = (packet:find("opt_buydl|1") ~= nil)
                config.autocombine          = (packet:find("opt_autocombine|1") ~= nil)
                config.cbgcolor             = (packet:find("opt_cbgcolor|1") ~= nil)
                config.wrench_touch_pull    = (packet:find("opt_cpull|1") ~= nil)
                config.showbal              = (packet:find("opt_smodal|1") ~= nil)
                config.sspin                = (packet:find("opt_sspin|1") ~= nil)
                config.autoGemDetect        = (packet:find("opt_gemdetect|1") ~= nil)
                config.rank_titles          = (packet:find("opt_rank_titles|1") ~= nil)
                config.spin_titles          = (packet:find("opt_spin_titles|1") ~= nil)
                config.show_ping            = (packet:find("opt_show_ping|1") ~= nil)
                helpers.RefreshAllPlayerNames()

                config.translator = config.translator or {
                    enabled              = false,
                    outgoing_enabled     = false,
                    target_lang          = "en",
                    outgoing_target_lang = "en",
                    show_bubble          = true,
                    show_console         = true,
                    skip_same_lang       = true
                }
                config.translator.enabled          = (packet:find("opt_tr_in|1") ~= nil)
                config.translator.outgoing_enabled = (packet:find("opt_tr_out|1") ~= nil)

                helpers.OnTextOverlay(config.branding .. " `2Options Saved Successfully!")
                helpers.Say("`2Feature options saved successfully!")
                helpers.OnConsoleMessage("`2Feature options updated successfully.")
                auto_save_config()
            end
            return true
        end

        -- Auto SB Settings Dialog Return
        if packet:find("dialog_name|bglproxy_autosb") then
            if packet:find("buttonClicked|autosb_btn_start") then
                helpers.StartAutoSB()
                return true
            elseif packet:find("buttonClicked|autosb_btn_stop") then
                helpers.StopAutoSB()
                return true
            elseif packet:find("buttonClicked|autosb_btn_reset") then
                helpers.ResetAutoSBStats()
                helpers.OpenAutoSbDialog()
                return true
            elseif packet:find("buttonClicked|autosb_btn_log") then
                helpers.OpenAutoSbLogDialog()
                return true
            end

            if not packet:find("buttonClicked|Cancel") and not packet:find("buttonClicked|cancel") then
                config.autosb_copysign        = (packet:find("autosb_copysign|1") ~= nil)
                config.autosb_autostart       = (packet:find("autosb_autostart|1") ~= nil)
                config.autosb_webhook_enabled = (packet:find("autosb_webhook|1") ~= nil)

                local new_text = packet:match("autosb_text|([^\n|]*)")
                if new_text then
                    config.autosb_text = new_text:gsub("^%s*(.-)%s*$", "%1")
                end

                local new_tag = packet:match("autosb_tag|([^\n|]*)")
                if new_tag and new_tag ~= "" then
                    config.autosb_tag = new_tag:gsub("^%s*(.-)%s*$", "%1")
                end

                local new_start = tonumber(packet:match("autosb_start|([%d]+)"))
                if new_start then
                    config.autosb_start_count = new_start
                    autosb_state.start_count = new_start
                end

                local new_total = tonumber(packet:match("autosb_total|([%d]+)"))
                if new_total and new_total > 0 then
                    config.autosb_total = new_total
                    autosb_state.total = new_total
                end

                local new_webhook = packet:match("autosb_webhook_url|([^\n|]*)")
                if new_webhook then
                    config.autosb_webhook_url = new_webhook:gsub("^%s*(.-)%s*$", "%1")
                end

                helpers.OnTextOverlay(config.branding .. " `eAuto SB Settings Saved!")
                helpers.OnConsoleMessage("`e[AutoSB] Settings updated.")
                auto_save_config()
            end
            return true
        end

        -- Hotkey Configuration Dialog Return
        if packet:find("dialog_name|hotkey_dialog") then
            if packet:find("buttonClicked|open_system_shortcuts") then
                helpers.SystemShortcutsDialog()
                return true
            end

            for slot = 1, 4 do
                if packet:find("buttonClicked|hk_clr_" .. slot) then
                    if not config.custom_hotkeys then config.custom_hotkeys = {} end
                    config.custom_hotkeys[slot] = { key = nil, cmd = "", enabled = false }
                    auto_save_config(true)
                    helpers.OnTextOverlay("`4Slot " .. slot .. " cleared!")
                    helpers.OnConsoleMessage("`4[Hotkey] Slot " .. slot .. " reset to [Not Set].")
                    helpers.HotkeyDialog()
                    return true
                elseif packet:find("buttonClicked|hk_set_" .. slot) then
                    helpers.StartHotkeyAssignCapture(slot)
                    return true
                end
            end

            if not packet:find("buttonClicked|Cancel") and not packet:find("buttonClicked|cancel") then
                if not config.custom_hotkeys then config.custom_hotkeys = {} end
                for slot = 1, 4 do
                    local cmd_val = packet:match("hk_cmd_" .. slot .. "|([^|\n]*)")
                    local en_val = (packet:find("hk_en_" .. slot .. "|1") ~= nil)
                    if not config.custom_hotkeys[slot] then
                        config.custom_hotkeys[slot] = { key = nil, cmd = "", enabled = false }
                    end
                    if cmd_val ~= nil then
                        config.custom_hotkeys[slot].cmd = cmd_val:gsub("^%s*(.-)%s*$", "%1")
                    end
                    config.custom_hotkeys[slot].enabled = en_val
                end

                local cd_val = tonumber(packet:match("hk_cooldown|([%d]+)"))
                if cd_val then
                    config.hotkey_cmd_cooldown_ms = math.max(100, cd_val)
                end

                auto_save_config(true)
                helpers.OnTextOverlay(config.branding .. " `2Hotkey Settings Saved!")
                helpers.OnConsoleMessage("`2[Hotkey] Custom hotkey settings saved successfully.")
            end
            return true
        end

        -- System Shortcuts Dialog Return
        if packet:find("dialog_name|system_shortcuts_dialog") then
            if not packet:find("buttonClicked|Cancel") and not packet:find("buttonClicked|cancel") then
                config.tp_ctrl_click_enabled = (packet:find("hotkey_ctrl_click|1") ~= nil)
                config.tp_shift_click_enabled = (packet:find("hotkey_shift_click|1") ~= nil)
                config.hotkey_f4_respawn = (packet:find("hotkey_f4_respawn|1") ~= nil)
                auto_save_config(true)
                helpers.OnTextOverlay(config.branding .. " `2System Shortcuts Saved!")
                helpers.OnConsoleMessage("`2[Shortcuts] CTRL-Click: " .. (config.tp_ctrl_click_enabled and "ON" or "OFF") .. " | SHIFT-Click: " .. (config.tp_shift_click_enabled and "ON" or "OFF") .. " | F4 Respawn: " .. (config.hotkey_f4_respawn and "ON" or "OFF"))
            end
            return true
        end

        -- Auto Spam Dialog Return
        if packet:find("dialog_name|dodged_spam") then
            if not config.spam_slots or type(config.spam_slots) ~= "table" then
                config.spam_slots = {}
            end

            local chk_rb = packet:match("chk_rainbow|(%d+)")
            if chk_rb ~= nil then
                config.spam_rainbow = (chk_rb == "1")
            end
            local chk_rc = packet:match("chk_random|(%d+)")
            if chk_rc ~= nil then
                config.spam_random_color = (chk_rc == "1")
            end
            if config.spam_rainbow and config.spam_random_color then
                if chk_rc == "1" then config.spam_rainbow = false else config.spam_random_color = false end
            end

            for i = 1, #config.spam_slots do
                local act = packet:match("chk_slot_active_" .. i .. "|(%d+)")
                if act ~= nil then
                    config.spam_slots[i].active = (act == "1")
                end
                local val = packet:match("input_spam_text_" .. i .. "|([^|\n]*)")
                if val ~= nil then config.spam_slots[i].text = val end
                local del = tonumber(packet:match("input_spam_delay_" .. i .. "|(%d+)"))
                if del ~= nil then config.spam_slots[i].delay = math.max(200, del) end
            end

            if packet:find("buttonClicked|btn_toggle_spam") then
                helpers.ToggleSpam()
                helpers.ShowSpamDialog()
                return true
            elseif packet:find("buttonClicked|btn_add_spam_field") then
                table.insert(config.spam_slots, { active = true, text = "HALLO " .. (#config.spam_slots + 1), delay = 3000 })
                auto_save_config(true)
                helpers.ShowSpamDialog()
                return true
            elseif packet:find("buttonClicked|btn_rem_spam_field") then
                if #config.spam_slots > 1 then
                    table.remove(config.spam_slots)
                    auto_save_config(true)
                end
                helpers.ShowSpamDialog()
                return true
            elseif packet:find("buttonClicked|btn_save_spam") then
                auto_save_config(true)
                helpers.OnTextOverlay(config.branding .. " `2Auto-Spam Settings Saved!")
                helpers.OnConsoleMessage("`2[Spam] Auto-Spam configuration saved successfully.")
                helpers.ShowSpamDialog()
                return true
            elseif packet:find("buttonClicked|menuu") then
                helpers.OpenProxyDialog()
                return true
            end
            auto_save_config(true)
            return true
        end
    end

    return false
end

function HandleOnVariant(var, netid, delay)
    if not var or not var[0] then
        return false
    end

    -- Reset TeleCache & Player titles on world exit / change
    if var[0] == "OnRequestWorldSelectMenu" then
        helpers.telecache = { world = "", tiles = {} }
        player_spin_titles = {}
        name_overrides = {}
        helpers.slave_netids = {}
        helpers.hidden_slaves = {}
    end

    -- ==================== CUSTOM TITLES & ONSPAWN HOOK ====================
    if var[0] and var[0]:find("OnSpawn") and var[1] and var[1]:find("spawn|avatar") then
        if var[1]:find("type|local") then
            helpers.slave_netids = {}
            helpers.hidden_slaves = {}
        end

        local mstate = var[1]:match("[mM]state|(%d+)") or var[1]:match("mstate|(%d+)")
        local netID = var[1]:match("[nN]et[iI][dD]|(%d+)") or var[1]:match("netID|(%d+)")
        local userID = var[1]:match("[uU]ser[iI][dD]|(%d+)") or var[1]:match("userID|(%d+)")
        local name = var[1]:match("[nN]ame|([^\n]+)") or var[1]:match("name|([^\n]+)")
        local playerWorldId = tonumber(var[1]:match("PlayerWorldID|(%d+)") or var[1]:match('"PlayerWorldID":(%d+)') or "0") or 0

        if netID and name then
            local numericNet = tonumber(netID)
            -- If Anti-Slave is enabled, block OnSpawn and send OnRemove to client
            if config.antislave and helpers.IsSlaveName(name) then
                helpers.slave_netids[numericNet] = true
                helpers.hidden_slaves[numericNet] = tostring(var[1])
                SendVariantList({
                    [0] = "OnRemove",
                    [1] = "netID|" .. numericNet,
                    [2] = "pId|1"
                }, -1)
                return true -- block from client spawning
            end
            local numericUser = tonumber(userID)
            if numericUser == nil then
                local ok_p, plr = pcall(GetPlayer, numericNet)
                if ok_p and plr and plr.userid ~= nil then
                    numericUser = tonumber(plr.userid)
                else
                    numericUser = 0
                end
            end
            local mstateNum = tonumber(mstate or "0")
            local is_mod = (mstateNum and mstateNum > 1)

            name_overrides[numericNet] = {
                base = strip_custom_proxy_tags(name),
                world_id = playerWorldId,
                userid = numericUser,
                is_mod = is_mod
            }

            local newName = build_custom_name(numericNet)
            if newName then
                RunThread(function()
                    Sleep(100)
                    SendVariantList({
                        [0] = "OnNameChanged",
                        [1] = newName,
                        [2] = string.format('{"PlayerWorldID":%d}', playerWorldId)
                    }, numericNet, 0)
                end)
            end
        end
    end

    if var[0] == "OnNameChanged" then
        local numericNet = tonumber(netid or -1)
        if numericNet and numericNet >= 0 and (name_overrides[numericNet] or player_spin_titles[numericNet]) then
            local incomingName = tostring(var[1] or "")
            local customName, worldId = build_custom_name(numericNet)
            local incomingMeta = tostring(var[2] or "")
            local incomingWorldId = tonumber(incomingMeta:match('"PlayerWorldID":(%d+)') or "0") or 0

            if incomingName ~= "" and customName and incomingName ~= customName then
                local override = name_overrides[numericNet] or {}
                override.base = strip_custom_proxy_tags(incomingName)
                override.world_id = incomingWorldId > 0 and incomingWorldId or (override.world_id or worldId or 0)
                name_overrides[numericNet] = override
                customName, worldId = build_custom_name(numericNet)
            end

            if customName and incomingName ~= customName then
                SendVariantList({
                    [0] = "OnNameChanged",
                    [1] = customName,
                    [2] = string.format('{"PlayerWorldID":%d}', worldId or 0)
                }, numericNet, 0)
                return true
            end
        end
    end

    -- ==================== BLOCK SUPER DUPER BROADCAST (/bsdb) ====================
    if var[0] == "OnSDBroadcast" and config.bsdb then
        helpers.OnTextOverlay(config.branding .. " `4Blocked `8S`6D`9B!")
        return true
    end

    -- ==================== BLOCK BANK DEPOSIT / WITHDRAW TALK BUBBLE ====================
    if var[0] == "OnTalkBubble" and var[2] then
        local bubble_str = tostring(var[2])
        if bubble_str:find("in the bank now") or (bubble_str:find("Blue Gem Lock") and (bubble_str:find("Deposited") or bubble_str:find("Withdrawn"))) then
            return true
        end
    end

    -- ==================== DONATION BOX TALK BUBBLE HOOK (ANTI-FAKE) ====================
    if var[0] == "OnTalkBubble" and var[2] then
        local bubble_text = tostring(var[2])
        if bubble_text:find("places") and bubble_text:find("into the Donation Box") then
            -- 1. Anti-Fake Filter #1: Bubble Flag harus bernilai 1 (System Action Bubble)
            local bubble_flag = tonumber(var[4]) or 0
            local is_flag_valid = (bubble_flag == 1)

            -- 2. Anti-Fake Filter #2: Teks TIDAK boleh mengandung prefix chat player `^
            local has_fake_prefix = (bubble_text:find("`^", 1, true) ~= nil)

            -- 3. Filter Kepemilikan (Hanya akun sendiri yang sedang run script)
            local ok_me, me = pcall(GetLocal)
            local my_netid = (ok_me and me and me.netid) and tonumber(me.netid) or nil
            local my_uid = (ok_me and me and me.userid) and tostring(math.floor(tonumber(me.userid) or 0)) or nil
            local speaker_netid = tonumber(var[1]) or -1

            local is_my_account = false
            if my_netid and speaker_netid == my_netid then
                is_my_account = true
            elseif speaker_netid >= 0 and my_uid then
                local ok_p, speaker_plr = pcall(GetPlayer, speaker_netid)
                if ok_p and speaker_plr and speaker_plr.userid then
                    local spk_uid = tostring(math.floor(tonumber(speaker_plr.userid) or 0))
                    if spk_uid == my_uid then
                        is_my_account = true
                    end
                end
                if not is_my_account then
                    local ok_plist, plist = pcall(GetPlayerList)
                    if ok_plist and plist then
                        for _, p in pairs(plist) do
                            if p and tonumber(p.netid) == speaker_netid and p.userid then
                                local p_uid = tostring(math.floor(tonumber(p.userid) or 0))
                                if p_uid == my_uid then
                                    is_my_account = true
                                    break
                                end
                            end
                        end
                    end
                end
            end

            -- Hanya proses jika ASLI (flag == 1, tanpa `^, dan dari akun sendiri)
            if is_flag_valid and not has_fake_prefix and is_my_account then
                local clean_text = bubble_text:gsub("`.", ""):gsub("^%s*(.-)%s*$", "%1")
                local donor_name, amount_str, item_name = clean_text:match("%[?(.-)%s+places%s+(%d+)%s+(.-)%s+into the Donation Box%]?")
                if not donor_name then
                    donor_name, amount_str, item_name = clean_text:match("(.-)%s+places%s+(%d+)%s+(.-)%s+into the Donation Box")
                end

                local donation_detail = ""
                local count = tonumber(amount_str) or 1
                local item = item_name or "Lock"
                item = item:gsub("%]$", ""):gsub("^%s*(.-)%s*$", "%1")

                -- Format dengan emoji lock yang sesuai
                if item:find("Diamond") then
                    donation_detail = "**" .. count .. "** <:dl:1556814401695252560> " .. item
                elseif item:find("Blue Gem") or item:find("BGL") then
                    donation_detail = "**" .. count .. "** <:bgl:1556814259478855690> " .. item
                elseif item:find("Black") then
                    donation_detail = "**" .. count .. "** <:black:1556814063449800804> " .. item
                elseif item:find("World Lock") or item:find("WL") then
                    donation_detail = "**" .. count .. "** <:wl:1556814610420473946> " .. item
                else
                    donation_detail = "**" .. count .. "** " .. item
                end

                helpers.SendDonationWebhook(donation_detail)
                helpers.OnConsoleMessage("`2[DONATION] `0Verified donation logged: `e" .. donation_detail)
            end
        end
    end

    -- ==================== BANK & GHOST CONSOLE PARSER ====================
    if var[0] == "OnConsoleMessage" and var[1] then
        local msg_str = tostring(var[1])

        -- Spammer Slave Filter: Block console chat messages sent by spammer slaves
        if config.antislave then
            local clean_msg = msg_str:gsub("`.", ""):lower()
            local sender = msg_str:match("<(.-)>")
            if (sender and helpers.IsSlaveName(sender))
                or clean_msg:find("'s spammer slave", 1, true)
                or clean_msg:find("spammer slave", 1, true)
                or clean_msg:find("spammer_slave", 1, true)
                or clean_msg:find("'s slave", 1, true)
                or msg_str:find("No spam text set")
                or msg_str:find("CreativePD MARKET IN") then
                return true -- block message from appearing in console
            end
        end

        -- Ghost Mode Detection (Server Mod Hook)
        if msg_str:find("quantum tunneling") and msg_str:find("Ghost in the shell") and msg_str:find("mod added") then
            config.ghost = true
            helpers.OnConsoleMessage("`9Ghost mode is now `2ENABLED")
            helpers.OnTextOverlay("`2Ghost Mode: `2ENABLED")
            return true
        end

        if msg_str:find("stops shimmering") and msg_str:find("Ghost in the shell") and msg_str:find("mod removed") then
            config.ghost = false
            helpers.OnConsoleMessage("`9Ghost mode is now `4DISABLED")
            helpers.OnTextOverlay("`4Ghost Mode: `4DISABLED")
            return true
        end

        if msg_str:find("in the bank now") then
            local clean_text = msg_str:gsub("`.", "")
            if msg_str:find("Deposited") then
                local amount = tonumber(clean_text:match("Deposited%s+(%d+)%s+Blue Gem Lock")) or tonumber(clean_text:match("Deposited%s+(%d+)")) or 1
                local total_bank = tonumber(clean_text:match("have%s+(%d+)%s+in the bank")) or tonumber(clean_text:match("have%s+(%d+)")) or 0

                local total_black = math.floor(total_bank / 100)
                local rem_bgl = total_bank % 100
                local parts = {}
                if total_black > 0 then table.insert(parts, "`b" .. total_black .. " BLACK`8") end
                if rem_bgl > 0 or total_black == 0 then table.insert(parts, "`e" .. rem_bgl .. " BGL`8") end
                local breakdown = " `8(" .. table.concat(parts, " ") .. ")"

                local formatted_msg = config.branding .. " `2Deposited `e" .. amount .. " BGL `9to Bank `7| `9Bank Balance: `2" .. total_bank .. " BGL" .. breakdown
                SendVariantList({ [0] = "OnConsoleMessage", [1] = formatted_msg }, -1)
                return true
            elseif msg_str:find("Withdrawn") then
                local amount = tonumber(clean_text:match("Withdrawn%s+(%d+)%s+Blue Gem Lock")) or tonumber(clean_text:match("Withdrawn%s+(%d+)")) or 1
                local total_bank = tonumber(clean_text:match("have%s+(%d+)%s+in the bank")) or tonumber(clean_text:match("have%s+(%d+)")) or 0

                local total_black = math.floor((total_bank or 0) / 100)
                local rem_bgl = (total_bank or 0) % 100
                local parts = {}
                if total_black > 0 then table.insert(parts, "`b" .. total_black .. " BLACK`8") end
                if rem_bgl > 0 or total_black == 0 then table.insert(parts, "`e" .. rem_bgl .. " BGL`8") end
                local breakdown = " `8(" .. table.concat(parts, " ") .. ")"

                local formatted_msg = config.branding .. " `4Withdrawn `e" .. amount .. " BGL `9from Bank `7| `9Bank Balance: `2" .. total_bank .. " BGL" .. breakdown
                SendVariantList({ [0] = "OnConsoleMessage", [1] = formatted_msg }, -1)
                return true
            end
        end

        -- Auto SB Console Confirmation Hook
        if autosb_state.running and msg_str:find("sent. Used") then
            autosb_state.success_flag = true
            if msg_str:find("Black") then
                autosb_state.gems_type = "BGems"
                local used = tonumber(msg_str:match("Used `%$(%d+)"))
                if used then autosb_state.bgems_used = used end
                local left = tonumber(msg_str:match("`%$(%d+)`` left"))
                if left then autosb_state.bgems_left = left end
                autosb_state.total_bgems_used = autosb_state.total_bgems_used + (used or 0)
            else
                autosb_state.gems_type = "Gems"
                local used = tonumber(msg_str:match("Used `%$(%d+)"))
                if used then autosb_state.gems_used = used end
                local left = tonumber(msg_str:match("`%$(%d+)`` left"))
                if left then autosb_state.gems_left = left end
                autosb_state.total_gems_used = autosb_state.total_gems_used + (used or 0)
            end
        end
    end

    -- ==================== AUTO SB SIGN SCANNER (OnDialogRequest) ====================
    if var[0] == "OnDialogRequest" and config.autosb_copysign and var[1] and var[1]:find("display_text") then
        local scanned = var[1]:match("display_text||(.-)|128") or var[1]:match("display_text||(.-)\n")
        if scanned and scanned:gsub("%s+", "") ~= "" then
            scanned = scanned:gsub("^/sb%s+", ""):gsub("^%s*(.-)%s*$", "%1")
            config.autosb_text = scanned
            auto_save_config()
            helpers.OnTextOverlay("`2Sign text captured! Open `9/autosb `2to start.")
            helpers.OnConsoleMessage("`2[AutoSB] Captured text from sign: `0" .. scanned)
            if config.autosb_autostart and not autosb_state.running then
                helpers.StartAutoSB()
            end
        end
    end

    -- ==================== VENDING COST FILTER (OnDialogRequest) ====================
    if var[0] == "OnDialogRequest" and config.vendfilter and var[1] then
        local dialog = var[1]

        local function parse_number(text)
            local clean = (text or "0"):gsub("[^%d]", "")
            return tonumber(clean) or 0
        end

        if dialog:find("vend_buy") and dialog:find("cost") then
            dialog = dialog:gsub("add_label_with_icon|small|([%d,]+)%s*x%s*[^|\n]+|left|242|", function(num_text)
                local wl_cost = parse_number(num_text)
                if wl_cost <= 0 then
                    return nil
                end
                return format_vend_cost_from_wl(wl_cost)
            end, 1)
            var[1] = dialog
        end

        if dialog:find("vend_buyconfirm") and (dialog:find("give") or dialog:find("cost")) then
            local updated_dialog = dialog:gsub(
                "add_label_with_icon|small|([%d,]+)%s*x%s*[^|\n]+|left|242|",
                function(num_text)
                    local wl_cost = parse_number(num_text)
                    if wl_cost <= 0 then
                        return nil
                    end
                    return format_vend_cost_from_wl(wl_cost)
                end,
                1
            )
            if updated_dialog ~= dialog then
                var[1] = updated_dialog
                dialog = updated_dialog
            end
        end

        if dialog:find("buy_use") then
            local updated_dialog = dialog
            updated_dialog = updated_dialog:gsub(
                "add_label_with_icon|small|This machine contains a total of%s*([%d,]+)[^|\n]+|left|242|",
                function(num_text)
                    local wl_total = parse_number(num_text)
                    if wl_total <= 0 then
                        return nil
                    end
                    local formatted_cost, icon_id = format_vend_cost_from_wl(wl_total, "inline")
                    return string.format("add_label_with_icon|small|This machine contains a total of %s|left|%d|",
                        formatted_cost, icon_id)
                end, 1)

            updated_dialog = updated_dialog:gsub(
                "add_label_with_icon|small|([%d,]+)%s*x%s*[^|\n]+a piece[^|\n]*|left|242|", function(num_text)
                    local wl_piece = parse_number(num_text)
                    if wl_piece <= 0 then
                        return nil
                    end
                    local formatted_cost = format_vend_cost_from_wl(wl_piece)
                    return "add_label|small|`7Price per piece:|left|\n" .. formatted_cost
                end, 1)

            if updated_dialog ~= dialog then
                var[1] = updated_dialog
            end
        end
    end

    -- ==================== ANTI-SLAVE TALKBUBBLE INTERCEPT ====================
    if config.antislave and var[0] == "OnTalkBubble" then
        if var[2] then
            local b_str = tostring(var[2])
            if b_str:find("No spam text set") or b_str:find("CreativePD MARKET IN") then
                return true
            end
        end
        if var[1] then
            local spk_nid = tonumber(var[1]) or -1
            if spk_nid >= 0 then
                if helpers.slave_netids[spk_nid] then
                    return true -- block talk bubble from removed slave!
                end
                local ok_p, speaker_plr = pcall(GetPlayer, spk_nid)
                local spk_name = (ok_p and speaker_plr and speaker_plr.name) or ""
                if helpers.IsSlaveName(spk_name) then
                    helpers.slave_netids[spk_nid] = true
                    return true
                end
            end
        end
    end

    -- ==================== REALTIME INCOMING TRANSLATOR HOOK ====================
    if config.translator and config.translator.enabled and var[0] == "OnTalkBubble" and var[1] and var[2] then
        local tr_speaker_netid = tonumber(var[1]) or 0
        local tr_raw_msg = tostring(var[2] or "")
        local tr_bubble_mode = tonumber(var[3]) or 0

        local tr_ok_me, tr_me_player = pcall(GetLocal)
        local tr_my_netid = (tr_ok_me and tr_me_player and tr_me_player.netid) and tonumber(tr_me_player.netid) or -999

        local clean_tr_msg = tr_raw_msg:gsub("`.", ""):gsub("^%s*(.-)%s*$", "%1")
        local is_sys_notif = clean_tr_msg:match("^<.-entered") or clean_tr_msg:match("^<.-left") or clean_tr_msg:match("^<.-joined") or clean_tr_msg:match("^<.-pulls") or (clean_tr_msg:sub(1, 1) == "<" and clean_tr_msg:sub(-1) == ">")
        local is_me = (tr_speaker_netid == tr_my_netid)

        -- Spammer Slave Filter: Check player name via GetPlayer(netid) for 's Spammer Slave
        local is_spammer_slave = false
        if (config.translator == nil or config.translator.filter_slave ~= false) and tr_speaker_netid >= 0 then
            if helpers.slave_netids[tr_speaker_netid] then
                is_spammer_slave = true
            else
                local ok_p, speaker_plr = pcall(GetPlayer, tr_speaker_netid)
                local spk_name = (ok_p and speaker_plr and speaker_plr.name) or ""
                if spk_name == "" then
                    local ok_plist, plist = pcall(GetPlayerList)
                    if ok_plist and plist then
                        for _, p in pairs(plist) do
                            if p and tonumber(p.netid) == tr_speaker_netid and p.name then
                                spk_name = p.name
                                break
                            end
                        end
                    end
                end
                if helpers.IsSlaveName(spk_name) or clean_tr_msg:lower():find("'s spammer slave", 1, true) or clean_tr_msg:lower():find("spammer slave", 1, true) then
                    is_spammer_slave = true
                end
            end
        end

        local tr_is_skip = is_spammer_slave or tr_raw_msg:find("%[AI") ~= nil or tr_raw_msg:find("%[TR") ~= nil or tr_raw_msg:find("%[EncTalk%]") ~= nil or is_sys_notif or is_me or (clean_tr_msg == "") or tr_raw_msg:find("spun the wheel")

        if not tr_is_skip and tr_speaker_netid >= 0 and clean_tr_msg ~= "" then
            RunThread(function(spk_nid, orig_msg, b_mode)
                local target_l = (config.translator and config.translator.target_lang == "id") and "id" or "en"
                local trans_res, detected_l = helpers.TranslateText(orig_msg, target_l)

                if trans_res and trans_res ~= "" then
                    if config.translator and config.translator.skip_same_lang and detected_l and detected_l:lower():sub(1, 2) == target_l:lower() then
                        return
                    end

                    local clean_orig = orig_msg:gsub("`.", ""):gsub("^%s*(.-)%s*$", "%1")
                    local clean_trans = trans_res:gsub("`.", ""):gsub("^%s*(.-)%s*$", "%1")
                    if clean_trans:lower() == clean_orig:lower() then
                        return
                    end

                    local colored_trans = trans_res
                    if tostring(orig_msg):find("`%S") and not colored_trans:find("`%S") then
                        colored_trans = helpers.ApplyOriginalColorPattern(orig_msg, trans_res)
                    end
                    local tag_color = (target_l == "id") and "`2[AI: ID] " or "`3[AI: EN] "
                    local bubble_text = tag_color .. colored_trans

                    if config.translator and config.translator.show_bubble then
                        SendVariantList({
                            [0] = "OnTalkBubble",
                            [1] = spk_nid,
                            [2] = bubble_text,
                            [3] = b_mode or 0,
                            netid = spk_nid
                        })
                    end

                    if config.translator and config.translator.show_console then
                        helpers.OnConsoleMessage("`c[AI: " .. target_l:upper() .. "] `0NetID " .. spk_nid .. ": " .. colored_trans .. " `7(Orig: " .. clean_orig .. ")")
                    end
                end
            end, tr_speaker_netid, tr_raw_msg, tr_bubble_mode)
        end
    end

    -- ==================== ROULETTE / WHEEL SPIN PARSER (100% ExProxy Exact Match) ====================
    if var[0] == "OnTalkBubble" and var[2] and var[2]:find("spun the wheel") then
        local is_fake = var[2]:find("<") and var[2]:find(">")
        local prefix = is_fake and "`0[`4FAKE`0] " or "`0[`2REAL`0] "

        local bubble_netid = tonumber(var[1]) or -1
        local player_key = tostring(bubble_netid)

        if bubble_netid ~= -1 then
            local num_str = var[2]:match("and got (.+)")
            if num_str then
                local num = string.gsub(string.gsub(num_str, "!%]", ""), "`", "")
                local onlynumber = string.sub(num, 2)
                local clearspace = string.gsub(onlynumber, " ", "")
                local h = string.gsub(string.gsub(clearspace, "!7", ""), "]", "")
                local num_parsed = tonumber(h)

                if num_parsed then
                    local game_text = helpers.getGame(num_parsed, player_key)
                    helpers.ApplySpinTitle(bubble_netid, num_parsed)
                    if config.sspin then
                        var[2] = prefix .. " `9" .. num_parsed .. " " .. game_text
                    else
                        var[2] = prefix .. var[2] .. " " .. game_text
                    end
                    SendVariantList(var, netid)
                    return true
                end
            end
        end
    end

    -- Also attach to OnConsoleMessage for chat log history
    if var[0] == "OnConsoleMessage" and var[1] and var[1]:find("spun the wheel") then
        local num_str = var[1]:match("and got (.+)")
        if num_str then
            local num = string.gsub(string.gsub(num_str, "!%]", ""), "`", "")
            local onlynumber = string.sub(num, 2)
            local clearspace = string.gsub(onlynumber, " ", "")
            local h = string.gsub(string.gsub(clearspace, "!7", ""), "]", "")
            local num_parsed = tonumber(h)
            if num_parsed then
                local game_text = helpers.getGame(num_parsed, "0")
                if game_text and game_text ~= "" then
                    helpers.OnConsoleMessage(var[1] .. " " .. game_text)
                    return true
                end
            end
        end
    end

    -- ==================== FAST DELIVERY SUPPRESSION (100% ExProxy Match) ====================
    if var[0] == "OnDialogRequest" and var[1] and var[1]:find("fast delivery") and (config.cbgl or config.buydl) then
        return true
    end

    -- ==================== CV BGL (TELEPHONE CONVERT - 100% ExProxy Match) ====================
    if var[0] == "OnDialogRequest" and var[1] and (var[1]:find("`wTelephone") or var[1]:find("`0Telephone") or var[1]:find("end_dialog|telephone")) and config.cbgl then
        local x = tonumber(var[1]:match("x|(%d+)")) or tonumber(var[1]:match("embed_data|x|(%d+)"))
        local y = tonumber(var[1]:match("y|(%d+)")) or tonumber(var[1]:match("embed_data|y|(%d+)"))
        if not x or not y then
            local closest, _ = get_nearest_telephone()
            if closest then
                x = closest.x
                y = closest.y
            end
        end
        if x and y then
            SendPacket(2,
                "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" ..
                x .. "|\ny|" .. y .. "|\nbuttonClicked|bglconvert")
            helpers.OnTextOverlay("`2Converted to BGL")
            return true
        end
    end

    -- ==================== BUY DL FROM TELEPHONE (100% ExProxy Match) ====================
    if var[0] == "OnDialogRequest" and var[1] and (var[1]:find("`wTelephone") or var[1]:find("`0Telephone") or var[1]:find("end_dialog|telephone")) and config.buydl then
        local x = tonumber(var[1]:match("x|(%d+)")) or tonumber(var[1]:match("embed_data|x|(%d+)"))
        local y = tonumber(var[1]:match("y|(%d+)")) or tonumber(var[1]:match("embed_data|y|(%d+)"))
        if not x or not y then
            local closest, _ = get_nearest_telephone()
            if closest then
                x = closest.x
                y = closest.y
            end
        end
        if x and y then
            SendPacket(2,
                "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" ..
                x .. "|\ny|" .. y .. "|\nbuttonClicked|dlconvert")
            helpers.OnTextOverlay("`2Success Buying `11 DL")
            return true
        end
    end

    -- ==================== AUTO COLLECT HOOK ====================
    if var[0] == "OnConsoleMessage" and var[1] and var[1]:find("Collected") and not var[1]:find("<") then
        local msg = var[1]
        local wl_amt = msg:match("(%d+) CreativePS World Lock") or msg:match("(%d+) World Lock")
        local dl_amt = msg:match("(%d+) CreativePS Diamond Lock") or msg:match("(%d+) Diamond Lock")
        local bgl_amt = msg:match("(%d+) CreativePS Blue Gem Lock") or msg:match("(%d+) Blue Gem Lock")
        local black_amt = msg:match("(%d+) CreativePS Black Gem Lock") or msg:match("(%d+) Black Gem Lock")

        if wl_amt then
            helpers.BufferCollectedItem("wl", wl_amt)
            return true
        elseif dl_amt then
            helpers.BufferCollectedItem("dl", dl_amt)
            return true
        elseif bgl_amt then
            helpers.BufferCollectedItem("bgl", bgl_amt)
            return true
        elseif black_amt then
            helpers.BufferCollectedItem("black", black_amt)
            return true
        end
    end

    -- ==================== BGL BANK DIALOG HOOK (Worker Modal Logger) ====================
    if var[0] == "OnDialogRequest" and var[1] and (var[1]:find("The BGL Bank") or var[1]:find("BGLs in the Bank")) then
        local clean_dialog = strip_colors(var[1])
        local bank_str = clean_dialog:match("You have ([%d,]+) BGLs in the Bank")
                      or clean_dialog:match("([%d,]+) BGLs in the Bank")
                      or var[1]:match("You have `%$([%d,]+)`` BGLs in the Bank")
                      or var[1]:match("([%d,]+)%s*BGLs in the Bank")
        if bank_str then
            worker_modal_state.bank_bgl = parse_dialog_number(bank_str)
        end

        if worker_modal_state.is_requesting_bank then
            worker_modal_state.is_requesting_bank = false
            helpers.SendWorkerModalWebhook()
            return true -- Silently block Bank dialog popup from rendering on screen
        end
    end

    -- ==================== SHOW MODAL / BALANCE PARSER (100% ExProxy Exact Match) ====================
    if var[0] == "OnDialogRequest" and var[1] and var[1]:find("'s Inventory") then
        local summary = parse_inventory_summary_from_dialog(var[1])
        if summary and config.showbal then
            local formatted_msg = format_inventory_balance_message(summary)
            helpers.OnTextOverlay(formatted_msg)
            helpers.OnConsoleMessage(formatted_msg)
            return true -- Block raw inventory popup dialog
        end
    end

    -- ==================== WRENCH ACTIONS INTERCEPTOR ====================
    -- Combines /wrp, /wrb, /wrk and /smodal simultaneously
    if var[0] == "OnDialogRequest" and var[1] and var[1]:find("embed_data|netID|") and var[1]:find("popup") then
        local target_netid = var[1]:match("embed_data|netID|(%d+)")
        if target_netid then
            local action_taken = false

            if config.wrench_mode == "pull" then
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. target_netid .. "|\nbuttonClicked|pull")
                action_taken = true
            elseif config.wrench_mode == "ban" then
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. target_netid .. "|\nbuttonClicked|worldban")
                action_taken = true
            elseif config.wrench_mode == "kick" then
                SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. target_netid .. "|\nbuttonClicked|kick")
                action_taken = true
            end

            -- If /smodal is also active, execute inventory view concurrently
            if config.showbal then
                if action_taken then
                    RunThread(function(nid)
                        Sleep(80)
                        SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. nid .. "|\nbuttonClicked|viewinv")
                    end, target_netid)
                else
                    SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. target_netid .. "|\nbuttonClicked|viewinv")
                end
                action_taken = true
            end

            if action_taken then
                return true -- Block default popup menu from opening
            end
        end
    end

    -- ==================== DIALOG COLOR & BORDER INJECTOR (cbgcolor 100% ExProxy) ====================
    if var[0] == "OnDialogRequest" and config.cbgcolor then
        if var[1] then
            local newDialog = "set_default_color|`o\nset_border_color|" ..
                config.dialogBorder .. "|\nset_bg_color|" .. config.dialogBg .. "|\n" .. var[1]
            var[1] = newDialog
        end

        SendVariantList({ [0] = var[0], [1] = var[1], netid = netid or -1 })
        return true
    end

    return false
end

-- =========================== INJECTION & INITIALIZATION ===========================

RunThread(function()
    helpers.LoadConfig()
    helpers.DownloadBanner()

    -- Remove any old hooks first to avoid duplicates or clean up unauth state
    pcall(RemoveHook, "dodged_cmd")
    pcall(RemoveHook, "dodged_var")
    pcall(RemoveHook, "dodged_touch")
    pcall(RemoveHook, "bglproxy_cmd")
    pcall(RemoveHook, "bglproxy_var")
    pcall(RemoveHook, "bglproxy_touch")
    pcall(RemoveHook, "GemTouchDetect")
    pcall(RemoveHook, "dodged_raw")
    pcall(RemoveHook, "bglproxy_raw")
    pcall(RemoveHook, "bglproxy_gem")
    pcall(RemoveHook, "GemDetect")
    pcall(RemoveHook, "dodged_imgui_draw")

    -- Verify whitelist from Discord bot API FIRST (3-Tier: Bypass, Hoster, Worker)
    helpers.FetchWorkerWhitelist()
    local ok_auth, auth_info = helpers.CheckLocalAuthorization()

    if not ok_auth or not auth_info then
        local ok_loc, me = pcall(GetLocal)
        local my_uid = (ok_loc and me and me.userid) and tostring(math.floor(tonumber(me.userid) or 0)) or "Unknown"
        helpers.OnConsoleMessage("`4[Access Denied] `0User ID (" .. my_uid .. ") belum terdaftar di Discord bot! Silakan daftar via /addworker atau /addhoster.")
        helpers.OnTextOverlay("`4[DODGED] Access Denied: Unregistered User (" .. my_uid .. ")!")
        helpers.Say("`4Access Denied! UID: " .. my_uid)

        return
    end

    -- Attach Bothax Hooks ONLY AFTER AUTHORIZATION
    AddHook("OnSendPacket", "dodged_cmd", HandleSendPacket)
    AddHook("OnVariant", "dodged_var", HandleOnVariant)
    AddHook("OnWorldTouch", "dodged_touch", HandleWorldTouch)
    AddHook("OnWorldTouch", "GemTouchDetect", HandleGemWorldTouch)
    AddHook("OnSendPacketRaw", "dodged_raw", HandleTeleportBlock)
    pcall(AddHook, "OnProcessTankUpdate", "bglproxy_gem", HandleGemDetector)
    pcall(AddHook, "OnProcessTankUpdatePacket", "GemDetect", HandleGemDetector)
    pcall(AddHook, "OnProcessTankUpdate", "dodged_storage", helpers.HandleStorageTankPacket)
    pcall(AddHook, "OnProcessTankUpdatePacket", "dodged_storage_pkt", helpers.HandleStorageTankPacket)
    pcall(AddHook, "OnReceivePacketRaw", "dodged_storage_recv", helpers.HandleStorageTankPacket)
    pcall(AddHook, "OnRawPacket", "dodged_storage_raw", helpers.HandleStorageTankPacket)
    pcall(AddHook, "OnDraw", "dodged_imgui_draw", helpers.RenderImGuiDashboard)

    Sleep(100)
    helpers.UpdateLocalPlayerName()
    helpers.RefreshAllPlayerNames()
    if config.modfly and type(ChangeValue) == "function" then
        pcall(ChangeValue, "[C] Modfly", true)
        pcall(ChangeValue, "[C] ModFly", true)
    end

    local role_tag = (auth_info.role == "HOSTER" and "Hoster") or ((auth_info.role == "BYPASS" and "Owner/Bypass") or "Worker")
    helpers.OnConsoleMessage("`2Script was `2Started successfully.")
    helpers.OnConsoleMessage("`2[Access Granted] `0Welcome " .. role_tag .. ": `e" .. tostring(auth_info.growId) .. " `7(UID: `e" .. tostring(auth_info.userId) .. "`7)")
    helpers.SayClean("`2Injected `eDODGED `0Proxy (troll)")
    helpers.OnTextOverlay(config.branding_title .. " `2[" .. role_tag:upper() .. "] `2Loaded: `e" .. tostring(auth_info.growId))
    Sleep(200)

    -- Auto-open /proxy dialog upon successful authorization
    helpers.OpenProxyDialog()
    helpers.StartWorkerModalLoop()
    helpers.RequestBankBalance()

    -- Start custom hotkeys async watcher (ExProxy Hotkey Engine)
    start_custom_hotkeys_async_watcher()

    -- Periodic Live Ping Updater Thread
    RunThread(function()
        local last_ping = -1
        while true do
            Sleep(2500)
            if config.show_ping then
                local ok_world, world = pcall(GetWorld)
                if ok_world and world and world.name and world.name ~= "" and world.name ~= "EXIT" then
                    local current_ping = helpers.GetPing()
                    if current_ping ~= last_ping then
                        last_ping = current_ping
                        helpers.UpdateLocalPlayerName()
                    end
                end
            end
        end
    end)
end)
