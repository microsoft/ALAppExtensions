// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.WithholdingTax;

using System.Security.AccessControl;

permissionsetextension 6784 "D365 BUS FULL ACCESS WHT" extends "D365 BUS FULL ACCESS"
{
    IncludedPermissionSets = "WHT - Admin";
}