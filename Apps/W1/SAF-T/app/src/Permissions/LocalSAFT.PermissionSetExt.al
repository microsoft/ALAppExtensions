// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Security.AccessControl;

permissionsetextension 5285 "LOCAL - SAF-T" extends LOCAL
{
    IncludedPermissionSets = "SAF-T - Read";
}
