codeunit 4023 "Hybrid BC Last Install"
{
    Subtype = Install;

    trigger OnInstallAppPerDatabase();
    begin
        OnAfterW1Install();
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterW1Install()
    begin
    end;
}