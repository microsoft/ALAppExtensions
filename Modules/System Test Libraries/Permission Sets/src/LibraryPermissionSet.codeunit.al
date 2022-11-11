// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 133401 "Library Permission Set"
{
    Access = Public;

    /// <summary>
    /// Opens the permission set page for the given permission set.
    /// </summary>
    /// <param name="AppId">App ID of the permission set to open</param>
    /// <param name="RoleId">Role ID of the permission set to open</param>
    /// <param name="Name">Name of the permission set to open</param>
    procedure OpenPermissionSetPageForPermissionSet(AppId: Guid; RoleId: Code[30]; Name: Text)
    var
        PermissionSetBuffer: Record "PermissionSet Buffer";
        PermissionSetPage: Page "Permission Set";
    begin
        PermissionSetBuffer.Init();
        PermissionSetBuffer."App ID" := AppId;
        PermissionSetBuffer."Role ID" := RoleId;
        PermissionSetBuffer.Name := CopyStr(Name, 1, MaxStrLen(PermissionSetBuffer.Name));
        PermissionSetBuffer.Scope := PermissionSetBuffer.Scope::Tenant;
        PermissionSetPage.SetRecord(PermissionSetBuffer);
        PermissionSetPage.Run();
    end;
}