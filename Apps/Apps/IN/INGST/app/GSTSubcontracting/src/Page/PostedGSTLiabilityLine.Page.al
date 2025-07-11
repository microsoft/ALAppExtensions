// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18484 "Posted GST Liability Line"
{
    Caption = 'Posted GST Liability Line';
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "Posted GST Liability Line";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(control1)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the Document line number.';
                    Visible = false;
                }
                field("Liability Document No."; Rec."Liability Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the liability document number.';
                }
                field("Liability Document Line No."; Rec."Liability Document Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the liability document line number.';
                    Visible = false;
                }
                field("Parent Item No."; Rec."Parent Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the parent item.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component code for the parent item.';
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shortcut dimension 1 code.';
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the shortcut dimension 2 code.';
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure of component.';
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of component.';
                    Editable = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the variant code of the component';
                    Visible = false;
                }
                field("Company Location"; Rec."Company Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company location for the document.';
                    Visible = false;
                }
                field("Vendor Location"; Rec."Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor location for the document.';
                    Visible = false;
                }
                field("Production Order No."; Rec."Production Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production order number is linked to.';
                    Visible = false;
                }
                field("Production Order Line No."; Rec."Production Order Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production order line number is linked to.';
                    Visible = false;
                }
                field("Quantity at Vendor Location"; Rec."Quantity at Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity at vendor location of the component.';
                    Visible = false;
                }
                field("Delivery Challan No."; Rec."Delivery Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery challan number.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number.';
                    Visible = false;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of the component.';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining quantity of the component.';
                }
                field("Components in Rework Qty."; Rec."Components in Rework Qty.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the components in rework quantity.';
                    Visible = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the entry.';
                    Visible = false;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number.';
                    Visible = false;
                }
                field("Process Description"; Rec."Process Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting process description.';
                    Visible = false;
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST group code of the component.';
                    Visible = false;
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the HSN/SAC code of the component.';
                    Visible = false;
                }
                field("GST Base Amount"; Rec."GST Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the GST base amount of the component.';
                    Visible = false;
                }
                field("GST Liability Created"; Rec."GST Liability Created")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST liability is created.';
                    Visible = false;
                }
                field("Last Date"; Rec."Last Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the last date for job work return period.';
                    Visible = false;
                }
            }
        }
    }
}
