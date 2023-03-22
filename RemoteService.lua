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

function RemoteFuncs:Send(Targets :{Player}, ...) :nil
	for _,Target :Player in Targets do
		self.Remote:FireClient(Target, ...);
	end;
	
	return;
end;

function RemoteFuncs:HookReturning(ReceiveFunction) :nil
	self.Remote.OnServerEvent:Connect(function(Client :Player, ...)
		self.Remote:FireClient(Client, ReceiveFunction(Client, ...));
	end);
	
	return;
end;

return M;
