// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

permissionset 4751 "RecommApps - Edit"
{
    Assignable = false;
    Access = Public;
    Caption = 'RecommendedApps - Edit';

    IncludedPermissionSets = "RecommApps - Read";

    Permissions = tabledata "Recommended Apps" = IMD;
}
