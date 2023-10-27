--Requiring gravity to initiate its function
require(script:WaitForChild("gravity"))
local orbitDeterminer = require(script:WaitForChild("orbitDeterminer"))
local orbitDrawer = require(script:WaitForChild("orbitDrawer"))

--Bodies
local Big: Part = workspace:WaitForChild("Big")
local Small: Part = workspace:WaitForChild("Small")

local orbitDrawing: Part = nil

task.wait()

--Determine Orbit
--I'm looping infinitely because slight variations in frame-rate change the orbit slightly.
--Re-drawing occasionally means the accuracy stays high (Small stays right on the orbit-line).
while true do

	--Clearing the last drawing
	if orbitDrawing then
		orbitDrawing:Destroy()
	end

	--Calculating the information for the orbit
	local smallOrbit = orbitDeterminer.determineOrbit(Small.CFrame.Position - Big.CFrame.Position, Small.AssemblyLinearVelocity - Big.AssemblyLinearVelocity, Big)


	--Drawing the orbit
	orbitDrawing = orbitDrawer.drawOrbit(smallOrbit, 360, Small.Color)

	--Aligning the 2D orbital frame with the 3D orbital frame of reference.
	orbitDrawing:PivotTo(Big.CFrame * CFrame.Angles(0, smallOrbit.LongitudeOfAscendingNode - (math.pi / 2), -smallOrbit.Inclination))
	--The LongitudeOfAscendingNode is off by 90 degrees due to the way I calculated my drawing.

	--orbitDrawing:PivotTo(Big.CFrame * CFrame.new(Big.CFrame.Position, smallOrbit.AscendingNodeVector) * CFrame.Angles(0, 0, -smallOrbit.Inclination))
	--This method may be easier to understand, as its very clear in what direction the LookVector becomes,
	--but it's much more expensive, especially since we already have calculted the LongitudeOfAscendingNode.

	--Finally, parenting the orbitDrawing to workspace
	orbitDrawing.Parent = workspace

	task.wait(1)
end