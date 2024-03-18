// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Calculation;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.FinanceCharge;
using Microsoft.Sales.History;
using Microsoft.Sales.Receivables;
using Microsoft.Service.History;

tableextension 11793 "VAT Amount Line CZL" extends "VAT Amount Line"
{
    fields
    {
        field(11782; "VAT Base (LCY) CZL"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Base (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11783; "VAT Amount (LCY) CZL"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'VAT Amount (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    var
        DocumentType: Enum "Gen. Journal Document Type";
        DocumentNo: Code[20];
        PostingDate: Date;
        SourceCode: Code[10];
        Sign: Integer;
        VATCurrFactor: Decimal;
        TransactionNo: Integer;

    procedure UpdateVATEntryLCYAmountsCZL(Variant: Variant)
    var
        Currency: Record Currency;
        TempTotalVATAmountLine: Record "VAT Amount Line" temporary;
        TempVATEntry: Record "VAT Entry" temporary;
        Factor: Decimal;
        SingleLine: Boolean;
    begin
        if Rec.IsEmpty() then
            exit;
        Clear(Currency);
        Currency.InitRoundingPrecision();

        SumPositiveAndNegativeVATAmountLines(TempTotalVATAmountLine);
        GetDocumentVATEntryBuffer(Variant, TempVATEntry);
        UpdateTotalLCYAmountsFromVATEntry(TempTotalVATAmountLine, TempVATEntry);

        if Rec.FindSet(true) then
            repeat
                TempTotalVATAmountLine.Get(Rec."VAT Identifier", Rec."VAT Calculation Type", Rec."Tax Group Code", Rec."Use Tax", false);
                SingleLine := (Rec."VAT Base" = TempTotalVATAmountLine."VAT Base") and (Rec."VAT Amount" = TempTotalVATAmountLine."VAT Amount");
                if Rec.Positive or SingleLine then begin
                    Rec."VAT Base (LCY) CZL" := TempTotalVATAmountLine."VAT Base (LCY) CZL";
                    Rec."VAT Amount (LCY) CZL" := TempTotalVATAmountLine."VAT Amount (LCY) CZL";
                end else begin
                    if (TempTotalVATAmountLine."VAT Base" + TempTotalVATAmountLine."VAT Amount") = 0 then
                        Factor := VATCurrFactor
                    else
                        Factor := (TempTotalVATAmountLine."VAT Base (LCY) CZL" + TempTotalVATAmountLine."VAT Amount (LCY) CZL") /
                            (TempTotalVATAmountLine."VAT Base" + TempTotalVATAmountLine."VAT Amount");
                    Rec."VAT Base (LCY) CZL" := Round((Rec."VAT Base" * Factor), Currency."Amount Rounding Precision");
                    Rec."VAT Amount (LCY) CZL" := Round((Rec."VAT Amount" * Factor), Currency."Amount Rounding Precision");
                    TempTotalVATAmountLine."VAT Base (LCY) CZL" -= Rec."VAT Base (LCY) CZL";
                    TempTotalVATAmountLine."VAT Amount (LCY) CZL" -= Rec."VAT Amount (LCY) CZL";
                    TempTotalVATAmountLine.Modify();
                end;
                Rec.Modify();
            until Rec.Next() = 0;
    end;

    local procedure GetDocumentVATEntryBuffer(Variant: Variant; var TempVATEntry: Record "VAT Entry")
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DocRecordRef: RecordRef;
        IsHandled: Boolean;
    begin
        DocRecordRef.GetTable(Variant);

        IsHandled := false;
        OnBeforeGetDocumentVATEntryBufferCZL(DocRecordRef, TempVATEntry, IsHandled);
        if IsHandled then
            exit;

        SetDocumentGlobals(DocumentType::" ", '', 0D, '', 0, 0, 0);
        case DocRecordRef.Number of
            Database::"Sales Invoice Header":
                begin
                    DocRecordRef.SetTable(SalesInvoiceHeader);
                    SetDocumentGlobals(DocumentType::Invoice,
                        SalesInvoiceHeader."No.",
                        SalesInvoiceHeader."Posting Date",
                        SalesInvoiceHeader."Source Code",
                        -1,
                        SalesInvoiceHeader."VAT Currency Factor CZL",
                        CustLedgerEntry.GetTransactionNoCZL(SalesInvoiceHeader."Cust. Ledger Entry No."));
                end;
            Database::"Sales Cr.Memo Header":
                begin
                    DocRecordRef.SetTable(SalesCrMemoHeader);
                    SetDocumentGlobals(DocumentType::"Credit Memo",
                        SalesCrMemoHeader."No.",
                        SalesCrMemoHeader."Posting Date",
                        SalesCrMemoHeader."Source Code",
                        1,
                        SalesCrMemoHeader."VAT Currency Factor CZL",
                        CustLedgerEntry.GetTransactionNoCZL(SalesCrMemoHeader."Cust. Ledger Entry No."));
                end;
            Database::"Purch. Inv. Header":
                begin
                    DocRecordRef.SetTable(PurchInvHeader);
                    SetDocumentGlobals(DocumentType::Invoice,
                        PurchInvHeader."No.",
                        PurchInvHeader."Posting Date",
                        PurchInvHeader."Source Code",
                        1,
                        PurchInvHeader."VAT Currency Factor CZL",
                        VendorLedgerEntry.GetTransactionNoCZL(PurchInvHeader."Vendor Ledger Entry No."));
                end;
            Database::"Purch. Cr. Memo Hdr.":
                begin
                    DocRecordRef.SetTable(PurchCrMemoHdr);
                    SetDocumentGlobals(DocumentType::"Credit Memo",
                        PurchCrMemoHdr."No.",
                        PurchCrMemoHdr."Posting Date",
                        PurchCrMemoHdr."Source Code",
                        -1,
                        PurchCrMemoHdr."VAT Currency Factor CZL",
                        VendorLedgerEntry.GetTransactionNoCZL(PurchCrMemoHdr."Vendor Ledger Entry No."));
                end;
            Database::"Issued Fin. Charge Memo Header":
                begin
                    DocRecordRef.SetTable(IssuedFinChargeMemoHeader);
                    SetDocumentGlobals(DocumentType::"Finance Charge Memo",
                        IssuedFinChargeMemoHeader."No.",
                        IssuedFinChargeMemoHeader."Posting Date",
                        IssuedFinChargeMemoHeader."Source Code",
                        -1,
                        1,
                        0);
                end;
            Database::"Service Invoice Header":
                begin
                    DocRecordRef.SetTable(ServiceInvoiceHeader);
                    SetDocumentGlobals(DocumentType::Invoice,
                        ServiceInvoiceHeader."No.",
                        ServiceInvoiceHeader."Posting Date",
                        ServiceInvoiceHeader."Source Code",
                        -1,
                        ServiceInvoiceHeader."VAT Currency Factor CZL",
                        0);
                end;
            Database::"Service Cr.Memo Header":
                begin
                    DocRecordRef.SetTable(ServiceCrMemoHeader);
                    SetDocumentGlobals(DocumentType::"Credit Memo",
                        ServiceCrMemoHeader."No.",
                        ServiceCrMemoHeader."Posting Date",
                        ServiceCrMemoHeader."Source Code",
                        1,
                        ServiceCrMemoHeader."VAT Currency Factor CZL",
                        0);
                end;
            else begin
                IsHandled := false;
                OnGetDocumentVATEntryBufferPerDocumentTypeCZL(DocRecordRef, DocumentType, DocumentNo, PostingDate, SourceCode, Sign, VATCurrFactor, TransactionNo, IsHandled);
            end;
        end;

        CopyDocumentVATEntriesToBuffer(TempVATEntry);

        OnAfterGetDocumentVATEntryBufferCZL(DocRecordRef, TempVATEntry);
    end;

    local procedure CopyDocumentVATEntriesToBuffer(var TempVATEntry: Record "VAT Entry")
    var
        VATEntry: Record "VAT Entry";
    begin
        VATEntry.Reset();
        if TransactionNo > 0 then begin
            VATEntry.SetCurrentKey("Transaction No.");
            VATEntry.SetRange("Transaction No.", TransactionNo);
        end else
            VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document Type", DocumentType);
        VATEntry.SetRange("Document No.", DocumentNo);
        VATEntry.SetRange("Posting Date", PostingDate);
        VATEntry.SetRange("Source Code", SourceCode);
        OnCopyDocumentVATEntriesToBufferOnAfterSetVATEntryFilterCZL(TransactionNo, DocumentType, DocumentNo, PostingDate, SourceCode, VATEntry);
        if VATEntry.FindSet() then
            repeat
                TempVATEntry := VATEntry;
                TempVATEntry.Insert();
            until VATEntry.Next() = 0;
    end;

    local procedure SumPositiveAndNegativeVATAmountLines(var TempTotalVATAmountLine: Record "VAT Amount Line")
    begin
        if Rec.FindSet() then
            repeat
                if TempTotalVATAmountLine.Get(Rec."VAT Identifier", Rec."VAT Calculation Type", Rec."Tax Group Code", Rec."Use Tax", false) then begin
                    TempTotalVATAmountLine."VAT Base" += Rec."VAT Base";
                    TempTotalVATAmountLine."VAT Amount" += Rec."VAT Amount";
                    TempTotalVATAmountLine.Modify();
                end else begin
                    TempTotalVATAmountLine.Init();
                    TempTotalVATAmountLine."VAT Identifier" := Rec."VAT Identifier";
                    TempTotalVATAmountLine."VAT Calculation Type" := Rec."VAT Calculation Type";
                    TempTotalVATAmountLine."Tax Group Code" := Rec."Tax Group Code";
                    TempTotalVATAmountLine."Use Tax" := Rec."Use Tax";
                    TempTotalVATAmountLine.Positive := false;
                    TempTotalVATAmountLine."VAT Base" := Rec."VAT Base";
                    TempTotalVATAmountLine."VAT Amount" := Rec."VAT Amount";
                    TempTotalVATAmountLine.Insert();
                end;
            until Rec.Next() = 0;
    end;

    local procedure UpdateTotalLCYAmountsFromVATEntry(var TempTotalVATAmountLine: Record "VAT Amount Line"; var TempVATEntry: Record "VAT Entry")
    begin
        if TempTotalVATAmountLine.FindSet(true) then
            repeat
                TempVATEntry.SetRange("VAT Identifier CZL", TempTotalVATAmountLine."VAT Identifier");
                TempVATEntry.SetRange("VAT Calculation Type", TempTotalVATAmountLine."VAT Calculation Type");
                TempVATEntry.SetRange("Tax Group Code", TempTotalVATAmountLine."Tax Group Code");
                TempVATEntry.SetRange("Use Tax", TempTotalVATAmountLine."Use Tax");
                if TempVATEntry.FindSet() then
                    repeat
                        TempTotalVATAmountLine."VAT Base (LCY) CZL" += Sign * TempVATEntry.Base;
                        TempTotalVATAmountLine."VAT Amount (LCY) CZL" += Sign * TempVATEntry.Amount;
                    until TempVATEntry.Next() = 0;
                TempTotalVATAmountLine.Modify();
            until TempTotalVATAmountLine.Next() = 0;
    end;

    local procedure SetDocumentGlobals(NewDocumentType: Enum "Gen. Journal Document Type"; NewDocumentNo: Code[20]; NewPostingDate: Date; NewSourceCode: Code[10];
                                        NewSign: Integer; NewVATCurrFactor: Decimal; NewTransactionNo: Integer);
    begin
        DocumentType := NewDocumentType;
        DocumentNo := NewDocumentNo;
        PostingDate := NewPostingDate;
        SourceCode := NewSourceCode;
        TransactionNo := NewTransactionNo;
        Sign := NewSign;
        VATCurrFactor := NewVATCurrFactor;
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeGetDocumentVATEntryBufferCZL(DocRecordRef: RecordRef; TempVATEntry: Record "VAT Entry"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetDocumentVATEntryBufferPerDocumentTypeCZL(DocRecordRef: RecordRef; var NewDocumentType: Enum "Gen. Journal Document Type"; var NewDocumentNo: Code[20]; var NewPostingDate: Date; var NewSourceCode: Code[10]; var NewSign: Integer; var NewVATCurrFactor: Decimal; var NewTransactionNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterGetDocumentVATEntryBufferCZL(DocRecordRef: RecordRef; var TempVATEntry: Record "VAT Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCopyDocumentVATEntriesToBufferOnAfterSetVATEntryFilterCZL(TransactionNo: Integer; DocumentType: Enum "Gen. Journal Document Type"; DocumentNo: Code[20]; PostingDate: Date; SourceCode: Code[10]; var VATEntry: Record "VAT Entry")
    begin
    end;
}
