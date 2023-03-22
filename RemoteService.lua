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
function M_Funcs:Send(Targets :{Player}, ...) :nil -- Exists for simplicity, and somewhat QOL
	for _,Target :Player in Targets do
		self.Remote:FireClient(Target, ...);
	end;
	
	return;
end;

function M_Funcs:HookReturning(ReceiveFunction) :nil -- Waits for signals from clients, triggers function and sends whatever the function returns to the client
	self.Remote.OnServerEvent:Connect(function(Client :Player, ...)
		self.Remote:FireClient(Client, ReceiveFunction(Client, ...));
	end);
	
	return;
end;

--- MODULE RETURN
return M;
