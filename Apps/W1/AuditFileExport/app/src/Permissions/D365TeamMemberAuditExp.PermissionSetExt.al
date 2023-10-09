// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Security.AccessControl;

permissionsetextension 5263 "D365 TEAM MEMBER - Audit Exp." extends "D365 TEAM MEMBER"
{
    IncludedPermissionSets = "Audit Export - Edit";
}
