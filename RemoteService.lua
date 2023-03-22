-- Crypted#9928 - https://github.com/CryptedVR/ModuleManager

--- SERVICES
local RPS = game:GetService("ReplicatedStorage");

--- VARIABLES
--/ Objects
local Remotes = RPS:WaitForChild("Remotes");

--/ Module
local M = {};

local M_Funcs = {};
M_Funcs.__index = M_Funcs;

--- FUNCTIONS
--/ Module Functions
function M.Hook(RemoteName :string, Timeout :number?) -- Main function, hooks up the functions as long as a remote called "RemoteName" is within a folder called "Remotes" in ReplicatedStorage
	local New = {};
	setmetatable(New, M_Funcs);
	
	New.Remote = Remotes:WaitForChild(RemoteName, Timeout);
	
	return New;
end;

--/ OOP Functions
function M_Funcs:Send(...) :nil -- Exists for simplicity
	self.Remote:FireServer(...);
	return;
end;

function M_Funcs:Get(...) :any -- Sends a request to Server, yields until response
	self.Remote:FireServer(...);
	return self.Remote.OnClientEvent:Wait();
end;

--- MODULE RETURN
return M;
