codeunit 1156 "COHUB Url Error Handler"
{
    TableNo = "COHUB Enviroment";
    Access = Internal;

    trigger OnRun()
    var
        COHUBCore: Codeunit "COHUB Core";
        SourceRecordRef: RecordRef;
    begin
        SourceRecordRef.GetTable(Rec);
        COHUBCore.LogFailure(GetLastErrorText(), SourceRecordRef);
    end;
}

