// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GST.Purchase;

using Microsoft.Finance.GST.Base;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Utilities;

codeunit 18153 "GST Canc Corr Purch Inv Credit"
{
    var
        PostedInvoiceIsPaidCancelErr: Label 'You cannot cancel this posted purchase invoice because it is fully or partially paid.\\To reverse a paid purchase invoice, you must manually create a purchase credit memo.';
        CorrectCancellPurchInvErr: Label 'You cannot cancel this posted purchase invoice because GST Vendor Type is Import.\\You must manually create a purchase credit memo.';
        CorrectCancellCrMemoErr: Label 'You cannot cancel this posted purchase Credit Memo because GST Vendor Type is Import.\\You must manually create a purchase Invoice.';
        UnappliedErr: Label 'You cannot cancel this posted purchase credit memo because it is fully or partially applied.\\To reverse an applied purchase credit memo, you must manually unapply all applied entries.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Purch. Invoice", 'OnAfterCreateCorrectivePurchCrMemo', '', false, false)]
    local procedure UpdateReferenceInvoiceNo(PurchInvHeader: Record "Purch. Inv. Header"; var PurchaseHeader: Record "Purchase Header"; var CancellingOnly: Boolean)
    begin
        CreateReferenceInvoiceNo(PurchInvHeader, PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Correct Posted Purch. Invoice", 'OnBeforeTestIfInvoiceIsPaid', '', false, false)]
    local procedure OnBeforeTestGSTPurchaseInvoiceIsPaid(var PurchInvHeader: Record "Purch. Inv. Header"; var IsHandled: Boolean)
    begin
        TestGSTTDSTCSPurchaseInvoiceIsPaid(PurchInvHeader, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cancel Posted Purch. Cr. Memo", 'OnBeforeTestIfUnapplied', '', false, false)]
    local procedure OnBeforeTestIfUnapplied(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var IsHandled: Boolean)
    begin
        TestGSTTDSTCSPurchCrMemoUnapplied(PurchCrMemoHdr, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnAfterCopyPurchaseDocument', '', false, false)]
    local procedure CalculateTaxOnPurchaseLine(var ToPurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        CalculateTax: Codeunit "Calculate Tax";
    begin
        PurchaseLine.Reset();
        PurchaseLine.SetRange("Document Type", ToPurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", ToPurchaseHeader."No.");
        PurchaseLine.SetFilter(Type, '<>%1', PurchaseLine.Type::" ");
        if PurchaseLine.FindSet() then
            repeat
                CalculateTax.CallTaxEngineOnPurchaseLine(PurchaseLine, PurchaseLine);
            until PurchaseLine.Next() = 0;
    end;

    local procedure TestGSTTDSTCSPurchaseInvoiceIsPaid(var PurchInvHeader: Record "Purch. Inv. Header"; var IsHandled: Boolean)
    var
        PurchInvLine: Record "Purch. Inv. Line";
        TaxTransactionValue: Decimal;
        IsPaid: Boolean;
    begin
        if PurchInvHeader."GST Vendor Type" = PurchInvHeader."GST Vendor Type"::" " then
            exit;

        if PurchInvHeader."GST Vendor Type" in [PurchInvHeader."GST Vendor Type"::Import] then
            Error(CorrectCancellPurchInvErr);

        PurchInvLine.Reset();
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        PurchInvLine.SetFilter(Type, '<>%1', PurchInvLine.Type::" ");
        if PurchInvLine.FindSet() then
            repeat
                TaxTransactionValue += FilterTaxTransactionValue(PurchInvLine.RecordId);
            until PurchInvLine.Next() = 0;

        IsHandled := true;
        PurchInvHeader.CalcFields("Amount Including VAT");
        PurchInvHeader.CalcFields("Remaining Amount");

        onBeforeCheckPostedPurchaseAmountonCancellation(PurchInvHeader, PurchInvLine, TaxTransactionValue, IsPaid);
        if not IsPaid then
            if not PurchInvLine."GST Reverse Charge" then begin
                if (PurchInvHeader."Amount Including VAT" + TaxTransactionValue) <> PurchInvHeader."Remaining Amount" then
                    Error(PostedInvoiceIsPaidCancelErr);
            end else
                if (PurchInvHeader."Amount Including VAT") <> PurchInvHeader."Remaining Amount" then
                    Error(PostedInvoiceIsPaidCancelErr);
    end;


    local procedure FilterTaxTransactionValue(RecordId: RecordId): Decimal
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Record ID", RecordId);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        TaxTransactionValue.CalcSums(TaxTransactionValue.Amount);
        exit(TaxTransactionValue.Amount);
    end;

    local procedure CreateReferenceInvoiceNo(PurchInvHeader: Record "Purch. Inv. Header"; var PurchaseHeader: Record "Purchase Header")
    var
        ReferenceInvoiceNo: Record "Reference Invoice No.";
    begin
        if not IsGSTApplicable(PurchInvHeader) then
            exit;

        ReferenceInvoiceNo.Init();
        ReferenceInvoiceNo."Document Type" := ReferenceInvoiceNo."Document Type"::"Credit Memo";
        ReferenceInvoiceNo."Document No." := PurchaseHeader."No.";
        ReferenceInvoiceNo."Source Type" := ReferenceInvoiceNo."Source Type"::Vendor;
        ReferenceInvoiceNo."Source No." := PurchaseHeader."Pay-to Vendor No.";
        ReferenceInvoiceNo."Reference Invoice Nos." := PurchInvHeader."No.";
        ReferenceInvoiceNo.Verified := true;
        ReferenceInvoiceNo.Insert();
    end;

    local procedure IsGSTApplicable(PurchInvHeader: Record "Purch. Inv. Header"): Boolean
    var
        GSTSetup: Record "GST Setup";
        PurchInvLine: Record "Purch. Inv. Line";
        TaxTransactionFound: Boolean;
    begin
        if not GSTSetup.Get() then
            exit;

        PurchInvLine.Reset();
        PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
        PurchInvLine.SetFilter(Type, '<>%1', PurchInvLine.Type::" ");
        if PurchInvLine.FindSet() then
            repeat
                GSTSetup.TestField("GST Tax Type");
                TaxTransactionFound := FilterTaxTransactionValue(GSTSetup."GST Tax Type", PurchInvLine.RecordId);
            until PurchInvLine.Next() = 0
        else
            exit(false);

        exit(TaxTransactionFound);
    end;

    local procedure TestGSTTDSTCSPurchCrMemoUnapplied(var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; var IsHandled: Boolean)
    var
        PurchCrMemoLine: Record "Purch. Cr. Memo Line";
        TaxTransactionValue: Decimal;
    begin
        if PurchCrMemoHdr."GST Vendor Type" = PurchCrMemoHdr."GST Vendor Type"::" " then
            exit;

        if PurchCrMemoHdr."GST Vendor Type" in [PurchCrMemoHdr."GST Vendor Type"::Import] then
            Error(CorrectCancellCrMemoErr);

        PurchCrMemoLine.Reset();
        PurchCrMemoLine.SetRange("Document No.", PurchCrMemoHdr."No.");
        PurchCrMemoLine.SetFilter(Type, '<>%1', PurchCrMemoLine.Type::" ");
        if PurchCrMemoLine.FindSet() then
            repeat
                TaxTransactionValue += FilterTaxTransactionValue(PurchCrMemoLine.RecordId);
            until PurchCrMemoLine.Next() = 0;

        IsHandled := true;
        PurchCrMemoHdr.CalcFields("Amount Including VAT");
        PurchCrMemoHdr.CalcFields("Remaining Amount");
        if (PurchCrMemoHdr."Amount Including VAT" + TaxTransactionValue) <> -PurchCrMemoHdr."Remaining Amount" then
            Error(UnappliedErr);
    end;

    local procedure FilterTaxTransactionValue(TaxTypeSetupCode: Code[10]; RecordId: RecordId): Boolean
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.SetCurrentKey("Tax Record ID", "Tax Type");
        TaxTransactionValue.SetRange("Tax Type", TaxTypeSetupCode);
        TaxTransactionValue.SetRange("Tax Record ID", RecordId);
        TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
        if not TaxTransactionValue.IsEmpty() then
            exit(true);
    end;

    [IntegrationEvent(false, false)]
    local procedure onBeforeCheckPostedPurchaseAmountonCancellation(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchInvLine: Record "Purch. Inv. Line"; var TaxTransactionValue: Decimal; var IsPaid: Boolean)
    begin
    end;
}
