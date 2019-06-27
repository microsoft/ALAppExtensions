// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
///
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
    [Scope('OnPrem')]
    internal procedure OnBeforeGetDefaultRoleCenter(var RoleCenterId: Integer; var Handled: Boolean)
    begin
    end;
}

