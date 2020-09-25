// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunit that raises an event that can be used to clean up sensitive data, such as sent emails, when copying a company to a sandbox environment.
/// </summary>
codeunit 1884 "Sandbox Cleanup"
{
    Access = Public;

    /// <summary>
    /// Subscribe to this event to clean up data when copying a company to a sandbox environment.
    /// </summary>
    /// <param name="CompanyName">The name of the company.</param>
    [IntegrationEvent(false, false)]
    internal procedure OnClearConfiguration(CompanyName: Text)
    begin
    end;
}

