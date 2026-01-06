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
  "Move with intention for one full minute.",
  "Slowly tilt your head ear to shoulder. Switch sides.",
"Clench fists for five seconds. Release fully.",
"Press your feet into the floor. Feel the ground.",
"Slide your shoulders up, back, then down.",
"Straighten one leg. Flex the foot. Switch.",
"Tap your toes rapidly for twenty seconds.",
"Gently massage your temples in small circles.",
"Interlace fingers. Push palms forward. Stretch upper back.",
"Draw slow circles with your nose.",
"Stand and stretch one arm across the chest. Switch.",
"Lift shoulders to ears. Hold three seconds. Drop.",
"Rotate your torso slowly while seated.",
"Extend arms out. Make small pulses backward.",
"Open your mouth wide. Close gently. Repeat.",
"Seated hamstring stretch. One leg at a time.",
"Press palms into desk. Straighten arms. Chest stretch.",
"Slow ankle circles in both directions.",
"March slowly, lifting knees high.",
"Rest eyes. Cover them with palms for ten seconds.",
"Engage core lightly while breathing normally.",
"Seated cat-cow spinal movement.",
"Lift heels, then toes, alternating.",
"Draw figure eights with your shoulders.",
"Stretch one side of neck diagonally. Switch.",
"Stand and gently sway side to side.",
"Extend arms overhead. Interlace fingers. Reach up.",
"Slowly open chest while inhaling.",
"Tap fingers to thumb, one by one.",
"Straighten spine. Lengthen, don’t stiffen.",
"Press knees outward gently while seated.",
"Shake out forearms from elbows down.",
"Do ten slow seated calf pumps.",
"Clasp hands behind head. Elbows wide.",
"Deep belly breath for five counts.",
"Stretch one quad by bending knee back. Switch.",
"Roll feet over imaginary pebbles.",
"Lift arms to shoulder height. Hold briefly.",
"Turn head diagonally left and right.",
"Lightly bounce on the balls of your feet.",
"Seated side bend. Switch sides.",
"Relax shoulders away from ears.",
"Press palms together firmly for five seconds.",
"Extend one arm up, one down. Switch.",
"Slow controlled sit-back squat.",
"Rotate ribcage gently without moving hips.",
"Stand tall and breathe into your back.",
"Open hands like releasing energy.",
"Reset spine from pelvis upward.",
"Move joints gently, no force."
}

-------------------------------------------------
-- State
-------------------------------------------------
local WATCH_SLOTS = {}        -- multislot table: [slot] = true
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
    SendChatMessage(text, "CHANNEL", nil, 6)
  elseif roll >= 97 then
    SendChatMessage(text, "CHANNEL", nil, 1)
  elseif roll >= 95 then
    SendChatMessage(text, "PARTY")
  elseif roll >= 93 then
    SendChatMessage(text, "YELL")
  elseif roll >= 91 then
    SendChatMessage(text, "SAY")
  else
    chat(text)
  end
end

local function ensureDB()
  if type(WorkThatGodBodDB) ~= "table" then
    WorkThatGodBodDB = {}
  end
  if type(WorkThatGodBodDB.slots) ~= "table" then
    WorkThatGodBodDB.slots = {}
  end
  return WorkThatGodBodDB
end

local _loaded_once = false
local function ensureLoaded()
  if _loaded_once then return end
  local db = ensureDB()
  WATCH_SLOTS = db.slots
  if db.cooldown then COOLDOWN = db.cooldown end
  if db.chance then trigger_chance = db.chance end
  if db.enabled ~= nil then ENABLED = db.enabled end
  _loaded_once = true
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
    if msg then outputExercise(msg) end
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

  if WATCH_SLOTS[slot] then
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
    if n and n >= 1 then
      WATCH_SLOTS[n] = true
      chat("watching slot " .. n .. " (added).")
    else
      chat("usage: /godbod slot <number>")
    end

  elseif cmd == "unslot" then
    local n = tonumber(rest)
    if n then
      WATCH_SLOTS[n] = nil
      chat("removed slot " .. n)
    else
      chat("usage: /godbod unslot <number>")
    end

  elseif cmd == "clear" then
    WATCH_SLOTS = {}
    ensureDB().slots = WATCH_SLOTS
    chat("all slots cleared.")

  elseif cmd == "watch" then
    WATCH_MODE = not WATCH_MODE
    chat("watch mode " .. (WATCH_MODE and "ON" or "OFF"))

  elseif cmd == "chance" then
    local n = tonumber(rest)
    if n and n >= 0 and n <= 100 then
      trigger_chance = n
      ensureDB().chance = n
      chat("trigger chance set to " .. n .. "%")
    end

  elseif cmd == "cd" then
    local n = tonumber(rest)
    if n and n >= 0 then
      COOLDOWN = n
      ensureDB().cooldown = n
      chat("cooldown set to " .. n .. "s")
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
    local count = 0
    for _ in pairs(WATCH_SLOTS) do count = count + 1 end
    chat("slots watched: " .. count)
    chat("chance: " .. trigger_chance .. "% | cooldown: " .. COOLDOWN .. "s | enabled: " .. tostring(ENABLED))

  else
    chat("/godbod slot <n> | unslot <n> | clear | watch | chance <0-100> | cd <s> | on | off | info")
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
    db.slots = WATCH_SLOTS
    db.cooldown = COOLDOWN
    db.chance = trigger_chance
    db.enabled = ENABLED
  end
end)
