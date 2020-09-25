page 30003 "APIV2 - Aut. User Groups"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'User Group';
    EntitySetCaption = 'User Groups';
    DelayedInsert = true;
    DeleteAllowed = false;
    EntityName = 'userGroup';
    EntitySetName = 'userGroups';
    InsertAllowed = false;
    PageType = API;
    SourceTable = "User Group";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("code"; Code)
                {
                    Caption = 'Code';
                    Editable = false;
                }
                field(displayName; Name)
                {
                    Caption = 'Display Name';
                }
                field(defaultProfileID; "Default Profile ID")
                {
                    Caption = 'Default Profile Id';
                }
                field(assignToAllNewUsers; "Assign to All New Users")
                {
                    Caption = 'Assign To All New Users';
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

