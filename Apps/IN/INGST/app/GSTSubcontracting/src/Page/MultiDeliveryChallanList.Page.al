// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

page 18497 "Multi. Delivery Challan List"
{
    Caption = 'Multi. Delivery Challan List';
    ApplicationArea = Basic, Suite;
    CardPageID = "Multiple Delivery Challan";
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    UsageCategory = Lists;
    SourceTable = "Delivery Challan Header";
    SourceTableView = sorting("No.") order(Ascending);

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(Vendor; Vendor)
                {
                    Caption = 'Vendor Filter';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number filter.';
                    TableRelation = Vendor."No." where(Subcontractor = const(true));

                    trigger OnValidate()
                    begin
                        FilterRecords();
                        CurrPage.Update();
                    end;
                }
                field(Days; Days)
                {

                    Caption = 'Days';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of days till which the list will be filtered.';

                    trigger OnValidate()
                    begin
                        FilterRecords();
                        CurrPage.Update();
                    end;
                }
                field(SubConorderNo; SubConorderNo)
                {
                    Caption = 'Subcon order No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting order number filter.';
                    TableRelation = "Purchase Header"."No.";

                    trigger OnValidate()
                    begin
                        FilterRecords();
                        CurrPage.Update();
                    end;
                }
                field(RemainingQuantity; RemainingQuantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether there is any remaining quantities available or not.';
                    Caption = 'Pending Quantities Exist';

                    trigger OnValidate()
                    begin
                        FilterRecords();
                        CurrPage.Update();
                    end;
                }
            }
            repeater(Control1)
            {
                Editable = false;
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontractor vendor number.';
                }
                field("No."; Rec."No.")
                {
                    Caption = 'Delivery Challan No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery challan number.';
                }
                field("Sub. order No."; Rec."Sub. order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery challan number.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan date of the delivery challan.';
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
            group("&Delivery Challan")
            {
                Caption = '&Delivery Challan';
                Image = OutboundEntry;
                action("&Card")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Card';
                    ToolTip = 'Card';
                    Image = EditLines;
                    RunObject = Page "Multiple Delivery Challan";
                    RunPageLink = "No." = Field("No.");
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Remaining Quantity");
    end;

    local procedure FilterRecords()
    begin
        Rec.Reset();
        if Vendor <> '' then
            Rec.SetRange("Vendor No.", Vendor);

        if SubConorderNo <> '' then begin
            Rec.SetRange("Sub. order No.", SubConorderNo);
            PurchHeader.Reset();
            PurchHeader.SetRange(Subcontracting, true);
            if Vendor <> '' then
                PurchHeader.SetRange("Buy-from Vendor No.", Vendor);
        end;

        if RemainingQuantity then
            Rec.SetRange("Remaining Quantity", true);

        DtParam := Format(Days);
        DtParam := '-' + DtParam + 'D';
        DtFilter := CalcDate(DtParam, Today());
        if Days <> 0 then
            Rec.SetRange("Challan Date", DtFilter, WorkDate());
    end;

    var
        PurchHeader: Record "Purchase Header";
        Vendor: Code[20];
        SubConorderNo: Code[20];
        Days: Integer;
        DtFilter: Date;
        DtParam: Text[10];
        RemainingQuantity: Boolean;
}
