// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Reporting;

using System.Security.AccessControl;

permissionsetextension 10038 "Local - IRS Forms" extends LOCAL
{
    IncludedPermissionSets = "IRS Forms - Read";
}
