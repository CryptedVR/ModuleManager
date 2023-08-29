-- Crypted#9928 - https://github.com/CryptedVR/ModuleManager

--- SERVICES
local RPS = game:GetService("ReplicatedStorage");

--- CONSTANTS
local Remotes = RPS:WaitForChild("Remotes");
local M = {};

--- FUNCTIONS
local _M = {};
_M.__index = _M;

function M.Hook(RemoteName :string, Timeout :number?)
	local New = setmetatable({}, _M);
	
	New.Remote = Remotes:WaitForChild(RemoteName, Timeout);
	
	return New;
end;

function _M:Send(...) :nil
	self.Remote:FireServer(...);
	return;
end;

function _M:Get(...) :any
	self.Remote:FireServer(...);
	return self.Remote.OnClientEvent:Wait();
end;

--- MODULE RETURN
return M;
