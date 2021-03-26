codeunit 4024 "Hybrid BC Last Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerDatabase();
    begin
        OnAfterW1Upgrade();
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterW1Upgrade()
    begin
    end;
}