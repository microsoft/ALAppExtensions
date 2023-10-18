// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Vendor;

page 18494 "Sub. Item Tracking"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Sub. Item Tracking';
    PageType = Worksheet;
    UsageCategory = Tasks;
    SourceTable = "Delivery Challan Line";

    layout
    {
        area(content)
        {
            field(Vendor; Vendor)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Vendor Filter';
                ToolTip = 'Specifies the vendor filter';
                TableRelation = Vendor;

                trigger OnValidate()
                begin
                    Rec.SetFilter("Vendor No.", Vendor);
                end;
            }
            field("Only Remaining Qtys."; "Only Remaining Qtys.")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Only Remaining Qty.';
                ToolTip = 'Specifies if only remaining quantity is needs to show.';

                trigger OnValidate()
                begin
                    if "Only Remaining Qtys." then begin
                        Rec.Reset();
                        Rec.SetFilter("Vendor No.", Vendor);
                        Rec.SetFilter("Remaining Quantity", '>0');
                    end
                    else begin
                        Rec.Reset();
                        Rec.SetFilter("Vendor No.", Vendor);
                    end;
                end;
            }
            repeater(Control1)
            {
                Editable = false;
                field("Delivery Challan No."; Rec."Delivery Challan No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery challan number.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item number is linked to.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the item';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity of the item.';
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the remaining quantity of the item.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the entry.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("F&unction")
            {
                Caption = 'F&unction';
                Image = "Action";
            }
        }
    }

    trigger OnInit()
    begin
        Rec.SetFilter(Quantity, '> 0');
        DeliveryChallanLine.Copy(Rec);
    end;

    var
        DeliveryChallanLine: Record "Delivery Challan Line";
        Vendor: Code[10];
        "Only Remaining Qtys.": Boolean;
}
