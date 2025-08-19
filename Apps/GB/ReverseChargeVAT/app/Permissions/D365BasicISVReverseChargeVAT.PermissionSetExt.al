// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Security.AccessControl;

permissionsetextension 10549 "D365 BASIC ISV - Reverse Charge VAT" extends "D365 BASIC ISV"
{
    IncludedPermissionSets = "Reverse Charge VAT - Objects";
}