-- Crypted#9928 - https://github.com/CryptedVR/ModuleManager

--- SERVICES
local P = game:GetService("Players");
local RPS = game:GetService("ReplicatedStorage");

--- VARIABLES
--/ Objects
local Remotes = RPS:FindFirstChild("Remotes") or Instance.new("Folder", RPS);
Remotes.Name = "Remotes";

--/ Module
local M = {};

M.CreateMissingRemotes = false;

local M_Funcs = {};
M_Funcs.__index = M_Funcs;

--- FUNCTIONS
--/ Module Functions
function M.Hook(RemoteName :string, Timeout :number?) -- Main function, hooks up the functions as long as a remote called "RemoteName" is within a folder called "Remotes" in ReplicatedStorage
	local New = {};
	setmetatable(New, M_Funcs);
	
	if M.CreateMissingRemotes and Remotes:FindFirstChild(RemoteName) == nil then
		New.Remote = Instance.new("RemoteEvent", Remotes);
		New.Remote.Name = RemoteName;
	else
		Remotes:WaitForChild(RemoteName, Timeout);
	end;
	
	return New;
end;

--/ OOP Functions
function M_Funcs:Send(Targets :{Player}?, ...) :nil -- Exists for simplicity, and somewhat QOL
	for _,Target :Player in (Targets or P:GetPlayers()) do
		self.Remote:FireClient(Target, ...);
	end;
	
	return;
end;

function M_Funcs:HookReturning(ReceiveFunction :(Player, ...any) -> (boolean, string)) :nil -- Waits for signals from clients, triggers function and sends whatever the function returns to the client
	self.Remote.OnServerEvent:Connect(function(Client :Player, ...)
		self.Remote:FireClient(Client, ReceiveFunction(Client, ...));
	end);
	
	return;
end;

--[[ Easy HookReturning usage

local ActionTypes :([string] :(Player, ...any) -> (boolean, string)) = {
	["Test"] = function(Client :Player, Argument :any)
		return "Some response " .. Argument;
	end;
};

Remote:HookReturning(function(Client :Player, Action :string, ...)
	return pcall(ActionTypes[Action], ...);
end);

]]

--- MODULE RETURN
return M;
