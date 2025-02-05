namespace Microsoft.Finance.Currency;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;

codeunit 31167 "Exch. Rate Adjmt. Mgt. CZL"
{
    procedure AdjustRemainingAmountLCY(var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; GenJournalLine: Record "Gen. Journal Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        AdjustedAmountLCY: Decimal;
        IsHandled: Boolean;
    begin
        OnBeforeAdjustRemainingAmountLCY(NewCVLedgEntryBuf, DtldCVLedgEntryBuf, GenJournalLine, IsHandled);
        if IsHandled then
            exit;

        if NewCVLedgEntryBuf."Currency Code" = '' then
            exit;

        GeneralLedgerSetup.Get();
        if GeneralLedgerSetup."Pmt. Disc. Excl. VAT" or not GeneralLedgerSetup."Adjust for Payment Disc." then
            exit;

        AdjustedAmountLCY := Round(NewCVLedgEntryBuf."Remaining Amount" / NewCVLedgEntryBuf."Adjusted Currency Factor");

        if AdjustedAmountLCY = NewCVLedgEntryBuf."Remaining Amt. (LCY)" then
            exit;

        if (AdjustedAmountLCY - NewCVLedgEntryBuf."Remaining Amt. (LCY)") < 0 then
            DtldCVLedgEntryBuf.InitDetailedCVLedgEntryBuf(
              GenJournalLine, NewCVLedgEntryBuf, DtldCVLedgEntryBuf,
              DtldCVLedgEntryBuf."Entry Type"::"Realized Loss", 0, AdjustedAmountLCY - NewCVLedgEntryBuf."Remaining Amt. (LCY)", 0, 0, 0, 0)
        else
            DtldCVLedgEntryBuf.InitDetailedCVLedgEntryBuf(
              GenJournalLine, NewCVLedgEntryBuf, DtldCVLedgEntryBuf,
              DtldCVLedgEntryBuf."Entry Type"::"Realized Gain", 0, AdjustedAmountLCY - NewCVLedgEntryBuf."Remaining Amt. (LCY)", 0, 0, 0, 0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeAdjustRemainingAmountLCY(var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer"; var DtldCVLedgEntryBuf: Record "Detailed CV Ledg. Entry Buffer"; GenJnlLine: Record "Gen. Journal Line"; var IsHandled: Boolean)
    begin
    end;
}
