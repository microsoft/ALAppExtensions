// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Finance;

page 4772 "Finance Module Setup"
{
    PageType = Card;
    ApplicationArea = All;
    Caption = 'Finance Module Setup';
    SourceTable = "Finance Module Setup";
    Extensible = false;
    DeleteAllowed = false;
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            group("VAT Product Posting Groups")
            {
                field("Standard VAT Prod. Posting Grp."; Rec."VAT Prod. Post Grp. Standard")
                {
                    ToolTip = 'Specifies the standard VAT product posting group.';
                }
                field("Reduced VAT Prod. Posting Grp."; Rec."VAT Prod. Post Grp. Reduced")
                {
                    ToolTip = 'Specifies the reduced VAT product posting group.';
                }
                field("No VAT Prod. Posting Grp."; Rec."VAT Prod. Post Grp. NO VAT")
                {
                    ToolTip = 'Specifies the NO VAT product posting group.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.InitRecord();
    end;
}