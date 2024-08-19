// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Agents;

permissionset 4304 "Agent - Configure"
{
    Assignable = true;
    Caption = 'Configure agents';

    IncludedPermissionSets = "Agent - Manage Tasks";

    Permissions = tabledata "Agent" = MD,
                  tabledata "Agent Access Control" = IMD;
}