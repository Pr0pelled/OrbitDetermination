--Calculates gravity using newtons equations

--Services
local RunService = game:GetService("RunService")

--Bodies
local Big = workspace:WaitForChild("Big")
local Small = workspace:WaitForChild("Small")

--Constants
local G = 6.67e-11
local massMultiplier = 10e10

--Functions
local function calculateGravity(deltaTime: number)
	--F = G * (m1 * m2) / r^2
	local dist = Big.Position - Small.Position
	local force = (G * (Big.Mass * massMultiplier) / (dist.Magnitude^2)) * dist.Unit --Ignoring the small mass
	Small.AssemblyLinearVelocity += (force * deltaTime) --Again, ignoring the small mass
end

RunService:BindToRenderStep("CalculateGravity", Enum.RenderPriority.Last.Value, calculateGravity)

return nil