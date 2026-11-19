-- andepzai · AD41 Home + AD42 Liquid Glass
-- Complete one-file client: put this code in a LocalScript in StarterPlayerScripts.
-- The home page, level guide, notebook, navigation and launcher start together.
-- The optional ModuleScript interface is preserved for existing callers.
-- Notes and glass settings last for the current play session.
-- Sources: AD41 (dashboard, quest givers, landmarks, teachers, materials, 39 quests);
-- Vxeze (status groups, fruit directory, material filters, Tiki eye positions); Teddy (gear checks);
-- message-7 (race, local phase, place and session IDs). All source code below is local.

local Players = game:GetService("Players")
local Run = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Input = game:GetService("UserInputService")
local Tweens = game:GetService("TweenService")
local World = game:GetService("Workspace")

local seaForPlace = {
    [2753915549]=1, [85211729168715]=1, [4442272183]=2,
    [79091703265657]=2, [7449423635]=3, [100117331123089]=3,
}
local landmarks = {
    [1] = {
        {"Pirate Starter", 1047, 15, 1506},
        {"Marine Starter", -2728, 25, 2056},
        {"Middle Town", -688, 15, 1585},
        {"Jungle", -1614, 37, 146},
        {"Pirate Village", -1173, 45, 3837},
        {"Desert", 944, 21, 4373},
        {"Frozen Village", 1298, 87, -1344},
        {"Marine Fortress", -4810, 21, 4359},
        {"Colosseum", -1535, 7, -3014},
        {"Lower Skylands", -4814, 718, -2551},
        {"Skylands", -4652, 873, -1754},
        {"Upper Skylands", -7895, 5547, -380},
        {"Prison", 4870, 6, 736},
        {"Magma Village", -5290, 9, 8349},
        {"Underwater City", 61164, 5, 1820},
        {"Fountain City", 5757, 91, 4017},
        {"Jean-Luc Island", -2850, 7, 5355},
    },
    [2] = {
        {"The Cafe", -382, 73, 290},
        {"First Spot", -11, 29, 2771},
        {"Dark Arena", 3494, 13, -3259},
        {"Don Swan Mansion", -317, 331, 597},
        {"Don Swan Room", 2285, 15, 905},
        {"Green Zone", -2258, 73, -2696},
        {"Graveyard", -5552, 194, -776},
        {"Snow Mountain", 752, 408, -5277},
        {"Hot and Cold", -6008, 29, -5018},
        {"Cursed Ship", 919, 125, 32869},
        {"Ice Castle", 5505, 40, -6178},
        {"Forgotten Island", -3050, 240, -10178},
        {"Remote Island", 4816, 8, 2863},
    },
    [3] = {
        {"Mansion", -12471, 374, -7551},
        {"Port Town", -340, 21, 5524},
        {"Great Tree", 2205, 22, -6766},
        {"Castle On The Sea", -4980, 314, -3018},
        {"Hydra Island", 5294, 1005, 391},
        {"Floating Turtle", -12528, 332, -8658},
        {"Haunted Castle", -9517, 142, 5528},
        {"Ice Cream Land", -843, 66, -10944},
        {"Peanut Land", -2082, 38, -10190},
        {"Cake Land", -1897, 14, -11576},
        {"Candy Cane Land", -1094, 64, -14519},
        {"Chocolate Land", 219, 127, -12604},
        {"Tiki Outpost", -16224, 9, 439},
    },
}
local teachers = {
    {"Black Leg", "Dark Step Teacher", 1, -1147.284, 4.752, 3816.326},
    {"Electro", "Mad Scientist", 1, -4842.112, 717.67, -2623.149},
    {"Fishman Karate", "Water Kung-fu Teacher", 1, 61122.652, 18.497, 1568.351},
    {"Dragon Claw", "Sabi", 2, 699.029, 185.661, 654.895},
    {"Superhuman", "Martial Arts Master", 2, 1377.125, 246.542, -5189.951},
    {"Death Step", "Phoeyu, the Reformed", 2, 6356.472, 296.1, -6762.771},
    {"Sharkman Karate", "Sharkman Teacher", 2, -2599.622, 238.198, -10315.998},
    {"Electric Claw", "Previous Hero", 3, -10368.514, 331.788, -10134.12},
    {"Dragon Talon", "Uzoth", 3, -9515.372, 142.13, 5535.089},
    {"Godhuman", "Ancient Monk", 3, -12463.87, 374.91, -7523.77},
    {"Sanguine Art", "Shafi", 3, -16548.8, 12, 412.3},
}
local materialReferences = {
    {"Angel Wings", {[1]="Shanda, Royal Squad, Royal Soldier, Wysper, Thunder God"}},
    {"Leather + Scrap Metal", {[1]="Brute, Pirate", [2]="Marine Captain", [3]="Jungle Pirate"}},
    {"Magma Ore", {[1]="Military Soldier, Military Spy, Magma Admiral", [2]="Magma Ninja, Lava Pirate"}},
    {"Fish Tail", {[1]="Fishman Warrior, Fishman Commando, Fishman Lord", [3]="Fishman Raider, Fishman Captain"}},
    {"Ectoplasm", {[2]="Ship Deckhand, Ship Engineer, Ship Steward, Ship Officer"}},
    {"Mystic Droplet", {[2]="Water Fighter"}},
    {"Radioactive Material", {[2]="Factory Staff"}},
    {"Vampire Fang", {[2]="Vampire"}},
    {"Demonic Wisp", {[3]="Demonic Soul"}},
    {"Conjured Cocoa", {[3]="Chocolate Bar Battler, Cocoa Warrior"}},
    {"Dragon Scale", {[3]="Dragon Crew Archer, Dragon Crew Warrior"}},
    {"Gunpowder", {[3]="Pistol Billionaire"}},
    {"Mini Tusk", {[3]="Mythological Pirate"}},
    {"Nightmare Catcher", {[3]="Reborn Skeleton, Living Zombie"}},
}
local quests = {
    {1, "Escape from Alcatraz", "Prison", 1},
    {2, "Don Megalo", "Prison", 1},
    {3, "Lever Jailbreak", "Prison", 1},
    {4, "Rescue Hasan", "Desert", 1},
    {5, "Archaeologist's Tablet", "Desert", 1},
    {6, "Prickly Harvest", "Desert", 1},
    {7, "Legendary Creator Statues", "Colosseum", 1},
    {8, "Crowd Favorite", "Colosseum", 1},
    {9, "King's Apprentice", "Colosseum", 1},
    {10, "Breaking the Ice", "Frozen Village", 1},
    {11, "Snowman", "Frozen Village", 1},
    {12, "Frozen Defense", "Frozen Village", 1},
    {13, "The Thieving Monkey", "Jungle", 1},
    {14, "Zipline Repair", "Jungle", 1},
    {15, "Banana Tree", "Jungle", 1},
    {16, "Fountain Pipe Repair", "Fountain", 1},
    {17, "Fountain Wire Repair", "Fountain", 1},
    {18, "Sewer Gangs", "Fountain", 1},
    {19, "Evil Slimes", "Magma Village", 1},
    {20, "Magma Ore Extraction", "Magma Village", 1},
    {21, "One Last Eruption", "Magma Village", 1},
    {22, "Battle Plans", "Marine Fortress", 1},
    {23, "Fortress Flagpole", "Marine Fortress", 1},
    {24, "Fortress Under Fire", "Marine Fortress", 1},
    {25, "Early Access", "Middle Town", 1},
    {26, "Lookout", "Middle Town", 1},
    {27, "X Marks The Spot", "Middle Town", 1},
    {28, "Chef's Kiss", "Pirate Village", 1},
    {29, "Tavern Brawl", "Pirate Village", 1},
    {30, "Windmill Maintenance", "Pirate Village", 1},
    {31, "Electric Fighting Teacher", "Sky", 1},
    {32, "The Clown's Jewels", "Sky", 1},
    {33, "Unexpected Guest", "Upper Sky", 1},
    {34, "Echoes Through the Clouds", "Upper Sky", 1},
    {35, "Temple Intel", "Upper Sky", 1},
    {36, "The Tyrant Awakens", "Upper Sky", 1},
    {37, "Beyond the Bubble", "Underwater City", 1},
    {38, "Fishman Karate", "Underwater City", 1},
    {39, "Pearl of the Deep", "Underwater City", 1},
}

-- Numeric quest-giver positions and level ranges from AD41. Each row groups the
-- display targets served by the same quest giver in the same Sea.
local questGivers = {
    [1] = {
        {"BanditQuest1", {1059.37195, 15.4495068, 1550.4231}, {{1, 9, "Bandit"}}},
        {"JungleQuest", {-1598.08911, 35.5501175, 153.377838}, {{10, 14, "Monkey"}, {15, 29, "Gorilla"}}},
        {"BuggyQuest1", {-1141.07483, 4.10001802, 3831.5498}, {{30, 39, "Pirate"}, {40, 59, "Brute"}}},
        {"DesertQuest", {894.488647, 5.14000702, 4392.43359}, {{60, 74, "Desert Bandit"}, {75, 89, "Desert Officer"}}},
        {"SnowQuest", {1389.74451, 88.1519318, -1298.90796}, {{90, 99, "Snow Bandit"}, {100, 119, "Snowman"}}},
        {"MarineQuest2", {-5039.58643, 27.3500385, 4324.68018}, {{120, 149, "Chief Petty Officer"}}},
        {"SkyQuest", {-4839.53027, 716.368591, -2619.44165}, {{150, 174, "Sky Bandit"}, {175, 189, "Dark Master"}}},
        {"PrisonerQuest", {5308.93115, 1.65517521, 475.120514}, {{190, 209, "Prisoner"}, {210, 249, "Dangerous Prisoner"}}},
        {"ColosseumQuest", {-1580.04663, 6.35000277, -2986.47534}, {{250, 274, "Toga Warrior"}, {275, 299, "Gladiator"}}},
        {"MagmaQuest", {-5313.37012, 10.9500084, 8515.29395}, {{300, 324, "Military Soldier"}, {325, 374, "Military Spy"}}},
        {"FishmanQuest", {61122.65234375, 18.497442245483, 1569.39978}, {{375, 399, "Fishman Warrior"}, {400, 449, "Fishman Commando"}}},
        {"SkyExp1Quest", {-4721.88867, 843.874695, -1949.96643}, {{450, 474, "God's Guard"}, {475, 524, "Shanda"}}},
        {"SkyExp2Quest", {-7906.81592, 5634.6626, -1411.99194}, {{525, 549, "Royal Squad"}, {550, 624, "Royal Soldier"}}},
        {"FountainQuest", {5259.81982, 37.3500175, 4050.0293}, {{625, 649, "Galley Pirate"}, {650, 699, "Galley Captain"}}},
    },
    [2] = {
        {"Area1Quest", {-429.543518, 71.7699966, 1836.18188}, {{700, 724, "Raider"}, {725, 774, "Mercenary"}}},
        {"Area2Quest", {638.43811, 71.769989, 918.282898}, {{775, 799, "Swan Pirate"}, {800, 874, "Factory Staff"}}},
        {"MarineQuest3", {-2440.79639, 71.7140732, -3216.06812}, {{875, 899, "Marine Lieutenant"}, {900, 949, "Marine Captain"}}},
        {"ZombieQuest", {-5497.06152, 47.5923004, -795.237061}, {{950, 974, "Zombie"}, {975, 999, "Vampire"}}},
        {"SnowMountainQuest", {609.858826, 400.119904, -5372.25928}, {{1000, 1049, "Snow Trooper"}, {1050, 1099, "Winter Warrior"}}},
        {"IceSideQuest", {-6064.06885, 15.2422857, -4902.97852}, {{1100, 1124, "Lab Subordinate"}, {1125, 1174, "Horned Warrior"}}},
        {"FireSideQuest", {-5428.03174, 16.0622921, -5299.43457}, {{1175, 1199, "Magma Ninja"}, {1200, 1249, "Lava Pirate"}}},
        {"ShipQuest1", {1037.80127, 125.092171, 32911.6016}, {{1250, 1274, "Ship Deckhand"}, {1275, 1299, "Ship Engineer"}}},
        {"ShipQuest2", {968.80957, 125.092171, 33244.125}, {{1300, 1324, "Ship Steward"}, {1325, 1349, "Ship Officer"}}},
        {"FrostQuest", {5667.6582, 26.7997818, -6486.08984}, {{1350, 1374, "Arctic Warrior"}, {1375, 1424, "Snow Lurker"}}},
        {"ForgottenQuest", {-3054.44458, 235.544281, -10142.8193}, {{1425, 1449, "Sea Soldier"}, {1450, 1499, "Water Fighter"}}},
    },
    [3] = {
        {"PiratePortQuest", {-290.074677, 42.9034653, 5581.58984}, {{1500, 1524, "Pirate Millionaire"}, {1525, 1574, "Pistol Billionaire"}}},
        {"DragonCrewQuest", {6738.96142578125, 127.81645965576, -713.51147460938}, {{1575, 1599, "Dragon Crew Warrior"}, {1600, 1624, "Dragon Crew Archer"}}},
        {"VenomCrewQuest", {5213.8740234375, 1004.5042724609, 758.6944580078}, {{1625, 1649, "Hydra Enforcer"}, {1650, 1699, "Venomous Assailant"}}},
        {"MarineTreeIsland", {2180.54126, 27.8156815, -6741.5498}, {{1700, 1724, "Marine Commodore"}, {1725, 1774, "Marine Rear Admiral"}}},
        {"DeepForestIsland3", {-10581.6563, 330.872955, -8761.18652}, {{1775, 1799, "Fishman Raider"}, {1800, 1824, "Fishman Captain"}}},
        {"DeepForestIsland", {-13234.04, 331.488495, -7625.40137}, {{1825, 1849, "Forest Pirate"}, {1850, 1899, "Mythological Pirate"}}},
        {"DeepForestIsland2", {-12680.3818, 389.971039, -9902.01953}, {{1900, 1924, "Jungle Pirate"}, {1925, 1974, "Musketeer Pirate"}}},
        {"HauntedQuest1", {-9479.2168, 141.215088, 5566.09277}, {{1975, 1999, "Reborn Skeleton"}, {2000, 2024, "Living Zombie"}}},
        {"HauntedQuest2", {-9516.99316, 172.017181, 6078.46533}, {{2025, 2049, "Demonic Soul"}, {2050, 2074, "Posessed Mummy"}}},
        {"NutsIslandQuest", {-2104.3908691406, 38.104167938, -10194.21875}, {{2075, 2099, "Peanut Scout"}, {2100, 2124, "Peanut President"}}},
        {"IceCreamIslandQuest", {-820.64825439453, 65.819526672, -10965.7959}, {{2125, 2149, "Ice Cream Chef"}, {2150, 2199, "Ice Cream Commander"}}},
        {"CakeQuest1", {-2021.32007, 37.7982254, -12028.7295}, {{2200, 2224, "Cookie Crafter"}, {2225, 2249, "Cake Guard"}}},
        {"CakeQuest2", {-1927.91602, 37.7981339, -12842.5391}, {{2250, 2274, "Baking Staff"}, {2275, 2299, "Head Baker"}}},
        {"ChocQuest1", {233.2283630371, 29.876001358, -12201.2334}, {{2300, 2324, "Cocoa Warrior"}, {2325, 2349, "Chocolate Bar Battler"}}},
        {"ChocQuest2", {150.506637573, 30.693693161, -12774.50293}, {{2350, 2374, "Sweet Thief"}, {2375, 2399, "Candy Rebel"}}},
        {"CandyQuest1", {-1150.040039, 20.378935, -14446.33496}, {{2400, 2424, "Candy Pirate"}, {2425, 2449, "Snow Demon"}}},
        {"TikiQuest1", {-16547.748046875, 61.135334, -173.413605}, {{2450, 2474, "Isle Outlaw"}, {2475, 2524, "Island Boy"}}},
        {"TikiQuest2", {-16539.078125, 55.686329, 1051.573853}, {{2525, 2574, "Isle Champion"}}},
        {"TikiQuest3", {-16665.1914, 104.596405, 1579.69434}, {{2575, 2599, "Skull Slayer"}}},
        {"SubmergedQuest1", {10778.875, -2087.72437, 9265.18359}, {{2600, 2624, "Reef Bandit"}, {2625, 2649, "Coral Pirate"}}},
        {"SubmergedQuest2", {10880.6855, -2086.20044, 10032.624}, {{2650, 2674, "Sea Chanter"}, {2675, 2699, "Ocean Prophet"}}},
        {"SubmergedQuest3", {9640.08789, -1992.44507, 9613.65234}, {{2700, 2724, "High Disciple"}, {2725, 9999, "Grand Devotee"}}},
    },
}

-- Vxeze's FruitList identifiers repeat the entire name, including T-Rex.
local fruitNames={
    "Rocket","Spin","Blade","Spring","Bomb","Smoke","Spike","Flame","Ice","Sand","Dark",
    "Eagle","Diamond","Light","Rubber","Ghost","Magma","Quake","Buddha","Love","Creation",
    "Spider","Sound","Phoenix","Portal","Lightning","Pain","Blizzard","Gravity","Mammoth",
    "T-Rex","Dough","Shadow","Venom","Control","Gas","Spirit","Tiger","Yeti","Kitsune","Dragon",
}

local accent = {}
for plain, letters in pairs({
    a="àáảãạăằắẳẵặâầấẩẫậÀÁẢÃẠĂẰẮẲẴẶÂẦẤẨẪẬ",
    e="èéẻẽẹêềếểễệÈÉẺẼẸÊỀẾỂỄỆ", i="ìíỉĩịÌÍỈĨỊ", d="đĐ",
    o="òóỏõọôồốổỗộơờớởỡợÒÓỎÕỌÔỒỐỔỖỘƠỜỚỞỠỢ",
    u="ùúủũụưừứửữựÙÚỦŨỤƯỪỨỬỮỰ", y="ỳýỷỹỵỲÝỶỸỴ",
}) do
    for _, code in utf8.codes(letters) do accent[utf8.char(code)] = plain end
end
for code = 0x300, 0x36f do accent[utf8.char(code)] = "" end
local function fold(text)
    return (text:gsub("[\194-\244][\128-\191]*", accent):lower())
end

local kinds = {
    all="Tất cả", island="Đảo", teacher="Võ sư", material="Vật liệu", quest="Quest", fruit="Trái",
    giver="NPC nhiệm vụ",
}
local catalog, byId = {}, {}
local function addEntry(id, kind, name, seas, detail, position, index, aliases)
    local seaNames, keys = {}, {name, kinds[kind], detail, aliases or ""}
    for _, sea in ipairs(seas) do
        table.insert(seaNames, tostring(sea))
        table.insert(keys, "sea "..sea.." sea"..sea.." bien "..sea)
    end
    local entry = {id=id, kind=kind, name=name, seas=seas, detail=detail, index=index,
        position=position, meta=kinds[kind].."  ·  Sea "..table.concat(seaNames," / "),
        search=fold(table.concat(keys," "))}
    table.insert(catalog,entry)
    byId[id]=entry
    return entry
end
for sea, names in ipairs(landmarks) do
    for _, item in ipairs(names) do
        local pos = {item[2],item[3],item[4]}
        addEntry("island/"..sea.."/"..item[1], "island", item[1], {sea},
            string.format("Mốc AD41   X %.0f   Y %.0f   Z %.0f", pos[1],pos[2],pos[3]), pos)
    end
end
for _, npc in ipairs(teachers) do
    addEntry("teacher/"..npc[2], "teacher", npc[2], {npc[3]},
        "Tên võ trong danh mục AD41: "..npc[1], {npc[4],npc[5],npc[6]}, nil, "NPC thay day vo")
end
for _, material in ipairs(materialReferences) do
    local seas, lines = {}, {}
    for sea=1,3 do
        if material[2][sea] then
            table.insert(seas,sea)
            table.insert(lines,"Sea "..sea.." · "..material[2][sea])
        end
    end
    addEntry("material/"..material[1], "material", material[1], seas, table.concat(lines,"\n"),
        nil, nil, "nguyen lieu quai")
end
for _, quest in ipairs(quests) do
    addEntry("quest/"..quest[1],"quest",quest[2],{quest[4]},
        string.format("Nhiệm vụ %02d  ·  %s",quest[1],quest[3]),nil,quest[1],"nhiem vu bi mat dao")
end
for _,name in ipairs(fruitNames) do
    local code=name.."-"..name
    addEntry("fruit/"..name,"fruit",name,{1,2,3},"Mã trong danh mục Vxeze: "..code,
        nil,nil,"trai ac quy devil fruit")
end
local routesBySea={}
local function bandText(low,high)
    if high==9999 then return tostring(low).."+" end
    return tostring(low).."–"..tostring(high)
end
for sea,groups in ipairs(questGivers) do
    local routes={}
    routesBySea[sea]=routes
    for _,group in ipairs(groups) do
        local key,position,bands=group[1],group[2],group[3]
        local targets,lines={},{"Mã điểm nhận trong AD41 · "..key}
        for _,band in ipairs(bands) do
            table.insert(targets,band[3])
            table.insert(lines,"Cấp "..bandText(band[1],band[2]).." · "..band[3])
        end
        table.insert(lines,string.format("X %.0f   Y %.0f   Z %.0f",position[1],position[2],position[3]))
        local entry=addEntry("giver/"..key,"giver",table.concat(targets," / "),{sea},
            table.concat(lines,"\n"),position,nil,"npc nhan quest nhiem vu theo cap quest giver "..key)
        for _,band in ipairs(bands) do
            table.insert(routes,{low=band[1],high=band[2],mob=band[3],entry=entry})
        end
    end
end
local function matches(entry, words, kind, sea)
    if kind~="all" and entry.kind~=kind then return false end
    if sea~=0 then
        local included=false
        for _, s in ipairs(entry.seas) do if s==sea then included=true; break end end
        if not included then return false end
    end
    for _, word in ipairs(words) do
        if not entry.search:find(word,1,true) then return false end
    end
    return true
end

local unknown = "Chưa có dữ liệu"
local function child(root, name)
    return root and root:FindFirstChild(name)
end
local function readValue(parent, key)
    local obj=child(parent,key)
    local value
    if obj and obj:IsA("ValueBase") then value=obj.Value end
    if value==nil and parent and key:match("^[%w_]+$") then value=parent:GetAttribute(key) end
    if type(value)=="string" or type(value)=="number" or type(value)=="boolean" then return value end
    return nil
end
local function number(value)
    if type(value)~="number" and type(value)~="string" then return nil end
    local n=tonumber(value)
    if n and n==n and n>=0 and n<math.huge then return n end
end
local function amount(value)
    local n=number(value)
    if not n then return unknown end
    return (string.format("%.0f",n):reverse():gsub("(%d%d%d)","%1."):reverse():gsub("^%.",""))
end
local function currentRoute(player)
    local sea=seaForPlace[game.PlaceId]
    local level=number(readValue(child(player,"Data"),"Level"))
    if not sea then return nil,"Chưa xác định được Sea" end
    if not level then return nil,"Đang chờ cấp nhân vật" end
    if sea==1 and level<10 then
        local team=player.Team
        if not team then return nil,"Chọn phe để xem nhiệm vụ đầu" end
        if team.Name=="Marines" then
            return nil,"Nhận nhiệm vụ đầu tại Đảo Hải quân",byId["island/1/Marine Starter"]
        end
    end
    for _,route in ipairs(routesBySea[sea]) do
        if level>=route.low and level<=route.high then
            return route,"Sea "..sea.." · cấp "..bandText(route.low,route.high)
        end
    end
    return nil,"AD41 chưa có tuyến cho cấp "..amount(level).." ở Sea "..sea
end
local function clockText(hours)
    local minutes=math.floor((hours%24)*60+0.00001)%1440
    return string.format("%02d:%02d",math.floor(minutes/60),minutes%60)
end
local function phaseText(phase,hours)
    local n=number(phase)
    if not n then return unknown end
    if n==5 and (hours>=12 or hours<5) then return "5 · trăng tròn theo nguồn" end
    if n==4 then return "4 · nguồn báo đêm kế" end
    return "Pha "..tostring(n)
end
local function presence(parent,name)
    if not parent then return "Khu vực chưa tải" end
    return child(parent,name) and "Đang thấy" or "Chưa thấy trên máy"
end
local function eyeStatus(map)
    local model=child(child(map,"TikiOutpost"),"IslandModel")
    local e=child(child(model,"IslandChunks"),"E")
    local loaded,lit=0,0
    for i=1,4 do
        local parent=model
        if i>2 then parent=e end
        local eye=child(parent,"Eye"..i)
        if eye and eye:IsA("BasePart") then
            loaded=loaded+1
            if eye.Transparency==0 then lit=lit+1 end
        end
    end
    if loaded==0 then return "Mắt chưa tải" end
    return lit.." sáng · đã tải "..loaded.."/4"
end
local function carried(player,data,name)
    local equipped=child(player.Character,name)
    local packed=child(player:FindFirstChildOfClass("Backpack"),name)
    for i=1,2 do
        local item=equipped
        if i==2 then item=packed end
        if item and (item:IsA("Tool") or item:IsA("Accessory")) then
            return item, i==1 and "Đang trang bị" or "Trong túi"
        end
    end
    local record=child(child(data,"Inventory"),name)
    if record then
        local count=number(readValue(record,"Count"))
        if record:IsA("IntValue") or record:IsA("NumberValue") then count=number(record.Value) end
        if count then
            if count>0 then return record,"Trong danh sách · "..amount(count) end
            return nil,"Danh sách ghi 0"
        end
        if record:IsA("BoolValue") then
            if record.Value then return record,"Có trong danh sách" end
            return nil,"Chưa được ghi nhận"
        end
        if record:IsA("Folder") or record:IsA("Tool") then return record,"Có trong danh sách" end
    end
    return nil,"Chưa thấy trên máy"
end
local function swordStatus(player,data,name)
    local item,location=carried(player,data,name)
    if not item then return location end
    local mastery=number(readValue(item,"Level")) or number(readValue(item,"Mastery"))
    if not mastery then return location.." · chưa rõ mastery" end
    if mastery>=350 then return "Đạt mốc · "..amount(mastery).."/350" end
    return amount(mastery).."/350 mastery"
end
local function targetDistance(player,sea,target)
    if not target or not target.position then return "Chạm để chọn đảo hoặc võ sư" end
    if not sea then return "Mốc thuộc Sea "..target.seas[1] end
    if target.seas[1]~=sea then return "Khác Sea · mốc ở Sea "..target.seas[1] end
    local char=player.Character
    local root=child(char,"HumanoidRootPart") or child(char,"UpperTorso") or child(char,"Torso")
    if not root or not root:IsA("BasePart") then return "Đang chờ nhân vật" end
    local p,at=target.position,root.Position
    local dx,dz=p[1]-at.X,p[3]-at.Z
    return string.format("%.0f stud ngang · chênh cao %+.0f", math.sqrt(dx*dx+dz*dz),p[2]-at.Y)
end

local function statusSnapshot(player,target)
    local sea=seaForPlace[game.PlaceId]
    local data=child(player,"Data")
    local stats=child(data,"Stats")
    local race=readValue(data,"Race")
    local energy=number(readValue(player.Character,"RaceEnergy"))
    local transformed=readValue(player.Character,"RaceTransformed")
    local map=child(World,"Map")
    local locations=child(child(World,"_WorldOrigin"),"Locations")
    local values={
        player=player.DisplayName, sea=sea and ("Sea "..sea) or "Ngoài danh mục",
        level=amount(readValue(data,"Level")), beli=amount(readValue(data,"Beli")),
        fragments=amount(readValue(data,"Fragments")),
        honour=amount(readValue(child(player,"leaderstats"),"Bounty/Honor")),
        race=race and tostring(race) or unknown,
        energy=energy and (string.format("%.2f",energy)..(energy>=1 and " · đủ mốc" or "")) or unknown,
        form=type(transformed)=="boolean" and (transformed and "Đang biến hình" or "Chưa biến hình") or unknown,
        place=string.format("%.0f",game.PlaceId), clock=clockText(Lighting.ClockTime),
        moon=phaseText(Lighting:GetAttribute("MoonPhase"),Lighting.ClockTime),
        mirage=presence(map,"MysticIsland"), kitsune=presence(map,"KitsuneShrine"),
        ancient=presence(locations,"PrehistoricIsland"), frozen=presence(locations,"FrozenDimension"),
        eyes=eyeStatus(map), pinTitle=target and target.name or "Ghim một mốc",
        distance=targetDistance(player,sea,target),
    }
    for _,key in ipairs({"Melee","Defense","Sword","Gun","Demon Fruit"}) do
        values[key]=amount(readValue(child(stats,key),"Level"))
    end
    return values
end
local function gearSnapshot(player)
    local data=child(player,"Data")
    local _,mirror=carried(player,data,"Mirror Fractal")
    local _,helm=carried(player,data,"Valkyrie Helm")
    return {tushita=swordStatus(player,data,"Tushita"),yama=swordStatus(player,data,"Yama"),
        mirror=mirror,helm=helm}
end
local function fruitLocation(player,entry)
    if not entry or entry.kind~="fruit" then return "Chọn một trái trong Tra cứu" end
    local code=entry.name.."-"..entry.name
    local data=child(player,"Data")
    local known
    for _,key in ipairs({entry.name.." Fruit",code}) do
        local item,where=carried(player,data,key)
        if item then return where end
        if where=="Danh sách ghi 0" or where=="Chưa được ghi nhận" then known=where end
    end
    return known or "Chưa thấy trên máy"
end

local API={}
local owner="andepzai.glass.42"
local colors={
    white=Color3.fromRGB(255,255,255), pearl=Color3.fromRGB(222,237,245),
    ice=Color3.fromRGB(239,247,250), edge=Color3.fromRGB(161,185,197),
    ink=Color3.fromRGB(30,43,51), soft=Color3.fromRGB(65,83,94),
    crystal=Color3.fromRGB(45,48,54), teal=Color3.fromRGB(34,103,105),
    tint=Color3.fromRGB(201,226,231),
}
local font=Enum.Font.Gotham
local bold=Enum.Font.GothamBold
local medium=Enum.Font.GothamMedium
local tabs={
    {"home","Trang chủ","Chủ"},{"status","Trạng thái","Chỉ số"},
    {"catalog","Tra cứu"},{"progress","Tiến độ"},{"settings","Cài đặt"},
}
local pageSize=9
local listOrder=setmetatable({}, {__mode="k"})
local function make(class, parent, props)
    local obj=Instance.new(class)
    if parent and listOrder[parent] and obj:IsA("GuiObject") then
        listOrder[parent]=listOrder[parent]+1
        obj.LayoutOrder=listOrder[parent]
    end
    for key,v in pairs(props or {}) do obj[key]=v end
    obj.Parent=parent
    return obj
end
local function blank(parent,name)
    return make("Frame",parent,{Name=name,BackgroundTransparency=1,BorderSizePixel=0})
end
local function radius(obj,px)
    return make("UICorner",obj,{CornerRadius=UDim.new(0,px)})
end
local function outline(obj,color,alpha)
    return make("UIStroke",obj,{ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Thickness=1,
        Color=color,Transparency=alpha})
end
local function label(parent,value,size,face,ink)
    return make("TextLabel",parent,{Text=value,BackgroundTransparency=1,BorderSizePixel=0,
        TextColor3=ink or colors.ink,TextSize=size,Font=face or font,Active=false,
        TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center,
        TextWrapped=true})
end
local function button(parent,name,text)
    return make("TextButton",parent,{Name=name,Text=text,AutoButtonColor=false,Active=true,
        Selectable=true,BorderSizePixel=0,TextColor3=colors.ink,Font=medium,TextSize=14,
        BackgroundTransparency=1})
end
local function vertical(obj,space,pad)
    listOrder[obj]=0
    make("UIListLayout",obj,{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,space)})
    if pad and pad>0 then
        make("UIPadding",obj,{PaddingTop=UDim.new(0,pad),PaddingBottom=UDim.new(0,pad),
            PaddingLeft=UDim.new(0,pad),PaddingRight=UDim.new(0,pad)})
    end
end
local function fitList(parent,name,space,pad)
    local box=blank(parent,name)
    box.AutomaticSize=Enum.AutomaticSize.Y
    box.Size=UDim2.new(1,0,0,0)
    vertical(box,space,pad)
    return box
end
local function scroll(parent,name)
    local sc=make("ScrollingFrame",parent,{Name=name,Size=UDim2.fromScale(1,1),
        BackgroundTransparency=1,BorderSizePixel=0,Active=true,ScrollBarThickness=3,
        ScrollBarImageColor3=colors.edge,ScrollingDirection=Enum.ScrollingDirection.Y,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.fromOffset(0,0),
        ClipsDescendants=true})
    vertical(sc,7,4)
    return sc
end
local function geometry(width,height,embedded)
    local pad=embedded and 0 or math.min(12,math.floor(math.min(width,height)*.026))
    local w=math.max(1,width-2*pad)
    local h=math.max(1,height-2*pad)
    if not embedded then w=math.min(900,w);h=math.min(608,h) end
    local header=embedded and 0 or (h<340 and 46 or 54)
    local inset=w<420 and 7 or 10
    local rail=w>=550 and h-header-2*inset>=44*#tabs
    local navH=48
    local railW=math.max(108,math.min(155,math.floor(w*.19)))
    local x=rail and (inset+railW+8) or inset
    local y=header+inset
    local bottom=rail and (h-inset) or (h-inset-navH-5)
    return {w=w,h=h,rail=rail,railW=railW,header=header,inset=inset,navH=navH,x=x,y=y,
        bodyW=math.max(1,w-inset-x),bodyH=math.max(1,bottom-y)}
end
local function storeFor(player)
    for _,v in ipairs(player:GetChildren()) do
        if v.Name=="Andepzai42Notebook" and v:IsA("Folder") and v:GetAttribute("Owner")==owner then
            return v
        end
    end
    local folder=make("Folder",player,{Name="Andepzai42Notebook"})
    folder:SetAttribute("Owner",owner)
    return folder
end
local function isShown(obj)
    while obj do
        if obj:IsA("GuiObject") and not obj.Visible then return false end
        if obj:IsA("ScreenGui") and not obj.Enabled then return false end
        obj=obj.Parent
    end
    return true
end
local function drawIcon(parent,id)
    local icon=blank(parent,"TabIcon")
    icon.Size=UDim2.fromOffset(18,18)
    local function bar(x,y,w,h,rot)
        local b=make("Frame",icon,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(w,h),
            BackgroundColor3=colors.crystal,BorderSizePixel=0,Rotation=rot or 0,Active=false})
        radius(b,2)
    end
    if id=="home" then
        bar(0,4,11,2,-38);bar(7,4,11,2,38)
        bar(3,8,2,8);bar(13,8,2,8);bar(3,14,12,2)
    elseif id=="status" then
        bar(1,10,3,6);bar(7,6,3,10);bar(13,2,3,14)
    elseif id=="catalog" then
        local ring=blank(icon,"Lens")
        ring.Position=UDim2.fromOffset(1,1);ring.Size=UDim2.fromOffset(11,11)
        radius(ring,8);outline(ring,colors.crystal,.04);bar(10,13,8,2,45)
    elseif id=="progress" then
        bar(1,3,3,3);bar(7,3,10,2);bar(1,8,3,3);bar(7,8,10,2);bar(1,13,3,3);bar(7,13,8,2)
    else
        bar(1,4,16,2);bar(5,2,3,6);bar(1,12,16,2);bar(11,10,3,6)
    end
    return icon
end
local function setText(obj,text)
    if obj.Text~=text then obj.Text=text end
end

function API.Mount(parent,startTab)
    assert(Run:IsClient(),"AndepzaiGlass42.Mount requires a client LocalScript")
    local player=assert(Players.LocalPlayer,"LocalPlayer chưa sẵn sàng")
    parent=parent or player:WaitForChild("PlayerGui")
    local embedded=parent:IsA("GuiObject") or parent:IsA("ScreenGui")
    assert(embedded or parent:IsA("PlayerGui"),"Mount expects PlayerGui, ScreenGui, or a Frame")
    local name=embedded and "AndepzaiGlass42Content" or "AndepzaiGlass42"
    for _,old in ipairs(parent:GetChildren()) do
        if old.Name==name and old:GetAttribute("Owner")==owner then old:Destroy() end
    end
    local root=embedded and blank(parent,name) or make("ScreenGui",parent,{Name=name,
        ResetOnSpawn=false,IgnoreGuiInset=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=55})
    root:SetAttribute("Owner",owner)
    local stage=embedded and root or blank(root,"SafeArea")
    stage.Size=UDim2.fromScale(1,1)
    local store=storeFor(player)
    local connections,views,navButtons,bindings={},{},{},{home={},status={},progress={}}
    local panels=setmetatable({}, {__mode="k"})
    local valueRows={}
    local closed=false
    local current=startTab=="home" and "home" or "status"
    local visible=true
    local viewWidth=300
    local handle={}
    local function listen(sig,fn)
        local conn=sig:Connect(fn);table.insert(connections,conn);return conn
    end
    local function tint(obj,alpha)
        obj.BackgroundTransparency=store:GetAttribute("Frost")==true and math.max(.03,alpha-.22) or alpha
    end
    local function glass(obj,alpha,r)
        obj.BackgroundColor3=colors.white
        obj.BorderSizePixel=0
        radius(obj,r or 15);outline(obj,colors.edge,.38)
        make("UIGradient",obj,{Rotation=118,Color=ColorSequence.new({
            ColorSequenceKeypoint.new(0,colors.white),ColorSequenceKeypoint.new(.44,colors.ice),
            ColorSequenceKeypoint.new(.72,colors.white),ColorSequenceKeypoint.new(1,colors.pearl)})})
        panels[obj]=alpha;tint(obj,alpha)
        return obj
    end
    local function simpleButton(parentObj,id,value,callback)
        local b=button(parentObj,id,value)
        b.BackgroundColor3=colors.ice;b.BackgroundTransparency=.18
        radius(b,11);outline(b,colors.edge,.5)
        b.Activated:Connect(callback)
        return b
    end
    local function styleChoice(b,chosen)
        b.BackgroundColor3=chosen and colors.tint or colors.white
        b.BackgroundTransparency=chosen and .04 or .36
        b.TextColor3=chosen and colors.ink or colors.soft
        b.Font=chosen and bold or medium
    end
    local function block(parentObj,title)
        local box=fitList(parentObj,title,3,8)
        glass(box,.33,15)
        return box
    end
    local function note(parentObj,text)
        local l=label(parentObj,text,13,font,colors.soft)
        l.Size=UDim2.new(1,0,0,0);l.AutomaticSize=Enum.AutomaticSize.Y
        l.TextYAlignment=Enum.TextYAlignment.Top
        return l
    end
    local function group(sc,id,title,open)
        local box=block(sc,id)
        local header=button(box,"Heading_"..id,"")
        header.Size=UDim2.new(1,0,0,44);header.Font=bold;header.TextSize=15
        header.TextXAlignment=Enum.TextXAlignment.Left;header.LayoutOrder=-1
        local body=fitList(box,"Rows",2)
        local function setOpen(value)
            body.Visible=value
            header.Text=(value and "−   " or "+   ")..title
        end
        header.Activated:Connect(function() setOpen(not body.Visible) end)
        setOpen(open)
        return body,setOpen
    end
    local function placeValue(row)
        local narrow=viewWidth<420
        row.frame.Size=UDim2.new(1,0,0,narrow and 56 or 42)
        row.key.Position=UDim2.fromOffset(7,0)
        row.key.Size=narrow and UDim2.new(1,-14,0,21) or UDim2.new(.41,-12,1,0)
        row.val.Position=narrow and UDim2.fromOffset(7,21) or UDim2.new(.41,0,0,0)
        row.val.Size=narrow and UDim2.new(1,-14,0,33) or UDim2.new(.59,-8,1,0)
        row.val.TextXAlignment=narrow and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
    end
    local function valueRow(sc,scope,key,title)
        local row=blank(sc,"Value_"..key)
        row.BackgroundColor3=colors.white;row.BackgroundTransparency=.57;radius(row,8)
        local k=label(row,title,13,font,colors.soft)
        local val=label(row,unknown,14,medium)
        local record={frame=row,key=k,val=val}
        table.insert(valueRows,record);placeValue(record);bindings[scope][key]=val
    end
    local shell=blank(stage,"Window")
    shell.AnchorPoint=Vector2.new(.5,.5);shell.Position=UDim2.fromScale(.5,.5)
    shell.Size=UDim2.fromScale(1,1);shell.ClipsDescendants=true;glass(shell,.30,embedded and 14 or 22)
    local scale=make("UIScale",shell,{Scale=1})
    local glint=make("Frame",shell,{Name="GlassRim",Position=UDim2.fromOffset(19,2),
        Size=UDim2.new(1,-38,0,1),BackgroundColor3=colors.white,BorderSizePixel=0,Active=false})
    make("UIGradient",glint,{Transparency=NumberSequence.new({
        NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.26,.05),
        NumberSequenceKeypoint.new(.70,.12),NumberSequenceKeypoint.new(1,1)})})
    local header=blank(shell,"Header")
    header.Visible=not embedded
    local monogram=label(header,"A",20,bold,colors.crystal)
    monogram.TextXAlignment=Enum.TextXAlignment.Center
    monogram.Position=UDim2.fromOffset(10,6);monogram.Size=UDim2.fromOffset(36,36);glass(monogram,.20,12)
    local brand=label(header,"andepzai",20,bold)
    brand.Position=UDim2.fromOffset(55,4);brand.Size=UDim2.new(1,-134,0,25)
    local edition=label(header,"AD42  /  LIQUID GLASS",11,medium,colors.soft)
    edition.Position=UDim2.fromOffset(56,28);edition.Size=UDim2.new(1,-140,0,15)
    local minimize=simpleButton(header,"Minimize","Thu gọn",function() handle:Hide() end)
    minimize.Size=UDim2.fromOffset(68,44);minimize.Position=UDim2.new(1,-77,.5,-22)
    local nav=blank(shell,"Navigation");glass(nav,.25,14)
    local content=blank(shell,"Pages");content.ClipsDescendants=true
    for _,tab in ipairs(tabs) do
        local id,title=tab[1],tab[2]
        local page=blank(content,"Page_"..id)
        page.Size=UDim2.fromScale(1,1);page.Visible=id==current;views[id]=page
        local tap=button(nav,"Nav_"..id,"")
        radius(tap,10)
        local icon=drawIcon(tap,id)
        local caption=label(tap,title,13,medium)
        caption.TextWrapped=false
        navButtons[id]={tap=tap,icon=icon,caption=caption}
        tap.Activated:Connect(function() handle:Open(id) end)
    end
    local start=scroll(views.status,"StatusRows")
    local guide=button(start,"Pinned","")
    guide.Size=UDim2.new(1,0,0,58);glass(guide,.14,13);guide.LayoutOrder=-1
    local pinTitle=label(guide,"Ghim một mốc",15,bold,colors.teal)
    pinTitle.Position=UDim2.fromOffset(10,3);pinTitle.Size=UDim2.new(1,-20,0,22)
    local pinDistance=label(guide,"",13,font,colors.soft)
    pinDistance.Position=UDim2.fromOffset(10,25);pinDistance.Size=UDim2.new(1,-20,0,29)
    bindings.status.pinTitle=pinTitle;bindings.status.distance=pinDistance
    local profile=group(start,"Profile","Nhân vật của tôi",true)
    for _,p in ipairs({{"player","Nhân vật"},{"sea","Khu vực"},{"level","Cấp"},{"beli","Beli"},
        {"fragments","Fragments"},{"race","Tộc"},{"honour","Bounty / Honor"},
        {"energy","Năng lượng V4"},{"form","Trạng thái V4"}}) do
        valueRow(profile,"status",p[1],p[2])
    end
    local skill=group(start,"Stats","Điểm chỉ số",false)
    for _,p in ipairs({{"Melee","Cận chiến"},{"Defense","Phòng thủ"},{"Sword","Kiếm"},
        {"Gun","Súng"},{"Demon Fruit","Trái ác quỷ"}}) do valueRow(skill,"status",p[1],p[2]) end
    local season=group(start,"World","Thế giới đang tải",false)
    for _,p in ipairs({{"clock","Giờ trong game"},{"moon","Pha trăng"},{"mirage","Mirage Island"},
        {"kitsune","Kitsune Shrine"},{"ancient","Prehistoric Island"},{"frozen","Frozen Dimension"},
        {"eyes","Mắt Tiki"}}) do valueRow(season,"status",p[1],p[2]) end
    local server=group(start,"Session","Phiên chơi",false)
    valueRow(server,"status","place","Place ID")
    note(server,"Job ID · chạm vào mã để chọn và sao chép")
    local job=make("TextBox",server,{Name="JobId",Text=game.JobId,PlaceholderText="Phiên chưa cấp Job ID",
        ClearTextOnFocus=false,Font=font,TextSize=13,TextColor3=colors.ink,TextWrapped=true,
        Size=UDim2.new(1,0,0,46),BackgroundColor3=colors.white,BackgroundTransparency=.22,BorderSizePixel=0})
    radius(job,8)
    job.Focused:Connect(function()
        task.defer(function()
            if not closed and job.Parent and job:IsFocused() and #job.Text>0 then
                job.CursorPosition=#job.Text+1;job.SelectionStart=1
            end
        end)
    end)
    job.FocusLost:Connect(function() job.Text=game.JobId end)

    local lookup=views.catalog
    local toolbar=blank(lookup,"SearchTools")
    toolbar.Size=UDim2.new(1,0,0,44)
    local field=make("TextBox",toolbar,{Name="Search",Text="",PlaceholderText="Tìm đảo, NPC, quest…",
        TextXAlignment=Enum.TextXAlignment.Left,TextSize=14,Font=font,TextColor3=colors.ink,
        PlaceholderColor3=colors.soft,ClearTextOnFocus=false,Size=UDim2.new(1,-65,1,0)})
    glass(field,.18,11)
    make("UIPadding",field,{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,37)})
    local clear=button(toolbar,"ClearSearch","×")
    clear.Position=UDim2.new(1,-105,0,0);clear.Size=UDim2.fromOffset(40,44)
    clear.TextSize=20;clear.Visible=false
    clear.Activated:Connect(function() field.Text="" end)
    local catalogScroll=scroll(lookup,"CatalogScroll")
    catalogScroll.Position=UDim2.fromOffset(0,48);catalogScroll.Size=UDim2.new(1,0,1,-48)
    local filters=block(catalogScroll,"Filters")
    filters.LayoutOrder=-3;filters.Visible=false
    local filterButton=simpleButton(toolbar,"FilterButton","Lọc",function()
        filters.Visible=not filters.Visible
        catalogScroll.CanvasPosition=Vector2.zero
    end)
    filterButton.Position=UDim2.new(1,-59,0,0);filterButton.Size=UDim2.fromOffset(59,44)
    local criteria={kind="all",sea=0,page=1,expanded=nil}
    local chips,filterStrips={},{}
    local summary=label(catalogScroll,"",12,medium,colors.soft)
    summary.LayoutOrder=-2;summary.Size=UDim2.new(1,0,0,24)
    local list=fitList(catalogScroll,"Results",5);list.LayoutOrder=1
    local paging=blank(catalogScroll,"Paging");paging.LayoutOrder=2;paging.Size=UDim2.new(1,0,0,44)
    local pageNumber=label(paging,"",13,medium)
    pageNumber.Position=UDim2.new(.28,0,0,0);pageNumber.Size=UDim2.new(.44,0,1,0)
    pageNumber.TextXAlignment=Enum.TextXAlignment.Center
    local renderCatalog,openCatalog,pickMaterial,showTrackedFruit,refresh
    local dirty=true
    local function changeFilter(key,v)
        criteria[key]=v;criteria.page=1;criteria.expanded=nil;dirty=true
        if current=="catalog" then renderCatalog(true) end
    end
    local function addChips(key,options)
        local strip=blank(filters,"Filter_"..key);strip.Size=UDim2.new(1,0,0,44)
        local stripItems={}
        table.insert(filterStrips,{frame=strip,items=stripItems})
        for i,opt in ipairs(options) do
            local v,caption=opt[1],opt[2]
            local b=simpleButton(strip,key..tostring(v),caption,function() changeFilter(key,v) end)
            b.TextSize=12;b.Size=UDim2.new(1/#options,-3,1,0)
            b.Position=UDim2.new((i-1)/#options,1,0,0)
            table.insert(chips,{button=b,key=key,value=v})
            table.insert(stripItems,b)
        end
    end
    addChips("kind",{{"all","Tất cả"},{"island","Đảo"},{"teacher","Võ sư"},{"giver","NPC"},
        {"material","Vật liệu"},{"quest","Quest"},{"fruit","Trái"}})
    addChips("sea",{{0,"Mọi Sea"},{1,"Sea 1"},{2,"Sea 2"},{3,"Sea 3"}})
    filters:GetPropertyChangedSignal("Visible"):Connect(function()
        filterButton.Text=filters.Visible and "Đóng" or "Lọc"
        styleChoice(filterButton,filters.Visible or criteria.kind~="all" or criteria.sea~=0)
    end)
    local prev=simpleButton(paging,"Prev","‹ Trước",function()
        criteria.page=math.max(1,criteria.page-1);criteria.expanded=nil;renderCatalog(true)
    end)
    prev.Size=UDim2.new(.28,0,1,0)
    local nextPage=simpleButton(paging,"Next","Sau ›",function()
        criteria.page=criteria.page+1;criteria.expanded=nil;renderCatalog(true)
    end)
    nextPage.Position=UDim2.new(.72,0,0,0);nextPage.Size=UDim2.new(.28,0,1,0)
    local locationAliases={Fountain="Fountain City",Sky="Skylands",["Upper Sky"]="Upper Skylands"}
    local function pinFor(entry)
        if entry.position then return entry end
        if entry.kind=="quest" then
            local quest=quests[entry.index]
            return byId["island/"..quest[4].."/"..(locationAliases[quest[3]] or quest[3])]
        end
        return nil
    end
    local function questKey(index) return string.format("Q%02d",index) end
    local displayed,redraw={},{ }
    local function rowAction(body,name,caption,fn)
        local b=simpleButton(body,name,caption,fn)
        b.Size=UDim2.new(1,0,0,44);b.TextWrapped=true
        return b
    end
    local function buildResult(entry,order)
        local box=block(list,entry.id);box.LayoutOrder=order
        table.insert(displayed,box)
        local head=button(box,"OpenRow","");head.Size=UDim2.new(1,0,0,52)
        local title=label(head,entry.name,15,bold);title.Size=UDim2.new(1,-32,0,32)
        local meta=label(head,entry.meta,12,medium,colors.soft)
        meta.Position=UDim2.fromOffset(0,32);meta.Size=UDim2.new(1,-32,0,19)
        local sign=label(head,"+",18,medium,colors.teal)
        sign.TextXAlignment=Enum.TextXAlignment.Center
        sign.Size=UDim2.fromOffset(26,34);sign.Position=UDim2.new(1,-27,.5,-17)
        local body=fitList(box,"Details",5);body.LayoutOrder=2
        note(body,entry.detail)
        local target=pinFor(entry)
        local pin,done,watch
        if target then
            pin=rowAction(body,"Pin","",function()
                local previous=store:GetAttribute("Pin")
                if previous==target.id then store:SetAttribute("Pin",nil)
                else store:SetAttribute("Pin",target.id) end
                for _,draw in pairs(redraw) do draw() end
            end)
        end
        if entry.index then
            done=rowAction(body,"Done","",function()
                local k=questKey(entry.index)
                store:SetAttribute(k,store:GetAttribute(k)~=true)
                redraw[entry.id]()
            end)
        end
        if entry.kind=="material" then
            local choices=entry.name=="Leather + Scrap Metal" and {"Leather","Scrap Metal"} or {entry.name}
            for _,itemName in ipairs(choices) do
                local item=itemName
                rowAction(body,"Track_"..item,"Theo dõi "..item,function() pickMaterial(item) end)
            end
        elseif entry.kind=="fruit" then
            watch=rowAction(body,"WatchFruit","",function()
                if store:GetAttribute("WatchFruit")==entry.id then
                    store:SetAttribute("WatchFruit",nil)
                    for _,update in pairs(redraw) do update() end
                else
                    store:SetAttribute("WatchFruit",entry.id);showTrackedFruit()
                end
            end)
        end
        local function draw()
            local open=criteria.expanded==entry.id
            body.Visible=open;sign.Text=open and "−" or "+"
            local tick=entry.index and store:GetAttribute(questKey(entry.index))==true
            meta.Text=entry.meta..(tick and "  ·  Đã đánh dấu" or "")
            if done then
                done.Text=tick and "Bỏ dấu đã xong" or "Đánh dấu đã xong"
                styleChoice(done,tick)
            end
            if pin then
                local chosen=store:GetAttribute("Pin")==target.id
                pin.Text=(chosen and "Bỏ ghim · " or "Ghim · ")..target.name
                styleChoice(pin,chosen)
            end
            if watch then
                local chosen=store:GetAttribute("WatchFruit")==entry.id
                watch.Text=chosen and "Bỏ theo dõi trái" or "Theo dõi trong Tiến độ"
                styleChoice(watch,chosen)
            end
        end
        redraw[entry.id]=draw
        head.Activated:Connect(function()
            local prior=criteria.expanded
            if prior==entry.id then criteria.expanded=nil else criteria.expanded=entry.id end
            if prior and prior~=entry.id and redraw[prior] then redraw[prior]() end
            draw()
        end)
        draw()
    end
    renderCatalog=function(top)
        dirty=false
        for _,v in ipairs(displayed) do v:Destroy() end
        displayed={};redraw={}
        local words={}
        for word in fold(field.Text):gmatch("%S+") do table.insert(words,word) end
        local hits={}
        for _,entry in ipairs(catalog) do
            if matches(entry,words,criteria.kind,criteria.sea) then table.insert(hits,entry) end
        end
        local pages=math.max(1,math.ceil(#hits/pageSize))
        criteria.page=math.clamp(criteria.page,1,pages)
        local lo=(criteria.page-1)*pageSize+1
        for i=lo,math.min(lo+pageSize-1,#hits) do buildResult(hits[i],i) end
        local s=criteria.sea==0 and "Mọi Sea" or "Sea "..criteria.sea
        summary.Text=kinds[criteria.kind].."  ·  "..s.."  ·  "..#hits.." kết quả"
        for _,chip in ipairs(chips) do styleChoice(chip.button,criteria[chip.key]==chip.value) end
        styleChoice(filterButton,filters.Visible or criteria.kind~="all" or criteria.sea~=0)
        if #hits==0 then
            local none=block(list,"Empty");table.insert(displayed,none)
            note(none,"Không tìm thấy mục phù hợp.")
            rowAction(none,"ResetFilters","Xóa tìm kiếm và bộ lọc",function() openCatalog("all") end)
        end
        paging.Visible=pages>1;prev.Visible=criteria.page>1;nextPage.Visible=criteria.page<pages
        pageNumber.Text="Trang "..criteria.page.." / "..pages
        if top then catalogScroll.CanvasPosition=Vector2.zero end
    end
    local settingQuery=false
    field:GetPropertyChangedSignal("Text"):Connect(function()
        clear.Visible=#field.Text>0
        if settingQuery then return end
        criteria.page=1;criteria.expanded=nil;dirty=true
        if current=="catalog" then renderCatalog(true) end
    end)
    openCatalog=function(kind,entry,sea)
        criteria.kind=kind or "all";criteria.sea=sea or 0;criteria.page=1
        criteria.expanded=entry and entry.id or nil
        settingQuery=true;field.Text=entry and entry.name or "";settingQuery=false
        clear.Visible=#field.Text>0;filters.Visible=false;dirty=true
        handle:Open("catalog")
    end
    guide.Activated:Connect(function()
        local p=byId[store:GetAttribute("Pin") or ""]
        openCatalog(p and p.kind or "island",p)
    end)

    -- AD41 home and quick navigation share the notebook's single window.
    local home=scroll(views.home,"HomeRows")
    local overview=label(home,"",15,bold,colors.teal)
    overview.Size=UDim2.new(1,0,0,36);bindings.home.overview=overview
    local quick=block(home,"QuickAccess")
    local shortcuts=blank(quick,"HomeShortcuts")
    local actions={
        {"Notebook","Sổ tay Glass",function() openCatalog("all") end},
        {"QuestGivers","NPC nhiệm vụ",function() openCatalog("giver",nil,seaForPlace[game.PlaceId]) end},
        {"Journal","Sổ nhiệm vụ",function() openCatalog("quest") end},
        {"Tracking","Đang theo dõi",function() handle:Open("progress") end},
    }
    local homeButtons={}
    for _,action in ipairs(actions) do
        local b=simpleButton(shortcuts,action[1],action[2],action[3])
        b.TextWrapped=true
        table.insert(homeButtons,b)
    end
    local levelGuide=group(home,"LevelGuide","Nhiệm vụ theo cấp · AD41",true)
    valueRow(levelGuide,"home","objective","Mục tiêu")
    valueRow(levelGuide,"home","bracket","Khoảng cấp")
    local seeGiver=rowAction(levelGuide,"ViewGiver","Tra điểm nhận nhiệm vụ",function()
        local route,_,fallback=currentRoute(player)
        local target=route and route.entry or fallback
        openCatalog(target and target.kind or "giver",target,seaForPlace[game.PlaceId])
    end)

    local goals=scroll(views.progress,"ProgressRows")
    local function revealProgress(body,setOpen)
        handle:Open("progress");setOpen(true)
        local card=body.Parent
        task.defer(function()
            if not closed and goals.Parent and current=="progress" then
                local y=card.AbsolutePosition.Y-goals.AbsolutePosition.Y+goals.CanvasPosition.Y
                goals.CanvasPosition=Vector2.new(0,math.max(0,y-5))
            end
        end)
    end
    local journal=group(goals,"QuestBook","Sổ nhiệm vụ",true)
    valueRow(journal,"progress","done","Tự đánh dấu trong phiên")
    rowAction(journal,"OpenQuests","Mở danh sách nhiệm vụ",function() openCatalog("quest") end)
    local equipment=group(goals,"Gear","Trang bị & mastery",true)
    note(equipment,"Mốc tham khảo từ Teddy. Giá trị lấy từ trang bị, túi hoặc danh sách đã tải.")
    for _,v in ipairs({{"tushita","Tushita"},{"yama","Yama"},{"mirror","Mirror Fractal"},{"helm","Valkyrie Helm"}}) do
        valueRow(equipment,"progress",v[1],v[2])
    end
    local fruits,setFruitOpen=group(goals,"FruitWatch","Trái đang theo dõi",false)
    valueRow(fruits,"progress","fruitName","Trái đã chọn")
    valueRow(fruits,"progress","fruitLocation","Trạng thái trên máy")
    rowAction(fruits,"BrowseFruit","Mở danh mục trái",function() openCatalog("fruit") end)
    showTrackedFruit=function() revealProgress(fruits,setFruitOpen) end
    local material,setMaterialOpen=group(goals,"MaterialGoal","Mục tiêu vật liệu",true)
    valueRow(material,"progress","matName","Đang theo dõi")
    valueRow(material,"progress","matProgress","Số lượng / mục tiêu")
    rowAction(material,"PickMaterial","Chọn vật liệu",function() openCatalog("material") end)
    local inputs=blank(material,"GoalInputs");inputs.Size=UDim2.new(1,0,0,68)
    local function numberField(id,caption,offset)
        local heading=label(inputs,caption,12,medium,colors.soft)
        heading.Position=UDim2.new(offset,3,0,0);heading.Size=UDim2.new(.5,-6,0,20)
        local b=make("TextBox",inputs,{Name=id,Font=medium,TextSize=14,TextColor3=colors.ink,
            BackgroundColor3=colors.white,BackgroundTransparency=.14,BorderSizePixel=0,Text="",
            PlaceholderText="—",ClearTextOnFocus=false,
            Position=UDim2.new(offset,2,0,21),Size=UDim2.new(.5,-4,0,44)})
        radius(b,8);outline(b,colors.edge,.5);return b
    end
    local goalInput=numberField("Target","Mục tiêu",0)
    local countInput=numberField("ManualCount","Số tự ghi",.5)
    local matKeys={}
    for index,ref in ipairs(materialReferences) do
        if ref[1]=="Leather + Scrap Metal" then
            matKeys.Leather="M"..index.."L";matKeys["Scrap Metal"]="M"..index.."S"
        else matKeys[ref[1]]="M"..index end
    end
    local function selectedMaterial()
        local item=store:GetAttribute("Material")
        if item and matKeys[item] then return item,matKeys[item] end
        return nil,nil
    end
    local function readInputs()
        local _,key=selectedMaterial()
        goalInput.Text=key and tostring(store:GetAttribute(key.."Goal") or 30) or ""
        local count=key and store:GetAttribute(key.."Note")
        countInput.Text=count and tostring(count) or ""
    end
    local function inventoryCount(data,name)
        local rec=child(child(data,"Inventory"),name)
        if rec and (rec:IsA("NumberValue") or rec:IsA("IntValue")) then return number(rec.Value) end
        return number(readValue(rec,"Count")) or number(readValue(rec,"Amount"))
    end
    local function parseCount(text,minimum)
        local n=number(text:match("^%s*(%d+)%s*$"))
        if n and n>=minimum and n<=999999999 then return n end
    end
    local message=note(material,"Có thể ghi tay khi số lượng trong game chưa tải.")
    local saveGoal=rowAction(material,"SaveGoal","Lưu mục tiêu",function()
        local _,key=selectedMaterial()
        if not key then message.Text="Chọn một vật liệu trước khi lưu.";return end
        local goal=parseCount(goalInput.Text,1)
        local blankCount=countInput.Text:match("^%s*$")~=nil
        local count=parseCount(countInput.Text,0)
        if not goal or (not blankCount and not count) then
            message.Text="Nhập số nguyên từ 0 tới 999999999. Mục tiêu phải lớn hơn 0.";return
        end
        store:SetAttribute(key.."Goal",goal);store:SetAttribute(key.."Note",count)
        message.Text="Đã lưu cho phiên này.";readInputs();refresh()
    end)
    saveGoal.LayoutOrder=20;message.LayoutOrder=21
    pickMaterial=function(name)
        if not matKeys[name] then return end
        store:SetAttribute("Material",name);readInputs()
        message.Text="Số lượng từ game được ưu tiên khi đã tải."
        revealProgress(material,setMaterialOpen)
    end
    readInputs()

    local settings=scroll(views.settings,"Preferences")
    local appearance=group(settings,"Appearance","Liquid Glass",true)
    local toggles={}
    local function preference(key,title)
        local tap=button(appearance,key,"");tap.Size=UDim2.new(1,0,0,48)
        local caption=label(tap,title,14,medium)
        caption.Position=UDim2.fromOffset(5,0);caption.Size=UDim2.new(1,-90,1,0)
        local indicator=label(tap,"",13,bold)
        indicator.TextXAlignment=Enum.TextXAlignment.Center;indicator.Size=UDim2.fromOffset(62,32)
        indicator.Position=UDim2.new(1,-66,.5,-16);indicator.BackgroundTransparency=.12;radius(indicator,16)
        local function paint()
            local on=store:GetAttribute(key)==true
            indicator.Text=on and "BẬT" or "TẮT"
            indicator.BackgroundColor3=on and colors.tint or colors.ice
            indicator.TextColor3=on and colors.teal or colors.soft
        end
        toggles[key]=paint;paint()
        tap.Activated:Connect(function() store:SetAttribute(key,store:GetAttribute(key)~=true) end)
    end
    preference("Frost","Kính đậm · dễ đọc")
    preference("ReduceMotion","Giảm chuyển động")
    local about=group(settings,"About","Dữ liệu của sổ tay",false)
    note(about,"AD41 cung cấp trang chủ, điểm nhận nhiệm vụ theo cấp, mốc bản đồ và sổ nhiệm vụ. Vxeze cung cấp bố cục theo tab, danh mục trái, vật liệu và các mục trạng thái. Teddy cung cấp mốc trang bị. message-7 cung cấp thông tin tộc, pha trăng và phiên chơi.")
    note(about,"Ghim, dấu nhiệm vụ và mục tiêu được giữ trong phiên hiện tại. Khi rời máy chủ, các ghi chú trong phiên sẽ hết.")
    refresh=function()
        if closed or not visible then return end
        local vals
        if current=="home" then
            local sea=seaForPlace[game.PlaceId]
            local level=number(readValue(child(player,"Data"),"Level"))
            local route,detail,fallback=currentRoute(player)
            vals={
                overview=(sea and "Sea "..sea or "Chưa rõ Sea").."   ·   "..
                    (level and "Cấp "..amount(level) or "Đang chờ cấp nhân vật"),
                objective=route and route.mob or detail,
                bracket=route and detail or "Chưa áp dụng",
            }
            local caption="Tra danh sách NPC"
            if route then caption="Xem điểm nhận nhiệm vụ"
            elseif fallback then caption="Xem đảo Hải quân" end
            setText(seeGiver,caption)
        elseif current=="status" then
            vals=statusSnapshot(player,byId[store:GetAttribute("Pin") or ""])
        elseif current=="progress" then
            vals=gearSnapshot(player)
            local tracked=byId[store:GetAttribute("WatchFruit") or ""]
            vals.fruitName=tracked and tracked.name or "Chưa chọn"
            vals.fruitLocation=fruitLocation(player,tracked)
            local n=0
            for i=1,#quests do if store:GetAttribute(questKey(i))==true then n=n+1 end end
            vals.done=n.." / "..#quests
            local item,key=selectedMaterial()
            vals.matName=item or "Chưa chọn"
            vals.matProgress="Chọn vật liệu để đặt mục tiêu"
            if key then
                local count=inventoryCount(child(player,"Data"),item)
                local target=store:GetAttribute(key.."Goal") or 30
                local origin="game"
                if count==nil then count=number(store:GetAttribute(key.."Note"));origin="ghi tay" end
                if count~=nil then
                    vals.matProgress=amount(count).." / "..amount(target).." · "..origin..
                        (count>=target and " · Đạt" or "")
                else vals.matProgress="Chưa rõ số lượng / "..amount(target) end
            end
        else return end
        for key,obj in pairs(bindings[current]) do setText(obj,vals[key] or unknown) end
    end

    local launcher=button(stage,"OpenAndepzai","A")
    launcher.AnchorPoint=Vector2.new(.5,.5)
    launcher.Size=UDim2.fromOffset(48,48)
    launcher.Visible=false;launcher.Font=bold;launcher.TextSize=23;launcher.ZIndex=8
    glass(launcher,.14,17)
    local drag,showTween
    local skipActivation=false
    local function limitPoint(v,extent)
        local pad=math.min(28,extent/2)
        return math.clamp(v,pad,extent-pad)
    end
    local function moveLauncher(x,y)
        local s=stage.AbsoluteSize
        launcher.Position=UDim2.fromOffset(limitPoint(x,s.X),limitPoint(y,s.Y))
    end
    local function placeLauncher()
        local s=stage.AbsoluteSize
        moveLauncher((number(store:GetAttribute("DockX")) or .87)*s.X,
            (number(store:GetAttribute("DockY")) or .27)*s.Y)
    end
    local touch,mouse=Enum.UserInputType.Touch,Enum.UserInputType.MouseButton1
    launcher.InputBegan:Connect(function(input)
        if drag or (input.UserInputType~=touch and input.UserInputType~=mouse) then return end
        skipActivation=false
        drag={input=input,x=input.Position.X,y=input.Position.Y,
            fromX=launcher.Position.X.Offset,fromY=launcher.Position.Y.Offset,moved=false}
    end)
    listen(Input.InputChanged,function(input)
        if not drag then return end
        if drag.input.UserInputType==touch then
            if drag.input~=input then return end
        elseif input.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local dx,dy=input.Position.X-drag.x,input.Position.Y-drag.y
        if not drag.moved and dx*dx+dy*dy<49 then return end
        drag.moved=true;skipActivation=true
        moveLauncher(drag.fromX+dx,drag.fromY+dy)
    end)
    listen(Input.InputEnded,function(input)
        if not drag or (input~=drag.input and not
            (drag.input.UserInputType==mouse and input.UserInputType==mouse)) then return end
        if drag.moved then
            local s=stage.AbsoluteSize
            if s.X>0 and s.Y>0 then
                store:SetAttribute("DockX",launcher.Position.X.Offset/s.X)
                store:SetAttribute("DockY",launcher.Position.Y.Offset/s.Y)
            end
        end
        drag=nil
    end)
    launcher.Activated:Connect(function(input)
        if input and input.UserInputType~=touch and input.UserInputType~=mouse then skipActivation=false end
        if not skipActivation then handle:Open(current) end
    end)
    local function setGeometry()
        local size=stage.AbsoluteSize
        if size.X<1 or size.Y<1 then return end
        local g=geometry(size.X,size.Y,embedded)
        shell.Size=UDim2.fromOffset(g.w,g.h)
        header.Size=UDim2.new(1,0,0,g.header)
        content.Position=UDim2.fromOffset(g.x,g.y)
        content.Size=UDim2.fromOffset(g.bodyW,g.bodyH)
        if g.rail then
            nav.Position=UDim2.fromOffset(g.inset,g.y)
            nav.Size=UDim2.fromOffset(g.railW,g.bodyH)
        else
            nav.Position=UDim2.fromOffset(g.inset,g.h-g.inset-g.navH)
            nav.Size=UDim2.fromOffset(g.w-2*g.inset,g.navH)
        end
        local navPad=math.clamp(math.floor((g.bodyH-44*#tabs)/2),0,4)
        local row=math.min(50,math.floor((g.bodyH-2*navPad)/#tabs))
        for i,tab in ipairs(tabs) do
            local v=navButtons[tab[1]]
            if g.rail then
                v.tap.Position=UDim2.fromOffset(3,navPad+(i-1)*row)
                v.tap.Size=UDim2.new(1,-6,0,row)
                v.icon.Position=UDim2.new(0,7,.5,-9)
                v.caption.Position=UDim2.fromOffset(30,0);v.caption.Size=UDim2.new(1,-32,1,0)
                v.caption.TextXAlignment=Enum.TextXAlignment.Left;v.caption.TextSize=13
            else
                v.tap.Position=UDim2.new((i-1)/#tabs,1,0,2)
                v.tap.Size=UDim2.new(1/#tabs,-2,1,-4)
                v.icon.Position=UDim2.new(.5,-9,0,3)
                v.caption.Position=UDim2.fromOffset(0,21);v.caption.Size=UDim2.new(1,0,0,22)
                v.caption.TextXAlignment=Enum.TextXAlignment.Center;v.caption.TextSize=12
            end
            local compactLabel=not g.rail and (g.w-2*g.inset)/#tabs<65
            v.caption.Text=(compactLabel and tab[3]) or tab[2]
        end
        viewWidth=g.bodyW
        local homeColumns=viewWidth>=245 and 2 or 1
        shortcuts.Size=UDim2.new(1,0,0,math.ceil(#homeButtons/homeColumns)*48-4)
        for i,b in ipairs(homeButtons) do
            b.Size=UDim2.new(1/homeColumns,-4,0,44)
            b.Position=UDim2.new(((i-1)%homeColumns)/homeColumns,2,0,math.floor((i-1)/homeColumns)*48)
        end
        for _,strip in ipairs(filterStrips) do
            local total=#strip.items
            local maxColumns=math.clamp(math.floor((viewWidth-26)/60),1,total)
            local columns=math.ceil(total/math.ceil(total/maxColumns))
            strip.frame.Size=UDim2.new(1,0,0,math.ceil(total/columns)*46-2)
            for i,b in ipairs(strip.items) do
                b.Size=UDim2.new(1/columns,-3,0,44)
                b.Position=UDim2.new(((i-1)%columns)/columns,1,0,math.floor((i-1)/columns)*46)
            end
        end
        for _,v in ipairs(valueRows) do placeValue(v) end
        if drag then drag=nil;skipActivation=true end
        placeLauncher()
    end
    local function stopAnimation()
        if showTween then showTween:Cancel();showTween:Destroy();showTween=nil end
        scale.Scale=1
    end
    function handle:Open(id)
        if closed then return false end
        id=id or current
        if not views[id] then return false end
        local changed=id~=current or not visible
        current=id;visible=true;shell.Visible=true;launcher.Visible=false
        for key,page in pairs(views) do
            local selected=key==current
            page.Visible=selected
            local v=navButtons[key]
            styleChoice(v.tap,selected)
            v.caption.TextColor3=selected and colors.ink or colors.soft
            v.caption.Font=selected and bold or medium
        end
        if current=="catalog" then
            if dirty then renderCatalog(true) else for _,draw in pairs(redraw) do draw() end end
        elseif current=="progress" and changed then readInputs() end
        if changed then
            stopAnimation()
            if store:GetAttribute("ReduceMotion")~=true then
                scale.Scale=.992
                showTween=Tweens:Create(scale,TweenInfo.new(.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Scale=1})
                showTween:Play()
            end
        end
        refresh()
        return true
    end
    function handle:Hide()
        if closed or not visible then return end
        local focused=Input:GetFocusedTextBox()
        if focused and focused:IsDescendantOf(shell) then focused:ReleaseFocus() end
        visible=false;stopAnimation()
        shell.Visible=false;launcher.Visible=true;placeLauncher()
    end
    function handle:Search(text)
        if closed or type(text)~="string" then return false end
        criteria.kind="all";criteria.sea=0;criteria.page=1;criteria.expanded=nil
        settingQuery=true;field.Text=text;settingQuery=false
        clear.Visible=text~="";dirty=true
        return self:Open("catalog")
    end
    function handle:GetTab()
        return current
    end
    local function cleanup()
        if closed then return end
        closed=true;drag=nil
        if showTween then showTween:Cancel();showTween:Destroy();showTween=nil end
        for _,conn in ipairs(connections) do conn:Disconnect() end
        connections={}
    end
    function handle:Destroy()
        if closed then return end
        cleanup();root:Destroy()
    end
    listen(root.Destroying,cleanup)
    listen(stage:GetPropertyChangedSignal("AbsoluteSize"),setGeometry)
    listen(store:GetAttributeChangedSignal("Frost"),function()
        for obj,alpha in pairs(panels) do if obj.Parent then tint(obj,alpha) end end
        toggles.Frost()
    end)
    listen(store:GetAttributeChangedSignal("ReduceMotion"),function()
        if store:GetAttribute("ReduceMotion") then stopAnimation() end
        toggles.ReduceMotion()
    end)
    listen(store:GetAttributeChangedSignal("Pin"),function()
        if current=="catalog" then for _,draw in pairs(redraw) do draw() end end
        refresh()
    end)
    local elapsed=0
    listen(Run.Heartbeat,function(dt)
        if not visible or not bindings[current] then return end
        elapsed=elapsed+dt
        if elapsed>=2 then
            elapsed=0
            if isShown(shell) then refresh() end
        end
    end)
    setGeometry();handle:Open(current)
    return handle
end

local installed=setmetatable({}, {__mode="k"})
function API.AttachAD41(addPage)
    assert(type(addPage)=="function","AttachAD41 expects the AD41 addPage function")
    local prior=installed[addPage]
    if prior and prior.host and prior.host.Parent then return prior.handle end
    local page=prior and prior.page
    if not page or not page.Frame.Parent then
        page=addPage("glass42","◇","Sổ tay Glass","Trạng thái, bản đồ và tiến độ")
    end
    local frame=page.Frame
    if page.Heading and page.Heading.Parent then page.Heading.Parent.Visible=false end
    frame.AutomaticCanvasSize=Enum.AutomaticSize.None
    frame.ScrollingEnabled=false;frame.ScrollBarThickness=0
    frame.CanvasSize=UDim2.fromOffset(0,0)
    local host=blank(frame,"Glass42Host");host.LayoutOrder=1
    local function fitHost()
        host.Size=UDim2.new(1,0,0,math.max(1,frame.AbsoluteSize.Y-13))
    end
    fitHost()
    local resized=frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitHost)
    local handle=API.Mount(host)
    local section={Name="Sổ tay Glass",Header=page.Heading,Card=host,Elements={},Collapsed=false}
    local query,pending,previousTab,applied="",nil,nil,nil
    local hasMatch=true
    local function showSearch()
        if not frame.Visible or not host.Visible then return end
        if pending and pending~=applied then
            previousTab=previousTab or handle:GetTab()
            handle:Search(pending);applied=pending
        elseif not pending and applied then
            handle:Search("")
            handle:Open(previousTab or "status")
            previousTab=nil;applied=nil
        end
    end
    local function showSection()
        host.Visible=hasMatch and (query~="" or not section.Collapsed)
        showSearch()
    end
    function section:SetCollapsed(collapse)
        self.Collapsed=collapse==true
        showSection()
    end
    function section:ApplyFilter(text,pageMatches)
        query=fold(text or "");pending=nil
        hasMatch=query=="" or pageMatches==true or fold(self.Name):find(query,1,true)~=nil
        if not hasMatch then
            local words={}
            for w in query:gmatch("%S+") do table.insert(words,w) end
            for _,entry in ipairs(catalog) do
                if matches(entry,words,"all",0) then
                    hasMatch=true;pending=text;break
                end
            end
        end
        showSection()
        return hasMatch
    end
    page.Index=(page.Index or 0)+1
    table.insert(page.Sections,section)
    local shown=frame:GetPropertyChangedSignal("Visible"):Connect(showSearch)
    local destroyPanel=handle.Destroy
    local function dispose()
        resized:Disconnect();shown:Disconnect()
        if installed[addPage] and installed[addPage].host==host then installed[addPage]={page=page} end
        destroyPanel(handle)
        for i,v in ipairs(page.Sections) do
            if v==section then table.remove(page.Sections,i);break end
        end
    end
    host.Destroying:Connect(dispose)
    function handle:Destroy()
        if host.Parent then host:Destroy() end
    end
    installed[addPage]={page=page,host=host,handle=handle}
    return handle
end

if script:IsA("ModuleScript") then return API end
if Run:IsClient() then
    local container=script.Parent
    if not container or not (container:IsA("GuiObject") or container:IsA("ScreenGui")) then container=nil end
    local window=API.Mount(container,"home")
    script.Destroying:Connect(function() window:Destroy() end)
end
