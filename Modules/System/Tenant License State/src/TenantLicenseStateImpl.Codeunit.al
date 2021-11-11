// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2301 "Tenant License State Impl."
{
    Access = Internal;
    Permissions = tabledata "Tenant License State" = r;

    var
        TenantLicenseStatePeriodProvider: DotNet TenantLicenseStatePeriodProvider;
        TenantLicenseStateProvider: DotNet TenantLicenseStateProvider;

    procedure GetPeriod(TenantLicenseState: Enum "Tenant License State"): Integer
    var
        TenantLicenseStateValue: Integer;
    begin
        TenantLicenseStateValue := TenantLicenseState.AsInteger();
        exit(TenantLicenseStatePeriodProvider.ALGetPeriod(TenantLicenseStateValue));
    end;

    procedure GetStartDate(): DateTime
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        if TenantLicenseState.FindLast() then
            exit(TenantLicenseState."Start Date");
        exit(0DT);
    end;

    procedure GetEndDate(): DateTime
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        if TenantLicenseState.FindLast() then
            exit(TenantLicenseState."End Date");
        exit(0DT);
    end;

    procedure IsEvaluationMode(): Boolean
    begin
        exit(GetLicenseState() = "Tenant License State"::Evaluation);
    end;

    procedure IsTrialMode(): Boolean
    begin
        exit(GetLicenseState() = "Tenant License State"::Trial);
    end;

    procedure IsTrialSuspendedMode(): Boolean
    var
        CurrentState: Enum "Tenant License State";
        PreviousState: Enum "Tenant License State";
    begin
        CurrentState := GetLicenseState();
        PreviousState := GetPreviousLicenseState(CurrentState);
        exit((CurrentState = "Tenant License State"::Suspended) and (PreviousState = "Tenant License State"::Trial));
    end;

    procedure IsTrialExtendedMode(): Boolean
    begin
        exit((GetTrialExtensions() > 1) and IsTrialMode());
    end;

    procedure IsTrialExtendedSuspendedMode(): Boolean
    begin
        exit((GetTrialExtensions() > 1) and IsTrialSuspendedMode());
    end;

    procedure IsPaidMode(): Boolean
    begin
        exit(GetLicenseState() = "Tenant License State"::Paid);
    end;

    procedure IsPaidWarningMode(): Boolean
    var
        CurrentState: Enum "Tenant License State";
        PreviousState: Enum "Tenant License State";
    begin
        CurrentState := GetLicenseState();
        PreviousState := GetPreviousLicenseState(CurrentState);
        exit((CurrentState = "Tenant License State"::Warning) and (PreviousState = "Tenant License State"::Paid));
    end;

    procedure IsPaidSuspendedMode(): Boolean
    var
        CurrentState: Enum "Tenant License State";
        PreviousState: Enum "Tenant License State";
    begin
        CurrentState := GetLicenseState();
        PreviousState := GetPreviousLicenseState(CurrentState);
        exit((CurrentState = "Tenant License State"::Suspended) and (PreviousState = "Tenant License State"::Paid));
    end;

    local procedure GetTrialExtensions(): Integer
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        TenantLicenseState.SetRange(State, "Tenant License State"::Trial);
        exit(TenantLicenseState.Count());
    end;

    procedure ExtendTrialLicense()
    begin
        TenantLicenseStateProvider.ALExtendTrialLicense();
    end;

    procedure GetLicenseState(): Enum "Tenant License State"
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        if TenantLicenseState.FindLast() then
            exit("Tenant License State".FromInteger(TenantLicenseState.State));
        exit("Tenant License State".FromInteger(TenantLicenseState.State::Evaluation));
    end;

    local procedure GetPreviousLicenseState(CurrentTenantLicenseState: Enum "Tenant License State"): Enum "Tenant License State"
    var
        TenantLicenseState: Record "Tenant License State";
        PreviousTenantLicenseState: Enum "Tenant License State";
    begin
        PreviousTenantLicenseState := "Tenant License State"::Evaluation;

        if CurrentTenantLicenseState in ["Tenant License State"::Warning, "Tenant License State"::Suspended] then begin
            TenantLicenseState.SetAscending("Start Date", false);
            if TenantLicenseState.FindSet() then
                while TenantLicenseState.Next() <> 0 do begin
                    PreviousTenantLicenseState := "Tenant License State".FromInteger(TenantLicenseState.State);
                    if PreviousTenantLicenseState in ["Tenant License State"::Trial, "Tenant License State"::Paid] then
                        exit(PreviousTenantLicenseState);
                end;
        end;

        exit(PreviousTenantLicenseState);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Telemetry Custom Dimensions", 'OnAddCommonCustomDimensions', '', true, true)]
    local procedure OnAddCommonCustomDimensions(var Sender: Codeunit "Telemetry Custom Dimensions")
    begin
        Sender.AddCommonCustomDimension('TenantLicenseState', Format(GetLicenseState()));
    end;
}
