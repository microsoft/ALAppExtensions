namespace Microsoft.API.V1;

using System.Environment;
using System.Security.AccessControl;

page 20005 "APIV1 - Aut. Permission Sets"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v1.0';
    Caption = 'permissionSets', Locked = true;
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
                    Caption = 'id', Locked = true;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(appId; Rec."App ID")
                {
                    Caption = 'appId', Locked = true;
                }
                field(extensionName; Rec."App Name")
                {
                    Caption = 'extensionName', Locked = true;
                }
                field(scope; Rec.Scope)
                {
                    Caption = 'scope', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        BINDSUBSCRIPTION(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
}


