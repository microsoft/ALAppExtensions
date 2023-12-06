// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

permissionset 30400 "D365 Intercompany CE"
{
    Access = Public;
    Assignable = true;
    Caption = 'Dynamics 365 Business Central Intercompany Cross Environment';
    IncludedPermissionSets = "Execute All Objects",
                             "Session - Edit",
                             "Data Access IC CE";
}