codeunit 31086 "Advance Payments Mgt. CZZ"
{
    Permissions = tabledata "NAV App Installed App" = r;

    var
        AdvancePaymentsFeatureIdTok: Label 'AdvancePaymentsLocalizationForCzech', Locked = true, MaxLength = 50;

    procedure IsEnabled() FeatureEnabled: Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
        if IsTestingEnvironment() then
            exit(false);

        FeatureEnabled := FeatureManagementFacade.IsEnabled(AdvancePaymentsFeatureIdTok);
        OnAfterIsEnabled(FeatureEnabled);
    end;

    procedure TestIsEnabled()
    var
        AdvancePaymentsFeatureNotEnabledErr: Label 'Advance Payments feature is not enabled.\Please enable it using Feature Management before use.';
    begin
        if not IsEnabled() then
            Error(AdvancePaymentsFeatureNotEnabledErr);
    end;

    procedure GetFeatureKey(): Text[50]
    begin
        exit(AdvancePaymentsFeatureIdTok);
    end;

    local procedure IsTestingEnvironment(): Boolean
    var
        NAVAppInstalledApp: Record "NAV App Installed App";
    begin
        exit(NAVAppInstalledApp.Get('74e323c4-70a3-49ce-b18e-fe9ccaff01d3')); // application "Tests-Marketing"
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsEnabled(var FeatureEnabled: Boolean)
    begin
    end;
}
