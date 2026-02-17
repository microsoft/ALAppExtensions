// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.FixedAssets.FixedAsset;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using Microsoft.Purchases.History;
using Microsoft.Purchases.Posting;
using Microsoft.Purchases.Setup;
using Microsoft.Purchases.Vendor;

codeunit 6784 "Wthldg Tax Purch. Subscribers"
{
    var
        GeneralLedgerSetup: Record "General Ledger Setup";

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", OnAfterCopyBuyFromVendorFieldsFromVendor, '', false, false)]
    local procedure CopyVendorInfo(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not Vendor."Withholding Tax Liable" then
            exit;

        PurchaseHeader."Wthldg. Tax Bus. Post. Group" := Vendor."Wthldg. Tax Bus. Post. Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterInitHeaderDefaults, '', false, false)]
    local procedure CopyHeaderInfo(PurchHeader: Record "Purchase Header"; var PurchLine: Record "Purchase Line")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        PurchLine."Wthldg. Tax Bus. Post. Group" := PurchHeader."Wthldg. Tax Bus. Post. Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterAssignGLAccountValues, '', false, false)]
    local procedure AssignGLAccValue(var PurchLine: Record "Purchase Line"; GLAccount: Record "G/L Account"; PurchHeader: Record "Purchase Header")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        PurchLine."Wthldg. Tax Prod. Post. Group" := GLAccount."Wthldg. Tax Prod. Post. Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterAssignItemValues, '', false, false)]
    local procedure AssignItemValue(var PurchLine: Record "Purchase Line"; Item: Record Item; PurchHeader: Record "Purchase Header")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        PurchLine."Wthldg. Tax Prod. Post. Group" := Item."Wthldg. Tax Prod. Post. Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterAssignFixedAssetValues, '', false, false)]
    local procedure AssignFAValue(var PurchLine: Record "Purchase Line"; FixedAsset: Record "Fixed Asset"; PurchHeader: Record "Purchase Header")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        PurchLine."Wthldg. Tax Prod. Post. Group" := FixedAsset."Wthldg. Tax Prod. Post. Group";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", OnAfterPrepareInvoicePostingBuffer, '', false, false)]
    local procedure OnAfterPrepareInvoicePostingBuffer(var InvoicePostingBuffer: Record "Invoice Posting Buffer" temporary; var PurchaseLine: Record "Purchase Line")
    var
        PurchHeader: Record "Purchase Header";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        PurchHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        InvoicePostingBuffer."Wthldg. Tax Bus. Post. Group" := PurchaseLine."Wthldg. Tax Bus. Post. Group";
        InvoicePostingBuffer."Wthldg. Tax Prod. Post. Group" := PurchaseLine."Wthldg. Tax Prod. Post. Group";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", OnPrepareGenJnlLineOnAfterCopyToGenJnlLine, '', false, false)]
    local procedure OnPrepareGenJnlLineOnAfterCopyToGenJnlLine(InvoicePostingBuffer: Record "Invoice Posting Buffer" temporary; var GenJnlLine: Record "Gen. Journal Line"; PurchHeader: Record "Purchase Header")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        InvoicePostingBuffer."Wthldg. Tax Bus. Post. Group" := GenJnlLine."Wthldg. Tax Bus. Post. Group";
        InvoicePostingBuffer."Wthldg. Tax Prod. Post. Group" := GenJnlLine."Wthldg. Tax Prod. Post. Group";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", OnPostLedgerEntryOnBeforeGenJnlPostLine, '', false, false)]
    local procedure OnPostLedgerEntryOnBeforeGenJnlPostLine(var GenJnlLine: Record "Gen. Journal Line"; var PurchHeader: Record "Purchase Header")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        GenJnlLine."Wthldg. Tax Bus. Post. Group" := PurchHeader."Wthldg. Tax Bus. Post. Group";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", OnPostBalancingEntryOnAfterInitNewLine, '', false, false)]
    local procedure OnPostBalancingEntryOnAfterInitNewLine(var GenJnlLine: Record "Gen. Journal Line"; var PurchHeader: Record "Purchase Header")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        GenJnlLine."Wthldg. Tax Bus. Post. Group" := PurchHeader."Wthldg. Tax Bus. Post. Group";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", OnPrepareLineOnAfterAssignAmounts, '', false, false)]
    local procedure OnPrepareLineOnAfterAssignAmounts(PurchLine: Record "Purchase Line"; var TotalAmount: Decimal; var TotalAmountACY: Decimal)
    var
        PurchHeader: Record "Purchase Header";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        PurchHeader.Get(PurchLine."Document Type", PurchLine."Document No.");
        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        AssignWithholdingAmounts(PurchLine, TotalAmount, TotalAmountACY);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch. Post Invoice Events", OnAfterInitGenJnlLineAmountFieldsFromTotalLines, '', false, false)]
    local procedure OnAfterInitGenJnlLineAmountFieldsFromTotalLines(var GenJnlLine: Record "Gen. Journal Line"; var PurchHeader: Record "Purchase Header"; var TotalPurchLine: Record "Purchase Line"; var TotalPurchLineLCY: Record "Purchase Line")
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        GenJnlLine.Amount += PurchHeader."Withholding Tax Amount";
        GenJnlLine."Source Currency Amount" += PurchHeader."Withholding Tax Amount";

        if (PurchHeader."Withholding Tax Amount" <> 0) and (PurchHeader."Currency Code" <> '') then
            GenJnlLine."Amount (LCY)" +=
                  Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                    PurchHeader."Posting Date", PurchHeader."Currency Code", PurchHeader."Withholding Tax Amount", PurchHeader."Currency Factor"))
        else
            GenJnlLine."Amount (LCY)" += PurchHeader."Withholding Tax Amount";
    end;

    local procedure AssignWithholdingAmounts(PurchLine: Record "Purchase Line"; var TotalAmount: Decimal; var TotalAmountACY: Decimal)
    var
        PurchHeader: Record "Purchase Header";
        GenPostingSetup: Record "General Posting Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        PrepaymentPurchInvHeader: Record "Purch. Inv. Header";
        PrepaymentWithholdingTaxEntry: Record "Withholding Tax Entry";
        TotalWHTAmtToBeDeducted: Decimal;
        TotalWHTAmountToBeDeductedLCY: Decimal;
        TotalWHTAmountToBeDeductedACY: Integer;
    begin
        PurchHeader := PurchLine.GetPurchHeader();
        GenPostingSetup.Get(PurchLine."Gen. Bus. Posting Group", PurchLine."Gen. Prod. Posting Group");

        PrepaymentPurchInvHeader.Reset();
        PrepaymentPurchInvHeader.SetRange("Prepayment Order No.", PurchLine."Document No.");
        PrepaymentPurchInvHeader.SetRange("Prepayment Invoice", true);
        if PrepaymentPurchInvHeader.FindSet() then
            repeat
                PrepaymentWithholdingTaxEntry.SetRange("Document Type", PrepaymentWithholdingTaxEntry."Document Type"::Invoice);
                PrepaymentWithholdingTaxEntry.SetRange("Document No.", PrepaymentPurchInvHeader."No.");
                PrepaymentWithholdingTaxEntry.SetRange("Gen. Bus. Posting Group", GenPostingSetup."Gen. Bus. Posting Group");
                PrepaymentWithholdingTaxEntry.SetRange("Gen. Prod. Posting Group", GenPostingSetup."Gen. Prod. Posting Group");
                if PrepaymentWithholdingTaxEntry.FindSet() then
                    repeat
                        TotalWHTAmountToBeDeductedLCY := TotalWHTAmountToBeDeductedLCY + PrepaymentWithholdingTaxEntry."Unrealized Amount (LCY)";
                        TotalWHTAmtToBeDeducted := TotalWHTAmtToBeDeducted + PrepaymentWithholdingTaxEntry."Unrealized Amount";
                    until PrepaymentWithholdingTaxEntry.Next() = 0;
            until PrepaymentPurchInvHeader.Next() = 0;

        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Additional Reporting Currency" <> '' then
            TotalWHTAmountToBeDeductedACY :=
              CurrExchRate.ExchangeAmtLCYToFCY(
                PurchHeader."Posting Date", GeneralLedgerSetup."Additional Reporting Currency",
                TotalWHTAmtToBeDeducted, 0);

        if PurchLine."Prepayment Line" then begin
            TotalAmount := TotalAmount + TotalWHTAmountToBeDeductedLCY;
            TotalAmountACY := TotalAmountACY + TotalWHTAmountToBeDeductedACY;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnCheckAndUpdateOnBeforeSetPostingFlags, '', false, false)]
    local procedure CheckWithholdingApplication(var PurchHeader: Record "Purchase Header")
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchHeader) then
            exit;

        if PurchHeader.IsCreditDocType() then begin
            if (PurchHeader."Applies-to Doc. Type" = PurchHeader."Applies-to Doc. Type"::Invoice) and (PurchHeader."Applies-to Doc. No." <> '') then
                WithholdingTaxMgmt.CheckApplicationPurchWithholdingTax(PurchHeader);

            if ((PurchHeader."Applies-to Doc. Type" = PurchHeader."Applies-to Doc. Type"::Refund) and (PurchHeader."Applies-to Doc. No." <> '')) or
               (PurchHeader."Applies-to ID" <> '')
            then
                WithholdingTaxMgmt.CheckApplicationPurchWithholdingTax(PurchHeader);
        end;

        if PurchHeader."Document Type" in [PurchHeader."Document Type"::Invoice] then begin
            if (PurchHeader."Applies-to Doc. Type" = PurchHeader."Applies-to Doc. Type"::"Credit Memo") and (PurchHeader."Applies-to Doc. No." <> '') then
                WithholdingTaxMgmt.CheckApplicationPurchWithholdingTax(PurchHeader);

            if ((PurchHeader."Applies-to Doc. Type" = PurchHeader."Applies-to Doc. Type"::Payment) and (PurchHeader."Applies-to Doc. No." <> '')) or
               (PurchHeader."Applies-to ID" <> '')
            then
                WithholdingTaxMgmt.CheckApplicationPurchWithholdingTax(PurchHeader);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnPostInvoiceOnAfterPostLines, '', false, false)]
    local procedure PostPurchWithholdingTax(var PurchaseHeader: Record "Purchase Header"; SrcCode: Code[10]; GenJnlLineDocType: Enum "Gen. Journal Document Type"; GenJnlLineExtDocNo: Code[35]; GenJnlLineDocNo: Code[20]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var TotalPurchLine: Record "Purchase Line"; var TotalPurchLineLCY: Record "Purchase Line"; var TempPurchLineGlobal: Record "Purchase Line" temporary; TotalAmount: Decimal)
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchaseHeader) then
            exit;

        PostWithholdingTax(PurchaseHeader, SrcCode, GenJnlLineDocType, GenJnlLineDocNo, GenJnlLineExtDocNo, GenJnlPostLine, TotalPurchLineLCY, TempPurchLineGlobal, TotalAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", OnAfterCreateLinesOnBeforeGLPosting, '', false, false)]
    local procedure VendorPrepaymentInvoiceWithholdingTax(var PurchaseHeader: Record "Purchase Header"; PurchInvHeader: Record "Purch. Inv. Header"; DocumentType: Option Invoice,"Credit Memo")
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchaseHeader) then
            exit;

        if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice] then
            if DocumentType = DocumentType::Invoice then
                WithholdingTaxMgmt.InsertVendPrepaymentInvoiceWithholding(PurchInvHeader, PurchaseHeader);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", OnBeforePostPrepmtInvLineBuffer, '', false, false)]
    local procedure PostPrepmtInvLineBuffer(var GenJnlLine: Record "Gen. Journal Line"; PrepmtInvLineBuffer: Record "Prepayment Inv. Line Buffer")
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        GLRegister: Record "G/L Register";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
        WithholdingTaxAmount: Decimal;
        WithholdingTaxAmountLCY: Decimal;
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJnlLine) then
            exit;

        WithholdingTaxAmount := 0;
        WithholdingTaxAmountLCY := 0;

        CalcWithholdingTaxAmounts(GenJnlLine."Document No.", PrepmtInvLineBuffer, WithholdingTaxEntry, WithholdingTaxAmount, WithholdingTaxAmountLCY);

        if GenJnlLine."Currency Code" <> '' then
            GenJnlLine.Amount := PrepmtInvLineBuffer.Amount - WithholdingTaxAmountLCY
        else
            GenJnlLine.Amount := PrepmtInvLineBuffer.Amount - WithholdingTaxAmount;

        if WithholdingTaxEntry.FindLast() then
            if GLRegister.FindLast() then begin
                GLRegister."To Withholding Tax Entry No." := WithholdingTaxEntry."Entry No.";
                GLRegister.Modify();
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", OnBeforePostVendorEntry, '', false, false)]
    local procedure OnBeforePostVendorEntry(var GenJnlLine: Record "Gen. Journal Line"; PurchaseHeader: Record "Purchase Header")
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxAmount: Decimal;
        WithholdingTaxAmountLCY: Decimal;
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchaseHeader) then
            exit;

        CalcWithholdingTaxAmounts(GenJnlLine."Document No.", WithholdingTaxEntry, WithholdingTaxAmount, WithholdingTaxAmountLCY);

        GenJnlLine.Amount += WithholdingTaxAmount;
        GenJnlLine."Amount (LCY)" += WithholdingTaxAmountLCY;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", OnBeforePostBalancingEntry, '', false, false)]
    local procedure OnBeforePostBalancingEntry(var GenJnlLine: Record "Gen. Journal Line")
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
        WithholdingTaxAmount: Decimal;
        WithholdingTaxAmountLCY: Decimal;
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJnlLine) then
            exit;

        CalcWithholdingTaxAmounts(GenJnlLine."Document No.", WithholdingTaxEntry, WithholdingTaxAmount, WithholdingTaxAmountLCY);

        GenJnlLine.Amount -= WithholdingTaxAmount;
        GenJnlLine."Source Currency Amount" := GenJnlLine.Amount;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purchase-Post Prepayments", OnCodeOnAfterUpdateHeaderAndLines, '', false, false)]
    local procedure VendorPrepaymentCrMemoWithholdingTax(var PurchaseHeader: Record "Purchase Header"; var PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; DocumentType: Option Invoice,"Credit Memo")
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not CheckWithholdingTaxLiable(PurchaseHeader) then
            exit;

        if PurchaseHeader."Document Type" in [PurchaseHeader."Document Type"::Order, PurchaseHeader."Document Type"::Invoice] then
            if DocumentType = DocumentType::"Credit Memo" then
                WithholdingTaxMgmt.InsertVendPrepaymentCrMemoWithholding(PurchCrMemoHdr, PurchaseHeader);
    end;

    local procedure CalcWithholdingTaxAmounts(PurchInvNo: Code[20]; PrepaymentInvLineBuffer: Record "Prepayment Inv. Line Buffer"; var WithholdingTaxEntry: Record "Withholding Tax Entry"; var WithholdingTaxAmount: Decimal; var WithholdingTaxAmountLCY: Decimal)
    var
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::Invoice);
        WithholdingTaxEntry.SetRange("Document No.", PurchInvNo);
        WithholdingTaxEntry.SetRange("Gen. Bus. Posting Group", PrepaymentInvLineBuffer."Gen. Bus. Posting Group");
        WithholdingTaxEntry.SetRange("Gen. Prod. Posting Group", PrepaymentInvLineBuffer."Gen. Prod. Posting Group");
        WithholdingTaxEntry.SetFilter("Unrealized Amount", '<>%1', 0);
        if WithholdingTaxEntry.FindSet() then
            repeat
                WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                if (WithholdingPostingSetup."Realized Withholding Tax Type" <> WithholdingPostingSetup."Realized Withholding Tax Type"::Payment) and
                   (WithholdingPostingSetup."Realized Withholding Tax Type" <> WithholdingPostingSetup."Realized Withholding Tax Type"::" ")
                then begin
                    WithholdingTaxAmount += WithholdingTaxEntry."Unrealized Amount";
                    WithholdingTaxAmountLCY += WithholdingTaxEntry."Unrealized Amount (LCY)";
                end;
            until WithholdingTaxEntry.Next() = 0;
    end;

    local procedure CalcWithholdingTaxAmounts(PurchInvNo: Code[20]; var WithholdingTaxEntry: Record "Withholding Tax Entry"; var WithholdingTaxAmount: Decimal; var WithholdingTaxAmountLCY: Decimal)
    var
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::Invoice);
        WithholdingTaxEntry.SetRange("Document No.", PurchInvNo);
        WithholdingTaxEntry.SetFilter("Unrealized Amount", '<>%1', 0);
        if WithholdingTaxEntry.FindSet() then
            repeat
                WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                if (WithholdingPostingSetup."Realized Withholding Tax Type" <> WithholdingPostingSetup."Realized Withholding Tax Type"::Payment) and
                   (WithholdingPostingSetup."Realized Withholding Tax Type" <> WithholdingPostingSetup."Realized Withholding Tax Type"::" ")
                then begin
                    WithholdingTaxAmount += WithholdingTaxEntry."Unrealized Amount";
                    WithholdingTaxAmountLCY += WithholdingTaxEntry."Unrealized Amount (LCY)";
                end;
            until WithholdingTaxEntry.Next() = 0;
    end;

    local procedure PostWithholdingTax(var PurchHeader: Record "Purchase Header"; SrcCode: Code[10]; GenJnlLineDocType: Enum "Gen. Journal Document Type"; GenJnlLineDocNo: Code[20]; GenJnlLineExtDocNo: Code[35]; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; var TotalPurchLineLCY: Record "Purchase Line"; var TempPurchLineGlobal: Record "Purchase Line" temporary; TotalInvAmount: Decimal)
    var
        GenJnlLine: Record "Gen. Journal Line";
        PurchSetup: Record "Purchases & Payables Setup";
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
        GLReg: Record "G/L Register";
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
        InvoiceWithholdingTaxExists: Boolean;
    begin
        if TempPurchLineGlobal.Type <> TempPurchLineGlobal.Type::" " then
            WithholdingPostingSetup.Get(TempPurchLineGlobal."Wthldg. Tax Bus. Post. Group", TempPurchLineGlobal."Wthldg. Tax Prod. Post. Group");

        if PurchHeader."Document Type" in [PurchHeader."Document Type"::Order, PurchHeader."Document Type"::Invoice] then begin
            PurchInvHeader.Get(GenJnlLineDocNo);

            if TotalInvAmount >= WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                WithholdingTaxMgmt.InsertVendInvoiceWithholdingTax(PurchInvHeader);

            WithholdingTaxEntry.Reset();
            WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::Invoice);
            WithholdingTaxEntry.SetRange("Document No.", PurchInvHeader."No.");
            if WithholdingTaxEntry.FindSet() then
                repeat
                    WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                    if (WithholdingPostingSetup."Realized Withholding Tax Type" <> WithholdingPostingSetup."Realized Withholding Tax Type"::Payment) and
                       (WithholdingPostingSetup."Realized Withholding Tax Type" <> WithholdingPostingSetup."Realized Withholding Tax Type"::" ")
                    then
                        if WithholdingTaxEntry.Amount <> 0 then begin
                            PurchHeader."Withholding Tax Amount" := WithholdingTaxEntry.Amount;
                            InsertGenJournalWithholding(PurchHeader, GenJnlLine, WithholdingPostingSetup.GetPayableWithholdingTaxAccount(), SrcCode, GenJnlLineDocType, GenJnlLineDocNo, GenJnlLineExtDocNo, WithholdingTaxEntry.Amount, TotalPurchLineLCY);
                            GenJnlPostLine.IncreaseTaxEntryNo();
                            GenJnlPostLine.Run(GenJnlLine);
                        end;
                until WithholdingTaxEntry.Next() = 0;

            GenJnlPostLine.GetGLReg(GLReg);

            if WithholdingTaxEntry.FindLast() then
                InvoiceWithholdingTaxExists := true;
        end else begin
            PurchCrMemoHeader.Get(GenJnlLineDocNo);
            WithholdingTaxMgmt.InsertVendCreditWithholding(PurchCrMemoHeader, PurchHeader."Applies-to ID");

            WithholdingTaxEntry.Reset();
            WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::"Credit Memo");
            WithholdingTaxEntry.SetRange("Document No.", PurchCrMemoHeader."No.");
            if WithholdingTaxEntry.FindSet() then
                repeat
                    WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                    if (WithholdingPostingSetup."Realized Withholding Tax Type" <> WithholdingPostingSetup."Realized Withholding Tax Type"::Payment) and
                       (WithholdingPostingSetup."Realized Withholding Tax Type" <> WithholdingPostingSetup."Realized Withholding Tax Type"::" ")
                    then
                        if WithholdingTaxEntry.Amount <> 0 then begin
                            PurchHeader."Withholding Tax Amount" := WithholdingTaxEntry.Amount;
                            InsertGenJournalWithholding(PurchHeader, GenJnlLine, WithholdingPostingSetup.GetPayableWithholdingTaxAccount(), SrcCode, GenJnlLineDocType, GenJnlLineDocNo, GenJnlLineExtDocNo, WithholdingTaxEntry.Amount, TotalPurchLineLCY);
                            GenJnlPostLine.RunWithCheck(GenJnlLine);
                        end;
                until WithholdingTaxEntry.Next() = 0;

            GenJnlPostLine.GetGLReg(GLReg);
            if WithholdingTaxEntry.FindLast() then
                InvoiceWithholdingTaxExists := true
        end;

        PurchSetup.Get();
        PurchHeader."Withholding Tax Amount" := PurchHeader."Withholding Tax Amount" - CalcWithholdingAmountOnPrepayment(PurchHeader."No.");
        if (PurchHeader."Withholding Tax Amount" <> 0) and InvoiceWithholdingTaxExists then
            if PurchHeader."Document Type" = PurchHeader."Document Type"::"Credit Memo" then begin
                if PurchSetup."Print Wthldg. Tax Docs Cr.Memo" then
                    WithholdingTaxMgmt.PrintWHTSlips(GLReg, false);
            end else
                WithholdingTaxMgmt.PrintWHTSlips(GLReg, false);
    end;

    local procedure CalcWithholdingAmountOnPrepayment(DocNo: Code[20]): Decimal
    var
        PurchInvHeaderPrePmt: Record "Purch. Inv. Header";
        WithholdingTaxEntryPrePmt: Record "Withholding Tax Entry";
        TotalAmtToBeDeducted: Decimal;
    begin
        PurchInvHeaderPrePmt.Reset();
        PurchInvHeaderPrePmt.SetRange("Prepayment Order No.", DocNo);
        PurchInvHeaderPrePmt.SetRange("Prepayment Invoice", true);
        if PurchInvHeaderPrePmt.FindSet() then
            repeat
                WithholdingTaxEntryPrePmt.SetRange("Document Type", WithholdingTaxEntryPrePmt."Document Type"::Invoice);
                WithholdingTaxEntryPrePmt.SetRange("Document No.", PurchInvHeaderPrePmt."No.");
                if WithholdingTaxEntryPrePmt.FindSet() then
                    repeat
                        TotalAmtToBeDeducted := TotalAmtToBeDeducted + WithholdingTaxEntryPrePmt."Unrealized Amount";
                    until WithholdingTaxEntryPrePmt.Next() = 0;
            until PurchInvHeaderPrePmt.Next() = 0;
        exit(TotalAmtToBeDeducted);
    end;

    procedure InsertGenJournalWithholding(var PurchHeader: Record "Purchase Header"; var GenJnlLine: Record "Gen. Journal Line"; AccountNo: Code[20]; SrcCode: Code[10]; GenJnlLineDocType: Enum "Gen. Journal Document Type"; GenJnlLineDocNo: Code[20]; GenJnlLineExtDocNo: Code[35]; TotalAmount: Decimal; TotalPurchLineLCY: Record "Purchase Line")
    var
        CurrExchRate: Record "Currency Exchange Rate";
    begin
        GenJnlLine.Init();
        GenJnlLine."Posting Date" := PurchHeader."Posting Date";
        GenJnlLine."Document Date" := PurchHeader."Document Date";
        GenJnlLine.Description := PurchHeader."Posting Description";
        GenJnlLine."Shortcut Dimension 1 Code" := PurchHeader."Shortcut Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := PurchHeader."Shortcut Dimension 2 Code";
        GenJnlLine."Dimension Set ID" := PurchHeader."Dimension Set ID";
        GenJnlLine."Reason Code" := PurchHeader."Reason Code";
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Account No." := AccountNo;
        GenJnlLine."Document Type" := GenJnlLineDocType;
        GenJnlLine."Document No." := GenJnlLineDocNo;
        GenJnlLine."External Document No." := GenJnlLineExtDocNo;
        GenJnlLine."Currency Code" := PurchHeader."Currency Code";
        GenJnlLine.Amount := -TotalAmount;
        GenJnlLine."Source Currency Code" := PurchHeader."Currency Code";
        GenJnlLine."Source Currency Amount" := -TotalAmount;

        if PurchHeader."Currency Code" <> '' then
            GenJnlLine."Amount (LCY)" :=
              Round(
                CurrExchRate.ExchangeAmtFCYToLCY(
                  PurchHeader."Posting Date", PurchHeader."Currency Code", -TotalAmount, PurchHeader."Currency Factor"));

        if PurchHeader."Currency Code" = '' then
            GenJnlLine."Currency Factor" := 1
        else
            GenJnlLine."Currency Factor" := PurchHeader."Currency Factor";

        GenJnlLine."Sales/Purch. (LCY)" := -TotalPurchLineLCY.Amount;
        GenJnlLine.Correction := PurchHeader.Correction;
        GenJnlLine."Inv. Discount (LCY)" := -TotalPurchLineLCY."Inv. Discount Amount";
        GenJnlLine."Sell-to/Buy-from No." := PurchHeader."Buy-from Vendor No.";
        GenJnlLine."Bill-to/Pay-to No." := PurchHeader."Pay-to Vendor No.";
        GenJnlLine."Salespers./Purch. Code" := PurchHeader."Purchaser Code";
        GenJnlLine."System-Created Entry" := true;
        GenJnlLine."On Hold" := PurchHeader."On Hold";
        GenJnlLine."Allow Application" := PurchHeader."Bal. Account No." = '';
        GenJnlLine."Due Date" := PurchHeader."Due Date";
        GenJnlLine."Payment Terms Code" := PurchHeader."Payment Terms Code";
        GenJnlLine."Source Type" := GenJnlLine."Source Type"::Vendor;
        GenJnlLine."Source No." := PurchHeader."Pay-to Vendor No.";
        GenJnlLine."Source Code" := SrcCode;
        GenJnlLine."Posting No. Series" := PurchHeader."Posting No. Series";
        GenJnlLine."IC Partner Code" := PurchHeader."Pay-to IC Partner Code";
    end;

    local procedure CheckWithholdingTaxDisabled(): Boolean
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Enable Withholding Tax" then
            exit(true);

        exit(false);
    end;

    local procedure CheckWithholdingTaxLiable(PurchHeader: Record "Purchase Header"): Boolean
    var
        Vendor: Record Vendor;
    begin
        Vendor.Get(PurchHeader."Pay-to Vendor No.");
        exit(Vendor."Withholding Tax Liable");
    end;
}