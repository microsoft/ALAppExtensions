page 20059 "APIV1 - Aut. User Group Member"
{
    Caption = 'userGroupMember', Locked = true;
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "User Group Member";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("code"; "User Group Code")
                {
                    ApplicationArea = All;
                    Caption = 'code', Locked = true;
                }
                field(displayName; "User Group Name")
                {
                    ApplicationArea = All;
                    Caption = 'displayName', Locked = true;
                }
                field(companyName; "Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'companyName', Locked = true;
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

