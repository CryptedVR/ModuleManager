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
