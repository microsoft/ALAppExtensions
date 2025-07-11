// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Security.AccessControl;

permissionsetextension 10554 "D365 READ - Reverse Charge VAT" extends "D365 READ"
{
    IncludedPermissionSets = "Reverse Charge VAT - Objects";
}