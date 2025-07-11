// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Security.AccessControl;

permissionsetextension 10552 "D365 BASIC - Reverse Charge VAT" extends "D365 BASIC"
{
    IncludedPermissionSets = "Reverse Charge VAT - Objects";
}