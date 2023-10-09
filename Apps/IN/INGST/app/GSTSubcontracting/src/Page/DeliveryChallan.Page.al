// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;

page 18468 "Delivery Challan"
{
    Caption = 'Delivery Challan';
    PageType = Document;
    SourceTable = "Delivery Challan Header";

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
                    ToolTip = 'Specifies the subcontracting delivery challan number.';
                    Editable = false;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontractor vendor number.';
                }
                field("Item No."; Rec."Item No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the parent item number.';
                }
                field(Description; Rec.Description)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the parent item description.';
                }
                field("Process Description"; Rec."Process Description")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting process description.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan date.';
                }
                field("Commissioner's Permission No."; Rec."Commissioner's Permission No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the commissioner permission number of the subcontrctor.';
                }
                field("Sub. order No."; Rec."Sub. order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting order number.';
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production order number this order is lined to.';
                }
                field("Quantity for rework"; Rec."Quantity for rework")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity sent for rework';
                }
            }
            part(SubDCLines; "Delivery Challan Subform")
            {
                Editable = false;
                SubPageLink = "Delivery Challan No." = field("No.");
                ApplicationArea = Basic, Suite;
            }
        }
        area(FactBoxes)
        {
            part(TaxInformation; "Tax Information Factbox")
            {
                Provider = SubDCLines;
                SubPageLink = "Table ID Filter" = const(18469), "Document No. Filter" = field("Delivery Challan No."), "Line No. Filter" = field("Line No.");
                ApplicationArea = Basic, Suite;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("&Print")
            {
                Caption = '&Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Print';

                trigger OnAction()
                var
                    DCHeader: Record "Delivery Challan Header";
                begin
                    DCHeader.Reset();
                    DCHeader := Rec;
                    DCHeader.SetRecFilter();

                    Report.Run(Report::"Delivery Challan", true, false, DCHeader);
                end;
            }
        }
    }
}
