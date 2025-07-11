// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Warehouse.GateEntry;

page 18611 "Outward Gate Entry SubForm"
{
    AutoSplitKey = true;
    Caption = 'Outward Gate Entry SubForm';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Gate Entry Line";

    layout
    {
        area(content)
        {
            repeater(list)
            {
                field("Challan No."; Rec."Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan number.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan date.';
                }
                field("Source Type"; Rec."Source Type")
                {
                    ApplicationArea = Basic, Suite;
                    ValuesAllowed = " ", "Sales Shipment", "Purchase Return Shipment", "Transfer Shipment";
                    ToolTip = 'Specifies the type of source document for which the document is created.';
                }
                field("Source No."; Rec."Source No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of source document for which the document is created.';
                }
                field("Source Name"; Rec."Source Name")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of customer/vendor for which the document is created.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'specifies the description of the challan document.';
                }
            }
        }
    }
}
