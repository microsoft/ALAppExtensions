codeunit 20236 "Transaction Value Helper"
{
    procedure UpdateCaseID(var SourceRecordRef: RecordRef; TaxType: Code[20]; CaseID: Guid)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
    begin
        TaxTransactionValue.SetRange("Tax Type", TaxType);
        TaxTransactionValue.SetRange("Tax Record ID", SourceRecordRef.RecordId());
        TaxTransactionValue.SetFilter("Case ID", '<>%1', CaseID);
        if not TaxTransactionValue.IsEmpty() then
            TaxTransactionValue.ModifyAll("Case ID", CaseID);
    end;
}