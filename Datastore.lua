-- By your boy, Crypted.
local DSS = game:GetService("DataStoreService");
local D = game:GetService("Debris");

local M = {
	Datastores = {},
};

local DSFunctions = {};
DSFunctions.__index = DSFunctions;

function M.New(Name :string, Scope :string?)
	local DS = {};
	setmetatable(DS, DSFunctions);

	DS.Datastore = DSS:GetDataStore(Name, Scope);
	DS.MaxTries = math.huge;

	return DS;
end;

function DSFunctions:Get(Scope :string, DefaultValue :any?, SaveIfDefault :boolean?) :any
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

function DSFunctions:Set(Scope :string, Value :any?) :string?
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

function DSFunctions:SetThreaded(Scope :string, Value :any?) :RBXScriptSignal
	local ReturnEvent :BindableEvent = Instance.new("BindableEvent", script);
	ReturnEvent.Name = Scope;

	task.spawn(function()
		ReturnEvent:Fire(self:Set(Scope, Value));
	end);

	return ReturnEvent.Event;
end;

return M;
