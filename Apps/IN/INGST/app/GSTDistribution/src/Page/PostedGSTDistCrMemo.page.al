// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Distribution;

page 18208 "Posted GST Dist.- Cr. Memo"
{
    Caption = 'Posted GST Dist.- Cr. Memo';
    UsageCategory = Documents;
    ApplicationArea = Basic, Suite;
    Editable = false;
    PageType = Card;
    SourceTable = "Posted GST Distribution Header";
    SourceTableView = where("ISD Document Type" = const("Credit Memo"));

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posted document number.';
                }
                field("From GSTIN No."; Rec."From GSTIN No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST registration number  of the GST distributing location.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry''s posting date.';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the creation date of the document.';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the user who created the document.';
                }
                field("From Location Code"; Rec."From Location Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the location from which GST credit will be distributed.';
                }
                field("Dist. Credit Type"; Rec."Dist. Credit Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the credit type has to be availed or not.';
                }
                field("Distribution Basis"; Rec."Distribution Basis")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the distribution basis on which distribution has to be done.';
                }
                field("Pre Distribution No."; Rec."Pre Distribution No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number assigned to the distribution before posting.Specifies the document number assigned to the distribution before posting.';
                }
            }
            part(PostedGSTDistSubform; "Posted GST Dist. Subform")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                SubPageLink = "Distribution No." = field("No.");
            }
        }
    }
}

