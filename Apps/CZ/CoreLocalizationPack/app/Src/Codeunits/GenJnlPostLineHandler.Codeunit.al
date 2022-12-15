codeunit 31315 "Gen.Jnl. Post Line Handler CZL"
{
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
}