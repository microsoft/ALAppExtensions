// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunit that raises an event that could be used to clean up data when copying a company to sandbox environment.
/// </summary>
codeunit 1884 "Sandbox Cleanup"
{
    Access = Public;

    /// <summary>
    /// Subscribe to this event to clean up data when copying a company to a sandbox environment.
    /// </summary>
    /// <param name="CompanyName">The name of the company.</param>
    [Obsolete('Separated into two events for clearing of company-specific data and environment-specific data. OnClearCompanyConfiguration and OnClearDatabaseConfiguration', '17.1')]
    [IntegrationEvent(false, false)]
    internal procedure OnClearConfiguration(CompanyName: Text)
    begin
    end;

    /// <summary>
    /// Subscribe to this event to clean up company-specific data when copying to a sandbox environment.
    /// </summary>
    /// <param name="CompanyName">The name of the company.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnClearCompanyConfiguration(CompanyName: Text)
    begin
    end;

    /// <summary>
    /// Subscribe to this event to clean up environment-specific data when copying to a sandbox environment.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnClearDatabaseConfiguration()
    begin
    end;
}

