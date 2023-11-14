// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.CashDesk;

using Microsoft.Finance;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Sales.Receivables;

codeunit 31083 "EET Management CZP"
{
    Permissions = tabledata "Posted Cash Document Hdr. CZP" = rm,
                  tabledata "EET Entry CZL" = rimd;

    var
        EETManagementCZL: Codeunit "EET Management CZL";
        MoreEETLinesDeniedErr: Label 'Cash document %1 %2 cannot contain more then one EET line.', Comment = '%1 = Cash Document Type;%2 = Cash Document No.';
        EntryDescriptionTxt: Label '%1 %2', Comment = '%1 = Applied Document Type;%2 = Applied Document No.';

    local procedure CheckEETTransaction(CashDocumentHeaderCZP: Record "Cash Document Header CZP"): Boolean
    begin
        exit(EETManagementCZL.IsEETEnabled() and CashDocumentHeaderCZP.IsEETTransaction());
    end;

    procedure CheckCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    var
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        NoOfLines: Integer;
        IsHandled: Boolean;
    begin
        OnBeforeCheckCashDocument(CashDocumentHeaderCZP, IsHandled);
        if IsHandled then
            exit;

        if not CheckEETTransaction(CashDocumentHeaderCZP) then
            exit;

        SetFilterCashDocumentLine(CashDocumentHeaderCZP, CashDocumentLineCZP);
        NoOfLines := CashDocumentLineCZP.Count();

        // All lines must be of EET
        CashDocumentLineCZP.SetRange("EET Transaction", true);
        if CashDocumentLineCZP.Count() < NoOfLines then begin
            CashDocumentLineCZP.SetRange("EET Transaction", false);
            CashDocumentLineCZP.FindFirst();
            CashDocumentLineCZP.TestField("EET Transaction");
        end;

        // If there is a line with cash desk event then all lines must be of cash desk event
        CashDocumentLineCZP.SetFilter("Cash Desk Event", '<>%1', '');
        if not CashDocumentLineCZP.IsEmpty() then
            if CashDocumentLineCZP.Count() < NoOfLines then begin
                CashDocumentLineCZP.SetRange("Cash Desk Event", '');
                CashDocumentLineCZP.FindFirst();
                CashDocumentLineCZP.TestField("Cash Desk Event");
            end;

        // If there is a line without cash desk event then must be with customer account type
        CashDocumentLineCZP.SetRange("Cash Desk Event", '');
        CashDocumentLineCZP.SetFilter("Account Type", '<>%1', CashDocumentLineCZP."Account Type"::Customer);
        if CashDocumentLineCZP.FindFirst() then
            CashDocumentLineCZP.TestField("Account Type", CashDocumentLineCZP."Account Type"::Customer);

        // If there is a line with customer account type then number of lines must be only one
        CashDocumentLineCZP.SetRange("Cash Desk Event");
        CashDocumentLineCZP.SetRange("Account Type", CashDocumentLineCZP."Account Type"::Customer);
        if CashDocumentLineCZP.FindFirst() then begin
            if NoOfLines > 1 then
                Error(MoreEETLinesDeniedErr, CashDocumentLineCZP."Document Type", CashDocumentLineCZP."Cash Document No.");

            CheckLineWithAppliedDocument(CashDocumentLineCZP, GetAppliedDocumentAmount(CashDocumentLineCZP));
        end;
    end;

    local procedure CheckLineWithAppliedDocument(CashDocumentLineCZP: Record "Cash Document Line CZP"; AppliedDocumentAmount: Decimal)
    var
        IsHandled: Boolean;
    begin
        OnBeforeCheckLineWithAppliedDocument(CashDocumentLineCZP, AppliedDocumentAmount, IsHandled);
        if IsHandled then
            exit;

        CashDocumentLineCZP.TestField("Account Type", CashDocumentLineCZP."Account Type"::Customer);
        CashDocumentLineCZP.TestField("Applies-To Doc. No.");
        if CashDocumentLineCZP."Amount Including VAT" > AppliedDocumentAmount then
            CashDocumentLineCZP.TestField("Amount Including VAT", AppliedDocumentAmount);
    end;

    local procedure GetAppliedDocumentAmount(CashDocumentLineCZP: Record "Cash Document Line CZP") AppliedDocumentAmount: Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        IsHandled: Boolean;
    begin
        OnBeforeGetAppliedDocumentAmount(CashDocumentLineCZP, AppliedDocumentAmount, IsHandled);
        if IsHandled then
            exit(AppliedDocumentAmount);

        if FindCustLedgerEntryForAppliedDocument(CashDocumentLineCZP, CustLedgerEntry) then
            AppliedDocumentAmount := CalculateOriginalAmount(CustLedgerEntry, false);

        OnAfterGetAppliedDocumentAmount(CashDocumentLineCZP, AppliedDocumentAmount);
    end;

    local procedure CalculateOriginalAmount(CustLedgerEntry: Record "Cust. Ledger Entry"; UseLCY: Boolean): Decimal
    begin
        if UseLCY then begin
            CustLedgerEntry.CalcFields("Original Amt. (LCY)");
            exit(Abs(CustLedgerEntry."Original Amt. (LCY)"));
        end;
        CustLedgerEntry.CalcFields("Original Amount");
        exit(Abs(CustLedgerEntry."Original Amount"));
    end;

    procedure CreateEETEntry(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"): Integer
    var
        TempVATEntry: Record "VAT Entry" temporary;
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        EETCashRegisterCZL: Record "EET Cash Register CZL";
        EETEntryCZL: Record "EET Entry CZL";
        IsHandled: Boolean;
        CreatedEETEntryNo: Integer;
    begin
        OnBeforeCreateEETEntry(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP, CreatedEETEntryNo, IsHandled);
        if IsHandled then
            exit(CreatedEETEntryNo);

        CashDocumentHeaderCZP.FindEETCashRegister(EETCashRegisterCZL);
        EETCashRegisterCZL.TestField("Receipt Serial Nos.");

        EETEntryCZL.Init();
        EETEntryCZL."Cash Register Type" := EETEntryCZL."Cash Register Type"::"Cash Desk";
        EETEntryCZL."Cash Register No." := PostedCashDocumentHdrCZP."Cash Desk No.";
        EETEntryCZL."Document No." := PostedCashDocumentHdrCZP."No.";
        EETEntryCZL."Business Premises Code" := EETCashRegisterCZL."Business Premises Code";
        EETEntryCZL."Cash Register Code" := EETCashRegisterCZL.Code;

        CashDocumentHeaderCZP.CalcFields("Amount Including VAT (LCY)");
        EETEntryCZL."Total Sales Amount" := -CashDocumentHeaderCZP.SignAmount() * CashDocumentHeaderCZP."Amount Including VAT (LCY)";
        EETEntryCZL."Amount Exempted From VAT" := EETEntryCZL."Total Sales Amount";

        SetFilterCashDocumentLine(CashDocumentHeaderCZP, CashDocumentLineCZP);
        CashDocumentLineCZP.FindFirst();

        EETEntryCZL."Applied Document Type" := GetAppliedDocumentType(CashDocumentLineCZP);
        EETEntryCZL."Applied Document No." := GetAppliedDocumentNo(CashDocumentLineCZP);

        CollectVATEntries(EETEntryCZL, CashDocumentHeaderCZP, CashDocumentLineCZP, PostedCashDocumentHdrCZP, TempVATEntry);

        TempVATEntry.Reset();
        if TempVATEntry.FindSet() then begin
            EETEntryCZL."Amount Exempted From VAT" := 0;
            repeat
                EETEntryCZL.CalculateAmounts(TempVATEntry);
            until TempVATEntry.Next() = 0;
        end;

        EETEntryCZL.RoundAmounts();

        if EETEntryCZL."Applied Document No." <> '' then
            EETEntryCZL.Description := StrSubstNo(EntryDescriptionTxt, EETEntryCZL."Applied Document Type", EETEntryCZL."Applied Document No.");

        OnCreateEETEntryOnBeforeInsertEETEntry(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP, EETEntryCZL);
        EETEntryCZL.Insert(true);
        exit(EETEntryCZL."Entry No.");
    end;

    local procedure CollectVATEntries(EETEntryCZL: Record "EET Entry CZL"; CashDocumentHeaderCZP: Record "Cash Document Header CZP"; CashDocumentLineCZP: Record "Cash Document Line CZP"; PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var TempVATEntry: Record "VAT Entry" temporary)
    var
        RoundingCashDocumentLineCZP: Record "Cash Document Line CZP";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VATEntry: Record "VAT Entry";
        AppliedDocumentAmount: Decimal;
        PartialPaymentFactor: Decimal;
        RoundingAmount: Decimal;
        IsHandled: Boolean;
    begin
        TempVATEntry.Reset();
        TempVATEntry.DeleteAll();

        OnBeforeCollectVATEntries(EETEntryCZL, CashDocumentHeaderCZP, CashDocumentLineCZP, TempVATEntry, IsHandled);
        if IsHandled then
            exit;

        case true of
            CashDocumentLineCZP.IsInvoicePayment(),
            CashDocumentLineCZP.IsCreditMemoRefund():
                begin
                    FindCustLedgerEntryForAppliedDocument(CashDocumentLineCZP, CustLedgerEntry);
                    AppliedDocumentAmount := CalculateOriginalAmount(CustLedgerEntry, true);
                    SetFilterVATEntry(CustLedgerEntry."Document No.", CustLedgerEntry."Posting Date", VATEntry);
                end;
        end;

        // Collect VAT entries of applied documents
        if VATEntry.HasFilter() then begin
            PartialPaymentFactor := 1;
            CashDocumentHeaderCZP.FindRoundingLine(RoundingCashDocumentLineCZP);
            RoundingAmount := CashDocumentHeaderCZP.SignAmount() * RoundingCashDocumentLineCZP."Amount Including VAT (LCY)";
            if (AppliedDocumentAmount <> 0) and (AppliedDocumentAmount <> (CashDocumentHeaderCZP."Amount Including VAT (LCY)" - RoundingAmount)) then
                PartialPaymentFactor := (CashDocumentHeaderCZP."Amount Including VAT (LCY)" - RoundingAmount) / AppliedDocumentAmount;

            if VATEntry.FindSet() then
                repeat
                    TempVATEntry.Init();
                    TempVATEntry := VATEntry;
                    TempVATEntry.Base := TempVATEntry.GetVATBaseCZL() * PartialPaymentFactor;
                    TempVATEntry.Amount := TempVATEntry.GetVATAmountCZL() * PartialPaymentFactor;
                    TempVATEntry.Insert();
                until VATEntry.Next() = 0;
        end;

        // Collect VAT entries of cash document
        VATEntry.Reset();
        SetFilterVATEntry(PostedCashDocumentHdrCZP."No.", PostedCashDocumentHdrCZP."Posting Date", VATEntry);
        if VATEntry.FindSet() then
            repeat
                TempVATEntry.Init();
                TempVATEntry := VATEntry;
                TempVATEntry.Base := TempVATEntry.GetVATBaseCZL();
                TempVATEntry.Amount := TempVATEntry.GetVATAmountCZL();
                TempVATEntry.Insert();
            until VATEntry.Next() = 0;

        OnAfterCollectVATEntries(EETEntryCZL, CashDocumentHeaderCZP, CashDocumentLineCZP, TempVATEntry);
    end;

    local procedure GetAppliedDocumentType(CashDocumentLineCZP: Record "Cash Document Line CZP") EETAppliedDocumentTypeCZL: Enum "EET Applied Document Type CZL"
    begin
        case true of
            CashDocumentLineCZP.IsInvoicePayment():
                EETAppliedDocumentTypeCZL := EETAppliedDocumentTypeCZL::Invoice;
            CashDocumentLineCZP.IsCreditMemoRefund():
                EETAppliedDocumentTypeCZL := EETAppliedDocumentTypeCZL::"Credit Memo";
            else
                OnGetAppliedDocumentType(CashDocumentLineCZP, EETAppliedDocumentTypeCZL);
        end;
    end;

    local procedure GetAppliedDocumentNo(CashDocumentLineCZP: Record "Cash Document Line CZP") AppliedDocumentNo: Code[20]
    begin
        AppliedDocumentNo := CashDocumentLineCZP."Applies-To Doc. No.";

        OnGetAppliedDocumentNo(CashDocumentLineCZP, AppliedDocumentNo);
    end;

    local procedure FindCustLedgerEntryForAppliedDocument(CashDocumentLineCZP: Record "Cash Document Line CZP"; var CustLedgerEntry: Record "Cust. Ledger Entry"): Boolean
    begin
        if CashDocumentLineCZP."Applies-To Doc. No." = '' then
            exit(false);
        SetFilterCustLedgerEntryForAppliedDocument(CashDocumentLineCZP, CustLedgerEntry);
        exit(CustLedgerEntry.FindFirst());
    end;

    local procedure SetFilterCashDocumentLine(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP")
    begin
        CashDocumentLineCZP.Reset();
        CashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        CashDocumentLineCZP.SetRange("System-Created Entry", false);
        CashDocumentLineCZP.SetFilter(Amount, '<>0');
    end;

    local procedure SetFilterCustLedgerEntryForAppliedDocument(CashDocumentLineCZP: Record "Cash Document Line CZP"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
        CustLedgerEntry.SetRange("Document Type", CashDocumentLineCZP."Applies-To Doc. Type");
        CustLedgerEntry.SetRange("Document No.", CashDocumentLineCZP."Applies-To Doc. No.");
        CustLedgerEntry.SetRange("Customer No.", CashDocumentLineCZP."Account No.");
        CustLedgerEntry.SetRange("Currency Code", CashDocumentLineCZP."Currency Code");
    end;

    local procedure SetFilterVATEntry(DocumentNo: Code[20]; PostingDate: Date; var VATEntry: Record "VAT Entry")
    begin
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", DocumentNo);
        VATEntry.SetRange("Posting Date", PostingDate);
        if VATEntry.FindLast() then
            VATEntry.SetRange("Transaction No.", VATEntry."Transaction No.");
    end;

    procedure CheckCashDocumentAction(CashDeskNo: Code[20]; CashDocumentAction: Enum "Cash Document Action CZP")
    var
        EETCashRegisterCZL: Record "EET Cash Register CZL";
        EETDocReleaseDeniedErr: Label 'Cash desk %1 is set up as EET cash register. Cash documents for this EET cash register is not possible release only.\Cash document action must not be set up to value "Release" or "Release and Print".', Comment = '%1 = cash desk code';
    begin
        if CashDeskNo = '' then
            exit;

        if (CashDocumentAction in [CashDocumentAction::Release, CashDocumentAction::"Release and Print"]) and
           EETCashRegisterCZL.FindByCashRegisterNo("EET Cash Register Type CZL"::"Cash Desk", CashDeskNo)
        then
            Error(EETDocReleaseDeniedErr, CashDeskNo);
    end;

    local procedure TryCreateEETEntry(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"): Boolean
    begin
        if not CheckEETTransaction(CashDocumentHeaderCZP) then
            exit(false);

        PostedCashDocumentHdrCZP."EET Entry No." := CreateEETEntry(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP);
        PostedCashDocumentHdrCZP.Modify();
        exit(PostedCashDocumentHdrCZP."EET Entry No." <> 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnBeforePostCashDoc', '', false, false)]
    local procedure CheckCashDocumentOnBeforePostCashDoc(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        CheckCashDocument(CashDocumentHeaderCZP);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnBeforeDeleteAfterPosting', '', false, false)]
    local procedure CreateEETEntryOnBeforeDeleteAfterPosting(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP")
    begin
        TryCreateEETEntry(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnAfterFinalizePosting', '', false, false)]
    local procedure SendEntryToServiceOnAfterFinalizePosting(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        EETEntryCZL: Record "EET Entry CZL";
    begin
        if not EETEntryCZL.Get(PostedCashDocumentHdrCZP."EET Entry No.") then
            exit;

        EETManagementCZL.TrySendEntryToService(EETEntryCZL);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Cash Document-Post CZP", 'OnAfterFinalizePostingPreview', '', false, false)]
    local procedure SendEntryToVerificationOnAfterFinalizePostingPreview(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        EETEntryCZL: Record "EET Entry CZL";
    begin
        if not TryCreateEETEntry(CashDocumentHeaderCZP, PostedCashDocumentHdrCZP) then
            exit;
        EETEntryCZL.Get(PostedCashDocumentHdrCZP."EET Entry No.");
        EETEntryCZL.Verify();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckLineWithAppliedDocument(CashDocumentLineCZP: Record "Cash Document Line CZP"; AppliedDocumentAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeGetAppliedDocumentAmount(CashDocumentLineCZP: Record "Cash Document Line CZP"; var AppliedDocumentAmount: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetAppliedDocumentAmount(CashDocumentLineCZP: Record "Cash Document Line CZP"; var AppliedDocumentAmount: Decimal)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateEETEntry(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var CreatedEETEntryNo: Integer; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateEETEntryOnBeforeInsertEETEntry(CashDocumentHeaderCZP: Record "Cash Document Header CZP"; PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP"; var EETEntryCZL: Record "EET Entry CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetAppliedDocumentType(CashDocumentLineCZP: Record "Cash Document Line CZP"; var EETAppliedDocumentTypeCZL: Enum "EET Applied Document Type CZL")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCollectVATEntries(EETEntryCZL: Record "EET Entry CZL"; CashDocumentHeaderCZP: Record "Cash Document Header CZP"; CashDocumentLineCZP: Record "Cash Document Line CZP"; var TempVATEntry: Record "VAT Entry" temporary; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCollectVATEntries(EETEntryCZL: Record "EET Entry CZL"; CashDocumentHeaderCZP: Record "Cash Document Header CZP"; CashDocumentLineCZP: Record "Cash Document Line CZP"; var TempVATEntry: Record "VAT Entry" temporary);
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetAppliedDocumentNo(CashDocumentLineCZP: Record "Cash Document Line CZP"; var AppliedDocumentNo: Code[20]);
    begin
    end;
}
