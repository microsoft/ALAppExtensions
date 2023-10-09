// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

page 18469 "Delivery Challan Line"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Delivery Challan Line';
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "Delivery Challan Line";
    SourceTableView = sorting("Delivery Challan No.", "Line No.") order(ascending);

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting delivery challan number.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting delivery challan line number.';
                }
                field("Parent Item No."; Rec."Parent Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the finished item code.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component code for the parent item.';
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the unit of measure of item.';
                }
                field("Prod. BOM Quantity"; Rec."Prod. BOM Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of released production order.';
                }
                field("Quantity To Send"; Rec."Quantity To Send")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantities that need to be sent to vendor location.';
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base quantity.';
                }
                field("Quantity To Send (Base)"; Rec."Quantity To Send (Base)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the base quantity to send.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of component.';
                }
                field(Position; Rec.Position)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the position.';
                }
                field("Position 2"; Rec."Position 2")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the position.2';
                }
                field("Position 3"; Rec."Position 3")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the position 3.';
                }
                field("Production Lead Time"; Rec."Production Lead Time")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production lead time.';
                }
                field("Routing Link Code"; Rec."Routing Link Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the routing link code.';
                }
                field("Scrap %"; Rec."Scrap %")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the percentage of scrap.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the variant code of item, if any.';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the start date.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the end date.';
                }
                field(Length; Rec.Length)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the length.';
                }
                field(Width; Rec.Width)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the width.';
                }
                field(Weight; Rec.Weight)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the weight.';
                }
                field(Depth; Rec.Depth)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the depth.';
                }
                field("Calculation Formula"; Rec."Calculation Formula")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the calculation formula.';
                }
                field("Quantity per"; Rec."Quantity per")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the per quantity requirement of a component for manufacturing the parent item.';
                }
                field("Company Location"; Rec."Company Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the company location from which components need to be sent.';
                }
                field("Vendor Location"; Rec."Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the vendor location.';
                }
                field("Production Order No."; Rec."Production Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the released production order number.';
                }
                field("Production Order Line No."; Rec."Production Order Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the released production order line number.';
                }
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line type.';
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the general product posting group.';
                }
                field("Quantity at Vendor Location"; Rec."Quantity at Vendor Location")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total quantity left at vendor location.';
                }
                field("Total Scrap Quantity"; Rec."Total Scrap Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the total scrap quantity.';
                }
                field("Delivery Challan No."; Rec."Delivery Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery challan number.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery challan line number.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of component.';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining quantity.';
                }
                field("Components in Rework Qty."; Rec."Components in Rework Qty.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the component rework quantity.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date for the entry.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number.';
                }
                field("Process Description"; Rec."Process Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of process.';
                }
                field("Prod. Order Comp. Line No."; Rec."Prod. Order Comp. Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the released production order component line number.';
                }

                field("Debit Note Created"; Rec."Debit Note Created")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether debit note has been created or not.';
                }
                field("Return Date"; Rec."Return Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the return date.';
                }
                field("Last Date"; Rec."Last Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date by when vendor should return the finished material as per GST law.';
                }
                field("GST Group Code"; Rec."GST Group Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an unique identifier for the GST group code used to calculate and post GST.';
                }
                field("HSN/SAC Code"; Rec."HSN/SAC Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies an unique identifier for the type of HSN or SAC that is used to calculate and post GST.';
                }
                field("GST Base Amount"; Rec."GST Base Amount")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the amount that the GST amount is calculated from.';
                }
                field("GST Liability Created"; Rec."GST Liability Created")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether GST liability has been created or not.';
                }
                field("GST Amount Remaining"; Rec."GST Amount Remaining")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining GST amount.';
                }
                field("Job Work Return Period"; Rec."Job Work Return Period")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the stipulated time period for return of material from subcontracting location, advised as per authorized body.';
                }
                field("GST Credit"; Rec."GST Credit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the GST credit has to be availed or not.';
                }
                field(Exempted; Rec.Exempted)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the line is exempted of GST.';
                }
                field("GST Jurisdiction Type"; Rec."GST Jurisdiction Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the type related to GST jurisdiction. For example, interstate/intrastate.';
                }
            }
        }
    }

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;
}
