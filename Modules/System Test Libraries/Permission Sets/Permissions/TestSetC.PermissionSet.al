// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.TestLibraries.Security.AccessControl;

using System.Security.AccessControl;
permissionset 133403 "Test Set C"
{
    Assignable = false;

    IncludedPermissionSets = "Test Set D";

    Permissions = page "Permission Set" = X,
                  page "Permission Set Subform" = X;
}