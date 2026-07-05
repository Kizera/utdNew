local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Player = Players.LocalPlayer

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
ToggleBtn.Text = "Auto Farm : OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.SourceSansBold
ToggleBtn.TextSize = 20
ToggleBtn.Draggable = true

getgenv().AutoLoop = false

ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().AutoLoop = not getgenv().AutoLoop
    if getgenv().AutoLoop then
        ToggleBtn.Text = "Auto Farm : ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
    else
        ToggleBtn.Text = "Auto Farm : OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    end
end)

-- ==========================================
-- 2. ฟังก์ชันช่วยยิง Remote แบบปลอดภัย (Safe Fire) [แก้บั๊กแล้ว]
-- ==========================================
local function fireRemote(remotePath, ...)
    local args = {...} -- แพ็คข้อมูลเก็บไว้ก่อน
    pcall(function()
        if remotePath then
            remotePath:FireServer(unpack(args)) -- เอาข้อมูลมาแตกใส่
        end
    end)
end

-- ==========================================
-- 3. Core Loop (แยกโซน Lobby กับ In-Game)
-- ==========================================
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
                    Player.Character.HumanoidRootPart.CFrame = tpTarget.CFrame + Vector3.new(0, 4, 0)
                end
            end)
            
            task.wait(1)
            
            -- เลือกแมพ RuinedFutureCity
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerSelectedMap"), "RuinedFutureCity")
            task.wait(1)
            
            -- เลือกความยาก HardDifficulty
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerSelectedDifficulty"), "HardDifficulty")
            task.wait(1)
            
            -- กด Start เข้าด่าน
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerQuickstartTeleport"))
            
            -- รอโหลดเข้าด่าน 8-10 วิ
            task.wait(8)
            
        else
            -- [ โซน In-Game ]
            
            -- กด Ready เริ่มเกม
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerVoteToStartMatch"))
            
            local placeRemote = RS:WaitForChild("GenericModules"):WaitForChild("Service"):WaitForChild("Network"):WaitForChild("PlayerPlaceTower")
            
            -- วาง Yuji
            fireRemote(placeRemote, "162743126:38673", Vector3.new(-602.1862182617188, 0.02558167278766632, -180.89651489257812), 0)
            task.wait(0.5)
            
            -- วาง Ori
            fireRemote(placeRemote, "162743126:40346", Vector3.new(-605.0648193359375, 0.025528330355882645, -173.67678833007812), 0)
            task.wait(0.5)
            
            -- วาง Rimuru
            fireRemote(placeRemote, "162743126:47563", Vector3.new(-607.68212890625, 0.02553214505314827, -168.1455078125), 0)
            task.wait(0.5)
            
            -- ออโต้สกิล Rimuru (อิงจาก ID: 107)
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerToggleAutoAbility"), "107")
            task.wait(0.5)
            
            -- วาง Dragon Gree
            fireRemote(placeRemote, "__rs__Shenron", Vector3.new(-619.9423828125, 0.025577858090400696, -177.84864807128906), 0)
            task.wait(0.5)
            
            -- วาง Red Dragon
            fireRemote(placeRemote, "162743126:41308", Vector3.new(-596.717529296875, 3.025526762008667, -160.88565063476562))
            task.wait(0.5)
            
            -- วาง Goku (ตามโค้ดเดิมใช้ Args ซ้ำกับ Red Dragon)
            fireRemote(placeRemote, "162743126:41308", Vector3.new(-596.717529296875, 3.025526762008667, -160.88565063476562))
            
            -- หน่วงเวลา 2 วิก่อนรีลูป ป้องกันเกมแจ้งเตือน Spam/Lag
            task.wait(2)
            
            -- ยิง Replay ค้างไว้ตลอดเวลา เมื่อเกมจบมันจะ Replay ให้ทันที
            fireRemote(RS:WaitForChild("Modules"):WaitForChild("GlobalInit"):WaitForChild("RemoteEvents"):WaitForChild("PlayerVoteReplay"))
        end
    end
end)
