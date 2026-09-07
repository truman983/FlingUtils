local Utils = {}
local lp = game.Players.LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")

local function GrabFromRepStorage(ObjName: string)
    return RepStorage:FindFirstChild(ObjName, true)
end

local SpawnedToys = workspace:FindFirstChild(lp.Name.."SpawnedInToys")

local SpawnToy: RemoteFunction = GrabFromRepStorage("SpawnToyRemoteFunction")
local DestroyToy: RemoteEvent = GrabFromRepStorage("DestroyToy")


local function ReturnYDegrees(Object: BasePart)
    local x,y = Object.CFrame:ToOrientation()
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

function Utils.SpawnToy(ToyName, Location)
    local argsTable = {}
    table.insert(argsTable, ToyName)
    table.insert(argsTable, (Location * CFrame.Angles(math.pi/2, 0, 0)) - Vector3.new(0,25))
    table.insert(argsTable, Vector3.new(0,ReturnYDegrees(lp.Character.HumanoidRootPart)))

    task.spawn(function()
        SpawnToy:InvokeServer(table.unpack(argsTable))
    end)
end

function Utils.QueueToySpawn(ToyName: string, Location: Vector3, NumberOfToys: number?)
    local bool = lp.CanSpawnToy

    if NumberOfToys then
        for i=1, NumberOfToys do
            Utils.SpawnToy(ToyName, Location)
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
