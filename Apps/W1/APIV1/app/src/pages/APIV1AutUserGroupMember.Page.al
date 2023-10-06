#if not CLEAN22
namespace Microsoft.API.V1;

using System.Environment;
using System.Security.AccessControl;

page 20059 "APIV1 - Aut. User Group Member"
{
    Caption = 'userGroupMember', Locked = true;
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "User Group Member";
    Extensible = false;
    ObsoleteState = Pending;
    ObsoleteReason = 'The User Group Member table is deprecated.';
    ObsoleteTag = '22.0';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("code"; Rec."User Group Code")
                {
                    ApplicationArea = All;
                    Caption = 'code', Locked = true;
                    ToolTip = 'Specifies the user group code';
                }
                field(displayName; Rec."User Group Name")
                {
                    ApplicationArea = All;
                    Caption = 'displayName', Locked = true;
                    ToolTip = 'Specifies the user group name';
                }
                field(companyName; Rec."Company Name")
                {
                    ApplicationArea = All;
                    Caption = 'companyName', Locked = true;
                    ToolTip = 'Specifies the company name';
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
            UserSecurityIDFilter := Rec.GetFilter("User Security ID");
            if UserSecurityIDFilter = '' then
                Error(UserIDNotSpecifiedForLinesErr);
            if not Rec.FindFirst() then
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


#endif