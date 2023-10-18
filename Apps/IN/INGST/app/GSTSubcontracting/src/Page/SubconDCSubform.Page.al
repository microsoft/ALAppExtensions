// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18489 "Subcon. DC Subform"
{
    AutoSplitKey = true;
    Caption = 'Subcon. DC Subform';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Subcon. Delivery Challan Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item number is linked to.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure of the item.';
                }
                field("Quantity To Send"; Rec."Quantity To Send")
                {
                    ApplicationArea = Basic, Suite;
                    Tooltip = 'Specifies the quantity needs to be sent.';
                }
                field("Quantity To Send (Base)"; Rec."Quantity To Send (Base)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity needs to send (base)';
                }
                field("Company Location"; Rec."Company Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company location for the subcontrcting order.';
                }
                field("Vendor Location"; Rec."Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor location for the subcontracting order.';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general product posting group of the item is linked to.';
                }
                field("Applies-to Entry"; Rec."Applies-to Entry")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the applies to entry number of the item is linked to.';
                }
            }
        }
    }
}
