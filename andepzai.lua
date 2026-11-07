--[[
  andepzai / CRYSTAL WHITE LIQUID GLASS 22.0 — PROGRESSION & PICKUP RELIABILITY
  An independent Blox Fruits Luau hub, informed by supplied farm scripts and
  Spooky Hub non-UI modules. This build embeds its own UI. No original source-hub UI, library, or
  remote third-party Lua is loaded.
  Runtime: Blox Fruits client and executor-supported features where needed.
  Controls that depend on game internals may need updates after game patches.
]]
local env = (type(getgenv) == "function" and getgenv()) or _G
-- Re-execution cleans up both this release and the previous standalone hub.
for _,slot in ipairs({"__ANDEPZAI_V22","__ANDEPZAI_V21","__ANDEPZAI_V20","__ANDEPZAI_V19","__ANDEPZAI_V18","__ANDEPZAI_V17","__ANDEPZAI_V16","__ANDEPZAI_V15","__ANDEPZAI_V14","__ANDEPZAI_V13","__ANDEPZAI_V12","__ANDEPZAI_V11","__ANDEPZAI_V10","__ANDEPZAI_V9","__ANDEPZAI_V8","__ANDEPZAI_V7","__ANDEPZAI_V6","__ANDEPZAI_V5","__ANDEPZAI_V4","__ANDEPZAI_V3"}) do
    local previous=env[slot]
    if type(previous)=="table" and type(previous.Destroy)=="function" then
        pcall(previous.Destroy)
    end
end

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local Tween = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Run = game:GetService("RunService")
local Http = game:GetService("HttpService")
local TP = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer
if not LP then warn("[andepzai] LocalPlayer not found"); return end
local STATE = { Alive=true, Connections={}, ESP={}, Jobs={}, UI={}, Start=os.clock(), Logs={}, Tween=nil,
    Pages={}, ThemeObjects={}, LastQuest=0, LastRemote={}, StatsClock=0, World=0 }
env.__ANDEPZAI_V22 = STATE
STATE.MoveThreadOwners=setmetatable({},{__mode="k"})
STATE.MovementLock=nil
local PLACE = { [2753915549]=1,[85211729168715]=1,[4442272183]=2,[79091703265657]=2,
    [7449423635]=3,[100117331123089]=3 }
STATE.World = PLACE[game.PlaceId] or 0

local defaults = {
  FarmMode="Level", Weapon="Melee", Mob="Bandit", Boss="The Gorilla King", Material="Bones",
  FarmEnabled=false, AutoQuest=true, Combat=true, AutoHaki=true, AutoKen=false, AutoRace=false,
  AutoEquip=true, AutoSkill=false, SkillZ=true, SkillX=true, SkillC=false, SkillV=false, SkillF=false,
  FarmDistance=5, FarmHeight=18, TweenSpeed=350, AttackDelay=0.20, QuestDelay=4,
  FarmStyle="Above", FarmHoverLock=true, SafeFarm=false, LowHealth=25, MasteryThreshold=30,
  Noclip=true, AutoStats=false, Stat="Melee", AutoCollectFruit=false, AutoStoreFruit=false,
  AutoChest=false, AutoBerry=false, AutoMagnetToken=false, EventRadar=false,
  PickupMaxDistance=1400, PickupFailureCooldown=35, AutoBerryHop=false, BerryHopAfter=180,
  AutoRaid=false, AutoAdvanceRaid=false, AutoRaidCombat=false, Raid="Flame",
  AutoBuso=false, AutoObservation=false, AutoRaceV3=false, AutoRejoin=false, AntiAFK=false,
  ESPPlayer=false, ESPEnemy=false, ESPBoss=false, ESPFruit=false, ESPChest=false, ESPIsland=false,
  AutoFish=false, AutoSea=false, AutoSkillSea=false, AutoSeaBoat=false,
  AutoElite=false, AutoBones=false, AutoTyrant=false, AutoKatakuri=false,
  AutoPray=false, AutoBuyChip=false, AutoRedeem=false,
  AutoBuyFruit=false, BuyFruit="Rocket", AutoStoreOnlyValuable=false,
  AutoClick=false, AntiStun=false, BoostFPS=false, Team="Pirates",
  NameTag=true, ToggleKey="RightControl", Accent="Crystal", FloatingButton=true,
  GlassIntensity=82, BackgroundBlur=true, BlurStrength=5, ReducedMotion=false, HighContrast=false, SoftGlow=true,
  SelectedNPC="", SelectedIsland="", SelectedFruit="", SelectedPlayer="", MinFruitPrice=1000000,
  BoatSpeed=1, ESPDistance=800, AutoSkillDelay=1.8, ReduceEffects=false,
  -- Unified feature set derived from the three supplied references.
  AllBossFarm=false, AutoFactory=false, AutoPirateRaid=false, AutoEliteCombat=false,
  AutoSoulReaper=false, AutoDarkbeard=false, AutoRipIndra=false, AutoDoughKing=false,
  AutoHallowBuy=false, AutoDoughSummon=false, AutoBossHop=false, BossHopDelay=90,
  AutoAwaken=false, AutoLawRaid=false, AutoBuyLawChip=false, FragmentsCap=0,
  AutoLegendarySword=false, AutoHakiColor=false, AutoBuyChosenFruit=false,
  AutoSellFish=false, AutoFishQuest=false, AutoDodgeSkill=false,
  AutoEventCollect=false, EventPickup="Dino Bones", EventTravel=false,
  SeaEncounter="Any", AutoSeaSkill=false, AutoFollowPlayer=false,
  AutoRaceV4=false, AutoObservationTrain=false, AutoFullBright=false,
  AutoFPS=false, AutoSafeItems=false, AutoFruitHop=false, AutoSeaHop=false,
  AutoBoatRepair=false, SelectedBoat="Guardian", SeaZone="Zone 1",
  SelectedCraft="Dragonheart", SelectedTrial="Good", SelectedSword="Saddi",
  SelectedBuyStyle="Godhuman", SelectedCombatMode="NPC", SelectedServerID="",
  AutoMeleeStyle=false, AutoOpenChest=false, AutoChestHop=false, AutoProgressTracker=false,
  ESPNPC=false, ESPBerry=false, ESPSea=false, AutoAutoJoinWorld=false,
  AutoBoatBuy=false, AutoRandomBones=false, AutoFruitDealer=false,
  WeaponMasteryTarget=400, AutoMasteryChain=false, AutoLowHPHeal=false,
  SmartPortal=false, PreferRouteData=false,
  -- V10: all gameplay automation opt-in, combat & quest subsystems.
  FastAttackEnabled=true, CombatMode="Adaptive", AttackRange=32,
  AutoAbandonWrongQuest=false, MovementMode="Proxy Tween",
  HalloweenPumpkins=false,
  MobMagnet=false, MobMagnetRadius=175, MobMagnetMax=6,
  AtlasUseScannedSpawns=true, AtlasIsland="", HalloweenReviveGrace=0.6,
  MoveRetargetThreshold=7, MoveRetargetDelay=0.40,
  -- Comprehensive optional modules from user's 7 additional source scripts.
  InputClickFallback=true, AutoCombatDiagnostics=true, MovementFailover=true,
  FishingAdvanced=true, FishingAutoCatch=true, FishingAutoBait=true, FishingGoVortex=false,
  FishingUseSaved=false, FishingHasPosition=false, FishingBait="Basic Bait",
  FishingCastDelay=5, FishingCastDistance=42,
  FishingX=0, FishingY=0, FishingZ=0, FishingHeading=0,
  SecretQuestIndex=1, SecretQuestName="[01] Escape from Alcatraz", AutoSecretQuestRoute=false,
  EventPromptKeyword="Pumpkin", BoatCruiseSpeed=170,

  -- v15: Spooky source mechanics, rewritten into the andepzai runtime; NO Spooky UI or loader.
  SpookyFastAttack=false,SpookyM1Extender=false,SpookyGunAura=false,
  SpookyPVP=false,SpookyManualTargetOnly=true,SpookyTeamCheck=true,
  SpookySafeZoneCheck=true,SpookyMinPlayerLevel=0,SpookyBlacklist="",
  SpookyTargetRange=120,SpookyAttackDelay=.18,SpookyM1Range=90,PVEHitProtocol="Spooky",
  SpookyCamLock=false,SpookyAimNPC=false,SpookyAimSmoothness=.22,
  SpookyAutoBounty=false,SpookyBountyChase=false,SpookyBountyHPMin=30,
  SpookyMacroSequence="Melee:Z:0.30,Melee:X:0.40,Sword:Z:0.35,Sword:X:0.50",
  SpookyMacroLoop=false,SpookyMacroSlot="1",
  SpookyMacroSlot1="Melee:Z:0.30,Melee:X:0.40,Sword:Z:0.35,Sword:X:0.50",
  SpookyMacroSlot2="Fruit:Z:0.35,Fruit:X:0.45,Fruit:C:0.55,Fruit:V:0.65",
  SpookyMacroSlot3="Equipped:M1:0.16,Equipped:M1:0.16,Equipped:M1:0.20",
  SpookyMacroSlot4="Melee:Z:0.3,Fruit:Z:0.35,Sword:X:0.4",
  SpookyMacroSlot5="Gun:Z:0.3,Sword:Z:0.3,Fruit:X:0.4",
  SpookyAutoDungeon=false,SpookyDungeonHeight=12,
  SpookyFly=false,SpookyFlySpeed=65,SpookyWalkSpeed=false,SpookySpeed=60,
  SpookyBunnyHop=false,SpookyAntiStun=false,SpookyWaterWalk=false,
  SpookyInfiniteZoom=false,SpookyCameraFOVEnabled=false,SpookyCameraFOV=75,
  SpookyPlayerChams=false,SpookyNPCChams=false,
  SpookyHitboxNPC=false,SpookyHitboxPVP=false,SpookyHitboxSize=12,
  SpookyNoFog=false,SpookyNoShadows=false,SpookyLowTextures=false,
  SpookySuperJump=false,SpookyJumpPower=110,SpookyNoAnimation=false,SpookyDashDistance=70,
  SpookyTracers=false,SpookyRainbowChams=false,SpookyHeadlessLocal=false,
  SpookyAccessoryNoclip=false,SpookyGiantLocal=false,SpookyGiantScale=1.6,
  SpookyShader=false,SpookyTimeOverride=false,SpookyClockTime=14,
}
local Config = {}
for k,v in pairs(defaults) do Config[k]=v end
local FOLDER = "andepzai"
local FILE = FOLDER .. "/config_v22.json"
local function canFile(method) return type(env[method])=="function" or type(_G[method])=="function" end
local function api(method)
    return (type(env[method])=="function" and env[method]) or (type(_G[method])=="function" and _G[method])
end
local function save()
    if not canFile("writefile") then return false end
    local data = {}
    for k in pairs(defaults) do
        if type(Config[k])=="boolean" or type(Config[k])=="number" or type(Config[k])=="string" then
            data[k]=Config[k]
        end
    end
    local ok = pcall(function()
        if canFile("makefolder") and canFile("isfolder") and not api("isfolder")(FOLDER) then api("makefolder")(FOLDER) end
        api("writefile")(FILE,Http:JSONEncode(data))
    end)
    return ok
end
local function load()
    if not (canFile("readfile") and canFile("isfile")) then return false end
    local chosenPath=FILE
    local ok,decoded = pcall(function()
        local path=FILE
        if not api("isfile")(path) then path=FOLDER.."/config_v21.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v20.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v19.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v18.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v17.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v16.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v15.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v14.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v13.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v12.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v11.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v10.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v9.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v8.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v7.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v6.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v3.json" end
        if not api("isfile")(path) then return nil end
        chosenPath=path
        return Http:JSONDecode(api("readfile")(path))
    end)
    if not ok or type(decoded)~="table" then return false end
    for k,v in pairs(decoded) do
        if defaults[k]~=nil and type(v)==type(defaults[k]) then Config[k]=v end
    end
    -- Never auto-start gameplay or resume old background jobs on reinjection.
    for k,v in pairs(defaults) do if type(v)=="boolean" and v==false then Config[k]=false end end
    return true,chosenPath
end
local loadedPreset,loadedFrom=load()
-- Only if no prior config was loaded, install a complete *passive* farm setup.
-- These flags only take effect after the user explicitly enables FarmEnabled.
if not loadedPreset then
    for key,value in pairs({
        FarmMode="Level",Weapon="Melee",FarmStyle="Above",FarmDistance=5,
        FarmHeight=18,FarmHoverLock=true,TweenSpeed=350,AttackDelay=0.20,QuestDelay=4,
        AutoQuest=true,Combat=true,AutoEquip=true,AutoHaki=true,Noclip=true,
        FastAttackEnabled=true,CombatMode="Adaptive",AttackRange=32,
        MoveRetargetThreshold=5,MoveRetargetDelay=0.35,
        MovementMode="Proxy Tween",SmartPortal=false,
    }) do Config[key]=value end
end
-- One-time migration: old presets often saved 160; update to the requested 350.
-- On later v21 launches respect the user-selected slider speed.
if not loadedPreset then Config.TweenSpeed=350 end
Config.FarmEnabled=false -- Explicit START is required even if old config was running.
save()
local function on(obj,signal,fn)
    if not STATE.Alive then return end
    local c = signal:Connect(fn); table.insert(STATE.Connections,c); return c
end
local function slog(text,level)
    local message=tostring(text)
    table.insert(STATE.Logs,1,{t=os.date("%H:%M:%S"),text=message,level=level or "info"})
    if #STATE.Logs>80 then table.remove(STATE.Logs) end
    if STATE.PushLog then pcall(STATE.PushLog,message,level) end
    if level=="error" then warn("[andepzai] "..message) end
end
local function safe(name,fn)
    local ok,value = pcall(fn)
    if not ok then slog(name..": "..tostring(value),"error") end
    return ok,value
end
local function notice(title,body,level)
    slog(title.." - "..tostring(body),level)
    if STATE.Notify then pcall(STATE.Notify,title,body,level) end
end
local function alive()
    local char=LP.Character
    local hum=char and char:FindFirstChildOfClass("Humanoid")
    local root=char and char:FindFirstChild("HumanoidRootPart")
    return char,hum,root, hum~=nil and root~=nil and hum.Health>0
end
local function level()
    local data=LP:FindFirstChild("Data"); local v=data and data:FindFirstChild("Level")
    return (v and tonumber(v.Value)) or 1
end
local function value(name)
    local data=LP:FindFirstChild("Data"); local v=data and data:FindFirstChild(name)
    return (v and v.Value) or 0
end
local function remote(method,...)
    local f=RS:FindFirstChild("Remotes")
    local r=f and f:FindFirstChild("CommF_")
    if not r then return false,"CommF_ unavailable" end
    return pcall(r.InvokeServer,r,method,...)
end
local function event(method,...)
    local f=RS:FindFirstChild("Remotes")
    local r=f and f:FindFirstChild("CommE")
    if not r then return false,"CommE unavailable" end
    return pcall(r.FireServer,r,method,...)
end
local function throttle(key,secs,fn)
    if os.clock()-(STATE.LastRemote[key] or 0)<secs then return end
    STATE.LastRemote[key]=os.clock()
    return safe(key,fn)
end
local function norm(text)
    return tostring(text or ""):gsub("%s*%[[^%]]+%]",""):gsub("%s+$",""):lower()
end
local function enemyFolder() return WS:FindFirstChild("Enemies") end
local function isBoss(name)
    local n=norm(name)
    if tostring(name or ""):find("[Boss]",1,true) then return true end
    if STATE.Atlas and STATE.Atlas.Bosses and STATE.Atlas.Bosses[STATE.World]
        and STATE.Atlas.Bosses[STATE.World][n] then return true end
    return STATE.BossNames and STATE.BossNames[n] or false
end
local bossDB={
    [1]={"The Gorilla King","Bobby","The Saw","Yeti","Mob Leader","Vice Admiral","Saber Expert","Warden","Chief Warden","Swan","Magma Admiral","Fishman Lord","Wysper","Thunder God","Cyborg","Ice Admiral","Greybeard"},
    [2]={"Diamond","Jeremy","Orbitus","Don Swan","Smoke Admiral","Awakened Ice Admiral","Tide Keeper","Darkbeard","Cursed Captain","Order"},
    [3]={"Stone","Hydra Leader","Kilo Admiral","Captain Elephant","Beautiful Pirate","Cake Queen","Cake Prince","Dough King","Longma","Soul Reaper","rip_indra True Form","Tyrant of the Skies","Terrorshark","Leviathan"},
}
STATE.BossNames={}
for _,arr in pairs(bossDB) do for _,name in ipairs(arr) do STATE.BossNames[norm(name)]=true end end
local materialMobs = {
  ["Bones"]={"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"},
  ["Ectoplasm"]={"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer","Cursed Captain"},
  ["Magma Ore"]={"Lava Pirate","Magma Ninja","Military Soldier"},
  ["Leather"]={"Jungle Pirate","Musketeer Pirate","Pirate"},
  ["Scrap Metal"]={"Jungle Pirate","Musketeer Pirate","Pirate Millionaire"},
  ["Angel Wings"]={"God's Guard","Shanda","Royal Squad","Royal Soldier"},
  ["Fish Tail"]={"Fishman Raider","Fishman Captain","Fishman Warrior"},
  ["Radioactive Material"]={"Factory Staff"},
  ["Vampire Fang"]={"Vampire"},
  ["Mystic Droplet"]={"Sea Soldier","Water Fighter"},
  ["Mini Tusk"]={"Mythological Pirate"},
  ["Gunpowder"]={"Pistol Billionaire"},
  ["Demonic Wisp"]={"Demonic Soul"},
  ["Dragon Scale"]={"Dragon Crew Archer","Dragon Crew Warrior"},
  ["Conjured Cocoa"]={"Cocoa Warrior","Chocolate Bar Battler"},
}
local mobSpawns={
  ["Bandit"]={1038,16,1594},["Monkey"]={-1449,36,25},["Gorilla"]={-1220,6,-515},
  ["Pirate"]={-1239,12,3855},["Brute"]={-1142,14,4322},
  ["Desert Bandit"]={932,6,4489},["Desert Officer"]={1572,10,4389},
  ["Snow Bandit"]={1389,87,-1297},["Snowman"]={1218,138,-1488},
  ["Chief Petty Officer"]={-4842,20,4363},["Sky Bandit"]={-4981,278,-536},
  ["Dark Master"]={-5250,389,-2278},["Prisoner"]={5308,2,475},
  ["Dangerous Prisoner"]={5489,2,452},["Toga Warrior"]={-1779,44,1553},
  ["Gladiator"]={-1288,44,1535},["Military Soldier"]={634,12,1488},
  ["Military Spy"]={-88,77,4533},["Fishman Warrior"]={60883,18,1529},
  ["Fishman Commando"]={61943,18,1494},["God's Guard"]={-4725,845,-1940},
  ["Shanda"]={-7687,5567,-497},["Royal Squad"]={-7687,5567,-497},
  ["Royal Soldier"]={-7687,5567,-497},["Galley Pirate"]={5566,39,3998},
  ["Galley Captain"]={5731,47,4749},["Raider"]={-746,37,4477},
  ["Mercenary"]={-970,73,1426},["Swan Pirate"]={886,122,1132},
  ["Factory Staff"]={295,73,-54},["Marine Lieutenant"]={-2916,73,-3038},
  ["Marine Captain"]={-1861,73,-3329},["Zombie"]={-5688,48,-853},
  ["Vampire"]={-6032,32,-1316},["Snow Trooper"]={541,401,-5336},
  ["Winter Warrior"]={1176,407,-5265},["Lab Subordinate"]={-2467,406,-2517},
  ["Horned Warrior"]={-2447,44,-1987},["Magma Ninja"]={-5426,78,-5926},
  ["Lava Pirate"]={-5237,49,-4706},["Ship Deckhand"]={1038,125,32913},
  ["Ship Engineer"]={1038,125,32913},["Ship Steward"]={1038,125,32913},
  ["Ship Officer"]={1038,125,32913},["Arctic Warrior"]={6235,92,-5048},
  ["Snow Lurker"]={5560,45,-6829},["Sea Soldier"]={-3026,65,-3367},
  ["Water Fighter"]={-3385,24,-10632},["Sea Archer"]={-3500,5,-10485},
  ["Pirate Millionaire"]={-713,98,5712},["Pistol Billionaire"]={-723,147,5932},
  ["Dragon Crew Warrior"]={7022,56,-730},["Dragon Crew Archer"]={6625,378,244},
  ["Female Islander"]={4693,798,859},["Venomous Assailant"]={4902,670,39},
  ["Marine Commodore"]={2401,123,-7589},["Marine Rear Admiral"]={3588,229,-7085},
  ["Fishman Raider"]={-10941,332,-8760},["Fishman Captain"]={-11035,332,-9087},
  ["Forest Pirate"]={-13446,413,-7760},["Mythological Pirate"]={-13510,584,-6987},
  ["Jungle Pirate"]={-11778,426,-10592},["Musketeer Pirate"]={-13282,496,-9565},
  ["Reborn Skeleton"]={-8764,142,5963},["Living Zombie"]={-10227,421,6161},
  ["Demonic Soul"]={-9579,6,6194},["Posessed Mummy"]={-9579,6,6194},
  ["Peanut Scout"]={-1993,187,-10103},["Peanut President"]={-2215,159,-10474},
  ["Ice Cream Chef"]={-877,118,-11032},["Ice Cream Commander"]={-877,118,-11032},
  ["Cookie Crafter"]={-2021,38,-12028},["Cake Guard"]={-2024,38,-12026},
  ["Baking Staff"]={-1932,38,-12848},["Head Baker"]={-1932,38,-12848},
  ["Cocoa Warrior"]={95,73,-12309},["Chocolate Bar Battler"]={647,42,-12401},
  ["Sweet Thief"]={116,36,-12478},["Candy Rebel"]={47,61,-12889},
}
-- Client-replicated EnemySpawns/Locations from user Workspace.7z (four runs, 2026-11-07).
-- NOTE: observed spawn positions, not Quest ID/remote signatures or server authoritative data.
do
    local observedSpawns={
      [1]={
        ["bandit"]={{922.1,13.9,1528.0},{928.0,13.2,1597.3},{1000.9,16.4,1568.2},{1114.3,11.4,1590.2},{1147.2,11.4,1676.8},{1203.6,12.7,1563.3},{1210.0,12.8,1673.5},{1254.7,11.4,1623.1},{1280.8,11.6,1528.9},{1310.7,11.6,1593.1}},
        ["brute"]={{-1436.8,28.1,4357.2},{-1350.1,28.1,4285.1},{-1312.8,28.1,4402.9},{-1094.9,28.1,4442.9},{-1085.9,28.1,4342.7},{-942.4,29.7,4387.2}},
        ["chef"]={{-1120.5,54.7,4121.2}},
        ["chief petty officer"]={{-5002.2,11.0,4004.7},{-4938.4,11.0,3995.9},{-4836.4,16.3,4465.8},{-4828.6,13.1,4196.8},{-4780.5,13.9,4419.9},{-4763.7,13.4,4288.8},{-4674.6,11.0,4483.3},{-4650.6,11.0,4562.1}},
        ["cyborg"]={{6252.4,9.3,4941.4}},
        ["dangerous prisoner"]={{5058.3,9.1,900.9},{5122.9,9.1,969.9},{5188.9,9.1,1058.1},{5295.3,9.1,1104.8},{5456.4,9.1,956.0}},
        ["dark master"]={{-5411.2,504.9,-372.8},{-5283.2,505.1,-221.0},{-5269.0,505.0,-461.1},{-5206.8,504.7,-348.5}},
        ["desert bandit"]={{860.5,7.6,4539.8},{902.9,7.6,4461.4},{931.7,7.6,4564.5},{999.9,7.6,4490.3}},
        ["desert officer"]={{1523.8,15.3,4095.4},{1544.0,14.1,4241.0},{1608.4,14.2,4112.3},{1615.5,14.2,4187.4}},
        ["fishman commando"]={{61808.1,24.6,1328.6},{61872.9,24.6,1464.2},{61887.8,24.6,1232.5},{61992.6,24.6,1205.7},{61994.6,24.6,1425.5},{62013.0,24.6,1330.0}},
        ["fishman lord"]={{61352.9,67.2,1029.1}},
        ["fishman warrior"]={{60626.4,25.2,1142.8},{60716.0,25.3,1284.9},{60736.8,23.8,1396.3},{60788.4,23.8,1484.5},{60859.7,23.8,1328.2},{60892.3,23.8,1500.5},{60930.9,23.8,1393.1}},
        ["galley captain"]={{5385.5,78.7,4851.1},{5409.5,77.7,4687.0},{5544.0,76.9,4899.1},{5594.9,78.7,4751.9},{5685.4,77.7,4742.6},{5773.7,77.7,4703.1},{5782.2,79.3,4868.9},{5899.6,76.6,4809.0}},
        ["galley pirate"]={{5327.6,76.2,4014.5},{5430.4,78.0,3953.6},{5452.9,78.7,4112.6},{5670.6,79.5,4074.5},{5708.2,80.9,3928.1},{5840.0,76.8,3975.6}},
        ["gladiator"]={{-1238.9,11.6,-3241.2},{-1212.6,11.6,-3378.7},{-1161.9,11.6,-3097.2},{-1144.5,11.6,-3337.4},{-1118.9,11.6,-3014.2}},
        ["god's guard"]={{-4403.3,1088.2,-498.1},{-4364.8,1090.2,-383.5},{-4234.6,1089.3,-267.4},{-4227.2,1088.0,-567.6},{-4130.8,1090.3,-291.2},{-4082.8,1087.3,-414.1}},
        ["gorilla"]={{-1401.1,26.5,-464.0},{-1387.3,14.5,-577.8},{-1266.6,14.5,-462.0},{-1198.4,17.3,-689.9}},
        ["ice admiral"]={{1212.4,20.4,-1429.6}},
        ["lightning god"]={{-7125.4,5596.1,111.5}},
        ["magma general"]={{-5625.7,55.4,8623.0}},
        ["military soldier"]={{-5694.5,17.0,8329.2},{-5623.8,17.0,8314.1},{-5418.5,18.0,8421.1},{-5337.1,17.1,8629.3},{-5266.4,17.1,8554.2}},
        ["military spy"]={{-5952.6,76.9,8742.4},{-5890.0,76.6,8723.0},{-5809.0,77.3,8791.2},{-5714.9,76.6,8834.9}},
        ["mob boss"]={{-2880.7,6.7,5430.9}},
        ["monkey"]={{-1866.3,29.9,21.6},{-1758.7,30.9,-31.8},{-1637.5,30.0,19.6},{-1610.2,29.2,399.7},{-1525.6,27.2,164.0},{-1450.6,29.0,306.1},{-1299.4,17.6,81.4}},
        ["pirate"]={{-1313.7,18.9,3964.2},{-1285.1,18.0,3887.0},{-1176.8,19.7,4027.3},{-1122.8,19.9,3965.9},{-981.0,30.4,3966.8},{-963.9,27.6,4043.7}},
        ["prisoner"]={{5057.8,7.1,567.1},{5193.0,7.1,414.3},{5278.6,7.1,391.6},{5370.8,7.1,459.2},{5457.7,7.1,507.5}},
        ["royal soldier"]={{-7175.8,5541.1,947.1},{-7138.5,5541.1,1050.8},{-7137.4,5541.1,893.0},{-6938.4,5541.1,963.8},{-6932.1,5541.1,842.4}},
        ["royal squad"]={{-6920.7,5551.4,1191.9},{-6868.9,5554.9,1320.0},{-6804.7,5550.4,1083.6},{-6706.9,5551.4,1155.4},{-6690.0,5551.4,1318.3}},
        ["ruthless prisoner"]={{5271.4,16.4,799.6},{5272.9,16.4,673.6},{5329.3,49.4,819.5},{5393.9,16.4,673.6},{5393.9,16.4,795.3}},
        ["saber expert"]={{-1527.2,34.1,-33.2}},
        ["shanda"]={{-6040.2,5468.0,1734.2},{-6026.8,5469.6,1851.0},{-5956.5,5470.1,1750.6},{-5890.4,5468.9,1956.2},{-5878.8,5470.4,1864.2}},
        ["sky bandit"]={{-5221.6,280.7,-1068.6},{-5157.1,280.7,-916.7},{-5014.0,280.7,-972.1},{-4973.7,280.7,-1119.4}},
        ["sky warlord"]={{-6271.6,5472.8,1887.8}},
        ["snow bandit"]={{1260.3,78.0,-1387.6},{1364.1,78.0,-1429.7},{1431.8,78.0,-1444.9},{1502.0,78.0,-1402.4},{1519.5,78.0,-1510.9}},
        ["snowman"]={{1121.5,98.2,-1669.0},{1149.5,98.2,-1540.5},{1246.8,98.3,-1555.7},{1272.4,98.3,-1647.2}},
        ["the gorilla king"]={{-1193.9,10.7,-549.9}},
        ["toga warrior"]={{-1973.1,9.0,-2744.9},{-1829.7,9.0,-2661.5},{-1819.5,9.2,-2736.6},{-1694.8,9.2,-2633.3},{-1620.1,12.5,-2672.3},{-1533.1,12.5,-2781.3}},
        ["vice admiral"]={{-5010.8,15.1,4383.7}},
        ["warden"]={{5623.2,1.4,733.8}},
        ["yeti"]={{1181.7,104.0,-1616.9}},
      },
      [2]={
        ["diamond"]={{-1711.4,206.0,-97.1}},
        ["factory staff"]={{-426.9,72.8,-367.2},{-105.9,72.8,-670.2},{-93.9,72.8,-34.2},{386.1,72.8,91.8},{692.1,72.8,227.8},{936.1,72.8,-71.2}},
        ["horned warrior"]={{-6540.0,29.2,-5718.0},{-6446.0,31.0,-5858.3},{-6421.2,29.2,-5591.4},{-6331.8,29.2,-5778.9},{-6182.0,29.2,-5914.2},{-6133.4,29.2,-6049.0}},
        ["lab subordinate"]={{-5998.3,90.0,-4386.5},{-5897.8,81.7,-4554.6},{-5766.4,81.7,-4249.7},{-5693.3,81.7,-4628.3},{-5623.3,81.7,-4444.2}},
        ["lava pirate"]={{-5218.4,29.8,-4999.9},{-5111.3,32.2,-5115.9},{-5082.4,28.9,-4796.3},{-5005.5,28.0,-4916.1},{-5005.4,28.5,-5025.1}},
        ["magma ninja"]={{-5885.4,32.6,-5501.2},{-5846.0,50.3,-5671.0},{-5811.1,30.1,-5576.5},{-5790.1,28.9,-5393.2},{-5711.4,47.4,-5658.5},{-5657.3,34.2,-5551.6}},
        ["marine captain"]={{-2103.9,73.0,-3259.3},{-2030.2,73.0,-3477.6},{-1928.4,73.0,-3119.6},{-1805.4,73.0,-3313.3},{-1601.3,73.0,-3315.3}},
        ["marine lieutenant"]={{-3258.6,71.0,-2990.9},{-3012.8,71.0,-2921.8},{-2932.5,71.0,-2604.1},{-2766.1,71.0,-3144.8},{-2583.9,71.0,-3039.6}},
        ["mercenary"]={{-1209.2,72.9,1073.0},{-1135.9,72.9,1248.3},{-1085.2,72.9,1696.4},{-986.8,72.9,1088.5},{-924.7,72.9,1788.1},{-913.8,72.9,1574.2}},
        ["orbitus"]={{-2138.5,75.9,-4326.5}},
        ["raider"]={{-917.4,40.0,2250.4},{-904.3,40.0,2501.4},{-612.4,40.0,2557.4},{-607.4,40.0,2202.4},{241.6,40.0,2195.4},{265.6,40.0,2497.4},{475.6,40.0,2433.4},{549.6,40.0,2190.4}},
        ["rip_indra"]={{-26952.3,21.5,329.4}},
        ["sea soldier"]={{-3499.3,16.1,-9712.0},{-3459.7,25.6,-9934.8},{-3293.1,5.9,-9640.9},{-3240.3,27.4,-9814.0},{-2840.1,27.4,-9814.4},{-2550.9,28.4,-9840.0}},
        ["ship deckhand"]={{580.3,125.6,32930.1},{580.3,125.6,33124.2},{719.3,125.6,33032.1},{1157.3,125.6,32930.1},{1176.3,125.6,33119.1},{1247.3,125.6,33218.1},{1259.3,125.6,33032.1}},
        ["ship engineer"]={{729.2,43.7,32950.3},{815.6,43.7,33111.3},{834.8,43.7,32720.9},{1016.8,43.7,33074.1},{1025.7,43.7,32740.9},{1088.2,43.7,32890.1}},
        ["ship officer"]={{505.5,179.9,33263.6},{657.5,179.9,33460.6},{694.5,179.9,33112.6},{1144.5,179.9,33112.6},{1162.5,179.9,33445.6},{1320.5,179.9,33294.6}},
        ["ship steward"]={{801.4,125.8,33505.2},{815.0,125.8,33376.2},{918.7,125.8,33506.5},{986.9,125.8,33366.9},{1032.5,125.8,33512.4}},
        ["smoke admiral"]={{-4857.4,233.7,-5583.2}},
        ["snow lurker"]={{5443.4,27.6,-7031.3},{5484.4,27.6,-6733.8},{5524.2,27.6,-6583.8},{5567.9,27.6,-6900.5},{5763.9,27.6,-6671.1}},
        ["snow trooper"]={{392.2,400.8,-5207.7},{430.4,400.8,-5069.1},{445.9,442.8,-5553.9},{484.4,400.8,-5472.4},{572.7,400.8,-5605.2},{642.7,400.8,-5454.5},{716.6,400.8,-5706.4}},
        ["swan pirate"]={{823.6,72.8,1162.2},{827.8,72.8,1326.9},{967.2,73.0,1180.8},{984.6,72.8,1401.7},{1063.2,72.8,1399.8},{1067.0,72.8,1080.9}},
        ["vampire"]={{-6277.3,9.0,-1269.5},{-6132.4,9.0,-1466.2},{-6039.7,9.0,-1099.2},{-5953.0,9.0,-1568.5},{-5776.6,9.0,-1373.5}},
        ["winter warrior"]={{1043.3,428.8,-5049.8},{1142.4,428.8,-5043.1},{1205.5,428.8,-5397.4},{1226.3,428.8,-5216.0},{1371.9,428.8,-5194.7},{1446.3,428.8,-5369.2}},
        ["zombie"]={{-5856.6,70.3,-739.0},{-5766.6,47.5,-824.7},{-5762.0,49.3,-654.9},{-5615.0,49.3,-938.5},{-5595.6,49.3,-524.2},{-5512.2,49.3,-848.0}},
      },
      [3]={
        ["baking staff"]={{-1980.4,34.7,-12983.8},{-1847.2,34.7,-13132.5},{-1828.8,34.7,-12699.4},{-1774.1,34.7,-12850.5},{-1759.3,34.7,-12994.8},{-1720.8,34.7,-13087.1}},
        ["beautiful pirate"]={{5367.3,26.4,-64.7}},
        ["cake guard"]={{-1736.5,35.2,-12249.1},{-1694.0,35.2,-12436.8},{-1531.4,35.2,-12132.4},{-1471.1,35.2,-12436.8},{-1418.5,35.2,-12255.7}},
        ["cake queen"]={{-678.5,381.9,-11114.4}},
        ["candy pirate"]={{-1440.3,32.5,-14435.9},{-1428.2,36.4,-14637.9},{-1378.7,38.0,-14802.9},{-1332.7,24.3,-14327.4},{-1255.8,33.5,-14507.1},{-1226.8,36.3,-14777.6}},
        ["candy rebel"]={{-72.1,25.6,-12940.3},{47.9,25.6,-13029.2},{53.0,26.6,-12851.7},{166.8,25.6,-13035.4},{220.4,26.6,-12914.0}},
        ["chocolate bar battler"]={{582.8,25.6,-12550.7},{598.8,25.6,-12395.1},{701.3,25.6,-12708.2},{717.5,25.6,-12557.7},{807.0,25.6,-12773.1},{833.2,25.6,-12671.4}},
        ["cocoa warrior"]={{-128.7,26.2,-12249.8},{-125.0,26.2,-12345.8},{6.3,26.2,-12305.2},{34.8,26.2,-12169.7},{168.0,26.2,-12238.9}},
        ["cookie crafter"]={{-2499.2,37.0,-12165.0},{-2464.5,37.0,-12049.9},{-2423.4,37.0,-12265.8},{-2342.9,37.0,-12009.2},{-2321.7,37.0,-12216.8},{-2246.4,37.0,-12126.9},{-2212.9,37.0,-11969.3}},
        ["coral pirate"]={{10646.8,-2087.3,9304.2},{10703.7,-2087.3,9255.4},{10733.2,-2087.3,9411.1},{10824.5,-2087.3,9357.2},{10839.5,-2087.3,9486.1}},
        ["demonic soul"]={{-9754.0,171.9,6166.4},{-9632.0,171.9,6053.4},{-9566.0,171.9,6235.4},{-9427.0,171.9,6048.4},{-9345.0,171.9,6201.4},{-9254.0,171.9,6050.4}},
        ["dragon crew archer"]={{6582.8,521.3,505.3},{6668.8,481.4,329.1},{6762.5,481.4,110.8},{6818.6,482.9,512.7},{6948.5,482.9,185.0}},
        ["dragon crew warrior"]={{6473.2,52.3,-1231.8},{6615.2,52.3,-978.9},{6709.8,52.3,-1139.0},{6919.1,57.7,-940.8},{6998.8,53.7,-519.4},{7217.8,56.6,-680.8}},
        ["fishman captain"]={{-11210.3,331.8,-9072.7},{-11135.2,331.8,-9240.9},{-11107.9,331.8,-8842.9},{-11072.6,331.8,-8610.1},{-10828.1,331.8,-9049.1},{-10736.7,331.8,-8807.6}},
        ["fishman raider"]={{-10853.9,332.6,-8425.2},{-10603.6,332.6,-8309.1},{-10523.8,332.6,-8597.6},{-10391.7,332.6,-8212.3},{-10223.1,332.6,-8482.5},{-10118.0,332.6,-8174.7}},
        ["forest pirate"]={{-13651.5,332.2,-7894.8},{-13600.5,332.2,-7741.8},{-13513.5,332.2,-8008.8},{-13345.5,332.2,-7630.8},{-13279.5,332.2,-7897.8}},
        ["ghost"]={{5192.5,10.3,439.0},{5206.9,10.3,496.5},{5253.1,10.3,394.0},{5306.2,10.3,490.1},{5307.2,10.3,427.5}},
        ["grand devotee"]={{9559.2,-1994.4,9798.7},{9561.2,-1989.9,10090.4},{9589.2,-1994.2,9704.8},{9608.9,-1994.4,9956.4},{9620.5,-1994.4,9871.7},{9719.9,-1989.9,10134.2}},
        ["head baker"]={{-2389.2,51.0,-13018.3},{-2369.1,51.0,-12807.9},{-2263.3,51.0,-12711.4},{-2251.6,51.0,-13033.4},{-2151.4,51.0,-13033.4},{-2100.7,51.0,-12721.0}},
        ["high disciple"]={{9778.4,-1995.1,9720.9},{9778.4,-1995.1,9876.9},{9835.4,-1995.1,9533.9},{9854.4,-1995.1,9963.9},{9886.4,-1995.1,9629.9}},
        ["hydra enforcer"]={{4434.1,1005.6,209.5},{4456.4,1008.5,418.8},{4462.6,1005.1,551.0},{4547.1,1003.1,334.2},{4581.5,1003.1,704.9},{4671.7,1004.3,-14.6}},
        ["hydra leader"]={{5888.8,1020.1,-117.8}},
        ["ice cream chef"]={{-1109.3,64.6,-10931.3},{-966.3,64.6,-10973.6},{-931.7,64.6,-11146.7},{-797.0,64.6,-10790.7},{-715.4,64.6,-10920.4},{-502.4,64.6,-10873.8}},
        ["ice cream commander"]={{-883.6,70.1,-11485.5},{-770.4,125.6,-11159.8},{-675.1,67.7,-11371.7},{-657.5,129.7,-11215.8},{-528.8,65.5,-11348.9},{-366.8,64.7,-11094.4}},
        ["island boy"]={{-16991.7,12.8,-186.2},{-16905.3,13.1,-73.5},{-16883.0,23.4,-250.9},{-16736.2,22.2,-131.7},{-16661.6,57.4,-253.0}},
        ["isle champion"]={{-16940.8,14.2,1070.9},{-16901.2,12.4,970.0},{-16787.3,25.2,992.1},{-16735.7,23.4,1110.6},{-16618.8,58.4,1099.5}},
        ["isle outlaw"]={{-16433.7,57.2,-195.5},{-16351.8,23.5,-282.4},{-16289.5,22.9,-179.4},{-16163.4,11.9,-99.4},{-16122.4,11.8,-257.4}},
        ["jungle pirate"]={{-12321.3,331.4,-10669.2},{-12306.4,331.1,-10352.9},{-12142.5,331.6,-10419.9},{-11918.1,332.5,-10744.1},{-11902.3,331.3,-10432.1},{-11708.4,331.9,-10700.0},{-11612.5,335.8,-10489.4}},
        ["kilo admiral"]={{2998.3,508.8,-7344.3}},
        ["living zombie"]={{-10293.1,152.9,5960.9},{-10205.1,151.9,5861.9},{-10184.1,152.9,5741.9},{-10170.9,141.2,6159.6},{-10061.9,140.2,6038.6},{-9956.1,140.9,5966.9}},
        ["longma"]={{-10156.2,337.8,-9445.9}},
        ["marine commodore"]={{2367.9,75.6,-7795.0},{2497.8,81.8,-7356.9},{2577.2,75.6,-7739.9},{2685.4,75.6,-8066.1},{2995.4,75.6,-8054.5},{3222.4,75.6,-7820.6}},
        ["marine rear admiral"]={{3465.2,123.9,-7181.8},{3753.5,123.9,-7403.2},{3761.8,123.9,-6823.5},{3920.1,146.2,-7175.2},{3973.7,123.9,-6931.9}},
        ["musketeer pirate"]={{-13556.1,391.4,-9735.9},{-13514.9,403.4,-9866.5},{-13417.6,391.4,-9962.3},{-13337.9,472.1,-9698.7},{-13270.9,472.1,-9860.7},{-13198.6,391.4,-9602.3},{-13075.6,391.4,-9890.3}},
        ["mythological pirate"]={{-13876.0,469.4,-7010.0},{-13732.0,469.4,-6827.0},{-13456.0,469.4,-7040.0},{-13320.0,519.1,-6785.0},{-13221.0,519.1,-6902.0},{-13221.0,519.1,-6689.0}},
        ["ocean prophet"]={{10862.0,-2006.6,10245.2},{10924.2,-1998.9,10121.0},{11003.3,-2007.0,10225.1},{11111.5,-2007.3,10201.5},{11129.8,-2007.8,10051.5}},
        ["peanut president"]={{-2395.1,87.4,-10456.3},{-2312.0,87.3,-10609.3},{-2247.5,87.3,-10440.9},{-1996.1,37.2,-10496.9},{-1993.4,37.2,-10682.9},{-1874.4,37.2,-10596.6}},
        ["peanut scout"]={{-2377.3,38.0,-10308.2},{-2294.2,37.2,-10176.1},{-2250.2,8.8,-9948.8},{-2078.1,12.8,-9997.1},{-2065.3,35.0,-10066.8},{-1924.0,37.3,-10199.7},{-1865.4,8.8,-10086.2}},
        ["pirate millionaire"]={{-751.6,55.5,5637.5},{-593.2,55.5,5511.5},{-543.8,56.7,5654.0},{-232.9,57.0,5757.8},{-118.8,55.5,5649.2},{-62.6,55.5,5803.5}},
        ["pistol billionaire"]={{-903.2,84.6,5891.0},{-852.9,70.0,6175.3},{-739.5,84.6,5833.1},{-666.8,84.9,6008.3},{-188.1,84.7,6337.0},{-185.7,84.7,6103.6},{-54.8,83.8,5947.8},{40.1,85.3,6114.3}},
        ["posessed mummy"]={{-9759.4,26.9,6052.0},{-9759.4,26.9,6369.0},{-9609.4,6.0,6362.0},{-9449.4,6.0,6343.0},{-9399.6,12.2,6118.8}},
        ["reborn skeleton"]={{-8868.1,140.9,6034.9},{-8826.1,140.9,6165.9},{-8811.6,143.1,5871.8},{-8762.7,141.6,6183.3},{-8710.1,140.9,6112.9},{-8682.1,140.9,5968.9},{-8646.1,140.9,5850.9}},
        ["reef bandit"]={{10883.5,-2160.2,9075.5},{10899.9,-2145.2,9279.3},{10980.5,-2160.4,9052.0},{11039.6,-2156.1,9279.1},{11085.2,-2160.5,9129.8}},
        ["sea chanter"]={{10466.3,-2087.4,10106.9},{10581.5,-2071.8,10020.6},{10625.5,-2087.4,10191.7},{10680.1,-2056.7,9933.9},{10786.4,-2087.4,10105.3}},
        ["serpent hunter"]={{-16621.4,121.9,1290.7},{-16599.7,71.1,1757.9},{-16536.0,106.9,1347.1},{-16521.1,106.1,1488.8},{-16442.8,71.6,1693.5}},
        ["skull slayer"]={{-16985.7,59.3,1632.8},{-16948.6,193.1,1643.6},{-16855.0,122.5,1478.2},{-16829.4,193.2,1753.4},{-16812.9,72.1,1757.2},{-16811.6,86.1,1542.2}},
        ["snow demon"]={{-936.1,14.0,-14552.5},{-897.8,24.6,-14733.8},{-813.6,15.3,-14322.7},{-784.7,24.8,-14631.8},{-771.2,14.2,-14434.3}},
        ["stone"]={{-1109.9,53.4,6811.7}},
        ["sun-kissed warrior"]={{-16413.5,56.7,1054.4},{-16357.3,21.0,1005.6},{-16186.4,25.1,1098.1},{-16153.4,14.5,942.5},{-16052.5,9.8,1061.9}},
        ["sweet thief"]={{-140.3,25.6,-12652.3},{-77.7,25.6,-12765.6},{5.4,25.6,-12537.4},{88.5,25.6,-12662.2},{144.0,25.6,-12531.7}},
        ["training dummy"]={{3657.1,11.9,178.0}},
        ["venomous assailant"]={{4443.1,1237.0,335.9},{4448.8,1222.0,540.5},{4452.8,1220.8,698.9},{4637.9,1078.8,882.4},{4674.9,1134.8,996.3},{4879.9,1093.7,1104.0}},
      },
    }
    local observedRegions={
      [1]={
        ["Colosseum"]={pos={-1666.21,-13.78,-3241.86},source="Location"},
        ["DapperJackArena"]={pos={-627.5,-10988,1630.5},source="Map"},
        ["Desert"]={pos={1066.79,-13.78,4430.14},source="Location"},
        ["Fishmen"]={pos={61188.37,590.33,1285.43},source="Map"},
        ["Fountain"]={pos={-3181.72,364.17,14.05},source="Map"},
        ["Fountain City"]={pos={5657.13,-13.78,4418.73},source="Location"},
        ["Frozen Village"]={pos={1276.79,-13.78,-1472.86},source="Location"},
        ["Jungle"]={pos={-1516.1,-3.78,-130.28},source="Location"},
        ["Magma Village"]={pos={-5528.21,-13.78,8691.14},source="Location"},
        ["MagmaCave"]={pos={-61147,7000,8995.83},source="Map"},
        ["Marine Fortress"]={pos={-4935.21,-13.78,4318.14},source="Location"},
        ["Marine Starter"]={pos={-2921.05,-10.77,2111.77},source="Location"},
        ["MarineBase"]={pos={-4939.36,160.59,4317.4},source="Map"},
        ["MarineStart"]={pos={-2956.5,102.17,2109.28},source="Map"},
        ["Middle Town"]={pos={-826.45,-3.78,1613.27},source="Location"},
        ["MobBoss"]={pos={-2862.36,56.96,5395.51},source="Map"},
        ["Observatory"]={pos={-627.5,-10988,1630.5},source="Location"},
        ["Pirate"]={pos={-1136.89,48.87,4171.77},source="Map"},
        ["Pirate Starter"]={pos={1014.48,15.83,1462.93},source="Location"},
        ["Pirate Village"]={pos={-1133.21,-3.78,4199.08},source="Location"},
        ["Prison"]={pos={5277.79,-13.78,743.14},source="Location"},
        ["Sea"]={pos={0,-1000,0},source="Location"},
        ["SewerSystem"]={pos={-196.8,-545.64,106.85},source="Map"},
        ["Sewers"]={pos={-196.8,-545.64,106.85},source="Location"},
        ["Sky"]={pos={-4798.65,626.44,-560.57},source="Map"},
        ["SkyArea2"]={pos={-6674.09,5795.48,1113.1},source="Map"},
        ["Skylands"]={pos={-5024.21,794.4,-639.68},source="Location"},
        ["TeleportSpawn"]={pos={4014.98,23.42,-1898.66},source="Map"},
        ["Town"]={pos={-1054.1,39.7,793.13},source="Map"},
        ["Underwater City"]={pos={61379.79,-13.78,1221.75},source="Location"},
        ["Volcano Cave"]={pos={-61147,7000,8995.83},source="Location"},
        ["Whirlpool"]={pos={4078.93,-13.78,-1814.86},source="Location"},
        ["Windmill"]={pos={1057.67,23.87,1471.74},source="Map"},
      },
      [2]={
        ["Café"]={pos={-380.41,72.82,303.24},source="Location"},
        ["CircleIsland"]={pos={-5745.37,712.83,-5162.05},source="Map"},
        ["Colosseum"]={pos={-1836.41,72.82,1360.24},source="Location"},
        ["Cursed Ship"]={pos={900.94,143.97,33072.64},source="Location"},
        ["DapperJackArena"]={pos={-334.5,-10926,267.2},source="Map"},
        ["Dark Arena"]={pos={3807.1,11.8,-3452.2},source="Location"},
        ["DarkbeardArena"]={pos={3792.69,31.43,-3471.78},source="Map"},
        ["Dressrosa"]={pos={1043.82,123.9,198.68},source="Map"},
        ["Factory"]={pos={430.99,238.42,-433.16},source="Location"},
        ["Fishmen"]={pos={676,-798.79,1683},source="Map"},
        ["Forgotten Island"]={pos={-3194.24,155.3,-10795.26},source="Location"},
        ["ForgottenIsland"]={pos={-3060.21,239.78,-10905.86},source="Map"},
        ["GhostShip"]={pos={-6594.63,260.36,-256.75},source="Map"},
        ["GhostShipInterior"]={pos={919.81,200.82,33135.07},source="Map"},
        ["GraveIsland"]={pos={-5775.4,249.91,-999.48},source="Map"},
        ["Graveyard Island"]={pos={-5577.94,87.55,-782.24},source="Location"},
        ["Green Zone"]={pos={-2340.8,155.3,-3396.3},source="Location"},
        ["GreenBit"]={pos={-2012.33,772.77,-2826.71},source="Map"},
        ["Hot  and Cold"]={pos={-5734.26,49.39,-5146.36},source="Location"},
        ["Ice Castle"]={pos={6062.26,155.3,-6880.86},source="Location"},
        ["IceCastle"]={pos={6275.23,537.98,-6594.02},source="Map"},
        ["IndraIsland"]={pos={-26795.65,-49.87,416.18},source="Map"},
        ["Kingdom of Rose"]={pos={-195.1,155.3,279.9},source="Location"},
        ["Mansion"]={pos={-393.3,367.3,687.5},source="Location"},
        ["Mini1"]={pos={4759.23,16.13,2846.74},source="Map"},
        ["Mini2"]={pos={-5147.65,51.19,2387.32},source="Map"},
        ["MiniSky"]={pos={-266.04,49335.56,-35261.95},source="Map"},
        ["Observatory"]={pos={-334.5,-10926,267.2},source="Location"},
        ["RaidMap"]={pos={0,0,0},source="Map"},
        ["Sea"]={pos={0,-1000,0},source="Location"},
        ["Snow Mountain"]={pos={856.2,50.3,-5278.3},source="Location"},
        ["SnowMountain"]={pos={848.03,194.45,-5245.29},source="Map"},
        ["Swan's Room"]={pos={2293.7,12.5,663.1},source="Location"},
        ["l'Église de Prophétie"]={pos={239.79,-58.38,1824.44},source="Location"},
      },
      [3]={
        ["Ancient Clock"]={pos={29523.48,15094.68,-87.59},source="Location"},
        ["Beautiful Pirate Domain"]={pos={5366.59,71.16,-225.89},source="Location"},
        ["Boat Castle"]={pos={-5411.22,778.61,-2682.28},source="Map"},
        ["CakeLoaf"]={pos={-1992.12,218.66,-12415.58},source="Map"},
        ["CandyCane"]={pos={-1097,122.63,-14576.17},source="Map"},
        ["Castle"]={pos={-5390.79,254.8,-2720.91},source="Map"},
        ["Castle on the Sea"]={pos={-5436.61,815.64,-2701.66},source="Location"},
        ["ChocolateIsland"]={pos={32.77,94.47,-12824.42},source="Map"},
        ["DapperJackArena"]={pos={-12517.9,-10669,-7613.7},source="Map"},
        ["Dragon Dojo"]={pos={5704.41,1168.06,937.05},source="Location"},
        ["Fishmen"]={pos={-4271.26,-600,10000},source="Map"},
        ["Floating Turtle"]={pos={-12164.61,-548.86,-8454.87},source="Location"},
        ["Friendly Arena"]={pos={5012.81,72.82,-1570.55},source="Location"},
        ["Great Tree"]={pos={3036.29,815.64,-7149.86},source="Location"},
        ["Haunted Castle"]={pos={-9530.61,-132.86,5763.13},source="Location"},
        ["Heavenly Dimension"]={pos={-22709.64,5258.99,3886.64},source="Location"},
        ["Hell Dimension"]={pos={-22737.64,5119.98,2234.63},source="Location"},
        ["Hydra Island"]={pos={5298.9,-989.57,344.72},source="Location"},
        ["Mansion"]={pos={-12547.71,290.14,-7487.06},source="Location"},
        ["MiniSky"]={pos={-266.04,49335.37,-35261.95},source="Map"},
        ["North Pole"]={pos={-1141.05,57.84,-14480.73},source="Location"},
        ["Observatory"]={pos={-12517.9,-10669,-7613.7},source="Location"},
        ["Port"]={pos={-779.43,125.24,7500.03},source="Map"},
        ["Port Town"]={pos={-610.37,57.83,6436.34},source="Location"},
        ["RaidMap"]={pos={0,0.1,0},source="Map"},
        ["Sea"]={pos={0,-397.48,0},source="Location"},
        ["Sea of Treats"]={pos={112.09,57.84,-12794.22},source="Location"},
        ["Sealed Cavern"]={pos={10437.39,-2227.39,9670.98},source="Location"},
        ["Secret Temple"]={pos={5226.19,63.52,858.84},source="Location"},
        ["Sharkman Arena"]={pos={9908.22,-11043.48,9679.72},source="Location"},
        ["Submerged Island"]={pos={10533.29,-2029.09,9940.48},source="Location"},
        ["Temple of Time"]={pos={29000,15000.98,-0.86},source="Location"},
        ["TempleHitboxes"]={pos={28733.02,14967.74,-87.35},source="Map"},
        ["Tiki Outpost"]={pos={-16641.51,213.31,435.38},source="Location"},
        ["TikiOutpost"]={pos={-16682.71,189.53,524.16},source="Map"},
        ["Trial of Carnage"]={pos={-12000,10098.14,0},source="Location"},
        ["Trial of Flames"]={pos={-40052.74,10098.8,23341.94},source="Location"},
        ["Trial of Speed"]={pos={3333,11000,16000},source="Location"},
        ["Trial of Strength"]={pos={10052.74,10098.8,41.94},source="Location"},
        ["Trial of Water"]={pos={24984.72,180.87,12502.29},source="Location"},
        ["Trial of the King"]={pos={12000,17000,5555},source="Location"},
        ["Trial of the Machine"]={pos={-20010.76,10009.4,-25.76},source="Location"},
        ["Turtle"]={pos={-12100.78,482.13,-7981.61},source="Map"},
        ["Waterfall"]={pos={5065.74,598.76,178.19},source="Map"},
        ["l'Église de Prophétie"]={pos={-11559.21,55.14,-7578.56},source="Location"},
      },
    }
    local observedBosses={
      [1]={["chef"]=true,["cyborg"]=true,["fishman lord"]=true,["ice admiral"]=true,["lightning god"]=true,["magma general"]=true,["mob boss"]=true,["saber expert"]=true,["sky warlord"]=true,["the gorilla king"]=true,["vice admiral"]=true,["warden"]=true,["yeti"]=true},
      [2]={["diamond"]=true,["orbitus"]=true,["rip_indra"]=true,["smoke admiral"]=true},
      [3]={["beautiful pirate"]=true,["cake queen"]=true,["hydra leader"]=true,["kilo admiral"]=true,["longma"]=true,["stone"]=true},
    }
    local counts={
      [1]={runs=2,captured=316816,spawnTypes=40,spawnPoints=162,regions=33},
      [2]={runs=1,captured=182953,spawnTypes=24,spawnPoints=121,regions=34},
      [3]={runs=1,captured=202844,spawnTypes=52,spawnPoints=264,regions=45},
    }
    STATE.Atlas={Spawns=observedSpawns,Regions=observedRegions,Bosses=observedBosses,Counts=counts,Source="Workspace.7z client snapshots 2026-11-07"}
    STATE.AtlasSpawnCache={}
    STATE.AtlasSpawnCFrame=function(name,from)
      if not Config.AtlasUseScannedSpawns or not name then return nil end
      local options=observedSpawns[STATE.World] and observedSpawns[STATE.World][norm(name)]
      if not options or #options==0 then return nil end
      local key=tostring(STATE.World)..":"..norm(name)
      local cached=STATE.AtlasSpawnCache[key]
      local selected=nil
      if cached and os.clock()<cached.Until and options[cached.Index] then selected=options[cached.Index] end
      if not selected then
        local source=from;local best=math.huge;local bestIndex=1
        if typeof(source)~="Vector3" then local _,_,r=alive();source=r and r.Position end
        for i,p in ipairs(options) do
          local v=Vector3.new(p[1],p[2],p[3])
          local d=source and (v-source).Magnitude or i
          if d<best then best=d;selected=p;bestIndex=i end
        end
        STATE.AtlasSpawnCache[key]={Index=bestIndex,Until=os.clock()+12}
      end
      if not selected then return nil end
      return CFrame.new(selected[1],selected[2]+24,selected[3])
    end
    STATE.AtlasRegionNames=function()
      local result={}
      for name in pairs(observedRegions[STATE.World] or {}) do result[#result+1]=name end
      table.sort(result)
      if #result==0 then return {"No scanned regions in this Sea"} end
      return result
    end
    STATE.AtlasRegion=function(name)
      local d=observedRegions[STATE.World] and observedRegions[STATE.World][tostring(name)]
      if not d then return nil end
      return CFrame.new(d.pos[1],d.pos[2]+25,d.pos[3]),d.source
    end
end

local redeemCodes={"EASTEREXP","BANEXPLOIT","NOMOREHACKS","WildDares","BossBuild","GetPranked",
  "EARN_FRUITS","Sub2UncleKizaru","FIGHT4FRUIT","kittgaming","TRIPLEABUSE",
  "Sub2CaptainMaui","Sub2Fer999","Enyu_is_Pro","Magicbus","JCWK","Starcodeheo","Bluxxy",
  "SUB2GAMERROBOT_EXP1","Sub2NoobMaster123","Sub2Daigrock","Axiore","TantaiGaming",
  "StrawHatMaine","Sub2OfficialNoobie","TheGreatAce","SEATROLLIN","24NOADMIN","ADMIN_TROLL",
  "NEWTROLL","SECRET_ADMIN","staffbattle","NOEXPLOIT","NOOB2ADMIN","CODESLIDE","fruitconcepts"}
local raids={"Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough"}
local shops={
  {"Dark Step","BuyBlackLeg"},{"Water Kung Fu","BuyFishmanKarate"},{"Electro","BuyElectro"},
  {"Superhuman","BuySuperhuman"},{"Death Step","BuyDeathStep"},
  {"Sharkman Karate","BuySharkmanKarate"},{"Electric Claw","BuyElectricClaw"},
  {"Dragon Talon","BuyDragonTalon"},{"Godhuman","BuyGodhuman"},
  {"Sanguine Art","BuySanguineArt"},
}

-- Level and quest reference adapted from the user-provided Kaitun Pastefy data.
-- The live game's GuideModule / Quests are preferred; this fallback is only
-- used when they do not expose a usable quest. Ranges may change in updates.
local ROUTES={
 [1]={
 {1,9,"Bandit","BanditQuest1",1},{10,14,"Monkey","JungleQuest",1},{15,29,"Gorilla","JungleQuest",2},
 {30,39,"Pirate","BuggyQuest1",1},{40,59,"Brute","BuggyQuest1",2},
 {60,74,"Desert Bandit","DesertQuest",1},{75,89,"Desert Officer","DesertQuest",2},
 {90,99,"Snow Bandit","SnowQuest",1},{100,119,"Snowman","SnowQuest",2},
 {120,149,"Chief Petty Officer","MarineQuest2",1},{150,174,"Sky Bandit","SkyQuest",1},
 {175,189,"Dark Master","SkyQuest",2},{190,209,"Prisoner","PrisonerQuest",1},
 {210,249,"Dangerous Prisoner","PrisonerQuest",2},
 {250,274,"Toga Warrior","ColosseumQuest",1},{275,299,"Gladiator","ColosseumQuest",2},
 {300,324,"Military Soldier","MagmaQuest",1},{325,374,"Military Spy","MagmaQuest",2},
 {375,399,"Fishman Warrior","FishmanQuest",1},{400,449,"Fishman Commando","FishmanQuest",2},
 {450,474,"God's Guard","SkyExp1Quest",1},{475,524,"Shanda","SkyExp1Quest",2},
 {525,549,"Royal Squad","SkyExp2Quest",1},{550,624,"Royal Soldier","SkyExp2Quest",2},
 {625,649,"Galley Pirate","FountainQuest",1},{650,699,"Galley Captain","FountainQuest",2}},
 [2]={
 {700,724,"Raider","Area1Quest",1},{725,774,"Mercenary","Area1Quest",2},
 {775,799,"Swan Pirate","Area2Quest",1},{800,874,"Factory Staff","Area2Quest",2},
 {875,899,"Marine Lieutenant","MarineQuest3",1},{900,949,"Marine Captain","MarineQuest3",2},
 {950,974,"Zombie","ZombieQuest",1},{975,999,"Vampire","ZombieQuest",2},
 {1000,1049,"Snow Trooper","SnowMountainQuest",1},{1050,1099,"Winter Warrior","SnowMountainQuest",2},
 {1100,1124,"Lab Subordinate","IceSideQuest",1},{1125,1174,"Horned Warrior","IceSideQuest",2},
 {1175,1199,"Magma Ninja","FireSideQuest",1},{1200,1249,"Lava Pirate","FireSideQuest",2},
 {1250,1274,"Ship Deckhand","ShipQuest1",1},{1275,1299,"Ship Engineer","ShipQuest1",2},
 {1300,1324,"Ship Steward","ShipQuest2",1},{1325,1349,"Ship Officer","ShipQuest2",2},
 {1350,1374,"Arctic Warrior","FrostQuest",1},{1375,1424,"Snow Lurker","FrostQuest",2},
 {1425,1449,"Sea Soldier","ForgottenQuest",1},{1450,1499,"Water Fighter","ForgottenQuest",2}},
 [3]={
 {1500,1524,"Pirate Millionaire","PiratePortQuest",1},{1525,1574,"Pistol Billionaire","PiratePortQuest",2},
 {1575,1599,"Dragon Crew Warrior","DragonCrewQuest",1},{1600,1624,"Dragon Crew Archer","DragonCrewQuest",2},
 {1625,1649,"Hydra Enforcer","VenomCrewQuest",1},{1650,1699,"Venomous Assailant","VenomCrewQuest",2},
 {1700,1724,"Marine Commodore","MarineTreeIsland",1},{1725,1774,"Marine Rear Admiral","MarineTreeIsland",2},
 {1775,1799,"Fishman Raider","DeepForestIsland3",1},{1800,1824,"Fishman Captain","DeepForestIsland3",2},
 {1825,1849,"Forest Pirate","DeepForestIsland",1},{1850,1899,"Mythological Pirate","DeepForestIsland",2},
 {1900,1924,"Jungle Pirate","DeepForestIsland2",1},{1925,1974,"Musketeer Pirate","DeepForestIsland2",2},
 {1975,1999,"Reborn Skeleton","HauntedQuest1",1},{2000,2024,"Living Zombie","HauntedQuest1",2},
 {2025,2049,"Demonic Soul","HauntedQuest2",1},{2050,2074,"Posessed Mummy","HauntedQuest2",2},
 {2075,2099,"Peanut Scout","NutsIslandQuest",1},{2100,2124,"Peanut President","NutsIslandQuest",2},
 {2125,2149,"Ice Cream Chef","IceCreamIslandQuest",1},{2150,2199,"Ice Cream Commander","IceCreamIslandQuest",2},
 {2200,2224,"Cookie Crafter","CakeQuest1",1},{2225,2249,"Cake Guard","CakeQuest1",2},
 {2250,2274,"Baking Staff","CakeQuest2",1},{2275,2299,"Head Baker","CakeQuest2",2},
 {2300,2324,"Cocoa Warrior","ChocQuest1",1},{2325,2349,"Chocolate Bar Battler","ChocQuest1",2},
 {2350,2374,"Sweet Thief","ChocQuest2",1},{2375,2399,"Candy Rebel","ChocQuest2",2},
 {2400,2424,"Candy Pirate","CandyQuest1",1},{2425,2449,"Snow Demon","CandyQuest1",2},
 {2450,2474,"Isle Outlaw","TikiQuest1",1},{2475,2524,"Island Boy","TikiQuest1",2},{2525,2574,"Isle Champion","TikiQuest2",1},{2575,2599,"Skull Slayer","TikiQuest3",2},
 {2600,2624,"Reef Bandit","SubmergedQuest1",1},{2625,2649,"Coral Pirate","SubmergedQuest1",2},
 {2650,2674,"Sea Chanter","SubmergedQuest2",1},{2675,2699,"Ocean Prophet","SubmergedQuest2",2},
 {2700,2724,"High Disciple","SubmergedQuest3",1},
 {2725,9999,"Grand Devotee","SubmergedQuest3",2}},
}
-- Known fast-travel destination vectors, requestEntrance is game/version dependent.
local PORTALS={
 [1]={Vector3.new(-7894.62,5545.49,-380.25),Vector3.new(-4607.82,872.54,-1667.56),
      Vector3.new(61163.85,11.76,1819.78),Vector3.new(3876.28,35.10,-1939.32)},
 [2]={Vector3.new(-288.46,306.13,598.0),Vector3.new(2284.91,15.15,905.48),
      Vector3.new(923.21,126.98,32852.83),Vector3.new(-6508.56,89.03,-132.84)},
 [3]={},
}

-- NPC quest-giver positions derived from the user-provided Kaitun ManualLevelLookup.
-- Compact XYZ only; data is NOT generated or looked up online at runtime.
STATE.QuestNPCs = {
    BanditQuest1={1059.37195,15.4495068,1550.4231},
    JungleQuest={-1598.08911,35.5501175,153.377838},
    BuggyQuest1={-1141.07483,4.10001802,3831.5498},
    DesertQuest={894.488647,5.14000702,4392.43359},
    SnowQuest={1389.74451,88.1519318,-1298.90796},
    MarineQuest2={-5039.58643,27.3500385,4324.68018},
    SkyQuest={-4839.53027,716.368591,-2619.44165},
    PrisonerQuest={5308.93115,1.65517521,475.120514},
    ColosseumQuest={-1580.04663,6.35000277,-2986.47534},
    MagmaQuest={-5313.37012,10.9500084,8515.29395},
    FishmanQuest={61122.65234375,18.497442245483,1569.39978},
    SkyExp1Quest={-4721.88867,843.874695,-1949.96643},
    SkyExp2Quest={-7906.81592,5634.6626,-1411.99194},
    FountainQuest={5259.81982,37.3500175,4050.0293},
    Area1Quest={-429.543518,71.7699966,1836.18188},
    Area2Quest={638.43811,71.769989,918.282898},
    MarineQuest3={-2440.79639,71.7140732,-3216.06812},
    ZombieQuest={-5497.06152,47.5923004,-795.237061},
    SnowMountainQuest={609.858826,400.119904,-5372.25928},
    IceSideQuest={-6064.06885,15.2422857,-4902.97852},
    FireSideQuest={-5428.03174,16.0622921,-5299.43457},
    ShipQuest1={1037.80127,125.092171,32911.6016},
    ShipQuest2={968.80957,125.092171,33244.125},
    FrostQuest={5667.6582,26.7997818,-6486.08984},
    ForgottenQuest={-3054.44458,235.544281,-10142.8193},
    PiratePortQuest={-290.074677,42.9034653,5581.58984},
    DragonCrewQuest={6738.96142578125,127.81645965576,-713.51147460938},
    VenomCrewQuest={5213.8740234375,1004.5042724609,758.6944580078},
    MarineTreeIsland={2180.54126,27.8156815,-6741.5498},
    DeepForestIsland3={-10581.6563,330.872955,-8761.18652},
    DeepForestIsland={-13234.04,331.488495,-7625.40137},
    DeepForestIsland2={-12680.3818,389.971039,-9902.01953},
    HauntedQuest1={-9479.2168,141.215088,5566.09277},
    HauntedQuest2={-9516.99316,172.017181,6078.46533},
    NutsIslandQuest={-2104.3908691406,38.104167938,-10194.21875},
    IceCreamIslandQuest={-820.64825439453,65.819526672,-10965.7959},
    CakeQuest1={-2021.32007,37.7982254,-12028.7295},
    CakeQuest2={-1927.91602,37.7981339,-12842.5391},
    ChocQuest1={233.2283630371,29.876001358,-12201.2334},
    ChocQuest2={150.506637573,30.693693161,-12774.50293},
    CandyQuest1={-1150.040039,20.378935,-14446.33496},
    TikiQuest1={-16547.748046875,61.135334,-173.413605},
    TikiQuest2={-16539.078125,55.686329,1051.573853},
    TikiQuest3={-16665.1914,104.596405,1579.69434},
    SubmergedQuest1={10778.875,-2087.72437,9265.18359},
    SubmergedQuest2={10880.6855,-2086.20044,10032.624},
    SubmergedQuest3={9640.08789,-1992.44507,9613.65234},
}
STATE.QuestNPCPos=function(questName)
    local xyz=STATE.QuestNPCs[questName]
    if xyz then return CFrame.new(xyz[1],xyz[2],xyz[3]) end
    return nil
end

local function questRoute(levelValue,seaIndex)
  if seaIndex==1 and levelValue<10 and LP.Team and LP.Team.Name=="Marines" then return nil end
  for _,route in ipairs(ROUTES[seaIndex] or {}) do
    if levelValue>=route[1] and levelValue<=route[2] then return route end
  end
end

-- v20: Dead NPCs can remain in workspace.Enemies after their death animation.
-- Ignore dead Humanoids, stale models, explicit death markers and recently killed instances.
-- Atlas v21: the snapshots show HP=0 Halloween models left in Workspace.Enemies.
-- Treat Health/Dead state as authoritative locally; a reused Model must remain
-- healthy for a grace interval before it can become a target again.
STATE.NPCFilter={Dead=setmetatable({},{__mode="k"}),Watched=setmetatable({},{__mode="k"}),
    HealthySince=setmetatable({},{__mode="k"}),Reviving=setmetatable({},{__mode="k"}),
    Held=nil,DeadSkipped=0,TargetChanges=0,LastLostAt=0,LastReason="None"}
STATE.MarkDeadNPC=function(model,reason)
    if not model then return end
    local f=STATE.NPCFilter
    if not f.Dead[model] then f.DeadSkipped=f.DeadSkipped+1 end
    local hum=model:FindFirstChildOfClass("Humanoid")
    f.Dead[model]={At=os.clock(),Humanoid=hum,Reason=tostring(reason or "NPC died")}
    f.HealthySince[model]=nil;f.Reviving[model]=nil
    if f.Held==model then
        f.Held=nil;f.LastLostAt=os.clock();f.StaleDestination=true
    end
    f.LastReason=tostring(reason or "NPC died")
end
STATE.IsAliveNPC=function(model)
    local folder=enemyFolder()
    if not (model and model:IsA("Model") and folder and model.Parent==folder) then return false end
    local h=model:FindFirstChildOfClass("Humanoid")
    local r=model:FindFirstChild("HumanoidRootPart")
    if not (h and r and r:IsA("BasePart") and r.Parent==model) then return false end
    if h.Health<=0 or h.MaxHealth<=0 then
        if h.Health<=0 then STATE.MarkDeadNPC(model,"Health <= 0") end
        return false
    end
    if h:GetState()==Enum.HumanoidStateType.Dead then
        STATE.MarkDeadNPC(model,"Humanoid state Dead");return false
    end
    for _,attr in ipairs({"Dead","IsDead","Died","Killed","Defeated","Despawned"}) do
        if model:GetAttribute(attr)==true or h:GetAttribute(attr)==true then
            STATE.MarkDeadNPC(model,"NPC attribute "..attr);return false
        end
    end
    for _,tag in ipairs({"Dead","IsDead","Killed","Defeated"}) do
        local v=model:FindFirstChild(tag)
        if v and v:IsA("BoolValue") and v.Value then
            STATE.MarkDeadNPC(model,"NPC BoolValue "..tag);return false
        end
    end
    local now=os.clock()
    if STATE.NPCFilter.Dead[model] then
        local prior=STATE.NPCFilter.Reviving[model]
        if prior and prior.Humanoid==h and now-prior.At>=math.max(.4,tonumber(Config.HalloweenReviveGrace) or .6) then
            STATE.NPCFilter.Dead[model]=nil;STATE.NPCFilter.Reviving[model]=nil
            STATE.NPCFilter.HealthySince[model]=nil
        else
            if not prior or prior.Humanoid~=h then
                STATE.NPCFilter.Reviving[model]={Humanoid=h,At=now}
            end
            return false
        end
    end
    -- Halloween NPCs can keep a model around during death/reanimation transitions.
    if model.Name:lower():find("lantern",1,true) or
       model.Name:lower():find("pumpkin",1,true) or
       model.Name:lower():find("halloween",1,true) then
        local seen=STATE.NPCFilter.HealthySince[model]
        if not seen or seen.Humanoid~=h then
            STATE.NPCFilter.HealthySince[model]={Humanoid=h,At=now}
            return false
        end
        if now-seen.At<math.max(.4,tonumber(Config.HalloweenReviveGrace) or .6) then return false end
    end
    if not STATE.NPCFilter.Watched[h] then
        STATE.NPCFilter.Watched[h]=true
        on(h,h.Died,function() STATE.MarkDeadNPC(model,"Humanoid.Died") end)
    end
    return true
end
STATE.IsHalloweenEnemy=function(name)
    local n=norm(name):gsub("[^%w]","")
    return n:find("jackolantern",1,true)~=nil or n:find("pumpkinsnowman",1,true)~=nil
        or n:find("halloweenenemy",1,true)~=nil or n:find("halloweenmob",1,true)~=nil
end
local function enemySearch(query,excludeBoss,preferHeld)
    local folder=enemyFolder(); if not folder then return nil end
    local _,_,root=alive(); if not root then return nil end
    local names=(type(query)=="table" and query) or (type(query)=="string" and {query}) or nil
    local function matches(m)
        if excludeBoss and isBoss(m.Name) then return false end
        if type(query)=="function" then return query(m) end
        if not names then return true end
        for _,n in ipairs(names) do if norm(m.Name)==norm(n) then return true end end
        return false
    end
    if STATE.NPCFilter.Held and not STATE.IsAliveNPC(STATE.NPCFilter.Held) then
        STATE.NPCFilter.Held=nil;STATE.NPCFilter.StaleDestination=true
    end
    if preferHeld and STATE.NPCFilter.Held and STATE.IsAliveNPC(STATE.NPCFilter.Held)
        and matches(STATE.NPCFilter.Held) then
        local mob=STATE.NPCFilter.Held
        return mob,(mob.HumanoidRootPart.Position-root.Position).Magnitude
    end
    local best,dist=nil,math.huge
    for _,m in ipairs(folder:GetChildren()) do
        if matches(m) and STATE.IsAliveNPC(m) then
            local d=(m.HumanoidRootPart.Position-root.Position).Magnitude
            if d<dist then best,dist=m,d end
        end
    end
    return best,dist
end
local function spawnCFrame(name)
    local origin=WS:FindFirstChild("_WorldOrigin")
    local group=origin and origin:FindFirstChild("EnemySpawns")
    local _,_,root=alive()
    if group then
        local best,dist=nil,math.huge
        for _,part in ipairs(group:GetDescendants()) do
            if part:IsA("BasePart") and norm(part.Name)==norm(name) then
                local d=root and (part.Position-root.Position).Magnitude or 0
                if d<dist then best,dist=part,d end
            end
        end
        if best then return best.CFrame*CFrame.new(0,24,0) end
    end
    -- Newer game versions expose spawn positions here instead of _WorldOrigin.
    local fort=RS:FindFirstChild("FortBuilderReplicatedSpawnPositionsFolder")
    if fort then
        local best,dist=nil,math.huge
        for _,point in ipairs(fort:GetChildren()) do
            if norm(point.Name)==norm(name) then
                local position=point:IsA("BasePart") and point.Position or
                    (point:IsA("Model") and point:GetPivot().Position or nil)
                if position then
                    local distance=root and (position-root.Position).Magnitude or 0
                    if distance<dist then dist=distance;best=position end
                end
            end
        end
        if best then return CFrame.new(best+Vector3.new(0,24,0)) end
    end
    local scanned=STATE.AtlasSpawnCFrame and STATE.AtlasSpawnCFrame(name,root and root.Position)
    if scanned then return scanned end
    local pos=mobSpawns[name]
    if pos then return CFrame.new(pos[1],pos[2]+24,pos[3]) end
    return nil
end
local moveTo,distanceTo
local Quests,Guide
local function loadQuestModules()
    local q=RS:FindFirstChild("Quests"); local g=RS:FindFirstChild("GuideModule")
    if q and not Quests then safe("quest list",function() Quests=require(q) end) end
    if g and not Guide then safe("quest guide",function() Guide=require(g) end) end
end
loadQuestModules()
task.spawn(function()
    for _=1,30 do
        if not STATE.Alive or (Quests and Guide) then break end
        task.wait(1)
        loadQuestModules()
    end
end)

-- QuestUpdate event cache; quest actions need both AutoQuest and FarmEnabled enabled.
STATE.QuestState={QuestName=nil,Mob=nil,EventSeen=false,Updated=0,SentAt=0,LastAbandon=0}
-- Quest state already stored in STATE
STATE.QuestBound=false
STATE.BindQuestRemote=function()
    if STATE.QuestBound or not STATE.Alive then return end
    local remotes=RS:FindFirstChild("Remotes")
    local update=remotes and remotes:FindFirstChild("QuestUpdate")
    if not (update and update:IsA("RemoteEvent")) then return end
    on(update,update.OnClientEvent,function(data)
        STATE.QuestState.EventSeen=true
        STATE.QuestState.Updated=os.clock()
        if type(data)=="table" and data.InternalQuestName then
            STATE.QuestState.QuestName=tostring(data.InternalQuestName)
            local progress=data.Progress
            STATE.QuestState.Mob=type(progress)=="table" and next(progress) or nil
        else
            STATE.QuestState.QuestName=nil;STATE.QuestState.Mob=nil
        end
    end)
    STATE.QuestBound=true
end
STATE.BindQuestRemote()
task.spawn(function()
    for _=1,40 do
        if not STATE.Alive or STATE.QuestBound then break end
        task.wait(1);STATE.BindQuestRemote()
    end
end)
local function questInfo()
    local route=questRoute(level(),STATE.World)
    if not route then return nil end
    -- Stable level route from Kaitun, with game NPC data for current position.
    local info={Mob=route[3],Name=route[4],Id=route[5],Pos=STATE.QuestNPCPos(route[4]),Source="Kaitun route"}
    if Guide and Guide.Data and type(Guide.Data.NPCList)=="table" then
        for _,npc in pairs(Guide.Data.NPCList) do
            if type(npc)=="table" then
                local matched=npc.InternalQuestName==route[4]
                if not matched and type(npc.Levels)=="table" then
                    for _,allowed in pairs(npc.Levels) do
                        if tonumber(allowed)==tonumber(route[1]) then matched=true;break end
                    end
                end
                if matched then
                    local pos=npc.CFrame or npc.Position
                    if typeof(pos)=="Vector3" then pos=CFrame.new(pos) end
                    if typeof(pos)=="CFrame" then info.Pos=pos;info.Source="GuideModule" end
                    break
                end
            end
        end
    end
    if type(Quests)=="table" and type(Quests[info.Name])=="table" then
        local entry=Quests[info.Name][info.Id]
        if type(entry)=="table" and type(entry.Task)=="table" then
            for name in pairs(entry.Task) do info.Mob=tostring(name);break end
        end
    end
    return info
end
-- Return: active, currentQuestName, currentMobName, source.
-- Never confuse quest ID (e.g. JungleQuest) with NPC mob name (e.g. Gorilla).
STATE.ReadQuestGUI=function()
    local pg=LP:FindFirstChild("PlayerGui")
    local main=pg and (pg:FindFirstChild("Main") or pg:FindFirstChild("Main (minimal)"))
    local panel=main and main:FindFirstChild("Quest")
    if not panel or not panel.Visible then
        local tracked=pg and pg:FindFirstChild("TrackedQuestFrame")
        if tracked then
            local visible=tracked:IsA("ScreenGui") and tracked.Enabled or
                (tracked:IsA("GuiObject") and tracked.Visible)
            if visible then
                local frame=tracked:FindFirstChild("Frame") or tracked
                local header=frame:FindFirstChild("header",true)
                local label=header and (header:IsA("TextLabel") and header or header:FindFirstChildWhichIsA("TextLabel",true))
                return true,label and label.Text or nil
            end
        end
        return false,nil
    end
    local title=panel:FindFirstChild("QuestTitle",true)
    local textNode=title and (title:FindFirstChild("Title",true) or title)
    local textValue=textNode and textNode:IsA("TextLabel") and textNode.Text or nil
    if textValue and textValue~="" then return true,textValue end
    local tracked=pg:FindFirstChild("TrackedQuestFrame")
    if tracked then
        local root=tracked:FindFirstChild("Frame") or tracked
        local header=root:FindFirstChild("header",true)
        local label=header and (header:IsA("TextLabel") and header or header:FindFirstChildWhichIsA("TextLabel",true))
        if label and label.Text~="" then return true,label.Text end
    end
    return true,nil
end
local function activeQuest()
    local now=os.clock()
    -- A missing/empty event payload is not proof that the quest was removed.
    -- Prefer server-positive data, then Guide, then GUI; avoid false abandon.
    if STATE.QuestState.EventSeen and now-STATE.QuestState.Updated<15 and STATE.QuestState.QuestName then
        return true,STATE.QuestState.QuestName,STATE.QuestState.Mob,"event"
    end
    if Guide and Guide.Data then
        local data=Guide.Data.QuestData
        if type(data)=="table" and data.InternalQuestName then
            local mob=type(data.Task)=="table" and next(data.Task) or nil
            return true,tostring(data.InternalQuestName),mob,"guide"
        end
    end
    local active,textValue=STATE.ReadQuestGUI()
    if active then return true,nil,textValue,"gui" end
    -- Wait for server/GUI replication after requesting a quest.
    if now-STATE.QuestState.SentAt<1.5 then return nil,nil,nil,"pending" end
    return false,nil,nil,"none"
end
STATE.HasQuest=function()
    local active,name,mob=activeQuest()
    return active,mob or name
end
STATE.MatchesQuest=function(info,qName,mob,source)
    if qName and qName~="" then return qName==info.Name end
    if mob and mob~="" then
        local target=norm(info.Mob):gsub("s$","")
        local text=norm(mob):gsub("s$","")
        return text:find(target,1,true)~=nil
    end
    -- GUI can exist without replicated quest details: do not auto-abandon unknown quests.
    return source=="gui"
end
STATE.ClaimQuest=function(info)
    if not (Config.FarmEnabled and Config.AutoQuest and info and info.Name and info.Id) then return false end
    local position=info.Pos
    if typeof(position)~="CFrame" then
        if os.clock()-(STATE.QuestPositionWarning or 0)>30 then
            STATE.QuestPositionWarning=os.clock()
            slog("Cannot locate quest NPC: "..tostring(info.Name),"warn")
        end
        return false
    end
    if distanceTo(position)>10 then
        moveTo(position*CFrame.new(0,3,0));return false
    end
    local now=os.clock()
    if now-STATE.QuestState.SentAt<math.max(2,tonumber(Config.QuestDelay) or 4) then return false end
    STATE.QuestState.SentAt=now
    local ok,result=remote("StartQuest",info.Name,info.Id)
    if not ok or result==false then
        slog("StartQuest rejected: "..tostring(result),"warn")
        return false
    end
    return true
end


-- V11 movement controller: reuse proxy, single active tween, hysteresis for moving mobs.
-- Keeping the existing Proxy/Direct modes, without reloading any external mover.
STATE.MoveStats={Started=0,Retargeted=0,Reached=0,Stalled=0,Corrections=0,
    RequestedSpeed=350,RecoveryUntil=0,LastError="None",Status="Idle"}
local function cancelMove()
    local m=STATE.Mover
    if m then
        m.Active=false;m.Generation=(m.Generation or 0)+1
        if m.CompletedConnection then pcall(function() m.CompletedConnection:Disconnect() end) end
        m.CompletedConnection=nil
        if m.Tween then pcall(function() m.Tween:Cancel() end) end
        m.Tween=nil;m.Goal=nil;m.Started=0
    end
    STATE.Tween=nil;STATE.TweenGoal=nil;STATE.TweenAt=nil
    STATE.MoveStats.Status="Idle"
    STATE.MovementLock=nil
end
STATE.EnsureMover=function(root)
    local m=STATE.Mover
    if m and m.Proxy and m.Proxy.Parent then return m end
    m={Active=false,Generation=0,At=0,Goal=nil,LastPosition=nil,Mode="Proxy Tween"}
    local proxy=Instance.new("Part")
    proxy.Name="__andepzai_move_proxy"
    proxy.Size=Vector3.new(1,1,1)
    proxy.Anchored=true;proxy.CanCollide=false;proxy.CanTouch=false
    proxy.Transparency=1;proxy.CFrame=root.CFrame
    pcall(function() proxy.CanQuery=false end)
    proxy.Parent=WS
    m.Proxy=proxy
    STATE.Mover=m
    return m
end
-- Only one Heartbeat subscription. The proxy follows a tween; character tracks it.
on(Run,Run.Heartbeat,function(dt)
    local m=STATE.Mover
    if not (STATE.Alive and m and m.Active and m.Tween) then return end
    local _,hum,root,ok=alive()
    if not ok or not root or hum.Sit then
        STATE.MoveStats.LastError="Character unavailable or seated"
        cancelMove();return
    end
    if m.CharacterRoot~=root then
        STATE.MoveStats.LastError="Character respawned"
        cancelMove();return
    end
    if m.Mode=="Proxy Tween" then
        if not m.Proxy or not m.Proxy.Parent then cancelMove();return end
        local targetCF=m.Proxy.CFrame
        local offset=targetCF.Position-root.Position
        local gap=offset.Magnitude
        if gap>230 then
            -- Never keep forcing a huge client CFrame jump on a corrected position.
            STATE.MoveStats.LastError="Large position mismatch / possible server correction ("..math.floor(gap).." studs)"
            STATE.MoveStats.Corrections=STATE.MoveStats.Corrections+1
            STATE.MoveStats.Stalled=STATE.MoveStats.Stalled+1
            STATE.MoveStats.RecoveryUntil=os.clock()+0.65
            cancelMove();return
        end
        -- Smooth high-speed following. Clamping frame delta avoids one huge
        -- teleport after an FPS hitch. This is NOT an anti-cheat bypass guarantee.
        local maxStep=math.max(1,math.clamp(tonumber(Config.TweenSpeed) or 350,40,400)
            * math.clamp(tonumber(dt) or (1/60),1/180,1/25) * 1.02)
        if gap>maxStep and gap>0 then
            root.CFrame=CFrame.new(root.Position+offset.Unit*maxStep)*targetCF.Rotation
        else
            root.CFrame=targetCF
        end
        root.AssemblyLinearVelocity=Vector3.zero
    end
    local now=os.clock()
    if m.Goal and (root.Position-m.Goal.Position).Magnitude<=((m.Caller=="Farm engine" and Config.FarmStyle=="Above") and 2.5 or 5) then
        STATE.MoveStats.Reached=STATE.MoveStats.Reached+1
        cancelMove();return
    end
    -- A Tween's Completed means the proxy reached its goal, not necessarily
    -- that the player's root has caught up at low FPS or after a correction.
    if m.FinishedAt and now-m.FinishedAt>2.5 then
        STATE.MoveStats.Stalled=STATE.MoveStats.Stalled+1
        STATE.MoveStats.LastError="Proxy arrived but character could not reach target"
        STATE.MoveStats.RecoveryUntil=now+0.35
        cancelMove();return
    end
    if now-(m.LastCheck or now)>2.4 then
        local progress=(root.Position-(m.LastPosition or root.Position)).Magnitude
        if progress<1.7 and m.Goal and (root.Position-m.Goal.Position).Magnitude>15 then
            STATE.MoveStats.Stalled=STATE.MoveStats.Stalled+1
            STATE.MoveStats.LastError="Move stalled (possible map collision or server correction)"
            STATE.MoveStats.RecoveryUntil=now+0.35
            cancelMove();return
        end
        m.LastPosition=root.Position;m.LastCheck=now
    end
end)

moveTo=function(cf)
    if typeof(cf)=="Vector3" then cf=CFrame.new(cf) end
    if typeof(cf)~="CFrame" then return false end
    local _,hum,root,ok=alive()
    if not ok or not root or hum.Sit then return false end
    local now=os.clock()
    if now<(STATE.MoveStats.RecoveryUntil or 0) then return false end
    local thread=coroutine.running()
    local caller=STATE.MoveThreadOwners[thread] or "Manual"
    local priority=({["Farm engine"]=96,["Raid combat"]=85,["Sea/fishing"]=77,
        ["Experience"]=75,["Unified bosses"]=74,["Unified world patrol"]=70,
        ["Advanced fishing"]=65,["Spooky dungeon"]=82,["Spooky bounty"]=68,["Collectibles"]=52,["Unified events"]=48,
        ["Halloween pumpkins"]=46,["Unified follow"]=42,["Events"]=40,
        ["Unified auto shop"]=20})[caller] or 100
    local lock=STATE.MovementLock
    if lock and lock.Name~=caller and lock.Until>now and lock.Priority>priority then
        return false
    end
    local distance=(root.Position-cf.Position).Magnitude
    if distance<((caller=="Farm engine" and Config.FarmStyle=="Above") and 2.5 or 6) then
        if STATE.Mover and STATE.Mover.Active then cancelMove() end
        return true
    end
    STATE.MovementLock={Name=caller,Priority=priority,Until=now+2.8}
    if Config.SmartPortal and distance>1200 and now-(STATE.LastPortal or 0)>16 then
        local best,gain=nil,800
        for _,p in ipairs(PORTALS[STATE.World] or {}) do
            local improvement=distance-(p-cf.Position).Magnitude
            if improvement>gain and (root.Position-p).Magnitude>100 then best,gain=p,improvement end
        end
        if best then
            STATE.LastPortal=now
            local success,accepted=remote("requestEntrance",best)
            if success and accepted~=false then cancelMove();return true end
        end
    end
    local mode=Config.MovementMode=="Direct Tween" and "Direct Tween" or "Proxy Tween"
    if Config.MovementFailover and (STATE.MoveStats.Stalled or 0)>=3 and
        Config.MovementMode=="Proxy Tween" then mode="Direct Tween" end
    local m=STATE.EnsureMover(root)
    if m.Active and m.Goal and m.Mode==mode and m.CharacterRoot==root then
        local shift=(m.Goal.Position-cf.Position).Magnitude
        local limit=math.max(4,tonumber(Config.MoveRetargetThreshold) or 7)
        local gap=now-(m.At or 0)
        -- Tiny target updates do not tear down the tween every farm tick.
        if shift<=limit then return true end
        if gap<math.max(.3,tonumber(Config.MoveRetargetDelay) or .4) then return true end
        STATE.MoveStats.Retargeted=STATE.MoveStats.Retargeted+1
    end
    cancelMove()
    STATE.MovementLock={Name=caller,Priority=priority,Until=now+2.8}
    m=STATE.EnsureMover(root)
    if mode=="Proxy Tween" then m.Proxy.CFrame=root.CFrame end
    local speed=math.clamp(tonumber(Config.TweenSpeed) or 350,40,400)
    STATE.MoveStats.RequestedSpeed=speed
    local duration=math.max(.08,distance/speed)
    local target=mode=="Direct Tween" and root or m.Proxy
    local okTween,tw=pcall(function()
        return Tween:Create(target,TweenInfo.new(duration,Enum.EasingStyle.Linear),{CFrame=cf})
    end)
    if not okTween or not tw then
        STATE.MoveStats.LastError="TweenService failed to construct tween"
        cancelMove();return false
    end
    m.Generation=(m.Generation or 0)+1
    m.Active=true;m.Goal=cf;m.At=now;m.Started=now;m.Tween=tw;m.Mode=mode;m.FinishedAt=nil
    m.CharacterRoot=root;m.Caller=caller;m.LastPosition=root.Position;m.LastCheck=now
    STATE.Tween=tw;STATE.TweenGoal=cf;STATE.TweenAt=now
    STATE.MoveStats.Started=STATE.MoveStats.Started+1
    STATE.MoveStats.Status="Moving / "..mode
    local id=m.Generation
    m.CompletedConnection=tw.Completed:Connect(function(playback)
        if STATE.Alive and STATE.Mover==m and m.Generation==id then
            if playback==Enum.PlaybackState.Completed then
                m.FinishedAt=os.clock() -- allow root to catch up to completed proxy
            else
                cancelMove()
            end
        end
    end)
    tw:Play()
    return true
end

distanceTo=function(cf)
    local _,_,root=alive()
    return root and (root.Position-cf.Position).Magnitude or math.huge
end

-- V14: NEVER read ToolTip on Humanoid/Part/Accessory before IsA("Tool").
-- This crashed the old farm loop after arriving at a mob.
local function equipByType()
    local char=LP.Character;local bag=LP:FindFirstChild("Backpack")
    if not (char and bag) then return nil end
    local chosen=tostring(Config.Weapon or "Melee"):lower()
    local equipped=char:FindFirstChildOfClass("Tool")
    local best,first=nil,nil
    for _,container in ipairs({char,bag}) do
        for _,item in ipairs(container:GetChildren()) do
            if item:IsA("Tool") then
                first=first or item
                local tip=tostring(item.ToolTip or ""):lower()
                local label=item.Name:lower()
                local match=chosen=="any" or chosen==tip or chosen==label or
                    (chosen=="melee" and (tip=="fighting style" or tip=="combat" or
                        tip=="melee" or label=="combat")) or
                    (chosen=="blox fruit" and (tip=="fruit" or tip=="demon fruit"))
                if match then best=item;break end
            end
        end
        if best then break end
    end
    if not best and equipped then best=equipped end
    if not best then best=first end
    if not best then
        STATE.LastCombatIssue="No Tool in backpack or character"
        return nil
    end
    if best.Parent~=char and Config.AutoEquip then
        local hum=char:FindFirstChildOfClass("Humanoid")
        if hum then
            local ok,err=pcall(function() hum:EquipTool(best) end)
            if not ok then STATE.LastCombatIssue="EquipTool: "..tostring(err) end
        end
    end
    return best
end
-- Resolve game Net on demand, without loading external Lua or starting an attack loop.
STATE.CombatRemotes={lastTry=0,Attack=nil,Hit=nil}
local function getCombatRemotes()
    if STATE.CombatRemotes.Attack and STATE.CombatRemotes.Hit then return STATE.CombatRemotes end
    if os.clock()-STATE.CombatRemotes.lastTry<4 then return nil end
    STATE.CombatRemotes.lastTry=os.clock()
    local modules=RS:FindFirstChild("Modules")
    local net=modules and modules:FindFirstChild("Net")
    if not net then return nil end
    -- Exact paths exist in the provided Sea 1, Sea 2 and Sea 3 JSON snapshots.
    -- Resolve directly first; only try the Net module if descendants are absent.
    local attack=net:FindFirstChild("RE/RegisterAttack")
    local hit=net:FindFirstChild("RE/RegisterHit")
    if attack and attack:IsA("RemoteEvent") and hit and hit:IsA("RemoteEvent") then
        STATE.CombatRemotes.Attack=attack;STATE.CombatRemotes.Hit=hit
        return STATE.CombatRemotes
    end
    pcall(function()
        if not net:IsA("ModuleScript") then return end
        local mod=require(net)
        if type(mod)=="table" and type(mod.RemoteEvent)=="function" then
            STATE.CombatRemotes.Attack=mod:RemoteEvent("RegisterAttack",true)
            STATE.CombatRemotes.Hit=mod:RemoteEvent("RegisterHit",true)
        end
    end)
    if STATE.CombatRemotes.Attack and STATE.CombatRemotes.Hit then return STATE.CombatRemotes end
    return nil
end
STATE.SendRemoteEvent=function(eventObject,...)
    if not eventObject then return false end
    local args=table.pack(...)
    return pcall(function() eventObject:FireServer(table.unpack(args,1,args.n)) end)
end
STATE.FastHit=function(mob)
    if not (Config.Combat and Config.FastAttackEnabled and STATE.IsAliveNPC(mob)) then return false end
    local enemies=enemyFolder()
    if not enemies or mob.Parent~=enemies then return false end
    local targetHum=mob:FindFirstChildOfClass("Humanoid")
    local targetRoot=mob:FindFirstChild("HumanoidRootPart")
    local head=mob:FindFirstChild("Head") or targetRoot
    local character,_,root,valid=alive()
    if not (valid and targetHum and targetRoot and head and targetHum.Health>0) then return false end
    local radius=math.clamp(tonumber(Config.AttackRange) or 16,8,65)
    if (root.Position-targetRoot.Position).Magnitude>radius then return false end
    if os.clock()-(STATE.LastPveEvent or 0)<.18 then return false end
    STATE.LastPveEvent=os.clock()
    local tool=character and character:FindFirstChildOfClass("Tool")
    -- Spooky source uses a weapon-owned LeftClickRemote when present.
    local clickRemote=tool and tool:FindFirstChild("LeftClickRemote")
    if clickRemote and clickRemote:IsA("RemoteEvent") then
        local dir=head.Position-root.Position
        local ok=STATE.SendRemoteEvent(clickRemote,dir.Magnitude>.02 and dir.Unit or root.CFrame.LookVector,1)
        if ok then STATE.CombatTelemetry.RemoteCalls=STATE.CombatTelemetry.RemoteCalls+1 end
        return ok
    end
    local net=getCombatRemotes()
    if not net then
        if os.clock()-(STATE.LastCombatWarning or 0)>25 then
            STATE.LastCombatWarning=os.clock()
            slog("Combat remotes absent; only Tool.Activate is available", "warn")
        end
        return false
    end
    -- Spooky: RegisterAttack(0), RegisterHit(head,{{mob,head}}).
    -- Topi reference uses .3 and root: an optional selector supports both.
    local useTopi=Config.PVEHitProtocol=="Topi"
    local primary=useTopi and targetRoot or head
    local speedArg=useTopi and .3 or 0
    local okAttack=STATE.SendRemoteEvent(net.Attack,speedArg)
    local okHit=okAttack and STATE.SendRemoteEvent(net.Hit,primary,{{mob,primary}})
    if okAttack and okHit then STATE.CombatTelemetry.RemoteCalls=STATE.CombatTelemetry.RemoteCalls+1 end
    return okAttack and okHit
end
STATE.CombatTelemetry={ToolCalls=0,RemoteCalls=0,HealthChanged=0,LastEnemy="None",
    LastDamage=0,LastObservedHP=nil,LastIssue="Waiting for farm",Attempts=0,
    NoDamageWarnings=0,Used="None",LastAttemptAt=0}
local function punch()
    if not (Config.Combat or Config.AutoClick) then return false end
    local character=LP.Character
    if not character then return false end
    local tool=character:FindFirstChildOfClass("Tool")
    if Config.AutoEquip then
        local candidate=equipByType()
        if candidate and candidate.Parent==character then tool=candidate end
    end
    if not tool or tool.Parent~=character then
        STATE.CombatTelemetry.LastIssue="No equipped Tool; check weapon/Auto Equip"
        return false
    end
    local success,err=pcall(function() tool:Activate() end)
    if success then STATE.CombatTelemetry.ToolCalls=STATE.CombatTelemetry.ToolCalls+1
    else STATE.CombatTelemetry.LastIssue="Tool.Activate: "..tostring(err) end
    -- Use a free area of screen, not (0,0), which may be intercepted by UI.
    -- Keep input synthesis opt-in. Avoid turning a virtual click into a GUI toggle.
    if Config.InputClickFallback and (not STATE.WindowVisible) and
        os.clock()-(STATE.LastVirtualClick or 0)>.30 then
        STATE.LastVirtualClick=os.clock()
        local camera=WS.CurrentCamera
        if camera then
            local p=Vector2.new(camera.ViewportSize.X*.78,camera.ViewportSize.Y*.63)
            pcall(function()
                local vim=game:GetService("VirtualInputManager")
                vim:SendMouseButtonEvent(p.X,p.Y,0,true,game,0)
                vim:SendMouseButtonEvent(p.X,p.Y,0,false,game,0)
            end)
        end
    end
    return success
end
local nextAttack=0
local nextSkills=0
local function useSkills()
    if not (Config.AutoSkill or (Config.AutoSea and Config.AutoSeaSkill)) or os.clock()<nextSkills then return end
    if Config.FarmMode=="Mastery" and not STATE.MasterySkillReady then return end
    nextSkills=os.clock()+math.max(.35,tonumber(Config.AutoSkillDelay) or 1.8)
    local vim
    pcall(function() vim=game:GetService("VirtualInputManager") end)
    if not vim then return end
    for _,key in ipairs({"Z","X","C","V","F"}) do
        if not STATE.Alive or not (Config.AutoSkill or (Config.AutoSea and Config.AutoSeaSkill)) then break end
        if Config["Skill"..key] then
            pcall(function()
                vim:SendKeyEvent(true,Enum.KeyCode[key],false,game)
                vim:SendKeyEvent(false,Enum.KeyCode[key],false,game)
            end)
            task.wait(.07)
        end
    end
end

-- Overhead farm: hold the character above the NPC rather than at hand-to-hand range.
-- BodyVelocity only opposes gravity in Y; it never moves the NPC or other players.
STATE.FarmHover={Root=nil,Force=nil,Target=nil}
STATE.ReleaseFarmHover=function()
    local hover=STATE.FarmHover
    if hover and hover.Force then
        pcall(function() hover.Force:Destroy() end)
    end
    if hover then hover.Force=nil;hover.Root=nil;hover.Target=nil end
end
STATE.UpdateFarmHover=function(mob)
    if not (STATE.Alive and Config.FarmEnabled and Config.FarmHoverLock and Config.FarmStyle=="Above") then
        STATE.ReleaseFarmHover();return
    end
    local char,hum,root,ok=alive()
    local target=mob and mob:FindFirstChild("HumanoidRootPart")
    local enemyHum=mob and mob:FindFirstChildOfClass("Humanoid")
    if not (ok and hum and root and target and enemyHum and enemyHum.Health>0) then
        STATE.ReleaseFarmHover();return
    end
    local hover=STATE.FarmHover
    if hover.Root~=root or not hover.Force or not hover.Force.Parent then
        STATE.ReleaseFarmHover()
        local force=Instance.new("BodyVelocity")
        force.Name="andepzai_overhead_hold"
        force.MaxForce=Vector3.new(0,1e7,0)
        force.P=14000
        force.Velocity=Vector3.zero
        force.Parent=root
        hover.Root=root;hover.Force=force
    end
    hover.Target=mob
end
local function positionForMob(mob)
    local r=mob and mob:FindFirstChild("HumanoidRootPart")
    if not r then return nil end
    if Config.AutoDodgeSkill and os.clock()<(STATE.DodgeUntil or 0) then
        return r.CFrame*CFrame.new(0,180,0)
    end
    local d=tonumber(Config.FarmDistance) or 5
    local h=tonumber(Config.FarmHeight) or 18
    if Config.FarmStyle=="Above" then
        -- Vertical separation avoids normal contact attacks; ranged/AoE can still hit.
        h=math.clamp(h,12,60)
        if Config.SafeFarm then h=math.max(h,28) end
        local front=r.CFrame.LookVector
        local flat=Vector3.new(front.X,0,front.Z)
        if flat.Magnitude<.05 then flat=Vector3.new(0,0,-1) end
        local spot=r.Position+Vector3.new(0,h,0)-flat.Unit*math.clamp(d,2,6)
        -- Face horizontally toward the NPC; never tilt the character downward.
        return CFrame.lookAt(spot,Vector3.new(r.Position.X,spot.Y,r.Position.Z))
    end
    -- Traditional modes remain opt-in; do not silently force an overhead preset lower.
    if Config.Combat and not Config.SafeFarm and
        (Config.CombatMode=="Tool only" or not Config.FastAttackEnabled) then
        d=math.min(d,8);h=math.min(h,7)
    end
    if Config.SafeFarm then h=math.max(h,28) end
    if Config.FarmStyle=="Behind" then return r.CFrame*CFrame.new(0,h,math.max(d,2)) end
    if Config.FarmStyle=="Orbit" then
        local a=os.clock()*1.7
        return CFrame.new(r.Position+Vector3.new(math.cos(a)*d,h,math.sin(a)*d))
    end
    if Config.FarmStyle=="Below" then return r.CFrame*CFrame.new(0,-math.max(7,d),0) end
    return r.CFrame*CFrame.new(0,math.max(h,d),0)
end
local function engage(mob)
    if not STATE.IsAliveNPC(mob) then return end
    local h=mob:FindFirstChildOfClass("Humanoid")
    local target=mob:FindFirstChild("HumanoidRootPart")
    if not (h and h.Health>0 and target) then return end
    local telemetry=STATE.CombatTelemetry
    if telemetry.LastEnemyInstance==mob and type(telemetry.LastObservedHP)=="number" and
        h.Health<telemetry.LastObservedHP then
        telemetry.LastDamage=telemetry.LastObservedHP-h.Health
        telemetry.HealthChanged=telemetry.HealthChanged+1
        telemetry.LastDamageAt=os.clock()
        telemetry.LastIssue="Damage confirmed: "..string.format("%.0f",telemetry.LastDamage)
    end
    telemetry.LastEnemy=mob.Name;telemetry.LastObservedHP=h.Health
    telemetry.LastEnemyInstance=mob
    if Config.FarmEnabled and Config.FarmStyle=="Above" then
        STATE.UpdateFarmHover(mob)
    end
    local cf=positionForMob(mob)
    if cf then moveTo(cf) end
    if not Config.Combat or os.clock()<nextAttack then return end
    local _,_,root,valid=alive()
    if not valid then return end
    -- Tool and remote calls require a selected weapon to be equipped first.
    if Config.AutoEquip then equipByType() end
    local gap=(target.Position-root.Position).Magnitude
    local method=Config.CombatMode
    local meleeDistance=math.min(12,math.max(8,tonumber(Config.AttackRange) or 13))
    local canMelee=gap<=meleeDistance
    -- Same range is enforced by STATE.FastHit; avoid claiming an out-of-range hit.
    local canRemote=gap<=math.clamp(tonumber(Config.AttackRange) or 32,12,65)
    if not canMelee and not canRemote then
        telemetry.LastIssue="Overhead gap "..math.floor(gap).." > attack range; increase range or lower height"
        return
    end
    nextAttack=os.clock()+math.max(.17,tonumber(Config.AttackDelay) or .25)
    telemetry.Attempts=telemetry.Attempts+1
    telemetry.LastAttemptAt=os.clock()
    if method=="Remote only" then
        if canRemote and Config.FastAttackEnabled then
            telemetry.Used="Remote only"
            if not STATE.FastHit(mob) then telemetry.LastIssue="Remote unavailable or rejected locally" end
        else telemetry.LastIssue="Remote not enabled / out of range" end
    elseif method=="Hybrid" or method=="Adaptive" then
        -- Adaptive always tries normal Tool and optionally PvE event pair.
        -- A successful FireServer alone is NOT evidence the target was damaged.
        if canMelee or (Config.FarmStyle=="Above" and canRemote) then
            telemetry.Used=canMelee and "Tool + PvE remote" or "Overhead Tool + PvE remote"
            punch()
        end
        if canRemote and Config.FastAttackEnabled then
            if not STATE.FastHit(mob) then telemetry.LastIssue="PvE remote unavailable; check HP drops or enable skills" end
        end
        if not canMelee and not Config.FastAttackEnabled then
            telemetry.LastIssue="Overhead Tool alone may not reach NPC; enable PvE remote or skills"
        end
    else
        telemetry.Used="Tool only"
        if canMelee then punch()
        elseif Config.FarmStyle=="Above" then
            telemetry.LastIssue="Tool-only cannot reach above NPC. Use Adaptive + fast attack, or reduce height"
        else telemetry.LastIssue="Closing melee distance: "..math.floor(gap).." studs" end
    end
    if Config.AutoSkill then useSkills() end
    if Config.AutoCombatDiagnostics and telemetry.Attempts>12 and
        (os.clock()-(telemetry.LastDamageAt or STATE.Start)>8) and
        (os.clock()-(STATE.LastNoDamageLog or 0)>20) then
        STATE.LastNoDamageLog=os.clock()
        telemetry.NoDamageWarnings=telemetry.NoDamageWarnings+1
        telemetry.LastIssue="No HP drop: check weapon/class, tool cooldown, attack remote or distance"
        slog("PvE: no target HP decrease observed. "..telemetry.LastIssue, "warn")
    end
end
local function getTarget()
    if Config.FarmMode=="Level" then
        local info=questInfo()
        if not info then return nil end
        local name=info.Mob
        if Config.AutoQuest then
            local current,qName,mobName,source=activeQuest()
            if current==nil then return nil end
            if current==false then
                STATE.ClaimQuest(info);return nil
            end
            if not STATE.MatchesQuest(info,qName,mobName,source) then
                -- Never abandon an existing quest without the dedicated opt-in toggle.
                if Config.AutoAbandonWrongQuest and os.clock()-STATE.QuestState.LastAbandon>7 then
                    STATE.QuestState.LastAbandon=os.clock()
                    remote("AbandonQuest")
                elseif os.clock()-(STATE.WrongQuestWarning or 0)>15 then
                    STATE.WrongQuestWarning=os.clock()
                    slog("Different quest is active; enable 'Abandon wrong quest' if desired", "warn")
                end
                return nil
            end
        end
        local mob=enemySearch(name,false,true)
        if not mob then moveTo(spawnCFrame(name)) end
        return mob
    elseif Config.FarmMode=="Nearest" then
        return enemySearch(nil,true,true)
    elseif Config.FarmMode=="Selected mob" then
        local mob=enemySearch(Config.Mob,false,true)
        if not mob then moveTo(spawnCFrame(Config.Mob)) end
        return mob
    elseif Config.FarmMode=="Halloween" then
        -- Boss/event detection from Topi Halloween: only real NPCs are targeted.
        local target=enemySearch(function(m) return STATE.IsHalloweenEnemy(m.Name) end,false,true)
        if not target and os.clock()-(STATE.LastHalloweenWarning or 0)>25 then
            STATE.LastHalloweenWarning=os.clock()
            slog("No Halloween event enemies loaded in workspace.Enemies", "warn")
        end
        return target
    elseif Config.FarmMode=="Boss" then
        return enemySearch(Config.Boss,false,true)
    elseif Config.FarmMode=="Material" then
        local names=materialMobs[Config.Material]
        if not names then return nil end
        local mob=enemySearch(names,false,true)
        if not mob then for _,name in ipairs(names) do
            local cf=spawnCFrame(name)
            if cf then moveTo(cf);break end
        end end
        return mob
    elseif Config.FarmMode=="Bones" then
        local mob=enemySearch(materialMobs.Bones,false,true)
        if not mob then moveTo(spawnCFrame("Reborn Skeleton")) end
        return mob
    elseif Config.FarmMode=="Mastery" then
        local mob=enemySearch(nil,true,true)
        if mob then
            local h=mob:FindFirstChildOfClass("Humanoid")
            STATE.MasterySkillReady=h and h.MaxHealth>0 and h.Health/h.MaxHealth*100<=Config.MasteryThreshold
        end
        return mob
    elseif Config.FarmMode=="All Boss" then
        local folder=enemyFolder()
        if folder then
            for _,e in ipairs(folder:GetChildren()) do
                if isBoss(e.Name) and STATE.IsAliveNPC(e) then return e end
            end
        end
    elseif Config.FarmMode=="Elite" then
        local target=enemySearch({"Diablo","Deandre","Urban"},false,true)
        if not target then throttle("EliteHunter",10,function() remote("EliteHunter") end) end
        return target
    elseif Config.FarmMode=="Factory" then
        return enemySearch({"Core","Factory Core"},false,true)
    elseif Config.FarmMode=="Pirate Raid" then
        return enemySearch({"Pirate Millionaire","Pistol Billionaire","Pirate","Elite Pirate"},false,true)
    elseif Config.FarmMode=="Aura" then
        return enemySearch(nil,false,true)
    end
    return nil
end



--// v20 MOB MAGNET. Same-name living NPCs ONLY, never player characters.
-- Inspired by the source's gradual pull/rubber-band guard, rewritten with local cleanup.
do
    local M={Tracked=setmetatable({},{__mode="k"}),Blocked=setmetatable({},{__mode="k"}),
        NextScan=0,Steps=0,Attracted=0,Rejections=0,Active=0,LastError="None"}
    STATE.MobMagnet=M
    local function release(mob)
        local d=M.Tracked[mob]
        if not d then return end
        M.Tracked[mob]=nil
        if d.hum and d.hum.Parent then
            pcall(function()
                d.hum.WalkSpeed=d.speed;d.hum.JumpPower=d.jump
                d.hum.JumpHeight=d.height;d.hum.AutoRotate=d.rotate
            end)
        end
        if d.root and d.root.Parent then
            pcall(function() d.root.CanCollide=d.collide end)
        end
    end
    function M.Stop()
        for mob in pairs(M.Tracked) do release(mob) end
        M.Active=0;M.NextScan=0
    end
    local function canMove(root)
        local owner=api("isnetworkowner")
        if type(owner)=="function" then
            local ok,owned=pcall(owner,root)
            if ok then return owned==true end
        end
        -- Without an ownership API, test locally; Roblox may reject position changes.
        return true
    end
    function M.Step(target)
        if not (STATE.Alive and Config.FarmEnabled and Config.MobMagnet
            and STATE.IsAliveNPC(target) and not isBoss(target.Name)) then M.Stop();return end
        local _,_,playerRoot,ready=alive()
        local targetRoot=target:FindFirstChild("HumanoidRootPart")
        if not (ready and playerRoot and targetRoot) then M.Stop();return end
        if (playerRoot.Position-targetRoot.Position).Magnitude>320 then M.Stop();return end
        local now=os.clock()
        if now<M.NextScan then return end
        M.NextScan=now+.35
        local folder=enemyFolder()
        if not folder then M.Stop();return end
        local radius=math.clamp(tonumber(Config.MobMagnetRadius) or 175,60,350)
        local maximum=math.clamp(math.floor(tonumber(Config.MobMagnetMax) or 6),2,12)
        local choices={}
        for _,mob in ipairs(folder:GetChildren()) do
            if mob~=target and norm(mob.Name)==norm(target.Name) and STATE.IsAliveNPC(mob)
                and not M.Blocked[mob] then
                local mobRoot=mob:FindFirstChild("HumanoidRootPart")
                local d=mobRoot and (mobRoot.Position-targetRoot.Position).Magnitude or math.huge
                if d<=radius and canMove(mobRoot) then
                    choices[#choices+1]={Mob=mob,Distance=d}
                end
            end
        end
        table.sort(choices,function(a,b) return a.Distance<b.Distance end)
        local selected={}
        for i=1,math.min(#choices,maximum-1) do
            local mob=choices[i].Mob
            selected[mob]=true
            local d=M.Tracked[mob]
            if not d then
                local hum=mob:FindFirstChildOfClass("Humanoid")
                local root=mob:FindFirstChild("HumanoidRootPart")
                d={hum=hum,root=root,speed=hum.WalkSpeed,jump=hum.JumpPower,
                    height=hum.JumpHeight,rotate=hum.AutoRotate,collide=root.CanCollide,
                    last=nil,snaps=0,expire=now+.8,slot=i}
                M.Tracked[mob]=d;M.Attracted=M.Attracted+1
            end
            d.expire=now+.8;d.slot=i;d.target=target
            pcall(function()
                d.hum.WalkSpeed=0;d.hum.JumpPower=0;d.hum.JumpHeight=0
                d.hum.AutoRotate=false;d.root.CanCollide=false
            end)
        end
        for mob in pairs(M.Tracked) do
            if not selected[mob] then release(mob) end
        end
        local count=0;for _ in pairs(M.Tracked) do count=count+1 end
        M.Active=count
    end
    -- One heartbeat for every mob; time-limited movement prevents stale targets.
    on(Run,Run.Heartbeat,function(dt)
        if not (STATE.Alive and Config.FarmEnabled and Config.MobMagnet) then
            if next(M.Tracked) then M.Stop() end
            return
        end
        dt=math.clamp(dt or 1/60,1/240,1/20)
        local now=os.clock()
        for mob,d in pairs(M.Tracked) do
            if now>(d.expire or 0) or not STATE.IsAliveNPC(mob)
                or not STATE.IsAliveNPC(d.target) or not d.root or not d.root.Parent then
                release(mob)
            else
                local center=d.target.HumanoidRootPart.Position
                local angle=(d.slot or 1)*2.39996
                local desired=center+Vector3.new(math.cos(angle)*3,0,math.sin(angle)*3)
                local delta=desired-d.root.Position
                -- Detect server position corrections; do not repeatedly fight a correction.
                if d.last and (d.root.Position-d.last).Magnitude>32 then
                    d.snaps=d.snaps+1;M.Rejections=M.Rejections+1
                    if d.snaps>=2 then
                        M.Blocked[mob]=now+15
                        M.LastError="Server corrected "..mob.Name.."; skip temporarily"
                        release(mob)
                    end
                elseif delta.Magnitude>5 then
                    local step=math.min(delta.Magnitude-3,280*dt)
                    local nextPos=d.root.Position+delta.Unit*step
                    local ok=pcall(function()
                        d.root.CFrame=CFrame.new(nextPos)*d.root.CFrame.Rotation
                        d.root.AssemblyLinearVelocity=Vector3.zero
                    end)
                    if not ok then release(mob) else d.last=nextPos;M.Steps=M.Steps+1 end
                end
                if M.Tracked[mob] then d.last=d.root.Position end
            end
        end
        for mob,untilTime in pairs(M.Blocked) do if now>untilTime then M.Blocked[mob]=nil end end
    end)
end

--// FEATURE SERVICES ------------------------------------------------------
local cachedWorldParts={}
local lastWorldScan=-10
local function worldPickups()
    if os.clock()-lastWorldScan>4.0 then
        local refreshed={}
        local descendants=WS:GetDescendants()
        for _,node in ipairs(descendants) do
            if node:IsA("BasePart") and node.Parent then
                local lname=node.Name:lower()
                -- Berry pickups can be named Handle/Main beneath a berry Model.
                local parentName=node.Parent.Name:lower()
                local berryChild=(lname=="handle" or lname=="main") and
                    parentName:find("berry",1,true)~=nil
                if lname:find("chest",1,true) or lname:find("berry",1,true) or berryChild then
                    table.insert(refreshed,node)
                end
            end
        end
        cachedWorldParts=refreshed
        lastWorldScan=os.clock()
    end
    return cachedWorldParts
end
local function findWorldItem(words)
    local _,_,root=alive()
    if not root then return nil end
    local best,dist=nil,math.huge
    for _,node in ipairs(worldPickups()) do
        if node.Parent and not node:IsDescendantOf(LP.Character or WS.Terrain) then
            local lname=(node.Name.." "..node.Parent.Name):lower()
            local hit=false
            for _,word in ipairs(words) do
                if lname:find(word,1,true) then hit=true;break end
            end
            if hit then
                local d=(root.Position-node.Position).Magnitude
                if d<dist then best,dist=node,d end
            end
        end
    end
    return best,dist
end
local function fruitsOnGround()
    local result={}
    for _,v in ipairs(WS:GetChildren()) do
        if v:IsA("Tool") and (v.Name:find("Fruit") or v:FindFirstChild("Handle")) then
            if v.Name:find("Fruit") and v:FindFirstChild("Handle") then table.insert(result,v) end
        end
    end
    return result
end
local function equippedFruit()
    local char=LP.Character; local bag=LP:FindFirstChild("Backpack")
    for _,container in ipairs({char,bag}) do
        if container then
            for _,tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:find("Fruit") then return tool end
            end
        end
    end
    return nil
end
local fruitPrices={Rocket=5000,Spin=7500,Blade=30000,Spring=60000,Bomb=80000,Smoke=100000,Spike=180000,
    Flame=250000,Falcon=300000,Ice=350000,Sand=420000,Dark=500000,Diamond=600000,Light=650000,
    Rubber=750000,Barrier=800000,Ghost=940000,Magma=960000,Quake=1000000,Buddha=1200000,
    Love=1300000,Spider=1500000,Sound=1700000,Phoenix=1800000,Portal=1900000,Rumble=2100000,
    Pain=2300000,Blizzard=2400000,Gravity=2500000,Mammoth=2700000,T_Rex=2700000,Dough=2800000,
    Shadow=2900000,Venom=3000000,Control=3200000,Spirit=3400000,Dragon=15000000,Kitsune=8000000}
local function storeFruit()
    local tool=equippedFruit()
    if not tool or STATE.LastFruit==tool then return end
    local base=tool.Name:gsub(" Fruit$","")
    if Config.AutoStoreOnlyValuable and (fruitPrices[base] or 0)<Config.MinFruitPrice then return end
    local original=tool:GetAttribute("OriginalName") or (base.."-"..base)
    local ok,res=remote("StoreFruit",original,tool)
    if ok then STATE.LastFruit=tool;notice("Fruit", "Store attempted: "..base) end
end
local function attackHaki()
    local char=LP.Character
    if not char then return end
    if (Config.AutoHaki or Config.AutoBuso) and not char:FindFirstChild("HasBuso") then
        throttle("Buso",5,function() remote("Buso") end)
    end
    if Config.AutoKen or Config.AutoObservation then throttle("Ken",8,function() event("Ken",true) end) end
    if Config.AutoRace or Config.AutoRaceV3 then throttle("Race",30,function() event("ActivateAbility") end) end
end
--// V22: lightweight, opt-in pickup coordinator (Banana review gap fix).
-- Only move toward visible client objects; record attempts separately from despawn.
do
    local P={Blocked=setmetatable({},{__mode="k"}), Current=nil,
        CacheTokens={},TokenCacheAt=-100,Scans=0,Moved=0,Attempts=0,
        Despawned=0,Failures=0,LastAttempt=nil,LastStatus="Idle",LastKind="None",LastTarget="None",
        LastActionAt=0}
    STATE.Pickups=P
    local function textName(item)
        return (item.Name.." "..(item.Parent and item.Parent.Name or "")):lower()
    end
    local function isItem(node,kind)
        if not (node and node:IsA("BasePart") and node:IsDescendantOf(WS)) then return false end
        local name=textName(node)
        if kind=="Chest" then return name:find("chest1",1,true)~=nil or
            name:find("chest2",1,true)~=nil or name:find("chest3",1,true)~=nil end
        if kind=="Berry" then
            -- Do not discard an actual Berry just because its parent is a Berry Tree.
            local own=node.Name:lower()
            local parent=node.Parent
            if own:find("berry",1,true) and
                not own:find("tree",1,true) and not own:find("bush",1,true) then return true end
            if parent and parent.Name:lower():find("berry",1,true) and
                (own=="handle" or own=="main") then
                return parent:IsA("Tool") or
                    parent:FindFirstChildWhichIsA("ProximityPrompt",true)~=nil or
                    parent:FindFirstChildWhichIsA("ClickDetector",true)~=nil
            end
            return false
        end
        if kind=="Magnet Token" then
            return name:find("magnet token",1,true)~=nil or name:find("magnettoken",1,true)~=nil
        end
        return false
    end
    local function interactions(node)
        local parent=node.Parent
        local grand=parent and parent.Parent
        local function pick(object,class)
            if not object then return nil end
            if object:IsA(class) then return object end
            return object:FindFirstChildWhichIsA(class,true)
        end
        for _,scope in ipairs({node,parent}) do
            local prompt=pick(scope,"ProximityPrompt")
            if prompt and prompt.Enabled then return "Prompt",prompt end
        end
        for _,scope in ipairs({node,parent}) do
            local click=pick(scope,"ClickDetector")
            if click then return "Click",click end
        end
        if node.CanTouch or (grand and grand:IsA("Model")) then return "Touch",node end
        return nil,nil
    end
    function P.ScanTokens()
        -- Only scan the full Workspace on request or at most once per 22 seconds.
        if os.clock()-P.TokenCacheAt<22 then return P.CacheTokens end
        P.TokenCacheAt=os.clock()
        local parts={}
        local descendants=WS:GetDescendants()
        for i,node in ipairs(descendants) do
            if isItem(node,"Magnet Token") then parts[#parts+1]=node end
            if i%2500==0 then task.wait() end
            if not STATE.Alive then break end
        end
        P.CacheTokens=parts
        P.Scans=P.Scans+1
        return parts
    end
    function P.Find(kind)
        local _,_,root,ok=alive()
        if not ok or not root then return nil end
        local list=kind=="Magnet Token" and P.ScanTokens() or worldPickups()
        local maxDistance=math.clamp(tonumber(Config.PickupMaxDistance) or 1400,150,4000)
        local now=os.clock()
        local best,bestD,bestMethod,bestDevice=nil,math.huge,nil,nil
        for _,part in ipairs(list) do
            if isItem(part,kind) and now>=(P.Blocked[part] or 0) then
                local method,device=interactions(part)
                if method then
                    local d=(part.Position-root.Position).Magnitude
                    if d<=maxDistance and d<bestD then
                        best,bestD,bestMethod,bestDevice=part,d,method,device
                    end
                end
            end
        end
        return best,bestD,bestMethod,bestDevice
    end
    function P.Step(kind)
        if not STATE.Alive or Config.FarmEnabled or Config.AutoSea or Config.AutoRaidCombat then return false end
        if Config.SpookyAutoDungeon or Config.SpookyAutoBounty or Config.AutoSeaBoat then return false end
        local now=os.clock()
        local last=P.LastAttempt
        if last and (not last.Part or not last.Part.Parent or not last.Part:IsDescendantOf(WS)) then
            P.Despawned=P.Despawned+1
            P.LastStatus="Pickup object despawned (reward not independently verified)"
            P.LastAttempt=nil
        end
        local old=P.Current
        if old and old.Kind==kind and (not old.Part or not old.Part.Parent or not old.Part:IsDescendantOf(WS)) then
            P.Despawned=P.Despawned+1;P.LastStatus="Target despawned after attempt (reward unverified)"
            P.Current=nil;old=nil
        end
        -- Prior version reset the Start timestamp after 12s, so the 14s timeout
        -- could never fire. Block genuinely unreachable objects for one cooldown.
        if old and old.Kind==kind and now-(old.Start or now)>=14 then
            if old.Part then P.Blocked[old.Part]=now+math.max(10,tonumber(Config.PickupFailureCooldown) or 35) end
            P.Failures=P.Failures+1;P.Current=nil
            P.LastStatus=kind..": navigation timed out; switching target"
            return false
        end
        local part,dist,method,device=P.Find(kind)
        if not part then
            P.LastStatus=kind..": no actionable loaded object"
            return false
        end
        P.LastKind=kind;P.LastTarget=part:GetFullName()
        if dist>8 then
            -- Maintain one target for a few seconds to avoid path thrashing.
            if old and old.Part and old.Part.Parent and old.Kind==kind and
                now-(old.Start or now)<14 and now>=(P.Blocked[old.Part] or 0) then
                part=old.Part
                local _,_,currentRoot,currentOK=alive()
                if currentOK and currentRoot then dist=(part.Position-currentRoot.Position).Magnitude end
                method,device=interactions(part)
                if not method then
                    P.Blocked[part]=now+math.max(10,tonumber(Config.PickupFailureCooldown) or 35)
                    P.Failures=P.Failures+1;P.Current=nil
                    P.LastStatus=kind..": interaction disabled; switching target"
                    return false
                end
            end
            P.Current={Part=part,Kind=kind,Start=(old and old.Part==part and old.Start) or now}
            if P.Current.Start and now-P.Current.Start>14 then
                P.Blocked[part]=now+math.max(10,tonumber(Config.PickupFailureCooldown) or 35)
                P.Failures=P.Failures+1;P.Current=nil
                P.LastStatus=kind..": timed out; try next visible pickup"
                return false
            end
            P.Moved=P.Moved+1
            P.LastStatus=kind..": navigating, "..math.floor(dist).." studs away"
            return moveTo(part.CFrame*CFrame.new(0,3,0))
        end
        if now-(P.LastActionAt or 0)<2 then return false end
        P.LastActionAt=now
        local success=false
        if method=="Prompt" then
            local fn=api("fireproximityprompt")
            if fn then success=pcall(fn,device) end
        elseif method=="Click" then
            local fn=api("fireclickdetector")
            if fn then success=pcall(fn,device) end
        elseif method=="Touch" then
            local fn=api("firetouchinterest")
            local _,_,root=alive()
            if fn and root then success=pcall(function() fn(root,part,0);fn(root,part,1) end) end
        end
        P.Attempts=P.Attempts+1
        P.LastAttempt={Part=part,At=now}
        P.Blocked[part]=now+math.max(10,tonumber(Config.PickupFailureCooldown) or 35)
        P.LastStatus=kind..(success and ": interaction requested; reward NOT verified" or
            ": no compatible interaction API, manual interaction required")
        P.Current=nil
        return success
    end
    function P.Reset()
        P.Current=nil;P.LastStatus="Stopped"
    end
end

local function tryNearestChest()
    return STATE.Pickups.Step("Chest")
end
local function tryBerry()
    return STATE.Pickups.Step("Berry")
end
local function collectFruit()
    local fruits=fruitsOnGround()
    local _,_,root=alive();if not root then return end
    local best,d=nil,math.huge
    for _,tool in ipairs(fruits) do
        local h=tool:FindFirstChild("Handle")
        if h and (h.Position-root.Position).Magnitude<d then best,d=h,(h.Position-root.Position).Magnitude end
    end
    if best then
        if d>8 then moveTo(best.CFrame*CFrame.new(0,4,0))
        elseif type(firetouchinterest)=="function" then
            pcall(function() firetouchinterest(root,best,0);firetouchinterest(root,best,1) end)
        end
    end
end
--// V22: client-visible event radar; names/presence do NOT establish event rewards.
do
    local E={LastScan=-100,Running=false,Scans=0,Total=0,Found={},Status="Not scanned"}
    STATE.EventRadar=E
    local markers={
      ["Magnet Token"]={"magnet token","magnettoken"},
      ["Factory"]={"factory core"},
      ["Pirate Raid"]={"pirate raid"},
      ["Mirage Island"]={"mirage island"},
      ["Prehistoric Island"]={"prehistoric island"},
      ["Frozen Dimension"]={"frozen dimension"},
      ["Halloween"]={"pumpkinhunt","jack o' lantern","halloween"},
      ["Sea Beast"]={"sea beast","terrorshark"},
      ["Leviathan"]={"leviathan"},
    }
    function E.Scan()
        if E.Running then return false,"Scan already in progress" end
        if os.clock()-E.LastScan<7 then return false,"Next scan available in a few seconds" end
        E.Running=true;E.LastScan=os.clock();E.Status="Scanning visible Workspace"
        task.spawn(function()
            local ok,err=pcall(function()
                local seen={};local total=0
                for _,item in ipairs(WS:GetDescendants()) do
                    if not STATE.Alive then break end
                    total=total+1
                    -- Process only named parent objects, avoid counting the same object hierarchy dozens of times.
                    if item:IsA("Model") or item:IsA("Folder") or item:IsA("BasePart") then
                        local name=item.Name:lower()
                        for category,needles in pairs(markers) do
                            for _,token in ipairs(needles) do
                                if name:find(token,1,true) then
                                    seen[category]=(seen[category] or 0)+1;break
                                end
                            end
                        end
                    end
                    if total%2200==0 then task.wait() end
                end
                E.Total=total;E.Found=seen;E.Scans=E.Scans+1
                local matched=0;for _ in pairs(seen) do matched=matched+1 end
                E.Status=string.format("Sea %d: %d categories / %d loaded instances",STATE.World,matched,total)
            end)
            if not ok then E.Status="Scan failed: "..tostring(err) end
            E.Running=false
        end)
        return true,"Event radar scan started"
    end
    function E.Summary()
        local names={}
        for key,n in pairs(E.Found) do names[#names+1]=key.." ("..n..")" end
        table.sort(names)
        return #names>0 and table.concat(names," | ") or "No matching event objects loaded"
    end
end

local function goNPC(name)
    if name=="" then return false end
    for _,folder in ipairs({WS:FindFirstChild("NPCs"), RS:FindFirstChild("NPCs")}) do
        if folder then
            for _,model in ipairs(folder:GetChildren()) do
                if model.Name:lower():find(name:lower(),1,true) then
                    local p=model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
                    if p then moveTo(p.CFrame*CFrame.new(0,3,4));return true end
                end
            end
        end
    end
    notice("Travel","NPC not found: "..name,"warn")
    return false
end
local function goIsland(name)
    if name=="" then return false end
    local map=WS:FindFirstChild("Map")
    if not map then return false end
    for _,v in ipairs(map:GetDescendants()) do
        if (v:IsA("Model") or v:IsA("Folder")) and v.Name:lower():find(name:lower(),1,true) then
            local cf
            if v:IsA("Model") then cf=v:GetPivot()
            else local p=v:FindFirstChildWhichIsA("BasePart",true);if p then cf=p.CFrame end end
            if cf then moveTo(cf*CFrame.new(0,45,0));return true end
        end
    end
    notice("Travel","Island not found: "..name,"warn")
    return false
end
local function refreshOptions(folder,filter)
    local out={}
    if folder then
        local seen={}
        for _,v in ipairs(folder:GetChildren()) do
            if not filter or filter(v) then
                local n=norm(v.Name)
                if not seen[n] then seen[n]=true;table.insert(out,v.Name) end
            end
        end
    end
    table.sort(out)
    return out
end
local function getMobs() return refreshOptions(enemyFolder(),function(v) return STATE.IsAliveNPC(v) end) end
local function getNPCs() return refreshOptions(WS:FindFirstChild("NPCs")) end
local function getIslands() return refreshOptions(WS:FindFirstChild("Map")) end
local function getPlayers()
    local arr={}
    for _,p in ipairs(Players:GetPlayers()) do if p~=LP then table.insert(arr,p.Name) end end
    return arr
end
local function raidSummon()
    local world=STATE.World
    local parts={
        world==2 and WS:FindFirstChild("Map") and WS.Map:FindFirstChild("CircleIsland"),
        world==3 and WS:FindFirstChild("Map") and WS.Map:FindFirstChild("Boat Castle"),
    }
    for _,node in ipairs(parts) do
        if node then
            local button=node:FindFirstChild("RaidSummon",true)
            local detector=button and button:FindFirstChildWhichIsA("ClickDetector",true)
            if detector and type(fireclickdetector)=="function" then
                pcall(function() fireclickdetector(detector) end)
                return true
            end
        end
    end
    -- Fallback: find buttons by expected raid placement, not any clickdetector.
    for _,node in ipairs(WS:GetDescendants()) do
        if node:IsA("ClickDetector") and node.Parent and node.Parent.Name=="Main" then
            local full=node:GetFullName():lower()
            if full:find("raidsummon",1,true) and type(fireclickdetector)=="function" then
                pcall(function() fireclickdetector(node) end);return true
            end
        end
    end
    return false
end
local function selectRaid()
    remote("RaidsNpc","Check")
    local ok=remote("RaidsNpc","Select",Config.Raid)
    return ok
end
local function raidIsland()
    local origin=WS:FindFirstChild("_WorldOrigin")
    local locations=origin and origin:FindFirstChild("Locations")
    if not locations then return false end
    local selected=nil
    for _,v in ipairs(locations:GetChildren()) do
        local n=v.Name:match("Island%s*(%d+)")
        if n and v:IsA("BasePart") then
            if not selected or tonumber(n)>selected.n then selected={n=tonumber(n),p=v} end
        end
    end
    if selected then moveTo(selected.p.CFrame*CFrame.new(0,55,0));return true end
    return false
end
local function raidEnemies()
    local folder=enemyFolder(); if not folder then return nil end
    local out={}
    for _,m in ipairs(folder:GetChildren()) do
        if STATE.IsAliveNPC(m) then table.insert(out,m) end
    end
    return out
end
local function teleportPlayer(name)
    local p=Players:FindFirstChild(name)
    local r=p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    if r then return moveTo(r.CFrame*CFrame.new(0,3,5)) end
    notice("Travel","Player unavailable","warn");return false
end
local function callRedeem()
    local folder=RS:FindFirstChild("Remotes")
    local r=folder and folder:FindFirstChild("Redeem")
    if not r then notice("Codes","Redeem remote missing","warn");return end
    task.spawn(function()
        local i=0
        for _,code in ipairs(redeemCodes) do
            if not STATE.Alive then break end
            pcall(function() r:InvokeServer(code) end)
            i=i+1;task.wait(.35)
        end
        notice("Codes","Attempted "..i.." redeem codes (some may be expired)")
    end)
end
local function findRod()
    local char=LP.Character;local bag=LP:FindFirstChild("Backpack")
    for _,container in ipairs({char,bag}) do
        if container then for _,v in ipairs(container:GetChildren()) do
            if v:IsA("Tool") and (v:FindFirstChild("FishingRodData",true) or v.Name:lower():find("rod",1,true)) then
                return v
            end
        end end
    end
end
local function fishOnce()
    local rod=findRod(); if not rod then return end
    if rod.Parent~=LP.Character then
        local _,h=alive();if h then pcall(function() h:EquipTool(rod) end) end
    end
    pcall(function() rod:Activate() end)
end
local function seaTarget()
    local folder=enemyFolder()
    if not folder then return nil end
    local names={"Sea Beast","Shark","Piranha","Fish Crew","Terrorshark","Leviathan","Ghost Ship"}
    local result=enemySearch(names)
    if result then return result end
    for _,v in ipairs(WS:GetChildren()) do
        for _,n in ipairs(names) do
            if norm(v.Name)==norm(n) and v:FindFirstChildOfClass("Humanoid") then return v end
        end
    end
end
local function findSeaLocation()
    local origin=WS:FindFirstChild("_WorldOrigin")
    if not origin then return nil end
    for _,name in ipairs({"Mirage Island","Prehistoric Island","Frozen Dimension"}) do
        local v=origin:FindFirstChild(name,true)
        if v and v:IsA("BasePart") then return v.CFrame*CFrame.new(0,50,0),name end
    end
end
local function hopServer()
    local candidates={}
    local ok,err=pcall(function()
        local url="https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
        local response=game:HttpGet(url)
        local data=Http:JSONDecode(response)
        if type(data.data)=="table" then
            for _,v in ipairs(data.data) do
                if v.id~=game.JobId and v.playing and v.maxPlayers and v.playing<v.maxPlayers then
                    table.insert(candidates,v)
                end
            end
        end
    end)
    if not ok then notice("Server","Server list request failed: "..tostring(err),"warn");return end
    if #candidates==0 then notice("Server","No available public server","warn");return end
    table.sort(candidates,function(a,b) return a.playing<b.playing end)
    local id=candidates[math.random(1,math.min(6,#candidates))].id
    safe("hop",function() TP:TeleportToPlaceInstance(game.PlaceId,id,LP) end)
end
local function doOnce(method,...)
    local args={...}
    safe(method,function()
        local ok,r=remote(method,table.unpack(args))
        if not ok then error(tostring(r)) end
        notice("Action",method.." invoked")
    end)
end
-- One farm loop owns movement. Background jobs do not stack independent tweens.
local function startLoop(name,delay,fn)
    if STATE.Jobs[name] then return end
    STATE.Jobs[name]=true
    task.spawn(function()
        local thread=coroutine.running()
        STATE.MoveThreadOwners[thread]=name
        while STATE.Alive do
            task.wait(delay)
            if not STATE.Alive then break end
            safe(name,fn)
        end
        STATE.MoveThreadOwners[thread]=nil
    end)
end
startLoop("Farm engine",.16,function()
    if not Config.FarmEnabled then return end
    if STATE.World==0 then return end
    local _,h,_,ok=alive();if not ok then return end
    if Config.LowHealth>0 and h.MaxHealth>0 and h.Health/h.MaxHealth*100<Config.LowHealth then
        cancelMove();STATE.ReleaseFarmHover();return
    end
    attackHaki()
    local target=getTarget()
    if STATE.NPCFilter.StaleDestination and Config.FarmMode=="Halloween" then
        -- Cancel stale movement toward a dead event NPC, including when the death
        -- notification cleared the held target before this Farm tick.
        cancelMove()
    end
    STATE.NPCFilter.StaleDestination=false
    if target and STATE.IsAliveNPC(target) then
        if STATE.NPCFilter.Held~=target then
            STATE.NPCFilter.TargetChanges=STATE.NPCFilter.TargetChanges+1
            STATE.NPCFilter.Held=target
        end
        if Config.MobMagnet then STATE.MobMagnet.Step(target)
        elseif next(STATE.MobMagnet.Tracked) then STATE.MobMagnet.Stop() end
        engage(target)
    else
        if STATE.NPCFilter.Held then
            STATE.NPCFilter.Held=nil;STATE.NPCFilter.LastLostAt=os.clock()
            -- Halloween has no valid fallback spawn; cancel stale corpse tween.
            if Config.FarmMode=="Halloween" then cancelMove() end
        end
        STATE.MobMagnet.Stop()
        STATE.ReleaseFarmHover()
    end
end)
startLoop("Character support",1,function()
    if Config.AutoStats then throttle("stats",3,function() remote("AddPoint",Config.Stat,3) end) end
    if Config.AutoBuso or Config.AutoObservation or Config.AutoRaceV3 then attackHaki() end
    if Config.AutoClick and not Config.FarmEnabled then punch() end
end)
startLoop("Collectibles",1.3,function()
    -- Never steal movement from a running farm.
    if Config.FarmEnabled then return end
    if Config.AutoStoreFruit then storeFruit() end
    if Config.AutoCollectFruit then collectFruit();return end
    if Config.AutoMagnetToken then STATE.Pickups.Step("Magnet Token");return end
    if Config.AutoChest then tryNearestChest();return end
    if Config.AutoBerry then tryBerry();return end
end)
startLoop("Banana event radar",26,function()
    if Config.EventRadar and STATE.EventRadar and not STATE.EventRadar.Running then
        STATE.EventRadar.Scan()
    end
end)
startLoop("Berry + Hop",5,function()
    -- Optional server hop after a sustained absence of actionable berries.
    if not (Config.AutoBerry and Config.AutoBerryHop) then
        STATE.BerryLastSeen=os.clock();return
    end
    if Config.FarmEnabled or Config.AutoSea or Config.AutoChest or Config.AutoMagnetToken then return end
    local berry=STATE.Pickups.Find("Berry")
    if berry then STATE.BerryLastSeen=os.clock();return end
    local grace=math.clamp(tonumber(Config.BerryHopAfter) or 180,120,900)
    if os.clock()-(STATE.BerryLastSeen or STATE.Start)>grace then
        STATE.BerryLastSeen=os.clock()
        notice("Berry + Hop","No actionable berries loaded for "..grace.." sec; requesting hop")
        hopServer()
    end
end)
startLoop("Events",3,function()
    if Config.AutoElite then throttle("elite",10,function() remote("EliteHunter") end) end
    if Config.AutoPray then throttle("pray",12,function() remote("gravestoneEvent",2) end) end
    if Config.AutoBuyChip then throttle("buyraid",30,selectRaid) end
    if Config.AutoRaid then
        if Config.FragmentsCap>0 and value("Fragments")>=Config.FragmentsCap then Config.AutoRaid=false;return end
        throttle("raid",15,function()
            local success=selectRaid()
            if success then raidSummon() end
        end)
    end
    if Config.AutoAdvanceRaid then raidIsland() end
end)
startLoop("Raid combat",.6,function()
    if not Config.AutoRaidCombat or Config.FarmEnabled or Config.AutoSea then return end
    local origin=WS:FindFirstChild("_WorldOrigin")
    local locations=origin and origin:FindFirstChild("Locations")
    if not locations then return end
    local raidActive=false
    for _,loc in ipairs(locations:GetChildren()) do
        if loc.Name:match("^Island%s*%d+") then raidActive=true;break end
    end
    if not raidActive then return end
    local mob=enemySearch(nil,true)
    if mob then engage(mob) end
end)
startLoop("Sea/fishing",.4,function()
    if Config.FarmEnabled then return end
    if Config.AutoFish and not Config.FishingAdvanced then fishOnce() end
    if Config.AutoSea then
        local target=seaTarget()
        if target then engage(target) end
    end
end)
startLoop("Experience",5,function()
    if Config.FarmEnabled or Config.AutoSea or Config.AutoRaidCombat then return end
    if Config.AutoTyrant then
        local mob=enemySearch("Tyrant of the Skies")
        if mob and not Config.FarmEnabled then engage(mob) end
    elseif Config.AutoKatakuri then
        local mob=enemySearch({"Cake Prince","Dough King"})
        if mob and not Config.FarmEnabled then engage(mob) end
    elseif Config.AutoBones then
        local mob=enemySearch(materialMobs.Bones)
        if mob and not Config.FarmEnabled then engage(mob) end
    end
end)
--// UNIFIED FEATURE MODULES -------------------------------------------------------
-- These features are implemented as independent jobs but share the existing
-- combat, movement, remote, notification and configuration services.
local EX={}
STATE.Unified=EX
EX.Bosses={
    {flag="AutoSoulReaper",names={"Soul Reaper"},world=3},
    {flag="AutoDarkbeard",names={"Darkbeard"},world=2},
    {flag="AutoRipIndra",names={"rip_indra True Form","rip_indra"},world=3},
    {flag="AutoDoughKing",names={"Dough King","Cake Prince"},world=3},
    {flag="AutoEliteCombat",names={"Diablo","Deandre","Urban"},world=3},
}
function EX.Carried(name)
    local char=LP.Character
    local bag=LP:FindFirstChild("Backpack")
    for _,container in ipairs({char,bag}) do
        if container then
            for _,item in ipairs(container:GetChildren()) do
                if item:IsA("Tool") and item.Name:lower():find(tostring(name):lower(),1,true) then return item end
            end
        end
    end
    return nil
end
function EX.SelectedBoss()
    local mob=enemySearch(Config.Boss)
    if mob then return mob end
    local folder=enemyFolder()
    if folder then
        for _,v in ipairs(folder:GetChildren()) do
            if isBoss(v.Name) then
                local hum=v:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health>0 then return v end
            end
        end
    end
    return nil
end
function EX.TargetBoss()
    for _,item in ipairs(EX.Bosses) do
        if Config[item.flag] and (not item.world or item.world==STATE.World) then
            local mob=enemySearch(item.names)
            if mob then return mob end
        end
    end
    return nil
end
function EX.QuestActions(name,first,second)
    local ok,result=remote(name,first,second)
    if ok and result~=false then
        local valueText=typeof(result)=="table" and Http:JSONEncode(result) or tostring(result)
        notice("Quest",tostring(name).." / "..tostring(first)..": "..valueText:sub(1,100))
    else
        notice("Quest",tostring(name).." request failed","warn")
    end
    return ok,result
end
function EX.Craft(item)
    if not item or item=="" then return end
    -- Reference scripts use CraftItem/Craft; these signatures may change.
    local ok,result=remote("CraftItem","Craft",item)
    if not ok then notice("Craft",tostring(result),"warn")
    else notice("Craft","Request sent: "..tostring(item)) end
end
function EX.RaidAwaken()
    local ok,can=remote("Awakener","Check")
    if ok and can then
        local worked,res=remote("Awakener","Awaken")
        if not worked then notice("Awaken",tostring(res),"warn") end
    end
end
function EX.BuyFruit()
    -- Only purchase after checking on-sale status.
    local ok,stock=remote("GetFruits",false)
    if not ok or type(stock)~="table" then return false end
    for _,fruit in pairs(stock) do
        if fruit.Name==Config.BuyFruit or tostring(fruit.Name):find(Config.BuyFruit,1,true) then
            if fruit.OnSale then
                local worked,res=remote("PurchaseRawFruit",fruit.Name)
                if worked then notice("Fruit","Purchase attempted: "..fruit.Name) end
                return worked,res
            end
            return false
        end
    end
    return false
end
function EX.FishingAction(operation)
    local jobs=RS:FindFirstChild("JobsReplicated")
    if jobs then
        local ok,mod=pcall(require,jobs)
        if ok and type(mod)=="table" and type(mod.InvokeServer)=="function" then
            return pcall(mod.InvokeServer,"FishingNPC",operation)
        end
    end
    return remote("FishingNPC",operation)
end
function EX.GameCraft(item,method)
    local target=RS:FindFirstChild("Modules")
    local net=target and target:FindFirstChild("Net")
    local rf=net and net:FindFirstChild("RF/Craft")
    if rf and rf:IsA("RemoteFunction") then
        return pcall(rf.InvokeServer,rf,"Craft",item,1,{})
    end
    return remote("CraftItem","Craft",item)
end
function EX.GetInventory()
    return remote("getInventory")
end
function EX.SeaEnvironment()
    local origin=WS:FindFirstChild("_WorldOrigin")
    local locations=origin and origin:FindFirstChild("Locations")
    if not locations then return {} end
    local markers={}
    for _,v in ipairs(locations:GetChildren()) do
        if v.Name:find("Mirage") or v.Name:find("Frozen Dimension") or
           v.Name:find("Prehistoric") or v.Name:find("Kitsune") then
            table.insert(markers,v)
        end
    end
    return markers
end
function EX.EventPickup()
    if Config.FarmEnabled or Config.AutoRaidCombat or Config.AutoSea then return end
    local _,_,root=alive()
    if not root then return end
    local look=Config.EventPickup:lower()
    local best,d=nil,math.huge
    local world=WS:FindFirstChild("_WorldOrigin") or WS
    for _,v in ipairs(world:GetDescendants()) do
        local isPhysical=v:IsA("BasePart")
        if isPhysical and (v.Name.." "..(v.Parent and v.Parent.Name or "")):lower():find(look,1,true) then
            local dd=(v.Position-root.Position).Magnitude
            if dd<d then best,d=v,dd end
        end
    end
    if best then
        if d>8 then moveTo(best.CFrame*CFrame.new(0,4,0))
        else
            local touch=(type(firetouchinterest)=="function" and firetouchinterest) or api("firetouchinterest")
            if touch then pcall(function() touch(root,best,0);touch(root,best,1) end) end
            local prompt=best:FindFirstChildWhichIsA("ProximityPrompt",true)
            local usePrompt=api("fireproximityprompt")
            if prompt and usePrompt then pcall(usePrompt,prompt) end
        end
    end
end
function EX.ProtectRareItems()
    if not (EX.Carried("Fist of Darkness") or EX.Carried("God's Chalice")) then return end
    local cf=STATE.World==2 and CFrame.new(-385.250916,73.0458984,297.388397)
        or CFrame.new(-12463,374,-7523)
    moveTo(cf)
end
function EX.SummonHallow()
    if not EX.Carried("Hallow Essence") then return false end
    local map=WS:FindFirstChild("Map")
    local altar=map and map:FindFirstChild("Haunted Castle",true)
    if not altar then return false end
    local detector=altar:FindFirstChildWhichIsA("ClickDetector",true)
    local fire=api("fireclickdetector")
    if detector and fire then
        return pcall(fire,detector)
    end
    return false
end
function EX.SummonCake()
    if EX.Carried("Sweet Chalice") then return remote("CakePrinceSpawner") end
    return false
end
function EX.SpecialRaidLaw()
    -- Exact path derived from bnn.lua; never click an unrelated island button.
    local boss=enemySearch("Order")
    if boss then engage(boss);return true end
    if not (EX.Carried("Microchip") or EX.Carried("Core Brain")) then
        if Config.AutoBuyLawChip and value("Fragments")>=1000 then
            remote("BlackbeardReward","Microchip","2")
        end
        return false
    end
    local map=WS:FindFirstChild("Map")
    local island=map and map:FindFirstChild("CircleIsland")
    local summon=island and island:FindFirstChild("RaidSummon",true)
    local button=summon and summon:FindFirstChild("Button",true)
    local main=button and button:FindFirstChild("Main")
    local detector=main and main:FindFirstChildWhichIsA("ClickDetector")
    local fire=api("fireclickdetector")
    if detector and fire then return pcall(fire,detector) end
    return false
end
EX.SeaZones={
    ["Zone 1"]={-21767.4765625,0,5815.41259765625},
    ["Zone 2"]={-26017.931640625,0,5657.8837890625},
    ["Zone 3"]={-29545.703125,0,6377.98974609375},
    ["Zone 4"]={-33609.7578125,0,7422.890625},
    ["Zone 5"]={-38480.42578125,0,10350.943359375},
    ["Zone 6"]={-32975.9921875,0,25963.7109375},
}
function EX.GoZone()
    if STATE.World~=3 then notice("Sea","Sea zones require world 3","warn");return false end
    local xyz=EX.SeaZones[Config.SeaZone]
    if not xyz then return false end
    return moveTo(CFrame.new(xyz[1],xyz[2]+25,xyz[3]))
end
function EX.BuyBoat()
    return remote("BuyBoat",Config.SelectedBoat)
end
function EX.TeleportToEvent(name)
    local origin=WS:FindFirstChild("_WorldOrigin")
    local location=origin and origin:FindFirstChild(name,true)
    if not location then notice("Event",name.." not loaded","warn"); return false end
    local cf
    if location:IsA("BasePart") then cf=location.CFrame
    elseif location:IsA("Model") then cf=location:GetPivot()
    else
        local part=location:FindFirstChildWhichIsA("BasePart",true)
        if part then cf=part.CFrame end
    end
    if cf then return moveTo(cf*CFrame.new(0,45,0)) end
    return false
end
function EX.Status(name,method,...)
    local ok,value=remote(method,...)
    if not ok then notice("Status",name.." unavailable","warn");return end
    local msg=tostring(value)
    if typeof(value)=="table" then
        local encoded=pcall(function() msg=Http:JSONEncode(value) end)
        if not encoded then msg="table" end
    end
    notice(name,msg:sub(1,140))
    return value
end
function EX.OpenFishingChest()
    local bag=LP:FindFirstChild("Backpack")
    if not bag then return end
    for _,item in ipairs(bag:GetChildren()) do
        if item.Name:lower():find("chest",1,true) then
            local r=item:FindFirstChild("RemoteEvent",true)
            if r then pcall(function() r:FireServer("Visual");r:FireServer("Open") end) end
        end
    end
end
function EX.FindDealer()
    return remote("LegendarySwordDealer","1")
end
-- The following loops are intentionally slower than the central farm combat
-- loop to avoid flooding hidden game endpoints with repeated RPCs.
startLoop("Unified bosses",.75,function()
    if Config.FarmEnabled or Config.AutoSea or Config.AutoRaidCombat then return end
    local mob=Config.AutoLawRaid and enemySearch("Order") or EX.TargetBoss()
    if mob then engage(mob) end
end)
startLoop("Unified summons",8,function()
    if Config.AutoDoughSummon then EX.SummonCake() end
    if Config.AutoHallowBuy and not EX.Carried("Hallow Essence") then remote("Bones","Buy",1,1) end
    if Config.AutoRandomBones then remote("Bones","Buy",1,1) end
end)
startLoop("Unified auto shop",15,function()
    if Config.AutoAwaken then EX.RaidAwaken() end
    if Config.AutoLegendarySword and STATE.World==2 then
        for _,id in ipairs({"1","2","3"}) do remote("LegendarySwordDealer",id) end
    end
    if Config.AutoHakiColor then remote("ColorsDealer","2") end
    if Config.AutoBuyChosenFruit then EX.BuyFruit() end
    if Config.AutoMeleeStyle then
        local buy={
            ["Dark Step"]="BuyBlackLeg",["Water Kung Fu"]="BuyFishmanKarate",
            ["Electro"]="BuyElectro",["Superhuman"]="BuySuperhuman",
            ["Death Step"]="BuyDeathStep",["Sharkman Karate"]="BuySharkmanKarate",
            ["Electric Claw"]="BuyElectricClaw",["Dragon Talon"]="BuyDragonTalon",
            ["Godhuman"]="BuyGodhuman",["Sanguine Art"]="BuySanguineArt",
        }
        local method=buy[Config.SelectedBuyStyle]
        if method then remote(method) end
    end
end)
startLoop("Unified events",3,function()
    if Config.AutoSafeItems and not Config.FarmEnabled then EX.ProtectRareItems() end
    if Config.AutoEventCollect then EX.EventPickup() end
    if Config.AutoLawRaid then throttle("lawraid",30,EX.SpecialRaidLaw) end
    if Config.AutoBuyLawChip and not Config.AutoLawRaid then throttle("lawchip",30,function() remote("BlackbeardReward","Microchip","2") end) end
    if Config.AutoFishQuest then throttle("fishquest",30,function() remote("FishingNPC","Angler","AskQuest") end) end
    if Config.AutoSellFish then throttle("sellfish",15,function() EX.FishingAction("SellFish") end) end
    if Config.AutoOpenChest then EX.OpenFishingChest() end
end)
startLoop("Unified world patrol",2,function()
    if Config.FarmEnabled or Config.AutoSea or Config.AutoRaidCombat then return end
    if Config.AutoFactory then
        local mob=enemySearch({"Core","Factory Core"})
        if mob then engage(mob) end
    elseif Config.AutoPirateRaid then
        local mob=enemySearch({"Pirate Millionaire","Pistol Billionaire"})
        if mob then engage(mob) end
    end
end)
startLoop("Unified race",5,function()
    if Config.AutoRaceV4 then
        event("ActivateAbility")
    end
    if Config.AutoObservationTrain then event("Ken",true) end
end)
startLoop("Unified follow",.65,function()
    if Config.AutoFollowPlayer and not Config.FarmEnabled and not Config.AutoSea then
        local selected=Config.SelectedPlayer
        if selected~="" then teleportPlayer(selected) end
    end
end)
startLoop("Unified hopping",5,function()
    if Config.FarmEnabled or Config.AutoSea or Config.AutoRaidCombat then return end
    local elapsed=os.clock()-(STATE.LastHopAttempt or 0)
    if elapsed<math.max(60,Config.BossHopDelay) then return end
    if Config.AutoChestHop and not findWorldItem({"chest"}) then
        STATE.LastHopAttempt=os.clock();hopServer()
    elseif Config.AutoSeaHop and not seaTarget() then
        STATE.LastHopAttempt=os.clock();hopServer()
    elseif Config.AutoBossHop and not enemySearch(Config.Boss) then
        STATE.LastHopAttempt=os.clock()
        hopServer()
    elseif Config.AutoFruitHop and #fruitsOnGround()==0 then
        STATE.LastHopAttempt=os.clock()
        hopServer()
    end
end)
-- Event-based dodge, no permanent event polling.
local currentEnemies=enemyFolder()
if currentEnemies then
    on(currentEnemies,currentEnemies.DescendantAdded,function(node)
        if not Config.AutoDodgeSkill then return end
        if node.Name=="BodyGyro" or node.Name=="BodyPosition" or node.Name=="KiBlastFireShort" then
            STATE.DodgeUntil=os.clock()+math.min(4,math.max(1,Config.AutoSkillDelay))
        end
    end)
end
-- Reversible visual preferences.
local originalLighting={Brightness=Lighting.Brightness,GlobalShadows=Lighting.GlobalShadows,
    FogEnd=Lighting.FogEnd,Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient}
function EX.ApplyFullBright()
    if Config.AutoFullBright then
        Lighting.Brightness=2;Lighting.GlobalShadows=false
        Lighting.FogEnd=100000;Lighting.Ambient=Color3.fromRGB(200,200,200)
        Lighting.OutdoorAmbient=Color3.fromRGB(190,190,190)
    else
        for key,v in pairs(originalLighting) do pcall(function() Lighting[key]=v end) end
    end
end
EX.ParticleStates=setmetatable({}, {__mode="k"})
function EX.ApplyFPS()
    if Config.AutoFPS then
        for _,obj in ipairs(WS:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                if EX.ParticleStates[obj]==nil then EX.ParticleStates[obj]=obj.Enabled end
                obj.Enabled=false
            end
        end
    else
        for obj,enabled in pairs(EX.ParticleStates) do
            if obj and obj.Parent then pcall(function() obj.Enabled=enabled end) end
            EX.ParticleStates[obj]=nil
        end
    end
end
STATE.RestoreLighting=function()
    for key,v in pairs(originalLighting) do pcall(function() Lighting[key]=v end) end
end

local noclipParts=setmetatable({}, {__mode="k"})
local lastNoclipUpdate=0
local function restoreNoclip()
    for part,wasCollidable in pairs(noclipParts) do
        if part and part.Parent then pcall(function() part.CanCollide=wasCollidable end) end
        noclipParts[part]=nil
    end
end
STATE.RestoreNoclip=restoreNoclip
on(LP,LP.Idled,function()
    if Config.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button2Down(Vector2.new(0,0),WS.CurrentCamera.CFrame)
            task.wait(.5)
            VirtualUser:Button2Up(Vector2.new(0,0),WS.CurrentCamera.CFrame)
        end)
    end
end)
on(Run,Run.Stepped,function()
    if not STATE.Alive then return end
    local enabled=Config.Noclip and ((STATE.Mover and STATE.Mover.Active)
        or Config.FarmEnabled or Config.AutoSea or Config.AutoChest or Config.AutoBerry or Config.AutoMagnetToken or Config.AutoCollectFruit or Config.HalloweenPumpkins)
    if not enabled then
        if next(noclipParts) then restoreNoclip() end
        return
    end
    if os.clock()-lastNoclipUpdate<0.40 then return end
    lastNoclipUpdate=os.clock()
    local char=LP.Character
    if char then
        for _,part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                if noclipParts[part]==nil then noclipParts[part]=part.CanCollide end
                if part.CanCollide then part.CanCollide=false end
            end
        end
    end
end)


-- // V11 source-informed Halloween/Pull Lever/Secret Quest tools.
-- No remote third-party loader, no external webhook, no background job unless toggle ON.
do
    STATE.Events={PromptAttempts=0,LastPumpkin=nil,LastQuestCheck=nil}
    local lastPrompt=setmetatable({}, {__mode="k"})
    local function pumpkinPosition(obj)
        if obj:IsA("BasePart") then return obj.CFrame end
        if obj:IsA("Model") then return obj:GetPivot() end
        return nil
    end
    local function nearestPumpkin()
        local folder=WS:FindFirstChild("PumpkinHunt")
        local _,_,root,ok=alive()
        if not (folder and ok and root) then return nil end
        local best,cf,dist=nil,nil,math.huge
        for _,obj in ipairs(folder:GetDescendants()) do
            if obj:IsA("Model") or obj:IsA("BasePart") then
                -- Only actionable models/parts. Don't blindly move to decorations.
                local prompt=obj:FindFirstChildWhichIsA("ProximityPrompt",true)
                if prompt and prompt.Enabled and prompt.Parent and
                    os.clock()-(lastPrompt[prompt] or 0)>15 then
                    local pos=pumpkinPosition(obj)
                    if pos then
                        local d=(pos.Position-root.Position).Magnitude
                        if d<dist then best,cf,dist=obj,pos,d end
                    end
                end
            end
        end
        return best,cf,dist
    end
    STATE.FindPumpkin=nearestPumpkin
    STATE.TryPumpkin=function()
        if not (STATE.Alive and Config.HalloweenPumpkins) or Config.FarmEnabled then return false end
        local p,cf,dist=nearestPumpkin()
        if not (p and cf) then return false end
        if dist>8 then moveTo(cf*CFrame.new(0,3,5));return false end
        cancelMove()
        local prompt=p:FindFirstChildWhichIsA("ProximityPrompt",true)
        if not (prompt and prompt.Enabled) then return false end
        if os.clock()-(lastPrompt[prompt] or 0)<15 then return false end
        lastPrompt[prompt]=os.clock()
        local fire=api("fireproximityprompt")
        if type(fire)~="function" then
            if os.clock()-(STATE.Events.MissingPromptAt or 0)>30 then
                STATE.Events.MissingPromptAt=os.clock()
                slog("Executor has no fireproximityprompt; manual E required", "warn")
            end
            return false
        end
        local ok=pcall(fire,prompt)
        if ok then STATE.Events.PromptAttempts=STATE.Events.PromptAttempts+1 end
        return ok
    end
    startLoop("Halloween pumpkins",.6,function()
        if Config.HalloweenPumpkins then STATE.TryPumpkin() end
    end)
    STATE.CheckSecretQuestProgress=function()
        local net=RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
        if not net then return false,"Modules.Net not loaded" end
        local r=net:FindFirstChild("RF/RequestBonusMomentReplication")
        if not r then
            pcall(function()
                local m=require(net)
                if type(m)=="table" and type(m.RemoteFunction)=="function" then
                    r=m:RemoteFunction("RequestBonusMomentReplication")
                end
            end)
        end
        if not r or not r:IsA("RemoteFunction") then return false,"Secret quest remote not found" end
        local ok,data=pcall(function() return r:InvokeServer({Type="GetMomentProgress"}) end)
        if not ok then return false,tostring(data) end
        STATE.Events.LastQuestCheck=data
        return true,data
    end
    STATE.CheckLeverProgress=function()
        return remote("RaceV4Progress","Check")
    end
end

--// ESP manager: world-state-based overlay, no global Drawing API dependency.
local function clearESP()
    for part,gui in pairs(STATE.ESP) do pcall(function() gui:Destroy() end);STATE.ESP[part]=nil end
end
local function addESP(part,name,color)
    if not part or not part.Parent then return end
    local existing=STATE.ESP[part]
    if existing and existing.Parent then
        local label=existing:FindFirstChild("Label")
        if label then label.Text=name end
        return
    end
    local b=Instance.new("BillboardGui")
    b.Name="AZ_ESP";b.AlwaysOnTop=true;b.Size=UDim2.fromOffset(150,42)
    b.StudsOffset=Vector3.new(0,3,0);b.MaxDistance=Config.ESPDistance;b.Adornee=part
    local t=Instance.new("TextLabel")
    t.Name="Label";t.BackgroundTransparency=.35;t.BackgroundColor3=Color3.fromRGB(12,13,16)
    t.Size=UDim2.fromScale(1,1);t.Text=name;t.TextSize=11;t.Font=Enum.Font.GothamBold
    t.TextColor3=Color3.fromRGB(247,247,248);t.TextWrapped=true;t.Parent=b
    Instance.new("UICorner",t).CornerRadius=UDim.new(0,9)
    local st=Instance.new("UIStroke",t);st.Thickness=1;st.Color=Color3.fromRGB(255,255,255);st.Transparency=.53
    b.Parent=LP:WaitForChild("PlayerGui");STATE.ESP[part]=b
end
startLoop("ESP",2,function()
    if not (Config.ESPPlayer or Config.ESPEnemy or Config.ESPBoss or Config.ESPFruit or Config.ESPChest or Config.ESPIsland or Config.ESPNPC or Config.ESPBerry or Config.ESPSea) then
        clearESP();return
    end
    local visible={}
    local folder=enemyFolder()
    if folder and (Config.ESPEnemy or Config.ESPBoss) then
        for _,enemy in ipairs(folder:GetChildren()) do
            local r=enemy:FindFirstChild("HumanoidRootPart")
            if r and STATE.IsAliveNPC(enemy) and
                ((isBoss(enemy.Name) and Config.ESPBoss) or (not isBoss(enemy.Name) and Config.ESPEnemy)) then
                visible[r]=true;addESP(r,enemy.Name,Color3.fromRGB(255,172,118))
            end
        end
    end
    if Config.ESPPlayer then
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then
                local r=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if r then visible[r]=true;addESP(r,p.DisplayName,Color3.fromRGB(94,221,255)) end
            end
        end
    end
    if Config.ESPFruit then
        for _,v in ipairs(fruitsOnGround()) do
            local part=v:FindFirstChild("Handle")
            if part then visible[part]=true;addESP(part,v.Name,Color3.fromRGB(225,147,255)) end
        end
    end
    if Config.ESPChest then
        local count=0
        for _,node in ipairs(worldPickups()) do
            if node.Parent and node.Name:lower():match("^chest%d+") then
                visible[node]=true;addESP(node,node.Name,Color3.fromRGB(255,224,129))
                count=count+1;if count>80 then break end
            end
        end
    end
    if Config.ESPIsland then
        local cf,name=findSeaLocation()
        if cf then
            local part=WS:FindFirstChild(name,true)
            if part and part:IsA("BasePart") then
                visible[part]=true;addESP(part,name,Color3.fromRGB(112,249,192))
            end
        end
    end
    if Config.ESPNPC then
        local npcs=WS:FindFirstChild("NPCs")
        if npcs then
            for _,npc in ipairs(npcs:GetChildren()) do
                local r=npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
                if r and r:IsA("BasePart") then visible[r]=true;addESP(r,"NPC: "..npc.Name,Color3.fromRGB(255,255,255)) end
            end
        end
    end
    if Config.ESPBerry then
        for _,part in ipairs(worldPickups()) do
            if part.Parent and part.Name:lower():find("berry",1,true) then
                visible[part]=true;addESP(part,"Berry",Color3.fromRGB(255,255,255))
            end
        end
    end
    if Config.ESPSea then
        for _,point in ipairs(STATE.Unified and STATE.Unified.SeaEnvironment() or {}) do
            local r=point:IsA("BasePart") and point or point:FindFirstChildWhichIsA("BasePart",true)
            if r then visible[r]=true;addESP(r,point.Name,Color3.fromRGB(255,255,255)) end
        end
    end
    for part,gui in pairs(STATE.ESP) do
        if not visible[part] or not part.Parent then gui:Destroy();STATE.ESP[part]=nil end
    end
end)

--// FULL INTEGRATION MODULES ----------------------------------------------------
-- Original implementation based on the user's supplied reference files.
-- No loadstring, webhook, or external script fetch. All automatic actions are opt-in.
do
    local ADV={}
    STATE.Advanced=ADV
    ADV.Diagnostics={MovementOwner="None",FastHitLast="Never",FishState="Idle",SecretQuest="Not checked",LastError="None"}
    ADV.SecretQuestNames={
        "Escape from Alcatraz","Don Megalo","Lever Jailbreak","Rescue Hasan",
        "Archaeologist's Tablet","Prickly Harvest","Legendary Creator Statues","Crowd Favorite",
        "King's Apprentice","Breaking the Ice","Snowman","Frozen Defense",
        "The Thieving Monkey","Zipline Repair","Banana Tree","Fountain Pipe Repair",
        "Fountain Wire Repair","Sewer Gangs","Evil Slimes","Magma Ore Extraction",
        "One Last Eruption","Battle Plans","Fortress Flagpole","Fortress Under Fire",
        "Early Access","Lookout","X Marks The Spot","Chef's Kiss","Tavern Brawl",
        "Windmill Maintenance","Electric Fighting Teacher","The Clown's Jewels",
        "Unexpected Guest","Echoes Through the Clouds","Temple Intel",
        "The Tyrant Awakens","Beyond the Bubble","Fishman Karate","Pearl of the Deep",
    }
    ADV.SecretQuestAreas={
        "Prison","Prison","Prison","Desert","Desert","Desert","Colosseum","Colosseum",
        "Colosseum","Frozen Village","Frozen Village","Frozen Village","Jungle","Jungle",
        "Jungle","Fountain","Fountain","Fountain","Magma Village","Magma Village",
        "Magma Village","Marine Fortress","Marine Fortress","Marine Fortress","Middle Town",
        "Middle Town","Middle Town","Pirate Village","Pirate Village","Pirate Village",
        "Sky","Sky","Sky","Upper Sky","Upper Sky","Upper Sky","Underwater City",
        "Underwater City","Underwater City",
    }
    -- Game replication, not the static 0/39 labels from the Teddy reference.
    function ADV.SecretQuestProgress()
        local ok,data=STATE.CheckSecretQuestProgress()
        if not ok then
            ADV.Diagnostics.SecretQuest=tostring(data)
            return false,data
        end
        ADV.Diagnostics.SecretQuest="Server data: "..typeof(data)
        return true,data
    end
    function ADV.SecretQuestNavigate()
        if STATE.World~=1 then return false,"Sea 1 is required" end
        if Config.FarmEnabled then return false,"Stop Farm before manual quest travel" end
        local selected=tonumber(Config.SecretQuestIndex) or 1
        selected=math.clamp(math.floor(selected),1,#ADV.SecretQuestNames)
        local area=ADV.SecretQuestAreas[selected]
        local needle=ADV.SecretQuestNames[selected]:lower()
        -- Find exact quest asset first, then a streamed island/area marker.
        local best,cf=nil,nil
        for _,root in ipairs({WS:FindFirstChild("Map"),WS:FindFirstChild("NPCs"),
            WS:FindFirstChild("_WorldOrigin"),WS:FindFirstChild("BonusMoments")}) do
            if root then
                for _,obj in ipairs(root:GetDescendants()) do
                    if obj.Name:lower():find(needle,1,true) then
                        if obj:IsA("BasePart") then best=obj;cf=obj.CFrame;break end
                        if obj:IsA("Model") then best=obj;cf=obj:GetPivot();break end
                    end
                end
            end
            if cf then break end
        end
        if not cf then
            local maps=WS:FindFirstChild("Map")
            local location=maps and maps:FindFirstChild(area,true)
            if location then
                cf=location:IsA("Model") and location:GetPivot() or
                    (location:IsA("BasePart") and location.CFrame or nil)
            end
        end
        if not cf then return false,"Area not streamed: "..tostring(area) end
        local moved=moveTo(cf*CFrame.new(0,8,0))
        if not moved then return false,"Movement lock or current character unavailable" end
        return true,"Travelling: "..ADV.SecretQuestNames[selected].." / "..area
    end
    -- Tools and progression: separate status queries from actual item purchase/combat.
    function ADV.QuestStage(kind)
        local commands={
            Bartilo={"BartiloQuestProgress","Bartilo"}, Saber={"ProQuestProgress","RichSon"},
            Yama={"EliteHunter","Progress"}, CDK={"CDKQuest","Progress"},
            Tushita={"TushitaQuest","Progress"}, RaceV4={"RaceV4Progress","Check"},
            Guitar={"gravestoneEvent",2}, Dragon={"DragonHunter","Check"},
        }
        local args=commands[kind]
        if not args then return false,"Unknown quest" end
        local method=args[1]
        local ok,val=remote(method,args[2])
        if not ok then return false,tostring(val) end
        return true,val
    end
    function ADV.SetProgressMission(kind)
        local target,world=nil,nil
        if kind=="Yama" then target={"Diablo","Deandre","Urban"};world=3
        elseif kind=="Tushita" then target={"Longma"};world=3
        elseif kind=="Soul Guitar" then target=materialMobs.Bones;world=3
        elseif kind=="Dough King" then target={"Cocoa Warrior","Chocolate Bar Battler"};world=3
        elseif kind=="Bartilo" then target={"Swan Pirate"};world=2
        elseif kind=="Race V4" then target={"rip_indra True Form","Dough King"};world=3
        end
        if not target then return false,"Unsupported mission" end
        if world~=STATE.World then return false,"Requires Sea "..world end
        ADV.ProgressTargets=target
        return true,"Selected mission "..kind
    end
    -- Source-derived real FishingRequest sequence (Topi Halloween) with lifecycle guards.
    ADV.Fish={LastCast=0,LastCatch=0,LastBite=0,LastError="None",Request=nil,RemoteBound=false,
        Casts=0,Catches=0,Failures=0}
    local function fishingRequest()
        local fish=RS:FindFirstChild("FishReplicated")
        local req=fish and fish:FindFirstChild("FishingRequest")
        if req and req:IsA("RemoteFunction") then ADV.Fish.Request=req;return req end
        return nil
    end
    local function fishCall(operation,...)
        local req=fishingRequest()
        if not req then return false,"FishingRequest not available" end
        local args=table.pack(...)
        return pcall(function() return req:InvokeServer(operation,table.unpack(args,1,args.n)) end)
    end
    ADV.FishCall=fishCall
    function ADV.BindFishEvents()
        if ADV.Fish.RemoteBound then return true end
        local modules=RS:FindFirstChild("Modules")
        local net=modules and modules:FindFirstChild("Net")
        if not net then return false end
        local remoteEvent=net:FindFirstChild("RE/FishingRemote")
        if not remoteEvent then
            pcall(function()
                local mod=require(net)
                if type(mod)=="table" and type(mod.RemoteEvent)=="function" then
                    remoteEvent=mod:RemoteEvent("FishingRemote",true)
                end
            end)
        end
        if not (remoteEvent and remoteEvent:IsA("RemoteEvent")) then return false end
        on(remoteEvent,remoteEvent.OnClientEvent,function(player,operation)
            if not (STATE.Alive and Config.AutoFish and Config.FishingAutoCatch) then return end
            if player~=LP or operation~="SpawnFishOnBob" then return end
            if os.clock()-ADV.Fish.LastBite<1.5 then return end
            ADV.Fish.LastBite=os.clock()
            task.spawn(function()
                if not (STATE.Alive and Config.AutoFish and Config.FishingAutoCatch) then return end
                task.wait(.2)
                if not (STATE.Alive and Config.AutoFish and Config.FishingAutoCatch) then return end
                local worked=fishCall("Catching",true,{fastBite=true})
                if not worked then ADV.Fish.Failures=ADV.Fish.Failures+1;return end
                task.wait(1.1)
                if not (STATE.Alive and Config.AutoFish and Config.FishingAutoCatch) then return end
                local ok=fishCall("Catch",1,1,1)
                if ok then
                    ADV.Fish.Catches=ADV.Fish.Catches+1
                    ADV.Fish.LastCatch=os.clock()
                    -- Some versions accept the secondary click transition.
                    fishCall("Catch",1,0,1)
                end
            end)
        end)
        ADV.Fish.RemoteBound=true
        return true
    end
    function ADV.CastFishing()
        if Config.FarmEnabled or Config.AutoSea or Config.AutoRaidCombat then return false,"Stop other activities first" end
        local _,hum,root,ready=alive()
        if not ready then return false,"Character not ready" end
        local rod=findRod()
        if not rod then return false,"Fishing rod not found" end
        if rod.Parent~=LP.Character then
            pcall(function() hum:EquipTool(rod) end)
            return false,"Equipping fishing rod"
        end
        local state=rod:GetAttribute("ServerState")
        if state and state~="ReeledIn" and state~="Idle" then
            return false,"Rod currently "..tostring(state)
        end
        if os.clock()-ADV.Fish.LastCast<math.max(2,tonumber(Config.FishingCastDelay) or 5) then
            return false,"Cast cooldown"
        end
        local current=LP:FindFirstChild("Data")
        local fishData=current and current:FindFirstChild("FishingData")
        local bait=fishData and fishData:GetAttribute("SelectedBait")
        if bait=="None" or bait==nil then
            if Config.FishingAutoBait and os.clock()-(ADV.Fish.LastBaitAttempt or 0)>12 then
                ADV.Fish.LastBaitAttempt=os.clock()
                ADV.LoadBait()
            end
            return false,"Fishing bait is not selected"
        end
        if not fishingRequest() then return false,"FishingRequest unavailable" end
        ADV.BindFishEvents()
        local castDistance=math.clamp(tonumber(Config.FishingCastDistance) or 42,15,80)
        local point=root.Position+root.CFrame.LookVector*castDistance
        local fishFolder=RS:FindFirstChild("FishReplicated")
        local util=RS:FindFirstChild("Util")
        local waterModule=util and util:FindFirstChild("GetWaterHeightAtLocation")
        if waterModule then
            pcall(function()
                local fn=require(waterModule)
                if type(fn)=="function" then
                    local water=fn(point)
                    if type(water)=="number" then point=Vector3.new(point.X,water,point.Z) end
                end
            end)
        end
        ADV.Fish.LastCast=os.clock()
        local okStart=fishCall("StartCasting")
        if not okStart then ADV.Fish.Failures=ADV.Fish.Failures+1;return false,"StartCasting failed" end
        task.wait(.2)
        if not STATE.Alive or Config.FarmEnabled then return false,"Cancelled" end
        local okCast,answer=fishCall("CastLineAtLocation",point,98,true)
        if not okCast or answer==false then
            ADV.Fish.Failures=ADV.Fish.Failures+1
            ADV.Fish.LastError="CastLineAtLocation rejected or unsupported"
            return false,ADV.Fish.LastError
        end
        ADV.Fish.Casts=ADV.Fish.Casts+1
        return true,"Line cast at "..tostring(point)
    end
    function ADV.GoSavedFishing()
        if not Config.FishingHasPosition then return false,"No position saved" end
        if Config.FarmEnabled then return false,"Stop farm first" end
        local cf=CFrame.new(Config.FishingX,Config.FishingY,Config.FishingZ)*
            CFrame.Angles(0,math.rad(Config.FishingHeading),0)
        return moveTo(cf),"Fishing position"
    end
    function ADV.SaveFishingPosition()
        local _,_,root,ok=alive()
        if not ok then return false end
        Config.FishingX=root.Position.X;Config.FishingY=root.Position.Y;Config.FishingZ=root.Position.Z
        local _,heading,_=root.CFrame:ToOrientation()
        Config.FishingHeading=math.deg(heading);Config.FishingHasPosition=true
        save();return true
    end
    function ADV.LoadBait()
        local bait=tostring(Config.FishingBait or "Basic Bait")
        local ok,val=remote("LoadItem",bait,{"Usables"})
        return ok,val
    end
    function ADV.FishingSpot()
        local folder=WS:FindFirstChild("ActiveFishingSpots")
        if not folder then return nil end
        local _,_,root,ready=alive()
        if not ready then return nil end
        local best,dist=nil,math.huge
        for _,v in ipairs(folder:GetChildren()) do
            if v.Name=="GoldenVortex" and v:IsA("BasePart") then
                local d=(v.Position-root.Position).Magnitude
                if d<dist then best=v;dist=d end
            end
        end
        return best,dist
    end
    startLoop("Advanced fishing",.85,function()
        if not Config.AutoFish then return end
        if Config.FarmEnabled or Config.AutoSea or Config.AutoRaidCombat then return end
        if Config.FishingUseSaved and Config.FishingHasPosition then
            local _,_,root,ok=alive()
            if not ok then return end
            local goal=Vector3.new(Config.FishingX,Config.FishingY,Config.FishingZ)
            if (root.Position-goal).Magnitude>13 then
                ADV.GoSavedFishing();return
            end
        end
        if Config.FishingGoVortex then
            local vortex,dist=ADV.FishingSpot()
            if vortex and dist>70 then moveTo(CFrame.new(vortex.Position+Vector3.new(0,18,0)));return end
        end
        if Config.FishingAdvanced then
            local ok,why=ADV.CastFishing()
            if not ok and why~="Cast cooldown" and why~="Equipping fishing rod" and
                not tostring(why):find("Rod currently",1,true) and os.clock()-(ADV.Fish.LastLog or 0)>18 then
                ADV.Fish.LastLog=os.clock();slog("Fishing: "..tostring(why),"warn")
            end
        end
    end)
    -- Progression actions run only when clicked; multi-stage auto missions use existing farm.
    function ADV.PresetProgressMission(name)
        local ok,msg=ADV.SetProgressMission(name)
        if not ok then return false,msg end
        if name=="Yama" then
            Config.FarmMode="Elite";Config.AutoQuest=false
        elseif name=="Tushita" then
            Config.FarmMode="Boss";Config.Boss="Longma";Config.AutoQuest=false
        elseif name=="Soul Guitar" then
            Config.FarmMode="Bones";Config.AutoQuest=false
        elseif name=="Dough King" then
            Config.FarmMode="Material";Config.Material="Conjured Cocoa";Config.AutoQuest=false
        elseif name=="Bartilo" then
            Config.FarmMode="Selected mob";Config.Mob="Swan Pirate";Config.AutoQuest=false
        elseif name=="Race V4" then
            Config.FarmMode="Boss";Config.Boss="rip_indra True Form";Config.AutoQuest=false
        end
        Config.Combat=true;Config.AutoEquip=true;Config.FarmEnabled=false
        save();return true,msg.."; press START FARM to begin"
    end
    function ADV.PullLeverStep()
        if STATE.World~=3 then return false,"Requires Sea 3" end
        if Config.FarmEnabled then return false,"Stop farm before lever interaction" end
        local ok,result=remote("RaceV4Progress","Check")
        if not ok then return false,tostring(result) end
        local _,_,root,ready=alive()
        if not ready then return false,"Character not ready" end
        local entrance=CFrame.new(3032,2280,-7325)
        if (root.Position-entrance.Position).Magnitude>28 then
            moveTo(entrance);return false,"Approaching temple; press again when nearby"
        end
        -- Begin is explicit; never invokes chained teleport commands automatically.
        return remote("RaceV4Progress","Begin")
    end
    function ADV.BlueGearLocation()
        local map=WS:FindFirstChild("Map")
        local mystic=map and map:FindFirstChild("MysticIsland")
        if not mystic then return nil end
        for _,v in ipairs(mystic:GetDescendants()) do
            if v:IsA("MeshPart") and v.MeshId=="rbxassetid://10153114969" and v.Transparency<1 then
                return v.CFrame
            end
        end
        return nil
    end
    function ADV.GoBlueGear()
        if STATE.World~=3 then return false,"Sea 3 required" end
        if Config.FarmEnabled then return false,"Stop Farm before travelling" end
        local cf=ADV.BlueGearLocation()
        if not cf then return false,"Blue Gear not streamed or not visible" end
        return moveTo(cf*CFrame.new(0,6,0)),"Moving to Blue Gear"
    end
    -- Event-aware prompt support, never scans every descendant on every heartbeat.
    ADV.Prompt={Scans=0,Attempts=0,Last=0}
    function ADV.FindPrompt(name)
        local _,_,root,ready=alive()
        if not ready then return nil end
        local key=tostring(name or ""):lower()
        local found,d=nil,math.huge
        for _,holder in ipairs({WS:FindFirstChild("Map"),WS:FindFirstChild("PumpkinHunt"),
            WS:FindFirstChild("_WorldOrigin"),WS:FindFirstChild("NPCs")}) do
            if holder then
                for _,v in ipairs(holder:GetDescendants()) do
                    if v:IsA("ProximityPrompt") and v.Enabled then
                        local parent=v.Parent
                        local label=(v.Name.." "..v.ActionText.." "..v.ObjectText.." "..(parent and parent.Name or "")):lower()
                        if label:find(key,1,true) then
                            local obj=parent and (parent:IsA("BasePart") and parent or
                                (parent:IsA("Model") and parent.PrimaryPart or nil))
                            if obj then
                                local dd=(root.Position-obj.Position).Magnitude
                                if dd<d then found=v;d=dd end
                            end
                        end
                    end
                end
            end
        end
        ADV.Prompt.Scans=ADV.Prompt.Scans+1
        return found,d
    end
    function ADV.InteractPrompt(name)
        if Config.FarmEnabled or Config.AutoSea then return false,"Stop combat before interacting" end
        local prompt,dist=ADV.FindPrompt(name)
        if not prompt then return false,"Prompt not loaded: "..tostring(name) end
        if dist>math.max(8,prompt.MaxActivationDistance) then
            local part=prompt.Parent
            if part:IsA("BasePart") then moveTo(part.CFrame*CFrame.new(0,3,0)) end
            return false,"Moving toward prompt"
        end
        local fire=api("fireproximityprompt")
        if not fire then return false,"Executor has no fireproximityprompt; press E manually" end
        local ok,err=pcall(fire,prompt)
        if ok then ADV.Prompt.Attempts=ADV.Prompt.Attempts+1 end
        return ok,err
    end
    -- Diagnostics distinguish a command sent from confirmation of game-side progress.
    function ADV.HealthCheck()
        local notes={}
        local enemies=enemyFolder()
        table.insert(notes,"sea="..tostring(STATE.World))
        table.insert(notes,"enemies="..tostring(enemies and #enemies:GetChildren() or 0))
        local _,_,root,ready=alive()
        table.insert(notes,"char="..tostring(ready))
        local net=getCombatRemotes()
        table.insert(notes,"combat remotes="..tostring(net~=nil))
        local q=questInfo();table.insert(notes,"route="..tostring(q and q.Mob or "none"))
        table.insert(notes,"mover="..tostring(STATE.MoveStats.Status))
        table.insert(notes,"fish request="..tostring(fishingRequest()~=nil))
        local taskMovement=STATE.MovementLock
        table.insert(notes,"movement owner="..tostring(taskMovement and taskMovement.Name or "none"))
        return table.concat(notes," | ")
    end
    -- Sea navigation adapted from the Topi boat-seat movement design.
    -- This can only move a boat whose client has authority; no fake 'success'.
    ADV.Boat={Active=nil,Stats={Started=0,Reached=0,Stopped=0,Rejected=0}}
    function ADV.Boat.Find()
        local folder=WS:FindFirstChild("Boats")
        if not folder then return nil,nil end
        local _,hum,root,ready=alive()
        if not ready then return nil,nil end
        local nearest,seat,best=nil,nil,math.huge
        for _,boat in ipairs(folder:GetChildren()) do
            if boat:IsA("Model") then
                local part=boat:FindFirstChild("VehicleSeat",true)
                if part and part:IsA("VehicleSeat") then
                    if part.Occupant==hum then return boat,part end
                    local owner=boat:FindFirstChild("Owner")
                    local mine=not owner or tostring(owner.Value)==LP.Name or
                        tostring(owner.Value)==tostring(LP.UserId)
                    local d=(root.Position-part.Position).Magnitude
                    if mine and d<best then nearest,seat,best=boat,part,d end
                end
            end
        end
        return nearest,seat
    end
    function ADV.Boat.Stop()
        if ADV.Boat.Active then
            ADV.Boat.Active=nil
            ADV.Boat.Stats.Stopped=ADV.Boat.Stats.Stopped+1
        end
    end
    function ADV.Boat.Start(zone)
        if STATE.World~=3 then return false,"Boat zones require Sea 3" end
        if Config.FarmEnabled then return false,"Stop farm before sailing" end
        local coords=EX.SeaZones[zone or Config.SeaZone]
        if not coords then return false,"Unknown sea zone" end
        local boat,seat=ADV.Boat.Find()
        if not boat or not seat then return false,"No owned boat found; buy and board a boat" end
        local _,hum,root,ready=alive()
        if not ready then return false,"Character not ready" end
        if seat.Occupant~=hum then
            if (root.Position-seat.Position).Magnitude>12 then moveTo(seat.CFrame*CFrame.new(0,3,0))
            else pcall(function() seat:Sit(hum) end) end
            return false,"Boarding boat"
        end
        local destination=Vector3.new(coords[1],math.max(3,seat.Position.Y),coords[3])
        local dist=(seat.Position-destination).Magnitude
        if dist<35 then ADV.Boat.Stop();return true,"Arrived" end
        if ADV.Boat.Active and ADV.Boat.Active.Seat==seat and
            (ADV.Boat.Active.Destination-destination).Magnitude<50 then return true,"Continuing" end
        ADV.Boat.Active={Boat=boat,Seat=seat,Destination=destination,
            Offset=seat.CFrame:ToObjectSpace(boat:GetPivot()),Started=os.clock(),
            Last=seat.Position}
        ADV.Boat.Stats.Started=ADV.Boat.Stats.Started+1
        return true,"Sailing to "..tostring(zone or Config.SeaZone)
    end
    on(Run,Run.Heartbeat,function(dt)
        local state=ADV.Boat.Active
        if not state then return end
        if not (STATE.Alive and Config.AutoSeaBoat and not Config.FarmEnabled) then
            ADV.Boat.Stop();return
        end
        local boat,seat=state.Boat,state.Seat
        local _,hum,root,ready=alive()
        if not (boat and boat.Parent and seat and seat.Parent and ready and seat.Occupant==hum) then
            ADV.Boat.Stop();return
        end
        local delta=state.Destination-seat.Position
        local remaining=delta.Magnitude
        if remaining<28 then
            ADV.Boat.Stats.Reached=ADV.Boat.Stats.Reached+1
            ADV.Boat.Stop();return
        end
        local speed=math.clamp(tonumber(Config.BoatCruiseSpeed) or 170,45,280)
        local step=math.min(remaining,speed*math.min(dt,.075))
        local nextPos=seat.Position+delta.Unit*step
        local cf=CFrame.lookAt(nextPos,Vector3.new(state.Destination.X,nextPos.Y,state.Destination.Z))
        local ok=pcall(function() boat:PivotTo(cf*state.Offset) end)
        if not ok then
            ADV.Boat.Stats.Rejected=ADV.Boat.Stats.Rejected+1
            ADV.Boat.Stop()
        end
    end)
    startLoop("Advanced boat pilot",1.2,function()
        if Config.AutoSeaBoat and not Config.FarmEnabled then
            local ok,why=ADV.Boat.Start(Config.SeaZone)
            if not ok and os.clock()-(ADV.Boat.LastLog or 0)>25 then
                ADV.Boat.LastLog=os.clock();slog("Boat: "..tostring(why),"warn")
            end
        elseif ADV.Boat.Active then ADV.Boat.Stop() end
    end)
end

--// SPOOKY-INSPIRED NON-UI MODULES (independent implementation)
-- No borrowed GUI, no HttpGet / loadstring, no webhook, no external UI library.
do
    local M={Connections={},Status="Idle",Metrics={Attacks=0,HitRequests=0,MacroRuns=0,Targets=0,LastError="-"},
        MacroEpoch=0,MacroRunning=false,LastAttack=0,LastKen=0,LastDungeon=0,LastV4=0,
        RenderObjects=setmetatable({},{__mode="k"}),OriginalHitboxes=setmetatable({},{__mode="k"}),
        OriginalTextures=setmetatable({},{__mode="k"}),OriginalAnimations=setmetatable({},{__mode="k"}),
        OriginalLights={},Character=nil}
    STATE.Spooky=M
    local VIM
    pcall(function() VIM=game:GetService("VirtualInputManager") end)
    local function report(name,err)
        M.Metrics.LastError=name..": "..tostring(err)
        if os.clock()-(M.LastLog or 0)>8 then M.LastLog=os.clock();slog("Spooky port "..M.Metrics.LastError,"warn") end
    end
    local function humanoidRoot(model)
        if not model or not model.Parent then return nil,nil end
        local hum=model:FindFirstChildOfClass("Humanoid")
        local root=model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart
        if hum and root and hum.Health>0 then return hum,root end
    end
    local function isProtected(part)
        local model=part and part:FindFirstAncestorOfClass("Model")
        return model and Players:GetPlayerFromCharacter(model)~=nil
    end
    local function friend(p)
        if not p or p==LP then return true end
        if Config.SpookyTeamCheck and LP.Team and p.Team and LP.Team==p.Team then return true end
        local userId=tostring(p.UserId)
        if Config.SpookyBlacklist~="" and (","..Config.SpookyBlacklist..","):find(","..userId..",",1,true) then return true end
        return false
    end
    local function isSafeZone(p)
        if not Config.SpookySafeZoneCheck or not p then return false end
        local c=p.Character
        if not c then return false end
        if c:FindFirstChild("SafeZone") or c:GetAttribute("SafeZone")==true then return true end
        if p:GetAttribute("InSafeZone")==true then return true end
        return false
    end
    M.ValidPlayer=function(p,limit)
        if friend(p) or isSafeZone(p) then return false end
        if Config.SpookyMinPlayerLevel>0 then
            local data=p:FindFirstChild("Data");local lvl=data and data:FindFirstChild("Level")
            if lvl and lvl.Value<Config.SpookyMinPlayerLevel then return false end
        end
        local _,_,root,ok=alive()
        local hum,other=humanoidRoot(p.Character)
        return ok and root and hum and other and (other.Position-root.Position).Magnitude <= (limit or Config.SpookyTargetRange)
    end
    M.FindPlayer=function()
        local selection=Config.SelectedPlayer
        local chosen=selection~="" and Players:FindFirstChild(selection)
        if chosen and M.ValidPlayer(chosen,Config.SpookyTargetRange) then return chosen end
        if Config.SpookyManualTargetOnly then return nil end
        local _,_,root,ok=alive();if not ok then return nil end
        local best,dist=nil,math.huge
        for _,p in ipairs(Players:GetPlayers()) do
            if M.ValidPlayer(p,Config.SpookyTargetRange) then
                local _,r=humanoidRoot(p.Character)
                local d=(r.Position-root.Position).Magnitude
                if d<dist then best=p;dist=d end
            end
        end
        return best
    end
    M.FindNPC=function(range)
        local enemy=WS:FindFirstChild("Enemies")
        if not enemy then return nil end
        local _,_,root,ok=alive();if not ok then return nil end
        local best,dist=nil,math.huge
        for _,m in ipairs(enemy:GetChildren()) do
            if m:IsA("Model") and not isProtected(m) then
                local hum,r=humanoidRoot(m)
                if hum and r then
                    local d=(r.Position-root.Position).Magnitude
                    if d<dist and d<(range or 120) then best=m;dist=d end
                end
            end
        end
        return best
    end
    local function equippedTool(category)
        local char,hum=alive()
        if not char or not hum then return nil end
        local selected=char:FindFirstChildOfClass("Tool")
        if not category or category=="Equipped" then return selected end
        local name=tostring(category):lower()
        for _,container in ipairs({char,LP:FindFirstChild("Backpack")}) do
            if container then for _,tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    local tooltip=tostring(tool.ToolTip or ""):lower()
                    local label=tool.Name:lower()
                    local match=tooltip==name or label==name
                        or (name=="melee" and (tooltip=="fighting style" or tooltip=="combat" or label=="combat"))
                        or (name=="fruit" and (tooltip=="blox fruit" or tooltip=="fruit" or tooltip=="demon fruit"))
                    if match then
                        if tool.Parent~=char then pcall(function() hum:EquipTool(tool) end) end
                        return tool
                    end
                end
            end end
        end
        return nil
    end
    M.Equip=equippedTool
    M.AttackBurst=function(targetKind)
        if not STATE.Alive then return false end
        local now=os.clock()
        if now-(M.LastAttack or 0)<math.max(.12,tonumber(Config.SpookyAttackDelay) or .18) then return false end
        local char,hum,root,ok=alive();if not ok then return false end
        if char:GetAttribute("isUsingSkill")==true or char:GetAttribute("UsingSkill")==true or char:GetAttribute("Busy")==true then return false end
        local tool=equippedTool("Equipped") or (Config.AutoEquip and equippedTool(Config.Weapon))
        if not tool or tool.Parent~=char then M.Status="Equip a weapon first";return false end
        if tool.ToolTip=="Gun" and targetKind~="Gun" then return false end
        local maxRange=math.clamp(tonumber(Config.SpookyM1Range) or 90,8,150)
        local hits={}
        local function add(model)
            local h,part=humanoidRoot(model)
            if h and part and (part.Position-root.Position).Magnitude<=maxRange then
                table.insert(hits,{model,model:FindFirstChild("Head") or part})
            end
        end
        if targetKind~="Players" then
            local folder=WS:FindFirstChild("Enemies")
            if folder then
                for _,npc in ipairs(folder:GetChildren()) do
                    if #hits>=3 then break end
                    if npc:IsA("Model") and not Players:GetPlayerFromCharacter(npc) then add(npc) end
                end
            end
        end
        if (targetKind=="Players" or targetKind=="Both") and Config.SpookyPVP then
            local p=M.FindPlayer()
            if p then add(p.Character) end
        end
        if #hits==0 then M.Status="No eligible target";return false end
        M.LastAttack=now
        local attack,hitevent=getCombatRemotes() and STATE.CombatRemotes.Attack,STATE.CombatRemotes.Hit
        if tool:FindFirstChild("LeftClickRemote") and tool.LeftClickRemote:IsA("RemoteEvent") then
            local direction=hits[1][2].Position-root.Position
            local okRemote,err=pcall(function()
                tool.LeftClickRemote:FireServer(direction.Magnitude>.05 and direction.Unit or root.CFrame.LookVector,1)
            end)
            if not okRemote then report("LeftClickRemote",err) end
            if okRemote then M.Metrics.Attacks=M.Metrics.Attacks+1 end
            return okRemote
        end
        if not attack or not hitevent then
            M.Status="RegisterAttack/RegisterHit missing"
            return false
        end
        local head=hits[1][2]
        local okRemote,err=pcall(function()
            attack:FireServer(0)
            hitevent:FireServer(head,hits)
        end)
        if not okRemote then report("Attack remote",err) end
        if okRemote then
            M.Metrics.Attacks=M.Metrics.Attacks+1
            M.Metrics.HitRequests=M.Metrics.HitRequests+#hits
            M.Status="Attack request sent / server damage unverified"
        end
        return okRemote
    end
    M.LastGun=0
    M.GunAura=function()
        if os.clock()-M.LastGun<math.max(.15,Config.SpookyAttackDelay) then return end
        local target=Config.SpookyPVP and M.FindPlayer() or M.FindNPC(Config.SpookyTargetRange)
        if not target then return end
        local model=typeof(target)=="Instance" and target:IsA("Player") and target.Character or target
        local _,part=humanoidRoot(model)
        if not part then return end
        local char,_,root,ok=alive();if not ok then return end
        local tool=equippedTool("Gun")
        if not tool then M.Status="Gun not owned";return end
        local rem=tool:FindFirstChild("LeftClickRemote")
        if rem and rem:IsA("RemoteEvent") then
            M.LastGun=os.clock()
            local d=part.Position-root.Position
            pcall(function() rem:FireServer(d.Magnitude>.01 and d.Unit or root.CFrame.LookVector,1) end)
        end
    end
    M.Macro={Token=0,Keys={}}
    M.StopMacro=function()
        M.Macro.Token=M.Macro.Token+1
        M.MacroRunning=false
        for key in pairs(M.Macro.Keys) do
            if VIM then pcall(function() VIM:SendKeyEvent(false,Enum.KeyCode[key],false,game) end) end
            M.Macro.Keys[key]=nil
        end
    end
    local function macroSteps()
        -- format: Melee:Z:0.30,Sword:X:0.25,Fruit:C:0.60,Equipped:M1:0.20
        local result={}
        local active=tostring(Config.SpookyMacroSlot or "1")
        local sequence=Config["SpookyMacroSlot"..active] or Config.SpookyMacroSequence
        for token in tostring(sequence):gmatch("[^,]+") do
            local weapon,key,delay=token:match("^%s*([%w ]+)%s*:%s*([%w]+)%s*:%s*([%d%.]+)%s*$")
            if weapon and key and delay then
                key=key:upper()
                if key=="M1" or key=="Z" or key=="X" or key=="C" or key=="V" or key=="F" then
                    table.insert(result,{Weapon=weapon,Key=key,Delay=math.clamp(tonumber(delay) or .3,.08,2)})
                end
            end
            if #result>=16 then break end
        end
        return result
    end
    M.StartMacro=function()
        if M.MacroRunning then return false end
        local steps=macroSteps()
        if #steps==0 then M.Status="Macro steps invalid";return false end
        local char,hum,_,ok=alive()
        if not ok then return false end
        M.Macro.Token=M.Macro.Token+1
        local token=M.Macro.Token
        M.MacroRunning=true;M.Metrics.MacroRuns=M.Metrics.MacroRuns+1
        task.spawn(function()
            repeat
                for _,step in ipairs(steps) do
                    if not STATE.Alive or not M.MacroRunning or token~=M.Macro.Token or LP.Character~=char or hum.Health<=0 then break end
                    local tool=equippedTool(step.Weapon)
                    if tool and tool.Parent==char then
                        if step.Key=="M1" then pcall(function() tool:Activate() end)
                        elseif VIM and Enum.KeyCode[step.Key] then
                            M.Macro.Keys[step.Key]=true
                            pcall(function() VIM:SendKeyEvent(true,Enum.KeyCode[step.Key],false,game) end)
                            task.wait(.06)
                            pcall(function() VIM:SendKeyEvent(false,Enum.KeyCode[step.Key],false,game) end)
                            M.Macro.Keys[step.Key]=nil
                        end
                    else M.Status="Macro missing: "..step.Weapon end
                    task.wait(step.Delay)
                end
                if not Config.SpookyMacroLoop then break end
            until not STATE.Alive or not M.MacroRunning or token~=M.Macro.Token
            if token==M.Macro.Token then M.StopMacro() end
        end)
        return true
    end
    M.Fly=nil
    M.LastJump=0
    M.UpdateMovement=function()
        local char,hum,root,ok=alive()
        if not ok then return end
        if Config.SpookyWalkSpeed then
            if not M.OriginalSpeed then M.OriginalSpeed=hum.WalkSpeed end
            if hum.WalkSpeed~=Config.SpookySpeed then hum.WalkSpeed=Config.SpookySpeed end
        elseif M.OriginalSpeed then
            hum.WalkSpeed=M.OriginalSpeed;M.OriginalSpeed=nil
        end
        if Config.SpookySuperJump then
            if M.OriginalJumpPower==nil then
                M.OriginalJumpPower=hum.JumpPower
                M.OriginalUseJumpPower=hum.UseJumpPower
            end
            hum.UseJumpPower=true
            hum.JumpPower=Config.SpookyJumpPower
        elseif M.OriginalJumpPower~=nil then
            hum.JumpPower=M.OriginalJumpPower
            if M.OriginalUseJumpPower~=nil then hum.UseJumpPower=M.OriginalUseJumpPower end
            M.OriginalJumpPower=nil;M.OriginalUseJumpPower=nil
        end
        local animator=char:FindFirstChild("Animate")
        if animator then
            if Config.SpookyNoAnimation then
                if M.OriginalAnimate==nil then M.OriginalAnimate=animator.Disabled end
                animator.Disabled=true
            elseif M.OriginalAnimate~=nil then
                animator.Disabled=M.OriginalAnimate
                M.OriginalAnimate=nil
            end
        end
        if Config.SpookyBunnyHop and hum.FloorMaterial~=Enum.Material.Air and os.clock()-M.LastJump>.5 then
            hum.Jump=true;M.LastJump=os.clock()
        end
        if Config.SpookyAntiStun then
            if hum.PlatformStand then hum.PlatformStand=false end
        end
        if Config.SpookyFly and not Config.FarmEnabled and not Config.AutoSeaBoat then
            local body=M.Fly
            if not body or body.Root~=root then
                if body then M.StopFly() end
                local bv=Instance.new("BodyVelocity")
                bv.Name="andepzai_fly_velocity";bv.MaxForce=Vector3.new(1e5,1e5,1e5)
                bv.P=9500;bv.Parent=root
                M.Fly={Root=root,Velocity=bv}
                body=M.Fly
            end
            local camera=WS.CurrentCamera
            local vector=hum.MoveDirection
            if UIS:IsKeyDown(Enum.KeyCode.Space) then vector=vector+Vector3.new(0,1,0) end
            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then vector=vector-Vector3.new(0,1,0) end
            if camera and vector.Magnitude<.05 then vector=Vector3.zero end
            body.Velocity.Velocity=vector.Magnitude>0 and vector.Unit*Config.SpookyFlySpeed or Vector3.zero
        elseif M.Fly then M.StopFly() end
        if Config.SpookyInfiniteZoom then
            if not M.OriginalZoom then M.OriginalZoom=LP.CameraMaxZoomDistance end
            LP.CameraMaxZoomDistance=5000
        elseif M.OriginalZoom then
            LP.CameraMaxZoomDistance=M.OriginalZoom;M.OriginalZoom=nil
        end
    end
    M.StopFly=function()
        if M.Fly then
            if M.Fly.Velocity then pcall(function() M.Fly.Velocity:Destroy() end) end
            M.Fly=nil
        end
    end
    M.ManualDash=function()
        if Config.FarmEnabled then return false end
        local char,hum,root,ok=alive();if not ok then return false end
        local direction=hum.MoveDirection.Magnitude>.05 and hum.MoveDirection.Unit or root.CFrame.LookVector
        local travel=math.clamp(Config.SpookyDashDistance,12,250)
        -- User-initiated short movement burst, uses the existing shared mover.
        return moveTo(CFrame.new(root.Position+direction*travel))
    end
    M.WaterPart=nil
    M.UpdateWater=function()
        if not Config.SpookyWaterWalk then
            if M.WaterPart then M.WaterPart:Destroy();M.WaterPart=nil end
            return
        end
        local _,_,root,ok=alive();if not ok then return end
        if not M.WaterPart then
            M.WaterPart=Instance.new("Part")
            M.WaterPart.Name="andepzai_waterwalk"
            M.WaterPart.Size=Vector3.new(40,1,40);M.WaterPart.Anchored=true
            M.WaterPart.Transparency=1;M.WaterPart.CanCollide=true;M.WaterPart.Parent=WS
        end
        -- Stay below feet; do not put a collision platform over normal land.
        if root.Position.Y<8 then M.WaterPart.CFrame=CFrame.new(root.Position.X,0,root.Position.Z)
        else M.WaterPart.CFrame=CFrame.new(root.Position.X,-10000,root.Position.Z) end
    end
    M.OriginalFov=nil
    M.OriginalFog=nil
    M.OriginalZoom=nil
    M.LastAimTarget=nil
    M.UpdateCamera=function(dt)
        local camera=WS.CurrentCamera
        if not camera then return end
        if Config.SpookyCameraFOVEnabled then
            if M.OriginalFov==nil then M.OriginalFov=camera.FieldOfView end
            camera.FieldOfView=Config.SpookyCameraFOV
        elseif M.OriginalFov then camera.FieldOfView=M.OriginalFov;M.OriginalFov=nil end
        if Config.SpookyCamLock or Config.SpookyAimNPC then
            local target
            if Config.SpookyCamLock then
                local p=M.FindPlayer()
                target=p and p.Character
            else target=M.FindNPC(Config.SpookyTargetRange) end
            local _,part=humanoidRoot(target)
            if part then
                local current=camera.CFrame
                local goal=CFrame.lookAt(current.Position,part.Position+Vector3.new(0,1.5,0))
                camera.CFrame=current:Lerp(goal,math.clamp(Config.SpookyAimSmoothness,0.05,.85))
                M.LastAimTarget=target.Name
            else M.LastAimTarget=nil end
        end
    end
    M.HighlightCache=setmetatable({},{__mode="k"})
    M.UpdateChams=function()
        local show=Config.SpookyPlayerChams or Config.SpookyNPCChams
        if not show then
            for model,highlight in pairs(M.HighlightCache) do
                if highlight then pcall(function() highlight:Destroy() end) end
                M.HighlightCache[model]=nil
            end
            return
        end
        local targets={}
        if Config.SpookyPlayerChams then
            for _,p in ipairs(Players:GetPlayers()) do
                if p~=LP and p.Character then table.insert(targets,p.Character) end
            end
        end
        if Config.SpookyNPCChams then
            local folder=WS:FindFirstChild("Enemies")
            if folder then for _,m in ipairs(folder:GetChildren()) do
                if m:IsA("Model") then table.insert(targets,m) end
                if #targets>70 then break end
            end end
        end
        local live={}
        for _,model in ipairs(targets) do
            local _,root=humanoidRoot(model)
            if root then
                live[model]=true
                local h=M.HighlightCache[model]
                if not h or not h.Parent then
                    h=Instance.new("Highlight")
                    h.Name="andepzai_chams";h.Adornee=model
                    h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
                    h.FillTransparency=.72;h.OutlineTransparency=.13
                    h.Parent=model
                    M.HighlightCache[model]=h
                end
                h.FillColor=Color3.fromRGB(255,255,255)
                h.OutlineColor=Color3.fromRGB(45,45,50)
            end
        end
        for model,h in pairs(M.HighlightCache) do
            if not live[model] or not model.Parent then
                if h then pcall(function() h:Destroy() end) end
                M.HighlightCache[model]=nil
            end
        end
    end
    M.UpdateHitboxes=function()
        if not Config.SpookyHitboxNPC and not Config.SpookyHitboxPVP then
            for part,old in pairs(M.OriginalHitboxes) do
                if part and part.Parent then pcall(function() part.Size=old.Size;part.Transparency=old.Transparency;part.CanCollide=old.CanCollide end) end
                M.OriginalHitboxes[part]=nil
            end
            return
        end
        local targets={}
        if Config.SpookyHitboxNPC then
            local folder=WS:FindFirstChild("Enemies")
            if folder then for _,m in ipairs(folder:GetChildren()) do table.insert(targets,m) end end
        end
        if Config.SpookyHitboxPVP then
            for _,p in ipairs(Players:GetPlayers()) do if M.ValidPlayer(p,250) then table.insert(targets,p.Character) end end
        end
        local _,_,origin,ok=alive();if not ok then return end
        local processed=0
        local current={}
        for _,model in ipairs(targets) do
            if processed>=24 then break end
            local _,root=humanoidRoot(model)
            if root and (origin.Position-root.Position).Magnitude<180 then
                if not M.OriginalHitboxes[root] then
                    M.OriginalHitboxes[root]={Size=root.Size,Transparency=root.Transparency,CanCollide=root.CanCollide}
                end
                current[root]=true
                root.Size=Vector3.new(Config.SpookyHitboxSize,Config.SpookyHitboxSize,Config.SpookyHitboxSize)
                root.Transparency=.75
                root.CanCollide=false
                processed=processed+1
            end
        end
        for root,old in pairs(M.OriginalHitboxes) do
            if not current[root] then
                if root and root.Parent then
                    pcall(function() root.Size=old.Size;root.Transparency=old.Transparency;root.CanCollide=old.CanCollide end)
                end
                M.OriginalHitboxes[root]=nil
            end
        end
    end
    M.GraphicsOriginal={FogEnd=Lighting.FogEnd,GlobalShadows=Lighting.GlobalShadows}
    M.UpdateGraphics=function()
        if Config.SpookyNoFog then Lighting.FogEnd=100000
        else Lighting.FogEnd=M.GraphicsOriginal.FogEnd end
        if Config.SpookyNoShadows then Lighting.GlobalShadows=false
        elseif not Config.AutoFPS and not Config.SpookyLowTextures then Lighting.GlobalShadows=M.GraphicsOriginal.GlobalShadows end
        if Config.SpookyLowTextures then
            local scanned=0
            for _,obj in ipairs(WS:GetDescendants()) do
                if scanned>1500 then break end
                if obj:IsA("Decal") or obj:IsA("Texture") then
                    if M.OriginalTextures[obj]==nil then M.OriginalTextures[obj]=obj.Transparency end
                    obj.Transparency=1
                    scanned=scanned+1
                end
            end
        else
            for obj,old in pairs(M.OriginalTextures) do
                if obj and obj.Parent then pcall(function() obj.Transparency=old end) end
                M.OriginalTextures[obj]=nil
            end
        end
    end
    M.UpdateBounty=function()
        if not Config.SpookyAutoBounty or not Config.SpookyPVP or Config.FarmEnabled then return end
        local target=M.FindPlayer()
        if not target or not target.Character then M.Status="No PvP target available";return end
        if Config.SpookyBountyHPMin>0 then
            local _,hum=alive()
            if hum and hum.MaxHealth>0 and hum.Health/hum.MaxHealth*100<Config.SpookyBountyHPMin then
                M.Status="Low HP / bounty paused";return
            end
        end
        local th,tr=humanoidRoot(target.Character)
        if not th or not tr then return end
        M.Metrics.Targets=M.Metrics.Targets+1
        if Config.SpookyBountyChase then
            moveTo(tr.CFrame*CFrame.new(0,3,7))
        end
        local _,_,root,valid=alive()
        if not valid then return end
        if (tr.Position-root.Position).Magnitude<math.min(Config.SpookyTargetRange,35) then
            local tool=equippedTool(Config.Weapon)
            if tool then pcall(function() tool:Activate() end) end
            if Config.SpookyFastAttack and Config.SpookyPVP then M.AttackBurst("Players") end
        end
    end
    M.UpdateDungeon=function()
        if not Config.SpookyAutoDungeon or Config.FarmEnabled or Config.AutoSeaBoat then return end
        local origin=WS:FindFirstChild("_WorldOrigin")
        local locations=origin and origin:FindFirstChild("Locations")
        if not locations then M.Status="Dungeon island not detected";return end
        local hasIsland=false
        local nextIsland=nil;local idx=0
        for _,o in ipairs(locations:GetChildren()) do
            local number=tonumber(o.Name:match("^Island%s*(%d+)$"))
            if number then
                hasIsland=true
                if number>idx then idx=number;nextIsland=o end
            end
        end
        if not hasIsland then M.Status="No dungeon active";return end
        local npc=M.FindNPC(2500)
        if npc then
            local _,r=humanoidRoot(npc)
            if r then
                local _,_,root,ok=alive()
                if ok and (root.Position-r.Position).Magnitude>Config.SpookyDungeonHeight then
                    moveTo(r.CFrame*CFrame.new(0,Config.SpookyDungeonHeight,0))
                end
                local tool=equippedTool(Config.Weapon)
                if tool then pcall(function() tool:Activate() end) end
                if Config.SpookyFastAttack then M.AttackBurst("NPC") end
            end
        elseif nextIsland then
            local pos=nextIsland:IsA("BasePart") and nextIsland.Position or nextIsland:GetPivot().Position
            moveTo(CFrame.new(pos+Vector3.new(0,18,0)))
        end
    end
    M.StopAll=function()
        Config.SpookyAutoBounty=false;Config.SpookyAutoDungeon=false
        Config.SpookyFastAttack=false;Config.SpookyM1Extender=false;Config.SpookyGunAura=false
        Config.SpookyCamLock=false;Config.SpookyAimNPC=false;Config.SpookyPVP=false
        Config.SpookyFly=false;Config.SpookyBunnyHop=false;Config.SpookyWaterWalk=false
        Config.SpookySuperJump=false;Config.SpookyNoAnimation=false
        Config.SpookyHitboxNPC=false;Config.SpookyHitboxPVP=false
        Config.SpookyPlayerChams=false;Config.SpookyNPCChams=false
        Config.SpookyLowTextures=false;Config.SpookyNoFog=false;Config.SpookyNoShadows=false
        Config.SpookyWalkSpeed=false;Config.SpookyCameraFOVEnabled=false;Config.SpookyInfiniteZoom=false
        if M.OriginalSpeed then
            local _,hum=alive();if hum then hum.WalkSpeed=M.OriginalSpeed end
            M.OriginalSpeed=nil
        end
        M.StopMacro();M.StopFly();M.UpdateHitboxes();M.UpdateChams();M.UpdateWater();M.UpdateGraphics()
        local char,hum=alive()
        if hum and M.OriginalJumpPower~=nil then
            hum.JumpPower=M.OriginalJumpPower
            if M.OriginalUseJumpPower~=nil then hum.UseJumpPower=M.OriginalUseJumpPower end
            M.OriginalJumpPower=nil;M.OriginalUseJumpPower=nil
        end
        local anim=char and char:FindFirstChild("Animate")
        if anim and M.OriginalAnimate~=nil then anim.Disabled=M.OriginalAnimate;M.OriginalAnimate=nil end
        if M.OriginalFov and WS.CurrentCamera then WS.CurrentCamera.FieldOfView=M.OriginalFov;M.OriginalFov=nil end
        if M.OriginalZoom then LP.CameraMaxZoomDistance=M.OriginalZoom;M.OriginalZoom=nil end
        -- Sync all newly exposed controls after STOP ALL / unload.
        if STATE.ControlBindings then
            for key,callbacks in pairs(STATE.ControlBindings) do
                if tostring(key):match("^Spooky") then
                    for _,callback in ipairs(callbacks) do pcall(callback,Config[key]) end
                end
            end
        end
        M.Status="Stopped"
    end
    M.Destroy=function()
        M.StopAll()
    end
    -- Opt-in jobs share andepzai lifecycle and are never launched by default flags.
    startLoop("Spooky PvE / skills",.22,function()
        if (Config.SpookyFastAttack or Config.SpookyM1Extender) and not Config.FarmEnabled then M.AttackBurst("NPC") end
        if Config.SpookyGunAura and not Config.FarmEnabled then M.GunAura() end
    end)
    startLoop("Spooky dungeon",.35,function() M.UpdateDungeon() end)
    startLoop("Spooky bounty",.45,function() M.UpdateBounty() end)
    startLoop("Spooky movement",.14,function() M.UpdateMovement();M.UpdateWater() end)
    startLoop("Spooky visuals",1.2,function()
        M.UpdateChams()
        M.UpdateHitboxes()
    end)
    startLoop("Spooky graphics",5,function()
        if Config.SpookyLowTextures or Config.SpookyNoFog or Config.SpookyNoShadows then M.UpdateGraphics() end
    end)
    on(Run,Run.RenderStepped,function(dt)
        if not STATE.Alive then return end
        if Config.SpookyCamLock or Config.SpookyAimNPC or Config.SpookyCameraFOVEnabled then
            local ok,err=pcall(M.UpdateCamera,dt)
            if not ok then report("Camera",err) end
        elseif M.OriginalFov then
            local camera=WS.CurrentCamera
            if camera then camera.FieldOfView=M.OriginalFov end
            M.OriginalFov=nil
        end
    end)
    on(LP,LP.CharacterRemoving,function() M.StopFly();M.StopMacro() end)
end

--// SPOOKY VISUAL/CHARACTER FEATURES — opt-in, local-only, reversible when possible.
do
    local M=STATE.Spooky
    M.Tracers=setmetatable({},{__mode="k"})
    M.OriginalCharProps=setmetatable({},{__mode="k"})
    M.SavedScale=setmetatable({},{__mode="k"})
    M.SavedLighting={ClockTime=Lighting.ClockTime}
    M.VfxNodes={}
    M.LastTracer=0
    M.ClearTracers=function()
        for target,beam in pairs(M.Tracers) do
            if beam then
                pcall(function() if beam.Beam then beam.Beam:Destroy() end end)
                pcall(function() if beam.From then beam.From:Destroy() end end)
                pcall(function() if beam.To then beam.To:Destroy() end end)
            end
            M.Tracers[target]=nil
        end
    end
    M.UpdateTracers=function()
        if not Config.SpookyTracers then M.ClearTracers();return end
        local _,_,meRoot,ok=alive();if not ok then M.ClearTracers();return end
        local live={}
        local nearby={}
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then
                local _,root=humanoidRoot(p.Character)
                if root and (root.Position-meRoot.Position).Magnitude<Config.SpookyTargetRange*3 then
                    table.insert(nearby,{root=root,distance=(root.Position-meRoot.Position).Magnitude})
                end
            end
        end
        table.sort(nearby,function(a,b)return a.distance<b.distance end)
        for i=1,math.min(12,#nearby) do
            local toRoot=nearby[i].root
            live[toRoot]=true
            local obj=M.Tracers[toRoot]
            if not obj or not obj.Beam or not obj.Beam.Parent or obj.From.Parent~=meRoot then
                if obj then
                    for _,inst in pairs(obj) do pcall(function() inst:Destroy() end) end
                end
                local a0=Instance.new("Attachment")
                a0.Name="andepzai_tracer_origin";a0.Parent=meRoot
                local a1=Instance.new("Attachment")
                a1.Name="andepzai_tracer_target";a1.Parent=toRoot
                local b=Instance.new("Beam")
                b.Name="andepzai_tracer";b.Attachment0=a0;b.Attachment1=a1
                b.Width0=.045;b.Width1=.045;b.FaceCamera=true
                b.Color=ColorSequence.new(Color3.fromRGB(245,245,245),Color3.fromRGB(110,110,120))
                b.Transparency=NumberSequence.new(.4);b.Parent=meRoot
                obj={From=a0,To=a1,Beam=b};M.Tracers[toRoot]=obj
            end
        end
        for target,obj in pairs(M.Tracers) do
            if not live[target] or not target.Parent then
                for _,inst in pairs(obj) do pcall(function() inst:Destroy() end) end
                M.Tracers[target]=nil
            end
        end
    end
    M.UpdateAvatar=function()
        local char,hum,_,ok=alive();if not ok then return end
        local head=char:FindFirstChild("Head")
        if head and head:IsA("BasePart") then
            if Config.SpookyHeadlessLocal then
                if M.OriginalCharProps[head]==nil then M.OriginalCharProps[head]=head.LocalTransparencyModifier end
                head.LocalTransparencyModifier=1
            elseif M.OriginalCharProps[head]~=nil then
                head.LocalTransparencyModifier=M.OriginalCharProps[head]
                M.OriginalCharProps[head]=nil
            end
        end
        for _,acc in ipairs(char:GetChildren()) do
            if acc:IsA("Accessory") then
                local handle=acc:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    if Config.SpookyAccessoryNoclip then
                        if M.OriginalCharProps[handle]==nil then M.OriginalCharProps[handle]=handle.CanCollide end
                        handle.CanCollide=false
                    elseif M.OriginalCharProps[handle]~=nil then
                        handle.CanCollide=M.OriginalCharProps[handle]
                        M.OriginalCharProps[handle]=nil
                    end
                end
            end
        end
        local bodyNames={"BodyHeightScale","BodyWidthScale","BodyDepthScale","HeadScale"}
        for _,name in ipairs(bodyNames) do
            local scale=hum:FindFirstChild(name)
            if scale and scale:IsA("NumberValue") then
                if Config.SpookyGiantLocal then
                    if M.SavedScale[scale]==nil then M.SavedScale[scale]=scale.Value end
                    scale.Value=math.clamp(Config.SpookyGiantScale,1,3)
                elseif M.SavedScale[scale]~=nil then
                    scale.Value=M.SavedScale[scale];M.SavedScale[scale]=nil
                end
            end
        end
    end
    M.UpdateExtrasGraphics=function()
        local effect=Config.SpookyShader
        if effect and #M.VfxNodes==0 then
            local cc=Instance.new("ColorCorrectionEffect")
            cc.Name="andepzai_optional_shader";cc.Brightness=.025;cc.Contrast=.10;cc.Saturation=.08
            cc.Parent=Lighting
            local bloom=Instance.new("BloomEffect")
            bloom.Name="andepzai_optional_bloom";bloom.Intensity=.22;bloom.Size=14;bloom.Threshold=1.4
            bloom.Parent=Lighting
            table.insert(M.VfxNodes,cc);table.insert(M.VfxNodes,bloom)
        elseif not effect then
            for _,node in ipairs(M.VfxNodes) do pcall(function() node:Destroy() end) end
            table.clear(M.VfxNodes)
        end
        if Config.SpookyTimeOverride then Lighting.ClockTime=Config.SpookyClockTime
        else Lighting.ClockTime=M.SavedLighting.ClockTime end
    end
    M.UpdateRainbow=function()
        if not Config.SpookyRainbowChams then return end
        local rgb=Color3.fromHSV((os.clock()*.08)%1,.65,1)
        for _,h in pairs(M.HighlightCache) do
            if h and h.Parent then h.OutlineColor=rgb;h.FillColor=rgb end
        end
    end
    M.StopExtras=function()
        for _,key in ipairs({"SpookyTracers","SpookyRainbowChams","SpookyHeadlessLocal","SpookyAccessoryNoclip",
            "SpookyGiantLocal","SpookyShader","SpookyTimeOverride"}) do Config[key]=false end
        M.ClearTracers()
        for part,original in pairs(M.OriginalCharProps) do
            if part and part.Parent then
                if part.Name=="Head" then pcall(function() part.LocalTransparencyModifier=original end)
                else pcall(function() part.CanCollide=original end) end
            end
            M.OriginalCharProps[part]=nil
        end
        for node,old in pairs(M.SavedScale) do
            if node and node.Parent then pcall(function() node.Value=old end) end
            M.SavedScale[node]=nil
        end
        M.UpdateExtrasGraphics()
    end
    local oldStop=M.StopAll
    M.StopAll=function()
        oldStop()
        M.StopExtras()
    end
    startLoop("Spooky tracer and avatar",1.0,function()
        if Config.SpookyTracers then M.UpdateTracers() end
        if Config.SpookyHeadlessLocal or Config.SpookyAccessoryNoclip or Config.SpookyGiantLocal then M.UpdateAvatar() end
        if Config.SpookyRainbowChams then M.UpdateRainbow() end
    end)
    startLoop("Spooky shader and clock",2.5,function()
        if Config.SpookyShader or Config.SpookyTimeOverride then M.UpdateExtrasGraphics() end
    end)
end

--// CRYSTAL WHITE LIQUID GLASS DESIGN SYSTEM ------------------------------------------
--// CRYSTAL WHITE DESIGN TOKENS (all glass panes are neutral white)
local C={
    BG=Color3.fromRGB(255,255,255), Panel=Color3.fromRGB(255,255,255),
    Row=Color3.fromRGB(255,255,255), RowHover=Color3.fromRGB(249,249,251),
    Glass=Color3.fromRGB(250,250,252), Border=Color3.fromRGB(255,255,255),
    Text=Color3.fromRGB(27,29,34), Muted=Color3.fromRGB(69,72,78),
    Quiet=Color3.fromRGB(103,107,113), Green=Color3.fromRGB(41,92,73),
    Red=Color3.fromRGB(150,42,50), Orange=Color3.fromRGB(141,95,38),
    White=Color3.fromRGB(255,255,255), Accent=Color3.fromRGB(46,49,54),
    Icon=Color3.fromRGB(50,52,58), Purple=Color3.fromRGB(111,112,117)
}
-- Tint here only affects monochrome accents/ink; the glass remains white.
local themes={
    Crystal=Color3.fromRGB(45,48,54),
    Pearl=Color3.fromRGB(68,70,75),
    Frost=Color3.fromRGB(84,87,92),
    Cloud=Color3.fromRGB(58,61,66),
    Silver=Color3.fromRGB(107,110,115),
    Quartz=Color3.fromRGB(77,80,85),
    Opal=Color3.fromRGB(32,34,38)
}
if not themes[Config.Accent] then Config.Accent="Crystal" end
C.Accent=themes[Config.Accent]
local themeItems={}
local glassItems=setmetatable({}, {__mode="k"})
local spectrumItems={}
local updateGlass
local updateBackdrop
STATE.ControlBindings={}
local function setFlag(key,value)
    Config[key]=value
    if value==true and (key=="AutoChest" or key=="AutoBerry" or key=="AutoMagnetToken" or
        key=="AutoCollectFruit" or key=="HalloweenPumpkins" or key=="AutoEventCollect") then
        if STATE.Pickups then STATE.Pickups.Reset() end
        if not Config.FarmEnabled then cancelMove() end
        for _,other in ipairs({"AutoChest","AutoBerry","AutoMagnetToken","AutoCollectFruit","HalloweenPumpkins","AutoEventCollect"}) do
            if other~=key then
                Config[other]=false
                for _,redraw in ipairs(STATE.ControlBindings[other] or {}) do pcall(redraw,false) end
            end
        end
    end
    local fn=STATE.ControlBindings[key]
    if fn then for _,redraw in ipairs(fn) do redraw(value) end end
    if key=="FarmEnabled" and not value then
        cancelMove();if STATE.ReleaseFarmHover then STATE.ReleaseFarmHover() end
        if STATE.MobMagnet then STATE.MobMagnet.Stop() end
        if STATE.NPCFilter then STATE.NPCFilter.Held=nil end
    end
    if key=="MobMagnet" and not value and STATE.MobMagnet then STATE.MobMagnet.Stop() end
    if (key=="AutoChest" or key=="AutoBerry" or key=="AutoMagnetToken") and not value and STATE.Pickups then
        STATE.Pickups.Reset()
        if not Config.FarmEnabled and not Config.AutoChest and not Config.AutoBerry and
           not Config.AutoMagnetToken and not Config.AutoCollectFruit and
           not Config.HalloweenPumpkins and not Config.AutoEventCollect then
            cancelMove()
        end
    end
    if (key=="FarmStyle" and value~="Above") or (key=="FarmHoverLock" and not value) then
        if STATE.ReleaseFarmHover then STATE.ReleaseFarmHover() end
    end
    if (key=="SpookyAutoBounty" or key=="SpookyAutoDungeon") and not value and not Config.FarmEnabled then cancelMove() end
    if key=="HalloweenPumpkins" and not value and not Config.FarmEnabled then cancelMove() end
    if key=="AutoSeaBoat" and not value and STATE.Advanced then STATE.Advanced.Boat.Stop() end
    if (key=="GlassIntensity" or key=="HighContrast") and updateGlass then updateGlass() end
    if (key=="BackgroundBlur" or key=="BlurStrength") and updateBackdrop then updateBackdrop() end
    if key=="SoftGlow" and STATE.Glow then STATE.Glow.Visible=value end
    if STATE.Spooky and (key=="SpookyPlayerChams" or key=="SpookyNPCChams") then STATE.Spooky.UpdateChams() end
    if STATE.Spooky and (key=="SpookyHitboxNPC" or key=="SpookyHitboxPVP") then STATE.Spooky.UpdateHitboxes() end
    if key=="AutoFullBright" and STATE.Unified and STATE.Unified.ApplyFullBright then STATE.Unified.ApplyFullBright() end
    if STATE.Spooky and (key=="SpookyShader" or key=="SpookyTimeOverride")
        and STATE.Spooky.UpdateExtrasGraphics then STATE.Spooky.UpdateExtrasGraphics() end
    if STATE.Spooky and (key=="SpookyTracers" or key=="SpookyGiantLocal" or key=="SpookyHeadlessLocal" or key=="SpookyAccessoryNoclip") then
        if key=="SpookyTracers" and not value then STATE.Spooky.ClearTracers() end
        if STATE.Spooky.UpdateAvatar then STATE.Spooky.UpdateAvatar() end
    end
    if key=="AutoFPS" and STATE.Unified and STATE.Unified.ApplyFPS then STATE.Unified.ApplyFPS() end
    if (key=="SpookyNoFog" or key=="SpookyNoShadows" or key=="SpookyLowTextures")
        and STATE.Spooky then STATE.Spooky.UpdateGraphics() end
    save()
end
STATE.StopAll=function()
    Config.FarmEnabled=false
    for key,v in pairs(defaults) do
        if type(v)=="boolean" and (key:match("^Auto") or key=="HalloweenPumpkins") then
            Config[key]=false
            local bindings=STATE.ControlBindings[key]
            if bindings then
                for _,redraw in ipairs(bindings) do pcall(redraw,false) end
            end
        end
    end
    for _,redraw in ipairs(STATE.ControlBindings.FarmEnabled or {}) do pcall(redraw,false) end
    cancelMove()
    if STATE.ReleaseFarmHover then STATE.ReleaseFarmHover() end
    if STATE.MobMagnet then STATE.MobMagnet.Stop() end
    if STATE.NPCFilter then STATE.NPCFilter.Held=nil end
    if STATE.Advanced and STATE.Advanced.Boat then STATE.Advanced.Boat.Stop() end
    if STATE.Unified then
        if STATE.Unified.ApplyFPS then pcall(STATE.Unified.ApplyFPS) end
        if STATE.Unified.ApplyFullBright then pcall(STATE.Unified.ApplyFullBright) end
    end
    if STATE.Spooky then STATE.Spooky.StopAll() end
    save()
    notice("Safety","All automatic jobs disabled")
end
-- Ready-to-run configurations modeled on the submitted hub defaults.
-- Setting a profile only arms the engine: it NEVER starts any auto activity.
STATE.ApplyReadyPreset=function(mode)
    local patch={
        AutoQuest=true,Combat=true,AutoEquip=true,AutoHaki=true,Noclip=true,
        FastAttackEnabled=true,CombatMode="Adaptive",AttackRange=32,
        FarmDistance=5,FarmHeight=18,FarmStyle="Above",FarmHoverLock=true,SafeFarm=false,
        TweenSpeed=350,MovementMode="Proxy Tween",SmartPortal=false,
        MoveRetargetThreshold=5,MoveRetargetDelay=0.35,
        AttackDelay=0.20,QuestDelay=4,
        AutoAbandonWrongQuest=false,AutoSkill=false,
    }
    if mode=="Boss" then
        patch.FarmMode="Boss";patch.AutoQuest=false
        if type(bossDB[STATE.World])=="table" and not table.find(bossDB[STATE.World],Config.Boss) then
            patch.Boss=bossDB[STATE.World][1]
        end
    elseif mode=="Material" then
        patch.FarmMode="Material";patch.AutoQuest=false
    elseif mode=="Mastery" then
        patch.FarmMode="Mastery";patch.AutoQuest=false
    else
        patch.FarmMode="Level";patch.AutoQuest=true
    end
    -- Preserve independent activity switches: Fruit, Raid, Sea, Event, Server etc.
    for key,value in pairs(patch) do
        Config[key]=value
        local redraws=STATE.ControlBindings[key]
        if redraws then for _,redraw in ipairs(redraws) do redraw(value) end end
    end
    if Config.FarmEnabled then cancelMove() end
    save()
    notice("Ready preset",tostring(patch.FarmMode).." configured. Start/Stop remains manual.")
    return patch.FarmMode
end
local function mk(class,props,parent)
    local node=Instance.new(class)
    for property,value in pairs(props or {}) do node[property]=value end
    node.Parent=parent
    return node
end
local function round(parent,r) return mk("UICorner",{CornerRadius=UDim.new(0,r or 12)},parent) end
local function stroke(parent,color,trans,size)
    return mk("UIStroke",{Color=color or C.Border,Transparency=trans or 0,Thickness=size or 1},parent)
end
local function themed(node,key)
    table.insert(themeItems,{obj=node,key=key})
    return node
end
local function animate(obj,props,d)
    if Config.ReducedMotion then
        for k,v in pairs(props) do pcall(function() obj[k]=v end) end
        return
    end
    local ok=pcall(function()
        Tween:Create(obj,TweenInfo.new(d or .22,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),props):Play()
    end)
    if not ok then for k,v in pairs(props) do pcall(function() obj[k]=v end) end end
end
local function themeSelect(name)
    local accent=themes[name]
    if not accent then return end
    Config.Accent=name;C.Accent=accent
    for _,item in ipairs(themeItems) do
        if item.obj and item.obj.Parent then animate(item.obj,{[item.key]=accent},.26) end
    end
    for _,grad in ipairs(spectrumItems) do
        if grad.Parent then
            grad.Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,Color3.fromRGB(228,228,230)),
                ColorSequenceKeypoint.new(.48,Color3.fromRGB(255,255,255)),
                ColorSequenceKeypoint.new(1,Color3.fromRGB(228,228,230))})
        end
    end
    if updateGlass then updateGlass() end
    save()
end
local function txt(parent,text,size,color,font)
    return mk("TextLabel",{BackgroundTransparency=1,Text=text or "",TextColor3=color or C.Text,
        Font=font or Enum.Font.Gotham,TextSize=size or 12,TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true,BorderSizePixel=0},parent)
end
-- Detailed hand-built 24x24 line icons, using only Roblox native GUI primitives.
-- Stroke/lines are static (no tween per segment) and share monochrome ink.
local function vectorIcon(parent,id,offset,size)
    -- Each high-level page has a dedicated monochrome vector mark, no asset downloads.
    id=({integrated="unified",fishingpro="fishing",secret39="quests",
        progressplus="progress",seapilot="sea",diagnosticspro="toolplus",
        spookycombat="crosshair",spookypvp="duel",spookymacro="macro",
        spookymovement="wing",spookyvisual="eyeplus",spookydungeon="dungeon",
        halloween="ghost",seapilot="ship",events="spark",spookyextras="spark"})[id] or id
    local holder=mk("Frame",{Name="Icon_"..tostring(id),BackgroundTransparency=1,
        Position=offset or UDim2.fromOffset(0,0),Size=UDim2.fromOffset(size or 24,size or 24)},parent)
    local scale=mk("UIScale",{Scale=(size or 24)/24},holder)
    holder.Size=UDim2.fromOffset(24,24)
    local ink=C.Icon
    local function bar(x,y,w,h,a)
        local e=mk("Frame",{BackgroundColor3=ink,BorderSizePixel=0,
            Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),Rotation=a or 0},holder)
        round(e,99);return e
    end
    local function line(x,y,x2,y2,t)
        local dx,dy=x2-x,y2-y
        local len=math.sqrt(dx*dx+dy*dy)
        return bar((x+x2-len)/2,(y+y2-(t or 2))/2,len,t or 2,math.deg(math.atan2(dy,dx)))
    end
    local function ring(x,y,w,h,r)
        local e=mk("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(x,y),
            Size=UDim2.fromOffset(w,h),Rotation=r or 0},holder)
        round(e,math.min(w,h)/2)
        stroke(e,ink,0,1.7)
        return e
    end
    local function circle(x,y,r)
        local e=bar(x-r,y-r,r*2,r*2,0);round(e,99);return e
    end
    local function rect(x,y,w,h)
        local e=mk("Frame",{BackgroundTransparency=1,Position=UDim2.fromOffset(x,y),
            Size=UDim2.fromOffset(w,h)},holder)
        round(e,4);stroke(e,ink,0,1.7);return e
    end
    if id=="logo" then
        line(5,20,12,3,2.6);line(12,3,19,20,2.6);bar(8,14,8,2.4)
    elseif id=="home" then
        line(4,11,12,4);line(12,4,20,11);rect(6,10,12,10);bar(11,14,3,6)
    elseif id=="farm" then
        ring(7,4,11,15,-35);line(8,19,18,7);line(9,14,14,16)
    elseif id=="boss" then
        line(4,7,7,17);line(7,17,17,17);line(17,17,20,7)
        line(4,7,10,12);line(10,12,12,5);line(12,5,15,12);line(15,12,20,7)
        bar(7,19,10,2)
    elseif id=="materials" then
        rect(6,6,12,12);line(6,12,12,6);line(12,6,18,12);line(18,12,12,18);line(12,18,6,12)
    elseif id=="fruits" then
        ring(5,8,14,13);bar(12,4,2,5,-16);ring(13,3,7,4,-28)
    elseif id=="raid" then
        rect(6,4,12,14);line(6,14,12,21);line(12,21,18,14);bar(11,8,2,7);bar(8,11,8,2)
    elseif id=="sea" then
        for y=7,16,5 do line(4,y,9,y-2);line(9,y-2,15,y);line(15,y,20,y-2) end
    elseif id=="fishing" then
        line(7,3,16,3);line(16,3,16,15);ring(10,12,8,8);bar(8,13,5,2)
    elseif id=="quests" then
        rect(6,3,13,18);bar(9,7,3,2);bar(14,7,3,2);bar(9,12,3,2);bar(14,12,3,2);bar(9,17,8,2)
    elseif id=="race" then
        line(4,17,10,7);line(10,7,20,6);line(4,17,17,12);line(4,17,17,17)
    elseif id=="combat" then
        line(5,5,19,19);line(19,5,5,19);bar(3,15,7,2,45);bar(15,15,7,2,-45)
    elseif id=="travel" then
        ring(5,3,14,14);circle(12,10,3);line(6,17,12,22);line(12,22,18,17)
    elseif id=="esp" then
        ring(4,8,16,9);circle(12,12.5,3);line(4,10,8,7);line(16,7,20,10)
    elseif id=="shop" then
        rect(5,8,14,13);ring(9,4,6,8);bar(5,10,14,2)
    elseif id=="server" then
        rect(4,4,16,7);rect(4,14,16,7);circle(7,7.5,1.4);circle(7,17.5,1.4);bar(12,7,5,2);bar(12,17,5,2)
    elseif id=="settings" then
        ring(8,8,8,8)
        for a=0,315,45 do
            local theta=math.rad(a)
            local x=12+math.cos(theta)*8;local y=12+math.sin(theta)*8
            bar(x-2,y-1,4,2,a)
        end
    elseif id=="unified" then
        ring(4,4,16,16);circle(12,12,3);line(12,3,12,8);line(12,16,12,21);line(3,12,8,12);line(16,12,21,12)
    elseif id=="specialboss" then
        ring(4,4,16,16);line(7,8,12,5);line(12,5,17,8);line(8,15,12,19);line(12,19,16,15);bar(10,11,4,2)
    elseif id=="events" then
        line(4,16,9,8);line(9,8,13,14);line(13,14,17,6);line(17,6,21,17);bar(4,20,17,2)
    elseif id=="progress" then
        rect(5,5,14,15);circle(12,9,2);bar(8,13,8,2);bar(8,17,6,2)
    elseif id=="craft" then
        line(5,6,17,19);line(17,6,5,19);circle(5,6,2);circle(18,6,2);circle(5,19,2);circle(18,19,2)
    elseif id=="extras" then
        ring(4,4,16,16);bar(11,7,2,10);bar(8,11,8,2);circle(20,4,1.7)
    elseif id=="toolplus" then
        rect(5,4,14,16);bar(8,8,8,2);bar(8,12,8,2);bar(8,16,5,2)
    elseif id=="crosshair" then
        ring(5,5,14,14);ring(9,9,6,6);line(12,1,12,7);line(12,17,12,23)
        line(1,12,7,12);line(17,12,23,12)
    elseif id=="duel" then
        line(4,3,17,18,2.1);line(20,3,7,18,2.1)
        line(4,3,8,4);line(20,3,16,4);bar(3,16,8,2,42);bar(13,16,8,2,-42)
    elseif id=="macro" then
        rect(3,4,18,16);bar(6,8,3,3);bar(11,8,3,3);bar(16,8,2,3)
        bar(7,14,10,2);bar(19,14,2,2)
    elseif id=="wing" then
        line(3,17,8,8);line(8,8,12,12);line(12,12,20,3)
        line(4,21,12,15);line(12,15,20,17);line(20,17,22,12)
    elseif id=="eyeplus" then
        line(3,12,8,7);line(8,7,16,7);line(16,7,21,12)
        line(3,12,8,17);line(8,17,16,17);line(16,17,21,12)
        ring(9,9,6,6);circle(12,12,1.4)
    elseif id=="dungeon" then
        rect(5,4,14,17);bar(9,7,6,2);line(12,9,12,18)
        bar(6,18,12,2);bar(10,13,4,2)
    elseif id=="ghost" then
        ring(5,3,14,17);bar(5,11,14,8);circle(9,11,1.4);circle(15,11,1.4)
        line(5,20,9,17);line(9,17,12,20);line(12,20,15,17);line(15,17,19,20)
    elseif id=="ship" then
        line(3,16,21,16);line(6,17,9,21);line(9,21,17,21);line(17,21,20,17)
        bar(11,3,2,13);line(11,5,5,14);line(5,14,11,14);line(13,6,19,14)
    elseif id=="search" then
        ring(3,3,13,13);line(15,15,21,21)
    elseif id=="check" then
        line(4,12,10,18,2.4);line(10,18,20,5,2.4)
    elseif id=="chevron" then
        line(7,10,12,15,2);line(12,15,17,10,2)
    elseif id=="arrow" then
        line(5,12,19,12,2);line(13,6,19,12,2);line(19,12,13,18,2)
    elseif id=="play" then
        line(7,4,18,12,2);line(18,12,7,20,2);line(7,20,7,4,2)
    elseif id=="x" then
        line(5,5,19,19,2.1);line(19,5,5,19,2.1)
    elseif id=="minus" then
        bar(5,11,14,2.2)
    elseif id=="save" then
        rect(4,4,16,16);rect(8,5,8,5);bar(8,15,8,3)
    elseif id=="shield" then
        line(12,3,20,7);line(20,7,18,17);line(18,17,12,21)
        line(12,21,6,17);line(6,17,4,7);line(4,7,12,3)
    elseif id=="clock" then
        ring(3,3,18,18);line(12,6,12,12);line(12,12,17,15)
    elseif id=="target" then
        ring(3,3,18,18);ring(7,7,10,10);circle(12,12,2)
    elseif id=="chest" then
        rect(3,9,18,12);line(3,10,12,5);line(12,5,21,10);bar(10,12,4,4)
    elseif id=="spark" then
        line(12,2,12,22);line(2,12,22,12);line(5,5,19,19);line(19,5,5,19)
    elseif id=="map" then
        line(4,6,10,4);line(10,4,16,7);line(16,7,20,5)
        line(4,6,4,19);line(4,19,10,17);line(10,17,16,20);line(16,20,20,18)
        line(10,4,10,17);line(16,7,16,20)
    elseif id=="info" then
        ring(3,3,18,18);circle(12,7,1.3);bar(11,10,2,8)
    elseif id=="sliders" then
        line(4,6,20,6);line(4,12,20,12);line(4,18,20,18)
        circle(9,6,2.5);circle(16,12,2.5);circle(8,18,2.5)
    elseif id=="bolt" then
        line(13,2,6,13);line(6,13,12,13);line(12,13,9,22)
        line(9,22,19,9);line(19,9,13,9);line(13,9,13,2)
    elseif id=="user" then
        ring(8,3,8,8);ring(4,13,16,10)
    else
        ring(4,4,16,16);bar(11,7,2,10);bar(8,11,8,2)
    end
    return holder
end

--// WHITE LIQUID GLASS SHADER (pure GUI primitives; no remote UI library).
-- Roblox BlurEffect blurs the world globally, not individual panels. Local
-- glass refraction is therefore simulated with white translucent layers.
local function liquidSurface(obj,kind)
    local base={window=.76,sidebar=.69,search=.62,footer=.68,
        panel=.70,row=.78,button=.65,toast=.49,nav=.89,bubble=.59}
    local entry={Kind=kind,Base=base[kind] or .72,
        Dynamic=kind=="nav" or kind=="switch" or kind=="option"}
    obj.BackgroundColor3=C.White
    if kind=="window" or kind=="sidebar" or kind=="search" or kind=="panel"
        or kind=="footer" or kind=="toast" or kind=="bubble" then
        entry.Fill=mk("UIGradient",{Rotation=125,Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(.33,Color3.fromRGB(246,246,248)),
            ColorSequenceKeypoint.new(.67,Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(239,239,242))})},obj)
    end
    entry.Rim=mk("UIStroke",{Name="CrystalEdge",
        Thickness=kind=="window" and 1.7 or 1.0,
        Transparency=kind=="window" and .14 or (kind=="row" and .48 or .35),
        Color=C.White,ApplyStrokeMode=Enum.ApplyStrokeMode.Border},obj)
    if kind~="switch" then
        local gloss=mk("Frame",{Name="TopGloss",AnchorPoint=Vector2.new(.5,0),Position=UDim2.new(.5,0,0,1),
            Size=UDim2.new(1,-10,0,math.max(2,math.floor(obj.AbsoluteSize.Y*0.16))),BackgroundColor3=C.White,
            BackgroundTransparency=kind=="window" and .55 or .72,BorderSizePixel=0,Active=false},obj)
        round(gloss,999)
        mk("UIGradient",{Rotation=90,Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,.08),NumberSequenceKeypoint.new(.45,.52),NumberSequenceKeypoint.new(1,1)})},gloss)
        entry.Gloss=gloss
    end
    if kind=="window" or kind=="sidebar" or kind=="panel" or kind=="row" or kind=="button" or kind=="nav" then
        local flare=mk("Frame",{Name="LiquidFlare",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-6,0,6),
            Size=UDim2.fromOffset(kind=="window" and 170 or 84,kind=="window" and 90 or 40),BackgroundColor3=C.White,
            BackgroundTransparency=.92,BorderSizePixel=0,Active=false},obj)
        round(flare,999)
        local flareGrad=mk("UIGradient",{Rotation=18,Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,.15),NumberSequenceKeypoint.new(.68,.94),NumberSequenceKeypoint.new(1,1)})},flare)
        table.insert(spectrumItems,flareGrad)
        entry.Flare=flare
    end
    glassItems[obj]=entry
    return entry
end
updateGlass=function()
    local intensity=math.clamp(tonumber(Config.GlassIntensity) or 76,15,100)
    for obj,entry in pairs(glassItems) do
        if obj and obj.Parent then
            -- +intensity means clearer; all surfaces stay white, never tinted blue.
            local alpha=math.clamp(entry.Base+(intensity-76)*.0035,.32,.94)
            if not entry.Dynamic then
                obj.BackgroundTransparency=Config.HighContrast
                    and math.clamp(alpha-.22,.22,.72) or alpha
            end
            local edge=entry.Kind=="window" and .14
                or (entry.Kind=="row" and .52 or (entry.Kind=="nav" and .68 or .34))
            entry.Rim.Transparency=Config.HighContrast and math.max(.12,edge-.12) or edge
            if entry.Gloss and entry.Gloss.Parent then
                entry.Gloss.BackgroundTransparency=Config.HighContrast and .66 or (entry.Kind=="window" and .52 or .72)
            end
            if entry.Flare and entry.Flare.Parent then
                entry.Flare.BackgroundTransparency=Config.HighContrast and .90 or .93
            end
        end
    end
end
local function pulse(buttonObj)
    if Config.ReducedMotion or not buttonObj.Parent then return end
    local halo=mk("Frame",{Name="TouchRipple",Active=false,BackgroundTransparency=1,
        AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
        Size=UDim2.fromScale(.65,.7),ZIndex=buttonObj.ZIndex+1},buttonObj)
    round(halo,999)
    local ring=stroke(halo,C.Accent,.22,1.5)
    Tween:Create(halo,TweenInfo.new(.38,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
        Size=UDim2.fromScale(1.12,1.20)}):Play()
    Tween:Create(ring,TweenInfo.new(.38),{Transparency=1}):Play()
    task.delay(.43,function() if halo.Parent then halo:Destroy() end end)
end
local function button(parent,text,w,h,fill,func)
    local b=mk("TextButton",{Text=text,AutoButtonColor=false,BackgroundColor3=fill or C.Row,
        TextColor3=C.Text,Font=Enum.Font.GothamBold,TextSize=12,
        Size=UDim2.fromOffset(w or 100,h or 34),BorderSizePixel=0},parent)
    round(b,14);liquidSurface(b,"button")
    local bScale=mk("UIScale",{Scale=1},b)
    on(b,b.MouseEnter,function()
        animate(b,{BackgroundColor3=C.White,BackgroundTransparency=.39},.13)
        animate(bScale,{Scale=1.018},.14)
        local glass=glassItems[b]
        if glass and glass.Flare then animate(glass.Flare,{BackgroundTransparency=.83},.19) end
    end)
    on(b,b.MouseLeave,function()
        animate(b,{BackgroundColor3=C.White,BackgroundTransparency=Config.HighContrast and .44 or .65},.13)
        animate(bScale,{Scale=1},.14)
        local glass=glassItems[b]
        if glass and glass.Flare then animate(glass.Flare,{BackgroundTransparency=.93},.20) end
    end)
    on(b,b.MouseButton1Click,function() pulse(b) end)
    on(b,b.InputBegan,function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            animate(b,{BackgroundTransparency=.27},.08)
            animate(bScale,{Scale=.97},.08)
        end
    end)
    on(b,b.InputEnded,function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            animate(b,{BackgroundTransparency=Config.HighContrast and .44 or .65},.12)
            animate(bScale,{Scale=1},.12)
        end
    end)
    if func then on(b,b.MouseButton1Click,func) end
    return b
end
local screen=WS.CurrentCamera and WS.CurrentCamera.ViewportSize or Vector2.new(900,600)
if screen.X<200 or screen.Y<200 then screen=Vector2.new(900,600) end
local W=math.min(884,math.max(280,screen.X<690 and screen.X-16 or screen.X*.79))
local H=math.min(572,math.max(260,screen.Y<460 and screen.Y-12 or screen.Y*.85))
local compact=W<690
local navW=compact and 58 or 192
local parent
if type(gethui)=="function" then pcall(function() parent=gethui() end) end
if not parent then pcall(function() parent=game:GetService("CoreGui") end) end
if not parent then parent=LP:WaitForChild("PlayerGui",8) end
if not parent then warn("[andepzai] Cannot create UI");STATE.Alive=false;return end
local gui=mk("ScreenGui",{Name="andepzai_CrystalWhiteGlassV20",IgnoreGuiInset=true,ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=12500},parent)
STATE.Gui=gui
local backdropBlur
updateBackdrop=function()
    local shouldEnable=STATE.Alive and Config.BackgroundBlur and gui.Parent~=nil
        and STATE.WindowVisible~=false and (tonumber(Config.BlurStrength) or 0)>0
    if shouldEnable then
        if not backdropBlur or not backdropBlur.Parent then
            backdropBlur=Instance.new("BlurEffect")
            backdropBlur.Name="andepzai_OptionalBackgroundBlur"
            backdropBlur.Parent=Lighting
        end
        backdropBlur.Size=math.clamp(tonumber(Config.BlurStrength) or 8,0,16)
        backdropBlur.Enabled=true
    elseif backdropBlur then
        backdropBlur.Enabled=false
    end
end
local glow=mk("Frame",{Name="SoftWhiteRefraction",AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,5,.5,5),Size=UDim2.fromOffset(W+24,H+24),
    BackgroundColor3=C.White,BackgroundTransparency=.96,BorderSizePixel=0,
    Visible=Config.SoftGlow,Active=false},gui)
STATE.Glow=glow
round(glow,42)
mk("UIGradient",{Rotation=90,Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,.42),NumberSequenceKeypoint.new(.5,.88),
    NumberSequenceKeypoint.new(1,.46)})},glow)
local shadow=mk("Frame",{Name="SoftDepth",AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,5,.5,9),Size=UDim2.fromOffset(W,H),
    BackgroundColor3=Color3.fromRGB(21,22,25),BackgroundTransparency=.88,BorderSizePixel=0},gui)
round(shadow,34)
local win=mk("Frame",{Name="Window",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(W,H),BackgroundColor3=C.BG,BackgroundTransparency=.76,
    BorderSizePixel=0,ClipsDescendants=true},gui)
round(win,32)
liquidSurface(win,"window")
-- Bright outer specular and faint inner depth; no gray/blue plate.
stroke(win,C.White,.12,1.2)
local halo=mk("Frame",{Name="WhiteDiffuseLight",BackgroundColor3=C.White,
    BackgroundTransparency=.955,Position=UDim2.new(1,-140,0,-95),
    Size=UDim2.fromOffset(200,200),BorderSizePixel=0,Active=false},win)
round(halo,100)
mk("UIGradient",{Rotation=110,Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,.21),NumberSequenceKeypoint.new(1,1)})},halo)
local glassTop=mk("Frame",{Name="SpecularTop",BackgroundColor3=C.White,
    BackgroundTransparency=.27,Position=UDim2.fromOffset(23,2),
    Size=UDim2.new(1,-46,0,2),BorderSizePixel=0,Active=false},win)
mk("UIGradient",{Rotation=0,Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.16,.2),
    NumberSequenceKeypoint.new(.65,.52),NumberSequenceKeypoint.new(1,1)})},glassTop)
local shine=mk("Frame",{Name="WhiteReflectiveStrip",Size=UDim2.new(1,0,0,2),BorderSizePixel=0,
    BackgroundColor3=C.White,BackgroundTransparency=.52},win)
local grad=mk("UIGradient",{Offset=Vector2.new(-.8,0),Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(240,240,242)),ColorSequenceKeypoint.new(.5,C.White),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(240,240,242))})},shine)
table.insert(spectrumItems,grad)
local header=mk("Frame",{Name="Header",BackgroundTransparency=1,
    Position=UDim2.fromOffset(0,7),Size=UDim2.new(1,0,0,64)},win)
local logo=mk("Frame",{BackgroundColor3=C.Row,Size=UDim2.fromOffset(42,42),
    Position=UDim2.fromOffset(17,9),BorderSizePixel=0},header)
round(logo,18);liquidSurface(logo,"bubble")
local logoRim=stroke(logo,C.White,.16,1.3)
vectorIcon(logo,"logo",UDim2.fromOffset(9,9),24)
local brand=txt(header,"andepzai",22,C.Text,Enum.Font.GothamBold)
brand.Position=UDim2.fromOffset(67,7);brand.Size=UDim2.fromOffset(190,29)
local tagline=txt(header,"C R Y S T A L   W H I T E   /   1 7 . 0",9,C.Muted,Enum.Font.GothamBold)
tagline.Position=UDim2.fromOffset(68,37);tagline.Size=UDim2.fromOffset(245,13)
local exitBtn=button(header,"",30,30,C.Glass)
exitBtn.Position=UDim2.new(1,-45,0,15)
vectorIcon(exitBtn,"x",UDim2.fromOffset(6,6),18)
local miniBtn=button(header,"",30,30,C.Glass)
miniBtn.Position=UDim2.new(1,-82,0,15)
vectorIcon(miniBtn,"minus",UDim2.fromOffset(6,6),18)
local statusCapsule=mk("Frame",{BackgroundColor3=C.Panel,BorderSizePixel=0,
    Position=UDim2.new(1,-188,0,13),Size=UDim2.fromOffset(96,32)},header)
round(statusCapsule,16);liquidSurface(statusCapsule,"bubble")
local statusLabel=txt(statusCapsule,"●  ACTIVE",10,C.Text,Enum.Font.GothamBold)
statusLabel.TextXAlignment=Enum.TextXAlignment.Center
statusLabel.Size=UDim2.fromScale(1,1)
statusCapsule.Visible=not compact
local searchBack=mk("Frame",{Name="Search",BackgroundColor3=C.Panel,
    Position=UDim2.fromOffset(navW+26,73),Size=UDim2.new(1,-navW-42,0,37),BorderSizePixel=0},win)
round(searchBack,19);liquidSurface(searchBack,"search")
local searchIcon=vectorIcon(searchBack,"search",UDim2.fromOffset(11,7),22)
local searchBox=mk("TextBox",{Name="SearchField",BackgroundTransparency=1,
    Text="",PlaceholderText="Tìm chức năng...  /  Search",ClearTextOnFocus=false,
    PlaceholderColor3=C.Quiet,TextColor3=C.Text,Font=Enum.Font.Gotham,
    TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
    Position=UDim2.fromOffset(42,0),Size=UDim2.new(1,-57,1,0)},searchBack)
on(searchBox,searchBox.Focused,function()
    local glass=glassItems[searchBack]
    if glass then animate(glass.Rim,{Transparency=.14,Thickness=1.4},.16) end
    animate(searchIcon,{Rotation=-8},.18)
end)
on(searchBox,searchBox.FocusLost,function()
    local glass=glassItems[searchBack]
    if glass then animate(glass.Rim,{Transparency=.34,Thickness=1},.18) end
    animate(searchIcon,{Rotation=0},.18)
end)
local side=mk("Frame",{BackgroundColor3=C.Panel,BackgroundTransparency=.68,
    Position=UDim2.fromOffset(12,74),Size=UDim2.new(0,navW,1,-132),BorderSizePixel=0},win)
round(side,22);liquidSurface(side,"sidebar")
if not compact then
    local sectionNav=txt(side,"NAVIGATION",9,C.Quiet,Enum.Font.GothamBold)
    sectionNav.Position=UDim2.fromOffset(14,9);sectionNav.Size=UDim2.fromOffset(125,22)
end
local navScroll=mk("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,
    Position=UDim2.fromOffset(4,compact and 8 or 34),
    Size=UDim2.new(1,-8,1,compact and -14 or -69),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.fromOffset(0,0),
    ScrollBarThickness=0,ScrollingDirection=Enum.ScrollingDirection.Y},side)
mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},navScroll)
local sideFoot=txt(side,compact and "v22" or "V22.0  •  3 SEA + REVIEW",9,C.Quiet,Enum.Font.GothamMedium)
sideFoot.TextXAlignment=Enum.TextXAlignment.Center
sideFoot.Size=UDim2.new(1,-8,0,24);sideFoot.Position=UDim2.new(0,4,1,-28)
local work=mk("Frame",{BackgroundTransparency=1,
    Position=UDim2.fromOffset(navW+22,119),Size=UDim2.new(1,-navW-36,1,-178)},win)
local footer=mk("Frame",{BackgroundColor3=C.Panel,BackgroundTransparency=.19,
    Position=UDim2.new(0,13,1,-48),Size=UDim2.new(1,-26,0,34),BorderSizePixel=0},win)
round(footer,13);liquidSurface(footer,"footer")
local footText=txt(footer,"CRYSTAL WHITE  •  liquid glass ui  •  andepzai",10,C.Muted,Enum.Font.GothamMedium)
footText.Position=UDim2.fromOffset(12,0);footText.Size=UDim2.new(1,-15,1,0)
local toastHolder=mk("Frame",{Name="Toasts",BackgroundTransparency=1,
    AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-15,0,18),
    Size=UDim2.fromOffset(math.min(290,screen.X-40),230)},gui)
mk("UIListLayout",{Padding=UDim.new(0,8),VerticalAlignment=Enum.VerticalAlignment.Top},toastHolder)
local toastCount=0
STATE.Notify=function(title,body,level)
    if not STATE.Alive or not gui.Parent or toastCount>=4 then return end
    toastCount=toastCount+1
    local color=(level=="error" and C.Red) or (level=="warn" and C.Orange) or C.Accent
    local card=mk("Frame",{BackgroundColor3=C.Panel,BackgroundTransparency=.06,
        Size=UDim2.new(1,0,0,58),BorderSizePixel=0},toastHolder)
    round(card,18);liquidSurface(card,"toast");stroke(card,color,.43,1.1)
    local toastScale=mk("UIScale",{Scale=Config.ReducedMotion and 1 or .94},card)
    if not Config.ReducedMotion then animate(toastScale,{Scale=1},.24) end
    local bar=mk("Frame",{BackgroundColor3=color,BorderSizePixel=0,
        Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(4,58)},card)
    round(bar,5)
    local heading=txt(card,tostring(title),12,C.Text,Enum.Font.GothamBold)
    heading.Position=UDim2.fromOffset(13,7);heading.Size=UDim2.new(1,-20,0,20)
    local desc=txt(card,tostring(body),10,C.Muted)
    desc.Position=UDim2.fromOffset(13,26);desc.Size=UDim2.new(1,-20,0,24)
    task.delay(3.8,function()
        if not card.Parent then return end
        if not Config.ReducedMotion then
            animate(toastScale,{Scale=.96},.17)
            animate(card,{BackgroundTransparency=.97},.17)
            task.wait(.19)
        end
        if card.Parent then card:Destroy() end
        toastCount=math.max(0,toastCount-1)
    end)
end
local navButtons={}
local selectedPage
local function choosePage(id)
    local changed=selectedPage~=id
    selectedPage=id
    searchBox.Text=""
    for name,page in pairs(STATE.Pages) do page.Frame.Visible=(name==id) end
    for name,entry in pairs(navButtons) do
        local selected=name==id
        animate(entry.Back,{BackgroundColor3=C.White,
            BackgroundTransparency=selected and .40 or .87},.16)
        animate(entry.IconChip,{BackgroundTransparency=selected and .24 or .56},.16)
        if entry.IconScale then animate(entry.IconScale,{Scale=selected and 1.08 or 1},.18) end
        entry.Label.TextColor3=selected and C.Text or C.Muted
        entry.Marker.Visible=selected
        if selected and changed then
            entry.Marker.Size=UDim2.fromOffset(3,5)
            animate(entry.Marker,{Size=UDim2.fromOffset(3,23)},.22)
        end
    end
    local page=STATE.Pages[id]
    if page then
        page.Frame.CanvasPosition=Vector2.zero
        if changed and page.Heading and not Config.ReducedMotion then
            page.Heading.TextTransparency=1
            page.Subtitle.TextTransparency=1
            page.Underline.Size=UDim2.fromOffset(0,2)
            animate(page.Heading,{TextTransparency=0},.23)
            animate(page.Subtitle,{TextTransparency=0},.32)
            animate(page.Underline,{Size=UDim2.fromOffset(45,2)},.30)
        end
    end
end
local function addPage(id,symbol,title,subtitle)
    local index=0;for _ in pairs(STATE.Pages) do index=index+1 end
    local nav=mk("TextButton",{Name="Nav_"..id,Text="",AutoButtonColor=false,
        BackgroundColor3=C.White,BackgroundTransparency=.87,
        Size=UDim2.new(1,0,0,42),LayoutOrder=index,BorderSizePixel=0},navScroll)
    round(nav,15);liquidSurface(nav,"nav")
    local marker=mk("Frame",{BackgroundColor3=C.Accent,BorderSizePixel=0,
        Size=UDim2.fromOffset(3,23),Position=UDim2.fromOffset(2,10),Visible=false},nav)
    round(marker,3);themed(marker,"BackgroundColor3")
    local iconChip=mk("Frame",{Name="NavIconGlass",BackgroundColor3=C.White,
        BackgroundTransparency=.55,BorderSizePixel=0,
        Position=UDim2.fromOffset(compact and 10 or 9,7),Size=UDim2.fromOffset(28,28)},nav)
    round(iconChip,12);stroke(iconChip,C.White,.35,1)
    vectorIcon(iconChip,id,UDim2.fromOffset(5,5),18)
    local chipScale=mk("UIScale",{Scale=1},iconChip)
    local l=txt(nav,title,11,C.Muted,Enum.Font.GothamMedium)
    l.Position=UDim2.fromOffset(44,0);l.Size=UDim2.new(1,-46,1,0)
    l.Visible=not compact
    navButtons[id]={Back=nav,Label=l,Marker=marker,IconChip=iconChip,IconScale=chipScale}
    local navScale=mk("UIScale",{Scale=1},nav)
    on(nav,nav.MouseEnter,function()
        if selectedPage~=id then
            animate(nav,{BackgroundTransparency=.80},.12)
            animate(iconChip,{BackgroundTransparency=.44},.12)
        end
        animate(navScale,{Scale=1.015},.14)
        animate(chipScale,{Scale=1.07},.14)
    end)
    on(nav,nav.MouseLeave,function()
        if selectedPage~=id then
            animate(nav,{BackgroundTransparency=.87},.12)
            animate(iconChip,{BackgroundTransparency=.56},.12)
        end
        animate(navScale,{Scale=1},.14)
        animate(chipScale,{Scale=selectedPage==id and 1.08 or 1},.14)
    end)
    on(nav,nav.MouseButton1Click,function()
        pulse(nav)
        if STATE.OpenPage then STATE.OpenPage(id) else choosePage(id) end
    end)
    local frame=mk("ScrollingFrame",{Name="Page_"..id,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),ScrollBarThickness=3,ScrollBarImageColor3=C.Border,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.fromOffset(0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false},work)
    mk("UIListLayout",{Padding=UDim.new(0,11),SortOrder=Enum.SortOrder.LayoutOrder},frame)
    mk("UIPadding",{PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,2),
        PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,3)},frame)
    local top=mk("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,52),LayoutOrder=0},frame)
    local heading=txt(top,title,21,C.Text,Enum.Font.GothamBold)
    heading.Size=UDim2.new(1,0,0,31)
    local underline=mk("Frame",{BackgroundColor3=C.Accent,BackgroundTransparency=.15,
        Size=UDim2.fromOffset(45,2),Position=UDim2.fromOffset(0,32),BorderSizePixel=0},top)
    round(underline,2);themed(underline,"BackgroundColor3")
    local sub=txt(top,subtitle or "",11,C.Quiet)
    sub.Position=UDim2.fromOffset(0,30);sub.Size=UDim2.new(1,0,0,18)
    local page={Frame=frame,Sections={},Index=0,Title=title,
        Heading=heading,Subtitle=sub,Underline=underline}
    STATE.Pages[id]=page
    return page
end
local function section(page,name,description)
    page.Index=page.Index+1
    local card=mk("Frame",{Name="Section_"..page.Index,BackgroundColor3=C.Panel,
        BackgroundTransparency=.22,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BorderSizePixel=0,LayoutOrder=page.Index},page.Frame)
    round(card,18);liquidSurface(card,"panel")
    mk("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},card)
    mk("UIPadding",{PaddingTop=UDim.new(0,9),PaddingBottom=UDim.new(0,11),
        PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)},card)
    local title=mk("TextButton",{Text=name:upper(),BackgroundTransparency=1,
        AutoButtonColor=false,TextColor3=C.Accent,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
        Font=Enum.Font.GothamBold,Size=UDim2.new(1,0,0,25)},card)
    themed(title,"TextColor3")
    local headerChevron=vectorIcon(title,"chevron",UDim2.new(1,-23,.5,-9),18)
    local sub
    if description then
        sub=txt(card,description,10,C.Quiet)
        sub.Size=UDim2.new(1,0,0,31)
    end
    local entry={Card=card,Elements={},Name=name,Header=title,Sub=sub,Collapsed=false}
    entry.SetCollapsed=function(self,collapsed)
        self.Collapsed=not not collapsed
        for _,element in ipairs(self.Elements) do element.Visible=not self.Collapsed and element.Name~="Choices" end
        if self.Sub then self.Sub.Visible=not self.Collapsed end
        self.Header.Text=self.Name:upper()
        animate(headerChevron,{Rotation=self.Collapsed and -90 or 0},.20)
    end
    on(title,title.MouseButton1Click,function()
        entry:SetCollapsed(not entry.Collapsed)
        pulse(title)
    end)
    table.insert(page.Sections,entry)
    return entry
end
local function control(sectionObj,name,height)
    local row=mk("Frame",{Name="Control",BackgroundColor3=C.Row,BackgroundTransparency=.78,
        BorderSizePixel=0,Size=UDim2.new(1,0,0,height or 47)},sectionObj.Card)
    round(row,16);liquidSurface(row,"row")
    row:SetAttribute("AZ_Label",name)
    table.insert(sectionObj.Elements,row)
    return row
end
local function controlGlyph(label)
    local lower=tostring(label or ""):lower()
    if lower:find("fruit") or lower:find("berry") then return "fruits" end
    if lower:find("fishing") or lower:find("fish") or lower:find("rod") then return "fishing" end
    if lower:find("law raid") or lower:find("raid") or lower:find("dungeon") then return "raid" end
    if lower:find("boss") or lower:find("elite") or lower:find("tyrant") then return "boss" end
    if lower:find("weapon") or lower:find("sword") or lower:find("attack") then return "combat" end
    if lower:find("haki") or lower:find("shield") or lower:find("protect") then return "shield" end
    if lower:find("cooldown") or lower:find("delay") or lower:find("timer") then return "clock" end
    if lower:find("farm") or lower:find("quest") or lower:find("level") then return "farm" end
    if lower:find("skill") or lower:find("ability") then return "bolt" end
    if lower:find("sea") or lower:find("boat") or lower:find("ship") then return "sea" end
    if lower:find("server") or lower:find("rejoin") or lower:find("job id") then return "server" end
    if lower:find("island") or lower:find("move") or lower:find("teleport") or lower:find("travel") then return "map" end
    if lower:find("material") or lower:find("craft") then return "craft" end
    if lower:find("esp") or lower:find("visual") or lower:find("bright") then return "esp" end
    if lower:find("purchase") or lower:find("buy") or lower:find("shop") then return "shop" end
    if lower:find("race") or lower:find("trial") then return "race" end
    if lower:find("config") or lower:find("save") then return "save" end
    if lower:find("glass") or lower:find("blur") or lower:find("animation") then return "spark" end
    if lower:find("health") then return "shield" end
    if lower:find("target") or lower:find("choose") or lower:find("select") then return "target" end
    if lower:find("player") or lower:find("team") then return "user" end
    return "sliders"
end

local function tip(row,labelText,description,labelWidth)
    local h=row.Size.Y.Offset
    local top=h>=68 and 8 or math.max(6,math.floor((h-28)/2))
    local bubble=mk("Frame",{Name="FeatureIconGlass",BackgroundColor3=C.White,
        BackgroundTransparency=.49,BorderSizePixel=0,
        Position=UDim2.fromOffset(10,top),Size=UDim2.fromOffset(28,28)},row)
    round(bubble,11);stroke(bubble,C.White,.38,1)
    vectorIcon(bubble,controlGlyph(labelText),UDim2.fromOffset(5,5),18)
    local reserve=labelWidth or 75
    -- On narrow phones descriptions stay above controls instead of crossing them.
    local label=txt(row,labelText,12,C.Text,Enum.Font.GothamMedium)
    label.Position=UDim2.fromOffset(46,description and (h>=68 and 7 or 3) or 0)
    label.TextTruncate=Enum.TextTruncate.AtEnd
    label.Size=UDim2.new(1,-reserve-54,0,description and 23 or h)
    if description then
        local sub=txt(row,description,10,C.Muted)
        sub.Position=UDim2.fromOffset(46,h>=68 and 31 or 25)
        sub.TextTruncate=Enum.TextTruncate.AtEnd
        sub.Size=UDim2.new(1,-reserve-54,0,18)
    end
    return label
end
local function toggle(s,name,key,description)
    local row=control(s,name,compact and (description and 73 or 48) or (description and 58 or 45))
    tip(row,name,description,76)
    local track=mk("TextButton",{Text="",BackgroundColor3=C.Glass,
        BorderSizePixel=0,Size=UDim2.fromOffset(47,25),Position=UDim2.new(1,-59,.5,-12),
        AutoButtonColor=false},row)
    round(track,15)
    liquidSurface(track,"switch")
    stroke(track,C.Text,.81,1)
    local dot=mk("Frame",{BackgroundColor3=C.White,Size=UDim2.fromOffset(19,19),
        Position=UDim2.fromOffset(3,3),BorderSizePixel=0},track)
    round(dot,10)
    local dotRim=stroke(dot,C.White,.35,.8)
    local trackScale=mk("UIScale",{Scale=1},track)
    local function redraw(v,instant)
        local trackColor=v and C.Accent or Color3.fromRGB(183,185,190)
        local trackTrans=v and .06 or .12
        local dotPos=UDim2.fromOffset(v and 25 or 3,3)
        local dotColor=C.White
        if instant then
            track.BackgroundColor3=trackColor
            track.BackgroundTransparency=trackTrans
            dot.Position=dotPos
            dot.BackgroundColor3=dotColor
        else
            animate(track,{BackgroundColor3=trackColor,BackgroundTransparency=trackTrans},.22)
            animate(dot,{Position=dotPos,BackgroundColor3=dotColor},.22)
            animate(dotRim,{Transparency=v and .12 or .35},.20)
        end
    end
    redraw(Config[key],true)
    STATE.ControlBindings[key]=STATE.ControlBindings[key] or {}
    table.insert(STATE.ControlBindings[key],redraw)
    -- Larger invisible touch target, while keeping a compact visible switch.
    local hit=mk("TextButton",{Name="SwitchTouchTarget",Text="",AutoButtonColor=false,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromOffset(66,42),Position=UDim2.new(1,-67,.5,-21)},row)
    on(hit,hit.MouseButton1Click,function()
        animate(trackScale,{Scale=.94},.07)
        setFlag(key,not Config[key]);pulse(track)
        task.delay(.08,function() if trackScale.Parent then animate(trackScale,{Scale=1},.12) end end)
    end)
    return {Set=function(_,value) setFlag(key,value) end}
end
-- Farm-mode switches are bound to the actual FarmEnabled + FarmMode state.
-- Only one farm mode can be active; selecting another changes that same engine.
local function farmSwitch(s,name,mode,description)
    local row=control(s,name,compact and (description and 73 or 49) or (description and 58 or 46))
    tip(row,name,description,compact and 82 or 118)
    local status=txt(row,"TẮT",10,C.Muted,Enum.Font.GothamBold)
    status.Size=UDim2.fromOffset(38,24)
    status.Position=UDim2.new(1,-100,.5,-12)
    status.TextXAlignment=Enum.TextXAlignment.Right
    status.Visible=not compact
    local track=mk("TextButton",{Name="FarmModeToggle",Text="",AutoButtonColor=false,
        BackgroundColor3=C.White,BorderSizePixel=0,Size=UDim2.fromOffset(48,26),
        Position=UDim2.new(1,-60,.5,-13)},row)
    round(track,16);liquidSurface(track,"switch")
    stroke(track,C.White,.40,1.2)
    local dot=mk("Frame",{Name="ToggleKnob",BackgroundColor3=C.White,
        BorderSizePixel=0,Position=UDim2.fromOffset(3,3),Size=UDim2.fromOffset(20,20)},track)
    round(dot,11)
    stroke(dot,C.White,.30,1)
    local scale=mk("UIScale",{Scale=1},track)
    local function onNow()
        return Config.FarmEnabled==true and (mode==nil or Config.FarmMode==mode)
    end
    local function redraw(_,instant)
        if not row.Parent then return end
        local active=onNow()
        local col=active and C.Accent or Color3.fromRGB(178,181,187)
        local pos=UDim2.fromOffset(active and 25 or 3,3)
        status.Text=active and "BẬT" or "TẮT"
        status.TextColor3=active and C.Text or C.Muted
        if instant or Config.ReducedMotion then
            track.BackgroundColor3=col;track.BackgroundTransparency=active and .06 or .13
            dot.Position=pos
        else
            animate(track,{BackgroundColor3=col,BackgroundTransparency=active and .06 or .13},.2)
            animate(dot,{Position=pos},.20)
        end
    end
    for _,key in ipairs({"FarmEnabled","FarmMode"}) do
        STATE.ControlBindings[key]=STATE.ControlBindings[key] or {}
        table.insert(STATE.ControlBindings[key],redraw)
    end
    local hit=mk("TextButton",{Name="FarmSwitchTouchTarget",Text="",AutoButtonColor=false,
        BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.new(1,-72,.5,-23),Size=UDim2.fromOffset(72,46)},row)
    local function change()
        local active=onNow()
        animate(scale,{Scale=.92},.07)
        if active then
            setFlag("FarmEnabled",false)
        else
            if mode~=nil then
                if mode=="Level" or mode=="Boss" or mode=="Material" or mode=="Mastery" then
                    STATE.ApplyReadyPreset(mode)
                else
                    setFlag("FarmMode",mode)
                end
            end
            setFlag("FarmEnabled",true)
        end
        redraw(nil,false)
        task.delay(.1,function() if scale.Parent then animate(scale,{Scale=1},.15) end end)
        pulse(track)
    end
    on(hit,hit.MouseButton1Click,change)
    redraw(nil,true)
    return {Set=function(_,enabled)
        if enabled then
            if mode~=nil then
                if mode=="Level" or mode=="Boss" or mode=="Material" or mode=="Mastery" then
                    STATE.ApplyReadyPreset(mode)
                else setFlag("FarmMode",mode) end
            end
            setFlag("FarmEnabled",true)
        elseif onNow() then setFlag("FarmEnabled",false) end
    end}
end
local activeSlider
local function slider(s,name,key,lo,hi,step,description)
    local row=control(s,name,compact and (description and 94 or 72) or (description and 80 or 64))
    local label=tip(row,name,description,75)
    local val=txt(row,tostring(Config[key]),11,C.Accent,Enum.Font.GothamBold)
    val.Size=UDim2.fromOffset(51,22);val.Position=UDim2.new(1,-61,0,7)
    val.TextXAlignment=Enum.TextXAlignment.Right;themed(val,"TextColor3")
    local track=mk("Frame",{BackgroundColor3=C.Glass,BorderSizePixel=0,
        Position=UDim2.new(0,14,1,-18),Size=UDim2.new(1,-28,0,8)},row)
    round(track,6);liquidSurface(track,"button")
    local fill=mk("Frame",{BackgroundColor3=C.Accent,BorderSizePixel=0,
        Size=UDim2.fromScale(0,1)},track)
    round(fill,6);themed(fill,"BackgroundColor3")
    local ball=mk("Frame",{BackgroundColor3=C.White,Size=UDim2.fromOffset(13,13),
        AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),BorderSizePixel=0},track)
    round(ball,10)
    themed(stroke(ball,C.Accent,.48,1.2),"Color")
    local lastPaint=0
    local function set(v)
        local num=math.clamp(math.floor((v-lo)/step+.5)*step+lo,lo,hi)
        num=math.floor(num*100+0.5)/100
        Config[key]=num
        local p=(num-lo)/(hi-lo)
        fill.Size=UDim2.fromScale(p,1);ball.Position=UDim2.fromScale(p,.5)
        val.Text=tostring(num)
        if key=="GlassIntensity" and updateGlass and os.clock()-lastPaint>.065 then
            lastPaint=os.clock();updateGlass()
        end
    end
    set(Config[key])
    STATE.ControlBindings[key]=STATE.ControlBindings[key] or {}
    table.insert(STATE.ControlBindings[key],function(v) set(v) end)
    local function update(x)
        local p=math.clamp((x-track.AbsolutePosition.X)/math.max(1,track.AbsoluteSize.X),0,1)
        set(lo+p*(hi-lo))
    end
    local sliderTouch=mk("TextButton",{Name="SliderTouchTarget",Text="",AutoButtonColor=false,
        BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.new(0,12,1,-29),Size=UDim2.new(1,-24,0,29)},row)
    on(sliderTouch,sliderTouch.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            animate(ball,{Size=UDim2.fromOffset(17,17)},.12)
            activeSlider={Update=update,Input=input,Finish=function()
                animate(ball,{Size=UDim2.fromOffset(13,13)},.18)
                if key=="GlassIntensity" and updateGlass then updateGlass() end
                if key=="BlurStrength" and updateBackdrop then updateBackdrop() end
                save()
            end}
            update(input.Position.X)
        end
    end)
    return {Set=function(_,v) setFlag(key,v) end}
end
-- Shared drag handlers for every slider; only one slider tracks the pointer.
on(UIS,UIS.InputChanged,function(input)
    local slider=activeSlider
    if not slider then return end
    if input.UserInputType==Enum.UserInputType.MouseMovement or
        (input.UserInputType==Enum.UserInputType.Touch and slider.Input==input) then
        slider.Update(input.Position.X)
    end
end)
on(UIS,UIS.InputEnded,function(input)
    local slider=activeSlider
    if slider and (input==slider.Input or
        (input.UserInputType==Enum.UserInputType.MouseButton1 and slider.Input.UserInputType==Enum.UserInputType.MouseButton1)) then
        activeSlider=nil
        slider.Finish()
    end
end)
local function dropdown(s,name,key,list,description)
    local row=control(s,name,compact and (description and 92 or 78) or (description and 61 or 47))
    tip(row,name,description,compact and 22 or 168)
    local options=list
    local popup=mk("Frame",{Name="Choices",BackgroundColor3=C.Row,
        BorderSizePixel=0,Visible=false,ClipsDescendants=true,
        Size=UDim2.new(1,0,0,185)},s.Card)
    round(popup,16);liquidSurface(popup,"panel")
    local scroller=mk("ScrollingFrame",{Name="OptionList",BackgroundTransparency=1,
        BorderSizePixel=0,Size=UDim2.fromScale(1,1),ScrollBarThickness=2,
        ScrollBarImageColor3=C.Accent,CanvasSize=UDim2.fromOffset(0,0),
        AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y},popup)
    mk("UIListLayout",{Padding=UDim.new(0,3)},scroller)
    mk("UIPadding",{PaddingTop=UDim.new(0,5),PaddingBottom=UDim.new(0,5),
        PaddingLeft=UDim.new(0,6),PaddingRight=UDim.new(0,6)},scroller)
    popup:SetAttribute("AZ_Label",name)
    table.insert(s.Elements,popup)
    local current=button(row,"",145,30,C.Glass)
    if compact then
        current.Size=UDim2.new(1,-22,0,30)
        current.Position=UDim2.new(0,11,1,-36)
    else
        current.Position=UDim2.new(1,-155,.5,-15)
    end
    current.TextTruncate=Enum.TextTruncate.AtEnd
    current.TextXAlignment=Enum.TextXAlignment.Left
    mk("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,29)},current)
    local arrowIcon=vectorIcon(current,"chevron",UDim2.new(1,-25,.5,-9),18)
    local popupToken=0
    local popupTargetHeight=185
    local setOpen
    local function sync()
        current.Text=tostring(Config[key])
    end
    sync()
    STATE.ControlBindings[key]=STATE.ControlBindings[key] or {}
    table.insert(STATE.ControlBindings[key],function() sync() end)
    -- Reuse option buttons instead of creating more event connections on each open.
    local cachedButtons={}
    local currentOptions={}
    local function build()
        local choices=type(options)=="function" and options() or options
        if type(choices)~="table" or #choices==0 then choices={"(none found)"} end
        local count=math.min(#choices,65)
        for i=1,count do
            local option=choices[i]
            currentOptions[i]=option
            local choose=cachedButtons[i]
            if not choose then
                choose=button(scroller,tostring(option),100,30,C.Row)
                choose.Size=UDim2.new(1,-3,0,31)
                choose.TextXAlignment=Enum.TextXAlignment.Left
                mk("UIPadding",{PaddingLeft=UDim.new(0,11),PaddingRight=UDim.new(0,7)},choose)
                cachedButtons[i]=choose
                if glassItems[choose] then glassItems[choose].Dynamic=true end
                local index=i
                on(choose,choose.MouseButton1Click,function()
                    local selected=currentOptions[index]
                    if selected and selected~="(none found)" then
                        if key=="Accent" then themeSelect(selected) end
                        setFlag(key,selected)
                    end
                    if setOpen then setOpen(false) end
                end)
            end
            local selected=tostring(Config[key])==tostring(option)
            choose.Text=(selected and "✓  " or "   ")..tostring(option)
            choose.Font=selected and Enum.Font.GothamBold or Enum.Font.Gotham
            choose.TextColor3=C.Text
            choose.BackgroundTransparency=selected and .32 or .71
            choose.Visible=true
        end
        for i=count+1,#cachedButtons do
            cachedButtons[i].Visible=false
            currentOptions[i]=nil
        end
        popupTargetHeight=math.min(198,count*35+10)
        scroller.CanvasPosition=Vector2.zero
    end
    setOpen=function(open)
        popupToken=popupToken+1
        local token=popupToken
        animate(arrowIcon,{Rotation=open and 180 or 0},.22)
        if open then
            popup.Size=UDim2.new(1,0,0,Config.ReducedMotion and popupTargetHeight or 0)
            popup.Visible=true
            if not Config.ReducedMotion then
                animate(popup,{Size=UDim2.new(1,0,0,popupTargetHeight)},.26)
            end
        elseif popup.Visible then
            if Config.ReducedMotion then popup.Visible=false
            else
                animate(popup,{Size=UDim2.new(1,0,0,0)},.18)
                task.delay(.20,function()
                    if popup.Parent and popupToken==token then popup.Visible=false end
                end)
            end
        end
    end
    on(current,current.MouseButton1Click,function()
        if popup.Visible then setOpen(false);return end
        -- Keep other dropdowns closed; never create new option event connections.
        for _,item in ipairs(s.Elements) do
            if item~=popup and item.Name=="Choices" then item.Visible=false end
        end
        build();setOpen(true)
    end)
    return {Refresh=build,Set=function(_,v) setFlag(key,v) end}
end
local function input(s,name,key,description)
    local row=control(s,name,compact and (description and 90 or 73) or (description and 65 or 49))
    tip(row,name,description,compact and 20 or 190)
    local field=mk("TextBox",{Text=tostring(Config[key]),ClearTextOnFocus=false,
        BackgroundColor3=C.Glass,TextColor3=C.Text,Font=Enum.Font.Gotham,
        TextSize=12,TextXAlignment=Enum.TextXAlignment.Center,
        Size=UDim2.fromOffset(162,31),Position=UDim2.new(1,-171,.5,-15),BorderSizePixel=0},row)
    round(field,14)
    local fieldRim=stroke(field,C.Text,.77,1)
    on(field,field.Focused,function() animate(fieldRim,{Transparency=.26,Thickness=1.5},.18) end)
    if compact then
        field.Size=UDim2.new(1,-22,0,31)
        field.Position=UDim2.new(0,11,1,-36)
    end
    on(field,field.FocusLost,function()
        animate(fieldRim,{Transparency=.77,Thickness=1},.18)
        Config[key]=field.Text;save()
    end)
    STATE.ControlBindings[key]=STATE.ControlBindings[key] or {}
    table.insert(STATE.ControlBindings[key],function(v) if not field:IsFocused() then field.Text=tostring(v) end end)
    return field
end
local function action(s,name,fn,description)
    -- One-shot commands must stay buttons, but must never misleadingly say RUN.
    -- Continuous functions use toggle() or farmSwitch() instead.
    local lower=tostring(name):lower()
    local label="DÙNG"
    if lower:find("stop") or lower:find("cancel") or lower:find("dừng") or lower:find("restore") then label="DỪNG"
    elseif lower:find("test") then label="THỬ"
    elseif lower:find("check") or lower:find("diagnos") or lower:find("read") or lower:find("progress") then label="XEM"
    elseif lower:find("move") or lower:find("teleport") or lower:find("navigate") or lower:find("travel") or lower:find("go to") then label="ĐI"
    elseif lower:find("setup") or lower:find("select") or lower:find("preset") or lower:find("choose") then label="CHỌN"
    elseif lower:find("buy") or lower:find("purchase") then label="MUA"
    elseif lower:find("refresh") or lower:find("rescan") then label="QUÉT"
    elseif lower:find("save") then label="LƯU"
    elseif lower:find("show") or lower:find("view") or lower:find("find") or lower:find("list") then label="XEM"
    elseif lower:find("hop") or lower:find("rejoin") then label="CHUYỂN" end
    local row=control(s,name,compact and (description and 88 or 69) or (description and 58 or 45))
    tip(row,name,description,compact and 18 or 125)
    local b=button(row,label,94,31,C.Glass,fn)
    b.TextSize=11
    b.TextXAlignment=Enum.TextXAlignment.Center
    vectorIcon(b,"arrow",UDim2.new(1,-25,.5,-9),18)
    b.Position=compact and UDim2.new(1,-104,1,-37) or UDim2.new(1,-104,.5,-15)
    return b
end
local function info(s,body)
    local row=control(s,body,54)
    vectorIcon(row,"info",UDim2.fromOffset(11,17),18)
    local lbl=txt(row,body,11,C.Muted)
    lbl.Position=UDim2.fromOffset(39,5);lbl.Size=UDim2.new(1,-48,1,-10)
    return lbl
end
local function statBox(s,name,init)
    local row=control(s,name,49)
    vectorIcon(row,controlGlyph(name),UDim2.fromOffset(12,15),18)
    local left=txt(row,name,12,C.Muted,Enum.Font.GothamMedium)
    left.Position=UDim2.fromOffset(39,0);left.Size=UDim2.new(.48,0,1,0)
    local right=txt(row,init or "--",14,C.Accent,Enum.Font.GothamBold)
    right.Position=UDim2.new(.6,0,0,0);right.Size=UDim2.new(.37,0,1,0)
    right.TextXAlignment=Enum.TextXAlignment.Right;themed(right,"TextColor3")
    return function(v) right.Text=tostring(v) end
end
-- Search every navigation page, not only the currently selected one.
on(searchBox,searchBox:GetPropertyChangedSignal("Text"),function()
    local q=searchBox.Text:lower():match("^%s*(.-)%s*$") or ""
    local firstHit=nil
    local selectedHit=false
    for id,page in pairs(STATE.Pages) do
        local pageHit=(q=="") or page.Title:lower():find(q,1,true)~=nil
        local matched=0
        for _,sec in ipairs(page.Sections) do
            local count=0
            local secHit=pageHit or sec.Name:lower():find(q,1,true)~=nil
            for _,item in ipairs(sec.Elements) do
                local label=tostring(item:GetAttribute("AZ_Label") or ""):lower()
                local yes=secHit or label:find(q,1,true)~=nil
                -- A dropdown only opens on user action, never from search filtering.
                if item.Name=="Choices" then
                    item.Visible=false
                else
                    item.Visible=yes and (q~="" or not sec.Collapsed)
                end
                if yes and item.Name~="Choices" then count=count+1 end
            end
            sec.Card.Visible=count>0 or pageHit
            if sec.Card.Visible then matched=matched+1 end
        end
        page.SearchHits=matched
        navButtons[id].Back.Visible=(q=="" or matched>0)
        if matched>0 then
            firstHit=firstHit or id
            if id==selectedPage then selectedHit=true end
        end
    end
    if q~="" and not selectedHit and firstHit then
        selectedPage=firstHit
        for id,page in pairs(STATE.Pages) do page.Frame.Visible=id==firstHit end
        for id,entry in pairs(navButtons) do
            entry.Marker.Visible=id==firstHit
            entry.Label.TextColor3=id==firstHit and C.Text or C.Muted
            entry.Back.BackgroundTransparency=id==firstHit and .40 or .87
            entry.IconChip.BackgroundTransparency=id==firstHit and .24 or .56
        end
        STATE.Pages[firstHit].Frame.CanvasPosition=Vector2.zero
    end
    if STATE.NavRebuild then STATE.NavRebuild(q) end
end)
local setWindowVisible
local floating=button(gui,"",48,48,C.Row,function()
    setWindowVisible(STATE.WindowVisible==false)
end)
floating.AnchorPoint=Vector2.new(1,1);floating.Position=UDim2.new(1,-15,1,-15)
floating.TextSize=24;floating.Visible=Config.FloatingButton
vectorIcon(floating,"logo",UDim2.fromOffset(12,12),24)
round(floating,20);themed(stroke(floating,C.Accent,.1,1.5),"Color")
local floatScale=mk("UIScale",{Scale=1},floating)
local windowScale=mk("UIScale",{Scale=1},win)
STATE.WindowMotionToken=0
setWindowVisible=function(visible)
    STATE.WindowMotionToken=STATE.WindowMotionToken+1
    local token=STATE.WindowMotionToken
    STATE.WindowVisible=visible
    if visible then
        win.Visible=true;shadow.Visible=true;glow.Visible=Config.SoftGlow
        if not Config.ReducedMotion then
            windowScale.Scale=.955
            animate(windowScale,{Scale=1},.27)
        else windowScale.Scale=1 end
    else
        if Config.ReducedMotion then
            win.Visible=false;shadow.Visible=false;glow.Visible=false
        else
            animate(windowScale,{Scale=.963},.17)
            task.delay(.18,function()
                if STATE.Alive and token==STATE.WindowMotionToken and not STATE.WindowVisible then
                    win.Visible=false;shadow.Visible=false;glow.Visible=false
                end
            end)
        end
    end
    floating.Visible=Config.FloatingButton or not visible
    if updateBackdrop then updateBackdrop() end
end
local dragging=false;local originPos;local winPos
on(header,header.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true;originPos=input.Position;winPos=win.Position
    end
end)
on(UIS,UIS.InputChanged,function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local delta=input.Position-originPos
        win.Position=UDim2.new(winPos.X.Scale,winPos.X.Offset+delta.X,winPos.Y.Scale,winPos.Y.Offset+delta.Y)
        shadow.Position=UDim2.new(win.Position.X.Scale,win.Position.X.Offset+8,win.Position.Y.Scale,win.Position.Y.Offset+10)
        glow.Position=UDim2.new(win.Position.X.Scale,win.Position.X.Offset+5,win.Position.Y.Scale,win.Position.Y.Offset+5)
    end
end)
on(UIS,UIS.InputEnded,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then dragging=false end
end)
on(miniBtn,miniBtn.MouseButton1Click,function()
    setWindowVisible(false)
end)
local function destroy()
    STATE.Alive=false
    if STATE.MobMagnet then STATE.MobMagnet.Stop() end
    cancelMove()
    if STATE.Pickups then STATE.Pickups.Reset() end
    if STATE.ReleaseFarmHover then STATE.ReleaseFarmHover() end
    if STATE.Advanced and STATE.Advanced.Boat then STATE.Advanced.Boat.Stop() end
    if STATE.Spooky then pcall(STATE.Spooky.Destroy) end
    if STATE.Mover and STATE.Mover.Proxy then pcall(function() STATE.Mover.Proxy:Destroy() end) end
    STATE.Mover=nil
    clearESP();save()
    if STATE.RestoreNoclip then STATE.RestoreNoclip() end
    if STATE.RestoreLighting then pcall(STATE.RestoreLighting) end
    if STATE.Unified and STATE.Unified.ApplyFPS then Config.AutoFPS=false;pcall(STATE.Unified.ApplyFPS) end
    if backdropBlur and backdropBlur.Parent then backdropBlur:Destroy() end
    for _,connection in ipairs(STATE.Connections) do pcall(function() connection:Disconnect() end) end
    if gui and gui.Parent then gui:Destroy() end
    if env.__ANDEPZAI_V22==STATE then env.__ANDEPZAI_V22=nil end
end
STATE.Destroy=destroy
on(exitBtn,exitBtn.MouseButton1Click,destroy)
on(UIS,UIS.InputBegan,function(input,gpe)
    if gpe then return end
    if input.KeyCode==Enum.KeyCode[Config.ToggleKey] then
        setWindowVisible(not win.Visible)
    end
end)

--// ALL PAGES -------------------------------------------------------------
local R = {}
do
local dashboard=addPage("home","⌂","Home","Crystal White Liquid Glass  /  andepzai 22.0")
local hero=section(dashboard,"ANDEPZAI · CONTROL CENTER","One standalone hub · 3 reference feature sets")
info(hero,"Crystal White Glass / READY preset: Quest, Equip, Combat and Tween configured. Farm chỉ chạy khi bạn bật công tắc.")
local welcome=section(dashboard,"Quick access","Farm • Combat • Fruits • Server")
local sb=section(dashboard,"Live session","Information comes from the local game client")
local statPlayer=statBox(sb,"Player",LP.DisplayName)
local statLevel=statBox(sb,"Level",level())
local statSea=statBox(sb,"Sea",STATE.World)
local statBeli=statBox(sb,"Beli",value("Beli"))
local statFrag=statBox(sb,"Fragments",value("Fragments"))
local statFarm=statBox(sb,"Farm status","Stopped")
info(welcome,"All controls live in this hub. Level route data can fall back to the supplied reference; advanced progression still needs in-game testing.")
toggle(welcome,"Enable PvE combat","Combat","Configured ON; attacks NPCs only when a farm/other explicit mode is started")
toggle(welcome,"Fast attack via game remotes","FastAttackEnabled","Requires PvE Combat toggle; version-dependent")
toggle(welcome,"Take level quests","AutoQuest","Only when Level farm is enabled")
toggle(welcome,"Collect nearby fruits","AutoCollectFruit","Move to dropped fruits on the map")
toggle(welcome,"Auto Haki","AutoHaki")
action(welcome,"Server hop",hopServer,"Find a public server with fewer players")
farmSwitch(welcome,"Level Farm + Quest + Combat","Level","Bật để farm; tắt để ngừng đánh, nhận quest và tween")
action(welcome,"Stop all movement",function()
    for _,key in ipairs({"FarmEnabled","AutoSea","AutoChest","AutoCollectFruit","AutoAdvanceRaid",
        "AutoTyrant","AutoKatakuri","AutoBones","AutoRaidCombat","AutoBerry","AutoBerryHop","AutoMagnetToken","EventRadar","AutoFactory","AutoPirateRaid","AutoSoulReaper","AutoDarkbeard","AutoRipIndra","AutoDoughKing","AutoEliteCombat","AutoEventCollect","AutoFollowPlayer"}) do setFlag(key,false) end
    setFlag("AutoSeaBoat",false)
    cancelMove();notice("Safety","Movement jobs disabled")
end)
do
local review=section(dashboard,"Banana Hub feature benchmark · V22",
    "Compared with public October/November 2026 reviews; menu listings are not proof of working automation")
info(review,"Already integrated: Level / Nearest / Boss / Material / Mastery, Quest, Mob Magnet, Raid, Sea, Fishing, Fruit, PvP, Atlas, Halloween. V22 improves pickup targeting and adds a visible event radar.")
info(review,"Still unverified: full CDK/Soul Guitar/Draco/Race V4 quest chains, Magnet Token event completion, Leviathan puzzles and all server-side Combat acceptance. No fake 100% claim.")
end
local liveInfo=section(dashboard,"Health & world")
local hp=statBox(liveInfo,"Health","--")
local curMob=statBox(liveInfo,"Nearby enemy","--")
local curQuest=statBox(liveInfo,"Level quest","--")
R.statLevel,R.statSea,R.statBeli,R.statFrag,R.statFarm=statLevel,statSea,statBeli,statFrag,statFarm
R.hp,R.curMob,R.curQuest=hp,curMob,curQuest

end

do
local farming=addPage("farm","⚡","Auto Farm","Quest logic / Combat / Mastery / Config")
local farmQuick=section(farming,"FARM · BẬT / TẮT","Chọn chế độ + vũ khí, sau đó bật công tắc; không chạy khi tải script")
dropdown(farmQuick,"Farm mode","FarmMode",{"Level","Nearest","Selected mob","Boss","Material","Bones","Mastery","Halloween","Aura"})
dropdown(farmQuick,"Weapon","Weapon",{"Melee","Sword","Blox Fruit","Gun","Any"})
farmSwitch(farmQuick,"Auto Farm · chế độ đã chọn",nil,"Bật: tìm quái / di chuyển / combat. Tắt: dừng farm và tween.")
farmSwitch(farmQuick,"Farm Level + Quest + Combat","Level","Đổi nhanh sang Level và trang bị cấu hình có sẵn")
local farmLive=statBox(farmQuick,"Combat status","Idle")
STATE.CombatStatusLabel=farmLive
info(farmQuick,"Mặc định: Above 18 studs + Adaptive + Fast Attack. Chỉ chạy khi bật Auto Farm.")
local fMode=section(farming,"Farm control")
dropdown(fMode,"Target mob","Mob",getMobs,"Refresh the dropdown after mobs spawn")
action(fMode,"Refresh mobs",function() notice("Scanner","Rescanned visible enemies") end)
toggle(fMode,"Take level quest","AutoQuest","Prioritize GuideModule, with reference route fallback")
info(fMode,"Quest route uses game data when available; fallback reference remains active.")
toggle(fMode,"Attack mobs","Combat")
toggle(fMode,"Auto equip weapon","AutoEquip")
toggle(fMode,"Use fast attack remotes","FastAttackEnabled","PvE event support; chỉ dùng sau khi bật Combat hoặc Farm. Actual HP is checked.")
dropdown(fMode,"Combat method","CombatMode",{"Adaptive","Hybrid","Tool only","Remote only"},"Adaptive equips weapon, clicks, and tries PvE event only in range")
slider(fMode,"Combat hit range","AttackRange",8,65,1)
toggle(fMode,"Abandon wrong level quest","AutoAbandonWrongQuest","Disabled by default; never abandons without enabling this")
toggle(fMode,"Auto haki","AutoHaki")
local fPreset=section(farming,"Chế độ farm khác · BẬT/TẮT","Mỗi công tắc chọn đúng 1 chế độ; tắt là ngừng chạy")
farmSwitch(fPreset,"Auto Boss","Boss")
farmSwitch(fPreset,"Auto Material","Material")
farmSwitch(fPreset,"Auto Mastery","Mastery")
local fDiag=section(farming,"Quest & combat diagnostics")
action(fDiag,"Kiểm tra spawn Atlas cho level",function()
    local q=questInfo()
    local atlas=STATE.Atlas and STATE.Atlas.Spawns[STATE.World]
    local arr=q and atlas and atlas[norm(q.Mob)]
    notice("Atlas",q and (q.Mob.." | scanned="..tostring(arr and #arr or 0).." points | quest route source="..q.Source)
       or "Không có route cho Sea / level hiện tại")
end)
info(fDiag,"Overhead mode: Adaptive + Fast Attack + equip. Theo dõi HP drops; nếu không gây sát thương hãy thử height 12–15 và xem Diagnostics.")
action(fDiag,"Check current quest",function()
    local active,q,mob,source=activeQuest()
    notice("Quest state",string.format("active=%s | %s | %s | %s",tostring(active),tostring(q),tostring(mob),tostring(source)))
end)
action(fDiag,"Check PvE attack remotes",function()
    local net=getCombatRemotes()
    notice("Combat",net and "Net events detected; server acceptance unverified" or "Net events unavailable; use Tool only")
end)
action(fDiag,"Kiểm tra quái chết / Mob Magnet",function()
    local f=STATE.NPCFilter;local m=STATE.MobMagnet
    notice("NPC filter",string.format("Target=%s | changes=%d | corpses=%d | last=%s",
        f.Held and f.Held.Name or "None",f.TargetChanges,f.DeadSkipped,f.LastReason))
    notice("Mob Magnet",string.format("Enabled=%s | active=%d | pulled=%d | corrections=%d | %s",
        tostring(Config.MobMagnet),m.Active,m.Attracted,m.Rejections,m.LastError))
end)
action(fDiag,"Movement diagnostics",function()
    local d=STATE.MoveStats
    notice("Movement",string.format("%s | requested=%d studs/s | starts=%d | reached=%d | stalls=%d | corrections=%d",
        d.Status,d.RequestedSpeed,d.Started,d.Reached,d.Stalled,d.Corrections))
    if d.LastError~="None" then slog("Move: "..d.LastError,"warn") end
end)
action(fDiag,"Combat damage diagnostics",function()
    local d=STATE.CombatTelemetry
    notice("Combat",string.format("Tool=%d | Remote=%d | HP drops=%d | last=%.0f",
        d.ToolCalls,d.RemoteCalls,d.HealthChanged,d.LastDamage))
    notice("Combat issue",d.LastIssue or "None")
end)
action(fDiag,"Test tween 25 studs",function()
    if Config.FarmEnabled then notice("Movement","Disable Auto Farm before movement test","warn");return end
    local _,_,r,ok=alive()
    if not ok then return end
    local goal=r.CFrame*CFrame.new(0,0,-25)
    if moveTo(goal) then notice("Movement","Test started; open diagnostics to verify destination") end
end)
local fPosition=section(farming,"Position & movement")
toggle(fPosition,"Dùng tọa độ spawn đã quét 3 Sea","AtlasUseScannedSpawns",
    "Ưu tiên spawn đang tải trên client, sau đó tới điểm trong Workspace.7z, cuối cùng mới dùng tọa độ dự phòng")
slider(fPosition,"Halloween revive / corpse grace (s)","HalloweenReviveGrace",.4,1.5,.1)
toggle(fPosition,"Gom quái cùng loại / Mob Magnet","MobMagnet",
    "Gom các NPC còn sống cùng loại quanh mục tiêu, chỉ chạy khi Auto Farm bật")
slider(fPosition,"Bán kính gom quái","MobMagnetRadius",60,350,10)
slider(fPosition,"Số quái tối đa (kể cả mục tiêu)","MobMagnetMax",2,12,1)
dropdown(fPosition,"Farm position","FarmStyle",{"Above","Behind","Below","Orbit"})
toggle(fPosition,"Giữ trên không / Hover lock","FarmHoverLock","Duy trì cao độ phía trên NPC; không chạm quái khi farm")
slider(fPosition,"Target distance","FarmDistance",2,70,1)
slider(fPosition,"Target height","FarmHeight",12,60,1)
dropdown(fPosition,"Movement engine","MovementMode",{"Proxy Tween","Direct Tween"},"Proxy tween follows a hidden target like Kaitun")
slider(fPosition,"Tween speed (default 350)","TweenSpeed",40,400,5)
slider(fPosition,"Retarget distance","MoveRetargetThreshold",4,55,1,"Larger = less jerking when mobs move")
slider(fPosition,"Retarget cooldown","MoveRetargetDelay",.3,1.8,.1,"Avoid starting a new tween on every farm tick")
toggle(fPosition,"Smart portal shortcuts","SmartPortal","Uses known Sea 1/2 entrances only if destination is substantially closer")
info(fPosition,"350 studs/s is the requested tween speed, not a guaranteed anti-cheat bypass. Check Movement diagnostics if Roblox corrects your position.")
slider(fPosition,"Attack interval (sec)","AttackDelay",.08,1.5,.01)
slider(fPosition,"Quest retry interval","QuestDelay",2,15,1)
slider(fPosition,"Low-health pause %","LowHealth",0,90,5)
toggle(fPosition,"Safe height override","SafeFarm")
local fAdvanced=section(farming,"Mastery & skills")
slider(fAdvanced,"Mastery threshold %","MasteryThreshold",5,95,5)
toggle(fAdvanced,"Automatic skill keys","AutoSkill","Uses input synthesis if supported by the executor")
slider(fAdvanced,"Skill key cooldown","AutoSkillDelay",.5,8,.1)
for _,key in ipairs({"Z","X","C","V","F"}) do toggle(fAdvanced,"Use skill "..key,"Skill"..key) end
local fActions=section(farming,"Extra farming actions")
toggle(fActions,"Collect chests (while not farming)","AutoChest")
toggle(fActions,"Collect berries (while not farming)","AutoBerry",
    "Now interacts when nearby; does not endlessly revisit a failed berry")
toggle(fActions,"Berry + Hop if empty","AutoBerryHop",
    "Only with Auto Berry ON; requests a server hop after a long absence of visible berries")
slider(fActions,"Berry hop wait (sec)","BerryHopAfter",120,900,30)
toggle(fActions,"Collect Magnet Tokens (visible only)","AutoMagnetToken",
    "Update 30 review mentions this event, but game state is unverified. Only acts on loaded, named token objects")
slider(fActions,"Max pickup travel (studs)","PickupMaxDistance",150,4000,50)
slider(fActions,"Retry failed pickup after (s)","PickupFailureCooldown",10,90,5)
R.pickupStatus=statBox(fActions,"Pickup status","Idle")
do
local pickupDetail=section(farming,"Pickup / event diagnostics")
action(pickupDetail,"Show pickup diagnostics",function()
    local p=STATE.Pickups
    notice("Pickup",string.format("Attempts=%d | Despawned=%d | Timeouts=%d",p.Attempts,p.Despawned,p.Failures))
    notice("Pickup status",p.LastStatus)
end)
action(pickupDetail,"Scan visible events now",function()
    local ok,msg=STATE.EventRadar.Scan()
    notice("Event radar",msg,ok and "info" or "warn")
end)
action(pickupDetail,"Show visible event matches",function()
    notice("Radar",STATE.EventRadar.Status)
    notice("Radar matches",STATE.EventRadar.Summary())
end)
toggle(pickupDetail,"Auto refresh visible event radar","EventRadar",
    "Opt-in, scan client-visible objects about every 26s. No hidden server status")
end
toggle(fActions,"Auto click (when farm off)","AutoClick")
toggle(fActions,"Noclip while moving","Noclip")
action(fActions,"Cancel current tween",function() cancelMove();notice("Movement","Tween cancelled") end)

end

do
local bossPage=addPage("boss","✦","Boss Hunter","Boss list and target-specific combat")
local bSelect=section(bossPage,"Boss target")
dropdown(bSelect,"Choose boss","Boss",function()
    local list={};local seen={}
    for _,name in ipairs(bossDB[STATE.World] or {}) do
        if not seen[norm(name)] then list[#list+1]=name;seen[norm(name)]=true end
    end
    for name in pairs((STATE.Atlas and STATE.Atlas.Bosses[STATE.World]) or {}) do
        if not seen[name] then
            local nice=name:gsub("^%l",string.upper)
            list[#list+1]=nice;seen[name]=true
        end
    end
    table.sort(list)
    return list
end)
farmSwitch(bSelect,"Farm selected boss","Boss","Bật / tắt đánh boss đã chọn")
action(bSelect,"Move to selected boss",function()
    local enemy=enemySearch(Config.Boss)
    if enemy then local r=enemy:FindFirstChild("HumanoidRootPart");if r then moveTo(r.CFrame*CFrame.new(0,30,0)) end
    else notice("Boss","Boss is not spawned in workspace.Enemies","warn") end
end)
local bAuto=section(bossPage,"Special bosses")
toggle(bAuto,"Auto Tyrant of the Skies","AutoTyrant","Attack when a Tyrant is present; Sea 3 only")
toggle(bAuto,"Auto Cake Prince / Dough King","AutoKatakuri")
toggle(bAuto,"Auto Bones monsters","AutoBones")
toggle(bAuto,"Auto Elite Hunter quest","AutoElite")
action(bAuto,"Request Elite quest",function() doOnce("EliteHunter") end)
action(bAuto,"Buy Bones random reward",function() doOnce("Bones","Buy",1,1) end,"Requests a bones reward; it does not guarantee a summon")
action(bAuto,"Find rip_indra boss",function()
    local enemy=enemySearch("rip_indra True Form")
    local part=enemy and enemy:FindFirstChild("HumanoidRootPart")
    if part then moveTo(part.CFrame*CFrame.new(0,30,0))
    else notice("Boss","rip_indra is not currently visible","warn") end
end)
local bNote=section(bossPage,"Boss availability")
info(bNote,"Boss lists are based on your uploaded scripts. Spawn conditions and remote signatures can change after game updates.")

end

do
local materialPage=addPage("materials","⬡","Materials","Drop locations / PvE farming")
local mSelect=section(materialPage,"Farm material")
local materials={}
for name in pairs(materialMobs) do table.insert(materials,name) end
table.sort(materials)
dropdown(mSelect,"Target material","Material",materials)
farmSwitch(mSelect,"Auto farm material","Material","Bật / tắt farm nguyên liệu đã chọn")
action(mSelect,"Move to source mob",function()
    local names=materialMobs[Config.Material]
    if names then for _,name in ipairs(names) do
        local cf=spawnCFrame(name)
        if cf then moveTo(cf);notice("Materials","Going to "..name);return end
    end end
    notice("Materials","No location found","warn")
end)
action(mSelect,"Request a random Bones reward",function() doOnce("Bones","Buy",1,1) end)
local mDetails=section(materialPage,"Source database")
info(mDetails,"Material-to-mob lookup covers 15 categories from Banana Cat, Redz and Sep9. Spawn data is checked live first; static coordinates are a fallback.")

end

do
local fruits=addPage("fruits","◆","Devil Fruits","Collect / Storage / Fruit shop")
local fruitAuto=section(fruits,"World fruits")
toggle(fruitAuto,"Auto collect dropped fruits","AutoCollectFruit","Move to visible fruit tools on the ground")
toggle(fruitAuto,"Auto store fruit tool","AutoStoreFruit","Uses StoreFruit remote for an existing fruit item")
toggle(fruitAuto,"Store valuable fruits only","AutoStoreOnlyValuable")
slider(fruitAuto,"Minimum value for storage","MinFruitPrice",0,15000000,100000)
action(fruitAuto,"Store carried fruit now",function() storeFruit() end)
action(fruitAuto,"Move to nearest fruit",function()
    collectFruit()
end)
local fruitShop=section(fruits,"Fruit dealer")
dropdown(fruitShop,"Select dealer fruit","BuyFruit",{"Rocket","Spin","Flame","Ice","Light","Buddha","Magma","Portal","Rumble","Dough","Kitsune","Dragon"})
action(fruitShop,"Purchase selected fruit",function() doOnce("PurchaseRawFruit",Config.BuyFruit) end,"Spends in-game currency if the dealer allows purchase")
action(fruitShop,"Buy random fruit",function() doOnce("Cousin","Buy") end,"Consumes currency if supported by this game version")
action(fruitShop,"View fruit stock",function()
    local ok,data=remote("GetFruits",false)
    if not ok or type(data)~="table" then notice("Fruit stock","Could not read stock","warn");return end
    local available=0;for _,fruit in pairs(data) do if fruit.OnSale then available=available+1 end end
    notice("Fruit dealer",tostring(available).." fruits reported on sale")
end)

end

do
local raid=addPage("raid","◇","Raids / Dungeons","Raid chips, waves and awakening")
local raidMain=section(raid,"Standard raids")
dropdown(raidMain,"Select raid","Raid",raids)
action(raidMain,"Buy / select raid chip",function()
    local ok=selectRaid()
    notice("Raid",ok and ("Chip requested: "..Config.Raid) or "Raid remote failed",ok and "info" or "warn")
end)
action(raidMain,"Activate raid button",function()
    local ok=raidSummon()
    notice("Raid",ok and "Raid activation attempted" or "Raid summon button not found",ok and "info" or "warn")
end)
toggle(raidMain,"Auto buy and attempt raid start","AutoRaid","Repeats every 15 seconds if turned on")
toggle(raidMain,"Move toward highest raid island","AutoAdvanceRaid")
toggle(raidMain,"Fight visible raid mobs","AutoRaidCombat","Enabled only while a raid island is detected")
toggle(raidMain,"Auto request raid chip","AutoBuyChip")
action(raidMain,"Travel to active raid island",function()
    notice("Raid",raidIsland() and "Moving to highest island" or "No raid location found")
end)
action(raidMain,"Check Raid NPC",function() doOnce("RaidsNpc","Check") end)
local raidHelp=section(raid,"Controls")
info(raidHelp,"Auto raid combat uses the existing attack engine and runs only when an active Island 1/2/3 location is detected. Awakening and raid success remain game-dependent.")

end

do
local sea=addPage("sea","≋","Sea Events","Sea creatures, islands and naval encounters")
local seaAuto=section(sea,"Sea encounter")
toggle(seaAuto,"Auto attack found sea mobs","AutoSea","Targets sea beasts, sharks, piranhas and terror sharks when visible")
toggle(seaAuto,"Auto use skills against sea mobs","AutoSeaSkill","Uses selected skill key configuration")
action(seaAuto,"Move near a sea mob",function()
    local mob=seaTarget();local r=mob and mob:FindFirstChild("HumanoidRootPart")
    if r then moveTo(r.CFrame*CFrame.new(0,35,0)) else notice("Sea","No target nearby","warn") end
end)
action(seaAuto,"Find special island",function()
    local cf,name=findSeaLocation()
    if cf then notice("Sea","Found "..name);moveTo(cf)
    else notice("Sea","No special island loaded","warn") end
end)
local seaStatus=section(sea,"Events status")
local seaEventStatus=statBox(seaStatus,"Special island","--")
local seaMobStatus=statBox(seaStatus,"Sea creature","--")
R.seaEventStatus,R.seaMobStatus=seaEventStatus,seaMobStatus
info(seaStatus,"Advanced Sea Pilot is an experimental opt-in seat/boat movement. Leviathan and event puzzle completion still need separate game-specific stages.")

end

do
local fishing=addPage("fishing","◉","Fishing","Fishing rod support")
local fish=section(fishing,"Rod controls")
toggle(fish,"Auto cast fishing rod","AutoFish","Requires a fishing tool already obtained in the game")
action(fish,"Cast once",fishOnce)
local rodState=statBox(fish,"Detected rod","--")
R.rodState=rodState
info(fish,"Advanced Fishing page includes cast request, bait selection, saved position and optional catch listener. Current game acceptance still needs testing.")

end

do
local quests=addPage("quests","☷","Quests & Items","Progression and item requests")
local qA=section(quests,"Quest actions")
action(qA,"Show suggested level quest",function()
    local q=questInfo()
    if not q then notice("Quest","GuideModule not available","warn");return end
    notice("Quest",q.Mob.." / "..q.Name.." #"..q.Id)
end)
action(qA,"Start suggested quest",function()
    local q=questInfo();if not q then return end
    local cf=typeof(q.Pos)=="CFrame" and q.Pos or CFrame.new(q.Pos)
    if distanceTo(cf)>12 then moveTo(cf*CFrame.new(0,3,0))
    else doOnce("StartQuest",q.Name,q.Id) end
end)
action(qA,"Abandon current quest",function() doOnce("AbandonQuest") end)
action(qA,"Set spawn point",function() doOnce("SetSpawnPoint") end)
local qB=section(quests,"Progression & items")
action(qB,"Check Bartilo quest",function() doOnce("BartiloQuestProgress","Bartilo") end)
action(qB,"Check Saber quest",function() doOnce("ProQuestProgress","RichSon") end)
action(qB,"Check race upgrade",function() doOnce("Alchemist","1") end)
action(qB,"Check Electric Claw",function() doOnce("BuyElectricClaw",true) end)
action(qB,"Check Dragon Talon",function() doOnce("BuyDragonTalon",true) end)
action(qB,"Soul Guitar grave event",function() doOnce("gravestoneEvent",2) end)
action(qB,"Request Yama progress",function() doOnce("EliteHunter","Progress") end)
info(qB,"These are individual remote actions and progress checks, not fully automated multi-stage puzzles such as CDK, Soul Guitar, Draco V4 or Tushita.")

end

do
local race=addPage("race","◈","Race & Abilities","Haki, race activation and upgrades")
local raceAuto=section(race,"Passive race controls")
toggle(raceAuto,"Enable Buso Haki","AutoBuso")
toggle(raceAuto,"Enable observation Haki","AutoObservation")
toggle(raceAuto,"Activate Race V3 periodically","AutoRaceV3")
action(raceAuto,"Activate Race V3 now",function() event("ActivateAbility") end)
action(raceAuto,"Activate observation now",function() event("Ken",true) end)
action(raceAuto,"Activate Buso now",function() doOnce("Buso") end)
local raceShop=section(race,"Race shop")
action(raceShop,"Reroll race",function() doOnce("BlackbeardReward","Reroll","2") end,"May consume fragments")
action(raceShop,"Purchase Ghoul race",function() doOnce("Ectoplasm","Change",4) end)
action(raceShop,"Purchase Cyborg race",function() doOnce("CyborgTrainer","Buy") end)
action(raceShop,"Check Alchemist",function() doOnce("Alchemist","1") end)
action(raceShop,"Race V4 temple check",function() doOnce("RaceV4Progress","Check") end)

end

do
local combat=addPage("combat","✕","Combat & PVP","Weapon activation and target travel")
local fight=section(combat,"Combat controls")
toggle(fight,"Auto equip tool","AutoEquip")
toggle(fight,"Auto attack M1","AutoClick")
toggle(fight,"Auto skills","AutoSkill")
toggle(fight,"Auto observation","AutoKen")
toggle(fight,"Auto race ability","AutoRace")
action(fight,"Perform one M1 attack",punch)
action(fight,"Perform selected skills",function()
    nextSkills=0;local old=Config.AutoSkill;Config.AutoSkill=true;useSkills();Config.AutoSkill=old
end)
local fightTarget=section(combat,"Player tracking")
dropdown(fightTarget,"Target player","SelectedPlayer",getPlayers)
action(fightTarget,"Move to selected player",function() teleportPlayer(Config.SelectedPlayer) end)
info(fightTarget,"No automated attack against other players is executed by the player-selection control.")

end

do
local travel=addPage("travel","⌁","Travel & Teleport","World transitions, NPCs, map and players")
local world=section(travel,"Sea travel")
action(world,"Sea 1 / Old World",function() doOnce("TravelMain") end)
action(world,"Sea 2 / New World",function() doOnce("TravelDressrosa") end)
action(world,"Sea 3 / Third Sea",function() doOnce("TravelZou") end)
action(world,"Return to spawn point",function() doOnce("SetSpawnPoint") end)
local namedTravel=section(travel,"Dynamic locations")
dropdown(namedTravel,"NPC","SelectedNPC",getNPCs)
action(namedTravel,"Move to NPC",function() goNPC(Config.SelectedNPC) end)
dropdown(namedTravel,"Island","SelectedIsland",getIslands)
action(namedTravel,"Move to island",function() goIsland(Config.SelectedIsland) end)
local atlasTravel=section(travel,"3 SEA ATLAS · Dữ liệu Workspace.7z",
    "Tọa độ snapshot client (2026-11-07), không phải vị trí teleport hoặc quest đã xác minh")
dropdown(atlasTravel,"Khu vực đã quét ở Sea này","AtlasIsland",STATE.AtlasRegionNames)
action(atlasTravel,"Kiểm tra tọa độ khu vực",function()
    local cf,source=STATE.AtlasRegion(Config.AtlasIsland)
    if not cf then notice("Atlas","Không có vị trí trong dữ liệu đã quét","warn");return end
    local p=cf.Position
    notice("Atlas",string.format("%s [%s] XYZ %.0f, %.0f, %.0f",Config.AtlasIsland,source,p.X,p.Y,p.Z))
end)
action(atlasTravel,"Bay đến khu vực Atlas (thủ công)",function()
    if Config.FarmEnabled then notice("Atlas","Tắt Farm trước khi bay thủ công","warn");return end
    local cf=STATE.AtlasRegion(Config.AtlasIsland)
    if not cf then notice("Atlas","Chọn một khu vực đã được quét","warn");return end
    if moveTo(cf) then notice("Atlas","Tween tới tâm khu vực ghi nhận (tọa độ xấp xỉ)")
    else notice("Atlas","Không thể bắt đầu Tween tới tọa độ này","warn") end
end)
action(atlasTravel,"Thống kê dữ liệu 3 Sea",function()
    for sea=1,3 do
        local d=STATE.Atlas.Counts[sea]
        notice("Atlas / Sea "..sea,string.format("runs=%d, mobs=%d, spawns=%d, regions=%d",
            d.runs,d.spawnTypes,d.spawnPoints,d.regions))
    end
end)
info(atlasTravel,"Chỉ quét client, không chứa server-only quest logic. Không tự bay sang Sea khác; dữ liệu Atlas nhúng sẵn trong Lua.")
dropdown(namedTravel,"Player","SelectedPlayer",getPlayers)
action(namedTravel,"Move to player",function() teleportPlayer(Config.SelectedPlayer) end)
action(namedTravel,"Cancel movement",cancelMove)
action(namedTravel,"Move to next level mob spawn",function()
    local quest=questInfo()
    if not quest then notice("Routes","No matching route for this sea/level","warn");return end
    local pos=spawnCFrame(quest.Mob)
    if pos then moveTo(pos) else notice("Routes","No streamed spawn coordinate for "..quest.Mob,"warn") end
end)
action(namedTravel,"Move to level quest giver",function()
    local quest=questInfo()
    local pos=quest and quest.Pos
    if typeof(pos)=="Vector3" then pos=CFrame.new(pos) end
    if typeof(pos)=="CFrame" then moveTo(pos*CFrame.new(0,4,0))
    else notice("Routes","Quest giver not available from live game data","warn") end
end)
info(namedTravel,"Movement uses local tween. Optional portal shortcuts use game requestEntrance and can be disabled.")

end

do
local esp=addPage("esp","◎","ESP / Visuals","Lightweight Billboards drawn with Roblox instances")
local espMain=section(esp,"World overlays")
toggle(espMain,"ESP players","ESPPlayer")
toggle(espMain,"ESP enemies","ESPEnemy")
toggle(espMain,"ESP bosses","ESPBoss")
toggle(espMain,"ESP fruits","ESPFruit")
toggle(espMain,"ESP chests","ESPChest")
toggle(espMain,"ESP special islands","ESPIsland")
slider(espMain,"ESP drawing distance","ESPDistance",100,2000,50)
action(espMain,"Clear all ESP objects",function()
    for _,key in ipairs({"ESPPlayer","ESPEnemy","ESPBoss","ESPFruit","ESPChest","ESPIsland"}) do Config[key]=false end
    clearESP();save();notice("ESP","All overlays cleared")
end)

end

do
local shop=addPage("shop","▣","Shop","Abilities, fighting styles and consumables")
local abilities=section(shop,"Abilities")
action(abilities,"Skyjump / Geppo",function() doOnce("BuyHaki","Geppo") end)
action(abilities,"Buso Haki",function() doOnce("BuyHaki","Buso") end)
action(abilities,"Observation / Ken",function() doOnce("KenTalk","Buy") end)
action(abilities,"Soru / Flash Step",function() doOnce("BuyHaki","Soru") end)
action(abilities,"Reset stats (option 1)",function() doOnce("BlackbeardReward","Refund","1") end)
action(abilities,"Reset stats (option 2)",function() doOnce("BlackbeardReward","Refund","2") end)
local styles=section(shop,"Fighting styles")
for _,style in ipairs(shops) do
    action(styles,"Buy "..style[1],function() doOnce(style[2]) end)
end
local miscShop=section(shop,"Other purchases")
action(miscShop,"Buy Dual Flintlock",function() doOnce("BuyItem","Dual Flintlock") end)
action(miscShop,"Buy random bones reward",function() doOnce("Bones","Buy",1,1) end)
action(miscShop,"Buy random fruit",function() doOnce("Cousin","Buy") end)
action(miscShop,"Redeem all known codes",callRedeem,"Some codes from original sources may already be expired")

end

do
local server=addPage("server","☷","Server & Status","Session management / game metadata")
local serverStats=section(server,"Current server")
local sid=statBox(serverStats,"Job ID",game.JobId=="" and "Studio" or game.JobId:sub(1,12).."…")
local sping=statBox(serverStats,"Ping","--")
local scount=statBox(serverStats,"Players",#Players:GetPlayers())
local sessTime=statBox(serverStats,"Session elapsed","00:00")
R.scount,R.sping,R.sessTime=scount,sping,sessTime
local actions=section(server,"Server tools")
action(actions,"Rejoin current place",function()
    safe("Rejoin",function() TP:Teleport(game.PlaceId,LP) end)
end)
action(actions,"Find a low-player public server",hopServer,"Uses the official Roblox public server list")
action(actions,"Copy server job ID",function()
    if type(setclipboard)=="function" then setclipboard(game.JobId);notice("Server","Job ID copied")
    else notice("Server","Clipboard unavailable","warn") end
end)
toggle(actions,"Anti AFK","AntiAFK")

end

do
local settings=addPage("settings","⚙","Settings","Preferences, themes, configuration and cleanup")
local prefs=section(settings,"Appearance")
dropdown(prefs,"Icon / accent tone","Accent",{"Crystal","Pearl","Frost","Cloud","Silver","Quartz","Opal"})
local swatchRow=control(prefs,"Color palette",65)
tip(swatchRow,"Palette swatches",nil,26)
for i,tname in ipairs({"Crystal","Pearl","Frost","Cloud","Silver","Quartz","Opal"}) do
    local swatch=mk("TextButton",{Name=tname,Text="",BackgroundColor3=themes[tname],
        Size=UDim2.fromOffset(23,23),Position=UDim2.new((i-1)/7,2,0,32),
        BorderSizePixel=0,AutoButtonColor=false},swatchRow)
    round(swatch,20)
    local border=stroke(swatch,C.White,Config.Accent==tname and .05 or .78,2)
    local function recolor(value)
        animate(border,{Transparency=value==tname and .05 or .78},.13)
    end
    STATE.ControlBindings.Accent=STATE.ControlBindings.Accent or {}
    table.insert(STATE.ControlBindings.Accent,recolor)
    on(swatch,swatch.MouseButton1Click,function()
        themeSelect(tname);setFlag("Accent",tname)
    end)
end
slider(prefs,"White glass clarity","GlassIntensity",15,100,1,"Higher = clearer white glass; no colored backdrop")
toggle(prefs,"Frosted backdrop blur","BackgroundBlur","Blurs the 3D world behind the open menu, not the game UI")
slider(prefs,"Background blur strength","BlurStrength",0,16,1,"0 = off  /  8 = soft frost  /  16 = strong frost")
toggle(prefs,"Specular halo","SoftGlow","Subtle white outline glow, not a colored overlay")
toggle(prefs,"High contrast","HighContrast","Whiter glass with stronger dark-text readability")
toggle(prefs,"Reduce animations","ReducedMotion","Disable hover and glass motion for lower-end phones")
toggle(prefs,"Show floating launcher","FloatingButton")
local glassPresets=section(settings,"One-tap crystal presets","Select the amount of white frost, not a colored theme")
action(glassPresets,"Crystal clear / transparent",function()
    setFlag("GlassIntensity",92);setFlag("BackgroundBlur",false)
    notice("Glass","Crystal clear mode enabled")
end,"Very light white tint, no background blur")
action(glassPresets,"Soft white frost",function()
    setFlag("GlassIntensity",76);setFlag("BlurStrength",3);setFlag("BackgroundBlur",true)
    notice("Glass","Soft white frost enabled")
end,"Light blur with transparent white panes")
action(glassPresets,"Pearl milk glass",function()
    setFlag("GlassIntensity",48);setFlag("BlurStrength",6);setFlag("BackgroundBlur",true)
    notice("Glass","Pearl milk glass enabled")
end,"Stronger white frost for bright scenes")
dropdown(prefs,"Open/close hotkey","ToggleKey",{"RightControl","RightShift","Insert","Home","F8"})
local playerSettings=section(settings,"Character settings")
dropdown(playerSettings,"Stat target","Stat",{"Melee","Defense","Sword","Gun","Demon Fruit"})
toggle(playerSettings,"Auto allocate stats","AutoStats")
dropdown(playerSettings,"Team","Team",{"Pirates","Marines"})
action(playerSettings,"Join selected team",function() doOnce("SetTeam",Config.Team) end)
action(playerSettings,"Set spawn point",function() doOnce("SetSpawnPoint") end)
local configuration=section(settings,"Config & maintenance")
action(configuration,"Save settings",function()
    notice("Config",save() and "Saved to "..FILE or "No file write API in this environment")
end)
action(configuration,"Export JSON config",function()
    local json=Http:JSONEncode(Config)
    if type(setclipboard)=="function" then setclipboard(json);notice("Config","JSON copied")
    else print("[andepzai config] "..json);notice("Config","Printed to console") end
end)
action(configuration,"Stop farm + movement",function()
    for _,key in ipairs({"FarmEnabled","AutoSea","AutoChest","AutoCollectFruit","AutoAdvanceRaid","AutoRaidCombat"}) do
        setFlag(key,false)
    end
    cancelMove();notice("Engine","Movement stopped")
end)
action(configuration,"Destroy hub",destroy)
local diagnostics=section(settings,"Diagnostics")
local engineStatus=statBox(diagnostics,"Engine","Idle")
local gameSupport=statBox(diagnostics,"World support",STATE.World==0 and "Unsupported place" or "Sea "..STATE.World)
local lastLog=statBox(diagnostics,"Last event","Ready")
R.engineStatus,R.lastLog=engineStatus,lastLog
local runtime=section(settings,"Runtime notices")
info(runtime,"This is a new, fully local Luau implementation. No external source file is executed. Features relying on hidden remotes, client hit registration or executor APIs cannot be guaranteed after game updates.")

end

--// UNIFIED PAGES: controls have real handlers in EX, not inactive mock toggles.
do
local unify=addPage("unified","⬡","Advanced Farming","Shared engine / original source capability groups")
local farming=section(unify,"Additional farm strategies")
info(farming,"These options share the same farming engine. Use one main mode at a time to prevent movement conflicts.")
dropdown(farming,"Farm strategy","FarmMode",{"Level","Nearest","Selected mob","Boss","Material","Bones","Mastery","Aura","All Boss","Elite","Factory","Pirate Raid"})
toggle(farming,"Start shared farm engine","FarmEnabled")
toggle(farming,"Mob dodge on skill cast","AutoDodgeSkill","Raises the farm point temporarily when a physics skill is detected")
farmSwitch(farming,"Farm all spawned bosses","All Boss")
farmSwitch(farming,"Farm Elite Hunter","Elite")
farmSwitch(farming,"Farm Factory Core","Factory")
farmSwitch(farming,"Farm Pirate Raid","Pirate Raid")
local farmEvents=section(unify,"World event targets")
toggle(farmEvents,"Auto Factory Core when spawned","AutoFactory")
toggle(farmEvents,"Auto Pirate Raid targets","AutoPirateRaid")
toggle(farmEvents,"Auto Elite fighters","AutoEliteCombat")
farmSwitch(farmEvents,"Auto all boss farm","All Boss")
end

do
local special=addPage("specialboss","✦","Special Bosses","Soul Reaper / Darkbeard / Dough King / rip_indra")
local battle=section(special,"Boss combat automation")
info(battle,"Special boss attacks use the shared combat engine. Boss fights are paused when main farming/raid combat is active.")
for _,entry in ipairs({{"AutoSoulReaper","Soul Reaper"},{"AutoDarkbeard","Darkbeard"},
    {"AutoRipIndra","rip_indra"},{"AutoDoughKing","Dough King / Cake Prince"},
    {"AutoEliteCombat","Elite Hunter mobs"}}) do toggle(battle,"Auto attack "..entry[2],entry[1]) end
local summon=section(special,"Summoning and rewards")
toggle(summon,"Summon Dough King with Sweet Chalice","AutoDoughSummon")
toggle(summon,"Buy bones reward to seek Hallow Essence","AutoHallowBuy")
toggle(summon,"Auto random Bones reward","AutoRandomBones")
action(summon,"Request Cake Prince/Dough spawn",function() EX.QuestActions("CakePrinceSpawner") end)
action(summon,"Use Hallow Essence at Haunted Castle",function()
    notice("Hallow",EX.SummonHallow() and "Altar detector attempted" or "Essence/altar detector missing")
end)
action(summon,"Read Bones amount",function() EX.Status("Bones","Bones","Check") end)
action(summon,"Read Elite Quest status",function() EX.Status("Elite Hunter","EliteHunter","Progress") end)
toggle(summon,"Hop for missing selected boss","AutoBossHop","Only if main farm is stopped")
slider(summon,"Minimum boss-hop wait (sec)","BossHopDelay",60,300,10)
end

do
local eventPage=addPage("events","◇","World Events","Prehistoric / Mirage / Kitsune / Leviathan")
local boatSection=section(eventPage,"Sea zones and boats")
dropdown(boatSection,"Selected sea zone","SeaZone",{"Zone 1","Zone 2","Zone 3","Zone 4","Zone 5","Zone 6"})
action(boatSection,"Move toward selected sea zone",EX.GoZone)
dropdown(boatSection,"Select boat","SelectedBoat",{"Guardian","Lantern","Beast Hunter","Grand Brigade","Dinghy","Sloop"})
action(boatSection,"Buy selected boat",EX.BuyBoat)
info(boatSection,"Zone positions are from bnn.lua. For automatic boat movement, use the separate Sea Pilot / Boat page and enable pilot explicitly.")
local radar=section(eventPage,"World / sea event locator")
action(radar,"Travel to Mirage",function() EX.TeleportToEvent("Mirage Island") end)
action(radar,"Travel to Frozen Dimension",function() EX.TeleportToEvent("Frozen Dimension") end)
action(radar,"Travel to Prehistoric Island",function() EX.TeleportToEvent("Prehistoric Island") end)
action(radar,"Travel to Kitsune Island",function() EX.TeleportToEvent("Kitsune Island") end)
action(radar,"Check Leviathan event",function() EX.Status("Leviathan","InfoLeviathan","1") end)
action(radar,"Check Leviathan gate",function() EX.Status("Leviathan gate","InfoLeviathan","2") end)
action(radar,"Open Leviathan gate request",function() EX.QuestActions("OpenLeviathanGate") end)
local collect=section(eventPage,"Event materials / pickups")
dropdown(collect,"Target pickup","EventPickup",{"Dino Bones","Dragon Egg","Azure Ember","Berry","Chest","Fruit","Present","Candy"})
toggle(collect,"Auto collect selected event objects","AutoEventCollect","Uses in-world touch/prompt where client APIs permit")
toggle(collect,"Move to safe location with Chalice/Fist","AutoSafeItems")
action(collect,"Collect nearby event object once",EX.EventPickup)
action(collect,"Craft Volcanic Magnet",function() EX.Craft("VolcanicMagnet") end)
info(collect,"These are collectible scanning and event-location tools. Full Leviathan sailing, Volcano puzzles and minigame solving are not equivalent to generic combat.")
end

do
local upgrades=addPage("progress","✧","Progression / Items","Quest remotes / weapons / race progress")
local quest=section(upgrades,"Quest and sword progression")
local actions={
 {"CDK Good progress","CDKQuest", "Progress","Good"},
 {"CDK Evil progress","CDKQuest", "Progress","Evil"},
 {"Start CDK Good trial","CDKQuest", "StartTrial","Good"},
 {"Start CDK Evil trial","CDKQuest", "StartTrial","Evil"},
 {"Start CDK final boss trial","CDKQuest", "StartTrial","Boss"},
 {"Open CDK door","CDKQuest", "OpenDoor"},
 {"Soul Guitar progress","GuitarPuzzleProgress","Check"},
 {"Purchase Soul Guitar","soulGuitarBuy",true},
 {"Saber Rich Son","ProQuestProgress","RichSon"},
 {"Saber Sick Man","ProQuestProgress","SickMan"},
 {"Saber relic placement","ProQuestProgress","PlaceRelic"},
 {"Bartilo quest","BartiloQuestProgress","Bartilo"},
 {"Citizen quest","CitizenQuestProgress","Citizen"},
 {"Yama/Elite progress","EliteHunter","Progress"},
 {"Tushita/Horned Man","HornedMan","Bet"},
 {"Rainbow Haki","HornedMan","Bet"},
 {"Dragon dojo progress","DragonHunter","Check"},
}
for _,entry in ipairs(actions) do
    local e=entry
    action(quest,e[1],function() EX.QuestActions(e[2],e[3],e[4]) end)
end
local ability=section(upgrades,"Race progress / activation")
action(ability,"Race V2 Alchemist check",function() EX.QuestActions("Alchemist","1") end)
action(ability,"Race V2 start",function() EX.QuestActions("Alchemist","2") end)
action(ability,"Race V2 finish",function() EX.QuestActions("Alchemist","3") end)
action(ability,"Race V3 Ghoul / Cyborg status",function() EX.QuestActions("Wenlocktoad","1") end)
action(ability,"Race V4 progress",function() EX.QuestActions("RaceV4Progress","Check") end)
action(ability,"Race V4 start",function() EX.QuestActions("RaceV4Progress","Begin") end)
action(ability,"Temple clock status",function() EX.QuestActions("TempleClock","Check") end)
toggle(ability,"Activate Race V4 periodically","AutoRaceV4")
info(ability,"Progress/check/start requests are not full automation for CDK, Yama, Tushita, Dragon Dojo or Race V4. Game-side prerequisites still apply.")
end

do
local craftPage=addPage("craft","▣","Craft / Shop Plus","Materials / upgrades / rare shop offers")
local crafting=section(craftPage,"Crafting from three reference scripts")
local craftList={{"Dragonheart","Dragonheart"},{"Dragonstorm","Dragonstorm"},{"Dino Hood","DinoHood"},
    {"Shark Tooth Necklace","SharkTooth"},{"Terror Jaw","TerrorJaw"},
    {"Shark Anchor","SharkAnchor"},{"Leviathan Crown","LeviathanCrown"},
    {"Leviathan Shield","LeviathanShield"},{"Leviathan Boat","LeviathanBoat"},
    {"Legendary Scroll","LegendaryScroll"},{"Mythical Scroll","MythicalScroll"}}
dropdown(crafting,"Choose craft","SelectedCraft",function()
    local choices={}
    for _,item in ipairs(craftList) do table.insert(choices,item[1]) end
    return choices
end)
action(crafting,"Craft chosen item",function()
    for _,item in ipairs(craftList) do
        if item[1]==Config.SelectedCraft then EX.Craft(item[2]);return end
    end
    notice("Craft","Select an item","warn")
end)
for _,item in ipairs(craftList) do
    local id,label=item[2],item[1]
    action(crafting,"Craft "..label,function() EX.Craft(id) end)
end
local rare=section(craftPage,"Dealer and equipment")
toggle(rare,"Check / buy legendary sword when available","AutoLegendarySword")
toggle(rare,"Check / buy haki color","AutoHakiColor")
action(rare,"Legendary sword dealer slot 1",function() EX.QuestActions("LegendarySwordDealer","1") end)
action(rare,"Legendary sword dealer slot 2",function() EX.QuestActions("LegendarySwordDealer","2") end)
action(rare,"Legendary sword dealer slot 3",function() EX.QuestActions("LegendarySwordDealer","3") end)
action(rare,"Haki color shop",function() EX.QuestActions("ColorsDealer","2") end)
dropdown(rare,"Fighting style to acquire","SelectedBuyStyle",{"Dark Step","Water Kung Fu","Electro","Superhuman","Death Step","Sharkman Karate","Electric Claw","Dragon Talon","Godhuman","Sanguine Art"})
toggle(rare,"Auto request selected fighting style","AutoMeleeStyle")
end

do
local extras=addPage("extras","⊕","Raid / Fruit / Fishing+","Reference-based feature extensions")
local raidExtras=section(extras,"Special raids and fruit awakening")
slider(raidExtras,"Stop raids at fragments","FragmentsCap",0,200000,500)
toggle(raidExtras,"Auto awaken fruit after raid","AutoAwaken")
action(raidExtras,"Awakener status",function() EX.Status("Awakener","Awakener","Check") end)
action(raidExtras,"Request awakening now",EX.RaidAwaken)
toggle(raidExtras,"Attempt Law (Order) raid","AutoLawRaid")
toggle(raidExtras,"Auto request Law microchip","AutoBuyLawChip")
action(raidExtras,"Buy Law microchip once",function() EX.QuestActions("BlackbeardReward","Microchip","2") end)
action(raidExtras,"Activate Law raid detector",EX.SpecialRaidLaw)
local fruitExtra=section(extras,"Fruit stocking / dealer")
toggle(fruitExtra,"Auto buy selected stock fruit","AutoBuyChosenFruit","Only buys when fruit is reported OnSale")
action(fruitExtra,"Check and buy selected fruit now",EX.BuyFruit)
toggle(fruitExtra,"Hop when no dropped fruits are visible","AutoFruitHop")
toggle(fruitExtra,"Hop when no chests are visible","AutoChestHop")
toggle(fruitExtra,"Hop when no sea mobs are visible","AutoSeaHop")
local fishExtra=section(extras,"Fishing NPC / inventory")
toggle(fishExtra,"Auto sell caught fish","AutoSellFish")
action(fishExtra,"Sell fish once",function() EX.FishingAction("SellFish") end)
action(fishExtra,"Sell celestial fish",function() EX.FishingAction("SellCelestialFish") end)
action(fishExtra,"Check angler quest",function() EX.QuestActions("FishingNPC","Angler","CheckQuest") end)
action(fishExtra,"Ask angler quest",function() EX.QuestActions("FishingNPC","Angler","AskQuest") end)
toggle(fishExtra,"Auto request Angler action","AutoFishQuest")
toggle(fishExtra,"Open carried fishing chests","AutoOpenChest")
action(fishExtra,"Open carried chests once",EX.OpenFishingChest)
end

do
local tools=addPage("toolplus","☰","Player / Visual Tools","Server / status / ESP / mobile")
local serverTools=section(tools,"Server / player utilities")
input(serverTools,"Target Job ID","SelectedServerID")
action(serverTools,"Join specified Job ID",function()
    local job=tostring(Config.SelectedServerID or ""):gsub("^%s+",""):gsub("%s+$","")
    if #job<32 or #job>40 or not job:match("^[a-fA-F0-9%-]+$") then
        notice("Server","Enter a valid Roblox Job ID","warn");return
    end
    safe("Teleport",function() TP:TeleportToPlaceInstance(game.PlaceId,job,LP) end)
end)
toggle(serverTools,"Follow selected player","AutoFollowPlayer")
action(serverTools,"Enable PvP",function() EX.QuestActions("EnablePvp") end)
action(serverTools,"Check inventory",function()
    local ok,items=EX.GetInventory()
    notice("Inventory",ok and (type(items)=="table" and #items.." entries" or tostring(items)) or "Unavailable")
end)
local extraVisual=section(tools,"White-glass ESP and visuals")
toggle(extraVisual,"ESP NPC","ESPNPC")
toggle(extraVisual,"ESP berry","ESPBerry")
toggle(extraVisual,"ESP sea event markers","ESPSea")
toggle(extraVisual,"Full bright world (reversible)","AutoFullBright")
toggle(extraVisual,"Reduce world particles (reversible)","AutoFPS")
action(extraVisual,"Apply FPS mode",EX.ApplyFPS)
action(extraVisual,"Apply lighting preference",EX.ApplyFullBright)
info(extraVisual,"Full Bright restores prior lighting when disabled; the crystal white UI remains unchanged.")
end

updateGlass()
setWindowVisible(true)
-- Adaptive window geometry; avoids a fixed oversized hub after rotation.
local function resizeUI(size)
    if not size or size.X<180 or size.Y<180 then return end
    screen=size
    W=math.min(884,math.max(280,size.X<690 and size.X-16 or size.X*.79))
    H=math.min(572,math.max(260,size.Y<460 and size.Y-12 or size.Y*.85))
    compact=W<690
    navW=compact and 58 or 192
    win.Size=UDim2.fromOffset(W,H)
    shadow.Size=win.Size
    glow.Size=UDim2.fromOffset(W+34,H+34)
    side.Size=UDim2.new(0,navW,1,-132)
    searchBack.Position=UDim2.fromOffset(navW+26,73)
    searchBack.Size=UDim2.new(1,-navW-42,0,37)
    work.Position=UDim2.fromOffset(navW+22,119)
    work.Size=UDim2.new(1,-navW-36,1,-178)
    navScroll.Position=UDim2.fromOffset(4,compact and 8 or 34)
    navScroll.Size=UDim2.new(1,-8,1,compact and -14 or -69)
    sideFoot.Text=compact and "v22" or "V22.0  •  3 SEA + REVIEW"
    statusCapsule.Visible=not compact
    tagline.Text=compact and "W H I T E  /  2 2 . 0" or "C R Y S T A L   W H I T E   /   2 2 . 0"
    tagline.Size=UDim2.fromOffset(compact and math.max(70,W-155) or 245,13)
    brand.Size=UDim2.fromOffset(compact and math.max(86,W-155) or 190,29)
    for _,entry in pairs(navButtons) do entry.Label.Visible=not compact end
    if STATE.NavResize then STATE.NavResize() end
end
local viewport=WS.CurrentCamera
if viewport then
    resizeUI(viewport.ViewportSize)
    on(viewport,viewport:GetPropertyChangedSignal("ViewportSize"),function()
        resizeUI(viewport.ViewportSize)
    end)
end
-- Slow specular sweep: animate gradient Offset, never rebuild color stops per frame.
task.spawn(function()
    while STATE.Alive do
        if win.Visible and not Config.ReducedMotion then
            grad.Offset=Vector2.new(-1,0)
            animate(grad,{Offset=Vector2.new(1,0)},3.4)
        end
        task.wait(7)
    end
end)

-- // New optional tools (source references: Topi Halloween, Teddy Quests, PullLever).
do
    local events=addPage("halloween","✧","Halloween & Events","Optional seasonal farms; no autonomous startup")
    local farm=section(events,"Halloween farming")
    info(farm,"To hunt event NPCs: set Farm type = Halloween, turn on Auto Farm, Combat và Auto Equip.")
    farmSwitch(farm,"Halloween NPC farm","Halloween","Bật / tắt farm quái Halloween khi sự kiện xuất hiện")
    toggle(farm,"Gom quái Halloween cùng loại","MobMagnet",
        "Chỉ gom NPC còn sống. Bật Halloween Farm trước khi gom")
    toggle(farm,"Auto collect pumpkin prompts","HalloweenPumpkins",
        "Runs only when Farm Engine is OFF; needs visible PumpkinHunt prompts")
    action(farm,"Find nearest pumpkin",function()
        local p,cf,d=STATE.FindPumpkin()
        if not cf then notice("Halloween","No actionable PumpkinHunt prompt loaded","warn");return end
        notice("Halloween",string.format("%s is %.0f studs away",p.Name,d))
    end)
    local secrets=section(events,"Secret Quests / Teddy")
    action(secrets,"Read 39 secret quests progress",function()
        local ok,data=STATE.CheckSecretQuestProgress()
        if not ok then notice("Secret Quests",tostring(data),"warn");return end
        local valueType=typeof(data)
        notice("Secret Quests","Server response received ("..valueType.."); see F9 console")
        print("[andepzai/secret quests]",data)
    end)
    info(secrets,"The Teddy reference shows static/fake red progress labels; we do not report 0/39 or completion without server confirmation.")
    local lever=section(events,"Race V4 / Pull Lever")
    action(lever,"Check lever / Race V4 progress",function()
        if STATE.World~=3 then notice("Lever","Available in Sea 3 only","warn");return end
        local ok,res=STATE.CheckLeverProgress()
        notice("Lever",ok and ("Server: "..tostring(res)) or "RaceV4Progress check unavailable",ok and "info" or "warn")
    end)
    action(lever,"Navigate to lever approach",function()
        if STATE.World~=3 then notice("Lever","Sea 3 only","warn");return end
        if Config.FarmEnabled then notice("Lever","Disable farm before navigating","warn");return end
        moveTo(CFrame.new(3032,2280,-7325))
    end)
    info(lever,"The lever/Blue Gear puzzle and Race V4 unlock are not auto-completed. Actions above are manual.")
end

--// EXPANDED INTEGRATED PAGES: functional handlers, not decorative toggles.
do
    local pg=addPage("integrated","⌘","Full Control Center","Single-hub operation, movement arbitration and self-checks")
    local quick=section(pg,"One-script operation","Choose a preset, inspect your game and start only when ready.")
    farmSwitch(quick,"Level + Quest + Combat","Level")
    farmSwitch(quick,"Boss Farm","Boss")
    farmSwitch(quick,"Material Farm","Material")
    farmSwitch(quick,"Mastery Farm","Mastery")
    action(quick,"STOP ALL ACTIONS AND MOVEMENT",function()
        STATE.StopAll()
    end)
    local options=section(pg,"Gameplay readiness")
    toggle(options,"Attack click fallback","InputClickFallback",
        "Sends conventional click input as well as Tool.Activate; only when combat is running")
    toggle(options,"Combat damage watchdog","AutoCombatDiagnostics",
        "Warns if targets' observed HP does not decrease")
    toggle(options,"Fallback to direct tween after repeated stalls","MovementFailover",
        "After repeated proxy stalls, attempt Direct Tween (not guaranteed accepted by game)")
    toggle(options,"Only move when explicitly enabled","Noclip",
        "Noclip belongs to movement engine; not a permanent world modification")
    action(options,"Run comprehensive self-check",function()
        local msg=STATE.Advanced.HealthCheck()
        notice("Self-check",msg:sub(1,170))
        print("[andepzai v13] SELF CHECK: ",msg)
    end)
    action(options,"Read movement + combat results",function()
        local m=STATE.MoveStats;local c=STATE.CombatTelemetry
        notice("Telemetry",string.format("tween=%d reached=%d stalled=%d | tools=%d remote=%d HP drops=%d",
            m.Started,m.Reached,m.Stalled,c.ToolCalls,c.RemoteCalls,c.HealthChanged))
    end)
    info(options,"No auto-farm, island hopping, fishing, raid or event task runs on load. Every activity requires a toggle or START button.")
end

do
    local pg=addPage("fishingpro","◉","Fishing PRO","Source-based FishingRequest, bait, water spots and catching")
    local core=section(pg,"Complete fishing controls","Topi source sequence: cast → wait for fish → optional catch events.")
    toggle(core,"ENABLE AUTO FISHING","AutoFish","Master toggle: no fishing requests are sent when OFF")
    toggle(core,"Advanced cast protocol","FishingAdvanced","Use FishingRequest instead of just Tool.Activate")
    toggle(core,"Load selected bait from inventory","FishingAutoBait",
        "Only LoadItem; does not automatically craft or spend material")
    toggle(core,"Catch when fish bites","FishingAutoCatch",
        "Listens for FishingRemote SpawnFishOnBob while Auto Fishing is enabled")
    dropdown(core,"Fishing bait","FishingBait",{"Basic Bait","Good Bait","Super Bait","Fish Bait","Golden Bait"},
        "Select an item available in your inventory; names may differ after updates")
    slider(core,"Cast distance","FishingCastDistance",15,80,5)
    slider(core,"Delay between casts","FishingCastDelay",2,15,1)
    action(core,"Load chosen bait",function()
        local ok,res=STATE.Advanced.LoadBait()
        notice("Fishing",ok and "LoadItem request sent" or tostring(res),ok and "info" or "warn")
    end)
    action(core,"CRAFT chosen bait (manual)",function()
        local ok,res=EX.GameCraft(tostring(Config.FishingBait),"Craft")
        notice("Fishing",ok and "Bait crafting requested" or tostring(res),ok and "info" or "warn")
    end)
    action(core,"CAST ONCE (request protocol)",function()
        local ok,why=STATE.Advanced.CastFishing()
        notice("Fishing",tostring(why),ok and "info" or "warn")
    end)
    action(core,"Test fishing remote availability",function()
        local fish=RS:FindFirstChild("FishReplicated")
        local req=fish and fish:FindFirstChild("FishingRequest")
        notice("Fishing",req and "FishingRequest is loaded" or "FishingRequest is not loaded",req and "info" or "warn")
    end)
    local spot=section(pg,"Position and golden vortex")
    action(spot,"Save current fishing position",function()
        notice("Fishing",STATE.Advanced.SaveFishingPosition() and "Position saved" or "Character not ready")
    end)
    action(spot,"Return to saved fishing position",function()
        local ok,why=STATE.Advanced.GoSavedFishing()
        notice("Fishing",tostring(why),ok and "info" or "warn")
    end)
    toggle(spot,"Move to saved spot before casting","FishingUseSaved")
    toggle(spot,"Follow a loaded Golden Vortex","FishingGoVortex",
        "Only moves when Auto Fishing is enabled and no other combat job is active")
    action(spot,"Find nearest Golden Vortex",function()
        local v,d=STATE.Advanced.FishingSpot()
        notice("Fishing",v and string.format("Golden Vortex %.0f studs",d) or "No Golden Vortex streamed")
    end)
    local fStatus=section(pg,"Fishing telemetry / NPC")
    action(fStatus,"Read casting / catching telemetry",function()
        local f=STATE.Advanced.Fish
        notice("Fishing",string.format("Casts %d | Catch events %d | Failures %d | %s",
            f.Casts,f.Catches,f.Failures,tostring(f.LastError)))
    end)
    action(fStatus,"Check Angler fishing quest",function() EX.QuestActions("FishingNPC","Angler","CheckQuest") end)
    action(fStatus,"Ask Angler for quest",function() EX.QuestActions("FishingNPC","Angler","AskQuest") end)
    action(fStatus,"Sell caught fish once",function()
        local ok,res=EX.FishingAction("SellFish")
        notice("Fishing",ok and "Sell request sent" or tostring(res),ok and "info" or "warn")
    end)
    toggle(fStatus,"Auto sell caught fish","AutoSellFish")
    info(fStatus,"The source uses internal game remotes; a successful request does not guarantee a catch or sale. No external code is executed.")
end

do
    local pg=addPage("secret39","☷","39 Secret Quests","Reference catalog / live progress / event location")
    local list=section(pg,"Secret quest catalog","39 names extracted from Teddy. The referenced hub falsely shows 0/39 permanently.")
    local optionList={}
    for i,name in ipairs(STATE.Advanced.SecretQuestNames) do
        optionList[i]=string.format("[%02d] %s",i,name)
    end
    dropdown(list,"Choose one secret quest","SecretQuestName",optionList)
    action(list,"SHOW selected quest",function()
        local idx=tonumber(tostring(Config.SecretQuestName):match("^%[(%d+)%]")) or 1
        setFlag("SecretQuestIndex",idx)
        notice("Secret quest",string.format("#%d %s / %s",idx,
            STATE.Advanced.SecretQuestNames[idx],STATE.Advanced.SecretQuestAreas[idx]))
    end)
    action(list,"NAVIGATE selected quest area",function()
        local idx=tonumber(tostring(Config.SecretQuestName):match("^%[(%d+)%]")) or 1
        setFlag("SecretQuestIndex",idx)
        local ok,msg=STATE.Advanced.SecretQuestNavigate()
        notice("Secret Quests",tostring(msg),ok and "info" or "warn")
    end)
    action(list,"CHECK live progress from server",function()
        local ok,data=STATE.Advanced.SecretQuestProgress()
        if not ok then notice("Secret Quests",tostring(data),"warn");return end
        notice("Secret Quests","Received game progress response. See F9 console")
        print("[andepzai v13] Secret quest response: ",data)
    end)
    action(list,"SHOW entire 39-quest catalog in console",function()
        for i,name in ipairs(STATE.Advanced.SecretQuestNames) do
            print(string.format("[Quest %02d] %s (%s)",i,name,STATE.Advanced.SecretQuestAreas[i]))
        end
        notice("Secret Quests","Printed 39 entries to F9 console")
    end)
    info(list,"This is a real catalog/progress/navigation utility. Full 39 multi-stage puzzle completion is NOT claimed: the supplied Teddy script itself contains dummy progress and nonfunctional quest buttons.")
end

do
    local pg=addPage("progressplus","◈","Quest & Race PRO","Character progression / Yama / CDK / gear / lever")
    local statuses=section(pg,"Progress from server","Status queries are separate from automatic gameplay.")
    for _,entry in ipairs({
        {"Bartilo","Bartilo"},{"Saber","Saber"},{"Yama","Yama"},
        {"CDK","CDK"},{"Tushita","Tushita"},{"Race V4","RaceV4"},
        {"Soul Guitar","Guitar"},{"Dragon Hunter","Dragon"},
    }) do
        local label,kind=entry[1],entry[2]
        action(statuses,"Check "..label,function()
            local ok,result=STATE.Advanced.QuestStage(kind)
            notice("Progress - "..label,ok and tostring(result):sub(1,120) or "Unavailable: "..tostring(result),
                ok and "info" or "warn")
        end)
    end
    local missions=section(pg,"Mission preparation","Select one mission, then use START FARM separately.")
    for _,name in ipairs({"Yama","Tushita","Soul Guitar","Dough King","Bartilo","Race V4"}) do
        local selected=name
        action(missions,"PREPARE "..selected.." FARM",function()
            local ok,msg=STATE.Advanced.PresetProgressMission(selected)
            if ok then
                for _,key in ipairs({"FarmMode","FarmEnabled","Boss","Material","Mob","AutoQuest","Combat","AutoEquip"}) do
                    setFlag(key,Config[key])
                end
            end
            notice("Progression",tostring(msg),ok and "info" or "warn")
        end)
    end
    local gear=section(pg,"Race V4 / Blue Gear / Pull Lever")
    action(gear,"Check Race V4 stage",function()
        local ok,res=STATE.Advanced.QuestStage("RaceV4")
        notice("Race V4",ok and tostring(res) or tostring(res),ok and "info" or "warn")
    end)
    action(gear,"Find and move to Blue Gear",function()
        local ok,msg=STATE.Advanced.GoBlueGear()
        notice("Blue Gear",tostring(msg),ok and "info" or "warn")
    end)
    action(gear,"Approach / BEGIN lever stage",function()
        local ok,msg=STATE.Advanced.PullLeverStep()
        notice("Pull Lever",tostring(msg),ok and "info" or "warn")
    end)
    action(gear,"Teleport to Temple of Time via game remote",function()
        if STATE.World~=3 then notice("Race V4","Requires Sea 3","warn");return end
        EX.QuestActions("RaceV4Progress","Teleport")
    end)
    action(gear,"Return from Temple of Time",function()
        if STATE.World~=3 then return end
        EX.QuestActions("RaceV4Progress","TeleportBack")
    end)
    info(gear,"Race V4 trials, full CDK quest sequence, Soul Guitar puzzle and Blue Gear spawn are game-state dependent; no unsupported Auto Complete toggles are shown.")
end

do
    local pg=addPage("seapilot","≋","Sea Pilot / Boat","Optional boat steering, zones, event prompts and navigator")
    local nav=section(pg,"Sea 3 boat pilot","Uses the owned boat's VehicleSeat/Model:PivotTo; works only if client has authority.")
    dropdown(nav,"Target sea zone","SeaZone",{"Zone 1","Zone 2","Zone 3","Zone 4","Zone 5","Zone 6"})
    slider(nav,"Boat cruise speed","BoatCruiseSpeed",45,280,5)
    toggle(nav,"ENABLE AUTO BOAT NAVIGATION","AutoSeaBoat","Opt-in. Requires a boat you own and are seated in.")
    action(nav,"Buy selected boat",function()
        local ok,res=EX.BuyBoat()
        notice("Boat",ok and "Purchase requested" or tostring(res),ok and "info" or "warn")
    end)
    action(nav,"NAVIGATE to selected sea zone",function()
        if not Config.AutoSeaBoat then
            notice("Boat","Enable boat navigation first","warn");return
        end
        local ok,msg=STATE.Advanced.Boat.Start(Config.SeaZone)
        notice("Boat",tostring(msg),ok and "info" or "warn")
    end)
    action(nav,"STOP BOAT",function()
        setFlag("AutoSeaBoat",false)
        STATE.Advanced.Boat.Stop()
        notice("Boat","Navigation stopped")
    end)
    action(nav,"Check boat / seat status",function()
        local boat,seat=STATE.Advanced.Boat.Find()
        local val=boat and boat.Name or "None loaded"
        local occupied=seat and seat.Occupant and seat.Occupant.Parent and seat.Occupant.Parent.Name or "Empty"
        notice("Boat",val.." | seat: "..occupied)
    end)
    local events=section(pg,"Event prompts and detection")
    dropdown(events,"Prompt keyword","EventPromptKeyword",{"Pumpkin","Lever","Core","Activation","Ancient","Chest","Talk"})
    action(events,"FIND matching event prompt",function()
        local p,d=STATE.Advanced.FindPrompt(Config.EventPromptKeyword)
        notice("Prompt",p and (p:GetFullName().." / "..math.floor(d).." studs") or "Not streamed")
    end)
    action(events,"MOVE / INTERACT selected event prompt",function()
        local ok,msg=STATE.Advanced.InteractPrompt(Config.EventPromptKeyword)
        notice("Prompt",tostring(msg),ok and "info" or "warn")
    end)
    action(events,"Find loaded Blue Gear",function()
        local cf=STATE.Advanced.BlueGearLocation()
        notice("Sea event",cf and tostring(cf.Position) or "Blue Gear not loaded")
    end)
    action(events,"Locate nearest Golden Vortex",function()
        local v,d=STATE.Advanced.FishingSpot()
        notice("Sea event",v and string.format("Golden Vortex %.0f studs away",d) or "No Vortex")
    end)
    info(events,"Event completion is not claimed. The page provides boat control and actual streamed-object interactions, not fabricated item drops.")
end

do
    local pg=addPage("diagnosticspro","⊕","Diagnostics PRO","Runtime health, logs, telemetry and feature support")
    local status=section(pg,"Runtime inspection")
    action(status,"Inspect all engine dependencies",function()
        local msg=STATE.Advanced.HealthCheck()
        print("[andepzai v13]",msg)
        notice("Diagnostics",msg:sub(1,160))
    end)
    action(status,"Dump detailed diagnostics to console",function()
        print("[andepzai] GAME",game.PlaceId,STATE.World,"Level",level())
        print("[andepzai] MOVE",STATE.MoveStats.Status,STATE.MoveStats.LastError,
            "Started",STATE.MoveStats.Started,"Reached",STATE.MoveStats.Reached,"Stalled",STATE.MoveStats.Stalled)
        print("[andepzai] COMBAT",STATE.CombatTelemetry.ToolCalls,
            STATE.CombatTelemetry.RemoteCalls,STATE.CombatTelemetry.HealthChanged)
        local fish=STATE.Advanced.Fish
        print("[andepzai] FISH",fish.Casts,fish.Catches,fish.Failures,fish.LastError)
        local boat=STATE.Advanced.Boat.Stats
        print("[andepzai] BOAT",boat.Started,boat.Reached,boat.Stopped,boat.Rejected)
        for i=1,math.min(30,#STATE.Logs) do
            print("[LOG]",STATE.Logs[i].t,STATE.Logs[i].level,STATE.Logs[i].text)
        end
        notice("Diagnostics","Detailed state printed to F9 console")
    end)
    action(status,"Copy error/status report",function()
        local report=STATE.Advanced.HealthCheck().."\n"
        for i=1,math.min(#STATE.Logs,40) do
            local item=STATE.Logs[i]
            report=report..item.t.." "..item.level.." "..item.text.."\n"
        end
        local copy=api("setclipboard")
        if copy then pcall(copy,report);notice("Diagnostics","Report copied")
        else print(report);notice("Diagnostics","Clipboard API not found; report printed") end
    end)
    action(status,"Cancel ALL movement",function()
        setFlag("FarmEnabled",false)
        setFlag("AutoSeaBoat",false)
        cancelMove()
        notice("Diagnostics","Movement cancelled")
    end)
    info(status,"F9 diagnostics distinguishes requests sent, tween started and observed HP loss. It does NOT infer server-side success from pcall alone.")
end

--// NON-UI SPOOKY CAPABILITIES EXPOSED IN THE EXISTING CRYSTAL WHITE PAGE SYSTEM
-- Uses the unchanged andepzai builders: addPage / section / action / toggle / slider / dropdown / input.
do
    local M=STATE.Spooky
    local page=addPage("spookycombat","✕","Combat Plus","Spooky-inspired PvE combat and weapon remotes")
    local base=section(page,"Fast Attack & M1","Only begins when enabled; internal game remotes may change")
    toggle(base,"Fast Attack (NPC)","SpookyFastAttack","Send a throttled strike for nearby NPCs")
    slider(base,"Attack delay","SpookyAttackDelay",.12,.9,.03)
    slider(base,"M1 target radius","SpookyM1Range",10,140,5)
    dropdown(base,"Farm remote format","PVEHitProtocol",{"Spooky","Topi"},"Choose source-style protocol; test actual HP drops")
    toggle(base,"M1 extender / nearby NPCs","SpookyM1Extender")
    action(base,"Test one NPC attack",function()
        if M.AttackBurst("NPC") then notice("Combat Plus","Request sent; verify target HP")
        else notice("Combat Plus",M.Status,"warn") end
    end)
    toggle(base,"Gun aura (nearby target)","SpookyGunAura","Only runs when farm is off")
    local monitoring=section(page,"Combat diagnostics")
    action(monitoring,"Combat status / requests",function()
        notice("Combat Plus",string.format("%s | Requests %d | Hits sent %d",M.Status,M.Metrics.Attacks,M.Metrics.HitRequests))
    end)
    info(monitoring,"FireServer success does not confirm server damage. Farm now supports Spooky/Topi hit formats; check HP drops.")
end

do
    local M=STATE.Spooky
    local page=addPage("spookypvp","◎","PvP Assist","Target filters, optional bounty pursuit, camera lock")
    local target=section(page,"Target selection / filters")
    dropdown(target,"Selected player","SelectedPlayer",getPlayers)
    toggle(target,"Enable PvP targeting","SpookyPVP","Required for targeted PvP remote requests")
    toggle(target,"Only selected player","SpookyManualTargetOnly")
    toggle(target,"Skip same team","SpookyTeamCheck")
    toggle(target,"Skip safe zones","SpookySafeZoneCheck")
    slider(target,"Target range","SpookyTargetRange",25,500,25)
    slider(target,"Minimum player level","SpookyMinPlayerLevel",0,2700,100)
    input(target,"Ignored user IDs (comma-separated)","SpookyBlacklist")
    local assistance=section(page,"Aim / CamLock")
    toggle(assistance,"CamLock to PvP target","SpookyCamLock")
    toggle(assistance,"Camera assist for NPCs","SpookyAimNPC")
    slider(assistance,"Aim smoothness","SpookyAimSmoothness",.05,.8,.05)
    action(assistance,"Show chosen target",function()
        local p=M.FindPlayer();notice("PvP Target",p and p.Name or "No valid target")
    end)
    local bounty=section(page,"Manual start PvP / bounty","These controls never auto-start on script load")
    toggle(bounty,"Auto bounty mode","SpookyAutoBounty")
    toggle(bounty,"Follow target using Tween","SpookyBountyChase")
    slider(bounty,"Pause when HP is below %","SpookyBountyHPMin",0,80,5)
    action(bounty,"Stop PvP / bounty",function()
        setFlag("SpookyAutoBounty",false);setFlag("SpookyCamLock",false)
        setFlag("SpookyBountyChase",false);cancelMove()
    end)
    info(bounty,"Team and safe-zone checks depend on game replication; other player permissions may prevent hits.")
end

do
    local M=STATE.Spooky
    local page=addPage("spookymacro","▣","Combat Macro","Run input combos on demand; not a background Kaitun")
    local steps=section(page,"Editable combo sequence")
    dropdown(steps,"Macro slot","SpookyMacroSlot",{"1","2","3","4","5"})
    input(steps,"Combo slot 1","SpookyMacroSlot1")
    input(steps,"Combo slot 2","SpookyMacroSlot2")
    input(steps,"Combo slot 3","SpookyMacroSlot3")
    input(steps,"Combo slot 4","SpookyMacroSlot4")
    input(steps,"Combo slot 5","SpookyMacroSlot5")
    toggle(steps,"Loop combo until STOP","SpookyMacroLoop")
    action(steps,"Melee + Sword preset",function()
        setFlag("SpookyMacroSlot1","Melee:Z:0.30,Melee:X:0.40,Sword:Z:0.35,Sword:X:0.50")
        setFlag("SpookyMacroSlot","1")
        notice("Macro","Preset selected")
    end)
    action(steps,"Fruit skills preset",function()
        setFlag("SpookyMacroSlot2","Fruit:Z:0.35,Fruit:X:0.45,Fruit:C:0.55,Fruit:V:0.65")
        setFlag("SpookyMacroSlot","2")
        notice("Macro","Preset selected")
    end)
    action(steps,"M1 burst preset",function()
        setFlag("SpookyMacroSlot3","Equipped:M1:0.16,Equipped:M1:0.16,Equipped:M1:0.2")
        setFlag("SpookyMacroSlot","3")
        notice("Macro","Preset selected")
    end)
    local control=section(page,"Run / stop")
    action(control,"START COMBO",function()
        if M.StartMacro() then notice("Macro","Combo started")
        else notice("Macro",M.Status,"warn") end
    end)
    action(control,"STOP / release keys",function()
        M.StopMacro();notice("Macro","Macro stopped")
    end)
    info(control,"5 editable macro slots. Use Weapon:Z:0.30 or Equipped:M1:0.15; skill keys require executor input support.")
end

do
    local M=STATE.Spooky
    local page=addPage("spookymovement","⌁","Movement Plus","Character motion controls inspired by Spooky")
    local basic=section(page,"Character movement")
    toggle(basic,"Override WalkSpeed","SpookyWalkSpeed")
    slider(basic,"WalkSpeed","SpookySpeed",16,250,2)
    toggle(basic,"Fly (movement keys)","SpookyFly","Disabled while Farm or Auto Boat is active")
    slider(basic,"Fly speed","SpookyFlySpeed",20,220,10)
    toggle(basic,"Bunny Hop","SpookyBunnyHop")
    toggle(basic,"Super Jump","SpookySuperJump")
    slider(basic,"Jump Power","SpookyJumpPower",50,250,10)
    toggle(basic,"Disable character animations","SpookyNoAnimation")
    slider(basic,"Manual dash distance","SpookyDashDistance",20,250,10)
    action(basic,"DASH now",function()
        if not M.ManualDash() then notice("Movement","Dash unavailable; disable Farm","warn") end
    end)
    toggle(basic,"Anti Stun / PlatformStand","SpookyAntiStun")
    toggle(basic,"Walk on water","SpookyWaterWalk")
    toggle(basic,"Extended camera zoom","SpookyInfiniteZoom")
    action(basic,"Restore character movement",function()
        for _,key in ipairs({"SpookyWalkSpeed","SpookyFly","SpookyBunnyHop","SpookyAntiStun","SpookyWaterWalk","SpookyInfiniteZoom","SpookySuperJump","SpookyNoAnimation"}) do setFlag(key,false) end
        M.StopFly()
    end)
    local cam=section(page,"Camera controls")
    toggle(cam,"Override Camera FOV","SpookyCameraFOVEnabled")
    slider(cam,"Camera FOV","SpookyCameraFOV",45,120,5)
    info(cam,"Global Fly is disabled during Farm to avoid competing with the Farm Tween controller.")
end

do
    local M=STATE.Spooky
    local page=addPage("spookyvisual","✧","Visual Plus","Highlights, hitboxes and optional graphics reduction")
    local outlines=section(page,"In-game visual assists")
    toggle(outlines,"Player Tracers (3D beams)","SpookyTracers")
    toggle(outlines,"Player Chams / highlights","SpookyPlayerChams")
    toggle(outlines,"NPC Chams / highlights","SpookyNPCChams")
    toggle(outlines,"Rainbow Chams colors","SpookyRainbowChams")
    toggle(outlines,"Expand NPC hitbox (client only)","SpookyHitboxNPC")
    toggle(outlines,"Expand PvP hitbox (client only)","SpookyHitboxPVP")
    slider(outlines,"Hitbox size","SpookyHitboxSize",4,35,1)
    info(outlines,"Hitbox size is changed locally; server validation may reject extended reach.")
    local graphics=section(page,"Graphics optimization")
    toggle(graphics,"No Fog","SpookyNoFog")
    toggle(graphics,"No Shadows","SpookyNoShadows")
    toggle(graphics,"Hide textures (reversible)","SpookyLowTextures")
    toggle(graphics,"Soft shader / bloom","SpookyShader")
    toggle(graphics,"Set daytime","SpookyTimeOverride")
    slider(graphics,"Clock time","SpookyClockTime",0,24,1)
    action(graphics,"Apply shader / daytime",function() M.UpdateExtrasGraphics() end)
    action(graphics,"Restore visuals / graphics",function()
        for _,key in ipairs({"SpookyPlayerChams","SpookyNPCChams","SpookyHitboxNPC","SpookyHitboxPVP","SpookyNoFog","SpookyNoShadows","SpookyLowTextures"}) do setFlag(key,false) end
        M.UpdateHitboxes();M.UpdateChams();M.UpdateGraphics()
        M.StopExtras()
        notice("Visual Plus","Local visuals restored")
    end)
    local appearance=section(page,"Local avatar effects")
    toggle(appearance,"Headless appearance (local)","SpookyHeadlessLocal")
    toggle(appearance,"No collision for accessories","SpookyAccessoryNoclip")
    toggle(appearance,"Giant appearance (local)","SpookyGiantLocal")
    slider(appearance,"Giant scale","SpookyGiantScale",1,3,.2)
    action(appearance,"Restore avatar effects",function() M.StopExtras();notice("Avatar","Local effects restored") end)
end

do
    local M=STATE.Spooky
    local page=addPage("spookydungeon","◇","Dungeon Plus","Optional dungeon combat; shares movement engine")
    local opts=section(page,"Dungeon / raid combat")
    toggle(opts,"Auto Dungeon (must enable)","SpookyAutoDungeon")
    slider(opts,"Attack height","SpookyDungeonHeight",5,50,5)
    toggle(opts,"Fast Attack in Dungeon","SpookyFastAttack")
    action(opts,"Stop Dungeon",function()
        setFlag("SpookyAutoDungeon",false);cancelMove();notice("Dungeon","Stopped")
    end)
    info(opts,"Finds dungeon islands from _WorldOrigin.Locations, prioritizes NPCs; actual progression depends on server mechanics.")
end

-- 8 compact navigation groups, all original feature pages remain present.
-- Only reveal subpages of selected group. Search still searches every page.
STATE.BuildCompactNav=function()
    local groups={
      {"home","Home","home",{"home","integrated"}},
      {"farm","Farm","farm",{"farm","boss","materials","unified","specialboss","spookycombat"}},
      {"items","Items","fruits",{"fruits","shop","craft"}},
      {"raids","Raid / Events","raid",{"raid","halloween","events","extras","spookydungeon"}},
      {"sea","Sea / Fish","sea",{"sea","seapilot","fishing","fishingpro"}},
      {"quests","Quest / Race","quests",{"quests","secret39","race","progress","progressplus"}},
      {"travel","Combat / Travel","combat",{"combat","spookypvp","spookymacro","spookymovement","travel","esp","spookyvisual","toolplus"}},
      {"system","System","settings",{"server","settings","diagnosticspro"}},
    }
    local groupButtons={}
    local activeGroup="home"
    local order=0
    for _,g in ipairs(groups) do
        order=order+1
        local entry=mk("TextButton",{Name="Group_"..g[1],Text="",AutoButtonColor=false,
            BackgroundColor3=C.White,BackgroundTransparency=.75,BorderSizePixel=0,
            Size=UDim2.new(1,0,0,43),LayoutOrder=order*100-20},navScroll)
        round(entry,14);liquidSurface(entry,"nav")
        local chip=mk("Frame",{BackgroundColor3=C.White,BackgroundTransparency=.48,
            Size=UDim2.fromOffset(28,28),Position=UDim2.fromOffset(compact and 10 or 9,7),
            BorderSizePixel=0},entry)
        round(chip,11);vectorIcon(chip,g[3],UDim2.fromOffset(5,5),18)
        local chipScale=mk("UIScale",{Scale=1},chip)
        local label=txt(entry,g[2],11,C.Text,Enum.Font.GothamBold)
        label.Position=UDim2.fromOffset(44,0);label.Size=UDim2.new(1,-48,1,0)
        label.Visible=not compact
        groupButtons[g[1]]={Button=entry,Label=label,Data=g,Chip=chip,Scale=chipScale}
        on(entry,entry.MouseEnter,function()
            animate(chipScale,{Scale=1.08},.16)
        end)
        on(entry,entry.MouseLeave,function()
            animate(chipScale,{Scale=1},.16)
        end)
        for pos,id in ipairs(g[4]) do
            if navButtons[id] then navButtons[id].Back.LayoutOrder=order*100+pos end
        end
    end
    local function rebuild(query)
        local searching=query and query~=""
        if not searching and selectedPage then
            for _,g in ipairs(groups) do
                if table.find(g[4],selectedPage) then activeGroup=g[1];break end
            end
        end
        for _,g in ipairs(groups) do
            local group=groupButtons[g[1]]
            group.Button.Visible=not searching
            animate(group.Button,{BackgroundTransparency=g[1]==activeGroup and .43 or .79},.18)
            animate(group.Chip,{BackgroundTransparency=g[1]==activeGroup and .23 or .48},.18)
            for _,pageID in ipairs(g[4]) do
                if navButtons[pageID] then
                    local item=navButtons[pageID].Back
                    item.Visible=searching and (STATE.Pages[pageID].SearchHits or 0)>0
                        or (not searching and g[1]==activeGroup)
                end
            end
        end
    end
    local function selectGroup(key,preferred)
        for _,g in ipairs(groups) do
            if g[1]==key then
                activeGroup=key
                choosePage(preferred or g[4][1])
                rebuild("")
                return
            end
        end
    end
    for _,g in ipairs(groups) do
        local id=g[1]
        on(groupButtons[id].Button,groupButtons[id].Button.MouseButton1Click,function()
            pulse(groupButtons[id].Button);selectGroup(id)
        end)
    end
    STATE.NavRebuild=rebuild
    STATE.OpenGroup=selectGroup
    STATE.OpenPage=function(id)
        for _,g in ipairs(groups) do
            if table.find(g[4],id) then selectGroup(g[1],id);return end
        end
        choosePage(id)
    end
    STATE.NavResize=function()
        for _,group in pairs(groupButtons) do group.Label.Visible=not compact end
    end
    rebuild("")
end
STATE.BuildCompactNav()
-- Hide long Farm sub-controls by default; tap title to expand.
for _,sec in ipairs(STATE.Pages.farm.Sections) do
    if sec.Name~="Quick actions / 1 tap" then
        sec:SetCollapsed(true)
    end
end

STATE.OpenGroup("home")
STATE.PushLog=function(message,level)
    if R.lastLog then
        local t=tostring(message)
        R.lastLog(t:sub(1,51))
    end
end
startLoop("Dashboard",1,function()
    if not STATE.Alive then return end
    R.statLevel(level());R.statSea(STATE.World);R.statBeli(value("Beli"));R.statFrag(value("Fragments"))
    local _,h,_,ok=alive()
    R.hp(h and string.format("%d / %d",h.Health,h.MaxHealth) or "Respawning")
    local mob=enemySearch(nil,false);R.curMob(mob and mob.Name or "--")
    local quest=questInfo();R.curQuest(quest and quest.Mob or "No quest")
    R.statFarm(Config.FarmEnabled and ("Active / "..Config.FarmMode) or "Stopped")
    if R.pickupStatus and STATE.Pickups then
        R.pickupStatus(STATE.Pickups.LastStatus)
    end
    if STATE.CombatStatusLabel then
        local d=STATE.CombatTelemetry
        STATE.CombatStatusLabel(Config.FarmEnabled and
            ("HP drops "..d.HealthChanged.." / tries "..d.Attempts) or "Idle")
    end
    R.engineStatus(Config.FarmEnabled and "Farming" or "Standby")
    R.scount(#Players:GetPlayers())
    local ping="--"
    pcall(function() ping=game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValueString() end)
    R.sping(ping)
    local elapsed=math.floor(os.clock()-STATE.Start)
    R.sessTime(string.format("%02d:%02d",math.floor(elapsed/60),elapsed%60))
    local rod=findRod();R.rodState(rod and rod.Name or "No rod")
    local cf,name=findSeaLocation();R.seaEventStatus(name or "Not loaded")
    local mobSea=seaTarget();R.seaMobStatus(mobSea and mobSea.Name or "Not visible")
    footText.Text=string.format("%s  •  Lv. %d  •  Sea %d  •  %s",
        LP.DisplayName,level(),STATE.World,Config.FarmEnabled and "FARMING" or "READY")
    floating.Visible=Config.FloatingButton or not win.Visible
end)

-- Optional public control API for local debugging or custom extensions.
STATE.Config=Config
STATE.GetQuest=questInfo
STATE.GetCurrentQuest=activeQuest
STATE.GetQuestRoute=questRoute
STATE.GetCombatRemotes=getCombatRemotes
STATE.MoveTo=moveTo
STATE.CancelMovement=cancelMove
STATE.GetOverheadState=function()
    return {Enabled=Config.FarmEnabled and Config.FarmStyle=="Above",Height=Config.FarmHeight,
        Hovering=STATE.FarmHover.Force~=nil,Target=STATE.FarmHover.Target and STATE.FarmHover.Target.Name or "None"}
end
STATE.UIVersion="Crystal White Liquid Glass 22.0 Banana benchmark"
STATE.SetTheme=themeSelect
STATE.UnifiedFeatures=EX
STATE.AdvancedFeatures=STATE.Advanced
STATE.HealthCheck=function() return STATE.Advanced.HealthCheck() end
STATE.SetGlassIntensity=function(percent)
    setFlag("GlassIntensity",math.clamp(tonumber(percent) or 76,15,100))
end
STATE.SetHighContrast=function(enabled) setFlag("HighContrast",not not enabled) end
STATE.SelectPage=function(id) if STATE.OpenPage then STATE.OpenPage(id) else choosePage(id) end end
STATE.Stop=function()
    for _,key in ipairs({"FarmEnabled","AutoSea","AutoChest","AutoCollectFruit","AutoAdvanceRaid","AutoRaidCombat",
        "AutoFactory","AutoPirateRaid","AutoSoulReaper","AutoDarkbeard","AutoRipIndra","AutoDoughKing","AutoEliteCombat",
        "AutoEventCollect","AutoFollowPlayer","AutoSafeItems","AutoChestHop","AutoSeaHop","AutoFruitHop",
        "AutoBerry","AutoBerryHop","AutoMagnetToken","EventRadar",
        "HalloweenPumpkins","AutoFish","AutoSeaBoat","FishingGoVortex",
        "AutoSecretQuestRoute"}) do
        setFlag(key,false)
    end
    cancelMove()
    if STATE.Pickups then STATE.Pickups.Reset() end
    if STATE.ReleaseFarmHover then STATE.ReleaseFarmHover() end
    if STATE.Advanced and STATE.Advanced.Boat then STATE.Advanced.Boat.Stop() end
    if STATE.Spooky then STATE.Spooky.StopAll() end
end
STATE.Save=save
STATE.ActivateFarm=function(mode)
    if mode then setFlag("FarmMode",mode) end
    setFlag("FarmEnabled",true)
end
notice("andepzai 22.0","3 Sea Atlas + Pickup repair / Farm OFF / Sea "..STATE.World)
print("[andepzai] CRYSTAL WHITE 22.0 Pickup repair + events radar | Farm OFF | Sea="..STATE.World)
return STATE
