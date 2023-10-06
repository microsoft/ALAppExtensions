// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18473 "Multi Delivery Challan Subform"
{
    Caption = 'Multi Delivery Challan Subform';
    PageType = ListPart;
    SourceTable = "Delivery Challan Line";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting order number.';
                }
                field("Production Order No."; Rec."Production Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the released production order number.';
                }
                field("Parent Item No."; Rec."Parent Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the finished material code.';
                }
                field("Process Description"; Rec."Process Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of process.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component code for the parent item.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure code of item.';
                }
                field("Quantity at Vendor Location"; Rec."Quantity at Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total quantity left at vendor location.';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining quantities.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total quantity mentioned in subcontracting order.';
                }
                field("Components in Rework Qty."; Rec."Components in Rework Qty.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component rework quantity.';
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
                field("Last Date"; Rec."Last Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Last Date';
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
