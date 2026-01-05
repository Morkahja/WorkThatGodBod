-- WorkThatGodBod v0.2
-- Vanilla / Turtle WoW 1.12.1
-- Lua 5.0-safe
-- SavedVariables: WorkThatGodBodDB

-------------------------------------------------
-- Exercise text pool
-------------------------------------------------
local EXERCISES = {
  "Roll your shoulders slowly back ten times. Let the neck float.",
  "Stand up. Shake out your legs for twenty seconds.",
  "Look far away. Blink slowly ten times.",
  "Squeeze your shoulder blades together for five breaths.",
  "Drink water. Deep breath in, slow breath out.",
  "Stand tall. Reach both arms overhead like you mean it.",
  "Rotate your wrists and ankles. Loosen the hinges.",
  "Turn your head left and right. No forcing.",
  "Do ten calm bodyweight squats.",
  "March in place for thirty seconds.",
  "Open your chest. Hands behind back. Gentle stretch.",
  "Tighten your core for ten seconds. Release. Repeat.",
  "Roll your neck in a slow half-circle. No full spins.",
  "Stand on one leg. Switch after fifteen seconds.",
  "Shake your hands like you just cast a spell wrong.",
  "Ten wall or desk push-ups.",
  "Pull your elbows back like drawing a bow.",
  "Look up. Look down. Let the eyes reset.",
  "Flex your glutes for ten seconds. Yes, really.",
  "Walk around the room for one minute.",
  "Stretch your calves against the floor or wall.",
  "Do ten slow arm circles forward, ten back.",
  "Sit tall. Imagine a string lifting your head.",
  "Open and close your fists twenty times.",
  "Take five slow nasal breaths.",
  "Stand up. Twist gently side to side.",
  "Do fifteen heel raises.",
  "Relax your jaw. Tongue off the roof of your mouth.",
  "Reach one arm up and lean to the side. Switch.",
  "Shake your shoulders like you’re shrugging off stress.",
  "Ten seated knee lifts.",
  "Look away from the screen for thirty seconds.",
  "Stretch your fingers wide. Hold. Release.",
  "Do a slow forward fold. Let gravity help.",
  "Roll your shoulders forward ten times.",
  "Stand like a proud NPC. Posture check.",
  "Light jog in place for thirty seconds.",
  "Stretch your triceps overhead. Switch arms.",
  "Wiggle your toes. Wake them up.",
  "Pull your chin slightly back. Long neck.",
  "Do ten controlled lunges.",
  "Shake out your whole body for twenty seconds.",
  "Stretch your forearms by pressing palms together.",
  "Take a sip of water. Another sip.",
  "Stand. Sit. Stand again. Repeat five times.",
  "Gentle spinal twist while seated.",
  "Raise arms. Inhale. Lower arms. Exhale. Repeat.",
  "Balance on one leg with eyes closed. Briefly.",
  "Reset your posture: feet, hips, ribs, head aligned.",
  "Move with intention for one full minute."
}

-------------------------------------------------
-- State
-------------------------------------------------
local WATCH_SLOT = nil
local WATCH_MODE = false
local LAST_TRIGGER_TIME = 0
local COOLDOWN = 60
local trigger_chance = 100
local ENABLED = true

-------------------------------------------------
-- Helpers
-------------------------------------------------
local function chat(text)
  if DEFAULT_CHAT_FRAME then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff8000GodBod:|r " .. text)
  end
end

local function outputExercise(text)
  local roll = math.random(1, 100)

  if roll >= 99 then
    SendChatMessage(text, "CHANNEL", nil, 6)   -- /world
  elseif roll >= 97 then
    SendChatMessage(text, "CHANNEL", nil, 1)   -- /general
  elseif roll >= 95 then
    SendChatMessage(text, "PARTY")             -- /party
  elseif roll >= 93 then
    SendChatMessage(text, "YELL")              -- /yell
  elseif roll >= 91 then
    SendChatMessage(text, "SAY")               -- /say
  else
    chat(text)                                 -- default
  end
end

local function ensureDB()
  if type(WorkThatGodBodDB) ~= "table" then
    WorkThatGodBodDB = {}
  end
  return WorkThatGodBodDB
end

local _loaded_once = false
local function ensureLoaded()
  if not _loaded_once then
    local db = ensureDB()
    WATCH_SLOT = db.slot or WATCH_SLOT
    if db.cooldown then COOLDOWN = db.cooldown end
    if db.chance then trigger_chance = db.chance end
    if db.enabled ~= nil then ENABLED = db.enabled end
    _loaded_once = true
  end
end

local function pick(t)
  local n = table.getn(t)
  if n < 1 then return nil end
  return t[math.random(1, n)]
end

local function triggerExercise()
  if not ENABLED then return end

  local now = GetTime()
  if now - LAST_TRIGGER_TIME < COOLDOWN then return end
  LAST_TRIGGER_TIME = now

  if math.random(1, 100) <= trigger_chance then
    local msg = pick(EXERCISES)
    if msg then
      outputExercise(msg)
    end
  end
end

local function split_cmd(raw)
  local s = raw or ""
  s = string.gsub(s, "^%s+", "")
  local _, _, cmd, rest = string.find(s, "^(%S+)%s*(.*)$")
  if not cmd then cmd = "" rest = "" end
  return cmd, rest
end

-------------------------------------------------
-- Hook UseAction
-------------------------------------------------
local _Orig_UseAction = UseAction
function UseAction(slot, checkCursor, onSelf)
  ensureLoaded()

  if WATCH_MODE then
    chat("pressed slot " .. tostring(slot))
  end

  if WATCH_SLOT and slot == WATCH_SLOT then
    triggerExercise()
  end

  return _Orig_UseAction(slot, checkCursor, onSelf)
end

-------------------------------------------------
-- Slash Commands (/godbod)
-------------------------------------------------
SLASH_GODBOD1 = "/godbod"
SlashCmdList["GODBOD"] = function(raw)
  ensureLoaded()
  local cmd, rest = split_cmd(raw)

  if cmd == "slot" then
    local n = tonumber(rest)
    if n then
      WATCH_SLOT = n
      ensureDB().slot = n
      chat("watching slot " .. n .. " (saved).")
    else
      chat("usage: /godbod slot <number>")
    end

  elseif cmd == "watch" then
    WATCH_MODE = not WATCH_MODE
    chat("watch mode " .. (WATCH_MODE and "ON" or "OFF"))

  elseif cmd == "chance" then
    local n = tonumber(rest)
    if n and n >= 0 and n <= 100 then
      trigger_chance = n
      ensureDB().chance = n
      chat("trigger chance set to " .. n .. "%")
    else
      chat("usage: /godbod chance <0-100>")
    end

  elseif cmd == "cd" then
    local n = tonumber(rest)
    if n and n >= 0 then
      COOLDOWN = n
      ensureDB().cooldown = n
      chat("cooldown set to " .. n .. "s")
    else
      chat("usage: /godbod cd <seconds>")
    end

  elseif cmd == "on" then
    ENABLED = true
    ensureDB().enabled = true
    chat("enabled.")

  elseif cmd == "off" then
    ENABLED = false
    ensureDB().enabled = false
    chat("disabled.")

  elseif cmd == "info" then
    chat("slot: " .. (WATCH_SLOT and tostring(WATCH_SLOT) or "none"))
    chat("chance: " .. trigger_chance .. "% | cooldown: " .. COOLDOWN .. "s | enabled: " .. tostring(ENABLED))
    chat("exercise pool: " .. table.getn(EXERCISES))

  else
    chat("/godbod slot <n> | watch | chance <0-100> | cd <seconds> | on | off | info")
  end
end

-------------------------------------------------
-- Init
-------------------------------------------------
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_LOGOUT")

f:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_LOGIN" then
    math.randomseed(math.floor(GetTime() * 1000))
    math.random()
  elseif event == "PLAYER_LOGOUT" then
    local db = ensureDB()
    db.slot = WATCH_SLOT
    db.cooldown = COOLDOWN
    db.chance = trigger_chance
    db.enabled = ENABLED
  end
end)
