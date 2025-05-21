namespace Microsoft.Integration.Shopify;

/// <summary>
/// Page Shpfy Staff Mapping (ID 30171).
/// </summary>
page 30171 "Shpfy Staff Mapping"
{
    ApplicationArea = All;
    Caption = 'Shopify Staff Mapping';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Shpfy Staff Member";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("First Name"; Rec."First Name")
                {
                    ToolTip = 'Specifies the staff member''s first name.';
                }
                field("Last Name"; Rec."Last Name")
                {
                    ToolTip = 'Specifies the staff member''s last name.';
                }
                field(Initials; Rec.Initials)
                {
                    ToolTip = 'Specifies the staff member''s initials.';
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the staff member''s name.';
                }
                field("Shop Owner"; Rec."Shop Owner")
                {
                    ToolTip = 'Indicates if the staff member is the shop owner.';
                }
                field(Exists; Rec.Exists)
                {
                    ToolTip = 'Indicates if the staff member exists.';
                }
                field(Email; Rec.Email)
                {
                    ToolTip = 'Specifies the staff member''s email address.';
                }
                field("Account Type"; Rec."Account Type")
                {
                    ToolTip = 'Specifies the staff account type.';
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Indicates if the staff member is active.';
                }
                field(Locale; Rec.Locale)
                {
                    ToolTip = 'Specifies the staff member''s locale.';
                }
                field(Phone; Rec.Phone)
                {
                    ToolTip = 'Specifies the staff member''s phone number.';
                }
                field("Salesperson/Purchaser Code"; Rec."Salesperson Code")
                {
                    ToolTip = 'Specifies the sales person or purchaser code.';
                }
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
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                ToolTip = 'Refreshes the list of Shopify staff members.';

                trigger OnAction()
                var
                    ShpfyStaffAPI: Codeunit "Shpfy Staff Member API";
                begin
                    ShpfyStaffAPI.GetStaffMembers(CopyStr(Rec.GetFilter("Shop Code"), 1, 20));
                end;
            }
        }
    }
}
