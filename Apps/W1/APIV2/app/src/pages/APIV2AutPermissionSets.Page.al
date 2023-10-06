namespace Microsoft.API.V2;

using System.Environment;
using System.Security.AccessControl;

page 30005 "APIV2 - Aut. Permission Sets"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'Permission Set';
    EntitySetCaption = 'Permission Sets';
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'permissionSet';
    EntitySetName = 'permissionSets';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Aggregate Permission Set";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec."Role ID")
                {
                    Caption = 'Id';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }
                field(appId; Rec."App ID")
                {
                    Caption = 'App Id';
                }
                field(extensionName; Rec."App Name")
                {
                    Caption = 'Extension Name';
                }
                field(scope; Rec.Scope)
                {
                    Caption = 'Scope';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
}

