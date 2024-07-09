// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Posting;

using Microsoft.Finance.Deferral;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Calculation;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Finance.VAT.Setup;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;
using System.Utilities;
using System.Security.User;

codeunit 31315 "Gen.Jnl. Post Line Handler CZL"
{
    Permissions = tabledata "VAT Entry" = d,
                  tabledata "G/L Entry - VAT Entry Link" = d;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGlobalGLEntry', '', false, false)]
    local procedure UserChecksAllowedOnBeforeInsertGlobalGLEntry(var GlobalGLEntry: Record "G/L Entry")
    var
        UserSetupAdvManagementCZL: Codeunit "User Setup Adv. Management CZL";
    begin
        if UserSetupAdvManagementCZL.IsCheckAllowed() then
            UserSetupAdvManagementCZL.CheckFiscalYear(GlobalGLEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterFindAmtForAppln', '', false, false)]
    local procedure ExchangeRatesAdjOnAfterFindAmtForAppln(var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var OldCVLedgEntryBuf2: Record "CV Ledger Entry Buffer"; var AppliedAmount: Decimal; var AppliedAmountLCY: Decimal; var OldAppliedAmount: Decimal)
    begin
        if NewCVLedgEntryBuf."Currency Code" = OldCVLedgEntryBuf2."Currency Code" then
            AppliedAmountLCY := Round(AppliedAmount / OldCVLedgEntryBuf."Adjusted Currency Factor")
        else
            if NewCVLedgEntryBuf."Currency Code" <> '' then
                AppliedAmountLCY := Round(OldAppliedAmount / OldCVLedgEntryBuf."Adjusted Currency Factor")
            else
                AppliedAmountLCY := Round(AppliedAmount / NewCVLedgEntryBuf."Adjusted Currency Factor");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterCalcCurrencyRealizedGainLoss', '', false, false)]
    local procedure ExchangeRatesAdjOnAfterCalcCurrencyRealizedGainLoss(var CVLedgEntryBuf: Record "CV Ledger Entry Buffer"; AppliedAmount: Decimal; AppliedAmountLCY: Decimal; var RealizedGainLossLCY: Decimal)
    begin
        RealizedGainLossLCY := AppliedAmountLCY - Round(AppliedAmount / CVLedgEntryBuf."Adjusted Currency Factor");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCalcCurrencyUnrealizedGainLoss', '', false, false)]
    local procedure ExchangeRatesAdjOnBeforeCalcCurrencyUnrealizedGainLoss(var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;

        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostCustOnAfterAssignCurrencyFactors', '', false, false)]
    local procedure ExchangeRatesAdjOnPostCustOnAfterAssignCurrencyFactors(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if (GenJournalLine."Currency Code" <> '') and (GenJournalLine."Amount (LCY)" <> 0) then
            CVLedgerEntryBuffer."Adjusted Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostVendOnAfterAssignCurrencyFactors', '', false, false)]
    local procedure ExchangeRatesAdjOnPostVendOnAfterAssignCurrencyFactors(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer"; GenJournalLine: Record "Gen. Journal Line")
    begin
        if (GenJournalLine."Currency Code" <> '') and (GenJournalLine."Amount (LCY)" <> 0) then
            CVLedgerEntryBuffer."Adjusted Currency Factor" := GenJournalLine.Amount / GenJournalLine."Amount (LCY)";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnCalcPmtDiscOnAfterAssignPmtDisc', '', false, false)]
    local procedure SavePmtDiscOnCalcPmtDiscOnAfterAssignPmtDisc(var OldCVLedgEntryBuf2: Record "CV Ledger Entry Buffer"; var PmtDisc: Decimal; var PmtDiscLCY: Decimal)
    begin
        OldCVLedgEntryBuf2."Orig. Pmt. Disc. CZL" := PmtDisc;
        OldCVLedgEntryBuf2."Orig. Pmt. Disc. (LCY) CZL" := PmtDiscLCY;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnCalcPmtDiscIfAdjVATOnBeforeVATEntryFind', '', false, false)]
    local procedure CalcPmtDiscFactorLCYOnCalcPmtDiscIfAdjVATOnBeforeVATEntryFind(var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var PmtDiscLCY2: Decimal; var PmtDiscFactorLCY: Decimal)
    var
        PmtDiscLCY: Decimal;
    begin
        if not IsAdjustPmtDiscFactorEnabled(OldCVLedgEntryBuf) then
            exit;
        PmtDiscLCY := Round(OldCVLedgEntryBuf."Orig. Pmt. Disc. CZL" / OldCVLedgEntryBuf."Original Currency Factor");
        PmtDiscFactorLCY := PmtDiscLCY / OldCVLedgEntryBuf."Original Amt. (LCY)";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnCalcPmtDiscIfAdjVATOnAfterCalcPmtDiscVATBases', '', false, false)]
    local procedure CorrectPmtDiscLCYOnCalcPmtDiscIfAdjVATOnAfterCalcPmtDiscVATBases(var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var VATEntry: Record "VAT Entry"; var VATBase: Decimal)
    var
        PmtDiscFactorLCY: Decimal;
        VATBase2: Decimal;
    begin
        if not IsAdjustPmtDiscFactorEnabled(OldCVLedgEntryBuf) then
            exit;
        PmtDiscFactorLCY := OldCVLedgEntryBuf."Orig. Pmt. Disc. (LCY) CZL" / OldCVLedgEntryBuf."Original Amt. (LCY)";
        CalcPmtDiscVATBases(VATEntry, VATBase2);
        OldCVLedgEntryBuf."Corr. Pmt. Disc. (LCY) CZL" += Round(VATBase2 * PmtDiscFactorLCY) - VATBase;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnCalcPmtDiscIfAdjVATOnAfterCalcPmtDiscVATAmounts', '', false, false)]
    local procedure CorrectPmtDiscLCYOnCalcPmtDiscIfAdjVATOnAfterCalcPmtDiscVATAmounts(var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var VATEntry: Record "VAT Entry"; var VATBase: Decimal; var VATAmount: Decimal)
    var
        PmtDiscFactorLCY: Decimal;
        VATAmount2: Decimal;
    begin
        if not IsAdjustPmtDiscFactorEnabled(OldCVLedgEntryBuf) then
            exit;
        PmtDiscFactorLCY := OldCVLedgEntryBuf."Orig. Pmt. Disc. (LCY) CZL" / OldCVLedgEntryBuf."Original Amt. (LCY)";
        CalcPmtDiscVATAmounts(VATEntry, VATBase, VATAmount2);
        OldCVLedgEntryBuf."Corr. Pmt. Disc. (LCY) CZL" += Round(VATAmount2 * PmtDiscFactorLCY) - VATAmount;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterCalcPmtDiscIfAdjVAT', '', false, false)]
    local procedure CorrectPmtDiscLCYOnAfterCalcPmtDiscIfAdjVAT(var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var PmtDiscLCY2: Decimal)
    begin
        if not IsAdjustPmtDiscFactorEnabled(OldCVLedgEntryBuf) then
            exit;
        PmtDiscLCY2 += OldCVLedgEntryBuf."Corr. Pmt. Disc. (LCY) CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterPostApply', '', false, false)]
    local procedure CalcRemAmtLCYAdjustmentOnAfterPostApply(GenJnlLine: Record "Gen. Journal Line"; var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        AdjustedAmountLCY: Decimal;
    begin
        if NewCVLedgEntryBuf."Currency Code" = '' then
            exit;
        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Pmt. Disc. Excl. VAT" or not GeneralLedgerSetup."Adjust for Payment Disc." then
            exit;

        AdjustedAmountLCY :=
          Round(NewCVLedgEntryBuf."Remaining Amount" / NewCVLedgEntryBuf."Adjusted Currency Factor");

        if AdjustedAmountLCY = NewCVLedgEntryBuf."Remaining Amt. (LCY)" then
            exit;

        if (AdjustedAmountLCY - NewCVLedgEntryBuf."Remaining Amt. (LCY)") < 0 then
            DtldCVLedgEntryBuf.InitDetailedCVLedgEntryBuf(
              GenJnlLine, NewCVLedgEntryBuf, DtldCVLedgEntryBuf,
              DtldCVLedgEntryBuf."Entry Type"::"Realized Loss", 0, AdjustedAmountLCY - NewCVLedgEntryBuf."Remaining Amt. (LCY)", 0, 0, 0, 0)
        else
            DtldCVLedgEntryBuf.InitDetailedCVLedgEntryBuf(
              GenJnlLine, NewCVLedgEntryBuf, DtldCVLedgEntryBuf,
              DtldCVLedgEntryBuf."Entry Type"::"Realized Gain", 0, AdjustedAmountLCY - NewCVLedgEntryBuf."Remaining Amt. (LCY)", 0, 0, 0, 0);
    end;

    local procedure IsAdjustPmtDiscFactorEnabled(CVLedgEntryBuf: Record "CV Ledger Entry Buffer"): Boolean
    begin
        exit((CVLedgEntryBuf."Orig. Pmt. Disc. CZL" <> 0) or (CVLedgEntryBuf."Orig. Pmt. Disc. (LCY) CZL" <> 0));
    end;

    local procedure CalcPmtDiscVATBases(VATEntry2: Record "VAT Entry"; var VATBase: Decimal)
    var
        VATEntry: Record "VAT Entry";
    begin
        case VATEntry2."VAT Calculation Type" of
            VATEntry2."VAT Calculation Type"::"Normal VAT",
            VATEntry2."VAT Calculation Type"::"Reverse Charge VAT",
            VATEntry2."VAT Calculation Type"::"Full VAT":
                VATBase :=
                  VATEntry2.Base + VATEntry2."Unrealized Base";
            VATEntry2."VAT Calculation Type"::"Sales Tax":
                begin
                    VATEntry.Reset();
                    VATEntry.SetCurrentKey("Transaction No.");
                    VATEntry.SetRange("Transaction No.", VATEntry2."Transaction No.");
                    VATEntry.SetRange("Sales Tax Connection No.", VATEntry2."Sales Tax Connection No.");
                    VATEntry := VATEntry2;
                    repeat
                        if VATEntry.Base < 0 then
                            VATEntry.SetFilter(Base, '>%1', VATEntry.Base)
                        else
                            VATEntry.SetFilter(Base, '<%1', VATEntry.Base);
                    until not VATEntry.FindLast();
                    VATEntry.Reset();
                    VATBase :=
                      VATEntry.Base + VATEntry."Unrealized Base";
                end;
        end;
    end;

    local procedure CalcPmtDiscVATAmounts(VATEntry2: Record "VAT Entry"; VATBase: Decimal; var VATAmount: Decimal)
    begin
        case VATEntry2."VAT Calculation Type" of
            VATEntry2."VAT Calculation Type"::"Normal VAT",
          VATEntry2."VAT Calculation Type"::"Full VAT":
                if (VATEntry2.Amount + VATEntry2."Unrealized Amount" <> 0) or
                   (VATEntry2."Additional-Currency Amount" + VATEntry2."Add.-Currency Unrealized Amt." <> 0)
                then begin
                    if (VATBase = 0) and
                       (VATEntry2."VAT Calculation Type" <> VATEntry2."VAT Calculation Type"::"Full VAT")
                    then
                        VATAmount := 0
                    else
                        VATAmount := VATEntry2.Amount + VATEntry2."Unrealized Amount";
                end else
                    VATAmount := 0;
            VATEntry2."VAT Calculation Type"::"Reverse Charge VAT":
                VATAmount := VATEntry2.Amount + VATEntry2."Unrealized Amount";
            VATEntry2."VAT Calculation Type"::"Sales Tax":
                if (VATEntry2.Type = VATEntry2.Type::Purchase) and VATEntry2."Use Tax" then
                    VATAmount := VATEntry2.Amount + VATEntry2."Unrealized Amount"
                else
                    if (VATEntry2.Amount + VATEntry2."Unrealized Amount" <> 0) or
                       (VATEntry2."Additional-Currency Amount" + VATEntry2."Add.-Currency Unrealized Amt." <> 0)
                    then begin
                        if VATBase = 0 then
                            VATAmount := 0
                        else
                            VATAmount := VATEntry2.Amount + VATEntry2."Unrealized Amount"
                    end else
                        VATAmount := 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCheckDimValueForDisposal', '', false, false)]
    local procedure IsCheckDimensionsEnabledOnBeforeCheckDimValueForDisposal(var GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        IsHandled := not GenJnlLine.IsCheckDimensionsEnabledCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCheckGLAccDimError', '', false, false)]
    local procedure IsCheckDimensionsEnabledOnBeforeCheckGLAccDimError(var GenJournalLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
        if IsHandled then
            exit;
        IsHandled := not GenJournalLine.IsCheckDimensionsEnabledCZL();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCode', '', false, false)]
    local procedure UpdateVatDateOnBeforeCode(var GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."VAT Reporting Date" = 0D then
            GenJnlLine.Validate("VAT Reporting Date", GenJnlLine."Posting Date");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertTempVATEntry', '', false, false)]
    local procedure UpdateVatDateOnBeforeInsertTempVATEntry(var TempVATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        UpdateVATEntryCZL(TempVATEntry, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInsertTempVATEntryOnBeforeInsert', '', false, false)]
    local procedure UpdateVatDateOnInsertTempVATEntryOnBeforeInsert(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VATEntry."VAT Reporting Date" := GenJournalLine."VAT Reporting Date";
        UpdateVATEntryCZL(VATEntry, GenJournalLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertPostUnrealVATEntry', '', false, false)]
    local procedure UpdateVatDateOnBeforeInsertPostUnrealVATEntry(var VATEntry: Record "VAT Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        UpdateVATEntryCZL(VATEntry, GenJournalLine);
    end;

    local procedure UpdateVATEntryCZL(var VATEntry: Record "VAT Entry"; var GenJournalLine: Record "Gen. Journal Line")
    begin
        VATEntry."Original Doc. VAT Date CZL" := GenJournalLine."Original Doc. VAT Date CZL";
        VATEntry."Registration No. CZL" := GenJournalLine."Registration No. CZL";
        VATEntry."Tax Registration No. CZL" := GenJournalLine."Tax Registration No. CZL";
        VATEntry."VAT Settlement No. CZL" := '';
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInsertVATEntry', '', false, false)]
    local procedure DeleteSettlementReverseVATEntryOnAfterInsertVATEntry(VATEntry: Record "VAT Entry"; GLEntryNo: Integer; var NextEntryNo: Integer; var TempGLEntryVATEntryLink: Record "G/L Entry - VAT Entry Link" temporary)
    begin
        if (VATEntry.Type = VATEntry.Type::Settlement) and
           (VATEntry."VAT Calculation Type" = VATEntry."VAT Calculation Type"::"Reverse Charge VAT") and
           (VATEntry."Document Type" = VATEntry."Document Type"::" ") and
           (VATEntry.Base = 0) and (VATEntry.Amount <> 0)
        then begin
            VATEntry.Delete(false);
            TempGLEntryVATEntryLink.Get(GLEntryNo, VATEntry."Entry No.");
            TempGLEntryVATEntryLink.Delete(false);
            NextEntryNo -= 1;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInsertGLEntryBuffer', '', false, false)]
    local procedure UpdateCheckAmountsOnBeforeInsertGLEntryBuffer(var TempGLEntryBuf: Record "G/L Entry")
    var
        GenJnlPostAccGroupCZL: Codeunit "Gen.Jnl. - Post Acc. Group CZL";
    begin
        GenJnlPostAccGroupCZL.UpdateCheckAmounts(TempGLEntryBuf);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterSettingIsTransactionConsistent', '', false, false)]
    local procedure CheckAccountGroupAmountsOnAfterSettingIsTransactionConsistent(var IsTransactionConsistent: Boolean)
    var
        GenJnlPostAccGroupCZL: Codeunit "Gen.Jnl. - Post Acc. Group CZL";
    begin
        IsTransactionConsistent := IsTransactionConsistent and GenJnlPostAccGroupCZL.IsAcountGroupTransactionConsistent();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInitVATOnBeforeVATPostingSetupCheck', '', false, false)]
    local procedure SkipVATCalculationTypeCheckForVATLCYCorrection(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var VATPostingSetup: Record "VAT Posting Setup"; var IsHandled: Boolean)
    begin
        if IsVATLCYCorrectionSourceCodeCZL(GenJournalLine."Source Code") then
            IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInsertVATOnBeforeCreateGLEntryForReverseChargeVATToRevChargeAcc', '', false, false)]
    local procedure SuppressReverseChargePostingForVATLCYCorrection(var GenJournalLine: Record "Gen. Journal Line"; VATPostingSetup: Record "VAT Posting Setup"; UnrealizedVAT: Boolean; var VATAmount: Decimal; var VATAmountAddCurr: Decimal; UseAmountAddCurr: Boolean)
    begin
        if IsVATLCYCorrectionSourceCodeCZL(GenJournalLine."Source Code") then
            VATAmount := 0;
    end;

    local procedure IsVATLCYCorrectionSourceCodeCZL(SrcCode: Code[10]): Boolean
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        if SrcCode = '' then
            exit;
        SourceCodeSetup.Get();
        exit(SourceCodeSetup."VAT LCY Correction CZL" = SrcCode)
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnInsertVATOnAfterAssignVATEntryFields', '', false, false)]
    local procedure SetVATIdentifierCZLOnInsertVATOnAfterAssignVATEntryFields(GenJnlLine: Record "Gen. Journal Line"; var VATEntry: Record "VAT Entry")
    var
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        if GenJnlLine."Gen. Posting Type" = GenJnlLine."Gen. Posting Type"::" " then
            exit;
        if not VATPostingSetup.Get(GenJnlLine."VAT Bus. Posting Group", GenJnlLine."VAT Prod. Posting Group") then
            exit;
        VATEntry."VAT Identifier CZL" := VATPostingSetup."VAT Identifier";
        if VATEntry."Non-Deductible VAT %" <> 0 then
            VATEntry."Original VAT Entry No. CZL" := VATEntry."Entry No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterInitVAT', '', false, false)]
    local procedure UpdateVATAmountOnAfterInitVAT(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
#if not CLEAN24
        GenJournalLineHandler: Codeunit "Gen. Journal Line Handler CZL";
#endif
        IsHandled: Boolean;
    begin
        OnBeforeUpdateVATAmountOnAfterInitVAT(GenJournalLine, GLEntry, IsHandled);
        if IsHandled then
            exit;

#if not CLEAN24
        GenJournalLineHandler.UpdateVATAmountOnAfterInitVAT(GenJournalLine, GLEntry);
#else
        if (GenJournalLine."Gen. Posting Type" = GenJournalLine."Gen. Posting Type"::" ") or
           (GenJournalLine."VAT Posting" <> GenJournalLine."VAT Posting"::"Automatic VAT Entry") or
           (GenJournalLine."VAT Calculation Type" <> GenJournalLine."VAT Calculation Type"::"Normal VAT") or
           (GenJournalLine."VAT Difference" <> 0)
        then
            exit;

        GLEntry.Amount := GenJournalLine."VAT Base Amount (LCY)";
        GLEntry."VAT Amount" := GenJournalLine."VAT Amount (LCY)";
#endif
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeCheckPurchExtDocNoProcedure', '', false, false)]
    local procedure SkipCheckExternalDocumentNoOnBeforeCheckPurchExtDocNoProcedure(var IsHandled: Boolean)
    var
        PersistConfirmResponseCZL: Codeunit "Persist. Confirm Response CZL";
    begin
        if IsHandled then
            exit;

        IsHandled := PersistConfirmResponseCZL.GetPersistentResponse();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforePostDtldCVLedgEntry', '', false, false)]
    local procedure OnBeforePostDtldCVLedgEntry(sender: Codeunit "Gen. Jnl.-Post Line"; var GenJournalLine: Record "Gen. Journal Line"; var DetailedCVLedgEntryBuffer: Record "Detailed CV Ledg. Entry Buffer"; var AccNo: Code[20]; var IsHandled: Boolean; AddCurrencyCode: Code[10]; MultiplePostingGroups: Boolean)
    var
        CustomerPostingGroup: Record "Customer Posting Group";
        VendorPostingGroup: Record "Vendor Posting Group";
        PostingGroupAccountNo: Code[20];
        OldCorrection: Boolean;
    begin
        if IsHandled then
            exit;

        if MultiplePostingGroups and
           (DetailedCVLedgEntryBuffer."Entry Type" = DetailedCVLedgEntryBuffer."Entry Type"::Application)
        then begin
            case GenJournalLine."Account Type" of
                GenJournalLine."Account Type"::Customer:
                    begin
                        CustomerPostingGroup.Get(GenJournalLine."Posting Group");
                        PostingGroupAccountNo := CustomerPostingGroup.GetReceivablesAccount();
                    end;
                GenJournalLine."Account Type"::Vendor:
                    begin
                        VendorPostingGroup.Get(GenJournalLine."Posting Group");
                        PostingGroupAccountNo := VendorPostingGroup.GetPayablesAccount();
                    end;
                else
                    exit;
            end;

            if AccNo = PostingGroupAccountNo then begin
                OldCorrection := GenJournalLine.Correction;
                GenJournalLine.Correction := true;
                sender.CreateGLEntry(GenJournalLine, AccNo, DetailedCVLedgEntryBuffer."Amount (LCY)", 0, DetailedCVLedgEntryBuffer."Currency Code" = AddCurrencyCode);
                GenJournalLine.Correction := OldCorrection;
                IsHandled := true;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostDeferralPostBufferOnAfterFindDeferalPostingBuffer', '', false, false)]
    local procedure GetNonDeductibleVATPctOnPostDeferralPostBufferOnAfterFindDeferalPostingBuffer(GenJournalLine: Record "Gen. Journal Line"; var DeferralPostingBuffer: Record "Deferral Posting Buffer"; var NonDeductibleVATPct: Decimal)
    begin
        NonDeductibleVATPct := GetNonDeductibleVATPct(GenJournalLine, DeferralPostingBuffer."Deferral Doc. Type");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostDeferralOnAfterGetNonDeductibleVATPct', '', false, false)]
    local procedure GetNonDeductibleVATPctOnPostDeferralOnAfterGetNonDeductibleVATPct(GenJournalLine: Record "Gen. Journal Line"; DeferralDocType: Enum "Deferral Document Type"; var NonDeductibleVATPct: Decimal)
    begin
        NonDeductibleVATPct := GetNonDeductibleVATPct(GenJournalLine, DeferralDocType);
    end;

    local procedure GetNonDeductibleVATPct(GenJournalLine: Record "Gen. Journal Line"; DeferralDocType: Enum "Deferral Document Type"): Decimal
    var
        NonDeductibleVATCZL: Codeunit "Non-Deductible VAT CZL";
    begin
        exit(NonDeductibleVATCZL.GetNonDeductibleVATPct(
            GenJournalLine."VAT Bus. Posting Group", GenJournalLine."VAT Prod. Posting Group",
            NonDeductibleVATCZL.GetGeneralPostingTypeFromDeferralDocType(DeferralDocType),
            GenJournalLine."VAT Reporting Date"));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeUpdateVATAmountOnAfterInitVAT(var GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var IsHandled: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterGetCurrencyExchRate', '', false, false)]
    local procedure OnAfterGetCurrencyExchRate(var GenJnlLine: Record "Gen. Journal Line"; var CurrencyFactor: Decimal)
    begin
        if GenJnlLine."Additional Currency Factor CZL" <> 0 then
            CurrencyFactor := GenJnlLine."Additional Currency Factor CZL";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostDeferralPostBufferOnBeforeInsertGLEntryForDeferralAccount', '', false, false)]
    local procedure OnPostDeferralPostBufferOnBeforeInsertGLEntryForDeferralAccount(GenJournalLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry")
    var
        GLEntryasCorrectionCZL: Codeunit "G/L Entry as Correction CZL";
    begin
        if (GLEntry.Amount < 0) and
           (GLEntry."Posting Date" = GenJournalLine."Posting Date") and
           (GLEntry."G/L Account No." = GenJournalLine."Account No.")
        then
            GLEntryasCorrectionCZL.Enable();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostDeferralPostBufferOnAfterInsertGLEntry', '', false, false)]
    local procedure OnPostDeferralPostBufferOnAfterInsertGLEntry()
    var
        GLEntryasCorrectionCZL: Codeunit "G/L Entry as Correction CZL";
    begin
        GLEntryasCorrectionCZL.Disable();
    end;
}
