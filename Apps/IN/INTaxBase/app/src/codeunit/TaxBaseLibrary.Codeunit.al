codeunit 18550 "Tax Base Library"
{
    procedure GetTotalTDSIncludingSheCess(DocumentNo: Code[20]; var TotalTDSEncludingSheCess: Decimal; var AccountNo: Code[20]; var EntryNo: Integer)
    begin
        OnAfterGetTotalTDSIncludingSheCess(DocumentNo, TotalTDSEncludingSheCess, AccountNo, EntryNo);
    end;

    procedure ReverseTDSEntry(EntryNo: Integer; TransactionNo: Integer)
    begin
        OnAfterReverseTDSEntry(EntryNo, TransactionNo);
    end;

    procedure GetTDSAmount(GenJournalLine: Record "Gen. Journal Line"; var Amount: Decimal)
    begin
        OnGetTDSAmount(GenJournalLine, Amount);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterGetTotalTDSIncludingSheCess(DocumentNo: Code[20]; var TotalTDSEncludingSheCess: Decimal; var AccountNo: Code[20]; var EntryNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReverseTDSEntry(EntryNo: Integer; TransactionNo: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetTDSAmount(GenJournalLine: Record "Gen. Journal Line"; var Amount: Decimal)
    begin
    end;
}