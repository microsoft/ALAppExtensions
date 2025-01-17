namespace Microsoft.API.V1;

using System.Apps;
using System.Environment;

page 20002 "APIV1 - Aut. Extensions"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    Caption = 'extensions', Locked = true;
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
                    Caption = 'packageId', Locked = true;
                }
                field(id; Rec.ID)
                {
                    Caption = 'id', Locked = true;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(publisher; Rec.Publisher)
                {
                    Caption = 'publisher', Locked = true;
                }
                field(versionMajor; Rec."Version Major")
                {
                    Caption = 'versionMajor', Locked = true;
                }
                field(versionMinor; Rec."Version Minor")
                {
                    Caption = 'versionMinor', Locked = true;
                }
                field(versionBuild; Rec."Version Build")
                {
                    Caption = 'versionBuild', Locked = true;
                }
                field(versionRevision; Rec."Version Revision")
                {
                    Caption = 'versionRevision', Locked = true;
                }
                field(isInstalled; isExtensionInstalled)
                {
                    Caption = 'isInstalled', Locked = true;
                    Editable = false;
                }
                field(publishedAs; Rec."Published As")
                {
                    Caption = 'publishedAs', Locked = true;
                    Editable = false;
                    ToolTip = 'TODO(pteisolation) We should remove the code cop error for API pages';
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

        BINDSUBSCRIPTION(AutomationAPIManagement);

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

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure install(var ActionContext: WebServiceActionContext)
    begin
        if ExtensionManagement.IsInstalledByPackageId(Rec."Package ID") then
            error(IsInstalledErr, Rec.Name);

        ExtensionManagement.InstallExtension(Rec."Package ID", GlobalLanguage(), false);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV1 - Aut. Extensions");
        ActionContext.AddEntityKey(Rec.FieldNo(ID), Rec.ID);
        ActionContext.SetResultCode(WebServiceActionResultCode::Deleted);
    end;

    [ServiceEnabled]
    [Scope('Cloud')]
    procedure uninstall(var ActionContext: WebServiceActionContext)
    begin
        if not ExtensionManagement.IsInstalledByPackageId(Rec."Package ID") then
            error(IsNotInstalledErr, Rec.Name);

        ExtensionManagement.UninstallExtension(Rec."Package ID", false);

        ActionContext.SetObjectType(ObjectType::Page);
        ActionContext.SetObjectId(Page::"APIV1 - Aut. Extensions");
        ActionContext.AddEntityKey(Rec.FieldNo(ID), Rec.ID);
        ActionContext.SetResultCode(WebServiceActionResultCode::Updated);
    end;

    var
        ExtensionManagement: Codeunit "Extension Management";

}


