// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Environment.Configuration;

permissionset 4753 "RecommApps - Read"
{
    Assignable = false;
    Access = Public;
    Caption = 'RecommendedApps - Read';

    IncludedPermissionSets = "RecommApps - Objects";

    Permissions = tabledata "Recommended Apps" = R;
}
