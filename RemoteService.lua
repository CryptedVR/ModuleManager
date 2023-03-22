--- CONSTANTS
local Huge :number = math.huge;

--- MODULE ESSENTIAL
local M = {};
local RemoteFuncs = {};
RemoteFuncs.__index = RemoteFuncs;

--- SERVICES
local RPS = game:GetService("ReplicatedStorage");

--- VARIABLES
local Remotes = RPS:WaitForChild("Remotes");

--- FUNCTIONS
function M.Hook(RemoteName :string)
	local NewRemote = {};
	setmetatable(NewRemote, RemoteFuncs);
	
	NewRemote.Remote = Remotes:WaitForChild(RemoteName, Huge);
	
	return NewRemote;
end;

function RemoteFuncs:Send(...) :nil
	self.Remote:FireServer(...);
	
	return;
end;

function RemoteFuncs:Get(...) :any
	self.Remote:FireServer(...);
	
	return self.Remote.OnClientEvent:Wait();
end;

return M;
