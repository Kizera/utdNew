local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

-- ==========================================
-- ระบบเซฟการตั้งค่า Auto Farm (ป้องกันสคริปต์ลืมตอนวาร์ป)
-- ==========================================
local configName = "UTD_AutoFarm_State.txt"
if isfile and readfile then
    if not isfile(configName) then
        writefile(configName, "OFF")
    end
    local savedState = readfile(configName)
    getgenv().AutoLoop = (savedState == "ON")
else
    -- กรณี Executor ไม่รองรับระบบไฟล์
    getgenv().AutoLoop = getgenv().AutoLoop or false
end

-- ==========================================
-- 1. สร้าง GUI เปิด/ปิด
-- ==========================================
local ScreenGui = Instance.new("ScreenGui")
local ToggleBtn = Instance.new("TextButton")

ScreenGui.Name = "AutoFarmGUI"
ScreenGui.Parent = game.CoreGui

ToggleBtn.Parent = ScreenGui
ToggleBtn.Size = UDim2.new(0, 150, 0, 50)
ToggleBtn.Position = UDim2.new(0.8, 0, 0.1, 0)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 20
ToggleBtn.Draggable = true

-- อัปเดตสีปุ่มตามสถานะที่เซฟไว้
if getgenv().AutoLoop then
    ToggleBtn.Text = "Auto Farm : ON"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
else
    ToggleBtn.Text = "Auto Farm : OFF"
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
end

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    if getgenv().AutoLoop then
        ToggleBtn.Text = "Auto Farm : ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
        if writefile then writefile(configName, "ON") end
    else
        ToggleBtn.Text = "Auto Farm : OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        if writefile then writefile(configName, "OFF") end
    end
end)

-- ==========================================
-- 2. ฟังก์ชันช่วยยิง Remote แบบปลอดภัย
-- ==========================================
local function fireRemote(remotePath, ...)
    local args = {...}
    pcall(function()
        if remotePath then
            remotePath:FireServer(unpack(args))
        end
    end)
end

-- ==========================================
-- 3. ระบบ Auto-Inject ตอนวาร์ป (Teleport)
-- ==========================================
pcall(function()
    local teleportFunc = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
    if teleportFunc then
        teleportFunc('loadstring(game:HttpGet("https://raw.githubusercontent.com/Kizera/utdNew/main/utdstr.lua?t=" .. tostring(tick())))()')
    end
end)

-- ==========================================
-- 4. Core Loop (แยกโซน Lobby กับ In-Game)
-- ==========================================
local lastRimuruSkillTime = 0 -- ตัวแปรเก็บเวลาดีเลย์สกิล 5 วิ

task.spawn(function()
    while task.wait(1) do
        if not getgenv().AutoLoop then continue end

        -- เช็คว่ามีโมเดล Lobby ใน Workspace ไหม
        local lobbyPath = workspace:FindFirstChild("Lobby")
        
        if lobbyPath then
            -- [ โซน Lobby ]
            pcall(function()
                local tpTarget = workspace.Lobby.ClassicPartyTeleporters.Teleporter4["Cylinder.119"]
                if tpTarget then
                    -- วาร์ปไปจุดเลือกด่าน
                    Player.Character.HumanoidRootPart.CFrame = tpTarget.CFrame + Vector3.new(0, 4, 0)
                end
            end)
            
            task.wait(1.5) 
            
            -- 1. เลือกแมพ RuinedFutureCity
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerSelectedMap"), "RuinedFutureCity")
            task.wait(2) 
            
            -- 2. เลือกความยาก HardDifficulty
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerSelectedDifficulty"), "HardDifficulty")
            task.wait(2) 
            
            -- 3. กด Start เข้าด่าน
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerQuickstartTeleport"))
            
            -- รอเกมโหลดวาร์ป
            task.wait(5)
            
        else
            -- [ โซน In-Game ]
            
            -- กด Ready เริ่มเกม
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerVoteToStartMatch"))
            
            local placeRemote = RS:WaitForChild("GenericModules"):WaitForChild("Service"):WaitForChild("Network"):WaitForChild("PlayerPlaceTower")
            local toggleAbilityRemote = RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerToggleAutoAbility")
            local activateAbilityRemote = RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerActivateTowerAbility")
            
            -- วาง Yuji
            fireRemote(placeRemote, "162743126:38673", Vector3.new(-602.1862182617188, 0.02558167278766632, -180.89651489257812), 0)
            task.wait(0.5)
            
            -- วาง Ori
            fireRemote(placeRemote, "162743126:40346", Vector3.new(-605.0648193359375, 0.025528330355882645, -173.67678833007812), 0)
            task.wait(0.5)
            
            -- วาง Rimuru
            fireRemote(placeRemote, "162743126:47563", Vector3.new(-607.68212890625, 0.02553214505314827, -168.1455078125), 0)
            task.wait(0.5)
            
            -- เปิด Auto Skill Rimuru (Toggle)
            fireRemote(toggleAbilityRemote, "107")
            
            -- สแปมกด Skill Rimuru (Activate) ทุกๆ 5 วินาที
            if tick() - lastRimuruSkillTime >= 5 then
                fireRemote(activateAbilityRemote, "6")
                lastRimuruSkillTime = tick() -- รีเซ็ตเวลาใหม่
            end
            task.wait(0.5)
            
            -- วาง Dragon Gree
            fireRemote(placeRemote, "__rs__Shenron", Vector3.new(-619.9423828125, 0.025577858090400696, -177.84864807128906), 0)
            task.wait(0.5)
            
            -- วาง Red Dragon
            fireRemote(placeRemote, "162743126:41308", Vector3.new(-596.717529296875, 3.025526762008667, -160.88565063476562))
            task.wait(0.5)
            
            -- วาง Goku (แก้ไข ID และพิกัดแล้ว)
            fireRemote(placeRemote, "162743126:48933", Vector3.new(-603.0701293945312, 0.025575950741767883, -177.08416748046875), 0)
            
            -- หน่วงเวลา 2 วิก่อนรีลูป ป้องกันเด้งหลุด
            task.wait(2)
            
            -- ยิง Replay (กดซ้ำรอบต่อไปตอนจบเกม)
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerVoteReplay"))
        end
    end
end)
