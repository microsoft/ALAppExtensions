// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

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
                field(Name; Rec.Name) { }
                field("Shop Owner"; Rec."Shop Owner") { }
                field(Exists; Rec.Exists) { Visible = false; }
                field(Email; Rec.Email) { }
                field(Phone; Rec.Phone) { Visible = false; }
                field("Account Type"; Rec."Account Type") { }
                field(Active; Rec.Active) { }
                field(Locale; Rec.Locale) { Visible = false; }
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