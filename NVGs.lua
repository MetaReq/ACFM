local UIS = game:GetService("UserInputService")

local nvg_on_ambient = Color3.fromRGB(111, 204, 104)
local nvg_off_ambient = game.Lighting.Ambient
local nvg_on_OutdoorAmbient = Color3.fromRGB(91, 170, 87)
local nvg_off_OutdoorAmbient = game.Lighting.OutdoorAmbient

local nvg_on_brightness = game.Lighting.Brightness + 2
local nvg_off_brightness = game.Lighting.Brightness
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local nvg = false
UIS.InputBegan:Connect(function(Input,gp)
	if Input.KeyCode == Enum.KeyCode.N and nvg == false then
		nvg = true
		local tweenInfo = TweenInfo.new(		
			1, 
			Enum.EasingStyle.Quad, 
			Enum.EasingDirection.Out
		)

		local ambientTween = TweenService:Create(
			Lighting,
			tweenInfo,
			{
				Ambient = nvg_on_ambient
			}
		)

		local outdoorAmbientTween = TweenService:Create(
			Lighting,
			tweenInfo,
			{
				OutdoorAmbient = nvg_on_OutdoorAmbient
			}
		)

		local brightnessTween = TweenService:Create(
			Lighting,
			tweenInfo,
			{
				Brightness = nvg_on_brightness
			}
		)

		ambientTween:Play()
		outdoorAmbientTween:Play()
		brightnessTween:Play()
		game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("NVGOverlay2").Visible = true
		game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("NVGOverlay3").Visible = true
		game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("NVGOverlay").Visible = true
	elseif Input.KeyCode == Enum.KeyCode.N and nvg == true then
		nvg = false
		local tweenInfo = TweenInfo.new(		
			1, 
			Enum.EasingStyle.Quad, 
			Enum.EasingDirection.Out
		)

		local ambientTween = TweenService:Create(
			Lighting,
			tweenInfo,
			{
				Ambient = nvg_off_ambient
			}
		)

		local outdoorAmbientTween = TweenService:Create(
			Lighting,
			tweenInfo,
			{
				OutdoorAmbient = nvg_off_OutdoorAmbient
			}
		)

		local brightnessTween = TweenService:Create(
			Lighting,
			tweenInfo,
			{
				Brightness = nvg_off_brightness
			}
		)

		ambientTween:Play()
		outdoorAmbientTween:Play()
		brightnessTween:Play()
		game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("NVGOverlay2").Visible = false
		game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("NVGOverlay3").Visible = false
		game.Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("HUD"):WaitForChild("NVGOverlay").Visible = false
	end
end)
