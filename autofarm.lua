
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Storage Hunters",
   LoadingTitle = "Loading Script...",
   LoadingSubtitle = "Auto Farm Hub",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

local Tab = Window:CreateTab("Main Menu", 4483345998)

-- ==========================================
-- FLOATING UI UNTUK AUTO FARM INFO
-- ==========================================
local CoreGui = game:GetService("CoreGui")
local infoUI = Instance.new("ScreenGui")
infoUI.Name = "AutoFarmTracker"
infoUI.Parent = CoreGui
infoUI.Enabled = false

local bgFrame = Instance.new("Frame", infoUI)
bgFrame.Size = UDim2.new(0, 250, 0, 90)
bgFrame.Position = UDim2.new(0.5, -125, 0, 20)
bgFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
bgFrame.BorderSizePixel = 0

local uiCorner = Instance.new("UICorner", bgFrame)
uiCorner.CornerRadius = UDim.new(0, 8)

local titleLabel = Instance.new("TextLabel", bgFrame)
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Text = "Auto Farm Active"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16

local statusLabel = Instance.new("TextLabel", bgFrame)
statusLabel.Size = UDim2.new(1, -20, 1, -40)
statusLabel.Position = UDim2.new(0, 10, 0, 35)
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
statusLabel.BackgroundTransparency = 1
statusLabel.TextWrapped = true
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 14
statusLabel.TextYAlignment = Enum.TextYAlignment.Top

local function updateStatus(text)
    statusLabel.Text = "Status: " .. text
end

-- ==========================================
-- FUNGSI BANTUAN UTAMA
-- ==========================================
local function teleportTo(targetInstance)
    if not targetInstance then return false end
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    if hrp then
        if targetInstance:IsA("BasePart") then
            hrp.CFrame = targetInstance.CFrame + Vector3.new(0, 4, 0)
            return true
        elseif targetInstance:IsA("Model") then
            if targetInstance.PrimaryPart then
                hrp.CFrame = targetInstance.PrimaryPart.CFrame + Vector3.new(0, 4, 0)
                return true
            elseif targetInstance:FindFirstChild("HumanoidRootPart") then
                hrp.CFrame = targetInstance.HumanoidRootPart.CFrame + Vector3.new(0, 4, 0)
                return true
            else
                hrp.CFrame = targetInstance:GetPivot() + Vector3.new(0, 4, 0)
                return true
            end
        end
    end
    return false
end

local function autoEnterCar()
    local keiTruck = nil
    for _, v in pairs(workspace:GetChildren()) do
        if string.find(v.Name, "Kei Truck") then
            keiTruck = v
            break
        end
    end
    
    if keiTruck and keiTruck:FindFirstChild("DriveSeat") then
        local driveSeat = keiTruck.DriveSeat
        local player = game.Players.LocalPlayer
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChild("Humanoid")
        
        if hrp and humanoid then
            hrp.CFrame = driveSeat.CFrame
            task.wait(0.3)
            driveSeat:Sit(humanoid)
        end
    end
end

-- ==========================================
-- BAGIAN 1: MENU LOKASI & TELEPORT MANUAL
-- ==========================================
Tab:CreateSection("Locations & Teleport")

local currentSelectedArea = nil
local currentSelectedNPC = nil

Tab:CreateDropdown({
   Name = "Select Teleport Area",
   Options = {"Back Alley", "Farmyard", "Junk Yard", "Shipyard", "Shopping Mall"},
   CurrentOption = {"Select Area"},
   MultipleOptions = false,
   Flag = "DropdownTPArea",
   Callback = function(Option)
       currentSelectedArea = Option[1] 
   end,
})

Tab:CreateButton({
   Name = "Teleport to Area",
   Callback = function()
       if not currentSelectedArea or currentSelectedArea == "Select Area" then return end
       local areasFolder = workspace:FindFirstChild("Areas")
       if areasFolder and areasFolder:FindFirstChild(currentSelectedArea) then
           local targetBoundary = areasFolder[currentSelectedArea]:FindFirstChild("AreaBoundary")
           teleportTo(targetBoundary)
       end
   end,
})

Tab:CreateDropdown({
   Name = "Select Shop NPC",
   Options = {"Quest NPC", "Barrista", "Car Dealer", "Cleaning Shop", "Fashion", "Fashion Shop", "Grading Shop", "Locksmith", "Repair Shop", "Rick Harrison", "Trailer Seller"},
   CurrentOption = {"Select NPC"},
   MultipleOptions = false,
   Flag = "DropdownNPC",
   Callback = function(Option)
       currentSelectedNPC = Option[1] 
   end,
})

Tab:CreateButton({
   Name = "Teleport to NPC",
   Callback = function()
       if not currentSelectedNPC or currentSelectedNPC == "Select NPC" then return end
       local npcFolder = workspace:FindFirstChild("Mall - Shop NPCs")
       if npcFolder and npcFolder:FindFirstChild(currentSelectedNPC) then
           teleportTo(npcFolder[currentSelectedNPC])
       end
   end,
})

Tab:CreateButton({
   Name = "TP to Plot 1",
   Callback = function()
       local plotFolder = workspace:FindFirstChild("_Plots")
       if plotFolder and plotFolder:FindFirstChild("Plot1") then
           local structures = plotFolder.Plot1:FindFirstChild("Structures")
           if structures and structures:FindFirstChild("Asphalt Floor") then
               teleportTo(structures["Asphalt Floor"])
           end
       end
   end,
})

-- ==========================================
-- BAGIAN 2: AUTO FARM SYSTEM
-- ==========================================
Tab:CreateSection("Auto Farm System")

local isAutoFarming = false
local farmAreaTarget = nil

Tab:CreateDropdown({
   Name = "Select Farm Area",
   Options = {"Back Alley", "Farmyard", "Junk Yard", "Shipyard", "Shopping Mall"},
   CurrentOption = {"Select Area"},
   MultipleOptions = false,
   Flag = "DropdownFarmArea",
   Callback = function(Option)
       farmAreaTarget = Option[1] 
   end,
})

Tab:CreateToggle({
   Name = "Auto Farm Info UI",
   CurrentValue = false,
   Flag = "TrackerToggle",
   Callback = function(Value)
       infoUI.Enabled = Value
   end,
})

Tab:CreateToggle({
   Name = "Start Auto Farm",
   CurrentValue = false,
   Flag = "AutoFarmToggle",
   Callback = function(Value)
       isAutoFarming = Value
       
       if isAutoFarming then
           task.spawn(function()
               while isAutoFarming do
                   if not farmAreaTarget or farmAreaTarget == "Select Area" then
                       updateStatus("Waiting for Farm Area selection...")
                       task.wait(1)
                       continue
                   end
                   
                   -- 1. Masuk Kendaraan (Awal)
                   updateStatus("(get in the vehicle)")
                   autoEnterCar()
                   task.wait(3.5) -- Waktu tunggu ditingkatkan agar server sync
                   
                   if not isAutoFarming then break end
                   
                   -- 2. Pergi ke Area
                   updateStatus("(moving to " .. farmAreaTarget .. ")")
                   local areasFolder = workspace:FindFirstChild("Areas")
                   if areasFolder and areasFolder:FindFirstChild(farmAreaTarget) then
                       local targetBoundary = areasFolder[farmAreaTarget]:FindFirstChild("AreaBoundary")
                       teleportTo(targetBoundary)
                       task.wait(2)
                   end
                   
                   if not isAutoFarming then break end
                   
                   -- 3. Keluar dari Kendaraan
                   updateStatus("(exiting vehicle)")
                   local player = game.Players.LocalPlayer
                   local char = player.Character or player.CharacterAdded:Wait()
                   if char and char:FindFirstChild("Humanoid") then
                       char.Humanoid.Sit = false
                   end
                   task.wait(1.5)
                   
                   -- 4. Cari Garasi Terdekat (Fix Bug Model Position)
                   updateStatus("(finding nearest garage)")
                   local hrp = char:FindFirstChild("HumanoidRootPart")
                   if not hrp then task.wait(1); continue end
                   
                   local closestGarage = nil
                   local closestPrompt = nil
                   local minDistance = math.huge
                   local debris = workspace:FindFirstChild("_Debris")
                   
                   if debris and debris:FindFirstChild("Garages") then
                       for _, garage in pairs(debris.Garages:GetChildren()) do
                           local entry = garage:FindFirstChild("EntrySquare")
                           if entry then
                               local prompt = entry:FindFirstChildWhichIsA("ProximityPrompt", true)
                               if prompt and prompt.Enabled then
                                   local entryPos = entry:IsA("Model") and entry:GetPivot().Position or entry.Position
                                   local dist = (entryPos - hrp.Position).Magnitude
                                   
                                   if dist < minDistance then
                                       minDistance = dist
                                       closestGarage = entry
                                       closestPrompt = prompt
                                   end
                               end
                           end
                       end
                   end
                   
                   if not isAutoFarming then break end
                   
                   -- 5. Interaksi Garasi (Start Bid)
                   if closestGarage and closestPrompt then
                       teleportTo(closestGarage)
                       task.wait(1)
                       
                       updateStatus("(start bid)")
                       closestPrompt.RequiresLineOfSight = false
                       closestPrompt.MaxActivationDistance = 50
                       fireproximityprompt(closestPrompt)
                       task.wait(2)
                       
                       if not isAutoFarming then break end
                       
                       -- 6. Auto Bid & Tunggu Item Keluar
                       updateStatus("(auto bid)")
                       local bidTimer = 0
                       local closestGaragePos = closestGarage:IsA("Model") and closestGarage:GetPivot().Position or closestGarage.Position
                       
                       while isAutoFarming do
                           pcall(function()
                               game:GetService("ReplicatedStorage").Events.Auction.Bid:FireServer()
                           end)
                           task.wait(0.2)
                           bidTimer = bidTimer + 0.2
                           
                           local hasItems = false
                           local carryables = workspace:FindFirstChild("_Carryables")
                           if carryables then
                               for _, item in pairs(carryables:GetChildren()) do
                                   local itemPos = item:IsA("Model") and item:GetPivot().Position or item.Position
                                   if (itemPos - closestGaragePos).Magnitude < 100 then
                                       hasItems = true
                                       break
                                   end
                               end
                           end
                           
                           if hasItems or bidTimer > 60 then
                               break
                           end
                       end
                       
                       if not isAutoFarming then break end
                       
                       -- 7. Collect Items (Diulang 5x untuk sapu bersih)
                       updateStatus("(collect item)")
                       for collectPass = 1, 5 do
                           if not isAutoFarming then break end
                           
                           local carryables = workspace:FindFirstChild("_Carryables")
                           if carryables then
                               for _, item in pairs(carryables:GetChildren()) do
                                   if not isAutoFarming then break end
                                   
                                   local itemPos = item:IsA("Model") and item:GetPivot().Position or item.Position
                                   if (itemPos - closestGaragePos).Magnitude < 100 then
                                       local itemPrompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                                       if itemPrompt then
                                           teleportTo(item)
                                           task.wait(0.3)
                                           itemPrompt.RequiresLineOfSight = false
                                           fireproximityprompt(itemPrompt)
                                           task.wait(0.2)
                                       end
                                   end
                               end
                           end
                           task.wait(0.5) -- Jeda pendek antar loop sapu bersih
                       end
                       
                       if not isAutoFarming then break end
                       
                       -- 8. Masuk Kendaraan Lagi
                       updateStatus("(get in the vehicle)")
                       autoEnterCar()
                       task.wait(3.5) -- Jeda ekstra agar mobil ikut ter-teleport dengan aman
                       
                       if not isAutoFarming then break end
                       
                       -- 9. Pergi ke Base (Unpack Zone)
                       updateStatus("(go unpackzone)")
                       local unpackZone = workspace:FindFirstChild("UnpackZone")
                       if unpackZone and unpackZone:FindFirstChild("Pad") then
                           teleportTo(unpackZone.Pad)
                       end
                       
                       updateStatus("Unpacking... Restarting loop in 5s")
                       task.wait(5)
                   else
                       updateStatus("No active garage found. Retrying in 3s...")
                       task.wait(3)
                   end
               end
           end)
       else
           updateStatus("Idle")
       end
   end,
})

Tab:CreateDivider()
Tab:CreateLabel("Manual Tools (Optional)")

local getManualBid = false
Tab:CreateToggle({
   Name = "Manual Auto Bid",
   CurrentValue = false,
   Flag = "ManualBidToggle",
   Callback = function(Value)
       getManualBid = Value
       if getManualBid then
           task.spawn(function()
               while getManualBid do
                   task.wait(0.1)
                   pcall(function()
                       game:GetService("ReplicatedStorage").Events.Auction.Bid:FireServer()
                   end)
               end
           end)
       end
   end,
})

Tab:CreateButton({
   Name = "Auto Collect Items",
   Callback = function()
       local carryables = workspace:FindFirstChild("_Carryables")
       if carryables then
           for _, item in pairs(carryables:GetChildren()) do
               if item:IsA("Model") or item:IsA("BasePart") then
                   local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                   if prompt then
                       teleportTo(item)
                       task.wait(0.2)
                       prompt.RequiresLineOfSight = false
                       fireproximityprompt(prompt)
                       task.wait(0.1)
                   end
               end
           end
       end
   end,
})

Tab:CreateButton({
   Name = "Enter Vehicle",
   Callback = function()
       autoEnterCar()
   end,
})

Tab:CreateButton({
   Name = "TP to Unpack Zone",
   Callback = function()
       local unpackZone = workspace:FindFirstChild("UnpackZone")
       if unpackZone and unpackZone:FindFirstChild("Pad") then
           teleportTo(unpackZone.Pad)
       end
   end,
})
