codeunit 1156 "COHUB Url Error Handler"
{
    TableNo = "COHUB Enviroment";
    Access = Internal;

    trigger OnRun()
    var
        COHUBCore: Codeunit "COHUB Core";
        RecRef: RecordRef;
    begin
        RecRef.GetTable(Rec);
        COHUBCore.LogFailure(GetLastErrorText(), RecRef);
    end;
}

