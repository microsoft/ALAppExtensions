// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.AuditFileExport;

using System.Security.AccessControl;

permissionsetextension 10832 "LOCAL - FEC" extends LOCAL
{
    IncludedPermissionSets = "FEC - Objects";
}
