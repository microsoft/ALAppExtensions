// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Security.AccessControl;

permissionsetextension 10830 "D365 TEAM MEMBER - FEC" extends "D365 TEAM MEMBER"
{
    IncludedPermissionSets = "FEC - Objects";
}
