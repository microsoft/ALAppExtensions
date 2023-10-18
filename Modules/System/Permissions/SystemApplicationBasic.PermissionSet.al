// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Integration;

permissionset 69 "System Application - Basic"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "System Tables - Basic",
                             "System Application - Edit",
                             "Web Service Management - Admin";
}
