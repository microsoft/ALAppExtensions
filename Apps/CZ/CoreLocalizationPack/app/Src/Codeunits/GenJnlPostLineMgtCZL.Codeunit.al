// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.GeneralLedger.Posting;

using Microsoft.Finance.ReceivablesPayables;

codeunit 11703 "Gen. Jnl.-Post Line Mgt. CZL"
{
    internal procedure CalcAppliedAmountLCY(var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var OldCVLedgEntryBuf2: Record "CV Ledger Entry Buffer"; var OldAppliedAmount: Decimal; var AppliedAmount: Decimal; var AppliedAmountLCY: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcAppliedAmountLCY(NewCVLedgEntryBuf, OldCVLedgEntryBuf, OldCVLedgEntryBuf2, OldAppliedAmount, AppliedAmount, AppliedAmountLCY, IsHandled);
        if IsHandled then
            exit;

        if NewCVLedgEntryBuf."Currency Code" = OldCVLedgEntryBuf2."Currency Code" then
            AppliedAmountLCY := Round(AppliedAmount / OldCVLedgEntryBuf."Adjusted Currency Factor")
        else
            if NewCVLedgEntryBuf."Currency Code" <> '' then
                AppliedAmountLCY := Round(OldAppliedAmount / OldCVLedgEntryBuf."Adjusted Currency Factor")
            else
                AppliedAmountLCY := Round(AppliedAmount / NewCVLedgEntryBuf."Adjusted Currency Factor");
    end;

    internal procedure CalcRealizedGainLossLCY(var CVLedgEntryBuf: Record "CV Ledger Entry Buffer"; AppliedAmount: Decimal; AppliedAmountLCY: Decimal; var RealizedGainLossLCY: Decimal)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCalcRealizedGainLossLCY(CVLedgEntryBuf, AppliedAmount, AppliedAmountLCY, RealizedGainLossLCY, IsHandled);
        if IsHandled then
            exit;

        RealizedGainLossLCY := AppliedAmountLCY - Round(AppliedAmount / CVLedgEntryBuf."Adjusted Currency Factor");
    end;

    internal procedure IsCalcCurrencyUnrealizedGainLossSuppressed() IsSuppressed: Boolean
    begin
        IsSuppressed := true;
        OnIsCalcCurrencyUnrealizedGainLossSuppressed(IsSuppressed);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcAppliedAmountLCY(var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var OldCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var OldCVLedgEntryBuf2: Record "CV Ledger Entry Buffer"; var OldAppliedAmount: Decimal; var AppliedAmount: Decimal; var AppliedAmountLCY: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCalcRealizedGainLossLCY(var CVLedgEntryBuf: Record "CV Ledger Entry Buffer"; AppliedAmount: Decimal; AppliedAmountLCY: Decimal; var RealizedGainLossLCY: Decimal; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnIsCalcCurrencyUnrealizedGainLossSuppressed(var IsSuppressed: Boolean)
    begin
    end;
}