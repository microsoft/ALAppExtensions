// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.VAT.Setup;

using System.Security.AccessControl;

permissionsetextension 10553 "D365 INTELLIGENT CLOUD - Reverse Charge VAT" extends "INTELLIGENT CLOUD"
{
    IncludedPermissionSets = "Reverse Charge VAT - Objects";
}