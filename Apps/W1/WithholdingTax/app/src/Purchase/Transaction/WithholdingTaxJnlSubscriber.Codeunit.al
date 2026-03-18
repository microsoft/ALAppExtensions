// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.WithholdingTax;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Check;
using Microsoft.Bank.Ledger;
using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;

codeunit 6786 "Withholding Tax Jnl Subscriber"
{
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        PaymentJournalPostApplyErr: Label 'Cannot post the payment journal because one or more journal lines must be applied to an invoice line when the Withholding Tax Realized Type %1', Comment = '%1 : Withholding Tax Realized Type';
        BankPaymentTypeMustNotBeFilledErr: Label 'Bank Payment Type must not be filled if Currency Code is different in Gen. Journal Line and Bank Account.';
        DocNoMustBeEnteredErr: Label 'Document No. must be entered when Bank Payment Type is %1.', Comment = '%1 - option value';
        CheckAlreadyExistsErr: Label 'Check %1 already exists for this Bank Account.', Comment = '%1 - document no.';

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterDeleteEvent, '', false, false)]
    local procedure DeleteWithholdingTaxEntry(var Rec: Record "Gen. Journal Line")
    var
        TempWithholdingTaxEntry: Record "Temp Withholding Tax Entry";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        TempWithholdingTaxEntry.SetRange("Document Type", Rec."Document Type");
        TempWithholdingTaxEntry.SetRange("Original Document No.", Rec."Document No.");
        if TempWithholdingTaxEntry.FindFirst() then
            TempWithholdingTaxEntry.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterAccountNoOnValidateGetGLAccount, '', false, false)]
    local procedure AssignGLAccValue(var GenJournalLine: Record "Gen. Journal Line"; var GLAccount: Record "G/L Account")
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        GenJournalLine."Wthldg. Tax Bus. Post. Group" := GLAccount."Wthldg. Tax Bus. Post. Group";
        GenJournalLine."Wthldg. Tax Prod. Post. Group" := GLAccount."Wthldg. Tax Prod. Post. Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterAccountNoOnValidateGetGLBalAccount, '', false, false)]
    local procedure AssignBalGLAccValue(var GenJournalLine: Record "Gen. Journal Line"; var GLAccount: Record "G/L Account")
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        GenJournalLine."Wthldg. Tax Prod. Post. Group" := GLAccount."Wthldg. Tax Prod. Post. Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterAccountNoOnValidateGetVendorAccount, '', false, false)]
    local procedure AssignVendValue(var GenJournalLine: Record "Gen. Journal Line"; var Vendor: Record Vendor)
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not Vendor."Withholding Tax Liable" then
            exit;

        GenJournalLine."Wthldg. Tax Bus. Post. Group" := Vendor."Wthldg. Tax Bus. Post. Group";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnAfterClearPostingGroups, '', false, false)]
    local procedure ClearPostingGroups(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        GenJournalLine."Wthldg. Tax Bus. Post. Group" := '';
        GenJournalLine."Wthldg. Tax Prod. Post. Group" := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeInitGLEntryForGLAcc, '', false, false)]
    local procedure OnBeforeInitGLEntryForGLAcc(GenJnlLine: Record "Gen. Journal Line"; GLAcc: Record "G/L Account"; var GLEntry: Record "G/L Entry"; var TaxAmount: Decimal; var TaxAmountLCY: Decimal; var IsHandled: Boolean; var sender: Codeunit "Gen. Jnl.-Post Line")
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJnlLine) then
            exit;

        CalcGLAccWithholdingTax(GenJnlLine, TaxAmountLCY);
        sender.InitGLEntry(
                GenJnlLine, GLEntry, GenJnlLine."Account No.", GenJnlLine."Amount (LCY)" + TaxAmountLCY,
                GenJnlLine."Source Currency Amount" + TaxAmountLCY, true, GenJnlLine."System-Created Entry",
                CalcSourceCurrVATBaseAmount(GenJnlLine, TaxAmountLCY, sender));
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostGLAccOnBeforeDeferralPosting, '', false, false)]
    local procedure PostWithholdingTaxforGL(var GenJournalLine: Record "Gen. Journal Line"; sender: Codeunit "Gen. Jnl.-Post Line"; TaxAmount: Decimal; TaxAmountLCY: Decimal)
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        PostGLAccWithholdingTax(GenJournalLine, TaxAmountLCY, sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostVendOnAfterInitVendLedgEntry, '', false, false)]
    local procedure OnPostVendOnAfterInitVendLedgEntry(var GenJnlLine: Record "Gen. Journal Line"; var VendLedgEntry: Record "Vendor Ledger Entry"; Vendor: Record Vendor; var TaxAmount: Decimal; var TaxAmountLCY: Decimal)
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not Vendor."Withholding Tax Liable" then
            exit;

        CalcVendWithholdingTax(GenJnlLine, TaxAmountLCY, TaxAmount);
        VendLedgEntry."Amount to Apply" := GenJnlLine.Amount;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostVendAfterTempDtldCVLedgEntryBufInit, '', false, false)]
    local procedure OnPostVendAfterTempDtldCVLedgEntryBufInit(var GenJnlLine: Record "Gen. Journal Line"; var TempDtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer" temporary; TaxAmount: Decimal; TaxAmountLCY: Decimal)
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJnlLine) then
            exit;

        TempDtldCVLedgEntryBuf.Amount := TempDtldCVLedgEntryBuf.Amount - GenJnlLine."WHT Interest Amount" - GenJnlPostLine.ExchangeAmtLCYToFCY2(TaxAmount);
        TempDtldCVLedgEntryBuf."Amount (LCY)" := TempDtldCVLedgEntryBuf."Amount (LCY)" - GenJnlLine."WHT Interest Amount (LCY)" - TaxAmountLCY;
        if GenJnlLine."WHT Vendor Exchange Rate (ACY)" <> 0 then
            TempDtldCVLedgEntryBuf."Additional-Currency Amount" := GenJnlLine."WHT Amount Including VAT (ACY)" - GenJnlLine."WHT Interest Amount"
        else
            TempDtldCVLedgEntryBuf."Additional-Currency Amount" := GenJnlLine.Amount;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInitGLRegister, '', false, false)]
    local procedure OnAfterInitGLRegister(var GLRegister: Record "G/L Register")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        SetFromWithholdingEntryNoInGLRegister(GLRegister);
    end;

    local procedure SetFromWithholdingEntryNoInGLRegister(var GLRegister: Record "G/L Register")
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        NextWHTEntryNo: Integer;
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if WithholdingTaxEntry.FindLast() then
            NextWHTEntryNo := WithholdingTaxEntry."Entry No." + 1
        else
            NextWHTEntryNo := 1;

        GLRegister."From Withholding Tax Entry No." := NextWHTEntryNo;
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforePostingDeferral, '', false, false)]
    local procedure OnAfterVendLedgEntryInsert(GenJnlLine: Record "Gen. Journal Line"; VendLedgEntry: Record "Vendor Ledger Entry"; TaxAmount: Decimal; TaxAmountLCY: Decimal; NextTransactionNo: Integer; var NextTaxEntryNo: Integer; var IsHandled: Boolean; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJnlLine) then
            exit;

        PostVendWithholdingTax(GenJnlLine, VendLedgEntry, TaxAmount, TaxAmountLCY, NextTransactionNo, NextTaxEntryNo, sender);
    end;

    local procedure CalcGLAccWithholdingTax(GenJnlLine: Record "Gen. Journal Line"; var WithholdingAmountLCY: Decimal)
    var
        GenJnlLine1: Record "Gen. Journal Line";
        CurrExchRate: Record "Currency Exchange Rate";
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
        CurrFactor: Decimal;
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        WithholdingAmountLCY := 0;
        if GeneralLedgerSetup."Enable Withholding Tax" then
            if not GenJnlLine."Skip Withholding Tax" then
                if (GenJnlLine."Applies-to ID" = '') and (GenJnlLine."Applies-to Doc. No." = '') then begin
                    if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment) or
                       (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund)
                    then
                        if WithholdingPostingSetup.Get(
                             GenJnlLine."Wthldg. Tax Bus. Post. Group",
                             GenJnlLine."Wthldg. Tax Prod. Post. Group")
                        then
                            if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then
                                if IsVendAcc(GenJnlLine) then begin
                                    if GenJnlLine."Withholding Tax Absorb Base" <> 0 then
                                        WithholdingAmountLCY :=
                                          Abs(Round(GenJnlLine."Withholding Tax Absorb Base" * WithholdingPostingSetup."Withholding Tax %" / 100))
                                    else
                                        WithholdingAmountLCY :=
                                          Abs(Round(GenJnlLine.Amount * WithholdingPostingSetup."Withholding Tax %" / 100));

                                    if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund then
                                        WithholdingAmountLCY := -Abs(WithholdingAmountLCY);
                                end;
                end else
                    if (GenJnlLine."Applies-to ID" <> '') or (GenJnlLine."Applies-to Doc. No." <> '') then begin
                        GenJnlLine1.Reset();
                        GenJnlLine1.Copy(GenJnlLine);
                        if GenJnlLine."Applies-to Doc. No." <> '' then
                            GenJnlLine1.SetRange("Applies-to Doc. No.", GenJnlLine."Applies-to Doc. No.")
                        else
                            GenJnlLine1.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");

                        GenJnlLine1.SetRange("Account Type", GenJnlLine."Account Type"::Vendor);
                        if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor) or
                           (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Vendor) or
                           GenJnlLine1.FindFirst()
                        then begin
                            CurrFactor := GenJnlLine1."Currency Factor";

                            if GenJnlLine1."WHT Interest Amount" <> 0 then
                                GenJnlLine1.Validate(Amount, GenJnlLine1.Amount - GenJnlLine1."WHT Interest Amount");

                            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment) or
                               (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund)
                            then
                                if WithholdingPostingSetup.Get(
                                     GenJnlLine."Wthldg. Tax Bus. Post. Group",
                                     GenJnlLine."Wthldg. Tax Prod. Post. Group")
                                then begin
                                    if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then begin
                                        if GenJnlLine1.FindFirst() then
                                            WithholdingTaxMgmt.CheckApplicationGenPurchWithholdingTax(GenJnlLine1);
                                        WithholdingAmountLCY :=
                                          CurrExchRate.ExchangeAmtFCYToLCY(
                                            GenJnlLine."Document Date",
                                            GenJnlLine."Currency Code",
                                            Abs(
                                              WithholdingTaxMgmt.CalcVendExtraWithholdingForEarliest(GenJnlLine1)), CurrFactor);
                                    end;

                                    if (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Payment)
                                    then
                                        WithholdingAmountLCY :=
                                          CurrExchRate.ExchangeAmtFCYToLCY(
                                            GenJnlLine."Document Date",
                                            GenJnlLine."Currency Code",
                                            Abs(
                                              WithholdingTaxMgmt.WithholdingAmountJournal(GenJnlLine1, true)), CurrFactor);
                                end;

                            if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund then
                                WithholdingAmountLCY := -Abs(WithholdingAmountLCY);
                        end;

                        WithholdingAmountLCY := Round(WithholdingAmountLCY);
                    end;

        if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group",
             GenJnlLine."Wthldg. Tax Prod. Post. Group")
        then
            if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then
                if Abs(GenJnlLine.Amount) < WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                    WithholdingAmountLCY := 0;
    end;

    local procedure CalcSourceCurrVATBaseAmount(var GenJnlLine: Record "Gen. Journal Line"; WithholdingAmountLCY: Decimal; var sender: Codeunit "Gen. Jnl.-Post Line"): Decimal
    var
        SourceCurrVATBaseAmount: Decimal;
    begin
        if (GenJnlLine."Source Currency Code" <> '') and ((not GenJnlLine."System-Created Entry") or GenJnlLine."Financial Void") then begin
            if GenJnlLine."Source Curr. VAT Base Amount" <> 0 then
                SourceCurrVATBaseAmount := GenJnlLine."Source Curr. VAT Base Amount" + sender.CalcAmountSourceCurrency(GenJnlLine, WithholdingAmountLCY)
            else
                SourceCurrVATBaseAmount := GenJnlLine."Source Currency Amount" + sender.CalcAmountSourceCurrency(GenJnlLine, WithholdingAmountLCY);
        end else
            SourceCurrVATBaseAmount := sender.CalcAmountSourceCurrency(GenJnlLine, GenJnlLine."VAT Base Amount (LCY)" + WithholdingAmountLCY);

        exit(SourceCurrVATBaseAmount);
    end;


    procedure IsVendAcc(GenJnlLine: Record "Gen. Journal Line"): Boolean
    begin
        exit((GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor) or (GenJnlLine."Bal. Account Type" = GenJnlLine."Account Type"::Vendor));
    end;

    procedure PostGLAccWithholdingTax(GenJnlLine: Record "Gen. Journal Line"; WHTAmountLCY: Decimal; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        if WHTAmountLCY = 0 then
            exit;

        if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Invoice then
            exit;

        case true of
            IsVendAcc(GenJnlLine):
                if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then
                    if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then
                        Sender.CreateGLEntry(
                          GenJnlLine, WithholdingPostingSetup."Payable Wthldg. Tax Acc. Code", -WHTAmountLCY, -WHTAmountLCY, true);
        end;
    end;

    procedure CalcVendWithholdingTax(GenJnlLine: Record "Gen. Journal Line"; var WHTAmountLCY: Decimal; var WHTAmount: Decimal)
    var
        SourceCodeSetup: Record "Source Code Setup";
        GenJnlLine1: Record "Gen. Journal Line";
        CurrExchRate: Record "Currency Exchange Rate";
        GLSetup: Record "General Ledger Setup";
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        WHTAmountLCY := 0;
        SourceCodeSetup.Get();
        GLSetup.Get();

        if ProcessSourceCode(GenJnlLine."Source Code", SourceCodeSetup) then begin
            GenJnlLine1.Reset();
            GenJnlLine1.Copy(GenJnlLine);

            if GLSetup."Enable Withholding Tax" then
                if not GenJnlLine1."Skip Withholding Tax" then
                    if (GenJnlLine1."Applies-to Doc. No." = '') and
                       (GenJnlLine1."Applies-to ID" = '')
                    then begin
                        if (((GenJnlLine1."Document Type" = GenJnlLine1."Document Type"::Invoice) or
                             (GenJnlLine1."Document Type" = GenJnlLine1."Document Type"::"Credit Memo")) and
                            ((GenJnlLine1."Account Type" = GenJnlLine1."Account Type"::"G/L Account") or
                             (GenJnlLine1."Bal. Account Type" = GenJnlLine1."Bal. Account Type"::"G/L Account")))
                        then
                            if WithholdingPostingSetup.Get(GenJnlLine1."Wthldg. Tax Bus. Post. Group", GenJnlLine1."Wthldg. Tax Prod. Post. Group") then
                                if (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Invoice) or
                                   (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest)
                                then begin
                                    if GenJnlLine1."Withholding Tax Absorb Base" <> 0 then
                                        WHTAmountLCY :=
                                          -Round(
                                            CurrExchRate.ExchangeAmtFCYToLCY(
                                              GenJnlLine."Posting Date", GenJnlLine."Currency Code",
                                              Round(GenJnlLine1."Withholding Tax Absorb Base" * WithholdingPostingSetup."Withholding Tax %" / 100), GenJnlLine."Currency Factor"))
                                    else
                                        WHTAmountLCY :=
                                          Round(
                                            CurrExchRate.ExchangeAmtFCYToLCY(
                                              GenJnlLine."Posting Date", GenJnlLine."Currency Code",
                                              Round(GenJnlLine1.Amount * WithholdingPostingSetup."Withholding Tax %" / 100), GenJnlLine."Currency Factor"));

                                    WHTAmount := CalcDtldCVLedgEntryAmount(GenJnlLine, WithholdingPostingSetup."Withholding Tax %");
                                end;
                    end else
                        if (((GenJnlLine1."Document Type" = GenJnlLine1."Document Type"::Invoice) or
                             (GenJnlLine1."Document Type" = GenJnlLine1."Document Type"::"Credit Memo")) and
                            ((GenJnlLine1."Account Type" = GenJnlLine1."Account Type"::"G/L Account") or
                             (GenJnlLine1."Bal. Account Type" = GenJnlLine1."Bal. Account Type"::"G/L Account")))
                        then
                            if WithholdingPostingSetup.Get(GenJnlLine1."Wthldg. Tax Bus. Post. Group", GenJnlLine1."Wthldg. Tax Prod. Post. Group") then begin
                                if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then begin
                                    GenJnlLine1.Reset();
                                    GenJnlLine1.Copy(GenJnlLine);
                                    if GenJnlLine1.FindFirst() then
                                        WithholdingTaxMgmt.CheckApplicationGenPurchWithholdingTax(GenJnlLine1);

                                    WHTAmountLCY := Round(WithholdingTaxMgmt.CalcVendExtraWithholdingForEarliest(GenJnlLine1));
                                    WHTAmount := WHTAmountLCY;
                                end;

                                if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Invoice then begin
                                    GenJnlLine1.Reset();
                                    GenJnlLine1.Copy(GenJnlLine);
                                    if GenJnlLine1.FindFirst() then
                                        WithholdingTaxMgmt.CheckApplicationGenPurchWithholdingTax(GenJnlLine1);

                                    if GenJnlLine1."Withholding Tax Absorb Base" <> 0 then
                                        WHTAmountLCY :=
                                          -Round(
                                            CurrExchRate.ExchangeAmtFCYToLCY(
                                              GenJnlLine."Posting Date", GenJnlLine."Currency Code",
                                              Round(GenJnlLine1."Withholding Tax Absorb Base" * WithholdingPostingSetup."Withholding Tax %" / 100), GenJnlLine."Currency Factor"))
                                    else
                                        WHTAmountLCY :=
                                          Round(
                                            CurrExchRate.ExchangeAmtFCYToLCY(
                                              GenJnlLine."Posting Date", GenJnlLine."Currency Code",
                                              Round(GenJnlLine1.Amount * WithholdingPostingSetup."Withholding Tax %" / 100), GenJnlLine."Currency Factor"));

                                    WHTAmount := CalcDtldCVLedgEntryAmount(GenJnlLine, WithholdingPostingSetup."Withholding Tax %");
                                end;
                            end;

            if GenJnlLine1."Document Type" = GenJnlLine1."Document Type"::Invoice then begin
                WHTAmountLCY := -Abs(WHTAmountLCY);
                WHTAmount := -Abs(WHTAmount);
            end else begin
                WHTAmountLCY := Abs(WHTAmountLCY);
                WHTAmount := Abs(WHTAmount);
            end;
        end;

        if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then
            if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then
                if GenJnlLine.Amount < WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                    WHTAmountLCY := 0;
    end;

    procedure ProcessSourceCode(SourceCode: Code[10]; SourceCodeSetup: Record "Source Code Setup"): Boolean
    begin
        exit(SourceCode in [SourceCodeSetup."Payment Journal",
                            SourceCodeSetup."Purchase Journal",
                            SourceCodeSetup."Sales Journal",
                            SourceCodeSetup."Cash Receipt Journal",
                            SourceCodeSetup."General Journal"]);
    end;

    procedure PostVendWithholdingTax(GenJnlLine: Record "Gen. Journal Line"; VendLedgEntry: Record "Vendor Ledger Entry"; WithholdingAmount: Decimal; WithholdingAmountLCY: Decimal; NextTransactionNo: Integer; var NextWHTEntryNo: Integer; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJnlLine1, GenJnlLine2 : Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
        GLSetup: Record "General Ledger Setup";
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
        KeepWHTEntryNo: Integer;
        HadWHTEntryNo: Boolean;
    begin
        if not WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then
            exit;

        WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group");

        GenJnlLine1.Reset();
        GenJnlLine1.Copy(GenJnlLine);
        if WithholdingAmountLCY <> 0 then
            if (GenJnlLine1."Document Type" = GenJnlLine1."Document Type"::Invoice) or
               (GenJnlLine1."Document Type" = GenJnlLine1."Document Type"::"Credit Memo")
            then
                if (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Invoice) or
                   (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest)
                then
                    sender.CreateGLEntry(
                      GenJnlLine, WithholdingPostingSetup."Payable Wthldg. Tax Acc. Code", WithholdingAmountLCY, WithholdingAmountLCY, true);

        SourceCodeSetup.Get();
        GLSetup.Get();

        if GenJnlLine."Source Code" <> SourceCodeSetup."Financially Voided Check" then begin
            GenJnlLine1.Reset();
            if GLSetup."Enable Withholding Tax" then
                if IsAboveWithholdingMinInvAmount(GenJnlLine) then begin
                    if (GenJnlLine."Applies-to Doc. No." <> '') or (GenJnlLine."Applies-to ID" <> '') then begin
                        GenJnlLine1.Copy(GenJnlLine);
                        if GenJnlLine1."WHT Interest Amount" <> 0 then
                            GenJnlLine1.Validate(Amount, GenJnlLine1.Amount - GenJnlLine1."WHT Interest Amount");

                        if not GenJnlLine."Skip Withholding Tax" then begin
                            KeepWHTEntryNo := NextWHTEntryNo;
                            case GenJnlLine."Document Type" of
                                GenJnlLine."Document Type"::"Credit Memo":
                                    begin
                                        if ProcessSourceCode(GenJnlLine."Source Code", SourceCodeSetup) then
                                            if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then
                                                if (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Invoice) or
                                                   (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest)
                                                then begin
                                                    GenJnlLine2.Reset();
                                                    GenJnlLine2.Copy(GenJnlLine);
                                                    GenJnlLine2.Amount := -Abs(GenJnlLine2.Amount);
                                                    GenJnlLine2."Withholding Tax Absorb Base" := -Abs(GenJnlLine2."Withholding Tax Absorb Base");
                                                    NextWHTEntryNo := WithholdingTaxMgmt.InsertVendJournalWithholdingTax(GenJnlLine2);
                                                    if WithholdingTaxEntry.Get(NextWHTEntryNo - 1) then begin
                                                        WithholdingTaxEntry."Transaction No." := NextTransactionNo;
                                                        WithholdingTaxEntry.Modify();
                                                    end;
                                                end;

                                        if SourceCodeSetup.Purchases = GenJnlLine."Source Code" then
                                            UpdateWithholdingEntryTransaction(GenJnlLine."Document No.", NextTransactionNo);
                                    end;

                                GenJnlLine."Document Type"::Payment:
                                    if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then begin
                                        if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Payment then begin
                                            NextWHTEntryNo := WithholdingTaxMgmt.ApplyVendInvoiceWHT(VendLedgEntry, GenJnlLine1);
                                            if NextWHTEntryNo <> -1 then
                                                HadWHTEntryNo := true
                                            else
                                                NextWHTEntryNo := KeepWHTEntryNo;
                                        end;

                                        if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then begin
                                            NextWHTEntryNo := WithholdingTaxMgmt.InsertVendJournalWithholdingTax(GenJnlLine);
                                            if WithholdingTaxEntry.Get(NextWHTEntryNo - 1) then begin
                                                WithholdingTaxEntry."Transaction No." := NextTransactionNo;
                                                WithholdingTaxEntry.Modify();
                                            end;
                                        end;
                                    end;

                                GenJnlLine."Document Type"::Refund:
                                    if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then begin
                                        if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Payment then begin
                                            NextWHTEntryNo := WithholdingTaxMgmt.ApplyVendInvoiceWHT(VendLedgEntry, GenJnlLine1);
                                            if NextWHTEntryNo <> -1 then
                                                HadWHTEntryNo := true
                                            else
                                                NextWHTEntryNo := KeepWHTEntryNo;
                                        end;

                                        if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then begin
                                            NextWHTEntryNo := WithholdingTaxMgmt.InsertVendJournalWithholdingTax(GenJnlLine);
                                            if WithholdingTaxEntry.Get(NextWHTEntryNo - 1) then begin
                                                WithholdingTaxEntry."Transaction No." := NextTransactionNo;
                                                WithholdingTaxEntry.Modify();
                                            end;
                                        end;
                                    end;

                                GenJnlLine."Document Type"::Invoice:
                                    begin
                                        if ProcessSourceCode(GenJnlLine."Source Code", SourceCodeSetup) then
                                            if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then
                                                if (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Invoice) or
                                                   (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest)
                                                then begin
                                                    GenJnlLine2.Reset();
                                                    GenJnlLine2.Copy(GenJnlLine);
                                                    GenJnlLine2.Amount := -Abs(GenJnlLine2.Amount);
                                                    GenJnlLine2."Withholding Tax Absorb Base" := -Abs(GenJnlLine2."Withholding Tax Absorb Base");
                                                    NextWHTEntryNo := WithholdingTaxMgmt.InsertVendJournalWithholdingTax(GenJnlLine2);
                                                    if WithholdingTaxEntry.Get(NextWHTEntryNo - 1) then begin
                                                        WithholdingTaxEntry."Transaction No." := NextTransactionNo;
                                                        WithholdingTaxEntry.Modify();
                                                    end;
                                                end;

                                        if SourceCodeSetup.Purchases = GenJnlLine."Source Code" then
                                            UpdateWithholdingEntryTransaction(GenJnlLine."Document No.", NextTransactionNo);
                                    end;
                            end;
                        end;

                        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::Purchases);
                        if GenJournalTemplate.FindFirst() then
                            if GenJnlLine."Journal Template Name" = GenJournalTemplate.Name then begin
                                WithholdingTaxEntry.Reset();
                                WithholdingTaxEntry.SetRange("Document Type", WithholdingTaxEntry."Document Type"::Payment);
                                WithholdingTaxEntry.SetRange("Document No.", GenJnlLine."Document No.");
                                WithholdingTaxEntry.SetRange("Bill-to/Pay-to No.", GenJnlLine."Account No.");
                                if WithholdingTaxEntry.FindSet() then
                                    repeat
                                        WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                                        WithholdingPostingSetup.TestField("Payable Wthldg. Tax Acc. Code");
                                        sender.CreateGLEntry(
                                          GenJnlLine, WithholdingPostingSetup."Payable Wthldg. Tax Acc. Code", -WithholdingTaxEntry."Amount (LCY)", GenJnlLine."Source Currency Amount", true);
                                    until WithholdingTaxEntry.Next() = 0;
                            end;
                    end else begin
                        KeepWHTEntryNo := NextWHTEntryNo;

                        case GenJnlLine."Document Type" of
                            GenJnlLine."Document Type"::Invoice,
                            GenJnlLine."Document Type"::"Credit Memo":
                                begin
                                    if ProcessSourceCode(GenJnlLine."Source Code", SourceCodeSetup) then begin
                                        GenJnlLine2.Reset();
                                        GenJnlLine2.Copy(GenJnlLine);
                                        GenJnlLine2."Withholding Tax Absorb Base" := -Abs(GenJnlLine2."Withholding Tax Absorb Base");
                                        NextWHTEntryNo := WithholdingTaxMgmt.InsertVendJournalWithholdingTax(GenJnlLine2);
                                    end;

                                    UpdateWithholdingEntryTransaction(GenJnlLine."Document No.", NextTransactionNo);
                                end;

                            GenJnlLine."Document Type"::Payment,
                            GenJnlLine."Document Type"::Refund:
                                if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then
                                    if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then begin
                                        NextWHTEntryNo := WithholdingTaxMgmt.InsertVendJournalWithholdingTax(GenJnlLine);
                                        if WithholdingTaxEntry.Get(NextWHTEntryNo - 1) then begin
                                            WithholdingTaxEntry."Transaction No." := NextTransactionNo;
                                            WithholdingTaxEntry.Modify();
                                        end;
                                    end;

                            GenJnlLine."Document Type"::" ":
                                NextWHTEntryNo := KeepWHTEntryNo;
                        end;
                    end;

                    if NextWHTEntryNo = 0 then
                        NextWHTEntryNo := KeepWHTEntryNo;
                end;

            if GenJnlLine."Applies-to ID" <> '' then begin
                VendLedgEntry.Reset();
                VendLedgEntry.SetCurrentKey("Vendor No.", "Applies-to ID", Open, Positive, "Due Date");
                VendLedgEntry.SetRange("Vendor No.", GenJnlLine."Account No.");
                VendLedgEntry.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
                VendLedgEntry.SetRange("Amount to Apply", 0);
                VendLedgEntry.ModifyAll("Applies-to ID", '');
            end;
        end;
    end;

    procedure UpdateWithholdingEntryTransaction(DocNo: Code[20]; NextTransactionNo: Integer)
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetCurrentKey("Document No.", "Posting Date");
        WithholdingTaxEntry.SetRange("Document No.", DocNo);
        if WithholdingTaxEntry.FindSet() then
            repeat
                WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");
                if (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Invoice) or
                   (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest)
                then begin
                    WithholdingTaxEntry."Transaction No." := NextTransactionNo;
                    WithholdingTaxEntry.Modify();
                end;
            until WithholdingTaxEntry.Next() = 0;
    end;

    local procedure CalcDtldCVLedgEntryAmount(GenJnlLine: Record "Gen. Journal Line"; WithholdingTaxPercent: Decimal): Decimal
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        if GenJnlLine."Withholding Tax Absorb Base" <> 0 then
            exit(GenJnlPostLine.ExchangeAmtLCYToFCY2(-Round(GenJnlLine."Withholding Tax Absorb Base" * WithholdingTaxPercent / 100)));

        exit(GenJnlPostLine.ExchangeAmtLCYToFCY2(Round(GenJnlLine.Amount * WithholdingTaxPercent / 100)));
    end;

    local procedure IsAboveWithholdingMinInvAmount(GenJnlLine: Record "Gen. Journal Line"): Boolean
    var
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        if not (GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Invoice, GenJnlLine."Document Type"::"Credit Memo"]) then
            exit(true);

        if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then
            exit(Abs(GenJnlLine.Amount) >= WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount");

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostBankAccOnBeforeInitBankAccLedgEntry, '', false, false)]
    local procedure OnPostBankAccOnBeforeInitBankAccLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; var TaxAmount: Decimal; var TaxAmountLCY: Decimal)
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        CalcBankAccWHT(GenJournalLine, TaxAmountLCY, TaxAmount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeBankAccLedgEntryUpdateAmounts, '', false, false)]
    local procedure OnBeforeBankAccLedgEntryUpdateAmounts(var BankAccountLedgerEntry: Record "Bank Account Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; BankAccount: Record "Bank Account"; TaxAmount: Decimal; TaxAmountLCY: Decimal)
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        BankAccount.Get(GenJournalLine."Account No.");
        if BankAccount."Currency Code" <> '' then
            BankAccountLedgerEntry.Amount := GenJournalLine.Amount + TaxAmount
        else
            BankAccountLedgerEntry.Amount := GenJournalLine."Amount (LCY)" + TaxAmountLCY;
        BankAccountLedgerEntry."Amount (LCY)" := GenJournalLine."Amount (LCY)" + TaxAmountLCY;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostBankAccOnBeforeCheckLedgEntryInsert, '', false, false)]
    local procedure OnPostBankAccOnBeforeCheckLedgEntryInsert(var CheckLedgerEntry: Record "Check Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; TaxAmount: Decimal; TaxAmountLCY: Decimal)
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        PostBankAccWHTOnBeforeCheckLedgEntryInsert(CheckLedgerEntry, GenJournalLine, TaxAmountLCY);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnPostBankAccOnBeforeCreateGLEntryBalAcc, '', false, false)]
    local procedure OnPostBankAccOnBeforeCreateGLEntryBalAcc(var GenJnlLine: Record "Gen. Journal Line"; BankAccPostingGr: Record "Bank Account Posting Group"; TaxAmount: Decimal; TaxAmountLCY: Decimal; sender: Codeunit "Gen. Jnl.-Post Line"; var IsHandled: Boolean)
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJnlLine) then
            exit;

        sender.CreateGLEntryBalAcc(
              GenJnlLine, BankAccPostingGr."G/L Account No.",
              GenJnlLine."Amount (LCY)" + TaxAmountLCY, GenJnlLine."Source Currency Amount" + TaxAmount,
              GenJnlLine."Bal. Account Type", GenJnlLine."Bal. Account No.");
        PostBankAccWHT(GenJnlLine, TaxAmountLCY, sender);
        IsHandled := true;
    end;

    local procedure CalcBankAccWHT(GenJnlLine: Record "Gen. Journal Line"; var WithholdingAmountLCY: Decimal; var WithholdingAmount: Decimal)
    var
        CheckLedgEntry: Record "Check Ledger Entry";
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
        GLSetup: Record "General Ledger Setup";
        CurrExchRate: Record "Currency Exchange Rate";
        GenJnlLine1: Record "Gen. Journal Line";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
        CurrFactor: Decimal;
    begin
        WithholdingAmountLCY := 0;
        GLSetup.Get();

        if not GLSetup."Enable Withholding Tax" or GenJnlLine."Skip Withholding Tax" then
            exit;

        if (GenJnlLine."Applies-to ID" = '') and (GenJnlLine."Applies-to Doc. No." = '') then begin
            if (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Payment) or (GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund) then
                if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then begin
                    if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then
                        if IsVendAcc(GenJnlLine) then begin
                            if GenJnlLine."Withholding Tax Absorb Base" <> 0 then
                                WithholdingAmountLCY := Abs(Round(GenJnlLine."Withholding Tax Absorb Base" * WithholdingPostingSetup."Withholding Tax %" / 100))
                            else
                                WithholdingAmountLCY := Abs(Round(GenJnlLine.Amount * WithholdingPostingSetup."Withholding Tax %" / 100));
                            if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund then
                                WithholdingAmountLCY := -Abs(WithholdingAmountLCY);
                        end;

                    if (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Payment) and (not GenJnlLine."Financial Void") then
                        Error(PaymentJournalPostApplyErr, WithholdingPostingSetup."Realized Withholding Tax Type");
                end;

            if (GenJnlLine."Currency Code" <> '') and (CurrFactor <> 0) then
                if (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Payment) then
                    WithholdingAmountLCY :=
                      CurrExchRate.ExchangeAmtFCYToLCY(
                        GenJnlLine."Document Date", GenJnlLine."Currency Code",
                        Abs(WithholdingTaxMgmt.WithholdingAmountJournal(GenJnlLine, true)), CurrFactor);
        end else
            if (GenJnlLine."Applies-to ID" <> '') or (GenJnlLine."Applies-to Doc. No." <> '') then begin
                GenJnlLine1.Reset();
                GenJnlLine1.Copy(GenJnlLine);
                if GenJnlLine."Applies-to Doc. No." <> '' then
                    GenJnlLine1.SetRange("Applies-to Doc. No.", GenJnlLine."Applies-to Doc. No.")
                else
                    GenJnlLine1.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");

                GenJnlLine1.SetRange("Account Type", GenJnlLine."Account Type"::Vendor);
                if (GenJnlLine."Account Type" = GenJnlLine."Account Type"::Vendor) or
                   (GenJnlLine."Bal. Account Type" = GenJnlLine."Bal. Account Type"::Vendor) or
                   GenJnlLine1.FindFirst()
                then begin
                    CurrFactor :=
                      CurrExchRate.ExchangeRate(
                        GenJnlLine."Document Date", GenJnlLine."Currency Code");

                    if GenJnlLine1."WHT Interest Amount" <> 0 then
                        GenJnlLine1.Validate(Amount, GenJnlLine1.Amount - GenJnlLine1."WHT Interest Amount");

                    if (GenJnlLine1."Document Type" = GenJnlLine1."Document Type"::Payment) or
                       (GenJnlLine1."Document Type" = GenJnlLine1."Document Type"::Refund)
                    then
                        if WithholdingPostingSetup.Get(
                             GenJnlLine1."Wthldg. Tax Bus. Post. Group",
                             GenJnlLine1."Wthldg. Tax Prod. Post. Group")
                        then begin
                            if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then begin
                                if GenJnlLine1.FindFirst() then
                                    WithholdingTaxMgmt.CheckApplicationGenPurchWithholdingTax(GenJnlLine1);
                                WithholdingAmountLCY :=
                                  CurrExchRate.ExchangeAmtFCYToLCY(
                                    GenJnlLine."Document Date", GenJnlLine."Currency Code",
                                    Abs(WithholdingTaxMgmt.CalcVendExtraWithholdingForEarliest(GenJnlLine1)), CurrFactor);
                            end;

                            if (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Payment) then begin
                                WithholdingAmount := Abs(WithholdingTaxMgmt.WithholdingAmountJournal(GenJnlLine1, true));
                                WithholdingAmountLCY :=
                                  CurrExchRate.ExchangeAmtFCYToLCY(
                                    GenJnlLine1."Document Date",
                                    GenJnlLine1."Currency Code",
                                    WithholdingAmount, CurrFactor);
                            end;
                        end;

                    if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund then
                        WithholdingAmountLCY := -Abs(WithholdingAmountLCY);
                end;

                WithholdingAmountLCY := Round(WithholdingAmountLCY);

                if GLSetup."Round Amount Wthldg. Tax Calc" then
                    WithholdingAmountLCY := WithholdingTaxMgmt.RoundWithholdingTaxAmount(WithholdingAmountLCY);
            end else
                if GenJnlLine."Bank Payment Type" =
                   GenJnlLine."Bank Payment Type"::"Computer Check"
                then begin
                    GenJnlLine.TestField("Check Printed", true);
                    CheckLedgEntry.LockTable();
                    CheckLedgEntry.Reset();
                    CheckLedgEntry.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
                    CheckLedgEntry.SetRange("Bank Account No.", GenJnlLine."Account No.");
                    CheckLedgEntry.SetRange("Entry Status", CheckLedgEntry."Entry Status"::Printed);
                    CheckLedgEntry.SetRange("Check No.", GenJnlLine."Document No.");
                    if CheckLedgEntry.FindFirst() then
                        WithholdingAmountLCY := Abs(CheckLedgEntry."Withholding Tax Amount")
                end;

        if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then
            if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest then
                if Abs(GenJnlLine.Amount) < WithholdingPostingSetup."Wthldg. Tax Min. Inv. Amount" then
                    WithholdingAmountLCY := 0;
    end;

    local procedure PostBankAccWHTOnBeforeCheckLedgEntryInsert(var CheckLedgEntry: Record "Check Ledger Entry"; GenJnlLine: Record "Gen. Journal Line"; WithholdingAmountLCY: Decimal)
    var
        GenJnlLine1: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        BankAcc: Record "Bank Account";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        GenJnlLine1.Reset();
        GenJnlLine1.Copy(GenJnlLine);

        if GLSetup."Enable Withholding Tax" then
            if not GenJnlLine."Skip Withholding Tax" then
                CheckLedgEntry."Withholding Tax Amount" := Abs(-WithholdingTaxMgmt.WithholdingAmountJournal(GenJnlLine1, false));

        CheckLedgEntry."WHT Interest Amount" := GenJnlLine."WHT Interest Amount";

        BankAcc.Get(GenJnlLine."Account No.");
        if BankAcc."Currency Code" <> '' then
            CheckLedgEntry.Amount := -GenJnlLine.Amount - CheckLedgEntry."Withholding Tax Amount"
        else begin
            if WithholdingAmountLCY <> 0 then
                CheckLedgEntry."Withholding Tax Amount" := WithholdingAmountLCY;
            CheckLedgEntry.Amount := -GenJnlLine."Amount (LCY)" - CheckLedgEntry."Withholding Tax Amount";
        end;
    end;

    local procedure PostBankAccWHT(GenJnlLine: Record "Gen. Journal Line"; WithholdingAmountLCY: Decimal; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
    begin
        if WithholdingAmountLCY = 0 then
            exit;

        case true of
            IsVendAcc(GenJnlLine):
                if WithholdingPostingSetup.Get(GenJnlLine."Wthldg. Tax Bus. Post. Group", GenJnlLine."Wthldg. Tax Prod. Post. Group") then
                    if ((WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Earliest) or
                        (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Payment)) and
                       ((GenJnlLine."Applies-to Doc. No." = '') and (GenJnlLine."Applies-to ID" = ''))
                    then begin
                        WithholdingPostingSetup.TestField("Payable Wthldg. Tax Acc. Code");
                        sender.CreateGLEntry(
                          GenJnlLine, WithholdingPostingSetup."Payable Wthldg. Tax Acc. Code", -WithholdingAmountLCY, -WithholdingAmountLCY, true);
                    end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeCopyFromCVLedgEntryBuffer, '', false, false)]
    local procedure OnBeforeCopyFromCVLedgEntryBuffer(var GenJnlLine: Record "Gen. Journal Line"; OldVendLedgEntry: Record "Vendor Ledger Entry"; TempOldVendLedgEntry: Record "Vendor Ledger Entry" temporary; AppliedAmount: Decimal; var RemainingTaxAmount: Decimal; NextTransactionNo: Integer; var NextTaxEntryNo: Integer)
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJnlLine) then
            exit;

        ApplyVendLedgEntryOnBeforeOldVendLedgEntryModify(GenJnlLine, OldVendLedgEntry, TempOldVendLedgEntry, AppliedAmount, RemainingTaxAmount, NextTransactionNo, NextTaxEntryNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeUpdateOldVendLedgEntryAmountToApply, '', false, false)]
    local procedure OnBeforeUpdateOldVendLedgEntryAmountToApply(var OldVendLedgEntry: Record "Vendor Ledger Entry"; OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; RemainingTaxAmount: Decimal; AppliedAmount: Decimal; GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJnlLine) then
            exit;

        UpdateAmountToApply(OldVendLedgEntry, RemainingTaxAmount, AppliedAmount, IsHandled);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterOldVendLedgEntryModify, '', false, false)]
    local procedure OnAfterOldVendLedgEntryModify(GenJournalLine: Record "Gen. Journal Line"; AppliedAmount: Decimal; var NextTaxEntryNo: Integer; var NextEntryNo: Integer; var NextCheckEntryNo: Integer; NextTransactionNo: Integer; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        ApplyWHT(GenJournalLine, AppliedAmount, NextTaxEntryNo, NextEntryNo, NextCheckEntryNo, NextTransactionNo, sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnVendUnrealizedVATOnBeforeGetUnrealizedVATPart, '', false, false)]
    local procedure OnVendUnrealizedVATOnBeforeGetUnrealizedVATPart(var GenJournalLine: Record "Gen. Journal Line"; var VendorLedgerEntry: Record "Vendor Ledger Entry"; VATEntry2: Record "VAT Entry"; SettledAmount: Decimal; PaidAmount: Decimal; TotalUnrealVATAmountFirst: Decimal; TotalUnrealVATAmountLast: Decimal; var VATPart: Decimal; var IsHandled: Boolean)
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
        WithholdingTaxAmount: Decimal;
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        VATPart := GetUnrealizedVATPart(VATEntry2,
                        Round(SettledAmount / VendorLedgerEntry.GetAdjustedCurrencyFactor()),
                        PaidAmount,
                        VendorLedgerEntry."Amount (LCY)" - WithholdingTaxAmount,
                        TotalUnrealVATAmountFirst,
                        TotalUnrealVATAmountLast);

        IsHandled := true;
    end;

    local procedure GetUnrealizedVATPart(VATEntry: Record "VAT Entry"; SettledAmount: Decimal; Paid: Decimal; Full: Decimal; TotalUnrealVATAmountFirst: Decimal; TotalUnrealVATAmountLast: Decimal): Decimal
    var
        UnrealizedVATType: Option " ",Percentage,First,Last,"First (Fully Paid)","Last (Fully Paid)";
    begin
        if (VATEntry.Type <> VATEntry.Type::" ") and
           (VATEntry.Amount = 0) and
           (VATEntry.Base = 0)
        then begin
            UnrealizedVATType := VATEntry.GetUnrealizedVATType();
            if (UnrealizedVATType = UnrealizedVATType::" ") or
               ((VATEntry."Remaining Unrealized Amount" = 0) and
                (VATEntry."Remaining Unrealized Base" = 0))
            then
                exit(0);

            if Abs(Paid) = Abs(Full) then
                exit(1);

            case UnrealizedVATType of
                UnrealizedVATType::Percentage:
                    begin
                        if Abs(Full) = Abs(Paid) - Abs(SettledAmount) then
                            exit(1);
                        if Full = 0 then
                            exit(Abs(SettledAmount) / (Abs(Paid) + Abs(SettledAmount)));
                        exit(Abs(SettledAmount) / (Abs(Full) - (Abs(Paid) - Abs(SettledAmount))));
                    end;
                UnrealizedVATType::First:
                    begin
                        if VATEntry."VAT Calculation Type" = VATEntry."VAT Calculation Type"::"Reverse Charge VAT" then
                            exit(1);
                        if Abs(Paid) < Abs(TotalUnrealVATAmountFirst) then
                            exit(Abs(SettledAmount) / Abs(TotalUnrealVATAmountFirst));
                        exit(1);
                    end;
                UnrealizedVATType::"First (Fully Paid)":
                    begin
                        if VATEntry."VAT Calculation Type" = VATEntry."VAT Calculation Type"::"Reverse Charge VAT" then
                            exit(1);
                        if Abs(Paid) < Abs(TotalUnrealVATAmountFirst) then
                            exit(0);
                        exit(1);
                    end;
                UnrealizedVATType::"Last (Fully Paid)":
                    exit(0);
                UnrealizedVATType::Last:
                    begin
                        if VATEntry."VAT Calculation Type" = VATEntry."VAT Calculation Type"::"Reverse Charge VAT" then
                            exit(0);
                        if Abs(Paid) > Abs(Full) - Abs(TotalUnrealVATAmountLast) then
                            exit((Abs(Paid) - (Abs(Full) - Abs(TotalUnrealVATAmountLast))) / Abs(TotalUnrealVATAmountLast));
                        exit(0);
                    end;
            end;
        end else
            exit(0);
    end;

    procedure CollectWithholdingTaxAmount(DocNo: Code[20]) WithholdingTaxAmount: Decimal
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
    begin
        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetCurrentKey(WithholdingTaxEntry."Document No.");
        WithholdingTaxEntry.SetRange(WithholdingTaxEntry."Document No.", DocNo);
        WithholdingTaxEntry.SetFilter(WithholdingTaxEntry."Applies-to Entry No.", '%1', 0);
        if WithholdingTaxEntry.FindSet() then
            repeat
                WithholdingTaxAmount := WithholdingTaxAmount + WithholdingTaxEntry."Unrealized Amount (LCY)";
            until WithholdingTaxEntry.Next() = 0;
    end;

    local procedure ApplyVendLedgEntryOnBeforeOldVendLedgEntryModify(GenJnlLine: Record "Gen. Journal Line"; OldVendLedgEntry: Record "Vendor Ledger Entry"; TempOldVendLedgEntry: Record "Vendor Ledger Entry" temporary; AppliedAmount: Decimal; var RemAmtWHT: Decimal; NextTransactionNo: Integer; var NextWHTEntryNo: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        GenJnlLine1: Record "Gen. Journal Line";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        GLSetup.Get();

        if GLSetup."Enable Withholding Tax" and
               (GenJnlLine."Document Type" in [GenJnlLine."Document Type"::Payment, GenJnlLine."Document Type"::Refund])
            then
            if (GenJnlLine."Applies-to Doc. No." = '') and (GenJnlLine."Applies-to ID" = '') then begin
                GenJnlLine1.Reset();
                GenJnlLine1.Copy(GenJnlLine);
                GenJnlLine1.Validate(Amount, AppliedAmount - GenJnlLine1."WHT Interest Amount");
                GenJnlLine1."Applies-to Doc. Type" := OldVendLedgEntry."Document Type";
                GenJnlLine1."Applies-to Doc. No." := OldVendLedgEntry."Document No.";
                NextWHTEntryNo := WithholdingTaxMgmt.ProcessPayment(GenJnlLine1, NextTransactionNo, OldVendLedgEntry."Entry No.", 0, true);
            end;

        RemAmtWHT := TempOldVendLedgEntry."Remaining Amount";
    end;

    local procedure UpdateAmountToApply(var OldVendLedgEntry: Record "Vendor Ledger Entry"; RemAmtWHT: Decimal; AppliedAmount: Decimal; var IsHandled: Boolean)
    begin
        OldVendLedgEntry."Rem. Amt for Withholding Tax" := -AppliedAmount;
        OldVendLedgEntry."WHT Rem. Amt" := RemAmtWHT;
        OldVendLedgEntry."Amount to Apply" := 0;
        // we don't clean "Applies-to ID" field here as it is required later for post posting processing in COD 13 / WHT functionality.
        IsHandled := true;
    end;

    local procedure ApplyWHT(GenJnlLine: Record "Gen. Journal Line"; AppliedAmount: Decimal; var NextWHTEntryNo: Integer; var NextEntryNo: Integer; var NextCheckEntryNo: Integer; NextTransactionNo: Integer; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJnlLine1: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        GLSetup: Record "General Ledger Setup";
        VendLedgEntry: Record "Vendor Ledger Entry";
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
        KeepWHTEntryNo: Integer;
        NextNo: Integer;
        HadWHTEntryNo: Boolean;
    begin
        GenJnlLine1.Reset();
        SourceCodeSetup.Get();
        GLSetup.Get();

        if GLSetup."Enable Withholding Tax" then
            if GenJnlLine."Source Code" = SourceCodeSetup."Purchase Entry Application" then
                if (GenJnlLine."Applies-to Doc. No." <> '') or (GenJnlLine."Applies-to ID" <> '') then begin
                    GenJnlLine1.Copy(GenJnlLine);
                    GenJnlLine1.Validate(Amount, AppliedAmount);
                    GenJnlLine1."Withholding Tax Entry No." := NextEntryNo;
                    if not GenJnlLine."Skip Withholding Tax" then begin
                        KeepWHTEntryNo := NextWHTEntryNo;

                        case GenJnlLine1."Document Type" of
                            GenJnlLine1."Document Type"::Payment:
                                begin
                                    NextNo := WithholdingTaxMgmt.ApplyVendInvoiceWHTPosted(VendLedgEntry, GenJnlLine1, NextTransactionNo);
                                    if NextWHTEntryNo <> -1 then
                                        HadWHTEntryNo := true
                                    else
                                        NextWHTEntryNo := KeepWHTEntryNo;

                                    WithholdingTaxEntry.SetRange("Original Document No.", GenJnlLine."Document No.");
                                    if WithholdingTaxEntry.FindFirst() then
                                        if WithholdingPostingSetup.Get(
                                             WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group",
                                             WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group")
                                        then
                                            if WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Payment then begin
                                                repeat
                                                    GenJnlLine1.Copy(GenJnlLine);
                                                    GenJnlLine1.Amount := WithholdingTaxEntry.Amount;
                                                    GenJnlLine1."Amount (LCY)" := WithholdingTaxEntry."Amount (LCY)";
                                                    InsertWHTPostingBufferPosted(WithholdingTaxEntry, GenJnlLine1, true, 1, NextEntryNo, NextCheckEntryNo, NextTransactionNo, sender);
                                                until WithholdingTaxEntry.Next() = 0;
                                                NextWHTEntryNo := WithholdingTaxEntry."Entry No." + 1;
                                            end;
                                end;
                        end;
                    end;
                end;
    end;

    procedure InsertWHTPostingBufferPosted(var WithholdingTaxEntryGL: Record "Withholding Tax Entry"; var GenJnlLine: Record "Gen. Journal Line"; Apply: Boolean; Source: Option Sales,Purchase; var NextEntryNo: Integer; var NextCheckEntryNo: Integer; NextTransactionNo: Integer; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        BankAcc: Record "Bank Account";
        BankAccLedgEntry: Record "Bank Account Ledger Entry";
        CheckLedgEntry: Record "Check Ledger Entry";
        CheckLedgEntry2: Record "Check Ledger Entry";
        BankAccPostingGr: Record "Bank Account Posting Group";
        PurchSetup: Record "General Ledger Setup";
        GenJnlLine1, GenJnlLine3 : Record "Gen. Journal Line";
        Vendor: Record Vendor;
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
        GLEntry: Record "G/L Entry";
        GLSetup: Record "General Ledger Setup";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        GLSetup.Get();

        if GLSetup."Enable Withholding Tax" then
            if GenJnlLine."Bill-to/Pay-to No." = '' then
                Vendor.Get(GenJnlLine."Account No.")
            else
                Vendor.Get(GenJnlLine."Bill-to/Pay-to No.");

        if WithholdingTaxEntryGL."Amount (LCY)" <> 0 then begin
            WithholdingPostingSetup.Get(WithholdingTaxEntryGL."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntryGL."Wthldg. Tax Prod. Post. Group");
            PurchSetup.Get();
            GenJnlLine3.Reset();
            GenJnlLine3 := GenJnlLine;
            GenJnlLine3.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
            GenJnlLine3.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
            GenJnlLine3."Line No." := 10000;

            GenJnlLine3.Init();
            GenJnlLine3.Validate("Posting Date", GenJnlLine."Posting Date");
            GenJnlLine3."Document Type" := GenJnlLine."Document Type";
            GenJnlLine3."Account Type" := GenJnlLine3."Account Type"::"G/L Account";
            GenJnlLine3.Validate("Currency Code", WithholdingTaxEntryGL."Currency Code");
            if Apply then
                GenJnlLine3.Validate(Amount, WithholdingTaxEntryGL.Amount)
            else
                GenJnlLine3.Validate(Amount, -WithholdingTaxEntryGL.Amount);

            if Source = Source::Purchase then begin
                if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund then
                    GenJnlLine3.Validate("Account No.", WithholdingPostingSetup."Purch. Wthldg. Tax Adj. Acc No")
                else
                    GenJnlLine3.Validate("Account No.", WithholdingPostingSetup."Payable Wthldg. Tax Acc. Code");

                case WithholdingPostingSetup."Bal. Payable Account Type" of
                    WithholdingPostingSetup."Bal. Payable Account Type"::"Bank Account":
                        GenJnlLine3."Bal. Account Type" := GenJnlLine3."Account Type"::"Bank Account";

                    WithholdingPostingSetup."Bal. Payable Account Type"::"G/L Account":
                        GenJnlLine3."Bal. Account Type" := GenJnlLine3."Account Type"::"G/L Account";
                end;

                GenJnlLine3.Validate("Bal. Account No.", WithholdingPostingSetup."Bal. Payable Account No.");
            end;

            GenJnlLine3.Validate("Currency Code", WithholdingTaxEntryGL."Currency Code");

            if Apply then begin
                GenJnlLine3.Validate(Amount, WithholdingTaxEntryGL.Amount);
                GenJnlLine3."Amount (LCY)" := WithholdingTaxEntryGL."Amount (LCY)";
            end else begin
                GenJnlLine3.Validate(Amount, -WithholdingTaxEntryGL.Amount);
                GenJnlLine3."Amount (LCY)" := -WithholdingTaxEntryGL."Amount (LCY)";
            end;

            GenJnlLine3.TestField("Bal. Account No.");
            GenJnlLine3."Source Code" := GenJnlLine."Source Code";
            GenJnlLine3."Reason Code" := GenJnlLine."Reason Code";
            GenJnlLine3."Shortcut Dimension 1 Code" := GenJnlLine."Shortcut Dimension 1 Code";
            GenJnlLine3."Shortcut Dimension 2 Code" := GenJnlLine."Shortcut Dimension 2 Code";
            GenJnlLine3."Allow Zero-Amount Posting" := true;
            GenJnlLine3."Wthldg. Tax Bus. Post. Group" := WithholdingTaxEntryGL."Wthldg. Tax Bus. Post. Group";
            GenJnlLine3."Wthldg. Tax Prod. Post. Group" := WithholdingTaxEntryGL."Wthldg. Tax Prod. Post. Group";
            GenJnlLine3."Document Type" := GenJnlLine."Document Type";
            GenJnlLine3."Document No." := GenJnlLine."Document No.";
            GenJnlLine3."External Document No." := GenJnlLine."External Document No.";

            if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund then
                GenJnlLine3."Gen. Posting Type" := GenJnlLine3."Gen. Posting Type"::" ";

            if NextEntryNo = 0 then
                NextEntryNo := GenJnlLine."Withholding Tax Entry No.";

            if Apply then begin
                if Source = Source::Purchase then
                    if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund then
                        sender.InitGLEntry(
                          GenJnlLine, GLEntry, WithholdingPostingSetup."Purch. Wthldg. Tax Adj. Acc No", -WithholdingTaxEntryGL."Amount (LCY)", 0, false, true)
                    else
                        sender.InitGLEntry(
                          GenJnlLine, GLEntry, WithholdingPostingSetup."Payable Wthldg. Tax Acc. Code", -WithholdingTaxEntryGL."Amount (LCY)", 0, false, true);

                GLEntry."Posting Date" := GenJnlLine3."Posting Date";
                GLEntry."Additional-Currency Amount" := -WithholdingTaxEntryGL.Amount;
            end else begin
                if Source = Source::Purchase then
                    if GenJnlLine."Document Type" = GenJnlLine."Document Type"::Refund then
                        sender.InitGLEntry(
                          GenJnlLine, GLEntry, WithholdingPostingSetup."Purch. Wthldg. Tax Adj. Acc No", WithholdingTaxEntryGL."Amount (LCY)", 0, false, true)
                    else
                        sender.InitGLEntry(
                          GenJnlLine, GLEntry, WithholdingPostingSetup."Payable Wthldg. Tax Acc. Code", WithholdingTaxEntryGL."Amount (LCY)", 0, false, true);

                GLEntry."Posting Date" := GenJnlLine3."Posting Date";
                GLEntry."Additional-Currency Amount" := WithholdingTaxEntryGL.Amount;
            end;

            GLEntry."Gen. Posting Type" := GenJnlLine."Gen. Posting Type";
            GLEntry."Gen. Bus. Posting Group" := GenJnlLine."Gen. Bus. Posting Group";
            GLEntry."Gen. Prod. Posting Group" := GenJnlLine."Gen. Prod. Posting Group";
            GLEntry."VAT Bus. Posting Group" := GenJnlLine."VAT Bus. Posting Group";
            GLEntry."VAT Prod. Posting Group" := GenJnlLine."VAT Prod. Posting Group";
            sender.InsertGLEntry(GenJnlLine, GLEntry, true);

            case GenJnlLine3."Bal. Account Type" of
                GenJnlLine3."Bal. Account Type"::"Bank Account":
                    begin
                        BankAccLedgEntry.LockTable();
                        if BankAcc."No." <> GenJnlLine3."Bal. Account No." then
                            BankAcc.Get(GenJnlLine3."Bal. Account No.");
                        BankAcc.TestField(Blocked, false);
                        if GenJnlLine3."Currency Code" = '' then
                            BankAcc.TestField("Currency Code", '')
                        else
                            if BankAcc."Currency Code" <> '' then
                                GenJnlLine3.TestField(GenJnlLine3."Currency Code", BankAcc."Currency Code");

                        BankAcc.TestField("Bank Acc. Posting Group");
                        BankAccPostingGr.Get(BankAcc."Bank Acc. Posting Group");

                        BankAccLedgEntry.Init();
                        BankAccLedgEntry."Bank Account No." := GenJnlLine3."Bal. Account No.";
                        BankAccLedgEntry."Posting Date" := GenJnlLine3."Posting Date";
                        BankAccLedgEntry."Document Date" := GenJnlLine3."Document Date";
                        BankAccLedgEntry."Document Type" := GenJnlLine3."Document Type";
                        BankAccLedgEntry."Document No." := GenJnlLine3."Document No.";
                        BankAccLedgEntry."External Document No." := GenJnlLine3."External Document No.";
                        BankAccLedgEntry.Description := GenJnlLine3.Description;
                        BankAccLedgEntry."Bank Acc. Posting Group" := BankAcc."Bank Acc. Posting Group";
                        BankAccLedgEntry."Global Dimension 1 Code" := GenJnlLine3."Shortcut Dimension 1 Code";
                        BankAccLedgEntry."Global Dimension 2 Code" := GenJnlLine3."Shortcut Dimension 2 Code";
                        BankAccLedgEntry."Dimension Set ID" := GenJnlLine3."Dimension Set ID";
                        BankAccLedgEntry."Our Contact Code" := GenJnlLine3."Salespers./Purch. Code";
                        BankAccLedgEntry."Source Code" := GenJnlLine3."Source Code";
                        BankAccLedgEntry."Journal Batch Name" := GenJnlLine3."Journal Batch Name";
                        BankAccLedgEntry."Reason Code" := GenJnlLine3."Reason Code";
                        BankAccLedgEntry."Entry No." := NextEntryNo;
                        BankAccLedgEntry."Transaction No." := NextTransactionNo;
                        BankAccLedgEntry."Currency Code" := BankAcc."Currency Code";

                        if BankAcc."Currency Code" <> '' then
                            BankAccLedgEntry.Amount := GenJnlLine3.Amount
                        else
                            BankAccLedgEntry.Amount := GenJnlLine3."Amount (LCY)";

                        BankAccLedgEntry."Amount (LCY)" := GenJnlLine3."Amount (LCY)";
                        BankAccLedgEntry."User ID" := UserId;

                        if BankAccLedgEntry.Amount <> 0 then begin
                            BankAccLedgEntry.Open := true;
                            BankAccLedgEntry."Remaining Amount" := BankAccLedgEntry.Amount;
                        end;

                        BankAccLedgEntry.Positive := BankAccLedgEntry.Amount > 0;
                        BankAccLedgEntry."Bal. Account Type" := GenJnlLine3."Bal. Account Type";
                        BankAccLedgEntry."Bal. Account No." := GenJnlLine3."Bal. Account No.";

                        if (GenJnlLine3.Amount > 0) and (not GenJnlLine3.Correction) or
                           (GenJnlLine3."Amount (LCY)" > 0) and (not GenJnlLine3.Correction) or
                           (GenJnlLine3.Amount < 0) and GenJnlLine3.Correction or
                           (GenJnlLine3."Amount (LCY)" < 0) and GenJnlLine3.Correction
                        then begin
                            BankAccLedgEntry."Debit Amount" := BankAccLedgEntry.Amount;
                            BankAccLedgEntry."Credit Amount" := 0;
                            BankAccLedgEntry."Debit Amount (LCY)" := BankAccLedgEntry."Amount (LCY)";
                            BankAccLedgEntry."Credit Amount (LCY)" := 0;
                        end else begin
                            BankAccLedgEntry."Debit Amount" := 0;
                            BankAccLedgEntry."Credit Amount" := -BankAccLedgEntry.Amount;
                            BankAccLedgEntry."Debit Amount (LCY)" := 0;
                            BankAccLedgEntry."Credit Amount (LCY)" := -BankAccLedgEntry."Amount (LCY)";
                        end;

                        BankAccLedgEntry.Insert();

                        if ((GenJnlLine3.Amount <= 0) and (GenJnlLine3."Bank Payment Type" = GenJnlLine3."Bank Payment Type"::"Computer Check") and GenJnlLine3."Check Printed") or
                           ((GenJnlLine3.Amount < 0) and (GenJnlLine3."Bank Payment Type" = GenJnlLine3."Bank Payment Type"::"Manual Check"))
                        then begin
                            if BankAcc."Currency Code" <> GenJnlLine3."Currency Code" then
                                Error(BankPaymentTypeMustNotBeFilledErr);

                            case GenJnlLine3."Bank Payment Type" of
                                GenJnlLine3."Bank Payment Type"::"Computer Check":
                                    begin
                                        GenJnlLine3.TestField(GenJnlLine3."Check Printed", true);
                                        CheckLedgEntry.LockTable();
                                        CheckLedgEntry.Reset();
                                        CheckLedgEntry.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
                                        CheckLedgEntry.SetRange("Bank Account No.", GenJnlLine3."Account No.");
                                        CheckLedgEntry.SetRange("Entry Status", CheckLedgEntry."Entry Status"::Printed);
                                        CheckLedgEntry.SetRange("Check No.", GenJnlLine3."Document No.");
                                        if CheckLedgEntry.FindSet() then
                                            repeat
                                                CheckLedgEntry2 := CheckLedgEntry;
                                                CheckLedgEntry2."Entry Status" := CheckLedgEntry2."Entry Status"::Posted;
                                                CheckLedgEntry2."Bank Account Ledger Entry No." := BankAccLedgEntry."Entry No.";
                                                CheckLedgEntry2.Modify();
                                            until CheckLedgEntry.Next() = 0;
                                    end;

                                GenJnlLine3."Bank Payment Type"::"Manual Check":
                                    begin
                                        if GenJnlLine3."Document No." = '' then
                                            Error(DocNoMustBeEnteredErr, GenJnlLine3."Bank Payment Type");
                                        CheckLedgEntry.Reset();
                                        if NextCheckEntryNo = 0 then begin
                                            CheckLedgEntry.LockTable();
                                            if CheckLedgEntry.FindLast() then
                                                NextCheckEntryNo := CheckLedgEntry."Entry No." + 1
                                            else
                                                NextCheckEntryNo := 1;
                                        end;

                                        CheckLedgEntry.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
                                        CheckLedgEntry.SetRange("Bank Account No.", GenJnlLine3."Account No.");
                                        CheckLedgEntry.SetFilter(
                                          "Entry Status", '%1|%2|%3',
                                          CheckLedgEntry."Entry Status"::Printed,
                                          CheckLedgEntry."Entry Status"::Posted,
                                          CheckLedgEntry."Entry Status"::"Financially Voided");
                                        CheckLedgEntry.SetRange("Check No.", GenJnlLine3."Document No.");
                                        if CheckLedgEntry.FindFirst() then
                                            Error(CheckAlreadyExistsErr, GenJnlLine3."Document No.");

                                        CheckLedgEntry.Init();
                                        CheckLedgEntry."Entry No." := NextCheckEntryNo;
                                        CheckLedgEntry."Bank Account No." := BankAccLedgEntry."Bank Account No.";
                                        CheckLedgEntry."Bank Account Ledger Entry No." := BankAccLedgEntry."Entry No.";
                                        CheckLedgEntry."Posting Date" := BankAccLedgEntry."Posting Date";
                                        CheckLedgEntry."Document Type" := BankAccLedgEntry."Document Type";
                                        CheckLedgEntry."Document No." := BankAccLedgEntry."Document No.";
                                        CheckLedgEntry."External Document No." := BankAccLedgEntry."External Document No.";
                                        CheckLedgEntry.Description := BankAccLedgEntry.Description;
                                        CheckLedgEntry."Bank Payment Type" := GenJnlLine3."Bank Payment Type";
                                        CheckLedgEntry."Bal. Account Type" := BankAccLedgEntry."Bal. Account Type";
                                        CheckLedgEntry."Bal. Account No." := BankAccLedgEntry."Bal. Account No.";
                                        CheckLedgEntry."Entry Status" := CheckLedgEntry."Entry Status"::Posted;
                                        CheckLedgEntry.Open := true;
                                        CheckLedgEntry."User ID" := UserId;
                                        CheckLedgEntry."Check Date" := BankAccLedgEntry."Posting Date";
                                        CheckLedgEntry."Check No." := BankAccLedgEntry."Document No.";

                                        GenJnlLine1.Reset();
                                        GenJnlLine1.Copy(GenJnlLine);

                                        if GLSetup."Enable Withholding Tax" then
                                            if not GenJnlLine."Skip Withholding Tax" then
                                                CheckLedgEntry."Withholding Tax Amount" := -WithholdingTaxMgmt.WithholdingAmountJournal(GenJnlLine1, false);

                                        CheckLedgEntry."WHT Interest Amount" := GenJnlLine3."WHT Interest Amount";

                                        if BankAcc."Currency Code" <> '' then
                                            CheckLedgEntry.Amount := -GenJnlLine3.Amount - CheckLedgEntry."Withholding Tax Amount"
                                        else
                                            CheckLedgEntry.Amount := -GenJnlLine3."Amount (LCY)" - CheckLedgEntry."Withholding Tax Amount";

                                        CheckLedgEntry.Insert();
                                        NextCheckEntryNo := NextCheckEntryNo + 1;
                                    end;
                            end;
                        end;

                        BankAccPostingGr.TestField("G/L Account No.");
                        sender.InitGLEntry(GenJnlLine, GLEntry,
                          BankAccPostingGr."G/L Account No.", GenJnlLine3."Amount (LCY)", GenJnlLine3."Source Currency Amount", true, true);
                    end;

                GenJnlLine3."Bal. Account Type"::"G/L Account":
                    sender.InitGLEntry(GenJnlLine, GLEntry,
                      GenJnlLine3."Bal. Account No.", GenJnlLine3."Amount (LCY)", GenJnlLine3."Source Currency Amount", true, true);
            end;

            GLEntry."Posting Date" := GenJnlLine3."Posting Date";
            GLEntry."Bal. Account Type" := GenJnlLine3."Bal. Account Type";
            GLEntry."Bal. Account No." := GenJnlLine3."Bal. Account No.";
            sender.InsertGLEntry(GenJnlLine, GLEntry, true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnUnapplyVendLedgEntryOnAfterCreateGLEntriesForTotalAmounts, '', false, false)]
    local procedure OnUnapplyVendLedgEntryOnAfterCreateGLEntriesForTotalAmounts(var GenJournalLine: Record "Gen. Journal Line"; DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; GenJournalLineToPost: Record "Gen. Journal Line"; var NextTaxEntryNo: Integer; var NextEntryNo: Integer; var NextCheckEntryNo: Integer; NextTransactionNo: Integer; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        SourceCodeSetup: Record "Source Code Setup";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
        VoidCheck: Boolean;
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        SourceCodeSetup.Get();

        if GenJournalLine."Source Code" = SourceCodeSetup."Financially Voided Check" then
            VoidCheck := true;

        UnapplyWHTEntry(GenJournalLineToPost, DetailedVendorLedgEntry."Vendor No.", DetailedVendorLedgEntry."Transaction No.", VoidCheck, NextTaxEntryNo, NextEntryNo, NextCheckEntryNo, NextTransactionNo, sender);
    end;

    procedure UnapplyWHTEntry(GenJnlLine: Record "Gen. Journal Line"; CVNo: Code[20]; TransactionNo: Integer; VoidCheck: Boolean; var NextWHTEntryNo: Integer; var NextEntryNo: Integer; var NextCheckEntryNo: Integer; NextTransactionNo: Integer; sender: Codeunit "Gen. Jnl.-Post Line")
    var
        InvoicedWithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingTaxEntry: Record "Withholding Tax Entry";
        NewWithholdingTaxEntry: Record "Withholding Tax Entry";
        UnrealizedWithholdingTaxEntry: Record "Withholding Tax Entry";
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
        UnApplyWithholdingTaxEntries: Record "Withholding Tax Entry";
        Vend: Record Vendor;
        GenJnlLine1: Record "Gen. Journal Line";
        GLSetup: Record "General Ledger Setup";
        Source: Option;
    begin
        GLSetup.Get();

        WithholdingTaxEntry.Reset();
        WithholdingTaxEntry.SetCurrentKey("Transaction Type", "Bill-to/Pay-to No.", "Transaction No.");
        WithholdingTaxEntry.SetRange("Transaction Type", NewWithholdingTaxEntry."Transaction Type"::Purchase);
        WithholdingTaxEntry.SetRange("Bill-to/Pay-to No.", CVNo);
        WithholdingTaxEntry.SetRange("Transaction No.", TransactionNo);
        WithholdingTaxEntry.SetFilter("Document Type", '<>%1', WithholdingTaxEntry."Document Type"::"Credit Memo");
        WithholdingTaxEntry.SetFilter("Unreal. Wthldg. Tax Entry No.", '<>%1', 0);
        if WithholdingTaxEntry.FindSet() then
            repeat
                NewWithholdingTaxEntry := WithholdingTaxEntry;
                NewWithholdingTaxEntry."Closed by Entry No." := 0;
                NewWithholdingTaxEntry.Closed := false;
                NewWithholdingTaxEntry."Posting Date" := GenJnlLine."Posting Date";
                NewWithholdingTaxEntry.Base := -WithholdingTaxEntry.Base;
                NewWithholdingTaxEntry.Amount := -WithholdingTaxEntry.Amount;
                NewWithholdingTaxEntry."Base (LCY)" := -WithholdingTaxEntry."Base (LCY)";
                NewWithholdingTaxEntry."Amount (LCY)" := -WithholdingTaxEntry."Amount (LCY)";
                NewWithholdingTaxEntry."Unrealized Amount" := -WithholdingTaxEntry."Unrealized Amount";
                NewWithholdingTaxEntry."Unrealized Base" := -WithholdingTaxEntry."Unrealized Base";
                NewWithholdingTaxEntry."Remaining Unrealized Amount" := -WithholdingTaxEntry."Remaining Unrealized Amount";
                NewWithholdingTaxEntry."Remaining Unrealized Base" := -WithholdingTaxEntry."Remaining Unrealized Base";
                NewWithholdingTaxEntry."Original Document No." := WithholdingTaxEntry."Document No.";
                NewWithholdingTaxEntry."Transaction No." := NextTransactionNo;
                NewWithholdingTaxEntry."Entry No." := NextWHTEntryNo;
                NextWHTEntryNo := NextWHTEntryNo + 1;
                NewWithholdingTaxEntry.Insert();
                WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");

                if not VoidCheck then begin
                    GenJnlLine1.Copy(GenJnlLine);
                    GenJnlLine1.Amount := -WithholdingTaxEntry.Amount;
                    GenJnlLine1."Amount (LCY)" := -WithholdingTaxEntry."Amount (LCY)";
                    Source := 1;

                    InsertWHTPostingBufferPosted(WithholdingTaxEntry, GenJnlLine1, false, Source, NextEntryNo, NextCheckEntryNo, NextTransactionNo, sender);
                end else begin
                    if GLSetup."Enable Withholding Tax" then
                        if GenJnlLine."Bill-to/Pay-to No." = '' then
                            Vend.Get(GenJnlLine."Account No.")
                        else
                            Vend.Get(GenJnlLine."Bill-to/Pay-to No.");

                    if WithholdingTaxEntry."Amount (LCY)" <> 0 then
                        WithholdingPostingSetup.Get(WithholdingTaxEntry."Wthldg. Tax Bus. Post. Group", WithholdingTaxEntry."Wthldg. Tax Prod. Post. Group");

                    sender.CreateGLEntry(
                      GenJnlLine, WithholdingPostingSetup."Payable Wthldg. Tax Acc. Code", WithholdingTaxEntry."Amount (LCY)", 0, false);
                end;

                UnrealizedWithholdingTaxEntry.Get(WithholdingTaxEntry."Unreal. Wthldg. Tax Entry No.");
                UnrealizedWithholdingTaxEntry."Remaining Unrealized Amount" := UnrealizedWithholdingTaxEntry."Remaining Unrealized Amount" + WithholdingTaxEntry.Amount;
                UnrealizedWithholdingTaxEntry."Remaining Unrealized Base" := UnrealizedWithholdingTaxEntry."Remaining Unrealized Base" + WithholdingTaxEntry.Base;
                UnrealizedWithholdingTaxEntry."Rem Unrealized Amount (LCY)" := UnrealizedWithholdingTaxEntry."Rem Unrealized Amount (LCY)" + WithholdingTaxEntry."Amount (LCY)";
                UnrealizedWithholdingTaxEntry."Rem Unrealized Base (LCY)" := UnrealizedWithholdingTaxEntry."Rem Unrealized Base (LCY)" + WithholdingTaxEntry."Base (LCY)";
                UnrealizedWithholdingTaxEntry.Closed := false;
                UnrealizedWithholdingTaxEntry.Modify();
                WithholdingTaxEntry."Original Document No." := NewWithholdingTaxEntry."Document No.";
                WithholdingTaxEntry.Modify();
            until WithholdingTaxEntry.Next() = 0;

        UnApplyWithholdingTaxEntries.SetLoadFields("Applies-to Entry No.");
        UnApplyWithholdingTaxEntries.SetCurrentKey("Document Type", "Document No.");
        UnApplyWithholdingTaxEntries.SetRange("Document Type", UnApplyWithholdingTaxEntries."Document Type"::"Credit Memo");
        UnApplyWithholdingTaxEntries.SetRange("Document No.", GenJnlLine."Document No.");
        UnApplyWithholdingTaxEntries.SetRange("Bill-to/Pay-to No.", CVNo);
        if UnApplyWithholdingTaxEntries.FindFirst() then
            if InvoicedWithholdingTaxEntry.Get(UnApplyWithholdingTaxEntries."Applies-to Entry No.") then begin
                InvoicedWithholdingTaxEntry."Remaining Unrealized Amount" := InvoicedWithholdingTaxEntry."Unrealized Amount";
                InvoicedWithholdingTaxEntry."Remaining Unrealized Base" := InvoicedWithholdingTaxEntry."Unrealized Base";
                InvoicedWithholdingTaxEntry.Modify(true);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnStartPostingOnAfterSetNextTaxEntryNo, '', false, false)]
    local procedure SetNextTaxEntryNo(var NextTaxEntryNo: Integer)
    var
        WithholdingTaxEntry: Record "Withholding Tax Entry";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        WithholdingTaxEntry.LockTable();

        if WithholdingTaxEntry.FindLast() then
            NextTaxEntryNo := WithholdingTaxEntry."Entry No." + 1
        else
            NextTaxEntryNo := 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnAfterInitGLRegister, '', false, false)]
    local procedure SetFromWithholdingEntryNo(var GLRegister: Record "G/L Register"; NextTaxEntryNo: Integer)
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        GLRegister."From Withholding Tax Entry No." := NextTaxEntryNo;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", OnBeforeUpdateGLReg, '', false, false)]
    local procedure OnBeforeUpdateGLReg(var GLReg: Record "G/L Register"; NextTaxEntryNo: Integer)
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if NextTaxEntryNo <> 0 then
            GLReg."To Withholding Tax Entry No." := NextTaxEntryNo - 1;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", OnBeforeProcessBalanceOfLines, '', false, false)]
    local procedure OnBeforeProcessBalanceOfLines(var GenJournalBatch: Record "Gen. Journal Batch"; var GenJournalLine: Record "Gen. Journal Line"; var GenJournalTemplate: Record "Gen. Journal Template"; var IsKeySet: Boolean)
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        if (IsWHTPaymentPosting(GenJournalLine) or GenJournalTemplate."Force Doc. Balance") then
            GenJournalLine.SetCurrentKey("Document No.", "Posting Date")
        else
            if CheckIfDiffPostingDatesExist(GenJournalBatch, GenJournalLine."Posting Date") then
                GenJournalLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Bal. Account No.");

        IsKeySet := true;
    end;

    local procedure CheckIfDiffPostingDatesExist(GenJournalBatch: Record "Gen. Journal Batch"; PostingDate: Date): Boolean
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetLoadFields("Journal Template Name", "Journal Batch Name", "Posting Date");
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.SetFilter("Posting Date", '<>%1', PostingDate);
        exit(not GenJournalLine.IsEmpty());
    end;

    local procedure IsWHTPaymentPosting(var GenJournalLine: Record "Gen. Journal Line"): Boolean
    var
        GenJournalLineWHT: Record "Gen. Journal Line";
        WithholdingPostingSetup: Record "Withholding Tax Posting Setup";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();

        if not GLSetup."Enable Withholding Tax" then
            exit(false);

        GenJournalLineWHT.Copy(GenJournalLine);
        GenJournalLineWHT.SetRange("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLineWHT.SetRange("Skip Withholding Tax", false);
        GenJournalLineWHT.SetFilter("Applies-to Doc. No.", '<>%1', '');
        if GenJournalLineWHT.FindSet() then
            repeat
                if WithholdingPostingSetup.Get(GenJournalLineWHT."Wthldg. Tax Bus. Post. Group", GenJournalLineWHT."Wthldg. Tax Prod. Post. Group") and
                   (WithholdingPostingSetup."Realized Withholding Tax Type" = WithholdingPostingSetup."Realized Withholding Tax Type"::Payment)
                then
                    exit(true);
            until GenJournalLineWHT.Next() = 0;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", OnAfterProcessBalanceOfLines, '', false, false)]
    local procedure ProcessBalanceOfLines(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        GenJournalLine.SetRange("Is Withholding Tax", false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", OnProcessLinesOnAfterPostGenJournalLine, '', false, false)]
    local procedure OnProcessLinesOnAfterProcessICTransaction(var GenJournalLine: Record "Gen. Journal Line"; CurrentICPartner: Code[20]; ICTransactionNo: Integer; var LastTaxLineNo: Integer; sender: Codeunit "Gen. Jnl.-Post Batch")
    var
        WHTGenJournalLine: Record "Gen. Journal Line";
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        WHTGenJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        WHTGenJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        WHTGenJournalLine.SetRange("Is Withholding Tax", true);
        WHTGenJournalLine.SetRange("System-Created Entry", true);
        WHTGenJournalLine.SetFilter("Line No.", '>%1', LastTaxLineNo);
        if WHTGenJournalLine.FindSet() then
            repeat
                sender.PostGenJournalLines(WHTGenJournalLine, GenJournalLine, CurrentICPartner, ICTransactionNo);
                LastTaxLineNo := WHTGenJournalLine."Line No.";
            until WHTGenJournalLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", OnBeforeFindGenJnlLineOnProcessLines, '', false, false)]
    local procedure OnBeforeFindGenJnlLineOnProcessLines(var GenJournalLine: Record "Gen. Journal Line")
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        GenJournalLine.SetRange("Is Withholding Tax");
        GenJournalLine.FindSet(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Reconciliation Post", OnPostPaymentApplicationsOnAfterPostGenJnlLine, '', false, false)]
    local procedure OnPostPaymentApplicationsOnAfterPostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        WithholdingTaxMgmt: Codeunit "Withholding Tax Mgmt.";
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if not WithholdingTaxMgmt.CheckVendorWithholdingTaxLiable(GenJournalLine) then
            exit;

        PostUnrealizedWHT(GenJournalLine, GenJnlPostLine);
    end;

    local procedure PostUnrealizedWHT(var GenJnlLine: Record "Gen. Journal Line"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        GenJournalLineWHT: Record "Gen. Journal Line";
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Enable Withholding Tax" then
            exit;

        GenJournalLineWHT.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJournalLineWHT.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GenJournalLineWHT.SetRange("Is Withholding Tax", true);
        GenJournalLineWHT.SetRange("System-Created Entry", true);
        if not GenJournalLineWHT.FindFirst() then
            exit;

        GenJnlPostLine.RunWithCheck(GenJournalLineWHT);

        GenJournalLineWHT.Delete();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Reconciliation Post", OnPostPaymentApplicationsOnBeforeValidateApplyRequirements, '', false, false)]
    local procedure OnPostPaymentApplicationsOnBeforeValidateApplyRequirements(var GenJournalLine: Record "Gen. Journal Line")
    begin
        if CheckWithholdingTaxDisabled() then
            exit;

        if (not GeneralLedgerSetup."Enable Withholding Tax") then
            GenJournalLine."Applies-to ID" := '';
    end;

    local procedure CheckWithholdingTaxDisabled(): Boolean
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Enable Withholding Tax" then
            exit(true);

        exit(false);
    end;
}