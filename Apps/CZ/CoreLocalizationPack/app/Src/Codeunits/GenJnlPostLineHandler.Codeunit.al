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
}