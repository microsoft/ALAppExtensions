// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.StockTransfer;

page 18391 "GST Tracking Entry"
{
    Caption = 'GST Tracking Entry';
    UsageCategory = Lists;
    ApplicationArea = Basic, Suite;
    Editable = false;
    PageType = List;
    SourceTable = "GST Tracking Entry";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the entry number.';
                }
                field("From Entry No."; Rec."From Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the from entry number.';
                }
                field("From To No."; Rec."From To No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the to entry number.';
                }
                field("Item Ledger Entry No."; Rec."Item Ledger Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item ledger entry number.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity.';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining quantity.';
                }
            }
        }
    }
}

