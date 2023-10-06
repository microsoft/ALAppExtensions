// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Subcontracting;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.Vendor;

page 18470 "Delivery Challan List"
{
    Caption = 'Delivery Challan List';
    CardPageID = "Delivery Challan";
    DeleteAllowed = false;
    Editable = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SourceTable = "Delivery Challan Header";
    SourceTableView = sorting("No.") order(ascending);

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
                    ToolTip = 'Specifies the subcontracting vendor as filter.';
                    TableRelation = Vendor."No." where(Subcontractor = const(true));

                    trigger OnValidate()
                    begin
                        FilterRecords();
                        VendorOnAfterValidate();
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
                        DaysOnAfterValidate();
                    end;
                }
                field(SubConOrderNo; Rec."Sub. order No.")
                {
                    Caption = 'Subcon Order No.';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies any specific subcontracting order filter.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        PurchaseListForm: Page "Purchase Order Subform";
                    begin
                        FilterRecords();
                        PurchaseListForm.SetTableView(PurchHeader);
                        PurchaseListForm.LookupMode(true);
                        if PurchaseListForm.RunModal() = Action::LookupOK then begin
                            PurchaseListForm.GetRecord(PurchHeader);
                            Rec."Sub. order No." := PurchHeader."No.";
                            FilterRecords();
                            CurrPage.Update();
                        end;
                    end;

                    trigger OnValidate()
                    begin
                        FilterRecords();
                        SubConOrderNoOnAfterValidate();
                    end;
                }
                field(RemainingQuantity; RemainingQuantity)
                {
                    Caption = 'Pending Quantities Exist';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether there is any remaining quantity available or not.';
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
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor code.';
                }
                field("Sub. order No."; Rec."Sub. order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the subcontracting vendor number.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posted delivery challan number.';
                }
                field("Prod. Order No."; Rec."Prod. Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the production order number this order is linked to.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the finished material code.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the item description.';
                }
                field("Challan Date"; Rec."Challan Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the date of the delivery challan.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date of the document.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("DeliveryChallan")
            {
                Caption = '&Delivery Challan';
                Image = OutboundEntry;
                action("DeliveryChallanCard")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Card';
                    ToolTip = 'Card';
                    Image = EditLines;
                    RunObject = Page "Delivery Challan";
                    RunPageLink = "No." = field("No.");
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Rec.CalcFields("Remaining Quantity");
    end;

    procedure FilterRecords()
    begin
        Rec.Reset();
        if Vendor <> '' then
            Rec.SetRange("Vendor No.", Vendor);

        if SubConOrderNo <> '' then begin
            Rec.SetRange("Sub. order No.", SubConOrderNo);
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
            PurchaseLine.Description :=
                    'Challan No ' + DeliveryChallanLine."Delivery Challan No." + ' Item No ' + DeliveryChallanLine."Item No.";
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

    local procedure SubConOrderNoOnAfterValidate()
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
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        PurchHeader: Record "Purchase Header";
        Vendor: Code[20];
        LineNo: Integer;
        Days: Integer;
        DtFilter: Date;
        DtParam: Text[20];
        RemainingQuantity: Boolean;
        SubConOrderNo: code[20];
}
