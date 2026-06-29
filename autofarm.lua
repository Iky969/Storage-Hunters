-- Memuat Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ==========================================
-- SETUP WINDOW, DISCORD, & KEY SYSTEM
-- ==========================================
-- Di sinilah tempat kamu menambahkan Discord dan Key System
local Window = Rayfield:CreateWindow({
   Name = "Storage Hunters",
   LoadingTitle = "Memuat Script...",
   LoadingSubtitle = "Auto Farm & Teleport",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = true, -- Ubah menjadi true untuk mengaktifkan
      Invite = "https://discord.gg/6wvR6AcRS", -- Masukkan kode invite Discord kamu di sini (misal: abcdefg)
      RememberJoins = true 
   },
   KeySystem = true, -- Ubah menjadi true untuk mengaktifkan sistem Key
   KeySettings = {
      Title = "Storage Hunters Key",
      Subtitle = "Masukkan Key untuk mengakses",
      Note = "Key bisa didapatkan di server Discord kami",
      FileName = "StorageHuntersKey",
      SaveKey = true,
      GrabKeyFromSite = false, -- Ubah ke true jika key kamu taruh di link (misal raw pastebin)
      Key = {"Reza"} -- Ganti "KeyRahasia123" dengan password/key yang kamu mau
   }
})

-- Membuat Tab Menu
local Tab = Window:CreateTab("Menu Utama", 4483345998)

-- ==========================================
-- FUNGSI TELEPORT UTAMA
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

-- Variabel untuk menyimpan pilihan sementara
local currentSelectedArea = nil
local currentSelectedNPC = nil

-- Dropdown Area
Tab:CreateDropdown({
   Name = "Pilih Area Lelang",
   Options = {"Back Alley", "Farmyard", "Junk Yard", "Shipyard", "Shopping Mall"},
   CurrentOption = {"Pilih Area"},
   MultipleOptions = false,
   Flag = "DropdownArea",
   Callback = function(Option)
       currentSelectedArea = Option[1] -- Hanya menyimpan pilihan, tidak langsung TP
   end,
})

-- Tombol Eksekusi TP Area
Tab:CreateButton({
   Name = "🚀 Teleport ke Area Terpilih",
   Callback = function()
       if not currentSelectedArea or currentSelectedArea == "Pilih Area" then
           Rayfield:Notify({Title = "Peringatan", Content = "Pilih area terlebih dahulu di menu atas!", Duration = 3})
           return
       end
       
       local areasFolder = workspace:FindFirstChild("Areas")
       if areasFolder and areasFolder:FindFirstChild(currentSelectedArea) then
           local targetBoundary = areasFolder[currentSelectedArea]:FindFirstChild("AreaBoundary")
           if targetBoundary then
               local success = teleportTo(targetBoundary)
               if success then
                   Rayfield:Notify({Title = "Sukses", Content = "TP ke Area: " .. currentSelectedArea, Duration = 2})
               end
           else
               Rayfield:Notify({Title = "Error", Content = "AreaBoundary tidak ditemukan di " .. currentSelectedArea, Duration = 3})
           end
       else
           Rayfield:Notify({Title = "Error", Content = "Folder Area tidak ditemukan!", Duration = 3})
       end
   end,
})

Tab:CreateDivider() -- Garis pemisah agar UI lebih rapi

-- Dropdown NPC
Tab:CreateDropdown({
   Name = "Pilih NPC Toko",
   Options = {"Quest NPC", "Barrista", "Car Dealer", "Cleaning Shop", "Fashion", "Fashion Shop", "Grading Shop", "Locksmith", "Repair Shop", "Rick Harrison", "Trailer Seller"},
   CurrentOption = {"Pilih NPC"},
   MultipleOptions = false,
   Flag = "DropdownNPC",
   Callback = function(Option)
       currentSelectedNPC = Option[1] -- Hanya menyimpan pilihan, tidak langsung TP
   end,
})

-- Tombol Eksekusi TP NPC
Tab:CreateButton({
   Name = "🚀 Teleport ke NPC Terpilih",
   Callback = function()
       if not currentSelectedNPC or currentSelectedNPC == "Pilih NPC" then
           Rayfield:Notify({Title = "Peringatan", Content = "Pilih NPC terlebih dahulu di menu atas!", Duration = 3})
           return
       end
       
       local npcFolder = workspace:FindFirstChild("Mall - Shop NPCs")
       if npcFolder and npcFolder:FindFirstChild(currentSelectedNPC) then
           local targetNPC = npcFolder[currentSelectedNPC]
           local success = teleportTo(targetNPC)
           if success then
               Rayfield:Notify({Title = "Sukses", Content = "TP ke NPC: " .. currentSelectedNPC, Duration = 2})
           end
       else
           Rayfield:Notify({Title = "Error", Content = "NPC " .. currentSelectedNPC .. " tidak ditemukan!", Duration = 3})
       end
   end,
})

Tab:CreateDivider()

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
                       teleportTo(item)
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
           teleportTo(unpackZone.Pad)
           Rayfield:Notify({Title = "Sukses", Content = "Berada di zona Unpack. Silakan bongkar barang.", Duration = 3})
       else
           Rayfield:Notify({Title = "Error", Content = "UnpackZone / Pad tidak ditemukan!", Duration = 3})
       end
   end,
})
