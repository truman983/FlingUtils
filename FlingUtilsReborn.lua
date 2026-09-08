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
    if NumberOfToys then
        for i=1, NumberOfToys do
            local bool = lp.CanSpawnToy
            task.wait(0.1)
            repeat
                task.wait()
            until bool.Value == true
            task.wait(0.05)
            Utils.SpawnToy(ToyName, Location)
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
