// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Security.AccessControl;

using System.Environment;

permissionset 93 "Company - Edit"
{
    Assignable = false;

    IncludedPermissionSets = "Company - Read";

    Permissions = system "Create a new company" = X,
                  system "Delete a company" = X,
                  system "Rename an existing company" = X,
                  tabledata Company = IMD;
}
