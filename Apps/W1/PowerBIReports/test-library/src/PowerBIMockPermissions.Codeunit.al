// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports.Test;

using System.TestLibraries.Security.AccessControl;

codeunit 139793 "Power BI Mock Permissions"
{
    var
        PermissionsMock: Codeunit "Permissions Mock";

    procedure AssignAdminPermissionSet()
    begin
        PermissionsMock.Assign('PowerBI Report Admin');
        PermissionsMock.Assign('D365 BUS FULL ACCESS');
    end;
}