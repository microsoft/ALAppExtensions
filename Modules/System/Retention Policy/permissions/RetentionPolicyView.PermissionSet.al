// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DataAdministration;

using System.Environment.Configuration;

/// <summary>
/// this is the minimum permission set needed to install an extension that adds a retention policy.
/// </summary>
permissionset 3901 "Retention Policy - View"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Guided Experience - View",
                             "Retention Policy - Read";

    Permissions = tabledata "Retention Period" = i,
                  tabledata "Retention Policy Allowed Table" = imd,
                  tabledata "Retention Policy Log Entry" = imd,
                  tabledata "Retention Policy Setup" = i,
                  tabledata "Retention Policy Setup Line" = i;
}
