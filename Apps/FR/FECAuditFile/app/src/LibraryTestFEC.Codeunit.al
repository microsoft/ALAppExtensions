codeunit 10830 "Library - Test FEC"
{
    var
        GenerateFileFEC: Codeunit "Generate File FEC";

    procedure GetLedgerEntryDataForCustVend(TransactionNo: Integer; SourceType: Enum "Gen. Journal Source Type"; var PartyNo: Code[20]; var PartyName: Text[100]; var FCYAmount: Text[250]; var CurrencyCode: Code[10]; var DocNoSet: Text; var DateApplied: Date)
    begin
        GenerateFileFEC.GetLedgerEntryDataForCustVend(TransactionNo, SourceType, PartyNo, PartyName, FCYAmount, CurrencyCode, DocNoSet, DateApplied);
    end;

    procedure InitGlobalVariables(AuditFileExportHeader: Record "Audit File Export Header")
    begin
        GenerateFileFEC.InitGlobalVariables(AuditFileExportHeader);
    end;
}