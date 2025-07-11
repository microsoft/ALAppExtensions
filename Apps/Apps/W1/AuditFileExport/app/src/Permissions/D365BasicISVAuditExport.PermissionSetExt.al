// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Security.AccessControl;

permissionsetextension 5261 "D365 BASIC ISV - Audit Export" extends "D365 BASIC ISV"
{
    IncludedPermissionSets = "Audit Export - Edit";
}
