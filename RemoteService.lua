-- https://github.com/CryptedVR/ModuleManager
-- Discord: crypted.gif

--- SERVICES
local RPS = game:GetService("ReplicatedStorage");

--- CONSTANTS
local Remotes = RPS:WaitForChild("Remotes");
local M = {};

--- FUNCTIONS
local _M = {};
_M.__index = _M;

function M.Hook(RemoteName :string)
	return setmetatable({
		Remote = Remotes:WaitForChild(RemoteName);
	}, _M);
end;

function _M:Send(Targets :{Player}, ...) :nil
	for _,Target :Player in Targets do
		self.Remote:FireClient(Target, ...);
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
