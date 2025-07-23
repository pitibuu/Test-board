repeat task.wait() until game:IsLoaded()

if game.PlaceId ~= 139394516128799 then return end

local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
local HttpService = game:GetService("HttpService")

function DisconnectAll(connections)
	task.spawn(function()
		for _, connection in pairs(connections) do
			if connection then
				connection:Disconnect()
				connection = nil
			end
		end
	end)
end

if getgenv().Info and getgenv().Info.Connections then
	DisconnectAll(getgenv().Info.Connections)
end

getgenv().Info = {
	EngineOptions = { "Stockfish 17", "Sunfish" },
	Connections = {},
}

getgenv().Settings = {
	AutoPlay = false,
	Engine = "Stockfish 17",
}

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
	Name = "Chess club",
	Icon = 0,
	LoadingTitle = "Chess club - Otomasyon",
	LoadingSubtitle = "Mei wu",
	Theme = "Default",
	ToggleUIKeybind = "K",
	DisableRayfieldPrompts = false,
	DisableBuildWarnings = false,
	ConfigurationSaving = {
		Enabled = true,
		FolderName = nil,
		FileName = "Big Hub",
	},
	KeySystem = false,
})

function BestMove(engine)
	local selected = engine or getgenv().Settings.Engine
    repeat task.wait() until game:GetService("ReplicatedStorage").InternalClientEvents.GetActiveTableset:Invoke() ~= nil
	local FEN = game:GetService("ReplicatedStorage").InternalClientEvents.GetActiveTableset:Invoke():WaitForChild("FEN").Value
	local res

	if selected == "Stockfish 17" then
		local success, err = pcall(function()
			res = req({
				Url = "https://chess-api.com/v1",
				Method = "POST",
				Headers = { ["Content-Type"] = "application/json" },
				Body = HttpService:JSONEncode({ fen = FEN }),
			})
		end)

		if success and res and res.Success then
			local data = HttpService:JSONDecode(res.Body)
			
			return data.from, data.to
			
		else
			warn("[Motor] Stockfish isteği başarısız oldu:", err or res.StatusCode or "Bilinmeyen hata")
		end

	elseif selected == "Sunfish" then
		local ok, result = pcall(function()
			local module = require(game:GetService("Players").LocalPlayer.PlayerScripts.AI.Sunfish)
			return module:GetBestMove(FEN, 2000)
		end)

		if ok and result then
			return result
		else
			warn("[Motor] Sunfish motoru başarısız oldu:", result)
		end
	end
end

function PlayMove(engine)
	local from, to = BestMove(engine)

    task.wait()

	if from and to then
		game:GetService("ReplicatedStorage").Chess.SubmitMove:InvokeServer(from .. to)
	elseif from then
		game:GetService("ReplicatedStorage").Chess.SubmitMove:InvokeServer(from)
	else
		warn("[Hamle] Geçersiz hamle alındı. Oynatılamaz.")
		return false
	end

	return true
end

local SelectedEngine

function PlaySuccesfullMove()
	task.spawn(function()
		local outcome = PlayMove()
		local retries = 0

		while not outcome and retries < 5 do
			retries += 1
			task.wait(1)
			outcome = PlayMove()
		end

		if not outcome then
			PlayMove("Sunfish")

			Rayfield:Notify({
				Title = "Uyarı!",
				Content = "Mevcut motor API'si yanıt vermiyor. Bu hamle için Sunfish motoru kullanılıyor. Uyarı devam ederse API'leri değiştirmeyi düşünün!",
				Duration = 5,
				Image = "triangle-alert",
			})
		end
	end)
end

function AutoPlay()
	if not getgenv().Settings.AutoPlay then return end

	getgenv().Info.Connections["MoveRecieved"] = game:GetService("ReplicatedStorage").Chess.MovePlayedRemoteEvent.OnClientEvent:Connect(function(move)
		PlaySuccesfullMove()
	end)

	getgenv().Info.Connections["GameStart"] = game:GetService("ReplicatedStorage").Chess:WaitForChild("StartGameEvent").OnClientEvent:Connect(function(t1, t2)
		PlaySuccesfullMove()
	end)

	PlaySuccesfullMove()
end

local MainTab = Window:CreateTab("Ana", "code-xml")

MainTab:CreateSection("Motor API'sini Seç")

SelectedEngine = MainTab:CreateDropdown({
	Name = "Motor API'si",
	Options = getgenv().Info.EngineOptions,
	CurrentOption = getgenv().Settings.Engine,
	MultipleOptions = false,
	Flag = "SelectedEngine",
	Callback = function(Options)
		getgenv().Settings.Engine = Options[1]
	end,
})

MainTab:CreateSection("En İyi Hamleyi Oyna")

local AutoBestMove = MainTab:CreateToggle({
	Name = "En İyi Hamleleri Otomatik Oynat",
	CurrentValue = false,
	Flag = "AutoBestMove",
	Callback = function(Value)
		getgenv().Settings.AutoPlay = Value
		if Value then
			AutoPlay()
		else
			DisconnectAll(getgenv().Info.Connections)
		end
	end,
})

local PlayBestMove = MainTab:CreateButton({
	Name = "En İyi Hamleyi Oyna",
	Callback = function()
		PlayMove()
	end,
})
