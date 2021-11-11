// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunit that raises an event that could be used to clean up data when copying a company to new environment.
/// </summary>
codeunit 1886 "Environment Cleanup"
{
    Access = Public;

    /// <summary>
    /// Subscribe to this event to clean up company-specific data when copying to a new environment.
    /// </summary>
    /// <param name="CompanyName">The name of the company.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnClearCompanyConfig(CompanyName: Text; SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    begin
    end;

    /// <summary>
    /// Subscribe to this event to clean up environment-specific data when copying to a new environment.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnClearDatabaseConfig(SourceEnv: Enum "Environment Type"; DestinationEnv: Enum "Environment Type")
    begin
    end;
}

