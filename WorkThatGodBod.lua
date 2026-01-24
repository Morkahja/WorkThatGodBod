-- WorkThatGodBod (Standalone) v1.1
-- Vanilla / Turtle WoW 1.12.1
-- Lua 5.0-safe
-- SavedVariables: WorkThatGodBodDB

-------------------------------------------------
-- Exercise text pool
-------------------------------------------------
local EXERCISES = {
  "Roll your shoulders like you’re shrugging off a dragon’s gaze.",
  "Rise from your chair and shake your legs as if the ground still hums with magic.",
  "Gaze toward the horizon. Blink as though watching gryphons pass.",
  "Draw your shoulder blades together like locking a shield wall. Hold for five breaths.",
  "Drink water as if refilling mana. Inhale deep. Exhale slow.",
  "Stand tall and reach overhead, stretching like a banner in the wind.",
  "Rotate wrists and ankles, oiling old adventurer joints.",
  "Turn your head left and right, scouting for ambush.",
  "Perform ten steady squats, as if bracing before a charge.",
  "March in place like a patrol on night watch.",
  "Open your chest, hands behind your back, armor straps loosening.",
  "Brace your core like taking a hit. Hold. Release.",
  "Roll your neck in a slow arc, following a drifting ember.",
  "Balance on one leg, a tavern trick learned too well.",
  "Shake your hands like a spell misfired.",
  "Ten wall push-ups, reinforcing the keep.",
  "Pull elbows back as if drawing a longbow.",
  "Look up, then down, scanning the battlefield.",
  "Clench your glutes like mounting a warhorse.",
  "Walk the room as if circling a campfire.",
  "Stretch calves like after a long road march.",
  "Arm circles forward and back, warming up before battle.",
  "Sit tall, spine like a tower spire.",
  "Open and close fists, counting gold you don’t yet have.",
  "Five slow breaths through the nose. Calm before the storm.",
  "Stand and twist gently, checking your flanks.",
  "Rise onto your toes fifteen times, training balance on uneven ground.",
  "Relax your jaw like setting down a heavy helm.",
  "Reach skyward and lean, dodging falling debris.",
  "Shake your shoulders as if laughter finally won.",
  "Lift knees while seated, restless as a caged wolf.",
  "Look away from the screen, watching clouds over Azeroth.",
  "Stretch fingers wide, releasing arcane residue.",
  "Fold forward slowly, bowing to gravity.",
  "Roll shoulders forward, shaking off travel fatigue.",
  "Stand proud like an NPC with a backstory.",
  "Jog lightly in place, chased by nothing at all.",
  "Stretch triceps overhead, loosening sword arms.",
  "Wiggle toes, checking you still have all of them.",
  "Draw chin back, long neck, noble bearing.",
  "Ten controlled lunges, advancing step by step.",
  "Shake out your whole body like after a tavern brawl.",
  "Press palms together, stretching forearms worn by steel.",
  "Drink water again. Hydration is a buff.",
  "Stand, sit, stand again. A ritual of readiness.",
  "Seated spinal twist, wringing out travel dust.",
  "Raise arms with the inhale, lower with the exhale. A quiet spell.",
  "Balance with eyes closed, trusting the world.",
  "Align feet, hips, ribs, head. Proper heroic posture.",
  "Move with purpose for one full minute.",
  "Tilt head ear to shoulder, easing old campaign scars.",
  "Clench fists, then release like letting go of anger.",
  "Press feet into the floor. The world holds you.",
  "Slide shoulders up, back, and down. Reset armor.",
  "Straighten one leg, flex the foot, swap sides.",
  "Tap toes rapidly like impatient drumming.",
  "Massage temples as if easing a curse.",
  "Interlace fingers and push forward, stretching your upper back.",
  "Draw slow circles with your nose, tracing runes in air.",
  "Stretch one arm across the chest, then switch.",
  "Lift shoulders to ears, hold, then drop like a sigh.",
  "Rotate torso slowly, surveying the room.",
  "Extend arms and pulse back, wings you don’t have.",
  "Open mouth wide, then close, releasing tension.",
  "Seated hamstring stretch, one leg at a time.",
  "Press palms into desk, chest opening like a gate.",
  "Slow ankle circles, both directions, steady footing.",
  "March slowly, lifting knees like high-stepping armor.",
  "Cover eyes with palms, resting them from the glow.",
  "Engage core gently, holding yourself together.",
  "Seated cat-cow, spine flowing like a river.",
  "Lift heels, then toes, testing balance.",
  "Draw figure eights with shoulders, loose and free.",
  "Diagonal neck stretch, switch sides, no strain.",
  "Stand and sway, ship deck imagination optional.",
  "Reach overhead with interlaced fingers, claiming space.",
  "Open chest on inhale, courage expanding.",
  "Tap fingers to thumb, counting spell components.",
  "Lengthen spine without stiffening. Quiet strength.",
  "Press knees outward gently, grounding yourself.",
  "Shake forearms from elbows down, releasing tension.",
  "Ten slow seated calf pumps, travel-ready.",
  "Hands behind head, elbows wide, relaxed vigilance.",
  "Deep belly breath, five counts, steady heart.",
  "Stretch quad by bending knee back, then switch.",
  "Roll feet over imaginary pebbles on a forest path.",
  "Lift arms to shoulder height, hold like bearing standards.",
  "Turn head diagonally, checking corners.",
  "Lightly bounce on the balls of your feet, energy rising.",
  "Seated side bend, switch, fluid motion.",
  "Let shoulders melt away from your ears.",
  "Press palms together firmly, then release.",
  "One arm up, one down, alternating like signals.",
  "Slow sit-back squat, controlled descent.",
  "Rotate ribcage gently, hips steady as stone.",
  "Stand tall and breathe into your back.",
  "Open hands like releasing stored magic.",
  "Reset spine from pelvis upward, one segment at a time.",
  "Move joints gently. No force. Longevity matters."
}

-------------------------------------------------
-- Utils
-------------------------------------------------
local U = {}

function U.trim(s)
  s = s or ""
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  return s
end

function U.upper(s)
  return string.upper(U.trim(s or ""))
end

function U.split_cmd(raw)
  local s = U.trim(raw or "")
  local _, _, cmd, rest = string.find(s, "^(%S+)%s*(.*)$")
  if not cmd then return "", "" end
  return cmd, rest or ""
end

function U.pick(t)
  local n = table.getn(t or {})
  if n < 1 then return nil end
  return t[math.random(1, n)]
end

local function charKey()
  local name = UnitName("player") or "Unknown"
  local realm = GetRealmName and GetRealmName() or "Realm"
  return name .. "-" .. realm
end

-------------------------------------------------
-- GodBod core
-------------------------------------------------
local GOD = {
  db = nil,          -- bound to WorkThatGodBodDB.chars[charKey()]
  slots = nil,       -- bound to GOD.db.slots (slot->true)
  watchMode = false,
  last = 0,
  timer = 60,
  chance = 100,
  enabled = true,
  _loaded = false,
}

local function godChat(text)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff8000GodBod:|r " .. tostring(text or ""))
  end
end

-- Never posts to global channels. Only: local chat, /say, /yell, /party, /guild.
-- roll:
-- 95-96 /party
-- 93-94 /yell
-- 91-92 /say
-- 87-90 /guild
-- 1-86  local chat
local function outputExercise(text)
  local roll = math.random(1, 100)

  if roll >= 95 then
    SendChatMessage(text, "PARTY")
  elseif roll >= 93 then
    SendChatMessage(text, "YELL")
  elseif roll >= 91 then
    SendChatMessage(text, "SAY")
  elseif roll >= 87 then
    SendChatMessage(text, "GUILD")
  else
    godChat(text)
  end
end

local function GOD_EnsureDB()
  if type(WorkThatGodBodDB) ~= "table" then WorkThatGodBodDB = {} end
  if type(WorkThatGodBodDB.chars) ~= "table" then WorkThatGodBodDB.chars = {} end

  local key = charKey()
  if type(WorkThatGodBodDB.chars[key]) ~= "table" then
    WorkThatGodBodDB.chars[key] = {
      slots = {},
      timer = 60,
      chance = 100,
      enabled = true,
    }
  end

  if type(WorkThatGodBodDB.chars[key].slots) ~= "table" then
    WorkThatGodBodDB.chars[key].slots = {}
  end

  return WorkThatGodBodDB.chars[key]
end

local function GOD_LoadOnce()
  if GOD._loaded then return end
  local db = GOD_EnsureDB()

  GOD.db = db
  GOD.slots = db.slots

  if db.timer ~= nil then GOD.timer = db.timer end
  if db.chance ~= nil then GOD.chance = db.chance end
  if db.enabled ~= nil then GOD.enabled = db.enabled end

  GOD._loaded = true
end

local function GOD_Trigger(now)
  if not GOD.enabled then return end
  if now - (GOD.last or 0) < (GOD.timer or 0) then return end

  GOD.last = now

  if math.random(1, 100) <= (GOD.chance or 0) then
    local msg = U.pick(EXERCISES)
    if msg and msg ~= "" then
      outputExercise(msg)
    end
  end
end

-------------------------------------------------
-- Hook UseAction
-------------------------------------------------
local _Orig_UseAction = UseAction
function UseAction(slot, checkCursor, onSelf)
  GOD_LoadOnce()

  local now = GetTime()

  if GOD.watchMode then
    godChat("pressed slot " .. tostring(slot))
  end

  if GOD.slots and GOD.slots[slot] then
    GOD_Trigger(now)
  end

  return _Orig_UseAction(slot, checkCursor, onSelf)
end

-------------------------------------------------
-- Slash Commands: /godbod
-------------------------------------------------
SLASH_GODBOD1 = "/godbod"
SlashCmdList["GODBOD"] = function(raw)
  GOD_LoadOnce()
  local cmd, rest = U.split_cmd(raw)
  cmd = U.upper(cmd)

  if cmd == "SLOT" then
    local n = tonumber(rest)
    if n and n >= 1 then
      GOD.slots[n] = true
      godChat("watching slot " .. tostring(n))
    else
      godChat("usage: /godbod slot <n>")
    end
    return
  end

  if cmd == "UNSLOT" then
    local n = tonumber(rest)
    if n then
      GOD.slots[n] = nil
      godChat("removed slot " .. tostring(n))
    else
      godChat("usage: /godbod unslot <n>")
    end
    return
  end

  if cmd == "CLEAR" then
    GOD.slots = {}
    GOD.db.slots = GOD.slots
    godChat("all slots cleared")
    return
  end

  if cmd == "WATCH" then
    GOD.watchMode = not GOD.watchMode
    godChat("watch mode " .. (GOD.watchMode and "ON" or "OFF"))
    return
  end

  if cmd == "CHANCE" then
    local n = tonumber(rest)
    if n and n >= 0 and n <= 100 then
      GOD.chance = n
      GOD.db.chance = n
      godChat("trigger chance set to " .. tostring(n) .. "%")
    else
      godChat("usage: /godbod chance <0-100>")
    end
    return
  end

  if cmd == "TIMER" then
    local n = tonumber(rest)
    if n and n >= 0 then
      GOD.timer = n
      GOD.db.timer = n
      godChat("timer set to " .. tostring(n) .. "s")
    else
      godChat("usage: /godbod timer <seconds>")
    end
    return
  end

  if cmd == "ON" then
    GOD.enabled = true
    GOD.db.enabled = true
    godChat("enabled.")
    return
  end

  if cmd == "OFF" then
    GOD.enabled = false
    GOD.db.enabled = false
    godChat("disabled.")
    return
  end

  if cmd == "INFO" then
    local count = 0
    for _ in pairs(GOD.slots or {}) do count = count + 1 end
    godChat("slots watched: " .. tostring(count) ..
      " | chance: " .. tostring(GOD.chance) .. "%" ..
      " | timer: " .. tostring(GOD.timer) .. "s" ..
      " | enabled: " .. tostring(GOD.enabled))
    return
  end

  godChat("/godbod slot <n> | unslot <n> | clear | watch | chance <0-100> | timer <s> | on | off | info")
end

-------------------------------------------------
-- Init / Save
-------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LOGOUT")

f:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_LOGIN" then
    math.randomseed(math.floor(GetTime() * 1000))
    math.random()
  elseif event == "PLAYER_LOGOUT" then
    if GOD.db then
      GOD.db.slots = GOD.slots
      GOD.db.timer = GOD.timer
      GOD.db.chance = GOD.chance
      GOD.db.enabled = GOD.enabled
    end
  end
end)

