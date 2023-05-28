codeunit 5112 "Create Jobs Demo Accounts"
{
    TableNo = "Jobs Demo Account";

    trigger OnRun()
    begin
        Rec.ReturnAccountKey(true);

        JobsDemoAccounts.AddAccount(Rec.WIPCosts(), '2221', XFinishedGoodsTok);

        OnAfterCreateDemoAccounts();
    end;

    var
        JobsDemoAccounts: Codeunit "Jobs Demo Accounts";

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDemoAccounts()
    begin
    end;
}