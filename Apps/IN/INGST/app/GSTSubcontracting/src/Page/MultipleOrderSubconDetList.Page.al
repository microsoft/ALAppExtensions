// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18477 "Multiple Order Subcon Det List"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Multiple Order Subcon Dispatch List';
    CardPageID = "Multiple Order Subcon Delivery";
    Editable = false;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Multiple Subcon. Order Details";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the multiple order subcon delivery number.';
                }
                field("Subcontractor No."; Rec."Subcontractor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontractor number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the entry.';
                }
                field("No. Series"; Rec."No. Series")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the assigned number series Code.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document date of the entry.';
                }
                field("Vendor Shipment No."; Rec."Vendor Shipment No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor shipment number.';
                }
            }
        }
    }
}
