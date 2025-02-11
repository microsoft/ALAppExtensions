namespace Microsoft.API.V2;

using System.Apps;
using System.Environment;

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
    SourceTableView = sorting(Name)
                      where(Name = filter(<> '_Exclude_*'),
                            "Tenant Visible" = const(true),
                            "Package Type" = filter(= Extension | Designer));
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(packageId; Rec."Package ID")
                {
                    Caption = 'Package Id';
                }
                field(id; Rec.ID)
                {
                    Caption = 'Id';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'DisplayName';
                }
                field(publisher; Rec.Publisher)
                {
                    Caption = 'Publisher';
                }
                field(versionMajor; Rec."Version Major")
                {
                    Caption = 'Version Major';
                }
                field(versionMinor; Rec."Version Minor")
                {
                    Caption = 'Version Minor';
                }
                field(versionBuild; Rec."Version Build")
                {
                    Caption = 'Version Build';
                }
                field(versionRevision; Rec."Version Revision")
                {
                    Caption = 'Version Revision';
                }
                field(isInstalled; isExtensionInstalled)
                {
                    Caption = 'Is Installed';
                    Editable = false;
                }
                field(publishedAs; Rec."Published As")
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
        isExtensionInstalled := ExtensionManagement.IsInstalledByPackageId(Rec."Package ID");
    end;

    trigger OnOpenPage()
    var
        EnvironmentInformation: codeunit "Environment Information";
    begin

        BindSubscription(AutomationAPIManagement);

        Rec.FilterGroup(2);
        if EnvironmentInformation.IsSaas() then
            Rec.SetFilter("PerTenant Or Installed", '%1', true)
        else
            Rec.SetFilter("Tenant Visible", '%1', true);
        Rec.FilterGroup(0);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";

        IsExtensionInstalled: Boolean;
        IsNotInstalledErr: Label 'The extension %1 is not installed.', Comment = '%1=name of app';
        IsInstalledErr: Label 'The extension %1 is already installed.', Comment = '%1=name of app';
        CannotUnpublishInstalledAppErr: Label 'The extension %1 cannot be unpublished because it is installed.', Comment = '%1=name of app';

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure install(var ActionContext: WebServiceActionContext)
    begin
        if ExtensionManagement.IsInstalledByPackageId(Rec."Package ID") then
            Error(IsInstalledErr, Rec.Name);

        ExtensionManagement.InstallExtension(Rec."Package ID", GLOBALLANGUAGE(), false);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Extensions");
        ActionContext.AddEntityKey(Rec.FieldNo(ID), Rec.ID);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure uninstall(var ActionContext: WebServiceActionContext)
    begin
        if not ExtensionManagement.IsInstalledByPackageId(Rec."Package ID") then
            Error(IsNotInstalledErr, Rec.Name);

        ExtensionManagement.UninstallExtension(Rec."Package ID", false);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Extensions");
        ActionContext.AddEntityKey(Rec.FieldNo(ID), Rec.ID);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure uninstallAndDeleteExtensionData(var ActionContext: WebServiceActionContext)
    begin
        if not ExtensionManagement.IsInstalledByPackageId(Rec."Package ID") then
            Error(IsNotInstalledErr, Rec.Name);

        ExtensionManagement.UninstallExtensionAndDeleteExtensionData(Rec."Package ID", false);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV2 - Aut. Extensions");
        ActionContext.AddEntityKey(Rec.FieldNo(ID), Rec.ID);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure unpublish(var ActionContext: WebServiceActionContext)
    begin
        if ExtensionManagement.IsInstalledByPackageId(Rec."Package ID") then
            Error(CannotUnpublishInstalledAppErr, Rec.Name);

        ExtensionManagement.UnpublishExtension(Rec."Package ID");

        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    var
        ExtensionManagement: Codeunit "Extension Management";

}
