-- Crypted#9928 - https://github.com/CryptedVR/ModuleManager

--- SERVICES
local DSS = game:GetService("DataStoreService");
local D = game:GetService("Debris");

--- CONSTANTS
local M = {};

--- FUNCTIONS
local _M = {};
_M.__index = _M;

function M.New(Name :string, Scope :string?)
	local New = setmetatable({}, _M);
	
	New.Datastore = DSS:GetDataStore(Name, Scope);
	New.MaxTries = math.huge;
	
	return New;
end;

--/ OOP Functions
function _M:Get(Scope :string, DefaultValue :any?, SaveIfDefault :boolean?) :any -- Simply just gets data with security in place, and minor QOL features
	local Success :boolean, Attempts :number, LoadedData :any = false, 0, nil;

	repeat
		Attempts += 1;

		Success, LoadedData = pcall(function()
			return self.Datastore:GetAsync(Scope);
		end);

		if not Success then -- No need to wait for a successful pcall
			task.wait(1.5);
		end;
	until Success or Attempts >= self.MaxTries;

	if LoadedData == nil and SaveIfDefault == true then
		self:Set(Scope, DefaultValue);
	end;

	return LoadedData or DefaultValue;
end;

function _M:Set(Scope :string, Value :any?) :string? -- Simply just sets data with security in place
	local Success :boolean, Attempts :number, ErrMsg :string? = false, 0, nil;

	repeat
		Attempts += 1;

		Success, ErrMsg = pcall(function()
			self.Datastore:SetAsync(Scope, Value); 
		end);

		if not Success then -- No need to wait for a successful pcall
			task.wait(1.5);
		end;
	until Success or Attempts >= self.MaxTries;

	return ErrMsg;
end;

function _M:SetThreaded(Scope :string, Value :any?) :RBXScriptSignal -- Sets data without yielding, and returning with a signal that can be connected and used to determine whether it errored or not
	local ReturnEvent :BindableEvent = Instance.new("BindableEvent", script);
	ReturnEvent.Name = Scope;

	task.spawn(function()
		ReturnEvent:Fire(self:Set(Scope, Value));
		D:AddItem(ReturnEvent, 1);
	end);

	return ReturnEvent.Event;
end;

--- MODULE RETURN
return M;
