// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2301 "Tenant License State Impl."
{

    trigger OnRun()
    begin
    end;

    var
        TenantLicenseStatePeriodProvider: DotNet TenantLicenseStatePeriodProvider;
        TenantLicenseStateProvider: DotNet TenantLicenseStateProvider;

    [Scope('OnPrem')]
    procedure GetPeriod(TenantLicenseState: Option): Integer
    begin
        exit(TenantLicenseStatePeriodProvider.ALGetPeriod(TenantLicenseState));
    end;

    [Scope('OnPrem')]
    procedure GetStartDate(): DateTime
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        if TenantLicenseState.FindLast then
          exit(TenantLicenseState."Start Date");
        exit(0DT);
    end;

    [Scope('OnPrem')]
    procedure GetEndDate(): DateTime
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        if TenantLicenseState.FindLast then
          exit(TenantLicenseState."End Date");
        exit(0DT);
    end;

    [Scope('OnPrem')]
    procedure IsEvaluationMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
    begin
        GetLicenseState(CurrentState);
        exit(CurrentState = TenantLicenseState.State::Evaluation);
    end;

    [Scope('OnPrem')]
    procedure IsTrialMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
    begin
        GetLicenseState(CurrentState);
        exit(CurrentState = TenantLicenseState.State::Trial);
    end;

    [Scope('OnPrem')]
    procedure IsTrialSuspendedMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
        PreviousState: Option;
    begin
        GetLicenseState(CurrentState);
        GetPreviousLicenseState(PreviousState,CurrentState);
        exit((CurrentState = TenantLicenseState.State::Suspended) and (PreviousState = TenantLicenseState.State::Trial));
    end;

    [Scope('OnPrem')]
    procedure IsTrialExtendedMode(): Boolean
    begin
        exit((GetTrialExtensions > 1) and IsTrialMode);
    end;

    [Scope('OnPrem')]
    procedure IsTrialExtendedSuspendedMode(): Boolean
    begin
        exit((GetTrialExtensions > 1) and IsTrialSuspendedMode);
    end;

    [Scope('OnPrem')]
    procedure IsPaidMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
    begin
        GetLicenseState(CurrentState);
        exit(CurrentState = TenantLicenseState.State::Paid);
    end;

    [Scope('OnPrem')]
    procedure IsPaidWarningMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
        PreviousState: Option;
    begin
        GetLicenseState(CurrentState);
        GetPreviousLicenseState(PreviousState,CurrentState);
        exit((CurrentState = TenantLicenseState.State::Warning) and (PreviousState = TenantLicenseState.State::Paid));
    end;

    [Scope('OnPrem')]
    procedure IsPaidSuspendedMode(): Boolean
    var
        TenantLicenseState: Record "Tenant License State";
        CurrentState: Option;
        PreviousState: Option;
    begin
        GetLicenseState(CurrentState);
        GetPreviousLicenseState(PreviousState,CurrentState);
        exit((CurrentState = TenantLicenseState.State::Suspended) and (PreviousState = TenantLicenseState.State::Paid));
    end;

    local procedure GetTrialExtensions(): Integer
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        TenantLicenseState.SetRange(State,TenantLicenseState.State::Trial);
        exit(TenantLicenseState.Count);
    end;

    [Scope('OnPrem')]
    procedure ExtendTrialLicense()
    begin
        TenantLicenseStateProvider.ALExtendTrialLicense;
    end;

    [Scope('OnPrem')]
    procedure GetLicenseState(var LicenseState: Option)
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        if TenantLicenseState.FindLast then
          LicenseState := TenantLicenseState.State
        else
          LicenseState := TenantLicenseState.State::Evaluation;
    end;

    local procedure GetPreviousLicenseState(var PreviousTenantLicenseState: Option;CurrentTenantLicenseState: Option)
    var
        TenantLicenseState: Record "Tenant License State";
    begin
        PreviousTenantLicenseState := TenantLicenseState.State::Evaluation;

        if CurrentTenantLicenseState in [TenantLicenseState.State::Warning,TenantLicenseState.State::Suspended] then begin
          TenantLicenseState.SetAscending("Start Date",false);
          if TenantLicenseState.FindSet then
            while TenantLicenseState.Next <> 0 do begin
              PreviousTenantLicenseState := TenantLicenseState.State;
              if PreviousTenantLicenseState in [TenantLicenseState.State::Trial,TenantLicenseState.State::Paid] then
                exit;
            end;
        end;
    end;
}

