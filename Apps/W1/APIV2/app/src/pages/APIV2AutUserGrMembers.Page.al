page 30058 "APIV2 - Aut. User Gr. Members"
{
    APIGroup = 'automation';
    APIPublisher = 'microsoft';
    APIVersion = 'v2.0';
    EntityCaption = 'User Group Member';
    EntitySetCaption = 'User Group Members';
    DelayedInsert = true;
    EntityName = 'userGroupMember';
    EntitySetName = 'userGroupMembers';
    Extensible = false;
    PageType = API;
    SourceTable = "User Group Member";
    ODataKeyFields = SystemId;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(userSecurityId; "User Security ID")
                {
                    Caption = 'User Security Id';
                    Editable = false;
                }
                field("code"; "User Group Code")
                {
                    Caption = 'Code';
                }
                field(displayName; "User Group Name")
                {
                    Caption = 'Display Name';
                }
                field(companyName; "Company Name")
                {
                    Caption = 'Company Name';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        UserSecurityIDFilter: Text;
    begin
        if not LinesLoaded then begin
            UserSecurityIDFilter := GetFilter("User Security ID");
            if UserSecurityIDFilter = '' then
                Error(UserIDNotSpecifiedForLinesErr);
            if not FindFirst() then
                exit(false);
            LinesLoaded := true;
        end;

        exit(true);
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        UserIDNotSpecifiedForLinesErr: Label 'You must specify a User Security ID to access user groups members.';
        LinesLoaded: Boolean;
}

