local module = {}

module.new = function()
	local self = {}
	
	return setmetatable(module, self)
end

module.RenderLaser = function(Viewmodel)
	local Player = game.Players.LocalPlayer
	local Mouse = Player:GetMouse()
	
	local Part = Instance.new("Part")
	Part.Size = Vector3.new(0.1,0.1,0.1)
	Part.Transparency = 1
	Part.Parent = workspace
	Part.Anchored = true
	Part.CanCollide = false
	
	local Attachment = Instance.new("Attachment",Part)
	Viewmodel:WaitForChild("Hands"):FindFirstChild("Laser"):FindFirstChild("Beam").Attachment1 = Attachment
	Mouse.Move:Connect(function()
		if not Part then return end
		Part.Position = Mouse.Hit.p
	end)
	
	return Part
end

return module
