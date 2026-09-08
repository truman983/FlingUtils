local Utils = {}
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")

local function GrabFromRepStorage(ObjName: string)
    return RepStorage:FindFirstChild(ObjName, true)
end

local SpawnedToys = workspace:FindFirstChild(lp.Name.."SpawnedInToys")

local SpawnToy: RemoteFunction = GrabFromRepStorage("SpawnToyRemoteFunction")
local DestroyToy: RemoteEvent = GrabFromRepStorage("DestroyToy")


local function ReturnYDegrees(Object: BasePart)
    local _, y = Object.CFrame:ToOrientation()
    return math.deg(y)
end

local function WaitTillFalse(Bv: BoolValue)
	if not Bv.Value then
		return
	end

	local thread = coroutine.running()

	local connection
	connection = Bv.Changed:Connect(function(value)
		if not value then
			connection:Disconnect()
			task.spawn(thread)
		end
	end)

	coroutine.yield()
end

function Utils.SpawnToy(toy: string, location: CFrame, rotation: Vector3?)
	task.spawn(function()
		SpawnToy:InvokeServer(
			toy,
			location,
			rotation or Vector3.zero
		)
	end)
end

function Utils.QueueToySpawn(ToyName: string, Location: CFrame, NumberOfToys: number?)
    local bool = lp.CanSpawnToy

    if NumberOfToys then
        for i=1, NumberOfToys do
            Utils.SpawnToy(ToyName, Location)
            task.wait(0.01)
            WaitTillFalse(bool)
        end
        return
    end

    Utils.SpawnToy(ToyName, Location)

end

function Utils.FindToy(ToyName: string)
    return SpawnedToys:FindFirstChild(ToyName)
end

function Utils.DeleteAllToys()
    for _,toy in SpawnedToys:GetChildren() do
        DestroyToy:FireServer(toy)
    end
end

function Utils.DeleteToy(ToyName: string, All: boolean?)
    local Matches = {}

    for _,toy in SpawnedToys:GetChildren() do
        if toy.Name == ToyName then
            table.insert(Matches, toy)
        end
    end

    if All then
        for _,toy in Matches do
            DestroyToy:FireServer(toy)
        end
    else
        DestroyToy:FireServer(Matches[1])
    end

end



return Utils
