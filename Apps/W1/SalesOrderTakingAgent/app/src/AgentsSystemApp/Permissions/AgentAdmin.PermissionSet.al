// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

permissionset 4305 "Agent - Admin"
{
    Assignable = true;
    Caption = 'Agent administrator';

    IncludedPermissionSets = "Agent - Configure";

    Permissions = tabledata Agent = I;
}