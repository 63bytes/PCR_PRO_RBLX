local mod = require(game.ServerScriptService.PCR.PCR_MAIN)

local pressed = false
local up = script.Parent.up.SurfaceGui.TextButton
local down = script.Parent.down.SurfaceGui.TextButton

up.MouseButton1Down:Connect(function()
	pressed = true
	while pressed and mod.piFuelInput[4]<100 do
		mod.piFuelInput[4] += 1
		wait(0.1)
	end
end)

up.MouseButton1Up:Connect(function()
	pressed = false
end)

down.MouseButton1Down:Connect(function()
	pressed = true
	while pressed and mod.piFuelInput[4]>0 do
		mod.piFuelInput[4] -= 1
		wait(0.1)
	end
end)

down.MouseButton1Up:Connect(function()
	pressed = false
end)