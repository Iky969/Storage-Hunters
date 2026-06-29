-- Memuat Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Membuat Window UI
local Window = Rayfield:CreateWindow({
   Name = "Storage Hunters",
   LoadingTitle = "Memuat Script...",
   LoadingSubtitle = "Auto Farm & Teleport",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

-- Membuat Tab Menu (Hanya 1 Tab agar UI tidak bug)
local Tab = Window:CreateTab("Menu Utama", 4483345998)

-- ==========================================
-- FUNGSI TELEPORT UTAMA (Bisa untuk jalan kaki & di mobil)
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

-- ==========================================
-- BAGIAN 1: MENU TELEPORT
-- ==========================================
Tab:CreateSection("Lokasi & Teleport")

Tab:CreateDropdown({
   Name = "TP ke Area Lelang",
   Options = {"Back Alley", "Farmyard", "Junk Yard", "Shipyard", "Shopping Mall"},
   CurrentOption = {"Pilih Area"},
   MultipleOptions = false,
   Flag = "TPArea",
   Callback = function(Option)
       local selectedArea = Option[1]
       if selectedArea == "Pilih Area" then return end
       
       local areasFolder = workspace:FindFirstChild("Areas")
       if areasFolder and areasFolder:FindFirstChild(selectedArea) then
           local targetBoundary = areasFolder[selectedArea]:FindFirstChild("AreaBoundary")
           if targetBoundary then
               local success = teleportTo(targetBoundary)
               if success then
                   Rayfield:Notify({Title = "Sukses", Content = "TP ke Area: " .. selectedArea, Duration = 2})
               end
           else
               Rayfield:Notify({Title = "Error", Content = "AreaBoundary tidak ditemukan di " .. selectedArea, Duration = 3})
           end
       else
           Rayfield:Notify({Title = "Error", Content = "Folder Area tidak ditemukan!", Duration = 3})
       end
   end,
})

Tab:CreateDropdown({
   Name = "TP ke NPC Toko",
   Options = {"Quest NPC", "Barrista", "Car Dealer", "Cleaning Shop", "Fashion", "Fashion Shop", "Grading Shop", "Locksmith", "Repair Shop", "Rick Harrison", "Trailer Seller"},
   CurrentOption = {"Pilih NPC"},
   MultipleOptions = false,
   Flag = "TPNPC",
   Callback = function(Option)
       local selectedNPC = Option[1]
       if selectedNPC == "Pilih NPC" then return end
       
       local npcFolder = workspace:FindFirstChild("Mall - Shop NPCs")
       if npcFolder and npcFolder:FindFirstChild(selectedNPC) then
           local targetNPC = npcFolder[selectedNPC]
           local success = teleportTo(targetNPC)
           if success then
               Rayfield:Notify({Title = "Sukses", Content = "TP ke NPC: " .. selectedNPC, Duration = 2})
           end
       else
           Rayfield:Notify({Title = "Error", Content = "NPC " .. selectedNPC .. " tidak ditemukan!", Duration = 3})
       end
   end,
})

Tab:CreateButton({
   Name = "Teleport ke Plot 1 (Asphalt Floor)",
   Callback = function()
       local plotFolder = workspace:FindFirstChild("_Plots")
       if plotFolder and plotFolder:FindFirstChild("Plot1") then
           local structures = plotFolder.Plot1:FindFirstChild("Structures")
           if structures and structures:FindFirstChild("Asphalt Floor") then
               local targetFloor = structures["Asphalt Floor"]
               local success = teleportTo(targetFloor)
               if success then
                   Rayfield:Notify({Title = "Sukses", Content = "Berhasil TP ke Asphalt Floor (Plot 1)", Duration = 2})
               end
           else
               Rayfield:Notify({Title = "Error", Content = "Asphalt Floor tidak ditemukan!", Duration = 3})
           end
       else
           Rayfield:Notify({Title = "Error", Content = "Folder _Plots/Plot1 tidak ditemukan!", Duration = 3})
       end
   end,
})

-- ==========================================
-- BAGIAN 2: MENU AUTO FARM
-- ==========================================
Tab:CreateSection("Auto Farm Lelang")

local getAutoBid = false
Tab:CreateToggle({
   Name = "Auto Bid Lelang",
   CurrentValue = false,
   Flag = "AutoBidToggle",
   Callback = function(Value)
       getAutoBid = Value
       if getAutoBid then
           Rayfield:Notify({Title = "Auto Bid", Content = "Auto Bid DIAKTIFKAN", Duration = 2})
           task.spawn(function()
               while getAutoBid do
                   task.wait(0.1)
                   pcall(function()
                       game:GetService("ReplicatedStorage").Events.Auction.Bid:FireServer()
                   end)
               end
           end)
       else
           Rayfield:Notify({Title = "Auto Bid", Content = "Auto Bid DIMATIKAN", Duration = 2})
       end
   end,
})

Tab:CreateButton({
   Name = "Auto Collect Hasil Lelang",
   Callback = function()
       local carryables = workspace:FindFirstChild("_Carryables")
       if carryables then
           local items = carryables:GetChildren()
           if #items == 0 then
               Rayfield:Notify({Title = "Info", Content = "Tidak ada barang di area ini.", Duration = 2})
               return
           end
           
           Rayfield:Notify({Title = "Auto Collect", Content = "Mengambil " .. #items .. " barang...", Duration = 2})
           
           for _, item in pairs(items) do
               if item:IsA("Model") or item:IsA("BasePart") then
                   local prompt = item:FindFirstChildWhichIsA("ProximityPrompt", true)
                   if prompt then
                       -- Cukup gunakan fungsi teleportTo ke item tersebut
                       teleportTo(item)
                       
                       -- Tunggu sebentar agar server mendaftarkan posisi baru
                       task.wait(0.2)
                       fireproximityprompt(prompt)
                       task.wait(0.1)
                   end
               end
           end
           Rayfield:Notify({Title = "Selesai", Content = "Semua barang berhasil dikumpulkan!", Duration = 2})
       else
           Rayfield:Notify({Title = "Error", Content = "Folder _Carryables tidak ditemukan.", Duration = 3})
       end
   end,
})

Tab:CreateButton({
   Name = "TP ke Base (Unpack Zone)",
   Callback = function()
       local unpackZone = workspace:FindFirstChild("UnpackZone")
       if unpackZone and unpackZone:FindFirstChild("Pad") then
           -- Langsung teleport ke Pad
           teleportTo(unpackZone.Pad)
           Rayfield:Notify({Title = "Sukses", Content = "Berada di zona Unpack. Silakan bongkar barang.", Duration = 3})
       else
           Rayfield:Notify({Title = "Error", Content = "UnpackZone / Pad tidak ditemukan!", Duration = 3})
       end
   end,
})
