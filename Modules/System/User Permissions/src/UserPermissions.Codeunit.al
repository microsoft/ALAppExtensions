// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Exposes functionality to check if a user has SUPER permissions set assigned as well as removing such permissions set from a user.
/// </summary>
codeunit 152 "User Permissions"
{
    Access = Public;

    /// <summary>
    /// Checks whether the user has the SUPER permissions set.
    /// </summary>
    /// <param name="UserSecurityId">The security ID assigned to the user.</param>
    /// <returns>True if the user has the SUPER permissions set. Otherwise, false.</returns>
    [Scope('OnPrem')]
    procedure IsSuper(UserSecurityId: Guid): Boolean
    var
        UserPermissionsImpl: Codeunit "User Permissions Impl.";
    begin
        exit(UserPermissionsImpl.IsSuper(UserSecurityId));
    end;

    /// <summary>
    /// Removes the SUPER permissions set from a user.
    /// </summary>
    /// <param name="UserSecurityId">The security ID of the user to modify.</param>  
    [Scope('OnPrem')]
    procedure RemoveSuperPermissions(UserSecurityId: Guid)
    var
        UserPermissionsImpl: Codeunit "User Permissions Impl.";
    begin
        UserPermissionsImpl.RemoveSuperPermissions(UserSecurityId);
    end;
}

