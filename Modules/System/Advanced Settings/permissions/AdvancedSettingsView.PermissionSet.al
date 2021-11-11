// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

permissionset 9202 "Advanced Settings - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Advanced Settings - Objects",
                             "Extension Management - Read",
                             "Guided Experience - View";
}