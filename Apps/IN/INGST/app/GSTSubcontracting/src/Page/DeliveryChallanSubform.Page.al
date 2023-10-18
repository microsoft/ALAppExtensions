// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18471 "Delivery Challan Subform"
{
    Caption = 'Delivery Challan Subform';
    PageType = ListPart;
    SourceTable = "Delivery Challan Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item number of this document.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure of the item is linked to.';
                }
                field("Quantity at Vendor Location"; Rec."Quantity at Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity at vendor location of the item is linked to.';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining quantity of the item is linked to.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of the item is linked to.';
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST Group code for the calculation of GST on Delivery Challan line.';
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the HSN/SAC code for the calculation of GST on Delivery Challan line.';
                }
                field("Components in Rework Qty."; Rec."Components in Rework Qty.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the rework component quantity of the item is linked to.';
                }
                field("Last Date"; Rec."Last Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the last date for the job work return period.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Dimensions';
                    ToolTip = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction()
                    begin
                        ShowDimension();
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Prod. BOM Quantity");
    end;

    procedure ShowDimension()
    begin
        Rec.ShowDimensions();
    end;
}
