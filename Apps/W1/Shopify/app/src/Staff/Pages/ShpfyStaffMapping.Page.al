namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Staff Mapping (ID 30171).
/// </summary>
page 30171 "Shpfy Staff Mapping"
{
    ApplicationArea = All;
    Caption = 'Shopify Staff Member Mapping';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Shpfy Staff Member";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("First Name"; Rec."First Name") { }
                field("Last Name"; Rec."Last Name") { }
                field(Initials; Rec.Initials) { }
                field(Name; Rec.Name) { }
                field("Shop Owner"; Rec."Shop Owner") { }
                field(Exists; Rec.Exists) { }
                field(Email; Rec.Email) { }
                field("Account Type"; Rec."Account Type") { }
                field(Active; Rec.Active) { }
                field(Locale; Rec.Locale) { }
                field(Phone; Rec.Phone) { }
                field("Salesperson/Purchaser Code"; Rec."Salesperson Code") { }
            }
        }
    }
    
    actions
    {
        area(processing)
        {
            action(Refresh)
            {
                ApplicationArea = All;
                Caption = 'Refresh';
                Image = Refresh;
                ToolTip = 'Refreshes the list of Shopify staff members.';

                trigger OnAction()
                var
                    StaffMemberAPI: Codeunit "Shpfy Staff Member API";
                begin
                    StaffMemberAPI.GetStaffMembers(CopyStr(Rec.GetFilter("Shop Code"), 1, 20));
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(Refresh_Promoted; Refresh) { }
            }
        }
    }
}
