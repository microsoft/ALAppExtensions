// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.WithholdingTax;

using System.Security.AccessControl;

permissionsetextension 6786 "D365 Team Member WHT" extends "D365 TEAM MEMBER"
{
    IncludedPermissionSets = "WHT - Edit";
}