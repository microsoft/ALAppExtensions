page 30002 "APIV2 - Aut. Extensions"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Extension';
    EntitySetCaption = 'Extensions';
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'extension';
    EntitySetName = 'extensions';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = "Package ID";
    PageType = API;
    SourceTable = "Published Application";
    SourceTableView = Sorting(Name)
                      Where(Name = Filter(<> '_Exclude_*'),
                            "Tenant Visible" = Const(true),
                            "Package Type" = Filter(= Extension | Designer));
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(packageId; "Package ID")
                {
                    Caption = 'Package Id';
                }
                field(id; ID)
                {
                    Caption = 'Id';
                }
                field(displayName; Name)
                {
                    Caption = 'DisplayName';
                }
                field(publisher; Publisher)
                {
                    Caption = 'Publisher';
                }
                field(versionMajor; "Version Major")
                {
                    Caption = 'Version Major';
                }
                field(versionMinor; "Version Minor")
                {
                    Caption = 'Version Minor';
                }
                field(versionBuild; "Version Build")
                {
                    Caption = 'Version Build';
                }
                field(versionRevision; "Version Revision")
                {
                    Caption = 'Version Revision';
                }
                field(isInstalled; isExtensionInstalled)
                {
                    Caption = 'Is Installed';
                    Editable = false;
                }
                field(publishedAs; "Published As")
                {
                    Caption = 'Published As';
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        isExtensionInstalled := ExtensionManagement.IsInstalledByPackageId("Package ID");
    end;

    trigger OnOpenPage()
    var
        EnvironmentInformation: codeunit "Environment Information";
    begin

        BindSubscription(AutomationAPIManagement);

        FilterGroup(2);
        if EnvironmentInformation.IsSaas() then
            SetFilter("PerTenant Or Installed", '%1', true)
        else
            SetFilter("Tenant Visible", '%1', true);
        FilterGroup(0);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";

        IsExtensionInstalled: Boolean;
        IsNotInstalledErr: Label 'The extension %1 is not installed.', Comment = '%1=name of app';
        IsInstalledErr: Label 'The extension %1 is already installed.', Comment = '%1=name of app';

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure install(var ActionContext: WebServiceActionContext)
    begin
        if ExtensionManagement.IsInstalledByPackageId("Package ID") then
            Error(IsInstalledErr, Name);

        ExtensionManagement.InstallExtension("Package ID", GLOBALLANGUAGE(), false);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Extensions");
        ActionContext.AddEntityKey(FieldNo(ID), ID);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure uninstall(var ActionContext: WebServiceActionContext)
    begin
        if not ExtensionManagement.IsInstalledByPackageId("Package ID") then
            Error(IsNotInstalledErr, Name);

        ExtensionManagement.UninstallExtension("Package ID", false);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Extensions");
        ActionContext.AddEntityKey(FieldNo(ID), ID);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure uninstallAndDeleteExtensionData(var ActionContext: WebServiceActionContext)
    begin
        if not ExtensionManagement.IsInstalledByPackageId("Package ID") then
            Error(IsNotInstalledErr, Name);

        ExtensionManagement.UninstallExtensionAndDeleteExtensionData("Package ID", false);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Extensions");
        ActionContext.AddEntityKey(FieldNo(ID), ID);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    var
        ExtensionManagement: Codeunit "Extension Management";

}
