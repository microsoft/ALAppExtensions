codeunit 10896 "Create Source Code FR"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoAuditCode: Codeunit "Contoso Audit Code";
    begin
        ContosoAuditCode.InsertSourceCode(EffetsTok, BillsOfExchangeLbl);
    end;

    procedure Effets(): Code[10]
    begin
        exit(EffetsTok);
    end;

    var
        EffetsTok: Label 'EFFETS', MaxLength = 10, Locked = true;
        BillsOfExchangeLbl: Label 'Bills Of Exchange', MaxLength = 100;
}