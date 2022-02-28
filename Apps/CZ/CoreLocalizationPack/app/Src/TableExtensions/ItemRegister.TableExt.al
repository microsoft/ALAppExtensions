tableextension 31044 "Item Register CZL" extends "Item Register"
{
    procedure FindByEntryNoCZL(EntryNo: Integer): Boolean
    begin
        SetFilter("From Entry No.", '..%1', EntryNo);
        SetFilter("To Entry No.", '%1..', EntryNo);
        exit(FindFirst());
    end;
}