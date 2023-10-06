#if not CLEAN21
codeunit 31086 "Advance Payments Mgt. CZZ"
{
    Permissions = tabledata "NAV App Installed App" = r;
    ObsoleteReason = 'Advance Payments will be enabled so this code is no longer used.';
    ObsoleteState = Pending;
#pragma warning disable AS0072
    ObsoleteTag = '21.0';
#pragma warning restore AS0072

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

}
#endif
