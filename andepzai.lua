--[[
  andepzai / LIQUID GLASS 4.0
  An independent Blox Fruits Luau hub, inspired by the feature categories
  in three user-supplied scripts. No original script, UI library, or
  remote third-party Lua is loaded.
  Runtime: Blox Fruits client and executor-supported features where needed.
  Controls that depend on game internals may need updates after game patches.
]]
local env = (type(getgenv) == "function" and getgenv()) or _G
-- Re-execution cleans up both this release and the previous standalone hub.
for _,slot in ipairs({"__ANDEPZAI_V4","__ANDEPZAI_V3"}) do
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
local VirtualUser = game:GetService("VirtualUser")
local LP = Players.LocalPlayer
if not LP then warn("[andepzai] LocalPlayer not found"); return end
local STATE = { Alive=true, Connections={}, ESP={}, Jobs={}, UI={}, Start=os.clock(), Logs={}, Tween=nil,
    Pages={}, ThemeObjects={}, LastQuest=0, LastRemote={}, StatsClock=0, World=0 }
env.__ANDEPZAI_V4 = STATE
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
  AutoChest=false, AutoBerry=false, AutoRaid=false, AutoAdvanceRaid=false, Raid="Flame",
  AutoBuso=false, AutoObservation=false, AutoRaceV3=false, AutoRejoin=false, AntiAFK=true,
  ESPPlayer=false, ESPEnemy=false, ESPBoss=false, ESPFruit=false, ESPChest=false, ESPIsland=false,
  AutoFish=false, AutoSea=false, AutoSkillSea=false, AutoSeaBoat=false,
  AutoElite=false, AutoBones=false, AutoTyrant=false, AutoKatakuri=false,
  AutoPray=false, AutoBuyChip=false, AutoRedeem=false,
  AutoBuyFruit=false, BuyFruit="Rocket", AutoStoreOnlyValuable=false,
  AutoClick=false, AntiStun=false, BoostFPS=false, Team="Pirates",
  NameTag=true, ToggleKey="RightControl", Accent="Nebula", FloatingButton=true,
  GlassIntensity=72, ReducedMotion=false, HighContrast=false, SoftGlow=true,
  SelectedNPC="", SelectedIsland="", SelectedFruit="", SelectedPlayer="", MinFruitPrice=1000000,
  BoatSpeed=1, ESPDistance=800, AutoSkillDelay=1.8, ReduceEffects=false,
}
local Config = {}
for k,v in pairs(defaults) do Config[k]=v end
local FOLDER = "andepzai"
local FILE = FOLDER .. "/config_v3.json"
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
        if not api("isfile")(FILE) then return nil end
        return Http:JSONDecode(api("readfile")(FILE))
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
local function questInfo()
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
                                best={Mob=mob,Name=npc.InternalQuestName,Id=questIndex,Pos=npc.Position}
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
    if STATE.Tween then pcall(function() STATE.Tween:Cancel() end); STATE.Tween=nil end
end
local function moveTo(cf)
    if typeof(cf)~="CFrame" then return false end
    local _,_,root,ok=alive(); if not ok then return false end
    local dist=(root.Position-cf.Position).Magnitude
    if dist<7 then return true end
    cancelMove()
    local speed=math.clamp(tonumber(Config.TweenSpeed) or 180,20,450)
    local secs=math.clamp(dist/speed,0.09,100)
    local ok2,tw=pcall(function()
        return Tween:Create(root,TweenInfo.new(secs,Enum.EasingStyle.Linear),{CFrame=cf})
    end)
    if ok2 and tw then STATE.Tween=tw;tw:Play();return true end
    return false
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
    if not Config.AutoSkill or os.clock()<nextSkills then return end
    if Config.FarmMode=="Mastery" and not STATE.MasterySkillReady then return end
    nextSkills=os.clock()+Config.AutoSkillDelay
    local keys={Z="SkillZ",X="SkillX",C="SkillC",V="SkillV",F="SkillF"}
    local vim
    pcall(function() vim=game:GetService("VirtualInputManager") end)
    if not vim then return end
    for key,field in pairs(keys) do
        if Config[field] then
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
                if os.clock()-STATE.LastQuest>Config.QuestDelay then
                    STATE.LastQuest=os.clock()
                    local pos=info.Pos
                    if typeof(pos)=="Vector3" then pos=CFrame.new(pos) end
                    if typeof(pos)=="CFrame" then
                        if distanceTo(pos)>12 then moveTo(pos*CFrame.new(0,3,0))
                        else remote("StartQuest",tostring(info.Name),info.Id) end
                    end
                end
                return nil
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
    elseif Config.FarmMode=="Aura" then
        return enemySearch(nil,false)
    end
    return nil
end

--// FEATURE SERVICES ------------------------------------------------------
local function findWorldItem(words)
    local _,_,root=alive()
    if not root then return nil end
    local best,dist=nil,math.huge
    for _,node in ipairs(WS:GetDescendants()) do
        if node:IsA("BasePart") and node.Parent and not node:IsDescendantOf(LP.Character or WS.Terrain) then
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
        throttle("raid",15,function()
            local success=selectRaid()
            if success then raidSummon() end
        end)
    end
    if Config.AutoAdvanceRaid then raidIsland() end
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
local noclipConnection
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
    if Config.Noclip and (Config.FarmEnabled or Config.AutoSea or Config.AutoChest or Config.AutoCollectFruit) then
        local char=LP.Character
        if char then for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide=false end
        end end
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
    t.Name="Label";t.BackgroundTransparency=.2;t.BackgroundColor3=Color3.fromRGB(14,18,34)
    t.Size=UDim2.fromScale(1,1);t.Text=name;t.TextSize=11;t.Font=Enum.Font.GothamBold
    t.TextColor3=color;t.TextWrapped=true;t.Parent=b
    Instance.new("UICorner",t).CornerRadius=UDim.new(0,9)
    local st=Instance.new("UIStroke",t);st.Thickness=1;st.Color=color;st.Transparency=.35
    b.Parent=LP:WaitForChild("PlayerGui");STATE.ESP[part]=b
end
startLoop("ESP",2,function()
    if not (Config.ESPPlayer or Config.ESPEnemy or Config.ESPBoss or Config.ESPFruit or Config.ESPChest or Config.ESPIsland) then
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
        for _,node in ipairs(WS:GetDescendants()) do
            if node:IsA("BasePart") and node.Name:lower():match("^chest%d+") then
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
    for part,gui in pairs(STATE.ESP) do
        if not visible[part] or not part.Parent then gui:Destroy();STATE.ESP[part]=nil end
    end
end)

--// LIQUID GLASS DESIGN SYSTEM ------------------------------------------
local C={BG=Color3.fromRGB(8,13,29),Panel=Color3.fromRGB(25,35,59),
    Row=Color3.fromRGB(35,48,75),RowHover=Color3.fromRGB(52,70,105),
    Glass=Color3.fromRGB(53,66,93),Border=Color3.fromRGB(124,148,181),
    Text=Color3.fromRGB(247,249,255),Muted=Color3.fromRGB(177,196,221),
    Quiet=Color3.fromRGB(133,155,184),Green=Color3.fromRGB(105,245,183),
    Red=Color3.fromRGB(255,121,146),Orange=Color3.fromRGB(255,205,138),
    White=Color3.new(1,1,1),Accent=Color3.fromRGB(113,215,255),
    Purple=Color3.fromRGB(176,140,255)}
local themes={Nebula=Color3.fromRGB(113,215,255),Iris=Color3.fromRGB(187,148,255),
    Sakura=Color3.fromRGB(255,162,198),Mint=Color3.fromRGB(121,241,195),
    Solar=Color3.fromRGB(255,205,133),Opal=Color3.fromRGB(172,216,255),
    Lagoon=Color3.fromRGB(80,225,234)}
C.Accent=themes[Config.Accent] or themes.Nebula
local themeItems={}
local glassItems=setmetatable({}, {__mode="k"})
local spectrumItems={}
local updateGlass
STATE.ControlBindings={}
local function setFlag(key,value)
    Config[key]=value
    local fn=STATE.ControlBindings[key]
    if fn then for _,redraw in ipairs(fn) do redraw(value) end end
    if key=="FarmEnabled" and not value then cancelMove() end
    if (key=="GlassIntensity" or key=="HighContrast") and updateGlass then updateGlass() end
    if key=="SoftGlow" and STATE.Glow then STATE.Glow.Visible=value end
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
                ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),
                ColorSequenceKeypoint.new(.30,accent:Lerp(C.White,.52)),
                ColorSequenceKeypoint.new(.72,accent),
                ColorSequenceKeypoint.new(1,C.Purple:Lerp(accent,.44))})
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
-- Local-only optics: tint, refractive-looking edge, specular highlights.
-- Roblox GUI has no per-Frame iOS backdrop refraction, so this deliberately
-- approximates the material without blurring the whole 3D scene.
local function liquidSurface(obj,kind)
    local base={window=.13,sidebar=.26,search=.18,footer=.24,
        panel=.25,row=.18,button=.20,toast=.14,nav=.34,bubble=.17}
    local entry={Kind=kind,Base=base[kind] or .2}
    if kind~="row" and kind~="nav" then
        local g=mk("UIGradient",{Rotation=118,Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,Color3.fromRGB(102,129,173)),
            ColorSequenceKeypoint.new(.20,C.Row),
            ColorSequenceKeypoint.new(.64,C.Panel),
            ColorSequenceKeypoint.new(1,Color3.fromRGB(16,24,49))})},obj)
        entry.Fill=g
    elseif kind=="row" then
        entry.Fill=mk("UIGradient",{Rotation=15,Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,C.RowHover),
            ColorSequenceKeypoint.new(.46,C.Row),
            ColorSequenceKeypoint.new(1,C.Panel)})},obj)
    end
    local rim=mk("UIStroke",{Name="LiquidRim",Thickness=(kind=="panel" or kind=="sidebar") and 1.15 or 1,
        Transparency=kind=="row" and .91 or .55,Color=C.White,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border},obj)
    mk("UIGradient",{Rotation=112,Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,C.White),
        ColorSequenceKeypoint.new(.28,Color3.fromRGB(196,229,255)),
        ColorSequenceKeypoint.new(.56,C.Accent),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(65,85,128))}),
        Transparency=NumberSequence.new({
            NumberSequenceKeypoint.new(0,.08),
            NumberSequenceKeypoint.new(.25,.58),
            NumberSequenceKeypoint.new(.80,.84),
            NumberSequenceKeypoint.new(1,.30)})},rim)
    entry.Rim=rim
    glassItems[obj]=entry
    return entry
end
updateGlass=function()
    local opacity=math.clamp(tonumber(Config.GlassIntensity) or 72,15,100)
    for obj,entry in pairs(glassItems) do
        if obj and obj.Parent then
            obj.BackgroundTransparency=Config.HighContrast and .06
                or math.clamp(entry.Base+(opacity-72)*.004, .04, .69)
            entry.Rim.Transparency=Config.HighContrast and .25
                or (entry.Kind=="row" and .89 or .57)
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
    round(b,12);liquidSurface(b,"button")
    on(b,b.MouseEnter,function()
        animate(b,{BackgroundColor3=C.RowHover,BackgroundTransparency=.08},.16)
    end)
    on(b,b.MouseLeave,function()
        animate(b,{BackgroundColor3=fill or C.Row,BackgroundTransparency=Config.HighContrast and .06 or .20},.16)
    end)
    on(b,b.MouseButton1Click,function() pulse(b) end)
    on(b,b.InputBegan,function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            animate(b,{BackgroundTransparency=.04},.1)
        end
    end)
    if func then on(b,b.MouseButton1Click,func) end
    return b
end
local screen=WS.CurrentCamera and WS.CurrentCamera.ViewportSize or Vector2.new(900,600)
if screen.X<200 or screen.Y<200 then screen=Vector2.new(900,600) end
local compact=screen.X<690
local W=math.min(948,math.max(310,screen.X-16))
local H=math.min(625,math.max(320,screen.Y-26))
local navW=compact and 54 or 190
local parent
if type(gethui)=="function" then pcall(function() parent=gethui() end) end
if not parent then pcall(function() parent=game:GetService("CoreGui") end) end
if not parent then parent=LP:WaitForChild("PlayerGui",8) end
if not parent then warn("[andepzai] Cannot create UI");STATE.Alive=false;return end
local gui=mk("ScreenGui",{Name="andepzai_LiquidGlass",IgnoreGuiInset=true,ResetOnSpawn=false,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=12500},parent)
STATE.Gui=gui
local glow=mk("Frame",{Name="PrismaticAura",AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,5,.5,5),Size=UDim2.fromOffset(W+34,H+34),
    BackgroundColor3=C.Accent,BackgroundTransparency=.92,BorderSizePixel=0,
    Visible=Config.SoftGlow,Active=false},gui)
STATE.Glow=glow
round(glow,36)
mk("UIGradient",{Rotation=25,Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,C.Accent),
    ColorSequenceKeypoint.new(.58,C.Purple),
    ColorSequenceKeypoint.new(1,C.Accent)}),
    Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,.15),
        NumberSequenceKeypoint.new(.54,.82),
        NumberSequenceKeypoint.new(1,.28)})},glow)
local shadow=mk("Frame",{Name="Shadow",AnchorPoint=Vector2.new(.5,.5),
    Position=UDim2.new(.5,8,.5,10),Size=UDim2.fromOffset(W,H),
    BackgroundColor3=Color3.fromRGB(0,0,0),BackgroundTransparency=.53,BorderSizePixel=0},gui)
round(shadow,23)
local win=mk("Frame",{Name="Window",AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
    Size=UDim2.fromOffset(W,H),BackgroundColor3=C.BG,BackgroundTransparency=.1,BorderSizePixel=0,ClipsDescendants=true},gui)
round(win,24)
local winRim=themed(stroke(win,C.Accent,.35,1.6),"Color")
mk("UIGradient",{Rotation=122,Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,.04),NumberSequenceKeypoint.new(.25,.45),
    NumberSequenceKeypoint.new(.72,.79),NumberSequenceKeypoint.new(1,.12)})},winRim)
mk("UIGradient",{Rotation=115,Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(41,57,87)),
    ColorSequenceKeypoint.new(.31,Color3.fromRGB(19,30,53)),
    ColorSequenceKeypoint.new(.68,Color3.fromRGB(13,22,46)),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(31,25,58))
})},win)
local halo=mk("Frame",{Name="LiquidTint",BackgroundColor3=C.Purple,
    BackgroundTransparency=.92,Position=UDim2.new(1,-128,0,-150),
    Size=UDim2.fromOffset(350,350),BorderSizePixel=0,Active=false},win)
round(halo,170)
mk("UIGradient",{Rotation=125,Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,.18),NumberSequenceKeypoint.new(1,1)
})},halo)
local glassTop=mk("Frame",{Name="TopSpecular",BackgroundColor3=C.White,
    BackgroundTransparency=.78,Position=UDim2.fromOffset(25,2),
    Size=UDim2.new(1,-50,0,1),BorderSizePixel=0,Active=false},win)
mk("UIGradient",{Rotation=0,Transparency=NumberSequence.new({
    NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.17,.16),
    NumberSequenceKeypoint.new(.45,.62),NumberSequenceKeypoint.new(.84,.25),
    NumberSequenceKeypoint.new(1,1)})},glassTop)
local shine=mk("Frame",{Name="Spectrum",Size=UDim2.new(1,0,0,3),BorderSizePixel=0,
    BackgroundColor3=C.White},win)
local grad=mk("UIGradient",{Offset=Vector2.new(-.8,0),Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,C.Accent),ColorSequenceKeypoint.new(.5,C.Purple),
    ColorSequenceKeypoint.new(1,C.Accent)
})},shine)
table.insert(spectrumItems,grad)
local header=mk("Frame",{Name="Header",BackgroundTransparency=1,
    Position=UDim2.fromOffset(0,7),Size=UDim2.new(1,0,0,64)},win)
local logo=mk("Frame",{BackgroundColor3=C.Row,Size=UDim2.fromOffset(42,42),
    Position=UDim2.fromOffset(17,9),BorderSizePixel=0},header)
round(logo,15);liquidSurface(logo,"bubble")
local logoRim=themed(stroke(logo,C.Accent,.20,1.3),"Color")
local letter=txt(logo,"A",24,C.Accent,Enum.Font.GothamBlack)
letter.Size=UDim2.fromScale(1,1);letter.TextXAlignment=Enum.TextXAlignment.Center
letter.TextYAlignment=Enum.TextYAlignment.Center;themed(letter,"TextColor3")
local brand=txt(header,"andepzai",23,C.Text,Enum.Font.GothamBlack)
brand.Position=UDim2.fromOffset(67,7);brand.Size=UDim2.fromOffset(190,29)
local tagline=txt(header,"L I Q U I D   G L A S S   /   4 . 0",9,C.Muted,Enum.Font.GothamBold)
tagline.Position=UDim2.fromOffset(68,37);tagline.Size=UDim2.fromOffset(245,13)
local exitBtn=button(header,"×",28,29,Color3.fromRGB(72,37,63))
exitBtn.Position=UDim2.new(1,-44,0,15);exitBtn.TextSize=17
local miniBtn=button(header,"−",28,29,C.Row)
miniBtn.Position=UDim2.new(1,-80,0,15);miniBtn.TextSize=16
local statusCapsule=mk("Frame",{BackgroundColor3=C.Panel,BorderSizePixel=0,
    Position=UDim2.new(1,-188,0,13),Size=UDim2.fromOffset(96,32)},header)
round(statusCapsule,16);liquidSurface(statusCapsule,"bubble")
local statusLabel=txt(statusCapsule,"●  ACTIVE",10,C.Green,Enum.Font.GothamBold)
statusLabel.TextXAlignment=Enum.TextXAlignment.Center
statusLabel.Size=UDim2.fromScale(1,1)
statusCapsule.Visible=not compact
local searchBack=mk("Frame",{Name="Search",BackgroundColor3=C.Panel,
    Position=UDim2.fromOffset(navW+26,73),Size=UDim2.new(1,-navW-42,0,37),BorderSizePixel=0},win)
round(searchBack,14);liquidSurface(searchBack,"search")
local searchIcon=txt(searchBack,"⌕",20,C.Muted,Enum.Font.GothamBold)
searchIcon.Size=UDim2.fromOffset(28,37);searchIcon.Position=UDim2.fromOffset(12,0)
local searchBox=mk("TextBox",{Name="SearchField",BackgroundTransparency=1,
    Text="",PlaceholderText="Tìm tính năng... / Search settings",ClearTextOnFocus=false,
    PlaceholderColor3=C.Quiet,TextColor3=C.Text,Font=Enum.Font.Gotham,
    TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
    Position=UDim2.fromOffset(42,0),Size=UDim2.new(1,-57,1,0)},searchBack)
local side=mk("Frame",{BackgroundColor3=C.Panel,BackgroundTransparency=.18,
    Position=UDim2.fromOffset(12,74),Size=UDim2.new(0,navW,1,-132),BorderSizePixel=0},win)
round(side,17);liquidSurface(side,"sidebar")
if not compact then
    local sectionNav=txt(side,"WORKSPACE",9,C.Quiet,Enum.Font.GothamBold)
    sectionNav.Position=UDim2.fromOffset(14,9);sectionNav.Size=UDim2.fromOffset(125,22)
end
local navScroll=mk("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,
    Position=UDim2.fromOffset(4,compact and 8 or 34),
    Size=UDim2.new(1,-8,1,compact and -14 or -69),
    AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.fromOffset(0,0),
    ScrollBarThickness=0,ScrollingDirection=Enum.ScrollingDirection.Y},side)
mk("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},navScroll)
local sideFoot=txt(side,compact and "v3" or "V3.0  •  MADE FOR YOU",9,C.Quiet,Enum.Font.GothamMedium)
sideFoot.TextXAlignment=Enum.TextXAlignment.Center
sideFoot.Size=UDim2.new(1,-8,0,24);sideFoot.Position=UDim2.new(0,4,1,-28)
local work=mk("Frame",{BackgroundTransparency=1,
    Position=UDim2.fromOffset(navW+22,119),Size=UDim2.new(1,-navW-36,1,-178)},win)
local footer=mk("Frame",{BackgroundColor3=C.Panel,BackgroundTransparency=.19,
    Position=UDim2.new(0,13,1,-48),Size=UDim2.new(1,-26,0,34),BorderSizePixel=0},win)
round(footer,13);liquidSurface(footer,"footer")
local footText=txt(footer,"LIQUID GLASS  •  handcrafted Luau UI",10,C.Muted,Enum.Font.GothamMedium)
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
    round(card,15);liquidSurface(card,"toast");stroke(card,color,.43,1.1)
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
        animate(entry.Back,{BackgroundColor3=name==id and C.RowHover or C.Panel,
            BackgroundTransparency=name==id and .09 or (Config.HighContrast and .06 or .34)},.18)
        entry.Label.TextColor3=name==id and C.Text or C.Muted
        entry.Marker.Visible=(name==id)
    end
    if STATE.Pages[id] then
        STATE.Pages[id].Frame.CanvasPosition=Vector2.zero
    end
end
local function addPage(id,symbol,title,subtitle)
    local index=0;for _ in pairs(STATE.Pages) do index=index+1 end
    local nav=mk("TextButton",{Name="Nav_"..id,Text="",AutoButtonColor=false,
        BackgroundColor3=C.Panel,BackgroundTransparency=.2,
        Size=UDim2.new(1,0,0,34),LayoutOrder=index,BorderSizePixel=0},navScroll)
    round(nav,12);liquidSurface(nav,"nav")
    local marker=mk("Frame",{BackgroundColor3=C.Accent,BorderSizePixel=0,
        Size=UDim2.fromOffset(3,17),Position=UDim2.fromOffset(3,8),Visible=false},nav)
    round(marker,3);themed(marker,"BackgroundColor3")
    local sym=txt(nav,symbol,16,C.Accent,Enum.Font.GothamBold)
    sym.Position=UDim2.fromOffset(compact and 9 or 13,0);sym.Size=UDim2.fromOffset(21,34)
    sym.TextXAlignment=Enum.TextXAlignment.Center
    themed(sym,"TextColor3")
    local l=txt(nav,title,11,C.Muted,Enum.Font.GothamBold)
    l.Position=UDim2.fromOffset(39,0);l.Size=UDim2.new(1,-43,1,0)
    l.Visible=not compact
    navButtons[id]={Back=nav,Label=l,Marker=marker}
    on(nav,nav.MouseButton1Click,function() pulse(nav);choosePage(id) end)
    local frame=mk("ScrollingFrame",{Name="Page_"..id,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromScale(1,1),ScrollBarThickness=3,ScrollBarImageColor3=C.Border,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.fromOffset(0,0),
        ScrollingDirection=Enum.ScrollingDirection.Y,Visible=false},work)
    mk("UIListLayout",{Padding=UDim.new(0,11),SortOrder=Enum.SortOrder.LayoutOrder},frame)
    mk("UIPadding",{PaddingBottom=UDim.new(0,10),PaddingLeft=UDim.new(0,2),
        PaddingRight=UDim.new(0,8),PaddingTop=UDim.new(0,3)},frame)
    local top=mk("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,0,52),LayoutOrder=0},frame)
    local heading=txt(top,title,22,C.Text,Enum.Font.GothamBold)
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
    round(card,17);liquidSurface(card,"panel")
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
    local row=mk("Frame",{Name="Control",BackgroundColor3=C.Row,BackgroundTransparency=.18,
        BorderSizePixel=0,Size=UDim2.new(1,0,0,height or 47)},sectionObj.Card)
    round(row,11);liquidSurface(row,"row")
    row:SetAttribute("AZ_Label",name)
    table.insert(sectionObj.Elements,row)
    return row
end
local function tip(row,labelText,description,labelWidth)
    local label=txt(row,labelText,12,C.Text,Enum.Font.GothamMedium)
    label.Position=UDim2.fromOffset(11,description and 6 or 0)
    label.TextTruncate=Enum.TextTruncate.AtEnd
    label.Size=UDim2.new(1,-(labelWidth or 72),0,description and 23 or row.Size.Y.Offset)
    if description then
        local sub=txt(row,description,10,C.Quiet)
        sub.Position=UDim2.fromOffset(11,28)
        sub.Size=UDim2.new(1,-(labelWidth or 72),0,18)
    end
    return label
end
local function toggle(s,name,key,description)
    local row=control(s,name,compact and (description and 73 or 48) or (description and 58 or 45))
    tip(row,name,description,76)
    local track=mk("TextButton",{Text="",BackgroundColor3=C.Glass,
        BorderSizePixel=0,Size=UDim2.fromOffset(43,23),Position=UDim2.new(1,-54,.5,-11),
        AutoButtonColor=false},row)
    round(track,14)
    liquidSurface(track,"button")
    local dot=mk("Frame",{BackgroundColor3=C.White,Size=UDim2.fromOffset(17,17),
        Position=UDim2.fromOffset(3,3),BorderSizePixel=0},track)
    round(dot,9)
    local function redraw(v)
        animate(track,{BackgroundColor3=v and C.Accent or C.Glass,
            BackgroundTransparency=v and .08 or .34},.2)
        animate(dot,{Position=UDim2.fromOffset(v and 23 or 3,3),
            BackgroundColor3=v and C.BG or C.White},.2)
    end
    redraw(Config[key])
    STATE.ControlBindings[key]=STATE.ControlBindings[key] or {}
    table.insert(STATE.ControlBindings[key],redraw)
    -- Larger invisible touch target, while keeping a compact visible switch.
    local hit=mk("TextButton",{Name="SwitchTouchTarget",Text="",AutoButtonColor=false,
        BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.fromOffset(60,39),Position=UDim2.new(1,-63,.5,-19)},row)
    on(hit,hit.MouseButton1Click,function()
        setFlag(key,not Config[key]);pulse(track)
    end)
    return {Set=function(_,value) setFlag(key,value) end}
end
local function slider(s,name,key,lo,hi,step,description)
    local row=control(s,name,compact and (description and 94 or 72) or (description and 80 or 64))
    local label=tip(row,name,description,75)
    local val=txt(row,tostring(Config[key]),11,C.Accent,Enum.Font.GothamBold)
    val.Size=UDim2.fromOffset(51,22);val.Position=UDim2.new(1,-61,0,7)
    val.TextXAlignment=Enum.TextXAlignment.Right;themed(val,"TextColor3")
    local track=mk("Frame",{BackgroundColor3=C.Glass,BorderSizePixel=0,
        Position=UDim2.new(0,14,1,-18),Size=UDim2.new(1,-28,0,8)},row)
    round(track,5);liquidSurface(track,"button")
    local fill=mk("Frame",{BackgroundColor3=C.Accent,BorderSizePixel=0,
        Size=UDim2.fromScale(0,1)},track)
    round(fill,4);themed(fill,"BackgroundColor3")
    local ball=mk("Frame",{BackgroundColor3=C.White,Size=UDim2.fromOffset(13,13),
        AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),BorderSizePixel=0},track)
    round(ball,8)
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
    local moving=false
    local function update(x)
        local p=math.clamp((x-track.AbsolutePosition.X)/math.max(1,track.AbsoluteSize.X),0,1)
        set(lo+p*(hi-lo))
    end
    local sliderTouch=mk("TextButton",{Name="SliderTouchTarget",Text="",AutoButtonColor=false,
        BackgroundTransparency=1,BorderSizePixel=0,
        Position=UDim2.new(0,12,1,-29),Size=UDim2.new(1,-24,0,29)},row)
    on(sliderTouch,sliderTouch.InputBegan,function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            moving=true;update(input.Position.X)
        end
    end)
    on(UIS,UIS.InputChanged,function(input)
        if moving and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)
    on(UIS,UIS.InputEnded,function(input)
        if moving and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
            moving=false
            if key=="GlassIntensity" and updateGlass then updateGlass() end
            save()
        end
    end)
    return {Set=function(_,v) set(v);if key=="GlassIntensity" then updateGlass() end;save() end}
end
local function dropdown(s,name,key,list,description)
    local row=control(s,name,compact and (description and 92 or 78) or (description and 61 or 47))
    tip(row,name,description,compact and 22 or 168)
    local options=list
    local popup=mk("Frame",{Name="Choices",BackgroundColor3=C.Row,
        BorderSizePixel=0,Visible=false,ClipsDescendants=true,
        Size=UDim2.new(1,0,0,185)},s.Card)
    round(popup,12);liquidSurface(popup,"panel")
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
    local function sync()
        current.Text=tostring(Config[key]).."  ▾"
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
                choose=button(scroller,tostring(option),100,26,C.Row)
                choose.Size=UDim2.new(1,-3,0,28)
                cachedButtons[i]=choose
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
            choose.Text=tostring(option)
            choose.Visible=true
        end
        for i=count+1,#cachedButtons do
            cachedButtons[i].Visible=false
            currentOptions[i]=nil
        end
        popup.Size=UDim2.new(1,0,0,math.min(198,count*31+10))
        scroller.CanvasPosition=Vector2.zero
    end
    on(current,current.MouseButton1Click,function()
        if popup.Visible then popup.Visible=false;return end
        build();popup.Visible=true
        if updateGlass then updateGlass() end
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
    round(field,11);stroke(field,C.White,.79,1)
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
    local b=button(row,"RUN  ↗",91,29,C.Glass,fn)
    b.Position=compact and UDim2.new(1,-101,1,-35) or UDim2.new(1,-101,.5,-14)
    return b
end
local function info(s,body)
    local row=control(s,body,54)
    local lbl=txt(row,body,11,C.Muted)
    lbl.Position=UDim2.fromOffset(10,5);lbl.Size=UDim2.new(1,-20,1,-10)
    return lbl
end
local function statBox(s,name,init)
    local row=control(s,name,49)
    local left=txt(row,name,12,C.Muted,Enum.Font.GothamMedium)
    left.Position=UDim2.fromOffset(12,0);left.Size=UDim2.new(.59,0,1,0)
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
            entry.Back.BackgroundTransparency=id==firstHit and .09 or .34
        end
        STATE.Pages[firstHit].Frame.CanvasPosition=Vector2.zero
    end
end)
local setWindowVisible
local floating=button(gui,"A",44,44,C.Row,function()
    local visible=not win.Visible
    setWindowVisible(visible)
end)
floating.AnchorPoint=Vector2.new(1,1);floating.Position=UDim2.new(1,-15,1,-15)
floating.TextSize=24;floating.Visible=Config.FloatingButton
round(floating,18);themed(stroke(floating,C.Accent,.1,1.5),"Color")
local floatScale=mk("UIScale",{Scale=1},floating)
local windowScale=mk("UIScale",{Scale=1},win)
setWindowVisible=function(visible)
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
    for _,connection in ipairs(STATE.Connections) do pcall(function() connection:Disconnect() end) end
    if gui and gui.Parent then gui:Destroy() end
    if env.__ANDEPZAI_V4==STATE then env.__ANDEPZAI_V4=nil end
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
local dashboard=addPage("home","⌂","Overview","Liquid Glass command center  /  andepzai 4.0")
local hero=section(dashboard,"WELCOME TO ANDEPZAI","Prismatic interface, one independent engine, no external UI package")
info(hero,"Switch features with the left menu. The glass appearance is fully customizable under Settings; mobile controls are supported.")
local sb=section(dashboard,"Live session","Information comes from the local game client")
local statPlayer=statBox(sb,"Player",LP.DisplayName)
local statLevel=statBox(sb,"Level",level())
local statSea=statBox(sb,"Sea",STATE.World)
local statBeli=statBox(sb,"Beli",value("Beli"))
local statFrag=statBox(sb,"Fragments",value("Fragments"))
local statFarm=statBox(sb,"Farm status","Stopped")
local welcome=section(dashboard,"Quick start")
info(welcome,"Use the left navigation to open features. Every working control is wired to this standalone engine; no original hub is loaded.")
action(welcome,"Activate level farming",function()
    setFlag("FarmMode","Level");setFlag("FarmEnabled",true)
    notice("Farm","Level farming enabled; check Farm tab for settings")
end)
action(welcome,"Stop all movement",function()
    for _,key in ipairs({"FarmEnabled","AutoSea","AutoChest","AutoCollectFruit","AutoAdvanceRaid",
        "AutoTyrant","AutoKatakuri","AutoBones"}) do setFlag(key,false) end
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
toggle(fMode,"Take level quest","AutoQuest","Read GuideModule NPCList and choose the highest eligible quest")
toggle(fMode,"Attack mobs","Combat")
toggle(fMode,"Auto equip weapon","AutoEquip")
toggle(fMode,"Auto haki","AutoHaki")
local fPosition=section(farming,"Position & movement")
dropdown(fPosition,"Farm position","FarmStyle",{"Above","Behind","Below","Orbit"})
slider(fPosition,"Target distance","FarmDistance",5,70,1)
slider(fPosition,"Target height","FarmHeight",0,80,1)
slider(fPosition,"Tween speed","TweenSpeed",40,450,5)
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
toggle(raidMain,"Auto request raid chip","AutoBuyChip")
action(raidMain,"Travel to active raid island",function()
    notice("Raid",raidIsland() and "Moving to highest island" or "No raid location found")
end)
action(raidMain,"Check Raid NPC",function() doOnce("RaidsNpc","Check") end)
local raidHelp=section(raid,"Controls")
info(raidHelp,"For attacking raid mobs, turn on Farm > Nearest/Aura separately. Raid completion depends on quest, chip and client-side hit mechanics.")

end

do
local sea=addPage("sea","≋","Sea Events","Sea creatures, islands and naval encounters")
local seaAuto=section(sea,"Sea encounter")
toggle(seaAuto,"Auto attack found sea mobs","AutoSea","Targets sea beasts, sharks, piranhas and terror sharks when visible")
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
info(namedTravel,"Teleportation uses local tween movement and requires a client that permits CFrame modification.")

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
dropdown(prefs,"Accent theme","Accent",{"Nebula","Iris","Sakura","Mint","Solar","Opal","Lagoon"})
local swatchRow=control(prefs,"Color palette",65)
tip(swatchRow,"Palette swatches",nil,26)
for i,tname in ipairs({"Nebula","Iris","Sakura","Mint","Solar","Opal","Lagoon"}) do
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
slider(prefs,"Glass transparency","GlassIntensity",15,100,1,"15 = opaque / 100 = translucent")
toggle(prefs,"Prismatic glow","SoftGlow","Soft colored ambient glow around the window")
toggle(prefs,"High contrast","HighContrast","Make panels more opaque and borders easier to read")
toggle(prefs,"Reduce animations","ReducedMotion","Disable hover and glass motion for lower-end phones")
toggle(prefs,"Show floating launcher","FloatingButton")
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
    for _,key in ipairs({"FarmEnabled","AutoSea","AutoChest","AutoCollectFruit","AutoAdvanceRaid"}) do
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

updateGlass()
setWindowVisible(true)
-- Adaptive window geometry; avoids a fixed oversized hub after rotation.
local function resizeUI(size)
    if not size or size.X<180 or size.Y<180 then return end
    screen=size
    W=math.min(948,math.max(310,size.X-16))
    H=math.min(625,math.max(320,size.Y-26))
    compact=W<690
    navW=compact and 54 or 190
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
    sideFoot.Text=compact and "v4" or "V4.0  •  LIQUID GLASS"
    statusCapsule.Visible=not compact
    tagline.Text=compact and "L I Q U I D   /   4 . 0" or "L I Q U I D   G L A S S   /   4 . 0"
    tagline.Size=UDim2.fromOffset(compact and 170 or 245,13)
    brand.Size=UDim2.fromOffset(compact and 152 or 190,29)
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
STATE.UIVersion="Liquid Glass 4.0"
STATE.SetTheme=themeSelect
STATE.SetGlassIntensity=function(percent)
    setFlag("GlassIntensity",math.clamp(tonumber(percent) or 72,15,100))
end
STATE.SetHighContrast=function(enabled) setFlag("HighContrast",not not enabled) end
STATE.SelectPage=choosePage
STATE.Stop=function()
    for _,key in ipairs({"FarmEnabled","AutoSea","AutoChest","AutoCollectFruit","AutoAdvanceRaid"}) do
        setFlag(key,false)
    end
    cancelMove()
end
STATE.Save=save
STATE.ActivateFarm=function(mode)
    if mode then setFlag("FarmMode",mode) end
    setFlag("FarmEnabled",true)
end
notice("andepzai LIQUID GLASS","Handcrafted interface initialized / Sea "..STATE.World)
print("[andepzai] LIQUID GLASS 4.0 loaded | World="..STATE.World.." | External UI=none")
return STATE
