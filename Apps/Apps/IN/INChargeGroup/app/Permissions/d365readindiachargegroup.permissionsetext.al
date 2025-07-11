// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.ChargeGroup;

using System.Security.AccessControl;

permissionsetextension 18922 "D365 READ - India Charge Group" extends "D365 READ"
{
    IncludedPermissionSets = "D365 Read Access - IN Charge";
}
