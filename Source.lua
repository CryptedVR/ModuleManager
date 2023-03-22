-- Source Code: https://github.com/CryptedVR/ModuleManager
-- Plugin Link: https://www.roblox.com/library/12864363301

--- SERVICES
local SS = game:GetService("ServerStorage");
local RPS = game:GetService("ReplicatedStorage");
local HTTPS = game:GetService("HttpService");
local CHS = game:GetService("ChangeHistoryService");
local TS = game:GetService("TweenService");

--- VARIABLES
local Categories = {
	Server = "Server",
	Client = "Client",
};
local CommonCharacters :{string} = string.split("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ123456789 ", "");
local LinkRoot :string = "https://raw.githubusercontent.com/CryptedVR/ModuleManager/";

function CreateFolder(Parent :Instance, FolderName :string) :Folder
	local Folder = Parent:FindFirstChild(FolderName);
	
	if Folder == nil then
		Folder = Instance.new("Folder", Parent);
		Folder.Name = FolderName;
	end;
	
	return Folder;
end;

--/ PLUGIN
local Toolbar :PluginToolbar = plugin:CreateToolbar("Module Manager");

local ServerGroup = Toolbar:CreateButton("1server", "Toggles Server UI", "rbxassetid://11778372908", "Server");
ServerGroup.ClickableWhenViewportHidden = true;
local ClientGroup = Toolbar:CreateButton("2client", "Toggles Client UI", "rbxassetid://11778372908", "Client");
ClientGroup.ClickableWhenViewportHidden = true;

local WidgetInfo :DockWidgetPluginGuiInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float,
	false, -- Start Enabled
	false, -- Overwrite
	300, 200, -- XY Default
	300, 200  -- XY Min
);

--/ WIDGET UI
local Widget = plugin:CreateDockWidgetPluginGui("widget", WidgetInfo);

local UI = script:WaitForChild("Background");
local Container = UI:WaitForChild("Contents");
local Button = script:WaitForChild("Button");
UI.Parent = Widget;

local LoadingFrame = UI:WaitForChild("Loading");
local LoadingSpinner = LoadingFrame:WaitForChild("Spinner");
local SpinnerTween :Tween = TS:Create(LoadingSpinner, TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1, false), {
	Rotation = 360,
});
SpinnerTween:Play();

--/ DIRECTORIES
local ServerModules :Folder = CreateFolder(SS, "Modules");
local ClientModules :Folder = CreateFolder(RPS, "Modules");

--/ STATES
local UI :string? = nil; -- nil / "S" / "C"
local Loading :boolean = false;

--- FUNCTIONS
function SpecialCharacterFilter(Input :string) :string
	local Output :string = "";
	
	for _,Letter :string in string.split(Input, "") do -- Not exactly sure how to do regex, so this'll do
		if table.find(CommonCharacters, Letter) then
			Output = Output .. Letter;
		end;
	end;
	
	return Output;
end;
function GetLinkList(Category :string) :{string}
	return string.split(SpecialCharacterFilter(HTTPS:GetAsync((LinkRoot .. Category .. "/LIST.txt"), false)), " ");
end;
function GetModuleSource(Category :string, Module :string) :string
	print("Getting Module Source from URL:");
	print(LinkRoot .. Category .. "/" .. Module .. ".lua");
	
	return HTTPS:GetAsync((LinkRoot .. Category .. "/" .. Module .. ".lua"), false);
end;

function UpdateUI()
	if UI == nil then
		Widget.Enabled = false;
	else
		LoadingFrame.Visible = true;
		
		local ModuleFolder = if UI == Categories.Server then ServerModules else ClientModules;
		
		ServerGroup:SetActive(UI == Categories.Server);
		ClientGroup:SetActive(UI == Categories.Client);
		
		for _,Object :Instance in Container:GetChildren() do
			if Object:IsA(Button.ClassName) then
				Object:Destroy();
			end;
		end;
		
		for _,ModuleName :string in GetLinkList(UI) do
			local NewButton = Button:Clone();
			NewButton.LayoutOrder = #Container:GetChildren();
			NewButton.Text = ModuleName;
			
			NewButton.MouseButton1Click:Connect(function()
				local NewModule :ModuleScript;
				
				local Success :boolean, Error :string? = pcall(function()
					NewModule = Instance.new("ModuleScript", ModuleFolder);
					NewModule.Source = GetModuleSource(UI, ModuleName);
					NewModule.Name = ModuleName;
				end);
				
				if not Success then
					NewModule:Destroy();
					print(Error);
				else
					CHS:SetWaypoint(math.random() .. "-" .. ModuleName);
				end;
			end);
			
			NewButton.Parent = Container;
		end;
		
		Widget.Title = UI;
		
		Widget.Enabled = true;
		
		LoadingFrame.Visible = false;
	end;
end;

--- EVENTS
ServerGroup.Click:Connect(function()
	if Loading then return; end;
	Loading = true;
	UI = (if UI ~= Categories.Server then Categories.Server else nil); -- nil if already on server
	
	UpdateUI();
	Loading = false;
end);

ClientGroup.Click:Connect(function()
	if Loading then return; end;
	Loading = true;
	UI = (if UI ~= Categories.Client then Categories.Client else nil);
	
	UpdateUI();
	Loading = false;
end);
