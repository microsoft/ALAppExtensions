// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
#if not CLEAN22
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

page 18475 "Multiple Delivery Challan List"
{
    ObsoleteState = Pending;
    ObsoleteReason = 'Replaced by New Page Multi. Delivery Challan List';
    ObsoleteTag = '22.0';
    ApplicationArea = Basic, Suite;
    Caption = 'Multiple Delivery Challan List';
    CardPageID = "Multiple Delivery Challan";
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
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
                Field(Vendor; Vendor)
                {
                    Caption = 'Vendor Filter';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number filter.';
                    TableRelation = Vendor."No." Where(Subcontractor = const(true));

                    trigger OnValidate()
                    begin
                        FilterRecords();
                        VendorOnAfterValidate();
                    end;
                }
                Field(Days; Days)
                {

                    Caption = 'Days';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of days till which the list will be filtered.';

                    trigger OnValidate()
                    begin
                        FilterRecords();
                        DaysOnAfterValidate();
                    end;
                }
                Field(SubConorderNo; SubConorderNo)
                {
                    Caption = 'Subcon order No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting order number filter.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PurchaseListForm: Page "Purchase List";
                    begin
                        FilterRecords();
                        PurchaseListForm.SetTableView(PurchHeader);
                        PurchaseListForm.LookupMode(true);
                        if PurchaseListForm.RunModal() = Action::LookupOK then begin
                            PurchaseListForm.GetRecord(PurchHeader);
                            SubConorderNo := PurchHeader."No.";
                            FilterRecords();
                            CurrPage.Update();
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        FilterRecords();
                        SubConorderNoOnAfterValidate();
                    end;
                }
                Field(RemainingQuantity; RemainingQuantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether there is any remaining quantities available or not.';
                    Caption = 'Pending Quantities Exist';

                    trigger OnValidate()
                    begin
                        FilterRecords();
                        RemainingQuantityOnAfterValida();
                    end;
                }
            }
            repeater(Control1)
            {
                Editable = false;
                Field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontractor vendor number.';
                }
                Field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the delivery challan number.';
                }
                Field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the challan date of the delivery challan.';
                }
                Field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the entry.';
                }
            }
        }
    }

    Actions
    {
        area(navigation)
        {
            group("&Delivery Challan")
            {
                Caption = '&Delivery Challan';
                Image = OutboundEntry;
                Action("&Card")
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

    trigger OnOpenPage()
    begin
        Error(UnusedPageLbl);
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Remaining Quantity");
    end;

    procedure FilterRecords()
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

    procedure CreateDebitNoteHeader(var PurchHeader: Record "Purchase Header")
    begin
        PurchaseHeader.Init();
        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::"Credit Memo";
        PurchaseHeader."No." := '';
        PurchaseHeader.Insert(true);
        PurchaseHeader.Validate("Buy-from Vendor No.", PurchHeader."Buy-from Vendor No.");
        PurchaseHeader.Subcontracting := true;
        PurchaseHeader.Modify();
    end;

    procedure CreateDebitNoteLines(DeliveryChallanLine: Record "Delivery Challan Line")
    var
        GLAccount: Record "G/L Account";
    begin
        repeat
            PurchaseLine.Reset();
            PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::"Credit Memo");
            PurchaseLine.SetFilter("Document No.", PurchaseHeader."No.");
            if PurchaseLine.FindFirst() then
                LineNo += 10000
            else
                LineNo := 10000;

            PurchaseLine.Init();
            PurchaseLine."Document Type" := PurchaseHeader."Document Type";
            PurchaseLine."Document No." := PurchaseHeader."No.";
            PurchaseLine."Line No." := LineNo;
            PurchaseLine.Description := 'Challan No ' + DeliveryChallanLine."Delivery Challan No." + ' Item No ' +
              DeliveryChallanLine."Item No.";
            PurchaseLine.Validate("Buy-from Vendor No.", DeliveryChallanLine."Vendor No.");
            PurchaseLine.Type := PurchaseLine.Type::"G/L Account";
            GLAccount.Get(PurchaseLine."No.");
            PurchaseLine."Gen. Bus. Posting Group" := GLAccount."Gen. Bus. Posting Group";
            PurchaseLine."Gen. Prod. Posting Group" := GLAccount."Gen. Prod. Posting Group";
            PurchaseLine.Validate(Quantity, 1);
            PurchaseLine.Subcontracting := true;
            PurchaseLine.Insert();
        until DeliveryChallanLine.Next() = 0;
    end;

    local procedure SubConorderNoOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    local procedure RemainingQuantityOnAfterValida()
    begin
        CurrPage.Update();
    end;

    local procedure VendorOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    local procedure DaysOnAfterValidate()
    begin
        CurrPage.Update();
    end;

    var
        PurchHeader: Record "Purchase Header";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        Vendor: Code[20];
        SubConorderNo: Code[20];
        LineNo: Integer;
        Days: Integer;
        DtFilter: Date;
        DtParam: Text[10];
        RemainingQuantity: Boolean;

        UnusedPageLbl: Label 'This Page has been marked as obsolete and will be removed from version 22.0. Instead of this Page use â€˜Multi. Delivery Challan List';
}
#endif
