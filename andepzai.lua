--[[
  andepzai / CRYSTAL WHITE LIQUID GLASS 38.9 — HALLOWEEN BOSS + MATERIAL TRACKER
  An independent Blox Fruits Luau hub, informed by supplied farm scripts and
  Spooky Hub non-UI modules. This build embeds its own UI. No original source-hub UI, library, or
  remote third-party Lua is loaded. 38.6 merges only static island/NPC/quest
  reference data from the supplied files; loaders, key systems, hooks and
  anti-cheat/bypass code are intentionally excluded.
  Runtime: Blox Fruits client and executor-supported features where needed.
  Controls that depend on game internals may need updates after game patches.
]]
local env = (type(getgenv) == "function" and getgenv()) or _G
-- Re-execution cleans up both this release and the previous standalone hub.
for _,slot in ipairs({"__ANDEPZAI_V38","__ANDEPZAI_V37","__ANDEPZAI_V36","__ANDEPZAI_V35","__ANDEPZAI_V34","__ANDEPZAI_V33","__ANDEPZAI_V32","__ANDEPZAI_V31","__ANDEPZAI_V30","__ANDEPZAI_V29","__ANDEPZAI_V28","__ANDEPZAI_V27","__ANDEPZAI_V26","__ANDEPZAI_V25","__ANDEPZAI_V24","__ANDEPZAI_V23","__ANDEPZAI_V22","__ANDEPZAI_V21","__ANDEPZAI_V20","__ANDEPZAI_V19","__ANDEPZAI_V18","__ANDEPZAI_V17","__ANDEPZAI_V16","__ANDEPZAI_V15","__ANDEPZAI_V14","__ANDEPZAI_V13","__ANDEPZAI_V12","__ANDEPZAI_V11","__ANDEPZAI_V10","__ANDEPZAI_V9","__ANDEPZAI_V8","__ANDEPZAI_V7","__ANDEPZAI_V6","__ANDEPZAI_V5","__ANDEPZAI_V4","__ANDEPZAI_V3"}) do
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
env.__ANDEPZAI_V38 = STATE
STATE.MoveThreadOwners=setmetatable({},{__mode="k"})
STATE.MovementLock=nil
local PLACE = { [2753915549]=1,[85211729168715]=1,[4442272183]=2,[79091703265657]=2,
    [7449423635]=3,[100117331123089]=3 }
STATE.World = PLACE[game.PlaceId] or 0

local defaults = {
  FarmMode="Level", Weapon="Melee", Mob="Bandit", Boss="The Gorilla King", Material="Bones", IslandFarmIsland="",
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
  AutoWorldProgression=false, PreferLiveQuestModule=true,
  AutoBoatBuy=false, AutoRandomBones=false, AutoFruitDealer=false,
  WeaponMasteryTarget=400, AutoMasteryChain=false, AutoLowHPHeal=false,
  SmartPortal=false, PreferRouteData=false,
  -- V10: all gameplay automation opt-in, combat & quest subsystems.
  FastAttackEnabled=true, CombatMode="Adaptive", AttackRange=32,
  -- v24: independent combat scheduler; bounded rate and confirmed HP feedback.
  CombatScheduler=true,FastAttackInterval=.06,FastAttackTargets=8,
  FastAttackMultiTarget=true,FastAttackAutoTune=true,ToolAttackInterval=.16,
  PreferReferenceQuests=true,
  AutoFishSlap=false,AutoGachaZioles=false,GachaMaxPrice=300000,GachaCooldown=600,
  AutoCakePortal=false,CakeTravelToNPC=false,CakeCheckDelay=25,
  RouteSmartScan=true,RouteSpawnWait=7,RouteCooldown=28,
  RouteArrivalRadius=70,RouteVisitPenalty=45,
  AutoAbandonWrongQuest=false, MovementMode="Flight Tween",FlightWaterHeight=35,
  FlightContinuous=true,FlightStabilize=true,FlightSoftRecovery=true,
  HalloweenPumpkins=false,AutoTrickOrTreat=false,TrickTreatWindowOnly=false,
  HalloweenBossType="Tất cả",HalloweenBossRadius=1600,
  TrickTreatRevisit=100,MoveAutoBackoff=true,MoveCorrectionThreshold=13,
  MobMagnet=true, MobMagnetRadius=205, MobMagnetMax=8,
  MobMagnetMatchMode="Same mob name", MobMagnetNetworkAssist=true,
  MobMagnetBodyPosition=true,
  ResetTeleport=false, ResetTeleportAllowRespawn=false, ResetTeleportCooldown=100,
  TeleportEnabled=true, TeleportAutoRecover=true, TeleportRetryLimit=3, TeleportArrivalRadius=8,
  FloatButtonX=.93, FloatButtonY=.88, SpookyMacroEnabled=false,
  AtlasUseScannedSpawns=true, AtlasIsland="", SpawnDestination="Gần nhất", SpawnRadar=false, HalloweenReviveGrace=0.6,
  MoveRetargetThreshold=7, MoveRetargetDelay=0.40,
  -- Comprehensive optional modules from user's 7 additional source scripts.
  InputClickFallback=true, AutoCombatDiagnostics=true, MovementFailover=true,
  FishingAdvanced=true, FishingAutoCatch=true, FishingAutoBait=true, FishingGoVortex=false,
  FishingUseSaved=false, FishingHasPosition=false, FishingBait="Basic Bait",
  FishingCastDelay=5, FishingCastDistance=42,
  FishingAutoFindWater=true, FishingAutoCraftBait=false, FishingTryAlternateAim=true,
  FishingX=0, FishingY=0, FishingZ=0, FishingHeading=0,
  SecretQuestIndex=1, SecretQuestName="[01] Escape from Alcatraz", AutoSecretQuestRoute=false,
  SecretQuestRunMode="Tự làm quest khả dụng", MobileTouchFirst=true,
  AutoFullMelee=false, FullMeleeAutoBuy=false, FullMeleeAutoFarm=true,
  FullMeleeMaxPurchases=1, FullMeleeCooldown=45,
  HalloweenGhostChase=true, HalloweenSceneFight=true, HalloweenAutoFight=true,
  KatakuriAutoSummon=true,KatakuriCheckInterval=15,KatakuriSummonInterval=30,
  RaidAutoBuyChip=true,RaidAutoAwaken=false,RaidMagnetRadius=175,

  V4AutoTrial=true,V4AutoGear=true,V4AutoLever=true,V4AutoMoon=false,
  V4TrialMagnetRadius=170,
  V4AutoSpendPoints=false,V4GearChoice="Alpha",
  MenuSize=.78, -- v38.5: compact mobile default; slider still allows 0.76–1.00
  HubStartPage="home",
  EventPromptKeyword="Pumpkin", BoatCruiseSpeed=170,

  -- v15: Spooky source mechanics, rewritten into the andepzai runtime; NO Spooky UI or loader.
  SpookyFastAttack=false,SpookyM1Extender=false,SpookyGunAura=false,
  SpookyPVP=false,SpookyManualTargetOnly=true,SpookyTeamCheck=true,
  SpookySafeZoneCheck=true,SpookyMinPlayerLevel=0,SpookyBlacklist="",
  SpookyTargetRange=120,SpookyAttackDelay=.18,SpookyM1Range=90,PVEHitProtocol="Auto",
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
local FILE = FOLDER .. "/config_v38.json"
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
        if not api("isfile")(path) then path=FOLDER.."/config_v37.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v36.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v35.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v34.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v33.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v32.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v31.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v30.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v29.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v28.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v27.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v26.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v25.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v24.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v23.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v22.json" end
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
        FarmHeight=18,FarmHoverLock=true,TweenSpeed=350,AttackDelay=0.12,QuestDelay=4,
        AutoQuest=true,Combat=true,AutoEquip=true,AutoHaki=true,Noclip=true,
        FastAttackEnabled=true,CombatMode="Adaptive",AttackRange=32,
        MoveRetargetThreshold=5,MoveRetargetDelay=0.35,
        MovementMode="Flight Tween",SmartPortal=false,
    }) do Config[key]=value end
end
-- One-time migration: old presets often saved 160; update to the requested 350.
-- On later v21 launches respect the user-selected slider speed.
if not loadedPreset then Config.TweenSpeed=350 end
if loadedFrom~=FILE then
    Config.MovementMode="Flight Tween"
    Config.Noclip=true
end
Config.MobMagnet=true -- v33: built in; old user config may contain false.
-- v38.5: keep automatic magnet enabled; the ownership helper is only used when
-- the executor exposes it, otherwise the code falls back to local movement.
Config.MobMagnetNetworkAssist=true
if UIS.TouchEnabled and math.abs((tonumber(Config.MenuSize) or .84)-.84)<.001 then
    Config.MenuSize=.78
end
Config.FarmEnabled=false -- Explicit START is required even if old config was running.
Config.AutoTrickOrTreat=false -- Never resume Halloween automation at script startup.
Config.AutoSecretQuestRoute=false -- Require an explicit mobile toggle on every injection.
Config.AutoFullMelee=false -- No unattended purchases/training at load.
Config.FullMeleeAutoBuy=false -- Spend authorization does not survive reinjection.
Config.V4AutoSpendPoints=false -- Reauthorize spending points each execution.
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
-- Halloween names observed in user-supplied captures and current community
-- event references. Dapper Jack is separate; it is not assumed to be Pumpkin.
STATE.Halloween2026={BossStatus="Chưa quét",MaterialStatus="Chưa kiểm tra",
    Bits=nil,Seeds=nil,Candy=nil,Busy=false,Generation=0,LastInventory=-math.huge}
STATE.Halloween2026.BossNames={
    hellfiregas="Hellfire Gas",
    thegreatpumpkin="The Great Pumpkin",
    greatpumpkin="The Great Pumpkin",
    dapperjack="Dapper Jack",
    unboundwerewolf="Unbound Werewolf",
}
for _,name in pairs(STATE.Halloween2026.BossNames) do STATE.BossNames[norm(name)]=true end
STATE.BossNames[norm("Great Pumpkin")]=true
function STATE.Halloween2026.MatchBoss(name,selection)
    local key=norm(name):gsub("[^%w]","")
    local canonical=STATE.Halloween2026.BossNames[key]
    if not canonical then return nil end
    if selection and selection~="" and selection~="Tất cả" and selection~=canonical then return nil end
    return canonical
end
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

-- Safe static part of the supplied hub's "Farm All Island" module.  Only the
-- island anchor and allowed mob names are copied; its duplicate combat/tween
-- loop is not used.  AD38 sends these targets through the single Farm engine,
-- so quest, magnet, flight and mobile movement guards remain in one place.
STATE.IslandFarmCatalog={
    [1]={
        ["Pirates"]={CFrame=CFrame.new(1047,15,1506),Mobs={"Bandit"}},
        ["Marine"]={CFrame=CFrame.new(-2709.68,24.52,2104.25),Mobs={"Trainee","Chief Petty Officer"}},
        ["Jungle"]={CFrame=CFrame.new(-1600,36,150),Mobs={"Monkey","Gorilla"}},
        ["Pirate Village"]={CFrame=CFrame.new(-1100,4,3850),Mobs={"Pirate","Brute"}},
        ["Desert"]={CFrame=CFrame.new(1090,7,4370),Mobs={"Desert Bandit","Desert Officer"}},
        ["Frozen Village"]={CFrame=CFrame.new(1200,28,-1500),Mobs={"Snow Bandit","Snowman"}},
        ["Marine Fortress"]={CFrame=CFrame.new(-4500,20,4250),Mobs={"Chief Petty Officer"}},
        ["Skylands Lower"]={CFrame=CFrame.new(-5000,700,-2500),Mobs={"Sky Bandit","Dark Master"}},
        ["Prison"]={CFrame=CFrame.new(4875,6,735),Mobs={"Prisoner","Dangerous Prisoner"}},
        ["Colosseum"]={CFrame=CFrame.new(-1535,7,-3014),Mobs={"Toga Warrior","Gladiator"}},
        ["Magma Village"]={CFrame=CFrame.new(-5200,8,8400),Mobs={"Military Soldier","Military Spy"}},
        ["Underwater City"]={CFrame=CFrame.new(61160,5,1819),Mobs={"Fishman Warrior","Fishman Commando"}},
        ["Skylands Upper"]={CFrame=CFrame.new(-7880,5545,-380),Mobs={"Shanda","Royal Squad","Royal Soldier"}},
    },
    [2]={
        ["Kingdom of Rose"]={CFrame=CFrame.new(-321,73,297),Mobs={"Raider","Mercenary","Swan Pirate","Factory Staff"}},
        ["Green Zone"]={CFrame=CFrame.new(-2447,73,-3211),Mobs={"Marine Lieutenant","Marine Captain"}},
        ["Graveyard Island"]={CFrame=CFrame.new(-5552,194,-776),Mobs={"Zombie","Vampire"}},
        ["Snow Mountain"]={CFrame=CFrame.new(561,401,-5306),Mobs={"Snow Trooper","Winter Warrior"}},
        ["Hot and Cold (Cold)"]={CFrame=CFrame.new(-6026,15,-5062),Mobs={"Lab Subordinate","Horned Warrior"}},
        ["Hot and Cold (Hot)"]={CFrame=CFrame.new(-5478,15,-5240),Mobs={"Magma Ninja","Lava Pirate"}},
        ["Cursed Ship"]={CFrame=CFrame.new(902,126,33071),Mobs={"Ship Deckhand","Ship Engineer","Ship Steward","Ship Officer"}},
        ["Ice Castle"]={CFrame=CFrame.new(6137,294,-6747),Mobs={"Arctic Warrior","Snow Lurker"}},
        ["Forgotten Island"]={CFrame=CFrame.new(-3043,238,-10191),Mobs={"Sea Soldier","Water Fighter"}},
    },
    [3]={
        ["Port Town"]={CFrame=CFrame.new(-340,21,5524),Mobs={"Pirate Millionaire","Pistol Billionaire"}},
        ["Hydra Island"]={CFrame=CFrame.new(5294,1005,391),Mobs={"Dragon Crew Warrior","Dragon Crew Archer","Female Islander","Training Dummy"}},
        ["Great Tree"]={CFrame=CFrame.new(2681,1682,-7190),Mobs={"Marine Commodore","Marine Rear Admiral"}},
        ["Floating Turtle"]={CFrame=CFrame.new(-12528,332,-8658),Mobs={"Forest Pirate","Mythological Pirate","Jungle Pirate","Musketeer Pirate","Fishman Raider","Fishman Captain"}},
        ["Haunted Castle"]={CFrame=CFrame.new(-9515,142,5536),Mobs={"Reborn Skeleton","Living Zombie","Demonic Soul","Posessed Mummy"}},
        ["Sea of Treats"]={CFrame=CFrame.new(-1145,13,-14450),Mobs={"Peanut Scout","Peanut President","Ice Cream Commander","Cookie Crafter","Cake Guard","Baking Staff","Head Baker","Cocoa Warrior","Chocolate Bar Battler","Sweet Thief","Candy Rebel"}},
        ["Tiki Outpost"]={CFrame=CFrame.new(-16101,12,380),Mobs={"Isle Outlaw","Island Boy","Sun-kissed Warrior","Isle Champion"}},
        ["Submerged Island"]={CFrame=Vector3.new(11256,-2138,9888),Mobs={"Reef Bandit","Coral Pirate","Sea Chanter","Ocean Prophet","High Disciple","Grand Devotee"}},
    },
}
STATE.GetIslandFarmOptions=function()
    local out={}
    for name in pairs((STATE.IslandFarmCatalog or {})[STATE.World] or {}) do out[#out+1]=name end
    table.sort(out)
    return out
end
STATE.GetIslandFarmEntry=function(name)
    local data=(STATE.IslandFarmCatalog or {})[STATE.World] or {}
    if type(name)=="string" and data[name] then return data[name],name end
    local firstName
    for key in pairs(data) do if not firstName or key<firstName then firstName=key end end
    return firstName and data[firstName] or nil,firstName
end
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
        ["monkey"]={{-1866.3,29.9,21.6},{-1758.7,30.9,-31.8},{-1637.5,30.0,19.6},{-1610.2,29.2,399.7},{-1525.6,27.2,164.0},{-1450.6,30.0,306.1},{-1299.4,17.6,81.4}},
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
        ["Submerged Island"]={pos={10533.29,-2030.09,9940.48},source="Location"},
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

--[[
  andepzai V24 / 3-SEA ROUTE DIRECTOR
  Spawn samples in Workspace.7z are snapshots of client-visible objects,
  not guarantees that an NPC is still there. The planner avoids treating an
  empty historical coordinate as a fresh spawn forever.
]]
do
    local Route={Sea=STATE.World,Entry=nil,LastStatus="Standby",LastName="",
        LastChanged=0,Switched=0,ArrivedEmpty=0,FoundLive=0,Skipped=0,
        ActiveIndex=0,ActiveGoal=nil,ActiveRegion="Unknown",
        RegionVisits={},SpawnVisits={}, Quarantine={}, LastEnemySeen=0,
        LastSkippedAt=0,LastSource="None",StaticPoints=0,
        LastDecision=0,VisitedNames={}, LastTargetLevel=0}
    STATE.RouteDirector=Route
    local function keyFor(name)
        return tostring(STATE.World)..":"..norm(tostring(name or ""))
    end
    local function atlasPoints(name)
        local sea=STATE.Atlas and STATE.Atlas.Spawns[STATE.World]
        local points=sea and sea[norm(name)]
        return type(points)=="table" and points or nil
    end
    local function locVec(arr)
        return Vector3.new(arr[1],arr[2],arr[3])
    end
    local function regionName(vec)
        if not STATE.Atlas or not STATE.Atlas.Regions then return "Unknown" end
        local bestName,bestDistance="Unknown",math.huge
        for name,info in pairs(STATE.Atlas.Regions[STATE.World] or {}) do
            local pos=info.pos
            if pos and pos[1] and pos[2] and pos[3] then
                local d=(Vector3.new(pos[1],pos[2],pos[3])-vec).Magnitude
                if d<bestDistance then bestName,bestDistance=name,d end
            end
        end
        return bestDistance<2400 and bestName or "Unknown"
    end
    local function validSamples(name)
        local points=atlasPoints(name)
        if not points then return {} end
        local list={}
        local seen={}
        for index,p in ipairs(points) do
            if type(p)=="table" and type(p[1])=="number" and
                type(p[2])=="number" and type(p[3])=="number" then
                local vec=locVec(p)
                local signature=math.floor(vec.X/5)..":"..math.floor(vec.Y/5)..":"..math.floor(vec.Z/5)
                if not seen[signature] then
                    seen[signature]=true
                    list[#list+1]={Index=index,Position=vec}
                end
            end
        end
        return list
    end
    local function recordSkip(entry,reason)
        local now=os.clock()
        local key=entry.Name..":"..tostring(entry.Index)
        local interval=math.clamp(tonumber(Config.RouteCooldown) or 28,12,100)
        Route.Quarantine[key]=now+interval
        entry.Failures=(entry.Failures or 0)+1
        Route.ArrivedEmpty=Route.ArrivedEmpty+1
        Route.LastStatus="Empty spawn: "..entry.Name.." #"..entry.Index.." -> waiting "..interval.."s"
        Route.LastSource=reason or "Unoccupied Atlas point"
        Route.LastSkippedAt=now
        Route.LastChanged=now
        Route.Entry=nil
        Route.ActiveGoal=nil
        Route.ActiveIndex=0
    end
    local function pickCandidate(name,source)
        local options=validSamples(name)
        Route.StaticPoints=#options
        if #options==0 then Route.LastStatus="No scanned spawn coordinates: "..name;return nil end
        local time=os.clock()
        local best,bestScore=nil,math.huge
        for _,candidate in ipairs(options) do
            local k=keyFor(name)..":"..candidate.Index
            local waitUntil=Route.Quarantine[k] or 0
            if time>=waitUntil then
                local distance=(candidate.Position-source).Magnitude
                local visits=Route.SpawnVisits[k] or 0
                local score=distance+visits*math.min(125,tonumber(Config.RouteVisitPenalty) or 45)
                -- Favor a nearby, confirmed-live mob group over a stale distant
                -- Atlas coordinate, but never invent a spawn or a quest.
                if score<bestScore then bestScore,best=candidate end
            end
        end
        if not best then
            local waitMin=math.huge
            for _,candidate in ipairs(options) do
                local k=keyFor(name)..":"..candidate.Index
                local deadline=Route.Quarantine[k] or 0
                if deadline<waitMin then waitMin=deadline;best=candidate end
            end
            Route.LastStatus="All scanned points were empty; least-delayed fallback"
        end
        return best
    end
    function Route.Choose(name,from)
        if STATE.World==0 or not Config.AtlasUseScannedSpawns then return nil end
        if not Config.RouteSmartScan then
            return STATE.AtlasSpawnCFrame and STATE.AtlasSpawnCFrame(name,from)
        end
        local key=keyFor(name)
        local now=os.clock()
        if typeof(from)~="Vector3" then
            local _,_,r=alive()
            from=r and r.Position or Vector3.zero
        end
        local current=Route.Entry
        if current and (current.Name~=key or not current.Position) then
            Route.Entry=nil;current=nil
        end
        if current then
            local dist=(from-current.Position).Magnitude
            if dist<=math.clamp(tonumber(Config.RouteArrivalRadius) or 70,30,150) then
                if not current.ArrivedAt then
                    current.ArrivedAt=now
                    Route.LastStatus="Waiting for streamed mobs at Atlas point "..current.Index
                elseif now-current.ArrivedAt>=math.clamp(tonumber(Config.RouteSpawnWait) or 7,4,30) then
                    recordSkip(current,"No living NPC of this type loaded")
                    current=nil
                end
            elseif current.ArrivedAt then
                -- Reaching a coordinate is one-way; don't reset its empty timer
                -- because the character moved 2 studs away during combat.
                if dist>180 then current.ArrivedAt=nil end
            end
        end
        if not current then
            local picked=pickCandidate(name,from)
            if not picked then return nil end
            current={Name=key,Label=name,Index=picked.Index,
                Position=picked.Position,Started=now,ArrivedAt=nil}
            Route.Entry=current
            Route.Switched=Route.Switched+1
            Route.LastChanged=now
            Route.LastName=name
            Route.LastSource="Workspace.7z Sea "..STATE.World
            local visitKey=key..":"..current.Index
            Route.SpawnVisits[visitKey]=(Route.SpawnVisits[visitKey] or 0)+1
            Route.ActiveRegion=regionName(current.Position)
            Route.RegionVisits[Route.ActiveRegion]=(Route.RegionVisits[Route.ActiveRegion] or 0)+1
            Route.LastStatus="Selected "..name.." / "..Route.ActiveRegion.." #"..current.Index
        end
        Route.ActiveIndex=current.Index
        Route.ActiveGoal=current.Position
        Route.LastDecision=now
        local hover=math.max(15,tonumber(Config.FarmHeight) or 18)
        return CFrame.new(current.Position+Vector3.new(0,hover+6,0))
    end
    function Route.EnemyFound(name,mob)
        if not mob or not STATE.IsAliveNPC(mob) then return end
        local current=Route.Entry
        if current and current.Label and norm(current.Label)==norm(name or mob.Name) then
            Route.FoundLive=Route.FoundLive+1
            Route.LastEnemySeen=os.clock()
            Route.Entry=nil
            Route.ActiveGoal=nil
            Route.ActiveIndex=0
            Route.LastStatus="Live NPC found: "..tostring(name or mob.Name)
        end
    end
    function Route.Skip()
        local current=Route.Entry
        if not current then
            Route.LastStatus="No active Atlas destination to skip"
            return false
        end
        recordSkip(current,"Manually skipped")
        Route.Skipped=Route.Skipped+1
        return true
    end
    function Route.Reset(keepHistory)
        Route.Entry=nil;Route.ActiveGoal=nil;Route.ActiveIndex=0
        Route.LastStatus="Atlas route reset"
        if not keepHistory then
            Route.Quarantine={};Route.SpawnVisits={};Route.RegionVisits={}
            Route.Switched=0;Route.ArrivedEmpty=0
        end
    end
    function Route.Snapshot()
        return {Sea=STATE.World,CurrentMob=Route.LastName,
            ActiveSpawn=Route.ActiveIndex,Region=Route.ActiveRegion,
            AvailableSamples=Route.StaticPoints,RouteSwitches=Route.Switched,
            EmptySpawns=Route.ArrivedEmpty,LiveFound=Route.FoundLive,
            LastStatus=Route.LastStatus,Source=Route.LastSource,
            TotalRegions=STATE.Atlas and STATE.Atlas.Counts[STATE.World] and
                STATE.Atlas.Counts[STATE.World].regions or 0,
            Note="Client Atlas samples are historical coordinates, not live NPC guarantees"}
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
 [3]={Vector3.new(-5058.77,314.52,-3155.88),Vector3.new(-12463.87,374.91,-7523.77),
      Vector3.new(28282.57,14896.85,105.1),Vector3.new(5661.53,1013.09,-334.96),
      Vector3.new(5319,23,-93),Vector3.new(5651,1018,-350),Vector3.new(28286,14897,103)},
}

-- Static Sea 3 travel data cross-checked against the supplied Kaitun reference.
-- It is used only as a navigation fallback when streaming has not created the
-- island/NPC model yet; it does not call an unknown remote or bypass validation.
STATE.SubmergedTravelData={
    Center=Vector3.new(11256,-2138,9888),
    Radius=4200,
    SubmarineEntrance=CFrame.new(-16269.4082,23.9799957,1371.66235),
    FallbackExit=CFrame.new(11427,-2157,9726),
    Entrances={
        Mansion=CFrame.new(-12500,337,-7480),
        Hydra=CFrame.new(5710,1015,-255),
        Castle=CFrame.new(-5050,315,-3150),
        GreatTree=CFrame.new(3000,2295,-7325),
        Tiki=CFrame.new(-16800,60,290),
        Submarine=CFrame.new(11520,0,9830),
    },
    QuestGivers={
        ["Submerged Quest Giver 1"]=CFrame.new(10778.875,-2087.72437,9265.18359),
        ["Submerged Quest Giver 2"]=CFrame.new(10880.6855,-2086.20044,10032.624),
        ["Submerged Quest Giver 3"]=CFrame.new(9640.08789,-1992.44507,9613.65234),
    },
    QuestIds={SubmergedQuest1=true,SubmergedQuest2=true,SubmergedQuest3=true},
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

-- v25.0 static reference data copied from the user's uploaded data.lua.txt.
-- No remote or external code execution; the static data stays local.
do
    local reference = (function()
return {
	QUESTS = {
		Sea_1 = {
			{1, 9, "Team-dependent", "Team-dependent", 1},
			{10, 14, "Monkey", "JungleQuest", 1},
			{15, 29, "Gorilla", "JungleQuest", 2, "The Gorilla King", 20},
			{30, 39, "Pirate", "BuggyQuest1", 1},
			{40, 59, "Brute", "BuggyQuest1", 2, "Chief", 55},
			{60, 74, "Desert Bandit", "DesertQuest", 1},
			{75, 89, "Desert Officer", "DesertQuest", 2},
			{90, 99, "Snow Bandit", "SnowQuest", 1},
			{100, 119, "Snowman", "SnowQuest", 2, "Yeti", 105},
			{120, 149, "Chief Petty Officer", "MarineQuest2", 1, "Vice Admiral", 130},
			{150, 174, "Sky Bandit", "SkyQuest", 1},
			{175, 189, "Dark Master", "SkyQuest", 2},
			{190, 209, "Prisoner", "PrisonerQuest", 1},
			{210, 249, "Dangerous Prisoner", "PrisonerQuest", 2, {"Warden", 220, "ImpelQuest", 1}, {"Chief Warden", 230, "ImpelQuest", 2}, {"Swan", 240, "ImpelQuest", 3}},
			{250, 274, "Toga Warrior", "ColosseumQuest", 1},
			{275, 299, "Gladiator", "ColosseumQuest", 2},
			{300, 324, "Military Soldier", "MagmaQuest", 1},
			{325, 374, "Military Spy", "MagmaQuest", 2, "Magma Admiral", 350},
			{375, 399, "Fishman Warrior", "FishmanQuest", 1},
			{400, 449, "Fishman Commando", "FishmanQuest", 2, "Fishman Lord", 425},
			{450, 474, "God's Guard", "SkyExp1Quest", 1},
			{475, 524, "Shanda", "SkyExp1Quest", 2, "Wysper", 500},
			{525, 549, "Royal Squad", "SkyExp2Quest", 1},
			{550, 624, "Royal Soldier", "SkyExp2Quest", 2, "Thunder God", 575},
			{625, 649, "Galley Pirate", "FountainQuest", 1},
			{650, 9999, "Galley Captain", "FountainQuest", 2, "Cyborg", 675},
		},
		Sea_2 = {
			{700, 724, "Raider", "Area1Quest", 1},
			{725, 774, "Mercenary", "Area1Quest", 2, "Diamond", 750},
			{775, 799, "Swan Pirate", "Area2Quest", 1},
			{800, 874, "Factory Staff", "Area2Quest", 2, "Jeremy", 850},
			{875, 899, "Marine Lieutenant", "MarineQuest3", 1},
			{900, 949, "Marine Captain", "MarineQuest3", 2, "Orbitus", 925},
			{950, 974, "Zombie", "ZombieQuest", 1},
			{975, 999, "Vampire", "ZombieQuest", 2},
			{1000, 1049, "Snow Trooper", "SnowMountainQuest", 1},
			{1050, 1099, "Winter Warrior", "SnowMountainQuest", 2},
			{1100, 1124, "Lab Subordinate", "IceSideQuest", 1},
			{1125, 1174, "Horned Warrior", "IceSideQuest", 2, "Smoke Admiral", 1150},
			{1175, 1199, "Magma Ninja", "FireSideQuest", 1},
			{1200, 1249, "Lava Pirate", "FireSideQuest", 2},
			{1250, 1274, "Ship Deckhand", "ShipQuest1", 1},
			{1275, 1299, "Ship Engineer", "ShipQuest1", 2},
			{1300, 1324, "Ship Steward", "ShipQuest2", 1},
			{1325, 1349, "Ship Officer", "ShipQuest2", 2},
			{1350, 1374, "Arctic Warrior", "FrostQuest", 1},
			{1375, 1424, "Snow Lurker", "FrostQuest", 2, "Awakened Ice Admiral", 1400},
			{1425, 1449, "Sea Soldier", "ForgottenQuest", 1},
			{1450, 9999, "Water Fighter", "ForgottenQuest", 2, "Tide Keeper", 1475},
		},
		Sea_3 = {
			{1500, 1524, "Pirate Millionaire", "PiratePortQuest", 1},
			{1525, 1574, "Pistol Billionaire", "PiratePortQuest", 2},
			{1575, 1599, "Dragon Crew Warrior", "DragonCrewQuest", 1},
			{1600, 1624, "Dragon Crew Archer", "DragonCrewQuest", 2},
			{1625, 1649, "Hydra Enforcer", "VenomCrewQuest", 1},
			{1650, 1699, "Venomous Assailant", "VenomCrewQuest", 2},
			{1700, 1724, "Marine Commodore", "MarineTreeIsland", 1},
			{1725, 1774, "Marine Rear Admiral", "MarineTreeIsland", 2},
			{1775, 1799, "Fishman Raider", "DeepForestIsland3", 1},
			{1800, 1824, "Fishman Captain", "DeepForestIsland3", 2},
			{1825, 1849, "Forest Pirate", "DeepForestIsland", 1},
			{1850, 1899, "Mythological Pirate", "DeepForestIsland", 2},
			{1900, 1924, "Jungle Pirate", "DeepForestIsland2", 1},
			{1925, 1974, "Musketeer Pirate", "DeepForestIsland2", 2},
			{1975, 1999, "Reborn Skeleton", "HauntedQuest1", 1},
			{2000, 2024, "Living Zombie", "HauntedQuest1", 2},
			{2025, 2049, "Demonic Soul", "HauntedQuest2", 1},
			{2050, 2074, "Posessed Mummy", "HauntedQuest2", 2},
			{2075, 2099, "Peanut Scout", "NutsIslandQuest", 1},
			{2100, 2124, "Peanut President", "NutsIslandQuest", 2},
			{2125, 2149, "Ice Cream Chef", "IceCreamIslandQuest", 1},
			{2150, 2199, "Ice Cream Commander", "IceCreamIslandQuest", 2},
			{2200, 2224, "Cookie Crafter", "CakeQuest1", 1},
			{2225, 2249, "Cake Guard", "CakeQuest1", 2},
			{2250, 2274, "Baking Staff", "CakeQuest2", 1},
			{2275, 2299, "Head Baker", "CakeQuest2", 2},
			{2300, 2324, "Cocoa Warrior", "ChocQuest1", 1},
			{2325, 2349, "Chocolate Bar Battler", "ChocQuest1", 2},
			{2350, 2374, "Sweet Thief", "ChocQuest2", 1},
			{2375, 2399, "Candy Rebel", "ChocQuest2", 2},
			{2400, 2424, "Candy Pirate", "CandyQuest1", 1},
			{2425, 2449, "Snow Demon", "CandyQuest1", 2},
			{2450, 2474, "Isle Outlaw", "TikiQuest1", 1},
			{2475, 2499, "Island Boy", "TikiQuest1", 2},
			{2500, 2524, "Sun-kissed Warrior", "TikiQuest2", 1},
			{2525, 2549, "Isle Champion", "TikiQuest2", 2},
			{2550, 2574, "Serpent Hunter", "TikiQuest3", 1},
			{2575, 2599, "Skull Slayer", "TikiQuest3", 2},
			{2600, 2624, "Reef Bandit", "SubmergedQuest1", 1},
			{2625, 2649, "Coral Pirate", "SubmergedQuest1", 2},
			{2650, 2674, "Sea Chanter", "SubmergedQuest2", 1},
			{2675, 2699, "High Disciple", "SubmergedQuest3", 1},
			{2700, 9999, "Grand Devotee", "SubmergedQuest3", 2},
		}
	},
	BossList = {
		Sea_1 = {
			{20, "The Gorilla King", "JungleQuest", 3, CFrame.new(-1602, 37, 153)},
			{55, "Chief", "BuggyQuest1", 2, CFrame.new(-1140, 5, 3827)},
			{105, "Yeti", "SnowQuest", 3, CFrame.new(1387, 87, -1298)},
			{130, "Vice Admiral", "MarineQuest2", 2, CFrame.new(-5036, 29, 4325)},
			{220, "Warden", "ImpelQuest", 1, CFrame.new(5192, 3, 686)},
			{230, "Chief Warden", "ImpelQuest", 2, CFrame.new(5192, 3, 686)},
			{240, "Swan", "ImpelQuest", 3, CFrame.new(5192, 3, 686)},
			{350, "Magma Admiral", "MagmaQuest", 3, CFrame.new(-5315, 12, 8517)},
			{425, "Fishman Lord", "FishmanQuest", 3, CFrame.new(61123, 18, 1569)},
			{500, "Wysper", "SkyExp1Quest", 3, CFrame.new(-7862, 5546, -380)},
			{575, "Thunder God", "SkyExp2Quest", 3, CFrame.new(-7903, 5636, -1411)},
			{675, "Cyborg", "FountainQuest", 3, CFrame.new(5258, 39, 4050)},
		},
		Sea_2 = {
			{750, "Diamond", "Area1Quest", 3, CFrame.new(-428, 73, 1835)},
			{850, "Jeremy", "Area2Quest", 3, CFrame.new(637, 73, 918)},
			{925, "Orbitus", "MarineQuest3", 3, CFrame.new(-2442, 73, -3218)},
			{1150, "Smoke Admiral", "IceSideQuest", 3, CFrame.new(-5429, 16, -5298)},
			{1400, "Awakened Ice Admiral", "FrostQuest", 3, CFrame.new(5669, 29, -6483)},
			{1475, "Tide Keeper", "ForgottenQuest", 3, CFrame.new(-3054, 237, -10145)},
		},
		Sea_3 = {
			{1575, "Stone", "PiratePortQuest", 3, CFrame.new(-290, 44, 5580)},
			{1775, "Kilo Admiral", "MarineTreeIsland", 3, CFrame.new(2179, 29, -6740)},
			{1875, "Captain Elephant", "DeepForestIsland", 3, CFrame.new(-13233, 332, -7626)},
			{1950, "Beautiful Pirate", "DeepForestIsland2", 3, CFrame.new(-12682, 391, -9902)},
			{2175, "Cake Queen", "IceCreamIslandQuest", 3, CFrame.new(-819, 65, -10967)},
		}
	},
	MaterialEnemies = {
		Sea_1 = {
			["Angel Wings"] = { "Shanda", "Royal Squad", "Royal Soldier", "Wysper", "Thunder God" },
			["Leather + Scrap Metal"] = { "Brute", "Pirate" },
			["Magma Ore"] = { "Military Soldier", "Military Spy", "Magma Admiral" },
			["Fish Tail"] = { "Fishman Warrior", "Fishman Commando", "Fishman Lord" },
		},
		Sea_2 = {
			["Leather + Scrap Metal"] = { "Marine Captain" },
			["Magma Ore"] = { "Magma Ninja", "Lava Pirate" },
			["Ectoplasm"] = { "Ship Deckhand", "Ship Engineer", "Ship Steward", "Ship Officer" },
			["Mystic Droplet"] = { "Water Fighter" },
			["Radioactive Material"] = { "Factory Staff" },
			["Vampire Fang"] = { "Vampire" },
		},
		Sea_3 = {
			["Leather + Scrap Metal"] = { "Jungle Pirate" },
			["Demonic Wisp"] = { "Demonic Soul" },
			["Fish Tail"] = { "Fishman Raider", "Fishman Captain" },
			["Conjured Cocoa"] = { "Chocolate Bar Battler", "Cocoa Warrior" },
			["Dragon Scale"] = { "Dragon Crew Archer", "Dragon Crew Warrior" },
			["Gunpowder"] = { "Pistol Billionaire" },
			["Mini Tusk"] = { "Mythological Pirate" },
			["Nightmare Catcher"] = { "Reborn Skeleton", "Living Zombie" },
		}
	},
	Materials = {
		Sea_1 = { "Leather + Scrap Metal", "Angel Wings", "Magma Ore", "Fish Tail" },
		Sea_2 = { "Leather + Scrap Metal", "Radioactive Material", "Ectoplasm", "Mystic Droplet", "Magma Ore", "Vampire Fang" },
		Sea_3 = { "Leather + Scrap Metal", "Demonic Wisp", "Conjured Cocoa", "Dragon Scale", "Gunpowder", "Fish Tail", "Mini Tusk", "Nightmare Catcher" }
	},
	BossNames = {
		Sea_1 = { "The Gorilla King", "Chief", "Yeti", "Vice Admiral", "Warden", "Chief Warden", "Swan", "Magma Admiral", "Fishman Lord", "Wysper", "Thunder God", "Cyborg", "Saw" },
		Sea_2 = { "Diamond", "Jeremy", "Orbitus", "Smoke Admiral", "Awakened Ice Admiral", "Tide Keeper", "Don Swan" },
		Sea_3 = { "Stone", "Kilo Admiral", "Captain Elephant", "Beautiful Pirate", "Cake Queen" }
	},
	MeleeNames = {
		Sea_1 = { "Black Leg", "Electro", "Fishman Karate" },
		Sea_2 = { "Death Step", "Dragon Claw", "Sharkman Karate", "Superhuman" },
		Sea_3 = { "Dragon Talon", "Electric Claw", "Godhuman", "Sanguine Art" }
	},
	Melees = {
		["Black Leg"] = {
			Model = "Dark Step Teacher",
			Npc = "Dark Step Teacher",
			npc = "Dark Step Teacher",
			CFrame = CFrame.new(-1147.284, 4.752, 3816.326),
			cframe = CFrame.new(-1147.284, 4.752, 3816.326),
			Remote = { "BuyBlackLeg" },
			remote = { "BuyBlackLeg" },
			Sea = 1
		},
		["Electro"] = {
			Model = "Mad Scientist",
			Npc = "Mad Scientist",
			npc = "Mad Scientist",
			CFrame = CFrame.new(-4842.112, 717.670, -2623.149),
			cframe = CFrame.new(-4842.112, 717.670, -2623.149),
			Remote = { "BuyElectro" },
			remote = { "BuyElectro" },
			Sea = 1
		},
		["Fishman Karate"] = {
			Model = "Water Kung-fu Teacher",
			Npc = "Water Kung-fu Teacher",
			npc = "Water Kung-fu Teacher",
			CFrame = CFrame.new(61122.652, 18.497, 1568.351),
			cframe = CFrame.new(61122.652, 18.497, 1568.351),
			Remote = { "BuyFishmanKarate" },
			remote = { "BuyFishmanKarate" },
			Sea = 1
		},
		["Dragon Claw"] = {
			Model = "Sabi",
			Npc = "Sabi",
			npc = "Sabi",
			CFrame = CFrame.new(699.029, 185.661, 654.895),
			cframe = CFrame.new(699.029, 185.661, 654.895),
			CFrames = {
				Sea_2 = CFrame.new(699.029, 185.661, 654.895),
			},
			cframes = {
				Sea_2 = CFrame.new(699.029, 185.661, 654.895),
			},
			Remote = { { "BlackbeardReward", "DragonClaw", "1" }, { "BlackbeardReward", "DragonClaw", "2" } },
			remote = { { "BlackbeardReward", "DragonClaw", "1" }, { "BlackbeardReward", "DragonClaw", "2" } },
			Sea = 2
		},
		["Superhuman"] = {
			Model = "Martial Arts Master",
			Npc = "Martial Arts Master",
			npc = "Martial Arts Master",
			CFrame = CFrame.new(1377.125, 246.542, -5189.951),
			cframe = CFrame.new(1377.125, 246.542, -5189.951),
			CFrames = {
				Sea_2 = CFrame.new(1377.125, 246.542, -5189.951),
			},
			cframes = {
				Sea_2 = CFrame.new(1377.125, 246.542, -5189.951),
			},
			Remote = { "BuySuperhuman" },
			remote = { "BuySuperhuman" },
			Sea = 2
		},
		["Death Step"] = {
			Model = "Phoeyu, the Reformed",
			Npc = "Phoeyu, the Reformed",
			npc = "Phoeyu, the Reformed",
			CFrame = CFrame.new(6356.472, 296.100, -6762.771),
			cframe = CFrame.new(6356.472, 296.100, -6762.771),
			CFrames = {
				Sea_2 = CFrame.new(6356.472, 296.100, -6762.771),
			},
			cframes = {
				Sea_2 = CFrame.new(6356.472, 296.100, -6762.771),
			},
			Remote = { "BuyDeathStep" },
			remote = { "BuyDeathStep" },
			Sea = 2
		},
		["Sharkman Karate"] = {
			Model = "Sharkman Teacher",
			Npc = "Sharkman Teacher",
			npc = "Sharkman Teacher",
			CFrame = CFrame.new(-2599.622, 238.198, -10315.998),
			cframe = CFrame.new(-2599.622, 238.198, -10315.998),
			CFrames = {
				Sea_2 = CFrame.new(-2599.622, 238.198, -10315.998),
			},
			cframes = {
				Sea_2 = CFrame.new(-2599.622, 238.198, -10315.998),
			},
			Remote = { "BuySharkmanKarate" },
			remote = { "BuySharkmanKarate" },
			Sea = 2
		},
		["Electric Claw"] = {
			Model = "Previous Hero",
			Npc = "Previous Hero",
			npc = "Previous Hero",
			CFrame = CFrame.new(-10368.514, 331.788, -10134.120),
			cframe = CFrame.new(-10368.514, 331.788, -10134.120),
			CFrames = {
				Sea_3 = CFrame.new(-10368.514, 331.788, -10134.120),
			},
			cframes = {
				Sea_3 = CFrame.new(-10368.514, 331.788, -10134.120),
			},
			Remote = { "BuyElectricClaw" },
			remote = { "BuyElectricClaw" },
			Sea = 3
		},
		["Dragon Talon"] = {
			Model = "Uzoth",
			Npc = "Uzoth",
			npc = "Uzoth",
			CFrame = CFrame.new(-9515.372, 142.130, 5535.089),
			cframe = CFrame.new(-9515.372, 142.130, 5535.089),
			CFrames = {
				Sea_3 = CFrame.new(-9515.372, 142.130, 5535.089),
			},
			cframes = {
				Sea_3 = CFrame.new(-9515.372, 142.130, 5535.089),
			},
			Remote = { "BuyDragonTalon" },
			remote = { "BuyDragonTalon" },
			Sea = 3
		},
		["Godhuman"] = {
			Model = "Ancient Monk",
			Npc = "Ancient Monk",
			npc = "Ancient Monk",
			CFrame = CFrame.new(-12463.870, 374.910, -7523.770),
			cframe = CFrame.new(-12463.870, 374.910, -7523.770),
			CFrames = {
				Sea_3 = CFrame.new(-12463.870, 374.910, -7523.770),
			},
			cframes = {
				Sea_3 = CFrame.new(-12463.870, 374.910, -7523.770),
			},
			Remote = { "BuyGodhuman" },
			remote = { "BuyGodhuman" },
			Sea = 3
		},
		["Sanguine Art"] = {
			Model = "Shafi",
			Npc = "Shafi",
			npc = "Shafi",
			CFrame = CFrame.new(-16548.800, 12.000, 412.300),
			cframe = CFrame.new(-16548.800, 12.000, 412.300),
			CFrames = {
				Sea_3 = CFrame.new(-16548.800, 12.000, 412.300),
			},
			cframes = {
				Sea_3 = CFrame.new(-16548.800, 12.000, 412.300),
			},
			Remote = { { "BuySanguineArt", true }, { "BuySanguineArt" } },
			remote = { { "BuySanguineArt", true }, { "BuySanguineArt" } },
			Sea = 3
		},
	},
	ItemsToBuy = {
		["Frags"] = {
			["Race Rerol"] = { "BlackbeardReward", "Reroll", "2" },
			["Reset Stats"] = { "BlackbeardReward", "Refund", "2" }
		},
		["Ability"] = {
			["Geppo"] = { "BuyHaki", "Geppo" },
			["Buso Haki"] = { "BuyHaki", "Buso" },
			["Soru"] = { "BuyHaki", "Soru" },
			["Observation Haki"] = { "KenTalk", "Buy" }
		},
		["Gun"] = {
			["Slingshot"] = { "BuyItem", "Slingshot" },
			["Musket"] = { "BuyItem", "Musket" },
			["Flintlock"] = { "BuyItem", "Flintlock" },
			["Refined Slingshot"] = { "BuyItem", "Refined Flintlock" },
			["Refined Flintlock"] = { "BuyItem", "Refined Flintlock" },
			["Cannon"] = { "BuyItem", "Cannon" },
			["Kabucha"] = { "BlackbeardReward", "Slingshot", "1" },
			["Bizarre Rifle"] = { "Ectoplasm", "Buy", 1 }
		},
		["Accessory"] = {
			["Black Cape"] = { "Black Cape" },
			["Swordsman Hat"] = { "Swordsman Hat" },
			["Tomoe Ring"] = { "Tomoe Ring" }
		},
		["Sword"] = {
			["Cutlass"] = { "Cutlass" },
			["Katana"] = { "Katana" },
			["Iron Mace"] = { "Iron Mace" },
			["Dual Katana"] = { "Duel Katana" },
			["Triple Katana"] = { "Triple Katana" },
			["Pipe"] = { "Pipe" },
			["Dual-Headed Blade"] = { "Dual-Headed Blade" },
			["Bisento"] = { "Bisento" },
			["Soul Cane"] = { "Soul Cane" },
			["Pole v.2"] = { "ThunderGodTalk" }
		}
	},
	Islands = {
		["Sea 1"] = {
			["Pirate Starter"] = CFrame.new(1047, 15, 1506),
			["Marine Starter"] = CFrame.new(-2728, 25, 2056),
			["Middle Town"] = CFrame.new(-688, 15, 1585),
			["Jungle"] = CFrame.new(-1614, 37, 146),
			["Pirate Village"] = CFrame.new(-1173, 45, 3837),
			["Desert"] = CFrame.new(944, 21, 4373),
			["Frozen Village"] = CFrame.new(1298, 87, -1344),
			["Marine Fortress"] = CFrame.new(-4810, 21, 4359),
			["Colosseum"] = CFrame.new(-1535, 7, -3014),
			["Lower Skylands"] = CFrame.new(-4814, 718, -2551),
			["Skylands"] = CFrame.new(-4652, 873, -1754),
			["Upper Skylands"] = CFrame.new(-7895, 5547, -380),
			["Prison"] = CFrame.new(4870, 6, 736),
			["Magma Village"] = CFrame.new(-5290, 9, 8349),
			["Underwater City"] = CFrame.new(61164, 5, 1820),
			["Fountain City"] = CFrame.new(5757, 91, 4017),
			["Jean-Luc Island"] = CFrame.new(-2850, 7, 5355),
		},
		["Sea 2"] = {
			["The Cafe"] = CFrame.new(-382, 73, 290),
			["First Spot"] = CFrame.new(-11, 29, 2771),
			["Dark Arena"] = CFrame.new(3494, 13, -3259),
			["Don Swan Mansion"] = CFrame.new(-317, 331, 597),
			["Don Swan Room"] = CFrame.new(2285, 15, 905),
			["Green Zone"] = CFrame.new(-2258, 73, -2696),
			["Graveyard"] = CFrame.new(-5552, 194, -776),
			["Snow Mountain"] = CFrame.new(752, 408, -5277),
			["Hot and Cold"] = CFrame.new(-6008, 29, -5018),
			["Cursed Ship"] = CFrame.new(919, 125, 32869),
			["Ice Castle"] = CFrame.new(5505, 40, -6178),
			["Forgotten Island"] = CFrame.new(-3050, 240, -10178),
			["Remote Island"] = CFrame.new(4816, 8, 2863),
		},
		["Sea 3"] = {
			["Mansion"] = CFrame.new(-12471, 374, -7551),
			["Port Town"] = CFrame.new(-340, 21, 5524),
			["Great Tree"] = CFrame.new(2205, 22, -6766),
			["Castle On The Sea"] = CFrame.new(-4980, 314, -3018),
			["Hydra Island"] = CFrame.new(5294, 1005, 391),
			["Floating Turtle"] = CFrame.new(-12528, 332, -8658),
			["Haunted Castle"] = CFrame.new(-9517, 142, 5528),
			["Ice Cream Land"] = CFrame.new(-843, 66, -10944),
			["Peanut Land"] = CFrame.new(-2082, 38, -10190),
			["Cake Land"] = CFrame.new(-1897, 14, -11576),
			["Candy Cane Land"] = CFrame.new(-1094, 64, -14519),
			["Chocolate Land"] = CFrame.new(219, 127, -12604),
			["Tiki Outpost"] = CFrame.new(-16224, 9, 439),
		}
	},
	PortalLocations = {
		Sea_1 = {
			Vector3.new(-7894.62, 5545.49, -380.25),
			Vector3.new(-4607.82, 872.54, -1667.56),
			Vector3.new(61163.85, 11.76, 1819.78),
			Vector3.new(3876.28, 35.11, -1939.32)
		},
		Sea_2 = {
			Vector3.new(-288.46, 306.13, 598),
			Vector3.new(2284.91, 15.15, 905.48),
			Vector3.new(923.21, 126.98, 32852.83),
			Vector3.new(-6508.56, 89.03, -132.84)
		},
		Sea_3 = {
			Vector3.new(-5058.77, 314.52, -3155.88),
			Vector3.new(-12463.87, 374.91, -7523.77),
			Vector3.new(28282.57, 14896.85, 105.1),
			Vector3.new(5661.53, 1013.09, -334.96),
			Vector3.new(5319, 23, -93),
			Vector3.new(5651, 1018, -350),
			Vector3.new(28286, 14897, 103)
		}
	},
	SwordData = {
		["Dark Blade"] = { Rarity = "Mythical", Order = 1 },
		["True Triple Katana"] = { Rarity = "Mythical", Order = 1 },
		["Cursed Dual Katana"] = { Rarity = "Mythical", Order = 1 },
		["Hallow Scythe"] = { Rarity = "Mythical", Order = 1 },
		["Triple Dark Blade"] = { Rarity = "Mythical", Order = 1 },
		["Dog Blade"] = { Rarity = "Mythical", Order = 1 },

		["Rengoku"] = { Rarity = "Legendary", Order = 2 },
		["Yama"] = { Rarity = "Legendary", Order = 2 },
		["Tushita"] = { Rarity = "Legendary", Order = 2 },
		["Buddy Sword"] = { Rarity = "Legendary", Order = 2 },
		["Shark Anchor"] = { Rarity = "Legendary", Order = 2 },
		["Fox Lamp"] = { Rarity = "Legendary", Order = 2 },
		["Dragon Trident"] = { Rarity = "Legendary", Order = 2 },
		["Saber"] = { Rarity = "Legendary", Order = 2 },
		["Canvander"] = { Rarity = "Legendary", Order = 2 },
		["Dark Dagger"] = { Rarity = "Legendary", Order = 2 },
		["Dragonheart"] = { Rarity = "Legendary", Order = 2 },
		["Koko"] = { Rarity = "Legendary", Order = 2 },
		["Midnight Blade"] = { Rarity = "Legendary", Order = 2 },
		["Oroshi"] = { Rarity = "Legendary", Order = 2 },
		["Pole (1st Form)"] = { Rarity = "Legendary", Order = 2 },
		["Pole (2nd Form)"] = { Rarity = "Legendary", Order = 2 },
		["Saishi"] = { Rarity = "Legendary", Order = 2 },
		["Shizu"] = { Rarity = "Legendary", Order = 2 },
		["Longsword"] = { Rarity = "Legendary", Order = 2 },
		["Pipe"] = { Rarity = "Legendary", Order = 2 },
		["Soul Cane"] = { Rarity = "Legendary", Order = 2 },
		["Trident"] = { Rarity = "Legendary", Order = 2 },
		["Wardens Sword"] = { Rarity = "Legendary", Order = 2 },
		["Bisento"] = { Rarity = "Legendary", Order = 2 },
		["Triple Katana"] = { Rarity = "Legendary", Order = 2 },
		["Twin Hooks"] = { Rarity = "Legendary", Order = 2 },
		["Dual-Headed Blade"] = { Rarity = "Legendary", Order = 2 },
		["Flail"] = { Rarity = "Legendary", Order = 2 },
		["Gravity Blade"] = { Rarity = "Legendary", Order = 2 },

		["Spikey Trident"] = { Rarity = "Rare", Order = 3 },
		["Fishing Trophy"] = { Rarity = "Rare", Order = 3 },
		["Shark Saw"] = { Rarity = "Rare", Order = 3 },

		["Iron Mace"] = { Rarity = "Uncommon", Order = 4 },

		["Cutlass"] = { Rarity = "Common", Order = 5 },
		["Katana"] = { Rarity = "Common", Order = 5 },
		["Dual Katana"] = { Rarity = "Common", Order = 5 },
	},
	BoatsList = {
		'Dinghy',
		'PirateSloop',
		'PirateBrigade',
		'PirateGrandBrigade',
		'MarineSloop',
		'MarineBrigade',
		'MarineGrandBrigade',
		'Beast Hunter',
		'Lantern',
		'Guardian',
		'Grand Brigade',
		'Sloop',
		'The Sentinel'
	},
	ZoneList = {
		'Level 1',
		'Level 2',
		'Level 3',
		'Level 4',
		'Level 5',
		'Level 6',
		'Infinite'
	},
	SeaEventTargets = {
		"Terror Shark",
		"Sea Beast",
		"Shark",
		"Piranha",
		"Fish Crew Member",
		"Pirate Brigade",
		"Pirate Grand Brigade",
		"Ghost Ship"
	},
	RodsList = {
		"Fishing Rod",
		"Gold Rod",
		"Shark Rod",
		"Shell Rod",
		"Treasure Rod",
		"Shark (Corrupted)",
		"Shell (Celestial)"
	},
	BaitsList = {
		"Basic Bait",
		"Kelp Bait",
		"Good Bait",
		"Abyssal Bait",
		"Frozen Bait",
		"Epic Bait",
		"Carnivore Bait"
	},
	DungeonCards = {
		"Hyper",
		"Overflow",
		"Fortress",
		"Shadow",
		"Sniper",
		"Lifesteal",
		"Unbreakable",
		"Health",
		"Defense",
		"Armor",
		"Melee",
		"Sword",
		"Fruit",
		"Gun"
	},
	TrainMethods = {
		"Bones",
		"Cakes"
	},
	LegendarySwordNames = {
		"Shizu",
		"Oroshi",
		"Saishi"
	},
	BossHopNames = {
		"Greybeard",
		"Darkbeard",
		"Cursed Captain",
		"rip_indra True Form",
		"Soul Reaper",
		"Cake Prince",
		"Dough King",
		"Tyrant of the Skies"
	},
	BossMap = {
		["Greybeard"] = "Greybeard",
		["Darkbeard"] = "Darkbeard",
		["Cursed Captain"] = "CursedCaptain",
		["rip_indra True Form"] = "Ripindra",
		["Soul Reaper"] = "SoulReaper",
		["Cake Prince"] = "CakePrince",
		["Dough King"] = "DoughKing",
		["Tyrant of the Skies"] = "Tyrant"
	},
	ScrollList = {
		"Common Scroll",
		"Rare Scroll",
		"Legendary Scroll",
		"Mythical Scroll"
	},
	ChestTiers = {
		"Diamond",
		"Gold",
		"Silver"
	},
	IgnoreNPC = {
		"Quest",
		"Boat",
		"Home"
	},
	DracoSequence = {
		"Relic1",
		"EndRelic1",
		"Relic2",
		"EndRelic2",
		"Relic3",
		"EndRelic3"
	},
	SwordList = {
		"Shizu",
		"Saishi",
		"Oroshi"
	},
	DealerFruitList = {
		"Rocket-Rocket",
		"Spin-Spin",
		"Blade-Blade",
		"Spring-Spring",
		"Bomb-Bomb",
		"Smoke-Smoke",
		"Spike-Spike",
		"Flame-Flame",
		"Ice-Ice",
		"Sand-Sand",
		"Dark-Dark",
		"Eagle-Eagle",
		"Diamond-Diamond",
		"Light-Light",
		"Rubber-Rubber",
		"Ghost-Ghost",
		"Magma-Magma",
		"Quake-Quake",
		"Buddha-Buddha",
		"Love-Love",
		"Creation-Creation",
		"Spider-Spider",
		"Sound-Sound",
		"Phoenix-Phoenix",
		"Portal-Portal",
		"Lightning-Lightning",
		"Pain-Pain",
		"Blizzard-Blizzard",
		"Gravity-Gravity",
		"Mammoth-Mammoth",
		"T-Rex-T-Rex",
		"Dough-Dough",
		"Shadow-Shadow",
		"Venom-Venom",
		"Gas-Gas",
		"Spirit-Spirit",
		"Tiger-Tiger",
		"Yeti-Yeti",
		"Kitsune-Kitsune",
		"Control-Control",
		"Dragon-Dragon"
	}
}

    end)()
    STATE.ReferenceData=reference
    STATE.ReferenceFruitIcons={
        ["15100283484"]="Light Fruit",
        ["15116730102"]="Love Fruit",
        ["15100273645"]="Dough Fruit",
        ["15116967784"]="Spider Fruit",
        ["15112263502"]="Shadow Fruit",
        ["15104782377"]="Blade Fruit",
        ["15060012861"]="Rocket Fruit",
        ["15106768588"]="Leopard Fruit",
        ["15112469964"]="Falcon Fruit",
        ["15708895165"]="T-Rex Fruit",
        ["19001642259"]="Dragon (East) Fruit",
        ["86024571204851"]="Gas Fruit",
        ["15100246632"]="Phoenix Fruit",
        ["14661873358"]="Sound Fruit",
        ["15111584216"]="Flame Fruit",
        ["15105281957"]="Spring Fruit",
        ["15116740364"]="Bomb Fruit",
        ["15104817760"]="Rubber Fruit",
        ["15057683975"]="Spin Fruit",
        ["15105350415"]="Magma Fruit",
        ["15482881956"]="Kitsune Fruit",
        ["15100485671"]="Barrier Fruit",
        ["18955022385"]="Dragon (West) Fruit",
        ["101378450824208"]="Yeti Fruit",
        ["15116721173"]="Pain Fruit",
        ["10395893751"]="Venom Fruit",
        ["11908375285"]="Spirit Fruit",
        ["15100433167"]="Ice Fruit",
        ["15100299740"]="Gravity Fruit",
        ["15107005807"]="Spike Fruit",
        ["15116696973"]="Smoke Fruit",
        ["15112600534"]="Diamond Fruit",
        ["15112333093"]="Ghost Fruit",
        ["15057718441"]="Quake Fruit",
        ["15111517529"]="Sand Fruit",
        ["15100313696"]="Buddha Fruit",
        ["15116747420"]="Rumble Fruit",
        ["15100384816"]="Blizzard Fruit",
        ["15111553409"]="Dark Fruit",
        ["14661837634"]="Mammoth Fruit",
        ["15100184583"]="Control Fruit",
    }
    STATE.ResolveFruitIcon=function(image)
        local id=tostring(image or ""):match("id=(%d+)") or tostring(image or ""):match("(%d+)")
        if not id then return nil end
        return STATE.ReferenceFruitIcons[id]
    end
    local mirror={Last="Not checked",Conflicts=0,LastMob="None",LastQuest="None",Resolved=0}
    STATE.QuestMirror=mirror
    function mirror.Route(lvl,sea)
        local rows=reference.QUESTS and reference.QUESTS["Sea_"..tostring(sea)]
        if type(rows)~="table" then return nil end
        local chosen=nil
        for _,row in ipairs(rows) do
            if type(row)=="table" and type(row[1])=="number" and type(row[2])=="number"
                and lvl>=row[1] and lvl<=row[2] then
                chosen=row
                break
            end
        end
        if not chosen or chosen[4]=="Team-dependent" then return nil end
        mirror.Resolved=mirror.Resolved+1
        mirror.LastMob=tostring(chosen[3]);mirror.LastQuest=tostring(chosen[4])
        return {chosen[1],chosen[2],chosen[3],chosen[4],chosen[5]}
    end
    function mirror.Compare(lvl,sea)
        local compiled=questRoute(lvl,sea)
        local fromFile=mirror.Route(lvl,sea)
        if not fromFile then mirror.Last="Source route missing";return compiled,nil end
        if compiled and (norm(compiled[3])~=norm(fromFile[3]) or
            norm(compiled[4])~=norm(fromFile[4]) or compiled[5]~=fromFile[5]) then
            mirror.Conflicts=mirror.Conflicts+1
            mirror.Last=string.format("Mismatch at %d: old=%s/%s new=%s/%s",
                lvl,tostring(compiled[3]),tostring(compiled[4]),tostring(fromFile[3]),tostring(fromFile[4]))
        else mirror.Last="Source route matches or fills a missing entry" end
        return compiled,fromFile
    end
    function mirror.Bosses(sea)
        return reference.BossList and reference.BossList["Sea_"..tostring(sea)] or {}
    end
    function mirror.Summary()
        local qCounts={}
        for sea=1,3 do qCounts[sea]=#(reference.QUESTS["Sea_"..sea] or {}) end
        return {quests_per_sea=qCounts,fruit_icons=41,
            last_status=mirror.Last,conflicts=mirror.Conflicts,reference="user data.lua.txt"}
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
function STATE.Halloween2026.FindBoss(selection,maxDistance)
    local _,_,root,ready=alive()
    if not ready or not root then return nil,nil end
    local radius=math.clamp(tonumber(maxDistance) or 1600,200,4000)
    return enemySearch(function(model)
        if not STATE.Halloween2026.MatchBoss(model.Name,selection) then return false end
        local part=model:FindFirstChild("HumanoidRootPart")
        return part and (part.Position-root.Position).Magnitude<=radius or false
    end,false,true)
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
    local scanned=(STATE.RouteDirector and STATE.RouteDirector.Choose(name,root and root.Position))
        or (STATE.AtlasSpawnCFrame and STATE.AtlasSpawnCFrame(name,root and root.Position))
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

-- Live quest resolver adapted from the repository's Auto-Fram-Level-BF source.
-- The static route remains the fallback because some game builds stream modules late.
function STATE.LiveQuestInfo()
    if not Config.PreferLiveQuestModule or type(Quests)~="table" then return nil end
    local currentLevel=level()
    local team=LP.Team and LP.Team.Name or "Pirates"
    local lowFilter=currentLevel<10 and (team=="Marines" and "trainee" or "bandit") or nil
    local excluded={BartiloQuest=true,CitizenQuest=true,ImpelQuest=true}
    local chosenQuest,chosenEntry,chosenIndex=nil,nil,nil
    local bestRequirement=-1
    for questName,entries in pairs(Quests) do
        if type(questName)=="string" and not excluded[questName] and type(entries)=="table" then
            for index,entry in ipairs(entries) do
                local requirement=type(entry)=="table" and tonumber(entry.LevelReq)
                local matches=requirement and requirement<=currentLevel
                if matches and lowFilter then
                    matches=false
                    for mobName in pairs(entry.Task or {}) do
                        if norm(mobName):find(lowFilter,1,true) then matches=true;break end
                    end
                end
                if matches and requirement>=bestRequirement then
                    chosenQuest=questName;chosenEntry=entry;chosenIndex=index
                    bestRequirement=requirement
                end
            end
        end
    end
    if not (chosenQuest and chosenEntry and chosenIndex) then return nil end
    local mobName
    for name in pairs(chosenEntry.Task or {}) do mobName=tostring(name);break end
    if not mobName then return nil end

    local position=nil
    local npcList=Guide and Guide.Data and Guide.Data.NPCList
    if type(npcList)=="table" then
        for npcInstance,npc in pairs(npcList) do
            if type(npc)=="table" then
                local matched=npc.InternalQuestName==chosenQuest
                if not matched and type(npc.Levels)=="table" then
                    for _,allowed in pairs(npc.Levels) do
                        if tonumber(allowed)==bestRequirement then matched=true;break end
                    end
                end
                if matched then
                    local candidate=npc.CFrame or npc.Position
                    if not candidate and typeof(npcInstance)=="Instance" then
                        if npcInstance:IsA("BasePart") then candidate=npcInstance.CFrame
                        elseif npcInstance:IsA("Model") then candidate=npcInstance:GetPivot() end
                    end
                    if typeof(candidate)=="Vector3" then candidate=CFrame.new(candidate) end
                    if typeof(candidate)=="CFrame" then position=candidate;break end
                end
            end
        end
    end
    if not position then position=STATE.QuestNPCPos(chosenQuest) end
    if not position then return nil end
    return {Mob=mobName,Name=chosenQuest,Id=chosenIndex,Pos=position,
        LevelReq=bestRequirement,Source="Live Quests"}
end

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
    local live=STATE.LiveQuestInfo()
    if live then return live end
    local route=nil
    local usedReference=false
    if Config.PreferReferenceQuests then
        route=STATE.QuestMirror.Route(level(),STATE.World)
        usedReference=(route~=nil)
    end
    route=route or questRoute(level(),STATE.World)
    if not route then return nil end
    -- Stable level route from Kaitun, with game NPC data for current position.
    local info={Mob=route[3],Name=route[4],Id=route[5],Pos=STATE.QuestNPCPos(route[4]),Source=usedReference and "User data.lua" or "Kaitun route"}
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
-- Kaitun's quest reader is kept as a local, read-only fallback.  Different
-- clients place the title in TrackedQuestFrame.Description.Header or inside
-- Main.Container.QuestTitle, so only the visible label is trusted.
STATE.GetCurrentClaimQuest=function()
    local pg=LP:FindFirstChild("PlayerGui")
    if not pg then return nil,nil end
    local raw=nil
    local tracked=pg:FindFirstChild("TrackedQuestFrame")
    local trackedVisible=tracked and ((tracked:IsA("ScreenGui") and tracked.Enabled) or
        (tracked:IsA("GuiObject") and tracked.Visible))
    if trackedVisible then
        local desc=tracked:FindFirstChild("Description")
        local header=(desc and (desc:FindFirstChild("Header") or desc:FindFirstChild("header")))
            or tracked:FindFirstChild("Header",true) or tracked:FindFirstChild("header",true)
        local label=header and (header:IsA("TextLabel") and header or header:FindFirstChildWhichIsA("TextLabel",true))
        if label and tostring(label.Text)~="" then raw=tostring(label.Text) end
    end
    if not raw then
        local main=pg:FindFirstChild("Main") or pg:FindFirstChild("Main (minimal)")
        local panel=main and main:FindFirstChild("Quest")
        local panelVisible=panel and panel:IsA("GuiObject") and panel.Visible
        if panelVisible then
            local container=panel:FindFirstChild("Container")
            local title=(container and container:FindFirstChild("QuestTitle")) or panel:FindFirstChild("QuestTitle",true)
            local label=title and (title:FindFirstChild("Title") or (title:IsA("TextLabel") and title))
            if label and tostring(label.Text)~="" then raw=tostring(label.Text) end
        end
    end
    if not raw or raw=="" then return nil,nil end
    local mob=raw:gsub("^Defeat%s+%d+%s+"," "):gsub("^Defeat%s+the%s+"," "):gsub("^Defeat%s+"," ")
        :gsub("%s*%b()%s*$",""):gsub("^%s+",""):gsub("%s+$","")
    return (mob~="" and mob or nil),raw
end
STATE.ReadQuestGUI=function()
    local mob,raw=STATE.GetCurrentClaimQuest()
    if mob then return true,mob,raw end
    local pg=LP:FindFirstChild("PlayerGui")
    local main=pg and (pg:FindFirstChild("Main") or pg:FindFirstChild("Main (minimal)"))
    local panel=main and main:FindFirstChild("Quest")
    if panel and panel:IsA("GuiObject") and panel.Visible then return true,nil,raw end
    return false,nil,raw
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
    local active,mob,textValue=STATE.ReadQuestGUI()
    if active then return true,nil,mob or textValue,"gui" end
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
STATE.TeleportRecovery={Pending=false,Retries=0,Token=0,LastTarget=nil,LastReason="None",Status="Ready"}
function STATE.QueueMoveRecovery(goal,caller,reason)
    local recovery=STATE.TeleportRecovery
    if not Config.TeleportEnabled or not Config.TeleportAutoRecover then return false end
    if typeof(goal)~="CFrame" or recovery.Pending then return recovery.Pending end
    if recovery.LastTarget and typeof(recovery.LastTarget)=="CFrame" and
        (recovery.LastTarget.Position-goal.Position).Magnitude>45 then
        recovery.Retries=0
    end
    local limit=math.clamp(tonumber(Config.TeleportRetryLimit) or 3,1,6)
    if recovery.Retries>=limit then
        recovery.Status="Đã dừng sau "..tostring(limit).." lần thử lại"
        recovery.LastReason=tostring(reason or "Movement stalled")
        return false
    end
    recovery.Retries=recovery.Retries+1
    recovery.Token=(recovery.Token or 0)+1
    local token=recovery.Token
    recovery.Pending=true;recovery.LastTarget=goal;recovery.Caller=caller;recovery.LastReason=tostring(reason or "Movement stalled")
    recovery.Status=string.format("Tự thử lại %d/%d · %s",recovery.Retries,limit,recovery.LastReason)
    local now=os.clock()
    local waitFor=.45
    if STATE.MoveGuard and STATE.MoveGuard.PauseUntil then
        waitFor=math.max(waitFor,(STATE.MoveGuard.PauseUntil-now)+.15)
    end
    task.delay(waitFor,function()
        if not STATE.Alive or not Config.TeleportEnabled or token~=recovery.Token
            or (caller=="Secret Quest Mobile" and not Config.AutoSecretQuestRoute)
            or (caller=="Full auto raid v38" and not Config.AutoRaid) then
            recovery.Pending=false
            return
        end
        recovery.Pending=false
        local thread=coroutine.running()
        if thread then STATE.MoveThreadOwners[thread]=caller or "Manual" end
        local ok=moveTo(goal,{Recovery=true,Caller=caller or "Manual"})
        if thread then STATE.MoveThreadOwners[thread]=nil end
        if ok then recovery.Status="Đang di chuyển lại" end
    end)
    return true
end
local function cancelMove(recoveryReason)
    local m=STATE.Mover
    local retryGoal=m and m.Active and m.Goal or nil
    local retryCaller=m and m.Active and m.Caller or "Manual"
    if m then
        m.Active=false;m.Generation=(m.Generation or 0)+1
        if m.CompletedConnection then pcall(function() m.CompletedConnection:Disconnect() end) end
        m.CompletedConnection=nil
        if m.Tween then pcall(function() m.Tween:Cancel() end) end
        m.Tween=nil;m.Goal=nil;m.Started=0
    end
    STATE.Tween=nil;STATE.TweenGoal=nil;STATE.TweenAt=nil
    if STATE.StopFlight then STATE.StopFlight() end
    STATE.MoveStats.Status="Idle"
    STATE.MovementLock=nil
    if recoveryReason and retryGoal then
        STATE.QueueMoveRecovery(retryGoal,retryCaller,recoveryReason)
    end
end

-- Automatic Sea progression based on the same level gates used by the repository.
-- It is opt-in and leaves FarmEnabled running until the game changes place.
STATE.WorldProgression={Status="Tắt",Busy=false,LastAttempt=-math.huge,
    Attempts=0,TargetSea=nil,LastError="Không"}
STATE.WorldProgressionRules={
    [1]={Level=700,Sea=2,Remote="TravelDressrosa",Place=4442272183},
    [2]={Level=1500,Sea=3,Remote="TravelZou",Place=7449423635},
}
function STATE.WorldProgressionTick()
    local progress=STATE.WorldProgression
    if not Config.AutoWorldProgression or not Config.FarmEnabled then
        progress.Status="Tắt";progress.Busy=false;return false
    end
    if Config.FarmMode~="Level" then
        progress.Status="Chờ Level Farm";progress.Busy=false;return false
    end
    local rule=STATE.WorldProgressionRules[STATE.World]
    if not rule then progress.Status="Sea tối đa / không có tuyến";return false end
    local currentLevel=level()
    if currentLevel<rule.Level then
        progress.Status=string.format("Sea %d · cần Lv.%d",STATE.World,rule.Level)
        return false
    end
    if progress.Busy then return true end
    if os.clock()-progress.LastAttempt<45 then return false end
    progress.Busy=true;progress.LastAttempt=os.clock();progress.Attempts=progress.Attempts+1
    progress.TargetSea=rule.Sea;progress.Status="Đang yêu cầu Sea "..rule.Sea
    cancelMove()
    local ok,result=remote(rule.Remote)
    if not ok or result==false then
        progress.Busy=false;progress.LastError=tostring(result)
        progress.Status="Lỗi chuyển Sea: "..tostring(result):sub(1,70)
        return false
    end
    progress.LastError="Không"
    progress.Status="Đã yêu cầu Sea "..rule.Sea.." · đang chuyển server"
    task.spawn(function()
        task.wait(3)
        if not STATE.Alive or not Config.AutoWorldProgression then
            progress.Busy=false;return
        end
        local teleported=pcall(function() TP:Teleport(rule.Place,LP) end)
        if not teleported then
            progress.Busy=false
            progress.Status="Remote đã nhận nhưng Teleport thất bại"
        end
    end)
    return true
end
STATE.GetWorldProgression=function() return STATE.WorldProgression end
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
-- V31 Flight Tween: a client-side lift force for the duration of travel.
-- Unlike FarmHover, it also protects manual travel / remote event moves from falling.
-- This does not bypass game-server position validation.
do
    local f={Root=nil,Force=nil,Starts=0,Stops=0}
    STATE.FlightControl=f
    STATE.StopFlight=function()
        if f.Force then pcall(function() f.Force:Destroy() end) end
        f.Root=nil;f.Force=nil;f.Stops=f.Stops+1
    end
    STATE.EnsureFlight=function(root)
        if not root or not root.Parent then return end
        if f.Root==root and f.Force and f.Force.Parent then return f.Force end
        STATE.StopFlight()
        local force=Instance.new("BodyVelocity")
        force.Name="andepzai_mobile_flight_lift"
        force.MaxForce=Vector3.new(0,1e8,0)
        force.P=16000
        force.Velocity=Vector3.zero
        force.Parent=root
        f.Root=root;f.Force=force;f.Starts=f.Starts+1
        return force
    end
    -- Keep gravity from winning while the proxy is moving.  Horizontal travel
    -- is still driven by the proxy heartbeat below; this force only stabilizes
    -- the vertical axis and is released as soon as the move ends.
    STATE.StabilizeFlight=function(root)
        local force=STATE.EnsureFlight(root)
        if not (force and Config.FlightStabilize) then return force end
        force.Velocity=Vector3.zero
        pcall(function()
            local v=root.AssemblyLinearVelocity
            if math.abs(v.Y)>0.5 then
                root.AssemblyLinearVelocity=Vector3.new(v.X,0,v.Z)
            end
            root.AssemblyAngularVelocity=Vector3.zero
        end)
        return force
    end
end

-- // v27 Movement consistency guard: stop repeated rubberband attempts.
--     The client cannot turn off server validation; this only reduces retries.
do
    local G={Corrections=0,Consecutive=0,SpeedCap=350,PauseUntil=0,LastCorrection=0,
        LastHealthy=os.clock(),Status="Monitoring",History={},LastGap=0}
    STATE.MoveGuard=G
    function G.Report(gap)
        local now=os.clock()
        if now-G.LastCorrection<0.65 then return end
        if now-G.LastCorrection>24 then G.Consecutive=0 end
        G.LastCorrection=now;G.Corrections=G.Corrections+1;G.Consecutive=G.Consecutive+1
        G.LastGap=gap
        local allowed=math.clamp(tonumber(Config.TweenSpeed) or 350,40,400)
        G.SpeedCap=math.max(65,math.floor(math.min(G.SpeedCap,allowed)*0.70))
        local seconds=math.min(tonumber(Config.MoveMaxBackoff) or 25,
            G.Consecutive>=5 and 25 or (G.Consecutive>=3 and 9 or 2.8))
        G.PauseUntil=now+seconds
        G.Status=string.format("Possible snapback %.0f studs; paused %.1fs; cap %d",gap,seconds,G.SpeedCap)
        STATE.MoveStats.Corrections=STATE.MoveStats.Corrections+1
        STATE.MoveStats.LastError=G.Status
        STATE.MoveStats.RecoveryUntil=G.PauseUntil
        table.insert(G.History,1,{At=now,Gap=math.floor(gap),SpeedCap=G.SpeedCap})
        if #G.History>30 then table.remove(G.History) end
        cancelMove("server correction")
    end
    function G.Refresh(now)
        now=now or os.clock()
        local requested=math.clamp(tonumber(Config.TweenSpeed) or 350,40,400)
        if now-G.LastCorrection>30 and now-(G.LastRaise or 0)>8 then
            G.LastRaise=now
            G.SpeedCap=math.min(requested,G.SpeedCap+20)
            if G.SpeedCap>=requested then G.Status="No recent correction" end
        end
        return math.min(requested,G.SpeedCap)
    end
end

-- A server correction should not leave the mobile player frozen in mid-air.
-- Rebuild the same proxy tween from the observed root and continue toward the
-- original goal.  This is a soft resync, not an anti-cheat bypass guarantee.
STATE.ResyncFlight=function(m,reason)
    if not (m and m.Active and m.Mode=="Flight Tween" and Config.FlightContinuous
        and Config.FlightSoftRecovery and m.Goal) then return false end
    local now=os.clock()
    if m.Resyncing or now-(STATE.FlightResyncAt or 0)<.20 then return true end
    m.Resyncing=true;STATE.FlightResyncAt=now
    local goal=m.Goal;local caller=m.Caller or "Manual";local final=m.FinalDestination
    local holdAtEnd=m.HoldAtEnd
    STATE.MoveStats.LastError="Flight resync: "..tostring(reason or "server correction")
    STATE.MoveStats.RecoveryUntil=0
    if STATE.MoveGuard then
        STATE.MoveGuard.PauseUntil=0
        STATE.MoveGuard.Status="Flight resync · tiếp tục bay"
    end
    cancelMove()
    task.defer(function()
        if not STATE.Alive or (caller=="Secret Quest Mobile" and not Config.AutoSecretQuestRoute)
            or (caller=="Full auto raid v38" and not Config.AutoRaid) then return end
        local ok=moveTo(goal,{Recovery=true,Caller=caller,HoldAtEnd=holdAtEnd})
        if ok and final and STATE.Mover and STATE.Mover.Active then
            STATE.Mover.FinalDestination=final
        end
        if STATE.Mover then STATE.Mover.Resyncing=nil end
        STATE.FlightResyncAt=os.clock()
    end)
    return true
end

-- Only one Heartbeat subscription. The proxy follows a tween; character tracks it.
on(Run,Run.Heartbeat,function(dt)
    if STATE.VerifyTeleportDestination then STATE.VerifyTeleportDestination(os.clock()) end
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
    if m.Mode=="Proxy Tween" or m.Mode=="Flight Tween" then
        if m.Mode=="Flight Tween" then STATE.StabilizeFlight(root) end
        if not m.Proxy or not m.Proxy.Parent then cancelMove();return end
        local nowProbe=os.clock()
        -- Compare the last position this client wrote with the replicated position now.
        -- Large unexpected divergence suggests correction/other movement; not proof of anti-cheat.
        if Config.MoveAutoBackoff and m.LastIssuedPos and
            nowProbe-(m.LastIssuedAt or 0)<0.25 and m.Goal then
            local disagreement=(root.Position-m.LastIssuedPos).Magnitude
            if disagreement>=math.max(8,tonumber(Config.MoveCorrectionThreshold) or 13) and
                (root.Position-m.Goal.Position).Magnitude>12 then
                if STATE.ResyncFlight(m,"server correction") then return end
                STATE.MoveGuard.Report(disagreement)
                return
            end
        end
        local targetCF=m.Proxy.CFrame
        local offset=targetCF.Position-root.Position
        local gap=offset.Magnitude
        if gap>230 then
            -- Never keep forcing a huge client CFrame jump on a corrected position.
            -- Flight mode is rebuilt from the current root so it keeps moving
            -- instead of cancelling and waiting through a long backoff pause.
            if STATE.ResyncFlight(m,"large position mismatch") then return end
            STATE.MoveStats.LastError="Large position mismatch / possible server correction ("..math.floor(gap).." studs)"
            STATE.MoveStats.Corrections=STATE.MoveStats.Corrections+1
            STATE.MoveStats.Stalled=STATE.MoveStats.Stalled+1
            STATE.MoveStats.RecoveryUntil=os.clock()+0.65
            cancelMove("large position mismatch");return
        end
        -- Smooth high-speed following. Clamping frame delta avoids one huge
        -- teleport after an FPS hitch. This is NOT an anti-cheat bypass guarantee.
        local maxStep=math.max(1,(Config.MoveAutoBackoff and STATE.MoveGuard.Refresh() or math.clamp(tonumber(Config.TweenSpeed) or 350,40,400))
            * math.clamp(tonumber(dt) or (1/60),1/180,1/25) * 1.02)
        if m.Mode=="Flight Tween" and Config.FlightContinuous then
            -- TweenService advances the invisible proxy linearly.  Following
            -- that proxy directly removes the per-frame step quantisation that
            -- caused the visible pause/fall on mobile frame hitches.
            root.CFrame=targetCF
        elseif gap>maxStep and gap>0 then
            root.CFrame=CFrame.new(root.Position+offset.Unit*maxStep)*targetCF.Rotation
        else
            root.CFrame=targetCF
        end
        if m.Mode=="Flight Tween" then STATE.StabilizeFlight(root) end
        -- Do not force AssemblyLinearVelocity to zero every frame; it can fight physics.
        m.LastIssuedPos=root.Position;m.LastIssuedAt=nowProbe
    end
    local now=os.clock()
    if m.Goal and (root.Position-m.Goal.Position).Magnitude<=
        (m.Caller=="Secret Quest Mobile" and 1 or
        ((m.Caller=="Farm engine" and Config.FarmStyle=="Above") and 2.5 or (m.Caller=="Halloween doors" and 2.3 or 5))) then
        STATE.MoveStats.Reached=STATE.MoveStats.Reached+1
        local destination=m.FinalDestination
        local owner=m.Caller
        local holdQuest=m.HoldAtEnd and owner=="Secret Quest Mobile" and Config.AutoSecretQuestRoute
        cancelMove()
        if holdQuest and not destination and STATE.EnsureFlight and STATE.SecretQuestDirector then
            STATE.EnsureFlight(root)
            STATE.SecretQuestDirector.HoldingRoot=root
        end
        if destination then
            task.defer(function()
                if STATE.Alive and root.Parent then
                    local thread=coroutine.running()
                    if thread then STATE.MoveThreadOwners[thread]=owner end
                    moveTo(destination)
                    if thread then STATE.MoveThreadOwners[thread]=nil end
                end
            end)
        end
        return
    end
    -- A Tween's Completed means the proxy reached its goal, not necessarily
    -- that the player's root has caught up at low FPS or after a correction.
    if m.FinishedAt and now-m.FinishedAt>2.5 then
        STATE.MoveStats.Stalled=STATE.MoveStats.Stalled+1
        STATE.MoveStats.LastError="Proxy arrived but character could not reach target"
        STATE.MoveStats.RecoveryUntil=now+0.35
        cancelMove("proxy arrived but character lagged");return
    end
    if now-(m.LastCheck or now)>2.4 then
        local progress=(root.Position-(m.LastPosition or root.Position)).Magnitude
        if progress<1.7 and m.Goal and (root.Position-m.Goal.Position).Magnitude>15 then
            STATE.MoveStats.Stalled=STATE.MoveStats.Stalled+1
            STATE.MoveStats.LastError="Move stalled (possible map collision or server correction)"
            STATE.MoveStats.RecoveryUntil=now+0.35
            cancelMove("movement stalled");return
        end
        m.LastPosition=root.Position;m.LastCheck=now
    end
end)


--[[
  V32 REGION NAVIGATION
  Source cross-check: data.lua.txt (portals / island anchors), Topi Halloween
  (Tiki submarine access), user-supplied Sea Atlas (observed region centers).
  Observed region centers are NOT guaranteed walkable landing points.
  This controller avoids treating a negative-Y destination as open sea.
]]
do
    local N={Status="Ready",Region="Surface",Attempts=0,Success=0,
        Failures=0,LastTransit=-1e9,Pending=nil,Recent={},LastError=""}
    STATE.RegionNavigator=N
    local zones={
        [1]={
            {Name="Underwater City",Center=Vector3.new(61164,5,1820),Radius=6500,Type="underwater"},
            {Name="Upper Sky",Center=Vector3.new(-7895,5545,-380),Radius=4500,Type="high"},
        },
        [2]={
            {Name="Cursed Ship",Center=Vector3.new(919,125,32869),Radius=3800,Type="interior"},
        },
        [3]={
        {Name="Submerged Island",Center=STATE.SubmergedTravelData.Center,Radius=5200,Type="submerged"},
            {Name="Temple of Time",Center=Vector3.new(28283,14897,105),Radius=4000,Type="high"},
        },
    }
    function N.Classify(pos)
        if typeof(pos)~="Vector3" then return "surface",nil end
        for _,z in ipairs(zones[STATE.World] or {}) do
            local d=(pos-z.Center).Magnitude
            if d<z.Radius then return z.Type,z.Name end
        end
        if pos.Y < -300 then return "deep",nil end
        if pos.Y > 3000 then return "high",nil end
        return "surface",nil
    end
    function N.Plan(startPos,endPos)
        local src,srcName=N.Classify(startPos)
        local dst,dstName=N.Classify(endPos)
        local plan={Source=src,Destination=dst,SourceName=srcName,
            DestinationName=dstName,Kind="normal",Waypoints={},
            Target=endPos}
        -- Temple is not an ordinary requestEntrance portal. Race V4 must
        -- approach its own entry or fly to the live corridor, not loop on portalling.
        if Config.AutoRaceV4 and dstName=="Temple of Time" then
            plan.Kind="normal"
            return plan
        end
        if dst=="submerged" and src~="submerged" then
            plan.Kind="submarine"
            plan.Waypoints={(STATE.SubmergedTravelData.SubmarineEntrance or CFrame.new(-16269.4082,23.9799957,1371.66235)).Position}
        elseif src=="submerged" and dst~="submerged" then
            plan.Kind="submarine-exit"
        elseif dst=="underwater" and src~="underwater" then
            plan.Kind="entrance"
            plan.Entrance=Vector3.new(61163.85,11.76,1819.78)
        elseif dst=="interior" and src~="interior" then
            plan.Kind="entrance"
            plan.Entrance=Vector3.new(923.21,126.98,32852.83)
        elseif dst=="high" and src~="high" then
            plan.Kind="entrance"
            local best,dist=nil,math.huge
            for _,v in ipairs(PORTALS[STATE.World] or {}) do
                if v.Y>3000 and (v-endPos).Magnitude<dist then
                    best,dist=v,(v-endPos).Magnitude
                end
            end
            plan.Entrance=best
        elseif dst=="deep" or src=="deep" then
            plan.Kind="deep-local"
        end
        return plan
    end
    function N.IsLocalUnderwater(a,b)
        local at=N.Classify(a)
        local bt=N.Classify(b)
        return (at=="submerged" and bt=="submerged")
            or (at=="underwater" and bt=="underwater")
            or (at=="deep" and bt=="deep")
    end
    function N.BeginTransit(kind,target)
        local now=os.clock()
        if N.Pending or now-N.LastTransit<18 then return false end
        N.LastTransit=now
        N.Attempts=N.Attempts+1
        N.Pending={Kind=kind,Started=now,From=target.From,Target=target.To}
        N.Status="Transit requested: "..kind
        task.spawn(function()
            local sent=false
            if kind=="submarine" then
                local net=RS:FindFirstChild("Modules")
                net=net and net:FindFirstChild("Net")
                local rf=net and net:FindFirstChild("RF/SubmarineWorkerSpeak")
                if rf then
                    sent=pcall(function() rf:InvokeServer("TravelToSubmergedIsland") end)
                end
            elseif kind=="entrance" and target.Entrance then
                sent=pcall(function() remote("requestEntrance",target.Entrance) end)
            end
            local arrived=false
            if sent then
                local deadline=os.clock()+8
                repeat
                    task.wait(.3)
                    local _,_,root,ok=alive()
                    if ok and root then
                        if kind=="submarine" then
                            arrived=N.Classify(root.Position)=="submerged"
                        else
                            arrived=(root.Position-target.Entrance).Magnitude<350
                        end
                    end
                until arrived or os.clock()>deadline or not STATE.Alive
            end
            if arrived then
                N.Success=N.Success+1
                N.Status="Transit confirmed: "..kind
            else
                N.Failures=N.Failures+1
                N.LastError="Transit not confirmed; cooldown before retry"
                N.Status=N.LastError
            end
            N.Pending=nil
        end)
        return true
    end
    function N.BeforeMove(root,destination)
        local plan=N.Plan(root.Position,destination.Position)
        N.Region=plan.DestinationName or plan.Destination
        if plan.Kind=="submarine" then
            local dock=plan.Waypoints[1]
            if (root.Position-dock).Magnitude>18 then
                N.Status="Approach Tiki submarine dock"
                return CFrame.new(dock),false,"dock"
            end
            N.BeginTransit("submarine",{From=root.Position,To=destination.Position})
            return nil,true,"submarine"
        end
        if plan.Kind=="submarine-exit" then
            N.Status="Submerged exit requires a confirmed game transition"
            return nil,true,"submarine-exit"
        end
        if plan.Kind=="entrance" and plan.Entrance then
            if N.Pending then return nil,true,"pending" end
            if os.clock()-N.LastTransit>18 then
                N.BeginTransit("entrance",{From=root.Position,To=destination.Position,
                    Entrance=plan.Entrance})
            end
            return nil,true,"entrance"
        end
        if plan.Kind=="deep-local" then
            N.Status="Deep area: local-height travel"
        else
            N.Status="Route: "..(plan.DestinationName or plan.Destination)
        end
        return destination,false,plan.Kind
    end
end

--// V23 Reset Teleport (Topi/Bnn-inspired): optional spawn-assisted long travel.
--// Disabled until BOTH switches are on: may respawn and lose carried items.
do
    local T={Busy=false,Token=0,LastAttempt=-1e9,Attempts=0,Success=0,Rejected=0,
        Status="Off",Target=nil}
    STATE.ResetTeleport=T
    local function regionAt(pos)
        local origin=WS:FindFirstChild("_WorldOrigin")
        local folder=origin and origin:FindFirstChild("Locations")
        if not folder then return nil end
        local found,best=nil,math.huge
        for _,loc in ipairs(folder:GetChildren()) do
            if loc:IsA("BasePart") then
                local mesh=loc:FindFirstChildWhichIsA("SpecialMesh")
                local width=loc.Size.X*(mesh and mesh.Scale.X or 1)/2
                local delta=loc.Position-pos
                local dist=delta.Magnitude
                if dist<=math.max(width,75) and dist<best then found=loc.Name;best=dist end
            end
        end
        return found
    end
    local function valuableCarried()
        local backpack=LP:FindFirstChildOfClass("Backpack")
        for _,holder in ipairs({backpack,LP.Character}) do
            if holder then
                for _,tool in ipairs(holder:GetChildren()) do
                    if tool:IsA("Tool") and (tool.Name:lower():find("chalice",1,true)
                        or tool.Name:lower():find("fist of darkness",1,true)
                        or tool.Name:lower():find("hallow essence",1,true)) then
                        return tool.Name
                    end
                end
            end
        end
    end
    local function destinationSpawn(target,playerPos)
        local origin=WS:FindFirstChild("_WorldOrigin")
        local spawns=origin and origin:FindFirstChild("PlayerSpawns")
        if not spawns then return nil,nil end
        local currentDistance=(playerPos-target).Magnitude
        local best,bestValue=nil,math.huge
        for _,node in ipairs(spawns:GetDescendants()) do
            if node:IsA("Model") and node.Parent and node.Parent.Parent==spawns and node.Name~="" then
                local ok,cf=pcall(function() return node:GetPivot() end)
                if ok and cf and (cf.Position-target).Magnitude<bestValue then
                    local remaining=(cf.Position-target).Magnitude
                    local gain=currentDistance-remaining
                    if gain>=800 and (cf.Position-playerPos).Magnitude>=600 then
                        best,bestValue=node.Name,remaining
                    end
                end
            end
        end
        return best,bestValue
    end
    function T.ResetController()
        cancelMove()
        if STATE.Mover and STATE.Mover.Proxy then
            pcall(function() STATE.Mover.Proxy:Destroy() end)
        end
        STATE.Mover=nil
        STATE.MovementLock=nil
        STATE.MoveStats.Stalled=0
        STATE.MoveStats.RecoveryUntil=0
        STATE.MoveStats.LastError="None"
        T.Status="Movement proxy recreated on next travel"
        return true
    end
    function T.Cancel()
        T.Token=T.Token+1
        T.Busy=false
        T.Target=nil
        T.Status="Cancelled (does not reverse an already requested respawn)"
    end
    function T.Try(goal,playerRoot)
        if not Config.ResetTeleport then return false end
        if not Config.ResetTeleportAllowRespawn then
            T.Status="Enable 'Allow respawn' explicitly to use Reset Teleport"
            return false
        end
        if T.Busy then return true end
        if typeof(goal)~="CFrame" or not playerRoot then return false end
        if STATE.World==0 or Config.AutoSeaBoat or Config.AutoSea then return false end
        if (playerRoot.Position-goal.Position).Magnitude<1600 then return false end
        local sourceRegion=regionAt(playerRoot.Position)
        local destRegion=regionAt(goal.Position)
        if sourceRegion and destRegion and sourceRegion==destRegion then return false end
        local cooldown=math.clamp(tonumber(Config.ResetTeleportCooldown) or 100,60,300)
        if os.clock()-T.LastAttempt<cooldown then return false end
        local valuable=valuableCarried()
        if valuable then T.Status="Blocked: carrying "..valuable;return false end
        local spawnName=destinationSpawn(goal.Position,playerRoot.Position)
        if not spawnName then
            T.Status="No valid spawn destination streamed; normal tween"
            return false
        end
        local data=LP:FindFirstChild("Data")
        local lastSpawn=data and data:FindFirstChild("LastSpawnPoint")
        if not lastSpawn then T.Status="LastSpawnPoint not replicated; normal tween";return false end
        T.LastAttempt=os.clock();T.Attempts=T.Attempts+1
        T.Busy=true;T.Token=T.Token+1;T.Target=goal
        T.Status="Requesting spawn point: "..spawnName
        local token=T.Token
        cancelMove()
        task.spawn(function()
            local okCall,accepted=remote("SetLastSpawnPoint",spawnName)
            if not T.Busy or token~=T.Token or not STATE.Alive then return end
            if not okCall or accepted==false then
                T.Rejected=T.Rejected+1;T.Status="Spawn request rejected; normal tween next time"
                T.Busy=false;return
            end
            local verified=false
            for _=1,15 do
                if not T.Busy or token~=T.Token then return end
                if tostring(lastSpawn.Value)==spawnName then verified=true;break end
                task.wait(.12)
            end
            if not verified then
                T.Rejected=T.Rejected+1;T.Status="Spawn not confirmed; did NOT reset character"
                T.Busy=false;return
            end
            local oldChar=LP.Character
            local hum=oldChar and oldChar:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health<=0 then
                T.Busy=false;T.Status="Character unavailable";return
            end
            T.Status="Spawn verified; requesting respawn"
            local resetOk=pcall(function() hum.Health=0 end)
            if not resetOk then
                T.Rejected=T.Rejected+1;T.Status="Respawn request not available"
                T.Busy=false;return
            end
            local foundNew=false
            for _=1,100 do
                if not T.Busy or token~=T.Token or not STATE.Alive then return end
                local char=LP.Character
                local current=char and char:FindFirstChildOfClass("Humanoid")
                if char and char~=oldChar and current and current.Health>0 then
                    foundNew=true;break
                end
                task.wait(.1)
            end
            T.Busy=false
            if foundNew then
                T.Success=T.Success+1
                T.Status="Respawn completed; farm/tween will resume normally"
                T.ResetController()
                T.Status="Respawn completed at "..spawnName
            else
                T.Rejected=T.Rejected+1
                T.Status="Respawn not observed; server may have rejected reset"
            end
        end)
        return true
    end
end

moveTo=function(cf,options)
    options=type(options)=="table" and options or {}
    if not Config.TeleportEnabled then
        STATE.MoveStats.Status="Teleport tắt"
        return false
    end
    if typeof(cf)=="Vector3" then cf=CFrame.new(cf) end
    if typeof(cf)~="CFrame" then return false end
    local _,hum,root,ok=alive()
    if not ok or not root or hum.Sit then return false end
    local now=os.clock()
    if now<(STATE.MoveStats.RecoveryUntil or 0) or
        (Config.MoveAutoBackoff and STATE.MoveGuard and now<(STATE.MoveGuard.PauseUntil or 0)) then return false end
    local thread=coroutine.running()
    local caller=options.Caller or STATE.MoveThreadOwners[thread] or "Manual"
    if not options.Recovery and caller~="Manual" then STATE.TeleportDestination=nil end
    if not options.Recovery and STATE.TeleportRecovery then
        STATE.TeleportRecovery.Token=(STATE.TeleportRecovery.Token or 0)+1
        STATE.TeleportRecovery.Pending=false
        STATE.TeleportRecovery.Retries=0
        STATE.TeleportRecovery.LastTarget=cf
        STATE.TeleportRecovery.Status="Đang di chuyển"
    end
    local priority=({["Farm engine"]=96,["Raid combat"]=85,["Sea/fishing"]=77,
        ["Experience"]=75,["Unified bosses"]=74,["Unified world patrol"]=70,
        ["Advanced fishing"]=65,["Spooky dungeon"]=82,["Spooky bounty"]=68,["Collectibles"]=52,["Unified events"]=48,
        ["Halloween doors"]=125,["Halloween pumpkins"]=46,["Unified follow"]=42,["Events"]=40,
        ["Unified auto shop"]=20})[caller] or 100
    local lock=STATE.MovementLock
    if lock and lock.Name~=caller and lock.Until>now and lock.Priority>priority then
        return false
    end
    local distance=(root.Position-cf.Position).Magnitude
    if STATE.RegionNavigator and distance>120 then
        local planned,handled,routeKind=STATE.RegionNavigator.BeforeMove(root,cf)
        if handled then return true end
        if planned then
            cf=planned
            distance=(root.Position-cf.Position).Magnitude -- V33: actual dock/waypoint distance
        end
    end
    if STATE.ResetTeleport and STATE.ResetTeleport.Try(cf,root) then return true end
    if distance<(caller=="Secret Quest Mobile" and 1 or
        ((caller=="Farm engine" and Config.FarmStyle=="Above") and 2.5 or (caller=="Halloween doors" and 2.3 or 6))) then
        if STATE.Mover and STATE.Mover.Active then cancelMove() end
        return true
    end
    STATE.MovementLock={Name=caller,Priority=priority,Until=now+2.8}
    local regionKind=STATE.RegionNavigator and
        STATE.RegionNavigator.Plan(root.Position,cf.Position).Kind or "normal"
    if Config.SmartPortal and regionKind=="normal" and distance>1200
        and now-(STATE.LastPortal or 0)>16 then
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
    local mode=Config.MovementMode=="Direct Tween" and "Direct Tween" or
        (Config.MovementMode=="Proxy Tween" and "Proxy Tween" or "Flight Tween")
    -- Never auto-switch to Direct Tween on a stall: it reintroduces collisions.
    if Config.MovementFailover and (STATE.MoveStats.Stalled or 0)>=3 then
        mode="Flight Tween"
    end
    local finalDestination
    if mode=="Flight Tween" and caller~="Secret Quest Mobile" and caller~="Secret Quest Manual" then
        -- Cross long stretches at a stable altitude; descend near the destination.
        -- Secret quest interactions use the actual object height directly: the
        -- sea-height climb/descend stages can oscillate around tiny objectives.
        local altitude=math.max(18,tonumber(Config.FlightWaterHeight) or 35)
        local horizontal=(Vector3.new(root.Position.X,0,root.Position.Z)-Vector3.new(cf.Position.X,0,cf.Position.Z)).Magnitude
        local localWater=STATE.RegionNavigator and
            STATE.RegionNavigator.IsLocalUnderwater(root.Position,cf.Position)
        if not localWater and horizontal>120 and root.Position.Y<altitude-6 then
            -- Stage one: climb vertically before crossing open sea at low altitude.
            finalDestination=cf
            cf=CFrame.new(root.Position.X,altitude,root.Position.Z)*root.CFrame.Rotation
        elseif not localWater and horizontal>120 and cf.Position.Y<altitude then
            -- Stage two: maintain altitude during the long horizontal crossing.
            finalDestination=cf
            cf=CFrame.new(cf.Position.X,altitude,cf.Position.Z)*cf.Rotation
        end
    end
    local m=STATE.EnsureMover(root)
    if m.Active and m.Goal and m.Mode==mode and m.CharacterRoot==root and m.Caller==caller then
        local shift=(m.Goal.Position-cf.Position).Magnitude
        local limit=caller=="Halloween doors" and 2.5 or math.max(4,tonumber(Config.MoveRetargetThreshold) or 7)
        local gap=now-(m.At or 0)
        -- Tiny target updates do not tear down the tween every farm tick.
        if shift<=limit then
            if caller=="Secret Quest Mobile" and options.HoldAtEnd~=nil then
                m.HoldAtEnd=options.HoldAtEnd==true
            end
            return true
        end
        if gap<math.max(.3,tonumber(Config.MoveRetargetDelay) or .4) then return true end
        STATE.MoveStats.Retargeted=STATE.MoveStats.Retargeted+1
    end
    cancelMove()
    STATE.MovementLock={Name=caller,Priority=priority,Until=now+2.8}
    m=STATE.EnsureMover(root)
    if mode=="Proxy Tween" or mode=="Flight Tween" then m.Proxy.CFrame=root.CFrame end
    if mode=="Flight Tween" then STATE.EnsureFlight(root) end
    local requested=math.clamp(tonumber(Config.TweenSpeed) or 350,40,400)
    local speed=Config.MoveAutoBackoff and STATE.MoveGuard.Refresh(now) or requested
    STATE.MoveStats.RequestedSpeed=requested
    STATE.MoveStats.EffectiveSpeed=speed
    local duration=math.max(.08,(root.Position-cf.Position).Magnitude/speed)
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
    m.HoldAtEnd=options.HoldAtEnd==true
    m.FinalDestination=finalDestination
    m.LastIssuedPos=nil;m.LastIssuedAt=nil
    STATE.Tween=tw;STATE.TweenGoal=cf;STATE.TweenAt=now
    STATE.MoveStats.Started=STATE.MoveStats.Started+1
    STATE.MoveStats.Status="Moving / "..mode
    local id=m.Generation
    m.CompletedConnection=tw.Completed:Connect(function(playback)
        if STATE.Alive and STATE.Mover==m and m.Generation==id then
            if playback==Enum.PlaybackState.Completed then
                m.FinishedAt=os.clock() -- allow root to catch up to completed proxy
            else
                cancelMove("Tween interrupted")
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
STATE.CombatRemotes={lastTry=-math.huge,Attack=nil,Hit=nil}
local function getCombatRemotes()
    local cached=STATE.CombatRemotes
    if cached.Attack and cached.Hit and cached.Attack:IsDescendantOf(RS) and cached.Hit:IsDescendantOf(RS) then
        return cached
    end
    if cached.Attack or cached.Hit then
        cached.Attack=nil
        cached.Hit=nil
        cached.lastTry=-math.huge
    end
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
    local raidActive=Config.AutoRaid and STATE.RaidDirector and STATE.RaidDirector.Owned
    if not (STATE.Alive and (Config.FarmEnabled or raidActive)
        and Config.FarmHoverLock and Config.FarmStyle=="Above") then
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
--[[ andepzai v25 / safe local combat protocol adapter.
  Source comparisons: user's message (2), Banana message (3), and bút tờ phờ...
  Different game builds route hit registration via COMBAT_REMOTE_THREAD or
  direct RE/RegisterHit. We detect the replicated flag and only use APIs
  present on this client, never assume an event means damage was accepted.
]]
do
    local B={Protocol="Undetected",Status="Not initialized",LastProbe=0,
        ServerThread=false,HasThreadFlag=false,LastAttack=0,Calls=0,
        DirectCalls=0,ThreadCalls=0,WeaponCalls=0,NoHandler=0,Failed=0,
        LastError="None",LastTool="None",LastBatch=0,
        LastOutput="None",HitFunction=nil,HitFunctionCheckedAt=0}
    STATE.CombatBridge=B
    local limbNames={"Head","HumanoidRootPart","UpperTorso","RightHand","LeftHand",
        "RightUpperArm","LeftUpperArm","RightLowerArm","LeftLowerArm"}
    function B.FindHitPart(mob,preference)
        if typeof(mob)~="Instance" then return nil end
        if preference=="Root" then return mob:FindFirstChild("HumanoidRootPart") end
        for _,partName in ipairs(limbNames) do
            local part=mob:FindFirstChild(partName)
            if part and part:IsA("BasePart") then return part end
        end
        local root=mob.PrimaryPart
        return root and root:IsA("BasePart") and root or nil
    end
    function B.Probe(force)
        if not force and B.LastProbe~=0 and os.clock()-B.LastProbe<10 then return end
        B.LastProbe=os.clock()
        B.Protocol="Direct remotes"
        B.ServerThread=false
        B.HasThreadFlag=false
        local modules=RS:FindFirstChild("Modules")
        local flagModule=modules and modules:FindFirstChild("Flags")
        if flagModule and flagModule:IsA("ModuleScript") then
            local ok,flags=pcall(require,flagModule)
            if ok and type(flags)=="table" and type(flags.COMBAT_REMOTE_THREAD)=="boolean" then
                B.HasThreadFlag=true
                B.ServerThread=flags.COMBAT_REMOTE_THREAD
                if B.ServerThread then B.Protocol="Game combat thread" end
            end
        end
        if B.ServerThread or force then B.ProbeSendHits(force) end
    end
    function B.ProbeSendHits(force)
        if not force and B.HitFunctionCheckedAt~=0 and os.clock()-B.HitFunctionCheckedAt<10 then return end
        B.HitFunctionCheckedAt=os.clock()
        B.HitFunction=nil
        local getEnvironment=api("getsenv")
        if type(getEnvironment)~="function" then
            B.Status="Game thread requires getsenv; Tool fallback only"
            return
        end
        local scripts=LP:FindFirstChild("PlayerScripts")
        if not scripts then B.Status="PlayerScripts not loaded";return end
        local count=0
        for _,scriptObject in ipairs(scripts:GetDescendants()) do
            if scriptObject:IsA("LocalScript") then
                count=count+1
                local ok,result=pcall(getEnvironment,scriptObject)
                if ok and type(result)=="table" then
                    local shared=result._G
                    local hit=type(shared)=="table" and shared.SendHitsToServer or result.SendHitsToServer
                    if type(hit)=="function" then
                        B.HitFunction=hit
                        B.Status="Game hit sender available"
                        return
                    end
                end
                if count>80 then break end
            end
        end
        B.Status="SendHitsToServer unavailable; Tool fallback"
    end
    function B.Send(targets,tool,protocol)
        B.Probe(false)
        if type(targets)~="table" or #targets==0 then
            B.Status="No valid attack targets";return false,"empty"
        end
        if not tool or not tool:IsA("Tool") then
            B.Status="Weapon not equipped";return false,"weapon"
        end
        B.LastTool=tool.Name;B.LastBatch=#targets
        local click=tool:FindFirstChild("LeftClickRemote")
        if click and click:IsA("RemoteEvent") then
            local char=LP.Character
            local root=char and char:FindFirstChild("HumanoidRootPart")
            local p=targets[1][2]
            local dir=(root and p and p.Position-root.Position) or Vector3.new(0,0,-1)
            local unit=dir.Magnitude>0 and dir.Unit or Vector3.new(0,0,-1)
            local ok=STATE.SendRemoteEvent(click,unit,1)
            if ok then
                B.WeaponCalls=B.WeaponCalls+1;B.Calls=B.Calls+1
                B.Status="Weapon remote sent; HP confirmation pending"
                return true,"LeftClickRemote"
            end
        end
        local remotes=getCombatRemotes()
        if not remotes or not remotes.Attack or not remotes.Hit then
            B.NoHandler=B.NoHandler+1;B.Status="PvE combat remotes not present"
            return false,"no-remotes"
        end
        local attackArg=protocol=="Topi" and .3 or 0
        local attackOK=STATE.SendRemoteEvent(remotes.Attack,attackArg)
        if not attackOK then
            B.Failed=B.Failed+1;B.LastError="RegisterAttack failed"
            return false,"attack-remote-failed"
        end
        if B.HasThreadFlag and B.ServerThread then
            if not B.HitFunction then
                B.NoHandler=B.NoHandler+1
                B.Status="COMBAT_REMOTE_THREAD is on; no game hit handler"
                return false,"thread-required"
            end
            local ok,err=pcall(B.HitFunction,targets[1][2],targets)
            if ok then
                B.ThreadCalls=B.ThreadCalls+1;B.Calls=B.Calls+1
                B.Status="Game-thread hit sent; HP confirmation pending"
                return true,"Game thread"
            end
            B.Failed=B.Failed+1;B.LastError=tostring(err)
            B.Status="Game hit handler errored"
            return false,"thread-call-failed"
        end
        -- When flag unavailable, keep old client behavior as a best-effort fallback.
        local ok=STATE.SendRemoteEvent(remotes.Hit,targets[1][2],targets)
        if ok then
            B.DirectCalls=B.DirectCalls+1;B.Calls=B.Calls+1
            B.Status="Direct RegisterHit sent; HP confirmation pending"
            return true,"Direct remote"
        end
        B.Failed=B.Failed+1;B.LastError="RegisterHit errored"
        return false,"hit-remote-failed"
    end
    function B.Snapshot()
        return {protocol=B.Protocol,status=B.Status,thread_flag=B.HasThreadFlag,
            server_thread=B.ServerThread,thread_handler=type(B.HitFunction)=="function",
            direct_calls=B.DirectCalls,thread_calls=B.ThreadCalls,weapon_calls=B.WeaponCalls,
            total_batches=B.Calls,failed=B.Failed,last_batch=B.LastBatch,
            last_weapon=B.LastTool,last_error=B.LastError,
            qualifier="Local sending is not server damage confirmation"}
    end
end

--[[
  andepzai V24 / COMBAT DIRECTOR
  User-supplied 3-Sea scan: replicated Net event paths only, not server hit logic.
  Source behavior contrasted with Topi and Spooky, rewritten as a self-contained
  client-side scheduler with measured HP damage and bounded call rate.
  It does not assume FireServer means damage, bypass anti-cheat, or claim that
  server-side combat accepts any particular request cadence.
]]
do
    local A={Active=false,Status="Standby",Protocol="Spooky",Attempts=0,
        AcceptedLocally=0,RemotePairs=0,ToolActivations=0,Failed=0,
        TargetsInBurst=0,TotalTargets=0,LastBurst=0,NextBurst=0,
        LastEquip=0,LastTool=0,LastProtocolSwitch=0,LastStatus=0,
        HPEvents=0,ConfirmedDamage=0,DamagePerSecond=0,Window={},
        Observed=setmetatable({},{__mode="k"}), LastTarget=nil,LastTargetAt=0,
        NoDamageSince=0, NoDamageWarnings=0, LastWarning=0, LastReason="Waiting for Farm",
        LastWindowTrim=0, LastCandidateScan=0, Candidates={}, LastProtocolAttempt="None",
        BurstSkips=0, LastCharacter=nil, LastWeapon=nil, BurstCount=0,
        LastBatch={}, StaleSkips=0, LastExport=0, LastDamageAt=0,
        ToolError="None", InvalidTargets=0, DamageSamples=0,
        LastRange=0, LastMeleeGap=0, AttemptsWithDamage=0,
    }
    STATE.FastAttackDirector=A
    local function now() return os.clock() end
    local function validMob(model)
        return model and STATE.IsAliveNPC(model) and model:FindFirstChild("HumanoidRootPart")~=nil
    end
    local function inWorkspace(model)
        local folder=enemyFolder()
        return folder and model and model.Parent==folder
    end
    local function number(v,fallback,lo,hi)
        return math.clamp(tonumber(v) or fallback,lo,hi)
    end
    local function selectedWeapon()
        local char=LP.Character
        if not char then return nil end
        local tool=char:FindFirstChildOfClass("Tool")
        if Config.AutoEquip and (not tool or now()-A.LastEquip>1.6) then
            A.LastEquip=now()
            local pick=equipByType()
            if pick and pick.Parent==char then tool=pick end
        end
        if not tool or tool.Parent~=char then return nil end
        return tool
    end
    local function recordDamage(model,newHealth)
        local entry=A.Observed[model]
        if not entry then return end
        if type(newHealth)~="number" then return end
        local before=entry.LastHP
        entry.LastHP=newHealth
        if type(before)~="number" or before<=newHealth then return end
        local loss=math.min(before-newHealth,1e9)
        if loss<.001 then return end
        local time=now()
        A.HPEvents=A.HPEvents+1
        A.ConfirmedDamage=A.ConfirmedDamage+loss
        A.LastDamageAt=time
        A.AttemptsWithDamage=A.AttemptsWithDamage+1
        A.NoDamageSince=0
        A.Window[#A.Window+1]={At=time,Damage=loss,Name=model.Name}
        STATE.CombatTelemetry.HealthChanged=STATE.CombatTelemetry.HealthChanged+1
        STATE.CombatTelemetry.LastDamage=loss
        STATE.CombatTelemetry.LastDamageAt=time
        STATE.CombatTelemetry.LastIssue="Confirmed HP drop: "..math.floor(loss)
        A.LastReason="HP decreasing (client observation); server validation unverified"
    end
    local function observe(model)
        if not validMob(model) then return end
        local hum=model:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health<=0 then return end
        local entry=A.Observed[model]
        if entry and entry.Humanoid==hum then
            if entry.LastHP==nil then entry.LastHP=hum.Health end
            entry.LastSeen=now()
            return
        end
        if entry and entry.Conn then pcall(function() entry.Conn:Disconnect() end) end
        local d={Humanoid=hum,LastHP=hum.Health,LastSeen=now()}
        d.Conn=hum.HealthChanged:Connect(function(hp)
            if STATE.Alive and A.Observed[model]==d then recordDamage(model,hp) end
        end)
        A.Observed[model]=d
    end
    local function garbageCollect(force)
        local time=now()
        for model,d in pairs(A.Observed) do
            if force or not model or not model.Parent or not d.Humanoid or not d.Humanoid.Parent
                or time-(d.LastSeen or 0)>18 then
                if d.Conn then pcall(function() d.Conn:Disconnect() end) end
                A.Observed[model]=nil
            end
        end
        if force then table.clear(A.Window);A.DamagePerSecond=0;return end
        if time-A.LastWindowTrim<.55 then return end
        A.LastWindowTrim=time
        local windowSecs=10
        local samples,total={},0
        for _,sample in ipairs(A.Window) do
            if time-sample.At<=windowSecs then
                samples[#samples+1]=sample
                total=total+sample.Damage
            end
        end
        A.Window=samples
        A.DamagePerSecond=total/windowSecs
    end
    local function markStatus(message)
        if A.Status~=message then A.Status=message end
        A.LastReason=message
    end
    function A.Reset(keepStats)
        A.Active=false;A.NextBurst=0;A.LastTarget=nil;A.LastTargetAt=0
        A.LastCandidateScan=0;A.Candidates={};A.LastBatch={}
        A.NoDamageSince=0;A.LastRange=0;A.TargetsInBurst=0
        A.Protocol="Spooky"
        A.Status="Standby";A.LastReason="Farm disabled or target unavailable"
        garbageCollect(true)
        if not keepStats then
            A.Attempts=0;A.AcceptedLocally=0;A.RemotePairs=0;A.ToolActivations=0
            A.HPEvents=0;A.ConfirmedDamage=0;A.DamageSamples=0
            A.Failed=0;A.NoDamageWarnings=0;A.AttemptsWithDamage=0
        end
    end
    function A.Stop()
        A.Reset(true)
    end
    function A.Prime(target)
        if not validMob(target) then return false end
        A.Active=true
        if A.LastTarget~=target then
            A.LastTarget=target;A.LastTargetAt=now();A.LastCandidateScan=0
            A.NoDamageSince=now();A.Candidates={}
            A.NextBurst=0
            A.Status="New target: "..target.Name
        end
        observe(target)
        return true
    end
    local function compatibleTarget(mob,target,center,playerPos,range)
        if not validMob(mob) then return false end
        if not inWorkspace(mob) then return false end
        if mob==target then return true end
        if not Config.FastAttackMultiTarget then return false end
        if isBoss(target.Name) or isBoss(mob.Name) then return false end
        local anyNormal=(STATE.MobMagnet and STATE.MobMagnet.AllowMixed)
            or Config.MobMagnetMatchMode=="Nearby normal mobs"
        if not anyNormal and norm(mob.Name)~=norm(target.Name) then return false end
        local mr=mob:FindFirstChild("HumanoidRootPart")
        if not mr then return false end
        local dist=(mr.Position-playerPos).Magnitude
        if dist>range then return false end
        -- Never include another island's NPC just because the attack range is large.
        if (mr.Position-center).Magnitude>math.max(range,number(Config.MobMagnetRadius,175,40,350)) then return false end
        return true
    end
    local function makeBatch(target,rootPos,range)
        local primaryRoot=target:FindFirstChild("HumanoidRootPart")
        if not primaryRoot then return {} end
        local nowTick=now()
        local maxTargets=math.floor(number(Config.FastAttackTargets,6,1,10))
        if not Config.FastAttackMultiTarget then maxTargets=1 end
        -- Cache the folder enumeration for short periods, but ALWAYS revalidate
        -- dead NPCs and distances before calling the attack remote.
        if nowTick-A.LastCandidateScan>.18 or A.LastTarget~=target then
            A.LastCandidateScan=nowTick
            local candidates={}
            local folder=enemyFolder()
            if folder then
                for _,mob in ipairs(folder:GetChildren()) do
                    if compatibleTarget(mob,target,primaryRoot.Position,rootPos,range) and mob~=target then
                        local mr=mob:FindFirstChild("HumanoidRootPart")
                        local d=(mr.Position-primaryRoot.Position).Magnitude
                        candidates[#candidates+1]={Mob=mob,Dist=d}
                    end
                end
            end
            table.sort(candidates,function(x,y)return x.Dist<y.Dist end)
            A.Candidates=candidates
        end
        local batch={}
        local function push(mob)
            if #batch>=maxTargets then return end
            if not validMob(mob) then A.StaleSkips=A.StaleSkips+1;return end
            local r=mob:FindFirstChild("HumanoidRootPart")
            local head=STATE.CombatBridge.FindHitPart(mob) or r
            if not head or (r.Position-rootPos).Magnitude>range then return end
            batch[#batch+1]={mob,head}
            observe(mob)
        end
        push(target)
        if #batch>=maxTargets then return batch end
        for _,entry in ipairs(A.Candidates) do
            if #batch>=maxTargets then break end
            if entry.Mob~=target and compatibleTarget(entry.Mob,target,primaryRoot.Position,rootPos,range) then
                push(entry.Mob)
            end
        end
        return batch
    end
    local function canAttack()
        local char,hum,root,ready=alive()
        if not ready or not char then return false,"Character not ready" end
        if hum.Sit or hum.Health<=0 then return false,"Character seated or dead" end
        if char:GetAttribute("UsingSkill") or char:GetAttribute("isUsingSkill") or char:GetAttribute("Busy") then
            return false,"Character using a skill"
        end
        return true,char,root
    end
    local function chooseProtocol(time)
        if Config.PVEHitProtocol=="Topi" or Config.PVEHitProtocol=="Spooky" then
            return Config.PVEHitProtocol
        end
        -- For Auto, switch only after a sustained interval without HP decrease.
        -- This avoids mistaking one dropped frame for a broken protocol.
        if A.NoDamageSince~=0 and time-A.NoDamageSince>5 and
            time-A.LastProtocolSwitch>6 and A.RemotePairs>=12 then
            A.Protocol=A.Protocol=="Topi" and "Spooky" or "Topi"
            A.LastProtocolSwitch=time
            A.NoDamageWarnings=A.NoDamageWarnings+1
            A.LastReason="No HP drop; trying "..A.Protocol.." hit format"
            A.NoDamageSince=time
        end
        return A.Protocol
    end
    local function effectiveInterval(time)
        local base=number(Config.FastAttackInterval,.06,.045,.4)
        if not Config.FastAttackAutoTune then return base end
        -- A short no-damage interval is more likely an incorrect hit/distance
        -- than a need to spam more requests. Back off, then retry another format.
        if A.NoDamageSince~=0 and time-A.NoDamageSince>4 then
            return math.min(.24,base+.055)
        end
        return base
    end
    function A.Tick()
        -- v33 did no damage outside FarmEnabled: engage() returned early
        -- when CombatScheduler=true, but only FarmEnabled drove this scheduler.
        local otherCombat=(Config.AutoTrickOrTreat or Config.AutoKatakuri or Config.AutoRaid
            or Config.AutoRaceV4 or Config.AutoRaidCombat or Config.AutoBones
            or Config.AutoTyrant or Config.AutoDoughKing or Config.AutoSea)
        if not (STATE.Alive and (Config.FarmEnabled or otherCombat) and Config.Combat
            and Config.FastAttackEnabled and Config.CombatScheduler) then
            if A.Active then A.Stop() end
            return
        end
        local target=Config.FarmEnabled and STATE.NPCFilter and STATE.NPCFilter.Held or nil
        if not target then
            local fresh=STATE.AutomationCombatTarget
            if fresh and os.clock()-(STATE.AutomationCombatAt or 0)<1.4 then target=fresh end
        end
        if not A.Prime(target) then
            if A.Active then A.Stop() end
            return
        end
        local time=now()
        if time<A.NextBurst then return end
        A.NextBurst=time+effectiveInterval(time)
        local ready,char,root=canAttack()
        if not ready then markStatus(char);A.BurstSkips=A.BurstSkips+1;return end
        local tool=selectedWeapon()
        if not tool then markStatus("No equipped weapon");return end
        A.LastWeapon=tool.Name
        local targetRoot=target:FindFirstChild("HumanoidRootPart")
        if not targetRoot then markStatus("Target root missing");return end
        local gap=(targetRoot.Position-root.Position).Magnitude
        local range=number(Config.AttackRange,32,8,65)
        A.LastRange=gap;A.LastMeleeGap=gap
        if gap>range then
            markStatus(string.format("Out of attack range (%.1f / %.0f studs)",gap,range))
            return
        end
        local batch=makeBatch(target,root.Position,range)
        if #batch==0 then markStatus("No living target in range");return end
        A.Attempts=A.Attempts+1
        A.BurstCount=A.BurstCount+1
        A.TargetsInBurst=#batch
        A.TotalTargets=A.TotalTargets+#batch
        A.LastBurst=time
        A.LastBatch=batch
        local method=Config.CombatMode
        local remoteAllowed=method~="Tool only"
        local toolAllowed=method~="Remote only"
        local sent=false
        local reason="Waiting for a supported attack method"
        if remoteAllowed then
            local format=chooseProtocol(time)
            local ok,used=STATE.CombatBridge.Send(batch,tool,format)
            sent=ok==true
            A.LastProtocolAttempt=format.." / "..tostring(used)
            if sent then
                A.RemotePairs=A.RemotePairs+1
                STATE.CombatTelemetry.RemoteCalls=STATE.CombatTelemetry.RemoteCalls+1
                reason="Batched attack ("..#batch.." mobs): "..tostring(used)
            else reason="PvE attack not sent: "..tostring(used) end
        end
        -- Tool activation is a lower-rate fallback; it does not claim range
        -- extension and never synthesizes input on top of the menu.
        if toolAllowed and (not sent or method=="Hybrid" or method=="Adaptive") and
            time-A.LastTool>=number(Config.ToolAttackInterval,.19,.13,.7) then
            A.LastTool=time
            local ok,err=pcall(function() tool:Activate() end)
            if ok then
                A.ToolActivations=A.ToolActivations+1
                STATE.CombatTelemetry.ToolCalls=STATE.CombatTelemetry.ToolCalls+1
            else A.ToolError=tostring(err);reason="Tool.Activate failed: "..A.ToolError end
        end
        if sent then A.AcceptedLocally=A.AcceptedLocally+1
        elseif not toolAllowed then A.Failed=A.Failed+1 end
        A.Status=reason
        STATE.CombatTelemetry.LastIssue=reason
        STATE.CombatTelemetry.Used=sent and "Fast Attack Director" or "Tool fallback"
        STATE.CombatTelemetry.Attempts=STATE.CombatTelemetry.Attempts+1
        STATE.CombatTelemetry.LastAttemptAt=time
        garbageCollect(false)
        if A.NoDamageSince==0 then A.NoDamageSince=time end
        if A.RemotePairs>10 and time-A.NoDamageSince>8 and time-A.LastWarning>18 then
            A.LastWarning=time
            A.NoDamageWarnings=A.NoDamageWarnings+1
            A.LastReason="No confirmed HP drop in 8s. Check range, weapon and server-side behavior"
            slog("Combat diagnostics: "..A.LastReason,"warn")
        end
    end
    function A.Snapshot()
        garbageCollect(false)
        return {
            sea=STATE.World,level=level(),mode=Config.FarmMode,weapon=A.LastWeapon,
            current_target=A.LastTarget and A.LastTarget.Name or "None",
            attack_interval=Config.FastAttackInterval,effective_interval=effectiveInterval(now()),
            protocol=A.LastProtocolAttempt,attempts=A.Attempts,
            remote_pairs=A.RemotePairs,tool_activations=A.ToolActivations,
            last_batch_targets=A.TargetsInBurst,all_target_attempts=A.TotalTargets,
            hp_drop_events=A.HPEvents,observed_damage=A.ConfirmedDamage,
            dps_window=A.DamagePerSecond,no_damage_warnings=A.NoDamageWarnings,
            distance=A.LastRange,range=Config.AttackRange,
            status=A.Status,reason=A.LastReason,
            qualifier="Client observations; FireServer does not confirm server acceptance",
        }
    end
    function A.Export()
        if not canFile("writefile") then return false,"Executor has no writefile" end
        local data=A.Snapshot()
        local filepath=FOLDER.."/combat_v25_"..tostring(STATE.World)..".json"
        local ok,err=pcall(function()
            if canFile("makefolder") and canFile("isfolder") and not api("isfolder")(FOLDER) then
                api("makefolder")(FOLDER)
            end
            api("writefile")(filepath,Http:JSONEncode(data))
        end)
        if ok then A.LastExport=now();return true,filepath end
        return false,tostring(err)
    end
    -- Cleanup lives on STATE.Alive, not a duplicate infinite loop.
    task.spawn(function()
        while STATE.Alive do
            task.wait(3)
            if A.Active then garbageCollect(false) end
        end
        garbageCollect(true)
    end)
end

local function engage(mob)
    if not STATE.IsAliveNPC(mob) then return end
    if not Config.FarmEnabled then
        STATE.AutomationCombatTarget=mob
        STATE.AutomationCombatAt=os.clock()
    end
    local h=mob:FindFirstChildOfClass("Humanoid")
    local target=mob:FindFirstChild("HumanoidRootPart")
    if not (h and h.Health>0 and target) then return end
    -- V33: Pull eligible nearby normal NPCs whenever the shared PvE engine engages.
    -- Farm, raid, bones, Halloween and other modes use this same entry point.
    if STATE.MobMagnet then STATE.MobMagnet.Step(mob) end
    local telemetry=STATE.CombatTelemetry
    local scheduled=Config.CombatScheduler and Config.FastAttackEnabled
    if not scheduled and telemetry.LastEnemyInstance==mob and type(telemetry.LastObservedHP)=="number" and
        h.Health<telemetry.LastObservedHP then
        telemetry.LastDamage=telemetry.LastObservedHP-h.Health
        telemetry.HealthChanged=telemetry.HealthChanged+1
        telemetry.LastDamageAt=os.clock()
        telemetry.LastIssue="Damage confirmed: "..string.format("%.0f",telemetry.LastDamage)
    end
    telemetry.LastEnemy=mob.Name;telemetry.LastObservedHP=h.Health
    telemetry.LastEnemyInstance=mob
    if (Config.FarmEnabled or (Config.AutoRaid and STATE.RaidDirector and STATE.RaidDirector.Owned))
        and Config.FarmStyle=="Above" then
        STATE.UpdateFarmHover(mob)
    end
    local cf=positionForMob(mob)
    if cf then moveTo(cf) end
    -- Movement and attack have separate loops in v24. Do not throttle attack
    -- to the 0.16-s Farm cadence and do not double-send from both loops.
    if scheduled then return end
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
    elseif Config.FarmMode=="Island" then
        local island,selected=STATE.GetIslandFarmEntry(Config.IslandFarmIsland)
        if not island then return nil end
        if selected and Config.IslandFarmIsland~=selected then Config.IslandFarmIsland=selected end
        local mob=enemySearch(island.Mobs,false,true)
        if not mob and island.CFrame then moveTo(island.CFrame) end
        return mob
    elseif Config.FarmMode=="Halloween Boss" then
        -- Only chase a living, locally replicated boss within the chosen radius.
        -- There is no fabricated spawn coordinate or automatic summoning here.
        local boss,distance=STATE.Halloween2026.FindBoss(Config.HalloweenBossType,Config.HalloweenBossRadius)
        if boss then
            STATE.Halloween2026.BossStatus=boss.Name.." · "..math.floor(distance or 0).." studs"
        else
            STATE.Halloween2026.BossStatus="Chưa thấy boss còn sống trong phạm vi"
            local mover=STATE.Mover
            if mover and mover.Active and mover.Caller=="Farm engine" then cancelMove() end
        end
        return boss
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



--// V33 AUTO MOB GROUPING — integrated in every eligible PvE engage().
--// Sources: Topi's renewed candidate scan + incremental Heartbeat pull,
--// bnn's same-area candidate selection, DynamicIsland's focus on active target.
--// Only changes client-controlled NPC assemblies; server replication is NOT guaranteed.
do
    local CollectionService=game:GetService("CollectionService")
    local M={Tracked=setmetatable({},{__mode="k"}),Blocked=setmetatable({},{__mode="k"}),
        NextScan=0,LastCall=0,LastAssist=0,Steps=0,Attracted=0,Rejections=0,
        Active=0,LastError="Sẵn sàng: tự gom khi đánh quái",SkippedOwner=0,
        LocalMoves=0,LastSuccess=0,Assisted=false,AutoWired=true,AllowMixed=false,
        TotalScans=0,Eligible=0,Target=nil,TargetName="--",Stopped=0}
    STATE.MobMagnet=M

    local function restore(mob)
        local d=M.Tracked[mob]
        if not d then return end
        M.Tracked[mob]=nil
        if d.hum and d.hum.Parent then
            pcall(function()
                d.hum.WalkSpeed=d.speed
                d.hum.JumpPower=d.jump
                d.hum.JumpHeight=d.height
                d.hum.AutoRotate=d.rotate
            end)
        end
        if d.root and d.root.Parent then
            pcall(function() d.root.CanCollide=d.collide end)
        end
        if d.parts then
            for part,collide in pairs(d.parts) do
                if part and part.Parent then pcall(function() part.CanCollide=collide end) end
            end
        end
        if d.body and d.body.Parent then pcall(function() d.body:Destroy() end) end
        if d.tagged and mob and mob.Parent then pcall(function() CollectionService:RemoveTag(mob,"andepzai_mob_magnet") end) end
    end
    local function restoreAssist()
        if not M.Assisted then return end
        local setter=api("sethiddenproperty")
        if setter and M.OriginalSimulationRadius~=nil then
            pcall(setter,LP,"SimulationRadius",M.OriginalSimulationRadius)
        end
        if setter and M.OriginalMaxSimulationRadius~=nil then
            pcall(setter,LP,"MaxSimulationRadius",M.OriginalMaxSimulationRadius)
        end
        M.Assisted=false
    end
    function M.Stop(reason)
        for mob in pairs(M.Tracked) do restore(mob) end
        M.Active=0;M.NextScan=0;M.LastCall=0
        M.Target=nil;M.TargetName="--";M.AllowMixed=false
        M.Stopped=M.Stopped+1
        restoreAssist()
        M.LastError=reason or "Đợi NPC · tự gom khi đánh"
    end
    local function hasOwnership(root)
        local checker=api("isnetworkowner")
        if checker then
            local ok,owned=pcall(checker,root)
            if ok then return owned==true end
        end
        -- Missing ownership API: attempt locally, then check for server snapbacks.
        return true
    end
    local function optionalNetworkAssist()
        if not Config.MobMagnetNetworkAssist or os.clock()-M.LastAssist<10 then return end
        M.LastAssist=os.clock()
        local getter=api("gethiddenproperty")
        local setter=api("sethiddenproperty")
        if not getter or not setter then return end
        if M.OriginalSimulationRadius==nil then
            local ok,old=pcall(getter,LP,"SimulationRadius")
            if not ok then return end
            M.OriginalSimulationRadius=old
            pcall(function()
                local _,maxRadius=pcall(getter,LP,"MaxSimulationRadius")
                M.OriginalMaxSimulationRadius=maxRadius
            end)
        end
        local radius=math.clamp(tonumber(Config.MobMagnetRadius) or 205,60,300)+70
        local ok=pcall(setter,LP,"SimulationRadius",radius)
        pcall(setter,LP,"MaxSimulationRadius",radius)
        M.Assisted=ok
    end
    local function mixedMode()
        if STATE.RaidDirector and STATE.RaidDirector.Owned then return true end
        if STATE.RaceV4Director and STATE.RaceV4Director.InTrial then return true end
        if not Config.FarmEnabled then return true end
        local mode=Config.FarmMode
        if mode=="Nearest" or mode=="Mastery" or mode=="Aura" then return true end
        return Config.MobMagnetMatchMode=="Nearby normal mobs"
    end
    local function validCandidate(mob,target,center,now,radius,allowMixed)
        if mob==target or not STATE.IsAliveNPC(mob) or isBoss(mob.Name) then return nil end
        if mob:FindFirstChild("Ignored") or mob:GetAttribute("Ignored")==true then return nil end
        if M.Blocked[mob] and M.Blocked[mob]>now then return nil end
        if not allowMixed and norm(mob.Name)~=norm(target.Name) then return nil end
        local mr=mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart
        if not mr then return nil end
        local gap=mr.Position-center
        -- Same floor, same island. Never pull NPCs from a different underwater level.
        if math.abs(gap.Y)>30 or gap.Magnitude>radius then return nil end
        return {Mob=mob,Root=mr,Distance=gap.Magnitude}
    end
    function M.Step(target)
        if not STATE.Alive then return end
        if not STATE.IsAliveNPC(target) or isBoss(target.Name)
            or target:FindFirstChild("Ignored") then
            if M.Target then M.Stop("Chỉ gom quái thường, không gom boss") end
            return
        end
        local _,_,playerRoot,ready=alive()
        local center=target:FindFirstChild("HumanoidRootPart")
        if not (ready and center) then
            if M.Target then M.Stop("Nhân vật/mục tiêu chưa sẵn sàng") end
            return
        end
        if (center.Position-playerRoot.Position).Magnitude>300 then
            if M.Target then M.Stop("Đang đến gần quái trước khi tự gom") end
            return
        end
        local now=os.clock()
        if M.Target~=target then
            if M.Target then M.Stop("Đổi mục tiêu farm") end
            M.Target=target;M.TargetName=target.Name;M.NextScan=0
        end
        M.LastCall=now
        M.AllowMixed=mixedMode()
        if now<M.NextScan then return end
        M.NextScan=now+.20
        optionalNetworkAssist()
        local folder=enemyFolder()
        if not folder then M.Stop("Không thấy workspace.Enemies");return end
        local radius=math.clamp(tonumber(Config.MobMagnetRadius) or 205,60,300)
        if STATE.RaidDirector and STATE.RaidDirector.Owned then
            radius=math.min(radius,tonumber(Config.RaidMagnetRadius) or 175)
        elseif STATE.RaceV4Director and STATE.RaceV4Director.InTrial then
            radius=math.min(radius,tonumber(Config.V4TrialMagnetRadius) or 170)
        end
        local maximum=math.clamp(math.floor(tonumber(Config.MobMagnetMax) or 8),2,12)
        local candidates={}
        -- Some event spawns are nested below an island model instead of being
        -- direct children of workspace.Enemies, so scan models recursively and
        -- cap the work per pass for low-end phones.
        local scanned=0
        for _,mob in ipairs(folder:GetDescendants()) do
            if mob:IsA("Model") then
                scanned=scanned+1
                local c=validCandidate(mob,target,center.Position,now,radius,M.AllowMixed)
                if c then candidates[#candidates+1]=c end
                if scanned>=180 then break end
            end
        end
        table.sort(candidates,function(a,b)return a.Distance<b.Distance end)
        M.TotalScans=M.TotalScans+1;M.Eligible=#candidates
        local selected={}
        local denied=0
        for i=1,math.min(#candidates,maximum-1) do
            local c=candidates[i]
            local mob,root=c.Mob,c.Root
            if hasOwnership(root) then
                local d=M.Tracked[mob]
                if not d then
                    local hum=mob:FindFirstChildOfClass("Humanoid")
                    if hum then
                        d={hum=hum,root=root,speed=hum.WalkSpeed,jump=hum.JumpPower,
                            height=hum.JumpHeight,rotate=hum.AutoRotate,
                            collide=root.CanCollide,parts={},body=nil,tagged=false,
                            corrections=0,firstCorrection=now}
                        M.Tracked[mob]=d;M.Attracted=M.Attracted+1
                        if Config.MobMagnetBodyPosition then
                            pcall(function()
                                local body=Instance.new("BodyPosition")
                                body.Name="andepzai_mob_anchor"
                                body.MaxForce=Vector3.new(1e6,1e6,1e6)
                                body.P=8000;body.D=600;body.Position=root.Position
                                body.Parent=root;d.body=body
                            end)
                        end
                        pcall(function()
                            CollectionService:AddTag(mob,"andepzai_mob_magnet")
                            d.tagged=true
                        end)
                    end
                end
                if d then
                    selected[mob]=true
                    d.expires=now+.75;d.slot=i;d.target=target
                    pcall(function()
                        d.hum.WalkSpeed=0;d.hum.JumpPower=0;d.hum.JumpHeight=0
                        d.hum.AutoRotate=false;d.hum:Move(Vector3.zero,false)
                        for _,part in ipairs(mob:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if d.parts[part]==nil then d.parts[part]=part.CanCollide end
                                part.CanCollide=false
                            end
                        end
                    end)
                end
            else
                denied=denied+1
            end
        end
        M.SkippedOwner=M.SkippedOwner+denied
        for mob in pairs(M.Tracked) do
            if not selected[mob] then restore(mob) end
        end
        local count=0;for _ in pairs(M.Tracked) do count=count+1 end
        M.Active=count
        if count>0 then
            M.LastError=string.format("Tự gom %d/%d quái quanh %s",count,#candidates,target.Name)
        elseif denied>0 then
            M.LastError="Server giữ quyền điều khiển NPC ("..denied.." mục tiêu)"
        elseif #candidates==0 then
            M.LastError="Chưa có quái phù hợp trong bán kính "..radius
        else
            M.LastError="Không gom được NPC ứng viên"
        end
    end
    on(Run,Run.Heartbeat,function(dt)
        if not STATE.Alive then return end
        if M.Target==nil then return end
        local now=os.clock()
        -- Even if a side-loop silently stops, all grabbed NPCs are released.
        if now-M.LastCall>1.1 or not STATE.IsAliveNPC(M.Target) then
            M.Stop("Chờ mục tiêu farm tiếp theo")
            return
        end
        dt=math.clamp(tonumber(dt) or 1/60,1/240,1/20)
        local remaining=0
        for mob,d in pairs(M.Tracked) do
            local root=d.root
            if now>(d.expires or 0) or not STATE.IsAliveNPC(mob)
                or not root or not root.Parent or not hasOwnership(root) then
                restore(mob)
            else
                local anchor=d.target and d.target:FindFirstChild("HumanoidRootPart")
                if not anchor or not STATE.IsAliveNPC(d.target) then
                    restore(mob)
                else
                    local current=root.Position
                    -- Topi's correction guard: stop trying with NPCs server resets.
                    if d.expected and (current-d.expected).Magnitude>18 then
                        if now-(d.firstCorrection or 0)>2 then
                            d.firstCorrection=now;d.corrections=0
                        end
                        d.corrections=d.corrections+1
                        M.Rejections=M.Rejections+1
                        if d.corrections>=4 then
                            M.Blocked[mob]=now+10
                            M.LastError="Server kéo quái về, tạm bỏ qua 15s: "..mob.Name
                            restore(mob)
                        end
                    end
                    if M.Tracked[mob] then
                        local angle=(d.slot or 1)*2.3999632297
                        local desired=anchor.Position+Vector3.new(math.cos(angle)*3,0,math.sin(angle)*3)
                        local flat=Vector3.new(desired.X-current.X,0,desired.Z-current.Z)
                        local dist=flat.Magnitude
                        if dist>5 then
                            local step=math.min(dist-4,280*dt)
                            if step>0 then
                                local delta=flat.Unit*step
                                local ok=pcall(function()
                                    if d.body and d.body.Parent then
                                        d.body.Position=desired
                                    else
                                        root.CFrame=CFrame.new(root.Position+delta)*root.CFrame.Rotation
                                    end
                                    local v=root.AssemblyLinearVelocity
                                    root.AssemblyLinearVelocity=Vector3.new(0,v.Y,0)
                                    root.AssemblyAngularVelocity=Vector3.zero
                                end)
                                if ok then
                                    d.expected=root.Position
                                    M.Steps=M.Steps+1;M.LocalMoves=M.LocalMoves+1
                                    M.LastSuccess=now
                                else
                                    M.LastError="NPC root không nhận CFrame"
                                    restore(mob)
                                end
                            end
                        else
                            d.expected=current
                        end
                    end
                end
            end
            if M.Tracked[mob] then remaining=remaining+1 end
        end
        M.Active=remaining
        for mob,untilAt in pairs(M.Blocked) do
            if now>untilAt then M.Blocked[mob]=nil end
        end
    end)
    on(LP,LP.CharacterAdded,function() M.Stop("Nhân vật hồi sinh; reset gom quái") end)
    function M.Snapshot()
        return {Automatic=true,Active=M.Active,Target=M.TargetName,
            Eligible=M.Eligible,Scans=M.TotalScans,LocalMoves=M.LocalMoves,
            ServerCorrections=M.Rejections,OwnershipDenied=M.SkippedOwner,
            Status=M.LastError,Stopped=M.Stopped}
    end
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

-- Static island aliases merged from NightMystic/Banana references.  The live
-- Map/_WorldOrigin objects still win; these entries only fill missing dropdown
-- names while a map is streaming.  Several spellings are kept as aliases
-- because the source files use different labels (e.g. Frist/First, Colossuim).
STATE.ReferenceIslandAliases={
    [1]={
        {Name="Windmill",CFrame=CFrame.new(979.79895,16.51661,1429.04663),Aliases={"WindMill"}},
        {Name="Marine",CFrame=CFrame.new(-2566.42968,6.85566,2045.2561),Aliases={"Marine Start"}},
        {Name="Sky Island 1",CFrame=CFrame.new(-4869.10253,733.46051,-2667.01806),Aliases={"Lower Skylands"}},
        {Name="Sky Island 2",CFrame=CFrame.new(-4607.82275,872.54248,-1667.55688),Aliases={"Skylands"}},
        {Name="Sky Island 3",CFrame=Vector3.new(-7894,5547,-380),Aliases={"Upper Skylands"}},
        {Name="Under Water Island",CFrame=Vector3.new(61163,11,1819),Aliases={"Underwater City","Under Water"}},
        {Name="Shank Room",CFrame=CFrame.new(-1442.16553,29.87882,-28.35474)},
        {Name="Mob Island",CFrame=CFrame.new(-2850.20068,7.39224,5354.99268),Aliases={"Jean-Luc Island"}},
        {Name="MarineFord",CFrame=CFrame.new(-4914.82128,50.96362,4281.02783),Aliases={"Marine Fortress"}},
    },
    [2]={
        {Name="The Cafe",CFrame=CFrame.new(-380.47927,77.22039,255.8255),Aliases={"Cafe","Café"}},
        {Name="Frist Spot",CFrame=CFrame.new(-11.31145,29.27673,2771.52246),Aliases={"First Spot"}},
        {Name="Dark Area",CFrame=CFrame.new(3780.03027,22.65216,-3498.58593),Aliases={"Dark Arena"}},
        {Name="Flamingo Mansion",CFrame=CFrame.new(-483.7337,332.03836,595.32708),Aliases={"Don Swan Mansion"}},
        {Name="Flamingo Room",CFrame=CFrame.new(2284.41406,15.15203,875.72534),Aliases={"Don Swan Room"}},
        {Name="Green Zone",CFrame=CFrame.new(-2448.53002,73.0161,-3210.63061)},
        {Name="Factory",CFrame=CFrame.new(424.12698,211.16171,-427.54049)},
        {Name="Colossuim",CFrame=CFrame.new(-1503.62243,219.79562,1369.31018),Aliases={"Colosseum"}},
        {Name="Zombie Island",CFrame=CFrame.new(-5622.0332,492.19604,-781.78552),Aliases={"Graveyard"}},
        {Name="Two Snow Mountain",CFrame=CFrame.new(753.14288,408.23559,-5274.61474),Aliases={"Snow Mountain"}},
        {Name="Punk Hazard",CFrame=CFrame.new(-6127.65429,15.95176,-5040.28613),Aliases={"Hot and Cold"}},
        {Name="Ice Castle",CFrame=CFrame.new(6148.41162,294.38687,-6741.11669)},
        {Name="Forgotten Island",CFrame=CFrame.new(-3032.76416,317.89672,-10075.37304)},
        {Name="Ussop Island",CFrame=CFrame.new(4816.86181,8.45998,2863.81958),Aliases={"Remote Island"}},
        {Name="Cursed Ship",CFrame=Vector3.new(923,126,32852)},
    },
    [3]={
        {Name="Port Town",CFrame=CFrame.new(-260.65557,49325.80468,-35253.57031),Aliases={"MiniSky"}},
        {Name="Hydra Island",CFrame=CFrame.new(5433,1062,290)},
        {Name="Great Tree",CFrame=CFrame.new(2681.27368,1682.8092,-7190.98535)},
        {Name="Castle On The Sea",CFrame=CFrame.new(-5074.45556,314.51553,-2991.05444),Aliases={"Castle on the Sea"}},
        {Name="Floating Turtle",CFrame=CFrame.new(-13274.52832,531.82073,-7579.22265)},
        {Name="Mansion",CFrame=CFrame.new(-12551,337,-7476)},
        {Name="Haunted Castle",CFrame=CFrame.new(-9516,142,5537)},
        {Name="Ice Cream Island",CFrame=CFrame.new(-874,66,-10915),Aliases={"Ice Cream Land"}},
        {Name="Peanut Island",CFrame=CFrame.new(-2062.74755,50.47389,-10232.56835),Aliases={"Peanut Land"}},
        {Name="Cake Island",CFrame=CFrame.new(-1884.77478,19.32752,-11666.89746),Aliases={"Cake Land"}},
        {Name="Cocoa Island",CFrame=CFrame.new(87.94276,73.55451,-12319.46484)},
        {Name="Candy Island",CFrame=CFrame.new(-1014.42419,149.11068,-14555.96289)},
        {Name="Tiki Outpost",CFrame=CFrame.new(-16101.1885,12.84221,380.94229)},
    },
}

STATE.TravelCatalog={NPCPoints={},IslandPoints={},BuiltAt=0}
function STATE.TravelModelRoot(model)
    if not model or not model:IsA("Model") then return nil end
    return model:FindFirstChild("HumanoidRootPart") or model.PrimaryPart or
        model:FindFirstChildWhichIsA("BasePart",true)
end
function STATE.TravelObjectCFrame(object)
    if not object then return nil end
    if object:IsA("Model") then
        local ok,cf=pcall(function() return object:GetPivot() end)
        return ok and cf or nil
    end
    if object:IsA("BasePart") then return object.CFrame end
    if object:IsA("Folder") then
        local part=object:FindFirstChildWhichIsA("BasePart",true)
        return part and part.CFrame or nil
    end
    return nil
end
function STATE.BuildTravelCatalog()
    local catalog=STATE.TravelCatalog
    catalog.NPCPoints={};catalog.IslandPoints={}
    local function add(map,label,cf,aliases)
        if typeof(cf)=="Vector3" then cf=CFrame.new(cf) end
        if type(label)~="string" or label=="" or typeof(cf)~="CFrame" then return end
        local key=norm(label)
        if key=="" then return end
        local entry=map[key]
        if not entry then
            entry={Name=label,CFrame=cf}
            map[key]=entry
        end
        for _,alias in ipairs(aliases or {}) do
            local aliasKey=norm(alias)
            if aliasKey~="" and not map[aliasKey] then map[aliasKey]=entry end
        end
    end
    local reference=STATE.ReferenceData
    local seaLabel="Sea "..tostring(STATE.World)
    local seaKey="Sea_"..tostring(STATE.World)
    for quest,xyz in pairs(STATE.QuestNPCs or {}) do
        if type(xyz)=="table" and xyz[1] and xyz[2] and xyz[3] then
            add(catalog.NPCPoints,"Quest NPC: "..quest,CFrame.new(xyz[1],xyz[2],xyz[3]),{quest})
        end
    end
    local meleeData=reference and reference.Melees
    for _,data in pairs(meleeData or {}) do
        if type(data)=="table" and (not data.Sea or tonumber(data.Sea)==STATE.World) then
            local cf=(data.CFrames and data.CFrames[seaKey]) or data.CFrame or data.cframe
            local npc=data.Npc or data.npc or data.Model
            if npc and cf then add(catalog.NPCPoints,tostring(npc),cf) end
        end
    end
    local bossRows=reference and reference.BossList and reference.BossList[seaKey]
    for _,row in ipairs(bossRows or {}) do
        if type(row)=="table" and row[2] and row[5] then add(catalog.NPCPoints,tostring(row[2]),row[5]) end
    end
    local islandData=reference and reference.Islands and reference.Islands[seaLabel]
    for name,cf in pairs(islandData or {}) do add(catalog.IslandPoints,tostring(name),cf) end
    local atlas=STATE.Atlas and STATE.Atlas.Regions and STATE.Atlas.Regions[STATE.World]
    for name,entry in pairs(atlas or {}) do
        local p=entry and entry.pos
        if type(p)=="table" and p[1] and p[2] and p[3] then
            add(catalog.IslandPoints,tostring(name),CFrame.new(p[1],p[2],p[3]))
        end
    end
    for _,row in ipairs((STATE.ReferenceIslandAliases or {})[STATE.World] or {}) do
        if type(row)=="table" then
            add(catalog.IslandPoints,row.Name,row.CFrame,row.Aliases)
        end
    end
    for name,cf in pairs((STATE.SubmergedTravelData and STATE.SubmergedTravelData.QuestGivers) or {}) do
        add(catalog.NPCPoints,name,cf)
    end
    catalog.BuiltAt=os.clock()
    return catalog
end
STATE.BuildTravelCatalog()
function STATE.BeginNamedTeleport(kind,name,baseCFrame,offset)
    if not Config.TeleportEnabled then
        notice("Travel","Teleport đang tắt; bật lại trong Position & movement","warn")
        return false
    end
    if typeof(baseCFrame)=="Vector3" then baseCFrame=CFrame.new(baseCFrame) end
    if typeof(baseCFrame)~="CFrame" then return false end
    local extra=tonumber(offset) or 0
    local target=baseCFrame*CFrame.new(0,extra,0)
    local _,_,root=alive()
    local distance=root and (root.Position-target.Position).Magnitude or 0
    local speed=math.max(40,tonumber(Config.TweenSpeed) or 350)
    STATE.TeleportDestination={Kind=kind,Name=tostring(name),Goal=target,Active=true,
        Started=os.clock(),LastCheck=0,Attempts=0,Timeout=math.clamp(distance/speed+6,8,60),
        Radius=math.clamp(tonumber(Config.TeleportArrivalRadius) or 8,4,30),Status="Đang tới"}
    local ok=moveTo(target)
    if not ok then
        STATE.TeleportDestination.Active=false
        STATE.TeleportDestination.Status="Không thể bắt đầu di chuyển"
    end
    return ok
end
function STATE.VerifyTeleportDestination(now)
    local destination=STATE.TeleportDestination
    if not destination or not destination.Active or not Config.TeleportEnabled then return end
    if STATE.Mover and STATE.Mover.Active then return end
    now=now or os.clock()
    if now-(destination.LastCheck or 0)<.35 then return end
    destination.LastCheck=now
    local _,_,root,ok=alive()
    if not ok or not root then return end
    local distance=(root.Position-destination.Goal.Position).Magnitude
    if distance<=destination.Radius then
        destination.Active=false;destination.Status="Đã tới "..destination.Name
        if STATE.TeleportRecovery then
            STATE.TeleportRecovery.Retries=0;STATE.TeleportRecovery.Pending=false
            STATE.TeleportRecovery.Status=destination.Status
        end
        return
    end
    if now-destination.Started<destination.Timeout then return end
    local limit=math.clamp(tonumber(Config.TeleportRetryLimit) or 3,1,6)
    if destination.Attempts>=limit then
        destination.Active=false
        destination.Status="Dừng: chưa tới đúng đích ("..math.floor(distance).." studs)"
        notice("Travel",destination.Status.." · "..destination.Name,"warn")
        return
    end
    destination.Attempts=destination.Attempts+1;destination.Started=now
    destination.Timeout=math.clamp(distance/math.max(40,tonumber(Config.TweenSpeed) or 350)+5,7,45)
    destination.Status=string.format("Đích chưa xác nhận · thử lại %d/%d",destination.Attempts,limit)
    if not STATE.QueueMoveRecovery(destination.Goal,"Manual","đích chưa xác nhận") then
        destination.Active=false
        destination.Status="Không thể tự thử lại"
    end
end
local function goNPC(name)
    if name=="" then return false end
    STATE.BuildTravelCatalog()
    local wanted=norm(name)
    local exact,fuzzy=nil,nil
    local exactDistance,fuzzyDistance=math.huge,math.huge
    local _,_,playerRoot=alive()
    local function consider(model)
        local root=STATE.TravelModelRoot(model)
        if not root then return end
        local modelName=norm(model.Name)
        local distance=playerRoot and (root.Position-playerRoot.Position).Magnitude or 0
        if modelName==wanted and distance<exactDistance then exact={CFrame=root.CFrame};exactDistance=distance
        elseif not exact and modelName:find(wanted,1,true) and distance<fuzzyDistance then
            fuzzy={CFrame=root.CFrame};fuzzyDistance=distance
        end
    end
    for _,container in ipairs({WS:FindFirstChild("NPCs"),RS:FindFirstChild("NPCs"),WS:FindFirstChild("Map"),WS:FindFirstChild("_WorldOrigin")}) do
        if container then
            for _,object in ipairs(container:GetDescendants()) do
                if object:IsA("Model") and (container.Name=="NPCs" or object:FindFirstChildOfClass("Humanoid")) then
                    consider(object)
                end
            end
        end
    end
    local chosen=exact or fuzzy
    if chosen then return STATE.BeginNamedTeleport("NPC",name,chosen.CFrame,3) end
    local static=STATE.TravelCatalog.NPCPoints[wanted]
    if static then return STATE.BeginNamedTeleport("NPC",static.Name,static.CFrame,3) end
    for key,entry in pairs(STATE.TravelCatalog.NPCPoints) do
        if key:find(wanted,1,true) then return STATE.BeginNamedTeleport("NPC",entry.Name,entry.CFrame,3) end
    end
    notice("Travel","NPC not found: "..name,"warn")
    return false
end
local function goIsland(name)
    if name=="" then return false end
    STATE.BuildTravelCatalog()
    local wanted=norm(name)
    local exact,fuzzy=nil,nil
    local exactDistance,fuzzyDistance=math.huge,math.huge
    local _,_,playerRoot=alive()
    local function consider(object)
        local cf=STATE.TravelObjectCFrame(object)
        if not cf then return end
        local objectName=norm(object.Name)
        local distance=playerRoot and (cf.Position-playerRoot.Position).Magnitude or 0
        if objectName==wanted and distance<exactDistance then exact=cf;exactDistance=distance
        elseif not exact and objectName:find(wanted,1,true) and distance<fuzzyDistance then
            fuzzy=cf;fuzzyDistance=distance
        end
    end
    for _,container in ipairs({WS:FindFirstChild("Map"),WS:FindFirstChild("_WorldOrigin")}) do
        if container then
            for _,object in ipairs(container:GetDescendants()) do
                if object:IsA("Model") or object:IsA("Folder") then consider(object) end
            end
        end
    end
    local chosen=exact or fuzzy
    if chosen then
        local offset=chosen.Position.Y<-300 and 8 or (chosen.Position.Y>3000 and 12 or 15)
        return STATE.BeginNamedTeleport("Island",name,chosen,offset)
    end
    local static=STATE.TravelCatalog.IslandPoints[wanted]
    if static then
        local offset=static.CFrame.Position.Y<-300 and 8 or (static.CFrame.Position.Y>3000 and 12 or 15)
        return STATE.BeginNamedTeleport("Island",static.Name,static.CFrame,offset)
    end
    for key,entry in pairs(STATE.TravelCatalog.IslandPoints) do
        if key:find(wanted,1,true) then
            local offset=entry.CFrame.Position.Y<-300 and 8 or (entry.CFrame.Position.Y>3000 and 12 or 15)
            return STATE.BeginNamedTeleport("Island",entry.Name,entry.CFrame,offset)
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
local function getNPCs()
    STATE.BuildTravelCatalog()
    local out=refreshOptions(WS:FindFirstChild("NPCs"));local seen={}
    for _,name in ipairs(out) do seen[norm(name)]=true end
    for _,container in ipairs({WS:FindFirstChild("NPCs"),RS:FindFirstChild("NPCs")}) do
        if container then
            for _,object in ipairs(container:GetDescendants()) do
                if object:IsA("Model") and STATE.TravelModelRoot(object) and not seen[norm(object.Name)] then
                    seen[norm(object.Name)]=true;out[#out+1]=object.Name
                end
            end
        end
    end
    for _,entry in pairs(STATE.TravelCatalog.NPCPoints) do
        if not seen[norm(entry.Name)] then seen[norm(entry.Name)]=true;out[#out+1]=entry.Name end
    end
    table.sort(out);return out
end
local function getIslands()
    STATE.BuildTravelCatalog()
    local out=refreshOptions(WS:FindFirstChild("Map"));local seen={}
    for _,name in ipairs(out) do seen[norm(name)]=true end
    for _,entry in pairs(STATE.TravelCatalog.IslandPoints) do
        if not seen[norm(entry.Name)] then seen[norm(entry.Name)]=true;out[#out+1]=entry.Name end
    end
    table.sort(out);return out
end
-- Team spawn navigator. Coordinates from the latest player_spawns capture per sea.
do
    local catalog={
        [1]={
            Marines={
                ["Colosseum"]={{-1517.44,13.03,-2709.31},{-1385.07,16.05,-2699.86}},
                ["Default"]={{-2856.46,56.01,1996.94},{-2812.83,56.01,1967.2},{-2810.74,56.01,1936.07}},
                ["Desert"]={{842.49,3.09,4196.49},{886.26,3.23,4115.46}},
                ["Fishman"]={{3857.37,5.53,-1914.47},{4004.78,9.22,-1645.77}},
                ["Fountain"]={{4983.13,6.87,3946.12},{5042.2,4.87,3888.81}},
                ["Ice"]={{977.16,7.15,-1331.31},{1010.72,15.26,-1364.17}},
                ["Jungle"]={{-1714.15,17.71,585.53},{-1630.26,29.45,495.05},{-1578.78,17.54,592.76}},
                ["Magma"]={{-5381.04,11.38,8222.2},{-5314.49,12.52,8328.84},{-5287.5,12.65,8364.52}},
                ["MarineBase"]={{-4867.05,22.14,4243.55},{-4820.75,22.14,4320.59}},
                ["Pirate"]={{-1307.33,16.96,3847.79},{-1191.07,16.96,3873.43}},
                ["Prison"]={{4855.54,7.37,747.49},{4887.95,7.37,754.09}},
                ["Sky"]={{-4891.17,924.4,-1064.88},{-4810.12,924.4,-977.13}},
                ["Sky2"]={{-6024.71,5466.15,2164.6},{-6012.07,5467.18,2054.33}},
                ["Town"]={{-1270.07,12.18,1583.53},{-1196.93,11,1873.71}},
            },
            Pirates={
                ["Colosseum"]={{-1253.7,9.22,-2940.33},{-1162.59,11.37,-2921.01}},
                ["Default"]={{1033.93,13.22,1364.49},{1081.26,13.71,1345.99},{1121.48,14.85,1357.65},{1161.01,18.11,1361.81},{1179.39,15.99,1392.54},{1199.64,14.49,1440.81}},
                ["Desert"]={{904.49,5.29,4199.41},{1042.15,6.23,4303.43},{1094.15,5.29,4192.89}},
                ["Fishman"]={{3909.04,2.19,-1928.7},{3952.22,5.24,-1667.3}},
                ["Fountain"]={{5024.8,5.49,3952.19},{5048.22,7.04,3928.82}},
                ["Ice"]={{1148.4,7.15,-1139.46},{1158.03,25.82,-1213.32}},
                ["Jungle"]={{-1299.64,16.14,428.17},{-1254.26,16.14,342.32},{-1203.05,16.14,251.29}},
                ["Magma"]={{-5219.56,12.52,8726.95},{-5203.35,10.61,8559.69}},
                ["MarineBase"]={{-4777.36,21.11,3883.65},{-4521.33,17.01,4457.04}},
                ["Pirate"]={{-1130.92,16.79,3885.05},{-1055.53,27.94,3877.96}},
                ["Prison"]={{4859.86,8.43,719.97},{5029.41,7.93,761.92}},
                ["Sky"]={{-4979,924.46,-793.45},{-4937.29,924.46,-800.24}},
                ["Sky2"]={{-5939.99,5466.76,2174.69},{-5849.07,5467.76,2133.74}},
                ["Town"]={{-734.93,8.07,1487.9},{-681.07,6.7,1686.17},{-587.9,8.04,1483.6},{-558.22,7.7,1621.92}},
            },
        },
        [2]={
            Marines={
                ["Bar"]={{-408.45,74.02,279.59},{-385.25,74.02,280.39},{-359.25,74.02,281.29}},
                ["CircleIslandFire"]={{-5515.22,32.41,-5388.78},{-5457.88,32.41,-5348.87},{-5380.71,32.41,-5320.58}},
                ["CircleIslandIce"]={{-6156.13,30.88,-5332.24},{-6127.83,29.31,-5194.02},{-6046.74,30.54,-5110.09}},
                ["Default"]={{-87.46,22.2,2827.25},{-11.26,22.2,2827.25},{59.84,22.2,2827.25}},
                ["DressTown"]={{-785.26,120.6,1243.35},{-387.26,120.6,1243.35},{13.04,120.6,1243.35}},
                ["ForgottenIsland"]={{-3059.95,239.26,-10201.76},{-3026.7,238.96,-10194.23},{-2986.38,238.66,-10191}},
                ["Graveyard"]={{-5430.73,49.06,-788.83},{-5382.49,9.55,-752.28}},
                ["Greenb"]={{-2337.99,72.41,-2627.92},{-1967.58,72.41,-2817.77},{-1929.16,55.12,-2724.85}},
                ["IceCastle"]={{5657.7,30.48,-6211.73},{5670.24,30.77,-6011.36}},
                ["Ship"]={{804.05,123.84,32974.33},{848.09,123.84,32874.57}},
                ["Snowy"]={{385.75,400.15,-5396.23},{512.72,400.25,-5294.7}},
            },
            Pirates={
                ["Bar"]={{-428.45,74.02,297.39},{-385.25,74.02,297.39},{-342.85,74.02,297.39}},
                ["CircleIslandFire"]={{-5298.85,29.32,-5234.54},{-5282.68,29.32,-5155.61},{-5210.91,29.32,-5154.34}},
                ["CircleIslandIce"]={{-5886.36,29.86,-4968.22},{-5810.41,30.54,-4883.23},{-5762.35,28.95,-4857}},
                ["Default"]={{-107.05,20.22,2834.99},{-67.05,20.22,2834.99},{42.95,20.22,2834.99},{82.95,20.22,2834.99}},
                ["DressTown"]={{-688.95,75.12,1036.79},{-443.05,76.02,1485.79},{-264.65,75.42,1063.89},{-113.55,74.02,1370.19}},
                ["ForgottenIsland"]={{-3076.56,239.26,-10199.11},{-3043.31,238.96,-10191.58},{-3003,238.66,-10188.34}},
                ["Graveyard"]={{-5491.56,49.06,-684.11},{-5392.58,9.55,-642.76}},
                ["Greenb"]={{-2470.99,72.41,-2606.92},{-2302.58,72.41,-2818.77},{-2135.61,72.41,-2758.82}},
                ["IceCastle"]={{5400.4,29.35,-6236.99},{5440.66,32.74,-6416.79}},
                ["Ship"]={{1002.56,123.84,32855.01},{1030.35,123.84,32964.81}},
                ["Snowy"]={{295.55,400.25,-5417.41},{569.46,400.15,-5284.16}},
            },
        },
        [3]={
            Marines={
                ["BigMansion"]={{-12572.93,341.78,-7488.16},{-12549.72,341.78,-7487.36},{-12523.72,341.78,-7486.46}},
                ["CandyCane"]={{-1106.08,24.66,-14232},{-1088.01,20.19,-14081.64},{-986.51,20.19,-14087.59}},
                ["Chocolate"]={{1.42,23.39,-12147.96},{147.35,23.33,-12030.55},{263.69,23.39,-12218.04}},
                ["Default"]={{-433.69,19.53,5463.81},{-388.36,19.53,5535.28},{-306,19.53,5557.35},{-219.84,19.53,5521.11}},
                ["GreatTree"]={{2124,21.56,-6925.8},{2145.76,21.56,-6801.6},{2262.59,21.56,-6462.95}},
                ["HauntedCastle"]={{-9539.01,141.18,5509.94},{-9387.11,141.18,5616.04},{-9366.8,141.18,5443.94}},
                ["Hydra1"]={{5247.01,1014.82,-34.69},{5424.21,1003.82,314.04},{5431.33,1003.82,493.66}},
                ["Hydra2"]={{3432.48,71.93,1511.24},{3527.58,56.9,1789.63},{3567.23,54.9,1927.11}},
                ["Hydra3"]={{4522.42,55.02,-1515.46},{4526.84,55.02,-1538.26},{4531.8,55.02,-1563.8}},
                ["IceCream"]={{-949.49,57.83,-10907.06},{-886.72,64.8,-11070.17},{-858.22,63.47,-10855.19}},
                ["Loaf"]={{-2106.07,36.65,-11908.52},{-1904.57,36.68,-12015.38},{-1761.69,36.68,-11878.25}},
                ["Peanut"]={{-2130.57,36.92,-10106.13},{-2061.11,36.96,-10241.8},{-1943.6,36.96,-10288.01}},
                ["PineappleTown"]={{-11343.72,333.21,-10339.65},{-11336.12,333.21,-10364.53},{-11329.34,333.21,-10386.74}},
                ["SeaCastle"]={{-5018.24,318.18,-3014.06},{-5015.21,318.18,-3004.17},{-5010.67,318.18,-2995.33}},
                ["SubmergedIsland"]={{11259.85,-2131.51,9915.93},{11285.15,-2131.51,9906.19},{11301.09,-2131.51,9900.07}},
                ["Tiki"]={{-16217.76,12.29,412.53},{-16217.76,12.29,446.07},{-16217.76,12.29,480.29}},
            },
            Pirates={
                ["BigMansion"]={{-12592.93,341.78,-7470.36},{-12549.72,341.78,-7470.36},{-12507.32,341.78,-7470.36}},
                ["CandyCane"]={{-1086.05,25.33,-14222.98},{-998.78,25.55,-14235.24},{-980.25,26.26,-14098.79}},
                ["Chocolate"]={{49.04,19.12,-12003.76},{78.02,23.39,-12118.43},{192.81,23.33,-12058.02}},
                ["Default"]={{-420.08,19.53,5486.75},{-378.27,19.53,5537.93},{-301.83,19.53,5558.42},{-231.7,19.53,5522}},
                ["GreatTree"]={{2148.34,21.27,-6652.35},{2178.69,21.27,-6904.1}},
                ["HauntedCastle"]={{-9625.31,141.18,5393.04},{-9506.11,141.18,5526.04},{-9483.5,141.18,5421.04}},
                ["Hydra1"]={{5198.75,1006.82,346.04},{5270.25,1006.82,23.67},{5404.45,1006.82,506.21}},
                ["Hydra2"]={{3436.89,56.9,1785.25},{3496.55,56.9,1873.13}},
                ["Hydra3"]={{4508.52,55.02,-1502.64},{4515.27,55.02,-1545.32},{4521.91,55.02,-1587.2}},
                ["IceCream"]={{-863.93,64.8,-11019.04},{-840.19,64.8,-10877.38},{-778.44,64.8,-10923.15}},
                ["Loaf"]={{-2145.42,36.68,-11895.08},{-1937.62,36.68,-11923.75},{-1794.7,36.68,-11938.1}},
                ["Peanut"]={{-2158.17,36.96,-10193.24},{-2062.68,36.96,-10287.75},{-2025.79,36.96,-10400.82}},
                ["PineappleTown"]={{-11363.52,333.42,-10327.97},{-11352.54,333.42,-10368.93},{-11341.36,333.42,-10410.66}},
                ["SeaCastle"]={{-5005.3,318.18,-3025.01},{-4999.45,318.18,-3010.54},{-4993.76,318.18,-2996.45}},
                ["SubmergedIsland"]={{11309.12,-2135.34,9706.63},{11320.24,-2135.34,9725.91},{11332.34,-2135.34,9746.85}},
                ["Tiki"]={{-16228.08,12.36,412.53},{-16228.08,12.36,446.07},{-16228.08,12.36,480.29}},
            },
        },
    }
    local nearest="Gần nhất"
    function STATE.SpawnChoices()
        local sea=catalog[STATE.World]
        local team=LP.Team and LP.Team.Name
        local names={}
        for name in pairs(sea and sea[team] or {}) do table.insert(names,name) end
        table.sort(names)
        table.insert(names,1,nearest)
        return names
    end
    function STATE.ResolvePlayerSpawn(choice)
        local _,_,root,valid=alive()
        if not valid then return nil,"Đang chờ nhân vật" end
        local sea=catalog[STATE.World]
        local team=LP.Team and LP.Team.Name
        local areas=sea and sea[team]
        if not areas then return nil,"Chưa xác định Sea hoặc phe" end
        if choice~=nearest and not areas[choice] then return nil,"Chọn lại điểm cho Sea và phe hiện tại" end
        local origin=WS:FindFirstChild("_WorldOrigin")
        local spawns=origin and origin:FindFirstChild("PlayerSpawns")
        local folder=spawns and spawns:FindFirstChild(team)
        local best,dist=nil,math.huge
        local function consider(pos,name,source)
            local gap=(pos-root.Position).Magnitude
            if gap<dist then
                best={Position=pos,Name=name,Source=source,Distance=gap}
                dist=gap
            end
        end
        for name,positions in pairs(areas) do
            if choice==nearest or choice==name then
                local group=folder and folder:FindFirstChild(name)
                local live=false
                if group then
                    for _,part in ipairs(group:GetChildren()) do
                        if part.Name=="Part" and part:IsA("BasePart") then
                            live=true
                            consider(part.Position,name,"Live")
                        end
                    end
                end
                if not live then
                    for _,xyz in ipairs(positions) do
                        consider(Vector3.new(xyz[1],xyz[2],xyz[3]),name,"Atlas 07/11")
                    end
                end
            end
        end
        return best
    end
end
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
--[[
  andepzai V24 / DIAGNOSTICS AND SELF-CHECK
  Read-only inspection of the live client; does not simulate server responses.
]]
do
    local D={Issues={},Checks={},Events={},LastCheck=0,LastExport=0,
        LastTarget=nil,TargetSwitches=0,LastMode="",LastMovementStatus="",
        ConsecutiveNoTarget=0,LastEmptyCheck=0,LastDeathAt=0,
        LogEntries=0,LastStatus="No tests run"}
    STATE.FarmAudit=D
    local function record(kind,message)
        D.Events[#D.Events+1]={At=os.clock(),Kind=kind,Message=tostring(message)}
        while #D.Events>100 do table.remove(D.Events,1) end
        D.LogEntries=D.LogEntries+1
    end
    local function check(label,passed,reason)
        D.Checks[label]={OK=passed==true,Detail=tostring(reason or "")}
        if not passed then D.Issues[#D.Issues+1]=label..": "..tostring(reason) end
    end
    local function readableTool()
        local char=LP.Character
        local equipped=char and char:FindFirstChildOfClass("Tool")
        local bag=LP:FindFirstChildOfClass("Backpack")
        local inventory=0
        if bag then
            for _,t in ipairs(bag:GetChildren()) do
                if t:IsA("Tool") then inventory=inventory+1 end
            end
        end
        return equipped,inventory
    end
    function D.RunChecks()
        D.Issues={};D.Checks={};D.LastCheck=os.clock()
        local char,hum,root,ready=alive()
        check("Game loaded",game:IsLoaded(),"Game:IsLoaded() must be true")
        check("Sea recognized",STATE.World>=1 and STATE.World<=3,
            "PlaceId="..tostring(game.PlaceId))
        check("Player character",ready,ready and "Humanoid and root exist" or "Respawning or missing root")
        local equipped,inventory=readableTool()
        check("Weapon available",equipped~=nil or inventory>0,
            "Equipped="..tostring(equipped and equipped.Name or "None").." / Backpack tools="..inventory)
        check("Weapon selection",not Config.AutoEquip or Config.Weapon~=nil,
            "Selected weapon="..tostring(Config.Weapon))
        local remotes=getCombatRemotes()
        check("RegisterAttack",remotes and remotes.Attack and remotes.Attack:IsA("RemoteEvent"),
            "Only replicated event presence is verifiable")
        check("RegisterHit",remotes and remotes.Hit and remotes.Hit:IsA("RemoteEvent"),
            "Server validation logic is unavailable")
        check("Enemies folder",enemyFolder()~=nil,"Workspace.Enemies must be loaded")
        local total,live,dead=0,0,0
        local folder=enemyFolder()
        if folder then
            for _,model in ipairs(folder:GetChildren()) do
                if model:IsA("Model") then
                    total=total+1
                    if STATE.IsAliveNPC(model) then live=live+1 else dead=dead+1 end
                end
            end
        end
        check("NPC visibility",total>0,"Loaded="..total..", alive="..live..", dead/stale="..dead)
        local atlas=STATE.Atlas and STATE.Atlas.Spawns[STATE.World]
        local types,points=0,0
        for _,samples in pairs(atlas or {}) do types=types+1;points=points+#samples end
        check("Scanned Atlas",types>0,"Sea="..STATE.World..", spawn types="..types..", points="..points)
        local q=questInfo()
        check("Level quest route",q~=nil,"Level="..tostring(level()).." mob="..tostring(q and q.Mob))
        check("Combat enabled",Config.Combat,"Combat must be ON when Farm is ON")
        check("Combat scheduler",Config.CombatScheduler,"V24 uses a separate attack cadence")
        check("Fast Attack enabled",Config.FastAttackEnabled,"Fast attack should be ON for overhead Farm")
        check("Overhead hit range",Config.FarmStyle~="Above" or
            (tonumber(Config.AttackRange) or 0)>(tonumber(Config.FarmHeight) or 18),
            "AttackRange="..Config.AttackRange.." / Height="..Config.FarmHeight)
        if STATE.MobMagnet then
            check("Magnet server constraints",STATE.MobMagnet.Rejections==0,
                "Corrections="..tostring(STATE.MobMagnet.Rejections).." (client movement may not replicate)")
        end
        local fails=0
        for _,entry in pairs(D.Checks) do if not entry.OK then fails=fails+1 end end
        local size=0
        for _ in pairs(D.Checks) do size=size+1 end
        D.LastStatus=string.format("Checks: %d pass / %d needs attention",size-fails,fails)
        record("self-test",D.LastStatus)
        return size-fails,fails
    end
    function D.Tick()
        if not STATE.Alive then return end
        if not Config.FarmEnabled then
            D.ConsecutiveNoTarget=0;D.LastTarget=nil;return
        end
        if D.LastMode~=Config.FarmMode then
            D.LastMode=Config.FarmMode
            record("mode","Farm mode = "..tostring(Config.FarmMode))
        end
        local mob=STATE.NPCFilter and STATE.NPCFilter.Held
        if D.LastTarget~=mob then
            D.TargetSwitches=D.TargetSwitches+1
            if D.LastTarget and not STATE.IsAliveNPC(D.LastTarget) then
                D.LastDeathAt=os.clock()
            end
            D.LastTarget=mob
            record("target",mob and mob.Name or "None")
        end
        if mob then
            D.ConsecutiveNoTarget=0
        else
            D.ConsecutiveNoTarget=D.ConsecutiveNoTarget+1
            if D.ConsecutiveNoTarget>=15 and os.clock()-D.LastEmptyCheck>18 then
                D.LastEmptyCheck=os.clock()
                record("empty","No live target at current route; check NPC streaming/quest state")
            end
        end
        if STATE.MoveStats and STATE.MoveStats.LastError~=D.LastMovementStatus then
            D.LastMovementStatus=STATE.MoveStats.LastError
            if D.LastMovementStatus~="None" then
                record("movement",D.LastMovementStatus)
            end
        end
    end
    function D.Snapshot()
        local combat=STATE.FastAttackDirector
        local route=STATE.RouteDirector
        local magnet=STATE.MobMagnet
        return {
            version="38.9",sea=STATE.World,place_id=game.PlaceId,
            level=level(),farm_mode=Config.FarmMode,farm_active=Config.FarmEnabled,
            status=D.LastStatus,checks=D.Checks,issues=D.Issues,
            events=D.Events,target_switches=D.TargetSwitches,
            combat=combat and combat.Snapshot() or nil,
            atlas_route=route and route.Snapshot() or nil,
            magnet=magnet and {active=magnet.Active,local_moves=magnet.LocalMoves,
                server_corrections=magnet.Rejections,denied=magnet.SkippedOwner,
                last_error=magnet.LastError} or nil,
            movement=STATE.MoveStats and {status=STATE.MoveStats.Status,
                requested_speed=STATE.MoveStats.RequestedSpeed,
                server_corrections=STATE.MoveStats.Corrections,
                stalled=STATE.MoveStats.Stalled} or nil,
            evidence="Self-test is local static/runtime observation, not a Roblox server test",
        }
    end
    function D.Export()
        if not canFile("writefile") then return false,"writefile unavailable" end
        local filename=FOLDER.."/andepzai_v24_Sea"..STATE.World.."_diagnostics.json"
        local ok,err=pcall(function()
            if canFile("makefolder") and canFile("isfolder") and not api("isfolder")(FOLDER) then
                api("makefolder")(FOLDER)
            end
            api("writefile")(filename,Http:JSONEncode(D.Snapshot()))
        end)
        if ok then D.LastExport=os.clock();return true,filename end
        return false,tostring(err)
    end
end

--[[ andepzai V25 / Source-backed feature implementations.
  Auto Fish Slap from user snippet (Gui AbsolutePosition/GreenZone/Tick).
  Zioles Gacha uses user-provided GachaClient.CheckGachaAsync / GachaNetworkRF.
  Cake Portal uses user-provided CakePrinceSpawner check; only explicitly toggled.
  No HTTP, webhook, loader, key or telemetry leaves the game.
]]
do
    local F={Slap={Attempts=0,Activated=0,Last="Standby",LastAt=0,Inside=false},
        Gacha={Attempts=0,Purchases=0,Last="Standby",LastAt=0,Cost=0},
        Cake={Checks=0,Opened=0,Last="Standby",LastAt=0,LastMove=0}}
    STATE.BonusFeatures=F
    local function pgui()
        return LP:FindFirstChildOfClass("PlayerGui")
    end
    local function isVisibleGui(gui)
        if not gui or not gui.Parent then return false end
        if gui:IsA("ScreenGui") then return gui.Enabled end
        if gui:IsA("GuiObject") then return gui.Visible end
        return true
    end
    function F.TickFishSlap()
        if not (STATE.Alive and Config.AutoFishSlap) then
            F.Slap.Inside=false;return
        end
        local pg=pgui()
        local minigame=pg and pg:FindFirstChild("FishSlapMinigame")
        if not isVisibleGui(minigame) then
            F.Slap.Last="FishSlapMinigame not visible";F.Slap.Inside=false;return
        end
        local bar=minigame:FindFirstChild("Bar",true)
        local green=bar and bar:FindFirstChild("GreenZone")
        local tick=bar and bar:FindFirstChild("Tick")
        local slap=minigame:FindFirstChild("SlapButton",true)
        if not (green and tick and slap and slap:IsA("GuiButton")
            and green:IsA("GuiObject") and tick:IsA("GuiObject")) then
            F.Slap.Last="Missing minigame Bar/GreenZone/Tick/SlapButton";return
        end
        local sz=green.AbsoluteSize
        if sz.Y<=0 or tick.AbsoluteSize.Y<=0 then return end
        local inset=sz.Y*.10
        local top=green.AbsolutePosition.Y+inset
        local bottom=green.AbsolutePosition.Y+sz.Y-inset
        local center=tick.AbsolutePosition.Y+tick.AbsoluteSize.Y*.5
        local inside=center>=top and center<=bottom
        if inside and (not F.Slap.Inside or os.clock()-F.Slap.LastAt>1.3) then
            F.Slap.LastAt=os.clock();F.Slap.Attempts=F.Slap.Attempts+1
            local signal=api("firesignal")
            if type(signal)~="function" then
                F.Slap.Last="Executor has no firesignal; cannot press Slap safely"
                F.Slap.Inside=true;return
            end
            local ok,err=pcall(signal,slap.Activated)
            if ok then
                F.Slap.Activated=F.Slap.Activated+1
                F.Slap.Last="Slap event dispatched (game outcome unverified)"
            else F.Slap.Last="Slap activation failed: "..tostring(err) end
        end
        F.Slap.Inside=inside
    end
    function F.TickGacha()
        if not (STATE.Alive and Config.AutoGachaZioles) then return end
        local t=os.clock()
        local cooldown=math.clamp(tonumber(Config.GachaCooldown) or 600,180,3600)
        if t-F.Gacha.LastAt<cooldown then return end
        F.Gacha.LastAt=t;F.Gacha.Attempts=F.Gacha.Attempts+1
        if Config.FarmEnabled then F.Gacha.Last="Paused during Farm";return end
        local controllers=RS:FindFirstChild("Controllers")
        local gachaScript=controllers and controllers:FindFirstChild("GachaClient")
        if not (gachaScript and gachaScript:IsA("ModuleScript")) then
            F.Gacha.Last="GachaClient unavailable";return
        end
        local okModule,gacha=pcall(require,gachaScript)
        if not okModule or type(gacha)~="table" then
            F.Gacha.Last="Cannot inspect GachaClient";return
        end
        local ok,data=pcall(function()
            return gacha.CheckGachaAsync("ZiolesGacha","Blox Fruit Gacha")
        end)
        if not ok or type(data)~="table" then
            F.Gacha.Last="Gacha check failed";return
        end
        if type(data.Level)=="table" and data.Level.RequirementMet==false then
            F.Gacha.Last="Gacha level requirement not met";return
        end
        local price=tonumber(type(data.Price)=="table" and data.Price.Value or data.Price)
        if not price or price<0 then F.Gacha.Last="Gacha price unknown";return end
        local maxPrice=math.clamp(tonumber(Config.GachaMaxPrice) or 300000,1000,1000000)
        if price>maxPrice then
            F.Gacha.Last="Price "..math.floor(price).." exceeds max "..math.floor(maxPrice);return
        end
        local wallet=tonumber(value("Beli")) or 0
        if wallet<price then F.Gacha.Last="Insufficient Beli";return end
        local net=RS:FindFirstChild("Modules")
        net=net and net:FindFirstChild("Net")
        local rf=net and net:FindFirstChild("RF/GachaNetworkRF")
        if not rf or not rf:IsA("RemoteFunction") then
            F.Gacha.Last="RF/GachaNetworkRF not replicated";return
        end
        local success,result=pcall(function()
            return rf:InvokeServer({Context="Purchase",BoxName="ZiolesGacha"})
        end)
        F.Gacha.Cost=price
        if success and result~=false then
            F.Gacha.Purchases=F.Gacha.Purchases+1
            F.Gacha.Last="Purchase request sent; check inventory and Beli"
        else
            F.Gacha.Last="Purchase rejected: "..tostring(result)
        end
    end
    local function locateCakeNPC()
        -- Streaming may make the NPC invisible; search known replicated containers only.
        for _,container in ipairs({WS:FindFirstChild("NPCs"),WS:FindFirstChild("Map"),RS:FindFirstChild("NPCs")}) do
            if container then
                for _,instance in ipairs(container:GetDescendants()) do
                    if instance.Name:lower():find("drip_mama",1,true) then
                        if instance:IsA("BasePart") then return instance end
                        if instance:IsA("Model") then
                            local part=instance.PrimaryPart or instance:FindFirstChildWhichIsA("BasePart",true)
                            if part then return part end
                        end
                    end
                end
            end
        end
    end
    function F.TickCake()
        if not (STATE.Alive and Config.AutoCakePortal and STATE.World==3) then return end
        if os.clock()-F.Cake.LastAt<math.max(12,tonumber(Config.CakeCheckDelay) or 25) then return end
        F.Cake.LastAt=os.clock();F.Cake.Checks=F.Cake.Checks+1
        if Config.FarmEnabled then F.Cake.Last="Paused while Farm active";return end
        if Config.CakeTravelToNPC then
            local npc=locateCakeNPC()
            local _,_,root,ready=alive()
            if ready and npc and (root.Position-npc.Position).Magnitude>45 then
                if os.clock()-F.Cake.LastMove>15 then
                    F.Cake.LastMove=os.clock()
                    moveTo(npc.CFrame*CFrame.new(0,5,0))
                end
                F.Cake.Last="Moving toward visible drip_mama NPC";return
            end
        end
        local remotes=RS:FindFirstChild("Remotes")
        local comm=remotes and remotes:FindFirstChild("CommF_")
        if not comm or not comm:IsA("RemoteFunction") then
            F.Cake.Last="CommF_ unavailable";return
        end
        local ok,status=pcall(function() return comm:InvokeServer("CakePrinceSpawner") end)
        if not ok then F.Cake.Last="Cake portal status request failed";return end
        local output=type(status)=="string" and status:lower() or ""
        if output:find("open the portal now",1,true) then
            local accepted,response=pcall(function() return comm:InvokeServer("CakePrinceSpawner",true) end)
            if accepted and response~=false then
                F.Cake.Opened=F.Cake.Opened+1
                F.Cake.Last="Cake portal open requested; game outcome unverified"
            else F.Cake.Last="Cake portal request rejected: "..tostring(response) end
        else
            F.Cake.Last="Portal not ready: "..tostring(status):sub(1,110)
        end
    end
    function F.Snapshot()
        return {fish_slap=F.Slap,gacha=F.Gacha,cake_portal=F.Cake,
            source="User code snippets + DynamicIsland/Banana; game acceptance unverified"}
    end
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
-- // v27 Auto Trick Or Treat based on the supplied Topi Halloween source.
--     Real-world event timing and door state are observed, never invented.
do
    local T={Active=false,Status="Off",Door=nil,DoorsFound=0,Visits=0,Prompts=0,
        DialogueClicks=0,Failures=0,ChosenAt=0,Side=1,LastE=0,LastClick=0,
        SeenDialogue=false,DoorScanAt=0,CachedDoors={},Skip=setmetatable({},{__mode="k"}),
        Shown=setmetatable({},{__mode="k"}),BusyAt=0,LastError="None",
        GhostVisited=setmetatable({},{__mode="k"}),GhostStart=0,GhostSkipUntil=0,
        SceneOrigin=nil,SceneDoor=nil,SceneSince=0,SceneRetries=0,SceneFightAt=0}
    STATE.TrickTreat=T
    local PPS=game:GetService("ProximityPromptService")
    on(PPS,PPS.PromptShown,function(prompt) T.Shown[prompt]=true end)
    on(PPS,PPS.PromptHidden,function(prompt) T.Shown[prompt]=nil end)
    local pg=LP:FindFirstChild("PlayerGui")
    local function watchLabel(obj)
        if not obj:IsA("TextLabel") then return end
        local function update()
            local txt=tostring(obj.Text or ""):lower()
            if txt:find("still busy with another door",1,true) or
               txt:find("nobody is home",1,true) then T.BusyAt=os.clock() end
        end
        update()
        on(obj,obj:GetPropertyChangedSignal("Text"),update)
    end
    if pg then on(pg,pg.DescendantAdded,watchLabel) end
    local function pivot(obj)
        if not (obj and obj.Parent) then return nil end
        if obj:IsA("BasePart") then return obj.CFrame end
        if obj:IsA("Model") then
            local ok,cf=pcall(function() return obj:GetPivot() end)
            if ok then return cf end
        end
        return nil
    end
    local function collectDoors()
        local now=os.clock()
        if now-T.DoorScanAt<6 then return T.CachedDoors end
        T.DoorScanAt=now
        local map=WS:FindFirstChild("Map");local out={};local seen={}
        if not map then T.CachedDoors={};T.DoorsFound=0;return out end
        local function addDoor(o)
            if o and not seen[o] and o.Name=="HalloweenDoor" and
                (o:IsA("Model") or o:IsA("BasePart")) then
                seen[o]=true;table.insert(out,o)
            end
        end
        for _,island in ipairs(map:GetChildren()) do
            local decor=island:FindFirstChild("HalloweenDecor")
            if decor then
                for _,o in ipairs(decor:GetDescendants()) do addDoor(o) end
            end
        end
        for _,names in ipairs({{"Turtle","IslandModel","HalloweenHotel"},
                               {"Dressrosa","Dressrosa"}}) do
            local node=map
            for _,n in ipairs(names) do node=node and node:FindFirstChild(n) end
            if node then
                for _,o in ipairs(node:GetDescendants()) do addDoor(o) end
            end
        end
        -- Client streaming may place HalloweenDoor in other island folders.
        if #out==0 and now-(T.DeepScanAt or 0)>20 then
            T.DeepScanAt=now
            for _,o in ipairs(map:GetDescendants()) do addDoor(o) end
        end
        T.CachedDoors=out;T.DoorsFound=#out
        return out
    end
    local function findPrompt(door)
        if not (door and door.Parent) then return nil end
        local sc=door:FindFirstChild("SceneWindow",true)
        local first=sc and sc:FindFirstChildWhichIsA("ProximityPrompt",true)
        if first and first.Enabled then return first,sc end
        local prompt=door:FindFirstChildWhichIsA("ProximityPrompt",true)
        if prompt and prompt.Enabled then return prompt,door end
        return nil,nil
    end
    local function getDialogueOption()
        local pgui=LP:FindFirstChild("PlayerGui")
        local dg=pgui and pgui:FindFirstChild("DialogueGui")
        if not dg or (dg:IsA("ScreenGui") and not dg.Enabled) then return nil end
        for _,o in ipairs(dg:GetDescendants()) do
            if o:IsA("GuiButton") and o.Visible and
                o.AbsoluteSize.X>0 and o.AbsoluteSize.Y>0 and
                o.Name:lower():find("option1",1,true) then return o end
        end
        return nil
    end
    local function standFor(cf,side)
        local dirs={cf.LookVector,-cf.LookVector,cf.RightVector,-cf.RightVector}
        local dir=dirs[math.clamp(side,1,4)]
        local flat=Vector3.new(dir.X,0,dir.Z)
        if flat.Magnitude<.05 then flat=Vector3.new(0,0,1) end
        return CFrame.lookAt(cf.Position+flat.Unit*3.5,cf.Position)
    end
    local function chooseDoor(root)
        local now=os.clock();local best,dist=nil,math.huge
        for _,door in ipairs(collectDoors()) do
            if door.Parent and (T.Skip[door] or 0)<now then
                local prompt,subject=findPrompt(door)
                local cf=pivot(subject or door)
                if cf and prompt then
                    local d=(root.Position-cf.Position).Magnitude
                    if d<dist then best=door;dist=d end
                end
            end
        end
        -- A SceneWindow indicates the special boss encounter: prioritize while loaded.
        if Config.HalloweenSceneFight then
            for _,door in ipairs(collectDoors()) do
                local sw=door:FindFirstChild("SceneWindow",true)
                local prompt=sw and sw:FindFirstChildWhichIsA("ProximityPrompt",true)
                if sw and prompt and prompt.Enabled and (T.Skip[door] or 0)<now then
                    return door
                end
            end
        end
        return best
    end
    local function attemptPrompt(prompt)
        local now=os.clock()
        if now-T.LastE<1.35 then return end
        T.LastE=now
        local fire=api("fireproximityprompt")
        if type(fire)=="function" then
            local ok=pcall(fire,prompt)
            if ok then T.Prompts=T.Prompts+1;return end
        end
        local vim=game:GetService("VirtualInputManager")
        local ok=pcall(function()
            vim:SendKeyEvent(true,Enum.KeyCode.E,false,game)
            task.delay(math.max(.12,prompt.HoldDuration+.07),function()
                pcall(function() vim:SendKeyEvent(false,Enum.KeyCode.E,false,game) end)
            end)
        end)
        if ok then T.Prompts=T.Prompts+1 else T.LastError="No prompt input support" end
    end
    local function clickDialogue(button)
        if os.clock()-T.LastClick<.8 then return end
        T.LastClick=os.clock()
        local fire=api("firesignal")
        if type(fire)=="function" then
            local ok=pcall(fire,button.Activated)
            if ok then T.DialogueClicks=T.DialogueClicks+1;return end
        end
        local vim=game:GetService("VirtualInputManager")
        local pos=button.AbsolutePosition+button.AbsoluteSize/2
        local screen=button:FindFirstAncestorWhichIsA("ScreenGui")
        if screen and not screen.IgnoreGuiInset then
            pcall(function() pos=pos+GuiService:GetGuiInset() end)
        end
        local ok=pcall(function()
            vim:SendMouseButtonEvent(pos.X,pos.Y,0,true,game,1)
            vim:SendMouseButtonEvent(pos.X,pos.Y,0,false,game,1)
        end)
        if ok then T.DialogueClicks=T.DialogueClicks+1 else T.LastError="No dialogue click support" end
    end
    function T.Stop()
        T.Active=false;T.Door=nil;T.ChosenAt=0;T.SeenDialogue=false
        T.Side=1;T.LastError="None";T.SceneDoor=nil;T.SceneOrigin=nil
        T.Status=Config.AutoTrickOrTreat and "Waiting for event doors" or "Off"
        if STATE.MovementLock and STATE.MovementLock.Name=="Halloween doors" then cancelMove() end
    end
    function T.Tick()
        if not Config.AutoTrickOrTreat then
            if T.Active or T.Door then T.Stop() end
            return
        end
        if Config.TrickTreatWindowOnly and (tonumber(os.date("%M")) or 99)>=10 then
            T.Stop();T.Status="Waiting for event time (minute 00–09)";return
        end
        local _,hum,root,aliveNow=alive()
        if not aliveNow or not root then T.Stop();T.Status="Character unavailable";return end
        if Config.FarmEnabled and Config.FarmMode=="Halloween" then
            local enemies=WS:FindFirstChild("Enemies")
            if enemies then
                for _,npc in ipairs(enemies:GetChildren()) do
                    if STATE.IsHalloweenEnemy(npc.Name) and STATE.IsAliveNPC(npc) then
                        local rp=npc:FindFirstChild("HumanoidRootPart")
                        if rp and (root.Position-rp.Position).Magnitude<165 then
                            if STATE.MovementLock and STATE.MovementLock.Name=="Halloween doors" then cancelMove() end
                            T.Active=false
                            T.Status="Halloween enemy nearby; Farm has movement priority"
                            return
                        end
                    end
                end
            end
        end
        local map=WS:FindFirstChild("Map")
        local realm=map and map:FindFirstChild("HellfireBossRealm")
        if realm then
            local inside=false
            pcall(function()
                local cf,size=realm:GetBoundingBox()
                local localPos=cf:PointToObjectSpace(root.Position)
                inside=math.abs(localPos.X)<size.X/2+16 and
                    math.abs(localPos.Y)<size.Y/2+65 and math.abs(localPos.Z)<size.Z/2+16
            end)
            if inside then
                T.Active=true;T.Status="Hellfire Realm: tìm quái sự kiện"
                local mob=enemySearch(function(n) return STATE.IsHalloweenEnemy(n.Name) or
                    n.Name:find("Hellfire",1,true)~=nil end,false,true)
                if mob and Config.HalloweenSceneFight then
                    T.Status="Đánh quái trong Hellfire Realm: "..mob.Name
                    engage(mob)
                else
                    if STATE.MovementLock and STATE.MovementLock.Name=="Halloween doors" then cancelMove() end
                    T.Status="Trong Hellfire Realm, chờ quái xuất hiện"
                end
                return
            end
        end
        -- Source Topi: GhostChase has movement priority over knocking doors.
        if Config.HalloweenGhostChase and os.clock()>T.GhostSkipUntil then
            local ghost=WS:FindFirstChild("GhostChase")
            if ghost and #ghost:GetChildren()>0 then
                T.GhostStart=T.GhostStart>0 and T.GhostStart or os.clock()
                if os.clock()-T.GhostStart>120 then
                    T.GhostSkipUntil=os.clock()+30;T.GhostStart=0
                    T.Status="GhostChase timeout, thử cửa khác 30 giây"
                else
                    local best,distance=nil,math.huge
                    for _,obj in ipairs(ghost:GetChildren()) do
                        if (obj:IsA("Model") or obj:IsA("BasePart")) and not T.GhostVisited[obj] then
                            local cf=pivot(obj)
                            if cf then
                                local d=(root.Position-cf.Position).Magnitude
                                if d<distance then best,distance=obj,d end
                            end
                        end
                    end
                    if not best then
                        T.GhostVisited=setmetatable({},{__mode="k"})
                    else
                        local cf=pivot(best)
                        if cf then
                            T.Active=true
                            T.Status=string.format("GhostChase: %s · %.0f studs",best.Name,distance)
                            if distance>8 then moveTo(cf) else T.GhostVisited[best]=true end
                            return
                        end
                    end
                end
            else
                T.GhostStart=0
                T.GhostVisited=setmetatable({},{__mode="k"})
            end
        end
        local door=T.Door
        if door and (not door.Parent or (T.Skip[door] or 0)>os.clock()) then
            door=nil;T.Door=nil
        end
        if not door then
            door=chooseDoor(root)
            if not door then
                T.Stop();T.Status=string.format("No actionable HalloweenDoor loaded (seen %d)",T.DoorsFound)
                return
            end
            T.Door=door;T.ChosenAt=os.clock();T.LastSideAt=os.clock()
            T.Side=1;T.SeenDialogue=false;T.DialogueGoneAt=nil
        end
        T.Active=true
        local prompt,target=findPrompt(door)
        local scene=door:FindFirstChild("SceneWindow",true)
        if scene and Config.HalloweenSceneFight then
            if T.SceneDoor~=door then
                T.SceneDoor=door;T.SceneOrigin=root.Position
                T.SceneSince=os.clock();T.SceneRetries=0
            end
            if T.SceneOrigin and (root.Position-T.SceneOrigin).Magnitude>500 then
                local mob=enemySearch(function(n) return STATE.IsHalloweenEnemy(n.Name) or
                    n.Name:find("Hellfire",1,true)~=nil end,false,true)
                if mob then T.Status="Scene teleported: fighting "..mob.Name;engage(mob)
                else T.Status="Scene teleported: waiting for boss" end
                return
            end
            local blocker=enemySearch("Hellfire Gas",false,true)
            if blocker then T.Status="Scene gateway: Hellfire Gas";engage(blocker);return end
            if os.clock()-T.SceneSince>28 then
                T.SceneRetries=T.SceneRetries+1;T.SceneSince=os.clock()
                T.Skip[door]=os.clock()+math.min(120,20*T.SceneRetries)
                T.Stop();T.Status="SceneWindow timeout; trying another door"
                return
            end
            T.Status="SceneWindow: approaching portal / dialogue"
        end
        local cf=pivot(target or door)
        if not cf then
            T.Skip[door]=os.clock()+25;T.Stop();return
        end
        local dialogue=getDialogueOption()
        if dialogue then
            T.SeenDialogue=true;T.DialogueGoneAt=nil
            T.Status="Dialogue visible: selecting option1"
            clickDialogue(dialogue)
            return
        elseif T.SeenDialogue then
            T.DialogueGoneAt=T.DialogueGoneAt or os.clock()
            if os.clock()-T.DialogueGoneAt>1.8 then
                T.Visits=T.Visits+1;T.Skip[door]=os.clock()+
                    math.max(30,tonumber(Config.TrickTreatRevisit) or 100)
                T.Stop()
                return
            end
        end
        local goal=standFor(cf,T.Side)
        local delta=(root.Position-goal.Position).Magnitude
        if delta>7 then
            T.Status=string.format("Going to %s / %.0f studs / door %d",door.Name,delta,T.Side)
            moveTo(goal)
        else
            T.Status="At door; waiting for E prompt / dialogue"
            if prompt and prompt.Enabled then
                if T.BusyAt>=T.ChosenAt then
                    T.Skip[door]=os.clock()+45;T.Stop();return
                end
                local distanceToPrompt=prompt.Parent and prompt.Parent:IsA("BasePart") and
                    (prompt.Parent.Position-root.Position).Magnitude or delta
                if distanceToPrompt <= math.max(6,prompt.MaxActivationDistance+1) then
                    attemptPrompt(prompt)
                end
            end
        end
        if os.clock()-(T.LastSideAt or 0)>4.5 then
            T.Side=T.Side+1;T.LastSideAt=os.clock()
            if T.Side>4 or os.clock()-T.ChosenAt>24 then
                T.Failures=T.Failures+1;T.Skip[door]=os.clock()+
                    math.max(30,tonumber(Config.TrickTreatRevisit) or 100)
                T.Stop()
            end
        end
    end
    startLoop("Halloween doors",.28,function() T.Tick() end)
end

startLoop("Farm engine",.16,function()
    if STATE.TrickTreat and STATE.TrickTreat.Active then return end
    if not Config.FarmEnabled then return end
    if STATE.ResetTeleport and STATE.ResetTeleport.Busy then return end
    if STATE.World==0 then return end
    local _,h,_,ok=alive();if not ok then return end
    if Config.LowHealth>0 and h.MaxHealth>0 and h.Health/h.MaxHealth*100<Config.LowHealth then
        cancelMove();STATE.ReleaseFarmHover();return
    end
    if STATE.WorldProgressionTick() then return end
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
        if STATE.RouteDirector then STATE.RouteDirector.EnemyFound(target.Name,target) end
        engage(target) -- engage() automatically operates the magnet
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
-- Combat runs at a separate cadence; sending is still rate-limited by
-- Config.FastAttackInterval, not by 0.04 seconds and not by Tween updates.
startLoop("Fast attack director",.02,function()
    if STATE.FastAttackDirector then STATE.FastAttackDirector.Tick() end
end)
startLoop("Fish Slap V25",.06,function() STATE.BonusFeatures.TickFishSlap() end)
startLoop("Zioles Gacha V25",2,function() STATE.BonusFeatures.TickGacha() end)
startLoop("Cake Portal V25",3,function() STATE.BonusFeatures.TickCake() end)
startLoop("Farm audit",.8,function()
    if STATE.FarmAudit then STATE.FarmAudit.Tick() end
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
    if Config.AutoBuyChip and not Config.AutoRaid then throttle("buyraid",30,selectRaid) end
    -- Auto Raid v34 owns chip/summon/combat/advance as one director.
    if Config.AutoAdvanceRaid and not Config.AutoRaid and
        STATE.RaidDirector and STATE.RaidDirector.Owned then raidIsland() end
end)
startLoop("Raid combat",.6,function()
    if not Config.AutoRaidCombat or Config.AutoRaid or Config.FarmEnabled or Config.AutoSea then return end
    -- Only allow legacy raid combat after the v37 owner-verified session starts.
    -- Never search all workspace.Enemies and follow another party's raid.
    local director=STATE.RaidDirector
    if not (director and director.Owned) then return end
    local mob=director.GetTarget and director.GetTarget()
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
-- Read-only event inventory view. A missing entry or missing amount is unknown,
-- not zero; do not spend materials, invoke Witch, or roll gacha from this panel.
function STATE.Halloween2026.ParseInventory(inventory)
    if type(inventory)~="table" then return nil end
    local result={}
    local keys={pumpkinbits="Bits",cursedpumpkinseed="Seeds",
        cursedpumpkinseeds="Seeds",candycorn="Candy",spookytokens="Candy",spookytoken="Candy"}
    for key,row in pairs(inventory) do
        local label,amount
        if type(row)=="table" then
            label=row.Name or row.ItemName or row.ItemId or (type(key)=="string" and key)
            amount=row.Count or row.Amount or row.Quantity
        elseif type(key)=="string" and type(row)=="number" then
            label=key;amount=row
        end
        local name=label and tostring(label):lower():gsub("[^%w]","") or ""
        local field=keys[name]
        local count=tonumber(amount)
        if field and count and count>=0 then
            result[field]=math.max(result[field] or 0,math.floor(count))
        end
    end
    return result
end
function STATE.Halloween2026.Window(epoch)
    local seconds=math.floor(tonumber(epoch) or os.time())%3600
    if seconds<600 then return true,600-seconds end
    return false,3600-seconds
end
function STATE.Halloween2026.RefreshMaterials()
    local H=STATE.Halloween2026
    if H.Busy then return false,"Đang đọc kho" end
    local now=os.clock()
    if now-H.LastInventory<5 then return false,"Chờ vài giây trước khi kiểm tra lại" end
    H.LastInventory=now;H.Busy=true;H.Generation=H.Generation+1
    local generation=H.Generation
    H.MaterialStatus="Đang đọc kho từ game"
    task.delay(12,function()
        if STATE.Alive and H.Busy and generation==H.Generation then
            H.Generation=H.Generation+1;H.Busy=false
            H.MaterialStatus="Hết thời gian đọc kho; thử lại"
        end
    end)
    task.spawn(function()
        local ok,data=EX.GetInventory()
        if not STATE.Alive or generation~=H.Generation then return end
        H.Busy=false
        if not ok or type(data)~="table" then
            H.Bits=nil;H.Seeds=nil;H.Candy=nil
            H.MaterialStatus="Không đọc được kho; chưa xác định số lượng"
            return
        end
        local parsed=H.ParseInventory(data)
        H.Bits=parsed.Bits;H.Seeds=parsed.Seeds;H.Candy=parsed.Candy
        local playerData=LP:FindFirstChild("Data")
        if H.Candy==nil then
            local holders={}
            if playerData then holders[#holders+1]=playerData end
            holders[#holders+1]=LP
            for _,holder in ipairs(holders) do
                for _,name in ipairs({"Candy Corn","CandyCorn","SpookyTokens","Candy","Candies","HalloweenCandy"}) do
                    local v=holder:FindFirstChild(name)
                    if v and v:IsA("ValueBase") and tonumber(v.Value) then
                        H.Candy=math.max(0,math.floor(tonumber(v.Value)));break
                    end
                end
                if H.Candy~=nil then break end
            end
        end
        if H.Bits~=nil and H.Seeds~=nil then
            H.MaterialStatus=(H.Bits>=200 and H.Seeds>=3)
                and "Theo mốc cộng đồng: đủ 200 Bits / 3 Seeds; kiểm tra tại Witch"
                or "Theo mốc cộng đồng: cần 200 Bits / 3 Seeds"
        else
            H.MaterialStatus="Thiếu dữ liệu vật liệu trong kho; không suy đoán là 0"
        end
    end)
    return true,"Đang đọc kho"
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
    -- The v34 V4 progression director replaces repetitive ActivateAbility.
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
        or Config.FarmEnabled or Config.AutoSea or Config.AutoChest or Config.AutoBerry or Config.AutoMagnetToken or Config.AutoCollectFruit or Config.HalloweenPumpkins or Config.AutoTrickOrTreat)
    if not enabled then
        if next(noclipParts) then restoreNoclip() end
        return
    end
    local char=LP.Character
    if not char then return end
    -- Core collision components are checked every physics step, not every 0.4s.
    for _,name in ipairs({"HumanoidRootPart","Head","UpperTorso","LowerTorso","Torso"}) do
        local part=char:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            if noclipParts[part]==nil then noclipParts[part]=part.CanCollide end
            if part.CanCollide then part.CanCollide=false end
        end
    end
    if os.clock()-lastNoclipUpdate<0.12 then return end
    lastNoclipUpdate=os.clock()
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if noclipParts[part]==nil then noclipParts[part]=part.CanCollide end
            if part.CanCollide then part.CanCollide=false end
        end
    end
end)


-- V34 Halloween director. Replaces the v27 tick while retaining the same UI telemetry.
-- Reference: Topi Halloween (door models + optionsList/scroller GuiObjects + event fights).
do
    local T=STATE.TrickTreat
    local INPUT=game:GetService('VirtualInputManager')
    local doorSkip=setmetatable({}, {__mode='k'})
    local cached,scannedAt={},0
    local activeDoor,sideIndex,sideSince,startedAt,seenDialogue,dialogueGone= nil,1,0,0,false,0
    local pressedAt,clickedAt,engagedAt,missingOptionAt,optionStart=0,0,0,0,0
    local lastCandy,candyChangedAt=nil,0
    local function pivot(obj)
        if not obj or not obj.Parent then return nil end
        if obj:IsA('BasePart') then return obj.CFrame end
        if obj:IsA('Model') then
            local ok,cf=pcall(function() return obj:GetPivot() end)
            if ok then return cf end
        end
        return nil
    end
    local function candyCount()
        local data=LP:FindFirstChild('Data')
        for _,root in ipairs({data,LP}) do
            if root then
                for _,n in ipairs({'Candy','Candies','HalloweenCandy'}) do
                    local v=root:FindFirstChild(n)
                    if v and v:IsA('ValueBase') and type(v.Value)=='number' then return v.Value end
                end
            end
        end
        return nil
    end
    local function doors()
        if os.clock()-scannedAt<3 and #cached>0 then return cached end
        scannedAt=os.clock()
        local map=WS:FindFirstChild('Map')
        local result,visited={},{}
        if map then
            for _,d in ipairs(map:GetDescendants()) do
                if d.Name=='HalloweenDoor' and (d:IsA('Model') or d:IsA('BasePart')) and not visited[d] then
                    visited[d]=true;result[#result+1]=d
                end
            end
        end
        cached=result
        T.DoorsFound=#result
        return result
    end
    local function promptFor(door)
        if not door or not door.Parent then return nil end
        local scene=door:FindFirstChild('SceneWindow',true)
        if scene then
            local p=scene:FindFirstChildWhichIsA('ProximityPrompt',true)
            if p and p.Enabled then return p,scene,true end
        end
        local p=door:FindFirstChildWhichIsA('ProximityPrompt',true)
        if p and p.Enabled then return p,door,false end
        return nil,door,false
    end
    local function visible(node)
        local p=node
        while p and not p:IsA('ScreenGui') do
            if p:IsA('GuiObject') and not p.Visible then return false end
            p=p.Parent
        end
        return p~=nil and (not p:IsA('ScreenGui') or p.Enabled)
    end
    local function dialogue()
        local pg=LP:FindFirstChild('PlayerGui')
        local gui=pg and pg:FindFirstChild('DialogueGui')
        if not gui or (gui:IsA('ScreenGui') and not gui.Enabled) then return nil,nil end
        local fallback=nil
        -- Options can be Frames/TextLabels and not GuiButtons (the v33 bug).
        for _,group in ipairs(gui:GetDescendants()) do
            if group.Name=='optionsList' then
                local sc=group:FindFirstChild('scroller')
                if sc then
                    fallback=fallback or sc
                    for _,entry in ipairs(sc:GetChildren()) do
                        if entry:IsA('GuiObject') and entry.Name:lower():find('option1',1,true)
                            and not entry.Name:lower():match('option1%d') and entry.AbsoluteSize.X>0 and entry.AbsoluteSize.Y>0 and visible(entry) then
                            return sc,entry
                        end
                    end
                end
            end
        end
        -- Still locate a visible option1 if the game changes its hierarchy.
        for _,entry in ipairs(gui:GetDescendants()) do
            if entry:IsA('GuiObject') and entry.Name:lower():find('option1',1,true)
                and not entry.Name:lower():match('option1%d') and visible(entry) and entry.AbsoluteSize.X>0 then return gui,entry end
        end
        return fallback,nil
    end
    local function clickOption(option)
        if os.clock()-clickedAt<.65 then return end
        clickedAt=os.clock()
        local target=option:IsA('GuiButton') and option or option:FindFirstChildWhichIsA('GuiButton',true)
        local fn=api('firesignal')
        if target and type(fn)=='function' then
            pcall(fn,target.MouseButton1Click)
            pcall(fn,target.Activated)
        end
        -- For Frame/TextLabel entries, click their actual on-screen center.
        local pos=option.AbsolutePosition+option.AbsoluteSize/2
        local screen=option:FindFirstAncestorWhichIsA('ScreenGui')
        if screen and not screen.IgnoreGuiInset then
            pcall(function() pos=pos+GuiService:GetGuiInset() end)
        end
        local ok=pcall(function()
            INPUT:SendMouseButtonEvent(pos.X,pos.Y,0,true,game,1)
            INPUT:SendMouseButtonEvent(pos.X,pos.Y,0,false,game,1)
        end)
        T.DialogueClicks=T.DialogueClicks+1
        if not ok and not target then T.LastError='No supported input for dialogue' end
        T.Status='Chọn hội thoại nhận kẹo (đang đợi game phản hồi)'
    end
    local function doorSides(cf,root,door)
        local ray=RaycastParams.new()
        ray.FilterType=Enum.RaycastFilterType.Exclude
        local excludes={door}
        if LP.Character then excludes[#excludes+1]=LP.Character end
        ray.FilterDescendantsInstances=excludes
        ray.IgnoreWater=true
        local sorted={}
        for _,dir in ipairs({cf.LookVector,-cf.LookVector,cf.RightVector,-cf.RightVector}) do
            local flat=Vector3.new(dir.X,0,dir.Z)
            if flat.Magnitude>.1 then
                local pos=cf.Position+flat.Unit*3.4
                local score=(root.Position-pos).Magnitude*.002
                local roof=WS:Raycast(pos+Vector3.new(0,2,0),Vector3.new(0,60,0),ray)
                if roof and roof.Instance.Transparency<1 then score=score+4 end
                local wall=WS:Raycast(pos+Vector3.new(0,2,0),(cf.Position-pos)*.8,ray)
                if wall then score=score+8 end
                sorted[#sorted+1]={dir=flat.Unit,score=score}
            end
        end
        table.sort(sorted,function(a,b) return a.score<b.score end)
        return sorted
    end
    local positions={}
    local function resetDoor(message,skip)
        if activeDoor and skip then doorSkip[activeDoor]=os.clock()+math.max(18,Config.TrickTreatRevisit or 100) end
        activeDoor=nil;positions={};sideIndex=1;sideSince=0;startedAt=0
        seenDialogue=false;dialogueGone=0;missingOptionAt=0;optionStart=0
        T.Door=nil;T.Active=false
        T.Status=message or 'Tìm cửa tiếp theo'
    end
    local function pickDoor(root)
        local best,near=nil,math.huge
        for _,door in ipairs(doors()) do
            if door.Parent and (doorSkip[door] or 0)<os.clock() then
                local p,part,special=promptFor(door)
                local cf=pivot(part) or pivot(door)
                if cf then
                    local dist=(root.Position-cf.Position).Magnitude
                    if special then dist=dist*.7 end
                    if dist<near then near=dist;best=door end
                end
            end
        end
        return best
    end
    local function fightEvent(root)
        if not Config.HalloweenAutoFight then return false end
        local folder=enemyFolder()
        if not folder then return false end
        local boss=folder:FindFirstChild('Hellfire Gas')
        if boss and STATE.IsAliveNPC(boss) then
            T.Status='Đánh Hellfire Gas'
            T.Active=true;engage(boss)
            return true
        end
        local found,dist=nil,190
        for _,npc in ipairs(folder:GetChildren()) do
            if STATE.IsAliveNPC(npc) then
                local r=npc:FindFirstChild('HumanoidRootPart')
                local isEvent=STATE.IsHalloweenEnemy(npc.Name) or npc.Name:lower():find('ghost',1,true)
                    or npc.Name:lower():find('hellfire',1,true)
                if r and activeDoor then
                    local cf=pivot(activeDoor)
                    if cf and (r.Position-cf.Position).Magnitude<135 then isEvent=true end
                end
                if r and isEvent then
                    local d=(root.Position-r.Position).Magnitude
                    if d<dist then found,dist=npc,d end
                end
            end
        end
        if found then
            T.Status='Đánh quái sự kiện: '..found.Name
            T.Active=true;engage(found)
            engagedAt=os.clock()
            return true
        end
        return false
    end
    local function press(prompt)
        if os.clock()-pressedAt<1.25 then return end
        pressedAt=os.clock()
        if prompt and prompt.Enabled and type(api('fireproximityprompt'))=='function' then
            local ok=pcall(api('fireproximityprompt'),prompt,1)
            if ok then T.Prompts=T.Prompts+1;T.Status='Đã gửi tương tác cửa, chờ hội thoại';return end
        end
        -- Touch devices do not have a physical E key; executor input is optional.
        local hold=prompt and prompt.HoldDuration or .15
        local ok=pcall(function()
            INPUT:SendKeyEvent(true,Enum.KeyCode.E,false,game)
            task.delay(math.max(.16,hold+.09),function()
                pcall(function() INPUT:SendKeyEvent(false,Enum.KeyCode.E,false,game) end)
            end)
        end)
        if ok then T.Prompts=T.Prompts+1
        else T.LastError='Executor cannot synthesize E or fire a prompt' end
    end
    function T.Stop()
        resetDoor(Config.AutoTrickOrTreat and 'Tạm dừng / chờ cửa' or 'Tắt',false)
        -- Keep the last error visible until a successful attempt.
    end
    function T.Tick()
        if not STATE.Alive or not Config.AutoTrickOrTreat then
            if T.Active then T.Stop() end
            return
        end
        if Config.TrickTreatWindowOnly and (tonumber(os.date('%M')) or 99)>=10 then
            T.Status='Đợi khung giờ sự kiện';return
        end
        if Config.FarmEnabled and Config.FarmMode~='Halloween' then
            T.Status='Chờ tắt Farm thường';return
        end
        local _,_,root,ok=alive()
        if not ok or not root then T.Status='Chờ nhân vật';return end
        -- After a door encounter, spawned mobs must be cleared BEFORE switching doors.
        if fightEvent(root) then return end
        -- SceneWindow can teleport the player to HellfireBossRealm. Stay there
        -- until it finishes, instead of immediately tweening back to a door.
        local map=WS:FindFirstChild('Map')
        local realm=map and map:FindFirstChild('HellfireBossRealm')
        if realm and realm:IsA('Model') then
            local inside=false
            pcall(function()
                local cf,size=realm:GetBoundingBox()
                local offset=cf:PointToObjectSpace(root.Position)
                inside=math.abs(offset.X)<=size.X/2+15 and
                    math.abs(offset.Y)<=size.Y/2+45 and math.abs(offset.Z)<=size.Z/2+15
            end)
            if inside then
                T.Active=true;T.Status='HellfireBossRealm: đợi quái / chưa có quái hợp lệ'
                return
            end
        end
        -- GhostChase is an event-specific movement phase in the Topi source.
        if Config.HalloweenGhostChase and os.clock()>(T.GhostSkipUntil or 0) then
            local ghostRoot=WS:FindFirstChild('GhostChase')
            if ghostRoot and #ghostRoot:GetChildren()>0 then
                T.GhostStart=(T.GhostStart or 0)==0 and os.clock() or T.GhostStart
                if os.clock()-T.GhostStart>105 then
                    T.GhostSkipUntil=os.clock()+30;T.GhostStart=0
                    T.Status='GhostChase quá lâu, tạm quay lại gõ cửa'
                else
                    local closest,d=nil,math.huge
                    for _,g in ipairs(ghostRoot:GetChildren()) do
                        local cf=pivot(g)
                        if cf and (T.GhostVisited[g] or 0)<os.clock() then
                            local dist=(root.Position-cf.Position).Magnitude
                            if dist<d then closest,d=g,dist end
                        end
                    end
                    if closest then
                        local cf=pivot(closest)
                        T.GhostVisited[closest]=os.clock()+2.2
                        T.Active=true
                        T.Status='GhostChase: '..closest.Name..' / '..math.floor(d)..' studs'
                        if d>7 then moveTo(cf) end
                        return
                    end
                    T.Status='GhostChase: đợi model kế tiếp';return
                end
            else T.GhostStart=0 end
        end
        local sc,opt=dialogue()
        if opt then
            T.Active=true;seenDialogue=true;dialogueGone=0;missingOptionAt=0
            optionStart=optionStart==0 and os.clock() or optionStart
            if os.clock()-optionStart>10 then
                T.Failures=T.Failures+1
                resetDoor('Đã chọn option1 nhưng chưa được xác nhận; đổi cửa',true)
                return
            end
            clickOption(opt)
            return
        elseif sc then
            -- Topi observed stale optionsList/scroller. Never wait indefinitely.
            missingOptionAt=missingOptionAt==0 and os.clock() or missingOptionAt
            T.Active=true;T.Status='Đợi option1 xuất hiện trong hội thoại'
            if os.clock()-missingOptionAt>7 then
                T.Failures=T.Failures+1
                resetDoor('Dialogue thiếu option1 quá 7s; thử cửa khác',true)
            end
            return
        elseif seenDialogue then
            if dialogueGone==0 then dialogueGone=os.clock() end
            if os.clock()-dialogueGone>1.4 then
                local candy=candyCount()
                if candy and lastCandy and candy>lastCandy then
                    T.CandyConfirmed=(T.CandyConfirmed or 0)+(candy-lastCandy)
                    candyChangedAt=os.clock()
                    T.Status='Đã nhận thêm '..tostring(candy-lastCandy)..' kẹo'
                else
                    T.Status='Hội thoại đóng; chưa xác nhận kẹo'
                end
                T.Visits=T.Visits+1
                resetDoor(T.Status,true)
                return
            end
        end
        local doorsLoaded=doors()
        if not activeDoor or not activeDoor.Parent then
            resetDoor('Chọn cửa Halloween gần nhất',false)
            activeDoor=pickDoor(root)
            if not activeDoor then
                T.Status='Không tìm thấy HalloweenDoor đang tải ('..#doorsLoaded..')'
                return
            end
            T.Door=activeDoor;startedAt=os.clock();sideSince=startedAt
            lastCandy=candyCount()
        end
        T.Active=true
        local prompt,subject,isScene=promptFor(activeDoor)
        local cf=pivot(subject) or pivot(activeDoor)
        if not cf then resetDoor('Cửa biến mất / stream out',true);return end
        if #positions==0 then positions=doorSides(cf,root,activeDoor) end
        if #positions==0 then resetDoor('Không xác định được vị trí đứng',true);return end
        if os.clock()-sideSince>3.4 then
            sideIndex=sideIndex+1;sideSince=os.clock()
        end
        if sideIndex>#positions or os.clock()-startedAt>27 then
            T.Failures=T.Failures+1;resetDoor('Cửa không phản hồi; thử cửa khác',true);return
        end
        local goal=CFrame.lookAt(cf.Position+positions[sideIndex].dir*3.4,cf.Position)
        local gap=(root.Position-goal.Position).Magnitude
        if gap>5.4 then
            T.Status=string.format('Đến cửa %s (%d studs) · phía %d',activeDoor.Name,math.floor(gap),sideIndex)
            moveTo(goal)
        else
            T.Status=isScene and 'Tương tác SceneWindow' or 'Gõ cửa · chờ nhận kẹo'
            press(prompt)
        end
    end
end

-- V34 Cake Prince / Katakuri: boss -> portal -> unlock mobs -> spawn cycling.
-- Sources: DynamicIsland's CakePrinceTask, Topi's Farm Katakuri.
do
    local K={Stage='Off',Status='Chưa bật',Remaining=nil,LastCheck=0,
        LastSummon=0,LastFight=0,LastBoss=nil,Attacks=0,Checks=0,Errors=0,
        SpawnPoint=Vector3.new(-2151.82,149.32,-12404.91),
        CakeCenter=Vector3.new(-2077,252,-12373)}
    STATE.KatakuriDirector=K
    local fodder={'Cookie Crafter','Cake Guard','Baking Staff','Head Baker'}
    function K.Check()
        if os.clock()-K.LastCheck<math.max(7,Config.KatakuriCheckInterval or 15) then return end
        K.LastCheck=os.clock();K.Checks=K.Checks+1
        local ok,res=remote('CakePrinceSpawner')
        if not ok then K.Errors=K.Errors+1;K.Status='Spawner check lỗi: '..tostring(res);return end
        K.SpawnerReply=tostring(res)
        local line=K.SpawnerReply:lower()
        if line:find('open the portal now',1,true) or line:find('enough',1,true) then
            K.Remaining=0;K.Ready=true
        else
            K.Ready=false
            -- Progress wording differs among game builds. Do not interpret arbitrary digits as kills.
            local n=line:match('(%d+)%s+more') or line:match('need%s+(%d+)')
                or line:match('remaining[:%s]+(%d+)')
            K.Remaining=n and tonumber(n) or nil
        end
    end
    local function findCakeMob()
        local folder=enemyFolder()
        local _,_,root,ok=alive()
        if not ok or not folder then return nil end
        local best,d=nil,math.huge
        for _,mob in ipairs(folder:GetChildren()) do
            if STATE.IsAliveNPC(mob) then
                local nm=norm(mob.Name)
                local matches=false
                for _,name in ipairs(fodder) do if nm==norm(name) then matches=true;break end end
                if matches then
                    local rp=mob:FindFirstChild('HumanoidRootPart')
                    if rp then
                        local dist=(root.Position-rp.Position).Magnitude
                        if dist<d then best=mob;d=dist end
                    end
                end
            end
        end
        return best
    end
    function K.Tick()
        if not Config.AutoKatakuri then K.Stage='Off';K.Status='Chưa bật';return end
        if STATE.World~=3 then K.Stage='Sea';K.Status='Katakuri yêu cầu Sea 3';return end
        if Config.FarmEnabled or Config.AutoRaid or Config.AutoTrickOrTreat then
            K.Stage='Paused';K.Status='Tạm dừng vì chế độ khác đang điều khiển';return
        end
        local _,_,root,ok=alive();if not ok then K.Status='Đợi nhân vật';return end
        local boss=enemySearch({'Cake Prince','Dough King'},false,true)
        if boss then
            K.Stage='Boss';K.LastBoss=boss.Name;K.Attacks=K.Attacks+1
            K.Status='Đánh '..boss.Name..' / HP được theo dõi bởi Combat'
            engage(boss)
            return
        end
        if (root.Position-K.CakeCenter).Magnitude>1500 then
            K.Stage='Travel';K.Status='Đang đến Cake Land'
            moveTo(CFrame.new(K.CakeCenter));return
        end
        K.Check()
        if K.Ready and Config.KatakuriAutoSummon then
            K.Stage='Summon';K.Status='Đã đủ điều kiện: gọi CakePrinceSpawner'
            if os.clock()-K.LastSummon>math.max(15,Config.KatakuriSummonInterval or 25) then
                K.LastSummon=os.clock()
                local sent,result=remote('CakePrinceSpawner',true)
                if not sent or result==false then K.Errors=K.Errors+1
                    K.Status='Server chưa nhận triệu hồi: '..tostring(result) end
            end
            local mirror=WS:FindFirstChild('Map') and WS.Map:FindFirstChild('CakeLoaf')
            mirror=mirror and mirror:FindFirstChild('BigMirror')
            local cf=mirror and (mirror:IsA('Model') and mirror:GetPivot() or (mirror:IsA('BasePart') and mirror.CFrame))
            if cf then moveTo(cf*CFrame.new(0,5,0)) else moveTo(CFrame.new(K.SpawnPoint)) end
            return
        end
        local mob=findCakeMob()
        if mob then
            K.Stage='Unlock';K.Status=K.Remaining and ('Farm quái mở Cake Prince · còn '..K.Remaining)
                or 'Farm Cookie Crafter / Cake Guard / Baking Staff / Head Baker'
            engage(mob)
        else
            K.Stage='SpawnWait';K.Status='Đợi quái Cake Land xuất hiện'
            local spawn=nil
            for _,name in ipairs(fodder) do spawn=spawnCFrame(name);if spawn then break end end
            moveTo(spawn or CFrame.new(K.CakeCenter))
        end
    end
    startLoop('Katakuri stage director',.25,function() K.Tick() end)
end

-- V37 RAID SESSION DIRECTOR: no foreign raid auto-join.
-- Reference Topi: CheckInRaid requires nearby Island marker; unlike Topi this
-- director also needs our own click->transition session token.
do
    local D={Stage="Off",Status="Chưa bật",RunCount=0,Wave=0,LastSelect=0,
        LastClick=0,LastActive=0,LastAwaken=0,Attacks=0,Errors=0,
        Owned=false,ForeignIgnored=0,StartedAt=0,Pending=nil,SessionId=0,
        LastSessionExit=0,MagnetActive=0,Marker=nil,SessionProof="none",
        LastLocalRoot=nil,LastTimer=false,ChipAttempts=0,WasEnabled=false}
    STATE.RaidDirector=D
    local function toolChip()
        local bag=LP:FindFirstChild('Backpack')
        for _,where in ipairs({LP.Character,bag}) do
            if where then
                for _,item in ipairs(where:GetChildren()) do
                    if item:IsA('Tool') and item.Name:find('Microchip',1,true) then
                        return item
                    end
                end
            end
        end
        return nil
    end
    local function raidTimer()
        local pg=LP:FindFirstChild('PlayerGui')
        local main=pg and (pg:FindFirstChild('Main') or pg:FindFirstChild('Main (minimal)'))
        local hud=main and main:FindFirstChild('TopHUDList')
        local timer=(hud and hud:FindFirstChild('RaidTimer')) or (main and main:FindFirstChild('RaidTimer',true))
        if not timer then return false end
        if timer:IsA('GuiObject') then return timer.Visible end
        return false
    end
    local function islandsNear(position,maxDist)
        local origin=WS:FindFirstChild('_WorldOrigin')
        local locs=origin and origin:FindFirstChild('Locations')
        if not locs then return nil,0,math.huge,0 end
        local best,wave,distance,count=nil,0,math.huge,0
        for _,entry in ipairs(locs:GetChildren()) do
            local n=tonumber(entry.Name:match('^Island%s+(%d+)$'))
            if n and n>=1 and n<=5 and entry:IsA('BasePart') then
                local d=(position-entry.Position).Magnitude
                local sameArea=not D.Owned or not D.RaidOrigin or
                    (entry.Position-D.RaidOrigin).Magnitude<=3000
                if sameArea and d<(maxDist or 3000) then
                    count=count+1
                    -- Follow the nearest island to this character. Taking the
                    -- highest numbered marker could select someone else's raid.
                    if d<distance then
                        best,wave,distance=entry,n,d
                    end
                end
            end
        end
        return best,wave,distance,count
    end
    local function nextIsland(current,wave,position)
        local origin=WS:FindFirstChild('_WorldOrigin')
        local locs=origin and origin:FindFirstChild('Locations')
        if not (current and locs) then return nil end
        local best,bestDistance=nil,math.huge
        for _,entry in ipairs(locs:GetChildren()) do
            if entry:IsA('BasePart') and entry.Name=='Island '..tostring(wave+1) then
                local between=(entry.Position-current.Position).Magnitude
                local fromPlayer=(entry.Position-position).Magnitude
                local fromStart=D.RaidOrigin and (entry.Position-D.RaidOrigin).Magnitude or between
                if between<=1800 and fromPlayer<=2200 and fromStart<=3000 and between<bestDistance then
                    best,bestDistance=entry,between
                end
            end
        end
        return best
    end
    local function raidButton()
        local map=WS:FindFirstChild('Map')
        local island=map and ((STATE.World==2 and map:FindFirstChild('CircleIsland'))
            or (STATE.World==3 and map:FindFirstChild('Boat Castle')))
        if not island then return nil,nil end
        local summon=island:FindFirstChild('RaidSummon2',true)
            or island:FindFirstChild('RaidSummon',true)
        local button=summon and (summon:FindFirstChild('Main',true)
            or summon:FindFirstChild('Button',true))
        local detector=button and button:FindFirstChildWhichIsA('ClickDetector',true)
        detector=detector or (summon and summon:FindFirstChildWhichIsA('ClickDetector',true))
        local source=detector and detector.Parent
        local stand=source and (source:IsA('BasePart') and source
            or source:FindFirstChildWhichIsA('BasePart',true))
        return detector,stand
    end
    local function reset(reason)
        if D.Owned and STATE.MobMagnet then
            STATE.MobMagnet.Stop('Raid session ended')
        end
        if D.Owned and STATE.ReleaseFarmHover then STATE.ReleaseFarmHover() end
        local mover=STATE.Mover
        if mover and mover.Active and mover.Caller=='Full auto raid v38' then cancelMove() end
        if D.LockedTarget and STATE.AutomationCombatTarget==D.LockedTarget then
            STATE.AutomationCombatTarget=nil;STATE.AutomationCombatAt=0
        end
        D.Owned=false;D.Pending=nil;D.Marker=nil;D.MagnetActive=0;D.RaidOrigin=nil
        D.EmptySince=nil;D.EmptyWave=nil
        D.LockedTarget=nil;D.ForeignSeen=false
        D.SessionProof='none';D.LastSessionExit=os.clock()
        D.Stage='Ready';D.Status=reason or 'Sẵn sàng khởi tạo raid mới'
    end
    D.Reset=reset
    function D.GetTarget()
        if not D.Owned then return nil end
        local _,_,root,ok=alive()
        if not ok or not root then return nil end
        local island,wave=islandsNear(root.Position,2600)
        if not island then return nil end
        if D.Wave~=wave then D.LockedTarget=nil end
        D.Marker=island;D.Wave=wave
        local enemies=enemyFolder()
        if not enemies then return nil end
        local current=D.LockedTarget
        if current and STATE.IsAliveNPC(current) then
            local cr=current:FindFirstChild('HumanoidRootPart')
            if cr and (cr.Position-island.Position).Magnitude<600 and
                (cr.Position-root.Position).Magnitude<1050 then return current end
        end
        D.LockedTarget=nil
        local nearest,bestDist=nil,math.huge
        for _,mob in ipairs(enemies:GetChildren()) do
            -- The final wave can contain a boss. Restrict by the local raid
            -- island, rather than dropping every NPC with a boss label.
            if STATE.IsAliveNPC(mob) then
                local r=mob:FindFirstChild('HumanoidRootPart')
                if r then
                    local islandDist=(r.Position-island.Position).Magnitude
                    local playerDist=(r.Position-root.Position).Magnitude
                    if islandDist<600 and playerDist<1050 and playerDist<bestDist then
                        nearest,bestDist=mob,playerDist
                    end
                end
            end
        end
        D.LockedTarget=nearest
        return nearest
    end
    local function activeEvidence(root)
        local marker,wave,distance,count=islandsNear(root.Position,2700)
        return marker,wave,distance,count,raidTimer()
    end
    local function updatePending(root)
        if not D.Pending then return false end
        local now=os.clock()
        if now-D.Pending.At>45 then
            D.Errors=D.Errors+1
            reset('Chưa xác nhận vào raid sau 45s; thử lại khi sẵn sàng')
            return false
        end
        local marker,wave,distance,count,timer=activeEvidence(root)
        -- Server-side transition to the raid zone is required. A global island
        -- marker or somebody else's raid timer is not an ownership proof.
        local leftSummon=(root.Position-D.Pending.From).Magnitude>150
        if timer then D.Pending.FirstTimerAt=D.Pending.FirstTimerAt or now end
        if marker and distance<800 then
            D.Pending.FirstMarkerAt=D.Pending.FirstMarkerAt or now
        end
        local proof=D.Pending.FirstTimerAt and D.Pending.FirstMarkerAt
        if proof and marker and timer and leftSummon and distance<800 then
            D.Owned=true;D.Pending=nil;D.RunCount=D.RunCount+1
            D.StartedAt=now;D.LastActive=now;D.Marker=marker;D.Wave=wave
            D.RaidOrigin=marker.Position
            D.SessionId=D.SessionId+1;D.SessionProof='our click + timer + local transition'
            D.Stage='Owned';D.Status='Đã xác nhận raid do mình vừa mở · đảo '..wave
            return true
        end
        D.Stage='Confirm';D.Status=string.format(
            'Đợi raid riêng: đảo gần=%s timer mới=%s rời nút=%s (%dm)',
            tostring(marker~=nil and distance<800),
            tostring(D.Pending.FirstTimerAt~=nil),tostring(leftSummon),
            math.floor(distance==math.huge and 0 or distance))
        return true
    end
    function D.Tick()
        if not Config.AutoRaid then
            if D.WasEnabled or D.Owned or D.Pending then reset('Đã tắt Auto Raid') end
            D.WasEnabled=false
            D.Stage='Off';D.Status='Chưa bật';return
        end
        D.WasEnabled=true
        if STATE.World~=2 and STATE.World~=3 then
            D.Stage='Sea';D.Status='Raid cần Sea 2/3';return
        end
        if level()<1100 then D.Stage='Level';D.Status='Cần cấp 1100';return end
        if Config.FarmEnabled or Config.AutoTrickOrTreat or Config.AutoKatakuri
            or Config.AutoRaceV4 or Config.AutoSea or Config.AutoFish then
            D.Stage='Paused';D.Status='Đợi chế độ khác dừng';return
        end
        if (Config.FragmentsCap or 0)>0 and value('Fragments')>=Config.FragmentsCap then
            reset('Đạt mốc Fragments')
            Config.AutoRaid=false;D.Stage='Goal'
            for _,redraw in ipairs(STATE.ControlBindings.AutoRaid or {}) do
                pcall(redraw,false)
            end
            return
        end
        local _,_,root,aliveNow=alive()
        if not aliveNow or not root then D.Status='Đợi nhân vật';return end
        local now=os.clock()
        if D.Pending then updatePending(root);return end
        if D.Owned then
            local marker,wave,distance,count,timer=activeEvidence(root)
            if marker and distance<1800 and timer then
                if D.Wave~=wave then D.LockedTarget=nil;D.EmptySince=nil end
                D.LastActive=now;D.Wave=wave;D.Marker=marker
                local mob=D.GetTarget()
                if mob then
                    D.EmptySince=nil;D.EmptyWave=nil
                    D.Stage='Combat'
                    D.Status='Raid riêng · đảo '..wave..' · đánh '..mob.Name
                    D.Attacks=D.Attacks+1
                    engage(mob) -- V33 auto magnet, no additional toggle
                    D.MagnetActive=STATE.MobMagnet and STATE.MobMagnet.Active or 0
                else
                    if STATE.ReleaseFarmHover then STATE.ReleaseFarmHover() end
                    local nextMarker=nextIsland(marker,wave,root.Position)
                    D.Stage='Wave'
                    if (root.Position-marker.Position).Magnitude>175 then
                        D.EmptySince=nil;D.EmptyWave=nil
                        D.Status='Đến đảo '..wave..' / chờ quái'
                        moveTo(CFrame.new(marker.Position+Vector3.new(0,60,0)))
                    else
                        if D.EmptyWave~=wave then D.EmptyWave=wave;D.EmptySince=now end
                        D.EmptySince=D.EmptySince or now
                        if nextMarker and now-D.EmptySince>=5 then
                            D.Status='Đảo '..wave..' trống · đến đảo '..(wave+1)
                            moveTo(CFrame.new(nextMarker.Position+Vector3.new(0,45,0)))
                        else
                            D.Status='Đảo '..wave..': chờ quái hoặc đảo tiếp theo'
                        end
                    end
                end
                return
            end
            if timer then
                D.LastActive=now;D.Stage='Transition';D.Status='Đợi đảo raid gần nhân vật tải';return
            end
            if now-D.LastActive<10 then
                D.Stage='Transition';D.Status='Đợi tải đảo tiếp theo';return
            end
            if now-D.LastActive<19 then
                D.Stage='Finish';D.Status='Đang xác minh raid kết thúc'
                if Config.RaidAutoAwaken and now-D.LastAwaken>20 then
                    D.LastAwaken=now
                    if EX and EX.RaidAwaken then EX.RaidAwaken() end
                end
                return
            end
            reset('Đã rời raid; chờ 15s để tránh chạm raid người khác')
            return
        end
        local marker,wave,distance,count,timer=activeEvidence(root)
        -- If the user enabled the toggle while already inside a raid, assist
        -- only that local raid; never navigate to a distant global marker.
        if timer and marker and distance<650 then
            D.Owned=true;D.RunCount=D.RunCount+1;D.StartedAt=now;D.LastActive=now
            D.Marker=marker;D.Wave=wave;D.RaidOrigin=marker.Position
            D.SessionId=D.SessionId+1;D.SessionProof='timer + đang đứng gần đảo raid'
            D.Stage='Owned';D.Status='Đã nhận raid đang đứng trong · đảo '..wave
            return
        end
        if timer then
            if not D.ForeignSeen then D.ForeignIgnored=D.ForeignIgnored+1 end
            D.ForeignSeen=true
            D.Stage='Foreign'
            D.Status='Có timer nhưng chưa đứng gần đảo raid; không tự bay sang raid khác'
            return
        end
        D.ForeignSeen=false
        if now-D.LastSessionExit<15 then
            D.Stage='Cooldown';D.Status='Chờ ra khỏi phiên raid cũ';return
        end
        local chip=toolChip()
        if chip then
            local click,stand=raidButton()
            if not click or not stand then
                -- Streaming often hides the laboratory until the player is near.
                local lab=STATE.World==2 and CFrame.new(-6438.73535,250.645355,-4501.50684)
                    or CFrame.new(-5017.40869,314.844055,-2823.0127)
                if (root.Position-lab.Position).Magnitude>35 then
                    D.Stage='Travel';D.Status='Đang đến phòng Raid để tải nút'
                    if not moveTo(lab) then D.Status='Không thể đến phòng Raid; kiểm tra bật dịch chuyển' end
                else
                    D.Stage='Summon';D.Status='Đợi nút RaidSummon2 tải tại phòng Raid'
                end
                return
            end
            local distanceToButton=(root.Position-stand.Position).Magnitude
            if distanceToButton>12 then
                D.Stage='Travel';D.Status='Bay đến nút mở raid ('..math.floor(distanceToButton)..' studs)'
                moveTo(stand.CFrame*CFrame.new(0,3,3));return
            end
            if now-D.LastClick<10 then D.Stage='Summon';D.Status='Đợi cooldown nhấn nút';return end
            local fire=api('fireclickdetector')
            if type(fire)~='function' then
                D.Stage='Input';D.Status='Executor Android thiếu fireclickdetector';return
            end
            local fired,err=pcall(fire,click)
            D.LastClick=now
            if fired then
                D.Pending={At=now,From=root.Position,Raid=Config.Raid,
                    FirstTimerAt=nil,FirstMarkerAt=nil,Clicks=1}
                D.Stage='Confirm';D.Status='Đã gửi click; CHƯA xác nhận vào raid riêng'
            else
                D.Errors=D.Errors+1;D.Status='ClickDetector lỗi: '..tostring(err)
            end
            return
        end
        if not Config.RaidAutoBuyChip then
            D.Stage='Chip';D.Status='Thiếu Special Microchip; chưa cho mua';return
        end
        if value('Beli')<100000 then
            D.Stage='Funds';D.Status='Thiếu 100.000 Beli; không dùng Fruit';return
        end
        if now-D.LastSelect<18 then return end
        D.LastSelect=now;D.ChipAttempts=D.ChipAttempts+1
        -- Avoid consuming currently equipped fruit when buying with Beli.
        local char=LP.Character
        local hum=char and char:FindFirstChildOfClass('Humanoid')
        if hum then
            for _,tool in ipairs(char:GetChildren()) do
                if tool:IsA('Tool') and tool.Name:find('Fruit',1,true) then
                    pcall(function() hum:UnequipTools() end)
                    break
                end
            end
        end
        remote('RaidsNpc','Check')
        local bought,result=remote('RaidsNpc','Select',Config.Raid)
        D.Stage='BuyChip'
        if bought and result~=false then
            D.Status='Đã yêu cầu chip '..Config.Raid..'; đợi Backpack'
        else
            D.Errors=D.Errors+1
            D.Status='Chưa mua được chip: '..tostring(result)
        end
    end
    startLoop('Full auto raid v38',.42,function() D.Tick() end)
end

-- V37 RACE V4 DIRECTOR — accurate per-race Temple corridor, entrance, flight
-- and local trial phases. Source paths from Topi AutoTrialV4 and PullLeverV4.
do
    local V={Stage='Off',Status='Chưa bật',Checks=0,Actions=0,Errors=0,
        LastCheck=0,LastAction=0,LastAbility=0,LastMoon=0,Progress=nil,
        Race='Unknown',Trial='None',Gear='Unknown',LastClock=nil,
        InTrial=false,Door=nil,DoorDistance=nil,LastEntry=0,EntryTries=0,
        TrialMoves=0,TrialEngagements=0,LastTrialTarget=nil,LastDoorScan=0,
        DoorStatus='Unknown',Ascents=0,LastTempleAt=0,LastGearAttempt=0,
        LastTempleTeleport=0,TrialStartedAt=0,TrialTimeouts=0}
    STATE.RaceV4Director=V
    local entrance=CFrame.new(3032.780029296875,2280.85107421875,-7325.47802734375)
    local templePos=CFrame.new(28282.5703125,14896.8505859375,105.1042709350586)
    local trialMarkers={Human='Trial of Strength',Ghoul='Trial of Carnage',
        Mink='Trial of Speed',Rabbit='Trial of Speed',Skypiea='Trial of the King',
        Angel='Trial of the King',Fishman='Trial of Water',Shark='Trial of Water',
        Cyborg='Trial of the Machine',Draco='Trial of Flames'}
    local corridorNames={Rabbit='Mink',Angel='Skypiea',Shark='Fishman'}
    local function raceName()
        local data=LP:FindFirstChild('Data')
        local v=data and data:FindFirstChild('Race')
        return v and tostring(v.Value) or 'Unknown'
    end
    local function temple()
        local map=WS:FindFirstChild('Map')
        local item=map and map:FindFirstChild('Temple of Time')
        if item and item:GetAttribute('ClientBorrowed') then return nil end
        return item
    end
    local function trialMarker(race)
        local origin=WS:FindFirstChild('_WorldOrigin')
        local locs=origin and origin:FindFirstChild('Locations')
        local name=trialMarkers[race]
        local marker=locs and name and locs:FindFirstChild(name)
        return marker,name
    end
    function V.FindRaceDoor(race)
        local area=temple()
        if not area then return nil,'Temple chưa tải' end
        local id=(corridorNames[race] or race)..'Corridor'
        -- Topi exact path: Temple/{Race}Corridor/Door/Door/RightDoor/Union.
        local corridor=area:FindFirstChild(id)
        local first=corridor and corridor:FindFirstChild('Door')
        local second=first and first:FindFirstChild('Door')
        local right=second and second:FindFirstChild('RightDoor')
        local union=right and right:FindFirstChild('Union')
        if union and union:IsA('BasePart') then return union,'Exact' end
        -- Limited fallback only inside our race's corridor (never another race).
        local fallback=corridor and corridor:FindFirstChild('RightDoor',true)
        local part=fallback and (fallback:IsA('BasePart') and fallback
            or fallback:FindFirstChild('Union',true))
        if part and part:IsA('BasePart') then return part,'Fallback' end
        return nil,'Không thấy '..id..'.Door.Door.RightDoor.Union'
    end
    local function canAutoInput()
        local ok,result=pcall(function()return game:GetService('VirtualInputManager')end)
        return ok and result or nil
    end
    local function activateRace()
        if os.clock()-V.LastAbility<5 then return false end
        local input=canAutoInput()
        if not input then V.Status='Android: thiếu VirtualInputManager';return false end
        V.LastAbility=os.clock()
        local ok=pcall(function()
            input:SendKeyEvent(true,Enum.KeyCode.T,false,game)
            task.delay(.16,function()pcall(function()
                input:SendKeyEvent(false,Enum.KeyCode.T,false,game)
            end)end)
        end)
        if not ok then V.Status='Không gửi được phím T trên Android' end
        return ok
    end
    local function lookupGear()
        local map=WS:FindFirstChild('Map')
        local mirage=map and map:FindFirstChild('MysticIsland')
        if not mirage then return nil,nil end
        local gear,highest=nil,nil
        for _,part in ipairs(mirage:GetDescendants()) do
            if part:IsA('MeshPart') then
                if part.MeshId=='rbxassetid://10153114969' then gear=part end
                if part.MeshId=='rbxassetid://6745037796' then highest=part end
            end
        end
        return gear,highest
    end
    function V.SpendGearPoint()
        if STATE.World~=3 then return false,'Requires Sea 3' end
        local good,data=remote('TempleClock','Check')
        if not good or type(data)~='table' then return false,'TempleClock unavailable' end
        V.LastClock=data
        if not data.HadPoint then return false,'No unused Gear point' end
        local count=0
        if type(data.RaceDetails)=='table' then
            count=(tonumber(data.RaceDetails.A) or 0)+(tonumber(data.RaceDetails.B) or 0)
        end
        local slot=tonumber(data.RaceLevel or 0)<2 and 'Gear1'
            or 'Gear'..tostring(math.clamp(2+count,2,4))
        local choice=Config.V4GearChoice=='Omega' and 'Omega' or 'Alpha'
        local spent,result=remote('TempleClock','SpendPoint',slot,choice)
        V.LastGearAttempt=os.clock()
        if not spent or result==false then
            V.Errors=V.Errors+1;return false,'SpendPoint rejected: '..tostring(result)
        end
        local confirmed,updated=remote('TempleClock','Check')
        if confirmed and type(updated)=='table' and updated.HadPoint==false then
            V.LastClock=updated;return true,slot..' / '..choice..' confirmed'
        end
        return false,'SpendPoint sent; server confirmation missing'
    end
    local function approach(cf,status)
        if typeof(cf)~='CFrame' then return false end
        local _,_,root,ok=alive()
        if not ok then return false end
        if (root.Position-cf.Position).Magnitude<6 then return true end
        V.Stage='Travel';V.Status=status
        V.TrialMoves=V.TrialMoves+1
        moveTo(cf)
        return false
    end
    local function nearPlayerRaces(door)
        local found={};local amount=0
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=LP then
                local char=p.Character
                local root=char and char:FindFirstChild('HumanoidRootPart')
                local hum=char and char:FindFirstChildOfClass('Humanoid')
                local data=p:FindFirstChild('Data')
                local rv=data and data:FindFirstChild('Race')
                if root and hum and hum.Health>0 and rv
                    and tostring(rv.Value)~=raceName() then
                    local otherDoor=V.FindRaceDoor(tostring(rv.Value))
                    if otherDoor and (root.Position-otherDoor.Position).Magnitude<95 then
                        local name=tostring(rv.Value)
                        if not found[name] then found[name]=true;amount=amount+1 end
                    end
                end
            end
        end
        return amount
    end
    local function lever(root)
        local area=temple()
        if not area then return false end
        local node=area:FindFirstChild('Lever',true)
        local prompt=node and node:FindFirstChildWhichIsA('ProximityPrompt',true)
        if not prompt or not prompt.Enabled then return false end
        local base=prompt.Parent
        local part=base and (base:IsA('BasePart') and base or
            base:FindFirstChildWhichIsA('BasePart',true))
        if not part then return false end
        if (root.Position-part.Position).Magnitude>8 then
            V.Stage='Lever';V.Status='Bay đến Lever';moveTo(part.CFrame*CFrame.new(0,2,2))
        elseif os.clock()-V.LastAction>8 and type(api('fireproximityprompt'))=='function' then
            V.LastAction=os.clock();V.Actions=V.Actions+1
            local fired=pcall(api('fireproximityprompt'),prompt,1)
            V.Status=fired and 'Đã tương tác Lever, kiểm tra server' or 'Lever prompt lỗi'
        else V.Status='Lever: chờ ProximityPrompt / cooldown' end
        return true
    end
    local function battleNPC(root,part,race)
        local enemies=enemyFolder()
        if not enemies then return nil end
        local current=V.LastMobInstance
        if current and STATE.IsAliveNPC(current) then
            local cr=current:FindFirstChild('HumanoidRootPart')
            if cr and (cr.Position-part.Position).Magnitude<850 then return current end
        end
        V.LastMobInstance=nil
        local best,dist=nil,math.huge
        for _,mob in ipairs(enemies:GetChildren()) do
            if STATE.IsAliveNPC(mob) then
                local target=mob:FindFirstChild('HumanoidRootPart')
                if target and (target.Position-part.Position).Magnitude<850 then
                    local d=(target.Position-root.Position).Magnitude
                    if d<dist then best,dist=mob,d end
                end
            end
        end
        V.LastMobInstance=best
        return best
    end
    -- Water trial requires ability attacks. Blox Fruits SeaBeasts do not carry
    -- a normal Humanoid, so generic engage() and NPC magnet cannot damage them.
    -- Use the same selected weapon/skill keys as the hub; on mobile this is
    -- VirtualInputManager (executor support varies, no claim of hit success).
    local function waterTrialSkills()
        local now=os.clock()
        if V.WaterCasting or now-(V.LastWaterSkills or 0)<3.4 then return end
        V.LastWaterSkills=now
        local vim=canAutoInput()
        if not vim then V.Status='SeaBeast Trial: thiếu VirtualInputManager';return end
        V.WaterCasting=true
        task.spawn(function()
            if Config.AutoEquip then pcall(equipByType) end
            for _,key in ipairs({'Z','X','C','V','F'}) do
                if not STATE.Alive or not Config.AutoRaceV4 or not V.InTrial then break end
                if Config['Skill'..key] then
                    pcall(function()
                        vim:SendKeyEvent(true,Enum.KeyCode[key],false,game)
                        task.wait(.075)
                        vim:SendKeyEvent(false,Enum.KeyCode[key],false,game)
                    end)
                    task.wait(.12)
                end
            end
            V.WaterCasting=false
        end)
    end
    local function waterTrialBeast(part)
        local seaBeasts=WS:FindFirstChild('SeaBeasts')
        if not seaBeasts then return nil end
        local best,dist=nil,math.huge
        for _,m in ipairs(seaBeasts:GetChildren()) do
            if m.Name:find('SeaBeast',1,true) then
                local root=m:FindFirstChild('HumanoidRootPart')
                local health=m:FindFirstChild('Health')
                local aliveHealth=health and tonumber(health.Value) or 1
                if root and aliveHealth>0 then
                    local d=(root.Position-part.Position).Magnitude
                    if d<1500 and d<dist then best,dist=m,d end
                end
            end
        end
        return best
    end
    -- V38 TRIAL PROOF & DRACO RELIC DIRECTOR
    -- Source: Topi Halloween / CheckModelTrialDraco + GetRelicChuanbiDat.
    -- A trial marker alone is NOT evidence that a trial is currently active.
    V.Draco={Stage='Idle',Status='Waiting',Runs=0,Prompts=0,Errors=0,
        LastPrompt=0,LastRequest=0,LastRoom=nil,LastRelic=nil,
        Seen=setmetatable({},{__mode='k'}),Slot=0,Carrying=false}
    function V.IsTrialTimerVisible()
        local gui=LP:FindFirstChild('PlayerGui')
        local main=gui and gui:FindFirstChild('Main')
        local hud=main and main:FindFirstChild('TopHUDList')
        local timer=hud and hud:FindFirstChild('RaidTimer')
        return timer~=nil and timer:IsA('GuiObject') and timer.Visible==true
    end
    local function dcFrame(obj)
        if not obj then return nil end
        if obj:IsA('BasePart') then return obj.CFrame end
        if obj:IsA('Model') then return obj:GetPivot() end
        return nil
    end
    local relicColors={
        Color3.fromRGB(132,203,0),
        Color3.fromRGB(232,106,110),
        Color3.fromRGB(191,153,0)
    }
    local function relicIndex(relic)
        local part=relic and relic:FindFirstChildWhichIsA('MeshPart',true)
        if not part then return nil end
        local n,d=nil,math.huge
        for i,c in ipairs(relicColors) do
            local score=math.abs(part.Color.R-c.R)+math.abs(part.Color.G-c.G)+math.abs(part.Color.B-c.B)
            if score<d then n,d=i,score end
        end
        -- Do not infer a mapping from any unrelated bright object.
        return d<.25 and n or nil
    end
    local function relicEnabled(relic)
        if not relic then return false end
        for _,node in ipairs(relic:GetDescendants()) do
            if node:IsA('ParticleEmitter') and node.Enabled then return true end
        end
        return false
    end
    local function relicCarried(relic)
        local main=relic.PrimaryPart or relic:FindFirstChildWhichIsA('BasePart',true)
        return main and main:FindFirstChild('AlignPosition')~=nil
    end
    local function dracoPrompt(prompt,target,root,desc)
        local d=V.Draco
        local cf=dcFrame(target) or dcFrame(prompt and prompt.Parent)
        if not cf then
            d.Stage='NoPosition';d.Status='Không đọc được vị trí '..desc;return true
        end
        local dist=(root.Position-cf.Position).Magnitude
        if dist>8 then
            d.Stage='Approach';d.Status='Đến '..desc..' · '..math.floor(dist)..' studs'
            V.Status=d.Status;moveTo(cf*CFrame.new(0,2,3));return true
        end
        if not prompt or not prompt.Enabled then
            d.Stage='NoPrompt';d.Status='Không có Prompt hoạt động: '..desc;V.Status=d.Status
            return true
        end
        local now=os.clock()
        if now-(d.Seen[prompt] or 0)<3.5 then
            d.Stage='Await';d.Status='Đã tương tác, chờ trạng thái game: '..desc
            V.Status=d.Status;return true
        end
        local fire=api('fireproximityprompt')
        if type(fire)~='function' then
            d.Stage='InputMissing';d.Status='Thiếu fireproximityprompt trên Android'
            V.Status=d.Status;return true
        end
        d.Seen[prompt]=now;d.LastPrompt=now
        local good,err=pcall(fire,prompt,1)
        d.Stage=good and 'Interacting' or 'Error'
        d.Status=good and ('Đã gửi tương tác: '..desc..'; chờ kết quả')
            or ('Prompt bị lỗi: '..tostring(err))
        if good then d.Prompts=d.Prompts+1 else d.Errors=d.Errors+1 end
        V.Status=d.Status
        return true
    end
    function V.HandleDracoTrial(root,active)
        local d=V.Draco
        local map=WS:FindFirstChild('Map')
        local room=map and map:FindFirstChild('DracoTrial')
        if not room then
            d.Stage='StreamWait';d.Status='Đợi DracoTrial tải vào Workspace'
            V.Status=d.Status;return true
        end
        d.Runs=d.Runs+1;d.LastRoom=room.Name
        local gate=room:FindFirstChild('TrialDoor',true)
        local touch=gate and gate:FindFirstChild('DoorTouch',true)
        if not active then
            -- Before the trial starts: follow the real entrance/teleport object.
            if touch and touch:IsA('BasePart') and touch:FindFirstChild('TouchInterest') then
                d.Stage='Door';d.Status='Chờ/đi đến cửa Draco Trial'
                V.Stage='DracoStart';V.Status=d.Status
                if (root.Position-touch.Position).Magnitude>5 then
                    moveTo(touch.CFrame*CFrame.new(0,1,1))
                end
                return true
            end
            local net=RS:FindFirstChild('Remotes')
            local invoke=net and net:FindFirstChild('DracoTrial')
            local now=os.clock()
            if invoke and invoke:IsA('RemoteFunction') and now-d.LastRequest>14 then
                d.LastRequest=now
                local ok,response=pcall(function()return invoke:InvokeServer()end)
                d.Stage=ok and 'StartRequested' or 'StartRejected'
                d.Status=ok and ('Đã yêu cầu DracoTrial; chờ server mở ải')
                    or ('Server chưa nhận DracoTrial: '..tostring(response))
                if not ok then d.Errors=d.Errors+1 end
            else
                d.Stage='AwaitTrial';d.Status='Chờ Trial Draco kích hoạt'
            end
            V.Status=d.Status;return true
        end
        -- The room is active. Reconcile relic state anew each tick; do not
        -- assume prompt success means the relic has been placed.
        local origin=WS:FindFirstChild('_WorldOrigin')
        local models=origin and origin:GetChildren() or {}
        local best,bestDistance,bestIndex,bestCarried=nil,math.huge,nil,false
        for _,obj in ipairs(models) do
            if obj:IsA('Model') and obj.Name=='Relic' and relicEnabled(obj) then
                local idx=relicIndex(obj)
                local cf=dcFrame(obj)
                if idx and cf then
                    local carried=relicCarried(obj)
                    local distance=(root.Position-cf.Position).Magnitude
                    -- Carried relic goes to its matching EndRelic; otherwise
                    -- first pick it up at the matching Relic placement.
                    if carried then distance=distance-100000 end
                    if distance<bestDistance then
                        best,bestDistance,bestIndex,bestCarried=obj,distance,idx,carried
                    end
                end
            end
        end
        if best then
            local name=(bestCarried and 'EndRelic' or 'Relic')..bestIndex
            local target=room:FindFirstChild(name,true)
            d.Slot=bestIndex;d.Carrying=bestCarried
            d.LastRelic=best
            if target then
                V.Stage='DracoRelic'
                local prompt=target:FindFirstChildWhichIsA('ProximityPrompt',true)
                return dracoPrompt(prompt,target,root,name)
            end
            d.Stage='MissingTarget';d.Status='Draco thiếu '..name..' trong Map'
            V.Status=d.Status;return true
        end
        d.Slot=0;d.Carrying=false;d.LastRelic=nil
        if touch and touch:IsA('BasePart') and touch:FindFirstChild('TouchInterest') then
            V.Stage='DracoFinish';d.Stage='Finish'
            d.Status='Không còn Relic sáng; đến DoorTouch để hoàn thành'
            V.Status=d.Status
            if (root.Position-touch.Position).Magnitude>5 then
                moveTo(touch.CFrame*CFrame.new(0,1,0))
            end
            return true
        end
        d.Stage='NoRelic';d.Status='Trial đang chạy nhưng chưa có Relic phát sáng; chờ đồng bộ'
        V.Status=d.Status
        return true
    end
    local function trial(root,race)
        local part,name=trialMarker(race)
        if not part or not part:IsA('BasePart') then return false end
        if (root.Position-part.Position).Magnitude>1250 then return false end
        local trialActive=V.IsTrialTimerVisible()
        -- Marker-only detection previously triggered a "trial" even outside
        -- an actual run. Topi requires the in-game RaidTimer to be visible.
        if not trialActive then
            V.InTrial=false
            if race=='Draco' and V.TempleOpen and Config.V4AutoTrial then
                V.Stage='DracoReady';V.Trial=name
                return V.HandleDracoTrial(root,false)
            end
            return false
        end
        V.Stage='Trial';V.Trial=name;V.InTrial=true
        V.Status='Trial '..name..': HUD xác nhận đang làm ải'
        if V.TrialStartedAt==0 then V.TrialStartedAt=os.clock() end
        if not Config.V4AutoTrial then V.Status='Đã tắt tự làm Trial';return true end
        if race=='Human' or race=='Ghoul' then
            local mob=battleNPC(root,part,race)
            if mob then
                V.LastTrialTarget=mob.Name
                V.Status='Trial '..race..': đánh '..mob.Name..' + tự gom quái'
                V.TrialEngagements=V.TrialEngagements+1
                engage(mob)
            else
                V.Status='Trial '..race..': chờ quái gần marker'
            end
        elseif race=='Skypiea' or race=='Angel' then
            local map=WS:FindFirstChild('Map')
            local sky=map and map:FindFirstChild('SkyTrial')
            local finish=sky and sky:FindFirstChild('FinishPart',true)
            if finish and finish:IsA('BasePart') then
                V.Status='Trial Angel: bay đến FinishPart'
                moveTo(finish.CFrame*CFrame.new(0,3,0))
            else V.Status='Trial Angel: FinishPart chưa tải' end
        elseif race=='Mink' or race=='Rabbit' then
            local start=WS:FindFirstChild('StartPoint')
            if start and start:IsA('BasePart') then
                V.Status='Trial Mink: di chuyển tới StartPoint'
                moveTo(start.CFrame*CFrame.new(0,2,0))
            else V.Status='Trial Mink: StartPoint chưa tải' end
        elseif race=='Fishman' or race=='Shark' then
            local beast=waterTrialBeast(part)
            if beast then
                local br=beast:FindFirstChild('HumanoidRootPart')
                if br then
                    V.Status='Trial Water: tiếp cận Sea Beast'
                    moveTo(CFrame.new(br.Position.X,140,br.Position.Z))
                    if (root.Position-br.Position).Magnitude<410 then
                        -- SeaBeasts are not ordinary Humanoid NPCs; use the
                        -- shared sea skill engine, not engage()'s NPC guard.
                        waterTrialSkills()
                    end
                end
            else V.Status='Trial Water: đợi SeaBeast tại Trial of Water' end
        elseif race=='Cyborg' then
            local map=WS:FindFirstChild('Map')
            local machine=map and map:FindFirstChild('CyborgTrial')
            local prompt=machine and machine:FindFirstChildWhichIsA('ProximityPrompt',true)
            if prompt and prompt.Enabled then
                local base=prompt.Parent
                if base and base:IsA('BasePart') then
                    V.Status='Cyborg: di chuyển tới prompt của puzzle'
                    if (root.Position-base.Position)>Vector3.new(9,9,9).Magnitude then
                        moveTo(base.CFrame*CFrame.new(0,2,0))
                    elseif type(api('fireproximityprompt'))=='function' and
                        os.clock()-(V.LastPuzzlePrompt or 0)>5 then
                        V.LastPuzzlePrompt=os.clock()
                        local okPrompt=pcall(api('fireproximityprompt'),prompt,1)
                        V.Status=okPrompt and 'Cyborg: thử tương tác puzzle' or 'Cyborg: prompt bị từ chối'
                    end
                end
            else V.Status='Cyborg: chưa thấy puzzle/prompt trong dữ liệu đã tải' end
        elseif race=='Draco' then
            return V.HandleDracoTrial(root,true)
        end
        return true
    end
    local function templeRoute(root)
        V.Stage='Temple';V.LastTempleAt=os.clock()
        local dist=(root.Position-templePos.Position).Magnitude
        if dist<1350 then return true end
        -- When unlocked and at the original Ancient Temple access point, try
        -- the documented RaceV4Progress Teleport, confirm only after movement.
        local entranceDist=(root.Position-entrance.Position).Magnitude
        if V.Progress==2 and entranceDist<12 and os.clock()-V.LastTempleTeleport>12 then
            V.LastTempleTeleport=os.clock();V.EntryTries=V.EntryTries+1
            remote('RaceV4Progress','Teleport');V.Actions=V.Actions+1
            V.Status='Đã yêu cầu vào Temple; chờ chuyển vùng'
            return false
        end
        -- Otherwise fly to the real temple coordinates. RegionNavigator v37
        -- permits this instead of an invalid requestEntrance to temple center.
        V.Stage='Ascend';V.Ascents=V.Ascents+1
        V.Status='Bay lên Temple of Time · còn '..math.floor(dist)..' studs'
        moveTo(templePos)
        return false
    end
    function V.Tick()
        if not Config.AutoRaceV4 then
            V.Stage='Off';V.Status='Chưa bật';V.InTrial=false;return
        end
        if STATE.World~=3 then V.Stage='Sea';V.Status='Race V4 cần Sea 3';return end
        if Config.FarmEnabled or Config.AutoRaid or Config.AutoTrickOrTreat or Config.AutoKatakuri then
            V.Stage='Paused';V.Status='Đợi tác vụ khác dừng';V.InTrial=false;return
        end
        local _,_,root,ok=alive()
        if not ok then V.Status='Đợi nhân vật';return end
        local race=raceName();V.Race=race
        V.InTrial=false
        if trial(root,race) then return end
        if V.Draco and V.Draco.Stage~='Idle' and race~='Draco' then
            V.Draco.Stage='Idle';V.Draco.Status='Đã đổi tộc; reset Draco'
        end
        V.TrialStartedAt=0
        if os.clock()-V.LastCheck>10 then
            V.LastCheck=os.clock();V.Checks=V.Checks+1
            local okGate,unlocked=remote('CheckTempleDoor')
            V.TempleOpen=okGate and unlocked==true
            local worked,progress=remote('RaceV4Progress','Check')
            V.Progress=worked and progress or nil
            if not worked then V.Errors=V.Errors+1 end
        end
        if not V.TempleOpen then
            local progress=tonumber(V.Progress)
            if progress==1 then
                V.Stage='Begin';V.Status='Bắt đầu RaceV4Progress'
                if os.clock()-V.LastAction>9 then
                    V.LastAction=os.clock();remote('RaceV4Progress','Begin');V.Actions=V.Actions+1
                end
                return
            elseif progress==2 then
                V.Stage='TempleEntrance';V.Status='Bay tới cổng Ancient Temple'
                if (root.Position-entrance.Position).Magnitude>10 then
                    moveTo(entrance)
                elseif os.clock()-V.LastAction>8 then
                    V.LastAction=os.clock();V.EntryTries=V.EntryTries+1
                    remote('RaceV4Progress','Teleport');V.Actions=V.Actions+1
                end
                return
            elseif progress==3 then
                V.Stage='Continue';V.Status='Tiếp tục RaceV4Progress'
                if os.clock()-V.LastAction>9 then
                    V.LastAction=os.clock();remote('RaceV4Progress','Continue');V.Actions=V.Actions+1
                end
                return
            end
            local map=WS:FindFirstChild('Map')
            local mystic=map and map:FindFirstChild('MysticIsland')
            if mystic then
                V.Stage='BlueGear'
                if not Config.V4AutoGear then V.Status='Tự tìm Blue Gear đang tắt';return end
                local gear,highest=lookupGear()
                if gear and gear.Transparency<1 then
                    V.Gear='Visible';V.Status='Bay tới Blue Gear'
                    moveTo(gear.CFrame*CFrame.new(0,3,0));return
                elseif highest then
                    local target=highest.CFrame*CFrame.new(0,211.88,0)
                    if (root.Position-target.Position).Magnitude>12 then
                        V.Gear='Hidden';V.Status='Bay lên đỉnh Mirage'
                        moveTo(target)
                    elseif Lighting.ClockTime>=18 or Lighting.ClockTime<=6 then
                        V.Status='Đang đợi ánh trăng / kích hoạt Race V3'
                        if Config.V4AutoMoon and os.clock()-V.LastMoon>12 then
                            V.LastMoon=os.clock()
                            local cam=WS.CurrentCamera
                            if cam then pcall(function()
                                cam.CFrame=CFrame.lookAt(cam.CFrame.Position,
                                    cam.CFrame.Position+Lighting:GetMoonDirection())
                            end)end
                            activateRace()
                        end
                    else V.Status='Đợi trời tối trên Mirage' end
                    return
                end
                V.Status='Mirage: chưa xác định được MeshId Gear';return
            end
            V.Stage='Mirage';V.Status='Chưa có Mirage/Blue Gear; không hop server';return
        end
        if not templeRoute(root) then return end
        if os.clock()-(V.LastClockCheck or 0)>19 then
            V.LastClockCheck=os.clock()
            local fine,clock=remote('TempleClock','Check')
            if fine and type(clock)=='table' then
                V.LastClock=clock
                if clock.HadPoint and Config.V4AutoSpendPoints
                    and os.clock()-V.LastGearAttempt>25 then
                    local okSpend,why=V.SpendGearPoint()
                    V.Status=okSpend and 'Gear V4 đã dùng điểm, server xác nhận'
                        or ('Gear V4: '..tostring(why))
                    return
                end
            end
        end
        if Config.V4AutoLever and lever(root) then return end
        local door,reason=V.FindRaceDoor(race)
        V.Door=door;V.DoorStatus=reason
        if not door then
            V.Stage='DoorWait';V.Status='Chưa thấy cửa tộc: '..tostring(reason)
            if (root.Position-templePos.Position).Magnitude>100 then
                moveTo(templePos)
            end
            return
        end
        local distance=(root.Position-door.Position).Magnitude
        V.DoorDistance=distance
        if distance>8 then
            V.Stage='RaceDoor';V.Status='Bay đến cửa '..race..' · còn '..math.floor(distance)..' studs'
            moveTo(door.CFrame*CFrame.new(0,1,2))
            return
        end
        V.Stage='DoorReady'
        local nearby=nearPlayerRaces(door)
        if nearby>=2 then
            V.Status='Cửa '..race..': đã thấy '..nearby..' tộc khác gần cửa, bật T'
            if Config.V4AutoTrial then activateRace() end
        else
            V.Status='Đúng cửa '..race..'; chờ 2 tộc khác ('..nearby..'/2)'
        end
    end
    startLoop('Race V4 progression director v38',.85,function()V.Tick()end)
end

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
        local r=net and net:FindFirstChild("RF/RequestBonusMomentReplication")
        local moduleNet
        if net then
            pcall(function()
                moduleNet=require(net)
                if not r and type(moduleNet)=="table" and type(moduleNet.RemoteFunction)=="function" then
                    r=moduleNet:RemoteFunction("RequestBonusMomentReplication")
                end
            end)
        end
        -- A few game revisions expose the same endpoint under Remotes instead
        -- of Modules.Net.  Prefer the canonical module, then use this fallback.
        if not r then
            local remotes=RS:FindFirstChild("Remotes")
            r=remotes and remotes:FindFirstChild("BonusMomentsRemoteFunction")
        end
        if not r or type(r.InvokeServer)~="function" then
            return false,net and "Secret quest remote not found" or "Modules.Net not loaded"
        end
        local payloads={{Type="GetMomentProgress"},"GetMomentProgress",nil}
        local lastError="Secret quest progress request failed"
        for _,payload in ipairs(payloads) do
            local ok,data=pcall(function()
                if payload==nil then return r:InvokeServer() end
                return r:InvokeServer(payload)
            end)
            if ok and type(data)=="table" then
                STATE.Events.LastQuestCheck=data
                return true,data
            end
            if not ok then lastError=tostring(data) end
        end
        return false,lastError
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
        existing.MaxDistance=Config.ESPDistance
        if label then
            label.Text=name
            local outline=label:FindFirstChildOfClass("UIStroke")
            if outline then outline.Color=color end
        end
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
    local st=Instance.new("UIStroke",t);st.Thickness=1;st.Color=color;st.Transparency=.53
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
        if not cf and STATE.SecretQuestDirector and STATE.SecretQuestDirector.GetAreaPosition then
            local areaPos=STATE.SecretQuestDirector.GetAreaPosition(area)
            if typeof(areaPos)=="Vector3" then cf=CFrame.new(areaPos) end
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
        local moved=moveTo(cf*CFrame.new(0,8,0),{Caller="Secret Quest Manual"})
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
    ADV.Fish={LastCast=0,LastCatch=0,LastBite=0,LastError="None",Request=nil,Generation=0,RetryCatchAt=0,
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
    local function catchBite(rod)
        local fish=ADV.Fish
        local generation=fish.Generation
        local function active()
            return STATE.Alive and Config.AutoFish and Config.FishingAdvanced and Config.FishingAutoCatch
                and fish.Generation==generation and rod and rod.Parent==LP.Character
        end
        if not active() or fish.Catching or fish.HandledRod==rod or os.clock()<fish.RetryCatchAt then return end
        fish.Catching=true
        local ok,err=pcall(function()
            task.wait(.2)
            if not active() then return end
            local started,result=fishCall("Catching",true,{fastBite=true})
            if not started or result==false then error("Catching: "..tostring(result)) end
            task.wait(1.1)
            if not active() then return end
            local sent,reply=fishCall("Catch",1,1,1)
            if not sent or reply==false then error("Catch: "..tostring(reply)) end
            if not active() then return end
            fish.HandledRod=rod
            fish.Catches=fish.Catches+1
            fish.LastCatch=os.clock()
            fish.State="Đã gửi yêu cầu thu cá"
        end)
        fish.Catching=false
        if not ok and active() then
            fish.Failures=fish.Failures+1
            fish.LastError=tostring(err)
            fish.RetryCatchAt=os.clock()+2
        end
    end
    function ADV.BindFishEvents()
        local modules=RS:FindFirstChild("Modules")
        local net=modules and modules:FindFirstChild("Net")
        local event=net and net:FindFirstChild("RE/FishingRemote")
        if not (event and event:IsA("RemoteEvent")) then return false end
        local fish=ADV.Fish
        if fish.Event==event and fish.Connection and fish.Connection.Connected then return true end
        if fish.Connection then fish.Connection:Disconnect() end
        fish.Event=event
        fish.Connection=on(event,event.OnClientEvent,function(player,operation)
            if player==LP and operation=="SpawnFishOnBob" then catchBite(findRod()) end
        end)
        return true
    end

    -- v31 / phone-first fishing: location and casting adapted from the user's Topi
    -- fishing source. No fixed forward-offset guess without validating the water.
    ADV.Fish.LastShoreScan=-math.huge
    ADV.Fish.LastShorePos=nil
    ADV.Fish.LastShoreWater=nil
    ADV.Fish.NextRetry=0
    ADV.Fish.WaterError=""
    function ADV.Fish.GetWaterHeight(position)
        local util=RS:FindFirstChild("Util")
        local mod=util and util:FindFirstChild("GetWaterHeightAtLocation")
        if not mod then return nil end
        local ok,height=pcall(function()
            local fn=require(mod)
            if type(fn)=="function" then return fn(position) end
            return nil
        end)
        if ok then return tonumber(height) end
        return nil
    end
    function ADV.FindFishingShore()
        local _,_,root,ready=alive()
        if not ready then return nil,nil,"character not ready" end
        local params=RaycastParams.new()
        params.FilterType=Enum.RaycastFilterType.Exclude
        local ignored={LP.Character}
        for _,name in ipairs({"Characters","Enemies"}) do
            local v=WS:FindFirstChild(name);if v then table.insert(ignored,v) end
        end
        params.FilterDescendantsInstances=ignored
        -- Inspect shoreline around current island; never blindly TP into the ocean.
        for radius=20,220,20 do
            if not Config.AutoFish or not STATE.Alive then return nil,nil,"cancelled" end
            if radius>20 then task.wait() end -- mobile: spread raycasts over frames
            for sector=0,11 do
                local rad=math.rad(sector*30)
                local dir=Vector3.new(math.cos(rad),0,math.sin(rad))
                local base=root.Position+dir*radius
                local water=ADV.Fish.GetWaterHeight(base)
                if water then
                    local solid=WS:Raycast(Vector3.new(base.X,water+200,base.Z),Vector3.new(0,-500,0),params)
                    if solid and solid.Position.Y>=water-1 then
                        local waterPoint=base+dir*14
                        local waterY=ADV.Fish.GetWaterHeight(waterPoint)
                        local other=waterY and WS:Raycast(Vector3.new(waterPoint.X,waterY+200,waterPoint.Z),Vector3.new(0,-500,0),params)
                        if waterY and (not other or other.Position.Y<waterY-2 or (other.Instance and other.Instance:IsA("Terrain"))) then
                            return solid.Position+Vector3.new(0,3,0),Vector3.new(waterPoint.X,waterY,waterPoint.Z),"shore detected"
                        end
                    end
                end
            end
        end
        return nil,nil,"no shoreline loaded nearby"
    end
    function ADV.ResolveFishingCastPoint(root,rod,charge)
        local character=LP.Character
        local head=character and character:FindFirstChild("Head")
        if not head then return nil,nil,"no head" end
        local ignore={character}
        for _,name in ipairs({"Characters","Enemies"}) do
            local item=WS:FindFirstChild(name);if item then table.insert(ignore,item) end
        end
        local launch=tonumber(rod:GetAttribute("MaxLaunchDistance")) or 85
        launch=math.clamp(launch,30,150)
        local wanted=math.clamp(tonumber(Config.FishingCastDistance) or 42,15,80)
        local ratio=math.clamp((tonumber(charge) or 98)/100,0,1)
        local len=math.min(launch,wanted)*(.65+.35*ratio)
        local direction=root.CFrame.LookVector*len
        local _,position=WS:FindPartOnRayWithIgnoreList(Ray.new(head.Position,direction),ignore)
        position=position or (head.Position+direction)
        local ground,groundPoint=WS:FindPartOnRayWithIgnoreList(
            Ray.new(position+Vector3.new(0,3,0),Vector3.new(0,-500,0)),ignore)
        local water=ADV.Fish.GetWaterHeight(position)
        if groundPoint then
            local target=Vector3.new(position.X,math.max(groundPoint.Y,water or groundPoint.Y),position.Z)
            local waterBody=ground~=nil and game:GetService("CollectionService"):HasTag(ground,"WaterBody")
            local waterTag=false
            pcall(function()
                local mod=RS.FishReplicated.FishingClient.Config
                local cfg=require(mod)
                if cfg.WATER_BODY_TAG and ground then
                    waterTag=game:GetService("CollectionService"):HasTag(ground,cfg.WATER_BODY_TAG)
                end
            end)
            if waterBody or waterTag then return target,true,"water body" end
            if water~=nil and (not ground or groundPoint.Y<=water+1.5) then
                return Vector3.new(target.X,water,target.Z),true,"water surface"
            end
            if water~=nil and groundPoint.Y>water+1.5 then
                return nil,nil,"solid land blocks fishing cast"
            end
        end
        if water~=nil then
            return Vector3.new(position.X,water,position.Z),true,"water-height fallback"
        end
        return nil,nil,"no water found in rod direction"
    end
    function ADV.Fish.AutoApproachWater()
        if not (Config.AutoFish and Config.FishingAutoFindWater) then return false,"auto shore off" end
        if Config.FishingUseSaved and Config.FishingHasPosition then return false,"saved spot selected" end
        if Config.FishingGoVortex then return false,"vortex selected" end
        if os.clock()-ADV.Fish.LastShoreScan>15 then
            ADV.Fish.LastShoreScan=os.clock()
            local bank,water,why=ADV.FindFishingShore()
            ADV.Fish.LastShorePos=bank
            ADV.Fish.LastShoreWater=water
            ADV.Fish.WaterError=tostring(why)
        end
        local bank=ADV.Fish.LastShorePos
        local water=ADV.Fish.LastShoreWater
        if not bank or not water then return false,ADV.Fish.WaterError end
        local _,_,root,ok=alive();if not ok then return false,"respawning" end
        if (root.Position-bank).Magnitude>9 then
            moveTo(CFrame.lookAt(bank,Vector3.new(water.X,bank.Y,water.Z)))
            return true,"moving to fishing shoreline"
        end
        if (root.CFrame.LookVector:Dot((water-root.Position).Unit))<.8 then
            pcall(function() root.CFrame=CFrame.lookAt(root.Position,Vector3.new(water.X,root.Position.Y,water.Z)) end)
        end
        return true,"at fishing shoreline"
    end
    function ADV.CastFishing(manual)
        if ADV.Fish.Busy then return false,"A cast is already in progress" end
        ADV.Fish.Busy=true
        local callOK,success,message=pcall(function()
        if Config.FarmEnabled or Config.AutoSea or Config.AutoRaidCombat then return false,"Stop other activities first" end
        local _,hum,root,ready=alive()
        if not ready then return false,"Character not ready" end
        local rod=findRod()
        if not rod then
            ADV.Fish.State="No fishing rod"
            ADV.Fish.LastError="Fishing rod not found"
            return false,"Fishing rod not found"
        end
        if rod.Parent~=LP.Character then
            pcall(function() hum:EquipTool(rod) end)
            ADV.Fish.State="Equipping rod"
            if manual==true then task.wait(.25) end
            if rod.Parent~=LP.Character then return false,"Equipping fishing rod" end
        end
        local state=rod:GetAttribute("ServerState") or rod:GetAttribute("State")
        if state=="Biting" then
            catchBite(rod)
            return false,"Rod currently Biting"
        end
        if ADV.Fish.Catching then return false,"Rod currently catching" end
        if state and state~="ReeledIn" and state~="Idle" then
            ADV.Fish.State="Rod "..tostring(state)
            return false,"Rod currently "..tostring(state)
        end
        if os.clock()-ADV.Fish.LastCast<math.max(2,tonumber(Config.FishingCastDelay) or 5) then
            return false,"Cast cooldown"
        end
        local current=LP:FindFirstChild("Data")
        local fishData=current and current:FindFirstChild("FishingData")
        local bait=fishData and fishData:GetAttribute("SelectedBait")
        if bait=="None" or bait==nil then
            ADV.Fish.State="Waiting for bait"
            if Config.FishingAutoBait and os.clock()-(ADV.Fish.LastBaitAttempt or 0)>12 then
                ADV.Fish.LastBaitAttempt=os.clock()
                local ok=ADV.LoadBait()
                if not ok and Config.FishingAutoCraftBait then
                    pcall(function()
                        local net=RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
                        local craft=net and net:FindFirstChild("RF/Craft")
                        if craft then craft:InvokeServer("Craft",tostring(Config.FishingBait),1,{}) end
                    end)
                end
            end
            return false,"Fishing bait is not selected (try Load Bait)"
        end
        if not fishingRequest() then return false,"FishingRequest unavailable" end
        ADV.BindFishEvents()
        local point,onWater,why=ADV.ResolveFishingCastPoint(root,rod,98)
        if not point then
            ADV.Fish.State="Searching water"
            ADV.Fish.LastError=tostring(why)
            if Config.FishingAutoFindWater then
                local moved,info=ADV.Fish.AutoApproachWater()
                return false,tostring(info or why)
            end
            return false,"No valid water ahead: "..tostring(why)
        end
        ADV.Fish.LastCast=os.clock()
        ADV.Fish.HandledRod=nil
        ADV.Fish.State="Casting"
        local okStart,started=fishCall("StartCasting")
        if not okStart or started==false then
            ADV.Fish.Failures=ADV.Fish.Failures+1
            ADV.Fish.LastError="StartCasting: "..tostring(started)
            ADV.Fish.State=ADV.Fish.LastError
            return false,ADV.Fish.LastError
        end
        -- Topi waits for the charge to enter the casting phase before positioning the line.
        task.wait(.7)
        if not STATE.Alive or (not Config.AutoFish and manual~=true) or Config.FarmEnabled then return false,"Cancelled" end
        local okCast,answer=fishCall("CastLineAtLocation",point,98,onWater==true)
        if not okCast or answer==false then
            ADV.Fish.Failures=ADV.Fish.Failures+1
            ADV.Fish.LastError="CastLineAtLocation: "..tostring(answer)
            ADV.Fish.State=ADV.Fish.LastError
            ADV.Fish.LastShoreScan=0
            return false,ADV.Fish.LastError
        end
        ADV.Fish.Casts=ADV.Fish.Casts+1
        ADV.Fish.LastError="None"
        ADV.Fish.State="Line deployed / waiting for fish"
        return true,"Cast success, water="..tostring(onWater).." at "..tostring(point)
        end)
        ADV.Fish.Busy=false
        if not callOK then
            ADV.Fish.Failures=ADV.Fish.Failures+1
            ADV.Fish.LastError=tostring(success)
            ADV.Fish.State="Fishing error"
            return false,ADV.Fish.LastError
        end
        return success,message
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
        save();return true,msg.."; bật công tắc Auto Farm để bắt đầu"
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
        Config.SpookyMacroEnabled=false
        for _,redraw in ipairs((STATE.ControlBindings and STATE.ControlBindings.SpookyMacroEnabled) or {}) do pcall(redraw,false) end
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
    if key=="MobMagnet" then value=true end -- V34 automatic, not a manual option
    -- V31: only one autonomous MOVEMENT owner at a time. On mobile a toggle
    -- must not silently fight another director for control of the character.
    if key=="FarmEnabled" and value==true then
        if Config.FarmMode=="Halloween Boss" then
            if not Config.Combat then setFlag("Combat",true) end
            if not Config.AutoEquip then setFlag("AutoEquip",true) end
        end
        for _,other in ipairs({"AutoFish","AutoSecretQuestRoute","AutoRaid"}) do
            if Config[other] then setFlag(other,false) end
        end
        if Config.FarmMode~="Halloween" and Config.AutoTrickOrTreat then
            setFlag("AutoTrickOrTreat",false)
        end
        if not (STATE.FullMelee and STATE.FullMelee.ArmingFarm) and Config.AutoFullMelee then
            setFlag("AutoFullMelee",false)
        end
    end
    if value==true then
        local exclusion={
            AutoFish={"AutoSecretQuestRoute","AutoTrickOrTreat","AutoFullMelee","FarmEnabled","AutoSea","AutoRaidCombat"},
            AutoSecretQuestRoute={"AutoFish","AutoTrickOrTreat","AutoFullMelee","AutoRaid","AutoKatakuri","AutoRaceV4"},
            AutoFullMelee={"AutoFish","AutoSecretQuestRoute","AutoTrickOrTreat","AutoSea","AutoRaidCombat"},
            AutoRaid={"FarmEnabled","AutoFish","AutoKatakuri","AutoTrickOrTreat","AutoRaceV4","AutoSea","AutoFullMelee","AutoSecretQuestRoute"},
            AutoKatakuri={"FarmEnabled","AutoRaid","AutoTrickOrTreat","AutoRaceV4","AutoSea","AutoFish","AutoSecretQuestRoute"},
            AutoRaceV4={"FarmEnabled","AutoKatakuri","AutoRaid","AutoTrickOrTreat","AutoSea","AutoFish","AutoSecretQuestRoute"},
            AutoTrickOrTreat={"FarmEnabled","AutoKatakuri","AutoRaid","AutoRaceV4","AutoSea","AutoFish","AutoSecretQuestRoute"},
        }
        for _,other in ipairs(exclusion[key] or {}) do
            if Config[other] then setFlag(other,false) end
        end
        if key=="AutoTrickOrTreat" and Config.FarmEnabled and Config.FarmMode~="Halloween" then
            setFlag("FarmEnabled",false)
        end
    end
    if key=="AutoSecretQuestRoute" and value==true then
        for _,other in ipairs({"FarmEnabled","AutoSea","AutoSeaBoat","AutoRaidCombat",
            "AutoAdvanceRaid","AutoCollectFruit","AutoChest","AutoBerry",
            "AutoMagnetToken","AutoTrickOrTreat","HalloweenPumpkins",
            "AutoEventCollect","SpookyAutoDungeon"}) do
            if Config[other] then setFlag(other,false) end
        end
        cancelMove()
    end
    if key=="AutoRaid" and value==true then
        -- The full raid toggle must be able to equip and attack its targets.
        if not Config.Combat then setFlag("Combat",true) end
        if not Config.AutoEquip then setFlag("AutoEquip",true) end
    end
    if (key=="AutoFish" or key=="FishingAutoCatch" or key=="FishingAdvanced") and Config[key]~=value
        and STATE.Advanced and STATE.Advanced.Fish then
        local fish=STATE.Advanced.Fish
        fish.Generation=fish.Generation+1
    end
    Config[key]=value
    if key=="AutoSecretQuestRoute" and not value and STATE.SecretQuestDirector
        and STATE.SecretQuestDirector.StopMovement then
        STATE.SecretQuestDirector.StopMovement()
    end
    if key=="AutoRaid" and not value and STATE.RaidDirector and STATE.RaidDirector.Reset then
        STATE.RaidDirector.Reset("Đã tắt Auto Raid")
        STATE.RaidDirector.WasEnabled=false
    end
    if key=="TeleportEnabled" and not value then
        STATE.TeleportDestination=nil
        if STATE.TeleportRecovery then
            STATE.TeleportRecovery.Token=(STATE.TeleportRecovery.Token or 0)+1
            STATE.TeleportRecovery.Pending=false
            STATE.TeleportRecovery.Status="Teleport đang tắt"
        end
        cancelMove()
        STATE.MoveStats.Status="Teleport tắt"
    elseif key=="TeleportEnabled" and value then
        if STATE.TeleportRecovery then STATE.TeleportRecovery.Status="Sẵn sàng" end
        STATE.MoveStats.Status="Idle"
    elseif key=="TeleportAutoRecover" and not value and STATE.TeleportRecovery then
        STATE.TeleportRecovery.Token=(STATE.TeleportRecovery.Token or 0)+1
        STATE.TeleportRecovery.Pending=false
        STATE.TeleportRecovery.Status="Tự sửa lag đang tắt"
    end
    if key=="AutoTrickOrTreat" and value==true then
        for _,other in ipairs({"AutoChest","AutoBerry","AutoMagnetToken", "AutoCollectFruit",
            "HalloweenPumpkins","AutoEventCollect"}) do
            Config[other]=false
            for _,redraw in ipairs(STATE.ControlBindings[other] or {}) do pcall(redraw,false) end
        end
    end
    if value==true and (key=="AutoChest" or key=="AutoBerry" or key=="AutoMagnetToken" or
        key=="AutoCollectFruit" or key=="HalloweenPumpkins" or key=="AutoEventCollect") then
        if STATE.Pickups then STATE.Pickups.Reset() end
        if not Config.FarmEnabled then cancelMove() end
        for _,other in ipairs({"AutoChest","AutoBerry","AutoMagnetToken","AutoCollectFruit","HalloweenPumpkins","AutoEventCollect","AutoTrickOrTreat"}) do
            if other~=key then
                Config[other]=false
                for _,redraw in ipairs(STATE.ControlBindings[other] or {}) do pcall(redraw,false) end
            end
        end
    end
    local fn=STATE.ControlBindings[key]
    if fn then for _,redraw in ipairs(fn) do redraw(value) end end
    if key=="FarmEnabled" and not value then
        if STATE.FastAttackDirector then STATE.FastAttackDirector.Stop() end
        if STATE.RouteDirector then STATE.RouteDirector.Reset(true) end
        cancelMove();if STATE.ReleaseFarmHover then STATE.ReleaseFarmHover() end
        if STATE.MobMagnet then STATE.MobMagnet.Stop() end
        if STATE.NPCFilter then STATE.NPCFilter.Held=nil end
    end
    if key=="FarmMode" and STATE.RouteDirector then STATE.RouteDirector.Reset(true) end
    if key=="AutoTrickOrTreat" and not value and STATE.TrickTreat then STATE.TrickTreat.Stop() end
    -- Auto magnet is released when PvE stops or changes target; no toggle needed.
    if (key=="MobMagnetMatchMode" or key=="MobMagnetRadius" or key=="MobMagnetMax")
        and STATE.MobMagnet then STATE.MobMagnet.NextScan=0 end
    if (key=="ResetTeleport" or key=="ResetTeleportAllowRespawn") and not value
        and STATE.ResetTeleport then STATE.ResetTeleport.Cancel() end
    if key=="SpookyMacroEnabled" and STATE.Spooky then
        if value then
            if not STATE.Spooky.StartMacro() then
                Config[key]=false
                for _,redraw in ipairs(STATE.ControlBindings[key] or {}) do pcall(redraw,false) end
                notice("Macro",tostring(STATE.Spooky.Status),"warn")
            end
        else STATE.Spooky.StopMacro() end
    end
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
    for _,key in ipairs({"AutoFullMelee","MobMagnetNetworkAssist","ResetTeleport",
        "ResetTeleportAllowRespawn","SpookyMacroEnabled"}) do
        Config[key]=false
        for _,redraw in ipairs(STATE.ControlBindings[key] or {}) do pcall(redraw,false) end
    end
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
    if STATE.TrickTreat then STATE.TrickTreat.Stop() end
    cancelMove()
    if STATE.ReleaseFarmHover then STATE.ReleaseFarmHover() end
    if STATE.MobMagnet then STATE.MobMagnet.Stop() end
    if STATE.ResetTeleport then STATE.ResetTeleport.Cancel() end
    Config.SpookyMacroEnabled=false
    for _,redraw in ipairs((STATE.ControlBindings and STATE.ControlBindings.SpookyMacroEnabled) or {}) do pcall(redraw,false) end
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
        TweenSpeed=350,MovementMode="Flight Tween",SmartPortal=false,
        MoveRetargetThreshold=5,MoveRetargetDelay=0.35,
        AttackDelay=0.12,QuestDelay=4,
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
    on(b,b.Activated,function() pulse(b) end)
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
    if func then on(b,b.Activated,func) end
    return b
end
local screen=WS.CurrentCamera and WS.CurrentCamera.ViewportSize or Vector2.new(900,600)
if screen.X<200 or screen.Y<200 then screen=Vector2.new(900,600) end
-- v36: actual window dimensions are smaller; do not shrink Roblox UI text
-- with UIScale (which would make touch controls unreadable on phones).
STATE.MenuDimensions=function(viewport)
    local factor=math.clamp(tonumber(Config.MenuSize) or .84,.76,1)
    local availableWidth=math.max(275,viewport.X-20)
    local availableHeight=math.max(245,viewport.Y-18)
    local w=math.floor(math.min(availableWidth,970*factor,availableWidth*factor))
    local h=math.floor(math.min(availableHeight,680*factor,availableHeight*(.68+.32*factor)))
    if viewport.Y<=440 then
        -- Short landscape phones still need space for page controls and dock.
        h=math.max(h,math.floor(availableHeight*.91))
    end
    return math.min(availableWidth,math.max(275,w)),math.min(availableHeight,math.max(258,h))
end
local W,H=STATE.MenuDimensions(screen)
local compact=UIS.TouchEnabled or screen.X<720 or screen.X<screen.Y
local navW=compact and 0 or 188
STATE.MobileDrawer=false -- compact phones use a labeled navigation drawer
local parent
if type(gethui)=="function" then pcall(function() parent=gethui() end) end
if not parent then pcall(function() parent=game:GetService("CoreGui") end) end
if not parent then parent=LP:WaitForChild("PlayerGui",8) end
if not parent then warn("[andepzai] Cannot create UI");STATE.Alive=false;return end
local gui=mk("ScreenGui",{Name="andepzai_CrystalWhiteGlassV36",IgnoreGuiInset=true,ResetOnSpawn=false,
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
brand.Position=UDim2.fromOffset(67,7);brand.Size=UDim2.new(1,-160,0,29)
brand.TextTruncate=Enum.TextTruncate.AtEnd
local tagline=txt(header,"C R Y S T A L   W H I T E   /   3 8 . 9",9,C.Muted,Enum.Font.GothamBold)
tagline.Position=UDim2.fromOffset(68,37);tagline.Size=UDim2.new(1,-168,0,13)
tagline.TextWrapped=false;tagline.TextTruncate=Enum.TextTruncate.AtEnd
local exitBtn=button(header,"",30,30,C.Glass)
exitBtn.Position=UDim2.new(1,-45,0,15)
vectorIcon(exitBtn,"x",UDim2.fromOffset(6,6),18)
local miniBtn=button(header,"",30,30,C.Glass)
miniBtn.Position=UDim2.new(1,-82,0,15)
vectorIcon(miniBtn,"minus",UDim2.fromOffset(6,6),18)
STATE.DrawerBtn=button(header,"☰",32,32,C.Glass)
STATE.DrawerBtn.Name="MobilePages"
STATE.DrawerBtn.Position=UDim2.new(1,-121,0,14)
STATE.DrawerBtn.TextSize=20
-- All pages remain reachable by a labeled drawer, no invisible icon-only menu.
STATE.DrawerBtn.Visible=compact
if compact then
    brand.Size=UDim2.new(1,-194,0,29)
    tagline.Visible=false
end
local statusCapsule=mk("Frame",{BackgroundColor3=C.Panel,BorderSizePixel=0,
    Position=UDim2.new(1,-188,0,13),Size=UDim2.fromOffset(96,32)},header)
round(statusCapsule,16);liquidSurface(statusCapsule,"bubble")
local statusLabel=txt(statusCapsule,"●  ACTIVE",10,C.Text,Enum.Font.GothamBold)
statusLabel.TextXAlignment=Enum.TextXAlignment.Center
statusLabel.Size=UDim2.fromScale(1,1)
statusCapsule.Visible=not compact
local searchBack=mk("Frame",{Name="Search",BackgroundColor3=C.Panel,
    Position=UDim2.fromOffset(compact and 14 or navW+26,73),Size=UDim2.new(1,compact and -28 or -navW-42,0,37),BorderSizePixel=0},win)
round(searchBack,19);liquidSurface(searchBack,"search")
local searchIcon=vectorIcon(searchBack,"search",UDim2.fromOffset(11,7),22)
local searchBox=mk("TextBox",{Name="SearchField",BackgroundTransparency=1,
    Text="",PlaceholderText="Tìm Farm, Raid, Halloween...",ClearTextOnFocus=false,
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
    Position=UDim2.fromOffset(compact and 13 or 12,compact and 119 or 74),
    Size=compact and UDim2.new(1,-26,1,-177) or UDim2.new(0,navW,1,-132),BorderSizePixel=0},win)
round(side,22);liquidSurface(side,"sidebar")
if not compact then
    local sectionNav=txt(side,"NAVIGATION",9,C.Quiet,Enum.Font.GothamBold)
    sectionNav.Position=UDim2.fromOffset(14,9);sectionNav.Size=UDim2.fromOffset(125,22)
end
local navScroll=mk("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,
    Position=UDim2.fromOffset(4,compact and 8 or 34),
    Size=UDim2.new(1,-8,1,compact and -18 or -69),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.fromOffset(0,0),
    ScrollBarThickness=0,ScrollingDirection=Enum.ScrollingDirection.Y},side)
mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},navScroll)
local sideFoot=txt(side,"V36  •  37 TRANG · GỌN HƠN",10,C.Quiet,Enum.Font.GothamMedium)
sideFoot.TextXAlignment=Enum.TextXAlignment.Center
sideFoot.Size=UDim2.new(1,-8,0,24);sideFoot.Position=UDim2.new(0,4,1,-28)
sideFoot.Visible=not compact
local work=mk("Frame",{BackgroundTransparency=1,
    Position=compact and UDim2.fromOffset(14,119) or UDim2.fromOffset(navW+22,119),
    Size=compact and UDim2.new(1,-28,1,-194) or UDim2.new(1,-navW-36,1,-170)},win)
if compact then
    side.Position=UDim2.fromOffset(13,119)
    side.Size=UDim2.new(1,-26,1,-201)
    side.Visible=false
    navScroll.Position=UDim2.fromOffset(7,8)
    navScroll.Size=UDim2.new(1,-14,1,-18)
    searchBack.Position=UDim2.fromOffset(14,73)
    searchBack.Size=UDim2.new(1,-28,0,37)
end
STATE.ShowMobileDrawer=function(show)
    if not compact then return end
    STATE.MobileDrawer=not not show
    side.Visible=STATE.MobileDrawer
    work.Visible=not STATE.MobileDrawer
    -- Keep search visible while the page drawer is open.
    if STATE.NavResize then STATE.NavResize() end
    STATE.DrawerBtn.Text=STATE.MobileDrawer and "✕" or "☰"
end
on(STATE.DrawerBtn,STATE.DrawerBtn.Activated,function()
    STATE.ShowMobileDrawer(not STATE.MobileDrawer)
end)

local footer=mk("Frame",{BackgroundColor3=C.Panel,BackgroundTransparency=.19,
    Position=UDim2.new(0,13,1,compact and -58 or -46),Size=UDim2.new(1,-26,0,compact and 46 or 32),BorderSizePixel=0},win)
round(footer,13);liquidSurface(footer,"footer")
local footText=txt(footer,"CRYSTAL WHITE  •  liquid glass ui  •  andepzai",10,C.Muted,Enum.Font.GothamMedium)
footText.Position=UDim2.fromOffset(12,0);footText.Size=UDim2.new(1,-22,1,0)
footText.TextWrapped=false;footText.TextTruncate=Enum.TextTruncate.AtEnd
footText.Visible=not compact
-- v35 five direct-entry mobile shortcuts; none opens an intermediate category.
do
local mobileDock=mk("Frame",{Name="ThumbNavDock",BackgroundTransparency=1,
    Position=UDim2.fromOffset(4,2),Size=UDim2.new(1,-8,1,-4),Visible=compact},footer)
local dockButtons={}
local dockSpecs={
    {"home","Chủ","home"},{"farm","Farm","farm"},
    {"secret39","Quest","quests"},{"halloween","Event","ghost"},
    {"raid","Raid","raid"},
}
local function focusDock(key)
    for id,button in pairs(dockButtons) do
        local selected=id==key
        button.BackgroundTransparency=selected and .16 or .97
        button.TextColor3=selected and C.Text or C.Muted
    end
end
for i,spec in ipairs(dockSpecs) do
    local id,label,iconID=spec[1],spec[2],spec[3]
    local tap=mk("TextButton",{Name="Dock_"..id,Text=label,Font=Enum.Font.GothamBold,
        TextSize=11,TextColor3=C.Muted,AutoButtonColor=false,
        TextYAlignment=Enum.TextYAlignment.Bottom,
        BackgroundColor3=C.White,BackgroundTransparency=.97,BorderSizePixel=0,
        Position=UDim2.new((i-1)/5,2,0,0),Size=UDim2.new(.2,-4,1,0)},mobileDock)
    round(tap,12)
    mk("UIPadding",{PaddingBottom=UDim.new(0,3)},tap)
    vectorIcon(tap,iconID,UDim2.new(.5,-9,0,2),18)
    dockButtons[id]=tap
    on(tap,tap.Activated,function()
        pulse(tap)
        if STATE.OpenPage then STATE.OpenPage(id) end
    end)
end
focusDock("home")
STATE.MobileDock=mobileDock
STATE.FocusDock=focusDock
end
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
        if compact and STATE.MobileDrawer and STATE.ShowMobileDrawer then
            STATE.ShowMobileDrawer(false)
        end
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
        Size=UDim2.new(1,0,0,49),LayoutOrder=index,BorderSizePixel=0},navScroll)
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
    local l=txt(nav,title,13,C.Muted,Enum.Font.GothamMedium)
    l.Position=UDim2.fromOffset(48,0);l.Size=UDim2.new(1,-52,1,0)
    l.Visible=true
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
    on(nav,nav.Activated,function()
        pulse(nav)
        if STATE.OpenPage then STATE.OpenPage(id) else choosePage(id) end
    end)
    local frame=mk("ScrollingFrame",{Name="Page_"..id,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),ScrollBarThickness=3,ScrollBarImageColor3=C.Border,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.fromOffset(0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false},work)
    mk("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},frame)
    mk("UIPadding",{PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,2),
        PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,3)},frame)
    local top=mk("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,compact and 88 or 63),LayoutOrder=0},frame)
    local heading=txt(top,title,21,C.Text,Enum.Font.GothamBold)
    heading.Size=UDim2.new(1,0,0,compact and 54 or 32)
    heading.TextYAlignment=Enum.TextYAlignment.Top
    heading.TextWrapped=true
    heading.TextTruncate=Enum.TextTruncate.AtEnd
    local underline=mk("Frame",{BackgroundColor3=C.Accent,BackgroundTransparency=.15,
        Size=UDim2.fromOffset(45,2),Position=UDim2.fromOffset(0,compact and 54 or 35),BorderSizePixel=0},top)
    round(underline,2);themed(underline,"BackgroundColor3")
    local sub=txt(top,subtitle or "",11,C.Quiet)
    sub.Position=UDim2.fromOffset(0,compact and 62 or 40);sub.Size=UDim2.new(1,0,0,compact and 24 or 19)
    sub.TextYAlignment=Enum.TextYAlignment.Top
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
    mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},card)
    mk("UIPadding",{PaddingTop=UDim.new(0,7),PaddingBottom=UDim.new(0,8),
        PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)},card)
    local title=mk("TextLabel",{Text=name:upper(),BackgroundTransparency=1,TextColor3=C.Accent,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
        Font=Enum.Font.GothamBold,TextWrapped=true,Size=UDim2.new(1,-24,0,compact and 42 or 28)},card)
    themed(title,"TextColor3")
    -- v35: section labels have no collapse chevrons.
    local sub
    if description then
        sub=txt(card,description,10,C.Quiet)
        sub.TextYAlignment=Enum.TextYAlignment.Top
        sub.TextWrapped=true
        sub.TextTruncate=Enum.TextTruncate.AtEnd
        sub.Size=UDim2.new(1,0,0,compact and 55 or 40)
    end
    local entry={Card=card,Elements={},Name=name,Header=title,Sub=sub,Collapsed=false}
    entry.SetCollapsed=function(self,collapsed)
        self.Collapsed=not not collapsed
        for _,element in ipairs(self.Elements) do element.Visible=not self.Collapsed and element.Name~="Choices" end
        if self.Sub then self.Sub.Visible=not self.Collapsed end
        self.Header.Text=self.Name:upper()
        -- No secondary expand/collapse animation in the flat hub.
    end
    table.insert(page.Sections,entry)
    return entry
end
local function control(sectionObj,name,height)
    local row=mk("Frame",{Name="Control",BackgroundColor3=C.Row,BackgroundTransparency=.78,
        BorderSizePixel=0,Size=UDim2.new(1,0,0,math.max(height or 47,UIS.TouchEnabled and 55 or 47))},sectionObj.Card)
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
    local top=compact and 9 or (h>=68 and 8 or math.max(6,math.floor((h-28)/2)))
    local bubble=mk("Frame",{Name="FeatureIconGlass",BackgroundColor3=C.White,
        BackgroundTransparency=.49,BorderSizePixel=0,
        Position=UDim2.fromOffset(10,top),Size=UDim2.fromOffset(28,28)},row)
    round(bubble,11);stroke(bubble,C.White,.38,1)
    vectorIcon(bubble,controlGlyph(labelText),UDim2.fromOffset(5,5),18)
    local reserve=labelWidth or 75
    -- On narrow phones descriptions stay above controls instead of crossing them.
    local label=txt(row,labelText,12,C.Text,Enum.Font.GothamMedium)
    label.Position=compact and UDim2.fromOffset(46,8) or UDim2.fromOffset(46,description and (h>=68 and 7 or 3) or 0)
    label.TextTruncate=Enum.TextTruncate.AtEnd
    label.TextYAlignment=compact and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
    label.TextWrapped=true
    label.Size=compact and UDim2.new(1,-56,0,34) or UDim2.new(1,-reserve-54,0,description and 23 or h)
    if description then
        local sub=txt(row,description,10,C.Muted)
        sub.Position=compact and UDim2.fromOffset(46,42) or UDim2.fromOffset(46,h>=68 and 31 or 25)
        sub.TextTruncate=Enum.TextTruncate.AtEnd
        sub.TextYAlignment=compact and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
        sub.TextWrapped=true
        sub.Size=compact and UDim2.new(1,-58,0,26) or UDim2.new(1,-reserve-54,0,18)
    end
    return label
end
local function toggle(s,name,key,description)
    local row=control(s,name,compact and (description and 108 or 84) or (description and 66 or 49))
    tip(row,name,description,76)
    local track=mk("TextButton",{Text="",BackgroundColor3=C.Glass,
        BorderSizePixel=0,Size=UDim2.fromOffset(47,25),Position=compact and UDim2.new(1,-59,1,-35) or UDim2.new(1,-59,.5,-12),
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
        Size=compact and UDim2.fromScale(1,1) or UDim2.fromOffset(70,48),
        Position=compact and UDim2.fromOffset(0,0) or UDim2.new(1,-67,.5,-21)},row)
    on(hit,hit.Activated,function()
        animate(trackScale,{Scale=.94},.07)
        setFlag(key,not Config[key]);pulse(track)
        task.delay(.08,function() if trackScale.Parent then animate(trackScale,{Scale=1},.12) end end)
    end)
    return {Set=function(_,value) setFlag(key,value) end}
end
-- Farm-mode switches are bound to the actual FarmEnabled + FarmMode state.
-- Only one farm mode can be active; selecting another changes that same engine.
local function farmSwitch(s,name,mode,description)
    local row=control(s,name,compact and (description and 108 or 84) or (description and 66 or 49))
    tip(row,name,description,compact and 82 or 118)
    local status=txt(row,"TẮT",10,C.Muted,Enum.Font.GothamBold)
    status.Size=UDim2.fromOffset(38,24)
    status.Position=compact and UDim2.new(1,-100,1,-35) or UDim2.new(1,-100,.5,-12)
    status.TextXAlignment=Enum.TextXAlignment.Right
    status.Visible=not compact
    local track=mk("TextButton",{Name="FarmModeToggle",Text="",AutoButtonColor=false,
        BackgroundColor3=C.White,BorderSizePixel=0,Size=UDim2.fromOffset(48,26),
        Position=compact and UDim2.new(1,-60,1,-37) or UDim2.new(1,-60,.5,-13)},row)
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
        Position=compact and UDim2.fromOffset(0,0) or UDim2.new(1,-72,.5,-23),
        Size=compact and UDim2.fromScale(1,1) or UDim2.fromOffset(74,50)},row)
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
    on(hit,hit.Activated,change)
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
    local row=control(s,name,compact and (description and 118 or 88) or (description and 88 or 69))
    local label=tip(row,name,description,75)
    local val=txt(row,tostring(Config[key]),11,C.Accent,Enum.Font.GothamBold)
    val.Size=UDim2.fromOffset(51,22);val.Position=compact and UDim2.new(1,-61,1,-49) or UDim2.new(1,-61,0,7)
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
                if key=="MenuSize" and STATE.ResizeMenu then STATE.ResizeMenu() end
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
    local row=control(s,name,compact and (description and 110 or 87) or (description and 67 or 49))
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
        local count=math.min(#choices,120)
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
                on(choose,choose.Activated,function()
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
    on(current,current.Activated,function()
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
    local row=control(s,name,compact and (description and 110 or 87) or (description and 71 or 53))
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
    local row=control(s,name,compact and (description and 110 or 87) or (description and 67 or 49))
    tip(row,name,description,compact and 76 or 125)
    local b=button(row,label,94,36,C.Glass,fn)
    b.TextSize=11
    b.TextXAlignment=Enum.TextXAlignment.Center
    vectorIcon(b,"arrow",UDim2.new(1,-25,.5,-9),18)
    b.Position=compact and UDim2.new(1,-104,1,-43) or UDim2.new(1,-104,.5,-18)
    return b
end
local function info(s,body)
    local width=math.max(110,W-(compact and 36 or (navW+36))-84)
    local height=54
    pcall(function()
        local service=game:GetService("TextService")
        height=math.max(54,service:GetTextSize(tostring(body),11,Enum.Font.Gotham,Vector2.new(width,1000)).Y+20)
    end)
    local row=control(s,body,math.clamp(height,54,310))
    vectorIcon(row,"info",UDim2.fromOffset(11,17),18)
    local lbl=txt(row,body,11,C.Muted)
    lbl.TextWrapped=true;lbl.TextYAlignment=Enum.TextYAlignment.Top
    lbl.Position=UDim2.fromOffset(39,9);lbl.Size=UDim2.new(1,-49,1,-17)
    return lbl
end
local function statBox(s,name,init)
    local row=control(s,name,compact and 70 or 49)
    vectorIcon(row,controlGlyph(name),UDim2.fromOffset(12,compact and 9 or 15),18)
    local left=txt(row,name,12,C.Muted,Enum.Font.GothamMedium)
    left.Position=compact and UDim2.fromOffset(39,5) or UDim2.fromOffset(39,0)
    left.Size=compact and UDim2.new(1,-50,0,32) or UDim2.new(.48,0,1,0)
    left.TextYAlignment=compact and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
    local right=txt(row,init or "--",compact and 12 or 14,C.Accent,Enum.Font.GothamBold)
    right.Position=compact and UDim2.fromOffset(39,41) or UDim2.new(.6,0,0,0)
    right.Size=compact and UDim2.new(1,-50,0,29) or UDim2.new(.37,0,1,0)
    right.TextXAlignment=compact and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    right.TextYAlignment=compact and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center
    right.TextTruncate=Enum.TextTruncate.AtEnd
    themed(right,"TextColor3")
    return function(v) right.Text=tostring(v) end
end
-- Search every navigation page, not only the currently selected one.
on(searchBox,searchBox:GetPropertyChangedSignal("Text"),function()
    local q=searchBox.Text:lower():match("^%s*(.-)%s*$") or ""
    local firstHit=nil
    local selectedHit=false
    for id,page in pairs(STATE.Pages) do
        local pageHit=(q=="") or page.Title:lower():find(q,1,true)~=nil
            or (page.NavTitle and page.NavTitle:lower():find(q,1,true)~=nil)
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
STATE.FloatDrag={Dragging=false,Moved=false,Start=nil,Input=nil,DownPos=nil,IgnoreClick=false}
local floating=button(gui,"",UIS.TouchEnabled and 50 or 46,UIS.TouchEnabled and 50 or 46,C.Row,nil)
floating.Name="andepzai_Draggable_A"
floating.AnchorPoint=Vector2.new(.5,.5)
floating.Position=UDim2.fromScale(math.clamp(Config.FloatButtonX,UIS.TouchEnabled and .07 or .05,UIS.TouchEnabled and .93 or .95),
    math.clamp(Config.FloatButtonY,UIS.TouchEnabled and .07 or .05,UIS.TouchEnabled and .93 or .95))
floating.Text=""
STATE.FloatingLetter=txt(floating,"A",26,C.Text,Enum.Font.GothamBold)
STATE.FloatingLetter.Name="CenteredLauncherLetter"
STATE.FloatingLetter.AnchorPoint=Vector2.new(.5,.5)
STATE.FloatingLetter.Position=UDim2.fromScale(.5,.5)
STATE.FloatingLetter.Size=UDim2.fromScale(1,1)
STATE.FloatingLetter.TextWrapped=false
STATE.FloatingLetter.TextXAlignment=Enum.TextXAlignment.Center
STATE.FloatingLetter.TextYAlignment=Enum.TextYAlignment.Center
STATE.FloatingLetter.Active=false
STATE.FloatingLetter.ZIndex=floating.ZIndex+2
floating.Visible=Config.FloatingButton
round(floating,20);themed(stroke(floating,C.Accent,.1,1.5),"Color")
local floatScale=mk("UIScale",{Scale=1},floating)
-- Dragging the launcher does not click it. Supports mouse + touch, persists position.
on(floating,floating.InputBegan,function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        STATE.FloatDrag.Dragging=true;STATE.FloatDrag.Moved=false
        STATE.FloatDrag.Input=input;STATE.FloatDrag.Start=floating.Position;STATE.FloatDrag.DownPos=input.Position
    end
end)
on(UIS,UIS.InputChanged,function(input)
    if not STATE.FloatDrag.Dragging or not STATE.FloatDrag.DownPos or not STATE.FloatDrag.Start then return end
    if input.UserInputType~=Enum.UserInputType.MouseMovement and
       not (input.UserInputType==Enum.UserInputType.Touch and input==STATE.FloatDrag.Input) then return end
    local delta=input.Position-STATE.FloatDrag.DownPos
    if delta.Magnitude>8 then STATE.FloatDrag.Moved=true end
    if not STATE.FloatDrag.Moved then return end
    local camera=WS.CurrentCamera
    local size=camera and camera.ViewportSize or Vector2.new(900,600)
    local pad=floating.AbsoluteSize.X/2+5
    local x=math.clamp(STATE.FloatDrag.Start.X.Scale*size.X+delta.X,pad,math.max(pad+1,size.X-pad))
    local y=math.clamp(STATE.FloatDrag.Start.Y.Scale*size.Y+delta.Y,pad,math.max(pad+1,size.Y-pad))
    floating.Position=UDim2.fromScale(x/math.max(1,size.X),y/math.max(1,size.Y))
end)
on(UIS,UIS.InputEnded,function(input)
    if STATE.FloatDrag.Dragging and (input==STATE.FloatDrag.Input or
        (STATE.FloatDrag.Input and STATE.FloatDrag.Input.UserInputType==Enum.UserInputType.MouseButton1 and
        input.UserInputType==Enum.UserInputType.MouseButton1)) then
        STATE.FloatDrag.Dragging=false;STATE.FloatDrag.Input=nil
        if STATE.FloatDrag.Moved then
            Config.FloatButtonX=floating.Position.X.Scale
            Config.FloatButtonY=floating.Position.Y.Scale
            save()
        else
            setWindowVisible(not STATE.WindowVisible)
        end
    end
end)

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
        dragging=true;STATE.HeaderDragInput=input;originPos=input.Position;winPos=win.Position
    end
end)
on(UIS,UIS.InputChanged,function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or
        (input.UserInputType==Enum.UserInputType.Touch and input==STATE.HeaderDragInput)) then
        local delta=input.Position-originPos
        win.Position=UDim2.new(winPos.X.Scale,winPos.X.Offset+delta.X,winPos.Y.Scale,winPos.Y.Offset+delta.Y)
        shadow.Position=UDim2.new(win.Position.X.Scale,win.Position.X.Offset+8,win.Position.Y.Scale,win.Position.Y.Offset+10)
        glow.Position=UDim2.new(win.Position.X.Scale,win.Position.X.Offset+5,win.Position.Y.Scale,win.Position.Y.Offset+5)
    end
end)
on(UIS,UIS.InputEnded,function(input)
    if input==STATE.HeaderDragInput then dragging=false;STATE.HeaderDragInput=nil end
end)
on(miniBtn,miniBtn.Activated,function()
    setWindowVisible(false)
end)
local function destroy()
    if not STATE.Alive then return end
    STATE.Alive=false
    Config.AutoSecretQuestRoute=false
    if STATE.TrickTreat then STATE.TrickTreat.Stop() end
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
    if env.__ANDEPZAI_V38==STATE then env.__ANDEPZAI_V38=nil end
end
STATE.Destroy=destroy
on(exitBtn,exitBtn.Activated,destroy)
on(UIS,UIS.InputBegan,function(input,gpe)
    if gpe then return end
    if input.KeyCode==Enum.KeyCode[Config.ToggleKey] then
        setWindowVisible(not win.Visible)
    end
end)

--[[
  ANDEPZAI v31 / MOBILE SECRET QUEST DIRECTOR
  Source: Topi Halloween HiddenEvent controller (user-supplied).
  This is a NEW, smaller state machine; it does not execute any external source.
  Supported: live progress, prioritization, navigation, active-moment observation,
  multiple multi-stage interactions, quest statuses and cooldowns.
  Other puzzles remain unsupported rather than claiming automatic completion.
]]
function STATE.InitSecretQuestDirector()
    local D={Enabled=false,Status="Tắt",Stage="Chờ bật",Current="None",Completed=0,Total=39,
        LastError="Không",LastPoll=-math.huge,Progress={},Moments={},Missing={},LastAction={},
        Skipped={},Actions=0,Failed=0,Reached=0,LastQuestAt=0,NextMove=0,
        LastStageAt=0,Supported=0,ActiveCount=0,LastProgressError="Chưa đọc",ProgressRaw=nil,
        CompletedNames={},ProgressAttempts=0,LastGuideWarm=-math.huge,LastMomentPoll=-math.huge,
        Lookout={Token=nil,Manifest=nil,Round=0,NextAt=0,StartedAt=0,Errors=0}}
    STATE.SecretQuestDirector=D
    local supported={
        ["Archaeologist's Tablet"]=true,["Prickly Harvest"]=true,
        ["Windmill Maintenance"]=true,["Fountain Pipe Repair"]=true,
        ["Fountain Wire Repair"]=true,["King's Apprentice"]=true,
        ["Lookout"]=true,["Rescue Hasan"]=true,
        ["Breaking the Ice"]=true,["Evil Slimes"]=true,
        ["Electric Fighting Teacher"]=true,
        ["Escape from Alcatraz"]=true,["Don Megalo"]=true,
        ["Crowd Favorite"]=true,["Magma Ore Extraction"]=true,
        ["Early Access"]=true,["X Marks The Spot"]=true,
        ["Fortress Flagpole"]=true,["Zipline Repair"]=true,
    }
    for _ in pairs(supported) do D.Supported=D.Supported+1 end
    -- Source Topi: BonusMomentsRemoteEvent distributes Setup/State and objective locations.
    D.EventState={}
    do
        local remotes=RS:FindFirstChild("Remotes")
        local bus=remotes and remotes:FindFirstChild("BonusMomentsRemoteEvent")
        if bus and bus:IsA("RemoteEvent") then
            on(bus,bus.OnClientEvent,function(quest,event,...)
                if not STATE.Alive or type(quest)~="string" then return end
                local data=table.pack(...)
                local st=D.EventState[quest] or {}
                D.EventState[quest]=st
                st.LastEvent=tostring(event)
                st.Updated=os.clock()
                if quest=="Fortress Flagpole" then
                    if event=="Setup" then
                        if typeof(data[1])=="CFrame" then st.Flag=data[1].Position end
                        if typeof(data[2])=="CFrame" then st.Rope=data[2].Position end
                        st.HasRope=data[4]==true
                    elseif event=="Started" and typeof(data[1])=="CFrame" then
                        st.Rope=data[1].Position
                    elseif event=="RopeTaken" then st.HasRope=true end
                elseif quest=="Zipline Repair" and event=="Setup" then
                    if typeof(data[1])=="CFrame" then st.Pickup=data[1].Position end
                    st.Target=data[5];st.Source=data[6]
                elseif quest=="X Marks The Spot" then
                    if event=="State" then
                        st.Stage=data[1]
                        if typeof(data[2])=="CFrame" then st.Target=data[2].Position end
                        if typeof(data[5])=="CFrame" then st.Piece=data[5].Position end
                    elseif event=="Setup" then
                        if typeof(data[1])=="CFrame" then st.Pickup=data[1].Position end
                    elseif event=="MapDropped" then
                        if typeof(data[2])=="CFrame" then st.Pickup=data[2].Position end
                    end
                elseif quest=="Don Megalo" and event=="GateUnlocked" then
                    st.GateOpen=true
                end
            end)
        end
    end
    local pauseNames={"FarmEnabled","AutoSea","AutoSeaBoat","AutoRaid","AutoRaidCombat","AutoAdvanceRaid",
        "AutoKatakuri","AutoRaceV4",
        "AutoCollectFruit","AutoChest","AutoBerry","AutoMagnetToken","AutoTrickOrTreat",
        "HalloweenPumpkins","AutoEventCollect","SpookyAutoDungeon"}
    local function nameFor(i) return STATE.Advanced.SecretQuestNames[i] end
    local function questKey(text)
        -- Progress keys are often Sea1/Island/Quest Name, whereas the UI and
        -- moment controller use just Quest Name. Keep the final path component.
        local key=norm(tostring(text or "")):gsub("^sea%s*%d+[/_:]",""):gsub("^bonusmoment[/_:]","")
        return (key:match("([^/]+)$") or key):gsub("^%s+",""):gsub("%s+$","")
    end
    D.QuestKey=questKey
    local function momentByName(name)
        local direct=D.Moments[name]
        if type(direct)=="table" then return direct end
        local wanted=questKey(name)
        for key,obj in pairs(D.Moments) do
            if type(obj)=="table" and (key==name or
                (type(key)=="string" and (key:sub(-#name)==name or questKey(key)==wanted)) or
                questKey(obj.Name)==wanted or questKey(obj.QuestName)==wanted or
                questKey(obj.DisplayName)==wanted or questKey(obj.InternalName)==wanted) then
                return obj
            end
        end
        return nil
    end
    local function location(obj)
        if not obj then return nil end
        if typeof(obj)=="Vector3" then return obj end
        if typeof(obj)=="CFrame" then return obj.Position end
        if typeof(obj)~="Instance" then return nil end
        if obj:IsA("BasePart") then return obj.Position end
        if obj:IsA("Model") then
            local ok,cf=pcall(function()return obj:GetPivot()end)
            if ok then return cf.Position end
        end
        return nil
    end
    local function arrive(pos,distance)
        if typeof(pos)~="Vector3" then return false end
        local _,hum,root,ready=alive()
        if not ready then D.Status="Nhân vật chưa sẵn sàng";return false end
        distance=distance or 11
        if (pos-root.Position).Magnitude<=distance then
            -- Stop only our own tween as soon as the requested interaction
            -- radius is reached. Hold vertical speed near small objectives so
            -- gravity cannot restart the same approach every tick.
            local mover=STATE.Mover
            if mover and mover.Active and mover.Caller=="Secret Quest Mobile" then cancelMove() end
            if distance<=25 and hum and not hum.Sit and STATE.EnsureFlight then
                STATE.EnsureFlight(root)
                D.HoldingRoot=root
            end
            D.Reached=D.Reached+1
            return true
        end
        if D.HoldingRoot then
            if not (STATE.Mover and STATE.Mover.Active) and STATE.StopFlight then STATE.StopFlight() end
            D.HoldingRoot=nil
        end
        if os.clock()>=D.NextMove then
            D.NextMove=os.clock()+.85
            -- An offset of (0,3,5) was outside a 5-stud interaction radius,
            -- causing an endless re-approach. Keep the goal inside the radius.
            local lift=math.min(3,math.max(0,distance*.25))
            moveTo(CFrame.new(pos+Vector3.new(0,lift,0)),
                {Caller="Secret Quest Mobile",HoldAtEnd=distance<=25})
        end
        return false
    end
    function D.StopMovement()
        local recovery=STATE.TeleportRecovery
        if recovery and recovery.Pending and recovery.Caller=="Secret Quest Mobile" then
            recovery.Token=(recovery.Token or 0)+1;recovery.Pending=false
        end
        local mover=STATE.Mover
        if mover and mover.Active and mover.Caller=="Secret Quest Mobile" then
            cancelMove()
        elseif D.HoldingRoot and not (mover and mover.Active) and STATE.StopFlight then
            STATE.StopFlight()
        end
        D.HoldingRoot=nil
    end
    local function nearQuestPart(part,dist)
        local pos=location(part)
        if not pos then D.Stage="Chưa có vật thể tương tác";return false end
        if not arrive(pos,dist or 13) then
            D.Stage="Đang đến "..tostring((typeof(part)=="Instance" and part.Name) or "mục tiêu")
            return false
        end
        return true
    end
    local function invoke(moment,...)
        if not moment or type(moment.InvokeServer)~="function" then return false,"Moment không hỗ trợ InvokeServer" end
        local args=table.pack(...)
        local ok,data=pcall(function() return moment:InvokeServer(table.unpack(args,1,args.n)) end)
        if ok then D.Actions=D.Actions+1 else D.Failed=D.Failed+1 end
        return ok,data
    end
    local function fire(moment,...)
        if not moment or type(moment.FireServer)~="function" then return false,"Moment không hỗ trợ FireServer" end
        local args=table.pack(...)
        local ok,data=pcall(function()return moment:FireServer(table.unpack(args,1,args.n))end)
        if ok then D.Actions=D.Actions+1 else D.Failed=D.Failed+1 end
        return ok,data
    end
    local function cooldown(name,action,seconds)
        local key=name..":"..action
        local now=os.clock()
        if now<(D.LastAction[key] or 0) then return false end
        D.LastAction[key]=now+(seconds or 2)
        return true
    end
    local function strike(part,name)
        if not part or not part:IsA("BasePart") then return false end
        if not nearQuestPart(part,18) then return true end
        if not cooldown(name,"hit",.50) then return true end
        local r=getCombatRemotes()
        if not(r and r.Attack and r.Hit) then D.Stage="Không có RegisterAttack/RegisterHit";return false end
        local char,hum,root,ok=alive()
        if ok and hum then
            local tool=char:FindFirstChildOfClass("Tool")
            if not tool then
                local bp=LP:FindFirstChild("Backpack")
                tool=bp and bp:FindFirstChildOfClass("Tool")
                if tool then pcall(function() hum:EquipTool(tool) end) end
            end
        end
        local a=pcall(function()r.Attack:FireServer(.3);r.Hit:FireServer(part)end)
        if a then D.Actions=D.Actions+1 else D.Failed=D.Failed+1 end
        D.Stage="Đang phá / đánh "..part.Name
        return true
    end
    local function findNamed(root,needle)
        if not root then return nil end
        return root:FindFirstChild(needle,true)
    end
    local function findTag(root)
        if not root then return nil end
        local _,_,hrp,ok=alive()
        if not ok then return nil end
        local best,bestD=nil,math.huge
        for _,p in ipairs(root:GetDescendants()) do
            if p:IsA("BasePart") and (p:HasTag("M1HitRegistry") or p.Name:lower():find("target",1,true)) then
                local d=(p.Position-hrp.Position).Magnitude
                if d<bestD then best,bestD=p,d end
            end
        end
        return best
    end
    local function refreshProgress()
        if os.clock()-D.LastPoll<12 then return end
        D.LastPoll=os.clock()
        D.ProgressAttempts=D.ProgressAttempts+1
        local ok,result=STATE.CheckSecretQuestProgress()
        if not ok then
            D.LastProgressError=tostring(result)
            return
        end
        local progress=type(result)=="table" and result.Data
        if progress==nil and type(result)=="table" then
            for key in pairs(result) do
                if type(key)=="string" and key:match("^Sea1/") then progress=result;break end
            end
        end
        if type(progress)~="table" then
            D.LastProgressError="Server chưa trả bảng tiến độ hợp lệ"
            return
        end
        local completed={}
        for key,value in pairs(progress) do
            local done=value==true
            if type(value)=="table" then
                done=value.Completed==true or value.completed==true or value.Done==true
                    or value.done==true or value.Claimed==true or value.claimed==true
                    or tostring(value.Status or value.status):lower()=="completed"
            end
            if done then
                completed[questKey(key)]=true
            end
        end
        local count=0
        for _,name in ipairs(STATE.Advanced.SecretQuestNames) do
            if completed[questKey(name)] then count=count+1 end
        end
        D.CompletedNames=completed
        D.ProgressRaw=result
        D.Progress=progress
        D.Completed=count
        D.LastProgressError="Không"
    end
    local function isComplete(name)
        return D.CompletedNames and D.CompletedNames[questKey(name)]==true
    end
    local function refreshMoments()
        -- The controller only populates its table after the guide has been
        -- touched once in a fresh server.  This warm-up mirrors the reference
        -- scripts' four Sea-1 guide probes, but is rate-limited and optional.
        if os.clock()-D.LastGuideWarm>25 then
            D.LastGuideWarm=os.clock()
            pcall(function()
                local net=RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
                local mod=net and require(net)
                local guide=mod and type(mod.RemoteFunction)=="function" and mod:RemoteFunction("BonusMomentsGuide")
                if not guide then
                    local remotes=RS:FindFirstChild("Remotes")
                    guide=remotes and remotes:FindFirstChild("BonusMomentsRemoteFunction")
                end
                if guide and type(guide.InvokeServer)=="function" then
                    for _,npcId in ipairs({"DesertMerchant","TravelDressrosa","FrozenAbilityTeacher","SkyAngelGuard"}) do
                        pcall(function() guide:InvokeServer("InteractQuestGiver",npcId) end)
                    end
                end
            end)
        end
        local ok,list=pcall(function()
            local controllers=RS:FindFirstChild("Controllers")
            local module=controllers and controllers:FindFirstChild("BonusMomentsController")
            if not module then return {} end
            local controller=require(module)
            if type(controller)~="table" or type(controller.GetLoadedMoments)~="function" then return {} end
            return controller:GetLoadedMoments()
        end)
        if ok and type(list)=="table" then D.Moments=list;D.LastMomentPoll=os.clock()
        elseif not ok then D.LastError="GetLoadedMoments: "..tostring(list) end
        local n=0
        for _,v in pairs(D.Moments) do
            if type(v)=="table" and v.Active==true then n=n+1 end
        end
        D.ActiveCount=n
    end
    local function questArea(name)
        for i,n in ipairs(STATE.Advanced.SecretQuestNames) do
            if name==n then return STATE.Advanced.SecretQuestAreas[i] end
        end
        return ""
    end
    local function findArea(area)
        -- Location parts are broad region centres, often below the ground; map
        -- model pivots can be far above or away from the playable landing. Use
        -- the existing Sea 1 travel anchors for island-streaming visits.
        local names={Fountain="Fountain City",Sky="Lower Skylands",["Upper Sky"]="Upper Skylands"}
        local canonical=names[area] or area
        local reference=STATE.ReferenceData and STATE.ReferenceData.Islands
        local cf=reference and reference["Sea 1"] and reference["Sea 1"][canonical]
        if typeof(cf)=="CFrame" then return cf.Position end
        local map=WS:FindFirstChild("Map")
        local synonyms={
            ["Pirate Village"]={"Pirate","Pirate Village"},
            ["Frozen Village"]={"Ice","Frozen Village"},
            ["Fountain"]={"Fountain","Fountain City"},
            ["Marine Fortress"]={"MarineBase","Marine Fortress"},
            ["Upper Sky"]={"SkyArea2","Upper Sky"},
            ["Sky"]={"Sky","SkyArea1","SkyArea2"},
            ["Underwater City"]={"Fishmen","Underwater City"},
            ["Middle Town"]={"Town","Middle Town"},
            ["Magma Village"]={"Magma","Magma Village"},
            ["Jungle"]={"Jungle"},["Desert"]={"Desert"},
            ["Colosseum"]={"Colosseum"},["Prison"]={"Prison"}
        }
        local locs=WS:FindFirstChild("_WorldOrigin")
        locs=locs and locs:FindFirstChild("Locations")
        for _,alias in ipairs(synonyms[area] or {area}) do
            local item=(locs and locs:FindFirstChild(alias)) or (map and map:FindFirstChild(alias))
            local pos=location(item)
            if pos then return pos end
        end
        -- Streaming can leave Map empty while the travel catalog still has a
        -- safe island anchor.  Use it only as a navigation fallback; the
        -- moment handler still waits for live objects before interacting.
        STATE.BuildTravelCatalog()
        local wanted=norm(area)
        for key,entry in pairs(STATE.TravelCatalog and STATE.TravelCatalog.IslandPoints or {}) do
            local label=norm(key)
            if label==wanted or label:find(wanted,1,true) or wanted:find(label,1,true) then
                return entry.CFrame.Position
            end
        end
        return nil
    end
    D.GetAreaPosition=findArea
    local function findNpc(name)
        local wanted=norm(name)
        for _,folder in ipairs({WS:FindFirstChild("NPCs"),WS:FindFirstChild("_WorldOrigin"),
            WS:FindFirstChild("Map"),RS:FindFirstChild("NPCs")}) do
            if folder then
                for _,obj in ipairs(folder:GetDescendants()) do
                    if (obj:IsA("Model") or obj:IsA("BasePart")) and
                        (norm(obj.Name)==wanted or norm(obj.Name):find(wanted,1,true)) then
                        return obj
                    end
                end
            end
        end
        STATE.BuildTravelCatalog()
        for key,entry in pairs(STATE.TravelCatalog and STATE.TravelCatalog.NPCPoints or {}) do
            if norm(key)==wanted or norm(key):find(wanted,1,true) then
                return entry.CFrame
            end
        end
        return nil
    end
    local function doQuest(name,moment)
        -- Concrete per-quest actions adapted from the detailed Topi quest logic (not runtime verified).
        -- All steps require a local visible object or an active moment.
        local map=WS:FindFirstChild("Map")
        local worldOrigin=WS:FindFirstChild("_WorldOrigin")
        if name=="Escape from Alcatraz" then
            local prisoners=type(moment.MiscData)=="table" and moment.MiscData.Prisoners or nil
            if type(prisoners)~="table" then return "Đợi server gửi danh sách tù nhân" end
            local best,bestKey,distance=nil,nil,math.huge
            local _,_,playerRoot,ready=alive();if not ready then return "Chờ hồi sinh" end
            for key,item in pairs(prisoners) do
                local model=type(item)=="table" and item.Model
                if typeof(model)=="Instance" and model.Parent then
                    local pos=location(model)
                    local d=pos and (pos-playerRoot.Position).Magnitude or math.huge
                    if d<distance then best,bestKey,distance=model,key,d end
                end
            end
            if not best then return "Chờ tù nhân xuất hiện" end
            if not nearQuestPart(best,12) then return "Đang tìm tù nhân cần bắt" end
            if not (D.Prisoner==best and os.clock()-(D.ProvokedAt or 0)<25) then
                if cooldown(name,"Provoke",1.5) then
                    invoke(moment,"Provoke",bestKey)
                    D.Prisoner=best;D.ProvokedAt=os.clock()
                end
                return "Khiêu khích tù nhân "..tostring(bestKey)
            end
            local root=best:FindFirstChild("HumanoidRootPart") or best.PrimaryPart
            if root then strike(root,name) end
            return "Đang bắt tù nhân "..tostring(bestKey)
        elseif name=="Don Megalo" then
            local prison=map and map:FindFirstChild("Prison")
            local locs=prison and prison:FindFirstChild("BonusMoment_Locations",true)
            local state=D.EventState[name] or {}
            D.EventState[name]=state
            if cooldown(name,"init",30) then fire(moment,"Init") end
            local enemies=WS:FindFirstChild("Enemies")
            for _,mob in ipairs(enemies and enemies:GetChildren() or {}) do
                if STATE.IsAliveNPC(mob) and (mob.Name:find("Megalo Guard") or mob.Name:find("Bouncer")) then
                    local root=mob:FindFirstChild("HumanoidRootPart")
                    if root and nearQuestPart(root,25) then strike(root,name) end
                    return "Đánh vệ sĩ Don Megalo"
                end
            end
            local function spot(id)
                local item=locs and locs:FindFirstChild(id,true)
                return location(item)
            end
            local cape=spot("SharkCape")
            if state.GateOpen and cape then
                if arrive(cape,8) and cooldown(name,"takecape",3) then
                    fire(moment,"BouncerReady")
                    local ok,result=invoke(moment,"TakeCape")
                    if ok and result==true then invoke(moment,"ClaimCape") end
                end
                return "Lấy áo choàng cá mập"
            end
            local key=spot("Key")
            if key and not state.HasKey then
                if arrive(key,8) and cooldown(name,"takekey",3) then
                    local ok,result=invoke(moment,"TakeKey")
                    if ok and result==true then state.HasKey=true end
                end
                return "Lấy chìa khóa nhà tù"
            end
            local gate=spot("MegaloGate")
            if gate then
                if arrive(gate,8) and cooldown(name,"unlock",3) then
                    local ok,result=invoke(moment,"Unlock")
                    if ok and result==true then state.GateOpen=true end
                end
                return "Mở cổng Don Megalo"
            end
            return "Đợi các đối tượng tù giam xuất hiện"
        elseif name=="Crowd Favorite" then
            local ring=WS:FindFirstChild("Ring")
            if not ring then
                local col=map and map:FindFirstChild("Colosseum")
                ring=col and col:FindFirstChild("Ring",true)
            end
            local target=ring and findTag(ring)
            if target then strike(target,name);return "Đánh bia biểu diễn Colosseum" end
            return "Đợi bia vòng đấu xuất hiện"
        elseif name=="Magma Ore Extraction" then
            local magma=map and map:FindFirstChild("Magma")
            local elevator=magma and magma:FindFirstChild("BackArea")
            elevator=elevator and elevator:FindFirstChild("Elevator")
            local part=elevator and elevator:FindFirstChild("Part")
            if not part then return "Chờ thang máy hầm Magma" end
            if nearQuestPart(part,8) and cooldown(name,"elevator",7) then
                local _,_,root,valid=alive()
                if valid and type(firetouchinterest)=="function" then
                    pcall(firetouchinterest,root,part,0)
                    task.wait(.15)
                    pcall(firetouchinterest,root,part,1)
                    D.Actions=D.Actions+1
                end
            end
            return "Đi thang máy vào mỏ Magma"
        elseif name=="Early Access" then
            local E=D.EarlyAccess or {Updated=-math.huge,Stage=0,Available=false}
            D.EarlyAccess=E
            if os.clock()-E.Updated>8 then
                E.Updated=os.clock()
                local ok,available=invoke(moment,"IsAvailable")
                E.Available=ok and available==true
                local ok2,stage=invoke(moment,"GetState")
                if ok2 then E.Stage=tonumber(stage) or E.Stage end
            end
            if E.Stage==0 and not E.Available then return "Chờ robotmega ghé Middle Town" end
            local npc=findNpc("robotmega superfan")
            local npcPos=location(npc) or Vector3.new(-1044.5,26,1683)
            local function doActions(pos,action1,action2)
                if arrive(pos,9) and cooldown(name,action1,4) then
                    local ok,result=invoke(moment,action1)
                    if type(result)=="number" then E.Stage=result end
                    if action2 then invoke(moment,action2) end
                    E.Updated=0
                end
            end
            if E.Stage==0 then
                doActions(npcPos,"InteractQuestGiver","AcceptQuest")
                return "Nhận Early Access từ robotmega"
            elseif E.Stage==1 then
                local world=WS:FindFirstChild("_WorldOrigin")
                local assets=world and world:FindFirstChild("EarlyAccessBonusMomentAssets")
                local key=assets and assets:FindFirstChild("KeySpot")
                doActions(location(key) or Vector3.new(-1052,13,1781),"CollectKey")
                return "Tìm chìa khóa cửa sau"
            elseif E.Stage==2 then
                doActions(Vector3.new(-1091.8,14,1806),"InteractMansionDoor")
                return "Mở cửa căn phòng bí mật"
            elseif E.Stage==3 then
                if cooldown(name,"infiltrate",10) then invoke(moment,"FinishInfiltration") end
                return "Hoàn thành xâm nhập"
            elseif E.Stage==4 then
                doActions(npcPos,"InteractQuestGiver","ClaimReward")
                return "Nhận thưởng Early Access"
            end
            return "Chờ trạng thái Early Access"
        elseif name=="X Marks The Spot" then
            local S=D.EventState[name] or {}
            if not S.Stage then
                if cooldown(name,"initialize",25) then fire(moment,"Initialize") end
                return "Đang nhận bản đồ kho báu"
            end
            if S.Stage=="Tree" then
                local town=map and map:FindFirstChild("Town")
                local p=town and findTag(town)
                if p then strike(p,name) end
                return "Rung cây lấy bản đồ"
            elseif S.Stage=="Pickup" and S.Pickup then
                if arrive(S.Pickup,7) and cooldown(name,"PickupMap",3) then fire(moment,"PickupMap") end
                return "Nhặt bản đồ rơi"
            elseif S.Stage=="Map" and S.Piece then
                if arrive(S.Piece,7) and cooldown(name,"CollectCheckpoint",3) then
                    fire(moment,"CollectCheckpoint")
                end
                return "Thu thập mảnh bản đồ"
            elseif S.Stage=="Dig" and S.Target then
                local part=findTag(WS)
                if part and (part.Position-S.Target).Magnitude<8 then strike(part,name)
                else arrive(S.Target,8) end
                return "Đào dấu X trên bản đồ"
            elseif S.Stage=="Chest" then
                local persistent=worldOrigin and worldOrigin:FindFirstChild("PersistentParts")
                local chest=persistent and persistent:FindFirstChild("Buried Treasure")
                local prompt=chest and chest:FindFirstChild("OpenPrompt",true)
                if prompt then
                    local pos=location(prompt.Parent)
                    if pos and arrive(pos,9) and cooldown(name,"open",4) then
                        if type(fireproximityprompt)=="function" then
                            pcall(fireproximityprompt,prompt)
                        else
                            pcall(function()
                                prompt:InputHoldBegin();task.wait(prompt.HoldDuration+.1);prompt:InputHoldEnd()
                            end)
                        end
                    end
                end
                return "Mở rương Treasure"
            elseif S.Stage=="Enemies" then
                local folder=WS:FindFirstChild("Enemies")
                for _,mob in ipairs(folder and folder:GetChildren() or {}) do
                    if STATE.IsAliveNPC(mob) and mob.Name:find("Desert Skeleton") then
                        local r=mob:FindFirstChild("HumanoidRootPart")
                        if r then strike(r,name) end
                        return "Đánh Skeleton giữ kho báu"
                    end
                end
            end
            return "Đợi bản đồ cập nhật: "..tostring(S.Stage)
        elseif name=="Fortress Flagpole" then
            local S=D.EventState[name] or {}
            if not S.Updated or os.clock()-S.Updated>20 then
                if cooldown(name,"init",20) then fire(moment,"Init") end
                return "Khởi động thử thách cờ Marine"
            end
            if S.HasRope and S.Flag then
                if arrive(S.Flag,5) and cooldown(name,"hoist",10) then fire(moment,"Hoist") end
                return "Kéo cờ Marine Fortress"
            end
            if not S.Rope then
                local par=findNpc("Parlus")
                if par and nearQuestPart(par,9) and cooldown(name,"start",4) then fire(moment,"Start") end
                return "Nói chuyện với Parlus"
            end
            if arrive(S.Rope,7) and cooldown(name,"TakeRope",4) then fire(moment,"TakeRope") end
            return "Nhặt dây kéo cờ"
        elseif name=="Zipline Repair" then
            local S=D.EventState[name] or {}
            if not S.Pickup then
                if cooldown(name,"Initialize",25) then fire(moment,"Initialize") end
                return "Tìm móc kéo Zipline"
            end
            local char,hum,_,ready=alive()
            if not ready then return "Chờ nhân vật" end
            local bp=LP:FindFirstChild("Backpack")
            local hook=char:FindFirstChild("Grappling Hook") or (bp and bp:FindFirstChild("Grappling Hook"))
            if not hook then
                if arrive(S.Pickup,7) and cooldown(name,"PickupTool",4) then fire(moment,"PickupTool") end
                return "Nhặt Grappling Hook"
            end
            if typeof(S.Source)~="Vector3" or typeof(S.Target)~="Vector3" then
                return "Đợi vị trí Zipline từ event"
            end
            if arrive(S.Source,8) then
                if hook.Parent~=char then pcall(function()hum:EquipTool(hook)end) end
                if cooldown(name,"Throw",5) then
                    local aim=(S.Target-S.Source).Unit
                    pcall(function()
                        local mod=require(RS.Util.Trajectory)
                        if mod and type(mod.getArcAim)=="function" then
                            aim=mod.getArcAim(char.HumanoidRootPart.Position,S.Target)
                        end
                    end)
                    invoke(moment,"Throw","Grappling Hook",aim)
                end
            end
            return "Phóng Grappling Hook nối Zipline"
        elseif name=="Breaking the Ice" then
            local iceberg=WS:FindFirstChild("Iceberg")
            local rock=iceberg and iceberg:FindFirstChild("IceRock")
            if rock and rock:IsA("BasePart") then
                strike(rock,name)
                return "Đập băng cứu Ability Teacher"
            end
            return "Đợi tảng băng sự kiện xuất hiện"
        elseif name=="Evil Slimes" then
            local magma=map and map:FindFirstChild("Magma")
            local locations=magma and magma:FindFirstChild("BonusMoment_Locations")
            local geyser=locations and locations:FindFirstChild("SlimeGeyser")
            if not geyser then return "Đợi Slime Geyser xuất hiện" end
            local position=location(geyser)
            local enemies=WS:FindFirstChild("Enemies")
            for _,mob in ipairs(enemies and enemies:GetChildren() or {}) do
                if mob:IsA("Model") and mob.Name:find("Slime",1,true) and STATE.IsAliveNPC(mob) then
                    local root=mob:FindFirstChild("HumanoidRootPart")
                    if root and position and (root.Position-position).Magnitude<400 then
                        if nearQuestPart(root,25) and cooldown(name,"slimehit",.5) then
                            local r=getCombatRemotes()
                            if r and r.Attack and r.Hit then
                                pcall(function()r.Attack:FireServer(.3);r.Hit:FireServer(root)end)
                                D.Actions=D.Actions+1
                            end
                        end
                        return "Đánh Slime sự kiện"
                    end
                end
            end
            local part=findTag(geyser)
            if part then strike(part,name);return "Phá Slime Geyser" end
            return "Đợi quái Slime / điểm đánh mở"
        elseif name=="Electric Fighting Teacher" then
            local scientist=findNpc("Mad Scientist")
            local fallback=Vector3.new(-4628.9,12,-355.7)
            local scientistPos=location(scientist) or fallback
            local ok,state=remote("ElectroQuestState")
            if not ok then return "Không kiểm tra được ElectroQuestState" end
            if tonumber(state)==4 then
                if arrive(scientistPos,12) and cooldown(name,"deliver",6) then
                    local success,value=remote("DeliverLightningBolt")
                    if success and value==1 then return "Giao Lightning Bolt thành công" end
                end
                return "Giao Lightning Bolt cho Mad Scientist (chưa mua Electro)"
            end
            if state~=1 and state~=2 then
                if arrive(scientistPos,12) and cooldown(name,"accept",8) then
                    remote("AcceptElectroQuest")
                end
                return "Nhận nhiệm vụ Electro từ Mad Scientist"
            end
            local sky=map and (map:FindFirstChild("Sky") or map:FindFirstChild("SkyArea1"))
            local cloud=findTag(sky)
            if cloud then strike(cloud,name);return "Đánh mây điện tích điện" end
            if not arrive(Vector3.new(-5025,820,-640),160) then return "Bay tới tầng mây điện" end
            return "Đợi mây điện xuất hiện"
        elseif name=="Archaeologist's Tablet" then
            local tablet=WS:FindFirstChild("Archaeologist's Tablet")
            local pillars=tablet and tablet:FindFirstChild("Pillars")
            if not pillars then return "Đợi cột đá sa mạc xuất hiện" end
            for _,pillar in ipairs(pillars:GetChildren()) do
                local count=tonumber(pillar:GetAttribute("NumHits")) or 0
                if count<3 then
                    local part=pillar:FindFirstChild("SandLayer"..tostring(count+1)) or pillar:FindFirstChild("SandLayer3")
                    if part then strike(part,name) end
                    return "Phá cát ở "..pillar.Name.." ("..count.."/3)"
                end
            end
            return "Đã phá các cột, đợi xác nhận nhiệm vụ"
        elseif name=="Windmill Maintenance" then
            local pirate=map and (map:FindFirstChild("Pirate") or map:FindFirstChild("Pirate Village"))
            local rig=pirate and findNamed(pirate,"Windmill_rig")
            if not rig then return "Đợi mô hình cối xay gió xuất hiện" end
            for i=1,5 do
                local rope=rig:FindFirstChild("Rope"..i.."A")
                if rope and rope:IsA("BasePart") and rope.Transparency<1 then
                    strike(rope,name)
                    return "Cắt dây cối xay "..i.."/5"
                end
            end
            return "Đợi cối xay quay / server xác nhận"
        elseif name=="Fountain Pipe Repair" then
            local data=type(moment.MiscData)=="table" and moment.MiscData._fountainPipeRepairState
            local folder=worldOrigin and worldOrigin:FindFirstChild("FountainPipeNodes")
            if not data or not data.pipes or not folder then return "Đợi ống nước xuất hiện" end
            if not data.fullyRepaired then
                for _,pipe in ipairs(folder:GetChildren()) do
                    local id=pipe:GetAttribute("FountainPipeRepairId")
                    local entry=id and data.pipes[id]
                    if entry and entry.currentSteps~=0 then
                        if pipe:IsA("BasePart") then strike(pipe,name) end
                        return "Sửa ống nước "..tostring(id)
                    end
                end
                return "Đợi trạng thái ống nước"
            end
            local seat=data.boat and data.boat:FindFirstChild("FakeVehicleSeat")
            if seat and nearQuestPart(seat,8) and cooldown(name,"turnin",6) then
                invoke(moment,"TurnIn")
            end
            return "Thả thuyền / nộp quest"
        elseif name=="Fountain Wire Repair" then
            local folder=worldOrigin and worldOrigin:FindFirstChild("FountainWireNodes")
            local target=findTag(folder)
            if target then strike(target,name);return "Sửa dây điện đài phun nước" end
            return "Đợi điểm sửa dây điện"
        elseif name=="Prickly Harvest" then
            local npc=findNpc("Desert Merchant")
            local ready=false
            if cooldown(name,"turnincheck",8) then
                local ok,data=invoke(moment,"TurnInReady")
                ready=ok and data==true
            end
            if ready or not D.PricklyStarted then
                if npc and nearQuestPart(npc,12) and cooldown(name,"merchant",5) then
                    local ok,response=invoke(moment,"Interact")
                    D.PricklyStarted=ok and (response=="StartQuest" or response=="InProgress")
                    if response=="Unavailable" then return "Cây xương rồng chưa nở" end
                end
                return ready and "Đang trả cánh hoa" or "Nói chuyện với Desert Merchant"
            end
            local desert=map and map:FindFirstChild("Desert")
            local cacti=desert and desert:FindFirstChild("Cacti")
            local target=findTag(cacti)
            if target then strike(target,name);return "Thu hoạch xương rồng" end
            return "Chờ xương rồng xuất hiện"
        elseif name=="King's Apprentice" then
            local npc=findNpc("Colosseum Emperor")
            local model=WS:FindFirstChild("King's Apprentice")
            local enemies=WS:FindFirstChild("Enemies")
            if enemies and model then
                for _,mob in ipairs(enemies:GetChildren()) do
                    if mob:IsA("Model") and STATE.IsAliveNPC(mob) and
                        (mob.Name:find("Gladiator")~=nil) then
                        local root=mob:FindFirstChild("HumanoidRootPart")
                        local trigger=model:FindFirstChild("StartMatchHitbox")
                        if root and trigger and (root.Position-trigger.Position).Magnitude<250 then
                            D.Stage="Đang đánh Gladiator"
                            if not nearQuestPart(root,math.max(12,tonumber(Config.AttackRange) or 25)) then return D.Stage end
                            if cooldown(name,"mobhit",.4) then
                                local r=getCombatRemotes()
                                local head=mob:FindFirstChild("Head") or root
                                if r and r.Attack and r.Hit then
                                    pcall(function()r.Attack:FireServer(.3);r.Hit:FireServer(head)end)
                                    D.Actions=D.Actions+1
                                end
                            end
                            return "Đang đánh "..mob.Name
                        end
                    end
                end
            end
            if tonumber(moment.Progress)==1 then
                if npc and nearQuestPart(npc,12) and cooldown(name,"report",5) then fire(moment,"Report") end
                return "Báo cáo cho Hoàng đế"
            end
            if not moment.Active then
                if npc and nearQuestPart(npc,12) and cooldown(name,"interact",5) then fire(moment,"Interact") end
                return "Nhận thử thách Colosseum"
            end
            local trigger=model and model:FindFirstChild("StartMatchHitbox")
            if trigger and nearQuestPart(trigger,9) and cooldown(name,"match",15) then fire(moment,"StartMatch") end
            return "Bắt đầu trận đấu"
        elseif name=="Lookout" then
            local npc=findNpc("Experienced Captain")
            if not (npc and nearQuestPart(npc,12)) then return "Tìm Experienced Captain" end
            local L=D.Lookout
            if os.clock()<L.NextAt then return "Quan sát thuyền / đang đợi" end
            if not L.Token then
                local ok,p=invoke(moment,"GetProgress")
                if not ok or type(p)~="table" then return "Chưa lấy được tiến độ Lookout" end
                if not p.Unlocked then
                    if (tonumber(p.SecondsRemaining) or 0)>0 then
                        L.NextAt=os.clock()+math.min(tonumber(p.SecondsRemaining),30)
                        return "Captain yêu cầu đợi "..tostring(p.SecondsRemaining).."s"
                    end
                    if cooldown(name,"introduction",5) then invoke(moment,"AdvanceIntroduction") end
                    return "Đang mở nhiệm vụ Lookout ("..tostring(p.IntroVisits or 0).."/3)"
                end
                local ok2,answer=invoke(moment,"StartAttempt")
                if not ok2 or type(answer)~="table" or type(answer.Token)~="string" or type(answer.Manifest)~="table" then
                    L.NextAt=os.clock()+8;return "Chưa bắt đầu được lượt quan sát"
                end
                L.Token=answer.Token;L.Manifest=answer.Manifest;L.Round=tonumber(answer.Round) or 1
                L.StartedAt=os.clock();L.NextAt=os.clock()+2
                return "Lookout vòng "..tostring(L.Round)..": chuẩn bị"
            end
            local ok,res=invoke(moment,"ObservationFinished",L.Token)
            if not ok then L.NextAt=os.clock()+3;return "Lỗi đọc kết quả quan sát" end
            if type(res)=="table" and res.Ready==false then
                L.NextAt=os.clock()+math.clamp(tonumber(res.RetryAfter) or 1,0.5,7)
                if os.clock()-L.StartedAt>120 then
                    invoke(moment,"AbortAttempt",L.Token);L.Token=nil;L.Manifest=nil
                end
                return "Đang quan sát lượt "..tostring(L.Round)
            end
            if type(res)~="table" then L.Token=nil;L.Manifest=nil;return "Không có dữ liệu quan sát" end
            local total=0
            for _,ship in ipairs(L.Manifest or {}) do
                if ship.Boat==res.TargetBoat and ship.FlagColor==res.TargetFlagColor then total=total+1 end
            end
            local correct,report=invoke(moment,"SubmitAnswer",L.Token,total)
            if correct and type(report)=="table" then
                if type(report.FinaleToken)=="string" then invoke(moment,"FinishFinale",report.FinaleToken) end
                L.Token=nil;L.Manifest=nil;L.NextAt=os.clock()+2
                return "Lookout đã trả lời: "..total.." (server: "..tostring(report.Correct)..")"
            end
            L.Token=nil;L.Manifest=nil;L.NextAt=os.clock()+7
            return "Lookout không xác nhận được kết quả"
        elseif name=="Rescue Hasan" then
            local npc=findNpc("Hasan")
            if (tonumber(moment.Progress) or 0)>=1 and npc then
                if nearQuestPart(npc,12) and cooldown(name,"hasan",8) then fire(moment,"Interact") end
                return "Nói chuyện với Hasan"
            end
            local enemies=WS:FindFirstChild("Enemies")
            for _,mob in ipairs(enemies and enemies:GetChildren() or {}) do
                if mob.Name:find("Desert Skeleton") and STATE.IsAliveNPC(mob) then
                    local root=mob:FindFirstChild("HumanoidRootPart")
                    if root then
                        if nearQuestPart(root,25) and cooldown(name,"skeleton",.5) then
                            local r=getCombatRemotes();if r and r.Attack and r.Hit then
                                pcall(function()r.Attack:FireServer(.3);r.Hit:FireServer(root)end)
                                D.Actions=D.Actions+1
                            end
                        end
                        return "Đánh Desert Skeleton để cứu Hasan"
                    end
                end
            end
            return "Đang chờ cutscene / Desert Skeleton (cần tương tác trong game nếu không xuất hiện)"
        end
        return "Nhiệm vụ chưa có bước tự động độc lập"
    end
    function D.Tick()
        if not Config.AutoSecretQuestRoute then
            if D.Enabled then D.StopMovement() end
            D.Enabled=false;D.Status="Tắt";D.Stage="Không chạy";D.Current="None"
            return
        end
        if STATE.World~=1 then
            D.Status="Chỉ hỗ trợ Secret Quests Sea 1";D.Stage="Hãy sang Sea 1"
            return
        end
        if not D.Enabled then
            D.Enabled=true;D.Status="Bắt đầu"
            D.LastPoll=-math.huge;D.NextMove=0;D.Lookout.Token=nil
            D.Status="Scanning server secret progress"
        end
        for _,flag in ipairs(pauseNames) do
            if Config[flag] then
                D.Status="Tạm dừng vì "..flag
                D.Stage="Tắt chế độ di chuyển khác trước"
                return
            end
        end
        refreshProgress()
        refreshMoments()
        local progressUnavailable=D.LastProgressError~="Không"
        -- Progress is useful for ordering, but an older server can reject the
        -- read while still streaming active BonusMoments.  Do not make the
        -- toggle appear dead in that case; run only a live moment and keep the
        -- error visible in the mobile status row.
        if progressUnavailable and D.ActiveCount<=0 then
            D.Status="Chờ tiến độ Secret Quest";D.Stage=D.LastProgressError
            return
        elseif progressUnavailable then
            D.Status="Đang làm moment đang tải · tiến độ server chưa đọc được"
        end
        local candidates={}
        local onlySelected=Config.SecretQuestRunMode=="Chỉ nhiệm vụ đã chọn"
        local selected=tonumber(tostring(Config.SecretQuestName or ""):match("^%[(%d+)%]")) or tonumber(Config.SecretQuestIndex) or 1
        local countUnknown=0
        local _,_,playerRoot,valid=alive()
        if not valid then D.Status="Đợi hồi sinh";return end
        for i,name in ipairs(STATE.Advanced.SecretQuestNames) do
            local locked=name=="Prickly Harvest" and not isComplete("Rescue Hasan")
            if locked and onlySelected and i==selected then
                D.Status="Chờ Rescue Hasan";D.Stage="Hoàn thành Rescue Hasan trước Prickly Harvest"
                return
            end
            if not locked and not isComplete(name) and (not onlySelected or i==selected) then
                if not supported[name] then countUnknown=countUnknown+1 end
                if supported[name] then
                    local moment=momentByName(name)
                    -- The source Topi routes to an island to stream its moment first.
                    -- In v28 this hard gate excluded every unloaded quest, so the switch appeared inert.
                    local areaPos=findArea(questArea(name))
                    if type(moment)=="table" or areaPos then
                        local dist=areaPos and (areaPos-playerRoot.Position).Magnitude or 100000
                        table.insert(candidates,{Name=name,Moment=moment,AreaPos=areaPos,Distance=dist,
                            Active=type(moment)=="table" and moment.Active==true,Selected=i==selected})
                    end
                end
            end
        end
        if D.Completed>=39 then
            D.StopMovement()
            D.Status="Đã nhận diện 39/39 quest đảo; The Finale cần kiểm tra riêng"
            D.Stage="Kiểm tra The Finale tại Middle Town"
            Config.AutoSecretQuestRoute=false
            return
        end
        table.sort(candidates,function(a,b)
            if onlySelected then return a.Distance<b.Distance end
            local aCurrent=a.Name==D.Current and os.clock()-D.LastQuestAt<90
            local bCurrent=b.Name==D.Current and os.clock()-D.LastQuestAt<90
            if aCurrent~=bCurrent then return aCurrent end
            if a.Active~=b.Active then return a.Active end
            return a.Distance<b.Distance
        end)
        local picked
        for _,item in ipairs(candidates) do
            if os.clock()>=(D.Skipped[item.Name] or 0) then picked=item;break end
        end
        if not picked then
            D.StopMovement()
            D.Current="None";D.Status="Đợi nhiệm vụ khả dụng"
            if onlySelected and not supported[nameFor(selected)] then
                D.Stage="Quest được chọn chưa có handler tự động: "..tostring(nameFor(selected))
            else
                D.Stage="Đã xác nhận "..D.Completed.."/39 · "..countUnknown.." loại chưa hỗ trợ tự xử lý"
            end
            return
        end
        if picked.Name~=D.Current then
            D.StopMovement()
            D.Current=picked.Name;D.LastQuestAt=os.clock();D.NextMove=0;D.AreaArrivedAt=nil
        end
        D.Status="Đang làm: "..picked.Name
        if type(picked.Moment)~="table" then
            -- Unlike v28, go to the quest area instead of waiting forever for replication.
            if picked.AreaPos then
                local reached=arrive(picked.AreaPos,45)
                if reached then D.AreaArrivedAt=D.AreaArrivedAt or os.clock()
                else D.AreaArrivedAt=nil end
                D.Stage=reached and "Đợi BonusMoment xuất hiện tại đảo" or
                    ("Đang đến đảo để tải Secret Quest: "..questArea(picked.Name))
                D.Status="Đang tìm: "..picked.Name
            else
                D.Stage="Khu vực chưa được tải xuống client"
            end
            if D.AreaArrivedAt and os.clock()-D.AreaArrivedAt>15 then
                D.Skipped[picked.Name]=os.clock()+30
                D.Current="None"
            end
            return
        end
        local ok,step=pcall(doQuest,picked.Name,picked.Moment)
        if ok then
            D.Stage=tostring(step or "Chờ server cập nhật")
            D.LastError="Không"
            if D.Stage~=D.PreviousStage then D.PreviousStage=D.Stage;D.LastStageAt=os.clock() end
            if os.clock()-D.LastStageAt>80 then
                D.Skipped[picked.Name]=os.clock()+120;D.Current="None"
                D.Stage="Nhiệm vụ không tiến triển, bỏ qua tạm thời 120s"
            end
        else
            D.Failed=D.Failed+1;D.LastError=tostring(step)
            D.Status="Lỗi nhiệm vụ";D.Stage=tostring(step):sub(1,160)
            D.Skipped[picked.Name]=os.clock()+30
        end
    end
    function D.Refresh()
        D.LastPoll=-math.huge;refreshProgress();refreshMoments()
        return D.Completed,D.LastProgressError
    end
    function D.Snapshot()
        return {Enabled=Config.AutoSecretQuestRoute,Sea=STATE.World,Current=D.Current,
            Completed=D.Completed,Total=D.Total,Supported=D.Supported,ActiveMoments=D.ActiveCount,
            Status=D.Status,Step=D.Stage,Failed=D.Failed,Actions=D.Actions,
            LastError=D.LastError,ProgressError=D.LastProgressError,
            Note="Chỉ các quest có state/handler được xác minh mới tự chạy; không phải auto full 39"}
    end
    startLoop("Secret Quest Mobile",1.25,function() D.Tick() end)
end
STATE.InitSecretQuestDirector()
STATE.InitSecretQuestDirector=nil



-- v31: one geometry owner. The original mobile-only resize hook was removed,
-- as it repeatedly overwrote the navigation/drawer dimensions after rotation.

--// V31 AUTOFULL MELEE DIRECTOR (DynamicIsland / Blox Fruits source references).
-- A sequential, server-state-aware planner. No in-game money is spent unless
-- the user enables BOTH AutoFullMelee and FullMeleeAutoBuy.
do
    local M={Stage="Tắt",Current="--",Mastery=0,Target=0,Buys=0,Errors=0,
        LastError="Không",LastCheck=-math.huge,LastPurchase=-math.huge,InventoryAt=-math.huge,Items={},
        LastEquipped="",LastRequest="",Completed=0,Total=10}
    STATE.FullMelee=M
    local steps={
        {name="Dark Step",aliases={"Dark Step","Black Leg"},target=300,remote="BuyBlackLeg",sea=1},
        {name="Electro",aliases={"Electro"},target=300,remote="BuyElectro",sea=1},
        {name="Water Kung Fu",aliases={"Water Kung Fu","Fishman Karate"},target=300,remote="BuyFishmanKarate",sea=1},
        {name="Dragon Claw",aliases={"Dragon Claw"},target=300,remote="BlackbeardReward",sea=2},
        {name="Superhuman",aliases={"Superhuman"},target=400,remote="BuySuperhuman",sea=2},
        {name="Death Step",aliases={"Death Step"},target=400,remote="BuyDeathStep",sea=2},
        {name="Sharkman Karate",aliases={"Sharkman Karate"},target=400,remote="BuySharkmanKarate",sea=2},
        {name="Electric Claw",aliases={"Electric Claw"},target=400,remote="BuyElectricClaw",sea=3},
        {name="Dragon Talon",aliases={"Dragon Talon"},target=400,remote="BuyDragonTalon",sea=3},
        {name="Godhuman",aliases={"Godhuman"},target=400,remote="BuyGodhuman",sea=3},
    }
    local function matches(label,step)
        label=tostring(label or ""):lower()
        for _,alias in ipairs(step.aliases) do if label==alias:lower() then return true end end
        return false
    end
    local function masteryOf(tool)
        if not tool then return nil end
        local v=tool:FindFirstChild("Level") or tool:FindFirstChild("Mastery")
        return v and tonumber(v.Value) or tonumber(tool:GetAttribute("Mastery"))
    end
    local function findTool(step)
        for _,box in ipairs({LP.Character,LP:FindFirstChild("Backpack")}) do
            if box then
                for _,tool in ipairs(box:GetChildren()) do
                    if tool:IsA("Tool") and matches(tool.Name,step) then return tool end
                end
            end
        end
        return nil
    end
    local function scanInventory()
        if os.clock()-M.InventoryAt<35 then return end
        M.InventoryAt=os.clock()
        local ok,inventory=EX.GetInventory()
        if not ok or type(inventory)~="table" then return end
        local result={}
        for _,entry in pairs(inventory) do
            if type(entry)=="table" then
                local label=tostring(entry.Name or entry.ItemName or entry.ItemId or "")
                if label~="" then
                    result[label:lower()]={owned=true,mastery=tonumber(entry.Mastery or entry.Level)}
                end
            end
        end
        M.Items=result
    end
    local function stateFor(step)
        local tool=findTool(step)
        if tool then return true,masteryOf(tool),tool end
        for _,alias in ipairs(step.aliases) do
            local item=M.Items[alias:lower()]
            if item then return true,item.mastery,nil end
        end
        return false,nil,nil
    end
    function M.Tick()
        if not Config.AutoFullMelee then
            if M.StartedFarm and Config.FarmEnabled and Config.FarmMode=="Mastery" then
                setFlag("FarmEnabled",false)
            end
            M.StartedFarm=false
            M.Stage="Tắt";return
        end
        if STATE.World==0 then M.Stage="Không ở Blox Fruits";return end
        if Config.AutoSecretQuestRoute or Config.AutoTrickOrTreat or Config.AutoSea then
            M.Stage="Tạm dừng để nhiệm vụ khác di chuyển";return
        end
        if os.clock()-M.LastCheck<3.5 then return end
        M.LastCheck=os.clock()
        scanInventory()
        local nextStep=nil
        M.Completed=0
        for _,step in ipairs(steps) do
            local owned,ma=stateFor(step)
            if owned and ma and ma>=step.target then M.Completed=M.Completed+1
            elseif not nextStep then nextStep={step=step,owned=owned,mastery=ma,tool=findTool(step)} end
        end
        if not nextStep then M.Stage="Đã đủ mastery các võ có dữ liệu";M.Current="Hoàn tất";return end
        local x=nextStep;local step=x.step
        M.Current=step.name;M.Target=step.target;M.Mastery=x.mastery or 0
        if STATE.World<step.sea then
            M.Stage="Cần Sea "..step.sea.." để mở "..step.name
            return
        end
        if not x.owned then
            M.Stage="Chưa có "..step.name
            if not Config.FullMeleeAutoBuy then
                M.Stage=M.Stage.." · bật Cho phép mua nếu muốn"
                return
            end
            if os.clock()-M.LastPurchase<(tonumber(Config.FullMeleeCooldown) or 45) then return end
            if M.Buys >= (tonumber(Config.FullMeleeMaxPurchases) or 1) then
                M.Stage="Đạt giới hạn mua trong phiên; hãy kiểm tra trước"
                return
            end
            M.LastPurchase=os.clock()
            local ok,res
            if step.name=="Dragon Claw" then ok,res=remote("BlackbeardReward","DragonClaw","2")
            else ok,res=remote(step.remote) end
            M.LastRequest=step.remote;M.Buys=M.Buys+1
            M.Stage=ok and ("Đã gửi yêu cầu mua "..step.name) or ("Không mua được: "..tostring(res))
            if not ok then M.Errors=M.Errors+1;M.LastError=tostring(res) end
            M.InventoryAt=-math.huge
            return
        end
        if not x.mastery then
            M.Stage="Đã có võ nhưng chưa đọc được mastery: "..step.name
            return
        end
        M.Stage=string.format("Luyện %s: %d / %d",step.name,x.mastery,step.target)
        if not Config.FullMeleeAutoFarm then return end
        if x.tool then
            Config.Weapon=x.tool.Name -- equipByType() matches exact names
            local current=LP.Character
            local hum=current and current:FindFirstChildOfClass("Humanoid")
            if hum and x.tool.Parent~=current then
                pcall(function() hum:EquipTool(x.tool) end)
            end
            M.LastEquipped=step.name
        else
            M.Stage="Võ đã sở hữu nhưng chưa có trong Backpack: "..step.name
            return
        end
        if Config.FarmMode~="Mastery" then setFlag("FarmMode","Mastery") end
        if not Config.Combat then setFlag("Combat",true) end
        if not Config.FarmEnabled then
            M.StartedFarm=true
            M.ArmingFarm=true
            setFlag("FarmEnabled",true)
            M.ArmingFarm=false
        end
    end
    function M.ReadOnlyScan()
        M.InventoryAt=-math.huge
        scanInventory()
        M.Completed=0
        local firstMissing=nil
        for _,step in ipairs(steps) do
            local owned,ma=stateFor(step)
            if owned and ma and ma>=step.target then
                M.Completed=M.Completed+1
            elseif not firstMissing then
                firstMissing={step=step,owned=owned,mastery=ma}
            end
        end
        if firstMissing then
            M.Current=firstMissing.step.name;M.Mastery=firstMissing.mastery or 0
            M.Target=firstMissing.step.target
            M.Stage=firstMissing.owned and "Cần luyện mastery" or "Chưa xác định sở hữu"
        else
            M.Current="Hoàn tất";M.Stage="Đã xác nhận mastery trong kho có dữ liệu"
        end
        return M.Completed
    end
    function M.ResetSession()
        M.Buys=0;M.LastPurchase=-math.huge;M.InventoryAt=-math.huge
        M.Stage="Đã đặt lại giới hạn mua trong phiên"
    end
    function M.Snapshot()
        return {Current=M.Current,Stage=M.Stage,Mastery=M.Mastery,Target=M.Target,
            Buys=M.Buys,Completed=M.Completed,Total=M.Total,LastError=M.LastError}
    end
    startLoop("Full Melee Director",3.5,function() M.Tick() end)
end

--// ALL PAGES -------------------------------------------------------------
local R = {}
do
local dashboard=addPage("home","⌂","Home","Crystal White Liquid Glass  /  andepzai 38.9")
do
local quickPower=section(dashboard,"ĐIỀU KHIỂN NHANH · CHẠM LÀ BẬT",
    "Các công tắc đều nối vào engine thật, chỉ một tác vụ di chuyển nên chạy mỗi lần.")
farmSwitch(quickPower,"Auto Farm Level / Quest","Level")
toggle(quickPower,"Auto Fishing + tự quăng cần","AutoFish")
toggle(quickPower,"Auto Secret Quest (19 handler)","AutoSecretQuestRoute")
toggle(quickPower,"Auto Halloween gõ cửa","AutoTrickOrTreat")
toggle(quickPower,"Flight Tween liên tục","FlightContinuous","Giữ đường bay thẳng; tự đồng bộ khi server kéo lệch")
toggle(quickPower,"Tự ổn định độ cao khi bay","FlightStabilize","Chống rơi khi FPS/độ trễ thay đổi")
STATE.MobileQuickStatus=statBox(quickPower,"Trạng thái bay / gom","Sẵn sàng")
action(quickPower,"DỪNG TOÀN BỘ TÁC VỤ",function() STATE.StopAll() end)
end
local hero=section(dashboard,"ANDEPZAI · CONTROL CENTER","One standalone hub · 3 reference feature sets")
info(hero,"MOBILE 38.9: 5 tab ở cạnh dưới, nút ☰ mở trang nâng cao. Farm chỉ hoạt động khi bạn bật công tắc.")
local welcome=section(dashboard,"MỞ NHANH · ĐIỆN THOẠI","Chạm mục cần dùng, không phải mở nhiều tầng menu")
action(welcome,"Mở Auto Fishing + Tự quăng cần",function() STATE.OpenPage("fishingpro") end)
action(welcome,"Mở Secret Quest tự động",function() STATE.OpenPage("secret39") end)
action(welcome,"Mở Farm + Gom quái",function() STATE.OpenPage("farm") end)
action(welcome,"Mở Halloween gõ cửa",function() STATE.OpenPage("halloween") end)
action(welcome,"Mở Auto Full Melee / Godhuman",function() STATE.OpenPage("fullmelee") end)
action(welcome,"Mở Farm Katakuri / Cake Prince",function() STATE.OpenPage("boss") end)
action(welcome,"Mở Auto Raid FULL",function() STATE.OpenPage("raid") end)
action(welcome,"Mở nâng Race V4",function() STATE.OpenPage("race") end)
R.doctor=section(dashboard,"CHẨN ĐOÁN MOBILE · COPY ĐỂ BÁO LỖI",
    "Trạng thái từng director, không cần mở F9 hoặc console PC")
R.v34Halloween=statBox(R.doctor,"Halloween · cửa / hội thoại","Off")
R.v34Kata=statBox(R.doctor,"Katakuri · Cake Prince","Off")
R.v34Raid=statBox(R.doctor,"Raid · chip / đảo / quái","Off")
R.v34Race=statBox(R.doctor,"Race V4 · Gear / Trial","Off")
action(R.doctor,"SAO CHÉP BÁO CÁO 4 CHỨC NĂNG",function()
    local statuses={"andepzai 38.9 / Sea="..STATE.World,
        "Halloween: "..tostring(STATE.TrickTreat and STATE.TrickTreat.Status),
        "Kata: "..tostring(STATE.KatakuriDirector and STATE.KatakuriDirector.Status),
        "Raid: "..tostring(STATE.RaidDirector and STATE.RaidDirector.Status),
        "RaidOwned: "..tostring(STATE.RaidDirector and STATE.RaidDirector.Owned),
        "RaidMagnet: "..tostring(STATE.MobMagnet and STATE.MobMagnet.LastError),
        "V4: "..tostring(STATE.RaceV4Director and STATE.RaceV4Director.Status),
        "V4Door: "..tostring(STATE.RaceV4Director and STATE.RaceV4Director.DoorStatus),
        "V4Draco: "..tostring(STATE.RaceV4Director and STATE.RaceV4Director.Draco and STATE.RaceV4Director.Draco.Status),
        "V4TrialTimer: "..tostring(STATE.RaceV4Director and STATE.RaceV4Director.IsTrialTimerVisible()),
        "RaidProof: "..tostring(STATE.RaidDirector and STATE.RaidDirector.SessionProof),
        "Combat: "..tostring(STATE.FastAttackDirector and STATE.FastAttackDirector.Status)}
    local report=table.concat(statuses,"\n")
    local copy=api('setclipboard')
    if type(copy)=='function' then
        local ok=pcall(copy,report)
        notice("Diagnostics",ok and "Đã sao chép báo cáo" or "Không sao chép được",ok and "info" or "warn")
    else
        notice("Diagnostics","Executor không hỗ trợ copy; xem 4 trạng thái phía trên","warn")
    end
end)
local sb=section(dashboard,"Live session","Information comes from the local game client")
local statPlayer=statBox(sb,"Player",LP.DisplayName)
local statLevel=statBox(sb,"Level",level())
local statSea=statBox(sb,"Sea",STATE.World)
local statBeli=statBox(sb,"Beli",value("Beli"))
local statFrag=statBox(sb,"Fragments",value("Fragments"))
local statFarm=statBox(sb,"Farm status","Stopped")
R.statWorldProgress=statBox(sb,"Sea progression","Tắt")
info(welcome,"All controls live in this hub. Level route data can fall back to the supplied reference; advanced progression still needs in-game testing.")
toggle(welcome,"Enable PvE combat","Combat","Configured ON; attacks NPCs only when a farm/other explicit mode is started")
toggle(welcome,"Fast attack via game remotes","FastAttackEnabled","Requires PvE Combat toggle; version-dependent")
toggle(welcome,"Take level quests","AutoQuest","Only when Level farm is enabled")
toggle(welcome,"Collect nearby fruits","AutoCollectFruit","Move to dropped fruits on the map")
toggle(welcome,"Auto Haki","AutoHaki")
toggle(welcome,"Teleport / Tween movement","TeleportEnabled","Công tắc tổng: bật để di chuyển tới NPC, đảo và spawn")
toggle(welcome,"Tự chuyển Sea theo level","AutoWorldProgression",
    "Sea 1 → 2 ở Lv.700, Sea 2 → 3 ở Lv.1500; chỉ chạy khi Farm Level đang bật")
action(welcome,"Server hop",hopServer,"Find a public server with fewer players")
farmSwitch(welcome,"Level Farm + Quest + Combat","Level","Bật để farm; tắt để ngừng đánh, nhận quest và tween")
action(welcome,"Stop all movement",function()
    for _,key in ipairs({"FarmEnabled","AutoWorldProgression","AutoSea","AutoChest","AutoCollectFruit","AutoAdvanceRaid",
        "AutoTyrant","AutoKatakuri","AutoBones","AutoRaidCombat","AutoBerry","AutoBerryHop","AutoMagnetToken","EventRadar","AutoFactory","AutoPirateRaid","AutoSoulReaper","AutoDarkbeard","AutoRipIndra","AutoDoughKing","AutoEliteCombat","AutoEventCollect","AutoFollowPlayer"}) do setFlag(key,false) end
    setFlag("AutoSeaBoat",false)
    STATE.TeleportDestination=nil
    if STATE.TeleportRecovery then
        STATE.TeleportRecovery.Token=(STATE.TeleportRecovery.Token or 0)+1
        STATE.TeleportRecovery.Pending=false
    end
    cancelMove();notice("Safety","Movement jobs disabled")
end)
do
local review=section(dashboard,"Feature coverage · V31",
    "Compared with public October/November 2026 reviews; menu listings are not proof of working automation")
info(review,"Engine: Farm Level/Boss/Material/Mastery/Island, Quest 3 Sea, Combat, Mob Magnet, Flight Tween, Raid, Fishing, Fruit, PvP, Halloween. Chọn 1 chế độ, mọi trang con đều hiển thị.")
info(review,"CHƯA FULL/CHƯA TEST: tự hoàn thành toàn bộ CDK, Soul Guitar, Draco, Race V4, Leviathan và tỷ lệ server chấp nhận Fast Attack/Mob Magnet. Bản này không khai báo 100% hoàn thiện.")
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
dropdown(farmQuick,"Farm mode","FarmMode",{"Level","Nearest","Selected mob","Island","Boss","Material","Bones","Mastery","Halloween","Halloween Boss","Aura"})
dropdown(farmQuick,"Weapon","Weapon",{"Melee","Sword","Blox Fruit","Gun","Any"})
farmSwitch(farmQuick,"Auto Farm · chế độ đã chọn",nil,"Bật: tìm quái / di chuyển / combat. Tắt: dừng farm và tween.")
farmSwitch(farmQuick,"Farm Level + Quest + Combat","Level","Đổi nhanh sang Level và trang bị cấu hình có sẵn")
local farmLive=statBox(farmQuick,"Combat status","Idle")
STATE.CombatStatusLabel=farmLive
info(farmQuick,"Mặc định: Above 18 studs + Adaptive + Fast Attack. Chỉ chạy khi bật Auto Farm.")
do
local fMode=section(farming,"Farm control")
dropdown(fMode,"Target mob","Mob",getMobs,"Refresh the dropdown after mobs spawn")
dropdown(fMode,"Island farm area","IslandFarmIsland",STATE.GetIslandFarmOptions,
    "Farm mục tiêu theo đảo; dùng chung flight, gom quái và combat engine của AD38")
action(fMode,"Refresh mobs",function() notice("Scanner","Rescanned visible enemies") end)
toggle(fMode,"Take level quest","AutoQuest","Prioritize GuideModule, with reference route fallback")
toggle(fMode,"Use live Quests module","PreferLiveQuestModule",
    "Ưu tiên ReplicatedStorage.Quests + GuideModule; route AD38 vẫn là fallback")
info(fMode,"Quest route uses game data when available; fallback reference remains active.")
toggle(fMode,"Attack mobs","Combat")
toggle(fMode,"Auto equip weapon","AutoEquip")
toggle(fMode,"Use fast attack remotes","FastAttackEnabled","PvE event support; chỉ dùng sau khi bật Combat hoặc Farm. Actual HP is checked.")
dropdown(fMode,"Combat method","CombatMode",{"Adaptive","Hybrid","Tool only","Remote only"},"Adaptive equips weapon, clicks, and tries PvE event only in range")
slider(fMode,"Combat hit range","AttackRange",8,65,1)
local fAttack=section(farming,"FAST ATTACK V25 · điều chỉnh thông minh",
    "Vòng đánh riêng với Tween; đếm HP thật. Gửi remote không bảo đảm server gây sát thương.")
toggle(fAttack,"Fast Attack Engine V24 (Bật/Tắt)","CombatScheduler",
    "ON: đánh liên tục khi Farm có mục tiêu. OFF: dùng chế độ tấn công v23")
toggle(fAttack,"Đánh nhiều quái trong một lượt","FastAttackMultiTarget",
    "Bó các quái còn sống, đúng loại, trong tầm vào RegisterHit")
slider(fAttack,"Fast Attack interval (giây)","FastAttackInterval",.05,.4,.01,
    "Mặc định 0.06 (~16Hz), giới hạn gửi; FPS/server có thể giảm tốc độ thực")
slider(fAttack,"Tối đa quái / lần đánh","FastAttackTargets",1,12,1)
toggle(fAttack,"Tự điều tiết khi không có damage","FastAttackAutoTune",
    "Nếu nhiều lượt không giảm HP, tự giãn nhịp và thử protocol khác")
slider(fAttack,"Tool M1 fallback (giây)","ToolAttackInterval",.12,.7,.01)
dropdown(fAttack,"Remote protocol","PVEHitProtocol",{"Auto","Spooky","Topi"},
    "Auto: thử Spooky/Topi khi nhiều giây không có HP drop")
STATE.FarmV24Stats=statBox(fAttack,"Đòn gửi / mục tiêu / HP giảm","Chưa chạy")
STATE.FarmV24DPS=statBox(fAttack,"Sát thương ước tính (10s)","0 DPS")
STATE.FarmV24Issue=statBox(fAttack,"Fast Attack status","Chưa bật Farm")
STATE.FarmV25Thread=statBox(fAttack,"Game COMBAT_REMOTE_THREAD","Not probed")
toggle(fMode,"Abandon wrong level quest","AutoAbandonWrongQuest","Disabled by default; never abandons without enabling this")
toggle(fMode,"Auto haki","AutoHaki")
end
do
local fPreset=section(farming,"Chế độ farm khác · BẬT/TẮT","Mỗi công tắc chọn đúng 1 chế độ; tắt là ngừng chạy")
farmSwitch(fPreset,"Auto Boss","Boss")
farmSwitch(fPreset,"Auto Material","Material")
farmSwitch(fPreset,"Auto Mastery","Mastery")
farmSwitch(fPreset,"Auto Farm selected island","Island","Chỉ đánh mob thuộc đảo đã chọn")
end
do
local fRoute=section(farming,"ATLAS 3 SEA · SMART ROUTE",
    "Dùng 547 điểm quét; nếu đến nơi không thấy quái thì chọn điểm khác có chờ.")
toggle(fRoute,"Tự tránh tọa độ spawn trống","RouteSmartScan",
    "Dùng dữ liệu Workspace.7z và không lặp cùng tọa độ rỗng mãi")
slider(fRoute,"Chờ quái xuất hiện (giây)","RouteSpawnWait",4,30,1)
slider(fRoute,"Tạm bỏ qua spawn trống (giây)","RouteCooldown",12,100,1)
slider(fRoute,"Bán kính xác nhận đã đến","RouteArrivalRadius",30,150,5)
STATE.AtlasV24Status=statBox(fRoute,"Route status","Đang chờ")
action(fRoute,"Bỏ qua điểm spawn đang trống",function()
    local ok=STATE.RouteDirector and STATE.RouteDirector.Skip()
    notice("Atlas",ok and "Đã bỏ qua điểm spawn hiện tại" or "Chưa có điểm spawn đang theo dõi")
end)
end
do
local fDiag=section(farming,"Quest & combat diagnostics")
toggle(fDiag,"Dùng bảng Quest chi tiết từ data.lua","PreferReferenceQuests",
    "Nguồn user: Sea 1/2/3; ưu tiên GuideModule cho tọa độ và xác thực quest")
action(fDiag,"Đối chiếu Quest hiện tại với bảng gốc",function()
    local old,new=STATE.QuestMirror.Compare(level(),STATE.World)
    notice("Quest comparison",STATE.QuestMirror.Last)
    notice("Reference Quest",new and (new[3].." / "..new[4].." #"..new[5]) or "Không có dữ liệu")
end)
action(fDiag,"Xem Combat Flag / Game Thread",function()
    STATE.CombatBridge.Probe(true)
    local a=STATE.CombatBridge.Snapshot()
    notice("Combat thread",string.format("Flag=%s | handler=%s | %s",tostring(a.server_thread),tostring(a.thread_handler),a.status))
end)
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
    notice("Auto Magnet",string.format("Auto=%s | target=%s | tracked=%d | eligible=%d | moves=%d | corrections=%d | %s",
        tostring(m.AutoWired),m.TargetName,m.Active,m.Eligible,m.LocalMoves,m.Rejections,m.LastError))
end)
action(fDiag,"Movement diagnostics",function()
    local d=STATE.MoveStats
    notice("Movement",string.format("%s | requested=%d studs/s | starts=%d | reached=%d | stalls=%d | corrections=%d",
        d.Status,d.RequestedSpeed,d.Started,d.Reached,d.Stalled,d.Corrections))
    if STATE.MoveGuard then notice("Move monitor",STATE.MoveGuard.Status) end
    if d.LastError~="None" then slog("Move: "..d.LastError,"warn") end
end)
action(fDiag,"V25 kiểm tra toàn bộ Farm (read-only)",function()
    local pass,fail=STATE.FarmAudit.RunChecks()
    notice("Farm self-check",tostring(pass).." OK | "..tostring(fail).." cần xử lý")
    for _,issue in ipairs(STATE.FarmAudit.Issues) do slog(issue,"warn") end
end)
action(fDiag,"Xuất JSON chẩn đoán Sea hiện tại",function()
    STATE.FarmAudit.RunChecks()
    local ok,path=STATE.FarmAudit.Export()
    notice("Farm diagnostics",ok and ("Saved: "..path) or ("Error: "..path),ok and nil or "warn")
end)
action(fDiag,"Xuất JSON Fast Attack",function()
    local ok,path=STATE.FastAttackDirector.Export()
    notice("Combat telemetry",ok and ("Saved: "..path) or ("Error: "..path),ok and nil or "warn")
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
end
do
local fPosition=section(farming,"Position & movement")
toggle(fPosition,"Dùng tọa độ spawn đã quét 3 Sea","AtlasUseScannedSpawns",
    "Ưu tiên spawn đang tải trên client, sau đó tới điểm trong Workspace.7z, cuối cùng mới dùng tọa độ dự phòng")
slider(fPosition,"Halloween revive / corpse grace (s)","HalloweenReviveGrace",.4,1.5,.1)
info(fPosition,"AUTO GOM QUÁI: TÍCH HỢP SẴN. Chỉ cần bật Farm; engine tự tìm, gom và thả quái. Không có công tắc riêng.")
dropdown(fPosition,"Kiểu gom quái","MobMagnetMatchMode",{"Same mob name","Nearby normal mobs"},
    "Same name: chỉ quái cùng tên; Nearby: các quái thường còn sống trong bán kính")
slider(fPosition,"Bán kính gom quái","MobMagnetRadius",60,300,10)
slider(fPosition,"Số quái tối đa (kể cả mục tiêu)","MobMagnetMax",2,12,1)
info(fPosition,"Gom quái mặc định hoạt động cùng mọi tác vụ PvE hợp lệ. Khi server không cấp network ownership, menu sẽ báo nguyên nhân.")
toggle(fPosition,"Network assist cho gom quái","MobMagnetNetworkAssist",
    "Thử tăng SimulationRadius khi executor hỗ trợ; tự bỏ qua nếu API không có")
toggle(fPosition,"Giữ quái bằng BodyPosition","MobMagnetBodyPosition",
    "Giữ anchor ổn định hơn CFrame đơn lẻ; tắt để dùng fallback CFrame")
STATE.MagnetStatusLabel=statBox(fPosition,"Auto Magnet · đang gom / di chuyển","0 / 0")
STATE.MagnetReasonLabel=statBox(fPosition,"Auto Magnet · tình trạng","Đợi Farm")
dropdown(fPosition,"Farm position","FarmStyle",{"Above","Behind","Below","Orbit"})
toggle(fPosition,"Giữ trên không / Hover lock","FarmHoverLock","Duy trì cao độ phía trên NPC; không chạm quái khi farm")
slider(fPosition,"Target distance","FarmDistance",2,70,1)
slider(fPosition,"Target height","FarmHeight",12,60,1)
dropdown(fPosition,"Kiểu bay / Tween","MovementMode",{"Flight Tween","Proxy Tween","Direct Tween"},"Flight Tween giữ độ cao khi bay và Noclip lúc di chuyển; server có thể kéo về")
toggle(fPosition,"Cho phép dịch chuyển / Teleport","TeleportEnabled",
    "Tắt để chặn mọi lệnh bay tới NPC, đảo, spawn và teleport tự động; không xóa dữ liệu farm")
toggle(fPosition,"Tự thử lại khi Teleport lag","TeleportAutoRecover",
    "Nếu proxy dừng hoặc server kéo ngược, tự kiểm tra đích và thử lại có giới hạn")
slider(fPosition,"Số lần tự thử lại","TeleportRetryLimit",1,6,1)
STATE.TeleportStatusLabel=statBox(fPosition,"Teleport / đích hiện tại","Sẵn sàng")
slider(fPosition,"Độ cao khi bay qua biển","FlightWaterHeight",20,100,5)
slider(fPosition,"Tween speed (requested)","TweenSpeed",40,400,5)
 toggle(fPosition,"Tự giảm nhịp khi bị kéo ngược","MoveAutoBackoff",
   "Phát hiện sai lệch, dừng yêu cầu chuyển động và giảm tốc cho tới khi ổn định; không bypass server")
 slider(fPosition,"Phát hiện lệch vị trí (studs)","MoveCorrectionThreshold",8,40,1)
 STATE.MoveGuardLabel=statBox(fPosition,"Movement: server correction monitor","Waiting")
slider(fPosition,"Retarget distance","MoveRetargetThreshold",4,55,1,"Larger = less jerking when mobs move")
slider(fPosition,"Retarget cooldown","MoveRetargetDelay",.3,1.8,.1,"Avoid starting a new tween on every farm tick")
toggle(fPosition,"Reset Teleport [BETA]","ResetTeleport",
    "Đi xa giữa các vùng: thử đổi điểm spawn. Không hoạt động nếu chưa cho phép hồi sinh")
toggle(fPosition,"Cho phép hồi sinh để Reset TP","ResetTeleportAllowRespawn",
    "CẢNH BÁO: có thể làm nhân vật chết, mất vật phẩm đang cầm và ngắt farm")
slider(fPosition,"Reset TP cooldown (giây)","ResetTeleportCooldown",60,300,10)
action(fPosition,"Reset bộ điều khiển Tween (không chết)",function()
    STATE.ResetTeleport.ResetController()
    notice("Movement","Đã hủy tween và tạo lại proxy ở lượt di chuyển sau")
end)
action(fPosition,"Kiểm tra Reset TP",function()
    local t=STATE.ResetTeleport
    notice("Reset TP",string.format("%s | thử %d | hồi sinh %d | từ chối %d",
        t.Status,t.Attempts,t.Success,t.Rejected))
end)
toggle(fPosition,"Smart portal shortcuts","SmartPortal","Uses known Sea 1/2 entrances only if destination is substantially closer")
info(fPosition,"350 studs/s is the requested tween speed, not a guaranteed anti-cheat bypass. Check Movement diagnostics if Roblox corrects your position.")
slider(fPosition,"Attack interval (sec)","AttackDelay",.08,1.5,.01)
slider(fPosition,"Quest retry interval","QuestDelay",2,15,1)
slider(fPosition,"Low-health pause %","LowHealth",0,90,5)
toggle(fPosition,"Safe height override","SafeFarm")
end
do
local fAdvanced=section(farming,"Mastery & skills")
slider(fAdvanced,"Mastery threshold %","MasteryThreshold",5,95,5)
toggle(fAdvanced,"Automatic skill keys","AutoSkill","Uses input synthesis if supported by the executor")
slider(fAdvanced,"Skill key cooldown","AutoSkillDelay",.5,8,.1)
for _,key in ipairs({"Z","X","C","V","F"}) do toggle(fAdvanced,"Use skill "..key,"Skill"..key) end
end
do
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
toggle(fActions,"Xuyên vật cản khi bay (Noclip)","Noclip")
action(fActions,"Cancel current tween",function()
    STATE.TeleportDestination=nil
    if STATE.TeleportRecovery then
        STATE.TeleportRecovery.Token=(STATE.TeleportRecovery.Token or 0)+1
        STATE.TeleportRecovery.Pending=false
    end
    cancelMove();notice("Movement","Tween cancelled")
end)
end
end

do
-- Dedicated end-to-end melee progression controller from DynamicIsland reference.
do
    local pg=addPage("fullmelee","⚡","Full Melee / Godhuman",
        "Luyện mastery tuần tự · chi tiêu phải xác nhận · tiến độ trực tiếp")
    local a=section(pg,"AUTO FULL MELEE · THAO TÁC THẬT",
        "Đọc võ đã có, mastery từ Tool/Inventory, chọn võ còn thiếu và đưa Farm sang Mastery.")
    toggle(a,"Bật Auto Full Melee","AutoFullMelee",
        "Tự đổi vũ khí và bật Farm Mastery khi đã có Tool; mọi mua sắm tách riêng")
    toggle(a,"Tự farm mastery để nâng võ","FullMeleeAutoFarm",
        "Bật nếu muốn Director dùng Farm Engine sẵn có")
    toggle(a,"CHO PHÉP TỰ MUA VÕ (tốn Beli/Fragments)","FullMeleeAutoBuy",
        "Mặc định TẮT; mua được hay không phụ thuộc nhiệm vụ và phía server")
    slider(a,"Tối đa yêu cầu mua trong một phiên","FullMeleeMaxPurchases",1,8,1)
    slider(a,"Giãn cách giữa hai yêu cầu mua","FullMeleeCooldown",25,180,5)
    local b=section(pg,"TRẠNG THÁI THEO THỜI GIAN THỰC")
    STATE.FullMeleeStateLabel=statBox(b,"Bước","Chưa bật")
    STATE.FullMeleeCurrentLabel=statBox(b,"Võ / mastery","--")
    STATE.FullMeleeCountLabel=statBox(b,"Đã đủ mastery","0/10")
    action(b,"Quét lại kho võ và tiến độ",function()
        STATE.FullMelee.LastCheck=-math.huge
        STATE.FullMelee.ReadOnlyScan()
        notice("Full Melee",STATE.FullMelee.Stage)
    end)
    action(b,"Đặt lại số yêu cầu mua trong phiên",function()
        STATE.FullMelee.ResetSession();notice("Full Melee","Giới hạn mua được đặt lại")
    end)
    info(b,"Chuỗi mục tiêu: Dark Step → Electro → Water Kung Fu → Dragon Claw → Superhuman → Death Step → Sharkman Karate → Electric Claw → Dragon Talon → Godhuman. Một số điều kiện mở võ và vật liệu chưa có chuỗi tự lấy; Director sẽ báo lý do thay vì tự tuyên bố hoàn thành.")
end

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
    -- Static BossList supplied in data.lua; labels only, no false spawn claim.
    for _,row in ipairs(STATE.QuestMirror.Bosses(STATE.World)) do
        local name=tostring(row[2] or "")
        if name~="" and not seen[norm(name)] then
            list[#list+1]=name
            seen[norm(name)]=true
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
toggle(bAuto,"AUTO KATAKURI · Farm mobs → Mở portal → Đánh Boss","AutoKatakuri",
    "Tự farm Cake Land, gửi CakePrinceSpawner khi đủ điều kiện và đánh boss lúc xuất hiện")
toggle(bAuto,"Tự triệu hồi Cake Prince khi đủ điều kiện","KatakuriAutoSummon")
slider(bAuto,"Chu kỳ kiểm tra portal (giây)","KatakuriCheckInterval",8,60,1)
STATE.KatakuriStatusLabel=statBox(bAuto,"Katakuri · giai đoạn","Off")
STATE.KatakuriProgressLabel=statBox(bAuto,"Số quái còn lại / Spawner","Đang đọc")
do
local cake=section(bossPage,"Cake Portal · Drip Mama",
    "Chỉ mở khi trạng thái CakePrinceSpawner báo portal sẵn sàng")
toggle(cake,"Auto Cake Portal (Bật/Tắt)","AutoCakePortal",
    "Chỉ gửi lệnh mở khi check trả về 'open the portal now'; tắt mặc định")
toggle(cake,"Tự đến NPC drip_mama khi không Farm","CakeTravelToNPC",
    "Di chuyển đến NPC nhìn thấy trên client; không tự đoán vị trí")
slider(cake,"Cake status interval (sec)","CakeCheckDelay",12,90,1)
STATE.CakeStatusLabel=statBox(cake,"Cake Portal status","Standby")
end
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
action(fruitShop,"Buy random fruit",function() doOnce("Cousin","Buy") end,"Legacy method; may be unavailable")
do
local gacha=section(fruits,"Zioles Random Fruit · Remote API",
    "Theo snippet của bạn: CheckGachaAsync + RF/GachaNetworkRF. CÓ TỐN BELI.")
toggle(gacha,"Tự mua Gacha khi đủ điều kiện","AutoGachaZioles",
    "Chỉ bật khi muốn tiêu Beli. Tắt mặc định, pause khi Farm chạy")
slider(gacha,"Giới hạn giá mua (Beli)","GachaMaxPrice",1000,1000000,1000)
slider(gacha,"Khoảng cách giữa lần mua (s)","GachaCooldown",180,3600,60)
STATE.GachaStatusLabel=statBox(gacha,"Gacha status","Standby")
end
action(fruitShop,"Identify carried fruit from TextureId",function()
    local candidates={}
    for _,container in ipairs({LP:FindFirstChild("Backpack"),LP.Character}) do
        if container then
            for _,tool in ipairs(container:GetChildren()) do
                if tool:IsA("Tool") then
                    local name=STATE.ResolveFruitIcon(tool.TextureId)
                    if name then candidates[#candidates+1]=name end
                end
            end
        end
    end
    notice("Fruit icons",#candidates>0 and table.concat(candidates,", ") or "No known icon in equipped tools")
end)
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
    notice("Raid",ok and "Đã thử nhấn Raid (thao tác thủ công, không xác nhận sở hữu phiên)" or "Raid summon button not found",ok and "info" or "warn")
end)
toggle(raidMain,"AUTO RAID FULL · Mua chip → Bắt đầu → 5 đảo → Đánh","AutoRaid",
    "Một công tắc chạy cả chuỗi; cần Sea 2/3, Level 1100 và tiền mua chip")
toggle(raidMain,"Cho phép mua chip bằng Beli (tốn tiền)","RaidAutoBuyChip",
    "Mặc định bật; không tự tiêu Fruit")
toggle(raidMain,"Tự gọi Awaken sau raid","RaidAutoAwaken",
    "Chỉ nếu bạn chủ động bật; game có thể yêu cầu chọn nâng kỹ năng")
STATE.RaidStatusLabel=statBox(raidMain,"Auto Raid · giai đoạn","Off")
STATE.RaidWaveLabel=statBox(raidMain,"Đảo / số lượt / quái đã đánh","--")
STATE.RaidOwnerLabel=statBox(raidMain,"Nhận diện phiên raid gần nhân vật","Chưa vào")
STATE.RaidMagnetLabel=statBox(raidMain,"Gom quái Raid (tự động)","Đợi Raid riêng")
STATE.RaidCombatLabel=statBox(raidMain,"Tình trạng đánh quái","Chưa có mục tiêu")
slider(raidMain,"Bán kính tự gom quái Raid","RaidMagnetRadius",75,240,5)
info(raidMain,"Chạy raid vừa mở hoặc raid bạn đang đứng trong: cần timer và đảo gần. Không tự bay tới marker raid ở xa.")
info(raidMain,"Gom quái, đi đảo và đánh đều được nối sẵn vào AUTO RAID FULL.")

action(raidMain,"Travel to active raid island",function()
    notice("Raid",raidIsland() and "Moving to highest island" or "No raid location found")
end)
action(raidMain,"Check Raid NPC",function() doOnce("RaidsNpc","Check") end)
local raidHelp=section(raid,"Controls")
info(raidHelp,"Bật AUTO RAID FULL để mua chip, đến phòng raid và đánh. Nếu đã ở trong raid, công tắc sẽ dùng timer và đảo gần để nhận phiên hiện tại.")

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
toggle(fish,"Tự quăng cần + tự câu","AutoFish","Tự trang bị cần, kiểm tra mồi và vị trí nước; mặc định dùng fishing protocol")
toggle(fish,"Tự tìm bờ nước để quăng","FishingAutoFindWater","Nếu đang đứng trên đất: tìm bờ nước gần rồi di chuyển tới")
action(fish,"Quăng cần thử 1 lần",function()
    if STATE.Advanced then
        local ok,why=STATE.Advanced.CastFishing(true)
        notice("Fishing",tostring(why),ok and "info" or "warn")
    else fishOnce() end
end)
local rodState=statBox(fish,"Detected rod","--")
R.rodState=rodState
do
local slap=section(fishing,"Fishing Slap · BẬT/TẮT",
    "Chạm chính xác khi Tick vào vùng xanh; chỉ hoạt động khi FishSlapMinigame xuất hiện")
toggle(slap,"Auto Slap minigame","AutoFishSlap",
    "Yêu cầu firesignal của executor; mặc định tắt; không tự cast")
STATE.FishSlapLabel=statBox(slap,"Slap: trạng thái","Standby")
STATE.FishSlapStats=statBox(slap,"Attempts / dispatched","0 / 0")
end
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
action(qA,"Nhận nhiệm vụ đã chọn",function()
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
local spawnTravel=section(travel,"Điểm spawn theo phe")
dropdown(spawnTravel,"Điểm đến","SpawnDestination",STATE.SpawnChoices)
toggle(spawnTravel,"Theo dõi khoảng cách","SpawnRadar")
local spawnStatus=statBox(spawnTravel,"Điểm đến · khoảng cách · nguồn","Tắt")
startLoop("Team spawn radar",1,function()
    if not Config.SpawnRadar then spawnStatus("Tắt");return end
    local point,reason=STATE.ResolvePlayerSpawn(Config.SpawnDestination)
    spawnStatus(point and string.format("%s · %.0f studs · %s",point.Name,point.Distance,point.Source) or reason)
end)
action(spawnTravel,"Bay tới điểm spawn",function()
    if Config.FarmEnabled then notice("Spawn","Tắt Farm trước khi bay thủ công","warn");return end
    local point,reason=STATE.ResolvePlayerSpawn(Config.SpawnDestination)
    if not point then notice("Spawn",reason,"warn");return end
    if moveTo(CFrame.new(point.Position+Vector3.new(0,5,0))) then
        notice("Spawn",point.Name.." · "..point.Source)
    else notice("Spawn","Chưa thể bắt đầu di chuyển","warn") end
end)
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
action(namedTravel,"Cancel movement",function()
    STATE.TeleportDestination=nil
    if STATE.TeleportRecovery then
        STATE.TeleportRecovery.Token=(STATE.TeleportRecovery.Token or 0)+1
        STATE.TeleportRecovery.Pending=false
    end
    cancelMove()
end)
action(namedTravel,"Refresh NPC & island list",function()
    STATE.BuildTravelCatalog()
    notice("Travel","Đã nạp lại danh sách NPC/đảo theo Sea "..tostring(STATE.World))
end)
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
slider(prefs,"Kích thước menu","MenuSize",.76,1,.02,
    "0.76 = gọn hơn | 0.84 = mặc định v36 | 1.00 = rộng hơn")
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
    on(swatch,swatch.Activated,function()
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
    STATE.TeleportDestination=nil
    if STATE.TeleportRecovery then
        STATE.TeleportRecovery.Token=(STATE.TeleportRecovery.Token or 0)+1
        STATE.TeleportRecovery.Pending=false
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
dropdown(farming,"Farm strategy","FarmMode",{"Level","Nearest","Selected mob","Island","Boss","Material","Bones","Mastery","Aura","All Boss","Elite","Factory","Pirate Raid","Halloween Boss"})
toggle(farming,"Farm Engine · BẬT/TẮT","FarmEnabled")
toggle(farming,"Mob dodge on skill cast","AutoDodgeSkill","Raises the farm point temporarily when a physics skill is detected")
farmSwitch(farming,"Farm all spawned bosses","All Boss")
farmSwitch(farming,"Farm Elite Hunter","Elite")
farmSwitch(farming,"Farm Factory Core","Factory")
farmSwitch(farming,"Farm Pirate Raid","Pirate Raid")
farmSwitch(farming,"Farm selected island","Island")
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
toggle(ability,"AUTO RACE V4 · Blue Gear / Lever / Trial","AutoRaceV4",
    "Tự xử lý các bước có dữ liệu; không spam ActivateAbility")
toggle(ability,"Tự tìm Blue Gear / Mirage","V4AutoGear")
toggle(ability,"Tự tới Lever và tương tác","V4AutoLever")
toggle(ability,"Tự xử lý Trial theo Race","V4AutoTrial")
toggle(ability,"Tự ngắm trăng và kích hoạt T trên Mirage","V4AutoMoon",
    "Mặc định TẮT do thay đổi camera; có thể không chạy trên mọi executor Android")
dropdown(ability,"Hướng nâng Gear V4","V4GearChoice",{"Alpha","Omega"})
toggle(ability,"CHO PHÉP TỰ TIÊU ĐIỂM GEAR V4","V4AutoSpendPoints",
    "Mặc định TẮT. Chỉ dùng điểm đã có sau khi TempleClock xác nhận HadPoint")
action(ability,"Dùng 1 điểm Gear V4 ngay",function()
    local ok,msg=STATE.RaceV4Director.SpendGearPoint()
    notice("Race V4",tostring(msg),ok and "info" or "warn")
end,"Chọn Alpha/Omega trước; chỉ gửi nếu server báo có điểm")
STATE.V4StatusLabel=statBox(ability,"Race V4 · giai đoạn","Off")
STATE.V4TrialLabel=statBox(ability,"Race / Trial / Progress","--")
STATE.V4DoorLabel=statBox(ability,"Cửa tộc / đường dẫn thực tế","--")
STATE.V4DracoLabel=statBox(ability,"Draco Relic / trạng thái puzzle (v38)","Idle")
info(ability,"V38: chỉ vào Trial khi HUD đang chạy, Draco tự kiểm tra Relic theo màu, tìm điểm đặt, nhấn Prompt và xác minh lại trạng thái game.")
slider(ability,"Bán kính gom quái Trial","V4TrialMagnetRadius",75,230,5)
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
    W,H=STATE.MenuDimensions(size)
    compact=UIS.TouchEnabled or size.X<720 or size.X<size.Y
    navW=compact and 0 or 188
    win.Size=UDim2.fromOffset(W,H)
    shadow.Size=win.Size
    glow.Size=UDim2.fromOffset(W+24,H+24)
    -- Reset dragging after rotation to avoid a window outside the viewport.
    win.Position=UDim2.fromScale(.5,.5)
    shadow.Position=UDim2.new(.5,5,.5,9)
    glow.Position=UDim2.new(.5,5,.5,5)
    side.Position=UDim2.fromOffset(compact and 13 or 12,compact and 119 or 74)
    side.Size=compact and UDim2.new(1,-26,1,-201) or UDim2.new(0,navW,1,-132)
    side.Visible=not compact
    STATE.MobileDrawer=false
    STATE.DrawerBtn.Visible=compact
    STATE.DrawerBtn.Text="☰"
    searchBack.Position=UDim2.fromOffset(compact and 14 or navW+26,73)
    searchBack.Size=UDim2.new(1,compact and -28 or -navW-42,0,37)
    work.Position=UDim2.fromOffset(compact and 14 or navW+22,119)
    work.Size=UDim2.new(1,compact and -28 or -navW-36,1,compact and -194 or -170)
    work.Visible=true
    navScroll.Position=UDim2.fromOffset(compact and 7 or 4,compact and 8 or 34)
    navScroll.Size=UDim2.new(1,compact and -14 or -8,1,compact and -18 or -69)
    footer.Position=UDim2.new(0,13,1,compact and -58 or -46)
    footer.Size=UDim2.new(1,-26,0,compact and 46 or 32)
    STATE.MobileDock.Visible=compact
    footText.Visible=not compact
    sideFoot.Text="V36  •  GỌN · TRỰC TIẾP"
    sideFoot.Visible=not compact
    statusCapsule.Visible=not compact
    tagline.Visible=not compact
    tagline.Text="C R Y S T A L  W H I T E  /  3 8 . 9"
    brand.TextSize=compact and 19 or 22
    brand.Size=UDim2.new(1,compact and -195 or -220,0,29)
    for _,entry in pairs(navButtons) do entry.Label.Visible=true end
    for _,page in pairs(STATE.Pages) do
        local headingFrame=page.Heading and page.Heading.Parent
        if headingFrame then
            headingFrame.Size=UDim2.new(1,0,0,compact and 88 or 63)
            page.Heading.Size=UDim2.new(1,0,0,compact and 54 or 32)
            page.Underline.Position=UDim2.fromOffset(0,compact and 54 or 35)
            page.Subtitle.Position=UDim2.fromOffset(0,compact and 62 or 40)
            page.Subtitle.Size=UDim2.new(1,0,0,compact and 24 or 19)
        end
        for _,part in ipairs(page.Sections) do
            part.Header.Size=UDim2.new(1,-24,0,compact and 42 or 28)
            if part.Sub then part.Sub.Size=UDim2.new(1,0,0,compact and 55 or 40) end
        end
    end
    if STATE.NavResize then STATE.NavResize() end
end
STATE.ResizeMenu=function()
    local camera=WS.CurrentCamera
    if camera then resizeUI(camera.ViewportSize) end
end
STATE.ControlBindings.MenuSize=STATE.ControlBindings.MenuSize or {}
table.insert(STATE.ControlBindings.MenuSize,function() STATE.ResizeMenu() end)
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
    local update=section(events,"BOSS HALLOWEEN · MỚI",
        "Tìm boss đang được client tải; dùng engine đánh và di chuyển hiện có.")
    dropdown(update,"Chọn boss","HalloweenBossType",
        {"Tất cả","Hellfire Gas","The Great Pumpkin","Dapper Jack","Unbound Werewolf"})
    farmSwitch(update,"Tự đánh boss Halloween","Halloween Boss",
        "Bật để đánh boss còn sống trong phạm vi; không tự triệu hồi hoặc tiêu vật liệu")
    slider(update,"Phạm vi tìm boss (stud)","HalloweenBossRadius",200,4000,100)
    STATE.HalloweenBossLabel=statBox(update,"Boss đang thấy","Chưa quét")
    STATE.HalloweenWindowLabel=statBox(update,"Giờ gõ cửa ước tính","--")
    STATE.HalloweenMaterialsLabel=statBox(update,"Bits / Seeds / Candy","Chưa kiểm tra")
    STATE.HalloweenMaterialsStatus=statBox(update,"Điều kiện Great Pumpkin","Chưa kiểm tra")
    action(update,"Kiểm tra vật liệu Halloween",function()
        local ok,message=STATE.Halloween2026.RefreshMaterials()
        notice("Halloween",message,ok and "info" or "warn")
    end,"Đọc kho một lần; không mua hoặc dùng vật phẩm")
    info(update,"Lịch 00–09 mỗi giờ và mốc 200 Bits / 3 Seeds là thông tin tham khảo cộng đồng; xác nhận lại trong game.")
    local farm=section(events,"Halloween farming")
    info(farm,"To hunt event NPCs: set Farm type = Halloween, turn on Auto Farm, Combat và Auto Equip.")
    farmSwitch(farm,"Halloween NPC farm","Halloween","Bật / tắt farm quái Halloween khi sự kiện xuất hiện")
    local doors=section(events,"Trick or Treat · Gõ cửa tự động")
    toggle(doors,"Auto Trick or Treat / Gõ cửa","AutoTrickOrTreat",
        "Tìm HalloweenDoor trong Map; tới cửa, nhấn E, chọn option1. Tự nhường quyền đi lại cho sự kiện")
    toggle(doors,"Tự đánh quái vừa xuất hiện sau khi gõ cửa","HalloweenAutoFight",
        "Không cần bật Farm Halloween; ưu tiên quái sự kiện trước cửa tiếp theo")
    toggle(doors,"Ưu tiên GhostChase khi xuất hiện","HalloweenGhostChase",
        "Theo mã Topi: ghé các model GhostChase trước, sau đó trở lại gõ cửa")
    toggle(doors,"Tự vào SceneWindow và đánh Hellfire","HalloweenSceneFight",
        "Ưu tiên SceneWindow, đánh Hellfire Gas và quái trong realm khi xuất hiện")
    toggle(doors,"Chỉ thử trong 10 phút đầu mỗi giờ","TrickTreatWindowOnly",
        "Theo Topi event 00–09; tắt nếu client dùng giờ khác hoặc sự kiện có lịch mới")
    slider(doors,"Chờ trước khi thử lại cửa (giây)","TrickTreatRevisit",30,240,10)
    STATE.TrickTreatStatusLabel=statBox(doors,"Trick or Treat status","Off")
    STATE.TrickTreatCountLabel=statBox(doors,"Ghi nhận cửa / gõ / hội thoại","0 / 0 / 0")
    info(doors,"Chỉ thấy cửa đang được Roblox tải vào client. Chưa vào đúng khu vực hoặc server không có sự kiện sẽ báo Không có cửa")
    info(farm,"Quái Halloween được tự gom khi có mục tiêu và Farm đang đánh, không cần bật thêm mục nào.")
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
    info(options,"Các chế độ chạy liên tục đều điều khiển bằng công tắc Bật/Tắt. Thao tác một lần (mua đồ, nhận quest, teleport) dùng nút hành động.")
end

do
    local pg=addPage("fishingpro","◉","Fishing PRO","Source-based FishingRequest, bait, water spots and catching")
    local core=section(pg,"Complete fishing controls","Topi source sequence: cast → wait for fish → optional catch events.")
    toggle(core,"ENABLE AUTO FISHING","AutoFish","Master toggle: no fishing requests are sent when OFF")
    toggle(core,"Quăng cần bằng FishingRequest","FishingAdvanced","Dùng StartCasting -> CastLineAtLocation chuẩn vị trí mặt nước; nên bật")
    toggle(core,"Tự tìm bờ nước khi chưa có vị trí","FishingAutoFindWater","Quét bờ nước đang tải, đi tới rồi quay mặt về biển")
    toggle(core,"Cho phép chế mồi tự động (tốn tài nguyên)","FishingAutoCraftBait","TẮT mặc định; có thể tiêu nguyên liệu khi không còn mồi")
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
        local ok,why=STATE.Advanced.CastFishing(true)
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
    local fStatus=section(pg,"Trạng thái câu cá · LIVE")
    STATE.MobileFishState=statBox(fStatus,"Bước hiện tại","Chưa bật")
    STATE.MobileFishError=statBox(fStatus,"Lý do chưa quăng","--")
    action(fStatus,"Read casting / catching telemetry",function()
        local f=STATE.Advanced.Fish
        notice("Fishing",string.format("Casts %d | Catch requests %d | Failures %d | %s",
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

function STATE.BuildSecretMobilePage()
    local pg=addPage("secret39","☷","Secret Quests · MOBILE","Sea 1 · tiến độ thật, tự động theo trạng thái sự kiện")
    local live=section(pg,"AUTO SECRET QUEST · BẬT/TẮT","Ưu tiên thao tác cảm ứng; chỉ chạy khi bạn bật. Không tự nhận hoàn thành 39/39.")
    toggle(live,"Tự làm Secret Quest có engine","AutoSecretQuestRoute",
        "Tìm nhiệm vụ thiếu, đến đảo để nạp moment và chạy nhánh có handler")
    dropdown(live,"Chế độ tự làm","SecretQuestRunMode",{"Tự làm quest khả dụng","Chỉ nhiệm vụ đã chọn"})
    local secretDone=statBox(live,"Quest đảo đã nhận diện","Chưa đọc")
    local secretCurrent=statBox(live,"Nhiệm vụ đang xử lý","Chưa bật")
    local secretStep=statBox(live,"Bước hiện tại","Chờ")
    local secretIssue=statBox(live,"Lỗi / trạng thái","Không")
    STATE.SecretMobileLabels={Done=secretDone,Current=secretCurrent,Step=secretStep,Issue=secretIssue}
    action(live,"Cập nhật tiến độ ngay",function()
        local count,errorMsg=STATE.SecretQuestDirector.Refresh()
        notice("Secret Quest",tostring(count).."/39 · "..tostring(errorMsg))
    end,"Kiểm tra tiến độ server mà không cần mở F9")
    action(live,"Xem thông tin nhiệm vụ đầy đủ",function()
        local d=STATE.SecretQuestDirector
        notice("Secret Quest",d.Status.." | "..d.Stage.." | "..d.LastError)
    end,"Đọc toàn bộ bước hiện tại trên điện thoại")
    info(live,"Tự động thật một phần theo engine Topi: Archaeologist's Tablet, Prickly Harvest, Windmill Maintenance, Fountain Pipe Repair, Fountain Wire Repair, King's Apprentice, Lookout, Rescue Hasan, Breaking the Ice, Evil Slimes, Electric Fighting Teacher. Các quest khác sẽ chờ hoặc báo chưa hỗ trợ, KHÔNG tự nhận xong.")
    info(live,"Theo nguồn cộng đồng: ngoài 39 quest đảo còn The Finale ở Middle Town. Script chưa xác nhận hoặc tự hoàn thành The Finale.")
    local list=section(pg,"Danh sách 39 nhiệm vụ","Dùng bảng chọn trên điện thoại; các thao tác bên dưới là thao tác một lần.")
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
        local count,reason=STATE.SecretQuestDirector.Refresh()
        notice("Secret Quests",tostring(count).."/39 · "..tostring(reason))
    end)
    info(list,"Nguồn Teddy chứa nút giả; v28 đã thay bằng bộ xử lý quest dựa vào Topi. 19/39 loại có handler; các bước puzzle còn lại chưa được chứng minh hoạt động.")
end
STATE.BuildSecretMobilePage()
STATE.BuildSecretMobilePage=nil

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
    local missions=section(pg,"Mission preparation","Chọn nhiệm vụ, sau đó bật công tắc Auto Farm.")
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
    toggle(nav,"Auto Boat Navigation · BẬT / TẮT","AutoSeaBoat","Opt-in. Requires a boat you own and are seated in.")
    action(nav,"Buy selected boat",function()
        local ok,res=EX.BuyBoat()
        notice("Boat",ok and "Purchase requested" or tostring(res),ok and "info" or "warn")
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
    toggle(control,"Combo Macro · BẬT / TẮT","SpookyMacroEnabled",
        "Bật: chạy slot đã chọn. Tắt: dừng và nhả phím. Tự tắt sau một lượt nếu Loop đang OFF")
    action(control,"Kiểm tra trạng thái Macro",function()
        notice("Macro",M.MacroRunning and "Đang chạy" or tostring(M.Status))
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

-- v35 ONE-TAP FLAT NAVIGATION
-- Unlike previous revisions there are no clickable parent groups, hidden subpages,
-- expandable nav categories, or MORE controls. Static labels only organize the list.
STATE.BuildFlatNav=function()
    local columns={
        {"THƯỜNG DÙNG",{"home","farm","boss","raid","halloween","fishingpro","secret39","race","travel"}},
        {"AUTO FARM / CHIẾN ĐẤU",{"fullmelee","materials","combat","spookycombat","unified","specialboss","spookydungeon","spookypvp","spookymacro"}},
        {"QUEST / VẬT PHẨM",{"quests","fruits","progress","shop","craft","progressplus"}},
        {"BIỂN / SỰ KIỆN",{"sea","fishing","events","seapilot","extras"}},
        {"HỆ THỐNG / CÔNG CỤ",{"integrated","diagnosticspro","server","settings","spookymovement","esp","spookyvisual","toolplus"}},
    }
    local labels={
        home="Tổng quan",farm="Auto Farm",boss="Boss / Katakuri",
        raid="Auto Raid",halloween="Halloween gõ cửa",fishingpro="Auto Fishing PRO",
        secret39="Secret Quest",race="Race V4",travel="Teleport / Bản đồ",
        fullmelee="Full Melee / Godhuman",materials="Farm nguyên liệu",
        combat="Chiến đấu",spookycombat="Fast Attack+",unified="Farm nâng cao",
        specialboss="Boss đặc biệt",spookydungeon="Dungeon",spookypvp="PvP",
        spookymacro="Combo / Macro",quests="Nhiệm vụ",fruits="Trái ác quỷ",
        progress="Tiến trình",shop="Cửa hàng",craft="Chế tạo",
        progressplus="Quest & Race PRO",sea="Sea Events",fishing="Câu cá",
        events="Sự kiện thế giới",seapilot="Thuyền / Biển",
        extras="Tính năng bổ sung",integrated="Trung tâm điều khiển",
        diagnosticspro="Chẩn đoán lỗi",server="Máy chủ",settings="Cài đặt",
        spookymovement="Di chuyển",esp="ESP",spookyvisual="Hiệu ứng",
        toolplus="Công cụ khác",
    }
    local captions={}
    local found={}
    for g,grp in ipairs(columns) do
        local order=g*100
        local caption=mk("TextLabel",{
            Name="SectionLabel_"..g,Text=grp[1],TextColor3=C.Quiet,
            TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Bottom,
            TextSize=10,Font=Enum.Font.GothamBold,BackgroundTransparency=1,
            BorderSizePixel=0,Size=UDim2.new(1,-12,0,compact and 33 or 32),
            LayoutOrder=order,
        },navScroll)
        captions[g]=caption
        for p,id in ipairs(grp[2]) do
            local item=navButtons[id]
            assert(item and STATE.Pages[id],"Missing navigation page: "..id)
            assert(not found[id],"Duplicated navigation page: "..id)
            found[id]=true
            item.Back.LayoutOrder=order+p
            item.Back.Size=UDim2.new(1,0,0,UIS.TouchEnabled and 46 or 43)
            item.Back.Visible=true
            item.Label.Text=labels[id] or STATE.Pages[id].Title
            STATE.Pages[id].NavTitle=item.Label.Text
            STATE.Pages[id].Heading.Text=item.Label.Text
            item.Label.TextSize=UIS.TouchEnabled and 12 or 12
            item.Label.Visible=true
        end
    end
    for id in pairs(STATE.Pages) do
        assert(found[id],"Unlisted navigation page: "..id)
    end
    local function rebuild(q)
        q=tostring(q or ""):lower():match("^%s*(.-)%s*$") or ""
        for groupID,grp in ipairs(columns) do
            -- Categories are pure visual separators, never interactive steps.
            captions[groupID].Visible=q==""
            for _,id in ipairs(grp[2]) do
                local item=navButtons[id]
                local matched=q=="" or (STATE.Pages[id].SearchHits or 0)>0
                item.Back.Visible=matched
                item.Label.Visible=true
            end
        end
    end
    STATE.NavRebuild=rebuild
    STATE.NavResize=function()
        for _,cap in ipairs(captions) do
            cap.Size=UDim2.new(1,-12,0,compact and 34 or 32)
        end
        for id,item in pairs(navButtons) do
            item.Label.Visible=true
            item.Back.Size=UDim2.new(1,0,0,UIS.TouchEnabled and 46 or 43)
        end
        rebuild(searchBox.Text)
    end
    STATE.OpenPage=function(id)
        if not STATE.Pages[id] then return end
        if STATE.FocusDock then STATE.FocusDock(id) end
        choosePage(id)
        -- The drawer closes in choosePage() on mobile after exactly one tap.
    end
    -- Backwards compatibility for previous in-script API callers.
    STATE.OpenGroup=function(_,preferred)
        STATE.OpenPage(preferred or "home")
    end
    STATE.NavBrowseGroup=function(_) if compact then STATE.ShowMobileDrawer(true) end end
    STATE.NavCatalog=columns
    rebuild("")
end
STATE.BuildFlatNav()
-- Mobile pages open their first, high-value card only.  Every other card is
-- still one tap away, but a phone no longer receives a wall of controls.
for _,page in pairs(STATE.Pages) do
    for index,sec in ipairs(page.Sections) do sec:SetCollapsed(compact and index~=1 or false) end
end

STATE.OpenPage("home")
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
    if STATE.TeleportStatusLabel then
        local destination=STATE.TeleportDestination
        local recovery=STATE.TeleportRecovery
        local status=not Config.TeleportEnabled and "Tắt" or
            (destination and destination.Active and (destination.Name.." · "..tostring(destination.Status))
                or (recovery and recovery.Status or "Sẵn sàng"))
        STATE.TeleportStatusLabel(status)
    end
    if R.statWorldProgress and STATE.WorldProgression then
        R.statWorldProgress(STATE.WorldProgression.Status)
    end
    if R.pickupStatus and STATE.Pickups then
        R.pickupStatus(STATE.Pickups.LastStatus)
    end
    if STATE.MagnetStatusLabel and STATE.MobMagnet then
        local m=STATE.MobMagnet
        STATE.MagnetStatusLabel(string.format("%d / %d",m.Active,m.LocalMoves))
        STATE.MagnetReasonLabel(m.LastError)
        if STATE.MobileQuickStatus then
            local flight=(STATE.Mover and STATE.Mover.Active and STATE.Mover.Mode=="Flight Tween")
                and "Bay liên tục" or "Đứng yên"
            STATE.MobileQuickStatus(flight.." · gom "..tostring(m.Active).." · "..tostring(m.LastError):sub(1,56))
        end
    end
    if R.v34Halloween then R.v34Halloween(tostring(STATE.TrickTreat and STATE.TrickTreat.Status or "Off")) end
    if R.v34Kata then R.v34Kata(tostring(STATE.KatakuriDirector and STATE.KatakuriDirector.Status or "Off")) end
    if R.v34Raid then R.v34Raid(tostring(STATE.RaidDirector and STATE.RaidDirector.Status or "Off")) end
    if R.v34Race then R.v34Race(tostring(STATE.RaceV4Director and STATE.RaceV4Director.Status or "Off")) end
    if STATE.KatakuriDirector and STATE.KatakuriStatusLabel then
        local k=STATE.KatakuriDirector
        STATE.KatakuriStatusLabel(k.Stage.." · "..tostring(k.Status):sub(1,100))
        STATE.KatakuriProgressLabel(k.Remaining and ("Còn "..k.Remaining.." mobs") or
            tostring(k.SpawnerReply or "Chưa có dữ liệu"):sub(1,85))
    end
    if STATE.RaidDirector and STATE.RaidStatusLabel then
        local d=STATE.RaidDirector
        STATE.RaidStatusLabel(d.Stage.." · "..tostring(d.Status):sub(1,100))
        STATE.RaidWaveLabel(tostring(d.Wave).."/5 · Lượt "..d.RunCount.." · Tấn công "..d.Attacks)
        if STATE.RaidOwnerLabel then STATE.RaidOwnerLabel(d.Owned and ("Raid gần #"..d.SessionId)
            or ("Chưa nhận · bỏ qua raid khác "..d.ForeignIgnored)) end
        if STATE.RaidMagnetLabel then STATE.RaidMagnetLabel(d.Owned and
            ("Đang gom "..(STATE.MobMagnet and STATE.MobMagnet.Active or 0).." quái") or "Chờ Raid riêng") end
        if STATE.RaidCombatLabel then
            local attack=STATE.FastAttackDirector
            STATE.RaidCombatLabel(d.Owned and tostring(attack and attack.Status or
                (STATE.CombatTelemetry and STATE.CombatTelemetry.LastIssue) or "Chờ mục tiêu")
                or "Chưa có mục tiêu")
        end
    end
    if STATE.RaceV4Director and STATE.V4StatusLabel then
        local v=STATE.RaceV4Director
        STATE.V4StatusLabel(v.Stage.." · "..tostring(v.Status):sub(1,90))
        STATE.V4TrialLabel(tostring(v.Race).." / "..tostring(v.Trial).." / "..tostring(v.Progress))
        if STATE.V4DoorLabel then STATE.V4DoorLabel(tostring(v.DoorStatus).." · cách "..
            tostring(v.DoorDistance and math.floor(v.DoorDistance) or "--").." studs") end
        if STATE.V4DracoLabel and v.Draco then
            STATE.V4DracoLabel(tostring(v.Draco.Stage).." · "..tostring(v.Draco.Status):sub(1,90))
        end
    end
    if STATE.TrickTreat and STATE.TrickTreatStatusLabel then
        local t=STATE.TrickTreat
        STATE.TrickTreatStatusLabel(t.Status)
        STATE.TrickTreatCountLabel(t.DoorsFound.." / "..t.Prompts.." / "..t.DialogueClicks)
    end
    if selectedPage=="halloween" and STATE.HalloweenBossLabel then
        local H=STATE.Halloween2026
        local boss,distance=H.FindBoss(Config.HalloweenBossType,Config.HalloweenBossRadius)
        if boss then
            local humanoid=boss:FindFirstChildOfClass("Humanoid")
            local hp=humanoid and (" · HP "..math.floor(humanoid.Health)) or ""
            H.BossStatus=boss.Name.." · "..math.floor(distance or 0).." studs"..hp
        else
            H.BossStatus="Chưa thấy boss còn sống trong phạm vi"
        end
        STATE.HalloweenBossLabel(H.BossStatus)
        local active,seconds=H.Window()
        STATE.HalloweenWindowLabel((active and "Ước tính đang mở · còn " or "Ước tính mở sau ")..
            string.format("%02d:%02d",math.floor(seconds/60),seconds%60))
        local function show(v) return v==nil and "?" or tostring(v) end
        STATE.HalloweenMaterialsLabel(show(H.Bits).." / "..show(H.Seeds).." / "..show(H.Candy))
        STATE.HalloweenMaterialsStatus(H.MaterialStatus)
    end
    if STATE.MoveGuardLabel and STATE.MoveGuard then
        STATE.MoveGuardLabel(STATE.MoveGuard.Status)
    end
    if STATE.FarmV25Thread and STATE.CombatBridge then
        local b=STATE.CombatBridge
        STATE.FarmV25Thread(b.Status.." / batches "..tostring(b.Calls))
    end
    if STATE.MobileFishState and STATE.Advanced then
        local fish=STATE.Advanced.Fish
        STATE.MobileFishState(tostring(fish.State or "Standby").." | Cast "..tostring(fish.Casts))
        STATE.MobileFishError(tostring(fish.LastError or fish.WaterError or "--"))
    end
    if STATE.FishSlapLabel and STATE.BonusFeatures then
        local s=STATE.BonusFeatures.Slap
        STATE.FishSlapLabel(s.Last)
        STATE.FishSlapStats(tostring(s.Attempts).." / "..tostring(s.Activated))
    end
    if STATE.SecretMobileLabels and STATE.SecretQuestDirector then
        local d=STATE.SecretQuestDirector
        STATE.SecretMobileLabels.Done((d.LastProgressError=="Không" and tostring(d.Completed).."/39 quest đảo" or "Chưa có dữ liệu").." · "..tostring(d.Supported).." handler")
        STATE.SecretMobileLabels.Current(d.Current)
        STATE.SecretMobileLabels.Step(d.Stage)
        STATE.SecretMobileLabels.Issue(d.LastError~="Không" and d.LastError or d.Status)
    end
    if STATE.FullMelee and STATE.FullMeleeStateLabel then
        local m=STATE.FullMelee
        STATE.FullMeleeStateLabel(m.Stage)
        STATE.FullMeleeCurrentLabel(string.format("%s · %d/%d",m.Current,m.Mastery,m.Target))
        STATE.FullMeleeCountLabel(tostring(m.Completed).."/"..tostring(m.Total))
    end
    if STATE.GachaStatusLabel then STATE.GachaStatusLabel(STATE.BonusFeatures.Gacha.Last) end
    if STATE.CakeStatusLabel then STATE.CakeStatusLabel(STATE.BonusFeatures.Cake.Last) end
    if STATE.FarmV24Stats and STATE.FastAttackDirector then
        local a=STATE.FastAttackDirector
        STATE.FarmV24Stats(string.format("%d / %d / %d",a.RemotePairs,a.TargetsInBurst,a.HPEvents))
        STATE.FarmV24DPS(string.format("%.1f DPS / HP -%.0f",a.DamagePerSecond,a.ConfirmedDamage))
        STATE.FarmV24Issue(a.LastReason or a.Status)
    end
    if STATE.AtlasV24Status and STATE.RouteDirector then
        STATE.AtlasV24Status(STATE.RouteDirector.LastStatus)
    end
    if STATE.CombatStatusLabel then
        local d=STATE.CombatTelemetry
        STATE.CombatStatusLabel(Config.FarmEnabled and
            ("HP drops "..d.HealthChanged.." / tries "..d.Attempts) or "Idle")
    end
    R.engineStatus(Config.FarmEnabled and ("Farm · Auto gom "..tostring(STATE.MobMagnet.Active)) or "Standby")
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
STATE.ResetMovementController=function() return STATE.ResetTeleport.ResetController() end
STATE.GetMobMagnetStats=function() return STATE.MobMagnet end
STATE.GetHalloweenDoorStats=function() return STATE.TrickTreat end
STATE.GetV34Diagnostics=function()
    return {
        halloween=STATE.TrickTreat and STATE.TrickTreat.Status,
        katakuri=STATE.KatakuriDirector and STATE.KatakuriDirector.Status,
        raid=STATE.RaidDirector and STATE.RaidDirector.Status,
        racev4=STATE.RaceV4Director and STATE.RaceV4Director.Status,
        combat=STATE.FastAttackDirector and STATE.FastAttackDirector.Status
    }
end
STATE.GetMovementGuard=function() return STATE.MoveGuard end
STATE.GetV38Diagnostics=function()
    local d=STATE.RaidDirector;local v=STATE.RaceV4Director
    return {raid={stage=d and d.Stage,proof=d and d.SessionProof,
            own=d and d.Owned,wave=d and d.Wave},
        trial={stage=v and v.Stage,race=v and v.Race,
            timer=v and v.IsTrialTimerVisible(),
            draco=v and v.Draco and v.Draco.Status},
        magnet=STATE.MobMagnet and STATE.MobMagnet.LastError,
        region=STATE.RegionNavigator and STATE.RegionNavigator.Status}
end
STATE.GetOverheadState=function()
    return {Enabled=Config.FarmEnabled and Config.FarmStyle=="Above",Height=Config.FarmHeight,
        Hovering=STATE.FarmHover.Force~=nil,Target=STATE.FarmHover.Target and STATE.FarmHover.Target.Name or "None"}
end
STATE.UIVersion="Crystal White Liquid Glass 38.9 / Mobile"
STATE.FeatureCoverage={
    Engine={"Farm modes","Quest reference","Mob Magnet","Fast Attack requests","3 Sea Atlas","Fruit/Gacha","Fishing Slap","Raid","Travel","ESP","Mobile thumb dock","Halloween GhostChase","Melee mastery planner"},
    Partial={"Dungeon progress","Cake Portal","Race progression","Sea Events","Rare bosses","PvP combat","Full melee steps","Halloween scene"},
    Unverified={"CDK full chain","Soul Guitar puzzle","Race V4 trials","Draco chain","Leviathan full chain","Server-confirmed attack rate"},
}
STATE.GetNavigationSummary=function()
    local pages=0;for _ in pairs(STATE.Pages) do pages=pages+1 end
    return {Groups=0,Pages=pages,Compact=true,ThumbDock=true,AllFeaturesSearchable=true,FlatNav=true}
end
STATE.SetTheme=themeSelect
STATE.UnifiedFeatures=EX
STATE.AdvancedFeatures=STATE.Advanced
STATE.GetSecretQuestState=function() return STATE.SecretQuestDirector.Snapshot() end
STATE.HealthCheck=function() return STATE.Advanced.HealthCheck() end
STATE.SetGlassIntensity=function(percent)
    setFlag("GlassIntensity",math.clamp(tonumber(percent) or 76,15,100))
end
STATE.SetHighContrast=function(enabled) setFlag("HighContrast",not not enabled) end
STATE.SelectPage=function(id) if STATE.OpenPage then STATE.OpenPage(id) else choosePage(id) end end
STATE.Stop=function()
    STATE.TeleportDestination=nil
    if STATE.TeleportRecovery then
        STATE.TeleportRecovery.Token=(STATE.TeleportRecovery.Token or 0)+1
        STATE.TeleportRecovery.Pending=false
    end
    for _,key in ipairs({"FarmEnabled","AutoWorldProgression","AutoSea","AutoChest","AutoCollectFruit","AutoAdvanceRaid","AutoRaidCombat",
        "AutoFactory","AutoPirateRaid","AutoSoulReaper","AutoDarkbeard","AutoRipIndra","AutoDoughKing","AutoEliteCombat",
        "AutoEventCollect","AutoFollowPlayer","AutoSafeItems","AutoChestHop","AutoSeaHop","AutoFruitHop",
        "AutoBerry","AutoBerryHop","AutoMagnetToken","EventRadar",
        "AutoKatakuri","AutoRaceV4","AutoRaid",
        "HalloweenPumpkins","AutoTrickOrTreat","AutoFish","AutoSeaBoat","FishingGoVortex",
        "AutoSecretQuestRoute","AutoFullMelee","AutoFishSlap","AutoGachaZioles","AutoCakePortal"}) do
        setFlag(key,false)
    end
    for _,key in ipairs({"AutoFullMelee","MobMagnetNetworkAssist","ResetTeleport",
        "ResetTeleportAllowRespawn","SpookyMacroEnabled"}) do setFlag(key,false) end
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
notice("andepzai 38.9","Mobile UI · Halloween boss · Sea "..STATE.World)
print("[andepzai] CRYSTAL WHITE 38.9 Mobile | Farm OFF | Sea="..STATE.World)
STATE.GetCombatSnapshot=function() return STATE.FastAttackDirector.Snapshot() end
STATE.GetAtlasRouteSnapshot=function() return STATE.RouteDirector.Snapshot() end
STATE.GetFarmAudit=function() return STATE.FarmAudit.Snapshot() end
STATE.GetCombatBridge=function() return STATE.CombatBridge.Snapshot() end
STATE.GetReferenceData=function() return STATE.QuestMirror.Summary() end
STATE.GetNewFeatureSnapshot=function() return STATE.BonusFeatures.Snapshot() end
STATE.GetFullMeleeSnapshot=function() return STATE.FullMelee.Snapshot() end
return STATE
