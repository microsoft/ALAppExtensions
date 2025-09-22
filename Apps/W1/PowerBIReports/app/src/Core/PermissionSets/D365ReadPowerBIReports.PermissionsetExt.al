// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.PowerBIReports;
using System.Security.AccessControl;

permissionsetextension 36952 "D365 READ PowerBI Reports" extends "D365 READ"
{
    IncludedPermissionSets = "PowerBi Report Basic";
}