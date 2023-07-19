local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ACFMRS = ReplicatedStorage:WaitForChild("ACFM")
local Guns = ACFMRS:WaitForChild("Guns")
local Player = game:GetService('Players').LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local Framework = {
	Viewmodel = nil;
	SettingsModule = nil;
	AnimationsModule = nil;
}

local HoldTrack
local SafetyTrack

local Mouse = Player:GetMouse()

local function Load(t)
	for i,v in ipairs(game.Workspace.Camera:GetChildren()) do if v:IsA("Model") then v:Destroy() end end
	Guns:FindFirstChild(t.Name):Clone().Parent = workspace.Camera
	Framework.Viewmodel = workspace.Camera:FindFirstChild(t.Name)
	Framework.SettingsModule = require(t:FindFirstChild("ACFM_Module"):FindFirstChild("Settings"))
	Framework.AnimationsModule = require(t:FindFirstChild("ACFM_Module"):FindFirstChild("Animations"))
	script.Parent.HumanoidCamera.Enabled = true
	script.Parent.HumanoidCamera.Tilt.Enabled = true
	ACFMRS:FindFirstChild("setup"):FireServer(t.Name)
	
	local CreatedAnims = script.Parent:WaitForChild("CreatedAnims")
	if not CreatedAnims:FindFirstChild(t.Name.."/HOLD") and not CreatedAnims:FindFirstChild(t.Name.."/SAFETY") then
		local NewAnim = Instance.new("Animation",script.Parent:WaitForChild("CreatedAnims"))
		NewAnim.Name = t.Name.."/HOLD"
		NewAnim.AnimationId = Framework.AnimationsModule.Hold
		
		local NewAnim1 = Instance.new("Animation",script.Parent:WaitForChild("CreatedAnims"))
		NewAnim1.Name = t.Name.."/SAFETY"
		NewAnim1.AnimationId = Framework.AnimationsModule.Safety
		
		local Animator = Character:WaitForChild("Humanoid"):WaitForChild("Animator")
		HoldTrack = Animator:LoadAnimation(NewAnim)
		SafetyTrack = Animator:LoadAnimation(NewAnim1)
		
		HoldTrack:Play()
	end
end

local Spring = require(script:WaitForChild('Spring'))

local SwaySpring = Spring.new()
local BobSpring = Spring.new()

local function Bob(addition)
	return math.sin(tick() * addition * 1.3) * 0.5
end

local Aim = false
local AimCF = CFrame.new()

local Running = false
local RunningCF = CFrame.new()

local Shooting = false
local ShootCF = CFrame.new()

local RecoilCF = CFrame.new()

local speed = 1.5
local intensity = 4
local smoothness = 0.2

local Safety = false

local LeaningQ = false
local LeaningE = false
local LeanCF = CFrame.new()

local LaserEnabled = false

local SafetyOnText = "Safety is <font color='rgb(86, 255, 35)'>ON</font>"
local SafetyOffText = "Safety is <font color='rgb(255, 0, 4)'>OFF</font>"

local function Unload()
	for i,v in ipairs(game.Workspace.Camera:GetChildren()) do if v:IsA("Model") then v:Destroy() end end
	Framework.Viewmodel = nil
	Framework.SettingsModule = nil
	Framework.AnimationsModule = nil
	Safety = false
	LeaningE = false
	LeaningQ = false
	Shooting = false
	Running = false
	Aim = false
	LaserEnabled = false
	
	HoldTrack:Stop()
	SafetyTrack:Stop()
	
	SafetyTrack = nil
	HoldTrack = nil
	
	LeanCF = CFrame.new()
	AimCF = CFrame.new()
	RecoilCF = CFrame.new()
	ShootCF = CFrame.new()
	RunningCF = CFrame.new()
	script.Parent.HumanoidCamera.Enabled = false
	script.Parent.HumanoidCamera.Tilt.Enabled = false
end

local PlayerGui = Player:WaitForChild("PlayerGui")
local HUD = PlayerGui:WaitForChild("HUD")
local Notifs = HUD:WaitForChild("Notifs")
local Template = HUD:WaitForChild("TextLabel")

local function CreateMessage(tyt)
	local c = Template:Clone()
	c.Parent = Notifs
	c.Text = tyt
end

local SafetyCF = CFrame.new()

local LaserModule = require(ACFMRS:FindFirstChild("Laser"))


local FpsValue = script.Parent.FPS

local TimeFunction = RunService:IsRunning() and time or os.clock

local LastIteration, Start
local FrameUpdateTable = {}

local function HeartbeatUpdate()
	LastIteration = TimeFunction()
	for Index = #FrameUpdateTable, 1, -1 do
		FrameUpdateTable[Index + 1] = FrameUpdateTable[Index] >= LastIteration - 1 and FrameUpdateTable[Index] or nil
	end

	FrameUpdateTable[1] = LastIteration
	FpsValue.Value = tostring(math.floor(TimeFunction() - Start >= 1 and #FrameUpdateTable or #FrameUpdateTable / (TimeFunction() - Start)))
end

Start = TimeFunction()
RunService.Heartbeat:Connect(HeartbeatUpdate)

RunService.RenderStepped:Connect(function(dt)
	if Framework.Viewmodel and Framework.SettingsModule and Framework.AnimationsModule and workspace.Camera:FindFirstChild(Framework.Viewmodel.Name) then
		local Delta = game.UserInputService:GetMouseDelta()

		SwaySpring:shove(Vector3.new(-Delta.X/500, Delta.Y/500, 0))
		if Running then
			BobSpring:shove(Vector3.new(Bob(10), Bob(15), Bob(10)) / 10 * (Character.PrimaryPart.Velocity.Magnitude) / 10)
		else
			BobSpring:shove(Vector3.new(Bob(5), Bob(10), Bob(5)) / 10 * (Character.PrimaryPart.Velocity.Magnitude) / 10)
		end

		local UpdatedSway = SwaySpring:update(dt)
		local UpdatedBob = BobSpring:update(dt)
		
		if Framework.AnimationsModule.AimType == "sideways" then
			if Aim == false then
				AimCF = AimCF:Lerp(CFrame.new(0,0,0) * CFrame.Angles(0,0,0), .2)
			else
				local a = (script.Parent.FPS.Value / 10) * 10
				local b = a + 10
				local fps = (if script.Parent.FPS.Value-a>b-script.Parent.FPS.Value then b else a)
				AimCF = AimCF:Lerp(Framework.AnimationsModule.AimCF, Framework.SettingsModule.AimSmooth)
			end
		elseif Framework.AnimationsModule.AimType == "aimpart" then
			if Aim == false then
				AimCF = AimCF:Lerp(CFrame.new(0,0,0) * CFrame.Angles(0,0,0),.2)
			else
				local a = (script.Parent.FPS.Value / 10) * 10
				local b = a + 10
				local fps = (if script.Parent.FPS.Value-a>b-script.Parent.FPS.Value then b else a)
				local Dist = Framework.Viewmodel.GunModel.AimPart.CFrame:ToObjectSpace(Framework.Viewmodel.PrimaryPart.CFrame)
				AimCF = AimCF:Lerp(Dist, Framework.SettingsModule.AimSmooth / fps)			
			end
		end

		if Running == false then
			RunningCF = RunningCF:Lerp(CFrame.new(0,0,0) * CFrame.Angles(0,0,0),.05)
		else
			RunningCF = RunningCF:Lerp(Framework.AnimationsModule.RunCF,.1)
		end

		if Safety == false then
			SafetyCF = SafetyCF:Lerp(CFrame.new(0,0,0) * CFrame.Angles(0,0,0),.05)
		else
			SafetyCF = SafetyCF:Lerp(Framework.AnimationsModule.SafetyCF,.1)
		end
		
		if Shooting == false and Framework.SettingsModule.FireMode == "Auto" then
			ShootCF = ShootCF:Lerp(CFrame.new(0,0,0) * CFrame.Angles(0,0,0),.2)
			RecoilCF = RecoilCF:Lerp(CFrame.new(0,0,0) * CFrame.Angles(0,0,0),.2)
		elseif Shooting == true and Framework.SettingsModule.FireMode == "Auto" then
			RecoilCF = RecoilCF:Lerp(CFrame.Angles(math.rad(0.2),0,0),0.1):Lerp(CFrame.Angles(math.rad(0.2),0,0),0.1)
			ShootCF = ShootCF:Lerp(CFrame.new(0,0,0.52) * CFrame.Angles(math.rad(math.random(.04,.2)),math.rad(math.random(0.04,.3)),math.rad(math.random(0.07,.4))), .2)
		end
		
		if Shooting == false and Framework.SettingsModule.FireMode == "Semi" then
			ShootCF = ShootCF:Lerp(CFrame.new(0,0,0) * CFrame.Angles(0,0,0),.2)
			RecoilCF = RecoilCF:Lerp(CFrame.new(0,0,0) * CFrame.Angles(0,0,0),.2)
		elseif Shooting == true and Framework.SettingsModule.FireMode == "Semi" then
			RecoilCF = RecoilCF:Lerp(CFrame.Angles(math.rad(0.2),0,0),0.1):Lerp(CFrame.Angles(math.rad(0.2),0,0),0.1)
			ShootCF = ShootCF:Lerp(CFrame.new(0,0,0.52) * CFrame.Angles(math.rad(math.random(.04,.2)),math.rad(math.random(0.04,.3)),math.rad(math.random(0.07,.4))), .2)
			task.wait(0.01)
			ShootCF = ShootCF:Lerp(CFrame.new(0,0,0) * CFrame.Angles(0,0,0),.2)
			RecoilCF = RecoilCF:Lerp(CFrame.new(0,0,0) * CFrame.Angles(0,0,0),.2)
		end
		
		if LeaningQ == false then
			LeanCF = LeanCF:Lerp(CFrame.Angles(0,0,0),.4)
		else
			LeanCF = LeanCF:Lerp(CFrame.new(-6.2,0,0)*CFrame.Angles(0,0,math.rad(80)), .1)
		end
		
		if LeaningE == false then
			LeanCF = LeanCF:Lerp(CFrame.Angles(0,0,0),.4)
		else
			LeanCF = LeanCF:Lerp(CFrame.new(6.2,0,0)*CFrame.Angles(0,0,math.rad(-80)), .1)
		end
		
		
		local ViewmodelCam = workspace.Camera:FindFirstChild(Framework.Viewmodel.Name)
		workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame * RecoilCF * LeanCF
		local Goal = workspace.CurrentCamera.CFrame *  CFrame.new(0.3,-1.4,1.4)*CFrame.new(UpdatedSway.X, UpdatedSway.Y, 0) *CFrame.new(UpdatedBob.X, UpdatedBob.Y, 0) *AimCF*RunningCF*ShootCF*SafetyCF
		--local Goal = workspace.CurrentCamera.CFrame *  CFrame.new(0.3,-1.4,1.4) *RunningCF*ShootCF*SafetyCF*AimCF

		ViewmodelCam:SetPrimaryPartCFrame(Goal)
	end
end)
local mouse = Mouse

local function onUpdate(dt)
	ACFMRS.tiltAt:FireServer(math.asin(workspace.CurrentCamera.CFrame.LookVector.y));
end
RunService.RenderStepped:Connect(onUpdate)

local function Shoot()
	local Bullet = game:GetService("ReplicatedStorage"):WaitForChild("Bullet"):Clone()
	Bullet.Color = Color3.new (1, 0.8, 0)
	Bullet. Material = Enum. Material. Neon
	Bullet.Parent = game. Workspace
	pcall(function()
		Bullet.CFrame = CFrame.new(workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Position, Mouse.Hit.p)
	end)
	local Loop=game: GetService ("RunService").RenderStepped: Connect(function(dt)
		pcall(function()
			Bullet.CFrame *= CFrame.new(0, 0, -600 * dt)
			Bullet.Touched:Connect(function(Part)
				ACFMRS:FindFirstChild("Fire"):FireServer(Part)
			end)
			if (Bullet. Position - workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart. Position).magnitude > 5000 then
				Bullet:Destroy()
			end
		end)
	end)
	
	Framework.SettingsModule.Ammo = Framework.SettingsModule.Ammo - 1
	
	local p = Instance.new("Part")
	p.formFactor = "Custom"
	p.Size = Vector3.new(0.5,0.5,0.5)
	p.Transparency = 1
	p.CanCollide = false
	p.Locked = true
	p.CFrame = mouse.Target.CFrame+(mouse.Hit.p-mouse.Target.Position)
	local w = Instance.new("Weld")
	w.Part0 = mouse.Target
	w.Part1 = p
	w.C0 = mouse.Target.CFrame:inverse()
	w.C1 = p.CFrame:inverse()
	w.Parent = p
	local d = Instance.new("Decal")
	d.Parent = p
	d.Face = mouse.TargetSurface
	d.Texture = "http://www.roblox.com/asset/?id=12769915043"
	p.Parent = game.Workspace
	script:FindFirstChild("BI"):Clone().Parent = p
	p:FindFirstChildWhichIsA("Sound"):Play()

	workspace.CurrentCamera[Framework.Viewmodel.Name].Hands:WaitForChild("Primary")["Fire"]:Play()
	workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Chamber.Shell.Enabled = true
	workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Chamber.Smoke.Enabled = true
	workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Muzzle.FlashFX.Enabled = true
	workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Muzzle["FlashFX[Flash]"].Enabled = true
	workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Muzzle["Smoke"].Enabled = true
	task.wait(Framework.SettingsModule.FireRate)
	workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Chamber.Shell.Enabled = false
	workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Chamber.Smoke.Enabled = false
	workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Muzzle.FlashFX.Enabled = false
	workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Muzzle["FlashFX[Flash]"].Enabled = false
	workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Muzzle["Smoke"].Enabled = false
	task.wait(0.01)
end

local Ignored = {
	["Handle"] = true;
	["AimPart"] = true;
	["Torso"] = true;
	["Primary"] = true;
}

local part

local UIS = game:GetService("UserInputService")
UIS.InputBegan:Connect(function(inp,gp)
	if inp.UserInputType == Enum.UserInputType.MouseButton2 and not Running and Framework.Viewmodel and not Safety and not gp then
		Aim = true
		game:GetService("TweenService"):Create(game.Workspace.CurrentCamera,TweenInfo.new(0.2),{FieldOfView = 63}):Play()
	elseif inp.KeyCode == Enum.KeyCode.LeftShift and Framework.Viewmodel and not Safety and not gp then
		Running = true
		Aim = false
		HoldTrack:Stop()
		SafetyTrack:Play()
		Character.Humanoid.WalkSpeed = 18
		game:GetService("TweenService"):Create(game.Workspace.CurrentCamera,TweenInfo.new(0.2),{FieldOfView = 72}):Play()
	elseif inp.UserInputType == Enum.UserInputType.MouseButton1 and Framework.Viewmodel and not Safety and not gp and not Running and Framework.SettingsModule.Ammo > 0 then
		Shooting = true
		if Framework.SettingsModule.FireMode == "Auto" then
			while Shooting do
				Shoot()
			end
		elseif Framework.SettingsModule.FireMode == "Semi" then
			Shoot()
		end
	elseif inp.KeyCode == Enum.KeyCode.Q and LeaningE == false and LeaningQ == false then
		LeaningQ = true
	elseif inp.KeyCode == Enum.KeyCode.E and LeaningE == false and LeaningQ == false then
		LeaningE = true
	elseif inp.KeyCode == Enum.KeyCode.V and not Aim then
		Safety = not Safety
		if Safety == false then
			SafetyTrack:Stop()
			HoldTrack:Play()
			game.Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
			for i,v in ipairs(workspace.CurrentCamera:FindFirstChildWhichIsA("Model"):GetDescendants()) do
				pcall(function()
					if not Ignored[v.Name] then
						v.Transparency = 0
					end
				end)
			end
			CreateMessage(SafetyOffText)
		else
			HoldTrack:Stop()
			SafetyTrack:Play()
			game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
			for i,v in ipairs(workspace.CurrentCamera:FindFirstChildWhichIsA("Model"):GetDescendants()) do
				pcall(function()
					if v.Transparency ~= 1 and not Ignored[v.Name] then
						v.Transparency = 1
					end
				end)
			end
			CreateMessage(SafetyOnText)
		end
	elseif inp.KeyCode == Enum.KeyCode.K and not Running and Framework.Viewmodel and game.Workspace.Camera:FindFirstChild(Framework.Viewmodel.Name):FindFirstChild("Hands"):FindFirstChild("Laser") and Framework.SettingsModule.LaserEnabled == true then
		if LaserEnabled == false then
			LaserEnabled = true
			part = LaserModule.RenderLaser(game.Workspace.Camera:FindFirstChild(Framework.Viewmodel.Name))
		else
			LaserEnabled = false
			part:Destroy()
			part = nil
		end
	elseif inp.KeyCode == Enum.KeyCode.R then
		Framework.SettingsModule.Ammo = Framework.SettingsModule.MaxAmmo
	end
end)


UIS.InputEnded:Connect(function(inp,gp)
	if inp.UserInputType == Enum.UserInputType.MouseButton2 and not Running and Framework.Viewmodel and not gp then
		Aim = false
		game:GetService("TweenService"):Create(game.Workspace.CurrentCamera,TweenInfo.new(0.2),{FieldOfView = 70}):Play()
	elseif inp.KeyCode == Enum.KeyCode.LeftShift and Framework.Viewmodel and not Safety and not Aim and not gp then
		Running = false
		SafetyTrack:Stop()
		HoldTrack:Play()
		Character.Humanoid.WalkSpeed = 11
		game:GetService("TweenService"):Create(game.Workspace.CurrentCamera,TweenInfo.new(0.2),{FieldOfView = 70}):Play()
	elseif inp.UserInputType == Enum.UserInputType.MouseButton1 and Framework.Viewmodel and not gp and not Running then
		workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Chamber.Shell.Enabled = false
		workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Chamber.Smoke.Enabled = false
		workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Muzzle.FlashFX.Enabled = false
		workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Muzzle["FlashFX[Flash]"].Enabled = false
		workspace.CurrentCamera[Framework.Viewmodel.Name].GunModel.ShootPart.Muzzle["Smoke"].Enabled = false
		Shooting = false
	elseif inp.KeyCode == Enum.KeyCode.Q and LeaningQ == true then
		LeaningQ = false
	elseif inp.KeyCode == Enum.KeyCode.E and LeaningE == true then
		LeaningE = false	
	end
end)

Character.ChildAdded:Connect(function(c)
	if c:FindFirstChild("ACFM_Module") then
		game.Players.LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
		Load(c)
	end
end)

Character.ChildRemoved:Connect(function(c)
	if c:FindFirstChild("ACFM_Module") then
		if Framework.Viewmodel.Name == c.Name then
			game.Players.LocalPlayer.CameraMode = Enum.CameraMode.Classic
			Unload()
		end
	end
end)
