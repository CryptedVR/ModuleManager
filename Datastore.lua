-- https://github.com/CryptedVR/ModuleManager
-- Discord: crypted.gif

--- SERVICES
local DSS = game:GetService("DataStoreService");
local D = game:GetService("Debris");

--- CONSTANTS
local M = {};

--- FUNCTIONS
local _M = {};
_M.__index = _M;

function M.New(Name :string, Scope :string?)
	return setmetatable({
		Datastore = DSS:GetDataStore(Name .. (Scope or "")),
		MaxTries = math.huge,
		RetryTime = 0.5,
	}, _M);
end;

function _M:Get(Scope :string, DefaultValue :any?, SaveIfDefault :boolean?) :any -- Simply just gets data with security in place, and minor QOL features
	local Success :boolean, Attempts :number, LoadedData :any = false, 0, nil;

	repeat
		Attempts += 1;

		Success, LoadedData = pcall(function()
			return self.Datastore:GetAsync(Scope);
		end);

		if not Success then
			task.wait(self.RetryTime);
		end;
	until Success or Attempts >= self.MaxTries;

	if LoadedData == nil and SaveIfDefault == true then
		self:Set(Scope, DefaultValue);
	end;

	return LoadedData or DefaultValue;
end;

function _M:Set(Scope :string, Value :any?) :string?
	local Success :boolean, Attempts :number, ErrMsg :string? = false, 0, nil;

	repeat
		Attempts += 1;

		Success, ErrMsg = pcall(function()
			self.Datastore:SetAsync(Scope, Value); 
		end);

		if not Success then
			task.wait(self.RetryTime);
		end;
	until Success or Attempts >= self.MaxTries;

	return ErrMsg;
end;

function _M:SetThreaded(Scope :string, Value :any?) :RBXScriptSignal
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
