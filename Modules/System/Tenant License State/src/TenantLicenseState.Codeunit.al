// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to retrieve the current state of the tenant license.
/// </summary>
codeunit 2300 "Tenant License State"
{
    Access = Public;

    var
        TenantLicenseStateImpl: Codeunit "Tenant License State Impl.";

    /// <summary>
    /// Returns the default number of days that the tenant license can be in the current state, passed as a parameter.
    /// </summary>
    /// <param name="TenantLicenseState">The tenant license state.</param>
    /// <returns>The default number of days that the tenant license can be in the current state, passed as a parameter or -1 if a default period is not defined for the state.</returns>
    procedure GetPeriod(TenantLicenseState: Enum "Tenant License State"): Integer
    begin
        exit(TenantLicenseStateImpl.GetPeriod(TenantLicenseState));
    end;

    /// <summary>
    /// Gets the start date for the current license state.
    /// </summary>
    /// <returns>The start date for the current license state or a blank date if no license state is found.</returns>

    procedure GetStartDate(): DateTime
    begin
        exit(TenantLicenseStateImpl.GetStartDate());
    end;

    /// <summary>
    /// Gets the end date for the current license state.
    /// </summary>
    /// <returns>The end date for the current license state or a blank date if no license state is found.</returns>
    procedure GetEndDate(): DateTime
    begin
        exit(TenantLicenseStateImpl.GetEndDate());
    end;

    /// <summary>
    /// Checks whether the current license state is evaluation.
    /// </summary>
    /// <returns>True if the current license state is evaluation, otherwise false.</returns>
    procedure IsEvaluationMode(): Boolean
    begin
        exit(TenantLicenseStateImpl.IsEvaluationMode());
    end;

    /// <summary>
    /// Checks whether the current license state is trial.
    /// </summary>
    /// <returns>True if the current license state is trial, otherwise false.</returns>
    procedure IsTrialMode(): Boolean
    begin
        exit(TenantLicenseStateImpl.IsTrialMode());
    end;

    /// <summary>
    /// Checks whether the trial license is suspended.
    /// </summary>
    /// <returns>True if the current license state is suspended and the previous license state is trial, otherwise false.</returns>
    procedure IsTrialSuspendedMode(): Boolean
    begin
        exit(TenantLicenseStateImpl.IsTrialSuspendedMode());
    end;

    /// <summary>
    /// Checks whether the trial license has been extended.
    /// </summary>
    /// <returns>True if the current license state is trial and the tenant has had at least one trial license state before, otherwise false.</returns>
    procedure IsTrialExtendedMode(): Boolean
    begin
        exit(TenantLicenseStateImpl.IsTrialExtendedMode());
    end;

    /// <summary>
    /// Checks whether the trial license has been extended and is currently suspended.
    /// </summary>
    /// <returns>True if the current license state is suspended and the tenant has had at least two trial license states before, otherwise false.</returns>
    procedure IsTrialExtendedSuspendedMode(): Boolean
    begin
        exit(TenantLicenseStateImpl.IsTrialExtendedSuspendedMode());
    end;

    /// <summary>
    /// Checks whether the current license state is paid.
    /// </summary>
    /// <returns>True if the current license state is paid, otherwise false.</returns>
    procedure IsPaidMode(): Boolean
    begin
        exit(TenantLicenseStateImpl.IsPaidMode());
    end;

    /// <summary>
    /// Checks whether the paid license is in warning mode.
    /// </summary>
    /// <returns>True if the current license state is warning and the previous license state is paid, otherwise false.</returns>
    procedure IsPaidWarningMode(): Boolean
    begin
        exit(TenantLicenseStateImpl.IsPaidWarningMode());
    end;

    /// <summary>
    /// Checks whether the paid license is suspended.
    /// </summary>
    /// <returns>True if the current license state is suspended and the previous license state is paid, otherwise false.</returns>
    procedure IsPaidSuspendedMode(): Boolean
    begin
        exit(TenantLicenseStateImpl.IsPaidSuspendedMode());
    end;

    /// <summary>
    /// Gets the the current license state.
    /// </summary>
    /// <returns>The the current license state.</returns>
    procedure GetLicenseState(): Enum "Tenant License State"
    begin
        exit(TenantLicenseStateImpl.GetLicenseState());
    end;

    /// <summary>
    /// Extends the trial license.
    /// </summary>
    [Scope('OnPrem')]
    procedure ExtendTrialLicense()
    begin
        TenantLicenseStateImpl.ExtendTrialLicense();
    end;
}