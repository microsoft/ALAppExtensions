// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Security.AccessControl;

permissionsetextension 10686 "D365 TEAM MEMBER - Electronic VAT Submission" extends "D365 TEAM MEMBER"
{
    IncludedPermissionSets = "Elec. VAT - Edit";
}
