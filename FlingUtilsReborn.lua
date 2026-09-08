local Utils = {}
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RepStorage = game:GetService("ReplicatedStorage")

local function GrabObjectFrom(Obj: Instance, ChildName: string)
    return Obj:FindFirstChild(ChildName, true)
end

local SpawnedToys = workspace:FindFirstChild(lp.Name.."SpawnedInToys")

local SpawnToy: RemoteFunction = GrabObjectFrom(RepStorage, "SpawnToyRemoteFunction")
local DestroyToy: RemoteEvent = GrabObjectFrom(RepStorage, "DestroyToy")
local UseToy: RemoteEvent = GrabObjectFrom(RepStorage, "Use")


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
            task.wait(lp:GetNetworkPing()*2)
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

function Utils.UseToy(toy: Model)
    task.spawn(function()
        UseToy:FireServer(toy)
    end)
end

function Utils.HoldToy(toy: Model)
    task.spawn(function()
        local remote = GrabObjectFrom(toy, "HoldItemRemoteFunction")
        remote:InvokeServer(
            toy,
            lp.Character
        )
    end)
end

function Utils.DropToy(toy: Model, location: CFrame)
    task.spawn(function()
        GrabObjectFrom(toy, "DropItemRemoteFunction"):InvokeServer(
            toy,
            location,
            Vector3.zero
        )
    end)
end

function Utils.GetSpawnedToys()
    local toys = {}
    for _,toy in SpawnedToys:GetChildren() do
        if toy:IsA("Model") then
            table.insert(toys, toy)
        end
    end

    return toys
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
