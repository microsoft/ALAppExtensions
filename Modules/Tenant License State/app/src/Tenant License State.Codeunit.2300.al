// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2300 "Tenant License State"
{

    trigger OnRun()
    begin
    end;

    var
        TenantLicenseStateImpl: Codeunit "Tenant License State Impl.";

    procedure GetPeriod(TenantLicenseState: Option): Integer
    begin
        // <summary>
        // Gets the period that is associated with the license state for the tenant.
        // </summary>
        // <param name="TenantLicenseState">The current tenant license state.</param>
        // <returns>The period allowed for the given state or -1 if no period is found.</returns>

        exit(TenantLicenseStateImpl.GetPeriod(TenantLicenseState));
    end;

    procedure GetStartDate(): DateTime
    begin
        // <summary>
        // Gets the start date for the current license state.
        // </summary>
        // <returns>The start date for the current license state or the default start date if no license state is found.</returns>

        exit(TenantLicenseStateImpl.GetStartDate);
    end;

    procedure GetEndDate(): DateTime
    begin
        // <summary>
        // Gets the end date for the current license state.
        // </summary>
        // <returns>The end date for the current license state or the default end date if no license state is found.</returns>

        exit(TenantLicenseStateImpl.GetEndDate);
    end;

    procedure IsEvaluationMode(): Boolean
    begin
        // <summary>
        // Checks whether the current license state is evaluation.
        // </summary>
        // <returns>True if the current license state is evaluation, otherwise false.</returns>

        exit(TenantLicenseStateImpl.IsEvaluationMode);
    end;

    procedure IsTrialMode(): Boolean
    begin
        // <summary>
        // Checks whether the current license state is trial.
        // </summary>
        // <returns>True if the current license state is trial, otherwise false.</returns>

        exit(TenantLicenseStateImpl.IsTrialMode);
    end;

    procedure IsTrialSuspendedMode(): Boolean
    begin
        // <summary>
        // Checks whether the trial license is suspended.
        // </summary>
        // <returns>True if the current license state is suspended and the previous license state is trial, otherwise false.</returns>

        exit(TenantLicenseStateImpl.IsTrialSuspendedMode);
    end;

    procedure IsTrialExtendedMode(): Boolean
    begin
        // <summary>
        // Checks whether the trial license has been extended.
        // </summary>
        // <returns>True if the current license state is trial and the tenant has had at least one trial license state before, otherwise false.</returns>

        exit(TenantLicenseStateImpl.IsTrialExtendedMode);
    end;

    procedure IsTrialExtendedSuspendedMode(): Boolean
    begin
        // <summary>
        // Checks whether the trial license has been extended and is currently suspended.
        // </summary>
        // <returns>True if the current license state is suspended and the tenant has had at least two trial license states before, otherwise false.</returns>

        exit(TenantLicenseStateImpl.IsTrialExtendedSuspendedMode);
    end;

    procedure IsPaidMode(): Boolean
    begin
        // <summary>
        // Checks whether the current license state is paid.
        // </summary>
        // <returns>True if the current license state is paid, otherwise false.</returns>

        exit(TenantLicenseStateImpl.IsPaidMode);
    end;

    procedure IsPaidWarningMode(): Boolean
    begin
        // <summary>
        // Checks whether the paid license is in warning mode.
        // </summary>
        // <returns>True if the current license state is warning and the previous license state is paid, otherwise false.</returns>

        exit(TenantLicenseStateImpl.IsPaidWarningMode);
    end;

    procedure IsPaidSuspendedMode(): Boolean
    begin
        // <summary>
        // Checks whether the paid license is suspended.
        // </summary>
        // <returns>True if the current license state is suspended and the previous license state is paid, otherwise false.</returns>

        exit(TenantLicenseStateImpl.IsPaidSuspendedMode);
    end;

    procedure GetLicenseState(var LicenseState: Option)
    begin
        // <summary>
        // Gets the the current license state.
        // </summary>
        // <param name="LicenseState">The reference to the tenant license state to set (current license state).</param>

        TenantLicenseStateImpl.GetLicenseState(LicenseState);
    end;
}

