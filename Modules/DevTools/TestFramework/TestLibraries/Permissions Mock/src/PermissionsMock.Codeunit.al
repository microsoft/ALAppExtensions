// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// "Permissions Mock" provides functions that let you simulate any permission set assignment for the current user.
/// </summary>
codeunit 131006 "Permissions Mock"
{
    SingleInstance = true;

    trigger OnRun()
    begin
        if Started then
            Stop()
        else
            Start();
    end;

    var
        PermissionTestHelper: DotNet PermissionTestHelper;
        Started: Boolean;

    /// <summary>
    /// Start mocking Permission Sets.
    /// </summary>
    procedure Start()
    begin
        PermissionTestHelper := PermissionTestHelper.PermissionTestHelper();
        Started := true;
    end;

    /// <summary>
    /// Stop mocking Permission Sets.
    /// </summary>
    procedure Stop()
    begin
        if not Started then
            exit;
        Started := false;
        PermissionTestHelper.Dispose();
    end;

    /// <summary>
    /// Clears all already assigned Permission Sets from the test user.
    /// </summary>
    procedure ClearAssignments()
    begin
        PermissionTestHelper.Clear();
    end;

    /// <summary>
    /// Assigns the given permission set to the test user.
    /// </summary>
    /// <param name="RoleID">The Permission Set to set.</param>
    procedure Assign(RoleID: Code[20])
    var
        PermissionSet: Record "Permission Set";
    begin
        if not Started then
            exit;

        PermissionSet.Get(RoleID);

        PermissionTestHelper.AddEffectivePermissionSet(PermissionSet."Role ID");
    end;

    /// <summary>
    /// Clears all already assigned Permission Sets and Sets the given Permission Set
    /// along side with the All Objects Permission Set that provides execute access to all objects.
    /// </summary>
    /// <param name="RoleID">The Permission Set to set.</param>
    procedure Set(RoleID: Code[20])
    begin
        if not Started then
            exit;

        PermissionTestHelper.Clear();

        Assign('All Objects');
        Assign(RoleID);
    end;

    /// <summary>
    /// Get whether permission sets mocking is started
    /// </summary>
    /// <returns>True if permission sets mocking is started.</returns>
    procedure IsStarted(): Boolean
    begin
        exit(Started);
    end;
}

