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
                field(id; "Role ID")
                {
                    Caption = 'Id';
                }
                field(displayName; Name)
                {
                    Caption = 'Display Name';
                }
                field(appId; "App ID")
                {
                    Caption = 'App Id';
                }
                field(extensionName; "App Name")
                {
                    Caption = 'Extension Name';
                }
                field(scope; Scope)
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

