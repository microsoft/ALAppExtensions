codeunit 18689 "TDS Entry Update Mgt."
{
    SingleInstance = true;

    var
        TempTDSEntry: Record "TDS Entry" temporary;

    procedure SetTDSEntryForUpdate(TDSEntryToUpdate: Record "TDS Entry")
    begin
        TempTDSEntry := TDSEntryToUpdate;
    end;

    procedure IsTDSEntryUpdateStarted(EntryNo: Integer): Boolean
    begin
        if TempTDSEntry."Entry No." = EntryNo then
            exit(true);
    end;

    procedure GetTDSEntryToUpdateInitialInvoiceAmount(EntryNo: Integer): Decimal
    begin
        if TempTDSEntry."Entry No." = EntryNo then
            exit(TempTDSEntry."Invoice Amount");
    end;

    procedure GetTempTDSEntry(var TDSEntry: Record "TDS Entry")
    begin
        TDSEntry := TempTDSEntry;
    end;

    procedure ResetTempTDSEntry()
    begin
        TempTDSEntry.Reset();
        TempTDSEntry.DeleteAll();
    end;
}