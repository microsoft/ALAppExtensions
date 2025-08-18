// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Security.AccessControl;

permissionsetextension 10584 "D365 TEAM MEMBER - Reports GB" extends "D365 TEAM MEMBER"
{
    IncludedPermissionSets = "Reports GB - Objects";
}