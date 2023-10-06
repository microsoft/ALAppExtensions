// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Security.AccessControl;

using System.Security.AccessControl;
permissionset 133401 "Test Set A"
{
    Assignable = true;

    IncludedPermissionSets = "Test Set B",
                             "Test Set C";

    Permissions = codeunit "Permission Set Relation" = X,
                  page "Tenant Permission Subform" = X;
}