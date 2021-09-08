// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The codeunit that emits the event that sets the default Role Center.
/// To use another Role Center by default, you must have a profile for it.
/// </summary>
codeunit 9172 "Default Role Center"
{
    Access = Public;

    /// <summary>
    /// Integration event for setting the default Role Center ID.
    /// </summary>
    /// <param name="RoleCenterId">Out parameter holding the Role Center ID.</param>
    /// <param name="Handled">Handled pattern</param>
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeGetDefaultRoleCenter(var RoleCenterId: Integer; var Handled: Boolean)
    begin
    end;
}

