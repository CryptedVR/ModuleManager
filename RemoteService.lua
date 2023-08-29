-- Crypted#9928 - https://github.com/CryptedVR/ModuleManager

--- CORE
function NewInstance(ClassName :string, Parent :Instance, Properties :{[string] :any}) :Instance
	local Object :Instance = Instance.new(ClassName, Parent);
	
	for Property :string, Value :any in Properties do
		Object[Property] = Value;
	end;
	
	return Object;
end;

function VerifyDirectory(Root :Instance, Path :string, Seperator :string?) :Instance
	local Current :Instance = Root;
	
	for _,Index :string in string.split(Path, Seperator or ".") do
		Current = Current:WaitForChild(Index) or NewInstance("Folder", Current, {
			Name = Index,
		});
	end;
	
	return Current;
end;

--- SERVICES
local P = game:GetService("Players");
local RPS = game:GetService("ReplicatedStorage");

--- CONSTANTS
local Remotes = VerifyDirectory(RPS, "Remotes");
local M = {};

--- SETTINGS
M.CreateMissingRemotes = false;
M.SendDefaultsToAll = true;

--- FUNCTIONS
local _M = {};
_M.__index = _M;

function M.Hook(RemoteName :string, Timeout :number?)
	local New = setmetatable({}, _M);
	
	if M.CreateMissingRemotes and Remotes:FindFirstChild(RemoteName) == nil then
		New.Remote = Instance.new("RemoteEvent", Remotes);
		New.Remote.Name = RemoteName;
	else
		New.Remote = Remotes:WaitForChild(RemoteName, Timeout);
	end;
	
	return New;
end;

function _M:Send(Targets :(Player | {Player})?, ...) :nil
	if typeof(Targets) == "table" then
		for _,Target :Player in (Targets or (if (M.SendDefaultsToAll) then P:GetPlayers() else {})) do
			self.Remote:FireClient(Target, ...);
		end;
	else
		self.Remote:FireClient(Targets, ...);
	end;
	
	return;
end;

function _M:HookReturning(ReceiveFunction :(Player, ...any) -> (...any)) :nil -- Waits for signals from clients, triggers function and sends whatever the function returns to the client
	self.Remote.OnServerEvent:Connect(function(Client :Player, ...)
		self.Remote:FireClient(Client, ReceiveFunction(Client, ...));
	end);
	
	return;
end;

--- MODULE RETURN
return M;
