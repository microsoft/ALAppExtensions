codeunit 5112 "Create Jobs Demo Accounts"
{
    TableNo = "Jobs Demo Account";

    trigger OnRun()
    begin
        Rec.ReturnAccountKey(true);



        OnAfterCreateDemoAccounts();
    end;

    var
#pragma warning disable AA0137 // This Codeunit would be used with WIP scenarios
        JobsDemoAccounts: Codeunit "Jobs Demo Accounts";
#pragma warning restore AA0137

    [IntegrationEvent(false, false)]
    local procedure OnAfterCreateDemoAccounts()
    begin
    end;
}