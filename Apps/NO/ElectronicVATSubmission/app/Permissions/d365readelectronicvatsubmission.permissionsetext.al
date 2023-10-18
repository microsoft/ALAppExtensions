// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Security.AccessControl;

permissionsetextension 10685 "D365 READ - Electronic VAT Submission" extends "D365 READ"
{
    IncludedPermissionSets = "Elec. VAT - Read";
}
