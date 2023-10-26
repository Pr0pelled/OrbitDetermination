local RunService = game:GetService("RunService")
--Requiring gravity to initiate its function
require(script:WaitForChild("gravity"))
local orbitDeterminer = require(script:WaitForChild("orbitDeterminer"))
local orbitDrawer = require(script:WaitForChild("orbitDrawer"))

--Bodies
local Big: Part = workspace:WaitForChild("Big")
local Small: Part = workspace:WaitForChild("Small")

task.wait(2)

local orbitDrawing: Part = nil

--Determine Orbit
for _ = 0, 1, 1 do

	if orbitDrawing then
		orbitDrawing:Destroy()
	end

	local smallOrbit = orbitDeterminer.determineOrbit(Small.CFrame.Position - Big.CFrame.Position, Small.AssemblyLinearVelocity - Big.AssemblyLinearVelocity, Big)

	print(smallOrbit)

	orbitDrawing = orbitDrawer.drawOrbit(smallOrbit, 100, Small.Color)

	orbitDrawing:PivotTo(CFrame.new(Big.CFrame.Position, smallOrbit.AscendingNodeVector) * CFrame.Angles(0, 0, -smallOrbit.Inclination))
	task.wait()
end