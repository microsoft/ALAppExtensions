// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.ExcelReports;

using System.Security.AccessControl;

permissionsetextension 4404 "D365 READ - FE Reports" extends "D365 READ"
{
    IncludedPermissionSets = "Excel Reports - Objects";
}
