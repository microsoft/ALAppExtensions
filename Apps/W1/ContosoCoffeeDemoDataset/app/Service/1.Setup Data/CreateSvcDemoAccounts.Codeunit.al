codeunit 5102 "Create Svc Demo Accounts"
{
    TableNo = "Svc Demo Account";

    trigger OnRun()
    begin
        Rec.ReturnAccountKey(true);

        SvcDemoAccounts.AddAccount(Rec.Contract(), '6700', XContractRevenueTok);

        OnAfterCreateDemoAccounts();
    end;

    var
        SvcDemoAccounts: Codeunit "Svc Demo Accounts";
        XContractRevenueTok: Label 'Sale of Service Contracts', MaxLength = 50;

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDemoAccounts()
    begin
    end;
}