// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.TaxEngine.TaxTypeHandler;

page 18474 "Multiple Delivery Challan"
{
    Caption = 'Multiple Delivery Challan';
    PageType = Document;
    DeleteAllowed = false;
    Editable = false;
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
                    ToolTip = 'Specifies the delivery challan number.';
                    Editable = false;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of the delivery challan.';
                    Editable = false;
                }
                field("Quantity for rework"; Rec."Quantity for rework")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of rework.';
                }
            }
            part(SubDCLines; "Multi Delivery Challan Subform")
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
                ToolTip = 'Print';
                Ellipsis = true;
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;
                ApplicationArea = Basic, Suite;

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
