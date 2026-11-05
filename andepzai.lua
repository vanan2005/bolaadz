--[[
  andepzai / CRYSTAL WHITE LIQUID GLASS 9.0 — ROUNDED
  An independent Blox Fruits Luau hub, inspired by the feature categories
  in three user-supplied scripts. No original script, UI library, or
  remote third-party Lua is loaded.
  Runtime: Blox Fruits client and executor-supported features where needed.
  Controls that depend on game internals may need updates after game patches.
]]
local env = (type(getgenv) == "function" and getgenv()) or _G
-- Re-execution cleans up both this release and the previous standalone hub.
for _,slot in ipairs({"__ANDEPZAI_V9","__ANDEPZAI_V8","__ANDEPZAI_V7","__ANDEPZAI_V6","__ANDEPZAI_V5","__ANDEPZAI_V4","__ANDEPZAI_V3"}) do
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
env.__ANDEPZAI_V9 = STATE
local PLACE = { [2753915549]=1,[85211729168715]=1,[4442272183]=2,[79091703265657]=2,
    [7449423635]=3,[100117331123089]=3 }
STATE.World = PLACE[game.PlaceId] or 0

local defaults = {
  FarmMode="Level", Weapon="Melee", Mob="Bandit", Boss="The Gorilla King", Material="Bones",
  FarmEnabled=false, AutoQuest=true, Combat=true, AutoHaki=true, AutoKen=false, AutoRace=false,
  AutoEquip=true, AutoSkill=false, SkillZ=true, SkillX=true, SkillC=false, SkillV=false, SkillF=false,
  FarmDistance=18, FarmHeight=15, TweenSpeed=180, AttackDelay=0.19, QuestDelay=4,
  FarmStyle="Above", SafeFarm=false, LowHealth=25, MasteryThreshold=30,
  Noclip=true, AutoStats=false, Stat="Melee", AutoCollectFruit=false, AutoStoreFruit=false,
  AutoChest=false, AutoBerry=false, AutoRaid=false, AutoAdvanceRaid=false, AutoRaidCombat=false, Raid="Flame",
  AutoBuso=false, AutoObservation=false, AutoRaceV3=false, AutoRejoin=false, AntiAFK=true,
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
}
local Config = {}
for k,v in pairs(defaults) do Config[k]=v end
local FOLDER = "andepzai"
local FILE = FOLDER .. "/config_v9.json"
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
    local ok,decoded = pcall(function()
        local path=FILE
        if not api("isfile")(path) then path=FOLDER.."/config_v7.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v6.json" end
        if not api("isfile")(path) then path=FOLDER.."/config_v3.json" end
        if not api("isfile")(path) then return nil end
        return Http:JSONDecode(api("readfile")(path))
    end)
    if not ok or type(decoded)~="table" then return false end
    for k,v in pairs(decoded) do
        if defaults[k]~=nil and type(v)==type(defaults[k]) then Config[k]=v end
    end
    -- Safety: don't silently restart ongoing activities upon rejoin/re-execute.
    for k,v in pairs(defaults) do if type(v)=="boolean" and v==false then Config[k]=false end end
    return true
end
load()
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
 {2450,2474,"Isle Outlaw","TikiQuest1",1},{2475,2499,"Island Boy","TikiQuest1",2},
 {2500,2524,"Sun-kissed Warrior","TikiQuest2",1},{2525,2549,"Isle Champion","TikiQuest2",2},
 {2550,2574,"Serpent Hunter","TikiQuest3",1},{2575,2599,"Skull Slayer","TikiQuest3",2},
 {2600,2624,"Reef Bandit","SubmergedQuest1",1},{2625,2649,"Coral Pirate","SubmergedQuest1",2},
 {2650,2674,"Sea Chanter","SubmergedQuest2",1},{2675,2699,"High Disciple","SubmergedQuest3",1},
 {2700,9999,"Grand Devotee","SubmergedQuest3",2}},
}
-- Known fast-travel destination vectors, requestEntrance is game/version dependent.
local PORTALS={
 [1]={Vector3.new(-7894.62,5545.49,-380.25),Vector3.new(-4607.82,872.54,-1667.56),
      Vector3.new(61163.85,11.76,1819.78),Vector3.new(3876.28,35.10,-1939.32)},
 [2]={Vector3.new(-288.46,306.13,598.0),Vector3.new(2284.91,15.15,905.48),
      Vector3.new(923.21,126.98,32852.83),Vector3.new(-6508.56,89.03,-132.84)},
 [3]={},
}
local function questRoute(levelValue,seaIndex)
  if seaIndex==1 and levelValue<10 and LP.Team and LP.Team.Name=="Marines" then return nil end
  for _,route in ipairs(ROUTES[seaIndex] or {}) do
    if levelValue>=route[1] and levelValue<=route[2] then return route end
  end
end

local function enemySearch(query,excludeBoss)
    local folder=enemyFolder(); if not folder then return nil end
    local _,_,root=alive(); if not root then return nil end
    local best,dist=nil,math.huge
    local names = (type(query)=="table" and query) or (query and {query}) or nil
    for _,m in ipairs(folder:GetChildren()) do
        local h=m:FindFirstChildOfClass("Humanoid")
        local r=m:FindFirstChild("HumanoidRootPart")
        if h and r and h.Health>0 and (not excludeBoss or not isBoss(m.Name)) then
            local hit=not names
            if names then for _,name in ipairs(names) do
                if norm(m.Name)==norm(name) then hit=true;break end
            end end
            if hit then
                local d=(r.Position-root.Position).Magnitude
                if d<dist then best,dist=m,d end
            end
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
    local pos=mobSpawns[name]
    if pos then return CFrame.new(pos[1],pos[2]+24,pos[3]) end
    return nil
end
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
local omitQuests={BartiloQuest=true,Trainees=true,MarineQuest=true,CitizenQuest=true}
local function questInfoDynamic()
    if not (Quests and Guide and Guide.Data and Guide.Data.NPCList) then return nil end
    local l=level(); local best,bestLv=nil,-1
    for _,npc in pairs(Guide.Data.NPCList) do
        local group=Quests[npc.InternalQuestName]
        if group and npc.Levels and not omitQuests[npc.InternalQuestName] then
            for questIndex,req in pairs(npc.Levels) do
                if type(req)=="number" and req<=l and req>=bestLv then
                    local detail=group[questIndex]
                    if detail and detail.Task then
                        for mob,count in pairs(detail.Task) do
                            if count>1 then
                                bestLv=req
                                best={Mob=mob,Name=npc.InternalQuestName,Id=questIndex,Pos=npc.CFrame or npc.Position}
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end
local function questInfo()
    local live=questInfoDynamic()
    if live and not Config.PreferRouteData then return live end
    local route=questRoute(level(),STATE.World)
    if not route then return live end
    local npcCF=nil
    if Guide and Guide.Data and Guide.Data.NPCList then
        for _,npc in pairs(Guide.Data.NPCList) do
            if npc.InternalQuestName==route[4] then
                npcCF=npc.Position or npc.CFrame
                if typeof(npcCF)=="Vector3" then npcCF=CFrame.new(npcCF) end
                if typeof(npcCF)=="CFrame" then break end
            end
        end
    end
    if not npcCF and not Config.PreferRouteData then return live or {
        Mob=route[3],Name=route[4],Id=route[5],Pos=nil,Source="Reference"} end
    return {Mob=route[3],Name=route[4],Id=route[5],Pos=npcCF,Source="Reference"}
end
local function hasQuest()
    local data=Guide and Guide.Data
    if data and data.QuestData and data.QuestData.Task then
        return true,next(data.QuestData.Task)
    end
    local gui=LP:FindFirstChild("PlayerGui")
    local main=gui and (gui:FindFirstChild("Main") or gui:FindFirstChild("Main (minimal)"))
    local q=main and main:FindFirstChild("Quest")
    if q and q.Visible then return true,nil end
    return false,nil
end
local function cancelMove()
    if STATE.Tween then pcall(function() STATE.Tween:Cancel() end) end
    STATE.Tween=nil
    STATE.TweenGoal=nil
    STATE.TweenAt=nil
end
local function moveTo(cf)
    if typeof(cf)~="CFrame" then return false end
    local _,_,root,isAlive=alive()
    if not isAlive then return false end
    local dist=(root.Position-cf.Position).Magnitude
    if dist<7 then cancelMove();return true end
    if Config.SmartPortal and dist>1050 and os.clock()-(STATE.LastPortal or 0)>14 then
        local bestPos,improvement=nil,900
        for _,p in ipairs(PORTALS[STATE.World] or {}) do
            local gain=dist-(cf.Position-p).Magnitude
            -- Use a portal only for a meaningful improvement and avoid
            -- repeatedly requesting entrances while already near one.
            if gain>improvement and (root.Position-p).Magnitude>100 then
                bestPos,improvement=p,gain
            end
        end
        if bestPos then
            STATE.LastPortal=os.clock()
            local ok=remote("requestEntrance",bestPos)
            if ok then cancelMove();return true end
        end
    end
    -- When farm ticks faster than TweenService, reuse an active tween briefly.
    -- Moving targets are resampled after 0.32 s, static targets after 0.7 s.
    local old=STATE.TweenGoal
    if STATE.Tween and old and (old.Position-cf.Position).Magnitude<9
        and os.clock()-(STATE.TweenAt or 0)<0.65 then
        return true
    end
    if STATE.Tween and os.clock()-(STATE.TweenAt or 0)<0.30 and old then
        return true
    end
    cancelMove()
    local speed=math.clamp(tonumber(Config.TweenSpeed) or 180,20,450)
    local secs=math.clamp(dist/speed,.09,100)
    local ok,tw=pcall(function()
        return Tween:Create(root,TweenInfo.new(secs,Enum.EasingStyle.Linear),{CFrame=cf})
    end)
    if not ok or not tw then return false end
    STATE.Tween,STATE.TweenGoal,STATE.TweenAt=tw,cf,os.clock()
    tw:Play()
    return true
end
local function distanceTo(cf)
    local _,_,root=alive()
    return root and (root.Position-cf.Position).Magnitude or math.huge
end
local function equipByType()
    local char=LP.Character; local bag=LP:FindFirstChild("Backpack")
    if not (char and bag) then return nil end
    local selected=Config.Weapon
    for _,container in ipairs({char,bag}) do
        for _,tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") and (tool.ToolTip==selected or tool.Name==selected or (selected=="Blox Fruit" and tool.ToolTip=="Blox Fruit")) then
                if tool.Parent~=char then
                    local hum=char:FindFirstChildOfClass("Humanoid")
                    if hum then pcall(function() hum:EquipTool(tool) end) end
                end
                return tool
            end
        end
    end
    if selected=="Any" then
        local tool=char:FindFirstChildOfClass("Tool") or bag:FindFirstChildOfClass("Tool")
        if tool and tool.Parent~=char then
            local hum=char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:EquipTool(tool) end) end
        end
        return tool
    end
    return nil
end
local function punch()
    local tool
    if Config.AutoEquip then tool=equipByType()
    else local char=LP.Character; tool=char and char:FindFirstChildOfClass("Tool") end
    if tool then pcall(function() tool:Activate() end) end
    safe("click",function()
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(0,0),WS.CurrentCamera.CFrame)
        VirtualUser:Button1Up(Vector2.new(0,0),WS.CurrentCamera.CFrame)
    end)
end
local nextAttack=0;local nextSkills=0
local function useSkills()
    if not (Config.AutoSkill or (Config.AutoSea and Config.AutoSeaSkill)) or os.clock()<nextSkills then return end
    if Config.FarmMode=="Mastery" and not STATE.MasterySkillReady then return end
    nextSkills=os.clock()+Config.AutoSkillDelay
    local keys={"Z","X","C","V","F"}
    local vim
    pcall(function() vim=game:GetService("VirtualInputManager") end)
    if not vim then return end
    for _,key in ipairs(keys) do
        if Config["Skill"..key] then
            pcall(function()
                vim:SendKeyEvent(true,Enum.KeyCode[key],false,game)
                vim:SendKeyEvent(false,Enum.KeyCode[key],false,game)
            end)
            task.wait(0.07)
        end
    end
end
local function positionForMob(mob)
    local r=mob and mob:FindFirstChild("HumanoidRootPart")
    if not r then return nil end
    if Config.AutoDodgeSkill and os.clock()<(STATE.DodgeUntil or 0) then
        return r.CFrame*CFrame.new(0,180,0)
    end
    local d=Config.FarmDistance;local h=Config.FarmHeight
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
    if not mob or not mob.Parent then return end
    local h=mob:FindFirstChildOfClass("Humanoid")
    if not h or h.Health<=0 then return end
    local cf=positionForMob(mob)
    if cf then moveTo(cf) end
    if Config.Combat and os.clock()>nextAttack then
        nextAttack=os.clock()+math.max(.07,Config.AttackDelay)
        punch()
        useSkills()
    end
end
local function getTarget()
    if Config.FarmMode=="Level" then
        local info=questInfo()
        if info then
            local present,current=hasQuest()
            if Config.AutoQuest and not present then
                local pos=info.Pos
                if typeof(pos)=="Vector3" then pos=CFrame.new(pos) end
                if typeof(pos)=="CFrame" then
                    if distanceTo(pos)>12 then
                        moveTo(pos*CFrame.new(0,3,0))
                    elseif os.clock()-STATE.LastQuest>Config.QuestDelay then
                        STATE.LastQuest=os.clock()
                        remote("StartQuest",tostring(info.Name),info.Id)
                    end
                    return nil
                end
                -- If the quest giver location isn't loaded, farm the correct
                -- mob instead of deadlocking the whole loop.
                if os.clock()-(STATE.NoQuestPosWarn or 0)>45 then
                    STATE.NoQuestPosWarn=os.clock()
                    slog("Quest NPC coordinates unavailable; using mob route", "warn")
                end
            end
            local name=current or info.Mob
            local mob=enemySearch(name)
            if not mob then moveTo(spawnCFrame(name)); end
            return mob
        end
        return enemySearch(nil,true)
    elseif Config.FarmMode=="Nearest" then
        return enemySearch(nil,true)
    elseif Config.FarmMode=="Selected mob" then
        local mob=enemySearch(Config.Mob)
        if not mob then moveTo(spawnCFrame(Config.Mob)) end
        return mob
    elseif Config.FarmMode=="Boss" then
        return enemySearch(Config.Boss)
    elseif Config.FarmMode=="Material" then
        local names=materialMobs[Config.Material]
        if not names then return nil end
        local mob=enemySearch(names)
        if not mob then
            for _,name in ipairs(names) do local cf=spawnCFrame(name);if cf then moveTo(cf);break end end
        end
        return mob
    elseif Config.FarmMode=="Bones" then
        local names=materialMobs.Bones
        local mob=enemySearch(names)
        if not mob then moveTo(spawnCFrame("Reborn Skeleton")) end
        return mob
    elseif Config.FarmMode=="Mastery" then
        local mob=enemySearch(nil,true)
        if mob then
            local h=mob:FindFirstChildOfClass("Humanoid")
            STATE.MasterySkillReady = h and h.MaxHealth>0 and h.Health/h.MaxHealth*100<=Config.MasteryThreshold
        end
        return mob
    elseif Config.FarmMode=="All Boss" then
        local mob=enemySearch(nil,false)
        if mob and isBoss(mob.Name) then return mob end
        local folder=enemyFolder()
        if folder then
            for _,e in ipairs(folder:GetChildren()) do
                if isBoss(e.Name) then
                    local hum=e:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health>0 then return e end
                end
            end
        end
        return nil
    elseif Config.FarmMode=="Elite" then
        local e=enemySearch({"Diablo","Deandre","Urban"})
        if not e then remote("EliteHunter") end
        return e
    elseif Config.FarmMode=="Factory" then
        return enemySearch({"Core","Factory Core"})
    elseif Config.FarmMode=="Pirate Raid" then
        return enemySearch({"Pirate Millionaire","Pistol Billionaire","Pirate","Elite Pirate"})
    elseif Config.FarmMode=="Aura" then
        return enemySearch(nil,false)
    end
    return nil
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
                if lname:find("chest",1,true) or lname:find("berry",1,true) then
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
local function tryNearestChest()
    local part,dist=findWorldItem({"chest1","chest2","chest3"})
    if part then
        if dist>6 then moveTo(part.CFrame*CFrame.new(0,3,0)) end
        if dist<=10 and type(firetouchinterest)=="function" then
            local _,_,root=alive()
            if root then pcall(function() firetouchinterest(root,part,0);firetouchinterest(root,part,1) end) end
        end
    end
end
local function tryBerry()
    local part,dist=findWorldItem({"berry"})
    if part and dist>6 then moveTo(part.CFrame*CFrame.new(0,2,0)) end
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
local function getMobs() return refreshOptions(enemyFolder(),function(v) return v:FindFirstChild("Humanoid")~=nil end) end
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
        if m:FindFirstChildOfClass("Humanoid") and m:FindFirstChild("HumanoidRootPart") then
            table.insert(out,m)
        end
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
        while STATE.Alive do
            task.wait(delay)
            if not STATE.Alive then break end
            safe(name,fn)
        end
    end)
end
startLoop("Farm engine",.16,function()
    if not Config.FarmEnabled then return end
    if STATE.World==0 then return end
    local _,h,_,ok=alive();if not ok then return end
    if Config.LowHealth>0 and h.MaxHealth>0 and h.Health/h.MaxHealth*100<Config.LowHealth then
        cancelMove();return
    end
    attackHaki()
    local target=getTarget()
    if target then engage(target) end
end)
startLoop("Character support",1,function()
    if Config.AutoStats then throttle("stats",3,function() remote("AddPoint",Config.Stat,3) end) end
    if Config.AutoBuso or Config.AutoObservation or Config.AutoRaceV3 then attackHaki() end
    if Config.AutoClick and not Config.FarmEnabled then punch() end
end)
startLoop("Collectibles",1.3,function()
    -- Never steal movement from a running farm.
    if Config.FarmEnabled then return end
    if Config.AutoCollectFruit then collectFruit() end
    if Config.AutoStoreFruit then storeFruit() end
    if Config.AutoChest then tryNearestChest() end
    if Config.AutoBerry then tryBerry() end
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
    if Config.AutoFish then fishOnce() end
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
    if ok then
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
    local enabled=Config.Noclip and (Config.FarmEnabled or Config.AutoSea or Config.AutoChest or Config.AutoCollectFruit)
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
            if r and ((isBoss(enemy.Name) and Config.ESPBoss) or (not isBoss(enemy.Name) and Config.ESPEnemy)) then
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
    local fn=STATE.ControlBindings[key]
    if fn then for _,redraw in ipairs(fn) do redraw(value) end end
    if key=="FarmEnabled" and not value then cancelMove() end
    if (key=="GlassIntensity" or key=="HighContrast") and updateGlass then updateGlass() end
    if (key=="BackgroundBlur" or key=="BlurStrength") and updateBackdrop then updateBackdrop() end
    if key=="SoftGlow" and STATE.Glow then STATE.Glow.Visible=value end
    if key=="AutoFullBright" and STATE.Unified and STATE.Unified.ApplyFullBright then STATE.Unified.ApplyFullBright() end
    if key=="AutoFPS" and STATE.Unified and STATE.Unified.ApplyFPS then STATE.Unified.ApplyFPS() end
    save()
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
        animate(bScale,{Scale=1.012},.14)
    end)
    on(b,b.MouseLeave,function()
        animate(b,{BackgroundColor3=C.White,BackgroundTransparency=Config.HighContrast and .44 or .65},.13)
        animate(bScale,{Scale=1},.14)
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
local gui=mk("ScreenGui",{Name="andepzai_CrystalWhiteGlassV9",IgnoreGuiInset=true,ResetOnSpawn=false,
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
local tagline=txt(header,"C R Y S T A L   W H I T E   /   9 . 0",9,C.Muted,Enum.Font.GothamBold)
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
local sideFoot=txt(side,compact and "v9" or "V9.0  •  LIQUID",9,C.Quiet,Enum.Font.GothamMedium)
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
    local bar=mk("Frame",{BackgroundColor3=color,BorderSizePixel=0,
        Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(4,58)},card)
    round(bar,5)
    local heading=txt(card,tostring(title),12,C.Text,Enum.Font.GothamBold)
    heading.Position=UDim2.fromOffset(13,7);heading.Size=UDim2.new(1,-20,0,20)
    local desc=txt(card,tostring(body),10,C.Muted)
    desc.Position=UDim2.fromOffset(13,26);desc.Size=UDim2.new(1,-20,0,24)
    task.delay(4.1,function()
        if card.Parent then card:Destroy() end
        toastCount=math.max(0,toastCount-1)
    end)
end
local navButtons={}
local selectedPage
local function choosePage(id)
    selectedPage=id
    searchBox.Text=""
    for name,page in pairs(STATE.Pages) do page.Frame.Visible=(name==id) end
    for name,entry in pairs(navButtons) do
        local selected=name==id
        animate(entry.Back,{BackgroundColor3=C.White,
            BackgroundTransparency=selected and .40 or .87},.16)
        animate(entry.IconChip,{BackgroundTransparency=selected and .24 or .56},.16)
        entry.Label.TextColor3=selected and C.Text or C.Muted
        entry.Marker.Visible=selected
    end
    if STATE.Pages[id] then
        STATE.Pages[id].Frame.CanvasPosition=Vector2.zero
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
    local l=txt(nav,title,11,C.Muted,Enum.Font.GothamMedium)
    l.Position=UDim2.fromOffset(44,0);l.Size=UDim2.new(1,-46,1,0)
    l.Visible=not compact
    navButtons[id]={Back=nav,Label=l,Marker=marker,IconChip=iconChip}
    local navScale=mk("UIScale",{Scale=1},nav)
    on(nav,nav.MouseEnter,function()
        if selectedPage~=id then
            animate(nav,{BackgroundTransparency=.80},.12)
            animate(iconChip,{BackgroundTransparency=.44},.12)
        end
        animate(navScale,{Scale=1.01},.14)
    end)
    on(nav,nav.MouseLeave,function()
        if selectedPage~=id then
            animate(nav,{BackgroundTransparency=.87},.12)
            animate(iconChip,{BackgroundTransparency=.56},.12)
        end
        animate(navScale,{Scale=1},.14)
    end)
    on(nav,nav.MouseButton1Click,function() pulse(nav);choosePage(id) end)
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
    local page={Frame=frame,Sections={},Index=0,Title=title}
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
    local title=txt(card,name:upper(),11,C.Accent,Enum.Font.GothamBold)
    title.Size=UDim2.new(1,0,0,20);themed(title,"TextColor3")
    if description then
        local sub=txt(card,description,10,C.Quiet)
        sub.Size=UDim2.new(1,0,0,31)
    end
    local entry={Card=card,Elements={},Name=name}
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
            activeSlider={Update=update,Input=input,Finish=function()
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
    vectorIcon(current,"chevron",UDim2.new(1,-25,.5,-9),18)
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
                    popup.Visible=false
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
        popup.Size=UDim2.new(1,0,0,math.min(198,count*35+10))
        scroller.CanvasPosition=Vector2.zero
    end
    on(current,current.MouseButton1Click,function()
        if popup.Visible then popup.Visible=false;return end
        -- Only one dropdown open per section to reduce overlapping controls.
        for _,item in ipairs(s.Elements) do
            if item~=popup and item.Name=="Choices" then item.Visible=false end
        end
        build();popup.Visible=true
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
    round(field,14);stroke(field,C.Text,.77,1)
    if compact then
        field.Size=UDim2.new(1,-22,0,31)
        field.Position=UDim2.new(0,11,1,-36)
    end
    on(field,field.FocusLost,function()
        Config[key]=field.Text;save()
    end)
    return field
end
local function action(s,name,fn,description)
    local row=control(s,name,compact and (description and 88 or 69) or (description and 58 or 45))
    tip(row,name,description,compact and 18 or 125)
    local b=button(row,"RUN",94,31,C.Glass,fn)
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
                    item.Visible=yes
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
end)
local setWindowVisible
local floating=button(gui,"",48,48,C.Row,function()
    local visible=not win.Visible
    setWindowVisible(visible)
end)
floating.AnchorPoint=Vector2.new(1,1);floating.Position=UDim2.new(1,-15,1,-15)
floating.TextSize=24;floating.Visible=Config.FloatingButton
vectorIcon(floating,"logo",UDim2.fromOffset(12,12),24)
round(floating,20);themed(stroke(floating,C.Accent,.1,1.5),"Color")
local floatScale=mk("UIScale",{Scale=1},floating)
local windowScale=mk("UIScale",{Scale=1},win)
setWindowVisible=function(visible)
    STATE.WindowVisible=visible
    if visible then
        win.Visible=true;shadow.Visible=true;glow.Visible=Config.SoftGlow
        if not Config.ReducedMotion then
            windowScale.Scale=.955
            animate(windowScale,{Scale=1},.28)
        else windowScale.Scale=1 end
    else
        win.Visible=false;shadow.Visible=false;glow.Visible=false
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
    cancelMove();clearESP();save()
    if STATE.RestoreNoclip then STATE.RestoreNoclip() end
    if STATE.RestoreLighting then pcall(STATE.RestoreLighting) end
    if STATE.Unified and STATE.Unified.ApplyFPS then Config.AutoFPS=false;pcall(STATE.Unified.ApplyFPS) end
    if backdropBlur and backdropBlur.Parent then backdropBlur:Destroy() end
    for _,connection in ipairs(STATE.Connections) do pcall(function() connection:Disconnect() end) end
    if gui and gui.Parent then gui:Destroy() end
    if env.__ANDEPZAI_V8==STATE then env.__ANDEPZAI_V8=nil end
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
local dashboard=addPage("home","⌂","Home","Crystal White Liquid Glass  /  andepzai 9.0")
local hero=section(dashboard,"ANDEPZAI · CONTROL CENTER","One standalone hub · 3 reference feature sets")
info(hero,"Dark clear glass, white reflective edges and lightweight animations. Change transparency, accessibility and blur in Settings.")
local welcome=section(dashboard,"Quick access","Farm • Combat • Fruits • Server")
local sb=section(dashboard,"Live session","Information comes from the local game client")
local statPlayer=statBox(sb,"Player",LP.DisplayName)
local statLevel=statBox(sb,"Level",level())
local statSea=statBox(sb,"Sea",STATE.World)
local statBeli=statBox(sb,"Beli",value("Beli"))
local statFrag=statBox(sb,"Fragments",value("Fragments"))
local statFarm=statBox(sb,"Farm status","Stopped")
info(welcome,"All controls live in this hub. Level route data can fall back to the supplied reference; advanced progression still needs in-game testing.")
toggle(welcome,"Fast attack / tool activation","Combat","Uses selected weapon and attack interval")
toggle(welcome,"Collect nearby fruits","AutoCollectFruit","Move to dropped fruits on the map")
toggle(welcome,"Auto Haki","AutoHaki")
action(welcome,"Server hop",hopServer,"Find a public server with fewer players")
action(welcome,"Activate level farming",function()
    setFlag("FarmMode","Level");setFlag("FarmEnabled",true)
    notice("Farm","Level farming enabled; check Farm tab for settings")
end)
action(welcome,"Stop all movement",function()
    for _,key in ipairs({"FarmEnabled","AutoSea","AutoChest","AutoCollectFruit","AutoAdvanceRaid",
        "AutoTyrant","AutoKatakuri","AutoBones","AutoRaidCombat","AutoFactory","AutoPirateRaid","AutoSoulReaper","AutoDarkbeard","AutoRipIndra","AutoDoughKing","AutoEliteCombat","AutoEventCollect","AutoFollowPlayer"}) do setFlag(key,false) end
    cancelMove();notice("Safety","Movement jobs disabled")
end)
local liveInfo=section(dashboard,"Health & world")
local hp=statBox(liveInfo,"Health","--")
local curMob=statBox(liveInfo,"Nearby enemy","--")
local curQuest=statBox(liveInfo,"Level quest","--")
R.statLevel,R.statSea,R.statBeli,R.statFrag,R.statFarm=statLevel,statSea,statBeli,statFrag,statFarm
R.hp,R.curMob,R.curQuest=hp,curMob,curQuest

end

do
local farming=addPage("farm","⚡","Auto Farm","Quest logic / Combat / Mastery / Config")
local fMode=section(farming,"Farm control")
toggle(fMode,"Enable farm engine","FarmEnabled","Controls the main loop; other background movement pauses")
dropdown(fMode,"Farming strategy","FarmMode",{"Level","Nearest","Selected mob","Boss","Material","Bones","Mastery","Aura"})
dropdown(fMode,"Weapon class","Weapon",{"Melee","Sword","Blox Fruit","Gun","Any"})
dropdown(fMode,"Target mob","Mob",getMobs,"Refresh the dropdown after mobs spawn")
action(fMode,"Refresh mobs",function() notice("Scanner","Rescanned visible enemies") end)
toggle(fMode,"Take level quest","AutoQuest","Prioritize GuideModule, with reference route fallback")
toggle(fMode,"Use level reference first","PreferRouteData","Offline quest ranges from reference; turn off if game updates changed missions")
toggle(fMode,"Attack mobs","Combat")
toggle(fMode,"Auto equip weapon","AutoEquip")
toggle(fMode,"Auto haki","AutoHaki")
local fPosition=section(farming,"Position & movement")
dropdown(fPosition,"Farm position","FarmStyle",{"Above","Behind","Below","Orbit"})
slider(fPosition,"Target distance","FarmDistance",5,70,1)
slider(fPosition,"Target height","FarmHeight",0,80,1)
slider(fPosition,"Tween speed","TweenSpeed",40,450,5)
toggle(fPosition,"Smart portal shortcuts","SmartPortal","Uses known Sea 1/2 entrances only if destination is substantially closer")
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
toggle(fActions,"Collect berries (while not farming)","AutoBerry")
toggle(fActions,"Auto click (when farm off)","AutoClick")
toggle(fActions,"Noclip while moving","Noclip")
action(fActions,"Cancel current tween",function() cancelMove();notice("Movement","Tween cancelled") end)

end

do
local bossPage=addPage("boss","✦","Boss Hunter","Boss list and target-specific combat")
local bSelect=section(bossPage,"Boss target")
dropdown(bSelect,"Choose boss","Boss",function() return bossDB[STATE.World] or bossDB[3] end)
action(bSelect,"Start selected boss",function()
    setFlag("FarmMode","Boss");setFlag("FarmEnabled",true)
    notice("Boss","Target: "..Config.Boss)
end)
action(bSelect,"Stop boss farming",function()
    if Config.FarmMode=="Boss" then setFlag("FarmEnabled",false) end
end)
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
action(mSelect,"Start material farm",function()
    setFlag("FarmMode","Material");setFlag("FarmEnabled",true)
    notice("Materials","Farming "..Config.Material)
end)
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
info(seaStatus,"Special event completion, ship steering and Leviathan mechanics are not implemented by generic mob combat. These actions are deliberately not presented as working toggles.")

end

do
local fishing=addPage("fishing","◉","Fishing","Fishing rod support")
local fish=section(fishing,"Rod controls")
toggle(fish,"Auto cast fishing rod","AutoFish","Requires a fishing tool already obtained in the game")
action(fish,"Cast once",fishOnce)
local rodState=statBox(fish,"Detected rod","--")
R.rodState=rodState
info(fish,"Casting is functional when the tool's Activate method is accepted. Reel/catching minigame automation is version-dependent and is not included in this release.")

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
action(farming,"Farm all spawned bosses",function() setFlag("FarmMode","All Boss");setFlag("FarmEnabled",true) end)
action(farming,"Farm Elite Hunter",function() setFlag("FarmMode","Elite");setFlag("FarmEnabled",true) end)
action(farming,"Farm Factory Core",function() setFlag("FarmMode","Factory");setFlag("FarmEnabled",true) end)
action(farming,"Farm Pirate Raid",function() setFlag("FarmMode","Pirate Raid");setFlag("FarmEnabled",true) end)
local farmEvents=section(unify,"World event targets")
toggle(farmEvents,"Auto Factory Core when spawned","AutoFactory")
toggle(farmEvents,"Auto Pirate Raid targets","AutoPirateRaid")
toggle(farmEvents,"Auto Elite fighters","AutoEliteCombat")
action(farmEvents,"Start all boss farm",function() setFlag("FarmMode","All Boss");setFlag("FarmEnabled",true) end)
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
info(boatSection,"Zone coordinates come from bnn.lua. Boat purchase uses BuyBoat; automatic steering is not included.")
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
    sideFoot.Text=compact and "v9" or "V9.0  •  LIQUID"
    statusCapsule.Visible=not compact
    tagline.Text=compact and "W H I T E  /  9 . 0" or "C R Y S T A L   W H I T E   /   9 . 0"
    tagline.Size=UDim2.fromOffset(compact and math.max(70,W-155) or 245,13)
    brand.Size=UDim2.fromOffset(compact and math.max(86,W-155) or 190,29)
    for _,entry in pairs(navButtons) do
        entry.Label.Visible=not compact
    end
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
choosePage("home")
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
STATE.UIVersion="Crystal White Liquid Glass 9.0 Rounded"
STATE.SetTheme=themeSelect
STATE.UnifiedFeatures=EX
STATE.SetGlassIntensity=function(percent)
    setFlag("GlassIntensity",math.clamp(tonumber(percent) or 76,15,100))
end
STATE.SetHighContrast=function(enabled) setFlag("HighContrast",not not enabled) end
STATE.SelectPage=choosePage
STATE.Stop=function()
    for _,key in ipairs({"FarmEnabled","AutoSea","AutoChest","AutoCollectFruit","AutoAdvanceRaid","AutoRaidCombat",
        "AutoFactory","AutoPirateRaid","AutoSoulReaper","AutoDarkbeard","AutoRipIndra","AutoDoughKing","AutoEliteCombat",
        "AutoEventCollect","AutoFollowPlayer","AutoSafeItems","AutoChestHop","AutoSeaHop","AutoFruitHop"}) do
        setFlag(key,false)
    end
    cancelMove()
end
STATE.Save=save
STATE.ActivateFarm=function(mode)
    if mode then setFlag("FarmMode",mode) end
    setFlag("FarmEnabled",true)
end
notice("andepzai 9.0","Crystal white liquid glass ready / Sea "..STATE.World)
print("[andepzai] CRYSTAL WHITE 9.0 loaded | Sea="..STATE.World.." | local UI, no remote library")
return STATE
