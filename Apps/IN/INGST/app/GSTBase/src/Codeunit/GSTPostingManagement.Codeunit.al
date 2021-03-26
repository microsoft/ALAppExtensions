Codeunit 18015 "GST Posting Management"
{
    SingleInstance = true;

    var
        DetailedGSTLedgerEntry: Record "Detailed GST Ledger Entry";
        RecordIDNotAvailableErr: Label 'Table %1 not handled', comment = '%1 = Table Caption';
        GSTAmountFCY: Decimal;
        GSTBaseAmountFCY: Decimal;
        UseCaseID: Guid;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Document GL Posting", 'OnPrepareTransValueToPost', '', false, false)]
    local procedure SetUseCaseID(var TempTransValue: Record "Tax Transaction Value")
    var
        GSTSetup: Record "GST Setup";
    begin
        if not GSTSetup.Get() then
            exit;

        if GSTSetup."GST Tax Type" = TempTransValue."Tax Type" then
            UseCaseID := TempTransValue."Case ID";
    end;

    procedure GetUseCaseID(): Guid
    begin
        exit(UseCaseID);
    end;

    procedure SetRecord(Record: Variant)
    var
        RecRef: RecordRef;
    begin
        if not Record.IsRecord then
            exit;

        RecRef.GetTable(Record);
        case RecRef.Number of
            database::"Detailed GST Ledger Entry":
                DetailedGSTLedgerEntry := Record;
            else
                Error(RecordIDNotAvailableErr, RecRef.Caption);
        end;
    end;

    procedure GetRecord(var Record: Variant; TableID: Integer)
    begin
        case TableID of
            Database::"Detailed GST Ledger Entry":
                Record := DetailedGSTLedgerEntry
            else
                Error(RecordIDNotAvailableErr, TableID);
        end;
    end;

    procedure SetGSTAmountFCY(FCYAmount: Decimal)
    begin
        GSTAmountFCY := FCYAmount;
    end;

    procedure GetGSTAmountFCY(): Decimal
    begin
        exit(GSTAmountFCY);
    end;

    procedure SetGSTBaseAmountFCY(FCYBaseAmount: Decimal)
    begin
        GSTBaseAmountFCY := FCYBaseAmount;
    end;

    procedure GetGSTBaseAmountFCY(): Decimal
    begin
        exit(GSTBaseAmountFCY);
    end;
}

