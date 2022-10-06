codeunit 31086 "Advance Payments Mgt. CZZ"
{
    Permissions = tabledata "NAV App Installed App" = r;

#if not CLEAN21
    var
        AdvancePaymentsFeatureIdTok: Label 'AdvancePaymentsLocalizationForCzech', Locked = true, MaxLength = 50;

    procedure IsEnabled() FeatureEnabled: Boolean
    var
        FeatureManagementFacade: Codeunit "Feature Management Facade";
    begin
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

    [IntegrationEvent(false, false)]
    local procedure OnAfterIsEnabled(var FeatureEnabled: Boolean)
    begin
    end;

#endif

#if not CLEAN19
    procedure DontUseObsoleteAdvancePayments()
    var
        AdvancePaymentsInstalledErr: Label 'Advance Payments Localization for Czech is installed.\Please use this instead of obsoleted version.';
    begin
        Error(AdvancePaymentsInstalledErr);
    end;
#endif
}
